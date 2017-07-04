//
//  SafeGuard.m
//  tjk
//
//  Created by huadao on 15/6/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "SafeGuard.h"
#import "PAPasscodeViewController.h"
#import "FormatView.h"
#import "MobClickUtils.h"

#define  QUESTION 111
#define  ANSWER   222
#define WHETHERNEWWORD 3333
@implementation SafeGuard

-(id)initwithTitle:(NSString * )title whichmneu:(NSString *)menu newpassword:(BOOL)word lastAnswer:(NSString*)answer{
   
    _keyboard = NO;
    _findold = word;
    thetitle = title;
    _whichmenu = menu;
    _lastAnswer = answer;
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0  blue:239.0/255.0  alpha:1.0];
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
    [self.view addSubview:_customNavigationBar];
    _customNavigationBar.title.text = title;
    if ([_whichmenu isEqualToString:@"updatekuke"]||[_whichmenu isEqualToString:@"movetokuke"]) {
        _customNavigationBar.rightBtn.hidden = YES;
    }

    _pickview = [[UIPickerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-150*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX, 150*WINDOW_SCALE_SIX)];
    _pickview.dataSource = self;
    _pickview.delegate = self;
    [self pickerView:nil didSelectRow:0 inComponent:0];
    return self;
}

#pragma mark Life Cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UILabel * lab1 = [[UILabel alloc]initWithFrame:CGRectMake(18*WINDOW_SCALE_SIX, 90*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 20*WINDOW_SCALE_SIX)];
    lab1.textAlignment = NSTextAlignmentLeft;
    lab1.text = NSLocalizedString(@"secretquestion", @"");
    lab1.font = [UIFont systemFontOfSize:17.0*WINDOW_SCALE_SIX];

    [self.view addSubview:lab1];
    
    _question = [[UITextField alloc]initWithFrame:CGRectMake(110*WINDOW_SCALE_SIX, 85*WINDOW_SCALE_SIX, 250*WINDOW_SCALE_SIX, 30*WINDOW_SCALE_SIX)];
   
    _question.tag = QUESTION;
//    _question.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0/4.0];
    [_question becomeFirstResponder];
    _question.delegate = self;
    _question.placeholder = NSLocalizedString(@"selectquestion", @"");
    [self.view addSubview:_question];
    
    
    UILabel * lab2 = [[UILabel alloc]initWithFrame:CGRectMake(18*WINDOW_SCALE_SIX, 145*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX, 20*WINDOW_SCALE_SIX)];
    lab2.textAlignment = NSTextAlignmentLeft;
    lab2.text = NSLocalizedString(@"answerofq", @"");
    lab2.font = [UIFont systemFontOfSize:17.0*WINDOW_SCALE_SIX];

    [self.view addSubview:lab2];

    _answer= [[UITextField alloc]initWithFrame:CGRectMake(110*WINDOW_SCALE_SIX, 140*WINDOW_SCALE_SIX, 250*WINDOW_SCALE_SIX, 30*WINDOW_SCALE_SIX)];
   
    _answer.delegate = self;
    _answer.placeholder = NSLocalizedString(@"enteranswerofq", @"");
    _answer.tag = ANSWER;
    [self.view addSubview:_answer];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(18*WINDOW_SCALE_SIX, 248*WINDOW_SCALE_SIX/2.0, SCREEN_WIDTH, 1.0*WINDOW_SCALE_SIX)];
    line1.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0/4.0];
    [self.view addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 368*WINDOW_SCALE_SIX/2.0, SCREEN_WIDTH, 1.0*WINDOW_SCALE_SIX)];
    line2.backgroundColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0/4.0];
    [self.view addSubview:line2];
    
    
    _questionArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"questionone", @""),NSLocalizedString(@"questiontwo", @""),NSLocalizedString(@"questionthree", @""),NSLocalizedString(@"questionfour", @""),NSLocalizedString(@"questionfive", @""),NSLocalizedString(@"questionsix", @""),NSLocalizedString(@"questionseven", @""),NSLocalizedString(@"questioneight", @""),NSLocalizedString(@"questionnine", @""),NSLocalizedString(@"questionten", @""),NSLocalizedString(@"questioneleven", @""),NSLocalizedString(@"questiontwelve", @""),NSLocalizedString(@"otherq", @""), nil];
    
    
   
    _select = [[UIView alloc]initWithFrame:CGRectMake(0, 568-216-30, SCREEN_WIDTH, 30)];
    UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 30)];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.text = NSLocalizedString(@"selectq", @"");
    lab.font = [UIFont systemFontOfSize:16];
    [_select addSubview:lab];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60,0 , 60, 30)];
    label.text = NSLocalizedString(@"sure", @"");
    label.textAlignment = NSTextAlignmentCenter;
    label.font =[UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1];
    [_select addSubview:label];
    
    UIButton * btn2 = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60,0 , 60, 30)];
    [btn2 addTarget:self action:@selector(savethequestion) forControlEvents:UIControlEventTouchUpInside];
    [_select addSubview:btn2];

    UIView * saveview = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-320*WINDOW_SCALE_SIX)/2.0, 200*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX, 45*WINDOW_SCALE_SIX)];
    UIImageView * image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"btn_cancel.png" bundle:@"TAIG_LEFTVIEW.bundle"]];
    image.frame = CGRectMake(0, 0, 320*WINDOW_SCALE_SIX, 45*WINDOW_SCALE_SIX);
    [saveview addSubview:image];
    UILabel * labbel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320*WINDOW_SCALE_SIX, 45*WINDOW_SCALE_SIX)];
    labbel.font = [UIFont systemFontOfSize:20.0*WINDOW_SCALE_SIX];
    labbel.textAlignment = NSTextAlignmentCenter;
    labbel.textColor =[UIColor whiteColor];
    labbel.text = NSLocalizedString(@"sure", @"");
    [saveview addSubview:labbel];
    UIButton * save = [[UIButton alloc]initWithFrame:labbel.frame];
    [save addTarget:self action:@selector(saveall) forControlEvents:UIControlEventTouchUpInside];
    [saveview addSubview:save];
    [self.view addSubview:saveview];
    
    // 格式化提示
    if ([self isShowFormatTip]) {
        _formatTipLab = [[TouchLabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT-50, SCREEN_WIDTH-20, 50)];
        _formatTipLab.backgroundColor = [UIColor clearColor];
        _formatTipLab.numberOfLines = 0;
        _formatTipLab.attributedText =  [self getFormatTipAttributedString];
        [self.view addSubview:_formatTipLab];
        
        UITapGestureRecognizer *tapLabGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToFormatKuke)];
        [_formatTipLab addGestureRecognizer:tapLabGes];
        
//        __weak typeof(self) weakSelf = self;
//        [_formatTipLab setClick:^{
//            [weakSelf jumpToFormatKuke];
//        }];
    }
    
    // 点击空白区域，取消键盘
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllFiledResponder)];
    [self.view addGestureRecognizer:tapGes];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textfieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark NSNotification Methods

-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
          
            if (_alert) {
                [_alert dismissWithClickedButtonIndex:0 animated:NO];
            }
            if (self.navigationController.topViewController == self) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    
}


-(void)textfieldChanged:(NSNotification*)noti{
    UITextField * field = noti.object;
    NSString* tmpStr = [self disable_emoji:field.text];
    NSString *trimmedString;
          NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"，^ _ ^——。？-\\！、：；……“”‘’（）《》｛｝ [  ]  ] ｝》）’”～·＃＊ | || 〖 〗【】『』〔〕.,?!':…~@;\"/()_-+=`^#*%&\[<{|·¡¿$¥£€}>]"];
        trimmedString = [tmpStr stringByTrimmingCharactersInSet:set];
    
    if (_isquestion) {
        if (_question.text.length > trimmedString.length) {
            _question.text =trimmedString;
        }
    }else{
        if (_answer.text.length > trimmedString.length) {
            _answer.text =trimmedString;
        }

    }
}

#pragma mark Button Actions

-(void)saveall{
    
    if ([thetitle isEqualToString:NSLocalizedString(@"findsecret", @"")]) {
        
        if ([FileSystem checkAnswer:_answer.text]) {
            [FileSystem resetLocked];
            if ([_whichmenu isEqualToString:@"updatekuke"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updatekuke" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
            if ([_whichmenu isEqualToString:@"movetokuke"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"movetokuke" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }

            
            
            [_question resignFirstResponder];
            [_answer resignFirstResponder];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"keepuseoldsecret", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:NSLocalizedString(@"resetsecret", @""), nil];
            alert.tag = WHETHERNEWWORD;
            [alert show];
            
            _findold = YES;
            
            
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"faultquestion", @"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethods:)
                                           userInfo:alert
                                            repeats:YES];
            
            [alert show];
            
        }
        
    }else if ([thetitle isEqualToString:NSLocalizedString(@"enterq", @"")]){
        if ([FileSystem clearAllWithAnswer:_answer.text]) {
            [FileSystem resetLocked];
            [MobClickUtils event:@"CLOSE_PASSCODE_RESULT" label:@"success"];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"closesecretsuccess", @"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethods:)
                                           userInfo:alert
                                            repeats:YES];
            
            [alert show];
            [self performSelector:@selector(backtoset) withObject:nil afterDelay:1.1];
  
        }else{
            [MobClickUtils event:@"CLOSE_PASSCODE_RESULT" label:@"fail"];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"faultquestion", @"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethods:)
                                           userInfo:alert
                                            repeats:YES];
            
            [alert show];

        }
        
    }else if([thetitle isEqualToString:NSLocalizedString(@"setquestion", @"")]) {
        
        [_answer resignFirstResponder];
        NSString *question;
        NSString *answer;
        if (![FileSystem isEngLish]) {
            question = [_question.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            answer = [_answer.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        }else{
            question = _question.text;
            answer = _answer.text;
        }
        
        if ((!_otherQuestion || (1<=question.length && question.length<= 25)) && 1<=answer.length && answer.length <=25) {
            _alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"issuretosetsecret", @"") message:NSLocalizedString(@"setsecrettip", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"sure", @""), nil];
            _alert.tag = 38935;
            [_alert show];
  
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"suretosetsecretquestion", @"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethods:)
                                           userInfo:alert
                                            repeats:YES];
            [alert show];
            
        }
        
        
    }
}

-(void)savethequestion{
    
    _pickview.frame = CGRectMake(0, SCREEN_HEIGHT-216, SCREEN_WIDTH, 216);
    _select.frame =CGRectMake(0, SCREEN_HEIGHT-216-30, SCREEN_WIDTH, 30);
    [self.view addSubview:_pickview];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _pickview.frame = CGRectMake(0, SCREEN_HEIGHT+30, SCREEN_WIDTH, 216);
    _select.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 30);
    [UIView commitAnimations];
    _otherQuestion = NO;
    if ([_thequsetion isEqualToString:NSLocalizedString(@"otherq", @"")]) {
        _keyboard = YES;
        _question.text = @"";
        _question.placeholder = NSLocalizedString(@"entersecretquestion", @"");
        [_question becomeFirstResponder];
        _otherQuestion = YES;
    }else{
        _question.text = _thequsetion;
        
    }
}

- (void)resignAllFiledResponder
{
    [_question resignFirstResponder];
    [_answer resignFirstResponder];
}

#pragma mark private methods

- (BOOL)isShowFormatTip
{
    // 找回密码 或者 回答密保问题
    if ([thetitle isEqualToString:NSLocalizedString(@"findsecret", @"")] || [thetitle isEqualToString:NSLocalizedString(@"enterq", @"")]) {
        return YES;
    }
    
    return NO;
}

- (NSAttributedString *)getFormatTipAttributedString
{
//    NSLinkAttributeName
    NSDictionary *normalAttrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],NSForegroundColorAttributeName:[UIColor colorWithRed:116/255.0 green:116/255.0 blue:116/255.0 alpha:1.0]};
    NSDictionary *boldAttrDic = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    
    NSAttributedString *formatTip = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"formatkuke", @"") attributes:boldAttrDic];
    NSMutableAttributedString *attrTip = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"formattingTips", @"") attributes:normalAttrDic];
    [attrTip appendAttributedString:formatTip];
    
    return attrTip;
}

- (void)jumpToFormatKuke
{
    FormatView *formatVC = [[FormatView alloc] initWithState:FormatStateCodeKeLocked];
    [self.navigationController pushViewController:formatVC animated:YES];
}

- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
}

-(void)saveTips{

    if (flag) {
        [MobClickUtils event:@"OPEN_PASSCODE_RESULT" label:@"success"];
        [FileSystem resetLocked];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"setsecretsuccess", @"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timerFireMethods:)
                                       userInfo:alert
                                        repeats:YES];
        [alert show];
        
        if (_findold) {
            
            [self performSelector:@selector(gotomenu) withObject:nil afterDelay:1.1];
            
        }
    }else{
        [MobClickUtils event:@"OPEN_PASSCODE_RESULT" label:@"fail"];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"setsecretfail", @"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timerFireMethods:)
                                       userInfo:alert
                                        repeats:YES];
        [alert show];
        
    }


}
-(void)gotomenu{

    [self.navigationController popToRootViewControllerAnimated:YES];
    if ([_whichmenu isEqualToString:@"leftbutton"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"leftbutton" object:nil];
    }else if ([_whichmenu isEqualToString:@"rightbutton"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"rightbutton" object:nil];
    }else if ([_whichmenu isEqualToString:@"mneucell"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"mneucell" object:nil];
    }else if ([_whichmenu isEqualToString:@"setUpan"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"setUpansss" object:nil];
    }


}

-(void)backtoset{
    NSArray * array = self.navigationController.viewControllers;
    if (array.count>=2) {
        [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        
        if (alertView.tag == WHETHERNEWWORD) {
            
            //            [FileSystem clearAllWithAnswer:_answer.text];
            
            PAPasscodeViewController * ppp = [[PAPasscodeViewController alloc]initForAction:PasscodeActionSet whatview:_whichmenu newPassWord:YES lastAnswer:_answer.text];
            [self.navigationController pushViewController:ppp animated:YES];
            
            
        }else{
            [FileSystem clearAllWithAnswer:_lastAnswer];
            NSString *question;
            NSString * answer;
            if (![FileSystem isEngLish]) {
                question = [_question.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                answer = [_answer.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            }else{
                question = _question.text;
                answer = _answer.text;
            }
            flag = [FileSystem setQuestion:question Answer:answer Password:self.password];
            [self performSelector:@selector(saveTips) withObject:nil afterDelay:0.5];
            
            if (_findold) {
                
            }else{
                [self performSelector:@selector(backtoset) withObject:nil afterDelay:1.5];
            }
        }
    }else{
        
        if (alertView.tag == WHETHERNEWWORD) {
            
            [FileSystem resetLocked];
            [self performSelector:@selector(gotomenu) withObject:nil afterDelay:0.5];
        }else{
            if (_findold) {
                //回到对应界面，无弹框
                [self gotomenu];
            }else{
                [self backtoset];
            }
            
        }
        
        
    }
}


#pragma mark NavBarDelegate

-(void)clickLeft:(UIButton *)leftBtn {
    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)clickRight:(UIButton *)leftBtn{
    if (_findold) {
      //回到对应界面，无密码
        [self gotomenu];
    }else{
        NSArray * array =self.navigationController.viewControllers;
        [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _questionArray.count;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row<_questionArray.count) {
        return  [_questionArray objectAtIndex:row];
    }else{
        return @"";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (row<_questionArray.count) {
        _thequsetion=[_questionArray objectAtIndex:row];
    }
}

#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField.tag ==ANSWER) {
        if (_pickview.superview) {
            [_pickview removeFromSuperview];
            _keyboard = NO;
            _isquestion = NO;
            
        }
        return YES;
    }
    
    if (textField.tag == QUESTION) {
        _isquestion = YES;
        if (!_keyboard) {
            [_question resignFirstResponder];
            [_answer resignFirstResponder];
            _select.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 30);
            
            
            _pickview.frame = CGRectMake(0, SCREEN_HEIGHT+30, SCREEN_WIDTH, 216);
            [self.view addSubview:_pickview];
            [self.view addSubview:_select];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            _select.frame =CGRectMake(0, SCREEN_HEIGHT-216-30, SCREEN_WIDTH, 30);
            _pickview.frame = CGRectMake(0, SCREEN_HEIGHT-216, SCREEN_WIDTH, 216);
            [UIView commitAnimations];

        }else{
            return YES;
        }
       
    }

    return NO;
}

@end

@implementation TouchLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)setClick:(TouchLabelClick)touchClick
{
    if (touchClick) {
        _clickBlock = touchClick;
    }
}

#pragma mark Life

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        _clickBlock();
    }
}

@end

