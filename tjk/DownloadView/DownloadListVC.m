//
//  DownloadListVC.m
//  tjk
//
//  Created by Youqs on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadListVC.h"
#import "CustomNavigationBar.h"
#import "BottomEditView.h"
#import "FileBean.h"
#import "DocumentFileCell.h"
#import "DownloadCell.h"
#import "CopyMainViewController.h"
#import "FileOperate.h"
#import "VideoViewController.h"
#import "CustomNotificationView.h"
#import "MusicPlayerViewController.h"
#import "KxMovieViewController.h"
#import "DownloadManager.h"
#import "ListVideoViewController.h"
#import "TopView.h"
#import "MusicPlayerViewController.h"
#import "MobClickUtils.h"
#import "AnOtherWebViewController.h"
#import "PreviewViewController.h"

#define DOWNLOAD_MENU_SELECTALL_TAG 10001
#define DOWNLOAD_MENU_DELETE_TAG 10002
#define DOWNLOAD_MENU_ALLPAUSE_TAG 10003

#define ALERT_MODEL_DELETE_TAG 1110
#define ALERT_FILES_DELETE_TAG 111

#define Downloaded_MENU_NEW_FOLDER_TAG 11001
#define Downloaded_MENU_SELECT_ALL_TAG 11002
#define Downloaded_MENU_COPY_TAG 11003
#define Downloaded_MENU_DELETE_TAG 11004

#define DOWNLOAD_LEFT_TAG 0
#define DOWNLOAD_RIGHT_TAG 1

#define SCROLLCONTENTVIEW 0
#define ALERT_NOTFOUNDFILE 115

#define FILE_UNKNOW_ALERT_TAG 112233

@interface DownloadListVC ()<NavBarDelegate,BottomEditViewDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,PhotoItemSelectDelegate,OperateFiles,VideoProtocal,KxBackDelegate,UIDocumentInteractionControllerDelegate>
{
    
    CustomNavigationBar          *_customNavigationBar;
    BottomEditView               *_downloadingBottomView;
    BottomEditView               *_downloadedBottomView;
    BottomEditView               *_allPauseBomView;
    BOOL _registerLoadedNib;
    BOOL _registerLoadingNib;
    BOOL _viewAppeared;
    BOOL _editListAnimation;
    BOOL _cellClicked;
    NSInteger                    _editType;
    NSString                     *_copyPath;
    FileOperate                  *_operation;
    DownloadItemInfo             *_removeFileBean;
    NSInteger                    _swipeIndex;
    VideoViewController          * Viedeoview;
    ListVideoViewController          * _listViedeoview;
    KxMovieViewController        *_player;
    
    FileBean *selectbean;
    CustomNotificationView *_loadingView;
    TopView *_topView;
    NSString *  _currentVideoPath;
    int tabType;
    
    dispatch_queue_t queueOfPause;
    
    BOOL isviewdidloaded;
    PathBean *current;
    NSDictionary *deletedict;
    NSString *info_sn;
}

@property(nonatomic,retain) NSMutableDictionary* selectedItem;
@property(nonatomic,retain) NSMutableArray* operationFileArr;
@property(nonatomic,retain) NSMutableArray* modelArr;
@property(nonatomic,retain) UIDocumentInteractionController *documentController;

@property(nonatomic,strong) NSMutableArray* downloadedArray;
@property(nonatomic,strong) NSMutableArray* downloadingArray;

@property(nonatomic,strong) UITableView *tableViewOfDownloaded;
@property(nonatomic,strong) UITableView *tableViewOfDownloading;
@property(nonatomic,strong) UIScrollView *scrollContentView;
@property(nonatomic,strong) UIButton *closeBtn;

@property(nonatomic, assign) float appOutPlayTime;

@end

@implementation DownloadListVC

static  DownloadListVC *downloadListVC=nil;

+(DownloadListVC *)sharedInstance
{
    if (!downloadListVC) {
        downloadListVC=[[DownloadListVC alloc]init];
        downloadListVC.downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
        downloadListVC.downloadedArray = [[DownloadManager shareInstance] getDownloadCompleteArray];
        
    }
    return downloadListVC;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTopViewNum];
    
    [self changePauseBtnStatus];
    if (tabType == 1) {
        [_tableViewOfDownloaded reloadData];
    }
    else{
        [_tableViewOfDownloading reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)changePauseBtnStatus
{
    if (isviewdidloaded) {
        dispatch_async(queueOfPause, ^{
            BOOL isPause = [[DownloadManager shareInstance] getALLItemDownloadPaused];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_allPauseBomView setMenuItemWithTag:DOWNLOAD_MENU_ALLPAUSE_TAG enable:YES showReverse:!isPause];
            });
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isviewdidloaded = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _editListAnimation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
    
    self.selectedItem = [[NSMutableDictionary alloc] init];
    self.operationFileArr = [NSMutableArray array];
    if (!queueOfPause) {
        queueOfPause = dispatch_queue_create("BottomStatusCheckQueue", DISPATCH_QUEUE_SERIAL);
    }
//    self.downloadedArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",nil];
//    self.downloadingArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",nil];
    
    self.navigationController.navigationBarHidden = YES;
    self.modelArr = [NSMutableArray arrayWithObjects:[NSMutableArray array],[NSMutableArray array], nil];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [_customNavigationBar.leftBtn setTitle:@"下载的视频" forState:UIControlStateNormal];
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
    _customNavigationBar.title.text = NSLocalizedString(@"downloadlist", @"");
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
    _downloadingBottomView = [[BottomEditView alloc] initWithInfos:
                [NSArray arrayWithObjects:
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  NSLocalizedString(@"checkall",@""), @"title" ,
                  NSLocalizedString(@"cancel",@""), @"reverse_title" ,
                  @"list_icon-allselect-nouse", @"img" ,
                  @"list_icon-allselect", @"hl_img" ,
                  @"list_icon-noselect-nouse", @"reverse_img" ,
                  @"list_icon-noselect", @"reverse_hl_img" ,
                  [NSNumber numberWithInteger:DOWNLOAD_MENU_SELECTALL_TAG], @"tag" ,
                  nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  NSLocalizedString(@"delete",@""), @"title" ,
                  @"list_icon-delete-nouse", @"img" ,
                  @"list_icon-delete", @"hl_img" ,
                  @"1", @"is_delete" ,
                  [NSNumber numberWithInteger:DOWNLOAD_MENU_DELETE_TAG], @"tag" ,
                  nil],
                 nil] frame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 45)];
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_SELECTALL_TAG enable:YES reverse:NO];
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_DELETE_TAG enable:NO reverse:NO];
    
    _downloadingBottomView.editDelegate = self;
    
    _allPauseBomView = [[BottomEditView alloc] initWithInfos:
                             [NSArray arrayWithObjects:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               NSLocalizedString(@"allstart", @""), @"title" ,
                               NSLocalizedString(@"allpause", @""), @"reverse_title" ,
                               @"resource_download_allstart", @"img" ,
                               @"resource_download_allstart", @"hl_img" ,
                               @"resource_download_allpause", @"reverse_img" ,
                               @"resource_download_allpause", @"reverse_hl_img" ,
                               [NSNumber numberWithInteger:DOWNLOAD_MENU_ALLPAUSE_TAG], @"tag" ,
                               nil],
                              nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
    _allPauseBomView.editDelegate = self;
    [_allPauseBomView setMenuItemWithTag:DOWNLOAD_MENU_ALLPAUSE_TAG enable:YES reverse:NO];
    
    _topView = [[TopView alloc] init];
    _topView.leftBtn.tag = DOWNLOAD_LEFT_TAG;
    _topView.rightBtn.tag = DOWNLOAD_RIGHT_TAG;
    [_topView.leftBtn addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView.rightBtn addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self refreshTopViewNum];
    
    [_topView changeMode:tabType];
    
    CGFloat topViewY = _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height - _topView.frame.size.height;//(self.isTypeUIRoot && connect ? 0 : _topView.frame.size.height);
    _topView.frame = CGRectMake(0,topViewY ,
                                SCREEN_WIDTH,
                                38*WINDOW_SCALE);
    [self.view addSubview:_topView];
    
    
    _scrollContentView = [[UIScrollView alloc] init];
    _scrollContentView.backgroundColor = [UIColor clearColor];
    _scrollContentView.tag = SCROLLCONTENTVIEW;
    _scrollContentView.scrollEnabled = NO;
    [self.view addSubview:_scrollContentView];
    
    _tableViewOfDownloaded = [[UITableView alloc] init];
    _tableViewOfDownloaded.delegate = self;
    _tableViewOfDownloaded.dataSource = self;
    _tableViewOfDownloaded.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    _tableViewOfDownloaded.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewOfDownloaded.tag = DOWNLOAD_RIGHT_TAG;
    [_scrollContentView addSubview:_tableViewOfDownloaded];
    
    _tableViewOfDownloading = [[UITableView alloc] init];
    _tableViewOfDownloading.delegate = self;
    _tableViewOfDownloading.dataSource = self;
    _tableViewOfDownloading.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    _tableViewOfDownloading.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewOfDownloading.tag = DOWNLOAD_LEFT_TAG;
    [_scrollContentView addSubview:_tableViewOfDownloading];
    
//    _topView = [[TopView alloc] init];
//    _topView.leftBtn.tag = LEFT_TAG;
//    _topView.rightBtn.tag = RIGHT_TAG;
//    [_topView.leftBtn addTarget:self action:@selector(changeTabMenuClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_topView.rightBtn addTarget:self action:@selector(changeTabMenuClick:) forControlEvents:UIControlEventTouchUpInside];
//    _topView.leftLabel.text = @"";
//    _topView.rightLabel.text = @"";
//    [_topView changeMode:(int)_lastDisplay];
    
//    CGFloat topViewY = _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height - _topView.frame.size.height;//(self.isTypeUIRoot && connect ? 0 : _topView.frame.size.height);
//    _topView.frame = CGRectMake(0,topViewY ,
//                                SCREEN_WIDTH,
//                                38*WINDOW_SCALE);
    
    [self.view addSubview:_downloadingBottomView];
    [self.view addSubview:_allPauseBomView];
//    [self.view addSubview:_downloadedBottomView];
    [self.view addSubview:_customNavigationBar];
    
//    if (!_closeBtn) {
//        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    }
//    [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
//    [_closeBtn addTarget:self action:@selector(coloseBtnPressed) forControlEvents:UIControlEventTouchUpInside];
//    [_closeBtn setTitle:NSLocalizedString(@"close", @"") forState:UIControlStateNormal];
//    _closeBtn.frame = CGRectMake(24*WINDOW_SCALE, _customNavigationBar.frame.size.height - 42*WINDOW_SCALE, 60*WINDOW_SCALE, 44*WINDOW_SCALE);
//    [_customNavigationBar addSubview:_closeBtn];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeNewIdentify:) name:DOWNCOMPELETE_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadTable) name:@"checknewsong" object:nil];
}

-(void)ReloadTable{

    [_tableViewOfDownloaded reloadData];
}

-(void)viewDidLayoutSubviews
{
    BOOL isIOS6 =[[UIDevice currentDevice] systemVersion].floatValue < 7;
    CGFloat barOffsetY =  isIOS6? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _closeBtn.frame = CGRectMake(24*WINDOW_SCALE, _customNavigationBar.frame.size.height - 42*WINDOW_SCALE, 60*WINDOW_SCALE, 44*WINDOW_SCALE);
    
    CGFloat navBottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    _topView.frame = CGRectMake(0,navBottom ,
                                SCREEN_WIDTH,
                                38*WINDOW_SCALE);
    
    CGFloat tableViewOffsetY =  _topView.frame.origin.y +_topView.frame.size.height;
    _scrollContentView.frame = CGRectMake(0,
                                  tableViewOffsetY,
                                  SCREEN_WIDTH,
                                  SCREEN_HEIGHT - tableViewOffsetY);
    
    _scrollContentView.contentSize = CGSizeMake(_scrollContentView.frame.size.width * 2, _scrollContentView.frame.size.height);
    _tableViewOfDownloaded.frame = CGRectMake(_scrollContentView.frame.size.width, 0, _scrollContentView.frame.size.width, _scrollContentView.frame.size.height);
    _tableViewOfDownloading.frame = CGRectMake(0, 0, _scrollContentView.frame.size.width, _scrollContentView.frame.size.height);
    
}

-(void)connectionNotification:(NSNotification*)noti {
    if([noti.object intValue] == CU_NOTIFY_DEVOFF){
        [[DownloadManager shareInstance] pauseAll];
        if (_documentController) {
            [_documentController dismissMenuAnimated:YES];
        }
    }
    else if ([noti.object intValue] == CU_NOTIFY_DEVCON){
//        dispatch_async(dispatch_queue_create(0, 0), ^{
//            
//            HardwareInfoBean *info = [FileSystem get_info];
//            NSString *newsn = info.INFO_SN;
//            info_sn = info_sn == nil? @"":info_sn;
//            newsn = newsn == nil? @"":newsn;
//            if (![newsn isEqualToString:info_sn]) {
//                info_sn = newsn;
//                [self.downloadingArray removeAllObjects];
//                [self.downloadedArray removeAllObjects];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_tableViewOfDownloaded reloadData];
//                    [_tableViewOfDownloading reloadData];
//                });
//                [[DownloadManager shareInstance] clearSnPath];
//                [[DownloadManager shareInstance] readDownloadListFromFile];
//                self.downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
//                self.downloadedArray = [[DownloadManager shareInstance] getDownloadCompleteArray];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_tableViewOfDownloaded reloadData];
//                    [_tableViewOfDownloading reloadData];
//                });
//            }
//            
//        });
    }
}

-(BOOL)checkVideoIsPlaying
{
    BOOL isAnimated = YES;
    if ((Viedeoview && Viedeoview.view && Viedeoview.view.superview) || (_listViedeoview && _listViedeoview.view && _listViedeoview.view.superview)) {
        isAnimated = NO;
        if ((_listViedeoview && _listViedeoview.view && _listViedeoview.view.superview)) {
            [self removeListVideoPlayView];
        }
        else {
            [self removeVideoPlayView];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    return isAnimated;
}

-(void)refreshTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableViewOfDownloaded reloadData];
        [_tableViewOfDownloading reloadData];
    });

}


#pragma mark - segment delegate

-(void)segmentAction:(UIButton *)sender
{
    NSInteger index = sender.tag;
    
    if (tabType != index) {
        tabType = (int)index;
        [_topView changeMode:tabType];
        [self setEditStatusNormal];
        [_tableViewOfDownloaded reloadData];
        [_tableViewOfDownloading reloadData];
        [_scrollContentView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:NO];
    }
}

#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = tableView.tag == DOWNLOAD_RIGHT_TAG?_downloadedArray.count : _downloadingArray.count;
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == DOWNLOAD_RIGHT_TAG) {
        
        if (!_registerLoadedNib) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([DocumentFileCell class]) bundle:nil];
            [_tableViewOfDownloaded registerNib:nib forCellReuseIdentifier:@"DocCell"];
            _registerLoadedNib = YES;
        }
        
        static NSString *CellIdentifier = @"DocCell";
        DocumentFileCell*cell = [_tableViewOfDownloaded dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DocumentFileCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if(indexPath.row >= _downloadedArray.count){
            return cell;
        }

        NSMutableDictionary* tmpDic = [_downloadedArray objectAtIndex:indexPath.row];
        
        [cell setDownloadData:tmpDic row:indexPath.row needLoadIcon:_viewAppeared];
        [cell setEditStatus:[self cellIsEditing] animation:_editListAnimation];
        
        NSString* key = [tmpDic objectForKey:@"fpath"];
        [cell setSelectStatus:[self itemIsSelected:key]];
        cell.itemEditDelegate = self;
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        dic = [MusicPlayerViewController instance].noplayMusicplistDict;
        
        BOOL played ;
        if (dic.count>0) {
            played = ([dic objectForKey:[tmpDic objectForKey:@"filepath"]]!=nil);
        }else{
            played = NO;
        }
        [cell setNewIdentify:played];
        return cell;
        
    }
    else {
        
        if (!_registerLoadingNib) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([DownloadCell class]) bundle:nil];
            [_tableViewOfDownloading registerNib:nib forCellReuseIdentifier:@"DownCell"];
            _registerLoadingNib = YES;
        }
        
        
        static NSString *CellIdentifier = @"DownCell";
        DownloadCell *cell = [_tableViewOfDownloading dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DownloadCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if(indexPath.row >= _downloadingArray.count){
            return cell;
        }
        
        NSMutableDictionary* tmpDic = [_downloadingArray objectAtIndex:indexPath.row];
//        [tmpDic setObject:cell forKey:@"delegate"];
        
        [cell setData:tmpDic row:indexPath.row needLoadIcon:_viewAppeared];
        [cell setEditStatus:[self cellIsEditing] animation:_editListAnimation];
        
        NSString* key = [tmpDic objectForKey:@"fpath"];
        [cell setSelectStatus:[self itemIsSelected:key]];
        cell.itemEditDelegate = self;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([FileSystem isConnectedKE] && ![FileSystem checkInit]) {
        return;
    }
    
    NSArray* currentArr = [self getCurrentModelArray];
    if(indexPath.row >= currentArr.count || Viedeoview.view.superview||_listViedeoview.view.superview){
        return;
    }
    
    if (![self cellIsEditing]) {
        if(_cellClicked){
            return;
        }
        _cellClicked = YES;
        [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
        if (tabType == DOWNLOAD_RIGHT_TAG) {
           NSMutableDictionary *dict = [[self getCurrentModelArray] objectAtIndex:indexPath.row];
           [self gotoFileScanView:dict];
           
            [[MusicPlayerViewController instance]removeNewIdentify:[dict objectForKey:@"filepath"]];
            [_tableViewOfDownloaded reloadData];
    
        }
    }
}

#pragma mark - cell delegate

-(void)downloadCompleted
{
    [_tableViewOfDownloading reloadData];
    [_tableViewOfDownloaded reloadData];
    
    [self changePauseBtnStatus];
    [self refreshTopViewNum];
}

-(void)downloadFailed{
    [self changePauseBtnStatus];
}

-(void)pauseBtnClickWith:(NSString *)urlPath status:(int)status
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        if (status == STATUS_DOWNLOAD_PAUSE) {
            [[DownloadManager shareInstance] pauseDownloadWith:urlPath];
        }
        else{
            [[DownloadManager shareInstance] startDownloadWith:urlPath];
        }
        [self changePauseBtnStatus];
    });
}

-(void)deleteModel:(id)model
{
    [self deleteDownloadModel:model inDownloaded:NO];
}

-(void)deleteDownloadModel:(id)model inDownloaded:(BOOL)isindownloaded
{
    if (model) {
        NSString *urlstr = @"";
        NSMutableArray *currentArray = [self getCurrentModelArray];
        NSInteger index = [currentArray indexOfObject:model];
        if (tabType == DOWNLOAD_RIGHT_TAG) {
            
            urlstr = [((NSDictionary *)model) objectForKey:@"webURL"];
            
            [_tableViewOfDownloaded beginUpdates];
            [[DownloadManager shareInstance] removeDownloadCompleteItems:@[(NSDictionary *)model] atIndex:@[[NSNumber numberWithInteger:[currentArray indexOfObject:model]]]];
            [_tableViewOfDownloaded deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [_tableViewOfDownloaded endUpdates];
            
        }
        else{
            DownloadInfo* tmpInfo = [model objectForKey:@"item"];
            urlstr = tmpInfo.webURL;
            
            [_tableViewOfDownloading beginUpdates];
            [[DownloadManager shareInstance] removeDownloadingItem:@[(NSDictionary *)model] atIndex:@[[NSNumber numberWithInteger:[currentArray indexOfObject:model]]]];
            [_tableViewOfDownloading deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [_tableViewOfDownloading endUpdates];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNDELETE_NOTI object:[NSArray arrayWithObject:urlstr]];
        
        [self changePauseBtnStatus];
        [self refreshTopViewNum];
    }
}

-(NSMutableArray*)getCurrentModelArray{
    return tabType == DOWNLOAD_RIGHT_TAG? _downloadedArray : _downloadingArray;
}

-(void)swipeToControlDeleteBtn:(BOOL)show atRow:(NSInteger)row
{
    if (show) {
        if (_swipeIndex >= 0) {
            if (tabType == DOWNLOAD_RIGHT_TAG) {
                DocumentFileCell* cell = (DocumentFileCell*)[_tableViewOfDownloaded cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_swipeIndex inSection:0]];
                [cell setEditStatus:NO animation:YES];
            }
            else{
                DownloadCell* cell = (DownloadCell*)[_tableViewOfDownloading cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_swipeIndex inSection:0]];
                [cell setEditStatus:NO animation:YES];
            }
            
        }
        _swipeIndex = row;
    }
    else {
        _swipeIndex = -1;
    }
}

-(void)itemClickedAt:(NSInteger)index selected:(BOOL)selected
{
    if (index < [self getCurrentModelArray].count && !Viedeoview.view.superview) {
        if (![self cellIsEditing]) {
            
//            FileBean* bean = [[self getCurrentModelArray] objectAtIndex:index];
            
//            [self gotoFileScanView:bean];
        }
        else {
            NSMutableDictionary *tmpDic = [[self getCurrentModelArray] objectAtIndex:index];
            NSString* key = [tmpDic objectForKey:@"fpath"];
            if (selected) {
                if (![self.selectedItem objectForKey:key]) {
                    [self.selectedItem setObject:tmpDic forKey:key];
                }
            }
            else {
                if ([self.selectedItem objectForKey:key]) {
                    [self.selectedItem removeObjectForKey:key];
                }
            }
            [self changeTitle];
        }
    }
}

#pragma mark - nav delegate

-(void)coloseBtnPressed
{
    if (_editType == 1) {
        [self clickRight:nil];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)clickLeft:(UIButton *)leftBtn
{
    if (_editType == 1) {
        [self clickRight:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRight:(UIButton *)leftBtn
{
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    _editType = _editType == 0?1:0;
    _editListAnimation = YES;
    
    if (tabType == DOWNLOAD_RIGHT_TAG) {
        [_tableViewOfDownloaded reloadData];
    }
    else{
        [_tableViewOfDownloading reloadData];
    }
    
    if (_editType == 1) {
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
    }
    else {
        [self.selectedItem removeAllObjects];
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    }
    [self changeTitle];
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        _downloadedBottomView.frame = CGRectMake(0,
//                                                 ([self cellIsEditing]?(tabType == 0? SCREEN_HEIGHT - 45 : SCREEN_HEIGHT) : SCREEN_HEIGHT ),
//                                    SCREEN_WIDTH,
//                                    45);
        _downloadingBottomView.frame = CGRectMake(0,
                                          ([self cellIsEditing]? SCREEN_HEIGHT - 45 : SCREEN_HEIGHT ),
                                          SCREEN_WIDTH,
                                          45);
        _allPauseBomView.frame = CGRectMake(0,
                                            ([self cellIsEditing]?SCREEN_HEIGHT : (tabType == DOWNLOAD_LEFT_TAG?SCREEN_HEIGHT - 45 : SCREEN_HEIGHT)),
                                                  SCREEN_WIDTH,
                                                  45);
       
    } completion:^(BOOL finished) {
        
    }];
    [self performSelector:@selector(editAnimationDone) withObject:nil afterDelay:.3];
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

-(void)editAnimationDone{
    _editListAnimation = NO;
}

-(void)cellClickDone {
    _cellClicked = NO;
}

-(BOOL)cellIsEditing
{
    return _editType == 1;
}

#pragma mark - bottom view delegate

-(void)editButtonClickedAt:(NSInteger)tag
{
    if (tag == DOWNLOAD_MENU_SELECTALL_TAG)
    {
        BOOL selectAll = NO;
        selectAll = [_downloadingBottomView menuItemIsOriginWithTag:DOWNLOAD_MENU_SELECTALL_TAG];
        [self setSelectAll:selectAll];
        [self changeTitle];
    }
    else if (tag == DOWNLOAD_MENU_DELETE_TAG)
    {
//        (tabType == 0? NSLocalizedString(@"deletefilesy", @""):)
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
                                   NSLocalizedString(@"suretodeletedownloadunit", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
        alertView.tag = ALERT_FILES_DELETE_TAG;
        [alertView show];
        [self countDeleteModels];
    }
    else if (tag == DOWNLOAD_MENU_ALLPAUSE_TAG)
    {
        
        if (!_downloadingArray || _downloadingArray.count == 0) {
            return;
        }
        
        if (_cellClicked) {
            return;
        }
        _cellClicked = YES;
        [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:0.5];
        
        BOOL startAll = [_allPauseBomView menuItemIsOriginWithTag:DOWNLOAD_MENU_ALLPAUSE_TAG];
        [_allPauseBomView setMenuItemWithTag:DOWNLOAD_MENU_ALLPAUSE_TAG enable:YES reverse:YES];
        if (startAll) {//
            [[DownloadManager shareInstance] startAll];
        }
        else {
            [[DownloadManager shareInstance] pauseAll];
        }
        
    }
//    else if (tag == Downloaded_MENU_NEW_FOLDER_TAG)
//    {
//        NSString *title = NSLocalizedString(@"newfoldertitle", @"");
//        NSString *msg = NSLocalizedString(@"inputfoldername", @"");
//        
//        _editAlert = [[CustomEditAlertView alloc] initWithTitle:title message:msg defaultLabel:nil];
//        _editAlert.delegate = self;
//        [_editAlert show:self.view.window];
//    }
//    else if (tag == Downloaded_MENU_SELECT_ALL_TAG)
//    {
//        
//    }
//    else if (tag == Downloaded_MENU_COPY_TAG)
//    {
//        [self.operationFileArr removeAllObjects];
//        NSArray* currModelArr = _downloadedArray;
//        for (NSInteger i = 0; i < currModelArr.count; i ++) {
//            FileBean* been = [currModelArr objectAtIndex:i];
//            if ([self itemIsSelected:been.filePath]) {
//                BOOL hasIn = NO;
//                for (FileBean* beenTmp in self.operationFileArr) {
//                    if ([beenTmp.filePath isEqualToString:been.filePath]) {
//                        hasIn = YES;
//                        break;
//                    }
//                }
//                if (!hasIn) {
//                    [self.operationFileArr addObject:been];
//                }
//            }
//        }
//        _copyPath = [FileSystem getCopyPath];
//        CopyMainViewController* copyUI = [[CopyMainViewController alloc] init];
//        copyUI.pathDelegate = self;
//        [self pushViewController:copyUI animation:YES];
//        [copyUI setLastCopyPath:_copyPath];
//    }
//    else if (tag == Downloaded_MENU_DELETE_TAG)
//    {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
//                                  NSLocalizedString(@"deletefilesy", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
//        alertView.tag = Downloaded_MENU_DELETE_TAG;
//        [alertView show];
//        [self countDeleteModels];
//    }
}

-(void)setSelectAll:(BOOL)selected{
    if (selected) {
        NSArray* currentarr = [self getCurrentModelArray];
        for (NSInteger i = 0; i < currentarr.count; i ++) {
            NSDictionary * dict = [currentarr objectAtIndex:i];
            NSString* key = [dict objectForKey:@"fpath"];
            if (![self.selectedItem objectForKey:key]) {
                [self.selectedItem setObject:dict forKey:key];
            }
        }
        
    }
    else {
        [self.selectedItem removeAllObjects];
    }
    
    [_tableViewOfDownloaded reloadData];
    [_tableViewOfDownloading reloadData];
}


- (void)changeTitle
{
    BOOL enable = self.selectedItem.count != 0;
//    if (tabType == 0) {
//        [_downloadedBottomView setMenuItemWithTag:Downloaded_MENU_DELETE_TAG enable:enable reverse:NO];
//        [_downloadedBottomView setMenuItemWithTag:Downloaded_MENU_COPY_TAG enable:enable reverse:NO];
//    }else{
//        [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_DELETE_TAG enable:enable reverse:NO];
//    }
    
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_DELETE_TAG enable:enable reverse:NO];
    
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_SELECTALL_TAG enable:YES showReverse:(self.selectedItem.count > 0 && (self.selectedItem.count == [self getCurrentModelArray].count))];
}

-(void)countDeleteModels{
    [self.operationFileArr removeAllObjects];
    for (NSMutableDictionary* been in self.selectedItem.objectEnumerator) {
        if (been) {
            [self.operationFileArr addObject:been];
        }
    }
}

#pragma mark - alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == ALERT_FILES_DELETE_TAG) {
            [self deleteModelFiles];
        }
        else if (alertView.tag == ALERT_NOTFOUNDFILE){
            [self deleteModel:deletedict];
        }
        else if (alertView.tag == FILE_UNKNOW_ALERT_TAG)
        {
            [self openDocumentIn:selectbean];
        }
    }
    else {
        [self.operationFileArr removeAllObjects];
    }
}

#pragma mark -

-(void)openDocumentIn:(FileBean *)bean{
    
    //    [CustomNotificationView showToastWithoutDismiss:NSLocalizedString(@"readying", @"")];
    
    CustomNotificationView *view = [CustomNotificationView getToastWithoutDismiss:NSLocalizedString(@"readying", @"")];
    [self.view addSubview:view];
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        BOOL result = [[CustomFileManage instance] copyToTempWith:bean];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [CustomNotificationView clearToast];
            [view removeFromSuperview];
            if (result) {
                
                NSString *path = [[[CustomFileManage instance] getLibraryTempPath] stringByAppendingPathComponent:bean.fileName];
                NSURL *URL= [NSURL fileURLWithPath:path];
                if (URL) {
                    _documentController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                    _documentController.delegate = self;
                    [_documentController presentOpenInMenuFromRect:CGRectMake(0, 300, 100, 100) inView:self.view animated:YES];
                }
            }
            else{
                [CustomNotificationView showToast:NSLocalizedString(@"readyfail", @"")];
            }
        });
        
    });
    
}

#pragma mark - funtion

-(void)refreshTopViewNum
{
    _topView.rightLabel.text = [NSLocalizedString(@"downloaded", @"") stringByAppendingFormat:@"(%lu)",_downloadedArray.count];
    _topView.leftLabel.text = [NSLocalizedString(@"downloading", @"") stringByAppendingFormat:@"(%lu)",(unsigned long)_downloadingArray.count];
}

-(void)setEditStatusNormal
{
    _editType = 0;
    [self.selectedItem removeAllObjects];
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    
    [UIView animateWithDuration:.3 animations:^{
//        _downloadedBottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _downloadedBottomView.frame.size.height);
        _downloadingBottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _downloadingBottomView.frame.size.height);
        _allPauseBomView.frame = CGRectMake(0, tabType == DOWNLOAD_LEFT_TAG? SCREEN_HEIGHT - 45 : SCREEN_HEIGHT, SCREEN_WIDTH, _allPauseBomView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setEditStatusSelect
{
    _editType = 1;
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
    
    [UIView animateWithDuration:.3 animations:^{
//        _downloadedBottomView.frame = CGRectMake(0, tabType == 0?(SCREEN_HEIGHT - 45) :SCREEN_HEIGHT, SCREEN_WIDTH, _downloadedBottomView.frame.size.height);
        _downloadingBottomView.frame = CGRectMake(0, tabType == DOWNLOAD_LEFT_TAG?(SCREEN_HEIGHT - 45) : SCREEN_HEIGHT, SCREEN_WIDTH, _downloadingBottomView.frame.size.height);
        _allPauseBomView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, _allPauseBomView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)setbottomViewBtnNormal
{
    
//    [_downloadedBottomView setMenuItemWithTag:Downloaded_MENU_DELETE_TAG enable:NO reverse:NO];
//    [_downloadedBottomView setMenuItemWithTag:Downloaded_MENU_COPY_TAG enable:NO reverse:NO];
//    [_downloadedBottomView setMenuItemWithTag:Downloaded_MENU_SELECT_ALL_TAG enable:YES reverse:NO];
    
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_DELETE_TAG enable:NO reverse:NO];
    [_downloadingBottomView setMenuItemWithTag:DOWNLOAD_MENU_SELECTALL_TAG enable:YES reverse:NO];
}

-(BOOL)itemIsSelected:(NSString*)key {
    return [self.selectedItem objectForKey:key] != nil;
}

-(void)deleteModelFiles{
    if (self.operationFileArr.count > 0) {
        NSMutableArray *currentArray = [self getCurrentModelArray];
        NSMutableArray *indexsArray = [NSMutableArray array];
        NSMutableArray *indexPathsArray = [NSMutableArray array];
        
        NSMutableArray *urlstrArr = [NSMutableArray array];
        
        for (NSMutableDictionary *dict in _operationFileArr.objectEnumerator) {
            NSString *urlstr = @"";
            if (tabType == DOWNLOAD_RIGHT_TAG) {
                urlstr = [dict objectForKey:@"webURL"];
            }
            else{
                DownloadInfo* tmpInfo = [dict objectForKey:@"item"];
                urlstr = tmpInfo.webURL;
            }
            if (!urlstr) {
                continue;
            }
            [urlstrArr addObject:urlstr];
            
            NSInteger index = [currentArray indexOfObject:dict];
            [indexsArray addObject:[NSNumber numberWithInteger:index]];
            [indexPathsArray addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DOWNDELETE_NOTI object:urlstrArr];
        
        [self.selectedItem removeAllObjects];
        
        if (tabType == DOWNLOAD_RIGHT_TAG) {
//            [_tableViewOfDownloaded beginUpdates];
            [[DownloadManager shareInstance] removeDownloadCompleteItems:_operationFileArr atIndex:indexsArray];
//            [_tableViewOfDownloaded deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
//            [_tableViewOfDownloaded endUpdates];
            [_tableViewOfDownloaded reloadData];
            
        }
        else{
//            [_tableViewOfDownloading beginUpdates];
            [[DownloadManager shareInstance] removeDownloadingItem:_operationFileArr atIndex:indexsArray];
//            [_tableViewOfDownloading deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
//            [_tableViewOfDownloading endUpdates];
            [_tableViewOfDownloading reloadData];
        }
        
        [self changeTitle];
        [self changePauseBtnStatus];
        [self refreshTopViewNum];
    }
}

#pragma mark - video play

-(void) gotoFileScanView:(NSDictionary *)dict {
    
    if (dict) {
        
        NSString *infofilepath = [dict objectForKey:@"filepath"];
        FilePropertyBean *propertybean = [FileSystem readFileProperty:infofilepath];
        if (!propertybean) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"deletedownloadedtip", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"sure", @"") ,nil];
            alertView.tag = ALERT_NOTFOUNDFILE;
            deletedict = dict;
            [alertView show];
            return;
        }
        
        NSArray *items = [dict objectForKey:@"items"];
        if (!items || items.count<1) {
            return;
        }
        NSDictionary *itemdict = [items objectAtIndex:0];
        NSString *name = [itemdict objectForKey:@"dirName"];
        name = name && name.length>0?name : [itemdict objectForKey:@"name"];
        NSString *videopath = nil;
        
        NSString *audiopath = RealDownloadAudioPath;
        NSString *realvideopath = RealDownloadVideoPath;
        
        if ([infofilepath hasPrefix:audiopath]) {
            videopath =  [audiopath stringByAppendingPathComponent:name];
            
            if ([VIDEO_EX_DIC objectForKey:name.pathExtension]) {
                _currentVideoPath = videopath;
                [self play:videopath anim:YES];
            }
            else{
                [self playAudio:videopath];
            }
            
        }
        else if ([infofilepath hasPrefix:realvideopath]){
            videopath =  [realvideopath stringByAppendingPathComponent:name];
            _currentVideoPath = videopath;
            [self play:videopath anim:YES];
        }
        else if([infofilepath hasPrefix:RealDownloadPicturePath]){
            
            FileBean* filebean = [[FileBean alloc] init];
            filebean.fileType = FILE_IMG;
            filebean.filePath = infofilepath;
            if ([GIF_EX_DIC objectForKey:[[infofilepath lastPathComponent] pathExtension]]){
                filebean.fileType = FILE_GIF;
            }
            PreviewViewController* picVC = [[PreviewViewController alloc] init];
            [picVC allPhotoArr:[NSMutableArray arrayWithObjects:filebean, nil] nowNum:0 fromDownList:YES];
            
            [self.navigationController pushViewController:picVC animated:YES];
        }
        else if([infofilepath hasPrefix:RealDownloadDocumentPath]){
            NSString* extName = [infofilepath pathExtension];
            if ([DOC_EX_DIC objectForKey:extName]) {
                NSURL* url = [FileSystem changeURL:infofilepath];
                AnOtherWebViewController* webView = [[AnOtherWebViewController alloc] init];
                webView.titleStr = infofilepath;
                webView.downloadWeb = NO;
                [self.navigationController pushViewController:webView animated:YES];
                [webView hideRefreshPullView];
                [webView performSelector:@selector(webView:) withObject:url afterDelay:.3];
            }
            else {
                selectbean = [[FileBean alloc] init];
                selectbean.fileType = FILE_NONE;
                selectbean.filePath = infofilepath;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"openunknowfileusethirdAPP", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"notto", @"") otherButtonTitles:NSLocalizedString(@"yesto", @""),nil];
                alert.tag = FILE_UNKNOW_ALERT_TAG;
                [alert show];
            }
        }
    }
    else {
        [CustomNotificationView showToast:NSLocalizedString(@"unknowfile", @"")];
    }
}


-(void)playAudio:(NSString *)filePath
{
    NSString * prepath = filePath;
    [FileSystem changeConfigWithKey:@"playing_dir" value:[filePath stringByDeletingLastPathComponent]];
    
    NSMutableArray *newArray = [self getMusicplayList];
    
    FileBean *playbean = nil;
    for (FileBean *bean in newArray) {
        if ([bean.filePath isEqualToString:filePath]) {
            playbean = bean;
            break;
        }
    }
    
    if (!playbean) {
        playbean = [[FileBean alloc]init];
        playbean.fileType = FILE_MUSIC;
        playbean.filePath = filePath;
    }
    
    if ([prepath hasPrefix:KE_PHOTO] || [prepath hasPrefix:KE_VIDEO] || [prepath hasPrefix:KE_MUSIC] || [prepath hasPrefix:KE_DOC] || [prepath hasPrefix:KE_ROOT]) {
        [[MusicPlayerViewController instance]setArray:newArray];
        [[MusicPlayerViewController instance]setSongPath:playbean kuke:YES];
        
    }else {
        
        [[MusicPlayerViewController instance]setArray:newArray];
        [[MusicPlayerViewController instance]setSongPath:playbean kuke:NO];
        
    }
    MusicPlayerViewController * newPlayView=[MusicPlayerViewController instance];
    [newPlayView setNoneMusicViewHidden:YES];
//    newPlayView.scanDelegate = self;
    newPlayView.fromRoot = NO;
//    _musicDisplay = _lastDisplay;
    [self.navigationController pushViewController:newPlayView animated:YES];
    
}

-(NSMutableArray *)getMusicplayList
{
    [[CustomFileManage instance] cleanPathCache:RealDownloadAudioPath];
    current = [[CustomFileManage instance] getFiles:RealDownloadAudioPath fromPhotoRoot:NO];
    
    return current.musicPathAry;
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

-(void)play:(NSString *)path  anim:(BOOL)isAnim{
    
    [[MusicPlayerViewController instance] setMovPlay:YES];
    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
        [[MusicPlayerViewController instance]playorpause];
    }
    [VideoViewController setVideoPlaying:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYMUSIC
                                                        object:@"PlayMusic" userInfo:nil];
    BOOL isM3u8Dir = NO;
    if ([[path pathExtension] isEqualToString:@"m3u8"]) {
        FilePropertyBean* pb = [FileSystem readFileProperty:[path stringByAppendingPathComponent:@"durations.txt"]];
        if (pb) {
            isM3u8Dir = YES;
        }
    }
    
    if (isM3u8Dir) {
        //            path  = [path stringByAppendingPathComponent:[path lastPathComponent]];
        //            path  = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
        
        NSString* durationStr = [[NSString alloc] initWithData:[FileSystem  kr_readData:[path stringByAppendingPathComponent:@"durations.txt"]]  encoding:NSUTF8StringEncoding];
        NSMutableArray* durationArray = [NSMutableArray arrayWithArray:[durationStr componentsSeparatedByString:@","]];
        
        NSMutableArray *theItems = [NSMutableArray array];
        for (NSInteger i = 0; i < durationArray.count; i ++) {
            NSString *pathTmp = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%ld.mp4",[[path lastPathComponent] stringByDeletingPathExtension],(i + 1)]];
            
            NSURL *url =[FileSystem changeURL:pathTmp];
            //            AVPlayerItem *thePlayerItemA = [[AVPlayerItem alloc] initWithURL:url];
            [theItems addObject:url];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopMov)
                                                    name:@"stopMov"
                                                  object:nil];
        _listViedeoview = [[ListVideoViewController alloc] init];
        _listViedeoview.delegate = self;
        
        MPMoviePlayerController *player = [Viedeoview moviePlayer];
        player.controlStyle = MPMovieControlStyleNone;
        
        //        [Viedeoview setVideo:url];
        //        [Viedeoview play];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
//        _listViedeoview.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//        _listViedeoview.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        [self.view addSubview:_listViedeoview.view];
        
        CGFloat lasttime = 0;
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        if ([userdefault objectForKey:_currentVideoPath]) {
            NSArray * array = [userdefault objectForKey:_currentVideoPath];
            if (array.count > 1) {
                NSNumber *num = [array objectAtIndex:1];
                lasttime = num.floatValue;
            }
        }
        
        [self presentViewController:_listViedeoview animated:YES completion:^{
            [_listViedeoview setVideos:theItems title:[path lastPathComponent] durations:durationArray lasttime:lasttime];
            [_listViedeoview play];
        }];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            _listViedeoview.view.frame = CGRectMake(0,
//                                                    0,
//                                                    [UIScreen mainScreen].bounds.size.width,
//                                                    [UIScreen mainScreen].bounds.size.height);
//        } completion:^(BOOL finished) {
//            
//            [_listViedeoview setVideos:theItems title:[path lastPathComponent] durations:durationArray lasttime:lasttime];
//            [_listViedeoview play];
//            
//            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100ull *NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
//            //                [Viedeoview setVideo:url];
//            //                [Viedeoview play];
//            //            });
//            
//        }];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.navigationBarHidden = YES;
    }
    else if (([VIDEO_IOS_FORMAT objectForKey:[[path pathExtension] lowercaseString]])  || ![MobClickUtils MobClickIsActive]) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopMov)
                                                    name:@"stopMov"
                                                  object:nil];
        
        
        NSURL * url = [FileSystem changeURL:path];
        Viedeoview = [[VideoViewController alloc] init];
        Viedeoview.delegate = self;
        
        MPMoviePlayerController *player = [Viedeoview moviePlayer];
        player.controlStyle = MPMovieControlStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [self presentViewController:Viedeoview animated:YES completion:^{
            [Viedeoview setVideo:url progress:0];
            [Viedeoview play];
        }];
        
//        Viedeoview.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//        Viedeoview.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        [self.view addSubview:Viedeoview.view];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            Viedeoview.view.frame = CGRectMake(0,
//                                               0,
//                                               [UIScreen mainScreen].bounds.size.width,
//                                               [UIScreen mainScreen].bounds.size.height);
//        } completion:^(BOOL finished) {
//            
//            [Viedeoview setVideo:url];
//            [Viedeoview play];
//            
//        }];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.navigationBarHidden = YES;
        [self performSelector:@selector(playlaststate) withObject:nil afterDelay:1.5];
        
    }else{
        if(_player){
            
            _player.view.frame = CGRectMake(0,
                                            [UIScreen mainScreen].bounds.size.height,
                                            [UIScreen mainScreen].bounds.size.width,
                                            [UIScreen mainScreen].bounds.size.height);
            
            [_player self_dealloc];
            [_player removeFromParentViewController];
            _player = nil;
        }
        
        path = [@"/" stringByAppendingPathComponent:path];
        
        if(!IS_TAIG){
            if([path hasPrefix:KE_PHOTO] || [path hasPrefix:KE_VIDEO] || [path hasPrefix:KE_MUSIC] || [path hasPrefix:KE_DOC] || [path hasPrefix:KE_ROOT]){
                
                path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
            }
        }
        
        _player = [[KxMovieViewController alloc] init];
//        _player.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        _player.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _player.kxBackDelegate = self;
        [self.view addSubview:_player.view];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [_player setPath:path parameters:nil];
        
        [self presentViewController:_player animated:YES completion:^{
            
        }];
        [self performSelector:@selector(playlaststate) withObject:nil afterDelay:0.5];
    }
    
    [[MusicPlayerViewController instance] setMovPlay:NO];
    
//    [self performSelector:@selector(playlaststate) withObject:nil afterDelay:0.5];
    
    
}

//重返app，增加视频播放完成通知

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [Viedeoview play];
    [self performSelector:@selector(sertime) withObject:nil afterDelay:0];
}
-(void)sertime{
    [[Viedeoview moviePlayer]setCurrentPlaybackTime:self.appOutPlayTime];
    [Viedeoview valueChanged:self.appOutPlayTime];
    [Viedeoview endChanged:self.appOutPlayTime];
    [Viedeoview pause];
}
//按完home键之后，移除播放完成通知
- (void) applicationWillResignActive: (NSNotification *)notification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.appOutPlayTime = [Viedeoview moviePlayer].currentPlaybackTime;
    
}

-(void)saveMPmovie:(float)curr totalTime:(float)total player:(id)player{
    
    [FileSystem rotateWindow:NO];
    
    if ([Viedeoview moviePlayer] == player) {
        [self removeVideoPlayView];
        
    }
    
    if (_listViedeoview.myQueuePlayer == player) {
        [self removeListVideoPlayView];
        
    }
    [self removeNotificationOnPlayingView];
    
    [self saveVideoMemory:curr totalTime:total];
}

- (void)FinishedCallback:(NSNotification *)notify{
    
    [FileSystem rotateWindow:NO];
    
    if ([Viedeoview moviePlayer] == [notify object]) {
        [self removeVideoPlayView];
        
    }
    
    if (_listViedeoview.myQueuePlayer == [notify object]) {
        [self removeListVideoPlayView];
        
    }
    
    [self removeNotificationOnPlayingView];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)removeNotificationOnPlayingView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopMov" object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)removeVideoPlayView
{
    [VideoViewController setVideoPlaying:NO];
    [Viedeoview stopTikTimer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [FileSystem clearKeVideoURL];
    [Viedeoview dismissViewControllerAnimated:YES completion:^{
        [Viedeoview stop];
        Viedeoview = nil;

    }];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        Viedeoview.view.frame = CGRectMake(0,
//                                           [UIScreen mainScreen].bounds.size.height,
//                                           [UIScreen mainScreen].bounds.size.width,
//                                           [UIScreen mainScreen].bounds.size.height);
//        
//        
//    } completion:^(BOOL finished) {
//        [Viedeoview stop];
//        [Viedeoview removeFromParentViewController];
//        [Viedeoview.view removeFromSuperview];
//        Viedeoview = nil;
//        [FileSystem clearKeVideoURL];
//    }];
}

-(void)removeListVideoPlayView
{
    [ListVideoViewController setVideoPlaying:NO];
    
    [_listViedeoview stop];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
     [FileSystem clearKeVideoURL];
    [self dismissViewControllerAnimated:YES completion:^{
        _listViedeoview = nil;
    }];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        _listViedeoview.view.frame = CGRectMake(0,
//                                                [UIScreen mainScreen].bounds.size.height,
//                                                [UIScreen mainScreen].bounds.size.width,
//                                                [UIScreen mainScreen].bounds.size.height);
//        
//        
//    } completion:^(BOOL finished) {
//        [_listViedeoview stop];
//        [_listViedeoview removeFromParentViewController];
//        [_listViedeoview.view removeFromSuperview];
//        _listViedeoview = nil;
//        [FileSystem clearKeVideoURL];
//    }];
}


-(void)stopMov{
    [CustomNotificationView showToast:NSLocalizedString(@"movplayfail", @"")];
    [self removeVideoPlayView];
    [self removeNotificationOnPlayingView];
}

-(void)playlaststate{
    
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:_currentVideoPath]) {
        NSArray * array = [userdefault objectForKey:_currentVideoPath];
        NSNumber *num = [NSNumber numberWithFloat:0];
        if (array.count > 1) {
            num = [array objectAtIndex:1];
        }
        if ([VIDEO_IOS_FORMAT objectForKey:[[_currentVideoPath pathExtension] lowercaseString]]) {
            //MP4格式播放记录
            [Viedeoview pause];
            [[Viedeoview moviePlayer]setCurrentPlaybackTime:[num floatValue]];
            [Viedeoview valueChanged:[num floatValue]];
            [Viedeoview endChanged:[num floatValue]];
            [Viedeoview play];
            
        }else if ([[[_currentVideoPath pathExtension] lowercaseString] isEqualToString:@"m3u8"]){
            [_listViedeoview pause];
            [_listViedeoview valueChanged:[num floatValue]];
            [_listViedeoview endChange:[num floatValue]];
            [_listViedeoview play];
        }else{
            //其他格式播放记录
            if (_player) {
                [_player pause];
                //            [_player setMoviePosition:[num floatValue]];
                [_player endChange:[num floatValue]/_player.totalTime];
                [_player play];
            }
            
        }
        
    }
    
}

-(void)setStatusBarIsHidden:(NSNumber *)isHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:isHidden.boolValue];
}

-(void)playEnd{
    [self clickBackBtn];
}

- (void) playError:(NSError *)error{
    
    [self clickBackBtn];
}

-(void)clickBackBtn{
    
    if (_player) {
        [_player removeViewAtBottom];
    }
    [FileSystem rotateWindow:NO];
    
    if (!_player) {
        return;
    }
    
    if (_player.totalTime>_player.currentTime+2.0) {
        
        [self saveVideoMemory:_player.currentTime totalTime:_player.totalTime];
    }else{
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        if ([userdefault objectForKey:_currentVideoPath]) {
            [userdefault removeObjectForKey:_currentVideoPath];
        }
    }
    
    [VideoViewController setVideoPlaying:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self dismissViewControllerAnimated:_player completion:^{
        if(_player){
            [_player self_dealloc];
            _player = nil;
        }
    }];
}

-(void)saveVideoMemory:(float)time totalTime:(float)totaltime{
    
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *oneDayStr = [dateFormatter stringFromDate:date];
    NSArray * array = [[NSArray alloc]initWithObjects:oneDayStr,[NSNumber numberWithFloat:time],[NSNumber numberWithFloat:totaltime], nil];
    [userdefault setObject:array forKey:_currentVideoPath];
    
}

#pragma mark - public

-(void)addDownloadTask:(DownloadInfo *)info
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [[DownloadManager shareInstance] addDownloadTask:info delegate:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewOfDownloading reloadData];
        });
    });
}

-(void)addDownloadTaskWithArray:(NSMutableArray *)infoarray
{
    dispatch_async(dispatch_queue_create(0, 0), ^{
        [[DownloadManager shareInstance] addDownloadTaskWithArray:infoarray delegate:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewOfDownloading reloadData];
        });
    });
}

-(void)removeTaskAtPath:(NSString*)path {
     NSMutableArray *currentArray = [self getCurrentModelArray];
    for (NSMutableDictionary* tmpDic in _downloadingArray) {
        DownloadInfo* tmpInfo = [tmpDic objectForKey:@"item"];
        if ([tmpInfo.filepath isEqualToString:path]) {
            [[DownloadManager shareInstance] removeDownloadingItem:@[(NSDictionary *)tmpDic] atIndex:@[[NSNumber numberWithInteger:[currentArray indexOfObject:tmpDic]]] fromFile:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableViewOfDownloading reloadData];
                [self refreshTopViewNum];
            });
            break;
        }
        
    }
}

-(BOOL)isTopVC{
    return [self.navigationController.topViewController isKindOfClass:[DownloadListVC class]];
}
#pragma mark - rotate

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    if (queueOfPause) {
        dispatch_object_t _o = (queueOfPause);
        _dispatch_object_validate(_o);
        queueOfPause = NULL;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
