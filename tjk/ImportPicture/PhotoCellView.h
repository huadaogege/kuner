//
//  PhotoCellView.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-7-2.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PhotoCellType) {
    PhotoCellTypeNormal,
    PhotoCellTypeDistinguish
};

@interface PhotoCellView : UICollectionViewCell{
    
    NSMutableDictionary *_infoMap;
    
    UIImageView         *_imgView;
    
    UIImageView         *_groupBackImgView;
    UIImageView         *_coverImgView;
    UILabel             *_photoNum;
    UILabel             *_photoName;
    
    UIImageView         *_clickImgV;
    UILabel     *_PicName;
    UIView      *_PickBack;
    UIImageView *vodeoImg;
}
@property (nonatomic ,strong)UILabel *videoTimeLab;
@property (nonatomic ,strong)UIView *videoBackView;
@property (nonatomic ,strong)UIImageView *videoSginImg;
@property (nonatomic ,strong)UIImageView *gifSginImg;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIView *selectView;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, assign) PhotoCellType cellType;

-(void)setImg:(UIImage *)img;
-(UIImage *)getImg;

-(void)setPath:(NSString *)path;

-(void)setVideoTimes:(NSString *)path;

-(void)VideoTime:(NSString*)videoTitle;

-(void)gifSgin;

-(void)videoHidden:(BOOL)hidd;
//瞬变选中状态
-(void)changeIsSelect:(BOOL)isSelect;

-(void)isSelect:(BOOL)isSelect;

-(void)setPhoneImg:(UIImage *)img;

-(void)SetPhotoName:(NSString*)picName;

-(void)videoImg;

-(void)theClickImgHidden:(BOOL)isClick;
// 图片文件夹
//-(void)groupSetImg:(UIImage *)image Tilte:(NSString *)title PhotoNum:(NSString *)photo;
@end

#pragma mark - UICollectionDateViewCell

typedef void(^ClickBlock)(NSInteger index, BOOL isSelected);

@interface UICollectionDateViewCell : UICollectionViewCell

- (void)setDateAttributedContent:(NSAttributedString *)dateStr;
- (void)setDateSelectedFlag:(BOOL)selected;
- (void)setDateClickBlock:(ClickBlock)clickBlock;

@end
