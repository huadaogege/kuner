//
//  AnOtherWebViewController.h
//  tjk
//
//  Created by huadao on 15/6/4.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "CustomNotificationView.h"
#import "DownloadSelectList.h"
#import "FileOperate.h"


@protocol AnOtherWebViewControllerDelegate <NSObject>

-(void)reloadHomeResourcePage;

@end

@interface AnOtherWebViewController : UIViewController<NavBarDelegate,UIWebViewDelegate,DownloadSelectListDelegate,OperateFiles>
{
    CustomNavigationBar * _customNavigationBar;
    CGFloat                  _barOffsetY;
    UIView *                   _webloading;
    NSString *           _copyfile;
    NSURL                * _thirdAppFileUrl;
}
@property UIWebView * web;
@property(nonatomic,retain) NSString * titleStr;
@property(nonatomic,assign) BOOL downloadWeb;
@property(nonatomic,assign) BOOL isBackToHome;
@property(nonatomic,assign) id<AnOtherWebViewControllerDelegate> delegate;
-(void)webView:(NSURL *)url;
-(void)hideRefreshPullView;
@end
