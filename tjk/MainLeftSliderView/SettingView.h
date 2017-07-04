//
//  SettingView.h
//  tjk
//
//  Created by huadao on 15/6/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBackDelegate.h"
#import "CustomNavigationBar.h"
#import "PAPasscodeViewController.h"
#import "ViewController.h"
#import "YpcCustomProgress.h"
#import "FormatView.h"
@interface SettingView : UIViewController<NavBarDelegate,PAPasscodeViewControllerDelegate,YpcCustomProgressDelegate,CustomVideoSubViewDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    CustomNavigationBar     *_customNavigationBar;
    UILabel * lab1,*lab2;
    YpcCustomProgress                 *_test;
    BOOL                                ret;
    BOOL                               _kunerlost;
    dispatch_queue_t                   _dispatchQueue;
    CustomGesView                    * _alert;
    UITableView                      * _musicTimerTable;
    NSMutableArray                   * _musicName;
    UILabel                          * _musicClock;
    UIView                           * _backView;
}

@property (nonatomic,retain) UISwitch * switchs;
@property (nonatomic,retain) UISwitch * musicSwitch;
@property (nonatomic,strong) UISwitch * chargeSwitch;

@property (nonatomic,assign) id<UIBackDelegate> backDelegate;
@end
