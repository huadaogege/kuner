//
//  HomePageView.m
//  tjk
//
//  Created by Ching on 15-3-31.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "HomePageView.h"
#import "CustomProgressView.h"
#import "PowerBean.h"
#import "CustomNotificationView.h"
#import "MobClickUtils.h"
#import "MusicPlayerViewController.h"
#import "LogUtils.h"
#import "ViewController.h"
@interface HomePageView ()
@property (nonatomic, retain)NSMutableArray* titleArr;
@property (nonatomic, retain)NSMutableArray* disArr;
@property (nonatomic, retain)NSMutableArray* unitArr;
@property (nonatomic, weak) ViewController * rootViewController;
@end

@implementation HomePageView
{
    NSTimer* timer;
    NSTimer* _timer2;
    NSTimer* _checktimer;
    NSInteger _nowPlay;
    CustomNotificationView       *_loadingView;
    CustomNotificationView       *_tmploadingView;
    NSInteger   _nowTag;
    int   _lastSurplus;
    int     keNeed;
    float   _lastNeed;
    NSInteger   _lastStart;
    BOOL    _initPower;
    BOOL    _stop;
    BOOL    _first;
    BOOL    _isPower;
    BOOL    _isLoading;
    BOOL    _firstCount;
    BOOL    _tooLow;
    UIImageView *imgViewL;
    UIImageView *imgViewR;
    
    UILabel *_chargeModelLB;
    UILabel *_percentageLB;
    UILabel *_canUsedTimeLB;
    dispatch_queue_t        _dispatchQueue;
    
    CustomProgressView *_prgressView;
    BOOL                _lowAlert;
    BOOL                _startThread;
    BOOL                _chargeStorage;
    
    BOOL _isLastTimeLinkPC;
}
- (id)init{
    self = [super init];
    if (self) {
        self.titleArr = [[NSMutableArray alloc] init];
        self.disArr = [[NSMutableArray alloc] init];
        self.unitArr = [[NSMutableArray alloc] init];
        _firstCount = YES;
        _stop = YES;
        _first = NO;
        _isPower = NO;
        NSArray *nameArr = [NSArray arrayWithObjects:NSLocalizedString(@"allgb",@""),NSLocalizedString(@"redaygb",@""),NSLocalizedString(@"canuse",@""),nil];
        _dispatchQueue  = dispatch_queue_create("FilterLoading", DISPATCH_QUEUE_SERIAL);
        
        imgViewL = [[UIImageView alloc]init];
        imgViewL.frame = CGRectMake((SCREEN_WIDTH - 200*WINDOW_SCALE_SIX)/2.0, 240*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 35*WINDOW_SCALE_SIX);
        [imgViewL setImage:[UIImage imageNamed:@"main_quickCharge.png" bundle:@"TAIG_MainImg.bundle"]];
        
        
        self.btnLift = [[UIButton alloc]init];
        [self.btnLift  setTitle:nil forState:UIControlStateNormal];
        self.btnLift .backgroundColor = [UIColor clearColor];
        self.btnLift.frame =  CGRectMake((SCREEN_WIDTH - 200*WINDOW_SCALE_SIX)/2.0, 230*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 65*WINDOW_SCALE_SIX);
        self.btnLift.titleLabel.font = [UIFont systemFontOfSize:11.0];
        
        //        [self.btnLift addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self.btnLift addTarget:self action:@selector(touchOutside:) forControlEvents:UIControlEventTouchUpOutside];
        //        [self.btnLift addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
        //        [self.btnLift addTarget:self action:@selector(touchChange:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        
        _prgressView = [[CustomProgressView alloc] init];
        _prgressView.backgroundColor = [UIColor clearColor];
        //        _prgressView.frame = CGRectMake(100*WINDOW_SCALE_SIX, 120*WINDOW_SCALE_SIX, 150*WINDOW_SCALE_SIX, 150*WINDOW_SCALE_SIX);
        _prgressView.frame = CGRectMake((SCREEN_WIDTH - 190*WINDOW_SCALE_SIX)/2, 142*WINDOW_SCALE_SIX, 160*WINDOW_SCALE_SIX, 150*WINDOW_SCALE_SIX);
        [_prgressView initView:120*WINDOW_SCALE_SIX point:CGSizeMake(3, 12) cornerRadius:1.5];
//        [_prgressView setProgress:0.2 anim:YES];
//        [_prgressView setLimitValue:0.15];
        [self addSubview:_prgressView];
        [self AllGB:@"0" UewdGB:@"0" UnUseGB:@"0"];
        
        _chargeModelLB = [[UILabel alloc]init];
        _chargeModelLB.backgroundColor = [UIColor clearColor];
        _chargeModelLB.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        _chargeModelLB.text = NSLocalizedString(@"batterysaving", @"");
        _chargeModelLB.textColor = [UIColor colorWithRed:164.0/255.0 green:165.0/255.0 blue:169.0/255.0 alpha:1.0];
        _chargeModelLB.textAlignment = NSTextAlignmentCenter;
        _chargeModelLB.frame = CGRectMake((SCREEN_WIDTH-150*WINDOW_SCALE_SIX)/2.0,85*WINDOW_SCALE_SIX,150*WINDOW_SCALE_SIX,30*WINDOW_SCALE_SIX);
        [self addSubview:_chargeModelLB];
        
        _percentageLB = [[UILabel alloc]init];
        _percentageLB.backgroundColor = [UIColor clearColor];
        _percentageLB.font =  [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50.0f];
        //        _percentageLB.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        _percentageLB.textColor = [UIColor whiteColor];
        _percentageLB.textAlignment = NSTextAlignmentCenter;
        _percentageLB.frame = CGRectMake((SCREEN_WIDTH-150*WINDOW_SCALE_SIX)/2.0,120*WINDOW_SCALE_SIX,150*WINDOW_SCALE_SIX,50*WINDOW_SCALE_SIX);
        [self addSubview:_percentageLB];
        
        
        _canUsedTimeLB = [[UILabel alloc]init];
        _canUsedTimeLB.backgroundColor = [UIColor clearColor];
        _canUsedTimeLB.font =  [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        _canUsedTimeLB.textColor = [UIColor colorWithRed:164.0/255.0 green:165.0/255.0 blue:169.0/255.0 alpha:1.0];
        _canUsedTimeLB.textAlignment = NSTextAlignmentCenter;
        _canUsedTimeLB.numberOfLines = 0;
        _canUsedTimeLB.frame = CGRectMake((SCREEN_WIDTH-150*WINDOW_SCALE_SIX)/2.0,_percentageLB.frame.origin.y+_percentageLB.frame.size.height+10*WINDOW_SCALE_SIX,150*WINDOW_SCALE_SIX,32*WINDOW_SCALE_SIX);
        [self addSubview:_canUsedTimeLB];
        
        CGFloat height = _canUsedTimeLB.frame.size.height/2.0;
        
        imgViewR = [[UIImageView alloc]init];
        imgViewR.frame = CGRectMake((SCREEN_WIDTH - 123*WINDOW_SCALE_SIX)/2.0,_canUsedTimeLB.frame.origin.y+height+ 28*WINDOW_SCALE_SIX, 123*WINDOW_SCALE_SIX, 35*WINDOW_SCALE_SIX);
        [imgViewR setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"]];
        imgViewR.hidden = YES;
        
        self.labRight = [[UILabel alloc]init];
        self.labRight.backgroundColor = [UIColor clearColor];
        self.labRight.font = [UIFont boldSystemFontOfSize:12.0f*WINDOW_SCALE_SIX];
        self.labRight.textColor = [UIColor whiteColor];
        self.labRight.textAlignment = NSTextAlignmentCenter;
        self.labRight.frame = imgViewR.frame;
        
        
        self.btnRight = [[UIButton alloc]init];
        self.btnRight.backgroundColor = [UIColor clearColor];
        [self.btnRight setTitle:nil forState:UIControlStateNormal];
        self.btnRight.frame = CGRectMake((SCREEN_WIDTH - 123*WINDOW_SCALE_SIX)/2.0,_canUsedTimeLB.frame.origin.y+height+ 28*WINDOW_SCALE_SIX, 123*WINDOW_SCALE_SIX, 35*WINDOW_SCALE_SIX);//CGRectMake((SCREEN_WIDTH - 100*WINDOW_SCALE_SIX)/2.0, 210*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 65*WINDOW_SCALE_SIX);
        self.btnRight.titleLabel.font = [UIFont systemFontOfSize:8.0*WINDOW_SCALE_SIX];
        [_btnRight setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
        [_btnRight setImage:[UIImage imageNamed:@"main_grayRight.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateHighlighted];
//        [self.btnRight addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
//        [self.btnRight addTarget:self action:@selector(touchOutside:) forControlEvents:UIControlEventTouchUpOutside];
//        [self.btnRight addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
        [self.btnRight addTarget:self action:@selector(touchChange:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:imgViewR];
        [self addSubview:self.btnRight];
        [self addSubview:self.labRight];
        
        for (int i = 0; i < nameArr.count; i++) {
            UILabel *labGB = [[UILabel alloc]init];
            labGB.backgroundColor = [UIColor clearColor];
            labGB.text = nameArr[i];
            labGB.font = [UIFont boldSystemFontOfSize:12.0f*WINDOW_SCALE_SIX];
            labGB.textColor = [UIColor colorWithRed:164.0/255.0 green:165.0/255.0 blue:169.0/255.0 alpha:1.0];
            labGB.textAlignment = NSTextAlignmentCenter;
            labGB.frame = CGRectMake((SCREEN_WIDTH-300*WINDOW_SCALE_SIX)/2.0-4*WINDOW_SCALE_SIX + i*102*WINDOW_SCALE_SIX,imgViewR.frame.origin.y+imgViewR.frame.size.height+28*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 12*WINDOW_SCALE_SIX);
            [self addSubview:labGB];
            [self.titleArr addObject:labGB];
            
            UILabel *labTX = [[UILabel alloc]init];
            labTX.textAlignment = NSTextAlignmentRight;
            labTX.textColor = [UIColor whiteColor];
            labTX.font = [UIFont boldSystemFontOfSize:28.0f*WINDOW_SCALE_SIX];
            labTX.frame = CGRectMake((SCREEN_WIDTH-300*WINDOW_SCALE_SIX)/2.0-4*WINDOW_SCALE_SIX + i*102*WINDOW_SCALE_SIX, labGB.frame.origin.y+labGB.frame.size.height+10*WINDOW_SCALE_SIX, 75*WINDOW_SCALE_SIX, 28*WINDOW_SCALE_SIX);
            labTX.backgroundColor = [UIColor clearColor];
            
            UILabel *labAnd = [[UILabel alloc]init];
            labAnd.textAlignment = NSTextAlignmentLeft;
            labAnd.textColor = labGB.textColor;
            labAnd.text = @"GB";
            labAnd.font = [UIFont boldSystemFontOfSize:12.0f*WINDOW_SCALE_SIX];
            labAnd.frame = CGRectMake(labTX.frame.origin.x+labTX.frame.size.width,labTX.frame.origin.y+15*WINDOW_SCALE_SIX , 25*WINDOW_SCALE_SIX, 12*WINDOW_SCALE_SIX);
            labAnd.backgroundColor = [UIColor clearColor];
            
            [self addSubview:labTX];
            [self.disArr addObject:labTX];
            [self addSubview:labAnd];
            [self.unitArr addObject:labAnd];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUpansss) name:@"setUpansss" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceModelChanged) name:DEVICE_MODEL_NOTF object:nil];
            //            if (i > 0) {
            //                UIView *lineView = [[UIView alloc]init];
            //                lineView.frame = CGRectMake(labGB.frame.origin.x-2*WINDOW_SCALE_SIX, 290*WINDOW_SCALE_SIX, 2*WINDOW_SCALE_SIX , 60*WINDOW_SCALE_SIX );
            //                lineView.backgroundColor = [UIColor colorWithRed:39.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1.0];
            //                [self addSubview:lineView];
            //            }
            
        }
        
        //        for (NSString* family in [UIFont familyNames])
        //        {
        //            NSLog(@"%@", family);
        //            for (NSString* name in [UIFont fontNamesForFamilyName: family])
        //            {
        //                NSLog(@"  %@", name);
        //            }
        //        }
        [self deviceModelChanged];
    }
    return self;
}
-(void)deviceModelChanged {
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    NSString* charge = [userdefault objectForKey:@"ChargeSwitch"];
    _chargeStorage = charge && [charge isEqualToString:@"on"];
    _chargeModelLB.hidden = !_chargeStorage;
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float  devicepower = [UIDevice currentDevice].batteryLevel;
    int powerInt = (int)(devicepower*100);
    _lastSurplus = powerInt;
    _lastStart = 0;
}

-(void)setUpansss{
    
    [self touchchange];
}
-(void)dealloc{
    if (_dispatchQueue) {
        dispatch_object_t _o = (_dispatchQueue);
        _dispatch_object_validate(_o);
        _dispatchQueue = NULL;
    }
}

-(void)nowLight:(NSString *)nowTx canUseTxt:(NSString *)useTxt setProgress:(float)progress isAnim:(BOOL)isanim{
    
    int pro = progress * VIEW_COUNT;
    int limitValue = [_prgressView getLimitValue];
    if (pro < limitValue) {
        _percentageLB.textColor = [UIColor redColor];
    }else{
        _percentageLB.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    if (nowTx == nil) {
        _percentageLB.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
    }else{
        _percentageLB.text = [NSString stringWithFormat:@"%@%@",nowTx,@"%"];
    }
    if (useTxt) {
        _canUsedTimeLB.text = useTxt;
    }
    if (![_prgressView isAnimating]) {
        [_prgressView setProgress:progress anim:isanim];
    }
}

-(void)setLeftBtn:(NSString *)leftTxt{
    self.labLift.text =leftTxt;
}
-(void)setRightBtn:(NSString *)rightTxt{
    self.labRight.text = rightTxt;
}
-(void)AllGB:(NSString *)all UewdGB:(NSString *)used UnUseGB:(NSString *)unuse{
    if(self.titleArr.count == 0)
        return;
    for (NSInteger i = 0; i < 3; i ++) {
        UILabel* title = [self.titleArr objectAtIndex:i];
        UILabel* dislab = [self.disArr objectAtIndex:i];
        UILabel* gblab = [self.unitArr objectAtIndex:i];
        if (i == 0) {
            dislab.text = [NSString stringWithFormat:@"%@",all];
        }
        else if (i == 1) {
            dislab.text = [NSString stringWithFormat:@"%@",used];
        }
        else if (i == 2) {
            dislab.text = [NSString stringWithFormat:@"%@",unuse];
        }
        [dislab sizeToFit];
        CGRect frame = dislab.frame;
        dislab.frame = CGRectMake(title.frame.origin.x +title.frame.size.width / 2.0f - dislab.frame.size.width/2.0f, frame.origin.y, frame.size.width, frame.size.height);
        gblab.frame = CGRectMake(dislab.frame.origin.x +dislab.frame.size.width, gblab.frame.origin.y, gblab.frame.size.width, gblab.frame.size.height);
    }
}

-(void)resetSizeLableColor:(BOOL)isU{
    for (NSInteger i = 0; i < 3; i ++) {
        UILabel* dislab = [self.disArr objectAtIndex:i];
        dislab.textColor = isU ? [UIColor lightGrayColor] : [UIColor whiteColor] ;
    }
}

-(void)stopData{
    _stop = YES;
}

-(void)beginData{
    _stop = NO;
    if (![_prgressView isAnimating]) {
        if (!_startThread) {
            _startThread = YES;
        }
        else {
            [timer invalidate];
        }
        NSLog(@"freshData start");
       [self freshData];
    }
}
-(void)resetPlayingKeMusic{
    [[MusicPlayerViewController instance] resetPlayArray];
}
-(void)freshData{
    
    [NSThread detachNewThreadSelector:@selector(threadGetPowerInfo) toTarget:self withObject:nil];
}

-(void)threadGetPowerInfo{
    PowerBean *powerBean = [FileSystem getPoweInfo];
    [self performSelectorOnMainThread:@selector(doRefreshPower:) withObject:powerBean waitUntilDone:NO];
}

-(void)doRefreshPower:(PowerBean*)powerBean {
    
    if(!powerBean){
        //            [self nowLight:0 canUseTxt:NSLocalizedString(@"suanzhong",@"") setProgress:0 isAnim:YES];
        //            [self setRightBtn:NSLocalizedString(@"changekukeu",@"")];
        if (_stop) {
            [timer invalidate];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
        }
        return;
    }else{
        
        NSString *_titleLabel;
        
        
//        [self quickOrSlow];
        
        //获取手机当前百分比
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        float  devicepower = [UIDevice currentDevice].batteryLevel;
        int powerInt = (int)(devicepower*100);
//        [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL powerBean.usb1_stat : %lu, surplus : %d ，devicepower : %d ，speed : %lu ,nowww : %d",(unsigned long)powerBean.usb1_stat,(int)(powerBean.surplus*100),(int)(devicepower*100),(unsigned long)powerBean.speed,powerBean.current]];
//        NSLog(@"powerBean.usb1_stat : %lu, surplus : %d ，devicepower : %d ，speed : %lu ,nowww : %d",(unsigned long)powerBean.usb1_stat,(int)(powerBean.surplus*100),(int)(devicepower*100),(unsigned long)powerBean.speed,powerBean.current);
        //自动设置快慢充
        if (_lastSurplus == 0) {
            _lastSurplus = powerInt;
        }
        
        NSInteger status = 0;
        if(powerBean.usb1_stat != INSERTPOWER && powerBean.usb1_stat != INSERTPC){
            float lastPay = 0;
            
            

            if (_chargeStorage) {
//                if (devicepower<0.1) {
//                    if (powerBean.speed==SLOW) {
//                        [FileSystem setChargingGear:FAST];
//                    }
//                    
//                }else{
//                    if ((int)(powerBean.surplus*100) >= 25) {
//                        
//                        if ((int)(powerBean.surplus*100)>=devicepower*100) {
//                            if ((int)(powerBean.surplus*100)-devicepower*100>5) {
//                                if (powerBean.speed==SLOW) {
//                                    [FileSystem setChargingGear:FAST];
//                                }
//                                
//                            }
//                            if ((int)(powerBean.surplus*100)==devicepower*100){
//                                if (powerBean.speed==FAST) {
//                                    [FileSystem setChargingGear:SLOW];
//                                }
//                            }
//                        }else {
//                            if (powerBean.speed==FAST) {
//                                [FileSystem setChargingGear:SLOW];
//                            }
//                        }
//                        
//                    }else{
//                        if (powerBean.speed == FAST) {
//                            [FileSystem setChargingGear:SLOW];
//                        }
//                    }
//                }
                if (powerInt < 25) {
//                    if (_lastSurplus != 25) {
//                        [LogUtils writeLog:[NSString stringWithFormat:@"%d",powerInt] fileName:@"phone"];
//                        [LogUtils writeLog:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] fileName:@"ke"];
//                        [LogUtils writeLog:[NSString stringWithFormat:@"%d",0] fileName:@"KeNeed"];
//                        [LogUtils writeLog:@"FAST" fileName:@"status"];
//                    }
                    status = FAST;
                    _lastSurplus = 25;
                    [FileSystem setChargingGear:FAST];
                }
                else {
                    if (!_tooLow) {
                        lastPay = _lastNeed > 0 ? (powerInt - 25)/_lastNeed : 0;
                        keNeed = _lastNeed > 0 ? (int)(lastPay*4) : (int)(powerBean.surplus*100);
                    }
                    
                    if (keNeed <= (int)(powerBean.surplus*100)) {
                        
                        if (powerInt < _lastSurplus - 1) {
                            if (_lastStart != 0) {
//                                [LogUtils writeLog:[NSString stringWithFormat:@"%d",_lastSurplus] fileName:@"lastphone"];
//                                [LogUtils writeLog:[NSString stringWithFormat:@"%f :: %ld",lastPay,_lastStart] fileName:@"lastPay"];
//                                [LogUtils writeLog:[NSString stringWithFormat:@"%d",powerInt] fileName:@"phone"];
//                                [LogUtils writeLog:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] fileName:@"ke"];
//                                [LogUtils writeLog:[NSString stringWithFormat:@"%d",keNeed] fileName:@"KeNeed"];
//                                [LogUtils writeLog:@"FAST" fileName:@"status"];
                                _lastNeed = 3600*1.0f/(_lastStart*5.0f);
                            }
                            _lastStart = 0;
                            status = FAST;
                            [FileSystem setChargingGear:FAST];
                        }
                        else if (powerInt >= _lastSurplus) {
                            if (_firstCount) {
                                _lastStart = 0;
                            }
                            else {
                                if (_isLoading) {
                                    _lastStart = 0;
                                    _isLoading = NO;
                                }
//                                if (_lastStart == 0) {
//                                    [LogUtils writeLog:[NSString stringWithFormat:@"%d",_lastSurplus] fileName:@"lastphone"];
//                                    [LogUtils writeLog:[NSString stringWithFormat:@"%f",lastPay] fileName:@"lastPay"];
//                                    [LogUtils writeLog:[NSString stringWithFormat:@"%d",powerInt] fileName:@"phone"];
//                                    [LogUtils writeLog:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] fileName:@"ke"];
//                                    [LogUtils writeLog:[NSString stringWithFormat:@"%d",keNeed] fileName:@"KeNeed"];
//                                    [LogUtils writeLog:@"SLOW" fileName:@"status"];
//                                }
                                _lastStart ++;
                            }
                            
                            status = SLOW;
                            if (!_initPower) {
                                _initPower = YES;
                                [self performSelector:@selector(delayChangeSlow) withObject:nil afterDelay:2];
                            }
                            else {
                                [FileSystem setChargingGear:SLOW];
                            }
                        }
                        else{
                            _firstCount = NO;
                            _isLoading = YES;
                            _lastStart ++;
                        }
                    }
                    else {
                        _tooLow = YES;
                        status = SLOW;
                        if (!_initPower) {
                            _initPower = YES;
                            [self performSelector:@selector(delayChangeSlow) withObject:nil afterDelay:2];
                        }
                        else {
                            [FileSystem setChargingGear:SLOW];
                        }
                    }
                    
                }
                
            }
            else {
                if (powerInt < 25) {
                    _lastSurplus = 25;
                    [FileSystem setChargingGear:FAST];
                }
                else {
                    if (powerInt <= _lastSurplus) {
                        status = FAST;
                        [FileSystem setChargingGear:FAST];
                    }
                    else {
                        status = SLOW;
                        if (!_initPower) {
                            _initPower = YES;
                            [self performSelector:@selector(delayChangeSlow) withObject:nil afterDelay:2];
                        }
                        else {
                            [FileSystem setChargingGear:SLOW];
                        }
                    }
                }
            }
            
//            [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL _chargeStorage : %d,_lastSurplus : %d, lastPay : %f, powerInt : %d,ke surplus : %d ,keNeed : %d ,_lastStart : %ld, status : %@ ，_lastNeed : %f",_chargeStorage,_lastSurplus,lastPay,powerInt,(int)(powerBean.surplus*100),keNeed,(long)_lastStart,status == FAST ? @"FAST" : @"SLOW",_lastNeed]];
        }
        if (_stop) {
            [timer invalidate];
            timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
            return;
        }
        
        [self determineTheState:powerBean];
        
        float surplus = powerBean.surplus;// > 0.1f ? (powerBean.surplus - 0.1f)* 10.0f/9.0f : 0;
//        surplus = surplus * 100 > (int)(surplus*100) + 0.005f ? ((int)(surplus*100))/100.0f + 0.01f : surplus;
        if (surplus <= 0.1f && !_lowAlert) {
            _lowAlert = YES;
            
//            UIViewController *vc = self.rootViewController.navigationController.topViewController;
//            NSLog(@"topppppp :%@",vc);
//            if (![vc isKindOfClass:[PAPasscodeViewController class]]) {
                _lowerPowAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lowpowertiptitle", @"") message:(surplus == 0.1f ? NSLocalizedString(@"tenpecentpowertip", @"") : NSLocalizedString(@"belowtenpecentpowertip", @"")) delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                [_lowerPowAlert show];

//            }
            
        }
        if(powerBean.usb1_stat == ERROR||powerBean.usb1_stat==NONE){
            
            _titleLabel = NSLocalizedString(@"pluspower",@"");//[NSString stringWithFormat:@"%@：%d：%@",NSLocalizedString(@"pluspower",@""),keNeed,status == FAST ? @"大" : @"小"];
            [self nowLight:[NSString stringWithFormat:@"%d",(int)(surplus*100)] canUseTxt:_titleLabel setProgress:(float)(surplus) isAnim:YES];
            
            [timer invalidate];
            timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
            
        }else{
            
            double delayInSeconds;
            if (!_first) {
                [self nowLight:[NSString stringWithFormat:@"%d",(int)(surplus*100)] canUseTxt:NSLocalizedString(@"powering",@"")  setProgress:1.0 isAnim:YES];
                _first = YES;
                delayInSeconds = [self animataTime:0.0];
            }else{
                [_prgressView setProgress:1.0 anim:YES];
                delayInSeconds = [self animataTime:(float)(surplus)*51];
            }
            
            if (surplus < 1) {
                _titleLabel = NSLocalizedString(@"powering",@"") ;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self nowLight:[NSString stringWithFormat:@"%d",(int)(surplus*100)] canUseTxt:_titleLabel setProgress:(float)(surplus)isAnim:NO];
                    [timer invalidate];
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
                });
                
            }else{
                _titleLabel = NSLocalizedString(@"powerfull",@"") ;
                [self nowLight:[NSString stringWithFormat:@"%d",(int)(surplus*100)] canUseTxt:_titleLabel setProgress:(float)(surplus)isAnim:NO];
                [timer invalidate];
                timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
                
            }
            
            
        }
    }
}

-(void)delayChangeSlow{
    [FileSystem setChargingGear:SLOW];
}

-(void)checkUDisk{
    if (_loadingView) {
        [self determineTheState:nil];
        [_checktimer invalidate];
       _checktimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkUDisk) userInfo:nil repeats:NO];
    }
    else {
        [_checktimer invalidate];
    }
}

-(double)animataTime:(float)now{
    double allTime = 0;
    
    for ( NSInteger i = now;i < 51 ; i++) {
        allTime = (i/51.0)*(i/51.0)*0.2 + allTime;
    }
    return allTime+0.2;
}
//-(void)notifyDevOff{
//    //放电
//    PowerBean *powerBean = [FileSystem getPoweInfo];
//    
//    [self nowLight:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] canUseTxt:NSLocalizedString(@"pluspower",@"") setProgress:(float)(powerBean.surplus) isAnim:YES];
//    [timer invalidate];
//    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(beginData) userInfo:nil repeats:NO];
//     timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(freshData) userInfo:nil repeats:NO];
//}

//-(void)notifPcInst{
//   //充电
//    [self stopData];
//    [CustomNotificationView showToast:@"推入充电"];
//    PowerBean *powerBean = [FileSystem getPoweInfo];
//    [_prgressView setProgress:1.0 anim:YES];
//    double delayInSeconds = [self animataTime:(1.0-(float)(powerBean.surplus))*51];
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        if (powerBean.surplus < 1) {
//            [self nowLight:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] canUseTxt:NSLocalizedString(@"powering",@"") setProgress:(float)(powerBean.surplus) isAnim:NO];
//        }else{
//            [self nowLight:[NSString stringWithFormat:@"%d",(int)(powerBean.surplus*100)] canUseTxt:NSLocalizedString(@"powerfull",@"") setProgress:(float)(powerBean.surplus) isAnim:NO];
//        }
//        if ( round(delayInSeconds*_nowPlay) >= 6.0) {
//            [self beginData];
//            [self freshData];
//            _nowPlay = 0;
//            
//        }else{
//            _nowPlay ++;
//
//            [timer invalidate];
//            timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(notifPcInst) userInfo:nil repeats:NO];
//        }
//    });
//   
//}
//连线状态下充电加动画效果

-(void)animateInbattery{
    [_prgressView setProgress:1.0 anim:YES];
    
}

-(void)touchDown:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableUserInterFace:)]) {
        [self.delegate tableUserInterFace:NO];
    }
    if(self.btnLift == btn){
        [imgViewL setImage:[UIImage imageNamed:@"main_grayLeft.png" bundle:@"TAIG_MainImg.bundle"]];
    }else{
        [imgViewR setImage:[UIImage imageNamed:@"main_grayRight.png" bundle:@"TAIG_MainImg.bundle"]];
    }
}

-(void)touchOutside:(UIButton *)btn{
    
    //    if(self.btnLift == btn){
    //        [self quickOrSlow];
    //    }else{
    //        [self determineTheState];
    //    }
}

-(void)touchCancel:(UIButton *)btn{
    
    if(self.btnLift == btn){
        [self quickOrSlow];
    }else{
        [self determineTheState:nil];
    }
}

-(void)touchChange:(UIButton *)btn{
    
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"setUpan" object:@"setUpan"];
    }else{
        [self touchchange];
   }
}
-(void)touchchange{
    
 [NSThread detachNewThreadSelector:@selector(getPowerInfoForChangeModel) toTarget:self withObject:nil];
}

-(void)getPowerInfoForChangeModel{
    PowerBean *powerBean = [FileSystem getPoweInfo];
    [self performSelectorOnMainThread:@selector(doChangeModel:) withObject:powerBean waitUntilDone:YES];
}

-(void)doChangeModel:(PowerBean*)powerBean {
//    if (self.delegate &&[self.delegate respondsToSelector:@selector(stopcycle)]) {
//        [self.delegate stopcycle];
//    }
    
    //check kuke is useable
    HardwareInfoBean *infoBean =  [FileSystem get_info];
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ HomePageView_doChangeModel_infoBean :: %@",DEBUGMODEL,infoBean]];
    if (!infoBean || (infoBean.size == 0 && infoBean.free_size == 0)) {
        int stat = [FileSystem getStat];
        if (stat != 1) {
            [LogUtils writeLog:[NSString stringWithFormat:@"%@ HomePageView_doChangeModel_getStat :: %d",DEBUGMODEL,stat]];
            if (self.delegate &&[self.delegate respondsToSelector:@selector(showFormatAlert)]) {
                [self.delegate showFormatAlert];
            }
            if(powerBean.usb1_model == INSERTPC_U){
                [imgViewR setImage:[UIImage imageNamed:@"main_unSetUDisc.png" bundle:@"TAIG_MainImg.bundle"]];
                
                [_btnRight setImage:[UIImage imageNamed:@"main_unSetUDisc.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
            }
            else{
                [_btnRight setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
                [imgViewR setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"]];
            }
            
            self.btnRight.userInteractionEnabled = YES;
            return;
        }
    }
    
    
    if (powerBean.usb1_model == INSERTPC_H) {
        [self resetPlayingKeMusic];
        _nowTag = 1;
    }
    else {
        _nowTag = 0;
        [LogUtils writeLog:@"CHANGE UPAN"];
        [[CustomFileManage instance] cleanPathCacheAll];
    }
    if (_loadingView) {
        [self loadingDone];
    }
    if (_timer2) {
        [_timer2 invalidate];
    }
    _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"switching",@"")];
    _timer2 = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(loadingDone) userInfo:nil repeats:NO];
    [_loadingView show];
    
    //            if (!_loadingView) {
    //                [_timer2 invalidate];
    //            }
    [self checkUDisk];
    // U盘模式
    self.btnRight.userInteractionEnabled = NO;
    dispatch_async(_dispatchQueue, ^{
        if (powerBean.usb1_model == INSERTPC_U) {
            if ([FileSystem set_deviceModel:DEVICE_H]) {
                [FileSystem tgk_fso_init];
                [MobClickUtils event:@"U_CHANGE_CLICK" label:@"Set_U"];
//                [[MusicPlayerViewController instance]setdisk:NO];
            }
            
        }else{
            if ([FileSystem set_deviceModel:DEVICE_U]) {
                //                    [self uDisck:NO];
                BOOL ison = powerBean.usb1_stat == INSERTPC;
                if (!_isLastTimeLinkPC && ison) {
                    [MobClickUtils event:@"CONNECT_TO_PC"];
                }
                _isLastTimeLinkPC = ison;
                
                [MobClickUtils event:@"U_CHANGE_CLICK" label:@"Set_Not_U"];
                //                    if (self.delegate && [self.delegate respondsToSelector:@selector(kunerViewHidden:)]) {
                //                        [self.delegate kunerViewHidden:NO];
                //                    }
                [[MusicPlayerViewController instance]setdisk:YES];
            }
        }
        self.btnRight.userInteractionEnabled = YES;
    });
}

-(void)loadingDone{
//    dispatch_async(dispatch_get_main_queue(), ^{
        if (_loadingView) {
            [_loadingView dismiss];
            _loadingView = nil;
        }
        
//    });
}

-(void)determineTheState:(PowerBean *)powerBean{
    //是否U盘模式
    if (!powerBean) {
        [NSThread detachNewThreadSelector:@selector(getPowerInfoForDetermineTheState) toTarget:self withObject:nil];
    }
    else {
        [self doDetermineTheState:powerBean];
    }
//    NSLog(@"usb1_stat : %lu",powerBean.usb1_stat);
//    [self showTmpDisplay:powerBean.usb1_stat model:powerBean.usb1_model];
    
}


-(void)getPowerInfoForDetermineTheState{
    PowerBean* powerBean = [FileSystem getPoweInfo];
    [self performSelectorOnMainThread:@selector(doDetermineTheState:) withObject:powerBean waitUntilDone:YES];
}

-(void)doDetermineTheState:(PowerBean *)powerBean {
    [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL usb status :: %lu",(unsigned long)powerBean.usb1_model]];
    if (powerBean.usb1_model == INSERTPC_U) {
        
        [self uDisck:NO isUSBOn:(powerBean.usb1_stat == INSERTPC)];
    }else {
        [self uDisck:YES isUSBOn:(powerBean.usb1_stat == INSERTPC)];
        
    }
    [self performSelector:@selector(tmpDisplayDone) withObject:nil afterDelay:1];
}


-(void)uDisck:(BOOL)disk isUSBOn:(BOOL)ison{
    if (disk) {
        
//            [CustomNotificationView showToast:@"透传" rootView:self.window];
        [imgViewR setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"]];
        [_btnRight setImage:[UIImage imageNamed:@"main_setUDisc.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
        [self setRightBtn:NSLocalizedString(@"changekukeu",@"")];
       
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"stopcycle" object:nil];
        if (_nowTag == 0) {
            [self loadingDone];
        }
    }else{
        
        if (!_isLastTimeLinkPC && ison) {
            [MobClickUtils event:@"CONNECT_TO_PC"];
        }
        
        _isLastTimeLinkPC = ison;
//            [CustomNotificationView showToast:@"U盘" rootView:self.window];
        [imgViewR setImage:[UIImage imageNamed:@"main_unSetUDisc.png" bundle:@"TAIG_MainImg.bundle"]];
        [_btnRight setImage:[UIImage imageNamed:@"main_unSetUDisc.png" bundle:@"TAIG_MainImg.bundle"] forState:UIControlStateNormal];
        [self setRightBtn:NSLocalizedString(@"closekukeu",@"")];
        if (_nowTag == 1) {
            [self loadingDone];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(kunerViewHidden:isUsbOn:)]) {
        [self.delegate kunerViewHidden:disk isUsbOn:ison];
    }
}

-(void)showTmpDisplay:(NSInteger)stat model:(NSInteger)model{
    if (_tmploadingView) {
        [_tmploadingView dismiss];
        _tmploadingView = nil;
    }
    _tmploadingView = [[CustomNotificationView alloc] initWithTitle:[NSString stringWithFormat:@"state : %ld , model : %ld",(long)stat,model]];
    [_tmploadingView show];
}

-(void)tmpDisplayDone{
    if (_tmploadingView) {
        [_tmploadingView dismiss];
        _tmploadingView = nil;
    }
}


-(void)quickOrSlow{
    PowerBean *powerBean = [FileSystem getPoweInfo];
    if (powerBean.speed == SLOW) {
        [self qCharge:NO];
    }else{
        [self qCharge:YES];
    }
}



-(void)qCharge:(BOOL)charge{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (charge) {
            [self setLeftBtn:NSLocalizedString(@"fastpower",@"")];
            [imgViewL setImage:[UIImage imageNamed:@"main_quickCharge" bundle:@"TAIG_MainImg.bundle"]];
        }else{
            [self setLeftBtn:NSLocalizedString(@"kukequickgo",@"")];
            [imgViewL setImage:[UIImage imageNamed:@"main_unQuickCharge" bundle:@"TAIG_MainImg.bundle"]];
        }
    });
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
