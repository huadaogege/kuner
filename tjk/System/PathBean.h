//
//  PathBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathBean : NSObject

//所有目录 的路径
@property NSMutableArray *dirPathAry;
//所有图片 的路径
@property NSMutableArray *imgPathAry;
//所有视频 的路径
@property NSMutableArray *videoPathAry;
//所有音乐 的路径
@property NSMutableArray *musicPathAry;
//所有文档 的路径
@property NSMutableArray *docPathAry;
//所有未知 
@property NSMutableArray *nonePathAry;

//文件总数
-(NSInteger)pathCount;

@end
