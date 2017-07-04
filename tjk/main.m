//
//  main.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        @try {
           return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
//            NSLog(@"%s\n%@", __FUNCTION__, exception);
            [FileSystem tgk_system_exit];
        }
        @finally {
        }
        
    }
}
