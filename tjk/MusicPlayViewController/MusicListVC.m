//
//  MusicListVC.m
//  tjk
//
//  Created by Youqs on 15/5/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "MusicListVC.h"
#import "CustomNavigationBar.h"
#import "BottomEditView.h"
#import "DocumentFileCell.h"
#import "FileOperate.h"
#import "MusicPlayerViewController.h"
#import "FileViewController.h"

#define IS_IOS7 [[UIDevice currentDevice] systemVersion].floatValue >= 7

#define MusicList_MENU_SELECT_ALL_TAG  1025
#define MusicList_MENU_DELETE_TAG      1026

#define MusicList_DELETE_ALERT_TAG   1027
#define MusicList_DELETE_ITEM_ALERT_TAG   1028

@interface MusicListVC ()<NavBarDelegate,UITableViewDataSource,UITableViewDelegate,BottomEditViewDelegate,UIAlertViewDelegate,OperateFiles>
{
    CustomNavigationBar          *_customNavigationBar;
    UITableView                  *_tableView;
    BottomEditView               *_deleteEditView;
    BOOL                         _registerNib;
    BOOL                         _cellClicked;
    BOOL                         _editListAnimation;
    NSInteger                    _editType;
    FileBean                     *_removeFileBean;
    NSInteger                    _swipeIndex;
    FileOperate                  *_operation;
    CustomNotificationView       *_loadingView;
    NSString *titleStr;
    NSMutableArray *cellArray;
}

@property(nonatomic,strong) NSMutableDictionary* selectedItem;
@property(nonatomic,retain) NSMutableArray* operationFileArr;

@end

@implementation MusicListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    cellArray = [NSMutableArray array];
    titleStr = NSLocalizedString(@"nowmusiclist", @"");
    _selectedItem = [NSMutableDictionary dictionary];
    _operationFileArr = [NSMutableArray array];
    _editType = 1;
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    CGFloat y = IS_IOS7?20:0;
    _customNavigationBar.frame = CGRectMake(0, y, self.view.frame.size.width, 44);
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
    _customNavigationBar.title.text = titleStr;
    _customNavigationBar.rightBtn.hidden = YES;
    
    if (IS_IOS7) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        topView.backgroundColor = BASE_COLOR;
        [self.view addSubview:topView];
    }
    
    [self.view addSubview:_customNavigationBar];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 1, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGFloat navBottom = _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height;
    _tableView.frame = CGRectMake(0, navBottom, self.view.frame.size.width, self.view.frame.size.height - navBottom);
    [self.view addSubview:_tableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCellColor:) name:NOWMUSICPLAYBEAN object:nil];
}

-(void)doReloadTable{
    [_tableView reloadData];
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
    [_tableView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [cellArray removeAllObjects];
    cellArray = nil;
}

#pragma mark - nav delegate
-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            [self clickLeft:nil];
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            BOOL ishasFileVC = NO;
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[FileViewController class]]) {
                    ishasFileVC = YES;
                    break;
                }
            }
            if (!ishasFileVC) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    
}

-(void)clickLeft:(UIButton *)leftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRight:(UIButton *)leftBtn
{
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    _editListAnimation = YES;
    [_tableView reloadData];
    
    if ([self checkEditStatus]) {
        _editType = 1;
    }
    else {
        _editType = 2;
    }
    
    if ([self checkEditStatus]) {
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"done",@"") forState:UIControlStateNormal];
    }
    else {
        [self.selectedItem removeAllObjects];
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"edit",@"") forState:UIControlStateNormal];
    }
    [self changeTitle];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _deleteEditView.frame = CGRectMake(0,
                                           SCREEN_HEIGHT-([self checkEditStatus]?45:0),
                                           SCREEN_WIDTH,
                                           45);
    } completion:^(BOOL finished) {
        
    }];
    [self performSelector:@selector(editAnimationDone) withObject:nil afterDelay:.3];
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

-(BOOL)checkEditStatus{
    return  _editType != 1;
}

-(void)editAnimationDone{
    _editListAnimation = NO;
}

-(void)cellClickDone {
    _cellClicked = NO;
}

#pragma mark - table delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicList?_musicList.count:0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_registerNib) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([DocumentFileCell class]) bundle:nil];
        [_tableView registerNib:nib forCellReuseIdentifier:@"DocCell"];
        _registerNib = YES;
    }
    
    static NSString *CellIdentifier = @"DocCell";
    DocumentFileCell*cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray* currentArr = _musicList;
    [cellArray removeObject:cell];
    [cellArray addObject:cell];
    if(indexPath.row >= currentArr.count){
        return cell;
    }
    FileBean* bean = [currentArr objectAtIndex:indexPath.row];
    
    [cell setData:bean row:indexPath.row needLoadIcon:YES];
    [cell setEditStatus:[self checkEditStatus] animation:_editListAnimation];
    NSString* key = bean.filePath;
    [cell setSelectStatus:[self itemIsSelected:key]];
//    cell.itemEditDelegate = self;
    [cell removeSwipeGes];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_tableView] && ![self checkEditStatus]) {
        if (_swipeIndex >= 0) {
            DocumentFileCell* cell = (DocumentFileCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_swipeIndex inSection:0]];
            [cell setEditStatus:NO animation:YES];
            _swipeIndex = -1;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
    NSArray* currentArr = _musicList;
    if(indexPath.row >= currentArr.count){
        return;
    }
    if (![self checkEditStatus]) {
        if(_cellClicked){
            return;
        }
        _cellClicked = YES;
        FileBean* bean = [_musicList objectAtIndex:indexPath.row];
        [self gotoMusicViewWith:bean];
        [[MusicPlayerViewController instance]removeNewIdentify:bean.filePath];
    }
}

-(BOOL)itemIsSelected:(NSString*)key {
    return [self.selectedItem objectForKey:key] != nil;
}

#pragma mark - cell delegate

-(void)deleteModel:(id)model
{
    if ([self cantainsFileBean:model inArray:_musicList]) {
        _removeFileBean = model;
         [self doDeleteModel];
        
//        NSString* message = [NSString stringWithFormat:@"%@\"%@\"%@",NSLocalizedString(@"deletefilea", @""),_removeFileBean.fileName,NSLocalizedString(@"deletefileb", @"")];
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
//        alertView.tag = MusicList_DELETE_ITEM_ALERT_TAG;
//        [alertView show];
    }
}

-(BOOL)cantainsFileBean:(FileBean*)bean inArray:(NSArray*)array{
    for (FileBean* tmp in array) {
        if ([tmp.filePath isEqualToString:bean.filePath]) {
            return YES;
        }
    }
    return NO;
}

-(void)swipeToControlDeleteBtn:(BOOL)show atRow:(NSInteger)row
{
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

-(void)itemClickedAt:(NSInteger)index selected:(BOOL)selected
{
    if (index < _musicList.count) {
        if (![self checkEditStatus]) {
            if(_cellClicked){
                return;
            }
            _cellClicked = YES;
//            FileBean* bean = [_musicList objectAtIndex:index];
            
//            [self gotoFileScanView:bean];
        }
        else {
            FileBean* model = [_musicList objectAtIndex:index];
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

#pragma mark - bottom view delegate

-(void)editButtonClickedAt:(NSInteger)tag
{
    if (_cellClicked) {
        return;
    }
    _cellClicked = YES;
    if (tag == MusicList_MENU_SELECT_ALL_TAG) {
        BOOL selectAll = NO;
        selectAll = [_deleteEditView menuItemIsOriginWithTag:MusicList_MENU_SELECT_ALL_TAG];
        [self setSelectAll:selectAll];
        [_deleteEditView setMenuItemWithTag:MusicList_MENU_SELECT_ALL_TAG enable:YES reverse:YES];
        [self changeTitle];
    }
    else if (tag == MusicList_MENU_DELETE_TAG) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
                                  /*(self.resType == Music_Res_Type?@"确定要删除所选歌单吗？" :*/
                                  NSLocalizedString(@"deletefilesy", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
        alertView.tag = MusicList_DELETE_ALERT_TAG;
        [alertView show];
    }
    
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.5];
}

#pragma mark - alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == MusicList_DELETE_ALERT_TAG) {
            [self deleteModelFiles];
        }
        else if (alertView.tag == MusicList_DELETE_ITEM_ALERT_TAG) {
            [self doDeleteModel];
        }
    }
}

#pragma mark - file operate delegate

-(void)fileActionResult:(BOOL)result userInfo:(id)info
{
    if(!result){
        return;
    }
    NSString* action = [info objectForKey:@"action"];
    if ([action isEqualToString:@"delete"]) {
        [FileSystem createDirIfNotExist];
        
        for (NSObject *obj in self.operationFileArr) {
            [_musicList removeObject:obj];
        }
        
        [self.selectedItem removeAllObjects];
        [self.operationFileArr removeAllObjects];
        _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
        if ([self checkIsShowDataSync]) {
            [_loadingView performSelector:@selector(show) withObject:nil afterDelay:.05];
        }
        [self performSelector:@selector(processDeleteAction:) withObject:info afterDelay:.1];
        
        NSString* dirPath = [info objectForKey:@"dirpath"];
        NSString* path = [self getCurrentPath];
        NSDictionary* actionInfo = [NSDictionary dictionaryWithObjectsAndKeys:dirPath,@"path",path,@"currentpath",@"delete",@"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ACTION_DONE" object:actionInfo];
    }
    NSLog(@"fileActionResult:: result : %d , info : %@",result,info);
}

-(void)processDeleteAction:(NSDictionary*)info{
    [self changeTitle];
    [_tableView reloadData];
    NSNumber* removeNowPlay = [info objectForKey:@"deleteplaying"];
    [[MusicPlayerViewController instance] deletefinishrefresh:_musicList deletenowplay:removeNowPlay.boolValue];
    [_loadingView dismiss];
}

#pragma mark - funtion

-(NSString*)getCurrentPath
{
    return nil;
}

- (void)changeTitle
{
    if ([self checkEditStatus])
    {
        if (self.selectedItem.count == 0) {
            _customNavigationBar.title.text = NSLocalizedString(@"selectmusic", @"");
            [_deleteEditView setMenuItemWithTag:MusicList_MENU_DELETE_TAG enable:NO reverse:NO];
        }else{
            _customNavigationBar.title.text =[NSString stringWithFormat:@"%@%lu%@",NSLocalizedString(@"selected",@""),(unsigned long)self.selectedItem.count,NSLocalizedString(@"selectcountunit", @"")];
            [_deleteEditView setMenuItemWithTag:MusicList_MENU_DELETE_TAG enable:YES reverse:NO];
        }
        [_deleteEditView setMenuItemWithTag:MusicList_MENU_SELECT_ALL_TAG enable:YES showReverse:(self.selectedItem.count > 0 && self.selectedItem.count == _musicList.count)];
        
    }else
    {
        _customNavigationBar.title.text = titleStr;
    }
}

-(void)setSelectAll:(BOOL)selected{
    if (selected) {
        NSArray* current = _musicList;
        
        for (NSInteger i = 0; i < current.count; i ++) {
            FileBean* model = [current objectAtIndex:i];
            NSString* key = model.filePath;
            if (![self.selectedItem objectForKey:key]) {
                [self.selectedItem setObject:model forKey:key];
            }
            
        }
    }
    else {
        [self.selectedItem removeAllObjects];
    }
    [self changeTitle];
    [_tableView reloadData];
}

-(void)deleteModelFiles{
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
        _operation.delegate = self;
    }
    [self.operationFileArr removeAllObjects];
    FileBean* currentMusic = [[MusicPlayerViewController instance] getCurrentBean];
    BOOL removeNowPlay = NO;
    BOOL removeNowDir = NO;
    for (FileBean* been in self.selectedItem.objectEnumerator) {
        if (!removeNowPlay && [currentMusic.filePath isEqualToString:been.filePath]) {
            if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
                removeNowPlay = YES;
                
            }
            [[MusicPlayerViewController instance]  setDeleteState:YES];
            [[CustomMusicPlayer shareCustomMusicPlayer]stop];
        }
        else if(!removeNowPlay && [currentMusic.filePath rangeOfString:been.filePath].location != NSNotFound){
            removeNowDir = YES;
        }
        if (been.fileType == FILE_DIR) {
            [[CustomFileManage instance] cleanPathCache:been.filePath];
        }
        [self.operationFileArr addObject:been];
    }
    [_operation deleteFiles:self.operationFileArr userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"delete",@"action",
                                                            currentMusic.filePath,@"dirpath",
                                                            [NSNumber numberWithBool:removeNowPlay],@"deleteplaying",
                                                            [NSNumber numberWithBool:removeNowDir],@"deleteplayingdir",
                                                            nil]];
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
    else if(!removeNowPlay && [currentMusic.filePath rangeOfString:_removeFileBean.filePath].location != NSNotFound){
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
                                                            _removeFileBean.filePath,@"dirpath",
                                                            [NSNumber numberWithBool:removeNowPlay],@"deleteplaying",
                                                            [NSNumber numberWithBool:removeNowDir],@"deleteplayingdir", nil]];
    _removeFileBean = nil;
}

-(void)gotoMusicViewWith:(FileBean *)bean
{
    NSString *prepath = bean.filePath;
    if ([prepath hasPrefix:KE_PHOTO] || [prepath hasPrefix:KE_VIDEO] || [prepath hasPrefix:KE_MUSIC] || [prepath hasPrefix:KE_DOC] || [prepath hasPrefix:KE_ROOT]) {
        [[MusicPlayerViewController instance]setSongPath:bean kuke:YES];
        
    }else {
        
        [[MusicPlayerViewController instance]setSongPath:bean kuke:NO];
    }
    [self performSelector:@selector(cellClickDone) withObject:nil afterDelay:.2];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - check show data sync

-(BOOL)checkIsShowDataSync
{
    if (self.navigationController.topViewController == self) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
