//
//  AboutKuke.m
//  tjk
//
//  Created by huadao on 15/4/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "AboutKuke.h"
#import "CustomNavigationBar.h"
#import "PrivateViewController.h"
#import "LogUtils.h"
#import "KukeCell.h"
#import "WXApi.h"
#import "ShareToHelper.h"
#import "SpecialTopicViewController.h"
#define WEF 1121
#define WEC 1122
@interface AboutKuke ()

@end

@interface AboutKuke ()<NavBarDelegate>{
    CustomNavigationBar *_customNavigationBar;
}

@end
@implementation AboutKuke

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceOn = NO;
     _infoAry = [[NSArray alloc]init];
    if ([FileSystem checkInit]) {
        _deviceOn = YES;
        _infoAry = [self getInfoDelay];
    }
   
    _linkNameAry = [NSMutableArray arrayWithObjects:
                    NSLocalizedString(@"gujianv", @""),
                    NSLocalizedString(@"snl", @""),
                    NSLocalizedString(@"privatel", @""),
                    NSLocalizedString(@"kukeofficemall",@""),
                    NSLocalizedString(@"sendkuketofd",@""),nil];
    _unLinkNameAry = [NSMutableArray arrayWithObjects:
                      NSLocalizedString(@"privatel", @""),
                      NSLocalizedString(@"kukeofficemall",@""),
                      NSLocalizedString(@"sendkuketofd",@""), nil];
    _unActivityNameAry = [NSMutableArray arrayWithObjects:
                          NSLocalizedString(@"privatel", @""), nil];
    _currentNameAry = [NSMutableArray arrayWithCapacity:0];
    // 后期更改
    if (![FileSystem isChinaLan]) {
        // 移除隐私声明
        [_linkNameAry removeObjectAtIndex:2];
        [_unLinkNameAry removeObjectAtIndex:0];
        [_unActivityNameAry removeObjectAtIndex:0];
    }
    //
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0  blue:242.0/255.0  alpha:1.0];
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
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    [self.view addSubview:_customNavigationBar];
    
    _iconimage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"about-icon" bundle:@"TAIG_MainImg"]];
    [self.view addSubview:_iconimage];
    
    _myKukeLabel = [[UILabel alloc] init];
    _myKukeLabel.text = NSLocalizedString(@"copymaintitle", @"");
    _myKukeLabel.textColor = [UIColor colorWithRed:72.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1.0];
    _myKukeLabel.font = [UIFont systemFontOfSize:19.0*WINDOW_SCALE_SIX];
    _myKukeLabel.textAlignment = NSTextAlignmentCenter;
    _myKukeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_myKukeLabel];
    
    _version = [[UILabel alloc]init];
    _version.textColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0];
    _version.font = [UIFont systemFontOfSize:12.0*WINDOW_SCALE_SIX];
    _version.textAlignment = NSTextAlignmentCenter;
    
    _version.text = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];

    [self.view addSubview:_version];
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    _cooperate = [[UILabel alloc]init];
    _cooperate.textAlignment = NSTextAlignmentCenter;
    _cooperate.font = [UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
    _cooperate.textColor = [UIColor blackColor];
    _cooperate.text = [NSString stringWithFormat:@"%@：kuner-kf@kuner.com.cn ",NSLocalizedString(@"cooperate",@"")];
    [self.view addSubview:_cooperate];
    
    _bottom1 = [[UILabel alloc]init];
    _bottom1.textColor = [UIColor colorWithRed:190.0/255.0 green:191.0/255.0 blue:195.0/255.0 alpha:1.0];
    _bottom1.textAlignment = NSTextAlignmentCenter;
    _bottom1.font =[UIFont systemFontOfSize:10.0*WINDOW_SCALE_SIX];
    _bottom1.text =@"Copyright @2012 Beijing Kuner Technology Co.Ltd.";
    [self.view addSubview:_bottom1];
    
    _bottom2 = [[UILabel alloc]init];
    _bottom2.textColor = [UIColor colorWithRed:190.0/255.0 green:191.0/255.0 blue:195.0/255.0 alpha:1.0];
    _bottom2.textAlignment = NSTextAlignmentCenter;
    _bottom2.font =[UIFont systemFontOfSize:10.0*WINDOW_SCALE_SIX];
    _bottom2.text =@"All Right Reserved";
    [self.view addSubview:_bottom2];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
    //分享弹框
    
    _weChatCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _weChatCancelBtn.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.7];
    [_weChatCancelBtn addTarget:self action:@selector(cancalClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_weChatCancelBtn];
    
    _weChatView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-315*WINDOW_SCALE_SIX)/2.0, (SCREEN_HEIGHT-420*WINDOW_SCALE_SIX)/2.0, 315*WINDOW_SCALE_SIX, 420*WINDOW_SCALE_SIX)];
    _weChatView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [_weChatCancelBtn addSubview:_weChatView];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 315*WINDOW_SCALE_SIX, 50*WINDOW_SCALE_SIX)];
    title.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    title.font = [UIFont systemFontOfSize:18.0*WINDOW_SCALE_SIX];
    title.text = NSLocalizedString(@"sendkuketofd",@"");
    title.textAlignment = NSTextAlignmentCenter;
    [_weChatView addSubview:title];
    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake((315-250)*WINDOW_SCALE_SIX/2.0,
                                                                       title.frame.size.height+title.frame.origin.y+18.0*WINDOW_SCALE_SIX,
                                                                       250*WINDOW_SCALE_SIX,
                                                                       250*WINDOW_SCALE_SIX)];
    image.image = [UIImage imageNamed:@"shareimage" bundle:@"TAIG_125"];
    [_weChatView addSubview:image];
    
    NSArray *nameArray = [NSArray arrayWithObjects:NSLocalizedString(@"wxfriend", @""),NSLocalizedString(@"wxcircle", @""), nil];
    NSArray *iconArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"list_shareto_wxfriend.png" bundle:@"TAIG_FILE_LIST.bundle"],[UIImage imageNamed:@"list_shareto_wxcircle.png" bundle:@"TAIG_FILE_LIST.bundle"], nil];
    UIImageView * imagewxfriend = [[UIImageView alloc]initWithFrame:CGRectMake(67*WINDOW_SCALE_SIX,image.frame.size.height+image.frame.origin.y+18.0*WINDOW_SCALE_SIX , 60*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
    imagewxfriend.image = iconArr[0];
    [_weChatView addSubview:imagewxfriend];
    
    UIImageView * imagewxcycle = [[UIImageView alloc]initWithFrame:CGRectMake(imagewxfriend.frame.size.width+imagewxfriend.frame.origin.x+61.0*WINDOW_SCALE_SIX,imagewxfriend.frame.origin.y , 60*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
    imagewxcycle.image = iconArr[1];
    [_weChatView addSubview:imagewxcycle];
    
    UIButton * wxfriendBtn = [[UIButton alloc]initWithFrame:imagewxfriend.frame];
    [wxfriendBtn addTarget:self action:@selector(shareToWeiXin:) forControlEvents:UIControlEventTouchUpInside];
    wxfriendBtn.tag = WEF;
    [_weChatView addSubview:wxfriendBtn];
    
    CGFloat width = 60*WINDOW_SCALE_SIX*2;
    CGFloat oriX  = wxfriendBtn.frame.origin.x-30*WINDOW_SCALE_SIX;
    UILabel * labwf = [[UILabel alloc]initWithFrame:CGRectMake(oriX,
                                                               wxfriendBtn.frame.size.height+wxfriendBtn.frame.origin.y,
                                                               width,
                                                               20*WINDOW_SCALE_SIX)];
    labwf.text = nameArray[0];
    labwf.font = [UIFont systemFontOfSize:11.0*WINDOW_SCALE_SIX];
    labwf.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    labwf.textAlignment = NSTextAlignmentCenter;
    [_weChatView addSubview:labwf];
    
    UIButton * wxcycleBtn = [[UIButton alloc]initWithFrame:imagewxcycle.frame];
    [wxcycleBtn addTarget:self action:@selector(shareToWeiXin:) forControlEvents:UIControlEventTouchUpInside];
    wxcycleBtn.tag = WEC;
    [_weChatView addSubview:wxcycleBtn];
    UILabel * labwc = [[UILabel alloc]initWithFrame:CGRectMake(wxcycleBtn.frame.origin.x,
                                                               wxcycleBtn.frame.size.height+wxcycleBtn.frame.origin.y,
                                                               60*WINDOW_SCALE_SIX,
                                                               20*WINDOW_SCALE_SIX)];
    labwc.text = nameArray[1];
    labwc.font = [UIFont systemFontOfSize:11.0*WINDOW_SCALE_SIX];
    labwc.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    labwc.textAlignment = NSTextAlignmentCenter;
    [_weChatView addSubview:labwc];
    _weChatCancelBtn.hidden = YES;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _iconimage.frame =CGRectMake((SCREEN_WIDTH-75.0*WINDOW_SCALE_SIX)/2.0,
                                 64.0+24.0,
                                 75.0*WINDOW_SCALE_SIX,
                                 75.0*WINDOW_SCALE_SIX);
    _myKukeLabel.frame = CGRectMake(0,
                                    _iconimage.frame.origin.y+_iconimage.frame.size.height+8.0*WINDOW_SCALE_SIX,
                                    self.view.frame.size.width,
                                    20.0*WINDOW_SCALE_SIX);
    
    _version.frame = CGRectMake((self.view.frame.size.width-100.0*WINDOW_SCALE_SIX)/2.0,
                                _myKukeLabel.frame.origin.y+_myKukeLabel.frame.size.height+8.0,
                                100.0*WINDOW_SCALE_SIX,
                                20.0*WINDOW_SCALE_SIX);
    
    _cooperate.frame = CGRectMake((self.view.frame.size.width-280.0*WINDOW_SCALE_SIX)/2.0, self.view.frame.size.height-170.0*WINDOW_SCALE_SIX/2.0, 280*WINDOW_SCALE_SIX, 20.0*WINDOW_SCALE_SIX);
    
    _bottom1.frame =CGRectMake((self.view.frame.size.width-280.0*WINDOW_SCALE_SIX)/2.0, self.view.frame.size.height-100.0*WINDOW_SCALE_SIX/2.0, 280.0*WINDOW_SCALE_SIX, 20.0*WINDOW_SCALE_SIX);
    
    _bottom2.frame = CGRectMake((self.view.frame.size.width-200.0*WINDOW_SCALE_SIX)/2.0, self.view.frame.size.height-60.0*WINDOW_SCALE_SIX/2.0, 200.0*WINDOW_SCALE_SIX, 20.0*WINDOW_SCALE_SIX);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NavBarDelegate

-(void)clickLeft:(UIButton *)leftBtn {
    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)clickRight:(UIButton *)leftBtn{
    
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([FileSystem isConnectedKE]) {
        if (_deviceOn) {
            NSInteger rowCount = _linkNameAry.count;
            _tableView.frame = CGRectMake(0,
                                          _version.frame.origin.y+_version.frame.size.height+34,
                                          SCREEN_WIDTH,
                                          48.0*rowCount*WINDOW_SCALE_SIX);

            return rowCount;
        }else{
            NSInteger rowCount = _unLinkNameAry.count;
            _tableView.frame = CGRectMake(0,
                                          _version.frame.origin.y+_version.frame.size.height+34,
                                          SCREEN_WIDTH,
                                          48.0*rowCount*WINDOW_SCALE_SIX);
            return rowCount;
        }
    }
    
    NSInteger rowCount = _unActivityNameAry.count;
    _tableView.frame = CGRectMake(0,
                                  _version.frame.origin.y+_version.frame.size.height+34,
                                  SCREEN_WIDTH,
                                  48.0*rowCount*WINDOW_SCALE_SIX);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIden = @"aboutCellIdentifier";
    KukeCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[KukeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([FileSystem isConnectedKE]) {
        if (_deviceOn) {
            _currentNameAry = _linkNameAry;
        }else{
            _currentNameAry = _unLinkNameAry;
        }
    }else{
        _currentNameAry = _unActivityNameAry;
    }
    
    BOOL      longer = NO;
    NSString *name   = _currentNameAry[indexPath.row];
    if ([name isEqualToString:NSLocalizedString(@"kukeofficemall", @"")] || [name isEqualToString:NSLocalizedString(@"sendkuketofd", @"")]) {
        longer = YES;
    }
    
    [cell setCellName:_currentNameAry[indexPath.row] longer:longer];
    if ([_currentNameAry[indexPath.row] isEqualToString:NSLocalizedString(@"gujianv", @"")]) {
        if (_infoAry.count>0) {
            cell.aboutRight.text = _infoAry[0];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if ([_currentNameAry[indexPath.row]isEqualToString:NSLocalizedString(@"snl", @"")]){
        if (_infoAry.count>1) {
            cell.aboutRight.text = _infoAry[1];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48*WINDOW_SCALE_SIX;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([_currentNameAry[indexPath.row]  isEqualToString:NSLocalizedString(@"privatel", @"")]) {
        [self gotoPrivateUI];
    }else if ([_currentNameAry[indexPath.row] isEqualToString:NSLocalizedString(@"kukeofficemall",@"")]){
        SpecialTopicViewController *spvc = [[SpecialTopicViewController alloc]init];
        spvc.barTitle = NSLocalizedString(@"kukeofficemall",@"");
        spvc.urlStr = KUKE_OFFICIAL_MALL_URL;
        spvc.backDelegate = self;
        [self.navigationController pushViewController:spvc animated:YES];
    }else if ([_currentNameAry[indexPath.row] isEqualToString:NSLocalizedString(@"sendkuketofd",@"")]){
        [self shareToChat];
    }
}

#pragma mark - NSNotification Mehtods

-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            [self clickLeft:nil];
            if (_infoAry.count<2) {
                [self getInfoDelay];
            }
            _deviceOn = YES;
            [_tableView reloadData];
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            [self clickLeft:nil];
            _deviceOn = NO;
            [_tableView reloadData];
        }
    }
    
}

#pragma mark - Utility

-(NSArray*)getInfoDelay{
    NSString* version = nil;
    NSString* SN = nil;
    version = [FileSystem getVersion];
    SN = [FileSystem getSN];
    if (!SN) {
        HardwareInfoBean * bean = [FileSystem get_info];
        version = [NSString stringWithFormat:@"%d.%d.%d",bean.INFO_VERSION_MA,bean.INFO_VERSION_MI,bean.INFO_VERSION_IN];
        SN = bean.INFO_SN;
    }
    NSArray * array = [NSArray arrayWithObjects:version,SN, nil];
    return array;
}

- (void)shareToChat{
    [UIView animateWithDuration:0.5 animations:^{
        _weChatCancelBtn.hidden = NO;
    }];
}

- (void)cancalClick{
    [UIView animateWithDuration:0.3 animations:^{
        _weChatCancelBtn.hidden = YES;
    }];
}

- (void)shareToWeiXin:(UIButton*)sender{
    
    if (sender.tag == WEF) {
        [ShareToHelper sendImageContentWith:[UIImage imageNamed:@"shareimage" bundle:@"TAIG_125"] scene:WXSceneSession];
    }else if (sender.tag == WEC){
        [ShareToHelper sendImageContentWith:[UIImage imageNamed:@"shareimage" bundle:@"TAIG_125"] scene:WXSceneTimeline];
    }
}

-(void)gotoPrivateUI {
    PrivateViewController* aboutVC = [[PrivateViewController alloc] initWithNibName:@"PrivateViewController" bundle:nil];
    aboutVC.discType = DiscriptionTypePrivacyNote;
    [self.navigationController pushViewController:aboutVC animated:YES];
}

@end
