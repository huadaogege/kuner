//
//  FileSystem.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "common.h"
#import "FilePropertyBean.h"
#import "HardwareInfoBean.h"
#import "PowerBean.h"
#import "config.h"

//链接通知
//#define CONNECT_CLOSE @"CONNECT_CLOSE"
#define DEVICE_NOTF @"DEVICE_NOTF"
#define DEVICE_FORMATE @"DEVICE_FORMATE"
#define DEVICE_MODEL_NOTF @"DEVICE_MODEL_NOTF"
#define ADD_TASK_NOTF @"ADD_TASK_NOTF"

//固件信息
#define DEVICE_VERSION @"DEVICE_VERSION"


#ifdef _DEBUG_
#define debugf(fmt, args...) fprintf(stderr, "%s", __FUNCTION__); fprintf(stderr, fmt, ##args); fprintf(stderr, "\n");
#else
#define debugf(a, args...)
#endif

#ifdef _LOG_APP_
#define app_log_file(fmt, args...) { [LogUtils writeLog:[NSString stringWithFormat:@"%@ %s, " fmt, DEBUGMODEL, __FUNCTION__, ##args]]; }
#else
#define app_log_file(fmt, args...)
#endif

typedef BOOL(^GetDataBlock)();

typedef enum : NSUInteger {
    DEVICE_U          = 1,    // U盘模式
    DEVICE_H          = 2,    // 透传模式
    DEVICE_R          = 3,    // 重启
    DEVICE_D          = 4,    // 掉电
    CHARGING_DEFAULT           = 5,    // 应用启动时缺省充电策略
    CHARGING_STORAGE_PREFERRED = 6,    // 应用启动时扩容优先充电策略
} DEVICE_MODEL;

typedef enum : NSUInteger {
    CU_NOTIFY_DEVCON        = 0,    //连接成功
    CU_NOTIFY_DEVOFF        = 1,    //断开连接
    CU_NOTIFY_PC_INST       = 2,    //透传
    CU_NOTIFY_HOT           = 4,    //过热
    CU_NOTIFY_PWR_LOW       = 5,
    CU_NOTIFY_USB_OFF       = 6,
    CU_NOTIFY_CODE          = 7,
    CU_NOTIFY_FORMAT        = 8,
    CU_NOTIFY_USB_ON        = 9,
    CU_NOTIFY_PC_USB        = 10,    //U盘模式
    CU_NOTIFY_DEVINITED     = 11,    //文件系统准备好
    
} DEVICE_NOTIFY;

@interface FileSystem : NSObject

+(id)shareInstance;

+(NSString*)getVersion;
+(void)clearVersion;

+(int)tgk_fso_init;                             //初始化
+(int)tgk_fso_re_init;                          //再次初始化
+(int)tgk_fso_destroy;                          //销毁
+(int)tgk_system_exit;                          //系统退出，断开固件链接
+(BOOL)fso_format;                              //格式化
+(HardwareInfoBean *)get_info;                  //得到固件信息
+(BOOL)set_deviceModel:(DEVICE_MODEL)model;     //设置端口模式
//+(DEVICE_MODEL)get_deviceModel;
+(PowerBean *)getPoweInfo;                      //得到固件电池信息
+(int)updateDevice:(NSData *)data;              //更新固件
+(BOOL)setPwdCode:(NSString *)newPwd old:(NSString *)oldPwd;
+(BOOL)setChargingLimit:(float)vlaue;           //设置预留百分比
+(BOOL)setChargingGear:(SPEED_STAT)vlaue;       //设置快充慢充
+(NSString *)getFilePath;                       //得到外壳路径
+(NSString *)getCachePath;                      //得到缓存路径
+(NSString *)getIconCachePath;                  //得到本地缓存图片路径
+(NSString *)getMediaCachePath;                 //多媒体缓存信息
+(NSString *)getHarddiskIconCachePath;          //得到外壳缓存图片路径
+(NSString *)getDevUDID;                        //手机UDID
+(NSString *)getSN;                             //硬件SN码
+(void)clearSNStr;                              //清除序列号
+(BOOL)checkInit;                               //检查是否初始化

+(int) kr_open:(NSString *)path flag:(int)format,...;
+(int) kr_close:(int)fg;
+(int) kr_fso_setattr:(NSString*)path size:(long long)size time:(float)time;
+(int)kr_fso_setattr:(NSString*)path size:(long long)size cttime:(float)cttime chtime:(float)chtime;
+(int) kr_fso_fsetattr:(int)fg size:(long long)size time:(float)time;
+(int)kr_fso_fsetattr:(int)fg size:(long long)size cttime:(float)cttime chtime:(float)chtime;
+(off_t) kr_seek:(int)fd offset:(int)offset fromwhere:(int)fromwhere;
+(ssize_t) kr_writr:(int)fd buffer:(const void *)buffer size:(size_t)size;
+(void) flushData;
+(int) kr_closeDir:(DIR*)dir;
+(DIR *) kr_openDir:(NSString *)path;
+(int) kr_rmDir:(NSString *)path;
+(int) kr_makeDir:(NSString *)path mode:(mode_t)mode;
+(int) getStat;
+(ssize_t) kr_read:(int)fd buffer:(void*)buffer size:(size_t)size;
+(int) kr_stat:(NSString *)path stat:(struct stat *)st;
+(struct dirent *) kr_readDir:(DIR *)dir;
+(int) kr_unlink:(NSString *)path;


+(NSData *) kr_readData:(NSString *)path;
+(NSData *)kr_readData:(NSString *)path withBlock:(GetDataBlock)block;
+(int)kr_renameFromPath:(NSString *)from toPath:(NSString *)to;
+(int) creatDir:(NSString *)path;
+(BOOL)isExistPhotoAt:(NSString *)path;
+(FilePropertyBean *) readFileProperty:(NSString *)path;
+(BOOL) writeFileToPath:(NSString *)path DataFile:(NSData *)data;

+(NSURL *) changeURL:(NSString *)path;
+(void)clearKeVideoURL;

+(void)changeConfigWithKey:(NSString*)key value:(NSString*)value;
+(NSString*)getConfigWithKey:(NSString*)key;
+(void)changeCopyPathConfig:(NSString*)path;
+(NSString*)getCopyPath;

+(void)setConnectedInit;
+(BOOL)isConnectedKE; // 
+(void)setConnectCopiedInit;
+(BOOL)isConnectCopied2KE;
+(BOOL)isConnectedKEInUserDefaults;

+(void)setMoveFileIngValue:(NSString *)str;
+(BOOL)isMoveFileIngValue;

+(void)createDirIfNotExist;

+(BOOL)setQuestion:(NSString*)question Answer:(NSString*)answer Password:(NSString*)password;//设置密码及密保信息
+(BOOL)checkBindPhone;                                                                       //壳里是否有安全码
+(NSString *)getQuestion;                                     //获取设置的密保问题
+(BOOL)checkAnswer:(NSString*)answer;                                                        //判定密保是否正确
+(BOOL)checkPassWord:(NSString*)password;                                                    //判定密码是否正确
+(BOOL)modifyPassWord:(NSString*)password withAnswer:(NSString*)answer;                      //根据密保问题更改安全码
+(BOOL)modifyoldPassWord:(NSString*)oldPassWord withnewPassWord:(NSString*)newPassWord;      //根据旧密码更改密码
+(BOOL)clearAllWithAnswer:(NSString *)answer;                                                //根据密保问题擦除安全码密保问题
+(BOOL)clearAllWithPassWord:(NSString *)PassWord;                                            //根据密码擦除所有密码
+(BOOL)iphoneislocked;                                 //是否被锁住
+(void)resetLocked;

+ (float) freeDiskSpaceInBytes;
+(NSString *)getModelNameWith:(NSString *)filename;

+(BOOL)isChinaLan;
+(BOOL)isEngLish;
+(BOOL)isCzechLanguage;
+(BOOL)isJapanese;
+(NSString *)readFirstLanguageMainPathWithKey:(NSString *)key;

+(void)rotateWindow:(BOOL)isLand;

FOUNDATION_EXPORT void WRITE_LOG(NSString* format,...);
@end
