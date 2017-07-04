//
//  AboutViewController.m
//  tjk
//
//  Created by lengyue on 15/4/1.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "AboutViewController.h"
#import "CustomNavigationBar.h"

@interface AboutViewController ()<NavBarDelegate>{
    CustomNavigationBar          *_customNavigationBar;
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"about", @"");
    _customNavigationBar.rightBtn.hidden = YES;
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    [self.view addSubview:_customNavigationBar];
    self.icon.image = [UIImage imageNamed:@"main_about_icon" bundle:@"TAIG_MainImg"];
    self.versionStr.text = [NSString stringWithFormat:@"%@ : V %@", NSLocalizedString(@"appversion", @""),[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
    self.gjVersionStr.hidden = ![FileSystem checkInit];
    if ([FileSystem checkInit]) {
        HardwareInfoBean * bean=[FileSystem get_info];
        NSString * localDeviceVersion = [NSString stringWithFormat:@"%u.%u.%u",bean.INFO_VERSION_MA,bean.INFO_VERSION_MI,bean.INFO_VERSION_IN];
        self.gjVersionStr.text = [NSString stringWithFormat:@"%@ : V %@", NSLocalizedString(@"gujianversion", @""),localDeviceVersion];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
}

-(void)connectionNotification:(NSNotification*)noti {
    if([noti.object intValue] == CU_NOTIFY_DEVCON || [noti.object intValue] == CU_NOTIFY_DEVOFF){
        self.gjVersionStr.hidden = [noti.object intValue] == CU_NOTIFY_DEVOFF;
    }
}

-(void)clickLeft:(UIButton *)leftBtn {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)clickRight:(UIButton *)leftBtn{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
