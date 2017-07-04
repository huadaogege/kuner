//
//  PowerBean.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "PowerBean.h"
#include <objc/runtime.h>

@implementation PowerBean

-(NSString *)description{

    return [NSString stringWithFormat:
            @"all = %d\n"
            "surplus = %f\n"
            "speed = %lu\n"
            "current = %d\n"
            "thermal = %d\n"
            "health = %d\n"
            "limit = %d\n"
            "model = %lu\n",
            self.all,
            self.surplus,
            self.speed,
            self.current,
            self.thermal,
            self.health,
            self.limit,
            self.model];
}
@end
