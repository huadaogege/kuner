//
//  FileBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilePropertyBean.h"

typedef enum : NSUInteger {
    FILE_IMG        = 0,
    FILE_GIF        = 1,
    FILE_MOV        = 2,
    FILE_MUSIC      = 3,
    FILE_VIDEO      = 4,
    FILE_DOC        = 5,
    FILE_DIR        = 6,
    FILE_NONE       = 7
} FILE_TYPE;

typedef enum : NSUInteger {
    POSITION_APP        = 0,    //其他APP
    POSITION_DEVICE     = 1,    //设备沙盒
    POSITION_HARDDISK   = 2     //外壳
} FILE_POSITION;



@interface FileBean : NSObject{
    
    FilePropertyBean *_fileInfo;
    long long creatTimeInApp;
}
//路径
@property (readonly, getter=getFilePath) NSString   *filePath;
//名字
@property (readonly, getter=getFileName) NSString   *fileName;
//数据
@property (readonly, getter=getFileData) NSData     *fileData;
//大小
@property (readonly, getter=getFileSize) float      fileSize;
//日期
@property (readonly, getter=getFileDate) float      fileDate;
//日期
@property (readonly, getter=getCreateTime) long      createTime;
//类型
@property (readonly, getter=getFileType) FILE_TYPE  fileType;
@property (readonly, getter=getOriginTypeIsDir) BOOL originTypeIsDir;

-(void)setFilePath:(NSString *)path;
-(void)setFileType:(FILE_TYPE)type;
-(void)setOriginTypeIsDir:(BOOL)isdir;
-(FILE_POSITION)getFilePosition;
-(void)resetFileSize;
@end
