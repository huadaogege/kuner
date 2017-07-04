#import "CustomAlertView.h"
#import "UIKit/UIKit.h"
#import "AppDelegate.h"
#import "NSNumber+Format.h"


#define forms_Height 100
#define forms_width 200

#define msg_Height 20
#define msg_width 150

@implementation CustomAlertView

//static CustomAlertView *view = nil;
+(CustomAlertView *)instance{
    static CustomAlertView * view = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        view = [[CustomAlertView alloc] init];
    });
    return view;
}

- (id)init{
    
    self = [super init];
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];

        _alphaView = [[UIView alloc] init];
        _alphaView.backgroundColor = [UIColor blackColor];
        _alphaView.alpha = 0.7;
        [self addSubview:_alphaView];
        
        _formsView = [[UIView alloc] init];
        _formsView.layer.cornerRadius = IS_IPHONE6 ? 6.0 : 3.0;;
        _formsView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_formsView];

        _formsMsgLabel = [[UILabel alloc] init];
        _formsMsgLabel.textAlignment = NSTextAlignmentCenter;
        _formsMsgLabel.backgroundColor = [UIColor clearColor];
        _formsMsgLabel.textColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:0.8];
        _formsMsgLabel.font = [UIFont systemFontOfSize:18*WINDOW_SCALE_SIX];
        [_formsView addSubview:_formsMsgLabel];
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.textColor = [UIColor colorWithRed:39.0/255.0 green:39.0/255.0 blue:39.0/255.0 alpha:0.8];
        _progressLabel.font = [UIFont systemFontOfSize:12*WINDOW_SCALE_SIX];
        [_formsView addSubview:_progressLabel];
        
        _progressEmptyView = [[UIView alloc] init];
        _progressEmptyView.layer.masksToBounds = YES;
        _progressEmptyView.layer.cornerRadius = IS_IPHONE6 ? 3.0 : 2.0;
        _progressEmptyView.backgroundColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0];
        [_formsView addSubview:_progressEmptyView];
        
        _progressFullView = [[UIView alloc] init];
        _progressFullView.layer.masksToBounds = YES;
        _progressFullView.backgroundColor = [UIColor blackColor];
        [_formsView addSubview:_progressFullView];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18*WINDOW_SCALE_SIX];
        [_cancelBtn addTarget:self action:@selector(cancelBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [_formsView addSubview:_cancelBtn];
    }
    return self;
}

-(void)cancelBtnPressed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _cancelBtn.userInteractionEnabled = NO;
        int alerttype = _alertType;
        [[NSNotificationCenter defaultCenter] postNotificationName:FILE_OPERATION_CANCEL object:[NSNumber numberWithInt:alerttype]];
        [self hidden];
        [self performSelector:@selector(usedCancelBtn) withObject:nil afterDelay:1.5];
    });
}
-(void)usedCancelBtn
{
    _cancelBtn.userInteractionEnabled = YES;
}

-(void) showProgress{
    [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMALERTSHOWPROGRESS object:nil];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [((AppDelegate*)[[UIApplication sharedApplication] delegate]).window addSubview:self];
    _progressLabel.text = @"";
    self.alpha = 1;
    _alphaView.frame = [[UIScreen mainScreen] bounds];
    
    _formsView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width * 0.14,
                                  [[UIScreen mainScreen] bounds].size.height * 0.415,
                                  [[UIScreen mainScreen] bounds].size.width * 0.72,
                                  [[UIScreen mainScreen] bounds].size.height * 0.17);
    
    _formsMsgLabel.frame = CGRectMake(0,
                                      _formsView.bounds.size.height * 0.13,
                                      _formsView.bounds.size.width,
                                      _formsView.bounds.size.height * 0.20);
    
    _progressLabel.frame = CGRectMake(0,
                                      _formsView.bounds.size.height * 0.37,
                                      _formsView.bounds.size.width,
                                      _formsView.bounds.size.height * 0.13);
    
    _progressEmptyView.frame = CGRectMake(_formsView.bounds.size.width * 0.095,
                                          _formsView.bounds.size.height * 0.7,
                                          _formsView.bounds.size.width * 0.81,
                                          _formsView.bounds.size.height * 0.05);
    
    _progressFullView.frame = CGRectMake(_formsView.bounds.size.width * 0.095,
                                         _formsView.bounds.size.height * 0.7,
                                         0,
                                         _formsView.bounds.size.height * 0.05);
    
    _formsView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width * 0.14,
                                  [[UIScreen mainScreen] bounds].size.height * 0.415,
                                  [[UIScreen mainScreen] bounds].size.width * 0.72,
                                  [[UIScreen mainScreen] bounds].size.height * 0.22);
    _cancelBtn.frame = CGRectMake(0,
                                         _formsView.bounds.size.height * 0.67,
                                         _formsView.bounds.size.width,
                                         _formsView.bounds.size.height * 0.3);
    _cancelBtn.hidden = _notshowcancelBtn;
    
    _progressEmptyView.hidden = NO;
    _progressFullView.hidden = NO;
}

-(BOOL)hasShown{
    return self.alpha != 0 && self.superview != nil;
}

-(void) showMsg{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
[((AppDelegate*)[[UIApplication sharedApplication] delegate]).window addSubview:self];
    self.alpha = 1;
    _formsView.frame = CGRectMake((self.bounds.size.width - forms_width) * 0.5,
                                  (self.bounds.size.height - forms_Height) * 0.5,
                                  forms_width,
                                  forms_Height);
    _alphaView.frame = _formsView.bounds;
    _progressEmptyView.hidden = YES;
    _progressFullView.hidden = YES;}

-(void) hidden{
    [UIView animateWithDuration:.3 animations:^{
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        _alertType = Alert_Normal;
        _notshowcancelBtn = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self removeFromSuperview];
    }];
    
}

-(void)setLabelStr:(NSString *)str{
//    [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL setMsg current isMainThread : %d",[NSThread currentThread].isMainThread]];
    _formsMsgLabel.text = str;
    CGRect rect = [_formsMsgLabel textRectForBounds:_formsMsgLabel.frame limitedToNumberOfLines:99];
    _formsMsgLabel.frame = CGRectMake((_formsView.bounds.size.width - rect.size.width) * 0.5,
                                      (_formsView.bounds.size.height - rect.size.height) * 0.5,
                                      rect.size.width,
                                      rect.size.height);
}

-(void) setMsg:(NSString *)str{
//[LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL setMsg current isMainThread : %d",[NSThread currentThread].isMainThread]];
    _formsMsgLabel.text = str;
}

-(void) setFilesCount:(int)allCount{
    
    _allCount = allCount;
    _progressLabel.text = [NSString stringWithFormat:@"0/%d", _allCount];
}

-(int) getFilesCount{
    
    return _allCount;
}

-(void) setNowNum:(int)num{
    _nowNumber = num;
    [_progressLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d/%d", _nowNumber, _allCount] waitUntilDone:YES];
}

-(void)setNowNum:(int)num fileName:(NSString *)filaname{
    _nowNumber = num;
    [_progressLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"\"%@\"(%d/%d)",filaname, _nowNumber, _allCount] waitUntilDone:YES];
}

-(void) setNowNum:(int)num currentSize:(float)currentSize allSize:(float)allSize {
    _nowNumber = num;
    [_progressLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@/%@ (%d/%d)",
                                                                                [[NSNumber numberWithFloat:currentSize] sizeString],
                                                                                [[NSNumber numberWithFloat:allSize] sizeString] ,
                                                                                _nowNumber,_allCount] waitUntilDone:YES];
    
}

-(void)setNowCountSize:(float)countsize {
    [_progressLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"calculatefilessize", @""),[[NSNumber numberWithFloat:countsize] sizeString]] waitUntilDone:YES];
    
}

- (void) progress:(float)pro{

    if(pro > 1.0){
        pro = 1.0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _progressFullView.layer.cornerRadius = _progressEmptyView.layer.cornerRadius;
        _progressFullView.frame = CGRectMake(_progressEmptyView.frame.origin.x,
                                             _progressEmptyView.frame.origin.y,
                                             _progressEmptyView.bounds.size.width * pro,
                                             _progressEmptyView.bounds.size.height);
    }];
}

@end