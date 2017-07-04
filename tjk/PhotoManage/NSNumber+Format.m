//
//  NSString-Format.m
//  tjk
//
//  Created by lengyue on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "NSNumber+Format.h"

#define K_SIZE 1024.0
#define M_SIZE (1024.0*1024.0)
#define G_SIZE (1024.0*1024.0*1024.0)

#define S_LENGTH (1000000)
#define M_LENGTH (60*1000000)
#define H_LENGTH (60*60*1000000)

@implementation NSNumber (Format)

-(NSString*)sizeString{
    float size = self.floatValue;
    float g = 0;
    float m = 0;
    float k = 0;
    if (size > G_SIZE) {
        g = size / G_SIZE;
    }
    else if (size > M_SIZE) {
        m = size / M_SIZE;;
    }
    else if (size > K_SIZE) {
        k = size / K_SIZE;
    }
    if(g > 1){
        return [NSString stringWithFormat:@"%.2fG",g];
    }
    else if(m > 1){
        return [NSString stringWithFormat:@"%.2fM",m];
    }
    return [NSString stringWithFormat:@"%.2fK",k];
}

-(NSString*)timeString {
    long length = self.longValue;
    NSInteger h = 0;
    NSInteger m = 0;
    NSInteger s = 0;
    if (length > H_LENGTH) {
        h = length / H_LENGTH;
    }
    if ((length % H_LENGTH) > M_LENGTH) {
        m = (length % H_LENGTH) / M_LENGTH;
    }
    if (((length % H_LENGTH) % M_LENGTH) > S_LENGTH) {
        s = ((length % H_LENGTH) % M_LENGTH) / S_LENGTH;
    }
    NSString* hStr = nil;
    NSString* mStr = nil;
    NSString* sStr = nil;
    if(h > 1){
        if(h < 10){
            hStr = [NSString stringWithFormat:@"0%ld",(long)h];
        }
        else {
            hStr = [NSString stringWithFormat:@"%ld",(long)h];
        }
    }
    if(m < 10){
        mStr = [NSString stringWithFormat:@"0%ld",m];
    }
    else {
        mStr = [NSString stringWithFormat:@"%ld",m];
    }
    if(s < 10){
        sStr = [NSString stringWithFormat:@"0%ld",s];
    }
    else {
        sStr = [NSString stringWithFormat:@"%ld",s];
    }
    if (hStr) {
        return [NSString stringWithFormat:@"%@:%@:%@",hStr,mStr,sStr];
    }
    else {
        return [NSString stringWithFormat:@"%@:%@",mStr,sStr];
    }
}

+(BOOL)compare:(NSString*)version1 isBiggerThan:(NSString*)version2 {
    NSArray* verArray1 = [version1 componentsSeparatedByString:@"."];
    NSArray* verArray2 = [version2 componentsSeparatedByString:@"."];
    for (NSInteger i = 0 ; i < verArray1.count ; i ++) {
        NSInteger ver1 = ((NSString*)[verArray1 objectAtIndex:i]).integerValue;
        if (verArray2.count <= i) {
            return YES;
        }
        else {
            NSInteger ver2 = ((NSString*)[verArray2 objectAtIndex:i]).integerValue;
            if (ver1 > ver2) {
                return YES;
            }
            else if (ver1 < ver2) {
                return NO;
            }
            else if(i == (verArray1.count - 1) && i < (verArray2.count - 1)){
                return NO;
            }
        }
    }
    return NO;
}

@end
