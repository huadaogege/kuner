//
//  NSString-Format.h
//  tjk
//
//  Created by lengyue on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Format)
-(NSString*)sizeString;
-(NSString*)timeString;
+(BOOL)compare:(NSString*)version1 isBiggerThan:(NSString*)version2;
@end
