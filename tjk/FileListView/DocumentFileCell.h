//
//  DocumentFileCell.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemSelectDelegate.h"
#import "FileBean.h"

@interface DocumentFileCell : UITableViewCell
@property(nonatomic, retain) IBOutlet UIView* content;
@property(nonatomic, retain) IBOutlet UIView* selectView;
@property(nonatomic, retain) IBOutlet UIView* cellSelectBtn;
@property(nonatomic, retain) IBOutlet UIView* deleteView;
@property(nonatomic, retain) IBOutlet UIButton* deleteBtn;
@property(nonatomic, retain) IBOutlet UIView* maskView;
@property(nonatomic, retain) IBOutlet UIImageView* fileImg;
@property(nonatomic, retain) IBOutlet UIImageView* selectImg;
@property(nonatomic, retain) IBOutlet UILabel* fileName;
@property(nonatomic, retain) IBOutlet UILabel* fileDesc;
@property(nonatomic, retain) IBOutlet UILabel* fileDate;
@property(nonatomic, retain) IBOutlet UIImageView* folderArrow;
@property(nonatomic, retain) IBOutlet UIImageView* playIcon;
@property(nonatomic, retain) IBOutlet UIImageView* underLine;
@property (strong, nonatomic) IBOutlet UIImageView *identifynew;
@property (strong, nonatomic) IBOutlet UIImageView *littleIcon;

@property(nonatomic, assign) id<PhotoItemSelectDelegate> itemEditDelegate;
@property(nonatomic, retain) FileBean *model;
@property(nonatomic, assign) int res_type;
@property(nonatomic, assign) BOOL isInDownloadingList;

@property(nonatomic, retain) NSDictionary *downloadModel;

-(void)setData:(FileBean*)been row:(NSInteger)row needLoadIcon:(BOOL)need;

-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation;
-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation isExport:(BOOL)isexport;
-(void)setSelectStatus:(BOOL)selected;

-(IBAction)deleteBtnPressed:(id)sender;
-(IBAction)selectedBtnPressed:(id)sender;

-(void)setNewIdentify:(BOOL)play;

-(void)removeSwipeGes;

-(void)setDownloadData:(NSDictionary *)model row:(NSInteger)row needLoadIcon:(BOOL)need;

@end
