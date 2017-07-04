//
//  CustomActivityView.h
//  tjk
//
//  Created by 张旭东 on 14-4-16.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^complent)(BOOL finished);

@interface CustomActivityView : UIView

@property(nonatomic,strong)NSString *message;

+ (id)defaultCheckActivityView;

+ (id)defaultActivityViewWith:(NSString *)message;

- (void)show;

- (void)dismiss;

- (void)dismissWithCompletion:(complent)complentBlock;

- (void)dismissAterDelay:(float)delay WithAnimationed:(BOOL)animationed withComlent:(complent)complentBlock;
+(CustomActivityView *)instance;
@end
