//
//  FileInfoUtiles.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotoClass.h"
#import "FileBean.h"

//相册刷新
#define GROUP_CHANGE_NOTF @"GROUP_CHANGE_NOTF"
//图片刷新
#define ASSET_CHANGE_NOTF @"ASSET_CHANGE_NOTF"

typedef NS_ENUM(NSInteger, resultCode) {
    PHOTO_RESULT_BIGTHAN4G_ERROR = -3,
    PHOTO_RESULT_BIG_ERROR = -2,
    PHOTO_RESULT_ERROR = -1,
    PHOTO_RESULT_FINISH = 0,
    PHOTO_RESULT_CANCE = 1,
    PHOTO_RESULT_NOFREE = 2,
    PHOTO_RESULT_RETRY = 3,
    
};

typedef NS_ENUM(NSInteger, actionCode) {
    PHOTOT_ACTION_COPY = 0,
    PHOTOT_ACTION_DELETE = 1
};

@protocol PhotoInfoUtiles <NSObject>
@optional
//相册图片复制到其他路径时的回调
-(void)actionResult:(CustomPhotoBean *)bean result:(resultCode)result userInfo:(id)info;
-(void)progress:(float)progress bean:(CustomPhotoBean *)bean userInfo:(id)info;
-(void)copyToLocalDone:(FileBean *)bean;

//其他路径文件导入相册时的回调
-(void)creatGroup:(BOOL)result userInfo:(id)info;
-(void)addPhotoToGroup:(BOOL)result userInfo:(id)info bean:(FileBean*)fileBean;
-(void)addPhotoToGroupErrorIs2Big:(BOOL)isBig  userInfo:(id)info bean:(FileBean*)fileBean;
-(void)addPhotoToGroupErrorSpaceNotEnough:(FileBean*)fileBean;
-(void)markCopyingFilePath:(NSString *)copyingPath;

@end

@interface PhotoInfoUtiles : NSObject{
    
    ALAssetsLibrary         *_alLibrary;
    PHFetchResult           *_topLevelUserCollections;
    PHFetchResult           *_systemResult;
}
@property (readonly) ALAssetsLibrary *alLibrary;
+(PhotoInfoUtiles *)instance;
-(void)resetLib;
//得到手机相册分组
-(void)getPhotoGroup:(void (^)(NSArray *ary))block;
-(void)getPhotoGroup:(void (^)(NSArray *ary))block isHiddenSys:(BOOL)isHiden showType:(typeCode)typecode;//是否隐藏系统相册
//将相册图片复制到指定路径
-(void)copyPhoto:(CustomPhotoBean *)bean toPath:(NSString *)toPath delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info;

//创建相册
-(void)creatGroup:(NSString *)name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info;
//导入文件到指定相册
-(void)creatPhoto:(FileBean *)file toGroup:(CustomPhotoGroupBean *)group delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info;
//检查用户是否授权相册
+(BOOL)check;

@end