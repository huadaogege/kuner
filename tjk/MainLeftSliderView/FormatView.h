//
//  FormatView.h
//  tjk
//
//  Created by huadao on 15/7/3.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "ViewController.h"
#import "YpcCustomProgress.h"

typedef NS_ENUM(NSInteger, FormatStateCode) {
    FormatStateCodeNormal,
    FormatStateCodeKeLocked, // 忘记密码或密保格式化
};

@interface FormatView : UIViewController<NavBarDelegate,YpcCustomProgressDelegate>
{
     CustomNavigationBar * _customNavigationBar;
     dispatch_queue_t                _dispatchQueue;
     YpcCustomProgress                 *_test;
     BOOL                            ret;
    BOOL                             _kunerlost;
    UIButton                         * confirms;
    UIAlertView                      * _failAlert;
    
    //
    FormatStateCode    _stateCode;
}

- (id)initWithState:(FormatStateCode)stateCode;

@end
