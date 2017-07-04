//
//  DocumentFileCell.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "DocumentFileCell.h"
#import "CustomFileManage.h"
#import "MediaBean.h"
#import "FileViewController.h"
#import "DownloadTask.h"

@interface DocumentFileCell (){
    BOOL _selected;
    BOOL _isEditing;
    BOOL _isAnimating;
    NSInteger _index;
//    FileBean*   _model;
    NSString* _lastImgPath;
    UISwipeGestureRecognizer* _swipeRight;
    UISwipeGestureRecognizer* _swipeLeft;
}

@end

@implementation DocumentFileCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self swipeCallBack:_swipeRight];
    [super setSelected:NO animated:NO];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:NO];
}


-(void)changeNameColor:(NSNotification*)noti
{
    NSString *str = (NSString *)[noti object];
    
    if ([str isEqualToString:@"NOWPLAYING"] && [noti.name isEqualToString:[NSString stringWithFormat:@"%@__%@",NOWMUSICPLAYBEAN,_model.filePath]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileName.textColor = [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:70.0/255.0 alpha:1];
        });
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileName.textColor = [UIColor blackColor];
        });
    }
}

-(void)setData:(FileBean*)model row:(NSInteger)row needLoadIcon:(BOOL)need{
    
    _model = model;
    _index = row;
    
    
    self.identifynew.image = [UIImage imageNamed:@"music_video_new" bundle:@"TAIG_MainImg"];
    
    if (([model.filePath isEqualToString:KE_DOWNLOAD_VIDEO]||[model.filePath isEqualToString:PHONE_VIDEO_DOWNLOAD_VIDEO]) && model.fileType==FILE_DIR) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"newvideodown"]) {
            self.littleIcon.image = [UIImage imageNamed:@"new_1num" bundle:@"TAIG_MainImg"];
        }else{
            self.littleIcon.image = [UIImage imageNamed:@"" bundle:@""];
        }
    }else if (([model.filePath isEqualToString:KE_DOWNLOAD_AUDIO]||[model.filePath isEqualToString:PHONE_AUDIO_DOWNLOAD_AUDIO])&&model.fileType==FILE_DIR){
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"newmusicdown"]) {
            self.littleIcon.image = [UIImage imageNamed:@"new_1num" bundle:@"TAIG_MainImg"];
        }else{
            self.littleIcon.image = [UIImage imageNamed:@"" bundle:@""];
        }
    }else if (([model.filePath isEqualToString:KE_DOWNLOAD_DOCUMENT]||[model.filePath isEqualToString:PHONE_AUDIO_DOWNLOAD_DOCUMENT])&&model.fileType == FILE_DIR){
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"newdocumentdown"]) {
            self.littleIcon.image = [UIImage imageNamed:@"new_1num" bundle:@"TAIG_MainImg"];
        }else{
            self.littleIcon.image = [UIImage imageNamed:@"" bundle:@""];
        }

    }
    else{
        self.littleIcon.image = [UIImage imageNamed:@"" bundle:@""];
    }
    
    if ([[CustomFileManage instance] isKukeDeletedFileCache]) {
        _lastImgPath = nil;
    }
    if (_isInDownloadingList) {
        NSString *ff = [FileSystem getModelNameWith:_model.fileName];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"DownloadSuccess_%@",ff] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSuccessNotification:) name:[NSString stringWithFormat:@"DownloadSuccess_%@",ff] object:nil];
    }
    
    self.fileName.text = [self getModelNameWith:_model.fileName];
    self.fileName.textColor = [UIColor blackColor];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"%@__%@",NOWMUSICPLAYBEAN,_model.filePath] object:nil];
    if (_model.fileType == FILE_MUSIC) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNameColor:) name:[NSString stringWithFormat:@"%@__%@",NOWMUSICPLAYBEAN,_model.filePath] object:nil];
        
        FileBean *fb = [[MusicPlayerViewController instance]getCurrentBean];
        if (fb && [fb.filePath isEqualToString:_model.filePath]) {
            self.fileName.textColor = [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:70.0/255.0 alpha:1];
        }
        else{
            self.fileName.textColor = [UIColor blackColor];
        }
    }
    
    if ([model.fileName isKindOfClass:[NSString class]] && [model.fileName rangeOfString:@"."].location == 0) {
        self.fileImg.alpha = 0.3;
    }
    else {
        self.fileImg.alpha = 1;
    }
    
    if (model.fileType == FILE_MOV || model.fileType == FILE_MUSIC || model.fileType == FILE_VIDEO || model.fileType == FILE_DOC || model.fileType == FILE_NONE || model.fileType == FILE_IMG || model.fileType == FILE_GIF) {
        
        if (_isInDownloadingList) {
            self.fileDesc.text = NSLocalizedString(@"downloadnotcomplete", @"");
        }
        else{
            self.fileDesc.text = [NSString stringWithFormat:@"%@  %@",[self getModelPathExtensionUppercaseWith:_model.filePath],[[NSNumber numberWithFloat:model.fileSize] sizeString]];
        }
    }
    else {
        if (model.fileType == FILE_DIR) {
            NSString *str = @"";
            if (_res_type == Music_Res_Type) {
                str = NSLocalizedString(@"musicdirname", @"");
            }
            else if (_res_type == Picture_Res_Type)
            {
                str = NSLocalizedString(@"photodirname", @"");
            }
            else{
                str = NSLocalizedString(@"folder", @"");
            }
            self.fileDesc.text = str;
        }
        else {
            self.fileDesc.text = [NSString stringWithFormat:@"%@  %@",[self getModelPathExtensionUppercaseWith:_model.filePath],[[NSNumber numberWithFloat:model.fileSize] sizeString]];;
        }
    }
    self.fileDate.hidden = model.fileType == FILE_DIR;
    //(model.fileType != FILE_DIR?YES:(_res_type == Picture_Res_Type?NO:YES));
    if(!self.folderArrow.image){
        self.folderArrow.image = [UIImage imageNamed:@"list_icon_arrow" bundle:@"TAIG_FILE_LIST"];
        self.folderArrow.frame=CGRectMake(self.folderArrow.frame.origin.x,
                               (self.frame.size.height - 15.0*WINDOW_SCALE_SIX)/2.0f,
                               10.0*WINDOW_SCALE_SIX,
                               15.0*WINDOW_SCALE_SIX);
    }
    self.playIcon.image = [self getPlayIconImg:model.fileType];
    if (_model.fileType == FILE_MUSIC) {
        self.playIcon.image = nil;
    }
    self.folderArrow.hidden = model.fileType != FILE_DIR;
    
    BOOL isshowCttime = _isInDownloadingList && (_model.createTime > _model.fileDate);
    
    NSString* dateStr = [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:(isshowCttime? model.createTime: model.fileDate)]];
    if ([dateStr isKindOfClass:[NSString class]] && [dateStr rangeOfString:@" "].location != NSNotFound) {
        self.fileDate.text = [dateStr substringToIndex:[dateStr rangeOfString:@" "].location];
    }
    else{
        self.fileDate.text = dateStr;
    }
    
    if (![_lastImgPath isEqualToString:model.filePath]) {
        self.fileImg.image = [[CustomFileManage instance] getDefaultIconForCache:_model resType:self.res_type];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:model.filePath object:nil];
        
        //GETICON_NOTF
        
        if (!_isInDownloadingList) {
            if (![_lastImgPath isEqualToString:model.filePath]) {
                [[CustomFileManage instance] cancelRequest:_lastImgPath];
            }
            
            _lastImgPath = model.filePath;
            if (model.fileType != FILE_NONE && model.fileType != FILE_DOC && model.fileType != FILE_DIR) {
                
                UIImage* img = [[CustomFileManage instance] getFileIconForCache:_model];
                if (img) {
                    //                if (model.fileType == FILE_MOV || model.fileType == FILE_MUSIC || model.fileType == FILE_VIDEO) {
                    //                    [self getDuration:model];
                    //                }
                    [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
                    if (_model.fileType == FILE_MUSIC) {
                        self.playIcon.image = nil;
                    }
                }
                else {
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconRequestDone:)  name:model.filePath object:nil];
                    [[CustomFileManage instance] requestFileIcon:model];
                    
                }
            }
        }
    }
    else if (!need){
        _lastImgPath = nil;
        [[CustomFileManage instance] cancelRequest:model.filePath];
    }
    else{
        if (!_isInDownloadingList) {
            if (model.fileType != FILE_NONE && model.fileType != FILE_DOC && model.fileType != FILE_DIR) {
                
                UIImage* img = [[CustomFileManage instance] getFileIconForCache:_model];
                if (img) {
                    [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
                    if (_model.fileType == FILE_MUSIC) {
                        self.playIcon.image = nil;
                    }
                }
            }
        }
    }
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:_swipeLeft];
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    [self addGestureRecognizer:_swipeRight];
}

-(void)removeSwipeGes
{
    [self removeGestureRecognizer:_swipeRight];
    [self removeGestureRecognizer:_swipeLeft];
}

-(void)iconRequestDone:(NSNotification*)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_model.filePath object:nil];
    if ([noti.name isEqualToString:_model.filePath]) {
        UIImage* img = [[CustomFileManage instance] getFileIconForCache:_model];
//        if (_model.fileType == FILE_MOV || _model.fileType == FILE_MUSIC || _model.fileType == FILE_VIDEO) {
//            [self getDuration:_model];
//        }
        if(img) {
            [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
            if (_model.fileType == FILE_MUSIC) {
                self.playIcon.image = nil;
            }
        }
    }
}

-(UIImage*)getPlayIconImg:(FILE_TYPE)type{
    if (type == FILE_MOV || type == FILE_VIDEO) {
        return nil;// [UIImage imageNamed:@"list-videoplay" bundle:@"TAIG_FILE_LIST"];
    }
    else if (type == FILE_MUSIC) {
        return [UIImage imageNamed:@"list_image-music" bundle:@"TAIG_FILE_LIST"];
    }
    return nil;
}

-(void)getDuration:(FileBean*)model{
    MediaBean* media = [[CustomFileManage instance] getMediaCache:model];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [[NSNumber numberWithLong:media.time] timeString],@"time",
                          model.filePath,@"path",
                          nil];
    [self performSelectorOnMainThread:@selector(reloadDuration:) withObject:dict waitUntilDone:NO];
}

-(void)reloadDuration:(NSDictionary*)dict {
    if ([[dict objectForKey:@"path"] isEqualToString:_model.filePath]) {
        self.fileDesc.text = [NSString stringWithFormat:@"%@ | %@",[[NSNumber numberWithFloat:_model.fileSize] sizeString],[dict objectForKey:@"time"]];
    }
}

-(void)swipeCallBack:(UISwipeGestureRecognizer*)pan{
    if (_isEditing || !self.maskView.hidden) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateEnded && !_isAnimating) {
        _isAnimating = YES;
        if ([self.itemEditDelegate respondsToSelector:@selector(swipeToControlDeleteBtn:atRow:)]) {
            [self.itemEditDelegate swipeToControlDeleteBtn:(pan.direction == UISwipeGestureRecognizerDirectionLeft) atRow:_index];
        }
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.deleteView.frame = CGRectMake(pan.direction == UISwipeGestureRecognizerDirectionLeft ? SCREEN_WIDTH - 60 : SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
            self.fileDate.alpha = pan.direction == UISwipeGestureRecognizerDirectionLeft ? 0 : 1;
            
        } completion:^(BOOL finished) {
            _isAnimating = NO;
        }];
    }
}

-(void)setNewIdentify:(BOOL)play{
    self.identifynew.hidden = !play;
}

-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation
{
    [self setEditStatus:editStatus animation:animation isExport:NO];
}

-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation isExport:(BOOL)isexport{
    _isEditing = editStatus;
    if(_isEditing){
        [self changeDeleteBtnImg:_isEditing];
    }
    
    BOOL isuseable = YES;
    if (editStatus && isexport && !(_model.fileType == FILE_GIF || _model.fileType == FILE_IMG || _model.fileType == FILE_MOV)) {
        isuseable = NO;
    }
    self.contentView.alpha = isuseable?1.0 : 0.3;
    self.selectView.userInteractionEnabled = isuseable;
    self.cellSelectBtn.userInteractionEnabled = isuseable;
    self.deleteView.hidden = !isuseable;
    
    self.fileDate.alpha = 1;
    
    if (animation) {
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.selectView.frame = CGRectMake(editStatus ? 0 : - 60, 0, self.selectView.frame.size.width, self.selectView.frame.size.height);
            self.content.frame = CGRectMake(editStatus ? 60 : 0, 0, self.frame.size.width - (editStatus && isexport? 60 : 0), self.content.frame.size.height);
//            self.deleteView.frame = CGRectMake((editStatus && !isexport) ? SCREEN_WIDTH - 60 : SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
            self.underLine.frame = CGRectMake(editStatus ? 0 : 60, self.underLine.frame.origin.y, self.underLine.frame.size.width, self.underLine.frame.size.height);
        } completion:^(BOOL finished) {
            [self changeDeleteBtnImg:_isEditing];
        }];
    }
    else {
        [self changeDeleteBtnImg:_isEditing];
        self.selectView.frame = CGRectMake(editStatus ? 0 : - 60, 0, self.selectView.frame.size.width, self.selectView.frame.size.height);
        self.content.frame = CGRectMake(editStatus ? 60 : 0, 0, self.frame.size.width - (editStatus && isexport? 60 : 0), self.content.frame.size.height);
//        self.deleteView.frame = CGRectMake((editStatus && !isexport)? SCREEN_WIDTH - 60 : SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
        self.underLine.frame = CGRectMake(editStatus ? 0 : 60, self.underLine.frame.origin.y, self.underLine.frame.size.width, self.underLine.frame.size.height);
    }
    self.deleteView.frame = CGRectMake(SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
}

-(void)changeDeleteBtnImg:(BOOL)editing {
    NSString* fileName = editing ? @"list_icon-delete-red" : @"list_icon-delete-white";
    if (editing) {
        self.deleteView.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.deleteView.backgroundColor = [UIColor redColor];
    }
    self.cellSelectBtn.hidden = !editing;
    [self.deleteBtn setImage:[UIImage imageNamed:fileName bundle:@"TAIG_FILE_LIST"]  forState:UIControlStateNormal];
}

-(IBAction)selectedBtnPressed:(id)sender {
    _selected = !_selected;
    [self changeSelectedStatus];
    if ([self.itemEditDelegate respondsToSelector:@selector(itemClickedAt:selected:)]) {
        [self.itemEditDelegate itemClickedAt:_index selected:_selected];
    }
}

-(IBAction)deleteBtnPressed:(id)sender {
    if ([self.itemEditDelegate respondsToSelector:@selector(deleteModel:)]) {
        if (_downloadModel) {
            [self.itemEditDelegate deleteModel:_downloadModel];
        }
        else{
            [self.itemEditDelegate deleteModel:_model];
        }
    }
}

-(void)setSelectStatus:(BOOL)selected{
    _selected = selected;
    [self changeSelectedStatus];
}

-(void)changeSelectedStatus{
    if (_selected) {
        self.selectImg.image = [UIImage imageNamed:@"list_btn-selected" bundle:@"TAIG_FILE_LIST"];
    }
    else {
        self.selectImg.image = [UIImage imageNamed:@"list_btn-select" bundle:@"TAIG_FILE_LIST"];
    }
}

-(FileBean*)getDirImgBean:(FileBean*)bean atIndex:(NSInteger)index{
    PathBean* path = [[CustomFileManage instance] getFiles:bean.filePath];
    if(path.imgPathAry.count > 0 && index < path.imgPathAry.count){
        NSInteger imgIndex = -1;
        for (NSInteger i = 0;i <  path.imgPathAry.count ; i ++) {
            FileBean* bean  = [path.imgPathAry objectAtIndex:i];
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

-(NSString *)getModelPathExtensionUppercaseWith:(NSString *)path
{
    NSArray *array = [[path lastPathComponent] componentsSeparatedByString:@"."];
    NSString *pathextension;
    if (array.count > 2) {
        pathextension = [[array lastObject] uppercaseString];
    }
    else{
        pathextension = [[path pathExtension] uppercaseString];
    }
    
    return pathextension;
}

-(NSString *)getModelNameWith:(NSString *)filename
{
    NSArray *array = [filename componentsSeparatedByString:@"."];
    NSString *name;
    if (array.count > 2) {
        name = [array firstObject];
        for (int i = 1; i < array.count -1; i ++) {
            name = [NSString stringWithFormat:@"%@.%@",name,[array objectAtIndex:i]];
        }
    }
    else{
        name = [filename stringByDeletingPathExtension];
    }
    
    return name;
}

#pragma mark - for download

-(void)downloadSuccessNotification:(NSNotification *)noti
{
    NSString *name = noti.object;
    NSString *filename = [FileSystem getModelNameWith:_model.fileName];
    if ([name isEqualToString:filename]) {
        _isInDownloadingList = NO;
        self.fileDesc.text = [NSString stringWithFormat:@"%@  %@",[self getModelPathExtensionUppercaseWith:_model.filePath],[[NSNumber numberWithFloat:_model.fileSize] sizeString]];
        [self setNewIdentify:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"DownloadSuccess_%@",filename] object:nil];
    }
}

-(void)setDownloadData:(NSDictionary *)model row:(NSInteger)row needLoadIcon:(BOOL)need{
    _downloadModel = model;
    _index = row;
    
    
    self.identifynew.image = [UIImage imageNamed:@"music_video_new" bundle:@"TAIG_MainImg"];
    
    NSArray* tmparray= [model objectForKey:@"items"];
    
    NSString *filepath = [model objectForKey:@"filepath"];
    NSString *filename = [filepath lastPathComponent];
    
    self.fileName.frame = CGRectMake(self.fileName.frame.origin.x, self.fileName.frame.origin.y, SCREEN_WIDTH - self.fileName.frame.origin.x - 20, self.fileName.frame.size.height);
    self.fileName.text = [self getModelNameWith:filename];
//    self.fileDesc.text = @"完成";
    
    CGFloat totalsize = 0;
    for (NSDictionary *dict in tmparray) {
        CGFloat size = ((NSString *)[dict objectForKey:@"size"]).floatValue;
        totalsize += size;
    }
    
    if (totalsize == 0) {
        totalsize = [self getFileSizeWith:[[filepath stringByDeletingLastPathComponent] stringByAppendingPathComponent:filename]];
    }
    
    self.fileDesc.text = [NSString stringWithFormat:@"%@  %@",[self getModelPathExtensionUppercaseWith:filepath],totalsize == 0? @"－－M":([[NSNumber numberWithFloat:totalsize] sizeString])];
    
//    if (![_lastImgPath isEqualToString:[model objectForKey:@"filepath"]]) {
    
        [_fileImg setImage:[UIImage imageNamed:@"resource_download_video_default" bundle:@"TAIG_ResourceDownload"]];
//    }
    
    /*
    FilePropertyBean* info = [FileSystem readFileProperty:[model objectForKey:@"filepath"]];
    if (info) {
        
        FileBean* bean = [[FileBean alloc] init];
        [bean setFilePath:[model objectForKey:@"filepath"]];
        [bean setFileType:FILE_VIDEO];
        _model = bean;
        
        if (![_lastImgPath isEqualToString:bean.filePath]) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:bean.filePath object:nil];
            
            //GETICON_NOTF
            if (![_lastImgPath isEqualToString:bean.filePath]) {
                [[CustomFileManage instance] cancelRequest:_lastImgPath];
            }
            _lastImgPath = bean.filePath;
            
            UIImage* img = [[CustomFileManage instance] getFileIconForCache:bean];
            if (img) {
                
                [self.fileImg performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
                if (_model.fileType == FILE_MUSIC) {
                    self.playIcon.image = nil;
                }
            }
            else {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconRequestDone:)  name:bean.filePath object:nil];
                [[CustomFileManage instance] requestFileIcon:bean];
            }
        }
//        else if (!need){
//            _lastImgPath = nil;
//            [[CustomFileManage instance] cancelRequest:bean.filePath];
//        }
    }
     */
    
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:_swipeLeft];
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    [self addGestureRecognizer:_swipeRight];
}

-(float)getFileSizeWith:(NSString *)path{
    if ([path.pathExtension isEqualToString:@"m3u8"] && [FileSystem readFileProperty:[path stringByAppendingPathComponent:@"durations.txt"]]) {
        NSString* sizePath = [path stringByAppendingPathComponent:@"size.txt"];
        NSData* sizedata = [FileSystem  kr_readData:sizePath];
        if(sizedata){
            NSString* filesize = [[NSString alloc] initWithData:sizedata  encoding:NSUTF8StringEncoding];
            return filesize.floatValue;
        }
        else {
            NSString* durationStr = [[NSString alloc] initWithData:[FileSystem  kr_readData:[path stringByAppendingPathComponent:@"durations.txt"]]  encoding:NSUTF8StringEncoding];
            NSMutableArray* durationArray = [NSMutableArray arrayWithArray:[durationStr componentsSeparatedByString:@","]];
            NSInteger allSize = 0;
            for (NSInteger i = 0; i < durationArray.count; i ++) {
                NSString *pathTmp = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%ld.mp4",[[path lastPathComponent] stringByDeletingPathExtension],(i + 1)]];
                FilePropertyBean* info = [FileSystem readFileProperty:pathTmp];
                allSize += info.size;
            }
            NSString* sizeStr = [NSString stringWithFormat:@"%ld",allSize];
            [FileSystem  writeFileToPath:sizePath DataFile:[sizeStr dataUsingEncoding:NSUTF8StringEncoding]];
            return sizeStr.floatValue;
        }
        //
    }
    
    FilePropertyBean *_fileInfo = [FileSystem readFileProperty:path];
    return  _fileInfo.size;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
