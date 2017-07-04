//
//  SettingView.m
//  tjk
//
//  Created by huadao on 15/6/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "SettingView.h"
#import "MobClickUtils.h"
#import "CustomGesView.h"
#import "MusicTimerCell.h"
#import "CustomMusicPlayer.h"

@implementation SettingView

#pragma mark - Life Cycle

-(void)viewDidLoad{

    [super viewDidLoad];
    
    _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0  blue:239.0/255.0  alpha:1.0];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"setting", @"");
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
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                            _customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height+20,
                                                            SCREEN_WIDTH,
                                                            300*WINDOW_SCALE_SIX)];
    [self.view addSubview:view];
    
    NSArray *iconArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"icon_code.png" bundle:@"TAIG_LEFTVIEW.bundle"],[UIImage imageNamed:@"clock.png" bundle:@"TAIG_125.bundle"],[UIImage imageNamed:@"icon_kurong_setting.png" bundle:@"TAIG_LEFTVIEW.bundle"],@"",[UIImage imageNamed:@"icon_formatting.png" bundle:@"TAIG_LEFTVIEW.bundle"], nil];
    NSArray *titlearr = [NSArray arrayWithObjects:@"",NSLocalizedString(@"musictimerplay", @""),NSLocalizedString(@"kukesavingmodel", @""),NSLocalizedString(@"charge_model_msg_two", @""),NSLocalizedString(@"formatekuke", @""), nil];
    
    for (int i = 0; i<5; i++) {
        
        CGFloat lineX = (i ==1?52*WINDOW_SCALE_SIX : 0);
        
        UIView * lineview = [[UIView alloc]initWithFrame:CGRectMake(lineX, i*60*WINDOW_SCALE_SIX, SCREEN_WIDTH, 1.0*WINDOW_SCALE_SIX)];
        lineview.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:215.0/255.0 blue:217.0/255.0 alpha:1.0];
        if (i == 3) {
            UILabel *_contentLab = [[UILabel alloc]initWithFrame:CGRectMake(15,i*60*WINDOW_SCALE_SIX, view.frame.size.width-20, 60*WINDOW_SCALE_SIX)];
            _contentLab.textAlignment = NSTextAlignmentLeft;
            _contentLab.textColor = [UIColor colorWithRed:52/255.0 green:56/255.0 blue:67/255.0 alpha:1.0];
            _contentLab.numberOfLines = 0;
            _contentLab.font = [UIFont systemFontOfSize:10];
            _contentLab.text = [titlearr objectAtIndex:i];
            [view addSubview:_contentLab];
            [view addSubview:lineview];

            continue;
        }
        
        UIView *contanierView = [[UIView alloc] initWithFrame:CGRectMake(0, i*60*WINDOW_SCALE_SIX, view.frame.size.width,60*WINDOW_SCALE_SIX)];
        contanierView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(52*WINDOW_SCALE_SIX, 0, 250*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = [titlearr objectAtIndex:i];
        label.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
        if (i == 1) {
            NSDictionary *fontDic = @{NSFontAttributeName:label.font};
            CGFloat labWidth = [label.text boundingRectWithSize:label.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:fontDic context:nil].size.width;
            _musicClock = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x+labWidth+2, 0, 60*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
            _musicClock.textColor = [UIColor colorWithRed:255.0/255.0 green:73.0/255.0 blue:71.0/255.0 alpha:1.0];
            _musicClock.textAlignment = NSTextAlignmentCenter;
            _musicClock.font = [UIFont systemFontOfSize:19*WINDOW_SCALE_SIX];
            [contanierView addSubview:_musicClock];
        }
        UIImageView * numimage = [[UIImageView alloc]initWithFrame:CGRectMake(15*WINDOW_SCALE_SIX,19*WINDOW_SCALE_SIX, 22*WINDOW_SCALE_SIX, 22*WINDOW_SCALE_SIX)];
        numimage.image = [iconArr objectAtIndex:i];
        [contanierView addSubview:numimage];
        [contanierView addSubview:label];
        
        UISwitch *theswitch;
        if (i != 3&&i !=4) {
            theswitch = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70*WINDOW_SCALE_SIX, 15*WINDOW_SCALE_SIX, 50*WINDOW_SCALE_SIX, 30*WINDOW_SCALE_SIX)];
            theswitch.tag = i+1;
            [theswitch addTarget:self action:@selector(switchs:) forControlEvents:UIControlEventValueChanged];
            [contanierView addSubview:theswitch];
        }
        
        [view addSubview:contanierView];
        [view addSubview:lineview];
        if (i == 0) {
            lab1 = label;
            _switchs = theswitch;
        }else if (i == 1){
            _musicSwitch = theswitch;
            [_musicSwitch setOn:[Context shareInstance].musicClockState];
        }
        else if (i == 2){
            lab2 = label;
            _chargeSwitch = theswitch;
        }
        
        if (i == 4) {
            UIView * lineview = [[UIView alloc]initWithFrame:CGRectMake(lineX, 4*60*WINDOW_SCALE_SIX, SCREEN_WIDTH, 1.0*WINDOW_SCALE_SIX)];
            lineview.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:215.0/255.0 blue:217.0/255.0 alpha:1.0];
            [view addSubview:lineview];
            
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"list_icon_arrow" bundle:@"TAIG_FILE_LIST"]];
            arrow.frame = CGRectMake(SCREEN_WIDTH-28.0*WINDOW_SCALE_SIX, (60-13)*WINDOW_SCALE_SIX/2.0, 9.0*WINDOW_SCALE_SIX, 13.0*WINDOW_SCALE_SIX);
            [contanierView addSubview:arrow];
        }
    }
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [_chargeSwitch setOn:[[userdefault objectForKey:@"ChargeSwitch"] isEqualToString:@"on"]];
    
    UIButton * changeSafe = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-70*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
    [changeSafe addTarget:self action:@selector(changeSafe) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:changeSafe];
    
    UIButton *musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    musicBtn.frame = CGRectMake(0, 60*WINDOW_SCALE_SIX, SCREEN_WIDTH-70*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX);
    [musicBtn addTarget:self action:@selector(musicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:musicBtn];
    
    UIButton *keSettingBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 120*WINDOW_SCALE_SIX, SCREEN_WIDTH- 70*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX)];
    [keSettingBtn addTarget:self action:@selector(keSettingBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:keSettingBtn];
    
    UIButton * format = [[UIButton alloc]initWithFrame:CGRectMake(0, 240*WINDOW_SCALE_SIX, SCREEN_WIDTH, 60*WINDOW_SCALE_SIX)];
    [format addTarget:self action:@selector(formatkuker) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:format];
    
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _backView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.7];
    [self.view addSubview:_backView];
    
    _musicTimerTable = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 49*8*WINDOW_SCALE_SIX)];
    _musicTimerTable.delegate = self;
    _musicTimerTable.dataSource = self;
    [self.view addSubview:_musicTimerTable];
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 49.0*7.0*WINDOW_SCALE_SIX, SCREEN_WIDTH, 49*WINDOW_SCALE_SIX)];
    [cancelBtn setTitle:NSLocalizedString(@"sure", @"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(selectTime) forControlEvents:UIControlEventTouchUpInside];
    [_musicTimerTable addSubview:cancelBtn];
    _musicName = [[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"dontopen",@""),NSLocalizedString(@"playcurrentmusic",@""),[NSString stringWithFormat:@"10%@",NSLocalizedString(@"time_min", @"")],[NSString stringWithFormat:@"20%@",NSLocalizedString(@"time_min", @"")],[NSString stringWithFormat:@"30%@",NSLocalizedString(@"time_min", @"")],[NSString stringWithFormat:@"60%@",NSLocalizedString(@"time_min", @"")],[NSString stringWithFormat:@"90%@",NSLocalizedString(@"time_min", @"")], nil];
    
    if ([Context shareInstance].musicClockState&&[Context shareInstance].musicTime>0) {
         _musicClock.text = [NSString stringWithFormat:@"%d:00",[Context shareInstance].musicOriginTime/60];
    }else{
         _musicClock.text = @"";
    }
    
    // NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeToStopPlay:) name:TIME_TO_STOPPLAY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPlayUI) name:REFRESH_SETTING_MUSICTIMER object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self freshsafenumberstate];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

#pragma mark - NavBarDelegate

-(void)clickLeft:(UIButton *)leftBtn {
    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)clickRight:(UIButton *)leftBtn{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Utility

- (void)musicTimerInvalidate
{
    [[Context shareInstance].musicTimer invalidate];
    [Context shareInstance].musicTimer = nil;
}

#pragma mark -
-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
}

- (void)timeToStopPlay:(NSNotification *)notify
{
    [self stopPlayUI];
    [self stopPlayerPlay];
    [self musicTimerInvalidate];
}

- (void)refreshPlayUI
{
    _musicClock.text = @"";
    [_musicSwitch setOn:NO];
    
    [Context shareInstance]._musicIndex = 0;
    [Context shareInstance].musicClockState = NO;
    [_musicTimerTable reloadData];
    
    [self musicTimerInvalidate];
}

- (void)stopPlayUI
{
    _musicClock.text = @"";
    [_musicSwitch setOn:NO];
    
    [Context shareInstance]._musicIndex = 0;
    [Context shareInstance].musicClockState = NO;
    [Context shareInstance].stopPlayingAfterCurMusicPlay = NO;
    [_musicTimerTable reloadData];
}

- (void)stopPlayerPlay
{
    if ([CustomMusicPlayer shareCustomMusicPlayer].isPlaying) {
        [[CustomMusicPlayer shareCustomMusicPlayer] pause];
        NSLog(@"pause --------------");
    }
}

-(void)keSettingBtnPressed
{
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    if (self.chargeSwitch.isOn) {
        [FileSystem set_deviceModel:CHARGING_DEFAULT];
        [userdefault setObject:@"off" forKey:@"ChargeSwitch"];
        [self.chargeSwitch setOn:NO];
    }else{
        
        [FileSystem set_deviceModel:CHARGING_STORAGE_PREFERRED];
        [userdefault setObject:@"on" forKey:@"ChargeSwitch"];
        [self.chargeSwitch setOn:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_MODEL_NOTF object:nil];
}

-(void)changeSafe{
    if (!self.switchs.userInteractionEnabled) {
        return;
    }
    
    if (self.switchs.isOn) {
        PAPasscodeViewController * removePassWord = [[PAPasscodeViewController alloc]initForAction:PasscodeActionEnter whatview:@"closepassword" newPassWord:NO lastAnswer:nil];
        
        [self.navigationController pushViewController:removePassWord animated:YES];

    }else{
        PAPasscodeViewController * setPassWord = [[PAPasscodeViewController alloc]initForAction:PasscodeActionSet whatview:@"setpassword" newPassWord:NO lastAnswer:nil];
        
        [self.navigationController pushViewController:setPassWord animated:YES ];
    }

}

- (void)musicBtnClick:(id)sender
{
    [_musicSwitch setOn:!_musicSwitch.on];
    [self switchs:_musicSwitch];
}

-(void)switchs:(UISwitch *)sender{
    if (sender.tag == 1) {
        if (sender.isOn) {
            [MobClickUtils event:@"SETTING_PASSCODE" label:@"open"];
            PAPasscodeViewController * setPassWord = [[PAPasscodeViewController alloc]initForAction:PasscodeActionSet whatview:@"setpassword" newPassWord:NO lastAnswer:nil];
            
            [self.navigationController pushViewController:setPassWord animated:YES ];
        }else{
            [MobClickUtils event:@"SETTING_PASSCODE" label:@"close"];
            PAPasscodeViewController * removePassWord = [[PAPasscodeViewController alloc]initForAction:PasscodeActionEnter whatview:@"closepassword" newPassWord:NO lastAnswer:nil];
            [self.navigationController pushViewController:removePassWord animated:YES];
        }
    }
    else if (sender.tag == 2)
    {
        if (sender.isOn) {
            [_musicTimerTable reloadData];
            
            [UIView animateWithDuration:0.3 animations:^{
                _musicTimerTable.frame = CGRectMake(0,
                                                      SCREEN_HEIGHT-49.0*8.0*WINDOW_SCALE_SIX,
                                                      SCREEN_WIDTH,
                                                      49.0*8.0*WINDOW_SCALE_SIX);
                _backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            }];
        }
        else
        {
            [self stopPlayUI];
            [self musicTimerInvalidate];
        }
    }else if (sender.tag == 3){
        
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        if (self.chargeSwitch.isOn) {
            [FileSystem set_deviceModel:CHARGING_STORAGE_PREFERRED];
            [userdefault setObject:@"on" forKey:@"ChargeSwitch"];
            [self.chargeSwitch setOn:YES];
        }else{
            [FileSystem set_deviceModel:CHARGING_DEFAULT];
            [userdefault setObject:@"off" forKey:@"ChargeSwitch"];
            [self.chargeSwitch setOn:NO];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_MODEL_NOTF object:nil];
    }
}

-(void)formatkuker{
    FormatView * format = [[FormatView alloc]init];
    [self.navigationController pushViewController:format animated:YES];
}

- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
}

-(void)endControlDelay{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(void)freshsafenumberstate{
    
    _switchs.userInteractionEnabled = NO;
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [LogUtils writeLog:@"FileSystem checkBindPhone"];
        BOOL ison = [FileSystem checkBindPhone];
        NSString *str = ison?NSLocalizedString(@"closesecret", @""):NSLocalizedString(@"opensecret", @"");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _switchs.userInteractionEnabled = YES;
            [self.switchs setOn:ison];
            lab1.text = str;
        });
    });
}

- (void)selectTime{
    [UIView animateWithDuration:0.3 animations:^{
        _musicTimerTable.frame = CGRectMake(0,
                                              SCREEN_HEIGHT,
                                              SCREEN_WIDTH,
                                              320.0*WINDOW_SCALE_SIX);
        _backView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    
    int  time = 0;
    BOOL onlyPlayCurMusic = NO;
    
    switch ([Context shareInstance]._musicIndex) {
        case 0:
            time = 0;
            break;
        case 1:
            onlyPlayCurMusic = YES;
            break;
        case 2:
            time = 10*60;
            break;
        case 3:
            time = 20*60;
            break;
        case 4:
            time = 30*60;
            break;
        case 5:
            time = 60*60;
            break;
        case 6:
            time = 90*60;
            break;
            
        default:
            break;
    }
    
    [Context shareInstance].stopPlayingAfterCurMusicPlay = onlyPlayCurMusic;
    
    //
    NSString *timeStr = @"";
    if (time>0) {
        [Context shareInstance].musicClockState = YES;
        timeStr = [NSString stringWithFormat:@"%d:00",time/60];
    }else{
        [Context shareInstance].musicClockState = NO;
    }
    
    if (onlyPlayCurMusic) {
        if ([CustomMusicPlayer shareCustomMusicPlayer].isPlaying) {
            [Context shareInstance].musicClockState = YES;
        }
        else
        {
            [Context shareInstance]._musicIndex = 0;
            [Context shareInstance].musicClockState = NO;
            [Context shareInstance].stopPlayingAfterCurMusicPlay = NO;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"noplayingmusic", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    // UI
    _musicClock.text = timeStr;
    [_musicSwitch setOn:[Context shareInstance].musicClockState];
    
    // 开启或关闭定时器
    [self setMusicCloseTime:time];
}

- (void)setMusicCloseTime:(int)time{
    
    [Context shareInstance].musicTime = time;
    [Context shareInstance].musicOriginTime = time;
    
    if (time > 0) {
        if (![Context shareInstance].musicTimer) {
            [Context shareInstance].musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerGo) userInfo:nil repeats:YES];
        }
    }
    else
    {
        [self musicTimerInvalidate];
    }
}

- (void)timerGo{
    
    [Context shareInstance].musicTime--;
    
    if ([Context shareInstance].musicTime == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TIME_TO_STOPPLAY object:nil];
    }
    
    NSLog(@"timerGo: %d",[Context shareInstance].musicTime);
}

# pragma mark - tableview
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49.0*WINDOW_SCALE_SIX;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _musicName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * identify = @"Mcell";
    MusicTimerCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[MusicTimerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.label.text = [_musicName objectAtIndex:indexPath.row];
    }
    if (![Context shareInstance]._musicIndex) {
        [Context shareInstance]._musicIndex = 0;
    }
    if (indexPath.row == [Context shareInstance]._musicIndex) {
        [cell selectCell:YES];
    }else{
        [cell selectCell:NO];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    [Context shareInstance]._musicIndex = indexPath.row;
    [_musicTimerTable reloadData];
}


@end
