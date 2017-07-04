//
//  LeftSwepView.h
//  RoundTest
//
//  Created by huadao on 15-3-25.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftCell.h"
#import "CellView.h"
#import "CustomActivityView.h"
#import "AppUpdateUtils.h"
#import "SetUpdateAlertView.h"
#import "MobClickUtils.h"

@protocol LeftSwepViewDelegate <NSObject>

-(void)leftMenuSelectedAt:(NSString *)itemIndexName;

@end

@interface LeftSwepView : UIView<UITableViewDelegate,UITableViewDataSource,SetUpdateAlertViewDelegate>
{
    UIView * view1;
    UIButton * view1Btn;
    
    UILabel * _iphoneType;
    UILabel * _whoseIphone;
    UILabel * _version;
    UIView  * line1;
    UIImageView * imagev1;
    UITableView * _tableview;
    
    
    UILabel * _phonePower;
    UILabel * _phoneCapacity;
    double  _used, _free;
//    NSTimer * timer,*timer1;
    CustomActivityView *_activityView;
    NSString           *Version;
    int               iphone;
    BOOL show;//区别两次请求更新，如果无更新是否弹框
    BOOL  _deviceon;
    
    double percentage;
    NSArray * _curTitleAry,*_currImgNameAry;
    BOOL     _canselect;


}
@property(nonatomic,assign)id<LeftSwepViewDelegate> menuDelegate;

@end
