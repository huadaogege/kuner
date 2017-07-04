//
//  PhotoOperate.h
//  KUKE
//
//  Created by 呼啦呼啦圈 on 15/3/25.
//  Copyright (c) 2015年 呼啦呼啦圈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoInfoUtiles.h"
#import "CustomFileManage.h"


@protocol OperatePhotos <NSObject>

@optional
-(void)actionResult:(BOOL)result userInfo:(id)info;
@end

@interface PhotoOperate : NSObject<PhotoInfoUtiles, UIAlertViewDelegate>{
    
    NSMutableArray      *_copyAry;
    NSMutableDictionary *_copyPhotosDic;
    NSString            *_toPath;
    NSString            *_processPhotoID;
    NSMutableArray      *_processArray;
    BOOL                _processing;
    NSUInteger          _countSize;
    NSUInteger          _nowSize;
    int                 _photoCount;
    id                  _userInfo;
    NSUInteger          _tempSize;
    BOOL inited;
    NSString *_nowcopyingPath;
}
@property (assign, atomic) int photoCount;;
@property (assign) id<OperatePhotos> delegate;
/*
 将相册里的图片数据, 复制到指定目录下
 beans: CustomPhotoBean对象的集合
 toPath:目标路径
 info:透传对象
 */
-(void)copyPhotos:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info;

/*
 支持Picture_Res_Type，Video_Res_Type
 photos keys(All_Photo,Copyed_Photo,Uncopyed_Photo)
 */

-(void)getCanRemoveResInfo:(ResourceType)resType progress:(void(^)(NSInteger count, NSUInteger size,BOOL finish,NSArray* filebeans,NSDictionary* photos))block;

@end
