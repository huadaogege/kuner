//
//  PhotoItemCell.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemSelectDelegate.h"
#import "FileBean.h"
enum{
    Edit_None,
    Edit_Select,
    Edit_Export,
}ItemEditType;

@interface PhotoItemCell : UIView
@property(nonatomic,retain) IBOutlet UIImageView* fileImg;
@property(nonatomic,retain) IBOutlet UIImageView* iconImg;
@property(nonatomic,retain) IBOutlet UIImageView* selectImg;
@property(nonatomic,retain) IBOutlet UIView* selectView;
@property(nonatomic,retain) IBOutlet UIButton* selectBtn;
@property(nonatomic,retain) IBOutlet UIView* folderView;
@property(nonatomic,retain) IBOutlet UILabel* folderName;
@property(nonatomic,retain) IBOutlet UIView* folderImgView;
@property(nonatomic,retain) IBOutlet UIImageView* folderImg;
@property(nonatomic,retain) IBOutlet UIImageView* folderImg2;
@property(nonatomic,retain) IBOutlet UIImageView* folderImg3;
@property(nonatomic,retain) IBOutlet UIImageView* folderImg4;
@property(nonatomic,retain) IBOutlet UIImageView* folderImgBg;
@property (strong, nonatomic) IBOutlet UIImageView *fileMusicIconIV;
@property (strong, nonatomic) IBOutlet UIImageView *identifyNew;


@property(nonatomic,assign) id<PhotoItemSelectDelegate> itemSelectDelegate;

-(void)setData:(FileBean*)model index:(NSInteger)index needLoadIcon:(BOOL)need;
-(IBAction)selectedBtnPressed:(id)sender;
-(void)setSelected:(BOOL)selected;
-(void)setEditStatus:(NSInteger)editStatusType isExport:(BOOL)isexport;//ItemEditType

-(void)stopCacheIconRequest;
@end
