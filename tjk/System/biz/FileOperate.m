//
//  FileOperate.m
//  KUKE
//
//  Created by ��煎����煎����� on 15/3/25.
//  Copyright (c) 2015骞� ��煎����煎�����. All rights reserved.
//

#import "FileOperate.h"
#import "FileBean.h"
#import "CustomAlertView.h"
#import "MobClickUtils.h"
#import "MusicPlayerViewController.h"
#import "LogUtils.h"

#define TAG_NOFREE 1111
#define TAG_COPY 2222
#define TAG_DEL 3333
#define TAG_COPYTOSELF 4444
#define TAG_BROKEN_COPY 5555
#define TAG_BROKEN_DEL 6666

@interface FileOperate (){
    NSString* _processPhotoID;
    BOOL isDeleteCancel;
}
@property (assign, atomic) int photoCount;
@end

@implementation FileOperate


-(id)init{
    self = [super init];
    if(self){
        
        _actionPhotosDic = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
    }
    return self;
}

-(void)dealloc{
    [_actionAry removeAllObjects];
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fileOperateCancel:(NSNotification *)noti
{
    if ([noti.name isEqualToString:FILE_OPERATION_CANCEL] && (((NSNumber *)noti.object).integerValue == Alert_Copy || ((NSNumber *)noti.object).integerValue == Alert_Delete)) {
        
        [_actionAry removeAllObjects];
        [_actionPhotosDic removeAllObjects];
        
        if (((NSNumber *)noti.object).integerValue == Alert_Delete) {
            isDeleteCancel = YES;
        }
        else{
            isDeleteCancel = NO;
            
            [self actionArrayCountEqualZeroActionIsNeedGotoHund:NO];
        }
        
    }
}

-(void)copyFiles:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info{
    BOOL hasParent = NO;
    for (FileBean *bean in beans) {
        if (bean.fileType == FILE_DIR && ([toPath hasPrefix:[NSString stringWithFormat:@"%@/",bean.filePath]] || [toPath isEqualToString:bean.filePath])) {
            hasParent = YES;
            break;
        }
    }
    if (hasParent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"existdirwhencopydir", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        alert.tag = TAG_COPYTOSELF;
        [alert show];
        return;
    }
    [self copyFiles:beans toPath:toPath userInfo:info alertMsg:nil];
}

-(void)copyFiles:(NSArray *)beans toPath:(NSString *)toPath userInfo:(id)info alertMsg:(NSString*)title{
    
    [CustomAlertView instance].alertType = Alert_Copy;
    NSDictionary *dict = (NSDictionary *)info;
    NSString *notshowcancel = [dict objectForKey:@"notshowcancel"];
    if (notshowcancel && [notshowcancel isEqualToString:@"1"]) {
        [CustomAlertView instance].notshowcancelBtn = YES;
    }
    else{
        [CustomAlertView instance].notshowcancelBtn = NO;
    }
    _successCount = 0;
    _actionAry = [[NSMutableArray alloc] initWithArray:beans];
    [_actionPhotosDic removeAllObjects];
    _toPath = toPath;
    self.photoCount = 0;
    _nowSize = 0;
    _countSize = 0;
    _userInfo = info;
    _processPhotoID = nil;
    if(_actionAry.count > 0){
        
        [self getSize:title];
    }
}

-(void)deleteFiles:(NSArray *)beans userInfo:(id)info{
    
    [self deleteFiles:beans userInfo:info alertMsg:nil];
}

-(void)deleteFiles:(NSArray *)beans userInfo:(id)info  alertMsg:(NSString*)title{
    if (![FileSystem checkInit] && [FileSystem isConnectedKE]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"deletefailforunlinkke", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles: nil];
        [alert show];
        return;
    }
    _successCount = 0;
    _actionAry = [[NSMutableArray alloc] initWithArray:beans];
    [_actionPhotosDic removeAllObjects];
    self.photoCount = 0;
    _userInfo = info;
    [[CustomAlertView instance] setFilesCount:(int)_actionAry.count];
    if (title) {
        [[CustomAlertView instance] setMsg:title];
    }
    else {
        [[CustomAlertView instance] setMsg:NSLocalizedString(@"sysDelete", @"")];
    }
    [CustomAlertView instance].alertType = Alert_Delete;
    [[CustomAlertView instance] showProgress];
    [self actionDelete:YES];
}

-(void)getSize:(NSString*)title{
    
    if (!_actionAry || _actionAry.count ==0 || (![FileSystem checkInit] && [CustomFileManage getFilePosition:_toPath] == POSITION_HARDDISK)) {
        return;
    }
    
    [[CustomAlertView instance] setMsg:NSLocalizedString(@"readying", @"")];
    [NSThread detachNewThreadSelector:@selector(doGetSize:) toTarget:self withObject:title];
}

-(void)doGetSize:(NSString*)title{
    for (FileBean *bean in _actionAry) {
        if(bean.fileType == FILE_DIR && ([_toPath hasPrefix:[NSString stringWithFormat:@"%@/",bean.filePath]] || [_toPath isEqualToString:bean.filePath])){
            [self performSelectorOnMainThread:@selector(pathErrorShow) withObject:nil waitUntilDone:NO];
        }else{
            [_actionPhotosDic setObject:@"1" forKey:bean.filePath];
            self.photoCount++;
            if (bean.fileType == FILE_DIR || bean.originTypeIsDir) {
                _countSize += [self getDirSize:bean];
            }
            else {
                _countSize += bean.fileSize;
            }
            if(self.photoCount == _actionAry.count){
                unsigned long long allSize = 0;
                if([_toPath hasPrefix:KE_PHOTO] || [_toPath hasPrefix:KE_VIDEO] || [_toPath hasPrefix:KE_MUSIC] || [_toPath hasPrefix:KE_DOC] || [_toPath hasPrefix:KE_ROOT]){
                    if (![FileSystem checkInit]) {
                        [[CustomAlertView instance] performSelectorOnMainThread:@selector(hidden) withObject:nil waitUntilDone:NO];
                        return;
                    }
                    allSize = [FileSystem get_info].free_size;
                }else{
                    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
                    allSize = [[fattributes objectForKey:NSFileSystemFreeSize] unsignedIntegerValue];
                }
                if(_countSize > allSize){
                    [self performSelectorOnMainThread:@selector(spaceErrorShow) withObject:nil waitUntilDone:NO];
                    return;
                }
                [self performSelectorOnMainThread:@selector(progressShow:) withObject:title waitUntilDone:NO];
            }
        }
    }
}

-(void)progressShow:(NSString*)title{
    [[CustomAlertView instance] showProgress];
    [[CustomAlertView instance] setFilesCount:(int)_actionAry.count];
    if (title) {
        [[CustomAlertView instance] setMsg:title];
    }
    else {
        [[CustomAlertView instance] setMsg:NSLocalizedString(@"sysCopy", @"")];
    }
    [self actionCopy:YES];
}

-(void)spaceErrorShow {
    [[CustomAlertView instance] hidden];
    [_actionAry removeAllObjects];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"notplace", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
    alert.tag = TAG_COPYTOSELF;
    [alert show];
}

-(void)pathErrorShow{
    [[CustomAlertView instance] hidden];
    [_actionAry removeAllObjects];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"existdirwhencopydir", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
    alert.tag = TAG_COPYTOSELF;
    [alert show];
}

-(float)getDirSize:(FileBean*)bean{
    float size = 0;
    PathBean* pathBean = [[CustomFileManage instance] getFiles:bean.filePath];
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObjectsFromArray:pathBean.dirPathAry];
    [arr addObjectsFromArray:pathBean.imgPathAry];
    [arr addObjectsFromArray:pathBean.videoPathAry];
    [arr addObjectsFromArray:pathBean.musicPathAry];
    [arr addObjectsFromArray:pathBean.docPathAry];
    [arr addObjectsFromArray:pathBean.nonePathAry];
    for (FileBean *bean in arr) {
        if (bean.fileType == FILE_DIR || bean.originTypeIsDir) {
            size += [self getDirSize:bean];
        }
        else {
            size += bean.fileSize;
        }
    }
    return size;
}

-(void)actionCopy:(BOOL)isSuccess{
    
    if(_actionAry.count > 0){
        FileBean *bean = [_actionAry firstObject];
        if (![FileSystem checkInit] && [FileSystem isConnectedKE]) {
            [self actionResult:FILE_ACTION_COPY result:RESULT_ERROR info:bean.filePath fileBean:bean];
            return;
        }
        int count = [[CustomAlertView instance] getFilesCount] - (int)_actionAry.count;
        [[CustomAlertView instance] setNowNum:count currentSize:_nowSize allSize:_countSize];
#ifndef _ERROR_CODE_TEST_
        if (![_processPhotoID isEqualToString:[bean getFilePath]]) {
#endif
            _processPhotoID = [bean getFilePath];
            _tempSize = 0;
            [[CustomFileManage instance] copyFile:bean toPath:_toPath delegate:self info:bean.filePath];
#ifndef _ERROR_CODE_TEST_
            }
#endif
        
    }else{
        [[CustomAlertView instance] setNowNum:[[CustomAlertView instance] getFilesCount] currentSize:_countSize allSize:_countSize];
        [[CustomAlertView instance] progress:1.0];
        [[CustomAlertView instance] hidden];
        if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
            [self.delegate fileActionResult:(_successCount > 0) userInfo:_userInfo];
        }
    }
}

-(void)actionDelete:(BOOL)isCance{
    
    if(_actionAry.count > 0){
        int count = [[CustomAlertView instance] getFilesCount] - (int)_actionAry.count;
        
        FileBean *bean = [_actionAry firstObject];
        [[CustomAlertView instance] setNowNum:count fileName:bean.fileName];
        [[CustomAlertView instance] progress:((float)([[CustomAlertView instance] getFilesCount] - _actionAry.count) / (float)[[CustomAlertView instance] getFilesCount])];
        NSString *msg = [NSString stringWithFormat:@"%@",NSLocalizedString(@"deleteing", @"")];
        if (bean.fileType == FILE_DIR) {
            msg = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"deleteingOn", @""),NSLocalizedString(@"folder", @"")];
            [self removeDirNewIdentify:bean];
        }
        [[CustomAlertView instance] setMsg:msg];
        if (![FileSystem checkInit] && [FileSystem isConnectedKE]) {
            [self actionResult:FILE_ACTION_DELETE result:RESULT_ERROR info:bean.filePath fileBean:bean];
            return;
        }
        [_actionPhotosDic setObject:@"1" forKey:bean.filePath];
        [[CustomFileManage instance] deleteFile:bean delegate:self info:bean.filePath];
        [[MusicPlayerViewController instance] removeNewIdentify:bean.filePath];
        
    }else{
        [self actionArrayCountEqualZeroActionIsNeedGotoHund:YES];
    }
}
-(void)removeDirNewIdentify:(FileBean*)bean{

    NSArray * pathArray = [[NSArray alloc]init];
    pathArray = [[MusicPlayerViewController instance].noplayMusicplistDict allKeys];
    for (NSString * filePath in pathArray) {
        if ([bean.filePath isEqualToString:RealDownloadAudioPath]) {
            if ([[filePath pathExtension] isEqualToString:@"mp3"]||[[filePath pathExtension] isEqualToString:@"m4a"]) {
                [[MusicPlayerViewController instance]removeNewIdentify:filePath];
            }

        }else if([bean.filePath isEqualToString:RealDownloadVideoPath]){
            if ([[filePath pathExtension] isEqualToString:@"mp4"]||[[filePath pathExtension] isEqualToString:@"m3u8"]) {
                [[MusicPlayerViewController instance]removeNewIdentify:filePath];
            }

        }else if ([bean.filePath isEqualToString:RealDownloadPicturePath]){
            if ([[filePath pathExtension] isEqualToString:@"jpg"]||[[filePath pathExtension] isEqualToString:@"png"]||[[filePath pathExtension] isEqualToString:@"bmp"]||[[filePath pathExtension] isEqualToString:@"jpe"]||[[filePath pathExtension] isEqualToString:@"jpeg"]) {
                [[MusicPlayerViewController instance]removeNewIdentify:filePath];
            }
        }else if ([bean.filePath isEqualToString:RealDownloadDocumentPath]){
            NSDictionary * extenseDic = [NSDictionary dictionaryWithObjectsAndKeys:@"mp3",@"1",@"m4a",@"1",@"mp4",@"1",@"m3u8",@"1",@"jpg",@"1",@"png",@"1",@"bmp",@"1",@"jpeg",@"1",@"jpe",@"1", nil];
            if (![extenseDic objectForKey:[filePath pathExtension]]) {
                [[MusicPlayerViewController instance]removeNewIdentify:filePath];
            }
            
         }
    }

}
-(void)actionArrayCountEqualZeroActionIsNeedGotoHund:(BOOL)isGoHund
{
    [[CustomAlertView instance] setNowNum:[[CustomAlertView instance] getFilesCount]];
    if (isGoHund) {
        [[CustomAlertView instance] progress:1.0];
    }
    [[CustomAlertView instance] hidden];
    if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
        NSString *notshowcancel = [_userInfo objectForKey:@"notshowcancel"];
        if (notshowcancel && [notshowcancel isEqualToString:@"1"]) {
            [[CustomAlertView instance] setNowNum:[[CustomAlertView instance] getFilesCount] currentSize:_countSize allSize:_countSize];
            [[CustomAlertView instance] progress:1.0];
            [[CustomAlertView instance] hidden];
            [self.delegate fileActionResult:(_successCount == [[CustomAlertView instance] getFilesCount]) userInfo:_userInfo];
        }
        else {
            [self.delegate fileActionResult:(_successCount > 0) userInfo:_userInfo];
        }
        
    }
}

-(void)actionResult:(ACTIONCODE)action result:(RESULTCODE)result info:(id)info fileBean:(FileBean *)bean{
    
    if([_actionPhotosDic objectForKey:bean.filePath] || isDeleteCancel){
        if(RESULT_FINISH == result){
            
            if([_actionPhotosDic objectForKey:info]){
                if(_actionAry.count > 0){
#ifndef _ERROR_CODE_TEST_
                    if ([_actionAry containsObject:bean]) {
                        [_actionAry removeObject:bean];
                    }
#else
                    [_actionAry removeObjectAtIndex:0];
#endif
                }
                _successCount++;
                if(FILE_ACTION_COPY == action){
                    [self actionCopy:YES];
                }else{
                    [self actionDelete:YES];
                    
                }
            }
            else{
                if(FILE_ACTION_DELETE == action){
                    _successCount++;
                    if (isDeleteCancel) {
                        [self actionDelete:YES];
                        isDeleteCancel = NO;
                    }
                }
            }
            return;
        }else if (RESULT_ERROR == result){
            if ([FileSystem checkInit] || (![FileSystem isConnectedKE] && ![FileSystem isMoveFileIngValue])) {
                if(FILE_ACTION_COPY == action){
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
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:[NSString stringWithFormat:@"\"%@\"%@",bean.fileName,NSLocalizedString(@"sysCopyError", @"")] delegate:self cancelButtonTitle:NSLocalizedString(@"jump", @"") otherButtonTitles:NSLocalizedString(@"again", @""), nil];
                        alert.tag = TAG_COPY;
                        [alert show];
                    }
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:[NSString stringWithFormat:@"\"%@\"%@",bean.fileName,NSLocalizedString(@"sysDeleteError", @"")] delegate:self cancelButtonTitle:NSLocalizedString(@"jump", @"") otherButtonTitles:NSLocalizedString(@"again", @""), nil];
                    alert.tag = TAG_DEL;
                    [alert show];
                }
            }//TAG_BROKEN
            else {
                
                if ([FileSystem isMoveFileIngValue]) {
                    [FileSystem setMoveFileIngValue:@"0"];
                }
                if (![MobClickUtils MobClickIsActive] || action == FILE_ACTION_DELETE) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:([FileSystem isConnectedKE] ? NSLocalizedString(@"keunlink", @"") : NSLocalizedString(@"opearateerror", @"")) delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
                    alert.tag = FILE_ACTION_COPY == action ? TAG_BROKEN_COPY : TAG_BROKEN_DEL;
                    [alert show];
                }
                if (action == FILE_ACTION_DELETE) {
                    [self brokenDone:NO];
                }
                
            }
            
        }else if (RESULT_CANCE == result){
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
                
                [self.delegate fileActionResult:YES userInfo:_userInfo];
            }
        }else if (RESULT_NOFREE == result){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"notplace", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
            alert.tag = TAG_NOFREE;
            [alert show];
        }else if (RESULT_DONTCOPYTOSELF == result){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"existdirwhencopydir", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"goontodo", @"") otherButtonTitles:nil];
            alert.tag = TAG_COPYTOSELF;
            [alert show];
        }
        _nowSize -= _tempSize;
    }
}

-(void)progress:(float)progress info:(id)info fileBean:(FileBean *)bean{
    BOOL hasIn = NO;
    if([_actionPhotosDic objectForKey:bean.filePath]){
        hasIn = YES;
    }
    else {
        for (NSString * path in [_actionPhotosDic keyEnumerator]) {
            if ([bean.filePath hasPrefix:path]) {
                hasIn = YES;
                break;
            }
        }
    }
    if (hasIn) {
        if(_tempSize < 0){
            _tempSize = 0;
        }
        if(_nowSize < 0){
            _nowSize = 0;
        }
        _tempSize += progress;
        _nowSize += progress;
        float x = _nowSize / _countSize;
        int count = [[CustomAlertView instance] getFilesCount] - (int)_actionAry.count;
        [[CustomAlertView instance] setNowNum:count currentSize:_nowSize allSize:_countSize];
        [[CustomAlertView instance] progress:x];
    }
}

-(void)brokenDone:(BOOL)isCopy{
    if (isCopy){
        
        [_actionAry removeAllObjects];
        if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
            
            NSString *notshowcancel = [_userInfo objectForKey:@"notshowcancel"];
            if (notshowcancel && [notshowcancel isEqualToString:@"1"]) {
                [[CustomAlertView instance] setNowNum:[[CustomAlertView instance] getFilesCount] currentSize:_countSize allSize:_countSize];
                [[CustomAlertView instance] progress:1.0];
                [[CustomAlertView instance] hidden];
                [self.delegate fileActionResult:NO userInfo:_userInfo];
            }
            else {
                [self actionCopy:NO];
            }
        }
    }
    else{
        
        [_actionAry removeAllObjects];
        [self actionDelete:NO];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == TAG_COPY){
        
        if(buttonIndex == 0){
            
//            [_actionAry removeAllObjects];
            if (_actionAry.count > 0) {
                [_actionAry removeObjectAtIndex:0];
            }
        }
        _processPhotoID = nil;
        [self actionCopy:NO];
    }else if(alertView.tag == TAG_DEL){
        
        if(buttonIndex == 0){
//            [_actionAry removeAllObjects];
            if (_actionAry.count > 0) {
                [_actionAry removeObjectAtIndex:0];
            }
        }
        [self actionDelete:NO];
    }
    else if (alertView.tag == TAG_BROKEN_COPY){
        
        [_actionAry removeAllObjects];
        if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
            NSString *notshowcancel = [_userInfo objectForKey:@"notshowcancel"];
            if (notshowcancel && [notshowcancel isEqualToString:@"1"]) {
                [self.delegate fileActionResult:NO userInfo:_userInfo];
            }
            else {
                [self actionCopy:NO];
            }
        }
    }
    else if (alertView.tag == TAG_BROKEN_DEL){
        
        [_actionAry removeAllObjects];
        [self actionDelete:NO];
    }
    else if (alertView.tag == TAG_NOFREE){
        
        [_actionAry removeAllObjects];
        [self actionDelete:NO];
    }else if(alertView.tag == TAG_COPYTOSELF){
        
        //        if(_actionAry.count > 0)
        //            [_actionAry removeObjectAtIndex:0];
        //        [self actionCopy:YES];
        if(self.delegate && [self.delegate respondsToSelector:@selector(fileActionResult:userInfo:)]){
            
            [self.delegate fileActionResult:NO userInfo:_userInfo];
        }
    }
}

@end