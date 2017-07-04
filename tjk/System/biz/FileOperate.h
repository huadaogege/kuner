//
//  FileOperate.h
//  KUKE
//
//  Created by 呼啦呼啦圈 on 15/3/25.
//  Copyright (c) 2015年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFileManage.h"

@protocol OperateFiles <NSObject>

-(void)fileActionResult:(BOOL)result userInfo:(id)info;
//-(void)actionError:(int)errorCode userInfo:(id)info;
@end



@interface FileOperate : NSObject<CustomFileBeanDelegate, UIAlertViewDelegate>{
    
    NSMutableArray      *_actionAry;
    NSMutableDictionary *_actionPhotosDic;
    NSString            *_toPath;
    float               _countSize;
    float               _nowSize;
    int                 _photoCount;
    id                  _userInfo;
    float               _tempSize;
    int                 _successCount;
}

@property (assign) id<OperateFiles> delegate;
/*
 拷贝文件到指定位置(沙盒或者外壳)
 beans:需要拷贝的FileBean对象集合
 toPath:目标路径
 info:透传对象
 */
-(void)copyFiles:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info;

-(void)copyFiles:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info alertMsg:(NSString*)title;//增加title参数，提示复制进度的显示
/*
 删除指定位置文件(沙盒或者外壳)
 beans:需要删除的FileBean对象集合
 info:透传对象
 */
-(void)deleteFiles:(NSArray *)beans userInfo:(id)info;
-(void)deleteFiles:(NSArray *)beans userInfo:(id)info  alertMsg:(NSString*)title;

@end