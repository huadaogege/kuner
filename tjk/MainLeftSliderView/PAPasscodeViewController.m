//
//  PAPasscodeViewController.m
//  PAPasscode
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PAPasscodeViewController.h"

#define KAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"//限制输入只有英文和数字

#define NAVBAR_HEIGHT   64
#define PROMPT_HEIGHT   33
#define DIGIT_SPACING   10
#define DIGIT_WIDTH     61
#define DIGIT_HEIGHT    53
#define MARKER_WIDTH    16
#define MARKER_HEIGHT   16
#define MARKER_X        22
#define MARKER_Y        18
#define MESSAGE_HEIGHT  74
#define FAILED_LCAP     19
#define FAILED_RCAP     19
#define FAILED_HEIGHT   26
#define FAILED_MARGIN   10
#define TEXTFIELD_MARGIN 8
#define SLIDE_DURATION  0.3

@interface PAPasscodeViewController ()
- (void)cancel:(id)sender;
- (void)handleFailedAttempt;
- (void)handleCompleteField;
- (void)passcodeChanged:(id)sender;
- (void)resetFailedAttempts;
- (void)showFailedAttempts;
- (void)showScreenForPhase:(NSInteger)phase animated:(BOOL)animated;
@end

@implementation PAPasscodeViewController

- (id)initForAction:(PasscodeAction)action whatview:(NSString *)what newPassWord:(BOOL)word lastAnswer:(NSString*)answer{
    self = [super init];
    if (self) {
        
        _action = action;
        _what   = what;
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _simple = YES;
        _newpassword = word;
        _lastAnswer = answer;
     }
    return self;
}
-(void)clickLeft:(UIButton *)leftBtn {
    
 

    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
      
        if (_newpassword) {
           
            if ([_customNavigationBar.title.text isEqualToString:NSLocalizedString(@"inputsecret", @"")]||[_customNavigationBar.title.text isEqualToString:NSLocalizedString(@"setsecret", @"")]) {
                //回到主界面，无锁
                [self.navigationController popToRootViewControllerAnimated:NO];
                if ([_what isEqualToString:@"leftbutton"]) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"leftbutton" object:nil];
                }else if ([_what isEqualToString:@"rightbutton"]){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"rightbutton" object:nil];
                }else if ([_what isEqualToString:@"mneucell"]){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"mneucell" object:nil];
                }else if ([_what isEqualToString:@"setUpan"]){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"setUpansss" object:nil];
                }
            }else{
                [self showScreenForPhase:0 animated:YES];
                _customNavigationBar.title.text = NSLocalizedString(@"setsecret", @"");
            }

            
        }else{
            if ([_customNavigationBar.title.text isEqualToString:NSLocalizedString(@"checksecret", @"")]) {
                
                [self showScreenForPhase:0 animated:YES];
                _customNavigationBar.title.text = NSLocalizedString(@"setsecret", @"");
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            

        }
        
        
    }
}

-(void)clickRight:(UIButton *)leftBtn{
    
    if (_newpassword) {
       
        
//        if ([_customNavigationBar.title.text isEqualToString:@"输入密码"]) {
             //回到主界面，无锁
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            if ([_what isEqualToString:@"leftbutton"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"leftbutton" object:nil];
            }else if ([_what isEqualToString:@"rightbutton"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"rightbutton" object:nil];
            }else if ([_what isEqualToString:@"mneucell"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"mneucell" object:nil];
            }else if ([_what isEqualToString:@"setUpan"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"setUpansss" object:nil];
            }else if ([_what isEqualToString:@"updatekuke"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updatekuke" object:nil];
            }else if ([_what isEqualToString:@"movetokuke"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"movetokuke" object:nil];
            }

//        }else{
//            [self showScreenForPhase:0 animated:YES];
//            _customNavigationBar.title.text = @"设置密码";
//        }
    }else{
        if ([_what isEqualToString:@"rightbutton"]||[_what isEqualToString:@"leftbutton"]||[_what isEqualToString:@"mneucell"]||[_what isEqualToString:@"setUpan"]||[_what isEqualToString:@"updatekuke"]||[_what isEqualToString:@"movetokuke"]){
            
            
//            SafeGuard * foundpass = [[SafeGuard alloc]initwithTitle:@"找回密码" whichmneu:_what newpassword:_newpassword];
            SafeGuard * foundpass = [[SafeGuard alloc]initwithTitle:NSLocalizedString(@"findsecret", @"") whichmneu:_what newpassword:_newpassword lastAnswer:nil];
            
            foundpass.question.userInteractionEnabled =NO;
            foundpass.question.text = [FileSystem getQuestion];
            char* buffer = (char*)calloc(1, 100);
            if (buffer) {
            }
            [self.navigationController pushViewController:foundpass animated:YES];
        }else if ([_what isEqualToString:@"setpassword"]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            
            NSArray * array =self.navigationController.viewControllers;
            if (array.count>1) {
                [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];

            }
            
        }

    }
    
}

- (void)loadView {
    
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, NAVBAR_HEIGHT)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navigationBar.items = @[self.navigationItem];
    [view addSubview:navigationBar];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, view.bounds.size.width, view.bounds.size.height-NAVBAR_HEIGHT)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [view addSubview:contentView];
    
    CGFloat panelWidth = DIGIT_WIDTH*4+DIGIT_SPACING*3+20;
//    if (_simple) {
    
    
        UIView *digitPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, panelWidth, DIGIT_HEIGHT)];
        digitPanel.frame = CGRectOffset(digitPanel.frame, (contentView.bounds.size.width-digitPanel.bounds.size.width)/2, PROMPT_HEIGHT);
        digitPanel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [contentView addSubview:digitPanel];
        
        UIImage *backgroundImage = [UIImage imageNamed:@"safe_box" bundle:@"TAIG_LEFTVIEW.bundle"];
        UIImage *markerImage = [UIImage imageNamed:@"papasscode_marker" bundle:@"TAIG_LEFTVIEW.bundle"];
        CGFloat xLeft = 0;
        for (int i=0;i<4;i++) {
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            backgroundImageView.frame = CGRectOffset(CGRectMake(0, 0, 61, 53), xLeft, 0);
            [digitPanel addSubview:backgroundImageView];

            
            digitImageViews[i] = [[UIImageView alloc] initWithImage:markerImage];
            digitImageViews[i].autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            digitImageViews[i].frame = CGRectOffset(digitImageViews[i].frame, backgroundImageView.frame.origin.x+MARKER_X, MARKER_Y);
            [digitPanel addSubview:digitImageViews[i]];
            xLeft += 61+50.0/3.0;
        }
        passcodeTextField = [[UITextField alloc] initWithFrame:digitPanel.frame];
        passcodeTextField.hidden = YES;
    passcodeTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    passcodeTextField.borderStyle = UITextBorderStyleNone;
    passcodeTextField.secureTextEntry = YES;
    passcodeTextField.textColor = [UIColor colorWithRed:0.23 green:0.33 blue:0.52 alpha:1.0];
    passcodeTextField.keyboardType = UIKeyboardTypeDefault;
    [passcodeTextField addTarget:self action:@selector(passcodeChanged:) forControlEvents:UIControlEventEditingChanged];
    passcodeTextField.delegate =self;
    [contentView addSubview:passcodeTextField];

    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, PROMPT_HEIGHT)];
    promptLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textColor = [UIColor colorWithRed:0.30 green:0.34 blue:0.42 alpha:1.0];
    promptLabel.font = [UIFont boldSystemFontOfSize:17];
    promptLabel.shadowColor = [UIColor whiteColor];
    promptLabel.shadowOffset = CGSizeMake(0, 1);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.numberOfLines = 0;
    [contentView addSubview:promptLabel];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PROMPT_HEIGHT+DIGIT_HEIGHT, contentView.bounds.size.width, MESSAGE_HEIGHT)];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor colorWithRed:0.30 green:0.34 blue:0.42 alpha:1.0];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.shadowColor = [UIColor whiteColor];
    messageLabel.shadowOffset = CGSizeMake(0, 1);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
	messageLabel.text = _message;
    [contentView addSubview:messageLabel];
        
    UIImage *failedBg = [[UIImage imageNamed:@"papasscode_failed_bg" bundle:@"TAIG_LEFTVIEW.bundle"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, FAILED_LCAP, 0, FAILED_RCAP)];
    failedImageView = [[UIImageView alloc] initWithImage:failedBg];
    failedImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    failedImageView.hidden = YES;
    [contentView addSubview:failedImageView];
    
    failedAttemptsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    failedAttemptsLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    failedAttemptsLabel.backgroundColor = [UIColor clearColor];
    failedAttemptsLabel.textColor = [UIColor whiteColor];
    failedAttemptsLabel.font = [UIFont boldSystemFontOfSize:15];
    failedAttemptsLabel.shadowColor = [UIColor blackColor];
    failedAttemptsLabel.shadowOffset = CGSizeMake(0, -1);
    failedAttemptsLabel.textAlignment = NSTextAlignmentCenter;
    failedAttemptsLabel.hidden = YES;
    [contentView addSubview:failedAttemptsLabel];
    
    CGFloat navbottomY = navigationBar.frame.size.height + navigationBar.frame.origin.y;
    tipView = [[UIView alloc] initWithFrame:CGRectMake(0, navbottomY +160*WINDOW_SCALE_SIX, SCREEN_WIDTH, 70)];
    tipView.backgroundColor = [UIColor clearColor];
    [view addSubview:tipView];
    
    tipView.hidden = YES;
    
    for (int i = 0; i < 2; i++) {
        
        UILabel *tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(0,28*i, tipView.frame.size.width, 25)];
        tiplabel.textAlignment = NSTextAlignmentCenter;
        tiplabel.text = i==0?NSLocalizedString(@"setsecrettipone", @"") :NSLocalizedString(@"setsecrettiptwo", @"");
        tiplabel.textColor = [UIColor colorWithRed:52/255.0 green:56/255.0 blue:67/255.0 alpha:1.0];
        tiplabel.font = [UIFont systemFontOfSize:(i==0?16.0:13.0)];
        
        if (![FileSystem isChinaLan] && i == 1) {
            UIFont *font = [UIFont systemFontOfSize:13.0];
            NSString *enstr =NSLocalizedString(@"setsecrettiptwo", @"");
            tiplabel.numberOfLines = 0;
            CGSize size = CGSizeMake(tipView.frame.size.width, 20000.0f);
            size = [enstr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
            
            tiplabel.frame = CGRectMake(0,28*i, tipView.frame.size.width, size.height + 10);
        }
        
        [tipView addSubview:tiplabel];
    }
    
    self.view = view;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:KAlphaNum]invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    BOOL canChange = [string isEqualToString:filtered];
    return canChange;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _safeIsFalse = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-104)/2.0, 192.0, 104, 32)];
    _safeIsFalse.image = [UIImage imageNamed:@"safe_tips" bundle:@"TAIG_LEFTVIEW.bundle"];
    
    _labFalse = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 104, 32)];
    _labFalse.text = NSLocalizedString(@"faultsecret", @"");
    _labFalse.textAlignment = NSTextAlignmentCenter;
    _labFalse.textColor = [UIColor whiteColor];
    _labFalse.font = [UIFont systemFontOfSize:17.0];
    [_safeIsFalse addSubview:_labFalse];
    
    [self.view addSubview:_safeIsFalse];
    
    _labFalse.hidden = YES;
    _safeIsFalse.hidden =YES;
    
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 250, SCREEN_WIDTH, 20)];
    label.font =[UIFont systemFontOfSize:17.0];
    label.textColor =[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"useqtoclosesecret", @"");
    [self.view addSubview:label];
    label.hidden = YES;
    UIView * lines = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-155)/2.0, 270, 155, 1.0)];
    lines.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    [self.view addSubview:lines];
    lines.hidden =YES;
     UIButton * safeguard = [[UIButton alloc]initWithFrame:label.frame];
    [safeguard addTarget:self action:@selector(safeguardtoremove) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:safeguard];
    safeguard.hidden = YES;
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel", @"") forState:UIControlStateNormal];
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    if ([_what isEqualToString:@"updatekuke"]||[_what isEqualToString:@"movetokuke"]){
        _customNavigationBar.leftBtn.hidden = YES;
    }

    [self.view addSubview:_customNavigationBar];
    
    switch (_action) {
        case PasscodeActionSet:
            _customNavigationBar.title.text = NSLocalizedString(@"setsecret", @"");
            tipView.hidden = NO;
            break;
            
        case PasscodeActionEnter:
            _customNavigationBar.title.text = NSLocalizedString(@"entersecret", @"");
            tipView.hidden = YES;
            
            if ([_what isEqualToString:@"rightbutton"]||[_what isEqualToString:@"leftbutton"]||[_what isEqualToString:@"mneucell"]||[_what isEqualToString:@"setUpan"]||[_what isEqualToString:@"updatekuke"]||[_what isEqualToString:@"movetokuke"]) {
                safeguard.hidden = YES;
                label.hidden = YES;
                lines.hidden =YES;
                 [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"forgetsecret", @"") forState:UIControlStateNormal];
            }else{
                safeguard.hidden =NO;
                label.hidden =NO;
//                lines.hidden = NO;
            }
           
            
            break;
            
        case PasscodeActionChange:
            tipView.hidden = YES;
            _customNavigationBar.title.text = NSLocalizedString(@"Change Passcode", nil);
            _changePrompt = NSLocalizedString(@"Enter your old passcode", nil);

            _confirmPrompt = NSLocalizedString(@"Re-enter your new passcode", nil);
            break;
    }
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    _simple = YES;

    
    if (_simple) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }

    if (_failedAttempts > 0) {
        [self showFailedAttempts];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
    

}
-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
           
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            
            if (self.navigationController.topViewController == self) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    
}

-(void)safeguardtoremove{
    
    SafeGuard * safeguard = [[SafeGuard alloc]initwithTitle:NSLocalizedString(@"enterq", @"") whichmneu:_what newpassword:NO lastAnswer:nil];
    safeguard.question.userInteractionEnabled = NO;
    safeguard.question.text = [FileSystem getQuestion];
    [self.navigationController pushViewController:safeguard animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showScreenForPhase:0 animated:NO];
    [passcodeTextField becomeFirstResponder];
    if ([_what isEqualToString:@"rightbutton"]||[_what isEqualToString:@"leftbutton"]||[_what isEqualToString:@"mneucell"]||[_what isEqualToString:@"setUpan"]||[_what isEqualToString:@"closepassword"]||[_what isEqualToString:@"updatekuke"]||[_what isEqualToString:@"movetokuke"]) {
        _customNavigationBar.title.text = NSLocalizedString(@"inputsecret", @"");
    }
    else {
        _customNavigationBar.title.text = NSLocalizedString(@"setsecret", @"");
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [passcodeTextField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [passcodeTextField resignFirstResponder];
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)cancel:(id)sender {
    [_delegate PAPasscodeViewControllerDidCancel:self];
}

-(void)sendPost:(NSString*)whatTmp {
    [FileSystem resetLocked];
    if ([whatTmp isEqualToString:@"leftbutton"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"leftbutton" object:nil];
    }else if ([whatTmp isEqualToString:@"rightbutton"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"rightbutton" object:nil];
    }else if ([whatTmp isEqualToString:@"mneucell"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"mneucell" object:nil];
    }else if ([whatTmp isEqualToString:@"setUpan"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"setUpansss" object:nil];
    }else if ([whatTmp isEqualToString:@"updatekuke"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updatekuke" object:nil];
    }else if ([whatTmp isEqualToString:@"movetokuke"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"movetokuke" object:nil];
    }
}

#pragma mark - implementation helpers

- (void)handleCompleteField {
    NSString *text = passcodeTextField.text;
    switch (_action) {
        case PasscodeActionSet:
            if (phase == 0) {
                _passcode = text;
                messageLabel.text = @"";
                [self showScreenForPhase:1 animated:YES];
            } else {
                
                
                if ([text isEqualToString:_passcode]) {
                    NSLog(@"%@:%@",NSLocalizedString(@"thesecret",@""),_passcode);

//
                    SafeGuard * safeguard = [[SafeGuard alloc]initwithTitle:NSLocalizedString(@"setquestion",@"") whichmneu:_what newpassword:_newpassword lastAnswer:_lastAnswer];
                    [self.navigationController pushViewController:safeguard animated:YES];
                    safeguard.password = _passcode;
                } else {
                    [self showScreenForPhase:0 animated:YES];
                    messageLabel.text = NSLocalizedString(@"secretnotsame",@"");
                    _customNavigationBar.title.text = NSLocalizedString(@"setsecret", @"");
                }
                
                
            }
            break;
            
        case PasscodeActionEnter:
            
            
            if ([FileSystem checkPassWord:text]) {
             
                if ([_what isEqualToString:@"rightbutton"]||[_what isEqualToString:@"leftbutton"]||[_what isEqualToString:@"mneucell"]||[_what isEqualToString:@"setUpan"]||[_what isEqualToString:@"updatekuke"]||[_what isEqualToString:@"movetokuke"]){
                    [FileSystem createDirIfNotExist];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [self performSelector:@selector(sendPost:) withObject:_what afterDelay:0];

                }else{
                    if ([FileSystem clearAllWithPassWord:text]) {
                        [FileSystem resetLocked];
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"closesecretsuccess", @"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(timerFireMethods:)
                                                       userInfo:alert
                                                        repeats:YES];
                        [alert show];
                         [self performSelector:@selector(popback) withObject:nil afterDelay:1.1];
                        
                    }else{
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"closesecretfail", @"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(timerFireMethods:)
                                                       userInfo:alert
                                                        repeats:YES];
                        [alert show];
                        passcodeTextField.text = @"";
                        [self showScreenForPhase:0 animated:YES];
                        
                    }
                   

                  

                }
                
                
        }else {
            _labFalse.hidden = NO;
            _safeIsFalse.hidden = NO;
            passcodeTextField.text = @"";
            [self showScreenForPhase:0 animated:YES];
        }
            break;
            
        case PasscodeActionChange:
            if (phase == 0) {
                if ([text isEqualToString:_passcode]) {
                    [self resetFailedAttempts];
                    [self showScreenForPhase:1 animated:YES];
                } else {
                    [self handleFailedAttempt];
                    [self showScreenForPhase:0 animated:NO];
                }
            } else if (phase == 1) {
                _passcode = text;
                messageLabel.text = @"";
                [self showScreenForPhase:2 animated:YES];
            } else {
                if ([text isEqualToString:_passcode]) {
                    if ([_delegate respondsToSelector:@selector(PAPasscodeViewControllerDidChangePasscode:)]) {
                        [_delegate PAPasscodeViewControllerDidChangePasscode:self];
                    }
                } else {
                    [self showScreenForPhase:1 animated:YES];
                    messageLabel.text = NSLocalizedString(@"secretnotsame", @"");
                }
            }
            break;
    }
}

-(void)popback{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
}

- (void)handleFailedAttempt {
    _failedAttempts++;
    [self showFailedAttempts];
    if ([_delegate respondsToSelector:@selector(PAPasscodeViewController:didFailToEnterPasscode:)]) {
        [_delegate PAPasscodeViewController:self didFailToEnterPasscode:_failedAttempts];
    }
}

- (void)resetFailedAttempts {
    messageLabel.hidden = NO;
    failedImageView.hidden = YES;
    failedAttemptsLabel.hidden = YES;
    _failedAttempts = 0;
}

- (void)showFailedAttempts {
    messageLabel.hidden = YES;
    failedImageView.hidden = NO;
    failedAttemptsLabel.hidden = NO;
    if (_failedAttempts == 1) {
        failedAttemptsLabel.text = NSLocalizedString(@"1 Failed Passcode Attempt", nil);
    } else {
        failedAttemptsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Failed Passcode Attempts", nil), _failedAttempts];
    }
    [failedAttemptsLabel sizeToFit];
    CGFloat bgWidth = failedAttemptsLabel.bounds.size.width + FAILED_MARGIN*2;
    CGFloat x = floor((contentView.bounds.size.width-bgWidth)/2);
    CGFloat y = PROMPT_HEIGHT+DIGIT_HEIGHT+floor((MESSAGE_HEIGHT-FAILED_HEIGHT)/2);
    failedImageView.frame = CGRectMake(x, y, bgWidth, FAILED_HEIGHT);
    x = failedImageView.frame.origin.x+FAILED_MARGIN;
    y = failedImageView.frame.origin.y+floor((failedImageView.bounds.size.height-failedAttemptsLabel.frame.size.height)/2);
    failedAttemptsLabel.frame = CGRectMake(x, y, failedAttemptsLabel.bounds.size.width, failedAttemptsLabel.bounds.size.height);
}

- (void)passcodeChanged:(id)sender {
    NSString *text = passcodeTextField.text;
    if (_simple) {
        if ([text length] > 4) {
            text = [text substringToIndex:4];
        }
        for (int i=0;i<4;i++) {
            digitImageViews[i].hidden = i >= [text length];
        }
        if ([text length] == 4) {
            [self handleCompleteField];
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = [text length] > 0;
    }
}

- (void)showScreenForPhase:(NSInteger)newPhase animated:(BOOL)animated {
    CGFloat dir = (newPhase > phase) ? 1 : -1;
    if (animated) {
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        snapshotImageView = [[UIImageView alloc] initWithImage:snapshot];
        snapshotImageView.frame = CGRectOffset(snapshotImageView.frame, -contentView.frame.size.width*dir, 0);
        [contentView addSubview:snapshotImageView];
    }
    phase = newPhase;
    passcodeTextField.text = @"";
    if (!_simple) {
        BOOL finalScreen = _action == PasscodeActionSet && phase == 1;
        finalScreen |= _action == PasscodeActionEnter && phase == 0;
        finalScreen |= _action == PasscodeActionChange && phase == 2;
        if (finalScreen) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleCompleteField)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(handleCompleteField)];
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    switch (_action) {
        case PasscodeActionSet:
            if (phase == 0) {
//                promptLabel.text = _enterPrompt;
//                 _customNavigationBar.title.text = _enterPrompt;
            } else {
                promptLabel.text = _confirmPrompt;
                  _customNavigationBar.title.text = NSLocalizedString(@"checksecret", @"");
            }
            break;
            
        case PasscodeActionEnter:
//            promptLabel.text = _enterPrompt;
            break;
            
        case PasscodeActionChange:
            if (phase == 0) {
                promptLabel.text = _changePrompt;
            } else if (phase == 1) {
//                promptLabel.text = _enterPrompt;
            } else {
                promptLabel.text = _confirmPrompt;
            }
            break;
    }
    for (int i=0;i<4;i++) {
        digitImageViews[i].hidden = YES;
    }
    if (animated) {
        contentView.frame = CGRectOffset(contentView.frame, contentView.frame.size.width*dir, 0);
        [UIView animateWithDuration:SLIDE_DURATION animations:^() {
            contentView.frame = CGRectOffset(contentView.frame, -contentView.frame.size.width*dir, 0);
        } completion:^(BOOL finished) {
            [snapshotImageView removeFromSuperview];
            snapshotImageView = nil;
        }];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
