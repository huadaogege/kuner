//
//  FirstViewController.m
//  tjk
//
//  Created by Ching on 15-3-26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "FirstViewController.h"
#import "ViewController.h"
#import "PreviewViewController.h"
#import "CustomNavigationController.h"
#import "FileSystem.h"
#import "CustomFileManage.h"
#import "CustomNavigationBar.h"
#import "AnOtherWebViewController.h"
#import "DownloadListVC.h"

enum{
    Tecent_Video = 0,
    UKu_Video
}DownloadResourceType;

@interface FirstViewController ()<NavBarDelegate>{
    CustomNavigationController *_containerVC;
    PreviewViewController* picVC;
    CustomNavigationBar *_customNavigationBar;
    UIView *videoContanierView;
    NSMutableArray *videoResArray;
}

@end

@implementation FirstViewController

-(id)initWithArray:(NSArray *)array index:(NSInteger)index
{
    self = [super init];
    if(self){
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(id)init{
    
    self = [super init];
    if(self){
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)initView{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    ViewController* rootVC = [[ViewController alloc] init];
    _containerVC = [[CustomNavigationController alloc]initWithRootViewController:rootVC];
    _containerVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerVC.edgesForExtendedLayout = UIRectEdgeNone;
    _containerVC.navigationBarHidden = YES;
    [self.view addSubview: _containerVC.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidLayoutSubviews
{
    BOOL isIOS6 =[[UIDevice currentDevice] systemVersion].floatValue < 7;
    CGFloat barOffsetY =  isIOS6? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    CGFloat navBottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    videoContanierView.frame = CGRectMake(0, navBottom + 20*WINDOW_SCALE_SIX, SCREEN_WIDTH, videoContanierView.frame.size.height);
    
}

-(void)clickLeft:(UIButton *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRight:(UIButton *)leftBtn
{
//    DownloadListVC *listvc = [DownloadListVC sharedInstance];
//    [self.navigationController pushViewController:listvc animated:YES];
}

-(void)addDownloadResourceView
{
    self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/245.0 blue:245.0/255.0 alpha:1.0];
    
    videoResArray = [NSMutableArray array];
    [videoResArray addObject:@"腾讯视频"];
    [videoResArray addObject:@"优酷"];
    
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:Tecent_Video],[NSNumber numberWithInt:UKu_Video], nil];
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
//    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.rightBtn setTitle:@"下载列表" forState:UIControlStateNormal];
    _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
    _customNavigationBar.title.text = @"资源下载";
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resource_download_listicon" bundle:@"TAIG_ResourceDownload"]];
    imgView.frame = CGRectMake(24*WINDOW_SCALE, 12*WINDOW_SCALE, 24*WINDOW_SCALE_SIX, 24*WINDOW_SCALE_SIX);
    [_customNavigationBar.rightBtn setTitle:@"" forState:UIControlStateNormal];
    [_customNavigationBar.rightBtn addSubview:imgView];
    
    [self.view addSubview:_customNavigationBar];
    
    videoContanierView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 176 * WINDOW_SCALE_SIX)];
    videoContanierView.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < 3; i++) {
        CGFloat originY = i == 0? 0 : (i == 1?43*WINDOW_SCALE_SIX : videoContanierView.frame.size.height - 0.5);
        CGFloat originX = i == 1? 10*WINDOW_SCALE_SIX : 0;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0];
        [videoContanierView addSubview:line];
    }
    
    for (int i = 0; i<videoResArray.count; i++) {
        UIView *view = [self getItemViewWith:nil titleName:[videoResArray objectAtIndex:i] tag:((NSNumber *)[array objectAtIndex:i]).intValue];
        view.frame = CGRectMake(22*WINDOW_SCALE_SIX*(i+1) + view.frame.size.width*i, 65*WINDOW_SCALE_SIX, view.frame.size.width, view.frame.size.height);
        
        [videoContanierView addSubview:view];
    }
    
    [self.view addSubview:videoContanierView];
    
}

-(UIView *)getItemViewWith:(UIImage *)image titleName:(NSString *)title tag:(NSInteger)tag
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64*WINDOW_SCALE_SIX, 90*WINDOW_SCALE_SIX)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.width)];
    if (image) {
        [imgView setImage:image];
    }
    else{
        imgView.layer.cornerRadius = 5.0;
        imgView.layer.masksToBounds = YES;
        imgView.backgroundColor = [UIColor purpleColor];
    }
    [view addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,view.frame.size.width, view.frame.size.width, view.frame.size.height - view.frame.size.width)];
    label.text = title?title : @"";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
    label.font = [UIFont systemFontOfSize:12.0*WINDOW_SCALE_SIX];
    [view addSubview:label];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [btn addTarget:self action:@selector(resourceBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    [view addSubview:btn];
    
    return view;
}

-(void)resourceBtnPressed:(UIButton *)sender
{
    if (sender.tag == Tecent_Video)
    {
        [self gotoWebUI:[NSURL URLWithString:@"http://v.qq.com"] title:@"腾讯视频"];
    }
    else if (sender.tag == UKu_Video)
    {
        [self gotoWebUI:[NSURL URLWithString:@"http://www.youku.com"] title:@"优酷视频"];
    }
    else{
        
    }
}

-(void)gotoWebUI:(NSURL*)url title:(NSString*)title{
    AnOtherWebViewController* webView = [[AnOtherWebViewController alloc] init];
    webView.titleStr = title;
    webView.downloadWeb = YES;
    [self.navigationController pushViewController:webView animated:YES];
    [webView performSelector:@selector(webView:) withObject:url afterDelay:.3];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
