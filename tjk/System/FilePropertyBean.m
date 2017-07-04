//
//  FilePropertyBean.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "FilePropertyBean.h"

@implementation FilePropertyBean

-(instancetype)init{
    
    self = [super init];
    if(self){
        
        self.size = 0;
        self.creatTime = 0;
        self.changeTime = 0;
        self.fileKind = 0;
    }
    return self;
}

@end
