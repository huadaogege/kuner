//
//  CustomCollectionViewController.h
//  tjk
//
//  Created by Ching on 15-3-16.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoInfoUtiles.h"
#import "PhotoClass.h"
#import "BottomEditView.h"

typedef NS_ENUM(NSInteger, PhotoAlbumOperation) {
    PhotoAlbumOperationImportToKe,     // 相册图片导入到ke
    PhotoAlbumOperationExportToPhone,  // 照片导出到手机
};

@protocol CustomecollectionDelegate <NSObject>

- (void)closeView:(BOOL)needRemove;
- (void)changeButtonTitle:(NSString*)title;
- (void)reloadPhoneTitle:(NSString*)titele;

@end

@interface CustomCollectionViewController : UIViewController

@property (nonatomic, weak)  id<CustomecollectionDelegate> delegate;

@property (nonatomic, assign) PhotoAlbumOperation phoAlbumOperation;
@property (nonatomic, assign) BOOL isResVideoType;
@property (nonatomic, assign) typeCode mediaType;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) CustomPhotoGroupBean *customGroupBean;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableDictionary *selectMulDic;

- (void)reloadCollectionView;
- (void)setScrollToBottom:(BOOL)isBottom;

- (void)setPhotoAlbumData:(NSArray *)array;
- (void)initScroll;
// 导出的图片数组
- (void)setExportPhotoData:(NSArray *)array;

- (void)refreshTitle;

@end
