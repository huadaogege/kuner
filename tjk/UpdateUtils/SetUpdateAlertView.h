//
//  SetUpdateAlertView.h
//  tjk
//
//  Created by 张旭东 on 14-4-16.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completion) (void);

@class SetUpdateAlertView;
@protocol SetUpdateAlertViewDelegate <NSObject>

- (void)setUpdateAlertView:(SetUpdateAlertView *)alertView clickedAtIndex:(NSUInteger)index; 

@end

@interface SetUpdateAlertView : UIView<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    NSString *updateVerson;
    NSString * downloadplist;
    NSString * binversion;
    BOOL isBanben;
    BOOL isapp;
}

@property(nonatomic,assign)id<SetUpdateAlertViewDelegate> delegate;
+(SetUpdateAlertView *)instance;
- (id)initWithUpdateMessage:(NSString *)updateMessage downloadplist:(NSString *)downplist version:(NSString*)version isApp:(BOOL)isApp;

- (id)initWithUpdateErrorMessage:(NSString *)updateMessage;

- (void)show;

- (void)dismiss;

- (void)dismissWithCompletion:(completion)completionBlock;

@end
