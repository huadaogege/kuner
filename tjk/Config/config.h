//
//  config.h
//  tjk
//
//  Created by liull on 14-3-25.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#ifndef tjk_config_h
#define tjk_config_h


#define IS_TAIG YES
#define VERSION [[[UIDevice currentDevice] systemVersion] intValue]
#define TIME_NUMBER 86400.0

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width


#define XX [UIScreen mainScreen].bounds.size.width / 320.0

#define VIDEO_EX_ARY [NSArray arrayWithObjects:@"mp4",@"rmvb",@"avi",@"flv",@"wmv",@"mov",@"ts",@"rm",@"3gp",@"mtk",@"drc",@"dsm",@"dsv",@"dsa",@"dss",@"vob",@"ifo",@"d2v",@"fli",@"flc",@"flic",@"ivf",@"mkv",@"mpg",@"mpeg",@"mpe",@"m1v",@"m2v",@"mpv2",@"mp2v",@"dat",@"ts",@"tp",@"tpr",@"m4v",@"pss",@"m4p",@"m4b",@"ogm",@"mov",@"qt",@"amr",@"3gpp",@"3g2",@"3gp2",@"ratdvd",@"rt",@"rp",@"smi",@"smil",nil]

#define VIDEO_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"m3u8", @"1", @"mp4", @"1", @"rmvb", @"1", @"avi", @"1", @"flv", @"1", @"wmv", @"1", @"ts", @"1", @"rm", @"1", @"3gp", @"1", @"mtk", @"1", @"dsm", @"1", @"dsv", @"1", @"dsa", @"1", @"dss", @"1", @"vob", @"1", @"ifo", @"1", @"d2v", @"1", @"fli", @"1", @"flc", @"1", @"flic", @"1", @"ivf", @"1", @"mkv", @"1", @"mpg", @"1", @"mpeg", @"1", @"mpe", @"1", @"m1v", @"1", @"m2v", @"1", @"mpv2", @"1", @"mp2v", @"1", @"dat", @"1", @"ts", @"1", @"tp", @"1", @"tpr", @"1", @"m4v", @"1", @"m4p", @"1",@"m4b", @"1", @"ogm", @"1", @"mov", @"1", @"qt", @"1", @"amr", @"1", @"3gpp", @"1", @"3g2", @"1", @"3gp2", @"1", @"rt", @"1", @"rp", @"1", @"smi", @"1", @"smil",nil]

#define MUSIC_EX_ARY [NSArray arrayWithObjects:@"m4a",@"mka",@"mp3", @"aac",@"wma",@"1128",@"tm3",@"m4a",nil]

#define MUSIC_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"m4a",@"1",@"mka",@"1",@"mp3",@"1",@"aac",@"1",@"wma",@"1",@"1128",@"1",@"tm3",@"1",@"m4a",@"1",@"tm0",@"1",@"tm6",nil]

#define PICTURE_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"bmp",@"1",@"gif",@"1",@"jpeg",@"1",@"tiff",@"1",@"psd",@"1",@"png",@"1",@"svg",@"1",@"ico",@"1",@"jpg",@"1",@"mov",@"1",@"mp4",nil]

#define DEVICE_VIDEO_APP_LIST [[NSArray alloc] initWithObjects:\
@"com.youku.YouKu",\
@"com.qiyi.iphone",\
@"com.tencent.live4iphone",\
@"com.sohu.iPhoneVideo",\
@"com.baofengyingyin.iphoneversion",\
@"com.tudou.tudouiphone",\
@"com.baidu.videoiphone",\
@"com.baidu.netdisk",\
@"com.snda.show",\
@"com.axiao.videoIPad",\
@"com.xunlei.XLVideoPhone",\
@"com.xunlei.xunleikankan.iphone",\
@"com.pptv.iphoneapp",\
@"com.hunantv.imgotv",\
@"in.huohua.Yuki",\
@"com.56.video",\
@"com.pps.test",\
@"com.qihoo.video",\
@"com.speedvideo.chaogaoqingyingshinew",\
@"com.letv.iphone.client",\
@"tv.danmaku.bilianime",\
@"com.yanzhen.lscsvideo",\
@"com.yanzhen.lolvideo",\
@"com.jianheng.dota2video",\
nil]

#define DEVICE_VIDEO_APP_PATH [[NSDictionary alloc] initWithObjectsAndKeys:\
 @"/Documents",                                   @"com.youku.YouKu",\
 @"/Library/.download/mp4",                       @"com.qiyi.iphone",\
 @"/Documents/Caches/Media",                      @"com.tencent.live4iphone",\
 @"/Library/PrivateDocuments/download",           @"com.sohu.iPhoneVideo",\
 @"/Library/BFData/Cache/Media",                  @"com.baofengyingyin.iphoneversion",\
 @"/Documents/Download",                          @"com.tudou.tudouiphone",\
 @"/Documents/Downloads",                         @"com.baidu.videoiphone",\
 @"/Documents",                                   @"com.baidu.netdisk",\
 @"/Library/Caches/.Ku6M3U8PlayerMovie",          @"com.snda.show",\
 @"/Library/Caches",                              @"com.axiao.video",\
 @"/Documents/cloudspaceHD/TDdownload/",          @"com.xunlei.XLVideoPhone",\
 @"/Documents/.config/TDDownload",                @"com.xunlei.xunleikankan.iphone",\
 @"/Library/com.innodaddy.video.download",        @"com.pptv.iphoneapp",\
 @"/Documents/DownLoad/Movie",                    @"com.hunantv.imgotv",\
 @"/Library/Application Support/in.huohua.Yuki",  @"in.huohua.Yuki",\
 @"/Documents/DownloadFinished",                  @"com.56.video",\
 @"/Library/MovieDownload",                       @"com.pps.test",\
 @"/Documents/taskaf",                            @"com.qihoo.video",\
 @"/Documents/PPTV",                              @"com.pptv.iphoneapp",\
 @"/Library/Caches/DownloadVideo",                @"com.speedvideo.chaogaoqingyingshinew",\
 @"/Library/Application Support/cacheMovie",      @"com.letv.iphone.client",\
 @"/Library/Downloads/av/",                       @"tv.danmaku.bilianime",\
 @"/Documents/videopath",                         @"com.yanzhen.lscsvideo",\
 @"/Documents/videopath",                         @"com.yanzhen.lolvideo",\
 @"/Documents/videopath",                         @"com.jianheng.dota2video",\
 nil]

#define DEVICE_MUSIC_APP_LIST [[NSArray alloc] initWithObjects:\
@"com.kugou.kugou1002",\
@"com.kuwo.KuwoTingting",\
@"com.ttpod.china",\
@"com.xiami.spark",\
@"com.baidu.TingIPhone",\
@"com.netease.cloudmusic",\
@"com.migu.migumobilemusic",\
@"com.9sky.aimuyt",\
@"com.duomi.duomimusic",\
@"com.360buy.lemusic",\
@"com.5sing.5sing",\
@"com.51vv.mvbox",\
nil]

#define DEVICE_MUSIC_APP_PATH [[NSDictionary alloc] initWithObjectsAndKeys:\
@"/Documents/kgmusic",                          @"com.kugou.kugou1002",\
@"/Documents/Download/Music",                   @"com.kuwo.KuwoTingting",\
@"/Documents/.Download",                         @"com.ttpod.china",\
@"/Documents/offlineSongs/",                    @"com.xiami.spark",\
@"/Documents/Downloaded",                       @"com.baidu.TingIPhone",\
@"/Documents/UserData/Download/done",           @"com.netease.cloudmusic",\
@"/Documents/MMDownload",                       @"com.migu.migumobilemusic",\
@"/Library/Caches/com.nickcheng.NCMusicEngine", @"com.9sky.aimuyt",\
@"/Library/duomidata/sdkroot/download",         @"com.duomi.duomimusic",\
@"/Library/Application Support/Root/Musics",    @"com.360buy.lemusic",\
@"/Documents/songdown",                         @"com.5sing.5sing",\
@"/Documents/DownLoadSongs",                    @"com.51vv.mvbox",\
nil]



#define BACKGROUND_COLOR [UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]

#define BASE_COLOR [UIColor colorWithRed:66.0/255.0 green:71.0/255.0 blue:79.0/255.0 alpha:1.0]

#define SIZE_COLOR_PHOTO  [UIColor colorWithRed:84.0/255.0 green:213.0/255.0 blue:189.0/255.0 alpha:1.0]
#define SIZE_COLOR_VIDEO  [UIColor colorWithRed:254.0/255.0 green:194.0/255.0 blue:59.0/255.0 alpha:1.0]
#define SIZE_COLOR_MUSIC  [UIColor colorWithRed:48.0/255.0 green:166.0/255.0 blue:211.0/255.0 alpha:1.0]
#define SIZE_COLOR_FILE  [UIColor colorWithRed:149.0/255.0 green:195.0/255.0 blue:229.0/255.0 alpha:1.0]
#define SIZE_COLOR_EMPTY  [UIColor colorWithRed:226.0/255.0 green:227.0/255.0 blue:229.0/255.0 alpha:1.0]

#define PLAY_VIDEO_NOTF @"PLAY_VIDEO_NOTF"

#define SYSTEM_PLAY_NEXT_ITEM   @"SYSTEM_PLAY_NEXT_ITEM"
#define SYSTEM_PLAY_PRIVIOUS_ITEM @"SYSTEM_PLAY_PRIVIOUS_ITEM"
#define SYSTEM_PLAY  @"SYSTEM_PLAY"
#define SYSTEM_PAUSE @"SYSTEM_PAUSE"
#define SYSTEM_STOP  @"SYSTEM_STOP"

//当获取到模块文件数量后, 发送通知告诉主界面
#define GET_FLIE_COUNT_NOTF @"TgkGetFileCountNotf"
#define FILE_COUNT @"TgkGetFileCount"
#define FILE_KIND @"TgkGetFileKind"

//设置的配置信息

////程序是否安装在设备上
//#define k_SET_SAVE_PROGRAM_ISlOCAL @"k_SET_SAVE_PROGRAM_ISlOCAL"
////图片是否保存到设备上
//#define k_SET_SAVE_PHOTO_ISLOCAL  @"k_SET_SAVE_PHOTO_ISLOCAL"
////视频是否保存到设备上
//#define k_SET_SAVE_VIEO_ISLOCAL @"k_SET_SAVE_VIEO_ISLOCAL"
//// 连接PC时是够是一直提示的key
//#define k_SET_TIP_ISON     @"k_SET_TIP_ON"
//设置的配置文件
#define SEETINGINFO_PATH ([[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"settinginfo.plist"])

typedef enum  {
    
    IMAGE_KIND = 0,
    VIDEO_KIND = 1,
    MUSIC_KIND = 2,
    DOC_KIND = 3,
    APP_KIND = 4,
    OTHER_KIND = 5
    
}KIND_NAME;


#define RECORD_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/file.plist"]
#define RECORD_PATHS [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/files.plist"]

//顶部的蓝色
#define BlueColor [UIColor colorWithRed:33.0/255.0 green:140.0/255.0 blue:206.0/255.0 alpha:1.0]

//外壳路径
#define FILE_PATH [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]




//////////////////////////

#define DEFINE_SINGLETON_FOR_HEADER(className) \
    \
+ (className *)shared##className;


#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

#define CUSTOM_BACKBTN NSLog(@"1");

#define CUSTOM_BACKACTION \
-(void)back{\
    [self.navigationController popViewControllerAnimated:YES];\
}

#endif
