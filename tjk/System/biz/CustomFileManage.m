//
//  CustomFileManage.m
//  tjk
//
//  Created by ??ºÂ????ºÂ????? on 15/3/24.
//  Copyright (c) 2015Âπ? taig. All rights reserved.
//

#import "CustomFileManage.h"
#import "FileBean.h"
#import "VideoInfoUtiles.h"
#import "DESUtils.h"
#import "LogUtils.h"
#import "AppDelegate.h"
#import "CustomAlertView.h"
#import "DownloadListVC.h"
#import "ShareToHelper.h"
#import "PhotoInfoUtiles.h"

#define CACHE_COUNT 120

typedef BOOL(^ContinueBlock)(NSString* filePath);

@interface CustomFileManage (){
    BOOL isPhotoOutCancel;
    BOOL isCopyCancel;
    BOOL _isSystemInited;
}
@property (retain, atomic) NSMutableDictionary *cachePathDic;
@property (retain, atomic) NSMutableDictionary *imgFileCachePathDic;
@property (retain, atomic) NSMutableDictionary *processPathDic;
@property (retain, atomic) NSMutableDictionary *processMediaPathDic;
@end

@implementation CustomFileManage

static CustomFileManage *cfm = NULL;
+(CustomFileManage *)instance{
    
    if(cfm == NULL){
        
        cfm = [[CustomFileManage alloc] init];
    }
    return cfm;
}

-(instancetype)init{
    
    self = [super init];
    if(self){
        
        self.cachePathDic = [[NSMutableDictionary alloc] init];
        self.imgFileCachePathDic = [[NSMutableDictionary alloc] init];
        self.processPathDic = [[NSMutableDictionary alloc] init];
        self.processMediaPathDic = [[NSMutableDictionary alloc] init];
        _cacheIconDic = [[NSMutableDictionary alloc] init];
        
        _cacheDefaultIconDic = [[NSMutableDictionary alloc] init];
        _cacheMediaDic = [[NSMutableDictionary alloc] init];
        _cacheIconAry = [[NSMutableArray alloc] init];
        _queueAry = [[NSMutableArray alloc] init];
        _dispatchQueue  = dispatch_queue_create("CustomFileManage", DISPATCH_QUEUE_SERIAL);
        _dispatchMusicQueue = dispatch_queue_create("CustomFileManage_Music", DISPATCH_QUEUE_SERIAL);
        _isCache = YES;
        _isAction = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CustomAlertShowprogress:) name:CUSTOMALERTSHOWPROGRESS object:nil];
    }
    return self;
}

+(FILE_POSITION)getFilePosition:(NSString*)path{
    if([path hasPrefix:KE_PHOTO] || [path hasPrefix:KE_VIDEO] || [path hasPrefix:KE_MUSIC] || [path hasPrefix:KE_DOC] || [path hasPrefix:KE_ROOT]){
        return POSITION_HARDDISK;
    }else{
        return POSITION_DEVICE;
    }
}

+(BOOL)isDownloadedDir:(NSString*)path{
    return [path isEqualToString:RealDownloadVideoPath] || [path isEqualToString:RealDownloadAudioPath] || [path isEqualToString:RealDownloadPicturePath] || [path isEqualToString:RealDownloadDocumentPath];
}

+(BOOL)isDownloadedSubDir:(NSString*)path{
    return [path hasPrefix:RealDownloadVideoPath] || [path hasPrefix:RealDownloadAudioPath] || [path hasPrefix:RealDownloadPicturePath] || [path hasPrefix:RealDownloadDocumentPath];
}

+(NSString*)getDownloadDir:(NSString*)name{
    NSString *exName = [[name pathExtension] lowercaseString];
    if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
        return RealDownloadVideoPath;
    }
    else if([MUSIC_EX_DIC objectForKey:exName]){
        return RealDownloadAudioPath;
    }
    else  if([PICTURE_EX_DIC objectForKey:exName] || [GIF_EX_DIC objectForKey:exName]){
        return RealDownloadPicturePath;
    }
    else {
        return RealDownloadDocumentPath;
    }
}

-(void)setSystemInited:(BOOL)inited {
    _isSystemInited = inited;
}

-(BOOL)isSystemInited{
    return _isSystemInited;
}


-(void)fileOperateCancel:(NSNotification *)noti
{
    if ([noti.name isEqualToString:FILE_OPERATION_CANCEL] && (((NSNumber *)noti.object).intValue == Alert_Copy || ((NSNumber *)noti.object).intValue == Alert_PhotoOut)) {
        if (((NSNumber *)noti.object).intValue == Alert_Copy) {
            isCopyCancel = YES;
        }
        else if (((NSNumber *)noti.object).intValue == Alert_PhotoOut){
            isPhotoOutCancel = YES;
        }
    }
}

-(void)CustomAlertShowprogress:(NSNotification *)noti
{
    if ([noti.name isEqualToString:CUSTOMALERTSHOWPROGRESS]) {
        isPhotoOutCancel = NO;
        isCopyCancel = NO;
    }
}

-(void)dealloc{
    
    if (_dispatchQueue) {
        
        dispatch_object_t _o = (_dispatchQueue);
        _dispatch_object_validate(_o);
        _dispatchQueue = NULL;
    }
    self.cachePathDic = nil;
    self.imgFileCachePathDic = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initSystem{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [FileSystem tgk_fso_init];
    });
}

-(BOOL)formatSystem{
    
    [self removeFileOrDir:[FileSystem getCachePath]];
    [self cleanPathCacheAll];
    
    return [FileSystem fso_format];
}

-(UIImage *)getFileIcon:(FileBean *)bean{

    NSString *cacheName = [self getCacheName:bean];
    UIImage *img = [_cacheIconDic objectForKey:cacheName];
    if(img == nil){
        NSString* dirPath = [self getFileIconCacheDir:bean.filePath];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:dirPath]) {
            [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *imgPath = [[self getFileIconCacheDir:bean.filePath] stringByAppendingPathComponent:cacheName];
        img = [UIImage imageWithContentsOfFile:imgPath];
        if(img == nil){
            NSError *err;
            [[NSFileManager defaultManager] removeItemAtPath:imgPath error:&err];

            switch (bean.fileType) {
                case FILE_IMG:{
                    NSData *data = [FileSystem kr_readData:bean.filePath];
                    img = [UIImage imageWithData:data];
                    break;
                }
                case FILE_GIF:{
                    
                    img = [UIImage imageWithData:[FileSystem kr_readData:bean.filePath]];
                    break;
                }
                case FILE_MOV:{
                    
                    MediaBean *_mediaDic = [self getMediaCache:bean];
                    img = _mediaDic.img ? _mediaDic.img : [[CustomFileManage instance] getDefaultIconForCache:bean resType:Video_Res_Type];
                    break;
                }
                case FILE_MUSIC:{
                    
                    MediaBean *_mediaDic = [self getMediaCache:bean];
                    img = _mediaDic.img;
                    break;
                }
                case FILE_VIDEO:{
                    
                    MediaBean *_mediaDic = [self getMediaCache:bean];
                    img = _mediaDic.img ? _mediaDic.img : [[CustomFileManage instance] getDefaultIconForCache:bean resType:Video_Res_Type];
                    break;
                }
                case FILE_DOC:{
                    
                    img = [UIImage imageNamed:[DOC_EX_DIC objectForKey:[bean.filePath pathExtension]]];
                    break;
                }
                case FILE_DIR:{
                    
                    img = [UIImage imageNamed:@"list_icon-folder.png" bundle:@"TAIG_FILE_LIST.bundle"];
                    break;
                }
                    
                default:
                    
                    img = [UIImage imageNamed:@"list_icon-unknow.png" bundle:@"TAIG_FILE_LIST.bundle"];
                    break;
            }
            
            if(img){
                img = [self getSquareImg:img];
                if(img){
                    
                    NSData *imgData;
                    if([[[bean.filePath pathExtension] lowercaseString] isEqualToString:@"png"]){
                        
                        imgData = UIImagePNGRepresentation(img);
                    }else{
                        
                        imgData = UIImageJPEGRepresentation(img, 1.0);
                    }
                    
                    [imgData writeToFile:imgPath atomically:YES];
                    imgData = nil;
                }
            }
        }
        
        if(_cacheIconAry.count > CACHE_COUNT){
            
            [_cacheIconDic removeObjectForKey:[_cacheIconAry objectAtIndex:0]];
            [_cacheIconAry removeObjectAtIndex:0];
        }
        if(img){
            [_cacheIconDic setObject:img forKey:cacheName];
            [_cacheIconAry addObject:cacheName];
        }
    }
    return img;
}

-(void)getFileIconForBlock:(FileBean *)bean info:(id)info block:(void(^)(UIImage *img, id info))block{
    dispatch_async(_dispatchQueue, ^{
        UIImage *img = [self getFileIcon:bean];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(img, info);
        });
    });
}

-(void)requestFileIcon:(FileBean *)bean{
    BOOL hasIn = NO;
    for (FileBean * tmp in _queueAry) {
        if ([tmp.filePath isEqualToString:bean.filePath]) {
            hasIn = YES;
            break;
        }
    }
    if (!hasIn) {
        
        [_queueAry addObject:bean];
        if(!_isAction){
            [self actionFileIcon];
        }
    }
}

-(void)actionFileIcon{
    _isAction = YES;
    dispatch_async(dispatch_queue_create(0, 0), ^{
        FileBean *bean = [_queueAry firstObject];
        if ([bean isKindOfClass:[FileBean class]]) {
            _currentpath = bean.filePath;
            UIImage *img = [self getFileIcon:bean];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:bean.filePath object:nil userInfo:nil];
                }
                
                if ([_queueAry containsObject:bean]) {
                    [_queueAry removeObjectAtIndex:0];
                }
                
                if(_queueAry.count > 0){
                    [self actionFileIcon];
                }else{
                    _isAction = NO;
                }
            });
        }
        else{
            if(_queueAry.count > 0){
                [self actionFileIcon];
            }else{
                _isAction = NO;
            }
        }
        
    });
}

-(BOOL)cancelRequest:(NSString *)path{
    if (![path isEqual:_currentpath]) {
        for (FileBean * beanTmp in _queueAry) {
            if ([beanTmp.filePath isEqual:path]) {
                [_queueAry removeObject:beanTmp];
                return YES;
            }
        }
    }
    return NO;
}

-(void)setKukeDeleteFileCache:(BOOL)deleted {
    _kukeDeletedCache = deleted;
}

-(BOOL)isKukeDeletedFileCache {
    return _kukeDeletedCache;
}

-(UIImage *)getFileIconForCache:(FileBean *)bean{
    NSString *cacheName = [self getCacheName:bean];
    return [_cacheIconDic objectForKey:cacheName];
}

-(UIImage *)getDefaultIconForCache:(FileBean *)bean resType:(NSInteger)res_type{
    
    if (bean.fileType == FILE_MOV || bean.fileType == FILE_GIF || bean.fileType == FILE_IMG) {
        if (![_cacheDefaultIconDic objectForKey:@"photo"]) {
            [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list-image-default" bundle:@"TAIG_FILE_LIST"] forKey:@"photo"];
        }
        return [_cacheDefaultIconDic objectForKey:@"photo"];
    }
    else if (bean.fileType == FILE_VIDEO) {
        if (![_cacheDefaultIconDic objectForKey:@"video"]) {
            [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list-video-default" bundle:@"TAIG_FILE_LIST"] forKey:@"video"];
        }
        return [_cacheDefaultIconDic objectForKey:@"video"];
    }
    else if (bean.fileType == FILE_MUSIC) {
        if (![_cacheDefaultIconDic objectForKey:@"music"]) {
            [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list-music-default" bundle:@"TAIG_FILE_LIST"] forKey:@"music"];
        }
        return [_cacheDefaultIconDic objectForKey:@"music"];
    }
    else if (bean.fileType == FILE_DOC) {
        NSString * kind = [[bean.filePath pathExtension] lowercaseString];
        if([kind isEqualToString:DOCUMENT_TXT]){
            if (![_cacheDefaultIconDic objectForKey:@"txt"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-txt" bundle:@"TAIG_FILE_LIST"] forKey:@"txt"];
            }
            return [_cacheDefaultIconDic objectForKey:@"txt"];
        }else if ([kind isEqualToString:DOCUMENT_PDF]){
            if (![_cacheDefaultIconDic objectForKey:@"pdf"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-pdf" bundle:@"TAIG_FILE_LIST"] forKey:@"pdf"];
            }
            return [_cacheDefaultIconDic objectForKey:@"pdf"];
        }
        else if ([kind isEqualToString:DOCUMENT_HTML]){
            if (![_cacheDefaultIconDic objectForKey:@"html"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-html" bundle:@"TAIG_FILE_LIST"] forKey:@"html"];
            }
            return [_cacheDefaultIconDic objectForKey:@"html"];
        }
        else if ([kind isEqualToString:DOCUMENT_RTF]){
            if (![_cacheDefaultIconDic objectForKey:@"rtf"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-rtf" bundle:@"TAIG_FILE_LIST"] forKey:@"rtf"];
            }
            return [_cacheDefaultIconDic objectForKey:@"rtf"];
        }
        else if ([kind isEqualToString:DOCUMENT_DOC] || [kind isEqualToString:DOCUMENT_DOCX]){
            if (![_cacheDefaultIconDic objectForKey:@"doc"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-doc" bundle:@"TAIG_FILE_LIST"] forKey:@"doc"];
            }
            return [_cacheDefaultIconDic objectForKey:@"doc"];
        }
        else if ([kind isEqualToString:DOCUMENT_PPT] || [kind isEqualToString:DOCUMENT_PPTX]){
            if (![_cacheDefaultIconDic objectForKey:@"ppt"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-ppt" bundle:@"TAIG_FILE_LIST"] forKey:@"ppt"];
            }
            return [_cacheDefaultIconDic objectForKey:@"ppt"];
        }
        else if ([kind isEqualToString:DOCUMENT_XLS] || [kind isEqualToString:DOCUMENT_XLSX]){
            if (![_cacheDefaultIconDic objectForKey:@"xls"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-xls" bundle:@"TAIG_FILE_LIST"] forKey:@"xls"];
            }
            return [_cacheDefaultIconDic objectForKey:@"xls"];
        }
    }
    else if (bean.fileType == FILE_DIR) {
        if (res_type == Video_Res_Type) {
            if (![_cacheDefaultIconDic objectForKey:@"videolist"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-videolist" bundle:@"TAIG_FILE_LIST"] forKey:@"videolist"];
            }
            return [_cacheDefaultIconDic objectForKey:@"videolist"];
        }
        else if (res_type == Music_Res_Type)
        {
            if (![_cacheDefaultIconDic objectForKey:@"musiclist"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-musiclist" bundle:@"TAIG_FILE_LIST"] forKey:@"musiclist"];
            }
            return [_cacheDefaultIconDic objectForKey:@"musiclist"];
        }
        else if (res_type == Picture_Res_Type)
        {
            if (![_cacheDefaultIconDic objectForKey:@"imagefolder"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon_imagefolder" bundle:@"TAIG_FILE_LIST"] forKey:@"imagefolder"];
            }
            return [_cacheDefaultIconDic objectForKey:@"imagefolder"];
        }
        else{
            if (![_cacheDefaultIconDic objectForKey:@"folder"]) {
                [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-folder" bundle:@"TAIG_FILE_LIST"] forKey:@"folder"];
            }
            return [_cacheDefaultIconDic objectForKey:@"folder"];
        }
    }
    else if (bean.fileType == FILE_NONE) {
        if (![_cacheDefaultIconDic objectForKey:@"unknow"]) {
            [_cacheDefaultIconDic setObject:[UIImage imageNamed:@"list_icon-unknow" bundle:@"TAIG_FILE_LIST"] forKey:@"unknow"];
        }
        return [_cacheDefaultIconDic objectForKey:@"unknow"];
    }
    return nil;
}

-(void)removeFileIconCache:(FileBean *)bean{
    NSString *cacheName = [self getCacheName:bean];
    if ([_cacheIconDic objectForKey:cacheName]) {
        [_cacheIconDic removeObjectForKey:cacheName];
    }
    NSString *imgPath = [[self getFileIconCacheDir:bean.filePath] stringByAppendingPathComponent:cacheName];
    [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
}

-(void)removeFileIconWithPath:(NSString *)filepath filesize:(float)size
{
    NSString *cacheName = [self getCacheNameWithName:[filepath lastPathComponent] size:size];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_clear",filepath] object:@"Clear"];
    if ([_cacheIconDic objectForKey:cacheName]) {
        [_cacheIconDic removeObjectForKey:cacheName];
    }
    NSString *imgPath = [[self getFileIconCacheDir:filepath] stringByAppendingPathComponent:cacheName];
    [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
}

-(MediaBean *)getMediaCache:(FileBean *)bean{
    
    if(bean.fileType == FILE_VIDEO || bean.fileType == FILE_MUSIC || bean.fileType == FILE_MOV){
        NSString *key = [self getCacheName:bean];
        MediaBean *_mediaDic = [_cacheMediaDic objectForKey:key];
//        NSLog(@"name : %@, filesize : %f, key : %@",bean.fileName, bean.fileSize,key);
        if(!_mediaDic && key && key.length > 0){
            if ([self.processMediaPathDic objectForKey:key]) {
                return nil;
            }
            [self.processMediaPathDic setObject:@"1" forKey:key];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[FileSystem getMediaCachePath]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[FileSystem getMediaCachePath] withIntermediateDirectories:NO attributes:nil error:nil];
            }
            if (![[NSFileManager defaultManager] fileExistsAtPath:[FileSystem getIconCachePath]]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[FileSystem getIconCachePath] withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSString *fileName = [[FileSystem getMediaCachePath] stringByAppendingPathComponent:key];
            NSString *imgName = [[FileSystem getIconCachePath] stringByAppendingPathComponent:key];
            if([FileSystem readFileProperty:fileName]){
                
                NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
                _mediaDic = [[MediaBean alloc] init];
                [_mediaDic setValuesForKeysWithDictionary:dic];
                _mediaDic.img = [UIImage imageWithData:[FileSystem kr_readData:imgName]];
                if(_mediaDic.time == 0 || _mediaDic.img == nil){
                    NSError *err;
                    [[NSFileManager defaultManager] removeItemAtPath:fileName error:&err];
                    _mediaDic = [self getMediaCache:bean];
                }
            }
            else {
                NSString *path = bean.filePath;
                if ([[path pathExtension] isEqualToString:@"m3u8"]) {
                    // m3u8文件读取不同的路径
                    path = [path stringByAppendingPathComponent:[path lastPathComponent]];
                }
                
                FilePropertyBean *probean = [FileSystem readFileProperty:path];
                if (probean.size <= 10) {
                    // 文件过小则不读取
                    _mediaDic = [[MediaBean alloc] init];
                }
                else if (bean.fileType == FILE_MUSIC) {
                    _mediaDic = [[VideoInfoUtiles instance] captureAudioInfo:path];
                }
                else {
                    _mediaDic = [[VideoInfoUtiles instance] captureOneFrame:path];
                }
                
                BOOL re = [[_mediaDic getDic] writeToFile:fileName atomically:YES];
                if(re && ![FileSystem readFileProperty:imgName]){
                    [UIImagePNGRepresentation(_mediaDic.img) writeToFile:imgName atomically:YES];
                }
            }
            
            [self.processMediaPathDic removeObjectForKey:key];
            
            if(_mediaDic) {
                [_cacheMediaDic setObject:_mediaDic forKey:key];
            }
        }
        
        if (bean.fileType == FILE_MOV) {
            if (_mediaDic && _mediaDic.img) {
                _mediaDic.img = [UIImage imageWithCGImage:_mediaDic.img.CGImage
                                                    scale:1.0 orientation:UIImageOrientationRight];
            }
        }
        
        return _mediaDic;
    }
    else {
        return nil;
    }
}

-(NSString *)getCacheName:(FileBean *)bean{
    
    return [DESUtils getMD5:[NSString stringWithFormat:@"%@%f", bean.fileName, bean.fileSize]];
}

-(NSString *)getCacheNameWithName:(NSString *)filename size:(float)size{
    
    return [DESUtils getMD5:[NSString stringWithFormat:@"%@%f", filename, size]];
}

-(NSString *)getFileIconCacheDir:(NSString *)filePath{
    
    NSString *path;
    if([filePath hasPrefix:KE_PHOTO] || [filePath hasPrefix:KE_VIDEO] || [filePath hasPrefix:KE_MUSIC] || [filePath hasPrefix:KE_DOC] || [filePath hasPrefix:KE_ROOT]){
        
        path = [FileSystem getHarddiskIconCachePath];
    }else{
    
        path = [FileSystem getIconCachePath];
    }
    NSFileManager* fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

-(NSData *)getFileData:(NSString *)path{
    
    return [FileSystem kr_readData:path];
}

-(void)getFileData:(FileBean *)fileBean delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info{
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        NSData *data = [FileSystem kr_readData:fileBean.filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(delegate && [delegate respondsToSelector:@selector(getFileData:info:)]){
                [delegate getFileData:data info:info];
            }
        });
    });
}

-(void)deleteFile:(FileBean *)fileBean delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          fileBean,@"fileBean",
                          delegate,@"delegate",
                          info,@"info",
                          nil];
    if ([CustomFileManage isDownloadedSubDir:fileBean.filePath]) {
        [self performSelector:@selector(performDelete:) withObject:dict afterDelay:0.5];
    }
    else {
        [self performDelete:dict];
    }
    
}

-(void)performDelete:(NSDictionary*)dict {
    [NSThread detachNewThreadSelector:@selector(doPerformDelete:) toTarget:self withObject:dict];
}

-(void)doPerformDelete:(NSDictionary*)dict{
    FileBean * fileBean = [dict objectForKey:@"fileBean"];
    int re = -1;
    BOOL ism3u8 = NO;
    if ([[fileBean.fileName pathExtension] isEqualToString:@"m3u8"]) {
        ism3u8 = YES;
    }
    if(fileBean.fileType == FILE_DIR || ism3u8){
        
        re = [self removeDir:fileBean.filePath];
        
        if (ism3u8 && re != RESULT_FINISH) {
            re = [self removeFile:fileBean.filePath];
        }
        
        if (re != RESULT_FINISH && [[fileBean.filePath lastPathComponent] isEqualToString:@"Inbox"]) {
            re = RESULT_FINISH;
        }
        
    }else{
        if ([CustomFileManage isDownloadedSubDir:fileBean.filePath]) {
            [[DownloadListVC sharedInstance] removeTaskAtPath:fileBean.filePath];
        }
        re = [self removeFile:fileBean.filePath];
        
        NSString *cacheName = [self getCacheName:fileBean];
        NSString *imgPath = [[FileSystem getIconCachePath] stringByAppendingPathComponent:cacheName];
        [[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
    }
    NSMutableDictionary* resultInfo = [[NSMutableDictionary alloc] initWithDictionary:[dict copy]];
    [resultInfo setObject:[NSNumber numberWithInt:re] forKey:@"result"];
    [self performSelectorOnMainThread:@selector(sendDeleteAction:) withObject:resultInfo waitUntilDone:NO];
}

-(void)sendDeleteAction:(NSDictionary*)dict{
    FileBean * fileBean = [dict objectForKey:@"fileBean"];
    id<CustomFileBeanDelegate> delegate = [dict objectForKey:@"delegate"];
    id info = [dict objectForKey:@"info"];
    NSNumber* result = [dict objectForKey:@"result"];
    if(delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
        
        [delegate actionResult:FILE_ACTION_DELETE result:result.integerValue info:info fileBean:fileBean];
    }
}

-(void)copyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info{
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:fileBean forKey:@"fileBean"];
    [dict setObject:toPath forKey:@"toPath"];
    if (delegate) {
        [dict setObject:delegate forKey:@"delegate"];
    }
    
    if (info) {
        [dict setObject:info forKey:@"info"];
    }
    [NSThread detachNewThreadSelector:@selector(doCopyFile:) toTarget:self withObject:dict];
}

-(void)doCopyFile:(NSDictionary*)copyInfo{
    FileBean *fileBean = [copyInfo objectForKey:@"fileBean"];
    NSString *toPath = [copyInfo objectForKey:@"toPath"];
    id<CustomFileBeanDelegate>delegate = [copyInfo objectForKey:@"delegate"];
    id info = [copyInfo objectForKey:@"info"];
    [self checkCopyFileKind:fileBean toPath:toPath delegate:delegate info:info];
}

-(void)copyFileMusic:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info{
    if (!_dispatchMusicArray) {
        _dispatchMusicArray = [[NSMutableArray alloc] init];
    }
    NSDictionary* dict = info ? [[NSDictionary alloc] initWithObjectsAndKeys:
                                 fileBean,@"bean",
                                 toPath,@"toPath",
                                 delegate,@"delegate",
                                 info,@"info",
                                 nil] : [[NSDictionary alloc] initWithObjectsAndKeys:
                                         fileBean,@"bean",
                                         toPath,@"toPath",
                                         delegate,@"delegate",
                                         nil];
    BOOL neadStart = _dispatchMusicArray.count == 0;
    [_dispatchMusicArray addObject:dict];
    if (_dispatchMusicArray.count > 3) {
        [_dispatchMusicArray removeObjectAtIndex:0];
    }
    NSLog(@"count : %lu",(unsigned long)_dispatchMusicArray.count);
    if (neadStart) {
        [self doCopyFileMusic];
    }
}

-(void)doCopyFileMusic{
    dispatch_async(_dispatchMusicQueue, ^{
        if (_dispatchMusicArray.count > 0) {
            NSDictionary* dict = [_dispatchMusicArray objectAtIndex:0];
            NSLog(@"filepath : %@",((FileBean*)[dict objectForKey:@"bean"]).filePath);
            [self actionCopyFile:[dict objectForKey:@"bean"] toPath:[dict objectForKey:@"toPath"]  delegate:[dict objectForKey:@"delegate"]  info:[dict objectForKey:@"info"]  isSend:YES forMusic:YES needContinue:^BOOL(NSString *filePath) {
                BOOL needContinue = NO;
                NSMutableArray* array = [NSMutableArray arrayWithArray:_dispatchMusicArray];
                for (NSDictionary* dict in array) {
                    FileBean* bean = [dict objectForKey:@"bean"];
                    if ([bean.filePath isEqualToString:filePath]) {
                        needContinue = YES;
                        break;
                    }
                }
                return needContinue;
            }];
            if ([_dispatchMusicArray containsObject:dict]) {
                [_dispatchMusicArray removeObject:dict];
            }
            if (_dispatchMusicArray.count > 0) {
                [self doCopyFileMusic];
            }
        }
        
    });
}

-(void)checkCopyFileKind:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info{
    
    if(fileBean.fileType == FILE_DIR || ([[fileBean.fileName pathExtension] isEqualToString:@"m3u8"] && fileBean.originTypeIsDir)){
        
        RESULTCODE re = RESULT_ERROR;
        if(fileBean.fileType == FILE_DIR && ([toPath hasPrefix:[NSString stringWithFormat:@"%@/",fileBean.filePath]] || [toPath isEqualToString:fileBean.filePath])){
            
            re = RESULT_DONTCOPYTOSELF;
        }else{
           
            PathBean *paths = [self getFiles:fileBean.filePath];
            NSString* resultPath = [toPath stringByAppendingPathComponent:fileBean.fileName];
            int result = [self creatDir:resultPath];
            if([paths pathCount] > 0){
                
                if( result == 0){
                    re = RESULT_FINISH;
                    toPath = [toPath stringByAppendingPathComponent:fileBean.fileName];
                    
                    for (FileBean *bean in paths.dirPathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        [self checkCopyFileKind:bean toPath:toPath delegate:delegate info:info];
                    }
                    for (FileBean *bean in paths.imgPathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        re = [self actionCopyWithCanCancelCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO forMusic:NO];
//                        re = [self actionCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO];
                        if(re == RESULT_ERROR) goto happenError;
                    }
                    for (FileBean *bean in paths.videoPathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        
                        if (([[bean.fileName pathExtension] isEqualToString:@"m3u8"] && bean.originTypeIsDir)) {
                            [self checkCopyFileKind:bean toPath:toPath delegate:delegate info:info];
                        }
                        else{
                            
                            re = [self actionCopyWithCanCancelCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO forMusic:NO];
                            if(re == RESULT_ERROR) goto happenError;
                        }
                    }
                    for (FileBean *bean in paths.musicPathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        re = [self actionCopyWithCanCancelCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO forMusic:NO];
//                        re = [self actionCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO];
                        if(re == RESULT_ERROR) goto happenError;
                    }
                    for (FileBean *bean in paths.docPathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        re = [self actionCopyWithCanCancelCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO forMusic:NO];
//                        re = [self actionCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO];
                        if(re == RESULT_ERROR) goto happenError;
                    }
                    for (FileBean *bean in paths.nonePathAry) {
                        if (isCopyCancel) {
                            break;
                        }
                        re = [self actionCopyWithCanCancelCopyFile:bean toPath:toPath delegate:delegate info:info isSend:NO forMusic:NO];
                        if(re == RESULT_ERROR) goto happenError;
                    }
                }
            }else{
                re = RESULT_FINISH;
            }
            
        }

    happenError:{
        NSMutableDictionary* resultIno = [[NSMutableDictionary alloc] init];
        [resultIno setObject:fileBean forKey:@"fileBean"];
        [resultIno setObject:[NSNumber numberWithInteger:re] forKey:@"result"];
        if (delegate) {
            [resultIno setObject:delegate forKey:@"delegate"];
        }
        
        if (info) {
            [resultIno setObject:info forKey:@"info"];
        }
        [self performSelectorOnMainThread:@selector(sendActionResult:) withObject:resultIno waitUntilDone:NO];
    }
        
    }else{
//        [self actionCopyFile:fileBean toPath:toPath delegate:delegate info:info isSend:YES];
        [self actionCopyWithCanCancelCopyFile:fileBean toPath:toPath delegate:delegate info:info isSend:YES forMusic:NO];
    }
}


-(void)sendActionResult:(NSDictionary*)resultInfo{
    FileBean *fileBean = [resultInfo objectForKey:@"fileBean"];
    NSNumber *result = [resultInfo objectForKey:@"result"];
    id<CustomFileBeanDelegate>delegate = [resultInfo objectForKey:@"delegate"];
    id info = [resultInfo objectForKey:@"info"];
    if(delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
        
        [delegate actionResult:FILE_ACTION_COPY result:result.integerValue info:info fileBean:fileBean];
    }
}

-(void)sendActionProgress:(NSDictionary*)progressInfo{
    FileBean *fileBean = [progressInfo objectForKey:@"fileBean"];
    NSNumber *progress = [progressInfo objectForKey:@"progress"];
    id<CustomFileBeanDelegate>delegate = [progressInfo objectForKey:@"delegate"];
    id info = [progressInfo objectForKey:@"info"];
    if(delegate && [delegate respondsToSelector:@selector(progress:info:fileBean:)]){
        
        [delegate progress:progress.floatValue info:info fileBean:fileBean];
    }
}

-(RESULTCODE)actionCopyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend{
//    if (fileBean.fileType == FILE_MOV || fileBean.fileType == FILE_VIDEO) {
        return [self actionCopyFile:fileBean toPath:toPath delegate:delegate info:info isSend:isSend forMusic:NO needContinue:^BOOL(NSString *filePath) {
            return YES;
        }];
//    }
//    else{
//       return [self actionCopyFile:fileBean toPath:toPath delegate:delegate info:info isSend:isSend forMusic:NO];
//    }
    
}

-(RESULTCODE)actionCopyWithCanCancelCopyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend forMusic:(BOOL)forMusic{
    
    //    [self cleanPathCache:toPath];
    if([[toPath stringByAppendingPathComponent:fileBean.fileName] isEqualToString:fileBean.filePath]){
        
        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        NSMutableDictionary* progressIno = [[NSMutableDictionary alloc] init];
        [progressIno setObject:fileBean forKey:@"fileBean"];
        [progressIno setObject:[NSNumber numberWithFloat:bean.size] forKey:@"progress"];
        if (delegate) {
            [progressIno setObject:delegate forKey:@"delegate"];
        }
        
        if (info) {
            [progressIno setObject:info forKey:@"info"];
        }
        [self performSelectorOnMainThread:@selector(sendActionProgress:) withObject:progressIno waitUntilDone:NO];
        NSMutableDictionary* resultIno = [[NSMutableDictionary alloc] init];
        [resultIno setObject:fileBean forKey:@"fileBean"];
        [resultIno setObject:[NSNumber numberWithInteger:RESULT_FINISH] forKey:@"result"];
        if (delegate) {
            [resultIno setObject:delegate forKey:@"delegate"];
        }
        
        if (info) {
            [resultIno setObject:info forKey:@"info"];
        }
        [self performSelectorOnMainThread:@selector(sendActionResult:) withObject:resultIno waitUntilDone:NO];
        return RESULT_FINISH;
    }
    _isCon = YES;
    RESULTCODE flag = RESULT_ERROR;
    FilePropertyBean *beanDir = [FileSystem readFileProperty:[toPath stringByDeletingLastPathComponent]];
    if (!beanDir || beanDir.fileKind != FILE_KIND_DIR) {
        [self creatDir:[toPath stringByDeletingLastPathComponent]];
    }
    int readSfp;
    int writeSfp;
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ before kr_openy readSfp:: fliepath:%@",DEBUGMODEL,fileBean.fileName]];
    readSfp = [FileSystem kr_open:fileBean.filePath flag:O_RDONLY, ACCESSPERMS];
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_openy readSfp:: fliepath:%@",DEBUGMODEL,fileBean.fileName]];
    NSString* resultPath = [toPath stringByAppendingPathComponent:fileBean.fileName];;
    if (readSfp > 0) {
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ before kr_openy writeSfp:: fliepath:%@",DEBUGMODEL,fileBean.fileName]];
        writeSfp = [FileSystem kr_open:resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_openy writeSfp:: fliepath:%@",DEBUGMODEL,fileBean.fileName]];
    }
    else{
        writeSfp = 0;
    }
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if( readSfp > 0 && writeSfp >0){
        
        float fileSize = fileBean.fileSize;
        float writeSize = 0;
//        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        [FileSystem kr_fso_fsetattr:writeSfp size:0 time:[fileBean getCreateTime]];
        size_t sizeof_buff = RW_BUFFER_SIZE;
        char* buff = (char*)malloc(sizeof_buff);
        float length = 0;
        if(buff){
            errno = 0;
            FILE_POSITION position = [CustomFileManage getFilePosition:toPath];
            while (writeSize < fileSize && (position != POSITION_HARDDISK || [FileSystem checkInit])) {
                if (isCopyCancel) {
//                    flag = RESULT_USER_CANCEL;
//                    [self removeFile:fileBean.filePath];
                    break;
                }
                memset(buff, 0, sizeof_buff);
                length = [FileSystem kr_read:readSfp buffer:buff size:sizeof_buff];
                if (length > 0) {
                    ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                    writeSize += writeLength;
                    if(_isCon){
                        
                        if(writeLength >= 0){
                            NSMutableDictionary* progressIno = [[NSMutableDictionary alloc] init];
                            [progressIno setObject:fileBean forKey:@"fileBean"];
                            [progressIno setObject:[NSNumber numberWithFloat:writeLength] forKey:@"progress"];
                            if (delegate) {
                                [progressIno setObject:delegate forKey:@"delegate"];
                            }
                            
                            if (info) {
                                [progressIno setObject:info forKey:@"info"];
                            }
                            [self performSelectorOnMainThread:@selector(sendActionProgress:) withObject:progressIno waitUntilDone:NO];
                        }else{
                            [self removeFile:resultPath];
                            flag = RESULT_ERROR;
                            break;
                        }
                    }else{
                        
                        flag = RESULT_CANCE;
                        [self removeFile:resultPath];
                        break;
                    }
                }
                else {
                    break;
                }
            }
            free(buff);
            buff = NULL;
        }
        [FileSystem kr_close:writeSfp];
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_close: writeSfp: copyfliepath:%@",DEBUGMODEL,fileBean.fileName]];
        if (!isCopyCancel) {
            if(fileSize == writeSize){
                if (!forMusic) {
                    [self insetFile:resultPath isDir:NO toPath:toPath];
                }
                flag = RESULT_FINISH;
            }
            else if (![resultPath hasPrefix:KE_ROOT]){
                NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
                NSError* error = nil;
                BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
                if(result && fileBean.fileSize == tmp.length){
                    if (!forMusic) {
                        [self insetFile:resultPath isDir:NO toPath:toPath];
                    }
                    flag = RESULT_FINISH;
                }
            }
        }
        
        [FileSystem kr_close:readSfp];
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_close: readSfp: copyfliepath:%@",DEBUGMODEL,fileBean.fileName]];
        if (isCopyCancel || flag == RESULT_ERROR || flag == RESULT_CANCE) {
            if (isCopyCancel) {
                flag = RESULT_USER_CANCEL;
            }
            NSArray *strs = [fileBean.filePath componentsSeparatedByString:@"/"];
            BOOL isM3u8 = NO;
            if (strs && strs.count>2) {
               NSString *str = [strs objectAtIndex:strs.count - 2];
                isM3u8 = [[str pathExtension] isEqualToString:@"m3u8"];
            }
            if ([[toPath pathExtension] isEqualToString:@"m3u8"] && isM3u8) {
                int re = [self removeDir:toPath];
                if (re != RESULT_FINISH) {
                    re = [self removeFile:toPath];
                }
            }
            else{
                [self removeFile:resultPath];
            }
        }
        
    }
    else if (readSfp >= 0 && ![resultPath hasPrefix:KE_ROOT] && ![appDelegate isAppActive]) {
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:resultPath];
        if (exist) {
            NSData* tmp = [FileSystem kr_readData:resultPath];
            if(fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        else {
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            [FileSystem kr_close:readSfp];
            if(result && fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        
    }
    NSMutableDictionary* resultIno = [[NSMutableDictionary alloc] init];
    [resultIno setObject:fileBean forKey:@"fileBean"];
    [resultIno setObject:[NSNumber numberWithInteger:flag] forKey:@"result"];
    if (delegate) {
        [resultIno setObject:delegate forKey:@"delegate"];
    }
    
    if (info) {
        [resultIno setObject:info forKey:@"info"];
    }
    [self performSelectorOnMainThread:@selector(sendActionResult:) withObject:resultIno waitUntilDone:NO];
    return flag;
}

-(RESULTCODE)actionCopyOutFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend forMusic:(BOOL)forMusic{
    
    //    [self cleanPathCache:toPath];
    if([[toPath stringByAppendingPathComponent:fileBean.fileName] isEqualToString:fileBean.filePath]){
        
        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(delegate && [delegate respondsToSelector:@selector(progress:info:fileBean:)]){
                
                [delegate progress:bean.size info:info fileBean:fileBean];
            }
            if(isSend && delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
                
                [delegate actionResult:FILE_ACTION_COPY result:RESULT_FINISH info:info fileBean:fileBean];
            }
        });
        return RESULT_FINISH;
    }
    _isCon = YES;
    RESULTCODE flag = RESULT_ERROR;
    FilePropertyBean *beanDir = [FileSystem readFileProperty:[toPath stringByDeletingLastPathComponent]];
    if (!beanDir || beanDir.fileKind != FILE_KIND_DIR) {
        [self creatDir:[toPath stringByDeletingLastPathComponent]];
    }
    int readSfp;
    int writeSfp;
    readSfp = [FileSystem kr_open:fileBean.filePath flag:O_RDONLY, ACCESSPERMS];
    NSString* resultPath = [toPath stringByAppendingPathComponent:fileBean.fileName];
    writeSfp = [FileSystem kr_open:resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if( readSfp > 0 && writeSfp >0){
        
        float fileSize = fileBean.fileSize;
        float writeSize = 0;
//        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        [FileSystem kr_fso_fsetattr:writeSfp size:0 time:[fileBean getCreateTime]];
        size_t sizeof_buff = RW_BUFFER_SIZE;
        char* buff = (char*)malloc(sizeof_buff);
        float length = 0;
        FILE_POSITION position = [CustomFileManage getFilePosition:toPath];
        if(buff){
            while (writeSize < fileSize &&(position != POSITION_HARDDISK || [FileSystem checkInit])) {
                if (isPhotoOutCancel) {
                    flag = RESULT_USER_CANCEL;
//                    [self removeFile:fileBean.fileName];
                    break;
                }
                memset(buff, 0, sizeof_buff);
                length = [FileSystem kr_read:readSfp buffer:buff size:sizeof_buff];
                if (length > 0) {
                    ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                    writeSize += writeLength;
                    if(_isCon){
                        
                        if(writeLength >= 0){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if(delegate && [delegate respondsToSelector:@selector(progress:info:fileBean:)]){
                                    
                                    [delegate progress:writeLength info:info fileBean:fileBean];
                                }
                                else{
                                    if (info && [info isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *dict = (NSDictionary *)info;
                                        id<PhotoInfoUtiles> delegate = [dict objectForKey:@"delegate"];
                                        if (delegate && [delegate respondsToSelector:@selector(progress:bean:userInfo:)]) {
                                            [delegate progress:writeLength*0.75 bean:nil userInfo:nil];
                                        }
                                    }
                                    
                                }
                            });
                        }else{
                            
//                            [self removeFile:fileBean.filePath];
                            flag = RESULT_ERROR;
                            break;
                        }
                    }else{
                        
                        flag = RESULT_CANCE;
//                        [self removeFile:fileBean.filePath];
                        break;
                    }
                }
                else {
                    break;
                }
            }
            free(buff);
            buff = NULL;
        }
        [FileSystem kr_close:writeSfp];
        if (!isPhotoOutCancel) {
            if(fileSize == writeSize){
                if (!forMusic) {
                    [self insetFile:resultPath isDir:NO toPath:toPath];
                }
                flag = RESULT_FINISH;
            }
            else if (![resultPath hasPrefix:KE_ROOT]){
                NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
                NSError* error = nil;
                BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
                if(result && fileBean.fileSize == tmp.length){
                    if (!forMusic) {
                        [self insetFile:resultPath isDir:NO toPath:toPath];
                    }
                    flag = RESULT_FINISH;
                }
            }
        }
        
        [FileSystem kr_close:readSfp];
        
    }
    else if (readSfp >= 0 && ![resultPath hasPrefix:KE_ROOT] && ![appDelegate isAppActive]) {
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:resultPath];
        if (exist) {
            NSData* tmp = [FileSystem kr_readData:resultPath];
            if(fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        else {
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            [FileSystem kr_close:readSfp];
            if(result && fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isSend && delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
            [delegate actionResult:FILE_ACTION_COPY result:flag info:info fileBean:fileBean];
        }
    });
    return flag;
}


-(RESULTCODE)actionCopyFile:(FileBean *)fileBean toPath:(NSString *)toPath delegate:(id<CustomFileBeanDelegate>)delegate info:(id)info isSend:(BOOL)isSend forMusic:(BOOL)forMusic needContinue:(ContinueBlock)continueBlock{
    
    //    [self cleanPathCache:toPath];
    if([[toPath stringByAppendingPathComponent:fileBean.fileName] isEqualToString:fileBean.filePath]){
        
        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(delegate && [delegate respondsToSelector:@selector(progress:info:fileBean:)]){
                
                [delegate progress:bean.size info:info fileBean:fileBean];
            }
            if(isSend && delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
                
                [delegate actionResult:FILE_ACTION_COPY result:RESULT_FINISH info:info fileBean:fileBean];
            }
        });
        return RESULT_FINISH;
    }
    _isCon = YES;
    RESULTCODE flag = RESULT_ERROR;
    FilePropertyBean *beanDir = [FileSystem readFileProperty:[toPath stringByDeletingLastPathComponent]];
    if (!beanDir || beanDir.fileKind != FILE_KIND_DIR) {
        [self creatDir:[toPath stringByDeletingLastPathComponent]];
    }
    int readSfp;
    int writeSfp;
    
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy music before open,fileBean.filePath:%@",DEBUGMODEL,fileBean.filePath]];
    readSfp = [FileSystem kr_open:fileBean.filePath flag:O_RDONLY, ACCESSPERMS];
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy music after open ,fileBean.filePath:%@",DEBUGMODEL,fileBean.filePath]];
    NSString* resultPath = [toPath stringByAppendingPathComponent:fileBean.fileName];
    writeSfp = [FileSystem kr_open:resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if( readSfp > 0 && writeSfp >0){
        
        float fileSize = fileBean.fileSize;
        float writeSize = 0;
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy music before readFileProperty filePath:%@",DEBUGMODEL,fileBean.filePath]];

//        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy music after readFileProperty, file size: %f filePath:%@",DEBUGMODEL, bean.size,fileBean.filePath]];
        [FileSystem kr_fso_fsetattr:writeSfp size:0 time:[fileBean getCreateTime]];
        size_t sizeof_buff = RW_BUFFER_SIZE;
        char* buff = (char*)malloc(sizeof_buff);
        size_t length = 0;
        if(buff){
            BOOL needCon = true;
            while (writeSize < fileSize && needCon) {
                needCon = continueBlock(fileBean.filePath);
                if (!needCon) {
                    [self removeFile:fileBean.fileName];
                    flag = RESULT_ERROR;
                    break;
                }
                memset(buff, 0, sizeof_buff);
//                 [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy kr_read before:%d, sizeif_buf: %lu ,resultPath:%@",
//                                     DEBUGMODEL,readSfp, sizeof_buff ,resultPath]];
                errno = 0;
                length = [FileSystem kr_read:readSfp buffer:buff size:sizeof_buff];
//                 [LogUtils writeLog:[NSString stringWithFormat:@"%@ action copy kr_read after: %d, length: %lu, errno: %d,resultPath:%@",
//                                     DEBUGMODEL,readSfp, length, errno ,resultPath]];
                if (length > 0) {
                    ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                    writeSize += writeLength;
                    if(_isCon){
                        
                        if(writeLength >= 0){
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if(delegate && [delegate respondsToSelector:@selector(progress:info:fileBean:)]){
                                    
                                    [delegate progress:writeLength info:info fileBean:fileBean];
                                }
                            });
                        }else{
                            
                            [self removeFile:fileBean.fileName];
                            flag = RESULT_ERROR;
                            break;
                        }
                    }else{
                        
                        flag = RESULT_CANCE;
                        [self removeFile:fileBean.fileName];
                        break;
                    }
                }
                else {
                    [LogUtils writeLog:@"length read error"];
                    break;
                }
            }
            free(buff);
            buff = NULL;
        }
        [FileSystem kr_close:writeSfp];
        if(fileSize <= writeSize){
            if (!forMusic) {
                [self insetFile:resultPath isDir:NO toPath:toPath];
            }
            flag = RESULT_FINISH;
        }
        else if (![resultPath hasPrefix:KE_ROOT]){
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            if(result && fileBean.fileSize <= tmp.length){
                if (!forMusic) {
                    [self insetFile:resultPath isDir:NO toPath:toPath];
                }
                flag = RESULT_FINISH;
            }
        }
        [FileSystem kr_close:readSfp];
        
    }
    else if (readSfp >= 0 && ![resultPath hasPrefix:KE_ROOT] && ![appDelegate isAppActive]) {
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:resultPath];
        if (exist) {
            NSData* tmp = [FileSystem kr_readData:resultPath];
            if(fileBean.fileSize <= tmp.length){
                flag = RESULT_FINISH;
            }
        }
        else {
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            [FileSystem kr_close:readSfp];
            if(result && fileBean.fileSize <= tmp.length){
                flag = RESULT_FINISH;
            }
        }
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@beforecope done",DEBUGMODEL]];
        if(isSend && delegate && [delegate respondsToSelector:@selector(actionResult:result:info:fileBean:)]){
//            [LogUtils writeLog:[NSString stringWithFormat:@"%@cope done",DEBUGMODEL]];
            [delegate actionResult:FILE_ACTION_COPY result:flag info:info fileBean:fileBean];
        }
    });
    return flag;
}


-(BOOL)copyToTempWith:(FileBean *)fileBean{
    
    [self cleanThirdOpenTempPathfiles];
    
    _isCon = YES;
    RESULTCODE flag = RESULT_ERROR;
    int readSfp;
    int writeSfp;
    readSfp = [FileSystem kr_open:fileBean.filePath flag:O_RDONLY, ACCESSPERMS];
    NSString* resultPath = [[self getLibraryTempPath] stringByAppendingPathComponent:fileBean.fileName];
    writeSfp = [FileSystem kr_open:resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if( readSfp > 0 && writeSfp >0){
        float fileSize = fileBean.fileSize;
        float writeSize = 0;
//        FilePropertyBean *bean = [FileSystem readFileProperty:fileBean.filePath];
        [FileSystem kr_fso_fsetattr:writeSfp size:0 time:[fileBean getCreateTime]];
        size_t sizeof_buff = RW_BUFFER_SIZE;
        char* buff = (char*)malloc(sizeof_buff);
        float length = 0;
        if(buff){
            while (writeSize < fileSize) {
                memset(buff, 0, sizeof_buff);
                length = [FileSystem kr_read:readSfp buffer:buff size:sizeof_buff];
                if (length > 0) {
                    ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                    writeSize += writeLength;
                    if(_isCon){
                        
                        if(writeLength >= 0){
                            
                        }else{
                            flag = RESULT_ERROR;
                            break;
                        }
                    }else{
                        flag = RESULT_CANCE;
                    }
                }
                else {
                    break;
                }
            }
            free(buff);
            buff = NULL;
        }
        [FileSystem kr_close:writeSfp];
        
        if(fileSize == writeSize){
            flag = RESULT_FINISH;
        }
        else if (![resultPath hasPrefix:KE_ROOT]){
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            if(result && fileBean.fileSize == tmp.length){
                
                flag = RESULT_FINISH;
            }
        }
        
        [FileSystem kr_close:readSfp];
        
    }
    else if (readSfp >= 0 && ![resultPath hasPrefix:KE_ROOT] && ![appDelegate isAppActive]) {
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:resultPath];
        if (exist) {
            NSData* tmp = [FileSystem kr_readData:resultPath];
            if(fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        else {
            NSData* tmp = [FileSystem kr_readData:fileBean.filePath];
            NSError* error = nil;
            BOOL result = [tmp writeToFile:resultPath options:NSDataWritingFileProtectionNone error:&error];
            [FileSystem kr_close:readSfp];
            if(result && fileBean.fileSize == tmp.length){
                flag = RESULT_FINISH;
            }
        }
        
    }
    return flag == RESULT_FINISH;
}


-(BOOL)cleanThirdOpenTempPathfiles
{
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:[self getLibraryTempPath] error:nil];
    return result;
}

-(NSString *)getLibraryTempPath
{
    NSString *librarypath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [librarypath stringByAppendingPathComponent:@"tempOpen"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if(![manager contentsOfDirectoryAtPath:path error:nil]){
        [manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return path;
}

-(BOOL)existFile:(NSString *)path{
    
    return [self existFile:path isDir:NO];
}

-(BOOL)existFile:(NSString *)path isDir:(BOOL)isDir{
    
    FilePropertyBean *bean = [FileSystem readFileProperty:path];
    if(bean){
        if (isDir) {
            return bean.fileKind == FILE_KIND_DIR;
        }
        return YES;
    }else{
        return NO;
    }
}

-(int)creatDir:(NSString *)path{
    return [self creatDir:path withCache:YES];
}

-(int)creatDir:(NSString *)path withCache:(BOOL)withCache {
    int ret = [FileSystem creatDir:path];
    
    if (ret == 0) {
        if (withCache) {
            [self insetFile:path isDir:![[path pathExtension] isEqualToString:@"m3u8"] toPath:[path stringByDeletingLastPathComponent]];
        }
    }
    return ret;
}


- (int) removeFileOrDir:(NSString *)path{
    
    if(!path) return -1;
    
    FilePropertyBean *dic = [FileSystem readFileProperty:path];
    if(dic && dic.fileKind == FILE_KIND_DIR){
        
        return [self removeDir:path];
    }else{
        
        return [self removeFile:path];
    }
}

- (int) removeFile:(NSString *)path{
    if(![FileSystem checkInit] && [CustomFileManage getFilePosition:path] == POSITION_HARDDISK){
        return -1;
    }
    return [self removeFile:path clearCache:NO];
}

- (int)removeFile:(NSString *)path clearCache:(BOOL)isclear{
    if(path){
        int re = [FileSystem kr_unlink:path];
        if (RESULT_FINISH == re || isclear) {
            [self deleteFile:path isDir:NO fromPath:[path stringByDeletingLastPathComponent]];
        }
        [FileSystem flushData];
        return re;
    }else{
        return -1;
    }
}

- (int)removeDir:(NSString *)path{
    if(!path) return -1;
    if([self.processPathDic objectForKey:path]){
        return -1;
    }
    [self.processPathDic setObject:@"1" forKey:path];
    DIR *dir;
    dir = [FileSystem kr_openDir:path];
    struct dirent *file;

    if(dir){
        
        while((file = [FileSystem kr_readDir:dir])){
            
            if(strcmp(".", file->d_name) != 0 && strcmp("..", file->d_name) != 0){

                NSString *fileName = [NSString stringWithCString:file->d_name encoding:NSUTF8StringEncoding];
                NSString *tempPath = [path stringByAppendingPathComponent:fileName];
                if ([path isEqualToString:tempPath]) {
                    
                    [FileSystem kr_unlink:tempPath];
                    continue;
                }
                if (file->d_type == DT_DIR){
                    
                    if([self removeDir:tempPath] != 0){
                        
                        break;
                    }
                }else{
                    if ([CustomFileManage isDownloadedSubDir:tempPath]) {
                        [[DownloadListVC sharedInstance] removeTaskAtPath:tempPath];
                    }
                    [FileSystem kr_unlink:tempPath];
                }
            }
        }
        [FileSystem kr_closeDir:dir];
    }else{
        
//        NSLog(@"%s fso_opendir %@ error:%d", __FUNCTION__, path, errno);
    }
    
    dir = NULL;
    int re = [FileSystem kr_rmDir:path];
    if(re == 0){
        if ([CustomFileManage isDownloadedSubDir:path]) {
            [[DownloadListVC sharedInstance] removeTaskAtPath:path];
        }
        [self cleanPathCache:path];
        [self deleteFile:path isDir:YES fromPath:[path stringByDeletingLastPathComponent]];
    }
    [FileSystem flushData];
    [self.processPathDic removeObjectForKey:path];
    return re;
}

-(BOOL)hasCacheWithPath:(NSString*)path{
    return [self.cachePathDic objectForKey:path] != nil;
}


- (PathBean *) getFiles:(NSString *)filePath{
    return [self getFiles:filePath getEX:nil count:-1 sync:YES fromPhotoRoot:NO];
}

-(PathBean *)getFiles:(NSString *)filePath fromPhotoRoot:(BOOL)isfromPhotoRoot{
    return [self getFiles:filePath getEX:nil count:-1 sync:YES fromPhotoRoot:isfromPhotoRoot];
}

- (PathBean *)getFilesAsync:(NSString *)filePath{
    return [self getFiles:filePath getEX:nil count:-1 sync:NO fromPhotoRoot:NO];
}

- (PathBean *) getFiles:(NSString *)filePath getEX:(NSDictionary *)exDic count:(NSInteger)needCount{
    return [self getFiles:filePath getEX:exDic count:needCount sync:YES fromPhotoRoot:NO];
}

- (PathBean *) getFiles:(NSString *)filePath getEX:(NSDictionary *)exDic count:(NSInteger)needCount sync:(BOOL)sync fromPhotoRoot:(BOOL)isfromPhotoRoot{
    
    if(filePath == nil){
        if (needCount < 0) {
            [LogUtils writeLog:@"DEBUGMODEL filePath == nil"];
        }
        return nil;
    }
    
    PathBean *pathBean = needCount < 0 ? [self.cachePathDic objectForKey:filePath] : [self.imgFileCachePathDic objectForKey:filePath];
    if(pathBean){
        if (needCount == -1) {
            NSInteger cacheCount = pathBean.dirPathAry.count + pathBean.imgPathAry.count + pathBean.videoPathAry.count + pathBean.musicPathAry.count + pathBean.docPathAry.count + pathBean.nonePathAry.count;
            [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL needCount %ld ,exist path : %@ , cache count %ld",(long)needCount,filePath,(long)cacheCount]];
        }
        return pathBean;
    }
    if(sync && [self.processPathDic objectForKey:filePath]){
        if (needCount == -1) {
            [LogUtils writeLog:@"DEBUGMODEL [self.processPathDic objectForKey:filePath]"];
        }
        return nil;
    }
    if (needCount == -1) {
        if (sync) {
            [self.processPathDic setObject:@"1" forKey:filePath];
//            [LogUtils writeLog:[NSString stringWithFormat:@"%@ sys read path : %@",DEBUGMODEL,filePath]];
        }
        else {
//            [LogUtils writeLog:[NSString stringWithFormat:@"%@ asys read path : %@",DEBUGMODEL,filePath]];
        }
    }
    
    pathBean = [[PathBean alloc] init];
    errno = 0;
    if ([CustomFileManage getFilePosition:filePath] == POSITION_HARDDISK && (![self isSystemInited] || ![FileSystem checkInit])) {
        if (sync) {
            [self.processPathDic removeObjectForKey:filePath];
        }
        
        return nil;
    }
    
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ before getfiles from ke:%@",DEBUGMODEL,filePath]];
    
    NSLog(@"getFiles from: %@",filePath);
    
    errno = 0;
    DIR *dir;
    dir = [FileSystem kr_openDir:filePath];
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ kr_openDir finish: %p ,errno:%d",DEBUGMODEL,dir,errno]];
    struct dirent *file;
    NSInteger count  = 0;
    NSInteger imageCount = 0;
    NSMutableArray* dotDir = [NSMutableArray array];
    NSMutableArray* dotFile = [NSMutableArray array];
    if(dir){
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ while begin:%@",DEBUGMODEL,filePath]];
        
        while((file = [FileSystem kr_readDir:dir])){
            if ([CustomFileManage getFilePosition:filePath] == POSITION_HARDDISK && (![self isSystemInited] || ![FileSystem checkInit])) {
                if (sync) {
                    [self.processPathDic removeObjectForKey:filePath];
                }
                
                return nil;
            }
            if(strcmp(".", file->d_name) != 0 && strcmp("..", file->d_name) != 0){
                
                NSString *fileName = [NSString stringWithCString:file->d_name encoding:NSUTF8StringEncoding];
                NSString *exName = [[fileName pathExtension] lowercaseString];
                if(!fileName){
                    continue;
                }
                NSString *path = [filePath stringByAppendingPathComponent:fileName];
                FileBean *bean = [[FileBean alloc] init];
                [bean setFilePath:path];
                if(file->d_type == DT_REG || [exName isEqualToString:@"m3u8"]){
                    if (file->d_type == DT_DIR && [exName isEqualToString:@"m3u8"]) {
                        [bean setOriginTypeIsDir:YES];
                    }
                    if ([bean.fileName rangeOfString:@"."].location == 0) {
                        if (dotFile.count > 0) {
                            BOOL hasAdded = NO;
                            for(int i = 0 ; i < dotFile.count ; i ++){
                                FileBean *tmp = [dotFile objectAtIndex:i];
                                if ([tmp getCreateTime] < [tmp getCreateTime]) {
                                    [dotFile insertObject:bean atIndex:i];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                            }
                            if (!hasAdded) {
                                [dotFile addObject:bean];
                                count ++;
                            }
                        }
                        else {
                            [dotFile addObject:bean];
                            count ++;
                        }
                    }
                    else  if(exDic == nil || [exDic objectForKey:exName]){
                        
                        if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
                            
                            if ([VIDEO_EX_DIC objectForKey:exName]) {
                                
                                [bean setFileType:FILE_VIDEO];
                            }
                            else{
                                
                                [bean setFileType:FILE_MOV];
                            }
                            
                            if (pathBean.videoPathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.videoPathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.videoPathAry objectAtIndex:i];
                                    
//                                    NSDate *tmpchdate = [NSDate dateWithTimeIntervalSince1970:[tmp getFileDate]];
//                                    NSDate *beanchdate = [NSDate dateWithTimeIntervalSince1970:[bean getFileDate]];
                                    
//                                    NSDate *tmpctdate = [NSDate dateWithTimeIntervalSince1970:[tmp getCreateTime]];
//                                    NSDate *beanctdate = [NSDate dateWithTimeIntervalSince1970:[bean getCreateTime]];
                                    
                                    if ([tmp getCreateTime] < [bean getCreateTime]) {
                                        [pathBean.videoPathAry insertObject:bean atIndex:i];
                                        hasAdded = YES;
                                        count ++;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.videoPathAry addObject:bean];
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.videoPathAry addObject:bean];
                                count ++;
                            }
                            
                            if (needCount > 0 && count >= needCount) {
                                break;
                            }
                        }else if ([MUSIC_EX_DIC objectForKey:exName]){
                            
                            [bean setFileType:FILE_MUSIC];
                            if (pathBean.musicPathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.musicPathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.musicPathAry objectAtIndex:i];
                                    if ([tmp getFileDate] < [bean getFileDate]) {
                                        [pathBean.musicPathAry insertObject:bean atIndex:i];
                                        count ++;
                                        hasAdded = YES;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.musicPathAry addObject:bean];
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.musicPathAry addObject:bean];
                                count ++;
                            }
                            if (needCount > 0 && count >= needCount) {
                                break;
                            }
                        }else if ([PICTURE_EX_DIC objectForKey:exName]){
                            
                            [bean setFileType:FILE_IMG];
//                            NSLog(@"imagename:%@,date:%f",bean.fileName,[bean getFileDate]);
                            if (pathBean.imgPathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.imgPathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.imgPathAry objectAtIndex:i];
                                    
//                                    NSDate *tmpdate = [NSDate dateWithTimeIntervalSince1970:[tmp getFileDate]];
//                                    NSDate *beandate = [NSDate dateWithTimeIntervalSince1970:[bean getFileDate]];
                                    
                                    BOOL issmall = !isfromPhotoRoot? ([tmp getFileDate] < [bean getFileDate]) : ([tmp getCreateTime] > [bean getCreateTime]);
                                    if (issmall) {
                                        [pathBean.imgPathAry insertObject:bean atIndex:i];
                                        count ++;
                                        imageCount ++;
                                        hasAdded = YES;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.imgPathAry addObject:bean];
                                    imageCount ++;
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.imgPathAry addObject:bean];
                                imageCount ++;
                                count ++;
                            }
                            if (needCount > 0 && imageCount >= needCount) {
                                break;
                            }
                        }else if ([GIF_EX_DIC objectForKey:exName]){
                            
                            [bean setFileType:FILE_GIF];
                            if (pathBean.imgPathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.imgPathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.imgPathAry objectAtIndex:i];
                                    BOOL issmall = !isfromPhotoRoot? ([tmp getFileDate] < [bean getFileDate]) : ([tmp getCreateTime] > [bean getCreateTime]);
//                                    if ([tmp getFileDate] < [bean getFileDate]) {
                                    if (issmall) {
                                        [pathBean.imgPathAry insertObject:bean atIndex:i];
                                        count ++;
                                        imageCount ++;
                                        hasAdded = YES;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.imgPathAry addObject:bean];
                                    
                                    imageCount ++;
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.imgPathAry addObject:bean];
                                imageCount ++;
                                count ++;
                            }
                            if (needCount > 0 && imageCount >= needCount) {
                                break;
                            }
                        }else if ([DOC_EX_DIC objectForKey:exName]){
                            
                            [bean setFileType:FILE_DOC];
                            if (pathBean.docPathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.docPathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.docPathAry objectAtIndex:i];
                                    if ([tmp getFileDate] < [bean getFileDate]) {
                                        [pathBean.docPathAry insertObject:bean atIndex:i];
                                        count ++;
                                        hasAdded = YES;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.docPathAry addObject:bean];
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.docPathAry addObject:bean];
                                count ++;
                            }
                            if (needCount > 0 && count >= needCount) {
                                break;
                            }
                        }else{
                            
                            [bean setFileType:FILE_NONE];
                            if (pathBean.nonePathAry.count > 0) {
                                BOOL hasAdded = NO;
                                for(int i = 0 ; i < pathBean.nonePathAry.count ; i ++){
                                    FileBean *tmp = [pathBean.nonePathAry objectAtIndex:i];
                                    if ([tmp getFileDate] < [bean getFileDate]) {
                                        [pathBean.nonePathAry insertObject:bean atIndex:i];
                                        count ++;
                                        hasAdded = YES;
                                        break;
                                    }
                                }
                                if (!hasAdded) {
                                    [pathBean.nonePathAry addObject:bean];
                                    count ++;
                                }
                            }
                            else {
                                [pathBean.nonePathAry addObject:bean];
                                count ++;
                            }
                        }
                    }
                }
                else if(file->d_type == DT_DIR){
                    [bean setFileType:FILE_DIR];
                    if ([bean.fileName rangeOfString:@"."].location == 0) {
                        if (dotDir.count > 0) {
                            BOOL hasAdded = NO;
                            for(int i = 0 ; i < dotDir.count ; i ++){
                                FileBean *tmp = [dotDir objectAtIndex:i];
                                if ([tmp getFileDate] < [bean getFileDate]) {
                                    [dotDir insertObject:bean atIndex:i];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                            }
                            if (!hasAdded) {
                                [dotDir addObject:bean];
                                count ++;
                            }
                        }
                        else {
                            [dotDir addObject:bean];
                            count ++;
                        }
                    }
                    else {
                        if (pathBean.dirPathAry.count > 0) {
                            BOOL hasAdded = NO;
                            for(int i = 0 ; i < pathBean.dirPathAry.count ; i ++){
                                FileBean *tmp = [pathBean.dirPathAry objectAtIndex:i];
                                if([CustomFileManage isDownloadedDir:[bean getFilePath]]){
                                    [pathBean.dirPathAry insertObject:bean atIndex:0];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                                else if ([tmp getCreateTime] < [bean getCreateTime] && ![CustomFileManage isDownloadedDir:[tmp getFilePath]]) {
                                    [pathBean.dirPathAry insertObject:bean atIndex:i];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                            }
                            if (!hasAdded) {
                                [pathBean.dirPathAry addObject:bean];
                                count ++;
                            }
                        }
                        else {
                            [pathBean.dirPathAry addObject:bean];
                            count ++;
                        }
                    }
                    
                }
                else{
                    [bean setFileType:FILE_NONE];
                    if ([bean.fileName rangeOfString:@"."].location == 0) {
                        if (dotFile.count > 0) {
                            BOOL hasAdded = NO;
                            for(int i = 0 ; i < dotFile.count ; i ++){
                                FileBean *tmp = [dotFile objectAtIndex:i];
                                if ([tmp getFileDate] < [bean getFileDate]) {
                                    [dotFile insertObject:bean atIndex:i];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                            }
                            if (!hasAdded) {
                                [dotFile addObject:bean];
                                count ++;
                            }
                        }
                        else {
                            [dotFile addObject:bean];
                            count ++;
                        }
                    }
                    else {
                        if (pathBean.nonePathAry.count > 0) {
                            BOOL hasAdded = NO;
                            for(int i = 0 ; i < pathBean.nonePathAry.count ; i ++){
                                FileBean *tmp = [pathBean.nonePathAry objectAtIndex:i];
                                if ([tmp getFileDate] < [bean getFileDate]) {
                                    [pathBean.nonePathAry insertObject:bean atIndex:i];
                                    count ++;
                                    hasAdded = YES;
                                    break;
                                }
                            }
                            if (!hasAdded) {
                                [pathBean.nonePathAry addObject:bean];
                                count ++;
                            }
                        }
                        else {
                            [pathBean.nonePathAry addObject:bean];
                            count ++;
                        }
                    }
                }
            }
        }
        
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ before kr_closeDir:%@",DEBUGMODEL,filePath]];
        [FileSystem kr_closeDir:dir];
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_closeDir:%@",DEBUGMODEL,filePath]];
        dir = NULL;
    }
    else {
        NSInteger err  = errno;
        pathBean = nil;
        if(_isCache && pathBean) {
            if (needCount < 0) {
                [self.cachePathDic removeObjectForKey:filePath];
            }
            else
            {
                [self.imgFileCachePathDic removeObjectForKey:filePath];
            }
        }
        [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL error %ld ，path ： %@",(long)err,filePath]];
    }
    
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ get file finish:%@",DEBUGMODEL,filePath]];
//    if (dotDir.count > 0) {
//        [dic.dirPathAry addObjectsFromArray:dotDir];
//    }
//    if (dotFile.count > 0) {
//        [dic.nonePathAry addObjectsFromArray:dotFile];
//    }
    if(_isCache && pathBean) {
        if (needCount < 0) {
            [self.cachePathDic setObject:pathBean forKey:filePath];
        }
        else
        {
            [self.imgFileCachePathDic setObject:pathBean forKey:filePath];
        }
    }
    if (needCount == -1) {
        NSInteger cacheCount = pathBean.dirPathAry.count + pathBean.imgPathAry.count + pathBean.videoPathAry.count + pathBean.musicPathAry.count + pathBean.docPathAry.count + pathBean.nonePathAry.count;
        NSLog(@"%@ needCount %ld ,path : %@, read count : %ld, cache count : %ld",DEBUGMODEL,(long)needCount,filePath,(long)count,(long)cacheCount);
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ needCount %ld ,path : %@, read count : %ld, cache count : %ld",DEBUGMODEL,(long)needCount,filePath,(long)count,(long)cacheCount]];
    }
    if (sync) {
        [self.processPathDic removeObjectForKey:filePath];
    }
    return pathBean;
}

-(void)setCache:(BOOL)isCache{
    _isCache = isCache;
}

-(void)cleanPathCache:(NSString *)path{
    
    if(path){
        [self.cachePathDic removeObjectForKey:path];
        [self.imgFileCachePathDic removeObjectForKey:path];
    }
}

-(void)cleanPathImgFileCache:(NSString *)path{
    
    if(path){
        [self.imgFileCachePathDic removeObjectForKey:path];
    }
}

-(void)deleteFile:(NSString*)beanPath isDir:(BOOL)isDir fromPath:(NSString*)path{
    if(path == nil)
        return;
    PathBean *dic = [self.cachePathDic objectForKey:path];
    if(dic){
        if (isDir && ![[beanPath pathExtension] isEqualToString:@"m3u8"]) {
            for (FileBean* bean in dic.dirPathAry) {
                if ([bean.filePath isEqualToString:beanPath]) {
                    [dic.dirPathAry removeObject:bean];
                    break;
                }
            }
        }
        else {
            NSString *exName = [[beanPath pathExtension] lowercaseString];
            if([VIDEO_EX_DIC objectForKey:exName] || [[beanPath pathExtension] isEqualToString:@"m3u8"] || [MOV_EX_DIC objectForKey:exName]){
                for (FileBean* bean in dic.videoPathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.videoPathAry removeObject:bean];
                        break;
                    }
                }
            }else if ([MUSIC_EX_DIC objectForKey:exName]){
                for (FileBean* bean in dic.musicPathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.musicPathAry removeObject:bean];
                        break;
                    }
                }
            }else if ([PICTURE_EX_DIC objectForKey:exName]){
                for (FileBean* bean in dic.imgPathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.imgPathAry removeObject:bean];
                        break;
                    }
                }
            }else if ([GIF_EX_DIC objectForKey:exName]){
                for (FileBean* bean in dic.imgPathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.imgPathAry removeObject:bean];
                        break;
                    }
                }
            }
//            else if ([MOV_EX_DIC objectForKey:exName]){
//                for (FileBean* bean in dic.imgPathAry) {
//                    if ([bean.filePath isEqualToString:beanPath]) {
//                        [self removeFileIconCache:bean];
//                        [dic.imgPathAry removeObject:bean];
//                        break;
//                    }
//                }
//            }
            else if ([DOC_EX_DIC objectForKey:exName]){
                for (FileBean* bean in dic.docPathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.docPathAry removeObject:bean];
                        break;
                    }
                }
            }else{
                for (FileBean* bean in dic.nonePathAry) {
                    if ([bean.filePath isEqualToString:beanPath]) {
                        [self removeFileIconCache:bean];
                        [dic.nonePathAry removeObject:bean];
                        break;
                    }
                }
            }
        }
    }
}

-(void)insetFile:(NSString*)beanPath isDir:(BOOL)isDir toPath:(NSString*)path{
    [self insetFile:beanPath isDir:isDir toPath:path fromPhotoRoot:NO];
}

-(void)insetFile:(NSString*)beanPath isDir:(BOOL)isDir toPath:(NSString*)path fromPhotoRoot:(BOOL)isfromPhotoRoot{
    if(path == nil || ([FileSystem isConnectedKE] && ![FileSystem checkInit]))
        return;
    PathBean *dic = [self.cachePathDic objectForKey:path];
    if(!dic){
        dic = [[PathBean alloc] init];
        [self.cachePathDic setObject:dic forKey:path];
//        [LogUtils writeLog:[NSString stringWithFormat:@"create dir : %@",path]];
    }
    FileBean *bean = [[FileBean alloc] init];
    [bean setFilePath:beanPath];
    if (isDir) {
        [bean setFileType:FILE_DIR];
        if (dic.dirPathAry.count > 0) {
            BOOL hasAdded = NO;
            BOOL hasIn = false;
            for(int i = 0 ; i < dic.dirPathAry.count ; i ++){
                FileBean *tmp = [dic.dirPathAry objectAtIndex:i];
                if ([tmp.filePath isEqualToString:beanPath]) {
                    hasIn = YES;
                    break;
                }
                if ([tmp getCreateTime] < [bean getCreateTime] && ![CustomFileManage isDownloadedDir:[tmp getFilePath]]) {
                    [dic.dirPathAry insertObject:bean atIndex:i];
                    hasAdded = YES;
                    break;
                }
            }
            if (!hasAdded && !hasIn) {
                [dic.dirPathAry addObject:bean];
            }
        }
        else {
            [dic.dirPathAry addObject:bean];
        }
    }
    else {
        NSString *exName = [[beanPath pathExtension] lowercaseString];
        if([VIDEO_EX_DIC objectForKey:exName] || [MOV_EX_DIC objectForKey:exName]){
            
            if ([MOV_EX_DIC objectForKey:exName]){
                [bean setFileType:FILE_MOV];
            }
            else{
                [bean setFileType:FILE_VIDEO];
            }
            
            if (dic.videoPathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.videoPathAry.count ; i ++){
                    FileBean *tmp = [dic.videoPathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    if ([tmp getFileDate] < [bean getFileDate]) {
                        [dic.videoPathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.videoPathAry addObject:bean];
                }
            }
            else {
                [dic.videoPathAry addObject:bean];
            }
        }else if ([MUSIC_EX_DIC objectForKey:exName]){
            [bean setFileType:FILE_MUSIC];
            if (dic.musicPathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.musicPathAry.count ; i ++){
                    FileBean *tmp = [dic.musicPathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    if ([tmp getFileDate] < [bean getFileDate]) {
                        [dic.musicPathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.musicPathAry addObject:bean];
                }
            }
            else {
                [dic.musicPathAry addObject:bean];
            }
        }else if ([PICTURE_EX_DIC objectForKey:exName]){
            [bean setFileType:FILE_IMG];
            if (dic.imgPathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.imgPathAry.count ; i ++){
                    FileBean *tmp = [dic.imgPathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    
//                    NSDate *tmpdate = [NSDate dateWithTimeIntervalSince1970:[tmp getFileDate]];
//                    NSDate *beandate = [NSDate dateWithTimeIntervalSince1970:[bean getFileDate]];
                    
                    BOOL isinsert = !isfromPhotoRoot? ([tmp getFileDate] < [bean getFileDate]) : ([tmp getCreateTime] > [bean getCreateTime]);
                    if(isinsert){
//                    if ([beandate timeIntervalSinceDate:tmpdate] <= 0.0) {
                        [dic.imgPathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.imgPathAry addObject:bean];
                }
            }
            else {
                [dic.imgPathAry addObject:bean];
            }
        }else if ([GIF_EX_DIC objectForKey:exName]){
            [bean setFileType:FILE_GIF];
            if (dic.imgPathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.imgPathAry.count ; i ++){
                    FileBean *tmp = [dic.imgPathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    
                    BOOL isinsert = !isfromPhotoRoot? ([tmp getFileDate] < [bean getFileDate]) : ([tmp getCreateTime] > [bean getCreateTime]);
                    if(isinsert){
//                    if ([tmp getFileDate] < [bean getFileDate]) {
                        [dic.imgPathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.imgPathAry addObject:bean];
                }
            }
            else {
                [dic.imgPathAry addObject:bean];
            }
        }
//        else if ([MOV_EX_DIC objectForKey:exName]){
//            [bean setFileType:FILE_MOV];
//            if (dic.imgPathAry.count > 0) {
//                BOOL hasAdded = NO;
//                BOOL hasIn = false;
//                for(int i = 0 ; i < dic.imgPathAry.count ; i ++){
//                    FileBean *tmp = [dic.imgPathAry objectAtIndex:i];
//                    if ([tmp.filePath isEqualToString:beanPath]) {
//                        hasIn = YES;
//                        break;
//                    }
//                    
//                    BOOL isinsert = !isfromPhotoRoot? ([tmp getFileDate] < [bean getFileDate]) : ([tmp getCreateTime] > [bean getCreateTime]);
//                    if(isinsert){
////                    if ([tmp getFileDate] < [bean getFileDate]) {
//                        [dic.imgPathAry insertObject:bean atIndex:i];
//                        hasAdded = YES;
//                        break;
//                    }
//                }
//                if (!hasAdded && !hasIn) {
//                    [dic.imgPathAry addObject:bean];
//                }
//            }
//            else {
//                [dic.imgPathAry addObject:bean];
//            }
//        }
        else if ([DOC_EX_DIC objectForKey:exName]){
            [bean setFileType:FILE_DOC];
            if (dic.docPathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.docPathAry.count ; i ++){
                    FileBean *tmp = [dic.docPathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    if ([tmp getFileDate] < [bean getFileDate]) {
                        [dic.docPathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.docPathAry addObject:bean];
                }
            }
            else {
                [dic.docPathAry addObject:bean];
            }
        }else{
            [bean setFileType:FILE_NONE];
            if (dic.nonePathAry.count > 0) {
                BOOL hasAdded = NO;
                BOOL hasIn = false;
                for(int i = 0 ; i < dic.nonePathAry.count ; i ++){
                    FileBean *tmp = [dic.nonePathAry objectAtIndex:i];
                    if ([tmp.filePath isEqualToString:beanPath]) {
                        hasIn = YES;
                        break;
                    }
                    if ([tmp getFileDate] < [bean getFileDate]) {
                        [dic.nonePathAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded && !hasIn) {
                    [dic.nonePathAry addObject:bean];
                }
            }
            else {
                [dic.nonePathAry addObject:bean];
            }
        }
    }
}

-(void)cleanPathCacheAll{
    
    [self.cachePathDic removeAllObjects];
    [_cacheIconDic removeAllObjects];
    [_cacheIconAry removeAllObjects];
    [_queueAry removeAllObjects];
    [_dispatchMusicArray removeAllObjects];
    [self.imgFileCachePathDic removeAllObjects];
}

-(UIImage *)getRectangular:(UIImage *)img{
    
    float imgW = img.size.width;
    float imgH = img.size.height;
    
    float ww = 0;
    float hh = 0;
    float xx = 156 * 2;
    if(imgW>imgH){
        hh = xx;
        ww = (hh/imgH)*imgW;
    }else{
        ww = xx;
        hh = (ww/imgW)*imgH;
    }
    
    UIImage *image = nil;
    image = [self zoomImg:img size:CGSizeMake(ww, hh) rect:CGRectMake(0, 0, ww, hh)];
    
    return image;
}

-(UIImage *)getSquareImg:(UIImage *)img{
    
    float imgW = img.size.width;
    float imgH = img.size.height;
    
    float ww = 0;
    float hh = 0;
    float xx = 200;
    if(imgW>imgH){
        hh = xx;
        ww = (hh/imgH)*imgW;
    }else{
        ww = xx;
        hh = (ww/imgW)*imgH;
    }
    
    UIImage *image = nil;
    image = [self zoomImg:img size:CGSizeMake(xx, xx) rect:CGRectMake((xx-ww)*0.5, (xx-hh)*0.5, ww, hh)];
    
    return image;
}

-(UIImage *)zoomImg:(UIImage *)img size:(CGSize)size rect:(CGRect)rect{
    
    UIImage *_image = img;
    UIGraphicsBeginImageContext(size);
    [img drawInRect:rect];
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _image;
}

@end
