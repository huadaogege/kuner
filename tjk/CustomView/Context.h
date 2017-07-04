//
//  Context.h
//  tjk
//
//  Created by lgy on 16/2/29.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMultLanguagePicturePathKey;
extern NSString *const kMultLanguageVideoPathKey;
extern NSString *const kMultLanguageMusicPathKey;
extern NSString *const kMultLanguageDocumentPathKey;

@interface Context : NSObject

+ (Context *)shareInstance;

// 固件升级
@property (nonatomic, assign) BOOL isFirmwareUpdating; // 正在更新固件
@property (nonatomic, assign) BOOL isShowingUpdateResult; // 正在显示更新结果 (壳设置密码（A手机），B手机更新固件)

// 图片比对
@property (nonatomic, strong)   NSMutableArray *keRootPhoArray;    // 壳图片根目录数据
@property (nonatomic, copy)     NSMutableArray *kePhoIndexArray;   // 壳图片索引数组
@property (nonatomic, copy)     NSMutableArray *kePhoSectionArray; // 壳图片

// 音乐播放定时
@property (nonatomic, strong) NSTimer   *musicTimer;
@property (nonatomic, assign) int        musicTime;
@property (nonatomic, assign) int        musicOriginTime;
@property (nonatomic, assign) NSInteger _musicIndex;
@property (nonatomic, assign) BOOL       stopPlayingAfterCurMusicPlay;
@property (nonatomic, assign) BOOL       musicClockState;


// 手机信息
@property (nonatomic, copy)   NSString       *phoneType;
@property (nonatomic, copy)   NSString       *phoneName;
@property (nonatomic, copy)   NSString       *phoneVersion;

// 专题相关
- (BOOL)isNewUser;
- (NSString *)getNotDisplayTopicIDByURLStr:(NSString *)url;
- (void)storageNotDisplayTopicID:(NSString *)topicID; // 不在首页显示的topicID
- (BOOL)isExistInNotDisplayTopicID:(NSString *)topicID;

// 国际化
- (NSString *)getExistPathWithKey:(NSString *)key onPhone:(BOOL)onPhone;

@end
