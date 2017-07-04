//
//  DownloadCell.h
//  tjk
//
//  Created by Youqs on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemSelectDelegate.h"
#import "DownloadTask.h"

@interface DownloadCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UIView* selectView;
@property(nonatomic, retain) IBOutlet UIView* cellSelectBtn;
@property(nonatomic, retain) IBOutlet UIImageView* selectImg;

@property (strong, nonatomic) IBOutlet UIView *infoCotanierView;
@property (strong, nonatomic) IBOutlet UIImageView *iconImgVIew;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UILabel *nameLb;
@property (strong, nonatomic) IBOutlet UILabel *sizeLb;
@property (strong, nonatomic) IBOutlet UIButton *pauseBtn;
@property (strong, nonatomic) IBOutlet UIView *deleteView;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLine;
@property (strong, nonatomic) IBOutlet UIButton *itemBtn;
@property (strong, nonatomic) IBOutlet UIImageView *progressBgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *progressImageView;
@property (strong, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (strong, nonatomic) IBOutlet UILabel *failLabel;

@property(nonatomic, assign) id<PhotoItemSelectDelegate> itemEditDelegate;

@property(nonatomic, retain) NSDictionary *model;
@property(nonatomic, strong) NSString *filepath;

-(IBAction)selectedBtnPressed:(id)sender;
- (IBAction)pauseBtnPressed:(id)sender;
- (IBAction)deleteBtnPressed:(id)sender;

-(void)setData:(NSMutableDictionary*)been row:(NSInteger)row needLoadIcon:(BOOL)need;

-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation;
-(void)setSelectStatus:(BOOL)selected;

-(void)removeSwipeGes;

-(void)changePropress:(NSInteger)downloadSize at:(NSInteger)index allCount:(NSInteger)count;

@end
