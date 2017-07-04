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
#define IS_DEBUG 0
#define START_DATE "2016-05-20 00:00:00" // 屏蔽开关日期(公历时间)
#define ABOUT_URL "https://app.kuke.com.cn/about.html" // 屏蔽开关

#define IS_USEDEFAULTPLAYER 1
#define FOR_STORE 1
#define IS_SHOWOTHER_LANGUAGE 1

#define RW_BUFFER_SIZE 512*1024
#define DEBUGMODEL @"DEBUGMODEL"
#define DOWNLOAD_LOG_TAG @"DOWNLOAD_LOG_TAG"

//#define _USE_VT_
//#define _DEBUG_
//#define _LOG_APP_
//#define _ERROR_CODE_TEST_

//#define TEST_SERVER_ADDRESS
#ifndef TEST_SERVER_ADDRESS

#define RESOURCE_DOWNLOAD_URL         @"http://www.kuke.com.cn/kuke/index/videoSource112.html"
#define RESOURCE_DOWNLOAD_ANALYZE_URL @"http://www.kuke.com.cn/kuke/vedio/analyze.html"
#define BAIDUYUN_DOWNLOAD_ANALYZE_URL @"http://www.kuke.com.cn/kuke/YunPan/analyze"
#define KUKE_TOPIC_LIST_URL           @"http://www.kuke.com.cn/kuke/topic/index.html"
#define KUKE_TOPIC_REQ_URL            @"http://www.kuke.com.cn/kuke/topic/api.html"

#define UPDATE_URL                    @"http://www.kuke.com.cn/kuke/kuke.html"
#define GUJIAN_UPDATE_URL             @"http://www.kuke.com.cn/kuke/firmware/upgrade.html"

#define KUKE_OFFICIAL_MALL_URL        @"http://www.kuner.com.cn"

#else

#define RESOURCE_DOWNLOAD_URL         @"http://192.168.12.248:83/kuke/index/videoSource112.html"
#define RESOURCE_DOWNLOAD_ANALYZE_URL @"http://192.168.12.248:83/kuke/vedio/analyze.html"
#define BAIDUYUN_DOWNLOAD_ANALYZE_URL @"http://192.168.12.248:83/kuke/YunPan/analyze"
#define KUKE_TOPIC_LIST_URL           @"http://192.168.12.248:83/kuke/topic/index.html"
#define KUKE_TOPIC_REQ_URL            @"http://192.168.12.248:83/kuke/topic/api.html"

#define UPDATE_URL                    @"http://192.168.12.248:83/kuke/kuke.html"
#define GUJIAN_UPDATE_URL             @"http://192.168.12.248:83/kuke/firmware/upgrade.html"

#define KUKE_OFFICIAL_MALL_URL        @"http://www.kuner.com.cn"

#endif

#pragma mark 宏

#define ENTERPW_FOR_UPDATE         @"enterPasswordForUpdate"   // 更新加密酷壳的固件，输入密码更新通知
#define COPYTPFILE_TO_KUKE         @"copyThirdPartyFileToKuke" // copy文件(第三方app内的)到酷壳(文档/下载的文档)
#define FILE_OPERATION_CANCEL      @"fileOperateCancel"
#define DOWNLOADING_TASK_PAUSEALL  @"allDownloadingTaskPause"  // 所有的下载任务都暂停
#define TIME_TO_STOPPLAY           @"Itistimetostopplay"       // 定时音乐停止播放
#define REFRESH_SETTING_MUSICTIMER @"refreshSettingMusicTimer" // 定时UI刷新

#pragma mark 宏-end

#define BASE_COLOR [UIColor colorWithRed:40.0/255.0 green:42.0/255.0 blue:52.0/255.0 alpha:1.0]
#define TOP_MENU_COLOR [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
#define MENU_DELETE_RED [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:70.0/255.0 alpha:1.0]

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)

#define VERSION [[[UIDevice currentDevice] systemVersion] intValue]
#define TIME_NUMBER 86400.0
#define IS_IPHONE6 SCREEN_WIDTH > 320

#define NAME_ERROR_CODE [[NSArray alloc] initWithObjects: @"/",@"\\",@":",@"*",@"?",@"\"",@"<",@">",@"|", nil]
#define KAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"//限制输入只有英文和数字

#define WINDOW_SCALE SCREEN_WIDTH / 320.0
#define WINDOW_SCALE_SIX SCREEN_WIDTH / 375.0

#define APP_DOC_ROOT         [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]
#define APP_LIB_ROOT         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0]
#define PHONE_PHOTO          [APP_DOC_ROOT stringByAppendingPathComponent:NSLocalizedString(@"picture", @"")]
#define PHONE_VIDEO          [APP_DOC_ROOT stringByAppendingPathComponent:NSLocalizedString(@"video", @"")]
#define PHONE_MUSIC          [APP_DOC_ROOT stringByAppendingPathComponent:NSLocalizedString(@"music", @"")]
#define PHONE_DOC            [APP_DOC_ROOT stringByAppendingPathComponent:NSLocalizedString(@"document", @"")]

#define PHONE_VIDEO_DOWNLOAD_VIDEO         [NSString stringWithFormat:@"%@/%@",PHONE_VIDEO,NSLocalizedString(@"downloadvideopath", @"")]
#define PHONE_AUDIO_DOWNLOAD_AUDIO         [NSString stringWithFormat:@"%@/%@",PHONE_MUSIC,NSLocalizedString(@"downloadaudiopath", @"")]
#define PHONE_AUDIO_DOWNLOAD_PICTURE         [NSString stringWithFormat:@"%@/%@",PHONE_PHOTO,NSLocalizedString(@"downloadpicturepath", @"")]
#define PHONE_AUDIO_DOWNLOAD_DOCUMENT         [NSString stringWithFormat:@"%@/%@",PHONE_DOC,NSLocalizedString(@"downloaddocumentpath", @"")]

#define RealDownloadVideoPath (![FileSystem isConnectedKE]? PHONE_VIDEO_DOWNLOAD_VIDEO :KE_DOWNLOAD_VIDEO)
#define RealDownloadAudioPath (![FileSystem isConnectedKE]? PHONE_AUDIO_DOWNLOAD_AUDIO :KE_DOWNLOAD_AUDIO)
#define RealDownloadPicturePath (![FileSystem isConnectedKE]? PHONE_AUDIO_DOWNLOAD_PICTURE :KE_DOWNLOAD_PICTURE)
#define RealDownloadDocumentPath (![FileSystem isConnectedKE]? PHONE_AUDIO_DOWNLOAD_DOCUMENT :KE_DOWNLOAD_DOCUMENT)

#define KE_PHOTO          [NSString stringWithFormat:@"/%@",[[FileSystem getFilePath] stringByAppendingPathComponent:NSLocalizedString(@"picture", @"")]]
#define KE_VIDEO          [NSString stringWithFormat:@"/%@",[[FileSystem getFilePath] stringByAppendingPathComponent:NSLocalizedString(@"video", @"")]]
#define KE_MUSIC          [NSString stringWithFormat:@"/%@",[[FileSystem getFilePath] stringByAppendingPathComponent:NSLocalizedString(@"music", @"")]]
#define KE_DOC            [NSString stringWithFormat:@"/%@",[[FileSystem getFilePath] stringByAppendingPathComponent:NSLocalizedString(@"document", @"")]]
#define KE_ROOT           [NSString stringWithFormat:@"/%@",[FileSystem getFilePath]]

#define KE_DOWNLOAD_VIDEO          [NSString stringWithFormat:@"%@/%@",KE_VIDEO,NSLocalizedString(@"downloadvideopath", @"")]
#define KE_DOWNLOAD_AUDIO          [NSString stringWithFormat:@"%@/%@",KE_MUSIC,NSLocalizedString(@"downloadaudiopath", @"")]
#define KE_DOWNLOAD_PICTURE          [NSString stringWithFormat:@"%@/%@",KE_PHOTO,NSLocalizedString(@"downloadpicturepath", @"")]
#define KE_DOWNLOAD_DOCUMENT          [NSString stringWithFormat:@"%@/%@",KE_DOC,NSLocalizedString(@"downloaddocumentpath", @"")]


#define CONFIG_DIR_PATH       [APP_LIB_ROOT stringByAppendingPathComponent:@"config/"]
#define CONFIG_FILE_PATH      [CONFIG_DIR_PATH stringByAppendingPathComponent:@"path_config.plist"]

#define DOWNLOAD_DIR_PATH     [APP_LIB_ROOT stringByAppendingPathComponent:@"Download/"]
#define DOWNLOAD_VIDEO_DIR_PATH     [DOWNLOAD_DIR_PATH stringByAppendingPathComponent:@"video/"]


#define DOCUMENT_PDF    @"pdf"
#define DOCUMENT_TXT    @"txt"
#define DOCUMENT_RTF    @"rtf"
#define DOCUMENT_DOC    @"doc"
#define DOCUMENT_DOCX   @"docx"
#define DOCUMENT_EPUB   @"epub"
#define DOCUMENT_HTML   @"html"
#define DOCUMENT_PPTX    @"pptx"
#define DOCUMENT_XLSX    @"xlsx"
#define DOCUMENT_PPT    @"ppt"
#define DOCUMENT_XLS    @"xls"
#define DOCUMENT_MOV    @"mov"

//数据分类
#define VIDEO_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:\
@"1", @"m3u8",\
@"1", @"mp4",\
@"1", @"rmvb",\
@"1", @"avi",\
@"1", @"flv",\
@"1", @"wmv",\
@"1", @"ts",\
@"1", @"rm",\
@"1", @"3gp",\
@"1", @"flc",\
@"1", @"mkv",\
@"1", @"mpg",\
@"1", @"mpeg",\
@"1", @"mpe",\
@"1", @"ts",\
@"1", @"m4v",\
@"1", @"3gpp",\
@"1", @"3g2",\
@"1", @"3gp2",\
@"1", @"rt", nil]\

#define MUSIC_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1",@"m4a",\
@"1",@"mka",\
@"1",@"mp3",\
@"1",@"1128",\
@"1",@"tm3",\
@"1",@"m4a",\
@"1",@"tm0",\
@"1",@"tm6", nil]\
//@"1",@"wma",\
//@"1",@"aac",\

#define PICTURE_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"bmp",\
@"1",@"jpeg",\
@"1",@"jpe",\
@"1",@"png",\
@"1",@"jpg",\
@"1",@"ico",nil]\

#define PICTURE_GIF_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"bmp",\
@"1",@"jpeg",\
@"1",@"jpe",\
@"1",@"png",\
@"1",@"gif",\
@"1",@"jpg",nil]\

#define GIF_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"gif", nil]

#define MOV_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"mov", nil]

#define DOC_EX_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"pdf",\
@"1",@"txt",\
@"1",@"rtf",\
@"1",@"doc",\
@"1",@"docx",\
@"1",@"html",\
@"1",@"ppt",\
@"1",@"xls",\
@"1",@"pptx",\
@"1",@"xlsx",\
@"1",@"mov",nil]\

#define DOC_DIC [NSMutableDictionary dictionaryWithObjectsAndKeys:   @"1",@"pdf",\
@"1",@"rtf",\
@"1",@"doc",\
@"1",@"docx",\
@"1",@"html",\
@"1",@"ppt",\
@"1",@"xls",\
@"1",@"pptx",\
@"1",@"xlsx",\
nil]\


//@"1",@"epub",\

//系统播放器支持视频格式 //  h.264/m4v/mp4/mov/mpeg-4/avi
#define VIDEO_IOS_FORMAT  [NSMutableDictionary dictionaryWithObjectsAndKeys:\
@"1",@"h.264",\
@"1",@"m4v",\
@"1",@"mp4",\
@"1",@"mpeg-4",\
@"1",@"mov",\
nil]\

//白名单
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

#endif