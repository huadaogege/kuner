//
//  CustomEditAlertView.h
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomEditAlertViewDelegate <NSObject>

-(void)alertViewButtonClickedAt:(NSInteger)index withText:(NSString*)text;

@end

@interface CustomEditAlertView : UIView
@property(nonatomic,assign)id<CustomEditAlertViewDelegate> delegate;
-(id)initWithTitle:(NSString*)title message:(NSString*)msg defaultLabel:(NSString*)defaultStr;
-(void)show:(UIView*)rootView;
@end
