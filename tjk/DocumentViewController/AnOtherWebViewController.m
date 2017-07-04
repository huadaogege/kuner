//
//  AnOtherWebViewController.m
//  tjk
//
//  Created by huadao on 15/6/4.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "AnOtherWebViewController.h"
#import "ServiceRequest.h"
#import "DownloadTask.h"
#import "CustomAlertView.h"
#import "AppDelegate.h"
#import "CustomFileManage.h"
#import "DownloadManager.h"
#import "DownloadListVC.h"
#import "BottomEditView.h"
#import "DownloadListVC.h"
#import "CustomNotificationView.h"
#import "EGORefreshTableHeaderView.h"
#import "Reachability.h"
#import "MobClickUtils.h"
#import "CustomMusicPlayer.h"
#import "LogUtils.h"
#import "DESUtils.h"
#import "PhotoClass.h"
#import "PrivateViewController.h"

#define WEB_MENU_DOWNLOAD_TAG 111

#define WEB_BOTTOM_LEFTMASKBTN_TAG 1112
#define WEB_BOTTOM_RIGHTMASKBTN_TAG 1113
#define WEB_BOTTOM_MAINMASKBTN_TAG 1114

#define ALERT_TAG_FLVTIP 1234
#define THIRDAPPFILE 3322

@interface AnOtherWebViewController ()<ServiceRequestDelegate,BottomEditViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,UIAlertViewDelegate>{
    NSString* _downloadUrl;
    NSURL* _webUrl;
    BottomEditView *_bottomView;
    NSArray* nowlist;
    int nowtype;
    NSDictionary *nowDict;
    UIButton *closeBtn;
    UIImageView *_newTaskIcon;
    UILabel * _downloadnum;
    BOOL reloading;
    BOOL _first;
    BOOL _loadWeb;
    BOOL _loadWebDone;
    BOOL _reloadAnimationFinished;
    BOOL _webLoadingBOOL;
    BOOL _loadWebFailed;
    BOOL _uibacked;
    NSTimer* _checktimer;
    NSString* _loadURL;
    CGFloat _navbottom;
    
    UIView                       *_linkKukeContanierView;
    UIView                       *_lightLinkContanierView;
    UILabel                      *_unlinkTitleLab;
    UILabel                      *_unlinkSubtitleLab;
    UILabel                      *_unlinkTipLab;
    UIImageView                  *_linkupImageView;
    UIImageView                  *_linkdownImageView;
    UIImageView                  *_handImageView;
    UIImageView                  *_circleImageView;
    UIImageView                  *_lightLinkImageView;
    NSTimer                      *_linkKeTimer;
    
    UIImageView                  *_downloadIntroduceIV;
    BOOL isInBaiduMusic;
    
    UIView                       *_downtip;
    UILabel                      *downaddtiplabel;
    UIView *failContanierView;
    BOOL _hideRefreshView;
    NSString                     *_lastUrl;
}

@property(nonatomic,retain) EGORefreshTableHeaderView* refreshView;
@property(nonatomic,retain) NSTimer* timer;
@property(nonatomic,retain) UIView* failedView;
@end

@implementation AnOtherWebViewController


-(id)init{

    self = [super init];
    if (self) {
        _first = YES;
      }
    return self;
}

#pragma mark - Life Cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = self.titleStr;
    _barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            _barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - _barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back", @"") forState:UIControlStateNormal];
    
    _navbottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    if (!_hideRefreshView) {
        _webloading = [[UIView alloc]initWithFrame:CGRectMake(0, _navbottom, SCREEN_WIDTH, 4)];
        _webloading.hidden = !([FileSystem isConnectedKE] && [FileSystem checkInit]);
        _webloading.backgroundColor = [UIColor colorWithRed:0 green:185/255.0f blue:1 alpha:1];
        //    [_webloading addSubview:indicatorView];
    }
    
    if (!closeBtn) {
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [closeBtn addTarget:self action:@selector(coloseBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitle:NSLocalizedString(@"close",@"") forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(48*WINDOW_SCALE, _customNavigationBar.frame.size.height - 42*WINDOW_SCALE, 60*WINDOW_SCALE, 44*WINDOW_SCALE);
    closeBtn.hidden = YES;
    [_customNavigationBar insertSubview:closeBtn belowSubview:_customNavigationBar.leftBtn];
    
    [self.view addSubview:_customNavigationBar];
    
    self.web = [[UIWebView alloc]initWithFrame:CGRectMake(0,
                                                          64.0,
                                                          SCREEN_WIDTH,
                                                          SCREEN_HEIGHT-64.0)];
    
    if (!_downloadWeb) {
        _customNavigationBar.rightBtn.hidden = YES;
    }
    else{
        _customNavigationBar.rightBtn.hidden = NO;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_downloadmanage" bundle:@"TAIG_MainImg"]];
        imgView.frame = CGRectMake(24*WINDOW_SCALE, 12*WINDOW_SCALE, 24*WINDOW_SCALE_SIX, 24*WINDOW_SCALE_SIX);
        [_customNavigationBar.rightBtn setTitle:@"" forState:UIControlStateNormal];
        [_customNavigationBar.rightBtn addSubview:imgView];
        
        _newTaskIcon = [[UIImageView alloc] init];
        _downloadnum = [[UILabel alloc]init];
        _downloadnum.textAlignment = NSTextAlignmentCenter;
        _downloadnum.textColor = [UIColor whiteColor];
        _downloadnum.font =[UIFont systemFontOfSize:10.0];
        [self refreshCurrentDownloadNum];
        NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
        [_customNavigationBar.rightBtn addSubview:_newTaskIcon];
        [_customNavigationBar.rightBtn addSubview:_downloadnum];
        _newTaskIcon.hidden = downnum == 0;
        _downloadnum.hidden = downnum == 0;
        
        _downtip = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 150.0*WINDOW_SCALE_SIX)/2.0,
                                                           SCREEN_HEIGHT-120.0*WINDOW_SCALE_SIX,
                                                           150.0*WINDOW_SCALE_SIX,
                                                           45.0*WINDOW_SCALE_SIX)];
        UIImageView * imagetip = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _downtip.frame.size.width, _downtip.frame.size.height)];
        imagetip.image = [UIImage imageNamed:@"download_list_07" bundle:@"TAIG_ResourceDownload"];
        [_downtip addSubview:imagetip];
        
        downaddtiplabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _downtip.frame.size.width, _downtip.frame.size.height)];
        
        downaddtiplabel.text = NSLocalizedString(@"indownloadlist", @"");
        downaddtiplabel.textAlignment = NSTextAlignmentCenter;
        downaddtiplabel.font = [UIFont systemFontOfSize:14.0];
        downaddtiplabel.textColor = [UIColor whiteColor];
        [_downtip addSubview:downaddtiplabel];
    }
    
    self.web.delegate =self;
    self.web.scalesPageToFit = YES;
    [self.view addSubview:self.web];
    if (_loadWeb && _webUrl) {
        [self webView:_webUrl];
    }
    if (!_refreshView && !_hideRefreshView) {
        self.web.scrollView.delegate = self;
        EGORefreshTableHeaderView* tmp = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.web.bounds.size.height, self.web.frame.size.width, self.web.bounds.size.height)];
        
        tmp.delegate = self;
        [self.web.scrollView addSubview:tmp];
        _refreshView = tmp;
    }
    
    _failedView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.web.scrollView.frame.size.height - 120)/2.0f - 60, self.view.frame.size.width, 120)];
    UIImageView* failedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resource_download_fail.png" bundle:@"TAIG_ResourceDownload"]];
    failedIcon.frame = CGRectMake((self.view.frame.size.width - failedIcon.frame.size.width)/2.0f, 0, failedIcon.frame.size.width, failedIcon.frame.size.height);
    UILabel* failedTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, failedIcon.frame.size.height + 25, self.view.frame.size.width - 80, 20)];
    failedTitle.font = [UIFont systemFontOfSize:16];
    failedTitle.textColor = [UIColor blackColor];
    failedTitle.text = NSLocalizedString(@"loadingfail",@"");
    failedTitle.textAlignment = NSTextAlignmentCenter;
    UILabel* failedlab = [[UILabel alloc] initWithFrame:CGRectMake(40, failedIcon.frame.size.height + 55, self.view.frame.size.width - 80, 20)];
    failedlab.font = [UIFont systemFontOfSize:16];
    failedlab.textColor = [UIColor grayColor];
    failedlab.text = NSLocalizedString(@"checknetandtryrefresh",@"");
    failedlab.textAlignment = NSTextAlignmentCenter;
    [_failedView addSubview:failedIcon];
    [_failedView addSubview:failedTitle];
    [_failedView addSubview:failedlab];
    CGFloat height = failedlab.frame.origin.y + failedlab.frame.size.height;
    _failedView.frame = CGRectMake(0, (self.web.scrollView.frame.size.height - height)/2.0f, self.view.frame.size.width, height);
    
    failContanierView = [[UIView alloc] initWithFrame:CGRectMake(0, self.web.frame.origin.y, self.web.frame.size.width, self.view.frame.size.height)];
    failContanierView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = CGRectMake(0, 0, failContanierView.frame.size.width, failContanierView.frame.size.height);
    [btn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [failContanierView addSubview:_failedView];
    [failContanierView addSubview:btn];
    
    NSString *str = [FileSystem isConnectedKE]?NSLocalizedString(@"downtoke",@""):NSLocalizedString(@"downtophone",@"");
    
    _bottomView = [[BottomEditView alloc] initWithInfos:
                        [NSArray arrayWithObjects:
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          str, @"title" ,
                          NSLocalizedString(@"indownloadlist",@""),  @"reverse_title" ,
                          @"resource_download_nouse", @"img" ,
                          @"resource_download_nouse_normal", @"hl_img" ,
                          [NSNumber numberWithInteger:WEB_MENU_DOWNLOAD_TAG], @"tag" ,
                          nil],
                         nil] frame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 45)];
    _bottomView.editDelegate = self;
    [_bottomView setMenuItemWithTag:WEB_MENU_DOWNLOAD_TAG enable:YES reverse:NO];
    
    [self.view addSubview:_bottomView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(taskAdded) name:ADD_TASK_NOTF object:nil];
    
    if (_downloadWeb) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localMusicPlay:) name:PLAYMUSIC object:nil];
        [self checkIsNeedToShowTipView:[NSNumber numberWithBool:YES]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentDownloadNum) name:DOWNCOMPELETE_NOTI object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self refreshCurrentDownloadNum];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (nowlist && nowtype == DOWN_TYPE_AUDIO) {
        if ([[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]) {
            [[CustomMusicPlayer shareCustomMusicPlayer] pause];
        }
    }
    
    if ((self.web.request.URL.absoluteString.length > 0 && ![self.web.request.URL.absoluteString hasPrefix:@"http://www.kuke.com.cn"])) {
        if (_downloadUrl && [FileSystem checkInit] && !_uibacked) {
            if (![self checkisFromYunWith:_downloadUrl]) {
                [[ServiceRequest instance] requestService:nil urlAddress:_downloadUrl info:nil delegate:self isBanben:NO];
            }
            else{
                if (nowDict) {
                    [self checkIsShowMenuWith:nowDict];
                }
            }
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)dealloc{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_checktimer) {
        [_checktimer invalidate];
        _checktimer = nil;
    }
    [_failedView removeFromSuperview];
    _failedView = nil;
    [failContanierView removeFromSuperview];
    failContanierView = nil;
    [_webloading removeFromSuperview];
    _webloading = nil;
    [_refreshView removeFromSuperview];
    _refreshView = nil;
    //    [_task cancel];
    //    _task = nil;
    [[ServiceRequest instance] cancelRequestWithDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

-(void)refreshBtnClick
{
    [self reloadTableViewDataSource:YES];
}

-(void)localMusicPlay:(NSNotification*)noti
{
    if (nowlist && nowtype == DOWN_TYPE_AUDIO) {
        //....
        [self reloadTableViewDataSource:NO];
    }
}

-(void)refreshCurrentDownloadNum{
   
    if (!_downloadWeb) {
        return;
    }
    
    NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
    
//    downnum = downnum > 99? 99 :downnum;
    
    if (downnum>=10) {
        _newTaskIcon.frame = CGRectMake(_customNavigationBar.rightBtn.frame.size.width - 21, 13, 20, 15);
        _newTaskIcon.image = [UIImage imageNamed:@"new_2num" bundle:@"TAIG_MainImg"];
    }else{
        _newTaskIcon.frame = CGRectMake(_customNavigationBar.rightBtn.frame.size.width - 21, 13, 15, 15);
        _newTaskIcon.image = [UIImage imageNamed:@"new_1num" bundle:@"TAIG_MainImg"];
    }
    _downloadnum.frame = _newTaskIcon.frame;
    _downloadnum.text = [NSString stringWithFormat:@"%lu",(unsigned long)downnum];
    _newTaskIcon.hidden = downnum == 0;
    _downloadnum.hidden = downnum == 0;
}


-(void)taskAdded{
    [self performSelectorOnMainThread:@selector(doTaskAdded) withObject:nil waitUntilDone:NO];
}

-(void)doTaskAdded{
//    if (_newTaskIcon && !_newTaskIcon.superview) {
//        [_customNavigationBar.rightBtn addSubview:_newTaskIcon];
//    }
    [self refreshCurrentDownloadNum];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == ALERT_TAG_FLVTIP) {
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FLVNOTTIP"];
        }
    }else if (alertView.tag == THIRDAPPFILE){
        if (buttonIndex == 0) {
            [self loadThirdFile];
        }else{
            NSString * fromwhere = [[_thirdAppFileUrl.absoluteString componentsSeparatedByString:@"://"] objectAtIndex:0];
            if ([FileSystem checkInit] && [fromwhere isEqualToString:@"file"]) {
                [NSThread detachNewThreadSelector:@selector(copyDataToDocuments:) toTarget:self withObject:_thirdAppFileUrl];
            }
        }
    }
    else{
        if (buttonIndex == 0) {
            [MobClickUtils event:@"DOWNLOAD_VIDEO_NET" label:@"2G/3G/4G"];
            [self downloadFileWith:nowlist];
        }
    }

}

- (void)loadThirdFile{
    NSString * kind = [[_thirdAppFileUrl.absoluteString pathExtension]lowercaseString];
    if ([kind isEqualToString:@"txt"]) {
        _webloading.hidden = YES;
        UITextView * view = [[UITextView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-44)];
        [self.view addSubview:view];
        __block  NSString * body ;
        dispatch_async(dispatch_queue_create(0, 0), ^{
            
            body = [NSString stringWithContentsOfURL:_thirdAppFileUrl encoding:0x80000632 error:nil];
            if (body==nil) {
                body =  [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:_thirdAppFileUrl ]  encoding:NSUTF8StringEncoding];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                view.text = body;
            });
        });
        
    }else if ([DOC_EX_DIC objectForKey:kind]){
        _webloading.hidden = YES;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_thirdAppFileUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
        request.allowsCellularAccess = self.downloadWeb || [self.titleStr isEqualToString:NSLocalizedString(@"topicTitle", @"")];
        if(request.allowsCellularAccess){
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            request.HTTPShouldHandleCookies = YES;
        }
        [self.web loadRequest:request];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"unsupportfilelayout",@"" ) delegate:nil cancelButtonTitle:NSLocalizedString(@"sure",@"" ) otherButtonTitles:nil];
        [alert show];
        
    }

}
-(void)coloseBtnPressed
{
//    self.web.delegate = nil;
    [self.web removeFromSuperview];
    self.web = nil;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_checktimer) {
        [_checktimer invalidate];
        _checktimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickLeft:(UIButton *)leftBtn{
    
    if ([_web canGoBack] && !failContanierView.superview) {
        _downloadUrl = nil;
        [self hideMenu];
        [_web goBack];
    }
    else{
        if (_isBackToHome) {
            _isBackToHome = NO;
            if (_delegate && [_delegate respondsToSelector:@selector(reloadHomeResourcePage)]) {
                [_delegate reloadHomeResourcePage];
            }
        }
        else{
            _uibacked = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * string = [APP_DOC_ROOT stringByAppendingPathComponent:@"Inbox"];
    if ([fm fileExistsAtPath:string]) {
        [fm removeItemAtPath:string error:nil];
    }
 
}

-(void)clickRight:(UIButton *)leftBtn
{
    
    if([FileSystem isConnectedKE] && ![FileSystem checkInit]){
        [CustomNotificationView showToast:NSLocalizedString(@"connectkuner",@"")];
        return;
    }
    
    DownloadListVC *listVC = [DownloadListVC sharedInstance];
//    if (_newTaskIcon && _newTaskIcon.superview) {
//        [_newTaskIcon removeFromSuperview];
// 
//    }
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DownloadListVC class]]) {
            [LogUtils writeLog:[NSString stringWithFormat:@"%@",self.navigationController.viewControllers]];
            [vc removeFromParentViewController];
            break;
        }
    }
    
    [self.navigationController pushViewController:listVC animated:YES];
}


//-(void)fileActionResult:(BOOL)result userInfo:(id)info{
//    [self loadThirdFile];
//
//}
//- (void)fileOperateCancel:(NSNotification *)noti{
//
//    if ([noti.name isEqualToString:@"fileOperateCancel"]) {
//       
//    }
//}

#pragma mark - Interfaces

-(void)webView:(NSURL *)url{
    _thirdAppFileUrl = url;
    NSString * kind = [[url.absoluteString pathExtension]lowercaseString];
    
        if(self.downloadWeb || [self.titleStr isEqualToString:NSLocalizedString(@"topicTitle", @"")]){
        _webUrl = url;
        if ([DOC_EX_DIC objectForKey:kind]) {
            _webloading.hidden = YES;
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
        request.allowsCellularAccess = self.downloadWeb || [self.titleStr isEqualToString:NSLocalizedString(@"topicTitle", @"")];
        if(request.allowsCellularAccess){
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            request.HTTPShouldHandleCookies = YES;
        }
        self.web.delegate = self;
        [self.web loadRequest:request];
    }
   _loadWeb = YES;
}

-(void)hideRefreshPullView {
    if (self.refreshView) {
        [self.refreshView removeFromSuperview];
        self.refreshView.hidden = YES;
        self.refreshView.delegate = nil;
        self.refreshView = nil;
    }
    if (_webloading) {
        [_webloading removeFromSuperview];
        _webloading = nil;
    }
    _hideRefreshView = YES;
    
}

#pragma mark - BottomEditViewDelegate

-(void)editButtonClickedAt:(NSInteger)tag
{
    if (tag == WEB_MENU_DOWNLOAD_TAG) {
        [self maskBtnPressed];
        if (nowlist) {
            Reachability* r = [Reachability reachabilityForInternetConnection];
            
            if (r.currentReachabilityStatus == ReachableViaWWAN) {
                UIAlertView * notice=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"tips",@"") message:NSLocalizedString(@"gpsnotice",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"yes",@"") otherButtonTitles:NSLocalizedString(@"no",@""), nil];
                [notice show];
                return;
            }
            [MobClickUtils event:@"DOWNLOAD_VIDEO_NET" label:@"WIFI"];
            [self downloadFileWith:nowlist];
        }
    }
}


#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource:NO];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark EGORefreshTableHeaderDelegate About Methods

//下拉动作触发事件调用的函数。在这里发送数据请求
- (void)reloadTableViewDataSource:(BOOL)show{
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    //    NSLog(@"request url : %@",self.web.request.URL.absoluteString);
    if (self.web.request.URL.absoluteString.length == 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_webUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        [self.web loadRequest:request];
    }
    else {
        [self.web reload];
    }
    
    reloading = !show;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - WebViewDelegate

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
    NSString *url = self.web.request.URL.absoluteString;
    NSString *locationurl = [self.web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    if ((!_lastUrl && url)|| ![_lastUrl isEqualToString:url]) {
        [self hideMenu];
    }
    
    if (_checktimer) {
        [_checktimer invalidate];
    }
    
    _loadURL = nil;
    NSLog(@"webViewDidStartLoad url : %@,location url : %@",url,locationurl);
    
    if ([self getNetWorkStates]) {
        _web.hidden = YES;
        _bottomView.hidden = YES;
    }
    else{
        _web.hidden = NO;
        _bottomView.hidden = NO;
    }
    
    [failContanierView removeFromSuperview];
    
    if (!reloading && self.navigationController.topViewController == self && !_webLoadingBOOL) {
//        [_webloading changeTitle: NSLocalizedString(@"adding",@"")];
//        [_webloading show];
        [self.view addSubview:_webloading];
        [self webLoadingStart];
    }
    _webLoadingBOOL = YES;
    _loadWebDone = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(doneLoadingTableViewData:) userInfo:[NSNumber numberWithBool:NO] repeats:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [failContanierView removeFromSuperview];
    
    NSString* url = [self.web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    if ([_loadURL isEqualToString:url]) {
        _loadWebFailed = NO;
        [CustomNotificationView clearToast];
    }
    NSLog(@"webViewDidFinishLoad:%@",url);
    _loadURL = url;
    _lastUrl = _loadURL;
    _webLoadingBOOL = NO;
    if (_reloadAnimationFinished) {
        [self webLoadingFinish];
        //        [self performSelector:@selector(webLoadingFinish) withObject:nil afterDelay:0];
    }
    
    [self doneLoadingTableViewData:[NSNumber numberWithBool:YES]];
    closeBtn.hidden = ![_web canGoBack];
    //    if ([_web canGoBack]) {
    ////        [_customNavigationBar.leftBtn setTitle:@"" forState:UIControlStateNormal];
    //    }else{
    //        _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    //        [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back", @"") forState:UIControlStateNormal];
    //    }
    if (_checktimer) {
        [_checktimer invalidate];
    }
    
    NSString *urlstr = self.web.request.URL.absoluteString;
    BOOL isHomePage = urlstr && [urlstr rangeOfString:RESOURCE_DOWNLOAD_URL].location != NSNotFound;
    if ([urlstr hasPrefix:@"http://www.tudou.com"] || [urlstr hasPrefix:@"http://music.baidu.com"] || (isInBaiduMusic && !isHomePage) || [urlstr hasPrefix:@"http://www.bilibili.com"]) {
        isInBaiduMusic = YES;
        _checktimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(viewdid) userInfo:nil repeats:YES];
    }
    else if(isHomePage){
        isInBaiduMusic = NO;
    }
    //    if (![_web canGoBack]) {
    //        _customNavigationBar.title.text = @"资源下载";
    //    }
    if (_first && [[UIDevice currentDevice] systemVersion].floatValue >= 9.0f) {
        _first = NO;
        [self.web reload];
    }
    _loadWebDone = YES;
    if (_downloadWeb) {
        //        [[CustomFileManage instance] getFiles:([FileSystem isConnectedKE]? PHONE_VIDEO : KE_VIDEO)];
        //        [[CustomFileManage instance] getFiles:RealDownloadVideoPath];
        NSString *str = webView.request.URL.absoluteString;
        [self processRequestUrl:str];
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSString* url = [self.web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    NSLog(@"url:%@,loadurl:%@",url,_loadURL);
    
    if ([self getNetWorkStates]) {
        if (![self isNotConnectingKeAfterActived]) {
            [self.view addSubview:failContanierView];
        }
    }
    else{
        if (![_loadURL isEqualToString:url] && !_webloading.superview) {
            _loadURL = url;
            if(_loadWebDone){
                _loadWebFailed = YES;
                [self performSelector:@selector(checkShowLoadError) withObject:nil afterDelay:1.5];
            }
            else if(![self isNotConnectingKeAfterActived]){
                [self.view addSubview:failContanierView];
            }
        }
    }
    _webLoadingBOOL = NO;
    [self webLoadingFinish];
//    [self performSelector:@selector(webLoadingFinish) withObject:nil afterDelay:0];
    [self doneLoadingTableViewData:[NSNumber numberWithBool:NO]];
}

#pragma mark UIWebViewDelegate About Methods

//请求结束函数。在这里要关闭下拉的视图.并更新表视图
- (void)doneLoadingTableViewData:(NSNumber*)result{
    if (![result isKindOfClass:[NSNumber class]]) {
        NSString* url = [self.web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
        if (![_loadURL isEqualToString:url] && !_webloading.superview) {
            _loadURL = url;
            if(_loadWebDone && self.navigationController.topViewController == self){
                [self performSelector:@selector(checkShowLoadError) withObject:nil afterDelay:1.5];
            }
            else if(![self isNotConnectingKeAfterActived]){
                [self.view addSubview:failContanierView];
            }
        }
    }
    //  model should call this when its done loading
    //    NSLog(@"stop loading");
    reloading = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.web.scrollView];
}

#pragma mark -

#pragma mark -

-(void)viewdid {
    NSString* url = [self.web stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    [self processRequestUrl:url];
}

-(void)processRequestUrl:(NSString *)str
{
    NSString* encodedString = [DESUtils stringByURLEncodingStringParameter:str];
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:@"http://pan.baidu.com"]];
    NSEnumerator *enumerator = [cookies objectEnumerator];
    NSHTTPCookie *cookie;
    while (cookie = [enumerator nextObject]) {
        if([[cookie name] isEqualToString:@"BDUSS"]){
            [[NSUserDefaults standardUserDefaults] setObject:[cookie value] forKey:[cookie name]];
            break;
        }
    }
    NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
    BOOL fromYunPan = [self checkisFromYunWith:str];
    NSString* urlStr = fromYunPan ? encodedString :[NSString stringWithFormat:@"%@?url=%@",RESOURCE_DOWNLOAD_ANALYZE_URL,encodedString];
    //        NSString* urlStr = @"http://www.kuke.com.cn/kuke/vedio/analyze.html?url=http%3A%2F%2Fm.kankan.com%2Fv%2F84%2F84705.shtml%3Fnew%3D1";
    if (((!fromYunPan &&![_downloadUrl isEqualToString:urlStr]) || (fromYunPan && ![_downloadUrl isEqualToString:str])) && !_uibacked) {
        _downloadUrl = fromYunPan ? str : urlStr;
        if (fromYunPan) {
            NSString* postString = [NSString stringWithFormat:@"bduss=%@&url=%@",BDUSS,urlStr];
            [[ServiceRequest instance] requestService:[postString dataUsingEncoding:NSUTF8StringEncoding] urlAddress:BAIDUYUN_DOWNLOAD_ANALYZE_URL info:str delegate:self isBanben:NO];
        }
        else {
            [[ServiceRequest instance] requestService:nil urlAddress:urlStr info:nil delegate:self isBanben:NO];
        }
        
    }
}

-(BOOL)getNetWorkStates{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
//    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            break;
        }
    }
    return netType == 0;
}

-(void)webLoadingStart{
    _reloadAnimationFinished = NO;
    _webloading.frame = CGRectMake(0,  _navbottom, 0, 4);
    [UIView animateKeyframesWithDuration:2 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        _webloading.frame = CGRectMake(0,  _navbottom, SCREEN_WIDTH*0.9f, 4);
    } completion:^(BOOL finished) {
        if (_loadWebDone) {
            [self webLoadingFinish];
        }
        _reloadAnimationFinished = YES;
    }];
}

-(void)webLoadingFinish{
    [UIView animateKeyframesWithDuration:.5 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        _webloading.frame = CGRectMake(0,  _navbottom, SCREEN_WIDTH, 4);
    } completion:^(BOOL finished) {
        [self webLoadingDismiss];
    }];
}

-(void)webLoadingDismiss {
//    if (!_webLoadingBOOL) {
        [_webloading removeFromSuperview];
//    }
}

-(void)checkShowLoadError{
    if (_loadWebFailed && self.navigationController.topViewController == self) {
        [CustomNotificationView showToast:NSLocalizedString(@"checknetandtryagain",@"")];
    }
}

//{
//no:0                                  视频编号:int 从0开始一次增加,默认值0
//    , name: "战狼"                    视频名称:string，默认值空字符串
//    , seconds:20                      视频长度:double，单位（秒）默认值0
//    , size:201053                     视频大小:long,单位(字节B),默认值0
//    , url: "XXXXXXXXXXXX"     视频地址:string，默认值字符串
//}

-(void)resultSuccess:(NSData *)data info:(id)info isBanben:(BOOL)isbanben originUrl:(NSString *)url{
    BOOL isequal1 = ![url isEqualToString:BAIDUYUN_DOWNLOAD_ANALYZE_URL];
    BOOL isequal2 = ![_downloadUrl isEqualToString:url];
    BOOL isequal3 = (info && ![_downloadUrl isEqual:info]);
    if((isequal1 && isequal2) || isequal3){
        return;
    }
    NSDictionary* weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    [self checkIsShowMenuWith:weatherDic];
    
//    if ([_customNavigationBar.title.text isEqualToString:@"资源下载"] && [_web canGoBack]) {
//        NSString *title = [self.web stringByEvaluatingJavaScriptFromString:@"document.title"];
//        _customNavigationBar.title.text = title;
//    }
    
//    NSLog(@"weatherDic %@",weatherDic);
    
}

-(void)checkIsShowMenuWith:(NSDictionary*)weatherDic
{
    NSArray* list  = [weatherDic objectForKey:@"list"];
    NSString *type = (NSString *)[weatherDic objectForKey:@"video"];
    
    int restype = type? type.intValue : TYPE_VIDEO;
    if (list && ![list isEqual:[NSNull null]] && list.count > 0) {
        if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]  && self == self.navigationController.topViewController) {
            [[CustomMusicPlayer shareCustomMusicPlayer]pause];
        }
        nowlist = list;
        nowtype = restype;
        nowDict = weatherDic;
        NSString *bill = [nowDict valueForKey:@"bill"];
        
        if (!bill || bill.intValue == 0) {
            NSDictionary* item = [nowlist objectAtIndex:0];
            NSString* tmpUrl = [item objectForKey:@"url"];
            if ([tmpUrl isKindOfClass:[NSString class]]) {
                if([tmpUrl rangeOfString:@"flv"].location != NSNotFound || [tmpUrl rangeOfString:@"FLV"].location != NSNotFound){
                    
                    [self hideMenu];
                    
                    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                    BOOL isTrue = [userdefault boolForKey:@"FLVNOTTIP"];
                    
                    if (!isTrue) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前视频为FLV格式，暂不支持此格式视频下载" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"不再提醒",nil];
                        alert.tag = ALERT_TAG_FLVTIP;
                        [alert show];
                    }
                }
                else {
                    [self showMenu];
                }
            }
            else{
                [self hideMenu];
            }
        }
        else{
            [self showMenu];
        }
        
    }
    else{
        [self hideMenu];
    }
}

-(void)showMenu{
    CGFloat height = [self getScrenHeight];
    CGFloat width = [self getScrenWidth];
    self.web.frame = CGRectMake(0,
                                64.0,
                                width,
                                height-64.0 - 45);
    
    NSString *bill = (NSString *)[nowDict valueForKey:@"bill"];
    NSString *reader = (NSString *)[nowDict valueForKey:@"reader"];
    
    if ((!bill || bill.intValue == 0) && nowlist.count > 0) {
        NSDictionary* item = [nowlist objectAtIndex:0];
        if ([reader isEqualToString:@"baidupan"]) {
            NSString *name = [item objectForKey:@"name"];
            name = [DownloadTask dealWithPointChar:name deletingPathExtension:NO];
            BOOL isin = [[DownloadManager shareInstance] IsInDownloadListForYunPan:name];
            [_bottomView setMenuItemWithTag:WEB_MENU_DOWNLOAD_TAG enable:!isin showReverse:isin];
        }
        else{
            NSString* tmpUrl = [item objectForKey:@"url"];
            if ([tmpUrl isKindOfClass:[NSString class]]) {
                if([tmpUrl rangeOfString:@"\r\n"].location == 0){
                    tmpUrl  = [tmpUrl stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                }
                if([tmpUrl rangeOfString:@"\n"].location == 0){
                    tmpUrl  = [tmpUrl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                }
                if([tmpUrl rangeOfString:@"http"].location == NSNotFound){
                    return;
                }
            }
            
            BOOL enable = [self isDownloadedWithUrl:nil fileid:nil];
            
            [_bottomView setMenuItemWithTag:WEB_MENU_DOWNLOAD_TAG enable:enable showReverse:!enable];
        }
    }
    else{
        
        [_bottomView setMenuItemWithTag:WEB_MENU_DOWNLOAD_TAG enable:YES showReverse:NO];
    }
    [UIView animateWithDuration:.3 animations:^{
        _bottomView.frame = CGRectMake(0, height - 45, width, 45);
    } completion:^(BOOL finished) {
        if (![reader isEqualToString:@"baidupan"]) {
            [self addIntroductTip];
        }
    }];
}

-(BOOL)isDownloadedWithUrl:(NSString *)number fileid:(NSString *)fileid{
    NSString* tmpUrl;
    NSString *itemname;
    
    if (!fileid && nowlist.count > 0) {
        NSDictionary* item = [nowlist objectAtIndex:0];
        itemname = [item objectForKey:@"name"];
        tmpUrl = [item objectForKey:@"url"];
        BOOL isM3U8 = NO;
        if (nowlist.count > 1) {
            isM3U8 = YES;
        }
        if([itemname isKindOfClass:[NSNull class]]|| !itemname || itemname.length == 0){
            if(isM3U8){
                itemname = [self.web stringByEvaluatingJavaScriptFromString:@"document.title"];
            }
            else {
                itemname = [NSString stringWithFormat:@"%@-%@",[self.web stringByEvaluatingJavaScriptFromString:@"document.title"],[self getDateString]];
            }
            
//            itemname = [itemname stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        }
        itemname = [DownloadTask dealWithErrorChar:itemname];
//        itemname = [itemname stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        if (!itemname || itemname.length == 0) {
            NSObject* thename = tmpUrl.lastPathComponent;
            if ([thename isKindOfClass:[NSString class]]) {
                NSString *name = (NSString *)tmpUrl.lastPathComponent;
                NSUInteger location = [name rangeOfString:@"?"].location;
                if (location != NSNotFound) {
                    name = [name substringToIndex:location];
                }
                itemname = itemname.length > 0 ? itemname : name;
            }
            
        }
    }
    else{
        tmpUrl = [NSString stringWithFormat:@"%@&subid=%@",_loadURL,fileid];
        if (number.integerValue < nowlist.count) {
            itemname = [[nowlist objectAtIndex:number.integerValue] objectForKey:@"name"];
        }
    }
    
    itemname = [DownloadTask dealWithPointChar:itemname deletingPathExtension:YES];
    
    BOOL isexist = ![[DownloadManager shareInstance] downloadingInList:tmpUrl name:itemname];
    
    return isexist;
}

-(void)hideMenu{
    CGFloat height = [self getScrenHeight];
    CGFloat width = [self getScrenWidth];
    nowlist = nil;
    self.web.frame = CGRectMake(0,
                                64.0,
                                width,
                                height-64.0);
    
    [UIView animateWithDuration:.3 animations:^{
        _bottomView.frame = CGRectMake(0, height, width, 45);
    } completion:^(BOOL finished) {
        
    }];
}

/*
 单视频数据结构：
 {
    code:int            解析结果：0成功，1失败
    msg:string          结果说明：如成功
    video:int           格式字段：1为视频，0为音频
    reader:string       解析类型：如腾讯视频为qq，响巢看看为kankan
    list:[{             视频列表数组：object Array
        no:int           视频编号：从0开始增加，默认值为0
        name:string      视频名称：默认值为空字符串
        seconds:double   视频时长：单位（秒），默认值0
        size:long        视频大小：单位（字节B），默认值0
        url:string       视频地址：默认值空字符串
    }]
 }
 
 剧集视频数据结构：
 {
    code:int            解析结果：0成功，1失败
    msg:string          结果说明：如成功
    video:int           格式字段：1为视频，0为音频
    reader:string       解析类型：如腾讯视频为qq，响巢看看为看看
    bill:int            视频类型：1剧集视频，0或不存在为单视频
    list:[{             视频列表数组：object Array
        no:int           视频编号：从0开始增加，默认值为0
        bill:int         视频类型：此字段，客户端无需关注
        id:string       视频ID：当请求单视频下载地址时使用
        name:string      视频名称：默认值为空字符串
    }]
 }
 */

-(void)downloadFileWith:(NSArray *)list
{
    if([FileSystem isConnectedKE] && ![FileSystem checkInit]){
        [CustomNotificationView showToast:NSLocalizedString(@"connectkuner",@"")];
        return;
    }
    
    NSString *bill = (NSString *)[nowDict valueForKey:@"bill"];
    
    if (!bill || bill.intValue == 0) {
        NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
        if (downnum >= 99) {
            [[DownloadManager shareInstance] showFullDownloadingAlert];
            return;
        }
        [self downloadSingleFileWith:list filetype:nowtype webUrl:_downloadUrl isMore:NO];
    }else{
        
        DownloadSelectList * ds = [[DownloadSelectList alloc]initWithType:nowtype setdataArray:nowlist listurl:_downloadUrl];
        ds.downselectdelegate = self;
//        [self presentViewController:ds animated:YES completion:nil];
        [self.navigationController pushViewController:ds animated:YES];
    }
}

-(void)downtipremove{
    [UIView animateWithDuration:1.0 animations:^{
        [_downtip removeFromSuperview];
    }];
    
}

#pragma mark - DownloadSelectListDelegate

-(void)downloadJuJiFileWith:(NSDictionary *)dict type:(int)type
{
    DownloadInfo *info = [self getDownloadInfoWith:dict type:type issameName:NO];
    
    [MobClickUtils event:@"DOWNLOAD_VIDEO" label:self.web.request.URL.host];
    [self performSelectorOnMainThread:@selector(sendRequest:) withObject:info waitUntilDone:YES];
}

-(void)downloadJuJiFileWithArray:(NSArray *)array type:(int)type
{
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        BOOL issamename = NO;
        for (DownloadInfo *infoo in infoArr) {
            NSString *name = [dict objectForKey:@"name"];
            name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"、"];
            if ([name isEqualToString:[infoo.filepath lastPathComponent]]) {
                issamename = YES;
                break;
            }
        }
        
        DownloadInfo *info = [self getDownloadInfoWith:dict type:type issameName:issamename];
        if (info) {
            [infoArr addObject:info];
        }
    }
    
    [MobClickUtils event:@"DOWNLOAD_VIDEO" label:self.web.request.URL.host];
    
    [self performSelectorOnMainThread:@selector(sendRequest:) withObject:infoArr waitUntilDone:YES];
}

#pragma mark -

-(DOWNLOAD_TYPE)getDownloadResType:(NSString*)name{
    NSString *exName = [[name pathExtension] lowercaseString];
    if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
        return DOWN_TYPE_VIDEO;
    }
    else if([MUSIC_EX_DIC objectForKey:exName]){
        return DOWN_TYPE_AUDIO;
    }
    else  if([PICTURE_EX_DIC objectForKey:exName] || [GIF_EX_DIC objectForKey:exName]){
        return DOWN_TYPE_PICTURE;
    }
    else {
        return DOWN_TYPE_DOCUMENT;
    }
}

-(DownloadInfo *)getDownloadInfoWith:(NSDictionary *)dict type:(int)type issameName:(BOOL)issamename
{
    NSString *videopath = RealDownloadVideoPath;
    
    if (type == DOWN_TYPE_VIDEO) {
        videopath = RealDownloadVideoPath;
    }
    else if (type == DOWN_TYPE_AUDIO){
        videopath = RealDownloadAudioPath;
    }
    else if (type == DOWN_TYPE_PICTURE){
        videopath = RealDownloadPicturePath;
    }
    else if (type == DOWN_TYPE_DOCUMENT){
        videopath = RealDownloadDocumentPath;
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@&subid=%@",_downloadUrl,[dict objectForKey:@"id"]];
    DownloadInfo* info = [[DownloadInfo alloc] init];
    info.type = type;
    NSString *name = [dict objectForKey:@"name"];
    if (name && name.length > 0) {
//        name = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    }
    BOOL fromYunPan = [self checkisFromYunWith:_downloadUrl];
    if (name && name.length > 0 && fromYunPan) {
        videopath = [CustomFileManage getDownloadDir:name];
        NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
        requestUrl = [NSString stringWithFormat:@"%@&bduss=%@&url=%@&subid=%@",BAIDUYUN_DOWNLOAD_ANALYZE_URL,BDUSS,_downloadUrl,[dict objectForKey:@"id"]];
        info.type = [self getDownloadResType:name];
    }
    info.webURL = requestUrl;
    info.typeRootPath = videopath;
    info.fpath = requestUrl;

    name = [DownloadTask dealWithErrorChar:name];
    name = [DownloadTask dealWithPointChar:name deletingPathExtension:NO];
    
    if (issamename || ([requestUrl isKindOfClass:[NSString class]] && (([requestUrl rangeOfString:@"http://music.baidu.com"].location != NSNotFound && type == 0) || type == 1))) {
        INDOWNLOADMANAGERSTATUS status = [[DownloadManager shareInstance] isMusicSameNameAndDiffFpathIndownloadingListWith:requestUrl name:name];
        if (issamename || status == IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH ) {
            NSString *midstr = type == 0? @"_artist_" : @"_";
            name = [NSString stringWithFormat:@"%@%@%@",name,midstr,[dict objectForKey:@"id"]];
        }
    }
    
    info.filepath = [videopath stringByAppendingPathComponent:name];
    
    return info;
}

#pragma mark -

-(BOOL)checkisFromYunWith:(NSString *)url
{
    NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
    BOOL fromYunPan = ([url rangeOfString:@"pan.baidu.com"].location != NSNotFound || [url rangeOfString:@"yun.baidu.com"].location != NSNotFound) && BDUSS;
    return fromYunPan;
}


-(void)downloadSingleFileWith:(NSArray *)list filetype:(int)type webUrl:(NSString *)weburl isMore:(BOOL)ismore
{
    NSString *videopath = RealDownloadVideoPath;
    
    if (type == DOWN_TYPE_VIDEO) {
        videopath = RealDownloadVideoPath;
    }
    else if (type == DOWN_TYPE_AUDIO){
        videopath = RealDownloadAudioPath;
    }
    
    [MobClickUtils event:@"DOWNLOAD_VIDEO" label:self.web.request.URL.host];
//    [CustomNotificationView showToast:NSLocalizedString(@"indownloadlist",@"")];
    
    [self.view addSubview:_downtip];
    [self performSelector:@selector(downtipremove) withObject:nil afterDelay:2.5];
    
    [_bottomView setMenuItemWithTag:WEB_MENU_DOWNLOAD_TAG enable:NO showReverse:YES];
    DownloadInfo* info = [[DownloadInfo alloc] init];
    info.type = type;
    
    info.webURL = weburl;
    info.typeRootPath = videopath;
    NSString* m3u8Str = @"";
    NSString* durationStr = @"";
    BOOL isM3U8 = NO;
    if (list.count > 1) {
        isM3U8 = YES;
    }
    NSString* m3u8DirName;
    float maxLength = 0;
//        float allLength = 0;
    
    NSString *filenameid = @"";
    BOOL fromYunPan = [self checkisFromYunWith:_downloadUrl];
    for (NSInteger i = 0 ; i < list.count ; i ++) {
        
        NSDictionary* item = [list objectAtIndex:i];
        NSString* tmpUrl = [item objectForKey:@"url"];
        if ([tmpUrl isKindOfClass:[NSString class]]) {
            if([tmpUrl rangeOfString:@"\r\n"].location == 0){
                tmpUrl  = [tmpUrl stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            }
            if([tmpUrl rangeOfString:@"\n"].location == 0){
                tmpUrl  = [tmpUrl stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            if([tmpUrl rangeOfString:@"http"].location == NSNotFound){
                return;
            }
        }
        
        if (i == 0) {
            info.fpath = tmpUrl;
        }
        DownloadItemInfo* itemInfo = [[DownloadItemInfo alloc] init];
        itemInfo.url = tmpUrl;
        itemInfo.idx = [item objectForKey:@"no"];
        itemInfo.name = [item objectForKey:@"name"];
        if (list.count == 1) {
            NSString* name = itemInfo.name;
            
            if (name && name.length > 0 && fromYunPan) {
                info.type = [self getDownloadResType:name];
                videopath = [CustomFileManage getDownloadDir:name];
                info.typeRootPath = videopath;
            }
        }
        
        if([itemInfo.name isKindOfClass:[NSNull class]] || !itemInfo.name || itemInfo.name.length == 0){
            if(isM3U8){
                itemInfo.name = [self.web stringByEvaluatingJavaScriptFromString:@"document.title"];
            }
            else {
                itemInfo.name = [NSString stringWithFormat:@"%@-%@",[self.web stringByEvaluatingJavaScriptFromString:@"document.title"],[self getDateString]];
            }
        }
        
        itemInfo.name = [DownloadTask dealWithErrorChar:itemInfo.name];
        
        NSString* name = fromYunPan && itemInfo.name ? itemInfo.name : itemInfo.url.lastPathComponent;
        if ([name isKindOfClass:[NSString class]]) {
            NSUInteger location = [name rangeOfString:@"?"].location;
            if (location != NSNotFound) {
                name = [name substringToIndex:location];
            }
        }
        
        name = [[name componentsSeparatedByString:@"&"] firstObject];
        filenameid = [[name componentsSeparatedByString:@"."] firstObject];
        if (isM3U8) {
            if (![itemInfo.name isKindOfClass:[NSNull class]] && itemInfo.name.length > 0) {
                itemInfo.dirName = [NSString stringWithFormat:@"%@.m3u8",itemInfo.name];//[[NSString stringWithFormat:@"%@.m3u8",itemInfo.name]stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            }
            else {
                itemInfo.dirName = [NSString stringWithFormat:@"%@.m3u8",name];
            }
            itemInfo.dirName = [DownloadTask dealWithErrorChar:itemInfo.dirName];
            if(i == 0){
                m3u8DirName = itemInfo.dirName;
            }
        }
        else {
            if(i == 0){
                m3u8DirName = ![itemInfo.name isKindOfClass:[NSNull class]] && itemInfo.name.length > 0 ? itemInfo.name : name;
            }
        }
        
        NSString* nameStr = list.count > 1 ? [NSString stringWithFormat:@"%@.%ld",itemInfo.name,((long)itemInfo.idx.integerValue + 1)] : itemInfo.name;
        if([name pathExtension].length > 0){
            if ([itemInfo.name rangeOfString:@"."].location == NSNotFound) {
                itemInfo.name = [NSString stringWithFormat:@"%@.%@",nameStr,[name pathExtension]];
            }
            
        }
        else if([itemInfo.url isKindOfClass:[NSString class]] &&([itemInfo.url rangeOfString:@"flv"].location != NSNotFound || [itemInfo.url rangeOfString:@"FLV"].location != NSNotFound)){
            itemInfo.name = [NSString stringWithFormat:@"%@.flv",nameStr];
        }
        else {
            if (!fromYunPan) {
                itemInfo.name = [NSString stringWithFormat:@"%@.mp4",nameStr];
            }
        }
        
        itemInfo.seconds = [item objectForKey:@"seconds"];
        if (maxLength < itemInfo.seconds.floatValue) {
            maxLength = itemInfo.seconds.floatValue;
        }
        if (isM3U8) {
            if (i == list.count - 1) {
                durationStr = [durationStr stringByAppendingString:[NSString stringWithFormat:@"%f",itemInfo.seconds.floatValue]];
            }
            else {
                durationStr = [durationStr stringByAppendingString:[NSString stringWithFormat:@"%f,",itemInfo.seconds.floatValue]];
            }
            m3u8Str = [m3u8Str stringByAppendingString:[NSString stringWithFormat:@"#EXTINF:%f,\n%@\n",itemInfo.seconds.floatValue,itemInfo.name]];
            info.filepath = [videopath stringByAppendingPathComponent:m3u8DirName];
        }
        else {
            itemInfo.name = [DownloadTask dealWithPointChar:itemInfo.name deletingPathExtension:NO];
            info.filepath = [videopath stringByAppendingPathComponent:itemInfo.name];
        }
        itemInfo.size = [item objectForKey:@"size"];
        [info.items addObject:itemInfo];
    }
    
    FilePropertyBean *bean = [FileSystem readFileProperty:videopath];
//    NSLog(@"path:%@",videopath);
    if (!bean) {
        [[CustomFileManage instance] creatDir:videopath withCache:[[CustomFileManage instance] hasCacheWithPath:[videopath stringByDeletingLastPathComponent]]];
    }
    if (isM3U8) {
        m3u8Str = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-TARGETDURATION:%d\n#EXT-X-VERSION:3\n%@#EXT-X-ENDLIST\n",(int)(maxLength + 1),m3u8Str];
        NSString* dirpath = [videopath stringByAppendingPathComponent:m3u8DirName];
        FilePropertyBean *bean2 = [FileSystem readFileProperty:dirpath];
        if (!bean2) {
            [[CustomFileManage instance] creatDir:dirpath withCache:NO];
        }
        [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:m3u8DirName] DataFile:[m3u8Str dataUsingEncoding:NSUTF8StringEncoding]];
        BOOL result = [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:@"durations.txt"] DataFile:[durationStr dataUsingEncoding:NSUTF8StringEncoding]];
        if (!result) {
            [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:@"durations.txt"] DataFile:[durationStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ : %d",[dirpath stringByAppendingPathComponent:@"durations.txt"],result]];
    }
    else{
        if (info.type == DOWN_TYPE_VIDEO) {
            NSArray *sepArr = [[info.filepath lastPathComponent]componentsSeparatedByString:@"."];
            NSString *filename = [sepArr firstObject];
            INDOWNLOADMANAGERSTATUS status = [[DownloadManager shareInstance] isMusicSameNameAndDiffFpathIndownloadingListWith:info.webURL name:filename ];
            if (status == IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH) {
                NSString *midstr = @"video";
                NSString *newname = [NSString stringWithFormat:@"%@_%@_%@.mp4",filename,midstr,filenameid];
                
                info.filepath = [[info.filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newname];
                for (DownloadItemInfo *item in info.items) {
                    item.name = newname;
                }
            }
        }
    }
    [self performSelectorOnMainThread:@selector(sendRequest:) withObject:info waitUntilDone:YES];
}

-(NSString*)getDateString{
    NSDate* date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString* dateStr = [NSString stringWithFormat:@"%@",localeDate];
    return [dateStr stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
}

-(void)sendRequest:(NSObject *)object{
//    [_webloading changeTitle:@"下载文件"];
//    [_webloading show];
//    [[DownloadManager shareInstance] addDownloadTask:info delegate:self];
    
    if ([object isKindOfClass:[DownloadInfo class]]) {
        DownloadInfo *info = (DownloadInfo *)object;
        [[DownloadListVC sharedInstance] addDownloadTask:info];
    }
    else if ([object isKindOfClass:[NSArray class]]){
        NSMutableArray *arr = (NSMutableArray *)object;
        [[DownloadListVC sharedInstance] addDownloadTaskWithArray:arr];
    }
}

-(void)resultFaile:(NSError *)error info:(id)info{
    
}

-(CGFloat)getScrenWidth
{
    return SCREEN_WIDTH < SCREEN_HEIGHT?SCREEN_WIDTH : SCREEN_HEIGHT;
}

-(CGFloat)getScrenHeight
{
    return SCREEN_WIDTH > SCREEN_HEIGHT?SCREEN_WIDTH : SCREEN_HEIGHT;
}

#pragma mark - download introduce tip

-(void)addIntroductTip
{
    if (![FileSystem isChinaLan] || ![FileSystem isConnectedKE]) {
        return;
    }
    BOOL isshow = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsShowDownloadIntroduceTip"];
    if (isshow) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsShowDownloadIntroduceTip"];
    
    if (!_downloadIntroduceIV) {
        _downloadIntroduceIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resource_download_tip" bundle:@"TAIG_ResourceDownload"]];
        _downloadIntroduceIV.frame = CGRectMake(0, SCREEN_HEIGHT - 45 - 204*WINDOW_SCALE_SIX, SCREEN_WIDTH, 204*WINDOW_SCALE_SIX);
        
        UIButton *maskbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        maskbtn.backgroundColor = [UIColor blackColor];
        maskbtn.alpha = 0.65;
        [maskbtn addTarget:self action:@selector(maskBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        maskbtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45);
        maskbtn.tag = WEB_BOTTOM_MAINMASKBTN_TAG;
        [self.view addSubview:maskbtn];
        
        UIButton *maskbtnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        maskbtnLeft.backgroundColor = [UIColor blackColor];
        maskbtnLeft.alpha = 0.65;
        [maskbtnLeft addTarget:self action:@selector(maskBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        maskbtnLeft.frame = CGRectMake(0, SCREEN_HEIGHT - 45, (SCREEN_WIDTH - 125*WINDOW_SCALE_SIX)/2.0,45);
        maskbtnLeft.tag = WEB_BOTTOM_LEFTMASKBTN_TAG;
        [self.view addSubview:maskbtnLeft];
        
        UIButton *maskbtnRight = [UIButton buttonWithType:UIButtonTypeCustom];
        maskbtnRight.alpha = 0.65;
        maskbtnRight.backgroundColor = [UIColor blackColor];
        [maskbtnRight addTarget:self action:@selector(maskBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        maskbtnRight.frame = CGRectMake((SCREEN_WIDTH + 125*WINDOW_SCALE_SIX)/2.0, SCREEN_HEIGHT - 45, (SCREEN_WIDTH - 125*WINDOW_SCALE_SIX)/2.0,45);
        maskbtnRight.tag = WEB_BOTTOM_RIGHTMASKBTN_TAG;
        [self.view addSubview:maskbtnRight];
        
        [self.view addSubview:_downloadIntroduceIV];
    }
}

-(void)maskBtnPressed
{
    for (int i = WEB_BOTTOM_LEFTMASKBTN_TAG; i <= WEB_BOTTOM_MAINMASKBTN_TAG; i++) {
        UIView *view = [self.view viewWithTag:i];
        if (view && [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
            view = nil;
        }
    }
    
    if (_downloadIntroduceIV) {
        if (_downloadIntroduceIV.superview) {
            [_downloadIntroduceIV removeFromSuperview];
        }
        _downloadIntroduceIV = nil;
    }
    
    
}

#pragma mark - device on off notification

-(void)connectionNotification:(NSNotification*)noti {
    if([noti.object intValue] == CU_NOTIFY_DEVCON || [noti.object intValue] == CU_NOTIFY_DEVOFF){
        if ([noti.object intValue] == CU_NOTIFY_DEVOFF) {
            _webloading.hidden = YES;
            [_webloading removeFromSuperview];
            _web.hidden = YES;
            [self checkIsNeedToShowTipView:[NSNumber numberWithBool:YES]];
            if (_downloadWeb && self.navigationController.topViewController != self) {
                BOOL isAinmated = [[DownloadListVC sharedInstance] checkVideoIsPlaying];
                [self.navigationController popToViewController:self animated:isAinmated];
            }
        }
        else {
            _webloading.hidden = NO;
            if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
                [[CustomAlertView instance] hidden];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
            NSString *str = [FileSystem isConnectedKE]?NSLocalizedString(@"downtoke",@""):NSLocalizedString(@"downtophone",@"");
            [_bottomView resetInfoDict:[NSArray arrayWithObjects:
                                       [NSDictionary dictionaryWithObjectsAndKeys:
                                        str, @"title" ,
                                        NSLocalizedString(@"indownloadlist",@""),  @"reverse_title" ,
                                        @"resource_download_nouse", @"img" ,
                                        @"resource_download_nouse_normal", @"hl_img" ,
                                        [NSNumber numberWithInteger:WEB_MENU_DOWNLOAD_TAG], @"tag" ,
                                        nil],
                                        nil]];
            [self removeTipView:YES];
            _web.hidden = NO;
            [self setBottomViewHidden:NO animated:YES];
        }
    }
    else if([noti.object intValue] == CU_NOTIFY_DEVINITED) {
        
    }
}

#pragma mark - device off tip

- (BOOL)isNotConnectingKeAfterActived
{
    return ([FileSystem isConnectedKE] && ![FileSystem checkInit]);
}

-(void)checkIsNeedToShowTipView:(NSNumber *)ischeckContanierViewExists
{
    BOOL isShow = NO;
    isShow = [self isNotConnectingKeAfterActived];
    _web.hidden = isShow;
    if (isShow) {
        if (!FOR_STORE) {
            [self setBottomViewHidden:YES animated:NO];
        }
        if (ischeckContanierViewExists.boolValue && _linkKukeContanierView) {
            return;
        }
        
        if (_linkKukeContanierView == nil) {
            _linkKukeContanierView = [[UIView alloc] init];
        }
        if (_linkKeTimer == nil) {
            _linkKeTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addTipView) userInfo:nil repeats:YES];
        }
        
        [self performSelector:@selector(addTipView) withObject:nil afterDelay:.1];
    }
    else{
//        [self setBottomViewHidden:NO animated:YES];
        [self performSelector:@selector(removeTipView:) withObject:[NSNumber numberWithFloat:YES] afterDelay:.1];
    }
}

-(void)addTipView
{
    [self removeTipView:NO];
    [self maskBtnPressed];
    
    CGFloat navbottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    
    if (_linkKukeContanierView == nil) {
        _linkKukeContanierView = [[UIView alloc] init];
        _linkKukeContanierView.frame = CGRectMake(0, navbottom, self.view.frame.size.width, self.view.frame.size.height - navbottom);
        _linkKukeContanierView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_linkKukeContanierView];
    }
    
    if (_unlinkTitleLab==nil) {
        _unlinkTitleLab = [[UILabel alloc] init];
        _unlinkTitleLab.backgroundColor = [UIColor clearColor];
        _unlinkTitleLab.textColor = BASE_COLOR;
        _unlinkTitleLab.font = [UIFont systemFontOfSize:24.0];
        _unlinkTitleLab.textAlignment = NSTextAlignmentCenter;
        _unlinkTitleLab.text = NSLocalizedString(@"openkuke", @"");
        _unlinkTitleLab.frame = CGRectMake(0, 25, _linkKukeContanierView.frame.size.width, 24);
        [_linkKukeContanierView addSubview:_unlinkTitleLab];
    }
    
    if (_unlinkSubtitleLab==nil) {
        _unlinkSubtitleLab = [[UILabel alloc] init];
        _unlinkSubtitleLab.backgroundColor = [UIColor clearColor];
        _unlinkSubtitleLab.textColor = BASE_COLOR;
        _unlinkSubtitleLab.font = [UIFont systemFontOfSize:15.0];
        _unlinkSubtitleLab.textAlignment = NSTextAlignmentCenter;
        _unlinkSubtitleLab.text = NSLocalizedString(@"presspowerbtn", @"");
        _unlinkSubtitleLab.frame = CGRectMake(0, _unlinkTitleLab.frame.origin.y+_unlinkTitleLab.frame.size.height+18, _linkKukeContanierView.frame.size.width, 15);
        [_linkKukeContanierView addSubview:_unlinkSubtitleLab];
    }
    
    if (_linkdownImageView == nil) {
        _linkdownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_two" bundle:@"TAIG_FILE_LIST"]];
        _linkdownImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0, _unlinkSubtitleLab.frame.origin.y+_unlinkSubtitleLab.frame.size.height+30, 160*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX);
    }
    
    if (_linkupImageView == nil) {
        _linkupImageView = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:@"list_link_one" bundle:@"TAIG_FILE_LIST"]];
        _linkupImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0, _unlinkSubtitleLab.frame.origin.y+_unlinkSubtitleLab.frame.size.height+30, 160*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX);
        _linkdownImageView.frame = _linkupImageView.frame;
        [_linkKukeContanierView addSubview:_linkupImageView];
        [_linkKukeContanierView addSubview:_linkdownImageView];
    }
    
    if (_unlinkTipLab == nil) {
        CGFloat oriY = _linkKukeContanierView.frame.size.height-45*WINDOW_SCALE_SIX-24;
        
        _unlinkTipLab = [[UILabel alloc] init];
        _unlinkTipLab.backgroundColor = [UIColor clearColor];
        _unlinkTipLab.text = NSLocalizedString(@"kukedisctitle", @"");
        _unlinkTipLab.textAlignment = NSTextAlignmentCenter;
        _unlinkTipLab.font = [UIFont systemFontOfSize:12];
        _unlinkTipLab.numberOfLines = 0;
        
        _unlinkTipLab.frame = CGRectMake(0, oriY, SCREEN_WIDTH, 24);
        _unlinkTipLab.textColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:1];
        
        [_linkKukeContanierView addSubview:_unlinkTipLab];
        
        UIButton *discBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [discBtn setFrame:_unlinkTipLab.frame];
        [discBtn addTarget:self action:@selector(discriptionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_linkKukeContanierView addSubview:discBtn];
    }
    
    [self doLinkKeAnimation:[NSNumber numberWithBool:YES]];
}

- (void)discriptionButtonClick:(id)sender
{
    PrivateViewController* aboutVC = [[PrivateViewController alloc] initWithNibName:@"PrivateViewController" bundle:nil];
    aboutVC.discType = DiscriptionTypeKUKEDisc;
    [self.navigationController pushViewController:aboutVC animated:YES];
}

-(void)kukeImageViewAnimated
{
    [_linkdownImageView.layer removeAnimationForKey:@"link"];
    CGPoint downCenter = _linkdownImageView.center;
    CGPoint midCenter = CGPointMake(_linkupImageView.center.x, _linkupImageView.center.y +20*WINDOW_SCALE_SIX);
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    opacityAnimation.duration = 2.0;
    opacityAnimation.repeatCount = 1;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.values = @[[NSValue valueWithCGPoint:downCenter], [NSValue valueWithCGPoint:midCenter], [NSValue valueWithCGPoint:CGPointMake(_linkupImageView.center.x, _linkupImageView.center.y)]];
    opacityAnimation.keyTimes = @[@0, @0.5,@1];
    
    [_linkdownImageView.layer addAnimation:opacityAnimation forKey:@"link"];
}

-(void)handImageViewAnimated
{
    if (_handImageView == nil) {
        _handImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_hand" bundle:@"TAIG_FILE_LIST"]];
    }
    _handImageView.hidden = NO;
    _handImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 - 50*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 70*WINDOW_SCALE_SIX, 105*WINDOW_SCALE_SIX);
    [_linkKukeContanierView addSubview:_handImageView];
    
    _handImageView.alpha = 0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1;
    group.beginTime = CACurrentMediaTime() +1;
    group.repeatCount =1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [_handImageView.layer removeAnimationForKey:@"hand_x"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue = [NSNumber numberWithFloat: (47*WINDOW_SCALE_SIX)];
    
    CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue = [NSNumber numberWithFloat:0];
    animation2.toValue = [NSNumber numberWithFloat:1.0];
    
    group.animations = [NSArray arrayWithObjects:animation,animation2, nil];
    [_handImageView.layer addAnimation:group forKey:@"hand_x"];
    
}

-(void)circleImageViewAnimated
{
    if (_circleImageView == nil) {
        _circleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_lightcycle" bundle:@"TAIG_FILE_LIST"]];
    }
    _circleImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + (47-30)*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18-30*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX);
    [_linkKukeContanierView addSubview:_circleImageView];
    
    _circleImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _circleImageView.alpha = 0;
    
    [_circleImageView.layer removeAnimationForKey:@"circle_scale"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.duration = 0.6;
    animation.beginTime = CACurrentMediaTime() + 2.1;
    animation.repeatCount =1;
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [_circleImageView.layer addAnimation:animation forKey:@"circle_scale"];
}

-(void)lightLinkAnimated
{
    //    if (_lightLinkImageView == nil) {
    //        _lightLinkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_light" bundle:@"TAIG_FILE_LIST"]];
    //    }
    //    _lightLinkImageView.hidden = YES;
    //    _lightLinkImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, (81+320 - 18)*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX);
    
    if (_lightLinkContanierView == nil) {
        _lightLinkContanierView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 7*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX)];
        _lightLinkContanierView.backgroundColor = [UIColor clearColor];
        
        for (int i = 0; i < 4; i++) {
            UIImageView *_lightLink = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_light" bundle:@"TAIG_FILE_LIST"]];
            _lightLink.frame = CGRectMake(8*WINDOW_SCALE_SIX*i, 0, 7*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX);
            [_lightLinkContanierView addSubview:_lightLink];
        }
        
    }
    _lightLinkContanierView.hidden = YES;
    _lightLinkContanierView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 7*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX);
    
    [_linkKukeContanierView addSubview:_lightLinkContanierView];
    
    [_lightLinkContanierView.layer removeAnimationForKey:@"light_x"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 2.7;
    animation.beginTime = CACurrentMediaTime() + 2.3;
    animation.repeatCount =1;
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [_lightLinkContanierView.layer addAnimation:animation forKey:@"light_x"];
}

-(void)animationDidStart:(CAAnimation *)anim
{
    CAAnimation *ani;
    if (_lightLinkContanierView) {
        ani = [_lightLinkContanierView.layer animationForKey:@"light_x"];
    }
    if (ani == anim) {
        
        _lightLinkContanierView.hidden = NO;
    }
    
    if (_circleImageView) {
        ani = [_circleImageView.layer animationForKey:@"circle_scale"];
    }
    if (ani == anim) {
        
        _circleImageView.alpha = 0.23;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_circleImageView) {
        CAAnimation *ani = [_circleImageView.layer animationForKey:@"circle_scale"];
        if (ani) {
            _circleImageView.alpha = 0;
        }
    }
    
    CAAnimation *ani;
    if (_lightLinkContanierView) {
        ani = [_lightLinkContanierView.layer animationForKey:@"light_x"];
        //        _lightLinkContanierView.hidden = YES;
    }
    
    if (ani == anim) {
        if (_linkKeTimer == nil) {
            [self removeTipView:YES];
        }
    }
}

-(void)doLinkKeAnimation:(NSNumber *)isshow
{
    if (isshow) {
        if (_handImageView) {
            _handImageView.hidden = YES;
        }
        
        [self handImageViewAnimated];
        [self circleImageViewAnimated];
        [self lightLinkAnimated];
    }
    else{
        [self removeTipView:YES];
    }
}


-(void)removeTipView:(BOOL)isneedRemoveTimer
{
    if (isneedRemoveTimer) {
        if (_linkKeTimer) {
            [_linkKeTimer invalidate];
            _linkKeTimer = nil;
        }
    }
    
    if (_linkKukeContanierView) {
        for (UIView *view in _linkKukeContanierView.subviews) {
            [view.layer removeAllAnimations];
            [view removeFromSuperview];
        }
        if (_linkKukeContanierView.superview) {
            [_linkKukeContanierView removeFromSuperview];
        }
        _linkKukeContanierView = nil;
    }
    if (_unlinkTipLab) {
        if (_unlinkTipLab.superview) {
            [_unlinkTipLab removeFromSuperview];
        }
        _unlinkTipLab = nil;
    }
    
    [_unlinkTitleLab removeFromSuperview];
    [_unlinkSubtitleLab removeFromSuperview];
    _unlinkTitleLab = nil;
    _unlinkSubtitleLab = nil;
    
    if (_linkdownImageView) {
        [_linkdownImageView.layer removeAllAnimations];
        if (_linkdownImageView.superview) {
            [_linkdownImageView removeFromSuperview];
        }
        _linkdownImageView = nil;
    }
    if (_linkupImageView) {
        if (_linkupImageView.superview) {
            [_linkupImageView removeFromSuperview];
        }
        _linkupImageView = nil;
    }
    if (_handImageView) {
        if (_handImageView.superview) {
            [_handImageView removeFromSuperview];
        }
        _handImageView = nil;
    }
    if (_lightLinkContanierView) {
        if (_lightLinkContanierView.superview) {
            [_lightLinkContanierView removeFromSuperview];
        }
        _lightLinkContanierView = nil;
    }
    if (_circleImageView) {
        if (_circleImageView.superview) {
            [_circleImageView removeFromSuperview];
        }
        _circleImageView = nil;
    }
}

-(void)setBottomViewHidden:(BOOL)isHidden animated:(BOOL)animated
{
    CGFloat height = [self getScrenHeight];
    CGFloat width = [self getScrenWidth];
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        _bottomView.frame = CGRectMake(0,
                                       isHidden? height :(nowlist?(height - 45) : height),
                                    width,
                                    45);
        
    } completion:^(BOOL finished) {
        
    }];
    _web.hidden = isHidden;
    _customNavigationBar.rightBtn.hidden = isHidden;
}

@end
