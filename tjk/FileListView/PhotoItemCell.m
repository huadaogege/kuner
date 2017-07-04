//
//  PhotoItemCell.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PhotoItemCell.h"
#import "CustomFileManage.h"
#import "PathBean.h"
#import "LogUtils.h"
#import "MusicPlayerViewController.h"

@interface PhotoItemCell (){
    BOOL _selected;
    NSInteger _index;
    NSInteger _editingType;
    NSString* _lastImgPath;
    NSString* _lastDirPath;
    FileBean* _model;
    PathBean* _path;
}

@end

@implementation PhotoItemCell

-(void)setData:(FileBean*)model index:(NSInteger)index needLoadIcon:(BOOL)need{
    _model = model;
    _index = index;
    self.identifyNew.image = [UIImage imageNamed:@"music_video_new" bundle:@"TAIG_MainImg"];
    
    if ([[CustomFileManage instance] isKukeDeletedFileCache]) {
        _lastImgPath = nil;
    }
    if (model.fileType == FILE_MOV || model.fileType == FILE_MUSIC || model.fileType == FILE_VIDEO) {
//        if (!self.iconImg.image) {
            self.iconImg.image = [UIImage imageNamed:(model.fileType == FILE_MUSIC?@"list_musicplay_center" : @"list_image-videoplay") bundle:@"TAIG_FILE_LIST"];
//        }
        self.iconImg.hidden = NO;
        self.folderView.hidden = YES;
    }
    else {
        self.folderView.hidden = YES;
        if (model.fileType == FILE_DIR) {
            self.folderView.hidden = NO;
            self.folderName.text = model.fileName;
        }
        self.iconImg.hidden = YES;
    }
    
    if ([model.fileName rangeOfString:@"."].location == 0) {
        if (model.fileType == FILE_DIR) {
            self.folderView.alpha = 0.3;
        }
        else {
            self.fileImg.alpha = 0.3;
        }
    }
    else {
        if (model.fileType == FILE_DIR) {
            self.folderView.alpha = 1;
        }
        else {
            self.fileImg.alpha = 1;
        }
    }
    if (model.fileType == FILE_DIR) {
        self.identifyNew.hidden = YES;
     }

    NSRange range = [model.filePath rangeOfString:RealDownloadPicturePath];
    if (range.location != NSNotFound) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        dic = [MusicPlayerViewController instance].noplayMusicplistDict;
        BOOL played= NO;
        if (dic.count>0) {
            played = ([dic objectForKey:model.filePath]!= nil);
        }else{
            played = NO;
        }
        self.identifyNew.hidden = !played;
   
    }else{
        self.identifyNew.hidden = YES;
    }
    self.selectView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.25];
    if (!self.selectImg.image) {
        self.selectImg.image = [UIImage imageNamed:@"list_btn-selected" bundle:@"TAIG_FILE_LIST"];
    }
    self.fileImg.hidden = model.fileType == FILE_DIR;
    self.folderImgView.hidden = model.fileType != FILE_DIR;
    self.fileImg.tag = index;
    if (_model.fileType == FILE_MUSIC) {
        self.iconImg.hidden = YES;
    }
    if (![_lastImgPath isEqualToString:model.filePath] || model.fileType == FILE_DIR ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];//GETICON_NOTF
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearLastPath:)  name:[NSString stringWithFormat:@"%@_clear",model.filePath] object:nil];
        if (![_lastImgPath isEqualToString:model.filePath]) {
            [[CustomFileManage instance] cancelRequest:_lastImgPath];
        }
        _lastImgPath = model.filePath;
        self.fileImg.image = [self getDefaultImg:model];
        
        if (model.fileType != FILE_NONE && model.fileType != FILE_DOC) {
            if (model.fileType == FILE_DIR) {
                
                if ([_model.filePath isEqualToString:RealDownloadPicturePath]) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadnoti:) name:DOWNCOMPELETE_NOTI object:nil];
                }
                [self getDirFourImage:model];
            }
            else {
                
                UIImage* img = [[CustomFileManage instance] getFileIconForCache:model];
                if (img) {
                    [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
                    
                    if (_model.fileType == FILE_MUSIC) {
                        self.iconImg.hidden = NO;
                        self.iconImg.tag = 11;
                    }
                }
                else {
                    if (_model.fileType == FILE_MUSIC) {
                        self.iconImg.hidden = YES;
                    }
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconRequestDone:)  name:model.filePath object:nil];
                    [[CustomFileManage instance] requestFileIcon:model];
//                    [self performSelector:@selector(delayToRequestFileIcon:) withObject:model afterDelay:0.05];
                }
            }
            
        }
    }
    else if (!need){
        _lastImgPath = nil;
        [[CustomFileManage instance] cancelRequest:model.filePath];
    }
    else if(self.fileImg.image){
        if (_model.fileType == FILE_MUSIC) {
            self.iconImg.hidden = (self.iconImg.tag != 11);
        }
    }
}

-(void)getDirFourImage:(FileBean *)model
{
    if (!self.folderImgBg.image) {
        self.folderImgBg.image = [UIImage imageNamed:@"list_album-bg" bundle:@"TAIG_FILE_LIST"];
    }
    self.folderImg.image = nil;
    self.folderImg2.image = nil;
    self.folderImg3.image = nil;
    self.folderImg4.image = nil;
    NSInteger imgNone = 0;
    _path = [[CustomFileManage instance] getFiles:model.filePath getEX:PICTURE_GIF_EX_DIC count:4];
    for (NSInteger i = 0; i < 4; i ++) {
//        FileBean*imgBean = [self getDirImgBean:model atIndex:i];
        FileBean *imgBean = [self getDirDetailImgBeanAtIndex:i];
        if (imgBean) {
            BOOL isinDownloadlist = [self checkDocmentCellIsInDownloadingList:imgBean];
            if (isinDownloadlist) {
                imgNone ++;
                continue;
            }
            UIImage* img = [[CustomFileManage instance] getFileIconForCache:imgBean];
            if (img) {
                UIImageView* folderImg = [self getFolderImageView:i];
                [folderImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
            }
            else {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconRequestDone:)  name:imgBean.filePath object:nil];
                //                            [self performSelector:@selector(delayToRequestFileIcon:) withObject:imgBean afterDelay:0.05];
                [[CustomFileManage instance] requestFileIcon:imgBean];
            }
            
        }
        else {
            imgNone ++;
        }
    }
    if (imgNone == 4) {
        self.fileImg.hidden = NO;
        self.folderImgView.hidden = YES;
    }
    
    if (imgNone == 0 && [_model.filePath isEqualToString:RealDownloadPicturePath]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNCOMPELETE_NOTI object:nil];
    }
    
//    if (imgNone > 0 && [_model.filePath isEqualToString:RealDownloadPicturePath]) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadnoti:) name:DOWNCOMPELETE_NOTI object:nil];
//    }
}

-(BOOL)checkDocmentCellIsInDownloadingList:(FileBean *)bean
{
    BOOL isIn = NO;
    
    
    NSMutableArray *downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
    
    for (NSDictionary *tmp in downloadingArray) {
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.filepath isEqualToString:bean.filePath]) {
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

-(void)downloadnoti:(NSNotification *)noti
{
    int type = [[noti object] intValue];
    if (type == 2 && [_model.filePath isEqualToString:RealDownloadPicturePath]){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newpicturedown"];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:DOWNCOMPELETE_NOTI object:nil];
        _lastImgPath = nil;
        [[CustomFileManage instance] cleanPathCache:_model.filePath];
        [self setData:_model index:_index needLoadIcon:YES];
//        [self getDirFourImage:_model];
    }
}

-(void)delayToRequestFileIcon:(FileBean *)bean
{
    [[CustomFileManage instance] requestFileIcon:bean];
}

-(UIImageView*)getFolderImageView:(NSInteger)index{
    if (index == 0) {
        return self.folderImg;
    }
    else if (index == 1) {
        return self.folderImg2;
    }
    else if (index == 2) {
        return self.folderImg3;
    }
    else if (index == 3) {
        return self.folderImg4;
    }
    return nil;
}

-(void)clearLastPath:(NSNotification*)noti
{
    if ([[NSString stringWithFormat:@"%@_clear",_model.filePath] isEqualToString:noti.name]) {
        _lastImgPath = nil;
    }
}

-(void)iconRequestDone:(NSNotification*)noti{
    if (_model.fileType == FILE_DIR) {
        for (NSInteger i = 0; i < 4; i ++) {
            FileBean* imgBean = [self getDirImgBean:_model atIndex:i];
            
            if ([noti.name isEqualToString:imgBean.filePath]) {
                UIImage* img = [[CustomFileManage instance] getFileIconForCache:imgBean];
                if(img){
                    UIImageView* folderImg = [self getFolderImageView:i];
                    [folderImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
                }
                break;
            }
        }
        
    }
    else {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_model.filePath object:nil];
        if ([noti.name isEqualToString:_model.filePath]) {
            UIImage* img = [[CustomFileManage instance] getFileIconForCache:_model];
            
            if (img) {
                [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
                if (_model.fileType == FILE_MUSIC) {
                    self.iconImg.hidden = NO;
                    self.iconImg.tag = 11;
                }
                
            }
            else{
                if (_model.fileType == FILE_MUSIC) {
                    self.iconImg.hidden = YES;
                }
            }
            
        }
        
    }
}

-(FileBean*)getDirImgBean:(FileBean*)bean atIndex:(NSInteger)index{
//    if (![_lastDirPath isEqualToString:bean.filePath] || _path.imgPathAry.count == 0) {
//        _lastDirPath = bean.filePath;
        _path = [[CustomFileManage instance] getFiles:bean.filePath getEX:PICTURE_GIF_EX_DIC count:4];
//    }
    if(_path.imgPathAry.count > 0 && index < _path.imgPathAry.count){
        NSInteger imgIndex = -1;
        for (NSInteger i = 0;i <  _path.imgPathAry.count ; i ++) {
            FileBean* bean  = [_path.imgPathAry objectAtIndex:i];
            if (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF) {
                imgIndex ++;
                if (imgIndex == index) {
                    return bean;
                }
            }
        }
    }
    return nil;
}

-(FileBean*)getDirDetailImgBeanAtIndex:(NSInteger)index{
    if(_path.imgPathAry.count > 0 && index < _path.imgPathAry.count){
        NSInteger imgIndex = -1;
        for (NSInteger i = 0;i <  _path.imgPathAry.count ; i ++) {
            FileBean* bean  = [_path.imgPathAry objectAtIndex:i];
            if (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF) {
                imgIndex ++;
                if (imgIndex == index) {
                    return bean;
                }
            }
        }
    }
    return nil;
}

-(UIImage*)getDefaultImg:(FileBean*)bean{
    if (bean.fileType == FILE_MOV || bean.fileType == FILE_GIF || bean.fileType == FILE_IMG) {
        return [UIImage imageNamed:@"list_image-pic-default" bundle:@"TAIG_FILE_LIST"];
    }
    else if (bean.fileType == FILE_VIDEO) {
        return [UIImage imageNamed:@"list_image-video-default" bundle:@"TAIG_FILE_LIST"];
    }
    else if (bean.fileType == FILE_MUSIC) {
        return [UIImage imageNamed:@"list_image-music-default" bundle:@"TAIG_FILE_LIST"];
    }
    else if (bean.fileType == FILE_DOC) {
        NSString * kind = [[bean.filePath pathExtension] lowercaseString];
        if([kind isEqualToString:DOCUMENT_TXT]){
            return [UIImage imageNamed:@"list_icon-txt" bundle:@"TAIG_FILE_LIST"];
        }else if ([kind isEqualToString:DOCUMENT_PDF]){
            return [UIImage imageNamed:@"list_icon-pdf" bundle:@"TAIG_FILE_LIST"];
        }
        else if ([kind isEqualToString:DOCUMENT_HTML]){
            return [UIImage imageNamed:@"list_icon-html" bundle:@"TAIG_FILE_LIST"];
        }
        else if ([kind isEqualToString:DOCUMENT_RTF]){
            return [UIImage imageNamed:@"list_icon-rtf" bundle:@"TAIG_FILE_LIST"];
        }
        else if ([kind isEqualToString:DOCUMENT_DOC] || [kind isEqualToString:DOCUMENT_DOCX]){
            return [UIImage imageNamed:@"list_icon-doc" bundle:@"TAIG_FILE_LIST"];
        }
        else if ([kind isEqualToString:DOCUMENT_PPT]){
            return [UIImage imageNamed:@"list_icon-ppt" bundle:@"TAIG_FILE_LIST"];
        }
        else if ([kind isEqualToString:DOCUMENT_XLS]){
            return [UIImage imageNamed:@"list_icon-xls" bundle:@"TAIG_FILE_LIST"];
        }
        return [UIImage imageNamed:@"list_icon-txt" bundle:@"TAIG_FILE_LIST"];
    }
    else if (bean.fileType == FILE_DIR) {
        return [UIImage imageNamed:@"list_image-album-default" bundle:@"TAIG_FILE_LIST"];
    }
    else if (bean.fileType == FILE_NONE) {
        return [UIImage imageNamed:@"list_image-otherdefault" bundle:@"TAIG_FILE_LIST"];
    }
    return nil;
}

-(IBAction)selectedBtnPressed:(id)sender {
    if (_editingType != Edit_None) {
        _selected = !_selected;
        [self changeSelectedStatus];
    }
    if ([self.itemSelectDelegate respondsToSelector:@selector(itemClickedAt:model:selected:)]) {
        [self.itemSelectDelegate itemClickedAt:_index model:_model selected:_selected];
    }
}

-(void)setSelected:(BOOL)selected{
    _selected = selected;
    [self changeSelectedStatus];
}

-(void)changeSelectedStatus{
//    if (_selected) {
//        self.selectImg.image = [UIImage imageNamed:@"list_photo-selected" bundle:@"TAIG_FILE_LIST"];
//    }
//    else {
//        self.selectImg.image = [UIImage imageNamed:@"list_photo-select" bundle:@"TAIG_FILE_LIST"];
//    }
    self.selectView.hidden = !_selected;
}

-(void)setEditStatus:(NSInteger)editStatusType isExport:(BOOL)isexport{
    _editingType = editStatusType;
//    self.selectBtn.hidden = !editStatus;
//    self.selectImg.hidden = _editingType == Edit_None;
    BOOL isuseable = YES;
    if (isexport && (editStatusType == Edit_None)) {
        isuseable = NO;
    }
    
    self.alpha = isuseable?1.0 : 0.3;
    self.selectView.userInteractionEnabled = isuseable;
    self.selectBtn.userInteractionEnabled = isuseable;
    
    self.selectView.hidden = _editingType == Edit_None || !_selected;
}

-(void)stopCacheIconRequest{
    if ([_lastImgPath isEqualToString:_model.filePath]) {
        if ([[CustomFileManage instance] cancelRequest:_model.filePath]) {
            _lastImgPath = nil;
        }
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
