//
//  SpecialTopicViewController.h
//  tjk
//
//  Created by huadao on 16/4/6.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "UIBackDelegate.h"
#import "CustomNotificationView.h"
@interface SpecialTopicViewController : UIViewController<NavBarDelegate,UIWebViewDelegate,UIBackDelegate>{

    CustomNavigationBar * _customNavigationBar;
    UIWebView           * _webView;
    CustomNotificationView *   _webloading;
}
@property (nonatomic,assign) id<UIBackDelegate> backDelegate;
@property (nonatomic,retain) NSString * urlStr;
@property (nonatomic,retain) NSString * barTitle;
@end
