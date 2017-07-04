//
//  CustomCollectionViewController.m
//  tjk
//
//  Created by Ching on 15-3-16.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "CustomCollectionViewController.h"
#import "PhotoCellView.h"
#import "CustomAlertView.h"
#import "EnumHeader.h"
#import "MobClickUtils.h"

typedef NS_ENUM(NSInteger, AlertTag){
    AlertTagUnlinkKe,
    AlertTagMoveOutFailed,
};

@interface CustomCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,BottomEditViewDelegate,PhotoInfoUtiles>{
    
    NSArray            *_curArray;         // 仅指向
    NSUInteger          _totalPhotos;     // 照片总数
    NSMutableArray     *_indexFlagArray; // 标记数组
    
    NSMutableArray     *_exportPhotoArray; // 导出到手机系统相册数组
    
    NSDateFormatter    *_dateFormatter; //外层
    NSDictionary       *_lineOneAttDic;
    NSDictionary       *_lineTwoAttDic;
    
    NSString           *_copyToPath;
    BOOL                _overChang;
    BOOL                _btnIsUsed;
    BOOL                _isBottom;
    BOOL                isRmoved;
    BOOL                iscopyDone;
    
    
    int                 _nowPro;
    float               _allSize;
    float               _countSize;
    float               _nowSize;
    float               _tmpsize;
    float               _toPhotosize;
    
    FileBean *nowCopyoutBean;
    NSTimer  *copyoutTimer;
    
    BottomEditView          *_bottomView;
}

@property (nonatomic, strong) NSMutableArray *photoIndexMulArray; // 索引数组
@property (nonatomic, strong) NSMutableArray *photoMulArray;      // 对应索引的相册数组

@property (nonatomic, strong) NSArray         *allPhoneArray; // 相册数据(导出到手机数组)

@end


#define ALL_CLICK_BTN_TAG  1101
#define MOVE_BTN_TAG       1102
#define DELETE_Btn         1103
#define MENU_SELECT_PICTURE_ALL_TAG 1291
#define MENU_IMPORT_PICTURE_TAG   1290
#define PHOTO_NAME NO         /***********   是否显示照片名字   ***********/

static NSString *phoCellIden  = @"photoCellIdentiifer";
static NSString *phoDateCellIden = @"PhotoDateCellIdentifier";
static NSString *phoNullCellIden = @"phoNullCellIdentifier";

@implementation CustomCollectionViewController

#pragma mark - Life Cycle

-(id)init{
    self = [super init];
    if (self) {
        _overChang      = NO;
        _btnIsUsed      = NO;
        
        _exportPhotoArray   = [[NSMutableArray alloc] init];
        _indexFlagArray = [[NSMutableArray alloc] init]; // 导入到ke专用
        _selectMulDic = [[NSMutableDictionary alloc] init];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat headerHeight = [self isDistinguish]?109:64;
    CGRect frame = CGRectMake(0, headerHeight, self.view.frame.size.width, self.view.frame.size.height-headerHeight);
    self.view.frame = frame;
    
    UICollectionViewFlowLayout *layout =  [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                         collectionViewLayout:layout];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[PhotoCellView class] forCellWithReuseIdentifier:phoCellIden];
    [_collectionView registerClass:[UICollectionDateViewCell class] forCellWithReuseIdentifier:phoDateCellIden];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:phoNullCellIden];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    // BottomView
    NSInteger  bottomMenuTag = 0;
    BOOL       importItemEnable = NO;
    NSArray   *bottomItemArr = nil;
    if ([self isImportToKe]) {
        bottomMenuTag = MENU_SELECT_PICTURE_ALL_TAG;
        bottomItemArr = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            NSLocalizedString(@"checkall",@""), @"title",
                                                            NSLocalizedString(@"cancel",@""), @"reverse_title",
                                                            @"list_icon-allselect-nouse", @"img",
                                                            @"list_icon-allselect", @"hl_img",
                                                            @"list_icon-noselect-nouse", @"reverse_img",
                                                            @"list_icon-noselect", @"reverse_hl_img",
                                                            [NSNumber numberWithInteger:MENU_SELECT_PICTURE_ALL_TAG], @"tag",
                                                            nil],
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   NSLocalizedString(@"importhere",@""), @"title" ,
                                   @"list_icon_import_nouse", @"img" ,
                                   @"list_icon_import", @"hl_img" ,
                                   [NSNumber numberWithInteger:MENU_IMPORT_PICTURE_TAG], @"tag",
                                   nil],
                                  nil];
        
    }
    else
    {
        importItemEnable = YES;
        bottomMenuTag = MENU_IMPORT_PICTURE_TAG;
        bottomItemArr = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                   NSLocalizedString(@"exporthere",@""), @"title" ,
                                   [NSNumber numberWithInteger:MENU_IMPORT_PICTURE_TAG], @"tag",
                                   nil],
         nil];
    }
    
    _bottomView = [[BottomEditView alloc] initWithInfos:bottomItemArr frame:CGRectMake(0, frame.size.height - 45, frame.size.width, 45)];
    _bottomView.editDelegate = self;
    
    [_bottomView setMenuItemWithTag:MENU_SELECT_PICTURE_ALL_TAG enable:YES reverse:NO];
    [_bottomView setMenuItemWithTag:MENU_IMPORT_PICTURE_TAG enable:importItemEnable reverse:NO];
    [self.view addSubview:_bottomView];
    
    // NSNotification Methods
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileOperateCancel:) name:FILE_OPERATION_CANCEL object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self initScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interfaces

-(void)reloadCollectionView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
    });
}

- (void)setPhotoAlbumData:(NSArray *)array
{
    [self clearAllArray];
    
    if ([self isDistinguish]) {
        self.photoIndexMulArray = array[0];
        self.photoMulArray      = array[1];
        
        [self initIndexSelectFlagArray:_photoIndexMulArray];
        [self calculateTotalPhotos];
    }
    else
    {
        self.allPhoneArray = array;
        
        [self calculateTotalPhotos];
        
        // RefreshUI
        [self reloadCollectionView];
        if (_isBottom && _allPhoneArray.count > 0) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:array.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
        else
        {
            [_collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }
    
}

- (void)initScroll
{
    if (_isBottom && _photoIndexMulArray.count > 0) {
        NSInteger section  = _photoIndexMulArray.count-1;
        NSArray   *lastArr = [_photoMulArray lastObject];
        NSInteger itemRow  = [self getCountOfSectionItems:lastArr.count]-1;
        
        NSLog(@"photoIndexArray: %lu, photoMulArray: %lu, section: %lu, itemRow: %lu",_photoIndexMulArray.count,_photoMulArray.count,section,itemRow);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemRow inSection:section] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
    else
    {
        [_collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

- (void)setExportPhotoData:(NSArray *)array
{
    [_exportPhotoArray removeAllObjects];
    [_exportPhotoArray addObjectsFromArray:array];
}

-(void)setScrollToBottom:(BOOL)isBottom{
    _isBottom = isBottom;
}

#pragma mark - Utility

- (NSAttributedString *)getDateAttributedString:(NSString *)dateStr
{
    NSString *lineOneStr = @"";
    NSString *lineTwoStr = @"";
    
    [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [_dateFormatter dateFromString:dateStr];
    
    // 获取特定日期字符串
    [_dateFormatter setDateFormat:@"MM-dd,EEE,yyyy"];
    NSString *tempStr = [_dateFormatter stringFromDate:date];
    NSArray  *tempArr = [tempStr componentsSeparatedByString:@","];
    
    if (tempArr.count>=3) {
        lineOneStr = tempArr[0];
        lineTwoStr = [NSString stringWithFormat:@"\n%@ %@",tempArr[1],tempArr[2]];
    }
    
    if (!_lineOneAttDic) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 9*WINDOW_SCALE_SIX;
        
        _lineOneAttDic = @{NSFontAttributeName:[UIFont systemFontOfSize:16*WINDOW_SCALE_SIX],NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName:paragraphStyle};
    }
    
    if (!_lineTwoAttDic) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 9*WINDOW_SCALE_SIX;
        
        _lineTwoAttDic = @{NSFontAttributeName:[UIFont systemFontOfSize:8*WINDOW_SCALE_SIX],NSForegroundColorAttributeName:BASE_COLOR,NSParagraphStyleAttributeName:paragraphStyle};
    }
    
    NSMutableAttributedString *lineOneAttStr = [[NSMutableAttributedString alloc] initWithString:lineOneStr attributes:_lineOneAttDic];
    NSAttributedString *lineTwoAttStr = [[NSAttributedString alloc] initWithString:lineTwoStr attributes:_lineTwoAttDic];
    [lineOneAttStr appendAttributedString:lineTwoAttStr];
    
    return lineOneAttStr;
}

- (NSArray *)getSelectedPhotoArray
{
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithCapacity:_totalPhotos];
    
    if ([self isDistinguish]) {
        for (NSArray *phoArr in _photoMulArray) {
            for (CustomPhotoBean *bean in phoArr) {
                if ([_selectMulDic objectForKey:[bean getPhotoId]]) {
                    [selectedArr addObject:bean];
                }
            }
        }
    }
    else
    {
        for (NSInteger i = 0 ; i < _allPhoneArray.count; i ++) {
            CustomPhotoBean* bean = [_allPhoneArray objectAtIndex:i];
            if ([_selectMulDic objectForKey:[bean getPhotoId]]) {
                [selectedArr addObject:bean];
            }
        }
    }
    
    return selectedArr;
}

- (BOOL)isDistinguish
{
    return (_phoAlbumOperation == PhotoAlbumOperationImportToKe) && (_mediaType==TYPE_PHOTO);
}

- (BOOL)isImportToKe
{
    return _phoAlbumOperation == PhotoAlbumOperationImportToKe;
}

#pragma mark - 手机照片导入到壳的专用方法

- (NSUInteger)getCountOfSectionItems:(NSUInteger)secItemCount
{ // 导入到壳的专用方法
    return (secItemCount-1)/3+1+secItemCount;
}

- (NSUInteger)getRealIndexByItemIndexRow:(NSUInteger)itemRow
{ // 导入到壳的专用方法
    NSUInteger columnCount = itemRow/4 + 1;
    return itemRow-columnCount;
}

- (void)calculateTotalPhotos
{ // 导入到壳的专用方法
    _totalPhotos = 0;
    
    if ([self isDistinguish]) {
        for (NSArray *phArr in _photoMulArray) {
            _totalPhotos += phArr.count;
        }
    }
    else
    {
        _totalPhotos = _allPhoneArray.count;
    }
}

#pragma mark - 选中图片相关方法(operation data and UI)

- (void)selectAllPhotos
{
    if ([self isDistinguish]) {
        for (int i=0; i<_photoIndexMulArray.count; i++) {
            [self storeIndexSelectedFlag:YES section:i];
            [self storeSelectedPhotoIDsOfSection:i];
        }
    }
    else
    {
        for (int i = 0; i < _allPhoneArray.count; i++) {
            CustomPhotoBean* bean = [_allPhoneArray objectAtIndex:i];
            [_selectMulDic setValue:bean forKey:[bean getPhotoId]];
        }
    }
    
    [self changeBottomNavItemState];
    [self reloadCollectionView];
}

- (void)selectAllPhotos:(BOOL)selected withSection:(NSUInteger)section
{ // 选中（非选中）一个section
    [self storeIndexSelectedFlag:selected section:section];
    
    if (selected) {
        [self storeSelectedPhotoIDsOfSection:section];
    }
    else
    {
        [self removeSelectedPhotoIDsOfSection:section];
    }
    
    [self changeBottomNavItemState];
    [self reloadCollectionView];
}

- (void)cancelSelectAllPhotos{
    
    if ([self isDistinguish]) {
        for (int i=0; i<_photoIndexMulArray.count; i++) {
            [self storeIndexSelectedFlag:NO section:i];
            [self removeSelectedPhotoIDsOfSection:i];
        }
    }
    else
    {
        [_selectMulDic removeAllObjects];
    }
    
    [self changeBottomNavItemState];
    [self reloadCollectionView];
}

#pragma mark 选中图片相关方法(operation data)

- (void)initIndexSelectFlagArray:(NSArray *)indexArr
{
    [_indexFlagArray removeAllObjects];
    
    NSInteger count = indexArr.count;
    for (int i=0; i<count; i++) {
        [_indexFlagArray addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)storeIndexSelectedFlag:(BOOL)flag section:(NSInteger)section
{
    NSNumber *numberFlag = [NSNumber numberWithBool:flag];
    [_indexFlagArray replaceObjectAtIndex:section withObject:numberFlag];
}

- (void)storeSelectedPhotoIDsOfSection:(NSUInteger)section
{
    NSArray *phoArr = _photoMulArray[section];
    for (CustomPhotoBean *bean in phoArr) {
        [_selectMulDic setValue:bean forKey:[bean getPhotoId]];
    }
}

- (void)removeSelectedPhotoIDsOfSection:(NSUInteger)section
{
    NSArray *phoArr = _photoMulArray[section];
    for (CustomPhotoBean *bean in phoArr) {
        [_selectMulDic removeObjectForKey:[bean getPhotoId]];
    }
}

- (void)changeIndexFlagForSection:(NSUInteger)section
{ // 当前section的Photo是否被选中
    BOOL isSecAllSelected = [self isAllSelectedForSection:section];
    [self storeIndexSelectedFlag:isSecAllSelected section:section];
}

- (BOOL)isAllSelectedForSection:(NSUInteger)section
{
    NSArray *phos = _photoMulArray[section];
    NSArray *keys = _selectMulDic.allKeys;
    
    BOOL isAll = YES;
    for (CustomPhotoBean *bean in phos) {
        if (![keys containsObject:[bean getPhotoId]]) {
            isAll = NO;
            break;
        }
    }
    
    return isAll;
}

- (BOOL)isSelectAllPhotos
{
    return _selectMulDic.allKeys.count == _totalPhotos;
}

#pragma mark - BottomEditViewDelegate

-(void)editButtonClickedAt:(NSInteger)tag{
    if (tag == MENU_IMPORT_PICTURE_TAG) {
        if ([self isImportToKe]) {
            
            NSArray* selectArr = [self getSelectedPhotoArray];
            
            if (selectArr.count > 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"importOver" object:selectArr];
            }
            
            [_collectionView removeFromSuperview];
            _collectionView = nil;
            
            if (self.delegate&&[self.delegate respondsToSelector:@selector(closeView:)]) {
                [self.delegate closeView:NO];
            }
            
        }
        else{
            //将图片导入制定相册
            if (_exportPhotoArray.count > 0) {
                _nowPro = 0;
                _nowSize = 0;
                _tmpsize = 0;
                [[CustomAlertView instance] setFilesCount:(int)_exportPhotoArray.count];
                [[CustomAlertView instance] showProgress];
                //                [[CustomAlertView instance] setNowNum:_nowPro];
                [CustomAlertView instance].alertType = Alert_PhotoOut;
                [self getSize];
                [[CustomAlertView instance] setMsg:self.isResVideoType?NSLocalizedString(@"moveveidoout",@""):NSLocalizedString(@"movetoPhone",@"")];
                [[CustomAlertView instance] setNowNum:_nowPro currentSize:_nowSize allSize:_countSize];
                nowCopyoutBean = [_exportPhotoArray objectAtIndex:0];
                [[PhotoInfoUtiles instance]creatPhoto:[_exportPhotoArray objectAtIndex:0] toGroup:_customGroupBean delegate:self userInfo:nil];
            }
        }
    }
    else if (tag == MENU_SELECT_PICTURE_ALL_TAG){
        
        BOOL selectAll = ![self isSelectAllPhotos];
        [_bottomView setMenuItemWithTag:MENU_SELECT_PICTURE_ALL_TAG enable:YES reverse:YES];
        if (selectAll) {
            [self selectAllPhotos];
        }
        else
        {
            [self cancelSelectAllPhotos];
        }
    }
}

#pragma mark - PhotoInfoUtiles

-(void)progress:(float)progress bean:(CustomPhotoBean *)bean userInfo:(id)info
{
    _nowSize += progress;
    _tmpsize += progress;
    float x = _nowSize / _countSize;
    [[CustomAlertView instance] setNowNum:_nowPro currentSize:_nowSize allSize:_countSize];
    [[CustomAlertView instance] progress:x];
}

-(void)copyToLocalDone:(FileBean *)bean
{
    iscopyDone = NO;
    _toPhotosize = 0;
    nowCopyoutBean = bean;
    if (copyoutTimer) {
        [copyoutTimer invalidate];
        copyoutTimer = nil;
    }
    copyoutTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doCopyoutProgress) userInfo:nil repeats:YES];
}

-(void)addPhotoToGroup:(BOOL)result userInfo:(id)info bean:(FileBean*)fileBean{
    dispatch_async(dispatch_get_main_queue(), ^{
        iscopyDone = YES;
        if (result) {
            if (_exportPhotoArray.count > 0) {
                _nowPro++;
                [_exportPhotoArray removeObjectAtIndex:0];
            }
            _nowSize -= _tmpsize;
            _nowSize += [fileBean getFileSize];
            float x = _nowSize / _countSize;
            [[CustomAlertView instance] setNowNum:_nowPro currentSize:_nowSize allSize:_countSize];
            [[CustomAlertView instance] progress:x];
            
            if (_exportPhotoArray.count >0) {
                _tmpsize = 0;
                nowCopyoutBean = [_exportPhotoArray objectAtIndex:0];
                [[PhotoInfoUtiles instance]creatPhoto:[_exportPhotoArray objectAtIndex:0] toGroup:_customGroupBean delegate:self userInfo:nil];
            }else{
                [self removeCustomAlertView];
            }
        }else{
            [self addPhotoToGroupErrorIs2Big:NO userInfo:info bean:fileBean];
        }
    });
}

-(void)addPhotoToGroupErrorIs2Big:(BOOL)isBig  userInfo:(id)info bean:(FileBean*)fileBean{
    if (isRmoved) {
        return;
    }
    if (![FileSystem checkInit] && [FileSystem isConnectedKE] && [MobClickUtils MobClickIsActive]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"keunlink", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil, nil];
        alert.tag = AlertTagUnlinkKe;
        [alert show];
        [[CustomAlertView instance] hidden];
        return;
    }
    if (isBig) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fail",@"")
                                                        message:[NSString stringWithFormat:@"\"%@\"%@",fileBean.fileName,NSLocalizedString(@"moveoutfailbig", @"")] delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"jump",@"")otherButtonTitles:NSLocalizedString(@"again",@""), nil];
        alert.tag = AlertTagMoveOutFailed;
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fail",@"")
                                                        message:[NSString stringWithFormat:@"\"%@\"%@",fileBean.fileName,NSLocalizedString(@"moveoutfail", @"")] delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"jump",@"")otherButtonTitles:NSLocalizedString(@"again",@""), nil];
        alert.tag = AlertTagMoveOutFailed;
        [alert show];
    }
}

-(void)addPhotoToGroupErrorSpaceNotEnough:(FileBean*)fileBean{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fail",@"")
                                                    message:NSLocalizedString(@"moveoutfailspace",@"") delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"jump",@"")otherButtonTitles:NSLocalizedString(@"again",@""), nil];
    alert.tag = AlertTagMoveOutFailed;
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (AlertTagMoveOutFailed == alertView.tag){
        
        if (0 == buttonIndex && _exportPhotoArray.count > 0) {
            _nowSize -= _tmpsize;
            _nowSize += [nowCopyoutBean getFileSize];
            float x = _nowSize / _countSize;
            [[CustomAlertView instance] setNowNum:_nowPro currentSize:_nowSize allSize:_countSize];
            [[CustomAlertView instance] progress:x];
            [_exportPhotoArray removeObjectAtIndex:0];
        }
        if(_exportPhotoArray.count > 0){
            _nowSize -= _tmpsize;
            float x = _nowSize / _countSize;
            [[CustomAlertView instance] setNowNum:_nowPro currentSize:_nowSize allSize:_countSize];
            [[CustomAlertView instance] progress:x];
            _tmpsize = 0;
            nowCopyoutBean = [_exportPhotoArray objectAtIndex:0];
            [[PhotoInfoUtiles instance]creatPhoto:nowCopyoutBean toGroup:self.customGroupBean delegate:self userInfo:nil];
        }
        else {
            [self removeCustomAlertView];
        }
    }
    else if (AlertTagUnlinkKe == alertView.tag){
        [[CustomAlertView instance] hidden];
        
    }
    
    [alertView removeFromSuperview];
}

#pragma mark - NSNotification Nethods

-(void)fileOperateCancel:(NSNotification *)noti
{
    if ([noti.name isEqualToString:FILE_OPERATION_CANCEL] && ((NSNumber *)noti.object).boolValue) {
        if (copyoutTimer) {
            [copyoutTimer invalidate];
            copyoutTimer = nil;
        }
        [_exportPhotoArray removeAllObjects];
        [self removeCustomAlertView];
    }
}

#pragma mark -

-(void)removeCustomAlertView
{
    if (!isRmoved) {
        isRmoved = YES;
        [[CustomAlertView instance] progress:1.0];
        [[CustomAlertView instance] hidden];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(closeView:)]) {
            [self.delegate closeView:YES];
        }
    }
}

-(void)doCopyoutProgress
{
    if (!iscopyDone) {
        float size = [nowCopyoutBean getFileSize]*0.25;
        float persecsize = (0.65*1024*1024);
        _toPhotosize += persecsize;
        if (_toPhotosize > size) {
            _toPhotosize = size;
        }
        float x = (_nowSize+_toPhotosize) / _countSize;
        [[CustomAlertView instance] setNowNum:_nowPro currentSize:(_nowSize+_toPhotosize) allSize:_countSize];
        [[CustomAlertView instance] progress:x];
    }
    else{
        if (copyoutTimer) {
            [copyoutTimer invalidate];
            copyoutTimer = nil;
        }
    }
}

-(void)getSize{
    [[CustomAlertView instance] setMsg:NSLocalizedString(@"readying", @"")];
    for (FileBean *bean in _exportPhotoArray) {
        _countSize += bean.fileSize;
    }
}

-(void)clearAllArray{
    
    [_selectMulDic removeAllObjects];
    
    _totalPhotos = 0;
    _allSize = 0.0;
}

- (void)changeBottomNavItemState{
    if ([self isImportToKe]) {
        if (_selectMulDic.count == 0) {
            [_bottomView setMenuItemWithTag:MENU_IMPORT_PICTURE_TAG enable:NO reverse:NO];
        }else{
            [_bottomView setMenuItemWithTag:MENU_IMPORT_PICTURE_TAG enable:YES reverse:NO];
        }
    }
    
    BOOL isSelectAll = [self isSelectAllPhotos];
    [_bottomView setMenuItemWithTag:MENU_SELECT_PICTURE_ALL_TAG enable:YES showReverse:isSelectAll];
    
    [self refreshTitle];
}

-(BOOL)isImportVideo
{
    return _mediaType == TYPE_VIDEO;
}

- (void)refreshTitle
{
    NSString *nowTitle;
    if ([self isImportToKe]) {
        if (_selectMulDic.count == 0){
            nowTitle = ([self isImportVideo]?NSLocalizedString(@"selectvideo",@"选择视频") : NSLocalizedString(@"selectpicture",@"选择图片"));
        }
        else
        {
            NSMutableArray *countArr = [[NSMutableArray alloc]initWithArray:[_selectMulDic allKeys]];
            nowTitle =[NSString stringWithFormat:@"%@ %lu%@",NSLocalizedString(@"selected",@"已选"),(unsigned long)countArr.count,([self isImportVideo]?NSLocalizedString(@"video",@"视频") : NSLocalizedString(@"picture",@""))];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadPhoneTitle:)]) {
        [self.delegate reloadPhoneTitle:nowTitle];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self isDistinguish]?_photoIndexMulArray.count:1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if ([self isDistinguish]) {
        NSArray   *sectionArr = _photoMulArray[section];
        NSInteger  rowCount = [self getCountOfSectionItems:sectionArr.count];
        return rowCount;
    }
    
    return _allPhoneArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self isDistinguish]) {
        if (indexPath.row==0) {
            // dateCell
            UICollectionDateViewCell *dateCell = [collectionView dequeueReusableCellWithReuseIdentifier:phoDateCellIden forIndexPath:indexPath];
            
            NSNumber *number = _indexFlagArray[indexPath.section];
            BOOL      selected = [number boolValue];
            NSString *dateStr  = _photoIndexMulArray[indexPath.section];
            NSAttributedString *dateAttStr = [self getDateAttributedString:dateStr];
            [dateCell setTag:indexPath.section];
            [dateCell setDateAttributedContent:dateAttStr];
            [dateCell setDateSelectedFlag:selected];
            
            __weak typeof(self) weakSelf = self;
            [dateCell setDateClickBlock:^(NSInteger index, BOOL isSelected) {
                // 选中事件
                NSLog(@"CustomCollectionViewController - IndexCellSelect: %d ,index: %ld",isSelected,(long)index);
                [weakSelf selectAllPhotos:isSelected withSection:index];
            }];
            
            return dateCell;
        }
        else if (indexPath.row%4 == 0)
        {// indexPath.row%4 == 0 , 空白cell
            
            UICollectionViewCell *nullCell = [collectionView dequeueReusableCellWithReuseIdentifier:phoNullCellIden forIndexPath:indexPath];
            return nullCell;
        }
    }
    
    // 展示图片CellF
    NSInteger index = indexPath.row;
    _curArray = _allPhoneArray;
    if ([self isDistinguish]) {
        index = [self getRealIndexByItemIndexRow:indexPath.row];
        _curArray = _photoMulArray[indexPath.section];
    }
    
    CustomPhotoBean *bean = [_curArray objectAtIndex:index];
    PhotoCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:phoCellIden forIndexPath:indexPath];
    if (_curArray.count >= index ) {
        
        // video/gif 是否隐藏相关
        cell.cellType = [self isDistinguish]?PhotoCellTypeDistinguish:PhotoCellTypeNormal;
        [cell videoHidden:YES];
        [bean getPhotoName:^(NSString *name) {
            NSString *videoStr = [[name pathExtension] lowercaseString];
            if ([videoStr isKindOfClass:[NSString class]]) {
                if ([videoStr isEqualToString:@"mov"] || [videoStr rangeOfString:@"ext=mov"].location != NSNotFound) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell videoImg];
                        cell.gifSginImg.hidden = YES;
                    });
                }else if ([videoStr isEqualToString:@"gif"]) {
                    [cell gifSgin];
                    [cell videoHidden:YES];
                }
                else
                {
                    [cell videoHidden:YES];
                    cell.gifSginImg.hidden = YES;
                }
            }
        }];
        
        // set select state(UI)
        [cell theClickImgHidden:(_phoAlbumOperation != PhotoAlbumOperationImportToKe)];
        if (_overChang) {
            cell.selectView.alpha = 0;
        }else{
            if ([_selectMulDic objectForKey:[bean getPhotoId]]) {
                [cell changeIsSelect:YES];
            }else
            {
                [cell changeIsSelect:NO];
            }
        }
        
        // set photoURL and thumbnail
        if (![cell.photoUrl isEqualToString:[bean getPhotoId]]) {
            cell.photoUrl = [bean getPhotoId];
            
            [bean getIcon:^(UIImage *img, NSString *name) {
                if ([cell.photoUrl isEqualToString:name]) {
                    [cell setPhoneImg:img];
                    if (PHOTO_NAME) {
                        [cell SetPhotoName:name];
                    }
                }
            }];
        }
    }
    
    return cell;
    
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDistinguish]) { // 导入的相册
        // 导入到ke
        if (indexPath.row%4 != 0) {
            NSInteger realRow = [self getRealIndexByItemIndexRow:indexPath.row];
            CustomPhotoBean *bean = _photoMulArray[indexPath.section][realRow];
            
            // 是否选中
            PhotoCellView *cell = (PhotoCellView *)[collectionView cellForItemAtIndexPath:indexPath];
            if([_selectMulDic objectForKey:bean.getPhotoId]){
                [_selectMulDic removeObjectForKey:bean.getPhotoId];
                [cell isSelect:NO];
            }else{
                [_selectMulDic setObject:bean forKey:bean.getPhotoId];
                [cell isSelect:YES];
            }
            
            // 当前section是否全选中
            [self changeIndexFlagForSection:indexPath.section];
            
            // bottomView item state
            [self changeBottomNavItemState];
            
            // 刷新UI
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            [_collectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
        }
    }
    else if ([self isImportToKe])
    { // 导出相册或其他，导入的相册或其他
        CustomPhotoBean *bean = _allPhoneArray[indexPath.row];
        // 是否选中
        PhotoCellView *cell = (PhotoCellView *)[collectionView cellForItemAtIndexPath:indexPath];
        if([_selectMulDic objectForKey:bean.getPhotoId]){
            [_selectMulDic removeObjectForKey:bean.getPhotoId];
            [cell isSelect:NO];
        }else{
            [_selectMulDic setObject:bean forKey:bean.getPhotoId];
            [cell isSelect:YES];
        }
        
        // bottomView item state
        [self changeBottomNavItemState];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UICollectionViewFlowlayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDistinguish]) {
        CGFloat gap = (15+50+5+10+15)*WINDOW_SCALE_SIX;
        int itemWidth = (collectionView.frame.size.width-gap)/3;
        
        if (indexPath.row %4 == 0) {
            return CGSizeMake(50*WINDOW_SCALE_SIX, itemWidth);
        }
        
        return CGSizeMake(itemWidth, itemWidth);
    }
    
    CGFloat itemWidth = (collectionView.frame.size.width-10)/4;
    return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 2, 0, 2);
    if ([self isDistinguish]) {
        CGFloat space = 15*WINDOW_SCALE_SIX;
        insets = UIEdgeInsetsMake(space, space, 0, space);
    }
    
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self isDistinguish]?5*WINDOW_SCALE_SIX:2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self isDistinguish]?5*WINDOW_SCALE_SIX:2;
}

#pragma mark- 视频时间显示

- (NSString *)Video:(NSString*)timeStr
{
    NSString *senStr;
    NSString *minStr;
    NSString *hourStr;
    NSString *videoTime;
    
    int time = [timeStr intValue];
    int iHour = time/3600;
    int iMin =( time-iHour*3600)/60;
    int iSen = time-iHour*3600-iMin*60;
    if (iSen < 10) {
        senStr = [NSString stringWithFormat:@"0%d",iSen];
    }else{
        senStr = [NSString stringWithFormat:@"%d",iSen];
    }
    if (iMin < 10) {
        minStr = [NSString stringWithFormat:@"0%d",iMin];
    }else{
        minStr = [NSString stringWithFormat:@"%d",iMin];
    }
    if (iHour < 10) {
        hourStr = [NSString stringWithFormat:@"0%d",iHour];
    }else{
        hourStr = [NSString stringWithFormat:@"%d",iHour];
    }
    
    if (iHour == 0) {
        videoTime = [NSString stringWithFormat:@"%@:%@",minStr,senStr];
    }else
    {
        videoTime = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minStr,senStr];
    }
    return videoTime;
}

@end
