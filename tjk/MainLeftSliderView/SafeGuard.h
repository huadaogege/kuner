//
//  SafeGuard.h
//  tjk
//
//  Created by huadao on 15/6/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBackDelegate.h"
#import "CustomNavigationBar.h"
#import "FileSystem.h"

#pragma mark - TouchLabel
typedef void(^TouchLabelClick)(void);

@interface TouchLabel : UILabel
{
    TouchLabelClick _clickBlock;
}

- (void)setClick:(TouchLabelClick)touchClick;

@end

#pragma mark - SafeGuard

@interface SafeGuard : UIViewController<NavBarDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    CustomNavigationBar * _customNavigationBar;
    NSArray * _questionArray;
    UIPickerView * _pickview;
    UITextField * _answer;
    UIView * _select;
    NSString * _thequsetion;
    BOOL       _keyboard;
    NSString   * thetitle;
    BOOL        _isquestion;
    NSString    *_oldStr;
    UIAlertView * _alert;
    NSString    * _whichmenu;
    BOOL         _findold;
    NSString * _lastAnswer;
    BOOL        flag;
    BOOL        _otherQuestion;
    
    // 格式化提示
    TouchLabel  *_formatTipLab;
}

@property (nonatomic,weak) id<UIBackDelegate> backDelegate;
@property (nonatomic,retain)  UITextField * question;
@property (nonatomic,retain) NSString * password;

-(id)initwithTitle:(NSString * )title whichmneu:(NSString *)menu newpassword:(BOOL)word lastAnswer:(NSString*)answer;

@end
