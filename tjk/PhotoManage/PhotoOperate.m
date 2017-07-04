//
//  PhotoOperate.m
//  KUKE
//
//  Created by 呼啦呼啦圈 on 15/3/25.
//  Copyright (c) 2015年 呼啦呼啦圈. All rights reserved.
//

#import "PhotoOperate.h"
#import "CustomAlertView.h"
#import "CustomFileManage.h"
#import "MobClickUtils.h"
#import "LogUtils.h"

#define TAG_ERROR 1111
#define TAG_NOFREE 2222
#define TAG_ERROR_BROKEN 3333
@implementation PhotoOperate


//static bool inited = false;

-(id)init{
    self = [super init];
    if(self){
        inited = true;
        _copyPhotosDic = [[NSMutableDictionary alloc] init];
        _processArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
    }
    return self;
}

-(void)dealloc{
    inited = false;
    [_copyAry removeAllObjects];
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fileOperateCancel:(NSNotification *)noti
{
    if ([noti.name isEqualToString:FILE_OPERATION_CANCEL]) {
        [_copyAry removeAllObjects];
        [_copyPhotosDic removeAllObjects];
        [_processArray removeAllObjects];
        
        if (_nowcopyingPath) {
            [[CustomFileManage instance]removeFile:_nowcopyingPath clearCache:YES];
        }
        
        [self actionArrayCountEqualZeroAction];
    }
}

-(void)actionArrayCountEqualZeroAction
{
    [self nodelegateEqualZeroAction];
    [self delegateResult];
}

-(void)delegateResult
{
    if(self.delegate && [self.delegate isKindOfClass:[UIViewController class]] && [self.delegate respondsToSelector:@selector(actionResult:userInfo:)]){
        
        [self.delegate actionResult:YES userInfo:_userInfo];
    }
}

-(void)nodelegateEqualZeroAction
{
    [[CustomAlertView instance] setNowNum:[[CustomAlertView instance] getFilesCount] currentSize:_countSize allSize:_countSize];
    [[CustomAlertView instance] progress:1.0];
    [[CustomAlertView instance] hidden];
    if (_processArray.count > 0) {
        [_processArray removeAllObjects];
    }
    _processPhotoID = nil;
}

-(void)getCanRemoveResInfo:(ResourceType)resType progress:(void(^)(NSInteger count, NSUInteger size,BOOL finish,NSArray* filebeans,NSDictionary* photos))block{
    NSString* scanPath = [self getResRootPath:resType];//
    NSArray* fileBeans = [self getResFileBeans:resType path:scanPath];
    NSMutableArray* canRemovePhotoBeans = [[NSMutableArray alloc] init];
    NSMutableArray* uncanRemovePhotoBeans = [[NSMutableArray alloc] init];
    NSMutableArray* canRemoveFileBeans = [[NSMutableArray alloc] init];
    NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
    __block NSUInteger sizeTmp = 0;
    
    [[PhotoInfoUtiles instance] getPhotoGroup:^(NSArray *ary) {
        for (CustomPhotoGroupBean* group in ary) {
            //            NSLog(@"group name : %@",[group getName]);
            if ([[group getName] isEqualToString:@"相机胶卷"] || [[group getName] isEqualToString:@"Camera Roll"] ) {
                NSLog(@"loop pic start");
                [group getPhotos:(resType == Picture_Res_Type ? TYPE_PHOTO : TYPE_VIDEO) withBlock:^(NSArray *allAry) {
                    NSLog(@"loop start");
                    [tmpDict setObject:allAry forKey:@"All_Photo"];
                    [self getCanRemoveResInfoWith:fileBeans withPhotos:allAry progress:^(FileBean *fileBean,CustomPhotoBean* photo) {
                        NSInteger index = [allAry indexOfObject:photo];
                        BOOL finish = (index == allAry.count - 1);
                        if (fileBean) {
                            [canRemovePhotoBeans addObject:photo];
                            [canRemoveFileBeans addObject:fileBean];
                            sizeTmp += [fileBean getFileSize];
                            [tmpDict setObject:canRemovePhotoBeans forKey:@"Copyed_Photo"];
                            block(canRemovePhotoBeans.count,sizeTmp,finish,canRemoveFileBeans,tmpDict);
                            
                        }
                        else {
                            [uncanRemovePhotoBeans addObject:photo];
                            [tmpDict setObject:uncanRemovePhotoBeans forKey:@"Uncopyed_Photo"];
                            block(canRemovePhotoBeans.count,sizeTmp,finish,canRemoveFileBeans,tmpDict);
                        }
                        if (finish) {
                            NSLog(@"  ****************** copyed length : %ld ,uncopyed length : %ld",canRemovePhotoBeans.count,uncanRemovePhotoBeans.count);
                            NSLog(@"  ****************** loop end111 : %ld",(long)index);
                        }
                        
                    }];
                }];
                break;
            }
        }
    } isHiddenSys:NO showType:resType == Picture_Res_Type ? TYPE_PHOTO : TYPE_VIDEO];
    
    
}

-(void)getCanRemoveResInfoWith:(NSArray*)beans withPhotos:(NSArray*)allAry progress:(void(^)(FileBean* filebean,CustomPhotoBean* photo))block{
    __block NSInteger index = -1;
    __block BOOL sendFinish = NO;
    NSMutableArray* tmpFileBeans = [NSMutableArray arrayWithArray:beans];
    for (NSInteger i = 0 ; i < allAry.count ; i ++) {
        CustomPhotoBean* photo = [allAry objectAtIndex:i];
        
        index = i;
        __block BOOL needWait = YES;
        
        [photo getImgData:^(NSData *data, NSString *name, NSString *photoId) {
            NSMutableArray* tmpFileBeans2 = [NSMutableArray arrayWithArray:tmpFileBeans];
            for (NSInteger j = 0 ; j < tmpFileBeans2.count ; j ++) {
                FileBean* fileBean = [tmpFileBeans2 objectAtIndex:j];
                if (data.length == [fileBean getFileSize] && [name isEqualToString:[fileBean getFileName]]) {
                    
                    //                    NSLog(@"name : %@ , time 1 : %ld , time 2 : %ld",name,(long)[photo getDateNumber],[fileBean getCreateTime]);
                    [tmpFileBeans removeObject:fileBean];
                    block(fileBean,photo);
                    needWait = NO;
                    sendFinish = YES;
                    break;
                }
                else if(j == tmpFileBeans2.count - 1){
                    sendFinish = YES;
                    block(nil,photo);
                }
                needWait = NO;
                
            }
            
        }];
        while (needWait) {
            
        }
    }
}

-(NSString*)getResRootPath:(ResourceType)resType{
    if (resType == Picture_Res_Type) {
        return  KE_PHOTO;
    }
    else if (resType == Video_Res_Type) {
        return  KE_VIDEO;
    }
    else if (resType == Document_Res_Type) {
        return  KE_DOC;
    }
    else if (resType == Music_Res_Type) {
        return  KE_MUSIC;
    }
    return KE_ROOT;
}

-(NSArray*)getResFileBeans:(ResourceType)resType path:(NSString*)path{
    NSMutableArray* fileBeans = [[NSMutableArray alloc] init];
    PathBean* pathBean = [[CustomFileManage instance] getFiles:path];
    if (pathBean.dirPathAry.count > 0) {
        for (FileBean* bean in pathBean.dirPathAry) {
            NSArray* tmp = [self getResFileBeans:resType path:[bean getFilePath]];
            if (tmp.count > 0) {
                [fileBeans addObjectsFromArray:tmp];
            }
        }
    }
    if (resType == Picture_Res_Type) {
        if (pathBean.imgPathAry.count > 0) {
            [fileBeans addObjectsFromArray:pathBean.imgPathAry];
        }
    }
    else if (resType == Video_Res_Type) {
        for (FileBean* bean in pathBean.videoPathAry) {
            if ([[[[bean getFilePath] pathExtension] lowercaseString] isEqualToString:@"mov"]) {
                [fileBeans addObject:bean];
            }
        }
    }
    return fileBeans;
}

-(void)copyPhotos:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info{

    _copyAry = [[NSMutableArray alloc] initWithArray:beans];
    [_copyPhotosDic removeAllObjects];
    _toPath = toPath;
    self.photoCount = 0;
    _nowSize = 0;
    _countSize = 0;
    _userInfo = info;
    _processPhotoID = nil;
    if(_copyAry.count > 0){
        
        NSDictionary *dict = (NSDictionary *)_userInfo;
        NSNumber *mediaType = [dict objectForKey:@"importType"];
        NSString *tipstr = NSLocalizedString(@"importphoto", @"");
        if (mediaType && mediaType.intValue == TYPE_VIDEO) {
            tipstr = NSLocalizedString(@"importvideo", @"");
        }
        [[CustomAlertView instance] setMsg:tipstr];
        [[CustomAlertView instance] showProgress];
        [self getSize];
        
    }
}

-(void)getSize{
    
    if (!_copyAry || _copyAry.count == 0 || (![FileSystem checkInit] && [CustomFileManage getFilePosition:_toPath] == POSITION_HARDDISK)) {
        [[CustomAlertView instance] hidden];
        return;
    }
    @autoreleasepool {
        if (self.photoCount<_copyAry.count) {
            CustomPhotoBean *bean = [_copyAry objectAtIndex:self.photoCount];
            [_copyPhotosDic setObject:@"1" forKey:bean.getPhotoId];
            [bean getPhotoSize:^(NSUInteger size) {
                NSNumber* sizeN = [NSNumber numberWithUnsignedInteger:size];
                [NSThread detachNewThreadSelector:@selector(countPhotoSize:) toTarget:self withObject:sizeN];
            }];
        }
    }
}

-(void)countPhotoSize:(NSNumber*)size{
    //        for (CustomPhotoBean *bean in _copyAry) {
    self.photoCount++;
    _countSize += size.unsignedIntegerValue;
    [[CustomAlertView instance] setNowCountSize:_countSize];
    if(self.photoCount == _copyAry.count){
        unsigned long long allSize = 0;
        if([_toPath hasPrefix:KE_PHOTO] || [_toPath hasPrefix:KE_VIDEO] || [_toPath hasPrefix:KE_MUSIC] || [_toPath hasPrefix:KE_DOC] || [_toPath hasPrefix:KE_ROOT]){
            if (![FileSystem checkInit]) {
                [[CustomAlertView instance] hidden];
                return;
            }
            allSize = [FileSystem get_info].free_size;
        }else{
            NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
            allSize = [[fattributes objectForKey:NSFileSystemFreeSize] unsignedIntegerValue];
        }
        if(_countSize > allSize){
            [self performSelectorOnMainThread:@selector(showCopySpaceAlert) withObject:nil waitUntilDone:NO];
            
        }else{
            [self performSelectorOnMainThread:@selector(toDoActionCopy) withObject:nil waitUntilDone:NO];
        }
    }else{
        [self performSelectorOnMainThread:@selector(getSize) withObject:nil waitUntilDone:NO];
    }

}

-(void)showCopySpaceAlert{
    [[CustomAlertView instance] hidden];
    [_copyAry removeAllObjects];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"notplace", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
    [alert show];
}

-(void)toDoActionCopy{
    [[CustomAlertView instance] setFilesCount:(int)_copyAry.count];
//    NSDictionary *dict = (NSDictionary *)_userInfo;
//    NSNumber *mediaType = [dict objectForKey:@"importType"];
//    NSString *tipstr = NSLocalizedString(@"importphoto", @"");
//    if (mediaType && mediaType.intValue == TYPE_VIDEO) {
//        tipstr = NSLocalizedString(@"importvideo", @"");
//    }
//    [[CustomAlertView instance] setMsg:tipstr];
    
    [self actionCopy];
}

-(void)actionCopy{
    _nowcopyingPath = nil;
    if(_copyAry.count > 0){
        CustomPhotoBean *bean = [_copyAry firstObject];
#ifndef _ERROR_CODE_TEST_
        if (_processArray.count == 0 && ![_processPhotoID isEqualToString:[bean getPhotoId]]) {
#endif
//            [LogUtils writeLog:[NSString stringWithFormat:@"%@ actionCopy :: fliepath:%@",DEBUGMODEL,_processPhotoID]];
            int count = [[CustomAlertView instance] getFilesCount] - (int)_copyAry.count;
            [[CustomAlertView instance] setNowNum:count currentSize:_nowSize allSize:_countSize];
            _tempSize = 0;
            _processPhotoID = [bean getPhotoId];
            [_processArray addObject:_processPhotoID];
            [[PhotoInfoUtiles instance] copyPhoto:bean toPath:_toPath delegate:self userInfo:bean.getPhotoId];
#ifndef _ERROR_CODE_TEST_
            }
#endif
    }else{

//        [[CustomFileManage instance] cleanPathCache:_toPath];
        
        [self actionArrayCountEqualZeroAction];
    }
}

-(void)savePhotoID:(CustomPhotoBean *)bean
{
//    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
//    [userdefaults setObject:_nowcopyingPath forKey:_processPhotoID];
}

-(void)actionResult:(CustomPhotoBean *)bean result:(resultCode)result userInfo:(id)info{
    
    if(PHOTO_RESULT_FINISH == result){
        
        if([_copyPhotosDic objectForKey:info] && [bean.getPhotoId isEqualToString:_processPhotoID]){
            [self savePhotoID:bean];
            if(_copyAry.count > 0){
#ifndef _ERROR_CODE_TEST_
                if ([_copyAry containsObject:bean]) {
                    [_copyAry removeObject:bean];
                }
#else 
                [_copyAry removeObjectAtIndex:0];
#endif
                if (_processArray.count > 0) {
                    [_processArray removeLastObject];
                }
                [self actionCopy];
            }
        }
        return;
    }else if (PHOTO_RESULT_BIG_ERROR == result){
        if (([FileSystem checkInit] || ![FileSystem isConnectedKE]) && inited) {
            [bean getPhotoName:^(NSString *name) {
                if (inited) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:[NSString stringWithFormat:@"\"%@\"%@",name,NSLocalizedString(@"importfailoffile", @"")] delegate:self cancelButtonTitle:NSLocalizedString(@"jump", @"") otherButtonTitles:NSLocalizedString(@"again", @""), nil];
                    alert.tag = TAG_ERROR;
                    [alert show];
                }
                
            }];
            
        }//TAG_BROKEN
        else {
            if (![MobClickUtils MobClickIsActive]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"opearateerror", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                alert.tag = TAG_ERROR_BROKEN;
                [alert show];
            }
        }
        
    }else if (PHOTO_RESULT_ERROR == result){
        if (([FileSystem checkInit] || ![FileSystem isConnectedKE]) && inited) {//[NSString stringWithFormat:@"\"%@\"导出失败(文件大于500M)",fileBean.fileName]
            unsigned long long allSize = 0;
            if([_toPath hasPrefix:KE_PHOTO] || [_toPath hasPrefix:KE_VIDEO] || [_toPath hasPrefix:KE_MUSIC] || [_toPath hasPrefix:KE_DOC] || [_toPath hasPrefix:KE_ROOT]){
                
                allSize = [FileSystem get_info].free_size;
            }else{
                NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
                allSize = [[fattributes objectForKey:NSFileSystemFreeSize] unsignedIntegerValue];
            }
            if (_countSize > allSize) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"notplace", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
                alert.tag = TAG_NOFREE;
                [alert show];
            }
            else{
                [bean getImgData:^(NSData *data, NSString *name, NSString *photoId) {
                    
                    if (inited) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:[NSString stringWithFormat:@"\"%@\"%@",name,NSLocalizedString(@"importfail", @"")] delegate:self cancelButtonTitle:NSLocalizedString(@"jump", @"") otherButtonTitles:NSLocalizedString(@"again", @""), nil];
                        alert.tag = TAG_ERROR;
                        [alert show];
                    }
                }];
            }
        }//TAG_BROKEN
        else {
            if (![MobClickUtils MobClickIsActive]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"opearateerror", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                alert.tag = TAG_ERROR_BROKEN;
                [alert show];
            }
           
        }
    }else if (PHOTO_RESULT_CANCE == result){
        
//        if(self.delegate && [self.delegate respondsToSelector:@selector(actionResult:userInfo:)]){
//            
//            [self.delegate actionResult:YES userInfo:_userInfo];
//        }
    }else if (PHOTO_RESULT_NOFREE == result){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"notplace", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        alert.tag = TAG_NOFREE;
        [alert show];
    }
    else if (PHOTO_RESULT_RETRY == result){
        _processPhotoID = nil;
        if (_processArray.count > 0) {
            [_processArray removeLastObject];
        }
        [self actionCopy];
    }
    else if (PHOTO_RESULT_BIGTHAN4G_ERROR == result){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"importfailofbigfile", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"jump", @"") otherButtonTitles:nil, nil];
        alert.tag = TAG_ERROR;
        [alert show];
    }
    _nowSize -= _tempSize;
}

-(void)progress:(float)progress bean:(CustomPhotoBean *)bean userInfo:(id)info{
    
    _tempSize += progress;
    _nowSize += progress;
    float x = _nowSize / (float)_countSize;
    
    int count = [[CustomAlertView instance] getFilesCount] - (int)_copyAry.count;
    [[CustomAlertView instance] setNowNum:count currentSize:_nowSize allSize:_countSize];
    [[CustomAlertView instance] progress:x];
}

-(void)markCopyingFilePath:(NSString *)copyingPath
{
    _nowcopyingPath = copyingPath;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == TAG_ERROR){
        
        if(buttonIndex == 0){
            
//            [_copyAry removeAllObjects];
            if (_copyAry.count>0) {
                [_copyAry removeObjectAtIndex:0];
            }
         }
        _processPhotoID = nil;
        if (_processArray.count > 0) {
            [_processArray removeLastObject];
        }
        [self actionCopy];
    }
    else if(alertView.tag == TAG_ERROR_BROKEN){
        
        if(buttonIndex == 0){
            [_copyAry removeAllObjects];
        }
        if (_processArray.count > 0) {
            [_processArray removeLastObject];
        }
        _processPhotoID = nil;
        [self actionCopy];
    }else if (alertView.tag == TAG_NOFREE){
        
        [_copyAry removeAllObjects];
        _processPhotoID = nil;
        [_processArray removeAllObjects];
        [self actionCopy];
    }
}

@end
