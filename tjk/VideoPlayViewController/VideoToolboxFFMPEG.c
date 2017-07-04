//
//  VideoToolboxFFMPEG.c
//  tjk
//
//  Created by webber.wang on 15/6/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#include "VideoToolboxFFMPEG.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/pixdesc.h"
#include "libavutil/imgutils.h"
#include "libavcodec/videotoolbox.h"


enum HWAccelID {
    HWACCEL_NONE = 0,
    HWACCEL_AUTO,
    HWACCEL_VDPAU,
    HWACCEL_DXVA2,
    HWACCEL_VDA,
    HWACCEL_VIDEOTOOLBOX,
};

typedef struct HWAccel {
    const char *name;
    int (*init)(AVCodecContext *s);
    enum HWAccelID id;
    enum AVPixelFormat pix_fmt;
} HWAccel;

const HWAccel hwaccels[] = {
    { "videotoolbox",   videotoolbox_init,   HWACCEL_VIDEOTOOLBOX,   AV_PIX_FMT_VIDEOTOOLBOX_VLD },
    { 0 },
};

typedef struct VTContext {
    AVFrame *tmp_frame;
} VTContext;

static void  *hwaccel_ctx = NULL;
enum HWAccelID hwaccel_id = HWACCEL_NONE;
enum HWAccelID active_hwaccel_id = HWACCEL_NONE;
enum AVPixelFormat hwaccel_pix_fmt = AV_PIX_FMT_NONE;

static int videotoolbox_retrieve_data(AVCodecContext *s, AVFrame *frame)
{
    //    InputStream *ist = s->opaque;
    VTContext  *vt = hwaccel_ctx;
    CVPixelBufferRef pixbuf = (CVPixelBufferRef)frame->data[3];
    OSType pixel_format = CVPixelBufferGetPixelFormatType(pixbuf);
    CVReturn err;
    uint8_t *data[4] = { 0 };
    int linesize[4] = { 0 };
    int planes, ret, i;
    
    av_frame_unref(vt->tmp_frame);
    
    switch (pixel_format) {
        case kCVPixelFormatType_420YpCbCr8Planar: vt->tmp_frame->format = AV_PIX_FMT_YUV420P; break;
        case kCVPixelFormatType_422YpCbCr8:       vt->tmp_frame->format = AV_PIX_FMT_UYVY422; break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: vt->tmp_frame->format = AV_PIX_FMT_NV12; break;
        default:
            av_log(NULL, AV_LOG_ERROR,
                   "Unsupported pixel format: %u\n", pixel_format);
            return AVERROR(ENOSYS);
    }
    
    vt->tmp_frame->width  = frame->width;
    vt->tmp_frame->height = frame->height;
    ret = av_frame_get_buffer(vt->tmp_frame, 32);
    if (ret < 0)
        return ret;
    
    err = CVPixelBufferLockBaseAddress(pixbuf, kCVPixelBufferLock_ReadOnly);
    if (err != kCVReturnSuccess) {
        av_log(NULL, AV_LOG_ERROR, "Error locking the pixel buffer.\n");
        return AVERROR_UNKNOWN;
    }
    
    if (CVPixelBufferIsPlanar(pixbuf)) {
        
        planes = CVPixelBufferGetPlaneCount(pixbuf);
        for (i = 0; i < planes; i++) {
            data[i]     = CVPixelBufferGetBaseAddressOfPlane(pixbuf, i);
            linesize[i] = CVPixelBufferGetBytesPerRowOfPlane(pixbuf, i);
        }
    } else {
        data[0] = CVPixelBufferGetBaseAddress(pixbuf);
        linesize[0] = CVPixelBufferGetBytesPerRow(pixbuf);
    }
    
    av_image_copy(vt->tmp_frame->data, vt->tmp_frame->linesize,
                  (const uint8_t **)data, linesize, vt->tmp_frame->format,
                  frame->width, frame->height);
    
    ret = av_frame_copy_props(vt->tmp_frame, frame);
    CVPixelBufferUnlockBaseAddress(pixbuf, kCVPixelBufferLock_ReadOnly);
    if (ret < 0)
        return ret;
    
    av_frame_unref(frame);
    av_frame_move_ref(frame, vt->tmp_frame);
    
    return 0;
}

static void videotoolbox_uninit(AVCodecContext *s)
{
    //    InputStream *ist = s->opaque;
    VTContext  *vt = hwaccel_ctx;
    
    //    ist->hwaccel_uninit        = NULL;
    //    ist->hwaccel_retrieve_data = NULL;
    
    av_frame_free(&vt->tmp_frame);
    
    av_videotoolbox_default_free(s);
    av_freep(hwaccel_ctx);
}

int videotoolbox_init(AVCodecContext *s)
{
    //    InputStream *ist = s->opaque;
    int ret = 0;
    VTContext *vt;
    
    vt = av_mallocz(sizeof(*vt));
    if (!vt)
        return AVERROR(ENOMEM);
    
    //    ist->hwaccel_ctx           = vt;
    hwaccel_ctx = vt;
    //    ist->hwaccel_uninit        = videotoolbox_uninit;
    //    ist->hwaccel_retrieve_data = videotoolbox_retrieve_data;
    
    vt->tmp_frame = av_frame_alloc();
    if (!vt->tmp_frame) {
        ret = AVERROR(ENOMEM);
        goto fail;
    }
    
    ret = av_videotoolbox_default_init(s);
    if (ret < 0) {
        goto fail;
    }
    
    return 0;
fail:
    videotoolbox_uninit(s);
    return ret;
}

static int get_buffer(AVCodecContext *s, AVFrame *frame, int flags)
{
    // NSLog(@"get_buffer")
    //    InputStream *ist = s->opaque;
    
    //    if (ist->hwaccel_get_buffer && frame->format == hwaccel_pix_fmt)
    //        return ist->hwaccel_get_buffer(s, frame, flags);
    
    if (frame->format == hwaccel_pix_fmt) {
        //        NSLog(@"get_buffer got frame format: %d", hwaccel_pix_fmt);
    }
    
    return avcodec_default_get_buffer2(s, frame, flags);
}

static const HWAccel *get_hwaccel(enum AVPixelFormat pix_fmt)
{
    int i;
    for (i = 0; hwaccels[i].name; i++)
        if (hwaccels[i].pix_fmt == pix_fmt)
            return &hwaccels[i];
    return NULL;
}

static enum AVPixelFormat get_format(AVCodecContext *s, const enum AVPixelFormat *pix_fmts)
{
//    NSLog(@"get_format");
    //    InputStream *ist = s->opaque;
    const enum AVPixelFormat *p;
    int ret;
    
    for (p = pix_fmts; *p != -1; p++) {
        const AVPixFmtDescriptor *desc = av_pix_fmt_desc_get(*p);
        const HWAccel *hwaccel;
        
        if (!(desc->flags & AV_PIX_FMT_FLAG_HWACCEL))
            break;
        
        hwaccel = get_hwaccel(*p);
        if (!hwaccel /*||
                      (active_hwaccel_id && active_hwaccel_id != hwaccel->id) ||
                      (hwaccel_id != HWACCEL_AUTO && hwaccel_id != hwaccel->id)*/)
            continue;
        
        ret = hwaccel->init(s);
        if (ret < 0) {
            if (hwaccel_id == hwaccel->id) {
                //                av_log(NULL, AV_LOG_FATAL,
                //                       "%s hwaccel requested for input stream #%d:%d, "
                //                       "but cannot be initialized.\n", hwaccel->name,
                //                       ist->file_index, ist->st->index);
//                NSLog(@"hwaccel->init failed, ret: %d", ret);
                return AV_PIX_FMT_NONE;
            }
            continue;
        }
        active_hwaccel_id = hwaccel->id;
        hwaccel_pix_fmt   = *p;
        break;
    }
    
    return *p;
}

int codecVideoToolboxInit(AVCodecContext *s)
{
    if (!s) {
        return -1;
    }
    
    s->get_format = get_format;
    s->get_buffer2 = get_buffer;
    s->thread_safe_callbacks = 1;
    
    return 0;
}