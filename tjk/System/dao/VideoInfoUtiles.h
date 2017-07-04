//
//  VideoInfoUtiles.h
//  KyShellMovieSDK
//
//  Created by 呼啦呼啦圈 on 14-3-27.
//  Copyright (c) 2014年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavdevice/avdevice.h>
#include "libswscale/swscale.h"

#import "MediaBean.h"

@interface VideoInfoUtiles : NSObject

+ (VideoInfoUtiles *)instance;

//获取音视频信息
- (MediaBean *)captureOneFrame:(NSString *)path;
- (MediaBean *)captureAudioInfo:(NSString *)path;

@end
