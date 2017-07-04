//
//  PhoneInformantion.h
//  tjk
//
//  Created by huadao on 16/4/1.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBackDelegate.h"
#import "CustomNavigationBar.h"
@interface PhoneInformantion : UIViewController<NavBarDelegate>{

    CustomNavigationBar * _customNavigationBar;
    double availRAM ;
    double totalRAM ;
    double percentage;
    int    iphone;
    NSTimer * timer;
}

@property (nonatomic,assign) id<UIBackDelegate> backDelegate;
@end
