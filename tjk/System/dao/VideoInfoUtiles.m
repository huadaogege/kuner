//
//  VideoInfoUtiles.m
//  KyShellMovieSDK
//
//  Created by 呼啦呼啦圈 on 14-3-27.
//  Copyright (c) 2014年 呼啦呼啦圈. All rights reserved.
//

#import "VideoInfoUtiles.h"
#import "MobClickUtils.h"
#import <AVFoundation/AVFoundation.h>


@implementation VideoInfoUtiles

+ (VideoInfoUtiles *)instance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VideoInfoUtiles alloc] init];
    });
    return instance;
}

- (id)init{
    self = [super init];
    if (self){
        //初始化
        av_register_all();
    }
    return self;
}

-(MediaBean *) captureOneFrame:(NSString *)path
{
    MediaBean *dic = [[MediaBean alloc] init];
    if(![MobClickUtils MobClickIsActive]){
        return dic;
    }
    //文件流 (包括视频, 音频)
    AVFormatContext * _formatCtx;
    
   
    
    //视频流指针
    int videoStream;
    
    //视频流指针
    AVCodecContext *pCodecCtx;
    
    //帧
    AVFrame *pFrame;
    //图像帧
    AVFrame * pFrameRGB;
    //解码
    AVCodec *pCodec;
    
    
    _formatCtx = NULL; // 解决
    pCodecCtx = NULL;
    pFrame = NULL;
    pFrameRGB = NULL;
    pCodec = NULL;
    
    if(!_formatCtx){
        
        _formatCtx = avformat_alloc_context();
    }
    if(!_formatCtx || _formatCtx == NULL){
        return nil;
    }
    //打开视频
    int ret = avformat_open_input(&_formatCtx, [path cStringUsingEncoding: NSUTF8StringEncoding], NULL, NULL);
    if(ret != 0){
        avformat_close_input(&_formatCtx);
        avformat_free_context(_formatCtx);
        return nil;
    }
    //读取信息
    if (avformat_find_stream_info(_formatCtx, NULL) < 0) {
        avformat_close_input(&_formatCtx);
        avformat_free_context(_formatCtx);
        return nil;
    }
    AVDictionaryEntry * album = av_dict_get(_formatCtx->metadata, "album", NULL, 0);
    AVDictionaryEntry * artist = av_dict_get(_formatCtx->metadata, "artist", NULL, 0);
    if(album){
        dic.album = [NSString stringWithFormat:@"%s", album->value];
    }
    if(artist)
        dic.artist = [NSString stringWithFormat:@"%s", artist->value];
    
    if(_formatCtx->duration > 0){
        dic.time = _formatCtx->duration;
    }
    //寻找视频中的视频流
    videoStream = -1;
    for(int i=0; i<_formatCtx->nb_streams; i++){
        if(_formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            videoStream=i;
            break;
        }
    }
    if(videoStream != -1){
        //得到视频流指针
        pCodecCtx = _formatCtx->streams[videoStream]->codec;
        //跳到指定位置
        av_dump_format(_formatCtx, 0, [path.lastPathComponent cStringUsingEncoding: NSUTF8StringEncoding], false);
        // 寻找解码器
        pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
        if(pCodec == NULL){
            avformat_close_input(&_formatCtx);
            avformat_free_context(_formatCtx);
            NSLog(@"error");
            return nil;
        }
        // Inform the codec that we can handle truncated bitstreams -- i.e.,
        // bitstreams where frame boundaries can fall in the middle of packets
        if(pCodec->capabilities & CODEC_CAP_TRUNCATED)
            pCodecCtx->flags|=CODEC_FLAG_TRUNCATED;
        
        // 打开解码器
        if(avcodec_open2(pCodecCtx, pCodec, NULL)<0){
            avformat_close_input(&_formatCtx);
            avformat_free_context(_formatCtx);
            NSLog(@"error");
            return nil;
        }
        pFrame = av_frame_alloc();
        pFrameRGB = av_frame_alloc();
        
        int numBytes = avpicture_get_size(PIX_FMT_BGR24, pCodecCtx->width,pCodecCtx->height);
        uint8_t *buffer;
        buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
        avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);
        int frameFinished = 0;
        //包
        AVPacket packet;
        while(av_read_frame(_formatCtx, &packet)>=0){
            
            if(packet.stream_index == videoStream){
                
                avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
                if(pCodecCtx->pix_fmt < 0)break;
                img_convert((AVPicture *)pFrameRGB, PIX_FMT_RGB24, (AVPicture*)pFrame,
                            pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height);
                UIImage *image = nil;
                NSData * data = [NSData
                                 dataWithBytes:pFrameRGB->data[0]
                                 length:pFrameRGB->linesize[0] * pCodecCtx->height];
                CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(data));//
                if (provider) {
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    if (colorSpace) {
                        CGImageRef imageRef = CGImageCreate(pFrame->width,
                                                            pFrame->height,
                                                            8,
                                                            24,
                                                            pFrameRGB->linesize[0],
                                                            colorSpace,
                                                            kCGBitmapByteOrderDefault,
                                                            provider,
                                                            NULL,
                                                            NO,
                                                            kCGRenderingIntentDefault);
                        
                        if (imageRef != nil) {
                            image = [UIImage imageWithCGImage:imageRef];
                            CGImageRelease(imageRef);
                            CGColorSpaceRelease(colorSpace);
                            CGDataProviderRelease(provider);
                            if(image){
                                dic.img = image;
                                break;
                            }
                        }
                        CGImageRelease(imageRef);
                        CGColorSpaceRelease(colorSpace);
                    }
                    CGDataProviderRelease(provider);
                }
            }
        av_free_packet(&packet);
        }
        av_free(buffer);
        av_frame_free(&pFrame);
        av_frame_free(&pFrameRGB);
        avcodec_close(pCodecCtx);
        pCodecCtx = NULL;
    }

    av_dict_free(&_formatCtx->metadata);
    avformat_close_input(&_formatCtx);
    avformat_free_context(_formatCtx);
    return dic;
}

int img_convert(AVPicture *dst, int dst_pix_fmt,
                const AVPicture *src, int src_pix_fmt,
                int src_width, int src_height){
    
    int w;
    int h;
    struct SwsContext *pSwsCtx;
    
    w = src_width;
    h = src_height;
    pSwsCtx = sws_getContext(w, h, src_pix_fmt,
                             w, h, dst_pix_fmt,
                             SWS_BICUBIC, NULL, NULL, NULL);
    
    sws_scale(pSwsCtx, src->data, src->linesize,
              0, h, dst->data, dst->linesize);
    
    
    //这里释放掉pSwsCtx的内存
    sws_freeContext(pSwsCtx);
    pSwsCtx = NULL;
    
    return 0;
}

- (MediaBean *)captureAudioInfo:(NSString *)path {
    NSURL *url = [FileSystem changeURL:path];
    MediaBean *mediaBean = [[MediaBean alloc] init];
    
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    // 读取文件中的数据
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artist"]) {
                mediaBean.artist = (NSString *)metadataItem.value;
            }
            
            if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
                mediaBean.album = (NSString *)metadataItem.value;
            }
            
            if ([metadataItem.commonKey isEqualToString:@"title"]) {
                
            }
            
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                NSData *imageData = [self getImgDataWithAVMetadataItem:metadataItem];
                mediaBean.img = [UIImage imageWithData:imageData];
                break;
            }
        }
    }
    
    return mediaBean;
}

#pragma mark - private methods

- (NSData *)getImgDataWithAVMetadataItem:(AVMetadataItem *)metaItem
{
    NSData *imgData = nil;
    if ([metaItem.commonKey isEqualToString:@"artwork"]) {
        
        id metaValue = (NSData *)metaItem.value;
        if ([metaValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *itemDic = (NSDictionary *)metaValue;
            if ([itemDic[@"MIME"] rangeOfString:@"image"].length>0) {
                imgData = itemDic[@"data"];
            }
        }
        else if ([metaValue isKindOfClass:[NSData class]])
        {
            imgData = metaValue;
        }
    }
    
    return imgData;
}

@end
