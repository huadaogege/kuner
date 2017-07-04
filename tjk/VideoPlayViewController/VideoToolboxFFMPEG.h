//
//  VideoToolboxFFMPEG.h
//  tjk
//
//  Created by webber.wang on 15/6/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#ifndef __tjk__VideoToolboxFFMPEG__
#define __tjk__VideoToolboxFFMPEG__

#include <stdio.h>
#import "libavcodec/avcodec.h"

int codecVideoToolboxInit(AVCodecContext *s);
int videotoolbox_init(AVCodecContext *s);

#endif /* defined(__tjk__VideoToolboxFFMPEG__) */
