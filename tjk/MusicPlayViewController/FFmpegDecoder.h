//
//  FFmpegDecoder.h
//  FFmpegAudioTest
//
//  Created by Pontago on 12/06/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"


@interface FFmpegDecoder : NSObject<UIAlertViewDelegate> {
  AVFormatContext *inputFormatContext_;
  AVCodecContext *audioCodecContext_;
  SwrContext* swrContext_;
  AVStream *audioStream_;
  AVPacket packet_, currentPacket_;
    

    CGFloat _audioTimeBase;
    
  NSString *inputFilePath_;
  NSInteger audioStreamIndex_, decodedDataSize_;
  int16_t *audioBuffer_;
  NSUInteger audioBufferSize_;
  BOOL inBuffer_;
   UIAlertView      * _alertview;
   
}

@property AVCodecContext *audioCodecContext_;
@property int16_t *audioBuffer_;
@property BOOL canplay;
+(FFmpegDecoder *)instance;
- (NSInteger)loadFile:(NSString*)filePath;
- (NSTimeInterval)duration;
- (void)seekTime:(NSTimeInterval)seconds;
- (AVPacket*)readPacket;
- (NSInteger)decode;
- (void)nextPacket;

@end
