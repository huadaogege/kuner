//
//  MediaBean.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "MediaBean.h"

@implementation MediaBean

-(NSDictionary *)getDic{
    
    return [NSDictionary dictionaryWithObjectsAndKeys:self.album, @"album", self.artist, @"artist", [NSNumber numberWithLongLong:self.time], @"time", nil];
}

@end
