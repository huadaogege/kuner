//
//  FormatView.m
//  tjk
//
//  Created by huadao on 15/7/3.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "FormatView.h"
#import "DownloadManager.h"
#import "FileSystem.h"

#define FORMATFAIL 333
@implementation FormatView

- (id)initWithState:(FormatStateCode)stateCode
{
    self = [super init];
    if (self) {
        _stateCode = stateCode;
    }
    
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
  
    _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
    self.view.backgroundColor = [UIColor whiteColor];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"formatekuke", @"");
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
    
    BOOL ischinalan = [FileSystem isChinaLan];
    CGFloat originY = 140*WINDOW_SCALE_SIX;
    if (!ischinalan) {
        originY = 100*WINDOW_SCALE_SIX;
    }

    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, originY, SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:20*WINDOW_SCALE_SIX];
    label1.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
    label1.text = NSLocalizedString(@"formattiptosure", @"");
    [self.view addSubview:label1];
    
    
    originY = 206*WINDOW_SCALE_SIX;
    if (!ischinalan) {
        originY = label1.frame.origin.y + label1.frame.size.height + 36*WINDOW_SCALE_SIX;
    }
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(0,originY , SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:17*WINDOW_SCALE_SIX];
    label2.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
    label2.text = NSLocalizedString(@"formattipfour", @"");
    
    [self fitLanSizeWithLabel:label2 labelfont:[UIFont systemFontOfSize:17]];
    
    [self.view addSubview:label2];

    
    originY = 64+338*WINDOW_SCALE_SIX/2.0;
    if (!ischinalan) {
        originY = label2.frame.origin.y + label2.frame.size.height + 6*WINDOW_SCALE_SIX;
    }
    UILabel * label3 = [[UILabel alloc]initWithFrame:CGRectMake(0,originY, SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.font = [UIFont systemFontOfSize:14*WINDOW_SCALE_SIX];
    label3.textColor = [UIColor colorWithRed:107.0/255.0 green:109.0/255.0 blue:115.0/255.0 alpha:1.0];
    label3.text = NSLocalizedString(@"formattipthree", @"");
    
    [self fitLanSizeWithLabel:label3 labelfont:[UIFont systemFontOfSize:14]];
    
    [self.view addSubview:label3];
    
    originY = 64+465*WINDOW_SCALE_SIX/2.0;
    if (!ischinalan) {
        originY = label3.frame.origin.y + label3.frame.size.height + 20*WINDOW_SCALE_SIX;
    }
    UILabel * label4 = [[UILabel alloc]initWithFrame:CGRectMake(0, originY, SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.font = [UIFont systemFontOfSize:17*WINDOW_SCALE_SIX];
    label4.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
    label4.text = NSLocalizedString(@"formattiptwo", @"");
    [self fitLanSizeWithLabel:label4 labelfont:[UIFont systemFontOfSize:17]];
    [self.view addSubview:label4];

    originY = 64+520*WINDOW_SCALE_SIX/2.0;
    if (!ischinalan) {
        originY = label4.frame.origin.y + label4.frame.size.height + 6;
    }
    UILabel * label5 = [[UILabel alloc]initWithFrame:CGRectMake(0,originY, SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.font = [UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
    label5.textColor = [UIColor colorWithRed:107.0/255.0 green:109.0/255.0 blue:115.0/255.0 alpha:1.0];
    label5.text = NSLocalizedString(@"formattipone", @"");
    [self fitLanSizeWithLabel:label5 labelfont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:label5];
    
    UILabel * label6 = [[UILabel alloc]initWithFrame:CGRectMake(0, 64+661*WINDOW_SCALE_SIX/2.0, SCREEN_WIDTH, 30*WINDOW_SCALE_SIX)];
    label6.textAlignment = NSTextAlignmentCenter;
    label6.font = [UIFont systemFontOfSize:20*WINDOW_SCALE_SIX];
    label6.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
    label6.text = NSLocalizedString(@"issuretodelete", @"");
    [self.view addSubview:label6];
    
    UIImageView * confirm = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-240*WINDOW_SCALE_SIX)/2.0, 64.0+780*WINDOW_SCALE_SIX/2.0, 240*WINDOW_SCALE_SIX, 40*WINDOW_SCALE_SIX)];
    confirm.image = [UIImage imageNamed:@"btn_confirm.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    [self.view addSubview:confirm];
    
    confirms =[[UIButton alloc]initWithFrame:confirm.frame];
    confirms.tag = 111;
    [confirms addTarget:self action:@selector(clickbtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirms];
    [confirms setTitle:NSLocalizedString(@"sure", @"") forState:UIControlStateNormal];
    [confirms setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImageView * cancel = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-240*WINDOW_SCALE_SIX)/2.0, 64+936*WINDOW_SCALE_SIX/2.0, 240*WINDOW_SCALE_SIX, 40*WINDOW_SCALE_SIX)];
    cancel.image = [UIImage imageNamed:@"btn_cancel.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    [self.view addSubview:cancel];
    
    UIButton * cancels =[[UIButton alloc]initWithFrame:cancel.frame] ;
    [cancels addTarget:self action:@selector(clickbtn:) forControlEvents:UIControlEventTouchUpInside];
    cancels.tag = 222;
    [cancels setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
    [cancels setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:cancels];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];

}

-(void)fitLanSizeWithLabel:(UILabel *)tiplabel labelfont:(UIFont *)font
{
    if (![FileSystem isChinaLan]) {
        NSString *enstr = tiplabel.text;
        tiplabel.numberOfLines = 0;
        CGSize size = CGSizeMake(tiplabel.frame.size.width, 20000.0f);
        size = [enstr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
        
        tiplabel.frame = CGRectMake(tiplabel.frame.origin.x,tiplabel.frame.origin.y, tiplabel.frame.size.width, size.height+5);
    }
}

-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            _kunerlost = NO;
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            _kunerlost = YES;
            [_failAlert dismissWithClickedButtonIndex:0 animated:NO];
            if (self.navigationController.topViewController == self) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } 
    }
    
}

-(void)clickbtn:(UIButton *)sender{
    if (sender.tag==111) {
        confirms.userInteractionEnabled = NO;
        [self doFormat];
    }else if (sender.tag==222){
        [self.navigationController popViewControllerAnimated:YES];
    }

}
-(void)clickLeft:(UIButton *)leftBtn {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doFormat{
    // 酷壳是否在更新固件
    [Context shareInstance].isFirmwareUpdating = NO;
    
    // 暂停下载
    [[DownloadManager shareInstance] pauseAll];
    
    ViewController * vc = [self getHomeVC];
    [vc resetPlayingKeMusic];
    _test = [[YpcCustomProgress alloc] init];
    [_test startPainting:YES];
    [_test backZero];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    dispatch_async(_dispatchQueue, ^{
        
        ret = [[CustomFileManage instance] formatSystem];
        
        __weak FormatView *weakSelf = self;
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
            
//            [vc needVolume]; // 重新获取容量
            [FileSystem createDirIfNotExist];
            [vc resetPlayingKeMusic];
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
-(ViewController *)getHomeVC
{
    ViewController * vc;
    for (UIViewController *viewCtr in self.navigationController.viewControllers) {
        if ([viewCtr isKindOfClass:[ViewController class]]) {
            vc = (ViewController *)viewCtr;
            break;
        }
    }
    if (vc == nil) {
        vc = [[ViewController alloc]init];
    }
    return vc;
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
            [self performSelector:@selector(popback) withObject:nil afterDelay:1.1];
            
        }else{
            _failAlert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"formatfail",@"") message:NSLocalizedString(@"formatagainy",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"sure",@""), nil];
            _failAlert.tag=FORMATFAIL;
            _failAlert.delegate=self;
            [_failAlert show];
            
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == FORMATFAIL) {
        if (buttonIndex == 1) {
            [self doFormat];
        }
        else if (buttonIndex == 0){
            if (_stateCode == FormatStateCodeKeLocked) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

-(void)popback{
    
    confirms.userInteractionEnabled =YES;
    if (_stateCode == FormatStateCodeKeLocked) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
