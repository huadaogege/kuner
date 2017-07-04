//
//  CustomActivityView.m
//  tjk
//
//  Created by 张旭东 on 14-4-16.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "CustomActivityView.h"
#import "AppDelegate.h"

#define appDelegate   ((AppDelegate*)([UIApplication sharedApplication].delegate))

typedef void (^complent)(BOOL finished);
@interface CustomActivityView()
{
    UIWindow  *_window;
    UIView   *_segregateView;
    UILabel *_messageLab;
    
}
@end

@implementation CustomActivityView

static CustomActivityView * alert=nil;
+(CustomActivityView *)instance
{
    if (alert==nil) {
        alert=[[CustomActivityView alloc]init];
    }
    return alert;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _window = appDelegate.window;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.frame = CGRectMake(0,
                                0,
                                180,
                                100);
         self.center = _window.center;
        
    }
    return self;
}

+ (id)defaultCheckActivityView

{
    
    return  [[self alloc]initWithDefaultCheckActivityView:nil];
    
}

+ (id)defaultActivityViewWith:(NSString *)message
{
    return  [[self alloc]initWithDefaultCheckActivityView:message];
}


- (id)initWithDefaultCheckActivityView:(NSString *)message
{
    if ( self = [super init])
    {
        UIActivityIndicatorView *alertView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        alertView.tintColor = [UIColor blackColor];
        [alertView startAnimating];
        alertView.frame = CGRectMake(80,
                                     20,
                                     20,
                                     20);
        [self addSubview:alertView];
        
        _messageLab = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                      60,
                                                                      180,
                                                                      20)];
        _messageLab.textAlignment = NSTextAlignmentCenter;

        [self addSubview:_messageLab];
        _messageLab.text = message?message:NSLocalizedString(@"checking",@"");
        _segregateView = [[UIView alloc]init];
        [_segregateView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        _segregateView.frame = _window.bounds;
        
        
        
        
    }
    return self;
}

- (void)show
{
    
    [_window addSubview:_segregateView];
    
    [_window addSubview:self];
    
    
}

- (void)dismiss
{
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 0.0;
        _segregateView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        [_segregateView removeFromSuperview];
    }];
}

- (void)dismissWithCompletion:(complent)complentBlock
{
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 0.0;
        _segregateView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        complentBlock(finished);
        
        [_segregateView removeFromSuperview];
    }];
}


- (void)setMessage:(NSString *)message
{
    if ([message isEqualToString:_messageLab.text])
    {
        return;
    }
    _message = message;
    _messageLab.text = message;
}



- (void)dismissAterDelay:(float)delay WithAnimationed:(BOOL)animationed withComlent:(complent)complentBlock
{
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (!animationed)
        {
            [self dismiss];
            complentBlock(YES);
           
        }else
        {
            
            [UIView animateWithDuration:0.28 animations:^{
                self.alpha = 0.0;
                _segregateView.alpha = 0.0;
            } completion:^(BOOL finished) {
                
                [self removeFromSuperview];
                if (complentBlock != nil)
                {
                    complentBlock(YES);
                }
                
                [_segregateView removeFromSuperview];
            }];

        }
        
    });
  
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
