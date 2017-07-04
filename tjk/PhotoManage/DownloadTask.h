//
//  DownloadTask.h
//  tjk
//
//  Created by lipeng.feng on 15/7/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DownloadProgressDelegate <NSObject>

-(void)downloadSuccessedFile:(NSString*)filePath atIndex:(NSInteger)index finish:(BOOL)finish;
-(void)downloadProgress:(NSInteger)downloadSize filepath:(NSString*)filePath atIndex:(NSInteger)index count:(NSInteger)count;
-(void)downloadFailedFile:(NSString*)filePath  atIndex:(NSInteger)index;

@end

//{
//no:0                                  视频编号:int 从0开始一次增加,默认值0
//    , name: "战狼"                    视频名称:string，默认值空字符串
//    , seconds:20                      视频长度:double，单位（秒）默认值0
//    , size:201053                     视频大小:long,单位(字节B),默认值0
//    , url: "XXXXXXXXXXXX"     视频地址:string，默认值字符串
//}

typedef enum : NSUInteger {
    STATUS_DOWNLOAD_PAUSE     = 0,    //暂停
    STATUS_DOWNLOADING        = 1,    //正在下载
    STATUS_DOWNLOAD_WAIT      = 2,    //等待下载
    STATUS_DOWNLOAD_FAILED    = 3,    //下载失败
}DOWNLOAD_STATUS;

typedef enum : NSUInteger {
    DOWN_TYPE_AUDIO     = 0,
    DOWN_TYPE_VIDEO     = 1,
    DOWN_TYPE_PICTURE     = 2,
    DOWN_TYPE_DOCUMENT     = 3,
}DOWNLOAD_TYPE;

@interface DownloadInfo : NSObject
@property(nonatomic,retain)NSString* fpath;
@property(nonatomic,retain)NSString* filepath;
@property(nonatomic,retain)NSString* webURL;
@property(nonatomic,retain)NSNumber* current;
@property(nonatomic,retain)NSNumber* currentDSize;//current download size
@property(nonatomic,retain)NSMutableArray* items;
@property(nonatomic,assign)DOWNLOAD_STATUS status;
@property(nonatomic,assign)DOWNLOAD_TYPE type;
@property(nonatomic,retain)NSString* typeRootPath;
@end

@interface DownloadItemInfo : NSObject
@property(nonatomic,retain)NSNumber* idx;
@property(nonatomic,retain)NSString* dirName;
@property(nonatomic,retain)NSString* name;
@property(nonatomic,retain)NSString* seconds;
@property(nonatomic,retain)NSString* size;
@property(nonatomic,retain)NSString* url;
@end

@interface DownloadTask : NSObject

-(void)downloadFileWith:(DownloadInfo *)info toPath:(NSString *)toPath delegate:(id<DownloadProgressDelegate>)delegate from:(NSInteger)index;
-(NSString*)privatePath;
-(NSInteger)listCount;
-(void)cancel;
-(void)pause;

+(NSString *)dealWithErrorChar:(NSString *)str;
+(NSString *)dealWithPointChar:(NSString *)str deletingPathExtension:(BOOL)isdelete;

@end
