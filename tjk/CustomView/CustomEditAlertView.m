//
//  CustomEditAlertView.m
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "CustomEditAlertView.h"
#import <CoreGraphics/CoreGraphics.h>

#define CANCEL_BTN_TAG 2
#define OK_BTN_TAG 1
#define EDIT_TEXT_TAG 111

@interface CustomEditAlertView ()<UITextViewDelegate>{
    NSString* _text;
}

@end

@implementation CustomEditAlertView

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithTitle:(NSString*)title message:(NSString*)msg defaultLabel:(NSString*)defaultStr{
    self = [[CustomEditAlertView alloc] init];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIButton* bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.backgroundColor = [UIColor clearColor];
    bgBtn.frame = self.frame;
    [self addSubview:bgBtn];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    CGFloat viewWidth = 270;
    CGFloat topSpace = 20;
    UIView* contailer = [[UIView alloc] init];
    contailer.backgroundColor = [UIColor clearColor];
    contailer.layer.cornerRadius = 6;
    contailer.layer.masksToBounds = YES;
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(topSpace, topSpace, viewWidth - 40, 0)];
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = title;
    titleLab.font = [UIFont boldSystemFontOfSize:15];
    titleLab.numberOfLines = 0;
    [titleLab sizeToFit];
    titleLab.frame = CGRectMake( titleLab.frame.origin.x, titleLab.frame.origin.y, viewWidth - 40, titleLab.frame.size.height);
    [contailer addSubview:titleLab];
    
    UILabel* msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(topSpace, titleLab.frame.origin.y + titleLab.frame.size.height + 10, viewWidth - 40, 0)];
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.text = msg;
    msgLabel.font = [UIFont systemFontOfSize:13];
    msgLabel.numberOfLines = 0;
    [msgLabel sizeToFit];
    msgLabel.frame = CGRectMake( msgLabel.frame.origin.x, msgLabel.frame.origin.y, viewWidth - 40, msgLabel.frame.size.height);
    [contailer addSubview:msgLabel];
//    UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(0, msgLabel.frame.size.height + 2 * topSpace, viewWidth, 1)];
//    line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
//    [contailer addSubview:line];
    
    UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(topSpace, msgLabel.frame.size.height + 2 * topSpace + topSpace, viewWidth - 40, 30)];
    textView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5].CGColor;
    textView.delegate = self;
    textView.layer.borderWidth = .5;
    textView.tag = EDIT_TEXT_TAG;
    [contailer addSubview:textView];
    
    UIImageView* line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, textView.frame.origin.y + textView.frame.size.height + topSpace, viewWidth, 0.5)];
    line2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    [contailer addSubview:line2];
    
    UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:NSLocalizedString(@"cancel", @"Cancel") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    cancelBtn.frame = CGRectMake(0, line2.frame.origin.y + 1, viewWidth/2.0f, 44);
    [cancelBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = CANCEL_BTN_TAG;
    
    UIButton* okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:NSLocalizedString(@"sure", @"Yes") forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    okBtn.frame = CGRectMake(viewWidth/2.0f, line2.frame.origin.y + 1, viewWidth/2.0f, 44);
    okBtn.tag = OK_BTN_TAG;
    [okBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    okBtn.enabled = NO;
    
    
    [contailer addSubview:cancelBtn];
    [contailer addSubview:okBtn];
    
    UIImageView* line3 = [[UIImageView alloc] initWithFrame:CGRectMake(cancelBtn.frame.size.width, cancelBtn.frame.origin.y-0.5, 0.5, 60)];
    line3.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    [contailer addSubview:line3];
    
    CGFloat viewHeight = okBtn.frame.size.height + okBtn.frame.origin.y;
    contailer.frame = CGRectMake((SCREEN_WIDTH - viewWidth)/2.0f, SCREEN_HEIGHT - viewHeight - 280, viewWidth, viewHeight);
    UIView* containerBG = [[UIView alloc] initWithFrame:CGRectMake(0,0, viewWidth, viewHeight)];
    containerBG.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.95];
    [contailer insertSubview:containerBG atIndex:0];
    [self addSubview:contailer];
    return self;
}

-(void)show:(UIView*)rootView{
    self.alpha = 0;
    [rootView addSubview:self];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        UITextView* text = (UITextView*)[self viewWithTag:EDIT_TEXT_TAG];
        [text becomeFirstResponder];
    }];
}

-(void)textViewDidChange:(UITextView *)textView {
    NSRange textRange = [textView selectedRange];
    NSString* tmpStr = [self disable_emoji:[textView text]];
    if (textView.text.length > tmpStr.length) {
        [textView setText:tmpStr];
        [textView setSelectedRange:textRange];
    }
    _text = textView.text;
    UIButton* okBtn = (UIButton*)[self viewWithTag:OK_BTN_TAG];
    NSString* noSpace = [_text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (noSpace.length == 0) {
        [okBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        okBtn.enabled = NO;
    }
    else {
        [okBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        okBtn.enabled = YES;
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        UIButton* btn = nil;
        NSString* noSpace = [_text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (noSpace.length == 0) {
            btn = (UIButton*)[self viewWithTag:CANCEL_BTN_TAG];
        }
        else {
            btn = (UIButton*)[self viewWithTag:OK_BTN_TAG];
        }
        [self buttonClicked:btn];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

-(void)buttonClicked:(UIButton*)button{
    if ([self.delegate respondsToSelector:@selector(alertViewButtonClickedAt:withText:)]) {
        [self.delegate alertViewButtonClickedAt:button.tag withText:_text];
    }
    self.delegate = nil;
    [self removeFromSuperview];
}

@end
