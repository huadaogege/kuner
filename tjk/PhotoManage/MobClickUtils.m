//
//  MobClickUtils.m
//  tjk
//
//  Created by lipeng.feng on 15/5/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "MobClickUtils.h"
#import "MobClick.h"
#import "UMOpus.h"
#import "UMFeedback.h"
#import "FileSystem.h"
#import "Reachability.h"

@implementation MobClickUtils


static bool mobActive = NO;
static bool mobActiveInit = NO;

+(BOOL)MobClickIsActive{
    if (!mobActive && !mobActiveInit) {
        mobActiveInit = YES;
        NSString* validStr = [FileSystem getConfigWithKey:@"MobClickIsActive"];
        if (!validStr || !validStr.boolValue) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//            [dateFormatter setCalendar:calendar];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [dateFormatter dateFromString:@START_DATE];
            NSDate* now = [NSDate date];
            NSComparisonResult result = [date compare:now];
            if (result == NSOrderedDescending) {
                if ([Reachability reachabilityWithHostName:@"www.baidu.com"]) {
                    NSString *urlPath = [NSString stringWithFormat:@"%@?time=%ld",@ABOUT_URL,time(0)];
                    NSURL *url = [NSURL URLWithString:urlPath];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
                    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
                    if(data){
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        
                        NSArray *versionarr = [dict objectForKey:@"hv"];
                        if (versionarr) {
                            BOOL hasInArray = NO;
                            for (NSString *resultStr in versionarr) {
                                BOOL isequal = [resultStr isEqualToString:[[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString]];
                                if (isequal) {
                                    hasInArray = YES;
                                    break;
                                }
                            }
                            mobActive = !hasInArray;
                        }
                        else{
                            mobActive = YES;
                        }
                    }
                    
//                    NSString* resultStr = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"result : %@",resultStr);
//                    mobActive = ![resultStr isEqualToString:[[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString]];
                }
                else {
                    mobActive = NO;
                }
            }
            else {
                mobActive = YES;
            }
            
            [FileSystem changeConfigWithKey:@"MobClickIsActive" value:[NSString stringWithFormat:@"%d",mobActive]];
        }
        else {
            mobActive = YES;
        }
    }
    
    return mobActive || FOR_STORE != 1;
}

+(void)MobClickInit {
    if ([self MobClickIsActive]) {
        [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@"App_Store"];
        [UMFeedback setAppkey:UMENG_APPKEY];
        [UMOpus setAudioEnable:YES];
        [MobClick setCrashReportEnabled:YES];
    }
}

+(void)event:(NSString *)eventId {
    if ([self MobClickIsActive]) {
        [MobClick event:eventId];
    }
}


+(void)event:(NSString *)eventId label:(NSString *)label {
    if ([self MobClickIsActive]) {
        [MobClick event:eventId label:label];
    }
}

@end
