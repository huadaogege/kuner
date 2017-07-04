//
//  FFmpegDecoder.m
//  FFmpegAudioTest
//
//  Created by Pontago on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FFmpegDecoder.h"
#include "libavcodec/avcodec.h"
#include "libavutil/samplefmt.h"
#include "libavutil/opt.h"

#define AVCODEC_MAX_AUDIO_FRAME_SIZE 192000
@implementation FFmpegDecoder

@synthesize audioCodecContext_, audioBuffer_;

static  FFmpegDecoder * obj=nil;
+(FFmpegDecoder *)instance
{
    if (obj==nil)
    {
        obj=[[FFmpegDecoder alloc]init];
    }
    return obj;
}


- (id)init {
    if (self = [super init]) {
    self.canplay=YES;
      av_register_all();

      audioStreamIndex_ = -1;
      audioBufferSize_ = AVCODEC_MAX_AUDIO_FRAME_SIZE;
      audioBuffer_ = (int16_t *)av_malloc(audioBufferSize_);
      swrContext_ = swr_alloc();
      av_init_packet(&packet_);
      inBuffer_ = NO;
    }

    return self;
}
- (void)dealloc {
    if (audioCodecContext_ != NULL) avcodec_close(audioCodecContext_);
    if (inputFormatContext_ != NULL) avformat_close_input(&inputFormatContext_);
    av_free_packet(&packet_);
    av_free(audioBuffer_);
}

static void avStreamFPSTimeBase(AVStream *st, CGFloat defaultTimeBase, CGFloat *pFPS, CGFloat *pTimeBase)
{
    CGFloat fps, timebase;
    
    if (st->time_base.den && st->time_base.num)
        timebase = av_q2d(st->time_base);
    else if(st->codec->time_base.den && st->codec->time_base.num)
        timebase = av_q2d(st->codec->time_base);
    else
        timebase = defaultTimeBase;
    
    if (st->codec->ticks_per_frame != 1) {
        NSLog(@"WARNING: st.codec.ticks_per_frame=%d", st->codec->ticks_per_frame);
        //timebase *= st->codec->ticks_per_frame;
    }
    
    if (st->avg_frame_rate.den && st->avg_frame_rate.num)
        fps = av_q2d(st->avg_frame_rate);
    else if (st->r_frame_rate.den && st->r_frame_rate.num)
        fps = av_q2d(st->r_frame_rate);
    else
        fps = 1.0 / timebase;
    
    if (pFPS)
        *pFPS = fps;
    if (pTimeBase)
        *pTimeBase = timebase;
}
- (NSInteger)loadFile:(NSString*)filePath {
    if (avformat_open_input(&inputFormatContext_, [filePath UTF8String], NULL, NULL) != 0) {
      NSLog(@"Could not load input file.");
      return -1;
    }

    if (avformat_find_stream_info(inputFormatContext_, NULL) < 0) {
      NSLog(@"The file format was not supported. (avformat_find_stream_info)");
      return -2;
    }

    for (NSInteger i = 0; i < inputFormatContext_->nb_streams; i++) {
      if (inputFormatContext_->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
        audioStreamIndex_ = i;
        break;
      }
    }
    
    AVStream *st = inputFormatContext_->streams[audioStreamIndex_];
    avStreamFPSTimeBase(st, 0.025, 0, &_audioTimeBase);
    
    if (audioStreamIndex_ == -1) {
      NSLog(@"Not found aduio stream.");
      return -3;
    }
    else {
      audioStream_ = inputFormatContext_->streams[audioStreamIndex_];
      audioCodecContext_ = audioStream_->codec;

      AVCodec *codec = avcodec_find_decoder(audioCodecContext_->codec_id);
      if (codec == NULL) {
        NSLog(@"Not found audio codec.");
        return -4;
      }
      if (avcodec_open2(audioCodecContext_, codec, NULL) < 0) {
        NSLog(@"Could not open audio codec.");
        return -5;
      }
        
        if (!swrContext_) {
            swrContext_ = swr_alloc();
        }
        
        av_opt_set_int(swrContext_, "in_channel_layout",  audioCodecContext_->channel_layout, 0);
        av_opt_set_int(swrContext_, "out_channel_layout", audioCodecContext_->channel_layout,  0);
        av_opt_set_int(swrContext_, "in_sample_rate",     audioCodecContext_->sample_rate, 0);
        av_opt_set_int(swrContext_, "out_sample_rate",    audioCodecContext_->sample_rate, 0);
        av_opt_set_sample_fmt(swrContext_, "in_sample_fmt",  audioCodecContext_->sample_fmt, 0);
        av_opt_set_sample_fmt(swrContext_, "out_sample_fmt", AV_SAMPLE_FMT_S16,  0);
        
        swr_init(swrContext_);
    }

    inputFilePath_ = filePath;

    return 0;
}

- (NSTimeInterval)duration {
    
   
    return inputFormatContext_ == NULL ? 
      0.0f : (NSTimeInterval)inputFormatContext_->duration / AV_TIME_BASE;
}

- (void)seekTime:(NSTimeInterval)seconds {
    
    if(inputFormatContext_){
        inBuffer_ = NO;
        av_free_packet(&packet_);
        currentPacket_ = packet_;
        
        //    int ret = av_seek_frame(inputFormatContext_, -1, seconds * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
        //    avcodec_flush_buffers(audioCodecContext_);
        //    int ret = av_seek_frame(inputFormatContext_, -1, seconds * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
        avformat_seek_file(inputFormatContext_, -1, seconds * AV_TIME_BASE, seconds * AV_TIME_BASE, seconds * AV_TIME_BASE, AVSEEK_FLAG_BACKWARD);
        avcodec_flush_buffers(audioCodecContext_);
    }
}

- (AVPacket*)readPacket {
    if (currentPacket_.size > 0 || inBuffer_) return &currentPacket_;

    av_free_packet(&packet_);

    for (;;) {
      NSInteger ret = av_read_frame(inputFormatContext_, &packet_);
      if (ret == AVERROR(EAGAIN)) {
        continue;
      }
      else if (ret < 0) {
        return NULL;
      }

      if (packet_.stream_index != audioStreamIndex_) {
        av_free_packet(&packet_);
        continue;
      }

      if (packet_.dts != AV_NOPTS_VALUE) {
        packet_.dts += av_rescale_q(0, AV_TIME_BASE_Q, audioStream_->time_base);
      }
      if (packet_.pts != AV_NOPTS_VALUE) {
        packet_.pts += av_rescale_q(0, AV_TIME_BASE_Q, audioStream_->time_base);
      }

      break;
    }

    currentPacket_ = packet_;

    return &currentPacket_;
}

- (NSInteger)decode {
    if (inBuffer_) return decodedDataSize_;

    decodedDataSize_ = 0;
    AVPacket *packet = [self readPacket];
//    NSLog(@"pts:0x%llx, dts:0x%llx, pos:0x%llx", packet->pts, packet->dts, packet->pos);
    
    AVFrame* recvframe = av_frame_alloc();
    int got_frame = 0;
    
    while (packet && packet->size > 0) {
      if (audioBufferSize_ < FFMAX(packet->size * sizeof(*audioBuffer_), AVCODEC_MAX_AUDIO_FRAME_SIZE)) {
        audioBufferSize_ = FFMAX(packet->size * sizeof(*audioBuffer_), AVCODEC_MAX_AUDIO_FRAME_SIZE);
        av_free(audioBuffer_);
        audioBuffer_ = (int16_t *)av_malloc(audioBufferSize_);
      }

    int len = avcodec_decode_audio4(audioCodecContext_, recvframe, &got_frame, packet);
        
        if (recvframe->format != AV_SAMPLE_FMT_S16) {
            int dest_samples = swr_convert(swrContext_, &audioBuffer_, recvframe->nb_samples, recvframe->extended_data, recvframe->nb_samples);
            
            decodedDataSize_ = dest_samples * recvframe->channels * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16);
        }
        else{
            decodedDataSize_ = recvframe->channels * recvframe->nb_samples * av_get_bytes_per_sample(recvframe->format);
            memcpy(audioBuffer_, recvframe->extended_data[0], decodedDataSize_);
        }
        
        CGFloat position = av_frame_get_best_effort_timestamp(recvframe) * _audioTimeBase;
//        NSLog(@"audio pts:%f", position);
        
//        decodedDataSize_ = audioBufferSize_;
//        NSInteger len = avcodec_decode_audio3(audioCodecContext_, audioBuffer_, &decodedDataSize_, packet);
//        
        
      if (len < 0) {
        
          if (_alertview!=nil) {
              
          }else{
              
              _alertview=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"sorry", @"") message:NSLocalizedString(@"cannotplay", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nextsong", @""), nil];
              _alertview.delegate=self;
              [_alertview show];
              
          }
          [[NSNotificationCenter defaultCenter]postNotificationName:@"canplay" object:nil];
          NSLog(@"Could not decode audio packet.");
          return 0;
      }

      packet->data += len;
      packet->size -= len;

      if (decodedDataSize_ <= 0) {
        NSLog(@"Decoding was completed.");
          NSLog(@"该歌曲解析完成");
        packet = NULL;
     
        return 0;
    }
      inBuffer_ = YES;
      break;
    }

    return decodedDataSize_;
}




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [_alertview removeFromSuperview];
    _alertview = nil;
    if (buttonIndex==0) {
        
    }else{
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"playnextsong" object:nil];
        
    }
    
}

- (void)nextPacket {
    inBuffer_ = NO;
}

@end
