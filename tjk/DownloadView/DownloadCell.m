//
//  DownloadCell.m
//  tjk
//
//  Created by Youqs on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadCell.h"
#import "CustomFileManage.h"
#import "DocumentFileCell.h"
#import "DownloadManager.h"
#import "DownloadListVC.h"

@interface DownloadCell()
{
    BOOL _selected;
    BOOL _isEditing;
    BOOL _isAnimating;
    NSInteger _index;
    UISwipeGestureRecognizer* _swipeRight;
    UISwipeGestureRecognizer* _swipeLeft;
    BOOL isLoadInfo;
    int _btnStatus;
    BOOL _btnClick;
    
    NSTimer *timer;
    NSInteger showSize;
    
    NSInteger currentsize;
    NSInteger theindex;
}

@end

@implementation DownloadCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self swipeCallBack:_swipeRight];
    [super setSelected:NO animated:NO];

    // Configure the view for the selected state
}

-(void)swipeCallBack:(UISwipeGestureRecognizer*)pan{
    if (_isEditing) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateEnded && !_isAnimating) {
        _isAnimating = YES;
        if ([self.itemEditDelegate respondsToSelector:@selector(swipeToControlDeleteBtn:atRow:)]) {
            [self.itemEditDelegate swipeToControlDeleteBtn:(pan.direction == UISwipeGestureRecognizerDirectionLeft) atRow:_index];
        }
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.deleteView.frame = CGRectMake(pan.direction == UISwipeGestureRecognizerDirectionLeft ? SCREEN_WIDTH - 60 : SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
//            self.fileDate.alpha = pan.direction == UISwipeGestureRecognizerDirectionLeft ? 0 : 1;
        } completion:^(BOOL finished) {
            _isAnimating = NO;
        }];
        
    }
}

-(void)setData:(NSMutableDictionary*)model row:(NSInteger)row needLoadIcon:(BOOL)need{
    _index = row;
    _model = model;
    
    if (!model) {
        return;
    }
    
    DownloadInfo* tmpInfo = [model objectForKey:@"item"];
//    _filepath = tmpInfo.fpath;
    
    
    
    [model setObject:self forKey:@"delegate"];
    
    NSString *fpath;
    if (tmpInfo.items && tmpInfo.items.count > 0) {
        fpath = tmpInfo.fpath;
    }
    else{
        fpath = tmpInfo.webURL;
    }
    
    if (!_filepath || ![_filepath isEqualToString:fpath]) {
        
        [_iconImgVIew setImage:[UIImage imageNamed:@"resource_download_video_default" bundle:@"TAIG_ResourceDownload"]];
        [_progressBgImageView setImage:[UIImage imageNamed:@"resource_download_progress_bg" bundle:@"TAIG_ResourceDownload"]];
        [_progressImageView setImage:[UIImage imageNamed:@"resource_download_progress" bundle:@"TAIG_ResourceDownload"]];
        
        _filepath = fpath;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:_filepath object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownloadStatusNotification:) name:_filepath object:nil];
        
        NSInteger current = tmpInfo.current.integerValue;
        NSInteger currentDSize = tmpInfo.currentDSize.integerValue;
        NSInteger count = tmpInfo.items.count;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC*30), dispatch_queue_create(0, 0), ^{
            
            [self changePropress:currentDSize at:current allCount:count];
            _btnStatus = [[DownloadManager shareInstance] getItemDownloadStatus:_filepath];
            [self setBtnStatus:_btnStatus];
        });
    }
    
    _btnStatus = [[DownloadManager shareInstance] getItemDownloadStatus:_filepath];
    [self setBtnStatus:_btnStatus];
    NSString *filename = [self getModelNameWith:[tmpInfo.filepath lastPathComponent]];
    _nameLb.text = filename;
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:_swipeLeft];
    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCallBack:)];
    [self addGestureRecognizer:_swipeRight];
}

-(void)receiveDownloadStatusNotification:(NSNotification *)noti
{
    NSDictionary *dict = noti.object;
    if (_filepath && [(NSString *)[dict objectForKey:@"filepath"] isEqualToString:_filepath]) {
        _btnStatus = ((NSNumber *)[dict objectForKey:@"status"]).intValue;
        [self setBtnStatus:_btnStatus];
    }
}

-(void)setEditStatus:(BOOL)editStatus animation:(BOOL)animation{
    _isEditing = editStatus;
    if(_isEditing){
        [self changeDeleteBtnImg:_isEditing];
    }
    
    [UIView animateWithDuration:(animation?0.3 : 0) delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.selectView.frame = CGRectMake(editStatus ? 0 : - 60, 0, self.selectView.frame.size.width, self.selectView.frame.size.height);
        self.infoCotanierView.frame = CGRectMake(editStatus ? 60 : 0, 0, self.frame.size.width, self.infoCotanierView.frame.size.height);
//        self.deleteView.frame = CGRectMake(editStatus? SCREEN_WIDTH - 60 : SCREEN_WIDTH, 0, self.deleteView.frame.size.width, self.deleteView.frame.size.height);
        self.bottomLine.frame = CGRectMake(editStatus ? 0 : 60, self.bottomLine.frame.origin.y, self.bottomLine.frame.size.width, self.bottomLine.frame.size.height);
    } completion:^(BOOL finished) {
        [self changeDeleteBtnImg:_isEditing];
    }];
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


-(void)removeSwipeGes
{
    [self removeGestureRecognizer:_swipeRight];
    [self removeGestureRecognizer:_swipeLeft];
}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:NO];
}

-(void)setBtnStatus:(int)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *img;
        NSString *statusstr = @"";
        if (status == STATUS_DOWNLOAD_PAUSE || status == STATUS_DOWNLOAD_FAILED ) {
            img = [UIImage imageNamed:@"resource_download_start_light" bundle:@"TAIG_ResourceDownload"];
            [self clearTimer];
            statusstr = status == STATUS_DOWNLOAD_PAUSE? NSLocalizedString(@"pause", @"") : NSLocalizedString(@"downloadfail", @"");
        }
        else if (status == STATUS_DOWNLOADING || status == STATUS_DOWNLOAD_WAIT){
            statusstr = (status == STATUS_DOWNLOADING?NSLocalizedString(@"downloading", @""):NSLocalizedString(@"waiting", @""));
            img = [UIImage imageNamed:@"resource_download_pause_light" bundle:@"TAIG_ResourceDownload"];
        }
        if (img) {
            [_pauseImageView setImage:img];
        }
        _failLabel.hidden = status == STATUS_DOWNLOADING;
        _sizeLb.hidden = status != STATUS_DOWNLOADING;
        _failLabel.text = statusstr;
    });
    
}

-(IBAction)selectedBtnPressed:(id)sender {
    _selected = !_selected;
    [self changeSelectedStatus];
    if ([self.itemEditDelegate respondsToSelector:@selector(itemClickedAt:selected:)]) {
        [self.itemEditDelegate itemClickedAt:_index selected:_selected];
    }
}

- (IBAction)pauseBtnPressed:(id)sender
{
    if (_btnClick) {
        return;
    }
    _btnClick = YES;
    [self performSelector:@selector(btnClickDone) withObject:nil afterDelay:.8];
    _btnStatus = (_btnStatus == STATUS_DOWNLOAD_FAILED || _btnStatus ==STATUS_DOWNLOAD_PAUSE)?STATUS_DOWNLOAD_WAIT : STATUS_DOWNLOAD_PAUSE;
    [self setBtnStatus:_btnStatus];
    if ([self.itemEditDelegate respondsToSelector:@selector(pauseBtnClickWith:status:)]) {
        [self.itemEditDelegate pauseBtnClickWith:_filepath status:_btnStatus];
    }
}

-(void)btnClickDone
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _btnClick = NO;
    });
    
}

- (IBAction)deleteBtnPressed:(id)sender {
    
    if ([self.itemEditDelegate respondsToSelector:@selector(deleteModel:)]) {
        [self.itemEditDelegate deleteModel:_model];
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

-(void)changePropress:(NSInteger)downloadSize at:(NSInteger)index allCount:(NSInteger)count
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        DownloadInfo* tmpInfo = [_model objectForKey:@"item"];
        CGFloat totalsize = 0;
        CGFloat loadedsize = 0;
        for (int i = 0; i < tmpInfo.items.count; i++) {
            DownloadItemInfo *item = (DownloadItemInfo *)[tmpInfo.items objectAtIndex:i];
            totalsize += item.size.floatValue;
            if (index > i) {
                loadedsize += item.size.floatValue;
            }
        }
        
        CGFloat realProgress = [NSString stringWithFormat:@"%.4f",(downloadSize + loadedsize ) / totalsize].floatValue;
        
        NSString *name = [self getModelNameWith:[tmpInfo.filepath lastPathComponent]];
        
        CGFloat alldownloadedsize = (downloadSize + loadedsize);
        if (totalsize != 0 &&((downloadSize + loadedsize) >= totalsize)) {
            alldownloadedsize = totalsize;
        }
        
        CGRect frame = _progressImageView.frame;
        CGFloat progresswidth = _progressBgImageView.frame.size.width * (realProgress>1.0?1.0:realProgress);
        NSString *size = [NSString stringWithFormat:@"%.2f%%(%@/%@)",(realProgress * 100)>=100?99.99:realProgress*100,[self floatToString:alldownloadedsize],totalsize == 0?@"－－":[self floatToString:totalsize]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressImageView.frame = CGRectMake(frame.origin.x, frame.origin.y,progresswidth,frame.size.height);
            _nameLb.text = name;
            _sizeLb.text = size;
        });
    });
    
//    [self setBtnStatus:_btnStatus];
}

-(NSString *)floatToString:(CGFloat)size
{
    NSString *str = @"0M";
    
    if (size <= 0) {
        str = @"0M";
    }
    else if (size < 1000) {
        str = [NSString stringWithFormat:@"%dB",(int)size];
    }
    else if ((size / 1024.0) < 1000){
        str = [NSString stringWithFormat:@"%dK",(int)(size / 1024.0)];
    }
    
    else if ((size / 1024.0 /1024.0) < 1000){
        str = [NSString stringWithFormat:@"%.2fM",size / 1024.0 / 1024.0];
    }
    else if ((size / 1024.0 /1024.0 / 1024.0) < 1000){
        str = [NSString stringWithFormat:@"%.2fG",size / 1024.0 / 1024.0 / 1024.0];
    }
    return str;
}

-(void)changeProgressWithTimer
{
    BOOL isrefresh = [[DownloadListVC sharedInstance] isTopVC];
    
    if (isrefresh) {
        DownloadInfo* tmpInfo = [_model objectForKey:@"item"];
        if (tmpInfo.currentDSize.integerValue != currentsize) {
            currentsize = tmpInfo.currentDSize.integerValue;
            [self changePropress:tmpInfo.currentDSize.integerValue at:tmpInfo.current.integerValue allCount:0];
        }
    }
    
}

-(void)clearTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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


#pragma mark - download progress delegate

-(void)downloadProgress:(NSInteger)downloadSize filepath:(NSString *)filePath atIndex:(NSInteger)index count:(NSInteger)count
{
    if ([self.filepath isEqualToString:filePath]) {
//        _btnStatus = STATUS_DOWNLOADING;
        dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeProgressWithTimer) userInfo:nil repeats:YES];
        }
        
//            [self changePropress:downloadSize at:index allCount:count];
        });
//        [self changePropress:(progress + index)/(count*1.00f)];
    }
}

-(void)downloadSuccessedFile:(NSString *)filePath atIndex:(NSInteger)index finish:(BOOL)finish
{
//    [_tableViewOfDownloading reloadData];
//    [_tableViewOfDownloaded reloadData];
    
    if (finish) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"DownloadSuccess_%@",_nameLb.text] object:_nameLb.text];
        });
        
        _filepath = nil;
        
        [self clearTimer];
        
        if (self.itemEditDelegate && [self.itemEditDelegate respondsToSelector:@selector(downloadCompleted)]) {
            [self.itemEditDelegate downloadCompleted];
        }
    }
    
    
    
    NSLog(@"downloadSuccessedFile");
}

-(void)downloadFailedFile:(NSString *)filePath atIndex:(NSInteger)index
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"downloadFailedFile" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles: nil];
//    [alert show];
    [self clearTimer];
    
    _btnStatus = STATUS_DOWNLOAD_FAILED;
    [self setBtnStatus:_btnStatus];
    
    if (index == -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _failLabel.text = NSLocalizedString(@"downloadfailwithouturl", @"");
        });
    }
    
    if (self.itemEditDelegate && [self.itemEditDelegate respondsToSelector:@selector(downloadFailed)]) {
        [self.itemEditDelegate downloadFailed];
    }
    NSLog(@"downloadFailedFile");
}

-(void)dealloc {
    [self clearTimer];
    _filepath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
