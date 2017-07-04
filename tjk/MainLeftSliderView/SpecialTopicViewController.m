//
//  SpecialTopicViewController.m
//  tjk
//
//  Created by huadao on 16/4/6.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "SpecialTopicViewController.h"

@interface SpecialTopicViewController ()

@end

@implementation SpecialTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _webloading = [[CustomNotificationView alloc] initWithTitle: NSLocalizedString(@"adding",@"")];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = self.barTitle;
    _customNavigationBar.rightBtn.hidden = YES;
    
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    [self.view addSubview:_customNavigationBar];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,
                                                         _customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height,
                                                         SCREEN_WIDTH,
                                                         SCREEN_HEIGHT-_customNavigationBar.frame.origin.y-_customNavigationBar.frame.size.height)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}
- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [_webView loadRequest:request];
}
-(void)clickLeft:(UIButton *)leftBtn {
    
    if (_webView.canGoBack) {
        [_webView goBack];
    }else{
        if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
            [self.backDelegate onBackBtnPressed:self];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
}

- (void)dismissLoading{

    [_webloading dismiss];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *topID = [[Context shareInstance] getNotDisplayTopicIDByURLStr:request.URL.absoluteString];
    if (topID.length>0) {
        [[Context shareInstance] storageNotDisplayTopicID:topID];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"notshowtopictip", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_webloading show];
    [self performSelector:@selector(dismissLoading) withObject:nil afterDelay:10.0];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error{

    [_webloading dismiss];
    
    if (error.code == NSURLErrorCancelled) {
        return ;
    }
    
    [CustomNotificationView showToast:NSLocalizedString(@"loadingfail", @"")];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_webloading dismiss];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
