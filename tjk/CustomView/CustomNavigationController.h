//
//  CustomNavigationController.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14/12/12.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (assign) BOOL isCanGesture;

@end
