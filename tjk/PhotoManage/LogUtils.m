//
//  LogUtils.m
//  tjk
//
//  Created by lengyue on 15/4/14.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "LogUtils.h"

@interface LogUtils ()
@property(nonatomic,retain) NSMutableArray* logArray;
@end

@implementation LogUtils


static bool isWritinglog = NO;

+(LogUtils*)shareInstance{
    static LogUtils * utils = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        utils = [[LogUtils alloc] init];
        utils.logArray = [[NSMutableArray alloc]init];
        isWritinglog = NO;
    });
    return utils;
}

+(void)writeLog:(NSString*)logStrParameter{
    [self writeLog:logStrParameter fileName:@"log"];
}

+(void)writeLog:(NSString*)logStrParameter fileName:(NSString*)fileName{
    if (IS_DEBUG && logStrParameter) {
//        if (![logStrParameter hasPrefix:DEBUGMODEL]) {
//            return;
//        }
//        NSDate* date = [NSDate date];
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
//        NSInteger interval = [zone secondsFromGMTForDate: date];
//        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
//        
//        NSString* dateStr = [NSString stringWithFormat:@"%@",localeDate];
//        dateStr = [dateStr substringToIndex:[dateStr rangeOfString:@" "].location];
//        NSString* logDir = [NSString stringWithFormat:@"%@/Log",APP_DOC_ROOT];
//        NSFileManager* fm = [NSFileManager defaultManager] ;
//        if (![[NSFileManager defaultManager] fileExistsAtPath:logDir]) {
//            [fm createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        NSString* logPath = [NSString stringWithFormat:@"%@/%@-%@.txt",logDir,fileName,dateStr];//\n
//        NSDictionary * attributes = [fm attributesOfItemAtPath:logPath error:nil];
//        
//        // file size
//        NSNumber *theFileSize = attributes ? [attributes objectForKey:NSFileSize] : nil;
//        if ([theFileSize intValue] >= 150*1024) {
//            [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
//        }
//        NSString* logStr = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
//        if (!logStr) {
//            logStr = @"";
//        }
//        logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@"\n%@ ::: %@",localeDate,logStrParameter]];
//        NSError* error = nil;
//        [logStr writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//        if (error) {
//            <#statements#>
//        }
        NSMutableArray* logArray = [self shareInstance].logArray;
        NSDictionary* logInfo = [NSDictionary dictionaryWithObjectsAndKeys:logStrParameter,@"logStrParameter",fileName,@"fileName", nil];
        [logArray addObject:logInfo];
        if (!isWritinglog) {
            isWritinglog = YES;
            [[LogUtils shareInstance] doWriteLog];
            
        }
    }
}

-(void)doWriteLog{
    NSMutableArray* logArray = [LogUtils shareInstance].logArray;
    NSInteger count = logArray.count;
    if (count > 0) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
        [NSThread detachNewThreadSelector:@selector(writeLogThread:) toTarget:self withObject:dict];
    }
    else {
        isWritinglog = NO;
    }
    
}

-(void)writeLogThread:(NSDictionary*)logDict{
    NSNumber* count = [logDict objectForKey:@"count"];
    NSMutableArray* logArray = [LogUtils shareInstance].logArray;
    NSDate* date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString* dateStr = [NSString stringWithFormat:@"%@",localeDate];
    dateStr = [dateStr substringToIndex:[dateStr rangeOfString:@" "].location];
    NSString* logDir = [NSString stringWithFormat:@"%@/Log",APP_DOC_ROOT];
    NSFileManager* fm = [NSFileManager defaultManager] ;
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDir]) {
        [fm createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* logPath = [NSString stringWithFormat:@"%@/%@-%@.txt",logDir,@"log",dateStr];//\n
    NSDictionary * attributes = [fm attributesOfItemAtPath:logPath error:nil];
    
    // file size
    NSNumber *theFileSize = attributes ? [attributes objectForKey:NSFileSize] : nil;
    if ([theFileSize intValue] >= 150*1024) {
        [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
    }
    NSString* logStr = [[NSString alloc] initWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray* tmp = [NSMutableArray array];
    for (NSInteger i = 0; i < count.integerValue; i ++) {
        NSDictionary* logInfo = [logArray objectAtIndex:i];
        NSString* logStrParameter = [logInfo objectForKey:@"logStrParameter"];
        //                NSString* fileName = [logInfo objectForKey:@"fileName"];
        if (logInfo && ![logStrParameter hasPrefix:DEBUGMODEL]) {
            [tmp addObject:logInfo];
            continue;
        }
        if (!logStr) {
            logStr = @"";
        }
        logStr = [logStr stringByAppendingString:[NSString stringWithFormat:@"\n%@ ::: %@",localeDate,logStrParameter]];
        [tmp addObject:logInfo];
    }
    [logStr writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    logStr = nil;
    [logArray removeObjectsInArray:tmp];
    [[LogUtils shareInstance] performSelectorOnMainThread:@selector(doWriteLog) withObject:nil waitUntilDone:NO];
}

-(void)dealloc {
    NSLog(@"LogUtils dealloc");
}

@end
