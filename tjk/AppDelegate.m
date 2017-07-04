//
//  AppDelegate.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "CustomAlertView.h"
#import "CustomFileManage.h"
#import "MobClickUtils.h"
#import "FileSystem.h"
#import "CustomMusicPlayer.h"
#import "MusicPlayerViewController.h"
#import "VideoViewController.h"
#import "ListVideoViewController.h"
#import "DownloadManager.h"
#import "APService.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>

@interface AppDelegate (){
    BOOL _active;
    AVAudioPlayer *_player;
    NSTimer* _backgroundTimer;
}

@end

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    [LogUtils writeLog:[NSString stringWithFormat:@"%s\n%p", __FUNCTION__,exception]];
    [FileSystem tgk_system_exit];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self printMethod];
    [self allPropertyNames];
//     [[UIApplication sharedApplication]registerUserNotificationSettings:<#(nonnull UIUserNotificationSettings *)#>];
//     初始化文件系统
    [[CustomFileManage instance] initSystem];
    
    // 第三方注册
    [WXApi registerApp:WX_APPKEY]; // 微信
    [MobClickUtils MobClickInit];  // 友盟
    [self addJPushNotification];   // 极光推送
    [APService setupWithOption:launchOptions];
    [APService setLogOFF]; //关闭log模式
    
    // UI
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self loadView];
    
    // 汇报 点击本地通知开启app事件
    [self reportLocalNotificationEvent:launchOptions];
    
    // 清除缓存
    [self removeVideoCache];
    [[CustomFileManage instance] cleanThirdOpenTempPathfiles];
    
    return YES;
}
- (NSArray *) allPropertyNames{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    
    ///存储属性的个数
    unsigned int propertyCount = 0;
    
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([PHPhotoLibrary class], &propertyCount);
    
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        
        const char * propertyName = property_getName(property);
        
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    
    ///释放
    free(propertys);
    
    return allNames;
}
- (void)printMethod{

    unsigned int methCount = 0;
    Method *meths = class_copyMethodList([PHPhotoLibrary class], &methCount);
    
    for(int i = 0; i < methCount; i++) {
        
        Method meth = meths[i];
        
        SEL sel = method_getName(meth);
        
        const char *name = sel_getName(sel);
        
        NSLog(@"%s", name);
    }  
    
    free(meths);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    _active = NO;
    if (![[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]) {
        [self endControlDelay];
        [self performSelector:@selector(endControlDelay) withObject:nil afterDelay:0.5];
    }
    
    _backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(startBackground) userInfo:nil repeats:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if (![[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]) {
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.4f) {
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        }
        
        [self endControlDelay];
        [self performSelector:@selector(endControlDelay) withObject:nil afterDelay:0.5];
    }
    
    [self addLocalNotificationWithRomveAll:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (_backgroundTimer) {
        [_backgroundTimer invalidate];
        _backgroundTimer = nil;
    }
    
    _active = YES;
    if ([MobClickUtils MobClickIsActive]) {
        [FileSystem tgk_fso_re_init];
    }
    
    if (![[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]) {
        [self endControlDelay];
        if (!_player) {
            [self playBackground];
        }
        
        [self performSelector:@selector(endControlDelay) withObject:nil afterDelay:0.5];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if (![sourceApplication isEqualToString:@"com.tencent.xin"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"POST_URL" object:url];
        return YES;
    }
    else
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"devicetoken:%@",deviceToken);
   
    
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self reciviceNoti:userInfo];
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    // 图标上的数字减1
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSDictionary *userinfo = notification.userInfo;
    if ([[userinfo objectForKey:@"one"] isEqualToString:@"one"]) {
        if (_rootVC) {
            [_rootVC.navigationController popToViewController:_rootVC animated:NO];
            [_rootVC gotoResUI:Picture_UI_Type title:NSLocalizedString(@"picture",@"") resType:Picture_Res_Type];
        }
    }
    else if ([[userinfo objectForKey:@"two"] isEqualToString:@"two"]){
        if (_rootVC) {
            [_rootVC.navigationController popToViewController:_rootVC animated:NO];
            NSString *str = RESOURCE_DOWNLOAD_URL;//@"http://www.kuke.com.cn/kuke/index/videoSource.html";
            NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];
            NSString *urlstr = [NSString stringWithFormat:@"%@?version=%@",str,version];
            [_rootVC gotoWebUI:[NSURL URLWithString:urlstr] title:NSLocalizedString(@"resourceDownload", @"") downloadWeb:YES backToHomeWeb:NO];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[DownloadManager shareInstance] saveDownlaodList:NO];
    
    NSString * paths = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
    if ([MusicPlayerViewController instance].noplayMusicplistDict.count>0) {
        [[MusicPlayerViewController instance].noplayMusicplistDict writeToFile:paths atomically:YES];
    }
    [self addLocalNotificationWithRomveAll:YES];
    if ([MobClickUtils MobClickIsActive]) {
        [FileSystem tgk_system_exit];
    }
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * string = [APP_DOC_ROOT stringByAppendingPathComponent:@"Inbox"];
    if ([fm fileExistsAtPath:string]) {
        [fm removeItemAtPath:string error:nil];
    }
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *) receivedEvent{
    // UIResponder method
    
    [[MusicPlayerViewController instance]avoidconflict:YES];
    if ([VideoViewController isVideoPlaying] || [ListVideoViewController isVideoPlaying]) {
        //视频正在播放
    }else{
        if ([MusicPlayerViewController instance].nowPlayList.count==0) {
            
            return;
        }
        if (receivedEvent.type == UIEventTypeRemoteControl)
        {
            switch (receivedEvent.subtype)
            {
                case UIEventSubtypeRemoteControlPause:
                    //暂停
                    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
                        [[CustomMusicPlayer shareCustomMusicPlayer]pause];
                    }
                    break;
                case UIEventSubtypeRemoteControlNextTrack:
                    //下一首
                    [[MusicPlayerViewController instance]next:NO];
                    
                    break;
                case UIEventSubtypeRemoteControlPreviousTrack:
                    //上一首
                    [[MusicPlayerViewController instance]previous:NO];
                    
                    break;
                case UIEventSubtypeRemoteControlStop:
                    //停止
                    
                    break;
                case UIEventSubtypeRemoteControlPlay:
                    //播放
                    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
                        
                    }else{
                        [[CustomMusicPlayer shareCustomMusicPlayer]play];
                    }
                    break;
                case UIEventSubtypeRemoteControlBeginSeekingBackward:
                    
                    break;
                case UIEventSubtypeRemoteControlBeginSeekingForward:
                    
                    break;
                default:
                    break;
                    
            }
            
        }
        
    }
    [[MusicPlayerViewController instance]avoidconflict:NO];
}

#pragma mark - Interfaces

-(BOOL)isAppActive {
    return _active;
}

-(void)playBackground{
    if (_player) {
        [_player stop];
        _player = nil;
    }
    
    AVAudioSession *session = [[AVAudioSession alloc] init];
    [session setActive:YES error:nil];
    //    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.4f) {
    //        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    //    }
    //    else {
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    }
    //[session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    //播放背景音乐
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    // 创建播放器
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_player prepareToPlay];
    
    [_player setVolume:0];
    _player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    [_player play];
}

-(void)stopBackground{
    if (_player) {
        [_player stop];
        _player = nil;
    }
}

#pragma mark - Utility

-(void)loadView{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _rootVC = [[ViewController alloc] init];
    UIView *view = [_rootVC getleftView];
    [self.window addSubview:view];
    
    CustomNavigationController *_containerVC = [[CustomNavigationController alloc]initWithRootViewController:_rootVC];
    _containerVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerVC.edgesForExtendedLayout = UIRectEdgeNone;
    _containerVC.navigationBarHidden = YES;
    self.window.rootViewController = _containerVC;
    [self.window makeKeyAndVisible];
}

-(void)endControlDelay{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(void)addJPushNotification
{
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
}

-(void)removeVideoCache{
    // 视频播放记忆缓存
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary * dic = [userdefault dictionaryRepresentation];
    NSArray * array = [dic allKeys];
    NSMutableArray * videoArray = [[NSMutableArray alloc]init];
    for (NSString * filePath in array) {
        if ([filePath hasPrefix:@"/.KUKE.01/"]) {
            [videoArray addObject:filePath];
        }
    }
    
    NSDateFormatter * dataformat = [[NSDateFormatter alloc]init];
    [dataformat setDateFormat:@"dd-MM-yyyy"];
    
    if (videoArray.count!=0) {
        for (NSString *filePath in videoArray) {
            NSArray * array = [userdefault objectForKey:filePath];
            if (array && array.count) {
                NSString * timeformat = [array firstObject];
                NSDate * today = [NSDate date];
                NSDate * lastday = [dataformat dateFromString:timeformat];
                NSTimeInterval  time = [today timeIntervalSinceDate:lastday];
                int days = ((int)time)/(3600*24);
                if (days>=7) {
                    [userdefault removeObjectForKey:filePath];
                }
            }
        }
    }
}

-(void)reciviceNoti:(NSDictionary *)userinfo
{
    if (!_rootVC) {
        return;
    }
    if ([userinfo objectForKey:@"gotoURL"]) {
        [_rootVC popToSelfWithoutLeftView];
        NSString *urlstr = [userinfo objectForKey:@"gotoURL"];
        [_rootVC gotoWebUI:[NSURL URLWithString:urlstr] title:NSLocalizedString(@"resourceDownload", @"") downloadWeb:YES backToHomeWeb:YES];
    }
    
    if ([userinfo objectForKey:@"gotoPath"]) {
        NSString *uiTypestr = [userinfo objectForKey:@"gotoPath"];
        [_rootVC popToSelfWithoutLeftView];
        if ([[uiTypestr lowercaseString] isEqualToString:@"homepage"]) {
            
        }
        else if ([[uiTypestr lowercaseString] isEqualToString:@"download"]) {
            NSString *str = RESOURCE_DOWNLOAD_URL;
            NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];
            NSString *urlstr = [NSString stringWithFormat:@"%@?version=%@",str,version];
            [_rootVC gotoWebUI:[NSURL URLWithString:urlstr] title:NSLocalizedString(@"resourceDownload", @"") downloadWeb:YES backToHomeWeb:NO];
        }
        else if ([[uiTypestr lowercaseString] isEqualToString:@"topic"]) {
            [_rootVC topicBtnPressed];
        }
        else if ([[uiTypestr lowercaseString] isEqualToString:@"picture"]) {
            [_rootVC gotoResUI:Picture_UI_Type title:NSLocalizedString(@"picture",@"") resType:Picture_Res_Type];
        }
    }
}

-(void)startBackground{
    if (![((AppDelegate*)[[UIApplication sharedApplication] delegate]).window viewWithTag:CUSTUM_ALERT_ATG] && ![[[UIApplication sharedApplication] keyWindow] viewWithTag:CUSTUM_ALERT_ATG] && ![[CustomMusicPlayer shareCustomMusicPlayer] isPlaying] && [[DownloadManager shareInstance] getALLItemDownloadPaused]) {
        [FileSystem tgk_system_exit];
        exit(0);
    }
}

- (void)reportLocalNotificationEvent:(NSDictionary *)launchOptions
{ // 汇报点击本地推送打开app的事件
    if (launchOptions && launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [MobClickUtils event:@"OPEN_WITH_NOTICE"];
    }
}

#pragma mark - 本地通知

-(void)addLocalNotificationWithRomveAll:(BOOL)isremove
{
    if (isremove) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    [self addLocalNotificationWithDelayTime:3600*24*3 notiName:@"one" message:NSLocalizedString(@"localnotitipone", @"")];
    [self addLocalNotificationWithDelayTime:3600*24*7 notiName:@"two" message:NSLocalizedString(@"localnotitiptwo", @"")];
    [self addLocalNotificationWithDelayTime:3600*24*15 notiName:@"three" message:NSLocalizedString(@"localnotitipthree", @"")];
}


-(void)addLocalNotificationWithDelayTime:(NSTimeInterval)time notiName:(NSString *)name message:(NSString *)msg{
    
    // 创建一个本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:time];
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = pushDate;
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = 0;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = msg;
//        notification.applicationIconBadgeNumber = 1;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *info = [NSDictionary dictionaryWithObject:name forKey:name];
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
        
    }
}


-(BOOL)isExistNotificationForKey:(NSString *)string{
    BOOL isAdd = NO;
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    //声明本地通知对象
    UILocalNotification *localNotification;
    if (localArray) {
        for (UILocalNotification *noti in localArray) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:string];
                if ([inKey isEqualToString:string]) {
                    if (localNotification){
                        isAdd = YES;
                    }
                    break;
                }
            }
        }
    }
    return isAdd;
}

#pragma mark - WXApiDelegate

-(void)onReq:(BaseReq *)req{
}

-(void)onResp:(BaseResp *)resp{
}

@end
