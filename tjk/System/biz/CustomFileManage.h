//
//  CustomFileManage.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileBean.h"
#import "MediaBean.h"
#import "PathBean.h"

//获取icon成功的通知
#define GETICON_NOTF @"GETICON_NOTF"
#define LOAD_DIR_DONE_NOTF @"LOAD_DIR_DONE_NOTF"

typedef NS_ENUM(NSInteger, ResourceType) {
    Picture_Res_Type,
    Video_Res_Type,
    Music_Res_Type,
    Document_Res_Type,
    Root_Res_Type,
};

typedef NS_ENUM(NSInteger, RESULTCODE) {
    RESULT_ERROR = -1,
    RESULT_FINISH = 0,
    RESULT_CANCE = 1,
    RESULT_NOFREE = 2,
    RESULT_DONTCOPYTOSELF  = 3,
    RESULT_USER_CANCEL = 4,
};

typedef NS_ENUM(NSInteger, ACTIONCODE) {
    FILE_ACTION_COPY = 0,
    FILE_ACTION_DELETE = 1
};

@protocol CustomFileBeanDelegate <NSObject>

@optional
-(void)actionResult:(ACTIONCODE)action result:(RESULTCODE)result info:(id)info fileBean:(FileBean *)bean;
-(void)progress:(float)progress info:(id)info fileBean:(FileBean *)bean;
-(void)getFileData:(NSData *)data info:(id)info;

@end

@interface CustomFileManage : NSObject{
    
    NSMutableDictionary *_cacheDefaultIconDic;
    NSMutableDictionary *_cacheMediaDic;
    NSMutableDictionary *_cacheIconDic; // 缩略图Data
    NSMutableArray      *_cacheIconAry; // 缩略图Keys(cacheName)
    
    dispatch_queue_t    _dispatchQueue;
    dispatch_queue_t    _dispatchMusicQueue;
    NSMutableArray*     _dispatchMusicArray;
    BOOL                _isCon;
    
    BOOL                _isCache; // 是否缓存数据
    
    NSMutableArray      *_queueAry;
    BOOL                _kukeDeletedCache;
    bool                _isAction;
    NSString            *_currentpath;
}

+(CustomFileManage *)instance;

+(FILE_POSITION)getFilePosition:(NSString*)path;
+(BOOL)isDownloadedDir:(NSString*)path;
+(BOOL)isDownloadedSubDir:(NSString*)path;
+(NSString*)getDownloadDir:(NSString*)name;

-(BOOL)isSystemInited;
-(void)setSystemInited:(BOOL)inited;
//初始化外壳
-(void)initSystem;
//格式化外壳
-(BOOL)formatSystem;
//目录path是否有缓存
-(BOOL)hasCacheWithPath:(NSString*)path;

/*
 指定路径下的 PathBean对象
 key 参考 "字典包含的文件路径分组"
 value 该类型的全路径
 */
- (PathBean *)getFiles:(NSString *)filePath;
- (PathBean *)getFiles:(NSString *)filePath fromPhotoRoot:(BOOL)isfromPhotoRoot;
- (PathBean *)getFilesAsync:(NSString *)filePath;
- (PathBean *)getFiles:(NSString *)filePath getEX:(NSDictionary *)exDic count:(NSInteger)count;

//设置, 是否进行缓存行为
-(void)setCache:(BOOL)isCache;
-(void)insetFile:(NSString*)beanPath isDir:(BOOL)isDir toPath:(NSString*)path;
-(void)insetFile:(NSString*)beanPath isDir:(BOOL)isDir toPath:(NSString*)path fromPhotoRoot:(BOOL)isfromPhotoRoot;
//清理路径缓存
-(void)cleanPathImgFileCache:(NSString *)path;
-(void)cleanPathCache:(NSString *)path;
-(void)cleanPathCacheAll;

//获取方块icon的三种行为.
-(void)getFileIconForBlock:(FileBean *)bean info:(id)info block:(void(^)(UIImage *img, id info))block; //不建议使用

//请求制作文件icon. 制作完成后发送通知 "GETICON_NOTF"
-(void)requestFileIcon:(FileBean *)bean;
-(BOOL)cancelRequest:(NSString *)path;
//获取列表，酷壳之前是否断过
-(void)setKukeDeleteFileCache:(BOOL)deleted;
-(BOOL)isKukeDeletedFileCache;
//获取制作完的icon. 有缓存数量限制
-(UIImage *)getFileIconForCache:(FileBean *)bean;
-(UIImage *)getDefaultIconForCache:(FileBean *)bean resType:(NSInteger)res_type;
-(void)removeFileIconCache:(FileBean *)bean;
-(void)removeFileIconWithPath:(NSString *)filepath filesize:(float)size;
//得到多媒体的信息, 如时间, 作者
-(MediaBean *)getMediaCache:(FileBean *)bean;
//得到缓存icon缩略图的物理文件路径
-(NSString *)getFileIconCacheDir:(NSString *)filePath;
//得到文件data. 同步操作
-(NSData *)getFileData:(NSString *)path;
//得到fileBean对应的文件data. 异步操作
-(void)getFileData:(FileBean *)fileBean delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info;
//删除fileBean对应的物理文件. 异步操作
-(void)deleteFile:(FileBean *)fileBean delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info;
//复制fileBean对应的物理文件. 异步操作
-(void)copyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info;
-(RESULTCODE)actionCopyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend;
//音乐播放
-(void)copyFileMusic:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info;
//检测文件是否存在
-(BOOL)existFile:(NSString *)path;
-(BOOL)existFile:(NSString *)path isDir:(BOOL)isDir;
//创建文件夹
-(int)creatDir:(NSString *)path;
//创建文件夹,不创建缓存
-(int)creatDir:(NSString *)path withCache:(BOOL)withCache;
//删除文件
- (int)removeFileOrDir:(NSString *)path;
- (int)removeFile:(NSString *)path;
- (int)removeFile:(NSString *)path clearCache:(BOOL)isclear;//用于导入时取消 使用
- (int)removeDir:(NSString *)path;
//制作缩略图
-(UIImage *)getRectangular:(UIImage *)img;
-(UIImage *)getSquareImg:(UIImage *)img;
-(UIImage *)zoomImg:(UIImage *)img size:(CGSize)size rect:(CGRect)rect;

//copy专用
-(RESULTCODE)actionCopyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend forMusic:(BOOL)forMusic;

//导出专用
-(RESULTCODE)actionCopyOutFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend forMusic:(BOOL)forMusic;

//文件打开方式 方法
-(BOOL)copyToTempWith:(FileBean *)fileBean;
-(BOOL)cleanThirdOpenTempPathfiles;
-(NSString *)getLibraryTempPath;

@end
