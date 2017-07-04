//
//  FileViewController.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015????? taig. All rights reserved.
//

#import "FileViewController.h"
#import "TopView.h"
#import "CustomNavigationBar.h"
#import "CustomAlertView.h"
#import "BottomEditView.h"
#import "PhotoLineCell.h"
#import "DocumentFileCell.h"
#import "CustomFileManage.h"
#import "CustomNavigationController.h"
#import "FileSystem.h"
#import "CustomFileManage.h"
#import "FileOperate.h"
#import "CustomNotificationView.h"
#import "CustomEditAlertView.h"
#import "CopyMainViewController.h"
#import "PhotoGroupViewController.h"
#import "ScanFileDelegate.h"
#import "PreviewViewController.h"
#import "PhotoOperate.h"
#import "PhotoItemCell.h"
#import "MobClickUtils.h"
#import "AppDelegate.h"
#import "FirstViewController.h"
#import "DownloadListVC.h"
#import "ListVideoViewController.h"
#import "PrivateViewController.h"
#import "DownloadManager.h"


#define ACTION_DONE @"ACTION_DONE"
#define TABLE_HEADER_HEIGHT 50.0


#define MENU_NEW_FOLDER_TAG  123
#define MENU_SELECT_ALL_TAG  124
#define MENU_COPY_TAG        125
#define MENU_DELETE_TAG      126
#define MENU_COPY_HERE_TAG   127

#define MENU_IMPORT_PICTURE_TAG   128
#define MENU_EXPORT_PICTURE_TAG   129
#define MENU_EXPORT_TAG   130

#define DELETE_ALERT_TAG   444
#define DELETE_ITEM_ALERT_TAG   555
#define COPYFROMSYS_ALERT_TAG   666
#define FILE_UNKNOW_ALERT_TAG 777
#define FILE_DOC_TYPE 888


#define FileView_ImportTip_MaskBtnLeft 1234
#define FileView_ImportTip_MaskBtnRight 1235

@interface FileViewController ()<NavBarDelegate,BottomEditViewDelegate,PhotoItemSelectDelegate,OperateFiles,CustomEditAlertViewDelegate,ScanFileDelegate,GroupDeletage,OperatePhotos,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIDocumentInteractionControllerDelegate,VideoProtocal> {
    NSInteger                    _lastDisplay;
    NSInteger                    _musicDisplay;
    
    NSInteger                    _swipeIndex;
    NSInteger                    _editType;
    BOOL                         _isExportEditing;
    BOOL                         _registerNib;
    BOOL                         _editListAnimation;
    BOOL                         _editDeleting;
    BOOL                         _cellClicked;
    BOOL                         _needReloadData;
    BOOL                         _viewAppeared;
    BOOL                         _viewVisible;
    BOOL                         _firstLoadView;
    BottomEditView               *_bomView;
    BottomEditView               *_importPicView;
    BottomEditView               *_exportPicView;
    TopView                      *_topView;
    CustomNavigationBar          *_customNavigationBar;
    CustomNavigationController   *_customNavigationVC;
    UITableView                  *_tableView;
    UIImageView                  *_screenshot;
    
    NSString                     *_copyPath;
    PathBean                     *_pathBean;
    PathBean                     *_kePathBean;
    FileBean                     *_removeFileBean;
    FileOperate                  *_operation;
    PhotoOperate                 *_importOperation;
    CustomNotificationView       *_loadingView;
    CustomEditAlertView          *_editAlert;
    KxMovieViewController        *_player;
    NSInteger                         _clickIndex;
    WebViewController             * web;
    
    UIView                       *_linkKukeContanierView;
    UIView                       *_lightLinkContanierView;
    UILabel                      *_unlinkTitleLab;
    UILabel                      *_unlinkSubtitleLab;
    UILabel                      *_unlinkTipLab;
    UIImageView                  *_linkupImageView;
    UIImageView                  *_linkdownImageView;
    UIImageView                  *_handImageView;
    UIImageView                  *_circleImageView;
    UIImageView                  *_lightLinkImageView;
    NSTimer *_linkKeTimer;
    
    
    DocumentFileCell *_lastPlayCell;
    //    NSMutableArray               *_VCArr;
    VideoViewController             *_videoViewController;
    ListVideoViewController         *_listViedeoview;
    
    NSMutableArray *cellArray;
    
    UIImageView *_noPicTipIV;
    UIButton *_noPicMaskBtn;
    UIButton *_noPicImportBtn;
    
    CGFloat screenWidth;
    
    
    
    CustomNavigationController *navi;
    
    UIView *selectView;
    FileBean *selectbean;
    
    BOOL isDownloadedVideoPath;
    UIDocumentInteractionController *documentController;
    NSDateFormatter *dateFormatter;
    NSMutableArray *_downloadingArray;
    BOOL isRefreshing;
}
@property(nonatomic,retain) NSMutableArray* modelArr;

@property(nonatomic,retain) NSMutableArray* sectionArr;

@property(nonatomic,retain) NSMutableDictionary* selectedItem;
@property(nonatomic,retain) NSMutableArray* operationFileArr;
@property(nonatomic,retain) NSString * currentVideoPath;
@property(nonatomic,retain) UIDocumentInteractionController *documentController;

@end

@implementation FileViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLoadView = YES;
    _needReloadData = YES;
    screenWidth = SCREEN_WIDTH;
    self.view.backgroundColor = [UIColor whiteColor];
    isDownloadedVideoPath = [self checkIsDownloadedFilePath];
    
    cellArray = [NSMutableArray array];
    BOOL connect = [FileSystem isConnectedKE];
    _lastDisplay =  connect && self.isTypeUIRoot ? RIGHT_TAG : LEFT_TAG;
    _swipeIndex = -1;
    self.selectedItem = [[NSMutableDictionary alloc] init];
    self.operationFileArr = [NSMutableArray array];
    self.navigationController.navigationBarHidden = YES;
    self.modelArr = [NSMutableArray arrayWithObjects:[NSMutableArray array],[NSMutableArray array], nil];
    self.sectionArr = [NSMutableArray array];
    
    [self readData:self.uiType != Copy_UI_Type];
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    if (!self.isTypeUIRoot) {
        NSArray* pathComponents = [self.subCopyPath pathComponents];
        NSString* lastPath = [self.subCopyPath stringByDeletingLastPathComponent];
//        NSLog(@"self.rootStr : %@, lastPath : %@, root : %@",self.rootStr,lastPath,[self getRootDirPath]);
        if (![[lastPath lowercaseString] isEqualToString:[[self getRootDirPath] lowercaseString]] && pathComponents.count > 2) {
            NSString* pathComponent = [pathComponents objectAtIndex:(pathComponents.count - 2)];
            NSInteger location = [pathComponent rangeOfString:@"/"].location;
            NSString* title = location > 0  && (pathComponent.length > location + 1) ? [pathComponent substringFromIndex: location] : pathComponent;
            _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            BOOL longer ;
            if (title.length >3) {
                longer = YES;
            }
            else
            {
                longer = NO;
            }
            
            [_customNavigationBar.leftBtn setTitle:longer ? NSLocalizedString(@"back",@""):[NSString stringWithFormat:@"  %@",title] forState:UIControlStateNormal];
        }
        else {
            _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [_customNavigationBar.leftBtn setTitle:[NSString stringWithFormat:@"  %@",self.rootStr] forState:UIControlStateNormal];
        }
    }else{
        _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
    }
    
    if (self.uiType == Copy_UI_Type) {
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
    }
    else {
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    }
    
    _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
    
    if (self.uiType == Copy_UI_Type) {
        _bomView = [[BottomEditView alloc] initWithInfos:
                    [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"newfolder",@""), @"title" ,
                      [NSNumber numberWithInteger:MENU_NEW_FOLDER_TAG], @"tag" ,
                      @"list_icon-new-nouse", @"img" ,
                      @"list_icon-new", @"hl_img" ,
                      nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"copyhere",@""), @"title" ,
                      @"list_icon-move-nouse", @"img" ,
                      @"list_icon-move", @"hl_img" ,
                      [NSNumber numberWithInteger:MENU_COPY_HERE_TAG], @"tag" ,
                      nil],
                     nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
        [_bomView setMenuItemWithTag:MENU_NEW_FOLDER_TAG enable:YES reverse:NO];
        [_bomView setMenuItemWithTag:MENU_COPY_HERE_TAG enable:YES reverse:NO];
    }
    else {
        _bomView = [[BottomEditView alloc] initWithInfos:
                    [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"newfolder",@""), @"title" ,
                      @"list_icon-new-nouse", @"img" ,
                      @"list_icon-new", @"hl_img" ,
                      [NSNumber numberWithInteger:MENU_NEW_FOLDER_TAG], @"tag" ,
                      nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"checkall",@""), @"title" ,
                      NSLocalizedString(@"cancel",@""), @"reverse_title" ,
                      @"list_icon-allselect-nouse", @"img" ,
                      @"list_icon-allselect", @"hl_img" ,
                      @"list_icon-noselect-nouse", @"reverse_img" ,
                      @"list_icon-noselect", @"reverse_hl_img" ,
                      [NSNumber numberWithInteger:MENU_SELECT_ALL_TAG], @"tag" ,
                      nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"copy",@""), @"title" ,
                      @"list_icon-copy-nouse", @"img" ,
                      @"list_icon-copy", @"hl_img" ,
                      [NSNumber numberWithInteger:MENU_COPY_TAG], @"tag" ,
                      nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedString(@"delete",@""), @"title" ,
                      @"list_icon-delete-nouse", @"img" ,
                      @"list_icon-delete", @"hl_img" ,
                      @"1", @"is_delete" ,
                      [NSNumber numberWithInteger:MENU_DELETE_TAG], @"tag" ,
                      nil],
                     nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
        [_bomView setMenuItemWithTag:MENU_NEW_FOLDER_TAG enable:YES reverse:NO];
        [_bomView setMenuItemWithTag:MENU_SELECT_ALL_TAG enable:YES reverse:NO];
        [_bomView setMenuItemWithTag:MENU_COPY_TAG enable:NO reverse:NO];
        [_bomView setMenuItemWithTag:MENU_DELETE_TAG enable:NO reverse:NO];
    }
    
    _bomView.editDelegate = self;
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    if (self.uiType == Picture_UI_Type || self.resType == Video_Res_Type) {
        _importPicView = [[BottomEditView alloc] initWithInfos:
                          [NSArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"importpic",@""), @"title" ,
                            @"list_icon_import_nouse", @"img" ,
                            @"list_icon_import", @"hl_img" ,
                            [NSNumber numberWithInteger:MENU_IMPORT_PICTURE_TAG], @"tag" ,
                            nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"exportpic",@""), @"title" ,
                            @"list_icon_export_nouse", @"img" ,
                            @"list_icon_export", @"hl_img" ,
                            [NSNumber numberWithInteger:MENU_EXPORT_PICTURE_TAG], @"tag" ,
                            nil],
                           nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
        [_importPicView setMenuItemWithTag:MENU_IMPORT_PICTURE_TAG enable:YES reverse:NO];
        [_importPicView setMenuItemWithTag:MENU_EXPORT_PICTURE_TAG enable:YES reverse:NO];
        _importPicView.editDelegate = self;
        [self.view addSubview:_importPicView];
        
        _exportPicView = [[BottomEditView alloc] initWithInfos:
                          [NSArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"checkall",@""), @"title" ,
                            NSLocalizedString(@"cancel",@""), @"reverse_title" ,
                            @"list_icon-allselect-nouse", @"img" ,
                            @"list_icon-allselect", @"hl_img" ,
                            @"list_icon-noselect-nouse", @"reverse_img" ,
                            @"list_icon-noselect", @"reverse_hl_img" ,
                            [NSNumber numberWithInteger:MENU_SELECT_ALL_TAG], @"tag" ,
                            nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            NSLocalizedString(@"export",@""), @"title" ,
                            @"list_icon_export_nouse", @"img" ,
                            @"list_icon_export", @"hl_img" ,
                            [NSNumber numberWithInteger:MENU_EXPORT_TAG], @"tag" ,
                            nil],
                           nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
        [_exportPicView setMenuItemWithTag:MENU_EXPORT_TAG enable:YES reverse:NO];
        [_exportPicView setMenuItemWithTag:MENU_SELECT_ALL_TAG enable:YES reverse:NO];
        _exportPicView.editDelegate = self;
        [self.view addSubview:_exportPicView];
        
    }
    if (self.uiType == Picture_UI_Type) {
        _tableView.allowsSelection = NO;
    }
    
    if (self.isTypeUIRoot) {
        _topView = [[TopView alloc] init];
        _topView.leftBtn.tag = LEFT_TAG;
        _topView.rightBtn.tag = RIGHT_TAG;
        [_topView.leftBtn addTarget:self action:@selector(changeTabMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView.rightBtn addTarget:self action:@selector(changeTabMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        _topView.leftLabel.text = @"";
        _topView.rightLabel.text = @"";
        
        
        [_topView changeMode:(int)_lastDisplay];
        
        CGFloat topViewY = _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height - _topView.frame.size.height;//(self.isTypeUIRoot && connect ? 0 : _topView.frame.size.height);
        _topView.frame = CGRectMake(0,topViewY ,
                                    SCREEN_WIDTH,
                                    38*WINDOW_SCALE);
        [self.view addSubview:_topView];
    }
    [self.view addSubview:_bomView];
    [self.view addSubview:_customNavigationBar];
    
    if(self.uiType != Copy_UI_Type) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_FORMATE object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyDoneNotification:) name:ACTION_DONE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCellColor:) name:NOWMUSICPLAYBEAN object:nil];
    if (self.uiType != Copy_UI_Type && (self.isTypeUIRoot || [CustomFileManage isDownloadedDir:self.subCopyPath])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadnoti:) name:DOWNCOMPELETE_NOTI object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadtable) name:@"checknewsong" object:nil];
    
    [self refreshLeftMenuTitle];
    [self refreshRightMenuTitle];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(reloadDelay) withObject:nil afterDelay:.3];
    _viewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _viewVisible = NO;
//    [self removeTipView:YES];
}

#pragma mark - NSNotification Methods

-(void)connectionNotification:(NSNotification*)noti {
    if([noti.name isEqualToString:DEVICE_FORMATE]){
        [self readData:NO];
    }
    else {
        if([noti.object intValue] == CU_NOTIFY_DEVCON || [noti.object intValue] == CU_NOTIFY_DEVOFF){
            BOOL isconnected = [FileSystem isConnectedKE];
            if ([noti.object intValue] == CU_NOTIFY_DEVOFF) {
                [LogUtils writeLog:@"DEBUGMODEL CU_NOTIFY_USB_OFF list"];
                
                if (_documentController) {
                    [_documentController dismissMenuAnimated:YES];
                }
                
                [self noPicMaskBtnClick];
                if ((_videoViewController && _videoViewController.view && _videoViewController.view.superview) || (_listViedeoview && _listViedeoview.view && _listViedeoview.view.superview)) {
                    if ((_listViedeoview && _listViedeoview.view && _listViedeoview.view.superview)) {
                        [self removeListVideoPlayView];
                    }
                    else {
                        [self removeVideoPlayView];
                    }
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
                }
                if(self.isTypeUIRoot && ![((AppDelegate*)[[UIApplication sharedApplication] delegate]).window viewWithTag:CUSTUM_ALERT_ATG] && !_customNavigationVC){//
                    [self clickBackBtn];
                    if ([self.navigationController.viewControllers containsObject:self]) {
                        [self.navigationController popToViewController:self animated:YES];
                    }
                    if (isconnected) {
                        [self setBottomViewHidden:YES animated:YES];
                    }
                    
                }
                
                if (navi) {
                    [navi dismissViewControllerAnimated:YES completion:^{
                        navi = nil;
                    }];
                }
                
                [self reloadCurrentData];
                [LogUtils writeLog:@"DEBUGMODEL CU_NOTIFY_USB_OFF list aa"];
            }
            else {
                [[CustomFileManage instance] setKukeDeleteFileCache:YES];
                [self removeTipView:YES];
                if (!self.parentViewController || !self.view.superview) {
                    [self setBottomViewHidden:NO animated:YES];
                    if (_loadingView) {
                        [_loadingView dismiss];
                        _loadingView = nil;
                    }
                    _needReloadData = YES;
                    [LogUtils writeLog:@"DEBUGMODEL fileview connectionNotification: !self.parentViewController || !self.view.superview return"];
                    return;
                }
                
                PowerBean* powerBean = [FileSystem getPoweInfo];
                if (([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) || powerBean.usb1_model == INSERTPC_U) {
                    [LogUtils writeLog:@"DEBUGMODEL fileview connectionNotification: ([FileSystem checkBindPhone] && ![FileSystem iphoneislocked]) || powerBean.usb1_model == INSERTPC_U return"];
                    [[CustomAlertView instance] hidden];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return;
                }
                //            BOOL isconnected = [FileSystem isConnectedKE];
                if (isconnected) {
                    [self setBottomViewHidden:NO animated:YES];
                    if (_loadingView) {
                        [_loadingView dismiss];
                        _loadingView = nil;
                    }
                    _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
                    if ([self checkIsShowDataSync]) {
                        [_loadingView show];
                    }
                    
                }
                else{
                    [LogUtils writeLog:@"DEBUGMODEL fileview connectionNotification: !isconnected return"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
        else if([noti.object intValue] == CU_NOTIFY_DEVINITED) {
            if (_loadingView || ([self getCurrentModelArray].count == 0 && self == self.navigationController.topViewController)) {
                [self performSelector:@selector(reloadCurrentData) withObject:nil afterDelay:.1];
                if (!_loadingView) {
                    _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
                    if ([self checkIsShowDataSync]) {
                        [_loadingView show];
                    }
                }
            }
            else{
                [LogUtils writeLog:@"DEBUGMODEL CU_NOTIFY_DEVINITED not reloadCurrentData"];
            }
        }
    }
}

-(void)copyDoneNotification:(NSNotification*)noti {
    NSDictionary* info = [noti object];
    NSString* action = [info objectForKey:@"action"];
    if ([info isKindOfClass:[NSDictionary class]] && [info objectForKey:@"path"]) {
        NSString* path = [info objectForKey:@"path"];
        [[CustomFileManage instance] cleanPathImgFileCache:path];
        BOOL needReload = NO;
        if([path isEqualToString:[self getCurrentPath]]) {
            if (_viewVisible) {
                needReload = YES;
            }
            else {
                _needReloadData = YES;
            }
        }
        else{
            NSString* superPath = [path stringByDeletingLastPathComponent];
            if ([superPath isEqualToString:[self getCurrentPath]] && self == self.navigationController.topViewController) {
                if (_viewVisible) {
                    needReload = YES;
                }
                else {
                    _needReloadData = YES;
                }
            }
            else if ([superPath isEqualToString:[self getCurrentPath]] || (self.isTypeUIRoot && ([superPath isEqualToString:[self getRootDirPathWith:LEFT_TAG]] || [superPath isEqualToString:[self getRootDirPathWith:RIGHT_TAG]]))) {
                if (self.parentViewController) {
                    _needReloadData = YES;
                }
                else if(self.isTypeUIRoot){
                    self.needReload = YES;
                }
            }
        }
        
        if (needReload) {
            if ([action isEqual:@"delete"]) {
                NSNumber* removeNowPlaying = [info objectForKey:@"deleteplaying"];
                NSString* noticepath = [info objectForKey:@"currentpath"];
                if(removeNowPlaying != nil){
                    [self performSelectorOnMainThread:@selector(delayReadDataWithNOLoading:) withObject:removeNowPlaying waitUntilDone:YES];
                }
                else {
                    if (noticepath && ![noticepath isEqualToString:[self getCurrentPath]]) {
                        [NSThread detachNewThreadSelector:@selector(reloadCurrentData) toTarget:self withObject:nil];
                    }
                }
                
            }
            else {
                if ([action isEqualToString:@"create"]) {
                    [NSThread detachNewThreadSelector:@selector(reloadCurrentData) toTarget:self withObject:nil];
                }
                else {
                    [self performSelectorOnMainThread:@selector(readDataWithLoading) withObject:nil waitUntilDone:NO];
                }
            }
            
        }
    }
}

-(void)changeCellColor:(NSNotification*)noti
{
    NSString *str = (NSString *)[noti object];
    NSString *path = [[noti userInfo] objectForKey:@"FILE_PATH"];
    if ([str isEqualToString:@"NOWPLAYING"] && [noti.name isEqualToString:NOWMUSICPLAYBEAN]) {
        for (DocumentFileCell *cell in cellArray) {
            
            if ([cell.model.filePath isEqualToString:path]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.fileName.textColor = [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:70.0/255.0 alpha:1];
                });
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.fileName.textColor = [UIColor blackColor];
                });
            }
        }
        
    }
}

-(void)downloadnoti:(NSNotification *)noti{
    int type = [[noti object] intValue];
    if (type == 0) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newmusicdown"];
    }else if (type == 1){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newvideodown"];
    }
    else if (type == 2){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newpicturedown"];
    }
    else if (type == 3){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"newdocumentdown"];
    }
    
    BOOL isneedRefresh = ((type == 0 && [self.subCopyPath isEqualToString:RealDownloadAudioPath]) || (type == 1 && [self.subCopyPath isEqualToString:RealDownloadVideoPath]) || (type == 2 && [self.subCopyPath isEqualToString:RealDownloadPicturePath]) || (type == 3 && [self.subCopyPath isEqualToString:RealDownloadDocumentPath]));
    if (isneedRefresh) {
        isRefreshing = YES;
        [NSThread detachNewThreadSelector:@selector(downloadCompletedToRefreshTable:) toTarget:self withObject:[NSNumber numberWithInt:type]];
    }
}

-(void)reloadtable{
    [_tableView reloadData];
}

#pragma mark -

-(void)downloadCompletedToRefreshTable:(NSNumber *)typeNum
{
    int type = typeNum.intValue;
    NSString* path = [self getCurrentPath];
    
    [[CustomFileManage instance] cleanPathCache:path];
    if ((([[self getCurrentPath] isEqualToString:KE_PHOTO] || [[self getCurrentPath] isEqualToString:PHONE_PHOTO]) && type == 2)) {
        [[CustomFileManage instance] cleanPathCache:RealDownloadPicturePath];
    }
    PathBean* bean = [[CustomFileManage instance] getFiles:path fromPhotoRoot:NO];
    _needReloadData = NO;
    if (bean) {
        NSInteger idx = type == 0?3:2; //2:video 3:music
        _pathBean = bean;
        NSArray* tmp = [NSArray arrayWithObjects:_pathBean.dirPathAry,_pathBean.imgPathAry,_pathBean.videoPathAry,_pathBean.musicPathAry,_pathBean.docPathAry,_pathBean.nonePathAry, nil];
        [self.modelArr replaceObjectAtIndex:0 withObject:[self getDetailArr:tmp withIndex:idx]];
        [[CustomFileManage instance] setKukeDeleteFileCache:YES];
        
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        isRefreshing = NO;
    }
}

- (void)removeMPmovie {
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:_currentVideoPath]) {
        [userdefault removeObjectForKey:_currentVideoPath];
    }
}

- (void)saveMPmovie:(float)curr totalTime:(float)total player:(id)player {
    
    [FileSystem rotateWindow:NO];
    
    if ([_videoViewController moviePlayer] == player) {
        [self removeVideoPlayView];
        
    }
    
    if (_listViedeoview.myQueuePlayer == player) {
        [self removeListVideoPlayView];
        
    }
    [self removeNotificationOnPlayingView];
    
    [self saveVideoMemory:curr totalTime:total];
}

-(void)reloadDelay{
    _viewAppeared = YES;
    _firstLoadView = NO;
    if (_needReloadData && !_firstLoadView && !_loadingView) {
        [self readData:YES];
        _needReloadData = NO;
    }
    else {
        [_tableView reloadData];
    }
}

-(void)loadingDoneDelay{
    if ([self.titleStr isEqualToString:NSLocalizedString(@"rootPath",@"")]) {
        for (FileBean *bean in [self getCurrentModelArray]) {
           
            [LogUtils writeLog:[NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"rootPath",@""),bean.fileName]];
        }
    }
    if (isDownloadedVideoPath) {
        for (FileBean *bean in [self getCurrentModelArray]) {
            [bean getFileSize];
        }
    }
    
    [_tableView reloadData];
    [self performSelector:@selector(checkIsShowImportAlert) withObject:nil afterDelay:.1];
    
    [self refreshLeftMenuTitle];
    [self refreshRightMenuTitle];
    [self performSelector:@selector(resetKukeDeletedCache) withObject:nil afterDelay:.25];
    [self performSelector:@selector(loadingDone) withObject:nil afterDelay:.3];
}

-(void)resetKukeDeletedCache {
    NSUInteger count = self.uiType == Picture_UI_Type ? [self getPhotoUIRowCount] : [self getCurrentModelArray].count;
    if(count > 0){
        [[CustomFileManage instance] setKukeDeleteFileCache:NO];
    }
}

#pragma mark - import tip

-(void)checkIsShowImportAlert
{
    if (self.uiType== Copy_UI_Type || ![FileSystem isChinaLan]) {
        return;
    }
    
    BOOL isImageFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsShowAlert"];
    BOOL isVideoFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsvideoShowAlert"];
    if (!isImageFirstTime && self.isTypeUIRoot && self.resType == Picture_Res_Type &&[FileSystem checkInit] ) {
        _noPicTipIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_no_pic_tips" bundle:@"TAIG_FILE_LIST"]];
        [self videoAndImageTips];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsShowAlert"];
        
    }else if ((!isVideoFirstTime && self.isTypeUIRoot && self.resType == Video_Res_Type &&[FileSystem checkInit] )){
         _noPicTipIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_tips" bundle:@"TAIG_MainImg"]];
        [self videoAndImageTips];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsvideoShowAlert"];
    }
     
}

-(void)videoAndImageTips{

    _noPicMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _noPicMaskBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45);
    _noPicMaskBtn.backgroundColor = [UIColor blackColor];
    _noPicMaskBtn.alpha = 0.65;
    [_noPicMaskBtn addTarget:self action:@selector(noPicMaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_noPicMaskBtn];
    
    _noPicTipIV.frame = CGRectMake(0, SCREEN_HEIGHT - 375*WINDOW_SCALE_SIX, 375*WINDOW_SCALE_SIX, 330*WINDOW_SCALE_SIX);
    [self.view addSubview:_noPicTipIV];
    
    CGFloat tipPicBottomY = _noPicTipIV.frame.size.height + _noPicTipIV.frame.origin.y;
    _noPicImportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _noPicImportBtn.frame = CGRectMake(125*WINDOW_SCALE_SIX, tipPicBottomY - 115*WINDOW_SCALE_SIX, 125*WINDOW_SCALE_SIX, 50*WINDOW_SCALE_SIX);
    _noPicImportBtn.backgroundColor = [UIColor clearColor];
    
    [_noPicImportBtn addTarget:self action:@selector(noPicImportBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_noPicImportBtn];
    
    UIButton *maskbtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    maskbtn1.frame = CGRectMake(0, SCREEN_HEIGHT - 45, (SCREEN_WIDTH/2.0 - 125*WINDOW_SCALE_SIX)/2.0,45);
    maskbtn1.backgroundColor = [UIColor blackColor];
    maskbtn1.alpha = 0.65;
    maskbtn1.tag = FileView_ImportTip_MaskBtnLeft;
    [maskbtn1 addTarget:self action:@selector(noPicMaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:maskbtn1];
    
    UIButton *maskbtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    maskbtn2.frame = CGRectMake((SCREEN_WIDTH/2.0 + 125*WINDOW_SCALE_SIX)/2.0, SCREEN_HEIGHT - 45, (SCREEN_WIDTH/2.0 - 125*WINDOW_SCALE_SIX)/2.0 + SCREEN_WIDTH/2.0,45);
    maskbtn2.backgroundColor = [UIColor blackColor];
    maskbtn2.alpha = 0.65;
    maskbtn2.tag = FileView_ImportTip_MaskBtnRight;
    [maskbtn2 addTarget:self action:@selector(noPicMaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:maskbtn2];
}

-(void)noPicImportBtnClick
{
    [self gotoImportPic];
}

-(void)noPicMaskBtnClick
{
    if (_noPicTipIV) {
        if (_noPicTipIV.superview) {
            [_noPicTipIV removeFromSuperview];
        }
        _noPicTipIV = nil;
    }
    
    if (_noPicMaskBtn) {
        if (_noPicMaskBtn.superview) {
            [_noPicMaskBtn removeFromSuperview];
        }
        _noPicMaskBtn = nil;
    }
    
    if (_noPicImportBtn) {
        if (_noPicImportBtn.superview) {
            [_noPicImportBtn removeFromSuperview];
        }
        _noPicImportBtn = nil;
    }
    
    UIView *btn1 = [self.view viewWithTag:FileView_ImportTip_MaskBtnLeft];
    UIView *btn2 = [self.view viewWithTag:FileView_ImportTip_MaskBtnRight];
    
    if (btn1) {
        if (btn1.superview) {
            [btn1 removeFromSuperview];
        }
        btn1 = nil;
    }
    
    if (btn2) {
        if (btn2.superview) {
            [btn2 removeFromSuperview];
        }
        btn2 = nil;
    }
}

#pragma mark -

-(void)loadingDone{
    [_loadingView dismiss];
    _loadingView = nil;
}

-(void)photoViewdismiss
{
    if (navi) {
        navi = nil;
    }
}

-(void)uiFitConnectionStatus {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGFloat yy = 38*WINDOW_SCALE;//(connect && self.isTypeUIRoot ? 0 : 38*WINDOW_SCALE);
        _topView.frame = CGRectMake(0,_customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height - yy ,
                                    SCREEN_WIDTH,
                                    38*WINDOW_SCALE);
        [self changeTitle];
        CGFloat tableViewOffsetY = _topView.frame.origin.y + _topView.frame.size.height;
        _tableView.frame = CGRectMake(0,
                                      tableViewOffsetY,
                                      SCREEN_WIDTH,
                                      SCREEN_HEIGHT - tableViewOffsetY);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)viewDidLayoutSubviews{
    BOOL isIOS6 =[[UIDevice currentDevice] systemVersion].floatValue < 7;
    CGFloat barOffsetY =  isIOS6? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _bomView.frame = CGRectMake(0,
                                SCREEN_HEIGHT-(([self isEditing] || self.uiType == Copy_UI_Type) && !_isExportEditing?45:0),
                                SCREEN_WIDTH,
                                45);
    if (_importPicView) {
        _importPicView.frame = CGRectMake(0,
                                          SCREEN_HEIGHT-([self isEditing]?0:45),
                                          SCREEN_WIDTH,
                                          45);
    }
    if (_exportPicView) {
        _exportPicView.frame = CGRectMake(0,
                                          SCREEN_HEIGHT-(!_isExportEditing?0:45),
                                          SCREEN_WIDTH,
                                          45);
    }
    
    CGFloat topViewY = _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height - _topView.frame.size.height;
    _topView.frame = CGRectMake(0,topViewY ,
                                SCREEN_WIDTH,
                                38*WINDOW_SCALE);
    [self changeTitle];
    CGFloat tableViewOffsetY =  _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height;
    _tableView.frame = CGRectMake(0,
                                  [UIApplication sharedApplication].isStatusBarHidden? tableViewOffsetY-(isIOS6?0: 20):tableViewOffsetY,
                                  SCREEN_WIDTH,
                                  SCREEN_HEIGHT - tableViewOffsetY);
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    
    if ([FileSystem isConnectedKE] || !FOR_STORE) {
        
        BOOL isLink = [FileSystem checkInit];
        if (!isLink) {
            [self setBottomViewHidden:YES animated:NO];
        }
        else{
            [self setBottomViewHidden:NO animated:YES];
        }
    }
    
}

- (void)changeTitle
{
    
    if ([self isEditing])
    {
        if (self.selectedItem.count == 0) {
            _customNavigationBar.title.text = (self.resType == Music_Res_Type?NSLocalizedString(@"selectmusic", @""):NSLocalizedString(@"selectfile", @""));
            [_bomView setMenuItemWithTag:MENU_COPY_TAG enable:NO reverse:NO];
            [_bomView setMenuItemWithTag:MENU_DELETE_TAG enable:NO reverse:NO];
            if (_isExportEditing) {
                [_exportPicView setMenuItemWithTag:MENU_EXPORT_TAG enable:NO reverse:NO];
            }
        }else{
            _customNavigationBar.title.text =[NSString stringWithFormat:@"%@%lu%@",NSLocalizedString(@"selected", @""),(unsigned long)self.selectedItem.count,NSLocalizedString(@"selectcountunit", @"")];
            [_bomView setMenuItemWithTag:MENU_COPY_TAG enable:YES reverse:NO];
            [_bomView setMenuItemWithTag:MENU_DELETE_TAG enable:YES reverse:NO];
            if (_isExportEditing) {
                [_exportPicView setMenuItemWithTag:MENU_EXPORT_TAG enable:YES reverse:NO];
            }
        }
        if(_editType == Edit_Export){
            PathBean* current = [self getCurrentPathBean];
            NSUInteger allcount = current.imgPathAry.count;
            for (FileBean *bean in current.videoPathAry) {
                if (bean.fileType == FILE_MOV) {
                    allcount ++;
                }
            }
            [_exportPicView setMenuItemWithTag:MENU_SELECT_ALL_TAG enable:YES showReverse:(self.selectedItem.count > 0 && self.selectedItem.count == allcount)];
        }
        else {
            [_bomView setMenuItemWithTag:MENU_SELECT_ALL_TAG enable:YES showReverse:(self.selectedItem.count > 0 && self.selectedItem.count == [self getCurrentModelArray].count)];
        }
        
    }else
    {
        _customNavigationBar.title.text = self.titleStr;
    }
}

- (void)refreshLeftMenuTitle
{
    _topView.leftLabel.text = [NSString stringWithFormat:@"%@ (%lu)",NSLocalizedString(@"phone", @""),(unsigned long)((NSArray*)[self.modelArr objectAtIndex:0]).count];
}

- (void)refreshRightMenuTitle
{
    _topView.rightLabel.text = [NSString stringWithFormat:@"%@ (%lu)",NSLocalizedString(@"kuner", @""),(unsigned long)((NSArray*)[self.modelArr objectAtIndex:1]).count];
}


-(void)changeTab:(NSInteger)tabTag{
    if (tabTag == LEFT_TAG) {
        [self changeTabMenuClick:_topView.leftBtn];
    }
    else {
        if ([FileSystem checkInit]) {
            [self changeTabMenuClick:_topView.rightBtn];
        }
        else{
            [self changeTabMenuClick:_topView.leftBtn];
        }
    }
}


- (void)changeTabMenuClick :(UIButton *)sender
{
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    if([self isEditing]){
        [self.selectedItem removeAllObjects];
        [self.operationFileArr removeAllObjects];
        [self changeTitle];
    }
    ChangeMode flag;
    int tag = (int)sender.tag;
    if (_lastDisplay == tag) {
        _cellClicked = NO;
        return;
    }
    _lastDisplay = tag;
    if (LEFT_TAG == tag)
    {
        flag = LEFT;
    }else
    {
        flag = RIGHT;
        
    }
    [_tableView reloadData];
    _tableView.contentOffset = CGPointMake(0, 0);
    [_topView changeMode:flag];
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

-(void)clickLeft:(UIButton *)leftBtn {
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    if (self.uiType == Copy_UI_Type) {
        [self gotoBeforePathUI];
    }
    else {
        if ([self isEditing]) {
            _cellClicked = NO;
            [self clickRight:nil];
        }
        if (self.isTypeUIRoot) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            if ([MusicPlayerViewController instance].scanDelegate == self){
                [MusicPlayerViewController instance].scanDelegate = nil;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

-(void)clickRight:(UIButton *)leftBtn {
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    if (self.uiType == Copy_UI_Type) {
        [self.pathDelegate dismissViewController:self];
    }
    else {
        if (_editType == Edit_Export) {
            _isExportEditing = !_isExportEditing;
        }
        if (!_isExportEditing) {
            if ([self isEditing]) {
                _editType = Edit_None;
            }
            else {
                _editType = Edit_Select;
            }
        }
        
        _editListAnimation = YES;
        [_tableView reloadData];
        
        
        if ([self isEditing]) {
            [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"done",@"") forState:UIControlStateNormal];
        }
        else {
            [self.selectedItem removeAllObjects];
            [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
        }
        [self changeTitle];
        
        NSLog(@"bottom frame:%@,import:%@,export:%@",NSStringFromCGRect(_bomView.frame),NSStringFromCGRect(_importPicView.frame),NSStringFromCGRect(_exportPicView.frame));
        
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _bomView.frame = CGRectMake(0,
                                        SCREEN_HEIGHT-(!_isExportEditing && [self isEditing]?45:0),
                                        SCREEN_WIDTH,
                                        45);
            if (_importPicView) {
                _importPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT-([self isEditing]?0:45),
                                                  SCREEN_WIDTH,
                                                  45);
            }
            if (_exportPicView) {
                _exportPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT-(!_isExportEditing?0:45),
                                                  SCREEN_WIDTH,
                                                  45);
            }
        } completion:^(BOOL finished) {
            NSLog(@"212121212bottom frame:%@,import:%@,export:%@",NSStringFromCGRect(_bomView.frame),NSStringFromCGRect(_importPicView.frame),NSStringFromCGRect(_exportPicView.frame));
        }];
        [self performSelector:@selector(editAnimationDone) withObject:nil afterDelay:.3];
    }
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

-(void)editAnimationDone{
    _editListAnimation = NO;
}

-(void)alertViewButtonClickedAt:(NSInteger)index withText:(NSString *)text {
    NSString* name = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (index == 1) {
        NSString *msg = @"";
        if(name.length == 0){
            if (self.resType == Music_Res_Type) {
                msg = NSLocalizedString(@"musicdirnamenotempty", @"");
            }
            else if (self.resType == Picture_Res_Type){
                msg = NSLocalizedString(@"photodirnamenotempty", @"");
            }
            else{
                msg = NSLocalizedString(@"firnillname", @"");
            }
            [CustomNotificationView showToast:msg];
        }
        else {
            BOOL hasErrorCode = NO;
            for (NSInteger i = 0; i < NAME_ERROR_CODE.count; i ++) {
                NSString* textCode = [NAME_ERROR_CODE objectAtIndex:i];
                if ([name isKindOfClass:[NSString class]]&& [name rangeOfString:textCode].location != NSNotFound) {
                    hasErrorCode = YES;
                    break;
                }
            }
            if (hasErrorCode) {
                msg = NSLocalizedString(@"namecontantunuseablechar", @"");
                [CustomNotificationView showToast:msg];
                return;
            }
            NSString* currentPath = [self getCurrentPath];
            NSString* path = [currentPath stringByAppendingPathComponent:name];
            if([[CustomFileManage instance] existFile:path]){
                if (self.resType == Music_Res_Type) {
                    msg = NSLocalizedString(@"existmusicdirname", @"");
                }
                else if (self.resType == Picture_Res_Type){
                    msg = NSLocalizedString(@"existphotodirname", @"");
                }
                else{
                    msg = NSLocalizedString(@"direxisted", @"");
                }
                
                [CustomNotificationView showToast:msg];
            }
            else {
                if (_loadingView) {
                    [_loadingView dismiss];
                    _loadingView = nil;
                }
                _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"newfodercreating",@"")];
                [_loadingView show];
                [NSThread detachNewThreadSelector:@selector(creatingPath:) toTarget:self withObject:path];
            }
        }
    }
}

-(void)createPathResult:(NSNumber *)result
{
    int ret = result.intValue;
    NSString* currentPath = [self getCurrentPath];
    [self loadingDone];
    if(ret == 0) {
        [self reloadCurrentData];
        if (self.uiType != Picture_UI_Type) {
            DocumentFileCell* cell = (DocumentFileCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self getCurrentModelArray].count - 1) inSection:0]];
            [cell setEditStatus:[self isEditing] animation:NO];
        }
        [self changeTitle];
        if (_lastDisplay == LEFT_TAG) {
            [self refreshLeftMenuTitle];
        }
        else {
            [self refreshRightMenuTitle];
        }
        if(self.uiType == Copy_UI_Type){
            NSDictionary* actionInfo = [NSDictionary dictionaryWithObjectsAndKeys:currentPath,@"path",@"create",@"action", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_DONE object:actionInfo];
        }
    }
    else {
        [CustomNotificationView showToast:NSLocalizedString(@"createfail", @"")];
    }
}

-(void)creatingPath:(NSString *)path
{
    int ret = [[CustomFileManage instance] creatDir:path];
    [self performSelectorOnMainThread:@selector(createPathResult:) withObject:[NSNumber numberWithInt:ret] waitUntilDone:YES];
}

#pragma mark - BottomEditViewDelegate

-(void)editButtonClickedAt:(NSInteger)tag {
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    if (tag == MENU_NEW_FOLDER_TAG) {
        NSString *title = @"";
        NSString *msg = @"";
        if (self.resType == Music_Res_Type) {
            title = NSLocalizedString(@"createmusicdirname", @"");
            msg = NSLocalizedString(@"entermusicdirname", @"");
        }
        else if (self.resType == Picture_Res_Type){
            title = NSLocalizedString(@"createphotodirname", @"");
            msg = NSLocalizedString(@"enterphotodirname", @"");
        }
        else{
            title = NSLocalizedString(@"newfoldertitle", @"");
            msg = NSLocalizedString(@"inputfoldername", @"");
        }
        _editAlert = [[CustomEditAlertView alloc] initWithTitle:title message:msg defaultLabel:nil];
        _editAlert.delegate = self;
        [_editAlert show:self.view.window];
        [self UMengClick: NSLocalizedString(@"newfolder",@"") isMenu:YES];
    }
    else if (tag == MENU_SELECT_ALL_TAG) {
        BOOL selectAll = NO;
        if(_editType == Edit_Export){
            selectAll = [_exportPicView menuItemIsOriginWithTag:MENU_SELECT_ALL_TAG];
        }
        else {
            selectAll = [_bomView menuItemIsOriginWithTag:MENU_SELECT_ALL_TAG];
        }
       [self setSelectAll:selectAll];
//        [_bomView setMenuItemWithTag:MENU_SELECT_ALL_TAG enable:YES reverse:YES];
        [self changeTitle];
        if (selectAll) {
            [self UMengClick:NSLocalizedString(@"checkall",@"") isMenu:YES];
        }
        else {
            [self UMengClick:NSLocalizedString(@"cancel",@"") isMenu:YES];
        }
    }
    else if (tag == MENU_COPY_TAG) {
        [self.operationFileArr removeAllObjects];
        NSArray* currModelArr = [self getCurrentModelArray];
        for (NSInteger i = 0; i < currModelArr.count; i ++) {
            FileBean* been = [currModelArr objectAtIndex:i];
            if ([self itemIsSelected:been.filePath]) {
                BOOL hasIn = NO;
                for (FileBean* beenTmp in self.operationFileArr) {
                    if ([beenTmp.filePath isEqualToString:been.filePath]) {
                        hasIn = YES;
                        break;
                    }
                }
                if (!hasIn) {
                    [self.operationFileArr addObject:been];
                }
            }
        }
        _copyPath = [FileSystem getCopyPath];
        CopyMainViewController* copyUI = [[CopyMainViewController alloc] init];
        copyUI.pathDelegate = self;
        [self pushViewController:copyUI animation:YES];
        [copyUI setLastCopyPath:_copyPath];
        [self UMengClick:NSLocalizedString(@"copy",@"") isMenu:YES];
    }
    else if (tag == MENU_DELETE_TAG) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
                                  /*(self.resType == Music_Res_Type?@"确定要删除所选歌单吗？" :*/
                                   NSLocalizedString(@"deletefilesy", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
        alertView.tag = DELETE_ALERT_TAG;
        [alertView show];
        [self countDeleteModels];
        [self UMengClick:NSLocalizedString(@"delete",@"") isMenu:YES];
    }
    else if (tag == MENU_COPY_HERE_TAG) {
        NSString* copyPathTmp = [self getCurrentPath];
        [self.pathDelegate choicedPathAt:copyPathTmp];
        [self.pathDelegate dismissViewController:self];
    }
    else if (tag == MENU_IMPORT_PICTURE_TAG) {
        [self gotoImportPic];
    }
    else if (tag == MENU_EXPORT_PICTURE_TAG) {
        _cellClicked = NO;
        _editType = Edit_Export;
        [self clickRight:nil];
        [self UMengClick:NSLocalizedString(@"exportpic",@"") isMenu:YES];
    }
    else if (tag == MENU_EXPORT_TAG) {
        PhotoGroupViewController* photoGroup = [[PhotoGroupViewController alloc]init];
        photoGroup.delegate = self;
        
        NSMutableArray* tmpArray = [NSMutableArray array];
        NSArray* currModelArr = [self getCurrentModelArray];
        for (NSInteger i = 0; i < currModelArr.count; i ++) {
            FileBean* been = [currModelArr objectAtIndex:i];
            if ([self itemIsSelected:been.filePath]) {
                BOOL hasIn = NO;
                for (FileBean* beenTmp in tmpArray) {
                    if ([beenTmp.filePath isEqualToString:been.filePath]) {
                        hasIn = YES;
                        break;
                    }
                }
                if (!hasIn) {
                    [tmpArray addObject:been];
                }
            }
        }
        navi = [[CustomNavigationController alloc] initWithRootViewController:photoGroup];
        [navi setNavigationBarHidden:YES animated:NO];
        [photoGroup type:NO moveArr:tmpArray showType:TYPE_ALL resType:self.resType == Video_Res_Type];
//        [photoGroup initDataToPath];
        [self.view.window.rootViewController presentViewController:navi animated:YES completion:^{
            
        }];
        [self UMengClick:NSLocalizedString(@"export",@"") isMenu:YES];
    }
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

#pragma mark -

-(void)UMengClick:(NSString*)label isMenu:(BOOL)isMenu{
    NSString* event = isMenu ? [self getUMengMenuEvent] : [self getUMengListEvent];
    [MobClickUtils event:event label:label];
}

-(NSString*)getUMengMenuEvent{
    if (self.resType == Picture_Res_Type) {
        return @"PIC_MENU_CLICK";
    }
    else if (self.resType == Video_Res_Type) {
        return @"VIDEO_MENU_CLICK";
    }
    else if (self.resType == Music_Res_Type) {
        return @"MUSIC_MENU_CLICK";
    }
    else if (self.resType == Document_Res_Type) {
        return @"DOC_MENU_CLICK";
    }
    else if (self.resType == Root_Res_Type) {
        return @"FM_MENU_CLICK";
    }
    return @"PIC_MENU_CLICK";
}

-(NSString*)getUMengListEvent{
    if (self.resType == Picture_Res_Type) {
        return @"PIC_LIST_CLICK";
    }
    else if (self.resType == Video_Res_Type) {
        return @"VIDEO_LIST_CLICK";
    }
    else if (self.resType == Music_Res_Type) {
        return @"MUSIC_LIST_CLICK";
    }
    else if (self.resType == Document_Res_Type) {
        return @"DOC_LIST_CLICK";
    }
    else if (self.resType == Root_Res_Type) {
        return @"FM_LIST_CLICK";
    }
    return @"PIC_LIST_CLICK";
}

#pragma mark - Utility

-(BOOL)checkDocmentCellIsInDownloadingList:(FileBean *)bean
{ // 文件是否下载中
    BOOL isIn = NO;
    for (NSDictionary *tmp in _downloadingArray) {
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.filepath isEqualToString:bean.filePath]) {
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

-(void)doDeleteModel{
    if (!_removeFileBean) {
        return;
    }
    if (!self.operationFileArr) {
        self.operationFileArr = [[NSMutableArray alloc]init];
    }
    [self.operationFileArr removeAllObjects];
    [self.operationFileArr addObject:_removeFileBean];
    FileBean* currentMusic = [[MusicPlayerViewController instance] getCurrentBean];
    BOOL removeNowPlay = NO;
    BOOL removeNowDir = NO;
    if ([currentMusic.filePath isEqualToString:_removeFileBean.filePath]) {
        if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
            removeNowPlay = YES;
        }
        
        [[MusicPlayerViewController instance]  setDeleteState:YES];
        [[CustomMusicPlayer shareCustomMusicPlayer]stop];
    }
    else if(!removeNowPlay && [currentMusic.filePath rangeOfString:_removeFileBean.filePath].location != NSNotFound && _removeFileBean.fileType == FILE_DIR){
        removeNowDir = YES;
    }
    if (_removeFileBean.fileType == FILE_DIR) {
        [[CustomFileManage instance] cleanPathCache:_removeFileBean.filePath];
    }
    for (NSString* key in self.selectedItem.keyEnumerator) {
        FileBean* tmp = [self.selectedItem objectForKey:key];
        if ([_removeFileBean isEqual:tmp]) {
            [self.selectedItem removeObjectForKey:key];
            break;
        }
    }
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
        _operation.delegate = self;
    }
    [_operation deleteFiles:self.operationFileArr userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"delete",@"action",
                                                            [self getCurrentPath],@"dirpath",
                                                            [NSNumber numberWithBool:removeNowPlay],@"deleteplaying",
                                                            [NSNumber numberWithBool:removeNowDir],@"deleteplayingdir", nil]];
    [self deleteplayidentify:self.operationFileArr];
    _removeFileBean = nil;
}

-(void)gotoImportPic
{
    [self noPicMaskBtnClick];
    
    PhotoGroupViewController* photoGroup = [[PhotoGroupViewController alloc]init];
    photoGroup.delegate = self;
    
    navi = [[CustomNavigationController alloc] initWithRootViewController:photoGroup];
    [navi setNavigationBarHidden:YES animated:NO];
    [photoGroup type:YES moveArr:nil showType:(self.resType == Picture_Res_Type?TYPE_PHOTO :(self.resType == Video_Res_Type?TYPE_VIDEO : TYPE_ALL)) resType:self.resType == Video_Res_Type];
//    [photoGroup initDataToPath];
    [self.view.window.rootViewController presentViewController:navi animated:YES completion:^{
    }];
    
    // ke Photo 索引及图片数据
    NSMutableArray *allPhos = [self getAllPhotos];
    NSArray *phoArr = [self groupPhotos:allPhos];
    if (phoArr.count == 2) {
        [Context shareInstance].kePhoIndexArray = phoArr[0];
        [Context shareInstance].kePhoSectionArray = phoArr[1];
    }
    
    [self UMengClick:NSLocalizedString(@"importpic",@"") isMenu:YES];
}

#pragma mark - 图片备份准备ke中图片方法

- (NSMutableArray *)getAllPhotos
{ // 获取当前目录下所有图片
    NSMutableArray *allPhoArr = [NSMutableArray array];
    for (FileBean *fileBean in [Context shareInstance].keRootPhoArray) {
        if (fileBean.fileType == FILE_IMG || fileBean.fileType==FILE_GIF) {
            [allPhoArr addObject:fileBean];
        }
        else if (fileBean.fileType == FILE_DIR)
        {
            NSArray *dirArr = [self getPhosFromFileBean:fileBean path:[self getRootDirPath]];
            [allPhoArr addObjectsFromArray:dirArr];
        }
    }
    
    NSLog(@"allPhotosCount: %lu",allPhoArr.count);
    return allPhoArr;
}

- (NSMutableArray *)getPhosFromFileBean:(FileBean *)fileBean path:(NSString *)path
{
    NSMutableArray *imgMutArr = [[NSMutableArray alloc] init];
    
    // 获取路径
    if (path.length > 0) {
        NSString *curPath = [path stringByAppendingPathComponent:fileBean.fileName];
        PathBean *pathBean = [[CustomFileManage instance] getFiles:curPath fromPhotoRoot:(_resType==Picture_Res_Type)];
        NSMutableArray  *fileMArr  = [NSMutableArray arrayWithArray:pathBean.dirPathAry];
        [fileMArr addObjectsFromArray:pathBean.imgPathAry];
        
        for (FileBean *fBean in fileMArr) {
            if (fBean.fileType == FILE_IMG || fBean.fileType == FILE_GIF) {
                [imgMutArr addObject:fBean];
            }
            else if (fBean.fileType == FILE_DIR)
            {
                NSArray *subImgArr = [self getPhosFromFileBean:fBean path:curPath];
                [imgMutArr addObjectsFromArray:subImgArr];
            }
        }
    }
    
    return imgMutArr;
}

- (NSArray *)groupPhotos:(NSArray *)phoArr
{// 照片按照日期分组
    NSMutableArray *groupMutIndexArr = [NSMutableArray array];
    NSMutableArray *groupMutArr      = [NSMutableArray array];
    
    for (FileBean *fileBean in phoArr) {
        NSString *dateStr = [self getDateStringWith:fileBean.createTime];
        
        NSInteger index = [groupMutIndexArr indexOfObject:dateStr];
        if (index == NSNotFound) {
            [groupMutIndexArr addObject:dateStr];
            
            NSMutableArray *mutArr = [NSMutableArray array];
            [mutArr addObject:fileBean];
            [groupMutArr addObject:mutArr];
        }
        else
        {
            NSMutableArray *mutArr = groupMutArr[index];
            [mutArr addObject:fileBean];
            [groupMutArr replaceObjectAtIndex:index withObject:mutArr];
        }
    }
    
    // 索引数组、对应索引的数据数组
    return [NSArray arrayWithObjects:groupMutIndexArr,groupMutArr, nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger count = 1;
    if ([self isPhotoPath]) {
        count = self.sectionArr.count;
        if (count == 0) {
            [self checkIsNeedToShowTipView:[NSNumber numberWithBool:YES]];
        }
    }
    
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
    NSUInteger count = self.uiType == Picture_UI_Type ? [self getPhotoUIRowCountBySection:section] : [self getCurrentModelArray].count;
    
    if(count == 0 && self.uiType == Picture_UI_Type){
        PhotoLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        if(cell != nil){
            [cell resetContent];
        }
    }
    
    [self checkIsNeedToShowTipView:[NSNumber numberWithBool:YES]];
    
    return count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_registerNib) {
        if (self.uiType == Document_UI_Type || self.uiType == Copy_UI_Type) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([DocumentFileCell class]) bundle:nil];
            [_tableView registerNib:nib forCellReuseIdentifier:@"DocCell"];
        }
        _registerNib = YES;
    }
    
    if (self.uiType == Picture_UI_Type) {
        static NSString *CellIdentifier = @"PhotoCell";
        PhotoLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[PhotoLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSMutableArray* tmp = [NSMutableArray array];
        NSMutableArray* selectedArr = [NSMutableArray array];
        NSInteger arrStart = indexPath.row * 4;
        if(self.sectionArr.count == 0 || indexPath.section >= self.sectionArr.count){
            return cell;
        }
        NSArray* currentArr = [self.sectionArr objectAtIndex:indexPath.section];
        for (NSInteger i = arrStart; i < arrStart + 4; i ++) {
            if (i < currentArr.count) {
                if(i >= currentArr.count){
                    return cell;
                }
                [tmp addObject:[currentArr objectAtIndex:i]];
                FileBean* bean = [currentArr objectAtIndex:i];
                NSString* key = bean.filePath;
                [selectedArr addObject:[NSNumber numberWithBool:[self itemIsSelected:key]]];
            }
        }
        cell.itemSelectDelegate = self;
        [cell setData:tmp selectedStatus:selectedArr row:indexPath.row needLoadIcon:_viewAppeared];
        [cell setEditStatus:_editType];
        //        [cell ];
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"DocCell";
        DocumentFileCell*cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSArray* currentArr = [self getCurrentModelArray];
        
        [cellArray removeObject:cell];
        [cellArray addObject:cell];
        
        if(indexPath.row >= currentArr.count){
            return cell;
        }
        FileBean* bean = [currentArr objectAtIndex:indexPath.row];
        if (self.uiType == Copy_UI_Type) {
            cell.maskView.hidden = bean.fileType == FILE_DIR;
        }
        cell.res_type = self.resType;
        
        if (isDownloadedVideoPath) {
            BOOL downlist = [self checkDocmentCellIsInDownloadingList:bean];
            cell.isInDownloadingList = downlist;
            BOOL played = NO;
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            dic = [MusicPlayerViewController instance].noplayMusicplistDict;
            if (dic.count>0) {
                played = ([dic objectForKey:bean.filePath]!= nil);
            }else{
                played = NO;
            }
            [cell setNewIdentify:played];
            if (cell.isInDownloadingList) {
                [bean resetFileSize];
                [cell setNewIdentify:NO];
            }
            
        }
        [cell setData:bean row:indexPath.row needLoadIcon:_viewAppeared];
        
        [cell setEditStatus:[self isEditing] animation:_editListAnimation isExport:(_editType == Edit_Export)];
        NSString* key = bean.filePath;
        [cell setSelectStatus:[self itemIsSelected:key]];
        cell.itemEditDelegate = self;
        return cell;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
    NSArray* currentArr = [self getCurrentModelArray];
    if(indexPath.row >= currentArr.count || _videoViewController.view.superview || _player.view.superview || _listViedeoview.view.superview){
        return;
    }
    
    if (![self isEditing]) {
        if(_cellClicked){
            return;
        }
        _cellClicked = YES;
        FileBean* bean = [[self getCurrentModelArray] objectAtIndex:indexPath.row];
        
        if (bean.fileType == FILE_DIR) {
            
            if ([bean.filePath isEqualToString:RealDownloadVideoPath]) {
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newvideodown"];
            }else if ([bean.filePath isEqualToString:RealDownloadAudioPath]){
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newmusicdown"];
            }
            else if ([bean.filePath isEqualToString:RealDownloadAudioPath]){
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newmusicdown"];
            }
            else if ([bean.filePath isEqualToString:RealDownloadPicturePath]){
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newpicturedown"];
            }
            else if ([bean.filePath isEqualToString:RealDownloadDocumentPath]){
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newdocumentdown"];
            }
            
            [_tableView  reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            _viewAppeared = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[self getCurrentPath] object:nil];
            [self gotoNextPathUI:bean.fileName uiType:self.uiType];
            [self UMengClick:@"DIR" isMenu:NO];
        }
        else if (self.uiType != Copy_UI_Type) {
            
            [self gotoFileScanView:bean];
            [[MusicPlayerViewController instance] removeNewIdentify:bean.filePath];
            [_tableView reloadData];
        }
        else {
            _cellClicked = NO;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.uiType == Picture_UI_Type ? ((screenWidth-10)/4.0 + 2) : 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isPhotoPath]) {
        return TABLE_HEADER_HEIGHT;
    }
    else{
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    if ([self isPhotoPath]) {
        NSMutableArray *array = [self.sectionArr objectAtIndex:section];
        if (array.count > 0) {
            view.frame = CGRectMake(0, 0, SCREEN_WIDTH, TABLE_HEADER_HEIGHT);
            view.backgroundColor = [UIColor whiteColor];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, view.frame.size.width - 20, view.frame.size.height)];
            label.textColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:67.0/255.0 alpha:1.0];
            
            FileBean *bean = [array objectAtIndex:0];
            NSString *currentDateStr = @"";
            if (bean.fileType == FILE_DIR) {
                currentDateStr = NSLocalizedString(@"photodirname", @"");
            }
            else
            {
                currentDateStr = [self getDateStringWith:[bean getCreateTime]];
            }
            
            label.text = currentDateStr;
            label.font = [UIFont systemFontOfSize:14.0];
            [view addSubview:label];
        }
    }
    
    return view;
}

#pragma mark UITableView About Methods

-(BOOL)isPhotoPath
{
    return (self.resType == Picture_Res_Type && self.uiType == Picture_UI_Type);
}

-(NSString *)getDateStringWith:(long)time
{
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *curDateStr = [dateFormatter stringFromDate:date];
    
    return curDateStr;
}

-(void) gotoFileScanView:(FileBean*)bean {
    
    selectbean = bean;
    
    PathBean* current = [self getCurrentPathBean];
    NSInteger index = [self getIndexInFileTypeArr:bean];
    CGFloat duration = 0.5;
    if (index >= 0) {
        
        BOOL isgoto;
        BOOL isPlay;
        isgoto = (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF);
        isPlay = (bean.fileType == FILE_VIDEO ||bean.fileType == FILE_MOV);
        
        if ([self checkDocmentCellIsInDownloadingList:bean]) {
            if (isgoto) {
                
                NSString *nowpath = [self getCurrentPath];
                if ([nowpath isEqualToString:RealDownloadPicturePath]) {
                    [CustomNotificationView showToast:NSLocalizedString(@"downloadingpicmsg", @"")];
                }
            }
            
            [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:duration];
            return;
        }
        
        if(isgoto){
            
            PathBean* current = [self getCurrentPathBean];
            
            NSMutableArray *imageArr = [NSMutableArray array];
            
            for (FileBean *bean in current.imgPathAry) {
                if (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF) {
                    [imageArr addObject:bean];
                }
            }
            
            NSMutableArray *newArray = [self dealArrayForDeleteDownloadingFileWith:RealDownloadPicturePath array:imageArr];
            
            if (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF) {
                index = [self indexFileBean:bean inArray:newArray];
            }
            
            PreviewViewController* picVC = [[PreviewViewController alloc] init];
            [picVC allPhotoArr:newArray nowNum:index fromDownList:NO];
            picVC.scanDelegate = self;
            
            [self.navigationController pushViewController:picVC animated:YES];
            if(bean.fileType == FILE_IMG){
                [self UMengClick:@"PICTURE" isMenu:NO];
            }
            else if(bean.fileType == FILE_MOV){
                [self UMengClick:@"MOV" isMenu:NO];
            }
            else if(bean.fileType == FILE_GIF){
                [self UMengClick:@"GIF" isMenu:NO];
            }
        }
        else if(isPlay){
            if(self.delegate && [self.delegate respondsToSelector:@selector(showPlayer)]){
                [self.delegate showPlayer];
            }
            _clickIndex = index;
            //当前播放视频
            _currentVideoPath = bean.filePath;
            
            [self play:bean.filePath anim:YES];
            [self UMengClick:@"VIDEO" isMenu:NO];
        }
        else if(bean.fileType == FILE_MUSIC){
            
            NSString * prepath = bean.filePath;
            
            NSMutableArray *newArray = [self dealArrayForDeleteDownloadingFileWith:RealDownloadAudioPath array:current.musicPathAry];
            
            NSString *nowpath = [self getCurrentPath];
            [FileSystem changeConfigWithKey:@"playing_dir" value:nowpath];
            
            if ([prepath hasPrefix:KE_PHOTO] || [prepath hasPrefix:KE_VIDEO] || [prepath hasPrefix:KE_MUSIC] || [prepath hasPrefix:KE_DOC] || [prepath hasPrefix:KE_ROOT]) {
                [[MusicPlayerViewController instance] setArray:newArray];
                [[MusicPlayerViewController instance] setSongPath:bean kuke:YES];
                
            }else {
                
                [[MusicPlayerViewController instance] setArray:newArray];
                [[MusicPlayerViewController instance] setSongPath:bean kuke:NO];
            }
            
            MusicPlayerViewController * newPlayView=[MusicPlayerViewController instance];
            [newPlayView setNoneMusicViewHidden:YES];
            newPlayView.scanDelegate = self;
            newPlayView.fromRoot = NO;
            _musicDisplay = _lastDisplay;
            [self.navigationController pushViewController:newPlayView animated:YES];
            duration = 2;
            
            // 发送友盟事件
            [self UMengClick:@"MUSIC" isMenu:NO];
            
        }
        else if(bean.fileType == FILE_DOC){
            
            FilePropertyBean *proportyBean = [FileSystem readFileProperty:bean.filePath];
            float size = proportyBean.size/1024.0/1024.0;
            if (size>80.0) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"pdf_cannotopen",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"") otherButtonTitles:NSLocalizedString(@"sure",@""), nil];
                alert.tag = FILE_DOC_TYPE;
                [alert show];
            }else{
                
                web=[[WebViewController alloc]init];
                web.scanDelegate=self;
                NSMutableArray *newArray = [self dealArrayForDeleteDownloadingFileWith:RealDownloadDocumentPath array:current.docPathAry];
                [web getPath:bean pathArray:newArray];
                [self.navigationController pushViewController:web animated:YES];
                [self UMengClick:@"DOCUMENT" isMenu:NO];
                
            }
        }
        else
        {
            [self UMengClick:@"OTHER" isMenu:NO];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"openunknowfileusethirdAPP", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"notto", @"") otherButtonTitles:NSLocalizedString(@"yesto", @""),nil];
        alert.tag = FILE_UNKNOW_ALERT_TAG;
        [alert show];
    }
    
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:duration];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_tableView] && self.uiType == Document_UI_Type && ![self isEditing]) {
        if (_swipeIndex >= 0) {
            DocumentFileCell* cell = (DocumentFileCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_swipeIndex inSection:0]];
            [cell setEditStatus:NO animation:YES];
            _swipeIndex = -1;
        }
    }
}

#pragma mark - PhotoItemSelectDelegate(itemEditDelegate)

-(void)itemClickedAt:(NSInteger)index selected:(BOOL)selected {
    if (index < [self getCurrentModelArray].count && !_videoViewController.view.superview && !_player.view.superview) {
        if (![self isEditing]) {
            if(_cellClicked){
                return;
            }
            _cellClicked = YES;
            FileBean* bean = [[self getCurrentModelArray] objectAtIndex:index];
            if (bean.fileType == FILE_DIR) {
                _viewAppeared = NO;
                //                [_tableView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:[self getCurrentPath] object:nil];
                NSLog(@"gotoNextPathUI");
                [self gotoNextPathUI:bean.fileName uiType:self.uiType];
                
                [self UMengClick:@"DIR" isMenu:NO];
            }
            else {
                [self gotoFileScanView:bean];
            }
        }
        else {
            FileBean* model = [[self getCurrentModelArray] objectAtIndex:index];
            NSString* key = model.filePath;
            if (selected) {
                if (![self.selectedItem objectForKey:key]) {
                    [self.selectedItem setObject:model forKey:key];
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

-(void)itemClickedAt:(NSInteger)index model:(NSObject *)bean selected:(BOOL)selected
{
    if (self.uiType == Picture_UI_Type) {
        NSInteger beanIndex = [[self getCurrentModelArray] indexOfObject:bean];
        if (beanIndex == NSNotFound && [bean isKindOfClass:[FileBean class]]) {
            beanIndex = [self getBeanIndexInArray:(FileBean*)bean];
        }
        if (beanIndex != NSNotFound) {
            [self itemClickedAt:beanIndex selected:selected];
        }
    }
    else{
        [self itemClickedAt:index selected:selected];
    }
}

-(void)deleteModel:(id)model {
    if ([self cantainsFileBean:model inArray:[self getCurrentModelArray]]) {
        
        _removeFileBean = model;
        [self doDeleteModel];
    }
}

-(void)swipeToControlDeleteBtn:(BOOL)show atRow:(NSInteger)row{
    if (show) {
        if (_swipeIndex >= 0) {
            DocumentFileCell* cell = (DocumentFileCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_swipeIndex inSection:0]];
            [cell setEditStatus:NO animation:YES];
        }
        _swipeIndex = row;
    }
    else {
        _swipeIndex = -1;
    }
}

#pragma mark PhotoItemSelectDelegate About Methods

#pragma mark -

-(NSInteger)getBeanIndexInArray:(FileBean*)bean{
    NSArray* array = [self getCurrentModelArray];
    for (NSInteger i = 0; i < array.count; i ++) {
        FileBean* beanTmp = [array objectAtIndex:i];
        if ([beanTmp.filePath isEqualToString:bean.filePath]) {
            return i;
        }
    }
    return NSNotFound;
}

-(BOOL)cantainsFileBean:(FileBean*)bean inArray:(NSArray*)array{
    for (FileBean* tmp in array) {
        if ([tmp.filePath isEqualToString:bean.filePath]) {
            return YES;
        }
    }
    return NO;
}

-(NSInteger)indexFileBean:(FileBean*)bean inArray:(NSArray*)array{
    for (NSInteger i = 0 ; i < array.count ; i ++) {
        FileBean* tmp = [array objectAtIndex:i];
        if ([tmp.filePath isEqualToString:bean.filePath]) {
            return i;
        }
    }
    return -1;
}

#pragma mark - ScanFileDelegate (WebViewController/MusicPlayerViewController/PreviewViewController's scanDelegate)

-(void)scanedItemWith:(FileBean *)item {
    
    if ([self isPhotoPath]) {
        return;
    }
    
    NSArray* array = [self getCurrentModelArray];
    if ([self cantainsFileBean:item inArray:array]) {
        NSInteger index = [self indexFileBean:item inArray:array];
        CGFloat offsetY = -1;
        if (self.uiType == Picture_UI_Type) {
            NSInteger line = index / 4;
            offsetY = line * ((SCREEN_WIDTH-10)/4.0 + 2);//self.uiType == Picture_UI_Type ? ((screenWidth-10)/4.0 + 2) : 60
        }
        else if (self.uiType == Document_UI_Type) {
            offsetY = index * 60;
        }
        offsetY = offsetY + _tableView.frame.size.height <= _tableView.contentSize.height ? offsetY : (_tableView.contentSize.height - _tableView.frame.size.height + _tableView.contentInset.bottom);
        if (offsetY >= 0) {
            _tableView.contentOffset = CGPointMake(0,offsetY-_tableView.contentInset.top);
        }
    }
}

-(void) needRemoveItemWith:(FileBean *)item {
    if (item) {
        [self.selectedItem removeAllObjects];
        NSString* key = item.filePath;
        [self.selectedItem setObject:item forKey:key];
        [self deleteModel:item];
    }
}

-(void)needCopyItemWith:(FileBean *)item {
    if (item) {
        NSString* key = item.filePath;
        [self.selectedItem setObject:item forKey:key];
        [self.operationFileArr removeAllObjects];
        for (FileBean* been in self.selectedItem.objectEnumerator) {
            [self.operationFileArr addObject:been];
        }
        _copyPath = [FileSystem getCopyPath];
        CopyMainViewController* copyUI = [[CopyMainViewController alloc] init];
        copyUI.pathDelegate = self;
        [self pushViewController:copyUI animation:YES];
        [copyUI setLastCopyPath:_copyPath];
    }
}

#pragma mark ScanFileDelegate About Methods

-(NSMutableArray *)dealArrayForDeleteDownloadingFileWith:(NSString *)path array:(NSMutableArray *)array
{
    NSString *nowpath = [self getCurrentPath];
    NSMutableArray * newArray = [NSMutableArray array];
    
    if ([nowpath isEqualToString:path]) {
        for (FileBean * bean in array) {
            if (![self checkDocmentCellIsInDownloadingList:bean]) {
                [newArray addObject:bean];
            }
        }
    }
    else{
        newArray = array;
    }
    return newArray;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == DELETE_ALERT_TAG) {
            [self deleteModelFiles];
        }
        else if (alertView.tag == DELETE_ITEM_ALERT_TAG) {
            [self doDeleteModel];
        }
        else if (alertView.tag == COPYFROMSYS_ALERT_TAG) {
            [self gotoImportPic];
        }
        else if (alertView.tag == FILE_UNKNOW_ALERT_TAG)
        {
            [self openDocumentIn:selectbean];
        }else if (alertView.tag == FILE_DOC_TYPE){
            [self openDocumentIn:selectbean];
        }
    }
    else {
        [self.operationFileArr removeAllObjects];
    }
}

#pragma mark UIAlertViewDelegate About Methods

-(void)deleteModelFiles{
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
        _operation.delegate = self;
    }
    FileBean* currentMusic = [[MusicPlayerViewController instance] getCurrentBean];
    BOOL removeNowPlay = NO;
    BOOL removeNowDir = NO;
    for (FileBean* been in self.operationFileArr) {
        if (!removeNowPlay && [currentMusic.filePath isEqualToString:been.filePath]) {
            if ([[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]) {
                removeNowPlay = YES;
                
            }
            [[MusicPlayerViewController instance] setDeleteState:YES];
            [[CustomMusicPlayer shareCustomMusicPlayer] stop];
        }
        else if(!removeNowPlay && [currentMusic.filePath rangeOfString:been.filePath].location != NSNotFound && been.fileType == FILE_DIR){
            removeNowDir = YES;
        }
        
        // 用于备份比对数据的处理
        [[Context shareInstance].keRootPhoArray removeObject:been];
        // 缓存删除
        if (been.fileType == FILE_DIR) {
            [[CustomFileManage instance] cleanPathCache:been.filePath];
        }
    }
    [_operation deleteFiles:self.operationFileArr userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"delete",@"action",
                                                            [self getCurrentPath],@"dirpath",
                                                            [NSNumber numberWithBool:removeNowPlay],@"deleteplaying",
                                                            [NSNumber numberWithBool:removeNowDir],@"deleteplayingdir",
                                                            nil]];
    
}

-(void)openDocumentIn:(FileBean *)bean{
    
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

#pragma mark -

-(void)selectMaskBtnPressed
{
    __block UIView *view = [self.view viewWithTag:100010];
    [UIView animateWithDuration:.3 animations:^{
        selectView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50);
        view.alpha = 0;
    } completion:^(BOOL finished) {
        
        [view removeFromSuperview];
        view = nil;
        [selectView removeFromSuperview];
    }];
    
}

-(void)cellClickDone {
    _cellClicked = NO;
}

#pragma mark - play video

-(void)playerItemDidReachEnd:(id)object {
    NSLog(@"");
}


-(void)play:(NSString *)path anim:(BOOL)isAnim{
    
    [[MusicPlayerViewController instance] setMovPlay:YES];
    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
        [[MusicPlayerViewController instance]playorpause];
    }
    [VideoViewController setVideoPlaying:YES];
 
    BOOL isM3u8Dir = NO;
    BOOL isM3u8DirFlv = NO;
    if ([[path pathExtension] isEqualToString:@"m3u8"]) {
        FilePropertyBean* pb = [FileSystem readFileProperty:[path stringByAppendingPathComponent:@"durations.txt"]];
        if (pb) {
            isM3u8Dir = YES;
        }
    }
    if (isM3u8Dir && !isM3u8DirFlv) {
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
        
        MPMoviePlayerController *player = [_videoViewController moviePlayer];
        player.controlStyle = MPMovieControlStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        CGFloat lasttime = 0;
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        if ([userdefault objectForKey:_currentVideoPath]) {
            NSArray * array = [userdefault objectForKey:_currentVideoPath];
            
            NSNumber *num = [NSNumber numberWithFloat:0];
            if (array && array.count>1) {
              num = [array objectAtIndex:1];
            }
            lasttime = num.floatValue;
            
        }
        [self presentViewController:_listViedeoview animated:YES completion:^{
            [_listViedeoview setVideos:theItems title:[path lastPathComponent] durations:durationArray lasttime:lasttime];
            [_listViedeoview play];
        }];
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.navigationBarHidden = YES;
    }
    else if (([VIDEO_IOS_FORMAT objectForKey:[[path pathExtension] lowercaseString]] && !isM3u8DirFlv) || ![MobClickUtils MobClickIsActive]) {
    
        
        
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
        _videoViewController = [[VideoViewController alloc] init];
        _videoViewController.delegate = self;
        
        MPMoviePlayerController *player = [_videoViewController moviePlayer];
        player.controlStyle = MPMovieControlStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [self presentViewController:_videoViewController animated:YES completion:^{
            [_videoViewController setVideo:url progress:0];
            [_videoViewController play];
        }];
        
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
            [_player.view removeFromSuperview];
            [_player removeFromParentViewController];
            _player = nil;
        }
        if (isM3u8Dir) {
            path = [@"/" stringByAppendingPathComponent:[path stringByAppendingPathComponent:[path lastPathComponent]]];
        }
        else {
            path = [@"/" stringByAppendingPathComponent:path];
        }
        
        if(!IS_TAIG){
            if([path hasPrefix:KE_PHOTO] || [path hasPrefix:KE_VIDEO] || [path hasPrefix:KE_MUSIC] || [path hasPrefix:KE_DOC] || [path hasPrefix:KE_ROOT]){
                
                path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
            }
        }
        _player = [[KxMovieViewController alloc] init];
        _player.kxBackDelegate = self;
        [self.view addSubview:_player.view];
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [_player setPath:path parameters:nil];
        [self presentViewController:_player animated:YES completion:^{
        }];
        [self performSelector:@selector(playlaststate) withObject:nil afterDelay:0.5];
    }
     [[MusicPlayerViewController instance] setMovPlay:NO];
}

-(void)playlaststate{
    
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:_currentVideoPath]) {
        NSArray * array = [userdefault objectForKey:_currentVideoPath];
        NSNumber *num = [NSNumber numberWithFloat:0];
        
        if (array && array.count>1) {
            num= [array objectAtIndex:1];
        }
        
        if ([VIDEO_IOS_FORMAT objectForKey:[[_currentVideoPath pathExtension] lowercaseString]]) {
            //MP4格式播放记录
            [_videoViewController pause];
            [[_videoViewController moviePlayer]setCurrentPlaybackTime:[num floatValue]];
            [_videoViewController valueChanged:[num floatValue]];
            [_videoViewController endChanged:[num floatValue]];
            [_videoViewController play];
            
        }else if ([[[_currentVideoPath pathExtension] lowercaseString] isEqualToString:@"m3u8"]){
            [_listViedeoview pause];
            NSLog(@"取出时间:%F",[num floatValue]);
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


-(void)stopMov{
    [CustomNotificationView showToast:NSLocalizedString(@"movplayfail", @"")];
    [self removeVideoPlayView];
    [self removeNotificationOnPlayingView];
}


//重返app，增加视频播放完成通知

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [_videoViewController play];
    [self performSelector:@selector(sertime) withObject:nil afterDelay:0];
}
-(void)sertime{
    [[_videoViewController moviePlayer]setCurrentPlaybackTime:self.appOutPlayTime];
    [_videoViewController valueChanged:self.appOutPlayTime];
    [_videoViewController endChanged:self.appOutPlayTime];
    [_videoViewController pause];
}
//按完home键之后，移除播放完成通知
- (void) applicationWillResignActive: (NSNotification *)notification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.appOutPlayTime = [_videoViewController moviePlayer].currentPlaybackTime;

}

- (void)FinishedCallback:(NSNotification *)notify{
    [self removeMPmovie];
    [self videoPlayEnd:notify];
}

-(void)videoPlayEnd:(NSNotification *)notify {
    [FileSystem rotateWindow:NO];
    
    if ([_videoViewController moviePlayer] == [notify object]) {
        [self removeVideoPlayView];
        
    }
    
    if (_listViedeoview.myQueuePlayer == [notify object]) {
        [self removeListVideoPlayView];
        
    }
    [self removeNotificationOnPlayingView];
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
    [_videoViewController stopTikTimer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [_videoViewController dismissViewControllerAnimated:YES completion:^{
        _videoViewController = nil;
    }];
}

-(void)removeListVideoPlayView
{
    [ListVideoViewController setVideoPlaying:NO];
    [_listViedeoview stop];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [FileSystem clearKeVideoURL];
    [_listViedeoview dismissViewControllerAnimated:YES completion:^{
        _listViedeoview = nil;
    }];
}


-(BOOL)playForward{
    
     PathBean* current = [self getCurrentPathBean];
    if(current.videoPathAry.count > 1){
        if(current.videoPathAry.count  > _clickIndex + 1){
            
            ++_clickIndex;
        }else{
            
            _clickIndex = 0;
        }
        
        FileBean *bean = [current.videoPathAry objectAtIndex:_clickIndex];
        [self play:bean.filePath anim:NO];
        
        return YES;
    }else{
        
        return NO;
    }
}

-(BOOL)playRewind{
    
     PathBean* current = [self getCurrentPathBean];
    if(current.videoPathAry.count > 1){
        
        if(_clickIndex > 0){
            
            --_clickIndex;
        }else{
            
            _clickIndex = current.videoPathAry.count - 1;
        }
        
        FileBean *bean = [current.videoPathAry objectAtIndex:_clickIndex];
        [self play:bean.filePath anim:NO];
        
        
        return YES;
    }else{
        
        return NO;
    }
}

-(void)playEnd{
    
//    BOOL need = [self playForward];
//    if (!need) {
//        [_player self_dealloc];
//        [_player removeFromParentViewController];
//        _player = nil;
//    }
    [self clickBackBtn];
}
extern int getIsNeedLongCDs();
extern float Get_Max_CD();
-(void)saveVideoMemory:(float)time totalTime:(float)totaltime{
  
    if (totaltime-time<10.0) {
        if (getIsNeedLongCDs())
        {
            time = 0.0;
        }
        
    }
     NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *oneDayStr = [dateFormatter stringFromDate:date];
    NSArray * array = [[NSArray alloc]initWithObjects:oneDayStr,[NSNumber numberWithFloat:time],[NSNumber numberWithFloat:totaltime], nil];
    [userdefault setObject:array forKey:_currentVideoPath];

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
//            [_player.view removeFromSuperview];
//            [_player removeFromParentViewController];
            _player = nil;
        }
    }];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        _player.view.frame = CGRectMake(0,
//                                        [UIScreen mainScreen].bounds.size.height,
//                                        [UIScreen mainScreen].bounds.size.width,
//                                        [UIScreen mainScreen].bounds.size.height);
//    } completion:^(BOOL finished) {
//        
//        if(_player){
//            
//            [_player self_dealloc];
//            [_player.view removeFromSuperview];
//            [_player removeFromParentViewController];
//            _player = nil;
//        }
//    }];
}

- (void) playError:(NSError *)error{
    
    [self clickBackBtn];
}

#pragma mark -


-(UIView*)applicationRootView{
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

-(CGRect)getItemFrameInPictureUI:(NSInteger)index {
    NSInteger row = index / 4;
    NSInteger col = index % 4;
    CGFloat cellHeight = ((SCREEN_WIDTH-10)/4.0 + 2);
    CGFloat offsetY = (cellHeight)* row + _tableView.frame.origin.y - _tableView.contentOffset.y + 2.5f;
    CGFloat offsetX = col * cellHeight;
    
    return CGRectMake(offsetX, offsetY, (SCREEN_WIDTH-10)/4.0, (SCREEN_WIDTH-10)/4.0);
}

-(void)gotoNextPathUI:(NSString*)dirName uiType:(int)uiTypeTmp{
    NSLog(@"gotoNextPathUI");
    FileViewController* copyUI = [[FileViewController alloc] init];
    copyUI.uiType = uiTypeTmp;
    copyUI.titleStr = dirName;
    copyUI.resType = self.resType;
    copyUI.subCopyPath = self.subCopyPath ? [self.subCopyPath stringByAppendingPathComponent:copyUI.titleStr] : [[self getRootDirPath] stringByAppendingPathComponent:copyUI.titleStr];
    if([copyUI.subCopyPath isEqualToString:RealDownloadVideoPath]){
        [MobClickUtils event:@"DOWNLOAD_FOLDER_CLICK" label:@"下载的视频"];
        [[CustomFileManage instance] cleanPathCache:RealDownloadVideoPath];
    }
    else if ([copyUI.subCopyPath isEqualToString:RealDownloadAudioPath]){
        [MobClickUtils event:@"DOWNLOAD_FOLDER_CLICK" label:@"下载的音乐"];
        [[CustomFileManage instance] cleanPathCache:RealDownloadAudioPath];
    }
    else if ([copyUI.subCopyPath isEqualToString:RealDownloadPicturePath]){
        [MobClickUtils event:@"DOWNLOAD_FOLDER_CLICK" label:@"下载的图片"];
        [[CustomFileManage instance] cleanPathCache:RealDownloadPicturePath];
    }
    else if ([copyUI.subCopyPath isEqualToString:RealDownloadDocumentPath]){
        [MobClickUtils event:@"DOWNLOAD_FOLDER_CLICK" label:@"下载的文档"];
        [[CustomFileManage instance] cleanPathCache:RealDownloadDocumentPath];
    }
//    NSLog(@"self.rootStr : %@",self.rootStr);
    copyUI.rootStr = self.rootStr ? self.rootStr : _customNavigationBar.title.text;
    copyUI.fromDisplay = self.isTypeUIRoot ? _lastDisplay : self.fromDisplay;
    if (uiTypeTmp == Copy_UI_Type) {
        copyUI.pathDelegate = self.pathDelegate ? self.pathDelegate : self;
        if (self.pathDelegate) {
            [self.pathDelegate pushViewController:copyUI animation:YES];
        }
        else {
            [self pushViewController:copyUI animation:YES];
        }
    }
    else {
        [self.navigationController pushViewController:copyUI animated:YES];
    }
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}


-(void)gotoBeforePathUI {
    if (self.isTypeUIRoot) {
        [self.pathDelegate popToRootViewController];
    }
    else {
        [self.pathDelegate popViewController];
    }
}

-(void)setSelectAll:(BOOL)selected{
    if (selected) {
        NSArray* current = [self getCurrentModelArray];
        for (NSInteger i = 0; i < current.count; i ++) {
            FileBean* model = [current objectAtIndex:i];
            NSString* key = model.filePath;
            if (_isExportEditing) {
                if (model.fileType == FILE_IMG || model.fileType == FILE_GIF || model.fileType == FILE_MOV ) {
                    if (![self.selectedItem objectForKey:key]) {
                        [self.selectedItem setObject:model forKey:key];
                    }
                }
            }
            else {
                if (![self.selectedItem objectForKey:key]) {
                    [self.selectedItem setObject:model forKey:key];
                }
            }
            
        }
    }
    else {
        [self.selectedItem removeAllObjects];
    }
    [self changeTitle];
    [_tableView reloadData];
}


-(void)choicedPathAt:(NSString *)path {
    
//    NSLog(@"choicedPathAt : %@ , Arr : %@",path,self.operationFileArr);
    _copyPath = path;
    [FileSystem changeCopyPathConfig:_copyPath];
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
    }
    _operation.delegate = self;
    
    NSString *copyfrompath = [self getCurrentPath];
    if ([CustomFileManage isDownloadedDir:copyfrompath]) {
        NSMutableArray *copyarr = [NSMutableArray array];
        for (FileBean *bean in self.operationFileArr) {
            if (![self checkDocmentCellIsInDownloadingList:bean]) {
                [copyarr addObject:bean];
            }
        }
        self.operationFileArr = copyarr;
    }
    
    [_operation copyFiles:self.operationFileArr toPath:path userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"copy",@"action",path,@"path", nil]];
}

-(void)fileActionResult:(BOOL)result userInfo:(NSDictionary*)info {
    if(!result){
        return;
    }
    NSString* action = [info objectForKey:@"action"];
    if ([action isEqualToString:@"delete"]) {
        [FileSystem createDirIfNotExist];
        [self.selectedItem removeAllObjects];
        [self.operationFileArr removeAllObjects];
        if (_loadingView) {
            [_loadingView dismiss];
            _loadingView = nil;
        }
        _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
        if ([self checkIsShowDataSync]) {
            [_loadingView performSelector:@selector(show) withObject:nil afterDelay:.05];
        }
        
         NSString* dirPath = [info objectForKey:@"dirpath"];
        if ([dirPath isEqualToString:KE_ROOT] || [dirPath isEqualToString:APP_DOC_ROOT]) {
            [LogUtils writeLog:@"DELETE ROOT"];
            [[CustomFileManage instance] cleanPathCacheAll];
        }
        [self performSelector:@selector(processDeleteAction:) withObject:info afterDelay:.1];
        NSString* path = [self getCurrentPath];
        NSDictionary* actionInfo = [NSDictionary dictionaryWithObjectsAndKeys:dirPath,@"path",path,@"currentpath",@"delete",@"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_DONE object:actionInfo];
    }
    else if ([action isEqualToString:@"copy"]) {
        if (self != self.navigationController.topViewController) {
            [self.selectedItem removeAllObjects];
            [self.operationFileArr removeAllObjects];
        }
        NSDictionary* actionInfo = [NSDictionary dictionaryWithObjectsAndKeys:_copyPath,@"path",@"copy",@"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_DONE object:actionInfo];
//        [self readData:YES];
    }
    NSLog(@"fileActionResult:: result : %d , info : %@",result,info);
}

-(void)processDeleteAction:(NSDictionary*)info{
    [[CustomFileManage instance] setKukeDeleteFileCache:YES];
    [self reloadCurrentData];
    [self changeTitle];
    [self refreshLeftMenuTitle];
    [self refreshRightMenuTitle];
    UIViewController* vc = self.navigationController.topViewController;
    NSNumber* removeNowPlay = [info objectForKey:@"deleteplaying"];
    NSNumber* deleteplayingdir = [info objectForKey:@"deleteplayingdir"];
    FileBean* currentMusic = [[MusicPlayerViewController instance] getCurrentBean];
    NSString* currentMusicRoot = [currentMusic.filePath stringByDeletingLastPathComponent];
    if ([currentMusicRoot isEqualToString:[self getCurrentPath]]){
        [[MusicPlayerViewController instance] deletefinishrefresh:[self getCurrentPathBean].musicPathAry deletenowplay:removeNowPlay.boolValue];
    }
    else if(deleteplayingdir.boolValue){
        [[MusicPlayerViewController instance] deletefinishrefresh:[NSArray array] deletenowplay:YES];
    }
    if ([vc isKindOfClass:[PreviewViewController class]]) {
        [((PreviewViewController*)vc) removeOverReloadArray:[self getCurrentPathBean].imgPathAry];
    }
    else if ([vc isKindOfClass:[WebViewController class]]){
        [((WebViewController*)vc) getPath:nil pathArray:[self getCurrentPathBean].docPathAry];
    }
    [_loadingView dismiss];
}

-(void)actionResult:(BOOL)result userInfo:(id)info {
    if(!result){
        return;
    }
    NSString* action = [info objectForKey:@"action"];
    if (result && [action isEqualToString:@"import"]) {
//        [self reloadCurrentData];
//        [self refreshRightMenuTitle];
//        [self refreshLeftMenuTitle];
        NSDictionary* copyInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self getCurrentPath],@"path", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_DONE object:copyInfo];
    }
}

-(void)importPhoto:(NSArray *)copyArr type:(typeCode)mediaType{
    if (copyArr.count > 0 && self.navigationController.topViewController == self) {
        if (!_importOperation) {
            _importOperation = [[PhotoOperate alloc] init];
            _importOperation.delegate = self;
        }
        NSString* importPath = [self getCurrentPath];
        [CustomAlertView instance].alertType = Alert_PhotoIn;
        [_importOperation copyPhotos:copyArr toPath:importPath userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"import",@"action", [NSNumber numberWithInt:mediaType],@"importType",nil]];
    }
}

-(void)pushViewController:(UIViewController*)vc animation:(BOOL)need{
//    if (!_VCArr) {
//        _VCArr = [[NSMutableArray alloc] init];
//    }
//    [_VCArr addObject:vc];
//    vc.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
//    [self.view addSubview:vc.view];
//    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        vc.view.frame = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
//    } completion:^(BOOL finished) {
//    }];
    if (!_customNavigationVC) {
        _customNavigationVC = [[CustomNavigationController alloc] initWithRootViewController:vc];
        _customNavigationVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _customNavigationVC.edgesForExtendedLayout = UIRectEdgeNone;
        _customNavigationVC.navigationBarHidden = YES;
        _customNavigationVC.view.tag = 1001;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_customNavigationVC animated:need completion:^{
            
        }];
    }
    else {
        [_customNavigationVC pushViewController:vc animated:need];
    }
}

-(void)uichangeFrom:(UIViewController*)vc1 to:(UIViewController*)vc2 {
    
//    [_VCArr addObject:vc2];
//    vc2.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
//    [self.view addSubview:vc2.view];
//    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        vc2.view.frame = CGRectMake(0, 0, vc2.view.frame.size.width, vc2.view.frame.size.height);
//        vc1.view.frame = CGRectMake(0, vc1.view.frame.size.height, vc1.view.frame.size.width, vc1.view.frame.size.height);
//    } completion:^(BOOL finished) {
//        [vc1.view removeFromSuperview];
//        [_VCArr removeObject:vc1];
//    }];
}

-(void)popViewController {
    [_customNavigationVC popViewControllerAnimated:YES];
}

-(void)popToRootViewController{
    [_customNavigationVC popToRootViewControllerAnimated:YES];
}
-(void)dismissViewController:(UIViewController *)vc {
    
//    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        vc.view.frame = CGRectMake(0, vc.view.frame.size.height, vc.view.frame.size.width, vc.view.frame.size.height);
//    } completion:^(BOOL finished) {
//        [vc.view removeFromSuperview];
//        [_VCArr removeObject:vc];
//    }];
    [_customNavigationVC dismissViewControllerAnimated:YES completion:^{
        _customNavigationVC = nil;
    }];
}

-(void)deleteplayidentify:(NSArray *)array{
    for (int i=0; i<array.count; i++) {
        FileBean * bean = [array objectAtIndex:i];
        [[MusicPlayerViewController instance]removeNewIdentify:bean.filePath];
        
    }
    
}

-(BOOL)itemIsSelected:(NSString*)key {
    return [self.selectedItem objectForKey:key] != nil;
}

-(void)countDeleteModels{
    [self.operationFileArr removeAllObjects];
    for (FileBean* been in self.selectedItem.objectEnumerator) {
        [self.operationFileArr addObject:been];
    }
}

-(void)delayReadDataWithLoading{
    [self performSelector:@selector(readDataWithLoading) withObject:nil afterDelay:0.01];
}

-(void)readDataWithLoading{
    [self readData:YES];
}

-(void)delayReadDataWithNOLoading:(NSNumber*)removeNowPlaying{
    [self performSelector:@selector(readDataWithNOLoading:) withObject:removeNowPlaying afterDelay:0.01];
}

-(void)readDataWithNOLoading:(NSNumber*)removeNowPlaying{
    [self readData:NO];
    FileBean* currentMusic = [[MusicPlayerViewController instance] getCurrentBean];
    NSString* currentMusicRoot = [currentMusic.filePath stringByDeletingLastPathComponent];
    if (removeNowPlaying != nil && [currentMusicRoot isEqualToString:[self getCurrentPath]]) {
        [[MusicPlayerViewController instance] deletefinishrefresh:[self getCurrentPathBean].musicPathAry deletenowplay:removeNowPlaying.boolValue];
    }
}

-(void)checkAndChangeTab{
    if (_lastDisplay == LEFT_TAG && [FileSystem isConnectedKE]) {
        [self changeTabMenuClick:_topView.rightBtn];
    }
}

-(void)removeSectionArrayAllObjects
{
    for (NSMutableArray *arr in self.sectionArr) {
        [arr removeAllObjects];
    }
    [self.sectionArr removeAllObjects];
}

-(void)readData:(BOOL)showloading{
    if (showloading && !_loadingView) {
        _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
        
        if ([self checkIsShowDataSync]) {
            [_loadingView show];
            if(![CustomFileManage isDownloadedDir:self.subCopyPath]){
                _loadingView.alpha = 0;
                [self performSelector:@selector(delayShowLoadingView) withObject:nil afterDelay:.5];
            }
        }
    }
    
    [NSThread detachNewThreadSelector:@selector(doLoadData) toTarget:self withObject:nil];
}

-(void)delayShowLoadingView{
    if (_loadingView.superview) {
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _loadingView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)doLoadData{
    
    if (self.isTypeUIRoot) {
        NSInteger idx = 1;
        NSString* iPhonePath = nil;
        NSString* kePath = nil;
        if (self.resType == Picture_Res_Type) {
            iPhonePath = PHONE_PHOTO;
            kePath = KE_PHOTO;
            idx = 1;
        }
        else if (self.resType == Video_Res_Type) {
            iPhonePath = PHONE_VIDEO;
            kePath = KE_VIDEO;
            idx = 2;
        }
        else if (self.resType == Music_Res_Type) {
            iPhonePath = PHONE_MUSIC;
            kePath = KE_MUSIC;
            idx = 3;
        }
        else if (self.resType == Document_Res_Type) {
            iPhonePath = PHONE_DOC;
            kePath = KE_DOC;
            idx = 4;
        }
        else if (self.resType == Root_Res_Type) {
            iPhonePath = APP_DOC_ROOT;
            kePath = KE_ROOT;
            idx = 4;
        }
        
        if(![FileSystem isConnectedKE]){
            [[CustomFileManage instance] cleanPathCache:iPhonePath];
            _pathBean = [[CustomFileManage instance] getFiles:iPhonePath fromPhotoRoot:self.resType == Picture_Res_Type];
            if (self.resType == Picture_Res_Type) {
                [self doSort:_pathBean byShotTime:YES];
            }
        }
        else {
            _pathBean = nil;
        }
        
        if([FileSystem checkInit]) {
            if(![FileSystem isConnectedKE]){
                [[CustomFileManage instance] cleanPathCache:kePath];
            }
            _kePathBean = [[CustomFileManage instance] getFiles:kePath fromPhotoRoot:self.resType == Picture_Res_Type];
            if (self.resType == Picture_Res_Type) {
                [self doSort:_kePathBean byShotTime:YES];
            }
        }
        else{
            _kePathBean = nil;
        }
        _needReloadData = NO;
        
        if (_pathBean){
            NSArray* tmp = [NSArray arrayWithObjects:_pathBean.dirPathAry,_pathBean.imgPathAry,_pathBean.videoPathAry,_pathBean.musicPathAry,_pathBean.docPathAry,_pathBean.nonePathAry, nil];
            [[self.modelArr objectAtIndex:0] removeAllObjects];
            [[self.modelArr objectAtIndex:0] addObjectsFromArray:[self getDetailArr:tmp withIndex:idx]];
        }
        else
        {
            [self removeSectionArrayAllObjects];
            [[self.modelArr objectAtIndex:0] removeAllObjects];
        }
        
        if (_kePathBean) {
            NSArray* tmp = [NSArray arrayWithObjects:_kePathBean.dirPathAry,_kePathBean.imgPathAry,_kePathBean.videoPathAry,_kePathBean.musicPathAry,_kePathBean.docPathAry,_kePathBean.nonePathAry, nil];
            [[self.modelArr objectAtIndex:1] removeAllObjects];
            [[self.modelArr objectAtIndex:1] addObjectsFromArray:[self getDetailArr:tmp withIndex:idx]];
        }
        else {
            if (!_pathBean) {
                [self removeSectionArrayAllObjects];
            }
            [[self.modelArr objectAtIndex:1] removeAllObjects];
        }
        [self performSelectorOnMainThread:@selector(loadingDoneDelay) withObject:nil waitUntilDone:NO];
    }
    else
    {
        if(![FileSystem isConnectedKE]){
            [[CustomFileManage instance] cleanPathCache:self.subCopyPath];
        }
        _pathBean = [[CustomFileManage instance] getFiles:self.subCopyPath fromPhotoRoot:(self.resType == Picture_Res_Type && [_rootStr isEqualToString:NSLocalizedString(@"picture", nil)])];
        _needReloadData = NO;
        if (self.resType == Picture_Res_Type) {
            if ([_rootStr isEqualToString:NSLocalizedString(@"picture", nil)]) {
                [self doSort:_pathBean byShotTime:YES];
            }
        }
        else if (self.resType == Root_Res_Type){
            if ([_rootStr isEqualToString:NSLocalizedString(@"rootPath", nil)]) {
                [self doSort:_pathBean byShotTime:NO];
            }
        }
        NSInteger idx = 1;
        if (self.resType == Picture_Res_Type) {
            idx = 1;
        }
        else if (self.resType == Video_Res_Type) {
            idx = 2;
        }
        else if (self.resType == Music_Res_Type) {
            idx = 3;
        }
        else if (self.resType == Document_Res_Type) {
            idx = 4;
        }
        else if (self.resType == Root_Res_Type) {
            idx = 4;
        }
        if (_pathBean) {
            NSArray* tmp = [NSArray arrayWithObjects:_pathBean.dirPathAry,_pathBean.imgPathAry,_pathBean.videoPathAry,_pathBean.musicPathAry,_pathBean.docPathAry,_pathBean.nonePathAry, nil];
            [[self.modelArr objectAtIndex:0] removeAllObjects];
            [[self.modelArr objectAtIndex:0] addObjectsFromArray:[self getDetailArr:tmp withIndex:idx]];
        }
        else
        {
            [self removeSectionArrayAllObjects];
            [[self.modelArr objectAtIndex:0] removeAllObjects];
        }
        
        [self performSelectorOnMainThread:@selector(loadingDoneDelay) withObject:nil waitUntilDone:NO];
    }
    
    if (_isTypeUIRoot && _uiType==Picture_UI_Type) {
        [Context shareInstance].keRootPhoArray = [FileSystem isConnectedKE]?_modelArr[1]:_modelArr[0];
    }
}

-(void)doSort:(PathBean *)pathbean byShotTime:(BOOL)isbyshottime
{
    [self doSortWith:pathbean.imgPathAry byShotTime:isbyshottime];
}

-(void)doSortWith:(NSMutableArray *)array byShotTime:(BOOL)isbyshottime
{
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        FileBean *bean1 = obj1;
        FileBean *bean2 = obj2;
        
        if (isbyshottime) {
            return [bean1 getCreateTime] < [bean2 getCreateTime];
        }
        else{
            return [bean1 getFileDate] < [bean2 getFileDate];
        }
    }];
}

-(void)readKEData{
    PathBean* tmp = nil;
    NSInteger idx = 1;
    NSString* kePath = nil;
    if (self.resType == Picture_Res_Type) {
        kePath = KE_PHOTO;
        idx = 1;
    }
    else if (self.resType == Video_Res_Type) {
        kePath = KE_VIDEO;
        idx = 2;
    }
    else if (self.resType == Music_Res_Type) {
        kePath = KE_MUSIC;
        idx = 3;
    }
    else if (self.resType == Document_Res_Type) {
        kePath = KE_DOC;
        idx = 4;
    }
    else if (self.resType == Root_Res_Type) {
        kePath = KE_ROOT;
        idx = 4;
    }
    if(![FileSystem isConnectedKE]){
        [[CustomFileManage instance] cleanPathCache:kePath];
    }
    tmp = [[CustomFileManage instance] getFiles:kePath fromPhotoRoot:(self.resType == Picture_Res_Type && [_rootStr isEqualToString:NSLocalizedString(@"picture", nil)])];
    _needReloadData = NO;
    if (tmp) {
        if (self.resType == Picture_Res_Type) {
            if ([_rootStr isEqualToString:NSLocalizedString(@"picture", nil)]) {
                [self doSort:tmp byShotTime:YES];
            }
        }
        else if (self.resType == Root_Res_Type){
            if ([_rootStr isEqualToString:NSLocalizedString(@"rootPath", nil)]) {
                [self doSort:tmp byShotTime:NO];
            }
        }
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:tmp,@"bean",[NSNumber numberWithInteger:idx],@"idx", nil];
        [self performSelectorOnMainThread:@selector(readKEDataDone:) withObject:dict waitUntilDone:YES];
    }
    else {
        [self removeSectionArrayAllObjects];
        [[self.modelArr objectAtIndex:1] removeAllObjects];
        [self performSelectorOnMainThread:@selector(loadingDoneDelay) withObject:nil waitUntilDone:NO];
    }
}


-(void)readKEDataDone:(NSDictionary*)info{
    _kePathBean = [info objectForKey:@"bean"];
    NSInteger idx = ((NSNumber*)[info objectForKey:@"idx"]).integerValue;
    NSArray* tmp = [NSArray arrayWithObjects:_kePathBean.dirPathAry,_kePathBean.imgPathAry,_kePathBean.videoPathAry,_kePathBean.musicPathAry,_kePathBean.docPathAry,_kePathBean.nonePathAry, nil];
    [[self.modelArr objectAtIndex:1] removeAllObjects];
    [[self.modelArr objectAtIndex:1] addObjectsFromArray:[self getDetailArr:tmp withIndex:idx]];
    [self refreshRightMenuTitle];
    [self loadingDoneDelay];
}

-(void)showTimeOutAlert{
    if (IS_DEBUG) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取文件目录超时"
                                                           delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)reloadCurrentData{
    NSString* path = [self getCurrentPath];
    if(![FileSystem isConnectedKE]){
        [[CustomFileManage instance] cleanPathCache:path];
    }
    PathBean* bean = [[CustomFileManage instance] getFiles:path fromPhotoRoot:(self.resType == Picture_Res_Type && [_rootStr isEqualToString:NSLocalizedString(@"picture", nil)])];
    if (!bean) {
        bean = [[CustomFileManage instance] getFiles:path fromPhotoRoot:(self.resType == Picture_Res_Type && [_rootStr isEqualToString:NSLocalizedString(@"picture", nil)])];
        
    }
    _needReloadData = NO;
    if (bean) {
        if (self.resType == Picture_Res_Type) {
            [self doSort:bean byShotTime:YES];
        }
        else if (self.resType == Root_Res_Type){
            if ([_rootStr isEqualToString:NSLocalizedString(@"rootPath", nil)]) {
                [self doSort:bean byShotTime:NO];
            }
        }
        
        NSInteger idx = 1;
        if (self.resType == Picture_Res_Type) {
            idx = 1;
        }
        else if (self.resType == Video_Res_Type) {
            idx = 2;
        }
        else if (self.resType == Music_Res_Type) {
            idx = 3;
        }
        else if (self.resType == Document_Res_Type) {
            idx = 4;
        }
        else if (self.resType == Root_Res_Type) {
            idx = 4;
        }
        if (_lastDisplay == LEFT_TAG) {
            _pathBean = bean;
            NSArray* tmp = [NSArray arrayWithObjects:_pathBean.dirPathAry,_pathBean.imgPathAry,_pathBean.videoPathAry,_pathBean.musicPathAry,_pathBean.docPathAry,_pathBean.nonePathAry, nil];
            [self.modelArr replaceObjectAtIndex:0 withObject:[self getDetailArr:tmp withIndex:idx]];
        }
        else {
            _kePathBean = bean;
            NSArray* tmp = [NSArray arrayWithObjects:_kePathBean.dirPathAry,_kePathBean.imgPathAry,_kePathBean.videoPathAry,_kePathBean.musicPathAry,_kePathBean.docPathAry,_kePathBean.nonePathAry, nil];
            [self.modelArr replaceObjectAtIndex:1 withObject:[self getDetailArr:tmp withIndex:idx]];
        }
    }
    else {
        [self removeSectionArrayAllObjects];
        if (_lastDisplay == LEFT_TAG) {
            [[self.modelArr objectAtIndex:0] removeAllObjects];
        }
        else {
            [[self.modelArr objectAtIndex:1] removeAllObjects];
        }
    }
    
    // 图片对比获取壳图片
    if (_isTypeUIRoot && _uiType==Picture_UI_Type) {
        [Context shareInstance].keRootPhoArray = [FileSystem isConnectedKE]?_modelArr[1]:_modelArr[0];
    }
    
    [self performSelectorOnMainThread:@selector(loadingDoneDelay) withObject:nil waitUntilDone:NO];
}


-(NSInteger)getPhotoUIRowCount{
    
    return [self getCurrentModelArray].count / 4 + ([self getCurrentModelArray].count % 4 > 0 ? 1 : 0);
}

-(NSInteger)getPhotoUIRowCountBySection:(NSInteger)section{
    NSMutableArray *array  = self.sectionArr;
    if (array.count > 0 && section < array.count) {
        NSMutableArray *rowArr = [array objectAtIndex:section];
        return rowArr.count / 4 + (rowArr.count % 4 > 0 ? 1 : 0);
    }
    else{
        return 0;
    }
}

-(BOOL)compareDate:(long)date1 date:(long)date2
{
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    if (
        (int)((date1 + timezoneFix)/(24*3600)) -
        (int)((date2 + timezoneFix)/(24*3600))
        == 0)
    {
        return YES;
    }
    else{
        return NO;
    }
}

-(NSArray*)getDetailArr:(NSArray*)typeArr withIndex:(NSInteger)index {
    NSMutableArray* tmp = [NSMutableArray array];
    
    for (NSMutableArray* arr in _sectionArr) {
        [arr removeAllObjects];
    }
    [_sectionArr removeAllObjects];
    if ([self isPhotoPath]) {
        
        if (typeArr && typeArr.count >0) {
            NSMutableArray *dirarr = [typeArr objectAtIndex:0];
            [tmp addObjectsFromArray:dirarr];
            if (dirarr.count > 0) {
                [self.sectionArr addObject:[NSMutableArray arrayWithArray:dirarr]];
            }
        }
        
        NSMutableArray *fileArray = [NSMutableArray array];
        for (NSInteger i = 1; i < typeArr.count; i ++) {
            [fileArray addObjectsFromArray:[typeArr objectAtIndex:i]];
        }
        
        NSMutableArray *resultArray = [NSMutableArray array];
        if (fileArray.count > 0) {
            [self doSortWith:fileArray byShotTime:YES];
            [tmp addObjectsFromArray:fileArray];
            for (int i = 0; i< fileArray.count; i++) {
                FileBean *bean = [fileArray objectAtIndex:i];
                
                if (resultArray.count == 0) {
                    [resultArray addObject:[NSMutableArray arrayWithObject:bean]];
                }
                else{
                    NSMutableArray *lastarr = [resultArray lastObject];
                    if (lastarr.count > 0) {
                        FileBean *exbean = [lastarr objectAtIndex:0];
                        NSString *beandateStr = [self getDateStringWith:[bean getCreateTime]];
                        NSString *exbeandateStr = [self getDateStringWith:[exbean getCreateTime]];
                        BOOL issameday = [beandateStr isEqualToString:exbeandateStr];
                        if (issameday) {
                            [lastarr addObject:bean];
                        }
                        else{
                            [resultArray addObject:[NSMutableArray arrayWithObject:bean]];
                        }
                    }
                    else{
                        [resultArray addObject:[NSMutableArray arrayWithObject:bean]];
                    }
                }
            }
            
            [self.sectionArr addObjectsFromArray:resultArray];
        }
        
    }
    else{
        if (typeArr && typeArr.count >0) {
            [tmp addObjectsFromArray:[typeArr objectAtIndex:0]];
        }
        if (typeArr && typeArr.count >0 && index < typeArr.count) {
            [tmp addObjectsFromArray:[typeArr objectAtIndex:index]];
        }
        for (NSInteger i = 1; i < typeArr.count; i ++) {
            if (i != index) {
                [tmp addObjectsFromArray:[typeArr objectAtIndex:i]];
            }
        }
    }
    
    return tmp;
}

-(NSString*)getRootDirPath {
    return self.isTypeUIRoot ? [self getRootDirPathWith:_lastDisplay] : [self getRootDirPathWith:self.fromDisplay] ;//fromDisplay
}

-(NSString*)getRootDirPathWith:(NSInteger)display {
    if (self.resType == Picture_Res_Type) {
        if (display == LEFT_TAG) {
            return PHONE_PHOTO;
        }
        else {
            return KE_PHOTO;
        }
    }
    else if (self.resType == Video_Res_Type) {
        if (display == LEFT_TAG) {
            return PHONE_VIDEO;
        }
        else {
            return KE_VIDEO;
        }
    }
    else if (self.resType == Music_Res_Type) {
        if (display == LEFT_TAG) {
            return PHONE_MUSIC;
        }
        else {
            return KE_MUSIC;
        }
    }
    else if (self.resType == Document_Res_Type) {
        if (display == LEFT_TAG) {
            return PHONE_DOC;
        }
        else {
            return KE_DOC;
        }
    }
    else if (self.resType == Root_Res_Type) {
        if (display == LEFT_TAG) {
            return APP_DOC_ROOT;
        }
        else {
            return KE_ROOT;
        }
    }
    return nil;
}

-(NSString*)getCurrentPath{
    return self.subCopyPath ? self.subCopyPath : [self getRootDirPath];
}


-(NSMutableArray*)getCurrentModelArray{
    return [self.modelArr objectAtIndex:(_lastDisplay == LEFT_TAG ? 0 : 1)];
}

-(PathBean*)getCurrentPathBean{
    return _lastDisplay == LEFT_TAG ? _pathBean : _kePathBean;
}

-(NSInteger)getIntegerInFileArr:(FileBean*)bean{
    return [self indexFileBean:bean inArray:[self getCurrentModelArray]];
}

-(NSInteger)getIndexInFileTypeArr:(FileBean*)bean{
    PathBean* current = [self getCurrentPathBean];
    if (bean.fileType == FILE_IMG || bean.fileType == FILE_GIF) {
        return [self indexFileBean:bean inArray:current.imgPathAry];
    }
    else if (bean.fileType == FILE_VIDEO || bean.fileType == FILE_MOV) {
        return [self indexFileBean:bean inArray:current.videoPathAry];
    }
    else if (bean.fileType == FILE_MUSIC) {
        return [self indexFileBean:bean inArray:current.musicPathAry];
    }
    else if (bean.fileType == FILE_DOC) {
        return [self indexFileBean:bean inArray:current.docPathAry];
    }
    return -1;
}

-(BOOL)isEditing{
    return  _editType != Edit_None;
}

#pragma mark - button action

- (void)discriptionButtonClick:(id)sender
{
    PrivateViewController* aboutVC = [[PrivateViewController alloc] initWithNibName:@"PrivateViewController" bundle:nil];
    aboutVC.discType = DiscriptionTypeKUKEDisc;
    [self.navigationController pushViewController:aboutVC animated:YES];
}

#pragma mark - device off tip

-(void)checkIsNeedToShowTipView:(NSNumber *)ischeckContanierViewExists
{
    NSUInteger count = self.uiType == Picture_UI_Type ? [self getPhotoUIRowCount] : [self getCurrentModelArray].count;
    BOOL isShow = NO;
    isShow = (([FileSystem isConnectedKE] || !FOR_STORE) && ![FileSystem checkInit] && (count == 0));
    
    if (isShow) {
        if (!FOR_STORE) {
            [self setBottomViewHidden:YES animated:NO];
        }
        if (ischeckContanierViewExists.boolValue && _linkKukeContanierView) {
            return;
        }
        if (_linkKukeContanierView == nil) {
            _linkKukeContanierView = [[UIView alloc] init];
        }
        if (_linkKeTimer == nil) {
            _linkKeTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(addTipView) userInfo:nil repeats:YES];
        }
        
        [self performSelector:@selector(addTipView) withObject:nil afterDelay:.1];
    }
    else{
        [self setBottomViewHidden:NO animated:YES];
        [self performSelector:@selector(removeTipView:) withObject:[NSNumber numberWithFloat:YES] afterDelay:.1];
    }
}

-(void)addTipView
{
    [self removeTipView:NO];
    
    CGFloat navbottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    
    if (_linkKukeContanierView == nil) {
        _linkKukeContanierView = [[UIView alloc] init];
        _linkKukeContanierView.frame = CGRectMake(0, navbottom, self.view.frame.size.width, self.view.frame.size.height - navbottom);
        [self.view addSubview:_linkKukeContanierView];
    }
    
    if (_unlinkTitleLab==nil) {
        _unlinkTitleLab = [[UILabel alloc] init];
        _unlinkTitleLab.backgroundColor = [UIColor clearColor];
        _unlinkTitleLab.textColor = BASE_COLOR;
        _unlinkTitleLab.font = [UIFont systemFontOfSize:24.0];
        _unlinkTitleLab.textAlignment = NSTextAlignmentCenter;
        _unlinkTitleLab.text = NSLocalizedString(@"openkuke", @"");
        _unlinkTitleLab.frame = CGRectMake(0, 30, _linkKukeContanierView.frame.size.width, 24);
        [_linkKukeContanierView addSubview:_unlinkTitleLab];
    }
    
    if (_unlinkSubtitleLab==nil) {
        _unlinkSubtitleLab = [[UILabel alloc] init];
        _unlinkSubtitleLab.backgroundColor = [UIColor clearColor];
        _unlinkSubtitleLab.textColor = [UIColor blackColor];
        _unlinkSubtitleLab.font = [UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
        _unlinkSubtitleLab.textAlignment = NSTextAlignmentCenter;
        _unlinkSubtitleLab.numberOfLines = 0;
        _unlinkSubtitleLab.text = NSLocalizedString(@"presspowerbtn", @"");
        _unlinkSubtitleLab.frame = CGRectMake(0, _unlinkTitleLab.frame.origin.y+_unlinkTitleLab.frame.size.height+10, _linkKukeContanierView.frame.size.width, 38);
        [_linkKukeContanierView addSubview:_unlinkSubtitleLab];
    }
    
    if (_linkdownImageView == nil) {
        _linkdownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_two" bundle:@"TAIG_FILE_LIST"]];
    }
    _linkdownImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0, _unlinkSubtitleLab.frame.origin.y+_unlinkSubtitleLab.frame.size.height+30, 160*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX);
    
    if (_linkupImageView == nil) {
        _linkupImageView = [[UIImageView alloc] init];
        _linkupImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0, _unlinkSubtitleLab.frame.origin.y+_unlinkSubtitleLab.frame.size.height+30, 160*WINDOW_SCALE_SIX, 320*WINDOW_SCALE_SIX);
        
        [_linkKukeContanierView addSubview:_linkupImageView];
        [_linkKukeContanierView addSubview:_linkdownImageView];
    }
    
    if (_unlinkTipLab == nil) {
        CGFloat oriY = _linkKukeContanierView.frame.size.height-45*WINDOW_SCALE_SIX-24;
        
        _unlinkTipLab = [[UILabel alloc] init];
        _unlinkTipLab.backgroundColor = [UIColor clearColor];
        _unlinkTipLab.text = NSLocalizedString(@"kukedisctitle", @"");
        _unlinkTipLab.textAlignment = NSTextAlignmentCenter;
        _unlinkTipLab.font = [UIFont systemFontOfSize:12];
        _unlinkTipLab.numberOfLines = 0;
        
        _unlinkTipLab.frame = CGRectMake(0, oriY, SCREEN_WIDTH, 34);
        _unlinkTipLab.textColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:1];
        
        [_linkKukeContanierView addSubview:_unlinkTipLab];
        
        UIButton *discBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [discBtn setFrame:_unlinkTipLab.frame];
        [discBtn addTarget:self action:@selector(discriptionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_linkKukeContanierView addSubview:discBtn];
    }
    
    [self doLinkKeAnimation:[NSNumber numberWithBool:YES]];
}

-(void)kukeImageViewAnimated
{
    [_linkdownImageView.layer removeAnimationForKey:@"link"];
    CGPoint downCenter = _linkdownImageView.center;
    CGPoint midCenter = CGPointMake(_linkupImageView.center.x, _linkupImageView.center.y +20*WINDOW_SCALE_SIX);
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    opacityAnimation.duration = 2.0;
    opacityAnimation.repeatCount = 1;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.values = @[[NSValue valueWithCGPoint:downCenter], [NSValue valueWithCGPoint:midCenter], [NSValue valueWithCGPoint:CGPointMake(_linkupImageView.center.x, _linkupImageView.center.y)]];
    opacityAnimation.keyTimes = @[@0, @0.5,@1];
    
    [_linkdownImageView.layer addAnimation:opacityAnimation forKey:@"link"];
}

-(void)handImageViewAnimated
{
    if (_handImageView == nil) {
        _handImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_hand" bundle:@"TAIG_FILE_LIST"]];
    }
    _handImageView.hidden = NO;
    _handImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 - 50*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 70*WINDOW_SCALE_SIX, 105*WINDOW_SCALE_SIX);
    [_linkKukeContanierView addSubview:_handImageView];
    
    _handImageView.alpha = 0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1;
    group.beginTime = CACurrentMediaTime() +1;
    group.repeatCount =1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    [_handImageView.layer removeAnimationForKey:@"hand_x"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.toValue = [NSNumber numberWithFloat: (47*WINDOW_SCALE_SIX)];
    
    CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue = [NSNumber numberWithFloat:0];
    animation2.toValue = [NSNumber numberWithFloat:1.0];
    
    group.animations = [NSArray arrayWithObjects:animation,animation2, nil];
    [_handImageView.layer addAnimation:group forKey:@"hand_x"];
    
}

-(void)circleImageViewAnimated
{
    if (_circleImageView == nil) {
        _circleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_lightcycle" bundle:@"TAIG_FILE_LIST"]];
    }
    _circleImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + (47-30)*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18-30*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX, 60*WINDOW_SCALE_SIX);
    [_linkKukeContanierView addSubview:_circleImageView];
    
    _circleImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _circleImageView.alpha = 0;
    
    [_circleImageView.layer removeAnimationForKey:@"circle_scale"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.duration = 0.6;
    animation.beginTime = CACurrentMediaTime() + 2.1;
    animation.repeatCount =1;
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [_circleImageView.layer addAnimation:animation forKey:@"circle_scale"];
}

-(void)lightLinkAnimated
{
//    if (_lightLinkImageView == nil) {
//        _lightLinkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_light" bundle:@"TAIG_FILE_LIST"]];
//    }
//    _lightLinkImageView.hidden = YES;
//    _lightLinkImageView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, (81+320 - 18)*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX);
    
    if (_lightLinkContanierView == nil) {
        _lightLinkContanierView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 7*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX)];
        _lightLinkContanierView.backgroundColor = [UIColor clearColor];
        
        for (int i = 0; i < 4; i++) {
            UIImageView *_lightLink = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_link_light" bundle:@"TAIG_FILE_LIST"]];
            _lightLink.frame = CGRectMake(8*WINDOW_SCALE_SIX*i, 0, 7*WINDOW_SCALE_SIX, 7*WINDOW_SCALE_SIX);
            [_lightLinkContanierView addSubview:_lightLink];
        }
        
    }
    _lightLinkContanierView.hidden = YES;
    _lightLinkContanierView.frame = CGRectMake((SCREEN_WIDTH - 160*WINDOW_SCALE_SIX)/2.0 + 109*WINDOW_SCALE_SIX, _linkupImageView.frame.origin.y+_linkupImageView.frame.size.height-18, 7*WINDOW_SCALE_SIX, 100*WINDOW_SCALE_SIX);
    
    [_linkKukeContanierView addSubview:_lightLinkContanierView];
    
    [_lightLinkContanierView.layer removeAnimationForKey:@"light_x"];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 2.7;
    animation.beginTime = CACurrentMediaTime() + 2.3;
    animation.repeatCount =1;
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [_lightLinkContanierView.layer addAnimation:animation forKey:@"light_x"];
}

-(void)animationDidStart:(CAAnimation *)anim
{
    CAAnimation *ani;
    if (_lightLinkContanierView) {
        ani = [_lightLinkContanierView.layer animationForKey:@"light_x"];
    }
    if (ani == anim) {
        
        _lightLinkContanierView.hidden = NO;
    }
    
    if (_circleImageView) {
        ani = [_circleImageView.layer animationForKey:@"circle_scale"];
    }
    if (ani == anim) {
        
        _circleImageView.alpha = 0.23;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_circleImageView) {
        CAAnimation *ani = [_circleImageView.layer animationForKey:@"circle_scale"];
        if (ani) {
            _circleImageView.alpha = 0;
        }
    }
    
    CAAnimation *ani;
    if (_lightLinkContanierView) {
        ani = [_lightLinkContanierView.layer animationForKey:@"light_x"];
//        _lightLinkContanierView.hidden = YES;
    }
    
    if (ani == anim) {
        if (_linkKeTimer == nil) {
            [self removeTipView:YES];
        }
    }
}

-(void)doLinkKeAnimation:(NSNumber *)isshow
{
    if (isshow) {
        if (_handImageView) {
            _handImageView.hidden = YES;
        }
        
//        [self kukeImageViewAnimated];
        [self handImageViewAnimated];
        [self circleImageViewAnimated];
        [self lightLinkAnimated];
    }
    else{
        [self removeTipView:YES];
    }
}


-(void)removeTipView:(BOOL)isneedRemoveTimer
{
    if (isneedRemoveTimer) {
        if (_linkKeTimer) {
            [_linkKeTimer invalidate];
            _linkKeTimer = nil;
        }
    }
    
    if (_linkKukeContanierView) {
        for (UIView *view in _linkKukeContanierView.subviews) {
            [view.layer removeAllAnimations];
            [view removeFromSuperview];
        }
        if (_linkKukeContanierView.superview) {
            [_linkKukeContanierView removeFromSuperview];
        }
        _linkKukeContanierView = nil;
    }
    if (_unlinkTipLab) {
        if (_unlinkTipLab.superview) {
            [_unlinkTipLab removeFromSuperview];
        }
        _unlinkTipLab = nil;
    }
    
    [_unlinkTitleLab removeFromSuperview];
    [_unlinkSubtitleLab removeFromSuperview];
    _unlinkTitleLab = nil;
    _unlinkSubtitleLab = nil;
    
    if (_linkdownImageView) {
        [_linkdownImageView.layer removeAllAnimations];
        if (_linkdownImageView.superview) {
            [_linkdownImageView removeFromSuperview];
        }
        _linkdownImageView = nil;
    }
    if (_linkupImageView) {
        if (_linkupImageView.superview) {
            [_linkupImageView removeFromSuperview];
        }
        _linkupImageView = nil;
    }
    if (_handImageView) {
        if (_handImageView.superview) {
            [_handImageView removeFromSuperview];
        }
        _handImageView = nil;
    }
    if (_lightLinkContanierView) {
        if (_lightLinkContanierView.superview) {
            [_lightLinkContanierView removeFromSuperview];
        }
        _lightLinkContanierView = nil;
    }
    if (_circleImageView) {
        if (_circleImageView.superview) {
            [_circleImageView removeFromSuperview];
        }
        _circleImageView = nil;
    }
}

-(void)setBottomViewHidden:(BOOL)isHidden animated:(BOOL)animated
{
    if (isHidden) {
        
        if ([self isEditing]) {
            [self clickRight:nil];
        }
        
        [UIView animateWithDuration:animated?0.3:0 animations:^{
            _bomView.frame = CGRectMake(0,
                                        SCREEN_HEIGHT,
                                        SCREEN_WIDTH,
                                        45);
            if (_importPicView) {
                _importPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT,
                                                  SCREEN_WIDTH,
                                                  45);
            }
            if (_exportPicView) {
                _exportPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT,
                                                  SCREEN_WIDTH,
                                                  45);
            }
        } completion:^(BOOL finished) {
            
        }];
        
    }
    else{
        [UIView animateWithDuration:animated?0.3:0 animations:^{
            
            _bomView.frame = CGRectMake(0,
                                        SCREEN_HEIGHT-(([self isEditing] || self.uiType == Copy_UI_Type) && !_isExportEditing?45:0),
                                        SCREEN_WIDTH,
                                        45);
            if (_importPicView) {
                _importPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT-([self isEditing]?0:45),
                                                  SCREEN_WIDTH,
                                                  45);
            }
            if (_exportPicView) {
                _exportPicView.frame = CGRectMake(0,
                                                  SCREEN_HEIGHT-(!_isExportEditing?0:45),
                                                  SCREEN_WIDTH,
                                                  45);
            }
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    _customNavigationBar.rightBtn.hidden = isHidden;
}

#pragma mark - rotate

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - check show data sync

-(BOOL)checkIsShowDataSync
{
    if (self.navigationController.topViewController == self) {
        return YES;
    }
    return NO;
}

#pragma mark - for downloading

-(BOOL)checkIsDownloadedFilePath
{
    return [CustomFileManage isDownloadedDir:self.subCopyPath];
}

#pragma mark - dealloc

-(void)dealloc {
    if ([MusicPlayerViewController instance].scanDelegate == self){
        [MusicPlayerViewController instance].scanDelegate = nil;
    }

    [_selectedItem removeAllObjects];
    _selectedItem = nil;
    [_operationFileArr removeAllObjects];
    _operationFileArr = nil;
    for (NSMutableArray* arr in self.modelArr) {
        [arr removeAllObjects];
    }
    [_modelArr removeAllObjects];
    
    for (NSMutableArray* arr in self.sectionArr) {
        [arr removeAllObjects];
    }
    [_sectionArr removeAllObjects];
    
    _modelArr = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView removeFromSuperview];
    _tableView = nil;
    _lastPlayCell = nil;
    
    [cellArray removeAllObjects];
    cellArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 无用方法

-(BOOL)checkDocmentCellIsInDownloadedList:(FileBean *)bean
{
    BOOL isIn = NO;
    
    
    NSMutableArray *downloadingArray = [[DownloadManager shareInstance] getDownloadCompleteArray];
    
    for (NSDictionary *tmp in downloadingArray) {
        
        if ([[tmp objectForKey:@"filepath"] isEqualToString:bean.filePath]) {
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

-(void)selectBtnPressed:(UIButton *)btn
{
    [self selectMaskBtnPressed];
    if (btn.tag == 0) {
        PathBean* current = [self getCurrentPathBean];
        web=[[WebViewController alloc]init];
        web.scanDelegate=self;
        [web getPath:selectbean pathArray:current.docPathAry];
        [self.navigationController pushViewController:web animated:YES];
        [self UMengClick:@"DOCUMENT" isMenu:NO];
    }
    else{
        [self openDocumentIn:selectbean];
    }
}

@end
