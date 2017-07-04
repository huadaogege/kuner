//
//  PathBean.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "PathBean.h"

@implementation PathBean

-(instancetype)init{
    
    self = [super init];
    if(self){
        
        self.dirPathAry = [[NSMutableArray alloc] init];
        self.imgPathAry = [[NSMutableArray alloc] init];
        self.videoPathAry = [[NSMutableArray alloc] init];
        self.musicPathAry = [[NSMutableArray alloc] init];
        self.docPathAry = [[NSMutableArray alloc] init];
        self.nonePathAry = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSInteger)pathCount{
    return self.dirPathAry.count + self.imgPathAry.count + self.videoPathAry.count + self.musicPathAry.count + self.docPathAry.count + self.nonePathAry.count;
}

@end
