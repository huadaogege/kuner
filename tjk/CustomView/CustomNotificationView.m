//
//  CustomNotificationView.m
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "CustomNotificationView.h"
#import "LogUtils.h"

#define MSG_LABLE_TAG 11

#define MSG_TOAST_TAG 9999

@implementation CustomNotificationView

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithTitle:(NSString*)title{
    self = [[CustomNotificationView alloc] init];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    CGFloat viewWidth = 200;
    CGFloat topSpace = 20;
    UIView* contailer = [[UIView alloc] init];
    contailer.backgroundColor = [UIColor clearColor];
    contailer.layer.cornerRadius = 6;
    contailer.layer.masksToBounds = YES;
    UILabel* msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(topSpace, topSpace, viewWidth - 40, 0)];
    [contailer addSubview:msgLabel];
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.text = title;
    msgLabel.tag = MSG_LABLE_TAG;
    msgLabel.font = [UIFont systemFontOfSize:13];
    msgLabel.numberOfLines = 0;
    [msgLabel sizeToFit];
    msgLabel.frame = CGRectMake( msgLabel.frame.origin.x, msgLabel.frame.origin.y, viewWidth - 40, msgLabel.frame.size.height);
    CGFloat viewHeight = msgLabel.frame.size.height + 40;
    contailer.frame = CGRectMake((SCREEN_WIDTH - viewWidth)/2.0f, (SCREEN_HEIGHT - viewHeight)/2.0f, viewWidth, viewHeight);
    [contailer addSubview:msgLabel];
    UIView* containerBG = [[UIView alloc] initWithFrame:CGRectMake(0,0, viewWidth, viewHeight)];
    containerBG.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.95];
    [contailer insertSubview:containerBG atIndex:0];
    [self addSubview:contailer];
    return self;
}

-(void)changeTitle:(NSString*)title{
    UILabel* msgLable = (UILabel*)[self viewWithTag:MSG_LABLE_TAG];
    if ([msgLable isKindOfClass:[UILabel class]]) {
        msgLable.text = title;
    }
}

-(void)show{
    [self show:nil];
}

-(void)show:(void (^)())block {
    self.alpha = 0;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

-(void)dismiss{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)needAnimation {
    if (needAnimation) {
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else {
        [self removeFromSuperview];
    }
}

+(void)showToast:(NSString*)msg{
    CustomNotificationView* view = [[CustomNotificationView alloc] initWithTitle:msg];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.15];
    view.tag = MSG_TOAST_TAG;
    [view show];
    [view performSelector:@selector(dismiss) withObject:nil afterDelay:2];
}

+(void)showToastWithoutDismiss:(NSString*)msg withTag:(NSInteger)tag {
    CustomNotificationView* view = [[CustomNotificationView alloc] initWithTitle:msg];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.15];
    view.tag = tag;
    [view show];
}

+(void)showToastWithoutDismiss:(NSString *)msg
{
    [self showToastWithoutDismiss:msg withTag:MSG_TOAST_TAG];
}

+(CustomNotificationView *)getToastWithoutDismiss:(NSString *)msg
{
    CustomNotificationView* view = [[CustomNotificationView alloc] initWithTitle:msg];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.15];
    view.tag = MSG_TOAST_TAG;
    return view;
}

+(BOOL)shownToastWithTag:(NSInteger)tag {
    return [[[UIApplication sharedApplication] keyWindow] viewWithTag:tag] != nil;
}

+(void)clearToastWithTag:(NSInteger)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView * view = [[[UIApplication sharedApplication] keyWindow] viewWithTag:tag];
        if (view && view.superview) {
            [view removeFromSuperview];
        }
    });
}

+(void)clearToast{
    [self  clearToastWithTag:MSG_TOAST_TAG];
}

@end
