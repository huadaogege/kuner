//
//  PhotoGroupViewController.h
//  tjk
//
//  Created by Ching on 15-3-17.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoInfoUtiles.h"
#import "PhotoClass.h"
#import "BottomEditView.h"
#import "CustomEditAlertView.h"
#import "CustomNavigationBar.h"
#import "PhonePhotoViewController.h"
#import "BottomEditView.h"
#import "CustomNotificationView.h"

@protocol GroupDeletage <NSObject>

-(void)importPhoto:(NSArray *)copyArr type:(typeCode)mediaType;//导入数组
-(void)photoViewdismiss;

@end

@interface PhotoGroupViewController : UIViewController{
    BottomEditView       *_bottomView;
    ALAssetsGroup        *_clickGroup;
    CustomEditAlertView  *_editAlert;
    UITableView          *_tableView;
}

@property BOOL isOut;
@property int mediaType;
@property BOOL isResVideoType;
@property (assign) id<GroupDeletage> delegate;
@property NSMutableArray *groupAry;
@property (nonatomic,strong)NSString *photoNumber;

- (void)initDataToPath ;
-(void)type:(BOOL)isOut moveArr:(NSArray*)movArr showType:(typeCode)showtype resType:(BOOL)isvideoPath;
@end
