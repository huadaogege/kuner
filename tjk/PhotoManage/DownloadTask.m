//
//  DownloadTask.m
//  tjk
//
//  Created by lipeng.feng on 15/7/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadTask.h"
#import "FileSystem.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "CustomFileManage.h"
#import "LogUtils.h"
#import "ServiceRequest.h"
#import "DownloadManager.h"
#import "DESUtils.h"
#import "PhotoClass.h"

#define IS_CHECK_WRITING 1

@implementation DownloadInfo

-(id)init{
    self = [super init];
    if(self){
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@implementation DownloadItemInfo

@end

@interface DownloadTask ()<ASIHTTPRequestDelegate,ASIProgressDelegate,ServiceRequestDelegate>{
    BOOL _setTime;
    unsigned long long _lastSize;
    unsigned long long _writeSize;
    unsigned long long _fileSize;
    NSInteger _tryCount;
    NSInteger _responcesCount;
    int writeSfp;
    BOOL  _writingData; // 是否正在向文件写数据
    BOOL  _requestDone;
    BOOL  _requestSuccess;
    BOOL  _canceled;
    BOOL  _requestStarted;
    BOOL  _whileWrite; // 是否在写数据的while循环中
    
    NSInteger _doanloadIndex;
    
    NSString *_newUrl;
    CGFloat   _progress;
    BOOL      isgetbytes;
    
    BOOL    _couldReceiveData; // 是否接收数据
//    // test 下载文件损坏日志
//    unsigned long  _totalSize;
//    unsigned long  _innerTotalSize;
}

@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) NSTimer* responcesTimer;
@property (nonatomic, retain) ASIHTTPRequest* request;
@property (nonatomic, retain) NSString* lastRedirectUrl;
@property (nonatomic, retain) NSMutableData* receivedData;
@property (nonatomic, retain) NSString* resultPath;
@property (nonatomic, retain) NSString* tmpPath;
@property (nonatomic, retain) NSString* toDir;
@property (nonatomic, retain) DownloadInfo* info;
@property (nonatomic, assign) id<DownloadProgressDelegate> delegate;

@end

@implementation DownloadTask

#pragma mark - Utility

- (NSUInteger)getLocationByContentRange:(NSString *)cntRange{
    
    NSRange endRange = [cntRange rangeOfString:@"-"];
    NSInteger location = NSNotFound;
    if (endRange.location != NSNotFound) {
        NSRange range = NSMakeRange(6, endRange.location-6);
        NSString *loc = [cntRange substringWithRange:range];
        location = [loc integerValue];
    }
    
    return location;
}

- (BOOL)shouldResumeWithReceiveLocation:(NSUInteger)location{
    // 是否需要重新请求续传
    if (_receivedData.length-location == 0) {
        return NO;
    }
    
    return YES;
}

- (void)resume
{
    // 取消当前请求
    [self cancel];
    
    // 启动下载
    [self performSelector:@selector(delayRetry) withObject:nil afterDelay:1];
}

#pragma mark - Interfaces

-(void)downloadFileWith:(DownloadInfo *)info toPath:(NSString *)toPath delegate:(id<DownloadProgressDelegate>)delegate  from:(NSInteger)index{
    _doanloadIndex = index;
    _toDir = toPath;
    _info = info;
    _tryCount = 0;
    writeSfp = -1;
    if (info.items && _doanloadIndex >= info.items.count && info.items.count > 0) {
        [self sendResult:NO];
        return;
    }
    if (info.items && info.items.count > 1) {
        DownloadItemInfo* itemInfo = (DownloadItemInfo*)[info.items objectAtIndex:_doanloadIndex];
        _toDir = [_toDir stringByAppendingPathComponent:itemInfo.dirName];
        FilePropertyBean *bean = [FileSystem readFileProperty:_toDir];
        if (!bean) {
            [[CustomFileManage instance] creatDir:toPath withCache:[[CustomFileManage instance] hasCacheWithPath:[toPath stringByDeletingLastPathComponent]]];
        }
    }
    else
    {
        
    }
    
     _delegate = delegate;
    [self performSelectorOnMainThread:@selector(updateUrls) withObject:nil waitUntilDone:NO];
    
    NSLog(@"DownloadTask -- downloadPath : %@",_info.fpath);
}

-(NSString*)privatePath {
    return _info.fpath;
}

-(NSInteger)listCount {
    return _info.items.count;
}

-(void)cancel {
    
    if (writeSfp >0 && !_whileWrite) {
//        NSLog(@"writeSfp >0 && !_whileWrite");
        [FileSystem kr_close:writeSfp];
        writeSfp = -1;
    }
    
    [_timer invalidate];
    _timer = nil;
    
    [_responcesTimer invalidate];
    _responcesTimer = nil;
    
    [_request clearDelegatesAndCancel];
    
    if (_requestStarted) {
        [_request markAsFinished];
    }
    
    [self checkread];
}

-(void)pause {
    if (writeSfp >0 && !_whileWrite) {
//        NSLog(@"writeSfp >0 && !_whileWrite");
        [FileSystem kr_close:writeSfp];
        writeSfp = -1;
    }
    _canceled = YES;
    
    [_timer invalidate];
    _timer = nil;
    
    [_responcesTimer invalidate];
    _responcesTimer = nil;
    
    [_request clearDelegatesAndCancel];
    
    if (_requestStarted) {
        [_request markAsFinished];
    }
    
    [self checkread];
}

+(NSString *)dealWithErrorChar:(NSString *)str
{
    NSString *name = str;
    for (NSString* errorStr in NAME_ERROR_CODE) {
        if ([name isKindOfClass:[NSString class]] && [name rangeOfString:errorStr].location != NSNotFound) {
            name = [name stringByReplacingOccurrencesOfString:errorStr withString:@"-"];
        }
    }
    return name;
}

+(NSString *)dealWithPointChar:(NSString *)str deletingPathExtension:(BOOL)isdelete
{
    NSString *name;
    NSString *pathExtension;
    if ([str isKindOfClass:[NSString class]]) {
        NSArray *array = [str componentsSeparatedByString:@"."];
        
        if (array.count > 2) {
            pathExtension = [array lastObject];
            for (int i = 0; i < array.count -1; i ++) {
                name = name?[NSString stringWithFormat:@"%@-%@",name,[array objectAtIndex:i]]:[array objectAtIndex:i];
            }
        }
        else{
            name = str;
        }
        
        if (pathExtension) {
            if (!isdelete) {
                name = [NSString stringWithFormat:@"%@.%@",name,pathExtension];
            }
            else{
                name = [NSString stringWithFormat:@"%@-%@",name,pathExtension];
            }
        }
        
    }
    
    return name;
}

#pragma mark - ServiceRequestDelegate

-(void)resultSuccess:(NSData *)data info:(id)info isBanben:(BOOL)isbanben originUrl:(NSString *)url{
    NSDictionary* weatherDic = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil]];
    NSArray* list  = [weatherDic objectForKey:@"list"];
    
    if ([list isKindOfClass:[NSNull class]]) {
        if (!_info.items || _info.items.count == 0) {
            [self performSelectorOnMainThread:@selector(delayToUpdateUrls) withObject:nil waitUntilDone:NO];
        }
        else{
            if (_info.items.count > _doanloadIndex) {
                
                [self sendTask:[_info.items objectAtIndex:_doanloadIndex]];
            }
        }
        return;
    }
    
    NSInteger itemcount = _info.items?_info.items.count : 0;
    
    NSString* m3u8Str = @"";
    NSString* durationStr = @"";
    BOOL isM3U8 = NO;
    if (list.count > 1) {
        isM3U8 = YES;
    }
    NSString* m3u8DirName;
    float maxLength = 0;
    //    float allLength = 0;
    
    NSString *downloadrootpath = [_info.filepath stringByDeletingLastPathComponent];
    
    NSString *type = (NSString *)[weatherDic objectForKey:@"video"];
    
    int restype = type? type.intValue : TYPE_VIDEO;
    _info.type = restype;
    
    for (NSInteger i = 0 ; i < list.count ; i ++) {
        NSDictionary* item = [list objectAtIndex:i];
        
        DownloadItemInfo* itemInfo = nil;
        if (i < _info.items.count) {
            itemInfo = [_info.items objectAtIndex:i];
        }
        if (!itemInfo) {
            itemInfo = [[DownloadItemInfo alloc] init];
        }
        NSString* tmpUrl = [item objectForKey:@"url"];
        tmpUrl = [self doReplaceSomeChar:tmpUrl];
        if([tmpUrl isKindOfClass:[NSNull class]] ||([tmpUrl rangeOfString:@"http"].location == NSNotFound && ![tmpUrl isEqualToString:@""])){
            
            return;
        }
        itemInfo.url = tmpUrl;
        itemInfo.idx = [item objectForKey:@"no"];
        itemInfo.name = [item objectForKey:@"name"];
        
        if ([itemInfo.name isKindOfClass:[NSNull class]]) {
            itemInfo.name = @"";
        }
        
        itemInfo.name = [DownloadTask dealWithPointChar:itemInfo.name deletingPathExtension:NO];
        //        NSRange inforange = [itemInfo.name rangeOfString:@"." options:NSBackwardsSearch];
        //        if (inforange.location != NSNotFound) {
        //            itemInfo.name = [itemInfo.name stringByReplacingOccurrencesOfString:@"." withString:@"-"];
        //
        //            itemInfo.name = [itemInfo.name stringByReplacingCharactersInRange:inforange withString:@"."];
        //        }
        if ([itemInfo.name isKindOfClass:[NSNull class]] || !itemInfo.name) {
            itemInfo.name = @"";
        }
        
        itemInfo.name = [DownloadTask dealWithErrorChar:itemInfo.name];
        
        //        itemInfo.name = [itemInfo.name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
        BOOL fromYunPan = ([_info.webURL rangeOfString:@"pan.baidu.com"].location != NSNotFound || [_info.webURL rangeOfString:@"yun.baidu.com"].location != NSNotFound) && BDUSS;
        NSString* name = fromYunPan && itemInfo.name ? itemInfo.name : itemInfo.url.lastPathComponent;
        if ([name isKindOfClass:[NSString class]]) {
            NSUInteger location = [name rangeOfString:@"?"].location;
            if (location != NSNotFound) {
                name = [name substringToIndex:location];
            }
        }
        
        
        name = [[name componentsSeparatedByString:@"&"] firstObject];
        
        if (isM3U8) {
            if (itemInfo.name.length > 0) {
                itemInfo.dirName = [NSString stringWithFormat:@"%@.m3u8",itemInfo.name];
                //                [[NSString stringWithFormat:@"%@.m3u8",itemInfo.name]stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            }
            else {
                itemInfo.dirName = [NSString stringWithFormat:@"%@.m3u8",name];
            }
            for (NSString* errorStr in NAME_ERROR_CODE) {
                if ([itemInfo.dirName isKindOfClass:[NSString class]] && [itemInfo.dirName rangeOfString:errorStr].location != NSNotFound) {
                    itemInfo.dirName = [itemInfo.dirName stringByReplacingOccurrencesOfString:errorStr withString:@"-"];
                }
            }
            if(i == 0){
                m3u8DirName = itemInfo.dirName;
            }
        }
        else {
            if(i == 0){
                m3u8DirName = itemInfo.name.length > 0 ? itemInfo.name : name;
            }
        }
        //            if (list.count > 1) {
        //                itemInfo.name = [NSString stringWithFormat:@"%@-%ld",itemInfo.name,((long)itemInfo.idx.integerValue + 1)];
        //            }
        NSString* nameStr = list.count > 1 ? [NSString stringWithFormat:@"%@.%ld",itemInfo.name,((long)itemInfo.idx.integerValue + 1)] : itemInfo.name;
        if (!nameStr || [nameStr isEqualToString:@""]) {
            itemInfo.name = [_info.filepath lastPathComponent];
        }
        else if([name pathExtension].length > 0){
            if ([itemInfo.name rangeOfString:@"."].location == NSNotFound) {
                itemInfo.name = [NSString stringWithFormat:@"%@.%@",nameStr,[name pathExtension]];
            }
        }
        else if([itemInfo.url isKindOfClass:[NSString class]] && ([itemInfo.url rangeOfString:@"flv"].location != NSNotFound || [itemInfo.url rangeOfString:@"FLV"].location != NSNotFound)){
            itemInfo.name = [NSString stringWithFormat:@"%@.flv",nameStr];
        }
        else {
            if (!fromYunPan) {
                itemInfo.name = [NSString stringWithFormat:@"%@.mp4",nameStr];
            }
        }
        //            m3u8FileName = [item objectForKey:@"name"];
        itemInfo.seconds = [item objectForKey:@"seconds"];
        if (maxLength < itemInfo.seconds.floatValue) {
            maxLength = itemInfo.seconds.floatValue;
        }
        if (isM3U8) {
            if (i == list.count - 1) {
                durationStr = [durationStr stringByAppendingString:[NSString stringWithFormat:@"%f",itemInfo.seconds.floatValue]];
            }
            else {
                durationStr = [durationStr stringByAppendingString:[NSString stringWithFormat:@"%f,",itemInfo.seconds.floatValue]];
            }
            m3u8Str = [m3u8Str stringByAppendingString:[NSString stringWithFormat:@"#EXTINF:%f,\n%@\n",itemInfo.seconds.floatValue,itemInfo.name]];
        }
        itemInfo.size = [item objectForKey:@"size"];
        
        if (_info.type == DOWN_TYPE_AUDIO) {
            if ((!itemInfo.name||[itemInfo.name isEqualToString:@""])) {
                itemInfo.name = [_info.filepath lastPathComponent];
            }
            else if ([itemInfo.name isKindOfClass:[NSString class]] && [itemInfo.name rangeOfString:@"."].location == NSNotFound){
                if (!fromYunPan) {
                    itemInfo.name = [NSString stringWithFormat:@"%@.mp3",itemInfo.name];
                }
            }
        }
        
        if ([itemInfo.name isKindOfClass:[NSString class]] && [itemInfo.name rangeOfString:@".php"].location != NSNotFound) {
            itemInfo.name = [NSString stringWithFormat:@"%@.mp4",[itemInfo.name substringToIndex:[itemInfo.name rangeOfString:@".php"].location]];
        }
        
        if (i >= _info.items.count) {
            if (itemInfo) {
                [_info.items addObject:itemInfo];
            }
        }
        NSString* nameTmp = [_info.filepath lastPathComponent];
        if (list.count == 1 && itemcount == 0 && ([_info.webURL rangeOfString:BAIDUYUN_DOWNLOAD_ANALYZE_URL].location == NSNotFound || [nameTmp rangeOfString:@"."].location == NSNotFound)) {
            if (!fromYunPan) {
                _info.filepath = [NSString stringWithFormat:@"%@.%@",_info.filepath,itemInfo.name.pathExtension?itemInfo.name.pathExtension:@"mp4"];
            }
            
        }
        
        if ([_info.filepath isKindOfClass:[NSString class]] && ([_info.filepath rangeOfString:@"_artist_"].location != NSNotFound || [_info.filepath rangeOfString:@"_video_"].location != NSNotFound)) {
            itemInfo.name = [_info.filepath lastPathComponent];
        }
        
        itemInfo.name = [itemInfo.name stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        
        if (!isM3U8) {
            NSString *laststr = [_info.filepath lastPathComponent];
            
            //            laststr = [laststr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            if ([laststr isKindOfClass:[NSNull class]]) {
                laststr = @"";
            }
            laststr = [DownloadTask dealWithPointChar:laststr deletingPathExtension:NO];
            //            NSRange infofilepathrange = [laststr rangeOfString:@"." options:NSBackwardsSearch];
            //            if (infofilepathrange.location != NSNotFound) {
            //                laststr = [laststr stringByReplacingOccurrencesOfString:@"." withString:@"-"];
            //
            //                laststr = [laststr stringByReplacingCharactersInRange:infofilepathrange withString:@"."];
            //            }
            
            _info.filepath = [[_info.filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:laststr];
            
            if ([itemInfo.name isKindOfClass:[NSString class]]) {
                itemInfo.name = [DownloadTask dealWithPointChar:itemInfo.name deletingPathExtension:NO];
                //                NSRange iteminfonamerange = [itemInfo.name rangeOfString:@"." options:NSBackwardsSearch];
                //                if (iteminfonamerange.location != NSNotFound) {
                //                    itemInfo.name = [itemInfo.name stringByReplacingOccurrencesOfString:@"." withString:@"-"];
                //
                //                    itemInfo.name = [itemInfo.name stringByReplacingCharactersInRange:iteminfonamerange withString:@"."];
                //                }
            }
            
        }
        
        //        itemInfo.name = [itemInfo.name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        //        _info.filepath = [_info.filepath stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        itemInfo.name = [self doReplaceSomeChar:itemInfo.name];
        _info.filepath = [self doReplaceSomeChar:_info.filepath];
        
        
        itemInfo.name = [self doDealName:itemInfo.name];
        NSString *laststring = [_info.filepath lastPathComponent];
        laststring = [self doDealName:laststring];
        _info.filepath = [[_info.filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:laststring];
        
        if (!isM3U8) {
            itemInfo.name = [_info.filepath lastPathComponent];
        }
    }
    
    FilePropertyBean *bean = [FileSystem readFileProperty:downloadrootpath];
    //    NSLog(@"path:%@",downloadrootpath);
    if (!bean) {
        [[CustomFileManage instance] creatDir:downloadrootpath withCache:[[CustomFileManage instance] hasCacheWithPath:[_toDir stringByDeletingLastPathComponent]]];
    }
    if (isM3U8) {
        m3u8Str = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-TARGETDURATION:%d\n#EXT-X-VERSION:3\n%@#EXT-X-ENDLIST\n",(int)(maxLength + 1),m3u8Str];
        NSString* dirpath = [downloadrootpath stringByAppendingPathComponent:m3u8DirName];
        FilePropertyBean *bean2 = [FileSystem readFileProperty:dirpath];
        if (!bean2) {
            [[CustomFileManage instance] creatDir:dirpath withCache:[[CustomFileManage instance] hasCacheWithPath:[_toDir stringByDeletingLastPathComponent]]];
        }
        [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:m3u8DirName] DataFile:[m3u8Str dataUsingEncoding:NSUTF8StringEncoding]];
        BOOL result = [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:@"durations.txt"] DataFile:[durationStr dataUsingEncoding:NSUTF8StringEncoding]];
        if (!result) {
            [FileSystem  writeFileToPath:[dirpath stringByAppendingPathComponent:@"durations.txt"] DataFile:[durationStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ : %d",[dirpath stringByAppendingPathComponent:@"durations.txt"],result]];
    }
    
    
    [[DownloadManager shareInstance] saveJuJiInfo:_info];
    
    if(_doanloadIndex < _info.items.count){
        DownloadItemInfo *taskiteminfo = [_info.items objectAtIndex:_doanloadIndex];
        
        if (!taskiteminfo.url||[taskiteminfo.url isKindOfClass:[NSNull class]]|| [taskiteminfo.url isEqualToString:@""]) {
            if(_delegate && [_delegate respondsToSelector:@selector(downloadFailedFile:atIndex:)]){
                
                [_delegate downloadFailedFile:_info.fpath atIndex:-1];
            }
        }
        else{
            [self sendTask:taskiteminfo];
        }
        
    }
    else {
        [self updateURLDone];
    }
}

-(void)resultFaile:(NSError *)error info:(id)info {
    if (_info.items && _info.items.count >0 && _info.items.count > _doanloadIndex) {
        [self sendTask:[_info.items objectAtIndex:_doanloadIndex]];
    }
    else{
        if (!_info.items || _info.items.count == 0) {
            [self performSelectorOnMainThread:@selector(delayToUpdateUrls) withObject:nil waitUntilDone:NO];
        }
    }
}



#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    _requestSuccess = NO;
    _fileSize = 0;
    _requestStarted = YES;
    [_responcesTimer invalidate];
    _responcesTimer = nil;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    
    if (_canceled || _fileSize != 0) {
        return;
    }
    
    // 即将收到的数据是否有效
     NSString  *contentRange = responseHeaders[@"Content-Range"];
    if (contentRange.length > 0) {
        NSInteger  location = [self getLocationByContentRange:contentRange];
        BOOL  resume = [self shouldResumeWithReceiveLocation:location];
        
//        _innerTotalSize = 0;
//        _totalSize = 0;
//        NSLog(@"DownloadTask -- didReceiveResponseHeaders -contentRange: %@ , resume: %d",contentRange,resume);
        if (resume) {
            _couldReceiveData = NO;
            [self resume];
            return;
        }
    }
    
    _couldReceiveData = YES;
    _fileSize = request.contentLength;
    
    if (_fileSize > 0 && (contentRange && [contentRange rangeOfString:@"bytes 0-"].location == NSNotFound)) {
        _fileSize += _info.currentDSize.integerValue;
    }
    if (contentRange && [contentRange rangeOfString:@"bytes 0-"].location != NSNotFound) {
        
        self.receivedData = [[NSMutableData alloc] init];
        [FileSystem kr_close:writeSfp];
        writeSfp = -1;
    }
    if (!_info.items || (!(_info.items && _info.items.count > 0 && _doanloadIndex < _info.items.count))) {
        return;
    }
    
    DownloadItemInfo* itemInfo = [_info.items objectAtIndex:_doanloadIndex];
    if(_fileSize > 0 && itemInfo.size.integerValue == 0){
        itemInfo.size = [NSString stringWithFormat:@"%ld",(long)_fileSize];
    }
    else if (itemInfo.size.integerValue > 0 && itemInfo.size.integerValue > _fileSize) {
        _fileSize = itemInfo.size.integerValue;
    }
    
    // _info.currentDSize _writeSize 赋值为真实变量
    _writeSize = _info.currentDSize.integerValue;
    if(self.receivedData.length < _info.currentDSize.integerValue){
        _info.currentDSize = [NSNumber numberWithInteger:self.receivedData.length];
        _writeSize = self.receivedData.length;
    }
    
    _requestDone = NO;
    _requestSuccess = NO;
    _responcesCount = 0;
    _responcesTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(responceTimeFire) userInfo:nil repeats:YES];
    
    if (writeSfp < 0) {
        
        FilePropertyBean *bean = [FileSystem readFileProperty:_resultPath];
        BOOL isexist = bean?YES :NO;
        
        writeSfp = [FileSystem kr_open:_resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
        if(writeSfp > 0){
            NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
            [FileSystem kr_fso_fsetattr:writeSfp size:_writeSize cttime:nowtime chtime:nowtime];
            
            if (!isexist) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DOWNCOMPELETE_NOTI object:[NSNumber numberWithInt:_info.type] userInfo:[NSDictionary dictionaryWithObject:_info.webURL forKey:@"weburl"]];
            }
            
            if (_info.items && _info.items.count > 1) {
                [FileSystem kr_fso_setattr:_toDir size:0 cttime:nowtime chtime:nowtime];
            }
        }
    }
    
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    if (_canceled) {
        return;
    }
    
    [_request redirectToURL:newURL];
    if(self.receivedData.length < _info.currentDSize.integerValue){
        _info.currentDSize = [NSNumber numberWithInteger:self.receivedData.length];
    }
    if (!(_info.items && _info.items.count > 0 && _doanloadIndex < _info.items.count)) {
        return;
    }
    DownloadItemInfo* itemInfo = [_info.items objectAtIndex:_doanloadIndex];
    if (itemInfo.size.integerValue > 0 && itemInfo.size.integerValue < _info.currentDSize.integerValue) {
        [_request addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%ld-",(long)(itemInfo.size.integerValue - 1)]];
        _info.currentDSize = [NSNumber numberWithInteger:(itemInfo.size.integerValue - 1)];
    }
    else {
        [_request addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%ld-",(long)_info.currentDSize.integerValue]];
    }
    _newUrl = newURL.absoluteString;
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    if (_canceled) {
        return;
    }
    _requestDone = YES;
    _requestSuccess = YES;
    [_responcesTimer invalidate];
    _responcesTimer = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_canceled) {
        return;
    }
    
    if (self.receivedData.length >= _fileSize && _fileSize > 0) {
        _requestDone = YES;
        [_responcesTimer invalidate];
        _responcesTimer = nil;
    }
    else {
        [_responcesTimer invalidate];
        _responcesTimer = nil;
        _responcesTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(responceTimeFire) userInfo:nil repeats:YES];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
    
    if (_couldReceiveData) {
        
        @synchronized(self) {
            _newUrl = nil;
            if (_timer) {
                [_timer invalidate];
                _timer = nil;
            }
            if (_canceled) {
                return;
            }
            
            if(data.length != 62){
                [self checkread];
                if (self.receivedData) {
                    [self.receivedData appendData:[data copy]];
                }
                if (!_writingData) {
                    _writingData = YES;
                    [self writeDataToFile];
                }
            }
            
            // 计时器计数 设置0
            _responcesCount = 0;
            
//            _innerTotalSize += data.length;
//            NSLog(@"didReceiveData: data.length(%lu) innerTotalSize ---------------- (%lu)",data.length,_innerTotalSize);
        }
    }
    
//    _totalSize += data.length;
//    NSLog(@"didReceiveData: data.length(%lu) totalSize(%lu)",data.length,_totalSize);
}

#pragma mark - Request Methods

-(void)delayToUpdateUrls
{
    _tryCount ++;
    if (_tryCount > 5) {
        [self pause];
        [self sendResult:NO];
        return;
    }
    [self performSelector:@selector(updateUrls) withObject:nil afterDelay:1];
}

-(void)delayRetry{
    [self performSelectorOnMainThread:@selector(updateUrls) withObject:nil waitUntilDone:NO];
}

-(void)sendTask:(DownloadItemInfo *)itemInfo{
    [NSThread detachNewThreadSelector:@selector(doSendtask:) toTarget:self withObject:itemInfo];
}

-(void)doSendtask:(DownloadItemInfo*)itemInfo{
    
    NSString *name = [self doReplaceSomeChar:itemInfo.name];
    _resultPath = [_toDir stringByAppendingPathComponent:name];
    
    if ([_resultPath isKindOfClass:[NSString class]]) {
        NSUInteger location = [_resultPath rangeOfString:@"?"].location;
        if (location != NSNotFound) {
            _resultPath = [_resultPath substringToIndex:location];
        }
    }
    
    if (writeSfp > 0) {
        [FileSystem kr_close:writeSfp];
        writeSfp = -1;
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ kr_close initURL",_resultPath]];
    }
    [self initReceiveData];
    _newUrl = itemInfo.url;
    [self performSelectorOnMainThread:@selector(initURL:) withObject:itemInfo.url waitUntilDone:NO];
}

-(void)updateUrls{
    //    NSLog(@"webURL : %@",_info.webURL);
    //    NSString* urlStr = @"http://www.kuke.com.cn/kuke/vedio/analyze.html?url=http%3A%2F%2Fm.kankan.com%2Fv%2F84%2F84705.shtml%3Fnew%3D1";
    
    NSLog(@"DownloadTask -- method updateUrls call");
    
    NSString* urlStr = [NSString stringWithFormat:@"%@&time=%ld",_info.webURL,time(0)];
    [[ServiceRequest instance] requestService:nil urlAddress:urlStr info:nil delegate:self isBanben:NO];
}

-(void)initURL:(NSString*)url{
    writeSfp = -1;
    _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    [_request setDownloadDestinationPath:_tmpPath];
    [_request setTemporaryFileDownloadPath:[_tmpPath stringByAppendingPathExtension:@"tmp"]];
    [_request setShouldContinueWhenAppEntersBackground:YES];
    [_request setDelegate:self];
    [_request setPersistentConnectionTimeoutSeconds:5];
    [_request setRequestMethod:@"GET"];
    [_request setDownloadProgressDelegate:self];
    [_request setNumberOfTimesToRetryOnTimeout:3];
    [_request setAllowResumeForFileDownloads:YES];
    _info.currentDSize = [NSNumber numberWithInteger:self.receivedData.length];
    NSLog(@"DownloadTask -initURL- _info.currentDSize %@ : %ld",_resultPath,self.receivedData.length);
    [_request addRequestHeader:@"Range" value:[NSString stringWithFormat:@"bytes=%ld-",(long)_info.currentDSize.integerValue]];
    [_request startAsynchronous];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeFire:) userInfo:url repeats:NO];
}

#pragma mark - Receive Data About Methods

-(void)writeDataToFile{
    if (_fileSize == 0 || _canceled) {
        _writingData = NO;
        return;
    }
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        if (writeSfp < 0) {
            writeSfp = [FileSystem kr_open:_resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
            if(writeSfp > 0){
                [LogUtils writeLog:[NSString stringWithFormat:@"%@ kr_open writeDataToFile",_info.filepath]];
            }
            else{
                [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL writeDataToFile errrno:%d ，path %@ ",errno,_info.filepath]];
                NSLog(@"%@ writeDataToFile errrno:%d",DEBUGMODEL,errno);
            }
        }
        
        if(writeSfp >0 && !_canceled){
            if (!_setTime) {
                _setTime = YES;
            }
            NSInteger fileSize = self.receivedData.length;
            FilePropertyBean *bean = [FileSystem readFileProperty:_resultPath];
            
            if (bean) {
                [FileSystem kr_seek:writeSfp offset:(int)_writeSize fromwhere:0];
            }
            
            size_t sizeof_buff = RW_BUFFER_SIZE;
            char* buff = (char*)malloc(sizeof_buff);
            float length = 0;
            
            if(buff){
                @try {
                    while (writeSfp > 0 && 0 < fileSize && !_canceled && buff) {
                        _whileWrite = YES;
                        memset(buff, 0, sizeof_buff);
                        fileSize = self.receivedData.length;
                        length = _writeSize + sizeof_buff < fileSize ? sizeof_buff : (fileSize - _writeSize);
                        if (length > 0) {
                            if(_writeSize + length >= self.receivedData.length){
                                length = self.receivedData.length - _writeSize;
                            }
                            if (self.receivedData.length > 0 && length > 0) {
                                
                                if (_canceled) {
                                    break;
                                }
                                if ([self.receivedData respondsToSelector:@selector(getBytes:length:)]) {
                                    NSRange range = NSMakeRange(_writeSize, length);
                                    if (range.location != NSNotFound) {
                                        
                                        isgetbytes = YES;
                                        [self.receivedData getBytes:buff range:range];
                                        isgetbytes = NO;
                                    }
                                    else{
                                        [LogUtils writeLog:[NSString stringWithFormat:@"%@ self.receivedData nsrange notfound",DEBUGMODEL]];
                                    }
                                }
                                else{
                                    [LogUtils writeLog:[NSString stringWithFormat:@"%@ self.receivedData respondsToSelector:@selector(getBytes:length: error",DEBUGMODEL]];
                                }
                                
                            }
                            errno = 0;
                            ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                            
                            if(writeLength >= 0){
                                _writeSize += writeLength;
                                BOOL needShow = (_writeSize >= fileSize) && (_writeSize >= _fileSize) && _fileSize > 0;
                                
                                NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970];
                                if (_info.items && _info.items.count > 1) {
                                    [FileSystem kr_fso_setattr:_toDir size:0 cttime:nowtime chtime:nowtime];
                                }
                                else{
                                    [FileSystem kr_fso_fsetattr:writeSfp size:_writeSize cttime:nowtime chtime:nowtime];
                                }
                                
                                if (_requestDone && needShow) {
                                    free(buff);
                                    buff = NULL;
                                }
                                
                                [self changeProgress:[NSNumber numberWithFloat:_writeSize]];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (_requestDone && needShow) {
                                        if (_writeSize >= fileSize) {
                                            [self cancel];
                                            [self sendResult:YES];
                                            _doanloadIndex ++;
                                            
                                            if (_info.items.count > _doanloadIndex) {
                                                _fileSize = 0;
                                                NSFileManager * fm = [NSFileManager defaultManager];
                                                [fm removeItemAtPath:_tmpPath error:nil];
                                                
                                                _writingData = NO;
                                                [self sendTask:[_info.items objectAtIndex:_doanloadIndex]];
                                            }
                                        }
                                        else
                                        {
                                            [LogUtils writeLog:[NSString stringWithFormat:@"%@ dddddd error",_info.filepath]];
                                            
                                            _writingData = NO;
                                            [self pause];
                                            [self sendResult:NO];
                                        }
                                        
                                        return;
                                    }
                                });
                            }
                            else{
                                if (![self needRetry]) {
                                    return;
                                }
                                free(buff);
                                buff = NULL;
                                [FileSystem flushData];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [LogUtils writeLog:[NSString stringWithFormat:@"%@ %@ write length error",DEBUGMODEL,_info.filepath]];
                                    [self timeFire:nil];
                                });
                                _writingData = NO;
                                return;
                            }
                        }
                        else {
                            free(buff);
                            buff = NULL;
                            [FileSystem flushData];
                            
                            _writingData = NO;
                            return;
                        }
                        
                        if (_requestDone) {
                            fileSize = self.receivedData.length;
                        }
                    }
                    _whileWrite = NO;
                    free(buff);
                    buff = NULL;
                    if(!_canceled && _writeSize > fileSize && writeSfp > 0){
                        [FileSystem flushData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [LogUtils writeLog:[NSString stringWithFormat:@"%@ write length more",_info.filepath]];
                            [self timeFire:nil];
                        });
                        
                        _writingData = NO;
                        return;
                    }
                }
                @catch (NSException *exception) {
//                    NSLog(@"writeDataToFile exception : %@",exception);
                    free(buff);
                    buff = NULL;
                    [FileSystem flushData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LogUtils writeLog:[NSString stringWithFormat:@"%@ exception error",_info.filepath]];
                        [self timeFire:nil];
                    });
                    _writingData = NO;
                    return;
                }
                @finally {
                    
                }
            }
            
            [FileSystem flushData];
        }
        else{
            NSLog(@"open error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [LogUtils writeLog:[NSString stringWithFormat:@"%@ open error",_info.filepath]];
                [self timeFire:nil];
            });
        }
        if (writeSfp >0 && _canceled) {
//            NSLog(@"writeSfp >0 && _canceled");
            [FileSystem kr_close:writeSfp];
            writeSfp = -1;
        }
        
        _writingData = NO;
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ writeDataToFile end",DEBUGMODEL]];
    });
    
}

-(void)initReceiveData{
    
    NSString* tmpDir = [[APP_DOC_ROOT stringByAppendingPathComponent:@"Download"] stringByAppendingPathComponent:@"video"];
    _tmpPath = [tmpDir stringByAppendingPathComponent:[_resultPath lastPathComponent]];
    _fileSize = 0;
    FilePropertyBean *bean = [FileSystem readFileProperty:_resultPath];
    
    if (!bean) {
        [self checkread];
        _receivedData = [[NSMutableData alloc] init];
    }
    else {
        [self checkread];
        _receivedData = [[NSMutableData alloc] initWithLength:bean.size];
        _writeSize = self.receivedData.length;
    }
}

-(void)sendResult:(BOOL)success{
    if (writeSfp >0) {
        [FileSystem kr_close:writeSfp];
        writeSfp = -1;
        [FileSystem flushData];
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ kr_close sendResult",_resultPath]];
    }
    if (success) {
        if(_delegate && [_delegate respondsToSelector:@selector(downloadSuccessedFile:atIndex:finish:)]){
            
            [_delegate downloadSuccessedFile:_info.fpath atIndex:_doanloadIndex finish:((_doanloadIndex + 1) == _info.items.count)];
            if ((_doanloadIndex + 1) == _info.items.count) {
                [self cancel];
            }
        }
    }
    else {
        if ((_doanloadIndex + 1) == _info.items.count) {
            DownloadInfo* tmpInfo = _info;
            CGFloat totalsize = 0;
            CGFloat loadedsize = 0;
            for (int i = 0; i < tmpInfo.items.count; i++) {
                DownloadItemInfo *item = (DownloadItemInfo *)[tmpInfo.items objectAtIndex:i];
                totalsize += item.size.floatValue;
                if (_doanloadIndex > i) {
                    loadedsize += item.size.floatValue;
                }
            }
            CGFloat realProgress = [NSString stringWithFormat:@"%.4f",(_writeSize + loadedsize ) / totalsize].floatValue;
            
            if (realProgress > 0.991) {
                if(_delegate && [_delegate respondsToSelector:@selector(downloadSuccessedFile:atIndex:finish:)]){
                    
                    [_delegate downloadSuccessedFile:_info.fpath atIndex:_doanloadIndex finish:((_doanloadIndex + 1) == _info.items.count)];
                    if ((_doanloadIndex + 1) == _info.items.count) {
                        [self cancel];
                    }
                }
            }
        }
        else{
            if(_delegate && [_delegate respondsToSelector:@selector(downloadFailedFile:atIndex:)]){
                
                [_delegate downloadFailedFile:_info.fpath atIndex:_doanloadIndex];
            }
        }
    }
    
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:_tmpPath error:nil];
}

#pragma mark - NSTimer Methods

-(void)timeFire:(NSTimer*)timerTmp{
//    NSLog(@"timeFire : %@",_newUrl);
    _whileWrite = NO;
    [_timer invalidate];
    _timer = nil;
    if (_canceled) {
        return;
    }
    
    _tryCount ++;
    if (_tryCount > 3) {
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ %@ timeFire: error",DEBUGMODEL,_info.filepath]];
        [self pause];
        [self sendResult:NO];
        return;
    }
    
    [self cancel];
    [self performSelector:@selector(delayRetry) withObject:nil afterDelay:1];
}

-(void)responceTimeFire {
//    NSLog(@"responceTimeFire : %@",_newUrl);
    
    if (_canceled) {
        [_responcesTimer invalidate];
        _responcesTimer = nil;
        return;
    }
    
    if (_writingData) {
        return ;
    }
    
    _responcesCount ++;
//    NSLog(@"responceTimeFire _responcesCount: %ld",(long)_responcesCount);
    if (_responcesCount > 4) {
        _tryCount = 0;
        _responcesCount = 0;
        [_responcesTimer invalidate];
        _responcesTimer = nil;
        [self cancel];
        [self performSelector:@selector(delayRetry) withObject:nil afterDelay:1];
    }
}

#pragma mark -

-(BOOL)checkisFromYunWith:(NSString *)url
{
    NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
    BOOL fromYunPan = ([url rangeOfString:@"pan.baidu.com"].location != NSNotFound || [url rangeOfString:@"yun.baidu.com"].location != NSNotFound) && BDUSS;
    return fromYunPan;
}

-(NSString *)doReplaceSomeChar:(NSString *)oldstr
{
    if ([oldstr isKindOfClass:[NSNull class]] || ![oldstr isKindOfClass:[NSString class]]) {
        return @"";
    }
    NSString *string = oldstr;
    if([string rangeOfString:@"\r\n"].location != NSNotFound){
        string  = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    }
    if([string rangeOfString:@"\n"].location != NSNotFound){
        string  = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    if([string rangeOfString:@"\t"].location != NSNotFound){
        string  = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    return string;
}

-(NSString *)doDealName:(NSString *)oldstr
{
    if ([oldstr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString *string = oldstr;
    if([string rangeOfString:@"&"].location != NSNotFound){
        string  = [string stringByReplacingOccurrencesOfString:@"&" withString:@""];
    }
    if([string rangeOfString:@";"].location != NSNotFound){
        string  = [string stringByReplacingOccurrencesOfString:@";" withString:@""];
    }
    
    for (NSString* errorStr in NAME_ERROR_CODE) {
        if ([string  rangeOfString:errorStr].location != NSNotFound) {
            string = [string stringByReplacingOccurrencesOfString:errorStr withString:@"-"];
        }
    }
    
    return string;
}

-(void)updateURLDone{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelectorOnMainThread:@selector(changeProgress:) withObject:[NSNumber numberWithFloat:_writeSize] waitUntilDone:YES];
        if (_requestDone) {
//            NSLog(@"%ld :: %ld",_writeSize,_fileSize);
        }
        [self cancel];
        if (_requestDone) {
            [self sendResult:YES];
        }
        else {
            [self sendResult:NO];
        }
    });
}

-(void)checkread
{
//    if (IS_CHECK_WRITING && isgetbytes) {
//        [NSThread sleepForTimeInterval:0.05];
//        [self checkread];
//    }
}

-(BOOL)needRetry{
    HardwareInfoBean *infobean = [FileSystem get_info];
    BOOL needtry = YES;
    if (infobean) {
        unsigned long long size = infobean.free_size;
        NSLog(@"errno : %d , empty size : %llu",errno,size);
        
        if ((errno == 28 || size == 0) && [FileSystem checkInit]) {
            [self sendDownloadErrorPause:NSLocalizedString(@"downloaderrorspace", @"")];
            needtry = NO;
        }
    }
    else{
        needtry = NO;
    }
    
    return needtry;
}

-(void)sendDownloadErrorPause:(NSString*)message {    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_STATUS_NEED_PAUSE" object:message];
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:_tmpPath error:nil];
}

- (void)setProgress:(float)newProgress {
    _progress = newProgress;
//    [self performSelectorOnMainThread:@selector(changeProgress:) withObject:[NSNumber numberWithFloat:newProgress] waitUntilDone:YES];
}

-(void)changeProgress:(NSNumber*)size{
    if(_delegate && [_delegate respondsToSelector:@selector(downloadProgress:filepath:atIndex:count:)]){
        [_delegate downloadProgress:size.integerValue filepath:_info.fpath atIndex:_doanloadIndex count:_info.items.count];
    }
}

-(void)dealloc {
    _receivedData = nil;
    NSLog(@"dealloc DownloadTask");
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ DownloadTask dealloc : %@ ",DEBUGMODEL,_resultPath]];
    if (writeSfp >0) {
//        NSLog(@"dealloc");
        int ret = [FileSystem kr_close:writeSfp];
        writeSfp = -1;
        [LogUtils writeLog:[NSString stringWithFormat:@"%@: %@ kr_close dealloc result:%d,errno:%d",DEBUGMODEL,_resultPath,ret,errno]];
    }
    [self pause];
}

@end
