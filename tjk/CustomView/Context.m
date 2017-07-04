//
//  Context.m
//  tjk
//
//  Created by lgy on 16/2/29.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "Context.h"

static Context  *context = nil;
static NSString *kTopicPath = nil;

NSString *const kMultLanguagePicturePathKey  = @"multiLang_picturePath";
NSString *const kMultLanguageVideoPathKey    = @"multiLang_videoPath";
NSString *const kMultLanguageMusicPathKey    = @"multiLang_musicPath";
NSString *const kMultLanguageDocumentPathKey = @"multiLang_documentPath";

NSString *multLanguageFileName = @"allLanguageCollection";
NSArray  *_multLanguageArr;

static NSString       *kUserDateKey    = @"kNewUserFirstStoredDateKey";
static NSString       *kOldUserKey     = @"kOldUserKey";
static NSTimeInterval  kThreeDays = 3600*24*3;

@implementation Context

+ (Context *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[Context alloc] init];
    });
    
    return context;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

#pragma mark - Interface

- (BOOL)isNewUser
{ // 前3天为新用户
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isOldUser = [[userDefault objectForKey:kOldUserKey] boolValue];
    if (!isOldUser) {
        NSDate *nowDate = [NSDate date];
        NSDate *storedDate = [userDefault objectForKey:kUserDateKey];
        if (!storedDate) {
            storedDate = nowDate;
            [userDefault setValue:nowDate forKey:kUserDateKey];
        }
        
        NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:storedDate];
        if (timeInterval>kThreeDays) {
            isOldUser = YES;
            [userDefault setValue:[NSNumber numberWithBool:isOldUser] forKey:kOldUserKey];
        }
    }
    
    return !isOldUser;
}

- (NSString *)getNotDisplayTopicIDByURLStr:(NSString *)url
{ // 不再首页显示的topID
    NSString *topID = @"";
    
    NSRange range = [url rangeOfString:@"kuke://topic_"];
    if (range.length>0) {
        topID = [url substringFromIndex:range.location+range.length];
    }
    
    return topID;
}

- (void)storageNotDisplayTopicID:(NSString *)topicID
{
    if (topicID.length > 0) {
        @synchronized (self) {
            NSString *topicPath = [self getPathOfTopicID];
            NSMutableArray *topicIDs = [NSMutableArray arrayWithContentsOfFile:topicPath];
            if (topicIDs==nil) {
                topicIDs = [[NSMutableArray alloc] init];
            }
            
            if (![self isExistInNotDisplayTopicID:topicID]) {
                [topicIDs addObject:topicID];
                [topicIDs writeToFile:topicPath atomically:YES];
            }
        }
    }
}

- (BOOL)isExistInNotDisplayTopicID:(NSString *)topicID
{
    if (topicID.length>0) {
        NSString *topicPath = [self getPathOfTopicID];
        NSArray  *topicArr  = [NSArray arrayWithContentsOfFile:topicPath];
        
        return [topicArr containsObject:topicID];
    }
    
    return NO;
}

- (NSString *)getExistPathWithKey:(NSString *)key onPhone:(BOOL)onPhone
{
    NSLog(@"getExistPathWithKey:%@ onPhone:%d",key,onPhone);
    [self initMLanguage];
    
    NSString *rootPath = onPhone?APP_DOC_ROOT:KE_ROOT;
    
    for (NSDictionary *lanDic in _multLanguageArr) {
        NSString *dirName = lanDic[key];
        NSString *dirPath = [rootPath stringByAppendingPathComponent:dirName];
        if ([FileSystem readFileProperty:dirPath]) {
            return dirPath;
        }
    }
    
    return nil;
}

- (NSString *)curDirNameWithKey:(NSString *)key
{
    if ([key isEqualToString:kMultLanguagePicturePathKey]) {
        return NSLocalizedString(@"picture", @"");
    }
    else if ([key isEqualToString:kMultLanguageVideoPathKey]){
        return NSLocalizedString(@"video", @"");
    }
    else if ([key isEqualToString:kMultLanguageMusicPathKey]){
        return NSLocalizedString(@"music", @"");
    }
    else if ([key isEqualToString:kMultLanguageDocumentPathKey]){
        return NSLocalizedString(@"document", @"");
    }
    
    return @"";
}


#pragma mark - private

- (NSString *)getPathOfTopicID
{
    if (!kTopicPath) {
        NSString *component = [DESUtils getMD5:@"TopicID"];
        NSString *fileName  = [DESUtils getMD5:@"notDisplay.kuke"];
        NSString *tailPath  = [APP_LIB_ROOT stringByAppendingPathComponent:component];
        kTopicPath = [tailPath stringByAppendingFormat:@"/%@",fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:tailPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tailPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return kTopicPath;
}

- (void)initMLanguage
{
    if (_multLanguageArr) {
        return ;
    }
    
    // 找到动态获取国际化文件中的字段后（代替当前初始化）
    // 简体中文
    NSDictionary *chLanDic = @{kMultLanguagePicturePathKey:@"图片",
                               kMultLanguageVideoPathKey:@"视频",
                               kMultLanguageMusicPathKey:@"音乐",
                               kMultLanguageDocumentPathKey:@"文档"};
    // 繁体中文
    NSDictionary *traLanDic = @{kMultLanguagePicturePathKey:@"圖片",
                                kMultLanguageVideoPathKey:@"影片",
                                kMultLanguageMusicPathKey:@"音樂",
                                kMultLanguageDocumentPathKey:@"文檔"};
    // 英文
    NSDictionary *enLanDic = @{kMultLanguagePicturePathKey:@"Photos",
                               kMultLanguageVideoPathKey:@"Videos",
                               kMultLanguageMusicPathKey:@"Musics",
                               kMultLanguageDocumentPathKey:@"Documents"};
    // 捷克语
    NSDictionary *csLanDic = @{kMultLanguagePicturePathKey:@"Fotky",
                               kMultLanguageVideoPathKey:@"Videa",
                               kMultLanguageMusicPathKey:@"Hudba",
                               kMultLanguageDocumentPathKey:@"Dokumenty"};
    // 日语
    NSDictionary *jaLanDic = @{kMultLanguagePicturePathKey:@"写真",
                               kMultLanguageVideoPathKey:@"映像",
                               kMultLanguageMusicPathKey:@"音楽",
                               kMultLanguageDocumentPathKey:@"書類"};
    
    _multLanguageArr = @[chLanDic,traLanDic,enLanDic,csLanDic,jaLanDic];
}


@end
