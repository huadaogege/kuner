//
//  AppDelegate.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ViewController* rootVC;

-(BOOL)isAppActive;
-(void)playBackground;
-(void)stopBackground;

@end

