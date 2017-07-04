//
//  PrivateViewController.h
//  tjk
//
//  Created by lengyue on 15/4/17.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBackDelegate.h"

typedef NS_ENUM(NSInteger, DiscriptionType) {
    DiscriptionTypePrivacyNote, // 隐私说明
    DiscriptionTypeKUKEDisc, // 酷壳说明
};

@interface PrivateViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIScrollView* scrollview;
@property (nonatomic,assign) id<UIBackDelegate> backDelegate;

@property (nonatomic, assign)  DiscriptionType discType;

@end
