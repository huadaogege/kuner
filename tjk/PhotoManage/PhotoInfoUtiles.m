//
//  FileInfoUtiles.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PhotoInfoUtiles.h"
#import "CustomFileManage.h"
#import "CustomAlertView.h"
#import "LogUtils.h"
#import "FileBean.h"

@interface PhotoInfoUtiles () <PHPhotoLibraryChangeObserver,CustomFileBeanDelegate>
{
    BOOL iscancel;
    int retryCount;
    NSString *bigMovFileID;
}

@end

@implementation PhotoInfoUtiles

static PhotoInfoUtiles *instance;

+(PhotoInfoUtiles *)instance{
    
    if(instance == nil){
        instance = [[PhotoInfoUtiles alloc] init];
    }
    return instance;
}

-(id)init{
    self = [super init];
    if(self){
        
        _alLibrary = [[ALAssetsLibrary alloc] init];
        _topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        _systemResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libChange:) name:ALAssetsLibraryChangedNotification object:nil];
        iscancel = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CustomAlertShowprogress:) name:CUSTOMALERTSHOWPROGRESS object:nil];
        bigMovFileID = @"";
    }
    return self;
}

-(void)resetLib {
    _alLibrary = [[ALAssetsLibrary alloc] init];
    _topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    _systemResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
}

-(void)fileOperateCancel:(NSNotification *)noti
{
    if ([noti.name isEqualToString:FILE_OPERATION_CANCEL] && ((NSNumber *)noti.object).intValue == Alert_PhotoIn) {
        iscancel = YES;
    }
}

-(void)CustomAlertShowprogress:(NSNotification *)noti
{
    if ([noti.name isEqualToString:CUSTOMALERTSHOWPROGRESS]) {
        iscancel = NO;
    }
}

+(BOOL)check{
    if(VERSION < 8){
        if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized){
            return YES;
        }
    }else{
        if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
            return YES;
        }
    }
    return NO;
}

- (void)libChange:(NSNotification *)notf{
    
    id obj = [notf.userInfo objectForKey:ALAssetLibraryInsertedAssetGroupsKey]; //创建相册
    if(obj){
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_CHANGE_NOTF object:nil];
    }else{
        NSSet *obj3 = [notf.userInfo objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
        if(obj3){
            NSArray *ary = [obj3 allObjects];
            if(ary.count > 0){
                NSURL *url = [ary firstObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:ASSET_CHANGE_NOTF object:url ];
            }
        }
    }
}

- (void)dealloc{
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{

        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:_topLevelUserCollections];
        PHFetchResultChangeDetails *changeDetails2 = [changeInstance changeDetailsForFetchResult:_systemResult];
        if (changeDetails || changeDetails2) {
            _topLevelUserCollections = [changeDetails fetchResultAfterChanges];
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_CHANGE_NOTF object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:ASSET_CHANGE_NOTF object:changeInstance];
        }
    });
}

-(void)getPhotoGroup:(void (^)(NSArray *ary))block{
    
    [self getPhotoGroup:block isHiddenSys:NO showType:TYPE_PHOTO];
}

-(void)getPhotoGroup:(void (^)(NSArray *ary))block isHiddenSys:(BOOL)isHiden showType:(typeCode)typeCode{
    
    __weak typeof(_alLibrary) weakLib = _alLibrary;
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        NSMutableArray *groupAry = [[NSMutableArray alloc] init];
        if(VERSION < 8){
            
            ALAssetsLibraryAccessFailureBlock aFailureblock = ^(NSError *myerror){
                
                if(myerror){
                    block(nil);
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop){
                
                if (group != nil){
                    
                    if (![[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:NSLocalizedString(@"photodelete", @"")]) {
                        
                        CustomPhotoGroup7_Bean *bean = [[CustomPhotoGroup7_Bean alloc] init];
                        [bean setAsset:group];
                        BOOL needAdd = NO;
                        if (typeCode == TYPE_PHOTO && [bean getPhotoCount:TYPE_PHOTO] > 0) {
                            needAdd = YES;
                        }
                        else if (typeCode == TYPE_VIDEO && [bean getPhotoCount:TYPE_VIDEO] > 0) {
                            needAdd = YES;
                        }
                        else if (typeCode == TYPE_ALL){
                            needAdd = YES;
                        }
                        if (needAdd) {
                            [groupAry addObject:bean];
                        }
                    }
                    
                }
                
                if(*stop || group == nil){
                    
                    block(groupAry);
                }
            };
            
            [weakLib enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:libraryGroupsEnumeration
                                    failureBlock:aFailureblock];
            
        }else{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized){
                    if(!isHiden){
                        
                        //系统相册
                        for (int i = 0; i < _systemResult.count; i++) {
                            PHAssetCollection *pc = [_systemResult objectAtIndex:i];
                            if (pc.assetCollectionSubtype == 1000000201) {
                                continue;
                            }
                            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:pc options:nil];
                            if(fetchResult.count > 0){
                                CustomPhotoGroup8_Bean *bean = [[CustomPhotoGroup8_Bean alloc] init];
                                [bean setAsset:pc];
                                BOOL needAdd = NO;
                                if (typeCode == TYPE_PHOTO && [bean getPhotoCount:TYPE_PHOTO] > 0) {
                                    needAdd = YES;
                                }
                                else if (typeCode == TYPE_VIDEO && [bean getPhotoCount:TYPE_VIDEO] > 0) {
                                    needAdd = YES;
                                }
                                else if (typeCode == TYPE_ALL){
                                    needAdd = YES;
                                }
                                if (needAdd) {
                                    if (pc.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                                        [groupAry insertObject:bean atIndex:0];
                                    }
                                    else{
                                        [groupAry addObject:bean];
                                    }
                                }
                            }
                        }
                    }
                    //用户相册
                    for (int i = 0; i < _topLevelUserCollections.count; i++) {
                        
                        PHAssetCollection *pc = [_topLevelUserCollections objectAtIndex:i];
                        if ([pc isKindOfClass:[PHAssetCollection class]]) {
                            CustomPhotoGroup8_Bean *bean = [[CustomPhotoGroup8_Bean alloc] init];
                            [bean setAsset:pc];
                            BOOL needAdd = NO;
                            if (typeCode == TYPE_PHOTO && [bean getPhotoCount:TYPE_PHOTO] > 0) {
                                needAdd = YES;
                            }
                            else if (typeCode == TYPE_VIDEO && [bean getPhotoCount:TYPE_VIDEO] > 0) {
                                needAdd = YES;
                            }
                            else if (typeCode == TYPE_ALL){
                                needAdd = YES;
                            }
                            if (needAdd) {
                                [groupAry addObject:bean];
                            }
                        }
//                        else {
//                            NSLog(@"pc %@",((PHCollectionList*)pc).localizedTitle);
//                        }
                    }
                    
                    block(groupAry);
                }else{
                    block(nil);
                }
            }];
        }
    });
}

-(void)freshGroup{
    
}

-(NSData*)getImageData:(NSString*)pathExt withImage:(UIImage*)img {
    NSData* imageData = nil;
    if([[pathExt lowercaseString] isEqualToString:@"png"]){
        
        imageData = UIImagePNGRepresentation(img);
    }else{
        
        imageData = UIImageJPEGRepresentation(img, 1.0);
    }
    return imageData;
}

-(void)copyPhoto:(CustomPhotoBean *)bean toPath:(NSString *)toPath delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    [bean getImgData:^(NSObject *data,NSString *name, NSString *photoId) {
//        NSData *data = dataTmp != nil ? [[NSData alloc] initWithBytes:[dataTmp bytes] length:dataTmp.length] : nil;
       
        NSMutableDictionary* beanInfos = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          bean,@"bean",
                                          toPath,@"toPath",
                                          delegate,@"delegate",
                                          name,@"name",
                                          photoId,@"photoId",
                                          nil];
        if (info) {
            [beanInfos setObject:info forKey:@"info"];
        }
        
        if (data) {
            [beanInfos setObject:data forKey:@"data"];
        }
        
        if ([data isKindOfClass:[NSString class]]) {
            NSString *path = (NSString *)data;
            FilePropertyBean *propertybean = [FileSystem readFileProperty:path];
            
            if (bean) {
                
                if (propertybean.size >= (1024.0*1024.0*1024.0*4.0)) {
                    NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         bean,@"bean",
                                                         delegate,@"delegate",
                                                         [NSNumber numberWithLong:propertybean.size],@"size",
                                                         nil];
                    if (info) {
                        [progressDict setObject:info forKey:@"info"];
                    }
                    [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
                    [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_BIGTHAN4G_ERROR needIgnoreCancel:YES];
                }
                else{
                    beanInfos = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 bean,@"bean",
                                 propertybean,@"propertybean",
                                 toPath,@"toPath",
                                 delegate,@"delegate",
                                 name,@"name",
                                 photoId,@"photoId",
                                 path,@"fromPath",
                                 nil];
                    if (info) {
                        [beanInfos setObject:info forKey:@"info"];
                    }
                    
                    
                    [NSThread detachNewThreadSelector:@selector(actionCopyWithCanCancelCopyFile:) toTarget:self withObject:beanInfos];
                }
            }
        }
        else{
            if ([bean getExistPhotoSize] >= (1024.0*1024.0*1024.0*4.0)) {
                NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     bean,@"bean",
                                                     delegate,@"delegate",
                                                     [NSNumber numberWithLong:[bean getExistPhotoSize]],@"size",
                                                     nil];
                if (info) {
                    [progressDict setObject:info forKey:@"info"];
                }
                [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
                [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_BIGTHAN4G_ERROR needIgnoreCancel:YES];
            }
            else{
                [NSThread detachNewThreadSelector:@selector(doCopyPhotos:) toTarget:self withObject:beanInfos];
            }
        }
        
    }];
}

-(void)docopyFileResult:(CustomPhotoBean *)bean delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info errorNum:(resultCode)error needIgnoreCancel:(BOOL)ignore
{
    [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:error needIgnoreCancel:ignore isRetry:NO];
}

-(void)docopyFileResult:(CustomPhotoBean *)bean delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info errorNum:(resultCode)error needIgnoreCancel:(BOOL)ignore isRetry:(BOOL)isretry
{
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       bean,@"bean",
                                       delegate,@"delegate",
                                       [NSNumber numberWithInteger:error],@"result",
                                       [NSNumber numberWithBool:ignore],@"needIgnoreCancel",
                                       nil];
    if (info) {
        [resultDict setObject:info forKey:@"info"];
    }
    
    if (isretry) {
        [self performSelector:@selector(deleyRetry:) withObject:resultDict afterDelay:2];
    }
    else{
        [self performSelectorOnMainThread:@selector(doProcessResult:) withObject:resultDict waitUntilDone:NO];
    }
    
}

-(void)deleyRetry:(NSDictionary*)resultDict{
    [self performSelectorOnMainThread:@selector(doProcessResult:) withObject:resultDict waitUntilDone:NO];
}

-(void)actionCopyWithCanCancelCopyFile:(NSMutableDictionary *)beanInfos{
    CustomPhotoBean* photobean = [beanInfos objectForKey:@"bean"];
    FilePropertyBean* propertyBean = [beanInfos objectForKey:@"propertybean"];
    NSString* toPath = [beanInfos objectForKey:@"toPath"];
    id<PhotoInfoUtiles> delegate = [beanInfos objectForKey:@"delegate"];
    id info = [beanInfos objectForKey:@"info"];
    NSString *fromPath = [beanInfos objectForKey:@"fromPath"];
    NSString *fileName = [fromPath lastPathComponent];
    NSString* resultPath = [toPath stringByAppendingPathComponent:fileName];
    if (!propertyBean || propertyBean.size == 0 || (![[CustomFileManage instance] isSystemInited] && [CustomFileManage getFilePosition:toPath] == POSITION_HARDDISK)) {
        [[CustomFileManage instance] removeFile:resultPath clearCache:YES];
        [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:!([[CustomFileManage instance] isSystemInited] && [CustomFileManage getFilePosition:toPath] == POSITION_HARDDISK ?PHOTO_RESULT_ERROR : PHOTO_RESULT_BIG_ERROR) needIgnoreCancel:NO];
        return;
    }
    
    
    FilePropertyBean* property = [FileSystem readFileProperty:resultPath];
    if (property.size == propertyBean.size) {
        NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             photobean,@"bean",
                                             delegate,@"delegate",
                                             [NSNumber numberWithLong:propertyBean.size],@"size",
                                             nil];
        if (info) {
            [progressDict setObject:info forKey:@"info"];
        }
        [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
        [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_FINISH needIgnoreCancel:YES];
        return;
    }
    else if (property.size > 0 && property.size != propertyBean.size){
        [[CustomFileManage instance] removeFile:resultPath];
        [[CustomFileManage instance] removeFileIconWithPath:resultPath filesize:property.size];
    }
    
    
    RESULTCODE flag = RESULT_ERROR;
//    FilePropertyBean *beanDir = [FileSystem readFileProperty:[toPath stringByDeletingLastPathComponent]];
//    if (!beanDir || beanDir.fileKind != FILE_KIND_DIR) {
//        [[CustomFileManage instance] creatDir:[toPath stringByDeletingLastPathComponent]];
//    }
    int readSfp;
    int writeSfp;
    readSfp = [FileSystem kr_open:fromPath flag:O_RDONLY, ACCESSPERMS];
    
    if (readSfp == -1 && errno == 1 && !iscancel) {
        if (retryCount <= 5) {
            if ([bigMovFileID isEqualToString:[photobean getPhotoId]]) {
                retryCount ++;
            }
            else{
                retryCount = 0;
                bigMovFileID = [photobean getPhotoId];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_RETRY needIgnoreCancel:NO isRetry:YES];
            });
            return;
        }
        else{
            retryCount = 0;
            bigMovFileID = @"";
        }
        
    }
    
    if (readSfp > 0) {
        writeSfp = [FileSystem kr_open:resultPath flag:O_CREAT|O_RDWR, ACCESSPERMS];
        if (delegate && [delegate respondsToSelector:@selector(markCopyingFilePath:)]) {
            [delegate markCopyingFilePath:resultPath];
        }
    }
    else{
        writeSfp = 0;
    }
    
    if( readSfp > 0 && writeSfp >0){
        float fileSize = propertyBean.size;
        float writeSize = 0;
        [FileSystem kr_fso_fsetattr:writeSfp size:0 time:[photobean getDateNumber]];
        size_t sizeof_buff = RW_BUFFER_SIZE;
        char* buff = (char*)malloc(sizeof_buff);
        float length = 0;
        if(buff){
            errno = 0;
            FILE_POSITION position = [CustomFileManage getFilePosition:toPath];
            while (writeSize < fileSize && (position != POSITION_HARDDISK || [FileSystem checkInit])) {
                if (iscancel) {
                    break;
                }
                memset(buff, 0, sizeof_buff);
                length = [FileSystem kr_read:readSfp buffer:buff size:sizeof_buff];
                if (length > 0) {
                    ssize_t writeLength = [FileSystem kr_writr:writeSfp buffer:buff size:length];
                    writeSize += writeLength;
                    if(writeLength >= 0){
                        
                        NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             photobean,@"bean",
                                                             delegate,@"delegate",
                                                             [NSNumber numberWithLong:writeLength],@"size",
                                                             nil];
                        if (info) {
                            [progressDict setObject:info forKey:@"info"];
                        }
                        [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
                    }else{
                        [[CustomFileManage instance] removeFile:resultPath];
                        flag = RESULT_ERROR;
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
        if (iscancel) {
            [[CustomFileManage instance] removeFile:resultPath clearCache:YES];
            
            [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_CANCE needIgnoreCancel:YES];
        }
        else{
//            [FileSystem kr_fso_setattr:filepath size:data.length time:[photobean getDateNumber]];
            [[CustomFileManage instance] insetFile:resultPath isDir:NO toPath:toPath fromPhotoRoot:YES];
            if(writeSize == fileSize) {
                [self performSelectorOnMainThread:@selector(doGetPictureIcon:) withObject:beanInfos waitUntilDone:NO];
            }
            else{
                [[CustomFileManage instance] removeFile:resultPath clearCache:YES];
                [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_ERROR needIgnoreCancel:NO];
            }
        }
        
        [FileSystem kr_close:readSfp];
        
    }
    else{
        [[CustomFileManage instance] removeFile:resultPath clearCache:YES];
        [self docopyFileResult:photobean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_ERROR needIgnoreCancel:NO];
        
    }
}

-(void)doCopyPhotos:(NSDictionary*)beanInfos {
    CustomPhotoBean* bean = [beanInfos objectForKey:@"bean"];
    NSString* toPath = [beanInfos objectForKey:@"toPath"];
    id<PhotoInfoUtiles> delegate = [beanInfos objectForKey:@"delegate"];
    id info = [beanInfos objectForKey:@"info"];
    NSData* data = [beanInfos objectForKey:@"data"];
    NSString* name = [beanInfos objectForKey:@"name"];
    NSString* filepath = [toPath stringByAppendingPathComponent:name];
    
//    NSString* photoId = [beanInfos objectForKey:@"photoId"];
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ doCopyPhotos getDataDone :: fliepath:%@",DEBUGMODEL,name]];
    if (!data || (![[CustomFileManage instance] isSystemInited] && [CustomFileManage getFilePosition:toPath] == POSITION_HARDDISK)) {
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ intrrupt copy :: fliepath:%@，data ＝＝ NULL",DEBUGMODEL,name]];
        [[CustomFileManage instance] removeFile:filepath clearCache:YES];
        [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:(![[CustomFileManage instance] isSystemInited]  && [CustomFileManage getFilePosition:toPath] == POSITION_HARDDISK ?PHOTO_RESULT_ERROR : PHOTO_RESULT_BIG_ERROR) needIgnoreCancel:NO];
        
        return;
    }
    
    
//    NSLog(@"%@",[NSString stringWithFormat:@"before copy, fliepath:%@",filepath]);
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ before readFileProperty :: fliepath:%@",DEBUGMODEL,filepath]];
    FilePropertyBean* property = [FileSystem readFileProperty:filepath];
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ after readFileProperty :: fliepath:%@",DEBUGMODEL,filepath]];
    if (property.size == data.length) {
        NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             bean,@"bean",
                                             delegate,@"delegate",
                                             [NSNumber numberWithLong:data.length],@"size",
                                             nil];
        if (info) {
            [progressDict setObject:info forKey:@"info"];
        }
        [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
        
        [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_FINISH needIgnoreCancel:YES];
        return;
    }
    else if (property.size > 0 && property.size !=  data.length){
        [[CustomFileManage instance] removeFile:filepath];
        [[CustomFileManage instance] removeFileIconWithPath:filepath filesize:property.size];
    }
    errno = 0;
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ before kr_openy :: fliepath:%@",DEBUGMODEL,filepath]];
    int flag = [FileSystem kr_open:filepath flag:O_CREAT|O_RDWR, ACCESSPERMS];
//    [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_open :: fliepath:%@",DEBUGMODEL,filepath]];
    if(flag >= 0){
        
        if (delegate && [delegate respondsToSelector:@selector(markCopyingFilePath:)]) {
            [delegate markCopyingFilePath:filepath];
        }
        
        size_t sizeof_buff = RW_BUFFER_SIZE;
        uint8_t* buff = (uint8_t*)malloc(sizeof_buff);
        if(!buff){
            [[CustomFileManage instance] removeFile:filepath clearCache:YES];
            [LogUtils writeLog:[NSString stringWithFormat:@"%@ intrrupt copy :: fliepath:%@，buff ＝＝ NULL",DEBUGMODEL,filepath]];
            NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               bean,@"bean",
                                               delegate,@"delegate",
                                               [NSNumber numberWithInteger:PHOTO_RESULT_ERROR],@"result",
                                               [NSNumber numberWithBool:NO],@"needIgnoreCancel",
                                               nil];
            if (info) {
                [resultDict setObject:info forKey:@"info"];
            }
            [self performSelectorOnMainThread:@selector(doProcessResult:) withObject:resultDict waitUntilDone:NO];
            return;
        }
        NSUInteger wl = 0;
        NSUInteger lwl = 0;
        NSInteger length = data.length;
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ begin while copy",DEBUGMODEL]];
        while (wl < length) {
            if (iscancel || ([FileSystem isConnectedKE] && ![FileSystem checkInit]) || (![[CustomFileManage instance] isSystemInited] && [CustomFileManage getFilePosition:toPath] == POSITION_HARDDISK)) {
                break;
            }
            if (lwl == wl && lwl != 0) {
                [LogUtils writeLog:[NSString stringWithFormat:@"%@ intrrupt copy :: fliepath:%@， , inited: %d",DEBUGMODEL,filepath, [FileSystem checkInit]]];
            }
            lwl = wl;
            memset(buff, 0, sizeof_buff);
            NSInteger subLength = length - wl > RW_BUFFER_SIZE ?  RW_BUFFER_SIZE : length - wl;
            //                    NSData* subData = [data subdataWithRange:NSMakeRange(wl, subLength)];
            [data getBytes:buff range:NSMakeRange(wl, subLength)];
            ssize_t size = [FileSystem kr_writr:flag buffer:buff size:subLength];;
            if(size > subLength || size == -1){
                [LogUtils writeLog:[NSString stringWithFormat:@"%@ intrrupt copy, fliepath:%@， size: %zd, subLength : %zd , errno: %d",DEBUGMODEL,filepath, size, subLength,errno]];
                break;
            }
            wl += size;
            NSMutableDictionary* progressDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               bean,@"bean",
                                               delegate,@"delegate",
                                               [NSNumber numberWithLong:size],@"size",
                                               nil];
            if (info) {
                [progressDict setObject:info forKey:@"info"];
            }
            [self performSelectorOnMainThread:@selector(doProcessProgress:) withObject:progressDict waitUntilDone:NO];
        }
        
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after while copy",DEBUGMODEL]];
        if (buff) {
            free(buff);
            buff = NULL;
        }
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ before kr_close :: fliepath:%@",DEBUGMODEL,filepath]];
        [FileSystem kr_close:flag];
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ after kr_close :: fliepath:%@",DEBUGMODEL,filepath]];
        if (iscancel) {
            [[CustomFileManage instance] removeFile:filepath clearCache:YES];
            
            [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_CANCE needIgnoreCancel:YES];
        }
        else{
//            [LogUtils writeLog:[NSString stringWithFormat:@"after fliepath:%@",filepath]];
//            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[bean getDateNumber]];
//            NSLog(@"photo date :%@",date);
            [FileSystem kr_fso_setattr:filepath size:data.length time:[bean getDateNumber]];
//            if (![FileSystem isConnectedKE] && ![FileSystem checkInit]) {
//                NSFileManager *mannager = [NSFileManager defaultManager];
//                [mannager setAttributes:[NSDictionary dictionaryWithObject:date forKey:@"NSFileCreationDate"] ofItemAtPath:filepath error:nil];
//            }

            [[CustomFileManage instance] insetFile:filepath isDir:NO toPath:toPath fromPhotoRoot:YES];
            if(wl == length) {
                [self performSelectorOnMainThread:@selector(doGetPictureIcon:) withObject:beanInfos waitUntilDone:NO];
            }
            else{
                [[CustomFileManage instance] removeFile:filepath clearCache:YES];
                [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_ERROR needIgnoreCancel:NO];
                NSLog(@"COPY LENGTH error");
            }
        }
        
    }else{
//        [LogUtils writeLog:[NSString stringWithFormat:@"%@ intrrupt copy, fliepath:%@， flag: %d, errno: %d",DEBUGMODEL,filepath, flag, errno]];
        [[CustomFileManage instance] removeFile:filepath clearCache:YES];
        [self docopyFileResult:bean delegate:delegate userInfo:info errorNum:PHOTO_RESULT_ERROR needIgnoreCancel:NO];
    }
//    NSLog(@"%@",[NSString stringWithFormat:@"after copy, fliepath:%@",filepath]);
}

-(void)doGetPictureIcon:(NSDictionary*)beanInfos {
    CustomPhotoBean* bean = [beanInfos objectForKey:@"bean"];
    NSString* toPath = [beanInfos objectForKey:@"toPath"];
    id<PhotoInfoUtiles> delegate = [beanInfos objectForKey:@"delegate"];
    id info = [beanInfos objectForKey:@"info"];
    NSData* data = [beanInfos objectForKey:@"data"];
    NSString* name = [beanInfos objectForKey:@"name"];
    FilePropertyBean* propertyBean = [beanInfos objectForKey:@"propertybean"];
    NSString* toPathDir = [[CustomFileManage instance] getFileIconCacheDir:toPath];
    @autoreleasepool {
        [bean getIcon:^(UIImage *img, NSString *name0) {
            //                                dispatch_async(dispatch_queue_create(0, 0), ^{
            NSString *fileName = [DESUtils getMD5:[NSString stringWithFormat:@"%@%f", name, (float)data.length == 0?propertyBean.size:(float)data.length]];
            
            NSString *tempImgPath = [toPathDir stringByAppendingPathComponent:fileName];
            if (!img) {
                [LogUtils writeLog:@" img == nil "];
            }
            UIImage* img11 = [[CustomFileManage instance] getSquareImg:img];
            if (!img11) {
                [LogUtils writeLog:@" img11 == nil "];
            }
            
            if (!img11 && img) {
                img11 = [[CustomFileManage instance] getSquareImg:img];
            }
            if(img11){
                NSData *imgData;
                NSString* pathExt = [name pathExtension];
                imgData = [self getImageData:pathExt withImage:img11];
                if (!imgData) {
                    [LogUtils writeLog:@" imgData == nil "];
                    imgData = [self getImageData:pathExt withImage:img11];
                }
                if (!imgData) {
                    [LogUtils writeLog:@" imgData == nil (again)"];
                }
                NSMutableDictionary* iconDict = [NSMutableDictionary dictionaryWithDictionary:beanInfos];
                if (tempImgPath) {
                    [iconDict setObject:tempImgPath forKey:@"tempImgPath"];
                }
                if (imgData) {
                    [iconDict setObject:imgData forKey:@"imgData"];
                }
                [NSThread detachNewThreadSelector:@selector(doWriteIconTmp:) toTarget:self withObject:iconDict];
                
            }
            else {
                [LogUtils writeLog:@" img11 == nil (again) "];
                //                    [FileSystem writeFileToPath:[tempImgPath stringByDeletingPathExtension] DataFile:imgData_];
                NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   bean,@"bean",
                                                   delegate,@"delegate",
                                                   [NSNumber numberWithInteger:PHOTO_RESULT_FINISH],@"result",
                                                   [NSNumber numberWithBool:YES],@"needIgnoreCancel",
                                                   nil];
                if (info) {
                    [resultDict setObject:info forKey:@"info"];
                }
                [self performSelectorOnMainThread:@selector(doProcessResult:) withObject:resultDict waitUntilDone:NO];
            }
            
            //                                });
            
        }];
    }
    
}

-(void)doWriteIconTmp:(NSMutableDictionary*)iconDict{
    CustomPhotoBean* bean = [iconDict objectForKey:@"bean"];
    id<PhotoInfoUtiles> delegate = [iconDict objectForKey:@"delegate"];
    id info = [iconDict objectForKey:@"info"];
    NSString* tempImgPath = [iconDict objectForKey:@"tempImgPath"];
    NSData* imgData = [iconDict objectForKey:@"imgData"];
    if (imgData.length > 0) {
        [imgData writeToFile:tempImgPath atomically:YES];
    }
    
    //                    [FileSystem writeFileToPath:[tempImgPath stringByDeletingPathExtension] DataFile:imgData_];
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       bean,@"bean",
                                       delegate,@"delegate",
                                       [NSNumber numberWithInteger:PHOTO_RESULT_FINISH],@"result",
                                       [NSNumber numberWithBool:YES],@"needIgnoreCancel",
                                       nil];
    if (info) {
        [resultDict setObject:info forKey:@"info"];
    }
    [iconDict removeAllObjects];
    [self performSelectorOnMainThread:@selector(doProcessResult:) withObject:resultDict waitUntilDone:NO];
}

-(void)doProcessResult:(NSMutableDictionary*)resultDict{
    id<PhotoInfoUtiles> delegate = [resultDict objectForKey:@"delegate"];
    NSNumber* result = [resultDict objectForKey:@"result"];
    CustomPhotoBean* bean = [resultDict objectForKey:@"bean"];
    id info = [resultDict objectForKey:@"info"];
    NSNumber* needIgnoreCancel = [resultDict objectForKey:@"needIgnoreCancel"];
    [resultDict removeAllObjects];
    if((needIgnoreCancel.boolValue || !iscancel) && delegate && [delegate respondsToSelector:@selector(actionResult:result:userInfo:)]){
        
        [delegate actionResult:bean result:result.integerValue userInfo:info];
    }
}

-(void)doProcessProgress:(NSMutableDictionary*)resultDict{
    id<PhotoInfoUtiles> delegate = [resultDict objectForKey:@"delegate"];
    NSNumber* size = [resultDict objectForKey:@"size"];
    CustomPhotoBean* bean = [resultDict objectForKey:@"bean"];
    id info = [resultDict objectForKey:@"info"];
    if(delegate && [delegate respondsToSelector:@selector(progress:bean:userInfo:)]){
        
        [delegate progress:size.longValue bean:bean userInfo:info];
    }
    [resultDict removeAllObjects];
}

//在相册下创建图片
-(void)creatPhoto:(FileBean *)file toGroup:(CustomPhotoGroupBean *)group delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    NSDictionary* dict = nil;
    if (info) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              file,@"file",
                              group,@"group",
                              delegate,@"delegate",
                              info,@"info",
                              nil];
    }
    else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              file,@"file",
                              group,@"group",
                              delegate,@"delegate",
                              info,@"info",
                              nil];
    }
    [self performSelector:@selector(doCreatePhoto:) withObject:dict afterDelay:.01];
}

-(void)doCreatePhoto:(NSDictionary*)dict {
    FileBean * file = [dict objectForKey:@"file"];
    CustomPhotoGroupBean * group = [dict objectForKey:@"group"];
    id<PhotoInfoUtiles> delegate = [dict objectForKey:@"delegate"];
    id info = [dict objectForKey:@"info"];
    if(VERSION < 8){
        
        [self creatPhotoFor7:file toGroup:group delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }else{
        [self creatPhotoFor8:file toGroup:group delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }
}

-(void)creatPhotoFor7:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    if(file.fileType == FILE_IMG || file.fileType == FILE_GIF){

        [self copyImgToGroup7:file toGroup:assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }else if (file.fileType == FILE_MOV){
        
        switch ([file getFilePosition]) {
            case POSITION_HARDDISK:{
                
                dispatch_async(dispatch_queue_create(0, 0), ^{
                    
                    NSString* cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"];
                    RESULTCODE ret = [[CustomFileManage instance] actionCopyOutFile:file toPath:cachePath delegate:nil info:nil isSend:NO forMusic:NO];
                    if(ret == RESULT_FINISH){
                        NSString *path = [NSString stringWithFormat:@"%@/%@",cachePath,file.fileName];
                        [self copyMovToPhone7:path toGroup:assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:file];
                    }
                });
                
                break;
            }
            case POSITION_DEVICE:
                
                [self copyMovToPhone7:file.filePath toGroup:assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:file];
                break;
            default:
                
                //尚未支持
                break;
        }

    }else{
        
        if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
            [delegate addPhotoToGroup:NO userInfo:info bean:file];
        }
    }
}

-(void)copyMovToPhone7:(NSString *)filePath toGroup:(CustomPhotoGroupBean *)assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:(FileBean*)fileBean{
    
    [_alLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:filePath]
                                   completionBlock:^(NSURL *assetURL, NSError *error) {
                                       
                                       [self saveToGroup7:assetURL toGroup:assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:fileBean];
                                       
                                       [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }];
}

-(void)copyImgToGroup7:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    [_alLibrary writeImageDataToSavedPhotosAlbum:file.fileData
                                        metadata:nil
                                 completionBlock:^(NSURL *assetURL, NSError *error) {
                                     
                                     [self saveToGroup7:assetURL toGroup:assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:file];
                                 }];
}

-(void)saveToGroup7:(NSURL *)assetURL toGroup:(CustomPhotoGroupBean *)assetGroup delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info bean:(FileBean*)fileBean{
    [_alLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        
        [(ALAssetsGroup *)[assetGroup getAsset] addAsset:asset];
        if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
            [delegate addPhotoToGroup:YES userInfo:info bean:fileBean];
        }
    } failureBlock:^(NSError *error) {
        
        if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
            [delegate addPhotoToGroup:NO userInfo:info bean:fileBean];
        }
    }];
}

-(void)creatPhotoFor8:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{

    if(file.fileType == FILE_IMG || file.fileType == FILE_GIF){
        
        [self copyImgToGroup8:file toGroup:assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }else if (file.fileType == FILE_MOV){
            [self copyMovToGroup8:file toGroup:assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }else{
        
        if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
            [delegate addPhotoToGroup:NO userInfo:info bean:file];
        }
    }
}

-(void)copyImgToGroup8:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    __block NSURL *url = nil;
    __block NSString *cachePath = nil;
    switch ([file getFilePosition]) {
        case POSITION_HARDDISK:{
            
            dispatch_async(dispatch_queue_create(0, 0), ^{
                cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"];
                FilePropertyBean* PropertyBean = [FileSystem readFileProperty:file.filePath];
                NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
                float allSize = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue];
                if (PropertyBean.size > allSize) {
                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroupErrorSpaceNotEnough:)]){
                        [delegate addPhotoToGroupErrorSpaceNotEnough:file];
                    }
                    return;
                }
                else{
                    RESULTCODE ret = [[CustomFileManage instance] actionCopyOutFile:file toPath:cachePath delegate:nil info:nil isSend:NO forMusic:NO];
                    cachePath = [NSString stringWithFormat:@"%@/%@",cachePath,file.fileName];
                    if(ret == RESULT_FINISH){
                        url = [NSURL fileURLWithPath:cachePath];
                    }
                    [self copyImageToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:ret != RESULT_USER_CANCEL];
                }
            });
            break;
        }
        case POSITION_DEVICE:
        {
            url = [NSURL fileURLWithPath:file.filePath];
            [self copyImageToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:YES];
            break;
        }
        default:
            
            //尚未支持
            [self copyImageToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:YES];
            break;
    }
    
}

-(void)copyImageToGroup8ResultWithUrl:(NSURL *)url cachePath:(NSString *)cachePath fileBean:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info isCheck:(BOOL)ischeck
{
    if(url == nil || ![[CustomFileManage instance] existFile:file.filePath] || ((![FileSystem checkInit] && [FileSystem isConnectedKE]))){
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        if (ischeck) {
            if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
                [delegate addPhotoToGroup:NO userInfo:info bean:file];
            }
        }
    }
    else {
        __block BOOL result = YES;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //        UIImage *img = [UIImage imageWithData:file.fileData];
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
            if(assetChangeRequest != nil){
                PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:(PHAssetCollection *)[assetCollection getAsset]];
                [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
            }
            else {
                result = NO;
                [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //                if(success){
                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
                        [delegate addPhotoToGroup:result userInfo:info bean:file];
                    }
                });
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (result) {
                [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //                if(success){
                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
                        [delegate addPhotoToGroup:success userInfo:info bean:file];
                    }
                    //                }
                    //                else {
                    //                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroupErrorSpaceNotEnough)]){
                    //                        [delegate addPhotoToGroupErrorSpaceNotEnough];
                    //                    }
                    //                }
                });

            }
        }];
    }
}

-(void)copyMovToGroup8:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    __block NSURL *url = nil;
    __block NSString *cachePath = nil;
    switch ([file getFilePosition]) {
        case POSITION_HARDDISK:{
            
            dispatch_async(dispatch_queue_create(0, 0), ^{
                cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/"];
                FilePropertyBean* PropertyBean = [FileSystem readFileProperty:file.filePath];
                NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
                float allSize = [[fattributes objectForKey:NSFileSystemFreeSize] floatValue];
                
                if (PropertyBean.size > allSize) {
                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroupErrorSpaceNotEnough:)]){
                        [delegate addPhotoToGroupErrorSpaceNotEnough:file];
                    }
                }
                else{
                    RESULTCODE ret = [[CustomFileManage instance] actionCopyOutFile:file toPath:cachePath delegate:nil info:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"] isSend:NO forMusic:NO];
                    cachePath = [NSString stringWithFormat:@"%@/%@",cachePath,file.fileName];
                    if(ret == RESULT_FINISH){
                        url = [NSURL fileURLWithPath:cachePath];
                        
                        if (delegate && [delegate respondsToSelector:@selector(copyToLocalDone:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                               [delegate copyToLocalDone:file];
                            });
                        }
                    }
                    [self copyMovToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:ret != RESULT_USER_CANCEL];
                }
                
            });
            break;
        }
        case POSITION_DEVICE:
        {
            url = [NSURL fileURLWithPath:file.filePath];
            [self copyMovToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:YES];
            break;
        }
        default:
            
            //尚未支持
            [self copyMovToGroup8ResultWithUrl:url cachePath:cachePath fileBean:file toGroup:assetCollection delegate:delegate userInfo:info isCheck:YES];
            break;
    }
}

-(void)copyMovToGroup8ResultWithUrl:(NSURL *)url cachePath:(NSString *)cachePath fileBean:(FileBean *)file toGroup:(CustomPhotoGroupBean *)assetCollection delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info isCheck:(BOOL)ischeck
{
    if(url == nil || ![[CustomFileManage instance] existFile:file.filePath] || ((![FileSystem checkInit] && [FileSystem isConnectedKE]) )){
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
        if (ischeck) {
            if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
                [delegate addPhotoToGroup:NO userInfo:info bean:file];
            }
        }
    }
    else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:(PHAssetCollection *)[assetCollection getAsset]];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        } completionHandler:^(BOOL success, NSError *error) {
            
            [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //                if(success){
                if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroup:userInfo:bean:)]){
                    [delegate addPhotoToGroup:success userInfo:info bean:file];
                }
                //                }
                //                else {
                //                    if(delegate && [delegate respondsToSelector:@selector(addPhotoToGroupErrorSpaceNotEnough)]){
                //                        [delegate addPhotoToGroupErrorSpaceNotEnough];
                //                    }
                //                }
            });
            
        }];
    }
}

//创建相册
-(void)creatGroup:(NSString *)name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    if(VERSION < 8){
        [self creatGroupFor7:name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }else{
        [self creatGroupFor8:name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info];
    }
}

-(void)creatGroupFor7:(NSString *)name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    [_alLibrary addAssetsGroupAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
        
        if(delegate && [delegate respondsToSelector:@selector(creatGroup:userInfo:)]){
            BOOL success = group?YES:NO;
            [delegate creatGroup:success userInfo:info];
        }
    } failureBlock:^(NSError *error) {
        
        if(delegate && [delegate respondsToSelector:@selector(creatGroup:userInfo:)]){
            [delegate creatGroup:NO userInfo:info];
        }
    }];
}

-(void)creatGroupFor8:(NSString *)name delegate:(id<PhotoInfoUtiles>)delegate userInfo:(id)info{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name];
    } completionHandler:^(BOOL success, NSError *error) {

        if(delegate && [delegate respondsToSelector:@selector(creatGroup:userInfo:)]){
            [delegate creatGroup:success userInfo:info];
        }
    }];
}
@end
