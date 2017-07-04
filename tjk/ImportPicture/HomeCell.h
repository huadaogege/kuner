//
//  HomeCell.h
//  CollectionDemo
//
//  Created by liguiyang on 14-9-2.
//  Copyright (c) 2014年 lgy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLImageView.h"
#import "OLImage.h"
#import "FileBean.h"
#import "VIPhotoView.h"
#import "FilterLoading.h"

#define HOMECELL_GET_IMAGE 555

@interface HomeCell : UICollectionViewCell<UIGestureRecognizerDelegate,UIScrollViewDelegate,FilterLoadingDelegate>

@property (nonatomic ,strong) UIScrollView *gifScrollview;
@property (nonatomic ,strong) UILabel *textLabel;
@property (nonatomic ,strong) UIImageView *imageView;
@property (nonatomic ,strong) UIButton *playBtn;
@property (nonatomic ,strong) UIImageView *playBenBack;
@property (nonatomic ,strong) UIWebView   *webView;
@property (nonatomic ,strong) OLImageView  *olImageView;
@property (nonatomic ,strong) UIScrollView *scrollview;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property int filetype;
@property (nonatomic ,strong) VIPhotoView *photoView;

-(void)addPlayBtn;
-(void)hiddenBtnAndBackView;
-(void)BigPictor:(FileBean *)bean;
-(void)setimage:(UIImage *)img;
-(void)addGif:(NSData*)data;
-(void)addTapGesture;
-(void)addPhotoView:(BOOL)isnotReloadData;
@end
