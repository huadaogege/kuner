//
//  PhotoClass.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, typeCode) {
    TYPE_ALL  = -1,
    TYPE_PHOTO  = 0,
    TYPE_VIDEO  = 1,
    TYPE_GIF    = 2
};

@interface CustomPhotoBean : NSObject{
    
    NSString        *_name;
    float           _length;
    NSUInteger      _photoSize;
}

-(NSUInteger)getExistPhotoSize;
//唯一标识
-(NSString *)getPhotoId;
//日期
-(long long)getDateNumber;
// 获取创建时间
- (NSTimeInterval)getCreateTime;
//视频时间
-(int)videoTime;
//类型
-(typeCode)mediaType;
//小方块图
-(void)getIcon:(void (^)(UIImage *img, NSString *photoId))block;
//全屏图
-(void)getFull:(void (^)(UIImage *img, NSString *photoId))block;
//原始数据
-(void)getImgData:(void (^)(NSData *data, NSString *name, NSString *photoId))block;
//名字
-(void)getPhotoNameAndData:(void (^)(NSString *name,NSInteger size))block;

-(void)getPhotoName:(void (^)(NSString *name))block;
//数据大小
-(void)getPhotoSize:(void (^)(NSUInteger size))block;

//删除照片
-(void)deleteFormPhotos:(void (^)(BOOL isSuccess))block;

@end

@interface CustomPhotoGroupBean : NSObject{
    
    NSString   *_name;
    int         _fileCount;
}
//得到icon
-(void)getIcon:(void (^)(UIImage *img))block withType:(typeCode)mediaType;
//得到图片名字
-(NSString *)getName;
//得到所有元素数量
-(int)getPhotoCount:(typeCode)typecode;

//得到所有图片
-(void)getPhotos:(typeCode)typeCode withBlock:(void (^)(NSArray *allAry))block;
/*
 得到系统的Group对象
 配合getAsset使用, 返回值传入getAsset中, 检测是否是同一个group
 */
-(id)getAsset;
-(BOOL)isThisGroup:(id)flag;
@end




@interface CustomPhoto7_Bean : CustomPhotoBean{
    
    ALAsset     *_asset;
}
-(void)setAsset:(ALAsset *)asset;
@end

@interface CustomPhoto8_Bean : CustomPhotoBean{
    
    NSString        *_photoId;
    PHAsset         *_asset;
    AVPlayerItem    *_playerItem;
    NSData          *_imageData;
}
- (PHAsset *)getAsset;
-(void)setAsset:(PHAsset *)asset;

+(void)deletePhotosWith:(NSArray *)array callback:(void (^)(BOOL isSuccess))block; //删除照片
@end

@interface CustomPhotoGroup8_AllBean : CustomPhotoGroupBean
@end

@interface CustomPhotoGroup8_Bean : CustomPhotoGroupBean{
    
    PHAssetCollection   *_asset;
}
-(void)setAsset:(PHAssetCollection *)asset;

@end

@interface CustomPhotoGroup7_Bean : CustomPhotoGroupBean{
    
    ALAssetsGroup *_asset;
}
-(void)setAsset:(ALAssetsGroup *)asset;
@end