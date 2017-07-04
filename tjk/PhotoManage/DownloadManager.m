//
//  DownloadItem.m
//  tjk
//
//  Created by lipeng.feng on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadManager.h"
#import "FileOperate.h"
#import "MobClickUtils.h"
#import "LogUtils.h"
#import "Reachability.h"
#import "DownloadListVC.h"

#define DOWNLOADINGFILENAME @"downloadingVideo"
#define DOWNLOADCOMPLETEFILENAME @"downloadCompleteVideo"
#define SHAHEDIR @"shahe"
#define NOSNDIR @"nosndir"

#define DOWNLOADLAGECOUNT 2

typedef NS_ENUM(NSInteger, AlertTag) {
    AlertTagNetChangeToViaWAN = 100,
    AlertTagNetViaWANStartAll,
    AlertTagNetViaWANStartOne,
    AlertTagDownloadCountFull,
};

@interface DownloadManager ()<DownloadProgressDelegate,UIAlertViewDelegate>{
    NSInteger _downloadingCount;
    FileOperate    *_operation;
    NSInteger _downloadingIdx;
    Reachability *hostReach;
    NetworkStatus _lastStatus;
    NSString* _startPath;
    
    NSString *snPath;
    NSTimer *saveTimer;
    BOOL isProgress;
    BOOL isread;
    BOOL showSpaceAlert;
}

@property (nonatomic, retain) NSMutableArray* downalodItemArray;
@property (nonatomic, retain) NSMutableArray* downalodDataArray;
@property (nonatomic, retain) NSMutableArray* downalodTaskArray;
@property (nonatomic, retain) NSMutableArray* downalodCompletedArray;

@end

@implementation DownloadManager

static DownloadManager* _instance;

+(id)shareInstance {
    if (!_instance) {
        _instance = [[DownloadManager alloc] init];
    }
    return _instance;
}

-(id)init{
    self = [super init];
    if(self){
        hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        Reachability* r = [Reachability reachabilityForInternetConnection];
        _lastStatus = r.currentReachabilityStatus;
        //开始监测
        [hostReach startNotifier];
        _downalodItemArray = [[NSMutableArray alloc] init];
        _downalodTaskArray = [[NSMutableArray alloc] init];
        _downalodDataArray = [[NSMutableArray alloc] init];
        _downalodCompletedArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:@"DOWNLOAD_STATUS_NEED_PAUSE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name: kReachabilityChangedNotification
                                                   object: nil];
        
        
        if (![FileSystem isConnectedKE] || [FileSystem checkInit]) {
            [self readDownloadListFromFile];
        }
    }
    return self;
}

#pragma mark - 监测网络情况，当网络发生改变时会调用
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == kReachableViaWWAN && _lastStatus == kReachableViaWiFi && ![self getALLItemDownloadPaused]) {
        [self pauseAll];
        [self doCheckListVCBottomBtnStatus];
        UIAlertView * notice=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"tips",@"") message:NSLocalizedString(@"netchangenotice",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"yes",@"") otherButtonTitles:NSLocalizedString(@"no",@""), nil];
        notice.tag = AlertTagNetChangeToViaWAN;
        [notice show];
    }
    else if (status == kNotReachable) {
        [self performSelector:@selector(delayPause) withObject:nil afterDelay:3];
    }
    
    _lastStatus = status;
}

-(void)delayPause{
    Reachability* r = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = r.currentReachabilityStatus;
    if (status == kNotReachable) {
        [self pauseAll];
        [self doCheckListVCBottomBtnStatus];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOADING_TASK_PAUSEALL object:nil];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    switch (alertView.tag) {
        case AlertTagNetChangeToViaWAN:{
            if (buttonIndex == 0) {
                [self doStartAll];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOADING_TASK_PAUSEALL object:nil];
            }
        }
            break;
        case AlertTagNetViaWANStartAll:{
            if (buttonIndex == 0) {
                [self doStartAll];
            }
        }
            break;
        case AlertTagNetViaWANStartOne:{
            if (buttonIndex == 0 && _startPath) {
                [self doStartDownloadWith:_startPath];
            }
        }
            break;
        case AlertTagDownloadCountFull:{
            if (buttonIndex == 1) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DOWNLOADCOUNTFULL"];
            }
        }
            break;
    
        default:
            break;
    }
    
    [self doCheckListVCBottomBtnStatus];
}

#pragma mark -

-(void)connectionNotification:(NSNotification*)noti {
    BOOL needPause = NO;
    if([noti.object intValue] == CU_NOTIFY_DEVOFF){
        needPause = YES;
    }
    else if([noti.name isEqualToString:@"DOWNLOAD_STATUS_NEED_PAUSE"]){
        if (!showSpaceAlert) {
            showSpaceAlert = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* message = noti.object;
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"downloadtitle", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                [alert show];
                [self performSelector:@selector(alertShowDone) withObject:nil afterDelay:1];
            });
        }
        needPause = YES;
    }
    else if ([noti.object intValue] == CU_NOTIFY_DEVCON){
        if (!isread) {
            [self readDownloadListFromFile];
            [[DownloadListVC sharedInstance] refreshTable];
        }
    }
    if (needPause) {
        [self pauseAll];
        [self doCheckListVCBottomBtnStatus];
    }
}

-(void)alertShowDone{
    showSpaceAlert = NO;
}

-(void)readDownloadListFromFile {
    isread = YES;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isfindingSnPath;
    NSString *snpath = [self getSavePath:NO];
    if ([fm fileExistsAtPath:snpath]) {
        isfindingSnPath = YES;
    }
    else{
        [fm createDirectoryAtPath:snpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *downloadingPath = isfindingSnPath?[snpath stringByAppendingPathComponent:DOWNLOADINGFILENAME] : [DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADINGFILENAME];
    
    if ([fm fileExistsAtPath:downloadingPath]) {
        _downalodDataArray = [NSMutableArray arrayWithContentsOfFile:downloadingPath];
        
        for (NSDictionary *dict in _downalodDataArray) {
            NSString *fpath = [dict objectForKey:@"fpath"];
            NSArray *items = [dict objectForKey:@"items"];
            NSMutableArray *itemsArr = [NSMutableArray array];
            for (NSDictionary *itemdict in items) {
                DownloadItemInfo *item = [[DownloadItemInfo alloc] init];
                item.idx = [itemdict objectForKey:@"idx"];
                item.dirName = [itemdict objectForKey:@"dirName"];
                item.name = [itemdict objectForKey:@"name"];
                item.seconds = [itemdict objectForKey:@"seconds"];
                item.size = [itemdict objectForKey:@"size"];
                item.url = [itemdict objectForKey:@"url"];
                [itemsArr addObject:item];
            }
            
            DownloadInfo *downloadinfo = [[DownloadInfo alloc] init];
            downloadinfo.fpath = fpath;
            downloadinfo.webURL = [dict objectForKey:@"webURL"];
            downloadinfo.current = [dict objectForKey:@"current"];
            downloadinfo.filepath = [dict objectForKey:@"filepath"];
            downloadinfo.currentDSize = [dict objectForKey:@"currentDSize"];
            downloadinfo.items = itemsArr;
            downloadinfo.type = ((NSNumber *)[dict objectForKey:@"downloadtype"]).intValue;
            
            NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
            [itemDict setObject:downloadinfo forKey:@"item"];
            [itemDict setObject:fpath forKey:@"fpath"];
            [_downalodItemArray addObject:itemDict];
        }
        
        if (!isfindingSnPath) {
            [fm removeItemAtPath:downloadingPath error:nil];
            [self saveDownlaodList:NO];
        }
    }
    
    NSString *downloadCompletePath = isfindingSnPath?[snpath stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME] : [DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME];
    
    if ([fm fileExistsAtPath:downloadCompletePath]) {
        _downalodCompletedArray = [NSMutableArray arrayWithContentsOfFile:downloadCompletePath];
        if (!_downalodCompletedArray) {
            _downalodCompletedArray = [[NSMutableArray alloc] init];
        }
        
        if (!isfindingSnPath) {
            [fm removeItemAtPath:downloadCompletePath error:nil];
            [self saveDownloadCompletedList:YES];
        }
    }
}

-(void)addDownloadTaskWithArray:(NSMutableArray *)infoArrr delegate:(id<DownloadProgressDelegate>)delegate
{
    @synchronized(self) {
        for (DownloadInfo *info in infoArrr) {
            
            [self addDownloadInfo:info delegate:delegate];
            
        }
        [self saveDownlaodList:NO];
        [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
    }
    
}

-(void)addDownloadTask:(DownloadInfo*)info delegate:(id<DownloadProgressDelegate>)delegate {
    
    @synchronized(self) {
        
        [self addDownloadInfo:info delegate:delegate];
        
        [self saveDownlaodList:NO];
        
        [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_TASK_NOTF object:nil];
}

-(void)addDownloadInfo:(DownloadInfo *)info delegate:(id<DownloadProgressDelegate>)delegate
{
    for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
        NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.fpath isEqualToString:info.fpath]) {
            return;
        }
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 info,@"item",
                                 info.fpath,@"fpath",
                                 delegate,@"delegate",
                                 nil];
    [_downalodItemArray addObject:dict];
    //        NSInteger idx = [_downalodItemArray indexOfObject:dict];
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    info.status = STATUS_DOWNLOAD_WAIT;
    for (DownloadItemInfo* itemInfo in info.items) {
        NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
                             itemInfo.idx,@"idx",
                             itemInfo.dirName?itemInfo.dirName : @"",@"dirName",
                             itemInfo.name?itemInfo.name : @"",@"name",
                             itemInfo.seconds?itemInfo.seconds : @"",@"seconds",
                             itemInfo.size?itemInfo.size : @"",@"size",
                             itemInfo.url?itemInfo.url : @"",@"url",
                             nil];
        [tmpArray addObject:dict];
    }
    [_downalodDataArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   info.fpath,@"fpath",
                                   info.webURL,@"webURL",
                                   tmpArray,@"items",
                                   info.filepath,@"filepath",
                                   [NSNumber numberWithInteger:0],@"current",
                                   [NSNumber numberWithInteger:0],@"currentDSize",
                                   [NSNumber numberWithInteger:info.type],@"downloadtype",
                                   nil]];
}

-(void)startTask:(NSInteger)index fromCurrent:(NSInteger)current{
    if (_downalodItemArray && _downalodItemArray.count > index) {
        NSDictionary* tmpDic = [_downalodItemArray objectAtIndex:index];
        DownloadInfo* tmpInfo = [tmpDic objectForKey:@"item"];
        tmpInfo.status = STATUS_DOWNLOADING;
        DownloadTask* task = [[DownloadTask alloc] init];
        NSLog(@"startTask:::");
        [task downloadFileWith:tmpInfo toPath:[tmpInfo.filepath stringByDeletingLastPathComponent] delegate:self from:current];
        [_downalodTaskArray addObject:task];
    }
}

-(void)saveJuJiInfo:(DownloadInfo *)info
{
    @synchronized(self) {
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSMutableDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if ([tmpInfo.fpath isEqualToString:info.fpath]) {
                [tmp setObject:info forKey:@"item"];
                NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
                for (DownloadItemInfo* itemInfo in info.items) {
                    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:
                                         itemInfo.idx,@"idx",
                                         itemInfo.dirName?itemInfo.dirName : @"",@"dirName",
                                         itemInfo.name?itemInfo.name : @"",@"name",
                                         itemInfo.seconds?itemInfo.seconds : @"",@"seconds",
                                         itemInfo.size?itemInfo.size : @"",@"size",
                                         itemInfo.url?itemInfo.url : @"",@"url",
                                         nil];
                    [tmpArray addObject:dict];
                }
                
                for (NSMutableDictionary *dict in _downalodDataArray) {
                    if ([[dict objectForKey:@"webURL"] isEqualToString:info.webURL]) {
                        NSMutableDictionary *newdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        info.fpath,@"fpath",
                        info.webURL,@"webURL",
                        tmpArray,@"items",
                        info.filepath,@"filepath",
                        [NSNumber numberWithInteger:0],@"current",
                        [NSNumber numberWithInteger:0],@"currentDSize",
                        [NSNumber numberWithInteger:info.type],@"downloadtype",
                        nil];
                        NSInteger index = [_downalodDataArray indexOfObject:dict];
                        if (index != NSNotFound) {
                            [_downalodDataArray replaceObjectAtIndex:index withObject:newdict];
                        }
                        break;
                    }
                }
                
                [self saveDownlaodList:NO];
                break;
            }
        }
        
    }
}

-(NSString *)getSavePath:(BOOL)ismoveToke
{
    if (!snPath) {
        BOOL isLinkKe = [FileSystem isConnectedKE] && [FileSystem checkInit];
        if (isLinkKe || ismoveToke) {
            NSString *sn = [FileSystem getSN];
            
            if (!sn || [sn isEqualToString:@""]) {
                sn = NOSNDIR;
            }
            snPath = [DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:sn];
        }
        else{
            snPath = [DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:SHAHEDIR];
        }
    }
    
    return snPath;
}

-(void)clearSnPath
{
    snPath = nil;
}

-(void)saveDownlaodListUsingTimer
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [self saveDownlaodListUsingThread];
    });
//    [NSThread detachNewThreadSelector:@selector(saveDownlaodListUsingThread) toTarget:self withObject:nil];
}

-(void)saveDownlaodListUsingThread
{
    
    if (_downloadingCount <= 0 && saveTimer) {
        [saveTimer invalidate];
        saveTimer = nil;
        [self saveDownlaodList:NO];
    }
    else{
        if (isProgress) {
//            NSLog(@"saveDownlaodListUsingThread");
            [self saveDownlaodList:NO];
            isProgress = NO;
        }
    }
}

-(void)saveDownlaodList:(BOOL)ismoveToke{
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:DOWNLOAD_DIR_PATH]) {
        [fm createDirectoryAtPath:DOWNLOAD_DIR_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fm fileExistsAtPath:DOWNLOAD_VIDEO_DIR_PATH]) {
        [fm createDirectoryAtPath:DOWNLOAD_VIDEO_DIR_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *savepath = [self getSavePath:ismoveToke];
    
    if (!savepath) {
        savepath = DOWNLOAD_VIDEO_DIR_PATH;
    }
    
    if (![fm fileExistsAtPath:savepath]) {
        [fm createDirectoryAtPath:savepath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableArray *saveArr = [[NSMutableArray alloc] initWithArray:_downalodDataArray copyItems:YES];
    [saveArr writeToFile:[savepath stringByAppendingPathComponent:DOWNLOADINGFILENAME] atomically:YES];
    
}

-(void)saveDownloadCompletedList:(BOOL)ismovetoke{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:DOWNLOAD_DIR_PATH]) {
        [fm createDirectoryAtPath:DOWNLOAD_DIR_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fm fileExistsAtPath:DOWNLOAD_VIDEO_DIR_PATH]) {
        [fm createDirectoryAtPath:DOWNLOAD_VIDEO_DIR_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *savepath = [self getSavePath:ismovetoke];
    
    if (![fm fileExistsAtPath:savepath]) {
        [fm createDirectoryAtPath:savepath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [_downalodCompletedArray writeToFile:[savepath stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME] atomically:YES];
}


-(void)downloadSuccessedFile:(NSString*)filePath atIndex:(NSInteger)index finish:(BOOL)finish{
    NSInteger current = finish ? 0 : (index + 1);
    if (finish) {
        [MobClickUtils event:@"DOWNLOAD_VIDEO_RESULT" label:@"SUCCESS"];
    }
    
    DOWNLOAD_TYPE successedtype = DOWN_TYPE_VIDEO;
    
    @synchronized(_downalodDataArray) {
        for (NSMutableDictionary * tmp in _downalodDataArray) {
            if (!tmp) {
                continue;
            }
            NSString* fpath = [tmp objectForKey:@"fpath"];
            if ([fpath isEqualToString:filePath]) {
                
                if (finish) {
                    
                    [_downalodCompletedArray insertObject:[tmp copy] atIndex:0];
                    [self saveDownloadCompletedList:NO];
                    
                    [_downalodDataArray removeObject:tmp];
                }
                else if([tmp objectForKey:@"current"]){
                    [tmp setValue:[NSNumber numberWithInteger:0] forKey:@"currentDSize"];
                    [tmp setValue:[NSNumber numberWithInteger:current] forKey:@"current"];
                }
                [self saveDownlaodList:NO];
                break;
            }
        }
    }
    
    
    NSString *weburl = @"";
    NSString *path = @"";
    @synchronized(_downalodItemArray) {
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if ([tmpInfo.fpath isEqualToString:filePath]) {
                successedtype = tmpInfo.type;
                NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
                BOOL fromYunPan = ([tmpInfo.webURL rangeOfString:@"pan.baidu.com"].location != NSNotFound || [tmpInfo.webURL rangeOfString:@"yun.baidu.com"].location != NSNotFound) && BDUSS;
                if (fromYunPan) {
                    NSString* exName = [[tmpInfo.filepath pathExtension] lowercaseString];
                    if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
                        successedtype = 1;
                    }
                    else if([MUSIC_EX_DIC objectForKey:exName]){
                        successedtype = 0;
                    }
                    else  if([PICTURE_EX_DIC objectForKey:exName] || [GIF_EX_DIC objectForKey:exName]){
                        successedtype = 2;
                    }
                    else {
                        successedtype = 3;
                    }
                }
                weburl = tmpInfo.webURL;
                path = tmpInfo.filepath;
                CGFloat totalsize = 0;
                CGFloat loadedsize = 0;
                for (int i = 0; i < tmpInfo.items.count; i++) {
                    DownloadItemInfo *item = (DownloadItemInfo *)[tmpInfo.items objectAtIndex:i];
                    totalsize += item.size.floatValue;
                    if (index >= i) {
                        loadedsize += item.size.floatValue;
                    }
                }
                NSString* sizeStr = [NSString stringWithFormat:@"%ld",(NSInteger)loadedsize];
                if ([tmpInfo.filepath.pathExtension isEqualToString:@"m3u8"]) {
                    [FileSystem  writeFileToPath:[tmpInfo.filepath stringByAppendingPathComponent:@"size.txt"] DataFile:[sizeStr dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                tmpInfo.current = [NSNumber numberWithInteger:current];
                [LogUtils writeLog:[NSString stringWithFormat:@"downloadSuccessedFile %@ : %ld",tmpInfo.filepath,index]];
                if (finish && tmp) {
                    [_downalodItemArray removeObject:tmp];
                }
                id<DownloadProgressDelegate> delegate = [tmp objectForKey:@"delegate"];
                if ([delegate respondsToSelector:@selector(downloadSuccessedFile:atIndex:finish:)]) {
                    [delegate downloadSuccessedFile:filePath atIndex:index finish:finish];
                }
                
                break;
            }
        }
    }
    
    if (finish){
        [[MusicPlayerViewController instance]writeNewPath:path];
        [self newcycle:successedtype];
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNCOMPELETE_NOTI object:[NSNumber numberWithInt:successedtype] userInfo:[NSDictionary dictionaryWithObject:weburl forKey:@"weburl"]];
       
        @synchronized(_downalodTaskArray) {
            for (DownloadTask* task in _downalodTaskArray) {
                if ([[task privatePath] isEqualToString:filePath]) {
                    [task cancel];
                    [_downalodTaskArray removeObject:task];
                    _downloadingCount --;
                    if (_downloadingCount < 0) {
                        _downloadingCount = 0;
                    }
                    break;
                }
            }
        }
        [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
    }
}
-(void)newcycle:(int)type{

    if (type == 0) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newmusicdown"];
    }else if (type == 1){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newvideodown"];
    }else if(type == DOWN_TYPE_DOCUMENT){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newdocumentdown"];
    }

}

-(void)checkDownloadAndStart:(NSNumber*)isstartAll{
    NSLog(@"checkDownloadAndStart");
    [NSThread detachNewThreadSelector:@selector(doCheckDownloadAndStart:) toTarget:self withObject:isstartAll];
}

-(void)doCheckDownloadAndStart:(NSNumber *)isstartAll{
    NSLog(@"doCheckDownloadAndStart");
    @synchronized(_downalodItemArray) {
        NSMutableArray *indexArr = [NSMutableArray array];
        NSMutableArray *infoArr = [NSMutableArray array];
        
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if (!tmpInfo) {
                continue;
            }
            if (i < _downloadingIdx) {
                [indexArr addObject:[NSNumber numberWithInteger:i]];
                [infoArr addObject:tmpInfo];
            }
            else {
                NSInteger idx = i - _downloadingIdx;
                [indexArr insertObject:[NSNumber numberWithInteger:i] atIndex:idx];
                [infoArr insertObject:tmpInfo  atIndex:idx];
            }
            
        }
        
        if (indexArr.count > 0) {
            for (int i = 0; i<indexArr.count; i++) {
                DownloadInfo *info = (DownloadInfo *)[infoArr objectAtIndex:i];
                NSNumber *indexNum = (NSNumber *)[indexArr objectAtIndex:i];
                if (info.status == STATUS_DOWNLOAD_WAIT && _downloadingCount < DOWNLOADLAGECOUNT) {
                    _downloadingCount ++;
                    [LogUtils writeLog:[NSString stringWithFormat:@"_downloadingCount : %ld",_downloadingCount]];
                    if (_downloadingCount == DOWNLOADLAGECOUNT) {
                        _downloadingIdx = indexNum.integerValue;
                    }
                    info.status = STATUS_DOWNLOADING;
                    
                    
                    if (!isstartAll.boolValue) {
                        [self performSelectorOnMainThread:@selector(postDownload:) withObject:info waitUntilDone:NO];
                    }
                    [self startTask:indexNum.integerValue fromCurrent:info.current.integerValue];
                    //                [self startTask:i fromCurrent:tmpInfo.current.integerValue];
                    
                }
                else{
                    if (isstartAll.boolValue) {
                        info.status = STATUS_DOWNLOAD_WAIT;
                    }
                }
                //            if (_downloadingCount == DOWNLOADLAGECOUNT) {
                //                break;
                //            }
                if (isstartAll.boolValue) {
                    [self performSelectorOnMainThread:@selector(postDownload:) withObject:info waitUntilDone:NO];
                }
            }
        }
        [indexArr removeAllObjects];
        [infoArr removeAllObjects];
    }
}

-(void)postDownload:(DownloadInfo*)tmpInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:tmpInfo.fpath object:[NSDictionary dictionaryWithObjectsAndKeys:tmpInfo.fpath,@"filepath",[NSNumber numberWithInt:tmpInfo.status],@"status", nil]];
}

-(void)downloadProgress:(NSInteger)downloadSize filepath:(NSString*)filePath atIndex:(NSInteger)index count:(NSInteger)count{
//    NSLog(@"%ld,(%ld/%ld)",downloadSize,index,count);
    
    if (!saveTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            saveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(saveDownlaodListUsingTimer) userInfo:nil repeats:YES];
        });
    }
    isProgress = YES;
    
    for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
        NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.fpath isEqualToString:filePath]) {
            if (tmpInfo.status != STATUS_DOWNLOAD_PAUSE) {
                tmpInfo.status = STATUS_DOWNLOADING;
            }
            tmpInfo.current = [NSNumber numberWithInteger:index];
            tmpInfo.currentDSize = [NSNumber numberWithInteger:downloadSize];
            id<DownloadProgressDelegate> delegate = [tmp objectForKey:@"delegate"];
            if ([delegate respondsToSelector:@selector(downloadProgress:filepath:atIndex:count:)]) {
                [delegate downloadProgress:downloadSize filepath:filePath atIndex:index count:count];
            }
            break;
        }
    }
    
    @synchronized(_downalodDataArray) {
        for (NSMutableDictionary * tmp in _downalodDataArray) {
            NSString* fpath = [tmp objectForKey:@"fpath"];
            if ([fpath isEqualToString:filePath]) {
               [tmp setValue:[NSNumber numberWithInteger:downloadSize] forKey:@"currentDSize"];
                [tmp setValue:[NSNumber numberWithInteger:index] forKey:@"current"];
//                [self saveDownlaodList:NO];
                break;
            }
        }
    }
}

-(void)downloadFailedFile:(NSString*)filePath atIndex:(NSInteger)index{
    [MobClickUtils event:@"DOWNLOAD_VIDEO_RESULT" label:@"FAILED"];
    
    for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
        NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.fpath isEqualToString:filePath]) {
            tmpInfo.status = STATUS_DOWNLOAD_FAILED;
            id<DownloadProgressDelegate> delegate = [tmp objectForKey:@"delegate"];
            if ([delegate respondsToSelector:@selector(downloadFailedFile:atIndex:)]) {
                [delegate downloadFailedFile:filePath atIndex:index];
            }
            break;
        }
    }
    @synchronized(_downalodTaskArray) {
        for (DownloadTask* task in _downalodTaskArray) {
            if ([[task privatePath] isEqualToString:filePath]) {
                [task cancel];
                [_downalodTaskArray removeObject:task];
                _downloadingCount --;
                if (_downloadingCount < 0) {
                    _downloadingCount = 0;
                }
                break;
            }
        }
    }
    
    if ([FileSystem freeDiskSpaceInBytes] < 1.0) {
        [self pauseAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"notplace", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
            [alert show];
        });
    }
    
    else{
       [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
    }
}

#pragma mark - funtion for list

-(NSMutableArray *)getDownloadingArray
{
    return _downalodItemArray;
}

-(void)removeDownloadingItem:(NSArray *)itemArray atIndex:(NSArray *)indexArray
{
    [self removeDownloadingItem:itemArray atIndex:indexArray fromFile:NO];
    
}

-(void)removeDownloadingItem:(NSArray *)itemArray atIndex:(NSArray *)indexArray fromFile:(BOOL)fromFile
{
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
        //        _operation.delegate = self;
    }
    NSMutableArray* tmpFileArray = [NSMutableArray array];
    for (NSInteger i = 0; i < itemArray.count; i ++) {
        
        NSDictionary *dict = [itemArray objectAtIndex:i];
        
        @synchronized(_downalodItemArray) {
            [_downalodItemArray removeObject:dict];
        }
        @synchronized(_downalodTaskArray) {
            NSArray* tmpArray = [NSMutableArray arrayWithArray:_downalodTaskArray];
            NSString *fpath = (NSString *)[dict objectForKey:@"fpath"];
            for (DownloadTask* task in tmpArray) {
                if ([[task privatePath] isEqualToString:fpath]) {
                    if (task) {
                        [task pause];
                        [_downalodTaskArray removeObject:task];
                    }
                }
            }
            
        }
        
        @synchronized(_downalodDataArray){
            DownloadInfo *tmpinfo = (DownloadInfo *)[dict objectForKey:@"item"];
            if (!fromFile) {
                FilePropertyBean* info = [FileSystem readFileProperty:tmpinfo.filepath];
                if (info) {
                    FileBean* bean = [[FileBean alloc] init];
                    [bean setFilePath:tmpinfo.filepath];
                    [bean setFileType:FILE_VIDEO];
                    [tmpFileArray addObject:bean];
                }
            }
            if (tmpinfo.status == STATUS_DOWNLOADING) {
                _downloadingCount --;
                if (_downloadingCount < 0) {
                    _downloadingCount = 0;
                }
            }
            for (NSDictionary *dict in _downalodDataArray) {
                NSString *fpath = (NSString *)[dict objectForKey:@"fpath"];
                if ([fpath isEqualToString:tmpinfo.fpath]) {
                    [_downalodDataArray removeObject:dict];
//                    [self saveDownlaodList];
                    break;
                }
            }
            
        }
    }
    [self saveDownlaodList:NO];
    if (!fromFile && tmpFileArray.count > 0) {
        [_operation deleteFiles:tmpFileArray userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"delete",@"action",
                                                       RealDownloadVideoPath,@"dirpath", nil] alertMsg:NSLocalizedString(@"deletecachefile", @"")];
    }
    [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
}



-(DOWNLOAD_STATUS)getItemDownloadStatus:(NSString*)path {
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if ([tmpInfo.fpath isEqualToString:path]) {
                return tmpInfo.status;
            }
        }
    }
    return STATUS_DOWNLOAD_PAUSE;
}

-(BOOL)getALLItemDownloadPaused{
    BOOL isAllPause = YES;
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if (tmpInfo.status == STATUS_DOWNLOADING || tmpInfo.status == STATUS_DOWNLOAD_WAIT) {
                isAllPause = NO;
                break;
            }
        }
    }
    return isAllPause;
}

-(BOOL)useGPRS{
    Reachability* r = [Reachability reachabilityForInternetConnection];
    return r.currentReachabilityStatus == ReachableViaWWAN;
}

-(void)startAll {
    NSLog(@"startAll START");
    
    if ([self useGPRS]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView * notice=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"tips",@"") message:NSLocalizedString(@"netchangenotice",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"yes",@"") otherButtonTitles:NSLocalizedString(@"no",@""), nil];
            notice.tag = AlertTagNetViaWANStartAll;
            [notice show];
        });
        
    }
    else {
        [self doStartAll];
    }
    NSLog(@"startAll END");
}


-(void)doStartAll{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if (tmpInfo.status == STATUS_DOWNLOAD_PAUSE || tmpInfo.status == STATUS_DOWNLOAD_FAILED) {
                tmpInfo.status = STATUS_DOWNLOAD_WAIT;
            }
        }
    }
    [self checkDownloadAndStart:[NSNumber numberWithBool:YES]];
}

-(void)startDownloadWith:(NSString*)path{
    
    if ([self useGPRS]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView * notice=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"tips",@"") message:NSLocalizedString(@"netchangenotice",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"yes",@"") otherButtonTitles:NSLocalizedString(@"no",@""), nil];
            notice.tag = AlertTagNetViaWANStartOne;
            _startPath = path;
            [notice show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:_startPath object:[NSDictionary dictionaryWithObjectsAndKeys:_startPath,@"filepath",[NSNumber numberWithInt:STATUS_DOWNLOAD_PAUSE],@"status", nil]];
        });
        
    }
    else {
        [self doStartDownloadWith:path];
    }
}

-(void)doStartDownloadWith:(NSString*)path{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if ([tmpInfo.fpath isEqualToString:path]) {
                tmpInfo.status = STATUS_DOWNLOAD_WAIT;
                [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
                break;
            }
        }
    }
    _startPath = nil;
}

-(void)pauseAll{
    _downloadingIdx = 0;
    @synchronized(_downalodTaskArray){
        for (NSInteger i = 0 ; i < _downalodTaskArray.count ; i ++) {
            DownloadTask* task = [_downalodTaskArray objectAtIndex:i];
            [task pause];
        }
        _downloadingCount = 0;
        [_downalodTaskArray removeAllObjects];
    }
    
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
//            if ([tmpInfo.fpath isEqualToString:[task privatePath]]) {
            if (tmpInfo.status != STATUS_DOWNLOAD_PAUSE) {
                tmpInfo.status = STATUS_DOWNLOAD_PAUSE;
                [self performSelectorOnMainThread:@selector(postDownload:) withObject:tmpInfo waitUntilDone:NO];
            }
//            }
        }
    }
}

-(void)pauseDownloadWith:(NSString*)path{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            if ([tmpInfo.fpath isEqualToString:path]) {
                if (tmpInfo.status == STATUS_DOWNLOADING) {
                    _downloadingCount --;
                }
                if (_downloadingCount < 0) {
                    _downloadingCount = 0;
                }
                tmpInfo.status = STATUS_DOWNLOAD_PAUSE;
                break;
            }
        }
    }
    @synchronized(_downalodTaskArray){
        DownloadTask* info = nil;
        for (NSInteger i = 0 ; i < _downalodTaskArray.count ; i ++) {
            DownloadTask* tmp = [_downalodTaskArray objectAtIndex:i];
            if ([[tmp privatePath] isEqualToString:path]) {
                [tmp pause];
                info = tmp;
                break;
            }
        }
        
        if (info) {
            [_downalodTaskArray removeObject:info];
        }
    }
    if ([self getALLItemDownloadPaused]) {
        _downloadingIdx = 0;
    }
    [self checkDownloadAndStart:[NSNumber numberWithBool:NO]];
}

-(NSString *)dealWhiteSpace:(NSString *)str
{
    NSString *name = str;
//    if (name && [name isKindOfClass:[NSString class]] && name.length > 0) {
//        name = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
//    }
    return name;
}

-(NSString *)dealUrl:(NSString *)str
{
    NSString *tmpinfosubpath = str;
    if ([str rangeOfString:@"&subid="].location != NSNotFound) {
        NSArray *array = [str componentsSeparatedByString:@"="];
        tmpinfosubpath = [array lastObject];
    }
    else{
        tmpinfosubpath = [str rangeOfString:@"?"].location != NSNotFound? [[str substringToIndex:[str rangeOfString:@"?"].location] lastPathComponent] : str;
    }
    return tmpinfosubpath;
}

-(BOOL)IsInDownloadListForYunPan:(NSString *)itemname{
    
    if (!itemname) {
        return NO;
    }
    
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            
            NSString *filepath = [tmpInfo.filepath lastPathComponent];
            
            NSString *name = filepath;//[filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
//            itemname = [itemname rangeOfString:@"."].location != NSNotFound?[[itemname substringToIndex:[itemname rangeOfString:@"."].location] lastPathComponent] : itemname;
            
            name = [self dealWhiteSpace:name];
            itemname = [self dealWhiteSpace:itemname];
            
            if ([name isEqualToString:itemname]) {
                return YES;
            }
            
        }
    }
    @synchronized(_downalodCompletedArray) {
        for (NSMutableDictionary * tmp in _downalodCompletedArray) {
            NSString *filepath = [[tmp objectForKey:@"filepath"] lastPathComponent];
            
            NSString *name = filepath;//[filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
//            itemname = [itemname rangeOfString:@"."].location != NSNotFound?[[itemname substringToIndex:[itemname rangeOfString:@"."].location] lastPathComponent] : itemname;
            name = [self dealWhiteSpace:name];
            itemname = [self dealWhiteSpace:itemname];
            
            if ([itemname isEqualToString:name]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)downloadingInList:(NSString*)path name:(NSString *)itemname{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            
            if ([tmpInfo.fpath isKindOfClass:[NSNull class]] || [tmpInfo.fpath isEqualToString:path]) {
                return YES;
            }
            else{
                NSString *tmpinfosubpath = [self dealUrl:tmpInfo.fpath];
                NSString *pathsubstr = [self dealUrl:path];
                
                NSString *filepath = [tmpInfo.filepath lastPathComponent];
                
                NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
                
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([tmpinfosubpath isEqualToString:pathsubstr] && [name isEqualToString:itemname]) {
                    return YES;
                }
            }
            
        }
    }
    @synchronized(_downalodCompletedArray) {
        for (NSMutableDictionary * tmp in _downalodCompletedArray) {
            NSString* fpath = [tmp objectForKey:@"fpath"];
            NSString *filepath = [[tmp objectForKey:@"filepath"] lastPathComponent];
            
            if ([filepath isKindOfClass:[NSNull class]] || [fpath isEqualToString:path]) {
                return YES;
            }
            else{
                
                NSString *tmpinfosubpath = [self dealUrl:fpath];
                NSString *pathsubstr = [self dealUrl:path];
                
                NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([tmpinfosubpath isEqualToString:pathsubstr] && [itemname isEqualToString:name]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


-(INDOWNLOADMANAGERSTATUS)isdownloadingInListWith:(NSString*)path name:(NSString *)itemname{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            
            if ([tmpInfo.webURL isKindOfClass:[NSNull class]] || [tmpInfo.webURL isEqualToString:path]) {
                return IN_STATUS_DOWNING;
            }
            else{
                NSString *tmpinfosubpath = [self dealUrl:tmpInfo.webURL];
                NSString *pathsubstr = [self dealUrl:path];
                
                NSString *filepath = [tmpInfo.filepath lastPathComponent];
                
                NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([tmpinfosubpath isEqualToString:pathsubstr] && [name isEqualToString:itemname]) {
                    return IN_STATUS_DOWNING;
                }
            }
            
        }
    }
    @synchronized(_downalodCompletedArray) {
        for (NSMutableDictionary * tmp in _downalodCompletedArray) {
            NSString* fpath = [tmp objectForKey:@"webURL"];
            NSString *filepath = [[tmp objectForKey:@"filepath"] lastPathComponent];
            
            if ([filepath isKindOfClass:[NSNull class]] || [fpath isEqualToString:path]) {
                return IN_STATUS_DOWNED;
            }
            else{
                
                NSString *tmpinfosubpath = [self dealUrl:fpath];
                NSString *pathsubstr = [self dealUrl:path];
                
                NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([tmpinfosubpath isEqualToString:pathsubstr] && [itemname isEqualToString:name]) {
                    return IN_STATUS_DOWNED;
                }
            }
        }
    }
    return IN_STATUS_NONEFONND;
}

-(INDOWNLOADMANAGERSTATUS)isMusicSameNameAndDiffFpathIndownloadingListWith:(NSString*)path name:(NSString *)itemname{
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            
            NSString *filepath = [tmpInfo.filepath lastPathComponent];
            if ([filepath isKindOfClass:[NSNull class]]) {
                return IN_STATUS_DOWNING;
            }
            NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
            if ([tmpInfo.webURL isEqualToString:path]) {
                return IN_STATUS_DOWNING;
            }
            else{
                
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                if ([name isEqualToString:itemname]) {
                    return IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH;
                }
            }
        }
    }
    @synchronized(_downalodCompletedArray) {
        for (NSMutableDictionary * tmp in _downalodCompletedArray) {
            NSString* fpath = [tmp objectForKey:@"webURL"];
            NSString *filepath = [[tmp objectForKey:@"filepath"] lastPathComponent];
            
            if ([filepath isKindOfClass:[NSNull class]]) {
                return IN_STATUS_DOWNED;
            }
            
            NSString *name = [filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
            
            if ([fpath isEqualToString:path]) {
                return IN_STATUS_DOWNED;
            }
            else{
                
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([name isEqualToString:itemname]) {
                    return IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH;
                }
            }
        }
    }
    return IN_STATUS_NONEFONND;
}

-(INDOWNLOADMANAGERSTATUS)isdownloadingBaiDuYunInListWith:(NSString*)subid name:(NSString *)itemname{
    NSString* param = [NSString stringWithFormat:@"&subid=%@",subid];
    @synchronized(_downalodItemArray){
        for (NSInteger i = 0 ; i < _downalodItemArray.count ; i ++) {
            
            NSDictionary* tmp = [_downalodItemArray objectAtIndex:i];
            DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
            
            if ([tmpInfo.webURL isKindOfClass:[NSNull class]] || [tmpInfo.webURL rangeOfString:param].location != NSNotFound) {
                return IN_STATUS_DOWNING;
            }
            else{
                NSString *filepath = [tmpInfo.filepath lastPathComponent];
                
                NSString *name = filepath;//[filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                
                if ([name isEqualToString:itemname]) {
                    return IN_STATUS_DOWNING;
                }
            }
            
        }
    }
    @synchronized(_downalodCompletedArray) {
        for (NSMutableDictionary * tmp in _downalodCompletedArray) {
            NSString* fpath = [tmp objectForKey:@"webURL"];
            NSString *filepath = [[tmp objectForKey:@"filepath"] lastPathComponent];
            NSString *tmpinfosubpath = [self dealUrl:fpath];
            if ([filepath isKindOfClass:[NSNull class]] || [tmpinfosubpath isEqualToString:subid]) {
                return IN_STATUS_DOWNED;
            }
            else{
                NSString *name = filepath;//[filepath rangeOfString:@"."].location != NSNotFound?[[filepath substringToIndex:[filepath rangeOfString:@"."].location] lastPathComponent] : filepath;
//                NSString *name2 = [itemname rangeOfString:@"."].location != NSNotFound?[[itemname substringToIndex:[itemname rangeOfString:@"."].location] lastPathComponent] : itemname;
                name = [self dealWhiteSpace:name];
                itemname = [self dealWhiteSpace:itemname];
                if ([itemname isEqualToString:name]) {
                    return IN_STATUS_DOWNED;
                }
            }
        }
    }
    return IN_STATUS_NONEFONND;
}


-(NSString*)getNewDownloadDir:(NSString*)name{
    NSString *exName = [[name pathExtension] lowercaseString];
    if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
        return KE_DOWNLOAD_VIDEO;
    }
    else if([MUSIC_EX_DIC objectForKey:exName]){
        return KE_DOWNLOAD_AUDIO;
    }
    else  if([PICTURE_EX_DIC objectForKey:exName] || [GIF_EX_DIC objectForKey:exName]){
        return KE_DOWNLOAD_PICTURE;
    }
    else {
        return KE_DOWNLOAD_DOCUMENT;
    }
}

-(void)changeLocalFileToKe
{
    NSFileManager *fm = [NSFileManager defaultManager];
    @synchronized(_downalodDataArray){
        
        for (NSMutableDictionary *dict in _downalodDataArray) {
            NSString *fpath = [dict objectForKey:@"filepath"];
            NSArray *array = [fpath componentsSeparatedByString:@"/"];
            NSString *name = [array lastObject];
            
//            int downloadtype = ((NSString *)[dict objectForKey:@"downloadtype"]).intValue;
            
            NSString *newpath = [[self getNewDownloadDir:name] stringByAppendingPathComponent:name];
            [dict setObject:newpath forKey:@"filepath"];
        }
        
        if ([fm fileExistsAtPath:[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADINGFILENAME]]) {
            [fm removeItemAtPath:[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADINGFILENAME] error:nil];
        }
        
        NSString *shahedir = [[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:SHAHEDIR]stringByAppendingPathComponent:DOWNLOADINGFILENAME];
        
        if ([fm fileExistsAtPath:shahedir]) {
            [fm removeItemAtPath:shahedir error:nil];
        }
        snPath = nil;
        [self saveDownlaodList:YES];
        
        [_downalodItemArray removeAllObjects];
        
        for (NSDictionary *dict in _downalodDataArray) {
            NSString *fpath = [dict objectForKey:@"fpath"];
            NSArray *items = [dict objectForKey:@"items"];
            NSMutableArray *itemsArr = [NSMutableArray array];
            for (NSDictionary *itemdict in items) {
                DownloadItemInfo *item = [[DownloadItemInfo alloc] init];
                item.idx = [itemdict objectForKey:@"idx"];
                item.dirName = [itemdict objectForKey:@"dirName"];
                item.name = [itemdict objectForKey:@"name"];
                item.seconds = [itemdict objectForKey:@"seconds"];
                item.size = [itemdict objectForKey:@"size"];
                item.url = [itemdict objectForKey:@"url"];
                [itemsArr addObject:item];
            }
            
            DownloadInfo *downloadinfo = [[DownloadInfo alloc] init];
            downloadinfo.fpath = fpath;
            downloadinfo.webURL = [dict objectForKey:@"webURL"];
            downloadinfo.current = [dict objectForKey:@"current"];
            downloadinfo.filepath = [dict objectForKey:@"filepath"];
            downloadinfo.currentDSize = [dict objectForKey:@"currentDSize"];
            downloadinfo.type = ((NSNumber *)[dict objectForKey:@"downloadtype"]).intValue;
            downloadinfo.items = itemsArr;
            
            NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
            [itemDict setObject:downloadinfo forKey:@"item"];
            [itemDict setObject:fpath forKey:@"fpath"];
            [_downalodItemArray addObject:itemDict];
        }
        
    }
    
    @synchronized(_downalodCompletedArray){
        if (_downalodCompletedArray && _downalodCompletedArray.count > 0) {
            NSInteger count = _downalodCompletedArray.count;
            for (int i = 0; i< count; i++) {
                NSDictionary *dict = [_downalodCompletedArray objectAtIndex:i];
                NSMutableDictionary *newdict = [NSMutableDictionary dictionaryWithDictionary:dict];
                NSString *fpath = [dict objectForKey:@"filepath"];
                NSArray *array = [fpath componentsSeparatedByString:@"/"];
                NSString *name = [array lastObject];
                
//                int downloadtype = ((NSString *)[dict objectForKey:@"downloadtype"]).intValue;
                
                NSString *newpath = [[self getNewDownloadDir:name] stringByAppendingPathComponent:name];
                [newdict setObject:newpath forKey:@"filepath"];
                [_downalodCompletedArray replaceObjectAtIndex:i withObject:newdict];
                
            }
        }
        
        if ([fm fileExistsAtPath:[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME]]) {
            [fm removeItemAtPath:[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME] error:nil];
        }
        
        NSString *shahedir = [[DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:SHAHEDIR]stringByAppendingPathComponent:DOWNLOADCOMPLETEFILENAME];
        
        if ([fm fileExistsAtPath:shahedir]) {
            [fm removeItemAtPath:shahedir error:nil];
        }
        [self saveDownloadCompletedList:YES];
    }
    
    NSString *shahepath = [DOWNLOAD_VIDEO_DIR_PATH stringByAppendingPathComponent:SHAHEDIR];
    if ([fm fileExistsAtPath:shahepath]) {
        [fm removeItemAtPath:shahepath error:nil];
    }
}


-(NSMutableArray *)getDownloadCompleteArray
{
    return _downalodCompletedArray;
}

-(void)removeDownloadCompleteItems:(NSArray *)itemArray atIndex:(NSArray *)indexArray
{
    for (NSInteger i = 0; i < itemArray.count; i ++) {
        
        NSDictionary *dict = [itemArray objectAtIndex:i];
        
        @synchronized(_downalodCompletedArray) {
            [_downalodCompletedArray removeObject:dict];
        }
    }
    
    [self saveDownloadCompletedList:NO];
    
}
//-(void)deleteplayidentify:(NSString *)fp{
//    NSFileManager * manger = [NSFileManager defaultManager];
//    NSString * path = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
//    if ([manger fileExistsAtPath:path]) {
//        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
//        if ([dic objectForKey:fp]) {
//            [dic removeObjectForKey:fp];
//            [dic writeToFile:path atomically:YES];
//        }
//    }
//}

-(void)doCheckListVCBottomBtnStatus
{
    [[DownloadListVC sharedInstance] changePauseBtnStatus];
}

#pragma mark - public 

-(void)removeAllDownloadInfo
{
    [_downalodItemArray removeAllObjects];
    [_downalodTaskArray removeAllObjects];
    [_downalodDataArray removeAllObjects];
    [_downalodCompletedArray removeAllObjects];
    [self saveDownlaodList:NO];
    [self saveDownloadCompletedList:NO];
}

-(void)showFullDownloadingAlert
{
    BOOL isshow = [[NSUserDefaults standardUserDefaults] boolForKey:@"DOWNLOADCOUNTFULL"];
    if (!isshow) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"downloadingfulltip", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:NSLocalizedString(@"notips", @""),nil];
            alert.tag = AlertTagDownloadCountFull;
            [alert show];
        });
    }
}

-(void)dealloc {
    _downalodDataArray = nil;
}

@end
