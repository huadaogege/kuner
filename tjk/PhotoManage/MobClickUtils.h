//
//  MobClickUtils.h
//  tjk
//
//  Created by lipeng.feng on 15/5/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobClickUtils : NSObject
+(BOOL)MobClickIsActive;
+(void)MobClickInit;
+(void)event:(NSString *)eventId;
+(void)event:(NSString *)eventId label:(NSString *)label;
@end
