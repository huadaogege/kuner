//
//  CustomNotificationView.h
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNotificationView : UIView
+(void)showToast:(NSString*)msg;
+(void)showToastWithoutDismiss:(NSString*)msg withTag:(NSInteger)tag;
+(void)showToastWithoutDismiss:(NSString*)msg;
+(BOOL)shownToastWithTag:(NSInteger)tag;
+(void)clearToastWithTag:(NSInteger)tag;
+(void)clearToast;
-(id)initWithTitle:(NSString*)title;
-(void)changeTitle:(NSString*)title;
-(void)show;
-(void)show:(void (^)())block;
-(void)dismiss;
-(void)dismiss:(BOOL)needAnimation;
+(CustomNotificationView *)getToastWithoutDismiss:(NSString *)msg;
@end
