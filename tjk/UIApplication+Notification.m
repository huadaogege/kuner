//
//  UIApplication+Notification.m
//  tjk
//
//  Created by 崔玉冠 on 16/7/12.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "UIApplication+Notification.h"
#import <objc/runtime.h>
@implementation UIApplication (Notification)


//+ (void)load{
//    Method registerUserNotificationSettings = class_getInstanceMethod([UIApplication class], @selector(registerUserNotificationSettings:));
//    Method newGetMethod = class_getInstanceMethod([UIApplication class], @selector(newGetMethod:));
//    method_exchangeImplementations(registerUserNotificationSettings, newGetMethod);
//    
//    Method excludedActivityTypes = class_getInstanceMethod([UIApplication class], @selector(registerForRemoteNotifications));
//    Method newGetMethod1 = class_getInstanceMethod([UIApplication class], @selector(newGetMethod1));
//    method_exchangeImplementations(excludedActivityTypes, newGetMethod1);
//    
//    Method excludedActivityType = class_getInstanceMethod([UIApplication class], @selector(registerForRemoteNotificationTypes:));
//    Method newGetMethod2 = class_getInstanceMethod([UIApplication class], @selector(newGetMethod2:));
//    method_exchangeImplementations(excludedActivityType, newGetMethod2);
//}

- (void)newGetMethod:(UIUserNotificationSettings *)notificationSettings{
    

}

- (void)newGetMethod1{

}
- (void)newGetMethod2:(UIRemoteNotificationType)types{

}
@end
