//
//  FilePropertyBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    FILE_KIND_DIR = 1,      //目录
    FILE_KIND_FILE = 2,     //文件
    FILE_KIND_OTHER = 3,    //其他
    FILE_KIND_LINK = 4,     //链接
} PROPERTY_KIND;

@interface FilePropertyBean : NSObject

//文件大小
@property float size;
//创建时间
@property long creatTime;
//修改时间
@property long changeTime;
//文件类型
@property PROPERTY_KIND fileKind;

@end
