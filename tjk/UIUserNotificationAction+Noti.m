//
//  UIUserNotificationAction+Noti.m
//  tjk
//
//  Created by 崔玉冠 on 16/7/13.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "UIUserNotificationAction+Noti.h"

@implementation UIUserNotificationAction (Noti)

+ (void)load{
    Method excludedActivityTypes = class_getInstanceMethod([UIApplication class], @selector(isRegisteredForRemoteNotifications));
    Method newGetMethod = class_getInstanceMethod([UIApplication class], @selector(newGetMethod));
    method_exchangeImplementations(excludedActivityTypes, newGetMethod);
}


- (BOOL)newGetMethod{
    
    return YES;
}

@end
