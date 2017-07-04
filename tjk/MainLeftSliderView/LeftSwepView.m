//
//  LeftSwepView.m
//  RoundTest
//
//  Created by huadao on 15-3-25.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import "LeftSwepView.h"
#include <sys/utsname.h>
#import "Context.h"

#define CELL_LINE_TAG 111
#define GUJIAN 123
#define PHONEINFORMANTION @"phoneinformantion"
#define TAKE_TELE 4454

@interface LeftSwepView (){
    BOOL _infoClickEnable; // 是否可点击
}
@property(nonatomic ,retain) NSMutableArray* topViews;
@end

@implementation LeftSwepView

-(id)initWithFrame:(CGRect)frame{
    
    self=[super initWithFrame:frame];
    if (self) {
        // Initilization
        _deviceon=NO;
        _infoClickEnable = YES;
        
        [self resetDataSource];
        
        // UI
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        view1=[[UIView alloc]init];
        view1.backgroundColor=[UIColor colorWithRed:40.0/255.0 green:42.0/255.0 blue:52.0/255.0 alpha:1.0];
        
        [self addSubview:view1];
        
        imagev1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iphone5.png" bundle:@"TAIG_LEFTVIEW.bundle"]];
        
        [view1 addSubview:imagev1];
        view1Btn = [[UIButton alloc]init];
        [view1Btn addTarget:self action:@selector(view1BtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        _iphoneType=[[UILabel alloc]init];
        _iphoneType.textColor=[UIColor whiteColor];
        _iphoneType.textAlignment=NSTextAlignmentLeft;
        _iphoneType.font=[UIFont systemFontOfSize:17.0*WINDOW_SCALE_SIX];
        _iphoneType.text=[self getDeviceModel];
        [Context shareInstance].phoneType = _iphoneType.text;
        
        _whoseIphone=[[UILabel alloc]init];
        _whoseIphone.textColor=[UIColor whiteColor];
        _whoseIphone.textAlignment=NSTextAlignmentLeft;
        _whoseIphone.font=[UIFont systemFontOfSize:13.0*WINDOW_SCALE_SIX];
        _whoseIphone.text=[NSString stringWithFormat:@"%@",[UIDevice currentDevice].name];
        [Context shareInstance].phoneName = _whoseIphone.text;
        
        UIImageView * iamgeArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-40, 130*WINDOW_SCALE_SIX/2.0, 30, 30)];
        iamgeArrow.image = [UIImage imageNamed:@"arrow" bundle:@"TAIG_125"];
        [view1 addSubview:iamgeArrow];
        
        _version=[[UILabel alloc]init];
        _version.textColor=[UIColor whiteColor];
        _version.textAlignment=NSTextAlignmentLeft;
        _version.font=[UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
        _version.text=[[NSString stringWithFormat:NSLocalizedString(@"phversion",@"")]stringByAppendingString:[NSString stringWithFormat:@": %@",[UIDevice currentDevice].systemVersion]];
        [Context shareInstance].phoneVersion =  _version.text;
        
        _tableview=[[UITableView alloc]init];
        _tableview.delegate=self;
        _tableview.dataSource=self;
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        line1=[[UIView alloc]init];
        line1.backgroundColor=[UIColor colorWithRed:30.0/255.0 green:32.0/255.0 blue:38.0/255.0 alpha:1.0];
        
        [view1 addSubview:_iphoneType];
        [view1 addSubview:_whoseIphone];
        [view1 addSubview:_version];
        [view1 addSubview:line1];
        [view1 addSubview:view1Btn];
        [self addSubview:_phonePower];
        [self addSubview:_phoneCapacity];
        [self addSubview:_tableview];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissalert) name:@"dismissalert" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateversion:) name:@"updateversion" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(findNewVersion:) name:FINDVERSION object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateResult:) name:DOWNLOAD_SELF object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failedChecked:) name:@"set_checkUpdate_error" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkversion) name:@"checkversion" object:nil];
    }
    return self;
}

-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            _deviceon=YES;
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            _deviceon=NO;
        }
        
        [self resetDataSource];
        [self reloadTable];
    }
}

- (void)reloadTable{
    [_tableview reloadData];
}

#pragma mark - Utility

- (void)resetDataSource
{ // 外语（隐藏客服和专题）
    if ([FileSystem isConnectedKE]) { // 已激活
        if (_deviceon) {// 链接壳
            if ([FileSystem isChinaLan]) { // 中文
                _curTitleAry = [NSArray arrayWithObjects:NSLocalizedString(@"about", @""),
                                NSLocalizedString(@"topicTitle",@""),
                                NSLocalizedString(@"setting",@""),
                                NSLocalizedString(@"feedback", @""),
                                NSLocalizedString(@"kehuphone",@""),
                                nil];
                _currImgNameAry = @[@"imark",@"topicmark",@"setmark",@"feedbackmark",@"telmark"];
            }
            else
            { // 外语
                _curTitleAry = [NSArray arrayWithObjects:NSLocalizedString(@"about", @""),
                                NSLocalizedString(@"setting",@""),
                                NSLocalizedString(@"feedback", @""),
                                nil];
                _currImgNameAry = @[@"imark",@"setmark",@"feedbackmark"];
            }
        }
        else
        { // 未接壳（激活）
            if ([FileSystem isChinaLan]) { // 中文
                _curTitleAry = [NSArray arrayWithObjects:NSLocalizedString(@"about", @""),
                                NSLocalizedString(@"topicTitle",@""),
                                NSLocalizedString(@"feedback", @""),
                                NSLocalizedString(@"kehuphone",@""),
                                nil];
                _currImgNameAry = @[@"imark",@"topicmark",@"feedbackmark",@"telmark"];
            }
            else
            { // 外语
                _curTitleAry = [NSArray arrayWithObjects:NSLocalizedString(@"about", @""),
                                NSLocalizedString(@"feedback", @""),
                                nil];
                _currImgNameAry = @[@"imark",@"feedbackmark"];
            }
        }
    }
    else
    { // 未激活
        _curTitleAry = [NSArray arrayWithObjects:NSLocalizedString(@"about", @""),
         NSLocalizedString(@"feedback",@""),
         nil];
        _currImgNameAry = @[@"imark",@"feedbackmark"];
    }
}

#pragma mark -

-(void)updateversion:(NSNotification *)noti{
    
    Version=noti.object;
    //    update=NO;
}

-(void)layoutSubviews{
    
    view1.frame=CGRectMake(0,
                           0,
                           SCREEN_WIDTH-132.0*WINDOW_SCALE_SIX/2.0,
                           63+325*WINDOW_SCALE_SIX-170*3*WINDOW_SCALE_SIX/2.0);
    view1Btn.frame = view1.frame;
    line1.frame=CGRectMake(0,
                           62+325*WINDOW_SCALE_SIX-170*3*WINDOW_SCALE_SIX/2.0,
                           SCREEN_WIDTH-132.0*WINDOW_SCALE_SIX/2.0,
                           1.0);
    
    imagev1.frame=CGRectMake(60.0*WINDOW_SCALE_SIX/2.0,
                             ((244.0-100)/2.0+40)*WINDOW_SCALE_SIX/2.0,
                             50.0*WINDOW_SCALE_SIX/2.0,
                             100.0*WINDOW_SCALE_SIX/2.0);
    
    _iphoneType.frame=CGRectMake(150.0*WINDOW_SCALE_SIX/2.0,
                                 100.0*WINDOW_SCALE_SIX/2.0,
                                 350.0*WINDOW_SCALE_SIX/2.0,
                                 32.0*WINDOW_SCALE_SIX/2.0);
    _whoseIphone.frame=CGRectMake(150*WINDOW_SCALE_SIX/2.0,
                                  (90.0+32.0+25.0)*WINDOW_SCALE_SIX/2.0,
                                  280.0*WINDOW_SCALE_SIX/2.0,
                                  32.0*WINDOW_SCALE_SIX/2.0);
    _version.frame=CGRectMake(150.0*WINDOW_SCALE_SIX/2.0,
                              (90.0+32.0*2.0+35.0)*WINDOW_SCALE_SIX/2.0,
                              350.0*WINDOW_SCALE_SIX/2.0,
                              32.0*WINDOW_SCALE_SIX/2.0);
    _tableview.frame=CGRectMake(0,
                                view1.frame.origin.y +view1.frame.size.height,
                                SCREEN_WIDTH-80.0,
                                170.0*5*WINDOW_SCALE_SIX);
    
    [_tableview reloadData];
}

- (void)view1BtnClick{
    
    if (_infoClickEnable && [self.menuDelegate respondsToSelector:@selector(leftMenuSelectedAt:)]) {
        
        _infoClickEnable = NO;
        [self performSelector:@selector(view1BtnClickEnable) withObject:nil afterDelay:0.5];
        
        [self.menuDelegate leftMenuSelectedAt:PHONEINFORMANTION];
    }
}

- (void)view1BtnClickEnable
{
    _infoClickEnable = YES;
}

-(NSString *)getDeviceModel{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * version;
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]){
        iphone=2; version= @"iPhone 2G";}
    if ([platform isEqualToString:@"iPhone1,2"]){
        iphone=3;version= @"iPhone 3G";}
    if ([platform isEqualToString:@"iPhone2,1"]){
        iphone=3; version= @"iPhone 3GS";}
    if ([platform isEqualToString:@"iPhone3,1"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone3,2"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone3,3"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone4,1"]){
        iphone=4; version= @"iPhone 4S";}
    if ([platform isEqualToString:@"iPhone5,1"]){
        iphone=5; version= @"iPhone 5";}
    if ([platform isEqualToString:@"iPhone5,2"]){
        iphone=5; version= @"iPhone 5";}
    if ([platform isEqualToString:@"iPhone5,3"]){
        iphone=5; version= @"iPhone 5c";}
    if ([platform isEqualToString:@"iPhone5,4"]){
        iphone=5; version= @"iPhone 5c";}
    if ([platform isEqualToString:@"iPhone6,1"]){
        iphone=5; version= @"iPhone 5s";}
    if ([platform isEqualToString:@"iPhone6,2"]){
        iphone=5; version= @"iPhone 5s";}
    if ([platform isEqualToString:@"iPhone7,1"]){
        iphone=6; version= @"iPhone 6 Plus";}
    if ([platform isEqualToString:@"iPhone7,2"]){
        iphone=6; version= @"iPhone 6";}
    if ([platform isEqualToString:@"iPhone8,1"]){
        iphone=7; version= @"iPhone 6s";}
    if ([platform isEqualToString:@"iPhone8,2"]){
        iphone=7; version= @"iPhone 6s plus";}
    return version;
    
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _curTitleAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 120.0/1334.0*[UIScreen mainScreen].bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identify=@"cell";
    LeftCell * cell=[tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell==nil) {
        cell=[[LeftCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    UIView * line = [cell viewWithTag:CELL_LINE_TAG];
    [line removeFromSuperview];
    
    [cell setcellName:_curTitleAry[indexPath.row]];
    cell.image.image = [UIImage imageNamed:_currImgNameAry[indexPath.row] bundle:@"TAIG_125"];
    
    if (indexPath.row==_curTitleAry.count-1) {
        UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 120.0*WINDOW_SCALE_SIX/2.0 - 1, SCREEN_WIDTH-80.0, 1/2.0)];
        line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        line.tag =CELL_LINE_TAG;
        [cell addSubview:line];
        
    }
    else{
        UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 120.0*WINDOW_SCALE_SIX/2.0 - 1, SCREEN_WIDTH-80.0, 1/2.0)];
        line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        line.tag = CELL_LINE_TAG;
        [cell addSubview:line];
    }
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.menuDelegate respondsToSelector:@selector(leftMenuSelectedAt:)]) {
        
        if (!_canselect) {
            _canselect = YES;
            if ([_curTitleAry[indexPath.row] isEqualToString:NSLocalizedString(@"kehuphone",@"")]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"takekefuphone",@"") message:@"400-655-8683" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
                alert.tag = TAKE_TELE;
                [alert show];
               
            }else{
                [self.menuDelegate leftMenuSelectedAt:_curTitleAry[indexPath.row]];
            }
            [self performSelector:@selector(canselect) withObject:nil afterDelay:0.3];
        }
    }
}

-(void)canselect{
    
    _canselect = NO;
    
}
-(void)checkversion
{
    _activityView = [CustomActivityView defaultCheckActivityView];
    if (show) {
        [_activityView show];
    }
    
    
    [[AppUpdateUtils instance]checkUpdate:Version Url:@"版本更新"];
    
}
-(void)findNewVersion:(NSNotification *)notif
{
    BOOL flag = [notif.object boolValue];
    if(flag)
    {
        NSString *updateVerson = [notif.userInfo objectForKey:APP_VERSION];
        NSString *updateInfoArr = [notif.userInfo objectForKey:APP_INFO];
        NSString * download=[notif.userInfo objectForKey:APP_UPDATE_PLIST];
        NSString * MD5=[notif.userInfo objectForKey:BIN_MD5];
        if (MD5) {
            UIAlertView * alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"updatetips", @"") message:NSLocalizedString(@"updatetipscontent", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
            alert.tag =GUJIAN;
            [alert show];
            
        }else{
            
            SetUpdateAlertView *alertView = [[SetUpdateAlertView alloc]
                                             initWithUpdateMessage:updateInfoArr downloadplist:download version:updateVerson isApp:YES];
            alertView.delegate = self;
            //菊花消失
            if (show) {
                [_activityView dismissWithCompletion:^(BOOL finished) {
                    if (finished)
                        [alertView show];
                } ];
            }else{
                [alertView show];
            }
        }
    }
    else
    {
        if (show) {
            SetUpdateAlertView *alertView = [[SetUpdateAlertView alloc]
                                             initWithUpdateMessage:nil downloadplist:nil version:nil isApp:NO];
            alertView.delegate = self;
            
            
            //菊花消失
            [_activityView dismissWithCompletion:^(BOOL finished) {
                if (finished)
                    [alertView show];
            } ];
            
        }else{
            //无更新不弹框
            [_activityView dismiss];
        }
    }
    
    
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
-(void)updateResult:(NSNotification *)notif{
    
    BOOL flag = [notif.object boolValue];
    NSString *updateResultStr = NSLocalizedString(@"updatefail",@"");
    
    if(flag)
        updateResultStr = NSLocalizedString(@"update_success",@"") ;
    
    [_activityView dismissAterDelay:0.0 WithAnimationed:YES withComlent:^(BOOL flag)
     {
         if (flag)
         {
             
         }
         
     }];
}
- (void)setUpdateAlertView:(SetUpdateAlertView *)alertView clickedAtIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
        {
//            HardwareInfoBean * bean=[FileSystem get_info];
//            NSString * localDeviceVersion = [NSString stringWithFormat:@"%u.%u.%u",bean.INFO_VERSION_MA,bean.INFO_VERSION_MI,bean.INFO_VERSION_IN];
//            NSString *serverDeviceVersion =@"2.1.0";
//            if (localDeviceVersion && serverDeviceVersion) {
//                
//                if (strcmp((char *)[localDeviceVersion UTF8String], (char *)[serverDeviceVersion UTF8String]) < 0) {
//                    
//                    
//                    UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"更新提示" message:@"固件需要更新，过程中酷壳会断开连接，稍等片刻后酷壳会自动重新连接。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    alert.delegate=self;
//                    [alert show];
//                    
//                    
//                }else{
//                    
//                }
//                
//            }
  
        }
            break;
        case 2:
        {
            _activityView = [CustomActivityView defaultActivityViewWith:NSLocalizedString(@"updating",@"")];
            [_activityView show];
            [[AppUpdateUtils instance] updateVersion];
        }
            break;
            
        default:
            break;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == GUJIAN) {
        if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTERPW_FOR_UPDATE object:nil];
        }
        else
        {
            [[AppUpdateUtils instance]updateVersion];
        }
    }else if (alertView.tag == TAKE_TELE){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4006558683"]];
        }
    }
}


-(void)dismissalert{
    
    [_activityView dismiss];
}
- (void)failedChecked:(NSNotification *)notif
{
    NSDictionary *notiDict = notif.object ;
    
    [_activityView dismissWithCompletion:^(BOOL finished) {
        if(finished)
        {
            if ([[notiDict objectForKey:@"flag"] isEqualToString:@"info"])
            {
                SetUpdateAlertView *alertView = [[SetUpdateAlertView alloc]
                                                 initWithUpdateErrorMessage:[notiDict objectForKey:@"tips"]];
                [alertView show];
            }else if ([[notiDict objectForKey:@"flag"] isEqualToString:@"download"])
            {
                
            }
        }
        else
        {
            
        }
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
