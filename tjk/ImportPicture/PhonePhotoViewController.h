//
//  PhonePhotoViewController.h
//  tjk
//
//  Created by Ching on 15-3-17.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "PhotoClass.h"
#import "PreviewViewController.h"
#import "PhotoOperate.h"
#import "EnumHeader.h"
@class CustomCollectionViewController;

@interface PhonePhotoViewController : UIViewController{
    PreviewViewController               *_homeViewController;
}

@property (nonatomic, weak)   id<OperatePhotos> delegate;
@property (nonatomic, assign) BOOL isOut;
@property (nonatomic, assign) typeCode mediaType;
@property (nonatomic, assign) BOOL isResVideoType;
@property (nonatomic, strong) NSArray *oneOutArr;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSMutableArray * photoPathArray,*tmpPathArray;

- (id)initWithGroupBean:(CustomPhotoGroupBean *)groupBean TypeCode:(typeCode)typeCode;

@end

#pragma mark - UIPhotoAlbumHeaderView

typedef void(^TabClickBlock)(PhotoAlbumHeaderTabClick clickIndex);

@interface UIPhotoAlbumHeaderView : UIView

- (void)setPhotoAblumHeaderTabClick:(TabClickBlock)clickBlock;

@end