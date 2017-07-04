//
//  AppUpdateUtils.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-4-14.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceRequest.h"
#import "CustomActivityView.h"

//服务器是否有新版本的通知（版本更新）
#define FINDVERSION @"findNewVersion"

//固件更新
#define FINDVERSIONS @"findNewVersions"

//更新是否成功
#define DOWNLOAD_SELF @"downloadSelf"

//下载安装太极是否成功
#define DOWNLOAD_TG @"downloadTg"
#define UPDATE_VERSION @"version"


#define UPDATE_ADDRESS @"http://117.121.11.87:8099/download.php"
#define DOWNLOAD_TG_ADDRESS @"http://117.121.11.87:8099/list.php?t=20141113"//@"http://f_bb.iphonespirit.com/Interface/i_update.php"

#define FWH_UPDATE_ADDRESS @"http://117.121.11.87:8099/download.php?t=app"
#define FWH_DOWNLOAD_TG_ADDRESS @"http://117.121.11.87:8099/download.php?t=firmware"
#define UPDATE_INFO_FLAG @"info"
#define UPDATE_DOWNLOAD_FLAG @"download"
#define SN_NUMBER @"snnumber"


#define UPDATE_INFO @"update_info"
#define DOWNLOAD    @"download"


#define SN_SEND_URL @"http://www.kuke.com.cn/kuke/Sn/index.html"

#define APP_UPDATE_PLIST @"dlplist"
#define APP_VERSION @"appversion"
#define APP_INFO @"appinfo"
#define BIN_UPDATE_PLIST @"dlbin"
#define BIN_VERSION @"binversion"
#define BIN_INFO @"bininfo"
#define BIN_MD5 @"new_fw_md5"
#import "CustomNotificationView.h"


@interface AppUpdateUtils : NSObject<ServiceRequestDelegate>{
    
    NSDictionary            *_downInfoMap;
    
    dispatch_queue_t        _dispatchQueue;
    NSString               *update;
    BOOL                   _isBanben;
    NSDictionary *        weatherDic;
    BOOL isApp;
    BOOL isBin;
    CustomNotificationView * _loadingView;
}

//@property id<UpdateDelegate> updateDelegate;

+(AppUpdateUtils *)instance;

//取消
-(void)cancleRequest;

//检测更新
-(void)checkUpdate:(NSString*)version Url:(NSString *)url;

-(void)checkUpdate;

//执行更新
-(void)updateVersion;

//下载太极
-(void)downloadTg;

//上传SN号

-(void)sendSNnumber;

@end
