
//
//  ViewController.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "ViewController.h"
#import "MusicPlayerViewController.h"
#import "FileViewController.h"
#import "CustomFileManage.h"
#import "PathBean.h"
#import "PreviewViewController.h"
#import "UMFeedback.h"
#import "AboutKuke.h"
#import "UIImage+Bundle.h"
#import "HomePageView.h"
#import "FileSystem.h"
#import "HardwareInfoBean.h"
#import "PowerBean.h"
#import "ClassBtnCellTableViewCell.h"
#import "MobClickUtils.h"
#import "UIBackDelegate.h"
#import "LogUtils.h"
#import "AnOtherWebViewController.h"
#import "SettingView.h"
#import "FirstViewController.h"
#import "DownloadListVC.h"
#import "NSNumber+Format.h"
#import "DownloadManager.h"
#import "WebViewController.h"
#import "CustomAlertView.h"
#import "PhoneInformantion.h"
#import "SpecialTopicViewController.h"

#define YANZHENG 111
#define NONE_TAG -1
#define ABOUT_TAG 0
#define Tecent 3
#define Youku 4

#define FEEDBACK_TAG 1
#define SETTING 2
#define PHONEINFORMANTION @"phoneinformantion"

#define FORMATFAIL 333

#define FORMAT_FIRST 100000
#define FORMAT_AGAIN 100001
#define FORMAT_APP_SYNC 100003
#define THIRDAPPFILE 100032
#define NOLINKKUKE   100033
#define ANOTHER_APP_OPEN 100034


//#define WINDOW_SCALE_SIX [UIScreen mainScreen].bounds.size.width / 375.0
#define TOPICVIEWHEIGHT 44

@interface ViewController ()<LeftSwepViewDelegate,OperateFiles,UIBackDelegate,AnOtherWebViewControllerDelegate,KxBackDelegate>
{
    NSInteger    _copyIndex;
    FileOperate* _operation;
    CustomNotificationView *_loadingView;
    UIView *_downView;
    BOOL    _lastKunerViewHiden;
    BOOL    _copyingRes;
    CABasicAnimation* rotationAnimation;
    BOOL    _cellClicked;
    BOOL     isGetHardInfo;
    BOOL     isOnGetInfo;
    BOOL     isGottenInfo;
    BOOL    _loadingInfo;
    UIView  *topic;
    NSDictionary *topicInfoDict;
    
    // 第三方
    KxMovieViewController *_player;
}
@property(nonatomic, retain) NSMutableArray* vcArr;
@property(nonatomic, retain) NSMutableArray* resArr;
@end

@implementation ViewController

- (id)init{
    self = [super init];
    if (self) {
        _turnRight = NO;
        _dontTouch = NO;
        isGottenInfo = NO;
        _lastKunerViewHiden = YES;
        
        _vcArr = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1], nil];
        _resArr = [NSMutableArray arrayWithObjects:[NSMutableArray array],[NSMutableArray array],[NSMutableArray array],[NSMutableArray array],[NSMutableArray array],[NSMutableArray array], nil];
        
        //顶部视图
        _topView = [[UIView alloc] init];
        _topView.backgroundColor= BASE_COLOR;
        
        _topLeftButton=[[UIButton alloc] init];
        [_topLeftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        
        _topRightButton=[[UIButton alloc]init];
        [_topRightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
        
        _topLeftButtonImgV = [[UIImageView alloc]init];
        [_topLeftButtonImgV setImage:[UIImage imageNamed:@"main_more.png" bundle:@"TAIG_MainImg.bundle"]];
        _topLeftButtonImgV.frame = CGRectMake(24*WINDOW_SCALE_SIX,20,24*WINDOW_SCALE_SIX,24*WINDOW_SCALE_SIX);
        
        _topRightButtonImgV = [[UIImageView alloc]init];
        [_topRightButtonImgV setImage:[UIImage imageNamed:@"main_musicPlay.png" bundle:@"TAIG_MainImg.bundle"]];
        _topRightButtonImgV.frame = CGRectMake(SCREEN_WIDTH - 34*WINDOW_SCALE_SIX,20,24*WINDOW_SCALE_SIX,24*WINDOW_SCALE_SIX);
        
        _musicplayanimateImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"main_musicPlay.png" bundle:@"TAIG_MainImg.bundle"]];
        _musicplayanimateImgV.hidden=YES;
        CGFloat space = [[UIDevice currentDevice] systemVersion].floatValue < 7.0 ? 0 : 20;
        
        _musicplayanimateImgV.frame =CGRectMake(SCREEN_WIDTH - 38*WINDOW_SCALE_SIX,space + (44 - 26*WINDOW_SCALE_SIX)/2.0,24*WINDOW_SCALE_SIX,24*WINDOW_SCALE_SIX);
        _topTitleLab=[[UILabel alloc]init];
        _topTitleLab.textAlignment=NSTextAlignmentCenter;
        _topTitleLab.textColor=[UIColor whiteColor];
        _topTitleLab.font = [UIFont systemFontOfSize:18.0*WINDOW_SCALE_SIX];
        _topTitleLab.text =  NSLocalizedString(@"copymaintitle",@"");
        
        [_topView addSubview:_topLeftButton];
        [_topView addSubview:_topRightButton];
        [_topView addSubview:_topTitleLab];
        [_topView addSubview:_topLeftButtonImgV];
        [_topView addSubview:_topRightButtonImgV];
        [_topView addSubview:_musicplayanimateImgV];
        
        //内容视图
        _contentView=[[UIView alloc]init];
        
        //底部视图
        _bottomView=[[UIView alloc]init];
        _bottomView.backgroundColor=[UIColor colorWithRed:137.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        [self.view addSubview:_topView];
        [self.view addSubview:_contentView];
        [self.view addSubview:_bottomView];
        
        [self newSorry];
        
         _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleURL:) name:@"POST_URL" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopcycle) name:@"stopcycle" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(begincycle) name:@"begincycle" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoMusic) name:@"gotomusic" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUpan:) name:@"setUpan" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterPasswordForUpdate) name:ENTERPW_FOR_UPDATE object:nil];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initPath];
    if (![FileSystem isConnectedKE]) {
        [self startgetMusicThread];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickLeft) name:@"leftbutton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickRight) name:@"rightbutton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCell) name:@"mneucell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatekuke) name:@"updatekuke" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movetokuke) name:@"movetokuke" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:DOWNCOMPELETE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:DOWNLOADING_TASK_PAUSEALL object:nil];
    
    if ([MobClickUtils MobClickIsActive]) {
        dispatch_async(dispatch_queue_create(0, 0), ^{
            [self getTopicInfo];
        });
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addLeftViewDelegateAndShadow];
    
    if(lightView && [FileSystem checkInit] && !_topLeftButton.hidden){
        
        [self needVolumeHidenLoading:[NSNumber numberWithBool:YES]];
    }
    if (_keOn) {
        [LogUtils writeLog:@"DEBUGMODEL viewWillAppear beginData"];
        [lightView beginData];
    }
    
    //
    [self reloadTableView];
    
    //
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self checkMusicIsPlaying:[NSNumber numberWithBool:NO]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [lightView stopData];
}

-(void)viewDidLayoutSubviews{
    CGFloat space = [[UIDevice currentDevice] systemVersion].floatValue < 7.0 ? 0 : 20;
    _topView.frame=CGRectMake(0,
                              0,
                              SCREEN_WIDTH,
                              44 + space);
    lightView.frame = CGRectMake(0,
                                 -30*WINDOW_SCALE_SIX ,
                                 SCREEN_WIDTH,
                                 355*WINDOW_SCALE_SIX);
    
    _contentView.frame=CGRectMake(0,
                                  64,
                                  SCREEN_WIDTH,
                                  SCREEN_HEIGHT-64);
    _bottomView.frame=CGRectMake(0,
                                 SCREEN_HEIGHT,
                                 SCREEN_WIDTH,
                                 64);
    _topLeftButton.frame=CGRectMake(0,
                                    _topView.frame.size.height - 44*WINDOW_SCALE,
                                    60*WINDOW_SCALE_SIX,
                                    44*WINDOW_SCALE);
    _topRightButton.frame=CGRectMake(SCREEN_WIDTH - 60*WINDOW_SCALE_SIX,
                                     _topView.frame.size.height - 44*WINDOW_SCALE,
                                     60*WINDOW_SCALE_SIX,
                                     44*WINDOW_SCALE);
    _topLeftButtonImgV.frame = CGRectMake(14*WINDOW_SCALE_SIX,space + (44 - 26*WINDOW_SCALE_SIX)/2.0,24*WINDOW_SCALE_SIX,24*WINDOW_SCALE_SIX);
    
    _topRightButtonImgV.frame = CGRectMake(SCREEN_WIDTH - 38*WINDOW_SCALE_SIX,space + (44 - 26*WINDOW_SCALE_SIX)/2.0,24*WINDOW_SCALE_SIX,24*WINDOW_SCALE_SIX);
    
    _topTitleLab.frame=CGRectMake(60.0*WINDOW_SCALE,
                               _topView.frame.size.height - 44*WINDOW_SCALE,
                               self.view.frame.size.width-60.0*WINDOW_SCALE*2.0,
                               44*WINDOW_SCALE);
    
    _maskButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _shadowImg.frame = CGRectMake(-10, 0, 10, SCREEN_HEIGHT);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Interfaces

-(UIView *)getleftView{
    _leftView = [[LeftSwepView alloc]initWithFrame:CGRectMake(0,
                                                            0,
                                                            SCREEN_WIDTH - 80,
                                                            SCREEN_HEIGHT)];
    return _leftView;
}

#pragma mark - Actions

-(void)clickLeftButton{
    [self clickLeft];
}

-(void)clickRightButton{
    fromsafenum = NO;
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        [self checkthenumber:@"rightbutton"];
    }else{
        [self clickRight];
    }
}

#pragma mark - Utility

- (void)reloadTableView
{
    [_btnTableview reloadData];
}

#pragma mark - NSNotification Methods

-(void)kunerOn:(NSNotification*)noti{
    
    if ([noti.name isEqualToString:DEVICE_NOTF])
    {
        //断开。连接
        BOOL lastLink = _keOn;
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            // 激活酷壳
            [FileSystem setConnectedInit];
//            [FileSystem createDirIfNotExist];
            
            //
            _kunerlost = NO;
            // 是否正在升级固件
            [Context shareInstance].isFirmwareUpdating = NO;
            //检测sn是否上传成功
            [self checkSNtoServe];
            
            [FileSystem resetLocked];
            
            NSLog(@"<<<< recivice device on notification>>>>>>");
            [LogUtils writeLog:@"DEBUGMODEL <<<< recivice device on notification>>>>>>"];
            
            _keOn = YES;
            [self hideLoadingView:YES];
            [[CustomFileManage instance] setSystemInited:YES];
            for(UIViewController* vc in self.vcArr){
                if ([vc isKindOfClass:[FileViewController class]]) {
                    ((FileViewController*)vc).needReload = true;
                }
            }
            
            isOnGetInfo = YES;
            if (lightView) {
                lightView.hidden = NO;
                [[CustomFileManage instance] setSystemInited:NO];
                [self needVolume];
                [lightView beginData];
            }
            else {
                [self ligtViewInit];
            }
        }
        else if ([noti.object intValue] == CU_NOTIFY_DEVINITED){
            if ([FileSystem checkInit]) {
                if (_keOn) {
                    PowerBean *powerBean = [FileSystem getPoweInfo];
                    
                    if (powerBean.usb1_model == INSERTPC_U) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self kunerViewHidden:NO];
                        });
                        
                    }
                    
                    [self startgetMusicThread];
                }
                
            }
        }
        else if ([noti.object intValue] == CU_NOTIFY_DEVOFF) {
            _keOn = NO;
            _kunerlost = YES;
            [Context shareInstance].isFirmwareUpdating = NO; // 是否正在升级固件
            [LogUtils writeLog:@"DEBUGMODEL CU_NOTIFY_DEVOFF"];
            BOOL showbroken = NO;
            if ([[CustomAlertView instance] hasShown]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FILE_OPERATION_CANCEL object:[NSNumber numberWithInt:[CustomAlertView instance].alertType]];
                [self performSelector:@selector(showBrokenAlert) withObject:nil afterDelay:.1];
                showbroken = YES;
            }
            [FileSystem resetLocked];
            if(_copyingRes){
                _copyingRes = NO;
            }
            if (lightView) {
                [lightView stopData];
            }
            if (lastLink) {
                [self hideLoadingView:NO];
                if (!showbroken && ![CustomNotificationView shownToastWithTag:112] && ![Context shareInstance].isShowingUpdateResult) {
                    [CustomNotificationView showToast:NSLocalizedString(@"kelinkbroken", @"")];
                }
                
                [self clearRL];
                [self kunerViewHidden:YES];
                
                [self setNavLeftAndRightBtnHidden:NO];
                [self stopcycle];
            }
            if(lightView && [FileSystem isConnectedKE]){
                [self resetPlayingKeMusic];
            }
            
            // 刷新TableView
            [self refreshTableView];
        }
        else if ([noti.object intValue] == CU_NOTIFY_USB_OFF)
        {
            [LogUtils writeLog:@"DEBUGMODEL CU_NOTIFY_USB_OFF"];
            for(UIViewController* vc in self.vcArr){
                if ([vc isKindOfClass:[FileViewController class]]) {
                    ((FileViewController*)vc).needReload = true;
                }
            }
        }
        else if ([noti.object intValue] == CU_NOTIFY_CODE){
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"safenumbercheck",@"") message:NSLocalizedString(@"imputsafenumber",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"sure",@""), nil];
            alert.alertViewStyle=UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0]setKeyboardType:UIKeyboardTypeDefault];
            [alert textFieldAtIndex:0].placeholder=NSLocalizedString(@"inport6number",@"");
            [alert textFieldAtIndex:0].delegate =self;
            alert.tag=YANZHENG;
            alert.delegate=self;
            [alert show];
        }
        
        CGFloat hh = allResBtn.frame.origin.y + allResBtn.frame.size.height + 20;
        _scrView.contentSize = CGSizeMake(SCREEN_WIDTH,!_keOn?(SCREEN_HEIGHT- 62):hh);
        [_scrView setContentOffset:CGPointMake(0, 0) animated:YES];
        [LogUtils writeLog:[NSString stringWithFormat:@"_keOn ; %d",_keOn]];
        [UIView animateWithDuration:0.5 animations:^{
            _downView.frame = CGRectMake(0, _keOn ?0:-325*WINDOW_SCALE_SIX, SCREEN_WIDTH,hh);
        }completion:^(BOOL finished) {
            if (!_keOn) {
            }
        }];
    }
}

-(void)handleURL:(NSNotification * )noti {
    NSURL* url = noti.object;
    [self gotoWebUI:url title:[[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]lastPathComponent] downloadWeb:NO];
}

-(void)stopcycle{
    
    [_musicplayanimateImgV.layer removeAllAnimations];
    _musicplayanimateImgV.hidden = YES;
    rotationAnimation = nil;
    _musicplayanimateImgV.hidden=YES;
    _topRightButtonImgV.hidden=NO;
}

-(void)begincycle{
    _musicplayanimateImgV.hidden=NO;
    _topRightButtonImgV.hidden=YES;
}

//重返app，增加视频播放完成通知
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self performSelector:@selector(checkMusicIsPlaying:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.2];
}

-(void)gotoMusic{
    [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"music",@"") resType:Music_Res_Type animation:NO];
}

-(void)setUpan:(NSNotification *)noti{
    [self checkthenumber:@"setUpan"];
}

- (void)enterPasswordForUpdate
{
    [self checkthenumber:@"updatekuke"];
}

-(void)clickLeft{
    _topRightButton.userInteractionEnabled =NO;
    if (!_dontTouch) {
        [MobClickUtils event:@"MAIN_TOP_CLICK" label:@"Setting"];
        
        [_scrView setContentOffset:CGPointMake(0, 0) animated:YES];
        _turnRight = YES;
        _maskButton.hidden = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.view.frame=CGRectMake(self.navigationController.view.frame.size.width - 80,
                                                            0,
                                                            self.navigationController.view.frame.size.width,
                                                            self.navigationController.view.frame.size.height);
            
            CGAffineTransform newTransform = CGAffineTransformConcat(_leftView.transform, CGAffineTransformInvert(_leftView.transform));
            [_leftView setTransform:newTransform];
            
        } completion:^(BOOL finished) {
        }];
    }
    
    [self performSelector:@selector(rightbutton) withObject:nil afterDelay:0.5];
}

- (void)refreshTableView
{
    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:1.0];
}

#pragma mark -

- (void)initPath {
    if(![FileSystem isConnectedKE]){
//        [FileSystem createDirIfNotExist];
        
    }
    else if([FileSystem isConnectCopied2KE]){
        [self removeAllPhoneDir];
    }
}

- (void)removeAllPhoneDir
{
    NSString *p_phoDir = [[Context shareInstance] getExistPathWithKey:kMultLanguagePicturePathKey  onPhone:YES];
    NSString *p_vdoDir = [[Context shareInstance] getExistPathWithKey:kMultLanguageVideoPathKey  onPhone:YES];
    NSString *p_mscDir = [[Context shareInstance] getExistPathWithKey:kMultLanguageMusicPathKey  onPhone:YES];
    NSString *p_docDir = [[Context shareInstance] getExistPathWithKey:kMultLanguageDocumentPathKey  onPhone:YES];
    [[CustomFileManage instance] removeDir:p_phoDir];
    [[CustomFileManage instance] removeDir:p_vdoDir];
    [[CustomFileManage instance] removeDir:p_mscDir];
    [[CustomFileManage instance] removeDir:p_docDir];
}

- (void)removeThirdCache{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * string = [APP_DOC_ROOT stringByAppendingPathComponent:@"Inbox"];
    if ([fm fileExistsAtPath:string]) {
        [fm removeItemAtPath:string error:nil];
    }
    if ([fm fileExistsAtPath:_copyfile]) {
        [fm removeItemAtPath:_copyfile error:nil];
    }
    
}
-(void)copyDataToDocuments:(NSURL *)url{
    
    NSString * str= url.absoluteString;
    
    FilePropertyBean *beanss = [FileSystem readFileProperty:_thirdAppCopyPath];
    if (!beanss) {
        [[CustomFileManage instance] creatDir:_thirdAppCopyPath withCache:[[CustomFileManage instance] hasCacheWithPath:[_thirdAppCopyPath stringByDeletingLastPathComponent]]];
    }
    
    NSString *unicodeStr = [NSString stringWithString:[str.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _thirdBoxFilePath = [APP_DOC_ROOT stringByAppendingPathComponent:unicodeStr];
    _copyfile = _thirdBoxFilePath;
    NSData * data = [NSData dataWithContentsOfURL:url];
    BOOL succ = [data writeToFile:_thirdBoxFilePath atomically:YES];
    if (succ) {
        if (_copyOrNot) {
             [self performSelectorOnMainThread:@selector(processFileCopyResult:) withObject:_thirdBoxFilePath waitUntilDone:NO];
        }else{
            NSString * kind = [[str pathExtension]lowercaseString];
            if ([kind isEqualToString:@"mp3"]||[kind isEqualToString:@"m4a"]) {
                FileBean * bean = [[FileBean alloc]init];
                [bean setFileType:FILE_MUSIC];
                [bean setFilePath:_thirdBoxFilePath];
                [[MusicPlayerViewController instance] setArray:[NSArray arrayWithObject:bean]];
                [[MusicPlayerViewController instance] setSongPath:bean kuke:YES];
                MusicPlayerViewController * newPlayView=[MusicPlayerViewController instance];
                [self.navigationController pushViewController:newPlayView animated:YES];

            }else if ([kind isEqualToString:@"jpg"]||[kind isEqualToString:@"png"]||[kind isEqualToString:@"gif"]||[kind isEqualToString:@"bmp"]){
                FileBean * bean = [[FileBean alloc]init];
                [bean setFileType:FILE_IMG];
                [bean setFilePath:_thirdBoxFilePath];
                PreviewViewController* picVC = [[PreviewViewController alloc] init];
                [picVC allPhotoArr:[NSMutableArray arrayWithObjects:bean, nil] nowNum:0 fromDownList:YES];
                [self.navigationController pushViewController:picVC animated:YES];
                
            }else if ([VIDEO_EX_DIC objectForKey:kind] || [MOV_EX_DIC objectForKey:kind]){
                
                FILE_TYPE fileType = MOV_EX_DIC[kind]?FILE_MOV:FILE_VIDEO;
                
                FileBean * bean = [[FileBean alloc]init];
                [bean setFileType:fileType];
                [bean setFilePath:_thirdBoxFilePath];
                [self play:bean.filePath anim:YES];
            }
            else{
                FileBean * bean = [[FileBean alloc]init];
                [bean setFileType:FILE_DOC];
                [bean setFilePath:_thirdBoxFilePath];
                WebViewController * web = [[WebViewController alloc]init];
                [web getPath:bean pathArray:[NSArray arrayWithObject:bean]];
                [self.navigationController pushViewController:web animated:YES];
            }
        }
       
    }
}
-(void)processFileCopyResult:(NSString*)filepath{
    NSString * kind = [[filepath pathExtension] lowercaseString];
    FileBean * bean = [[FileBean alloc]init];
    [bean setFilePath:filepath];
    if ([kind isEqualToString:@"mp3"]||[kind isEqualToString:@"m4a"]) {
        [bean setFileType:FILE_MUSIC];
        [_thirdAppBean setFileType:FILE_MUSIC];
        [_thirdAppBean setFilePath:[RealDownloadAudioPath stringByAppendingPathComponent:[filepath lastPathComponent]]];
    }else if ([kind isEqualToString:@"jpg"]||[kind isEqualToString:@"png"]||[kind isEqualToString:@"gif"]||[kind isEqualToString:@"bmp"]){
        [bean setFileType:FILE_IMG];
        [_thirdAppBean setFileType:FILE_IMG];
        [_thirdAppBean setFilePath:[RealDownloadPicturePath stringByAppendingPathComponent:[filepath lastPathComponent]]];
    }else if ([VIDEO_EX_DIC objectForKey:kind] || [MOV_EX_DIC objectForKey:kind])
    {
        FILE_TYPE fileType = [MOV_EX_DIC objectForKey:kind]?FILE_MOV:FILE_VIDEO;
        
        [bean setFileType:fileType];
        [_thirdAppBean setFileType:fileType];
        [_thirdAppBean setFilePath:[RealDownloadVideoPath stringByAppendingPathComponent:[filepath lastPathComponent]]];
    }
    else{
        [bean setFileType:FILE_DOC];
        [_thirdAppBean setFileType:FILE_DOC];
        [_thirdAppBean setFilePath:[RealDownloadDocumentPath stringByAppendingPathComponent:[filepath lastPathComponent]]];
    }
    NSMutableArray * array = [NSMutableArray array];
    [array addObject:bean];
    FileOperate * operate = [[FileOperate alloc]init];
    operate.delegate = self;
    NSString *unicodeStr = [NSString stringWithString:[filepath.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FilePropertyBean * pbean = [FileSystem readFileProperty:[_thirdAppCopyPath stringByAppendingPathComponent:unicodeStr]];
    if (!pbean) {
        [operate copyFiles:array toPath:_thirdAppCopyPath userInfo:nil alertMsg:NSLocalizedString(@"copying", nil)];
    }
}

-(void)gotoWebUI:(NSURL*)url title:(NSString*)title downloadWeb:(BOOL)downloadWeb{
    
    _thirdAppUrl = url;
    NSString * str= url.absoluteString;
    NSString * kind = [[str pathExtension] lowercaseString];
    
    if([title isEqualToString:NSLocalizedString(@"topicTitle", @"")]||downloadWeb){
        AnOtherWebViewController* webView = [[AnOtherWebViewController alloc] init];
        webView.titleStr = title;
        webView.downloadWeb = downloadWeb;
        [self.navigationController pushViewController:webView animated:YES];
        [webView performSelector:@selector(webView:) withObject:url afterDelay:.3];
    }else{
        NSString * thetitle ;
        if ([kind isEqualToString:@"mp3"]||[kind isEqualToString:@"m4a"]) {
            thetitle = [NSString stringWithFormat:@"%@:%@-%@",NSLocalizedString(@"savefield",@""),NSLocalizedString(@"music",@""),NSLocalizedString(@"downloadaudiopath",@"")];
            _thirdAppCopyPath = RealDownloadAudioPath;
        }else if ([kind isEqualToString:@"jpg"]||[kind isEqualToString:@"png"]||[kind isEqualToString:@"gif"]||[kind isEqualToString:@"bmp"]){
            thetitle = [NSString stringWithFormat:@"%@:%@-%@",NSLocalizedString(@"savefield",@""),NSLocalizedString(@"picture",@""),NSLocalizedString(@"downloadpicturepath",@"")];
            _thirdAppCopyPath = RealDownloadPicturePath;
        }
        else if ([VIDEO_EX_DIC objectForKey:kind] || [MOV_EX_DIC objectForKey:kind])
        {
            thetitle = [NSString stringWithFormat:@"%@:%@-%@",NSLocalizedString(@"savefield",@""),NSLocalizedString(@"video",@""),NSLocalizedString(@"downloadvideopath",@"")];
            _thirdAppCopyPath = RealDownloadVideoPath;
        }
        else{
            thetitle = [NSString stringWithFormat:@"%@:%@-%@",NSLocalizedString(@"savefield",@""),NSLocalizedString(@"document",@""),NSLocalizedString(@"downloaddocumentpath",@"")];
            _thirdAppCopyPath = RealDownloadDocumentPath;
        }
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"copysavetokuke",@"") message:thetitle delegate:self cancelButtonTitle:NSLocalizedString(@"notto",@"" ) otherButtonTitles:NSLocalizedString(@"yesto",@"" ), nil];
        alert.tag = THIRDAPPFILE;
        [alert show];

    }
//    else{
//        
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"unsupportfilelayout",@"" ) delegate:nil cancelButtonTitle:NSLocalizedString(@"sure",@"" ) otherButtonTitles:nil];
//        [alert show];
//
//    }
}

-(void)gotoWebUI:(NSURL*)url title:(NSString*)title downloadWeb:(BOOL)downloadWeb backToHomeWeb:(BOOL)isBackToHomeWeb{
    AnOtherWebViewController* webView = [[AnOtherWebViewController alloc] init];
    webView.titleStr = title;
    webView.downloadWeb = downloadWeb;
    webView.isBackToHome = isBackToHomeWeb;
    if (isBackToHomeWeb) {
        webView.delegate = self;
    }
    [self.navigationController pushViewController:webView animated:YES];
    [webView performSelector:@selector(webView:) withObject:url afterDelay:.3];
}

-(void)reloadHomeResourcePage{
    NSString *str = RESOURCE_DOWNLOAD_URL;
    NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];
    NSString *urlstr = [NSString stringWithFormat:@"%@?version=%@&time=%ld",str,version,time(0)];
    [self gotoWebUI:[NSURL URLWithString:urlstr] title:NSLocalizedString(@"resourceDownload", @"") downloadWeb:YES];
}

-(void)tableUserInterFace:(BOOL)isNo{
    _btnTableview.userInteractionEnabled = isNo;
    
}

-(void)movetokuke{
    if ([FileSystem checkInit]) {
        [NSThread detachNewThreadSelector:@selector(moveFilesToKe) toTarget:self withObject:nil];
    }
    else{
        _copyingRes = NO;
    }
}

-(void)getTopicInfo
{
    BOOL isNewUser   = [[Context shareInstance] isNewUser]; // n=1 为新用户
    NSString *urlStr = [NSString stringWithFormat:@"%@?lang=%@&n=%d",KUKE_TOPIC_REQ_URL,[FileSystem isChinaLan]?@"ch":@"en",isNewUser];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (response.statusCode == 200 && ![data isKindOfClass:[NSNull class]] && [data length] > 0) {
        topicInfoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *topicID = topicInfoDict[@"topic_id"];
            BOOL isExist = [[Context shareInstance] isExistInNotDisplayTopicID:topicID];
            if (topicInfoDict &&
                [topicInfoDict isKindOfClass:[NSDictionary class]] &&
                [topicInfoDict objectForKey:@"title"] &&
                topicID &&
                !isExist) {
                
                [self operateTopicViewIsAdd:YES topicTitle:[topicInfoDict objectForKey:@"title"]];
            }
            else{
                [self operateTopicViewIsAdd:NO topicTitle:@""];
                topicInfoDict = nil;
            }
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self operateTopicViewIsAdd:NO topicTitle:@""];
            topicInfoDict = nil;
        });
    }
}

-(void) startMusicPlayingAnimation{
    [_musicplayanimateImgV.layer removeAnimationForKey:@"MusicPlaying"];
    if (rotationAnimation == nil) {
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 3;
        rotationAnimation.repeatCount = MAXFLOAT;
    }
    [_musicplayanimateImgV.layer addAnimation:rotationAnimation forKey:@"MusicPlaying"];
}
-(void)endAnimation{
    _angle +=7;
    [self startMusicPlayingAnimation];
}

-(void)checkMusicIsPlaying:(NSNumber *)isbecomeActive
{
    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
        
        [self startMusicPlayingAnimation];
        
        _topRightButtonImgV.hidden= YES;
        _musicplayanimateImgV.hidden =NO;
    }else{
        [_musicplayanimateImgV.layer removeAnimationForKey:@"MusicPlaying"];
        rotationAnimation = nil;
        if (!isbecomeActive.boolValue) {
            _topRightButtonImgV.hidden =NO;
            _musicplayanimateImgV.hidden =YES;
        }
    }
}

-(void)addLeftViewDelegateAndShadow{
    _leftView.menuDelegate = self;
    [self.navigationController.view addSubview:_shadowImg];
}

-(void)needVolumeHidenLoading:(NSNumber*)hideLoading{
    [self performSelectorOnMainThread:@selector(getHardwareInfoOnMainThread:) withObject:hideLoading waitUntilDone:NO];
}

-(void)getHardwareInfoOnMainThread:(NSNumber*)hideLoading{
    
    if (![MobClickUtils MobClickIsActive] || !_keOn) {
        return;
    }
    _loadingInfo = YES;
    isGetHardInfo = NO;
    if (self == self.navigationController.topViewController) {
        if (hideLoading) {
            [self performSelector:@selector(GethardwareInfo) withObject:nil afterDelay:0.5];
        }
        else {
            [self performSelector:@selector(GethardwareInfo) withObject:nil afterDelay:0.05];
        }
    }
    
    [self performSelector:@selector(getInfo:) withObject:hideLoading afterDelay:0.15];
}

-(void)getInfo:(NSNumber*)hideLoading
{
    [NSThread detachNewThreadSelector:@selector(toLoadInfo:) toTarget:self withObject:hideLoading];
}

-(void)toLoadInfo:(NSNumber*)show{
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ <<<< get hardware  info ing>>>>>>",DEBUGMODEL]];
    HardwareInfoBean *infoBean = [FileSystem get_info];
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ <<<< get hardware  info success>>>>>>",DEBUGMODEL]];
    isGetHardInfo = YES;
    
    NSDictionary* resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                show ? show : [NSNumber numberWithInt:0],@"show",
                                infoBean,@"infoBean",
                                nil];
    
    [self performSelectorOnMainThread:@selector(showKeInfoDone:) withObject:resultDict waitUntilDone:NO];
}

-(void)showKeInfoDone:(NSDictionary*)dict{
    NSNumber* show = [dict objectForKey:@"dict"];
    HardwareInfoBean* bean = [dict objectForKey:@"infoBean"];
    
    if (![Context shareInstance].isFirmwareUpdating) {
        // 设置状态变量
        [Context shareInstance].isFirmwareUpdating = YES;
        // 更新固件
        [[AppUpdateUtils instance] checkUpdate];
    }
    
    if (show.boolValue) {
        [self loadKeInfoDone:bean];
    }
    else {
        [self performSelector:@selector(loadKeInfoDone:) withObject:bean afterDelay:.3];
    }
}

-(void)GethardwareInfo
{
    if (!isGetHardInfo) {
        [self hideLoadingView:NO];
//        _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"gettingkukeinfo",@"")];
        [_loadingView show:^{
            [LogUtils writeLog:[NSString stringWithFormat:@"%@ <<<< show done>>>>>> : %d",DEBUGMODEL,_loadingInfo]];
            if (!_loadingInfo) {
                [self hideLoadingView:NO];
            }
        }];
    }
}

-(void)hideLoadingView:(BOOL)animation{
    if (_loadingView) {
        [_loadingView dismiss];
        _loadingView = nil;
    }
}

-(void)needVolume{
    [self needVolumeHidenLoading:nil];
}

-(void)doNeedVolume{
    if (![MobClickUtils MobClickIsActive]) {
        return;
    }
    
    HardwareInfoBean *infoBean =  [FileSystem get_info];
    isGetHardInfo = YES;
    
    [self performSelectorOnMainThread:@selector(loadKeInfoDone:) withObject:infoBean waitUntilDone:NO];
}

-(void)loadKeInfoDone:(HardwareInfoBean*)infoBean{
    
    if(![FileSystem checkInit]){
        [self hideLoadingView:YES];
        return;
    }
    
    if (!infoBean || (infoBean.size == 0 && infoBean.free_size == 0)) {
        [self hideLoadingView:YES];
        int stat = [FileSystem getStat];
        if (stat != 1) {
            
            if (stat == 2) {
                if (isGottenInfo) {
                    [MobClickUtils event:@"APP_INFO_ERROR" label:@"需要格式化前退出"];
                    exit(0);
                }
                else {
                    [MobClickUtils event:@"APP_INFO_ERROR" label:@"需要格式化并提示"];
                    //可以格式化的状态
                    UIAlertView *formatalert=[[UIAlertView alloc]initWithTitle:nil
                                                                       message:NSLocalizedString(@"readinfoerror", @"")
                                                                      delegate:nil cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"formatdefault", @""), nil];
                    
                    formatalert.tag = FORMAT_FIRST;
                    formatalert.delegate = self;
                    
                    [formatalert show];
                }
            }
            else{
                [MobClickUtils event:@"APP_INFO_ERROR" label:@"其他错误状态重启提示"];
                [self showFormatAlert];
            }
        }
        else{
            [MobClickUtils event:@"APP_INFO_ERROR" label:@"文件系统可用"];
            [CustomNotificationView showToast:NSLocalizedString(@"getsizerror", @"")];
            [LogUtils writeLog:[NSString stringWithFormat:@"Read Ke Info error : infoBean == nil (%d)",infoBean == nil]];
        }
    }
    else {
        if (!([FileSystem checkBindPhone] && [FileSystem iphoneislocked])) {
            isGottenInfo = YES;
        }
        NSString *allGB =  [NSString stringWithFormat:@"%.1f",infoBean.size/1024.0/1024.0/1024.0];
        NSString *usedGB = [NSString stringWithFormat:@"%.1f",(infoBean.size - infoBean.free_size)/1024.0/1024.0/1024.0];
        NSString *freeGB = [NSString stringWithFormat:@"%.1f",allGB.floatValue - usedGB.floatValue];
        
        [lightView AllGB:allGB UewdGB:usedGB UnUseGB:freeGB];
    }
    
    if (isOnGetInfo && !_topLeftButton.hidden) {
        [[CustomFileManage instance] setSystemInited:YES];
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        if (![userdefault objectForKey:@"ChargeSwitch"]) {
            [userdefault setObject:@"off" forKey:@"ChargeSwitch"];
        }
        BOOL open = [[userdefault objectForKey:@"ChargeSwitch"] isEqualToString:@"on"];
        [FileSystem set_deviceModel:(open ? CHARGING_STORAGE_PREFERRED : CHARGING_DEFAULT)];
        
        [LogUtils writeLog:[NSString stringWithFormat:@"%@是否设为U盘模式%d",DEBUGMODEL,open]];
//        [self performSelector:@selector(delayCheck) withObject:nil afterDelay:0.5];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_MODEL_NOTF object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_NOTF object:[NSNumber numberWithInt:CU_NOTIFY_DEVINITED]];
        isOnGetInfo = NO;
    }
    else {
        [self hideLoadingView:YES];
    }
    _loadingInfo = NO;
}

-(void)delayCheck{
    
    if(![FileSystem isConnectCopied2KE] && !_copyingRes){
        _copyingRes = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[MusicPlayerViewController instance] deletefinishrefresh:[NSArray array] deletenowplay:NO];
        [NSThread detachNewThreadSelector:@selector(lookupAppData) toTarget:self withObject:nil];
    }
    else {
        [self hideLoadingView:YES];
        [self moveDownloadFile];
        [FileSystem setConnectCopiedInit];
    }
}

-(void)showFormatAlert
{
    UIAlertView *formatalert=[[UIAlertView alloc]initWithTitle:nil
                                                       message:NSLocalizedString(@"readinfoerrorforrestart", @"")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles: nil];
    formatalert.tag = FORMAT_FIRST;
    [formatalert show];
}

-(void)newSorry{
    _scrView = [[UIScrollView alloc]init];
    _scrView.backgroundColor = [UIColor clearColor];
    _scrView.delegate = self;
    _scrView.zoomScale = 1.0;
    _scrView.frame = CGRectMake(0, 63, SCREEN_WIDTH, SCREEN_HEIGHT - 63);
    _scrView.scrollEnabled = YES;
    _scrView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT- 63 + 60*WINDOW_SCALE_SIX);
    [self.view addSubview:_scrView];
    
    _downView = [[UIView alloc]init];
    _downView.backgroundColor = [UIColor clearColor];
    _downView.frame = CGRectMake(0, -325*WINDOW_SCALE_SIX, SCREEN_WIDTH, SCREEN_HEIGHT - 63);
    [_scrView addSubview:_downView];
    
    backView = [[UIView alloc]init];
    backView.backgroundColor = BASE_COLOR;
    backView.frame = CGRectMake(0, -_scrView.frame.size.height ,SCREEN_WIDTH, _scrView.frame.size.height);
    [_scrView addSubview:backView];
    
    kunerView = [[UIView alloc]init];
    kunerView.frame = CGRectMake(0, 325*WINDOW_SCALE_SIX, SCREEN_WIDTH,300*WINDOW_SCALE_SIX);
    kunerView.alpha = 0;
    kunerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *pcimgViw = [[UIImageView alloc]init];
    pcimgViw.frame = CGRectMake((SCREEN_WIDTH - 140*WINDOW_SCALE_SIX)/2.0, 44*WINDOW_SCALE_SIX, 140*WINDOW_SCALE_SIX, 101*WINDOW_SCALE_SIX);
    [pcimgViw setImage:[UIImage imageNamed:@"main_linkPC.png" bundle:@"TAIG_MainImg.bundle"]];
    
    UILabel *labA = [[UILabel alloc]init];
    labA.backgroundColor = [UIColor clearColor];
    labA.font = [UIFont boldSystemFontOfSize:14.0f];
    labA.textColor = [UIColor blackColor];
    labA.textAlignment = NSTextAlignmentCenter;
    labA.frame = CGRectMake(0 ,pcimgViw.frame.origin.y + 117*WINDOW_SCALE_SIX, SCREEN_WIDTH, 15*WINDOW_SCALE_SIX);
    
    UILabel *labB = [[UILabel alloc]init];
    labB.backgroundColor = [UIColor clearColor];
    labB.font = [UIFont boldSystemFontOfSize:14.0f];
    labB.textColor = [UIColor blackColor];
    labB.textAlignment = NSTextAlignmentCenter;
    labB.frame = CGRectMake(0 ,labA.frame.origin.y + 22*WINDOW_SCALE_SIX, SCREEN_WIDTH, 40*WINDOW_SCALE_SIX);
    labB.numberOfLines = 0;
    labB.tag = 111;
    
    labA.text = NSLocalizedString(@"main_nowU",@"");
//    labB.text = NSLocalizedString(@"main_longSize",@"");
    [kunerView addSubview:pcimgViw];
    [kunerView addSubview:labA];
    [kunerView addSubview:labB];
    
    nowthe = YES;
    
    if (([FileSystem isChinaLan] && [MobClickUtils MobClickIsActive]) || !IS_SHOWOTHER_LANGUAGE) {
        _nameArr = [NSArray arrayWithObjects:NSLocalizedString(@"picture",@""),NSLocalizedString(@"video",@""),NSLocalizedString(@"music",@""),NSLocalizedString(@"document",@""),NSLocalizedString(@"resourceDownload",@""),nil];
        _iconAry = [NSArray arrayWithObjects:[UIImage imageNamed:@"main_photo.png" bundle:@"TAIG_MainImg.bundle"],
                    [UIImage imageNamed:@"main_video.png" bundle:@"TAIG_MainImg.bundle"],
                    [UIImage imageNamed:@"imain_music.png" bundle:@"TAIG_MainImg.bundle"],

                    [UIImage imageNamed:@"main_file.png" bundle:@"TAIG_MainImg.bundle"],[UIImage imageNamed:@"main_resource.png" bundle:@"TAIG_MainImg.bundle"],nil];
                    //[UIImage imageNamed:@"main_resource.png" bundle:@"TAIG_MainImg.bundle"],nil];

    }
    else {
        _nameArr = [NSArray arrayWithObjects:NSLocalizedString(@"picture",@""),NSLocalizedString(@"video",@""),NSLocalizedString(@"music",@""),NSLocalizedString(@"document",@""),nil];
        _iconAry = [NSArray arrayWithObjects:[UIImage imageNamed:@"main_photo.png" bundle:@"TAIG_MainImg.bundle"],
                    [UIImage imageNamed:@"main_video.png" bundle:@"TAIG_MainImg.bundle"],
                    [UIImage imageNamed:@"imain_music.png" bundle:@"TAIG_MainImg.bundle"],
                    [UIImage imageNamed:@"main_file.png" bundle:@"TAIG_MainImg.bundle"],nil];
                    //[UIImage imageNamed:@"main_resource.png" bundle:@"TAIG_MainImg.bundle"],nil];
    }
    
    _btnTableview = [[UITableView alloc]init];
    _btnTableview.delegate =self;
    _btnTableview.dataSource = self;
    _btnTableview.scrollEnabled = YES;
    _btnTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _btnTableview.contentInset = UIEdgeInsetsMake(0, 0, 4, 0);
    _btnTableview.frame = CGRectMake(0, 325*WINDOW_SCALE_SIX, SCREEN_WIDTH,_nameArr.count*60*WINDOW_SCALE_SIX);
    
    allResBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [allResBtn setImage:[UIImage imageNamed:@"main_btn_allresources.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
    [allResBtn setBackgroundImage:[UIImage imageNamed:@"main_btn_allresources.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
    [allResBtn setTitle:NSLocalizedString(@"rootPath",@"") forState:UIControlStateNormal];
    [allResBtn setTitleColor:[UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    allResBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    CGFloat allresBtnWidth = 240*WINDOW_SCALE_SIX;
    CGFloat allresBtnHeight = 40*WINDOW_SCALE_SIX;
    allResBtn.frame = CGRectMake((SCREEN_WIDTH - allresBtnWidth)/2.0, 20*WINDOW_SCALE_SIX + _btnTableview.frame.origin.y + _btnTableview.frame.size.height, allresBtnWidth, allresBtnHeight);
    [allResBtn addTarget:self action:@selector(allResBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _downView.frame = CGRectMake(0, -325*WINDOW_SCALE_SIX, SCREEN_WIDTH, allResBtn.frame.origin.y + allResBtn.frame.size.height + 20);
    
    [_downView addSubview:_btnTableview];
    [_downView addSubview:allResBtn];
    [_downView addSubview:kunerView];
    
    _maskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _maskButton.backgroundColor = [UIColor clearColor];
    _maskButton.hidden = YES;
    _maskButton.enabled = YES;
    
    _leftSwipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipbackOnMaskBtn:)];
    _leftSwipeGestureRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    _leftSwipeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesOnMaskBtn:)];
    
    [_maskButton addGestureRecognizer:_leftSwipeTapGesture];
    [_maskButton addGestureRecognizer:_leftSwipeGestureRecognizer];
    [_leftSwipeTapGesture requireGestureRecognizerToFail:_leftSwipeGestureRecognizer];
    
    
    [self.view addSubview:_maskButton];
    
    _shadowImg = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 10, SCREEN_HEIGHT)];
    _shadowImg.image = [[UIImage imageNamed:@"main_leftShadow" bundle:@"TAIG_MainImg"] stretchableImageWithLeftCapWidth:30 topCapHeight:1];
    self.navigationController.view.clipsToBounds = NO;
}

-(void)allResBtnPressed
{
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        
        _nowPath = NSLocalizedString(@"rootPath",@"");
        [self checkthenumber:@"mneucell"];
    }else{
        NSString* rootPath = ([FileSystem checkInit]?[self getKePathAt:4] : [self getPhonePathAt:4]) ;
        [[CustomFileManage instance] cleanPathCache:rootPath];
        [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"rootPath",@"") resType:Root_Res_Type];
    }
}

-(void)swipbackOnMaskBtn:(UIGestureRecognizer *)ges
{
    if ([ges isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if (ges.state == UIGestureRecognizerStateEnded) {
            UISwipeGestureRecognizer *swipeGest = (UISwipeGestureRecognizer *)ges;
            if (swipeGest.direction == UISwipeGestureRecognizerDirectionLeft) {
                [self maskBtnPressed:_maskButton];
            }
        }
    }
}

-(void)tapGesOnMaskBtn:(UIGestureRecognizer *)ges
{
    if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
        if (ges.state == UIGestureRecognizerStateEnded) {
            [self maskBtnPressed:_maskButton];
        }
    }
}

-(void)ligtViewInit{
    if (lightView) {
        [lightView removeFromSuperview];
    }
    lightView = [[HomePageView alloc]init];
    lightView.delegate = self;
    lightView.backgroundColor = BASE_COLOR;
    
    [_downView addSubview:lightView];
    if (_keOn) {
        [lightView beginData];
    }
    
    [self needVolume];
    [self.view insertSubview:_scrView belowSubview:_maskButton];
}
-(void)checkSNtoServe{
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSString * code = [user objectForKey:@"sncode"];
    if ([code intValue] != 0||code == nil) {
        [[AppUpdateUtils instance]sendSNnumber];
    }
}

-(void)showBrokenAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"keunlink", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
    [alert show];
}

-(void)clearRL
{
    [lightView AllGB:@"0" UewdGB:@"0" UnUseGB:@"0"];
}

-(void)GetUsbModel{
    PowerBean *powerBean = [FileSystem getPoweInfo];
    if (powerBean.usb1_model == INSERTPC_U) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self kunerViewHidden:NO];
        });
        
    }
}

-(void)startgetMusicThread{
    [NSThread detachNewThreadSelector:@selector(getLastPlayingMusic) toTarget:self withObject:nil];
}

-(void)getLastPlayingMusic{
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        return;
    }
    NSString* dirPath = [FileSystem getConfigWithKey:@"playing_dir"];
    PathBean* pathBean = [[CustomFileManage instance] getFilesAsync:dirPath];
    NSString* lastmusicPath = [FileSystem getConfigWithKey:@"lastmusic"];
    NSInteger index = 0;
    if(pathBean.musicPathAry.count == 0){
        return;
    }
    NSMutableArray * lastmusicArray = [NSMutableArray array];
    if ([dirPath isEqualToString:RealDownloadAudioPath]) {
        
        for (FileBean * bean in pathBean.musicPathAry) {
            if (![self checkDocmentCellIsInDownloadingList:bean]) {
                [lastmusicArray addObject:bean];
            }
        }
        
    }
    else{
        lastmusicArray = pathBean.musicPathAry;
    }
     NSMutableArray* tmpArray = [NSMutableArray arrayWithArray:lastmusicArray];
    for (NSInteger i = 0 ; i < lastmusicArray.count; i ++) {
        FileBean* fileBeanTmp = [lastmusicArray objectAtIndex:i];
        if (![FileSystem readFileProperty:fileBeanTmp.filePath]) {
            [tmpArray removeObject:fileBeanTmp];
        }
        else if ([fileBeanTmp.filePath isEqualToString:lastmusicPath]) {
            index = i + 1;
            break;
        }
    }
    if (index == 0 && tmpArray.count > 0) {
        index = 1;
    }
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          lastmusicArray,@"array",
                          [NSNumber numberWithInteger:index],@"index",
                          nil];
    [self performSelectorOnMainThread:@selector(getLastPlayingMusicDone:) withObject:dict waitUntilDone:NO];
}

-(BOOL)checkDocmentCellIsInDownloadingList:(FileBean *)bean
{
    BOOL isIn = NO;
    
    
    NSMutableArray *downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
    
    for (NSDictionary *tmp in downloadingArray) {
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.filepath isEqualToString:bean.filePath]) {
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}
-(void)getLastPlayingMusicDone:(NSDictionary*)dict{
    NSArray* musicArray = [dict objectForKey:@"array"];
    NSInteger index = [((NSNumber*)[dict objectForKey:@"index"]) integerValue] - 1;
    FileBean* bean = nil;
    if (index >= 0 && index < musicArray.count) {
        bean = [musicArray objectAtIndex:index];
    }
    if(bean) {
        [[MusicPlayerViewController instance] getTheLastSong:bean LastSongList:musicArray];
    }
    else{
        [[MusicPlayerViewController instance] resetPlayArray];
    }
}

-(void)resetKunerViewText:(BOOL)isusbOn
{
    UILabel *labB = (UILabel *)[kunerView viewWithTag:111];
    NSString *str = isusbOn?@"main_linkLongSize":@"main_longSize";
    labB.text = NSLocalizedString(str,@"");
}

-(void)lookupAppData{
    [[DownloadManager shareInstance] pauseAll];
    NSInteger needMove = 0;
    for (NSInteger i = 0; i < 5; i ++) {
        NSString* path = [self getPhonePathAt:i];
        PathBean* pathBean = [[CustomFileManage instance] getFiles:path];
        if (pathBean) {
            NSMutableArray* array;
            if (i<self.resArr.count) {
                array = [self.resArr objectAtIndex:i];
                [array removeAllObjects];

            }
            if (i == 4) {
                NSMutableArray* tmpArray = [NSMutableArray array];
                [tmpArray addObjectsFromArray:pathBean.dirPathAry];
                for (NSInteger j = 0; j < 4; j ++) {
                    NSString* path = [self getPhonePathAt:j];
                    for (FileBean* fileBean in pathBean.dirPathAry) {
                        if ([fileBean.filePath isEqualToString:path] || [fileBean.fileName isEqualToString:@"Log"] || [fileBean.fileName isEqualToString:@"Recordings"]) {
                            [tmpArray removeObject:fileBean];
                        }
                    }
                }
                for (FileBean* fileBean in tmpArray) {
                    NSString* pathTmp = [NSString stringWithFormat:@"/%@",[[FileSystem getFilePath] stringByAppendingPathComponent:fileBean.fileName]];
                    if (![FileSystem readFileProperty:pathTmp]) {
                        [FileSystem creatDir:pathTmp];
                    }
                }
                [array addObjectsFromArray:tmpArray];
            }
            else {
                [array addObjectsFromArray:pathBean.dirPathAry];
            }
            [array addObjectsFromArray:pathBean.imgPathAry];
            [array addObjectsFromArray:pathBean.videoPathAry];
            [array addObjectsFromArray:pathBean.musicPathAry];
            [array addObjectsFromArray:pathBean.docPathAry];
            if (i == 4) {
                NSMutableArray* tmpArray = [NSMutableArray array];
                [tmpArray addObjectsFromArray:pathBean.nonePathAry];
                for (FileBean* fileBean in tmpArray) {
                    if ([fileBean.fileName rangeOfString:@"."].location == 0) {
                        [tmpArray removeObject:fileBean];
                    }
                }
                [array addObjectsFromArray:tmpArray];
            }
            else {
                [array addObjectsFromArray:pathBean.nonePathAry];
            }
            needMove += array.count;
        }
    }
    
    [self performSelectorOnMainThread:@selector(lookupAppDataDone:) withObject:[NSNumber numberWithInteger:needMove] waitUntilDone:NO];
}

-(void)lookupAppDataDone:(NSNumber*)needNum{
    [self hideLoadingView:YES];
    if (needNum.integerValue > 0) {
        UIAlertView * formatalert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"importantnotice",@"")
                                                            message:NSLocalizedString(@"importantmsg",@"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"sure",@"")
                                                  otherButtonTitles:nil, nil] ;
        
        formatalert.tag = FORMAT_APP_SYNC;
        formatalert.delegate=self;
        
        [formatalert show];
    }
    else {
        _copyingRes = NO;
        [self moveDownloadFile];
        [FileSystem setConnectCopiedInit];
    }
}

-(void)fileActionResult:(BOOL)result userInfo:(id)info{
    [self removeThirdCache];
    NSDictionary* dict = info;
    NSString* action = [dict objectForKey:@"action"];
    if ([action isEqualToString:@"copy"]) {
        if ([FileSystem checkInit] && result) {
            [self performSelectorOnMainThread:@selector(deleteFilesFromPhone) withObject:nil waitUntilDone:NO];
        }
        else{
            _copyingRes = NO;
        }
    }
    else if ([action isEqualToString:@"delete"]) {
        _copyIndex ++;
        if(_copyIndex < 5){
            [NSThread detachNewThreadSelector:@selector(moveFilesToKe) toTarget:self withObject:nil];
        }
        else{
            [LogUtils writeLog:@"MOVE FILES"];
            [[CustomFileManage instance] cleanPathCacheAll];
            _copyingRes = NO;
            
            [self moveDownloadFile];
            [FileSystem setConnectCopiedInit];
            [self needVolumeHidenLoading:nil];
            if (_keOn) {
                [lightView beginData];
            }
            
        }
    }else if(_thirdAppFile){
        if ([_thirdAppCopyPath isEqualToString:RealDownloadAudioPath]) {
            [[MusicPlayerViewController instance] setArray:[NSArray arrayWithObject:_thirdAppBean]];
            [[MusicPlayerViewController instance] setSongPath:_thirdAppBean kuke:YES];
            MusicPlayerViewController * newPlayView=[MusicPlayerViewController instance];
            [self.navigationController pushViewController:newPlayView animated:YES];

        }else if ([_thirdAppCopyPath isEqualToString:RealDownloadPicturePath]){
                PreviewViewController* picVC = [[PreviewViewController alloc] init];
                [picVC allPhotoArr:[NSMutableArray arrayWithObjects:_thirdAppBean, nil] nowNum:0 fromDownList:YES];
                [self.navigationController pushViewController:picVC animated:YES];
        }else if ([_thirdAppCopyPath isEqualToString:RealDownloadVideoPath])
        {
            [self play:_thirdAppBean.filePath anim:YES];
        }
        else
        {
            if ([DOC_DIC objectForKey:[[_thirdAppUrl.absoluteString pathExtension]lowercaseString]]) {
                WebViewController * web = [[WebViewController alloc]init];
                web.scanDelegate=self;
                [web getPath:_thirdAppBean pathArray:[NSArray arrayWithObject:_thirdAppBean]];
                [self.navigationController pushViewController:web animated:YES];
            }else{
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"dontsupportthetype",@"" ) message:NSLocalizedString(@"useotherappopen",@"" ) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"" ) otherButtonTitles:NSLocalizedString(@"otherappopen",@"" ),nil];
                alert.tag = ANOTHER_APP_OPEN;
                [alert show];

            }
        }
    }
    _thirdAppFile = NO;
}

-(void)moveDownloadFile{
    
    [FileSystem setMoveFileIngValue:@"0"];
    if (![FileSystem isConnectedKE]) {
        [[DownloadManager shareInstance] pauseAll];
        [[DownloadManager shareInstance] changeLocalFileToKe];
    }
    
}

-(void)moveFilesToKe{
    
    [FileSystem setMoveFileIngValue:@"1"];
    
    NSArray* array = [self getFiles:_copyIndex];
    while (array.count == 0 && _copyIndex < 4) {
        _copyIndex ++;
        array = [self getFiles:_copyIndex];
    }
    NSString* toPath = [self getKePathAt:_copyIndex];
    FilePropertyBean* propertyBean = [FileSystem readFileProperty:toPath];
    if (_copyIndex != 4 && !propertyBean) {
        int ret = [FileSystem creatDir:toPath];
        NSString *createStr = [NSString stringWithFormat:@"DEBUGMODEL creatteDir: %@ , state: %d -moveFileToKe------ViewController-createPath",toPath,ret];
        [LogUtils writeLog:createStr];
    }
    [self performSelectorOnMainThread:@selector(doMoveFilesToKe) withObject:nil waitUntilDone:YES];
}

-(void)doMoveFilesToKe{
    NSString* toPath = [self getKePathAt:_copyIndex];
     NSArray* array = [self getFiles:_copyIndex];
    if (array.count > 0) {
        if (!_operation) {
            _operation = [[FileOperate alloc] init];
        }
        _operation.delegate = self;
        NSString* msg = [self getCopyMsgAt:_copyIndex];
        
        [_operation copyFiles:array toPath:toPath userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"copy",@"action",@"1",@"notshowcancel",
                                                            nil] alertMsg:msg];
    }
    else if(_copyIndex >= 4){
        [LogUtils writeLog:@"MOVE FILES 2222"];
        [[CustomFileManage instance] cleanPathCacheAll];
        [self moveDownloadFile];
        [FileSystem setConnectCopiedInit];
        [self needVolumeHidenLoading:nil];
        if (_keOn) {
            [lightView beginData];
        }
    }
}

-(void)deleteFilesFromPhone{
    NSArray* array = [self getFiles:_copyIndex];
    NSString* msg = [self getDeleteMsgAt:_copyIndex];
    [_operation deleteFiles:array userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"delete",@"action",
                                            nil] alertMsg:msg];
}

-(NSArray*)getFiles:(NSInteger)index{
    
    if (index>=self.resArr.count) {
        return nil;
    }
    return [self.resArr objectAtIndex:index];
}

-(void)kunerViewHidden:(BOOL)hidden isUsbOn:(BOOL)ison
{
    if (!hidden) {
        [[DownloadManager shareInstance] pauseAll];
    }
    [self setNavLeftAndRightBtnHidden:!hidden];
    [self resetKunerViewText:ison];
    [self kunerViewHidden:hidden];
    
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@kunerViewHidden isusbon:%d",DEBUGMODEL,hidden]];
}

-(void)setNavLeftAndRightBtnHidden:(BOOL)hidden
{
    _topLeftButton.hidden = hidden;
    _topRightButton.hidden = hidden;
    
    _topLeftButtonImgV.hidden = hidden;
    _topRightButtonImgV.hidden = hidden;
    
    if (!hidden) {
        if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
            _musicplayanimateImgV.hidden = NO;
            if (rotationAnimation == nil) {
                [self startMusicPlayingAnimation];
            }
            _topRightButtonImgV.hidden = YES;
        }
        else{
            [_musicplayanimateImgV.layer removeAllAnimations];
            _musicplayanimateImgV.hidden = YES;
            rotationAnimation = nil;
        }
    }
    else{
        _musicplayanimateImgV.hidden = YES;
    }

}

-(void)kunerViewHidden:(BOOL)hidden{
    
    _btnTableview.userInteractionEnabled = hidden;
    if (_lastKunerViewHiden != hidden && lightView) {
        [lightView resetSizeLableColor:!hidden];
        [UIApplication sharedApplication].idleTimerDisabled = !hidden;
        _lastKunerViewHiden = hidden;
        if (hidden) {
            [self startgetMusicThread];
            
            for(UIViewController* vc in self.vcArr){
                if ([vc isKindOfClass:[FileViewController class]]) {
                    ((FileViewController*)vc).needReload = true;
                }
            }
            
            [self needVolume];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!hidden) {
            [_scrView setContentOffset:CGPointMake(0, 0) animated:YES];
            _scrView.scrollEnabled = NO;
        }
        else{
            _scrView.scrollEnabled = YES;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            kunerView.alpha = hidden?0:1;
            if (topic) {
                topic.hidden = !hidden;
            }
        }];
    });
}

-(NSString*)getKePathAt:(NSInteger)index{
    if (index == 0) {
        return KE_PHOTO;
    }
    else if (index == 1) {
        return KE_VIDEO;
    }
    else if (index == 2) {
        return KE_MUSIC;
    }
    else if (index == 3) {
        return KE_DOC;
    }
    else if (index == 4) {
        return KE_ROOT;
    }
    return KE_DOC;
}

-(NSString*)getPhonePathAt:(NSInteger)index{
    if (index == 0) {
        return PHONE_PHOTO;
    }
    else if (index == 1) {
        return PHONE_VIDEO;
    }
    else if (index == 2) {
        return PHONE_MUSIC;
    }
    else if (index == 3) {
        return PHONE_DOC;
    }
    else if (index == 4) {
        return APP_DOC_ROOT;
    }
    return PHONE_DOC;
}

-(NSString*)getCopyMsgAt:(NSInteger)index{
    if (index == 0) {
        return NSLocalizedString(@"movephoto", @"");
    }
    else if (index == 1) {
        return NSLocalizedString(@"movevideo", @"");
    }
    else if (index == 2) {
        return NSLocalizedString(@"movemusic", @"");
    }
    else if (index == 3) {
        return NSLocalizedString(@"movedoc", @"");
    }
    else if (index == 4) {
        return NSLocalizedString(@"moveother", @"");
    }
    return NSLocalizedString(@"movedoc", @"");
}

-(NSString*)getDeleteMsgAt:(NSInteger)index{
    if (index == 0) {
        return NSLocalizedString(@"deletephoto", @"");
    }
    else if (index == 1) {
        return NSLocalizedString(@"deletevideo", @"");
    }
    else if (index == 2) {
        return NSLocalizedString(@"deletemusic", @"");
    }
    else if (index == 3) {
        return NSLocalizedString(@"deletedoc", @"");
    }
    else if (index == 4) {
        return NSLocalizedString(@"deleteother", @"");
    }
    return NSLocalizedString(@"deletedoc", @"");
}

-(void)gotoResUI:(int)uiType title:(NSString*)title resType:(int)resType{
    [self gotoResUI:uiType title:title resType:resType animation:YES];
}

-(void)gotoResUI:(int)uiType title:(NSString*)title resType:(int)resType animation:(BOOL)animate{
    [LogUtils writeLog:[NSString stringWithFormat:@"ResUI:%d title:%@ resType:%d",uiType,title,resType]];
    UIViewController* vc;
    if (resType<self.vcArr.count) {
        vc = [self.vcArr objectAtIndex:resType];
    }
     if (!vc || [vc isKindOfClass:[NSNumber class]]) {
        FileViewController *newVC = [[FileViewController alloc] init];
        newVC.uiType = uiType;
        newVC.resType = resType;
        newVC.isTypeUIRoot = YES;
        newVC.titleStr = title;
        [self.vcArr replaceObjectAtIndex:resType withObject:newVC];
        vc = newVC;
    }
    else {
        [self performSelector:@selector(delayReloadData:) withObject:vc afterDelay:.1];
    }
    [MobClickUtils event:@"MAIN_MENU_CLICK" label:title];
    [self.navigationController pushViewController:vc animated:animate];
}

-(void)delayReloadData:(UIViewController*)vc{
    [((FileViewController*)vc) checkAndChangeTab];
    [((FileViewController*)vc) readData:((FileViewController*)vc).needReload];
    ((FileViewController*)vc).needReload = false;
}

-(void)playNowVideo{
    MusicPlayerViewController * newPlayView=[MusicPlayerViewController instance];
    newPlayView.fromRoot = YES;
    [self.navigationController pushViewController:newPlayView animated:YES];
}

- (NSString *)getDownloadingCellSubTitle:(NSString *)title
{
    NSString *subTitle = @"";
    if ([title isEqualToString:NSLocalizedString(@"resourceDownload", @"")]) {
        
        if ([self isDownloading]) {
            subTitle = NSLocalizedString(@"downloadingtip", @"");
        }
    }
    
    return subTitle;
}

- (BOOL)isDownloading
{
    NSArray *downloadingArr = [[DownloadManager shareInstance] getDownloadingArray];
    for (id obj in downloadingArr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *itemDic = (NSDictionary *)obj;
            NSString *fPath = itemDic[@"fpath"];
            DOWNLOAD_STATUS status = [[DownloadManager shareInstance] getItemDownloadStatus:fPath];
            NSLog(@"DOWNLOAD_STATUS: %ld, fPath=%@",status,fPath);
            if (status == STATUS_DOWNLOADING) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - 第三方导入视频播放

-(void)play:(NSString *)path anim:(BOOL)isAnim{
    
    [[MusicPlayerViewController instance] setMovPlay:YES];
    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
        [[MusicPlayerViewController instance]playorpause];
    }
    [VideoViewController setVideoPlaying:YES];
    
    if(_player){
        _player.view.frame = CGRectMake(0,
                                        [UIScreen mainScreen].bounds.size.height,
                                        [UIScreen mainScreen].bounds.size.width,
                                        [UIScreen mainScreen].bounds.size.height);
        
        [_player self_dealloc];
        [_player.view removeFromSuperview];
        [_player removeFromParentViewController];
        _player = nil;
    }
    _player = [[KxMovieViewController alloc] init];
    _player.kxBackDelegate = self;
    [self.view addSubview:_player.view];
    
    path = [@"/" stringByAppendingPathComponent:path];
    
    if(!IS_TAIG){
        if([path hasPrefix:KE_PHOTO] || [path hasPrefix:KE_VIDEO] || [path hasPrefix:KE_MUSIC] || [path hasPrefix:KE_DOC] || [path hasPrefix:KE_ROOT]){
            
            path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
        }
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [_player setPath:path parameters:nil];
    
    [self presentViewController:_player animated:YES completion:^{
    }];
    
    [[MusicPlayerViewController instance] setMovPlay:NO];
}

#pragma mark KxBackDelegate

-(void)clickBackBtn{
    
    if (_player) {
        [_player removeViewAtBottom];
    }
    
    [FileSystem rotateWindow:NO];
    
    if (!_player) {
        return;
    }
    
    [VideoViewController setVideoPlaying:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self dismissViewControllerAnimated:_player completion:^{
        if(_player){
            [_player self_dealloc];
            _player = nil;
        }
    }];
}

-(void)playEnd{
    NSLog(@"playEnd");
    [self clickBackBtn];
}

- (void)playError:(NSError *)error{
    NSLog(@"PlayError");
    [self clickBackBtn];
}

-(BOOL)playForward{
    NSLog(@"playForward");
    return NO;
}

-(BOOL)playRewind{
    NSLog(@"playRewind");
    return NO;
}

#pragma mark -

#pragma mark Update About Methods

-(void)checkthenumber:(NSString *)what{
    // 隐藏左侧菜单
    [self leftMenuSelectedAt:@"-1"];
    
    // push
    PAPasscodeViewController * checknum = [[PAPasscodeViewController alloc]initForAction:PasscodeActionEnter whatview:what newPassWord:NO lastAnswer:nil];
    [self.navigationController pushViewController:checknum animated:YES];
}

-(void)rightbutton{
    _topRightButton.userInteractionEnabled=YES;
}
-(void)leftMenuSelectedAt:(NSString *)itemIndexName {
    /*
     NSLocalizedString(@"about", @""),
     @"专题",
     NSLocalizedString(@"setting",@""),
     NSLocalizedString(@"feedback", @""),
     @"客服电话",
     nil];
     */
    
    _turnRight = NO;
    if ([itemIndexName isEqualToString:NSLocalizedString(@"about", @"")]) {
        [MobClickUtils event:@"LEFT_MENU_CLICK" label:@"About"];
        AboutKuke* aboutVC = [[AboutKuke alloc] init];
        aboutVC.backDelegate = self;
        [self.navigationController pushViewController:aboutVC animated:NO];
    }
    else if ([itemIndexName isEqualToString:NSLocalizedString(@"setting",@"")]){
        
        [MobClickUtils event:@"LEFT_MENU_CLICK" label:@"setting"];
        SettingView * setting = [[SettingView alloc]init];
        setting.backDelegate =self;
        [self.navigationController pushViewController:setting animated:NO];
    }else if ([itemIndexName  isEqualToString: PHONEINFORMANTION]){
        PhoneInformantion * phoneV = [[PhoneInformantion alloc]init];
        phoneV.backDelegate = self;
        [self.navigationController pushViewController:phoneV animated:YES];
    }else if ([itemIndexName  isEqualToString:NSLocalizedString(@"topicTitle",@"")]){
        SpecialTopicViewController * spvc = [[SpecialTopicViewController alloc]init];
        spvc.backDelegate = self;
        spvc.barTitle = NSLocalizedString(@"topicTitle",@"");
        spvc.urlStr = KUKE_TOPIC_LIST_URL;
        [self.navigationController pushViewController:spvc animated:YES];
    }
    
    [UIView animateWithDuration:.3 animations:^{
        self.navigationController.view.frame=CGRectMake(0,
                                                        0,
                                                        self.navigationController.view.frame.size.width,
                                                        self.navigationController.view.frame.size.height);
    } completion:^(BOOL finished) {
        _maskButton.hidden = YES;
        if ([itemIndexName  isEqualToString:NSLocalizedString(@"feedback", @"")]) {
            
            [MobClickUtils event:@"LEFT_MENU_CLICK" label:@"Feedback"];
            
            UIViewController *feedVC = [UMFeedback feedbackModalViewController];
            FirstViewController *vc = [[FirstViewController alloc] init];
            [vc addChildViewController:feedVC];
            [vc.view addSubview:feedVC.view];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
          
            if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
                [[MusicPlayerViewController instance] playorpause];
            }
        }
    }];
}

-(void)onBackBtnPressed:(UIViewController *)vc{
    self.navigationController.view.frame=CGRectMake(self.navigationController.view.frame.size.width - 80,
                                                    0,
                                                    self.navigationController.view.frame.size.width,
                                                    self.navigationController.view.frame.size.height);
    vc.view.frame = CGRectMake(0,
                               0,
                               self.navigationController.view.frame.size.width,
                               self.navigationController.view.frame.size.height);
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController.view.superview addSubview:vc.view];
    [UIView animateWithDuration:.3 animations:^{
        vc.view.frame = CGRectMake(self.navigationController.view.frame.size.width,
                                   0,
                                   self.navigationController.view.frame.size.width,
                                   self.navigationController.view.frame.size.height);
        CGAffineTransform newTransform = CGAffineTransformConcat(_leftView.transform, CGAffineTransformInvert(_leftView.transform));
        [_leftView setTransform:newTransform];
    } completion:^(BOOL finished) {
 
        _maskButton.hidden = NO;
        
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){
        if(alertView.tag == FORMAT_APP_SYNC){
            
            if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
                [self checkthenumber:@"movetokuke"];
            }else{
                [lightView stopData];
//                [self movetokuke];
            }
            
        }else if (alertView.tag == THIRDAPPFILE){
            _copyOrNot = NO;
            NSString * str= _thirdAppUrl.absoluteString;
            NSString * fromwhere = [[str componentsSeparatedByString:@"://"] objectAtIndex:0];
            NSString * kind = [[str pathExtension] lowercaseString];
            if ([DOC_DIC objectForKey:kind]) {
                WebViewController * another = [[WebViewController alloc]init];
                [another thirdAppWebUrl:_thirdAppUrl];
                [self.navigationController pushViewController:another animated:YES];
            }else{
                if ([kind isEqualToString:@"mp3"]||[kind isEqualToString:@"m4a"]||[kind isEqualToString:@"jpg"]||[kind isEqualToString:@"png"]||[kind isEqualToString:@"gif"]||[kind isEqualToString:@"bmp"] || VIDEO_EX_DIC[kind] || MOV_EX_DIC[kind]) {
                    if ([FileSystem checkInit] && [fromwhere isEqualToString:@"file"]) {
                        [NSThread detachNewThreadSelector:@selector(copyDataToDocuments:) toTarget:self withObject:_thirdAppUrl];
                    }
                }else{
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"dontsupportthetype",@"" ) message:NSLocalizedString(@"useotherappopen",@"" ) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"" ) otherButtonTitles:NSLocalizedString(@"otherappopen",@"" ),nil];
                    alert.tag = ANOTHER_APP_OPEN;
                    [alert show];
                }
            }
        }
    }
    else if (buttonIndex == 1)
    {
        if (alertView.tag==FORMAT_FIRST){
            [self showAgainTip];
        }else if (alertView.tag == FORMAT_AGAIN){
            
            [self performSelector:@selector(doFormat) withObject:nil afterDelay:0.5];
        }else if (alertView.tag == THIRDAPPFILE){
            
            if ([FileSystem checkInit]) {
                _copyOrNot = YES;
                NSString * str= _thirdAppUrl.absoluteString;
                NSString * kind = [[str pathExtension] lowercaseString];
                _thirdAppBean = [[FileBean alloc]init];
                NSString * fromwhere;
                if ([kind isEqualToString:@"mp3"]||[kind isEqualToString:@"m4a"]) {
                    _copyTips = [NSString stringWithFormat:@"%@/%@/%@",NSLocalizedString(@"copyto",@""),NSLocalizedString(@"music",@""),NSLocalizedString(@"downloadaudiopath",@"")];
                    _thirdAppFile = YES;
                    fromwhere = [[str componentsSeparatedByString:@"://"] objectAtIndex:0];
                }else if ([kind isEqualToString:@"jpg"]||[kind isEqualToString:@"png"]||[kind isEqualToString:@"gif"]||[kind isEqualToString:@"bmp"]){
                    _copyTips = [NSString stringWithFormat:@"%@/%@/%@",NSLocalizedString(@"copyto",@""),NSLocalizedString(@"picture",@""),NSLocalizedString(@"downloadpicturepath",@"")];
                    _thirdAppFile = YES;
                    fromwhere = [[str componentsSeparatedByString:@"://"] objectAtIndex:0];
                }
                else if (VIDEO_EX_DIC[kind] || MOV_EX_DIC[kind]){
                    _copyTips = [NSString stringWithFormat:@"%@/%@/%@",NSLocalizedString(@"copyto",@""),NSLocalizedString(@"picture",@""),NSLocalizedString(@"downloadpicturepath",@"")];
                    _thirdAppFile = YES;
                    fromwhere = [[str componentsSeparatedByString:@"://"] objectAtIndex:0];
                }
                else{
                    _copyTips = [NSString stringWithFormat:@"%@/%@/%@",NSLocalizedString(@"copyto",@""),NSLocalizedString(@"document",@""),NSLocalizedString(@"downloaddocumentpath",@"")];
                    _thirdAppFile = YES;
                    fromwhere = [[str componentsSeparatedByString:@"://"] objectAtIndex:0];
                }
                
                if ([FileSystem checkInit] && [fromwhere isEqualToString:@"file"]) {
                    [NSThread detachNewThreadSelector:@selector(copyDataToDocuments:) toTarget:self withObject:_thirdAppUrl];
                }

            }else{
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"copynokuke",@"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"sure",@"") otherButtonTitles: nil];
                alert.tag = NOLINKKUKE;
                [alert show];

            }

        }else if (alertView.tag == ANOTHER_APP_OPEN){
        //第三方打开
            if (_copyOrNot) {
                [self openDocumentIn:_thirdAppBean];
            }else{
                [self openDocumentIn];
            }
            
            
        }
    }
}
-(void)openDocumentIn:(FileBean*)bean{
    
    [CustomNotificationView showToastWithoutDismiss:NSLocalizedString(@"readying",@"")];
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        BOOL result = [[CustomFileManage instance] copyToTempWith:bean];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomNotificationView clearToast];
            if (result) {
                
                NSString *path = [[[CustomFileManage instance] getLibraryTempPath] stringByAppendingPathComponent:bean.fileName];
                NSURL *URL= [NSURL fileURLWithPath:path];
                if (URL) {
                    documentController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                    documentController.delegate = self;
                    [documentController presentOpenInMenuFromRect:CGRectMake(0, 300, 100, 100) inView:self.view animated:YES];
                }
            }
            else{
                [CustomNotificationView showToast:NSLocalizedString(@"readyfail",@"")];
            }
        });
        
    });
    
    
}


-(void)openDocumentIn{
    
//    [CustomNotificationView showToastWithoutDismiss:NSLocalizedString(@"readying",@"")];
//    
//    dispatch_async(dispatch_queue_create(0, 0), ^{
//        BOOL result = [[CustomFileManage instance] copyToTempWith:bean];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [CustomNotificationView clearToast];
//            if (result) {
//                
//                NSString *path = [[[CustomFileManage instance] getLibraryTempPath] stringByAppendingPathComponent:bean.fileName];
                NSURL *URL= _thirdAppUrl;
                if (URL) {
                    documentController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                    documentController.delegate = self;
                    [documentController presentOpenInMenuFromRect:CGRectMake(0, 300, 100, 100) inView:self.view animated:YES];
                }
//            }
//            else{
//                [CustomNotificationView showToast:NSLocalizedString(@"readyfail",@"")];
//            }
//        });
//        
//    });
    
}


-(void)updatekuke{
    [[AppUpdateUtils instance] updateVersion];
}
-(void)showAgainTip{
    
    UIAlertView * affirmformat = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"formatting",@"") message:NSLocalizedString(@"format_surey",@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"sure",@""), nil];
    affirmformat.tag = FORMAT_AGAIN;
    affirmformat.delegate = self;
    [affirmformat show];
}

-(void)doFormat{
    [[DownloadManager shareInstance] pauseAll];
    
    [self resetPlayingKeMusic];
    _test = [[YpcCustomProgress alloc] init];
    [_test startPainting:YES];
    [_test backZero];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    dispatch_async(_dispatchQueue, ^{
        
        ret = [[CustomFileManage instance]formatSystem];
        
        __weak ViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [FileSystem resetLocked];
            [[DownloadManager shareInstance] removeAllDownloadInfo];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [_test goToHundred];
            
            [[CustomFileManage instance] cleanPathCacheAll];
            [[CustomFileManage instance] removeDir:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/musiccache"]];
            [[CustomFileManage instance] removeDir:[FileSystem getHarddiskIconCachePath]];
            [[CustomFileManage instance] removeDir:[FileSystem getIconCachePath]];
            [[CustomFileManage instance] removeDir:[FileSystem getCachePath]];
            [self needVolume];
//            [FileSystem createDirIfNotExist];
            [self resetPlayingKeMusic];
            [_test removeTheFormatView];
            _test = nil;
            [weakSelf endControlDelay];
            [weakSelf performSelector:@selector(endControlDelay) withObject:nil afterDelay:0.5];
            [weakSelf performSelector:@selector(formatlater) withObject:nil afterDelay:1.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_FORMATE object:nil];
        });
    });
}
-(void)endControlDelay{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}
- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
}

-(void)formatlater
{
    if (_kunerlost) {
        UIAlertView * fail=[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"formatfail",@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure",@"") otherButtonTitles:nil];
        [fail show];
    }else{
        
        if(ret){
            
            UIAlertView * success=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"formatdone",@"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethods:)
                                           userInfo:success
                                            repeats:YES];
            [success show];
        }else{
            _failAlert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"formatfail",@"") message:NSLocalizedString(@"formatagainy",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"sure",@""), nil];
            _failAlert.tag=FORMATFAIL;
            _failAlert.delegate=self;
            [_failAlert show];
            
        }
    }
}

-(void)resetPlayingKeMusic{
    
    FileBean* curFileBean = [[MusicPlayerViewController instance] getCurrentBean];
    if ([curFileBean.filePath rangeOfString:KE_ROOT].location != NSNotFound) {
        [[MusicPlayerViewController instance] deletefinishrefresh:[NSArray array] deletenowplay:NO];
    }
}

-(void)maskBtnPressed:(UIButton*)button {
    [self leftMenuSelectedAt:@"-1"];
}

-(void)clickRight{
    if (fromsafenum) {
        [self startgetMusicThread];
    }
     _topLeftButton.userInteractionEnabled=NO;
    [MobClickUtils event:@"MAIN_TOP_CLICK" label:@"Music"];
    [self playNowVideo];
    
    [self performSelector:@selector(leftbutton) withObject:nil afterDelay:0.5];
}

-(void)leftbutton{

    _topLeftButton.userInteractionEnabled=YES;
}
//隐藏头部导航条
-(void)HiddenTopView:(BOOL)animated{
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            _topView.frame=CGRectMake(0,
                                      -64.0*WINDOW_SCALE,
                                      self.view.frame.size.width,
                                      64.0*WINDOW_SCALE);
        }];
    }else{
        _topView.hidden=YES;
    }
    
}
//显示头部导航条
-(void)AppearTopView:(BOOL)animated{
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            _topView.frame=CGRectMake(0,
                                      64.0*WINDOW_SCALE,
                                      self.view.frame.size.width,
                                      64.0*WINDOW_SCALE);
        }];
    }else{
        _topView.hidden=NO;
    }
    
}
//是否显示底部视图
-(void)hiddenOrAppearBottom:(BOOL)hidden{
    
    if (hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame=CGRectMake(0,
                                          64.0*WINDOW_SCALE,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-64.0*WINDOW_SCALE);
            _bottomView.frame=CGRectMake(0,
                                         self.view.frame.size.height,
                                         self.view.frame.size.width,
                                         64.0*WINDOW_SCALE);
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame=CGRectMake(0,
                                          64.0*WINDOW_SCALE,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-64.0*WINDOW_SCALE*2.0);
            _bottomView.frame=CGRectMake(0,
                                         self.view.frame.size.height-64.0*WINDOW_SCALE,
                                         self.view.frame.size.width,
                                         64.0*WINDOW_SCALE);
            
        }];
    }
    
}

#pragma mark - tableview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _nameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identify=@"classcell";
    ClassBtnCellTableViewCell * cell=[_btnTableview dequeueReusableCellWithIdentifier:identify];
    _btnTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (cell==nil) {
        cell=[[ClassBtnCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    if (indexPath.row<_iconAry.count) {
        [cell setImage:[_iconAry objectAtIndex:indexPath.row]];
    }
    
    if (indexPath.row<_nameArr.count) {
        NSString *title = [_nameArr objectAtIndex:indexPath.row];
        [cell setName:title];
        [cell setSubTitle:[self getDownloadingCellSubTitle:title]];
    }
    
    if (indexPath.row == (_nameArr.count -1)) {
        [cell setLineLast:60*WINDOW_SCALE_SIX];
    }
    else{
        [cell setLineNormal:60*WINDOW_SCALE_SIX];
    }
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - tableView delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60*WINDOW_SCALE_SIX;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_cellClicked) {
        return;
    }
    
    _cellClicked = YES;
    [self performSelector:@selector(clickDone) withObject:nil afterDelay:.5];
    
    if (indexPath.row<_nameArr.count) {
        NSString *nowPath = [_nameArr objectAtIndex:indexPath.row];
        _nowPath = nowPath;
    }
    
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        [self checkthenumber:@"mneucell"];
    }else{
        [self selectCell];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    _topLeftButton.userInteractionEnabled = NO;
    lightView.btnRight.userInteractionEnabled = NO;
    _dontTouch = YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    _topLeftButton.userInteractionEnabled = YES;
    lightView.btnRight.userInteractionEnabled = YES;
    _dontTouch = NO;
}

-(void)selectCell{
    
    
    [FileSystem createDirIfNotExist];
    
    [self delayCheck];
    if ([_nowPath isEqualToString:NSLocalizedString(@"picture",@"")]) {
        [self gotoResUI:Picture_UI_Type title:NSLocalizedString(@"picture",@"") resType:Picture_Res_Type];
    }
    else if ([_nowPath isEqualToString:NSLocalizedString(@"video",@"")]) {
        [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"video",@"") resType:Video_Res_Type];
    }
    else if ([_nowPath isEqualToString:NSLocalizedString(@"music",@"")]) {
        [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"music",@"") resType:Music_Res_Type];
    }
    else if ([_nowPath isEqualToString:NSLocalizedString(@"document",@"")]) {
        [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"document",@"") resType:Document_Res_Type];
    }
    else if ([_nowPath isEqualToString:NSLocalizedString(@"rootPath",@"")]) {
        NSString* rootPath = ([FileSystem checkInit]?[self getKePathAt:4] : [self getPhonePathAt:4]) ;
        [[CustomFileManage instance] cleanPathCache:rootPath];
        [self gotoResUI:Document_UI_Type title:NSLocalizedString(@"rootPath",@"") resType:Root_Res_Type];
    }
    else if ([_nowPath isEqualToString:NSLocalizedString(@"resourceDownload",@"")]) {
        NSString *str = RESOURCE_DOWNLOAD_URL;//@"http://www.kuke.com.cn/kuke/index/videoSource.html";
        NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];
        NSString *urlstr = [NSString stringWithFormat:@"%@?version=%@",str,version];
        [self gotoWebUI:[NSURL URLWithString:urlstr] title:NSLocalizedString(@"resourceDownload",@"") downloadWeb:YES];
        [MobClickUtils event:@"MAIN_MENU_CLICK" label:@"资源下载"];
    }
}

-(void)clickDone
{
    _cellClicked = NO;
}

#pragma mark -

-(void)showPlayer{
    
}

-(void)hiddenPlayer{
    
}

#pragma mark - topic 

-(void)operateTopicViewIsAdd:(BOOL)isadd topicTitle:(NSString *)title
{
    CGFloat changeheight = isadd? TOPICVIEWHEIGHT : (topic? -TOPICVIEWHEIGHT : 0);
    if (topic) {
        for (UIView *view in topic.subviews) {
            [view removeFromSuperview];
        }
        if (topic.superview) {
            [topic removeFromSuperview];
        }
        topic = nil;
    }
    
    if (isadd) {
        topic = [[UIView alloc] initWithFrame:CGRectMake(0, _btnTableview.frame.origin.y, SCREEN_WIDTH, TOPICVIEWHEIGHT)];
        topic.backgroundColor = [UIColor colorWithRed:255/255.0 green:250/255.0 blue:206/255.0 alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15*WINDOW_SCALE_SIX, 0, topic.frame.size.width, topic.frame.size.height)];
        label.textColor = [UIColor colorWithRed:52.0/255.0 green:56/255.0 blue:57/255.0 alpha:1.0];
        label.text = title;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:15.0];
        [topic addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = label.frame;
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(topicBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [topic addSubview:btn];
        
        UIView *_lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:253/255.0 green:216/255.0 blue:53/255.0 alpha:1.0];
        _lineView.frame = CGRectMake(0, topic.frame.size.height - 1, topic.frame.size.width, 0.5);
        [topic addSubview:_lineView];
        
        UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"main_topic_arrow" bundle:@"TAIG_MainImg"]];
        arrow.frame = CGRectMake(SCREEN_WIDTH-26, (topic.frame.size.height - 12)/2.0, 12, 12);
        [topic addSubview:arrow];
        
        [_downView addSubview:topic];
    }
    
    _btnTableview.frame = CGRectMake(_btnTableview.frame.origin.x, _btnTableview.frame.origin.y + changeheight, _btnTableview.frame.size.width, _btnTableview.frame.size.height);
    allResBtn.frame = CGRectMake(allResBtn.frame.origin.x, allResBtn.frame.origin.y + changeheight, allResBtn.frame.size.width, allResBtn.frame.size.height);
    _scrView.contentSize = CGSizeMake(_scrView.contentSize.width, _scrView.contentSize.height + changeheight);
    _downView.frame = CGRectMake(_downView.frame.origin.x, _downView.frame.origin.y, _downView.frame.size.width, allResBtn.frame.size.height + allResBtn.frame.origin.y+20);
}

-(void)topicBtnPressed
{
    if (topicInfoDict) {
        NSString *urlstr = [topicInfoDict objectForKey:@"url"];
        if ([urlstr isKindOfClass:[NSNull class]]) {
            return;
        }
        if ([urlstr rangeOfString:@"?"].location != NSNotFound) {
            urlstr = [NSString stringWithFormat:@"%@&time=%ld",urlstr,time(0)];
        }
        else {
            urlstr = [NSString stringWithFormat:@"%@?time=%ld",urlstr,time(0)];
        }
        NSURL *url = [NSURL URLWithString:urlstr];
        [MobClickUtils event:@"MAIN_MENU_CLICK" label:@"专题"];
        [self gotoWebUI:url title:NSLocalizedString(@"topicTitle", @"") downloadWeb:NO];
    }
}

#pragma mark - recivice push noti

-(void)popToSelfWithoutLeftView
{
    _turnRight = NO;
    
    if (_maskButton.hidden == NO) {
        self.navigationController.view.frame=CGRectMake(0,
                                                        0,
                                                        self.navigationController.view.frame.size.width,
                                                        self.navigationController.view.frame.size.height);
        _maskButton.hidden = YES;
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - rotate

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
 
