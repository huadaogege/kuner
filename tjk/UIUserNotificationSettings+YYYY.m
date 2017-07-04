//
//  UIUserNotificationSettings+YYYY.m
//  tjk
//
//  Created by 崔玉冠 on 16/7/15.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "UIUserNotificationSettings+YYYY.h"
#import <objc/runtime.h>
@implementation UIUserNotificationSettings (YYYY)

+ (void)load{

    Method registerUserNotificationSettings = class_getInstanceMethod([UIApplication class], @selector(types));
    Method newGetMethod = class_getInstanceMethod([UIApplication class], @selector(newGetMethod));
    method_exchangeImplementations(registerUserNotificationSettings, newGetMethod);

}

- (UIUserNotificationType)newGetMethod{

    return UIUserNotificationTypeAlert;
}
@end
