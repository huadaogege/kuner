//
//  YpcCustomProgress.m
//  CustomProgressBar
//
//  Created by Ching on 14-8-19.
//  Copyright (c) 2014年 Ching. All rights reserved.
//

#import "YpcCustomProgress.h"
//#import "TAIG_Info.h"
#import "TGK_FFPlayerViewController.h"

#define PERCENTAGE_OF_COMPLETION 98 //进度百分比停止
#define COUNT_TIME_S 115 //总秒数

@implementation YpcCustomProgress
{
    UIView *viewBG;
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        _isFinish = NO;
        formatall = NO;
        _window = [[UIApplication sharedApplication] keyWindow];
        //        [_window makeKeyAndVisible];
        
        //半透明View
        _backView = [[UIView alloc] initWithFrame:_window.bounds];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        [_window addSubview:_backView];
        
        //复制成功
        viewBG = [[UIView alloc] initWithFrame:CGRectMake((_window.bounds.size.width-185)/2.0 , 175, 185, 90)];
        viewBG.backgroundColor = [UIColor whiteColor];
        viewBG.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0);
        viewBG.layer.masksToBounds = YES;
        viewBG.layer.cornerRadius = 4.0;
        viewBG.hidden = YES;
        [_backView addSubview:viewBG];
        
        
        UILabel *Lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 32, viewBG.frame.size.width, 17)];
        Lable.text = NSLocalizedString(@"copypicturefinish",@"图片复制完成");
        Lable.textAlignment = NSTextAlignmentCenter;
        Lable.font = [UIFont systemFontOfSize:20];
        Lable.textColor =[ UIColor blackColor];
        [viewBG addSubview:Lable];
        
        //底层View
        
        _picDownView = [[UIView alloc]initWithFrame:CGRectMake((_window.bounds.size.width-270)/2.0, 220,270, 125)];
        _picDownView.backgroundColor = [UIColor whiteColor];
        _picDownView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0);
        _picDownView.layer.masksToBounds = YES;
        _picDownView.layer.cornerRadius = 4.0;
        [_backView addSubview:_picDownView];
        
        UIImageView *linView = [[UIImageView alloc]init];
        linView.frame = CGRectMake(0, 125-44, 320-50, 1);
        linView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        [_picDownView addSubview:linView];
        
        //提醒文字
        
        _pickLable= [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320-50, 15)];
        _pickLable.font = [UIFont systemFontOfSize:15];
        _pickLable.textAlignment = NSTextAlignmentCenter;
        _pickLable.textColor = [UIColor blackColor];
        NSString *dele = NSLocalizedString(@"delete",@"删除");
        NSString *copy = NSLocalizedString(@"copy",@"复制");
        _pickLable.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"now",@""),self.copyOrDele ? dele:copy];
        [_picDownView addSubview: _pickLable];
        
        
        
        cancelLab = [[UILabel alloc]init];
        cancelLab.frame = CGRectMake(0, 125-43, 320-50, 44);
        cancelLab.font = [UIFont systemFontOfSize:19];
        cancelLab.text = NSLocalizedString(@"cancel",@"");
        cancelLab.textAlignment = NSTextAlignmentCenter;
        cancelLab.textColor = [UIColor colorWithRed:11.0/255.0 green:91.0/255.0 blue:251.0/255.0 alpha:1.0];
        [_picDownView addSubview:cancelLab];
        
        
        self.cancelBtn = [[UIButton alloc]init];
        self.cancelBtn.backgroundColor = [UIColor clearColor];
        self.cancelBtn.frame = CGRectMake(0, 125-43, 320-50, 44);
        [_picDownView addSubview:self.cancelBtn];
        
        _downView = [[UIView alloc]initWithFrame:CGRectMake((_window.bounds.size.width-265)/2.0, 150, 265, 90)];
        _downView.backgroundColor = [UIColor whiteColor];
        _downView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0);
        _downView.layer.masksToBounds = YES;
        _downView.layer.cornerRadius = 4.0;
        [_backView addSubview:_downView];
        
        //提醒文字
        _formattingLab = [[UILabel alloc]initWithFrame:CGRectMake(23, 17, 200, 15)];
        _formattingLab.font = [UIFont systemFontOfSize:14];
        _formattingLab.text = [[NSString stringWithFormat:NSLocalizedString(@"formatting_wait",@"")]stringByAppendingString:@"0 %"];
        
        _formattingLab.textColor = [UIColor blackColor];
        [_downView addSubview: _formattingLab];
        
        _finishLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 35, 160, 15)];
//        _finishLabel.text = NSLocalizedString(@"formatfinish",@"");
        _finishLabel.text = @"";
        [_downView addSubview:_finishLabel];
        
        //灰色进度条
        _grayView = [[UIView alloc]initWithFrame:CGRectMake(self.aOrB?50:50, self.aOrB?245:235,self.aOrB?225:215, 7)];
        _grayView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        _grayView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0);
        _grayView.layer.masksToBounds = YES;
        _grayView.layer.cornerRadius = 4.0;
        _grayView.hidden = NO;
        [_backView addSubview:_grayView];
        
        //蓝色进度条
        _blueView = [[UIView alloc]init];
        _blueView.frame = CGRectMake(self.aOrB?50:50,self.aOrB?245:235,0, 7);
        _blueView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0);
        _blueView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _blueView.layer.masksToBounds = YES;
        _blueView.layer.cornerRadius = 6.0;
        _blueView.hidden = NO;
        [_backView addSubview:_blueView];
        
    }
    return self;
}

- (void)JinDuTiao
{
    _backView.alpha = 1.0;
    _backView.hidden = NO;
    if (self.aOrB) {
        
        _picDownView.hidden = self.aOrB;
        self.cancelBtn.hidden = self.aOrB;
        cancelLab.hidden = YES;
        
    }else{
        _downView.hidden = !self.aOrB;
        _formattingLab.hidden = !self.aOrB;
        _finishLabel.hidden = !self.aOrB;
    }
    
}
-(void)backZero{
    
    _blueView.frame = CGRectMake(_grayView.frame.origin.x,_grayView.frame.origin.y,0, 7);
    
    
}
// 开始定时器
- (void) startPainting:(BOOL)yesOrNo
{
    self.aOrB = yesOrNo;
    [self JinDuTiao];
    [self formatFinish:YES];
    
    _formattingLab.frame=CGRectMake(50, 25, 200, 15);
    _grayView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0+15);
    _blueView.center = CGPointMake(_window.bounds.size.width/2.0, _window.bounds.size.height/2.0+15);
    
    
    
    // 定义一个NSTimer
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(paint)  userInfo:nil
                                    repeats:NO];
    
    HardwareInfoBean *infoBean =  [FileSystem get_info];
    size = infoBean.size/1024.0/1024.0/1024.0;
}
//////////////////////////////////////////////////////
// 定时器执行的方法
- (void)paint{
    
    if(_isFinish){
        
        float count = _grayView.bounds.size.width;
        float temp  ;
        float now=0.0   ;
        float doTime = 1.0;
        
        if (formatall)
        {
            doTime = 0.01;
            
        }else{
            
            if (size){
                
                if (size>40.0) {
                    all=140.0;
                }
                else
                {
                    all=35.0;
                }
                
            }else
            {
                all=140.0;
            }
            
        }
        
        temp = count/all;
        now = _blueView.frame.size.width + temp;
        
        
        
        [UIView animateWithDuration:0.3 animations:^{
            _blueView.layer.cornerRadius = 4.0;
            _blueView.frame = CGRectMake(_grayView.frame.origin.x, _grayView.frame.origin.y, now, _blueView.frame.size.height);
        }];
        
        int ratio = now / count * 100.0;
        if (!formatall) {
            if(ratio > PERCENTAGE_OF_COMPLETION){
                _isFinish = NO;
            }
        }
        if (ratio>=100) {
            
            ratio = 100;
        }else{
            [NSTimer scheduledTimerWithTimeInterval:doTime
                                             target:self
                                           selector:@selector(paint)  userInfo:nil
                                            repeats:NO];
        }
        _formattingLab.text =[[NSString stringWithFormat:NSLocalizedString(@"formatting_wait",@"")]stringByAppendingString:[NSString stringWithFormat:@"  %d %%",ratio]];
        
        
        
        if (ratio == 100 && ratio>=100) {
            _isFinish = NO;
            [UIView animateWithDuration:1.0 animations:^{
                
             
            } completion:^(BOOL finished) {
//                if (self.YpcDelegate && [self.YpcDelegate respondsToSelector:@selector(formatlater)]) {
//                    [self.YpcDelegate formatlater];
//                }
                
                [UIView animateWithDuration:0.5 animations:^{
                    [self formatFinish:NO];
                } completion:^(BOOL finished) {
                    [self removeTheFormatView];
                }];
            }];
        }
        
    }
}
////////////////////////
// 停止定时器
- (void) stopPainting{
    //    _isFinish = NO;
    //    all=1.0;
    formatall = YES;
    _isFinish = YES;
    [self paint];
}
////////////////////
- (void)goToHundred{
    
    [self stopPainting];
    
}
///////////////////
- (void)formatFinish:(BOOL)siShow{
    _isFinish = YES;
    _finishLabel.hidden = siShow;
    _blueView.hidden = !_finishLabel.hidden;
    _grayView.hidden = _blueView.hidden;
    _formattingLab.hidden = _blueView.hidden;
}

- (void)removeTheFormatView{
    
    double delayInSeconds = 0.3;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                _backView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [_backView removeFromSuperview];
            }];
        });
    });
    
    [[TGK_FFPlayerViewController instance] copyplay];
}

@end