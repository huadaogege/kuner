
#import "PhonePhotoViewController.h"
#import "PhotoClass.h"
#import "CustomNotificationView.h"
#import "CustomCollectionViewController.h"

#define TAGBASE 2016

@interface PhonePhotoViewController ()<UIScrollViewDelegate,NavBarDelegate,CustomecollectionDelegate,OperatePhotos>
{
    // datasource
    CustomPhotoGroupBean *_groupBean;
    NSUInteger            _curPhonePhoCount;   // 手机当前相册照片数

    // 全部、未备份、已备份
    NSMutableArray       *_allPhoMIndexArray; // 手机相册图片索引(NSString对象，精确到天）
    NSMutableArray       *_allPhoMSectionArray; // 手机相册图片
    NSMutableArray       *_unCopiedMulIndexArray;
    NSMutableArray       *_unCopiedMulArray;
    NSMutableArray       *_copiedMulIndexArray;
    NSMutableArray       *_copiedMulArray;
    
    // UI
    UIView               *_backView;
    UIView               *_baseView;
    UIImageView          *_changImageView;
    CustomNavigationBar  *_customNavigationBar;
    
    CustomCollectionViewController *_currentVC;
    CustomCollectionViewController *_uncopiedPhotoAlbumVC;
    CustomCollectionViewController *_copiedPhotoAlbumVC;
    CustomCollectionViewController *_allPhotoAlbumVC;
    
    BOOL             _compeleteOnce;
    CGFloat          _tabHeaderHeight;
    NSLock          *_uncopiedLock;
    NSLock          *_copiedLock;
    
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_convertDateFormatter;
}

@end

@implementation PhonePhotoViewController

#pragma mark - Life Cycle

- (id)initWithGroupBean:(CustomPhotoGroupBean *)groupBean TypeCode:(typeCode)typeCode
{
    self = [super init];
    if (self) {
        _mediaType = typeCode;
        _groupBean = groupBean;
        _compeleteOnce = NO;
        
        //
        _unCopiedMulIndexArray = [NSMutableArray array];
        _unCopiedMulArray      = [NSMutableArray array];
        _copiedMulIndexArray   = [NSMutableArray array];
        _copiedMulArray        = [NSMutableArray array];
        
        //
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        _convertDateFormatter = [[NSDateFormatter alloc] init];
        [_convertDateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 当前相册名称
    _tabHeaderHeight = [self isDistinguish]?45:0;
    CGFloat curWidth = [UIScreen mainScreen].bounds.size.width;
    
    // UINavigation Bar
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.frame = CGRectMake(0,
                                            20,
                                            curWidth,
                                            45);
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
    if ([self isDistinguish]) {
        _uncopiedPhotoAlbumVC = [[CustomCollectionViewController alloc] init];
        _uncopiedPhotoAlbumVC.delegate = self;
        _uncopiedPhotoAlbumVC.tag = PhotoAlbumHeaderTabClickUncopied;
        [_uncopiedPhotoAlbumVC setScrollToBottom:YES];
        
        _copiedPhotoAlbumVC = [[CustomCollectionViewController alloc] init];
        _copiedPhotoAlbumVC.delegate = self;
        _copiedPhotoAlbumVC.tag = PhotoAlbumHeaderTabClickCopied;
        [_copiedPhotoAlbumVC setScrollToBottom:YES];
        
        _allPhotoAlbumVC = [[CustomCollectionViewController alloc] init];
        _allPhotoAlbumVC.delegate = self;
        _allPhotoAlbumVC.tag = PhotoAlbumHeaderTabClickAll;
        [_allPhotoAlbumVC setScrollToBottom:YES];
        
        [self.view addSubview:_uncopiedPhotoAlbumVC.view];
        [self addChildViewController:_uncopiedPhotoAlbumVC];
        [_uncopiedPhotoAlbumVC didMoveToParentViewController:self];
        
        _currentVC = _uncopiedPhotoAlbumVC;
    }
    else
    {
        _allPhotoAlbumVC = [[CustomCollectionViewController alloc] init];
        _allPhotoAlbumVC.delegate = self;
        _allPhotoAlbumVC.tag = -1;
        _allPhotoAlbumVC.mediaType = _mediaType;
        _allPhotoAlbumVC.customGroupBean = _groupBean;
        _allPhotoAlbumVC.isResVideoType = _isResVideoType;
        _allPhotoAlbumVC.phoAlbumOperation = (_isOut)?PhotoAlbumOperationImportToKe:PhotoAlbumOperationExportToPhone;
        
        [self.view addSubview:_allPhotoAlbumVC.view];
        [self addChildViewController:_allPhotoAlbumVC];
    }
    
    // TabBar
    if ([self isDistinguish]) {
        __weak typeof(self) weakSelf = self;
        UIPhotoAlbumHeaderView *pAlbumHeaderView = [[UIPhotoAlbumHeaderView alloc] initWithFrame:CGRectMake(0, 64, curWidth, _tabHeaderHeight)];
        [pAlbumHeaderView setPhotoAblumHeaderTabClick:^(PhotoAlbumHeaderTabClick clickIndex) {
            NSLog(@"UIPhotoAlbumHeadView ClickBlock");
            [weakSelf headerViewTabClickIndex:clickIndex];
        }];
        [self.view addSubview:pAlbumHeaderView];
    }
    
    _backView = [[UIView alloc]init];
    _changImageView = [[UIImageView alloc]init];
    _baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20*WINDOW_SCALE)];
    _baseView.backgroundColor = BASE_COLOR;
    
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _backView.hidden = NO;
    _backView.alpha = 0;
    
    [self.view addSubview:_customNavigationBar];
    [self.navigationController.view addSubview:_backView];
    [self.navigationController.view addSubview:_changImageView];
    [self.view addSubview:_baseView];
    
    // 加载数据
    [self loadPhotoData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _customNavigationBar.leftBtn.hidden = NO;
    _customNavigationBar.title.text = self.titleName;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAllarr:) name:ASSET_CHANGE_NOTF object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSET_CHANGE_NOTF object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utility

-(void)loadPhotoData{
    
    [self changeFace];
    
    BOOL isBottom = NO;
    if ([_groupBean isKindOfClass:[CustomPhotoGroup8_Bean class]]) {
        CustomPhotoGroup8_Bean *bean8 = (CustomPhotoGroup8_Bean *)_groupBean;
        PHAssetCollection *_asset = [bean8 getAsset];
        if(_asset.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumCloudShared || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            
            isBottom = YES;
        }
        else
        {
            isBottom = NO;
        }
    }
    else{
        isBottom = [_groupBean isKindOfClass:[CustomPhotoGroup8_AllBean class]];
    }
    
    [CustomNotificationView showToastWithoutDismiss:NSLocalizedString(@"getting", @"")];
    
    __weak typeof(self) weakSelf = self;
    [_groupBean getPhotos:_mediaType withBlock:^(NSArray *allAry) {
        
        // 数据分类（是否备份）
        if ([weakSelf isDistinguish]) {
            [weakSelf accordingToTheDatePacketPhotos:allAry];
            [weakSelf distinguishWhetherPhotosHaveBeenCopied];
        }
        else
        {
            [weakSelf performSelector:@selector(clearAlertView) withObject:nil afterDelay:0.5];
            
            [_allPhotoAlbumVC setExportPhotoData:_oneOutArr];
            [_allPhotoAlbumVC setScrollToBottom:isBottom];
            [weakSelf setChildVCMediaData:allAry];
        }
    }];
}

- (NSString *)getDateWithInterval:(long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    return [_dateFormatter stringFromDate:date];
}

- (NSString *)getKeDateWithDateStr:(NSString *)dateStr
{
    NSDate *date = [_dateFormatter dateFromString:dateStr];
    return [_convertDateFormatter stringFromDate:date];
}

- (void)distinguishCompletion
{
    BOOL isCompletion = [self isDistinguishCompletion];
    if (isCompletion && !_compeleteOnce) {
        NSLog(@"Distinguish Completion");
        _compeleteOnce = YES;
        [self setChildVCMediaData:nil];
        [self reloadPhotoAlbum:YES];
        
        [self clearAlertView];
    }
}

- (BOOL)isDistinguishCompletion
{
    NSUInteger count = 0;
    for (NSArray *copiedArr in _copiedMulArray) {
        count += copiedArr.count;
    }
    
    for (NSArray *uncopiedArr in _unCopiedMulArray) {
        count += uncopiedArr.count;
    }
    
    return _curPhonePhoCount == count;
}

- (BOOL)isDistinguish
{
    return _isOut&&(_mediaType==TYPE_PHOTO);
}

- (void)reloadPhotoAlbum:(BOOL)firstFlag
{
    CustomCollectionViewController *curPhotoAlbumVC = (CustomCollectionViewController *)_currentVC;
    [curPhotoAlbumVC reloadCollectionView];
    [curPhotoAlbumVC refreshTitle];
    
    if (firstFlag) {
        [curPhotoAlbumVC initScroll];
    }
}

-(void)clearAlertView
{
    [CustomNotificationView clearToast];
}

#pragma mark - TabHeaderView about methods

- (void)headerViewTabClickIndex:(PhotoAlbumHeaderTabClick)index
{
    if (_currentVC.tag == index) {
        return ;
    }
    
    // 切换UI
    switch (index) {
        case PhotoAlbumHeaderTabClickUncopied:{
            [self replaceViewController:_currentVC newViewController:_uncopiedPhotoAlbumVC];
        }
            break;
            
        case PhotoAlbumHeaderTabClickCopied:{
            [self replaceViewController:_currentVC newViewController:_copiedPhotoAlbumVC];
        }
            break;
            
        case PhotoAlbumHeaderTabClickAll:{
            [self replaceViewController:_currentVC newViewController:_allPhotoAlbumVC];
        }
            break;
            
        default:
            break;
    }
}

- (void)replaceViewController:(CustomCollectionViewController *)oldVC newViewController:(CustomCollectionViewController *)newVC
{
    [self addChildViewController:newVC];
    
    __weak typeof(self) weakSelf = self;
    [self transitionFromViewController:oldVC
                      toViewController:newVC
                              duration:0.1
                               options:UIViewAnimationOptionCurveLinear
                            animations:^{
                            }
                            completion:^(BOOL finished) {
                                if (finished) {
                                    
                                    [oldVC willMoveToParentViewController:nil];
                                    [oldVC removeFromParentViewController];
                                    [newVC didMoveToParentViewController:self];
                                    
                                    _currentVC = newVC;
                                    [weakSelf reloadPhotoAlbum:NO];
                                    
                                }
                                else
                                {
                                    _currentVC = oldVC;
                                }
                            }];
}

- (void)setChildVCMediaData:(NSArray *)array
{ // 旧版的参数有用
    if ([self isDistinguish]) {
        // set data
        [_uncopiedPhotoAlbumVC setPhotoAlbumData:@[_unCopiedMulIndexArray,_unCopiedMulArray]];
        [_copiedPhotoAlbumVC setPhotoAlbumData:@[_copiedMulIndexArray, _copiedMulArray]];
        [_allPhotoAlbumVC setPhotoAlbumData:@[_allPhoMIndexArray,_allPhoMSectionArray]];
    }
    else
    {
        [_allPhotoAlbumVC setPhotoAlbumData:array];
    }
}

#pragma mark - NavBarDelegate

-(void)clickLeft:(UIButton *)leftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickRight:(UIButton *)leftBtn{
    [self closeView:YES];
}

#pragma mark - CustomecollectionDelegate

-(void)closeView:(BOOL)needRemove{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (needRemove) {
            [_allPhotoAlbumVC willMoveToParentViewController:nil];
            [_allPhotoAlbumVC removeFromParentViewController];
            
            [_copiedPhotoAlbumVC willMoveToParentViewController:nil];
            [_copiedPhotoAlbumVC removeFromParentViewController];
            
            [_uncopiedPhotoAlbumVC willMoveToParentViewController:nil];
            [_uncopiedPhotoAlbumVC removeFromParentViewController];
            
            _allPhotoAlbumVC = nil;
            _uncopiedPhotoAlbumVC = nil;
            _copiedPhotoAlbumVC = nil;
        }
    }];
}

-(void)changeButtonTitle:(NSString *)title{
    [_customNavigationBar.rightBtn setTitle:title forState:UIControlStateNormal];
}

-(void)reloadPhoneTitle:(NSString *)titele{
    _customNavigationBar.title.text = titele;
}

#pragma mark CustomecollectionDelegate About methods

-(void)hiddenView:(UIImageView*)imageView{
    imageView.hidden = YES;
    //    imageView.image = nil;
}

#pragma mark - NSNotification Methods

-(void)reloadAllarr:(NSNotification*)noti{
    
    if ([_groupBean isThisGroup:noti.object]) {
        [self reloaData:_groupBean];
    }
}

#pragma mark NSNotification About Methods

-(void)reloaData:(CustomPhotoGroupBean*)bean{
    _groupBean = bean;
    [self changeFace];
    
    __weak typeof(self) weakSelf = self;
    [bean getPhotos:_mediaType withBlock:^(NSArray *allAry) {
        _allPhotoAlbumVC.phoAlbumOperation = _isOut?PhotoAlbumOperationImportToKe:PhotoAlbumOperationExportToPhone;
        _allPhotoAlbumVC.mediaType = _mediaType;
        _allPhotoAlbumVC.isResVideoType = _isResVideoType;
        if ([self isDistinguish]) {
            [weakSelf accordingToTheDatePacketPhotos:allAry];
            [weakSelf distinguishWhetherPhotosHaveBeenCopied];
        }else{
            _allPhotoAlbumVC.customGroupBean = bean;
            [weakSelf setChildVCMediaData:allAry];
        }
    }];
}

#pragma mark - private methods

-(void)changeFace{
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
}

- (void)accordingToTheDatePacketPhotos:(NSArray *)phoArr
{
    NSLog(@"accordingToTheDatePacketPhotos - PhonePhotoAllCount: %lu",phoArr.count);
    NSMutableArray *indexMulArr = [NSMutableArray array];
    NSMutableArray *sectionMulArr = [NSMutableArray array];
    
    for (CustomPhotoBean *phoBean in phoArr) {
        
        NSTimeInterval time = [phoBean getCreateTime];
        NSString *dateStr = [self getDateWithInterval:(long)time];
        NSUInteger index = [indexMulArr indexOfObject:dateStr];
        if (index == NSNotFound) {
            // 排序
            if (indexMulArr.count > 0) {
                int i = 0;
                for (; i<indexMulArr.count; i++) {
                    NSString *objStr = indexMulArr[i];
                    if ([dateStr compare:objStr options:NSNumericSearch] == NSOrderedAscending) {
                        break;
                    }
                }
                
                // 索引
                [indexMulArr insertObject:dateStr atIndex:i];
                
                // 数据数组
                NSMutableArray *phoMulArr = [[NSMutableArray alloc] init];
                [phoMulArr addObject:phoBean];
                [sectionMulArr insertObject:phoMulArr atIndex:i];
            }
            else
            {
                // 索引数据
                [indexMulArr addObject:dateStr];
                
                // 数据数组
                NSMutableArray *phoMulArr = [[NSMutableArray alloc] init];
                [phoMulArr addObject:phoBean];
                [sectionMulArr addObject:phoMulArr];
            }
        }
        else
        {
            NSMutableArray *phoMulArr = sectionMulArr[index];
            [phoMulArr addObject:phoBean];
            [sectionMulArr replaceObjectAtIndex:index withObject:phoMulArr];
        }
    }
    
    // 手机相册图片 索引数据及图片数组
    _curPhonePhoCount = phoArr.count;
    _allPhoMIndexArray = indexMulArr;
    _allPhoMSectionArray = sectionMulArr;
    
    NSLog(@"accordingToTheDatePacketPhotos - indexMulArrCount: %u,sectionMulArrCount: %u",indexMulArr.count,sectionMulArr.count);
}

- (void)distinguishWhetherPhotosHaveBeenCopied
{ // 照片是否备份过
    NSLog(@"distinguishWhetherPhotosHaveBeenCopied start");
    [_copiedMulArray removeAllObjects];
    [_unCopiedMulArray removeAllObjects];
    
    NSMutableArray *keIndexArr = [Context shareInstance].kePhoIndexArray;
    NSMutableArray *keSecArr = [Context shareInstance].kePhoSectionArray;
    
    // iterate Phone photos' index
    for (int i=0; i<_allPhoMIndexArray.count; i++) {
        NSString *dateStr = _allPhoMIndexArray[i];
        NSString *keformatStr    = [self getKeDateWithDateStr:dateStr];
        NSMutableArray *phArr = _allPhoMSectionArray[i];
        NSInteger index = [keIndexArr indexOfObject:keformatStr];
        
        if (index == NSNotFound) {
            [self appendUncopiedPhos:phArr withTimeDate:dateStr];
        }
        else
        {// iterate ke Photos
            NSMutableArray *keArr = keSecArr[index];
            // 开启多线程
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"线程 ------->-------> %@",[NSThread currentThread].name);
                [weakSelf classifyPhonePhos:phArr accordingTo:keArr timeDate:dateStr];
            });
        }
    }
    
    NSLog(@"distinguishWhetherPhotosHaveBeenCopied end");
}

- (void)classifyPhonePhos:(NSMutableArray *)phArr accordingTo:(NSMutableArray *)keArr timeDate:(NSString *)dateStr
{ // 1>比对照片（名称、大小）; 2>写入对应数组
    NSLog(@" *************** Compare Start %@ (Phone Recycle Done) *************** ",[NSThread currentThread].name);
    NSMutableArray *copiedArr = [NSMutableArray array];
    NSMutableArray *uncopiedArr = [NSMutableArray array];
    
    __weak typeof(self)  weakSelf = self;
    __block NSUInteger recycleCount = phArr.count;
    for (CustomPhotoBean *pBean in phArr) { // 遍历手机相册中的照片
        [pBean getImgData:^(NSData *data, NSString *name, NSString *photoId) {
            BOOL isEqual = NO;
            for (FileBean *fBean in keArr) { // 遍历Ke中的照片
                if ([[fBean getFileName] isEqualToString:name] && [fBean getFileSize]==data.length) {
                    [copiedArr addObject:pBean];
                    isEqual = YES;
                    break;
                }
            }
            
            if (!isEqual) {
                [uncopiedArr addObject:pBean];
            }
            
            // 比对结束
            if (--recycleCount == 0) {
                NSLog(@" *************** Compare End %@ (Phone Recycle Done) *************** ",[NSThread currentThread].name);
                NSLog(@"/n part copiedArrayCount: %lu, unCopiedCount: %lu",(unsigned long)copiedArr.count,uncopiedArr.count);
                
                [weakSelf appendCopiedPhos:copiedArr withTimeDate:dateStr];
                [weakSelf appendUncopiedPhos:uncopiedArr withTimeDate:dateStr];
            }
        }];
    }
}

- (void)appendUncopiedPhos:(NSMutableArray *)partUncopiedPhos withTimeDate:(NSString *)dateStr
{ // 线程互斥
    if (_uncopiedLock == nil) {
        _uncopiedLock = [[NSLock alloc] init];
    }
    
    if (partUncopiedPhos.count <= 0) {
        return ;
    }
    
    // 处理数据
    [_uncopiedLock lock];
    NSLog(@"appendUncopiedPhos locked - timeStamp:%@",dateStr);
    
    NSInteger index = [_unCopiedMulIndexArray indexOfObject:dateStr];
    if (index == NSNotFound) {
        // 排序
        if (_unCopiedMulIndexArray.count > 0) {
            int i = 0;
            for (; i<_unCopiedMulIndexArray.count; i++) {
                NSString *objStr = _unCopiedMulIndexArray[i];
                if ([dateStr compare:objStr options:NSNumericSearch] == NSOrderedAscending) {
                    break;
                }
            }
            
            [_unCopiedMulIndexArray insertObject:dateStr atIndex:i];
            [_unCopiedMulArray insertObject:partUncopiedPhos atIndex:i];
        }
        else
        {
            [_unCopiedMulIndexArray addObject:dateStr];
            [_unCopiedMulArray addObject:partUncopiedPhos];
        }
    }
    else
    {
        NSMutableArray *uncopiedMulArr = _unCopiedMulArray[index];
        [uncopiedMulArr addObjectsFromArray:partUncopiedPhos];
        [_unCopiedMulArray replaceObjectAtIndex:index withObject:uncopiedMulArr];
    }
    
    NSLog(@"appendUncopiedPhos unlocked - date:%@ ,count: %lu",dateStr,partUncopiedPhos.count);
    [_uncopiedLock unlock];
    
    // 是否完成分类
    [self distinguishCompletion];
}

- (void)appendCopiedPhos:(NSMutableArray *)partCopiedPhos withTimeDate:(NSString *)dateStr
{ // 线程互斥
    if (_copiedLock == nil) {
        _copiedLock = [[NSLock alloc] init];
    }
    
    if (partCopiedPhos.count <= 0) {
        return ;
    }
    
    // 处理数据
    [_copiedLock lock];
    NSLog(@"appendCopiedPhos locked - timeStamp:%@",dateStr);
    
    NSInteger index = [_copiedMulIndexArray indexOfObject:dateStr];
    if (index == NSNotFound) {
        // 排序
        if (_copiedMulIndexArray.count > 0) {
            int i = 0;
            for (; i<_copiedMulIndexArray.count; i++) {
                NSString *objStr = _copiedMulIndexArray[i];
                if ([dateStr compare:objStr options:NSNumericSearch] == NSOrderedAscending) {
                    break;
                }
            }
            
            [_copiedMulIndexArray insertObject:dateStr atIndex:i];
            [_copiedMulArray insertObject:partCopiedPhos atIndex:i];
        }
        else
        {
            [_copiedMulIndexArray addObject:dateStr];
            [_copiedMulArray addObject:partCopiedPhos];
        }
    }
    else
    {
        NSMutableArray *copiedMulArr = _copiedMulArray[index];
        [copiedMulArr addObjectsFromArray:partCopiedPhos];
        [_copiedMulArray replaceObjectAtIndex:index withObject:copiedMulArr];
    }
    
    NSLog(@"appendCopiedPhos unlocked - date:%@ ,count: %lu",dateStr,partCopiedPhos.count);
    [_copiedLock unlock];
    
    // 是否完成分类
    [self distinguishCompletion];
}

@end


#pragma mark - *** UIPhotoAlbumHeaderView ***

@interface UIPhotoAlbumHeaderView (){
    TabClickBlock  _clickBlock;
    
    UIView        *_signLine;
    CGFloat        _signLineWitdh;
}

@end

@implementation UIPhotoAlbumHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 3个标签
        NSArray *headTitleArr = @[NSLocalizedString(@"tabuncopiedtitle", @""),NSLocalizedString(@"tabcopiedtitle", @""),NSLocalizedString(@"tabtotaltitle", @"")];
        
        CGFloat itemWidth  = frame.size.width/headTitleArr.count;
        CGFloat itemHeight = frame.size.height;
        
        CGFloat vLineHeight    = 20;
        CGFloat vLineOriY = (self.frame.size.height-vLineHeight)*0.5;
        
        for (int i=0; i < headTitleArr.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:headTitleArr[i] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [btn setTitleColor:BASE_COLOR forState:UIControlStateNormal];
            [btn setTitleColor:BASE_COLOR forState:UIControlStateSelected];
            [btn setFrame:CGRectMake(itemWidth*i, 0, itemWidth, itemHeight)];
            [btn addTarget:self action:@selector(tabButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i+TAGBASE;
            
            [self addSubview:btn];
            
            // 分割线
            if (i != 0) {
                UIView *vLine = [[UIView alloc] init];
                vLine.backgroundColor = [UIColor blackColor];
                vLine.frame = CGRectMake(itemWidth*i, vLineOriY, 1, vLineHeight);
                [self addSubview:vLine];
            }
        }
        
        // 标志线
        _signLineWitdh  = frame.size.width/3;
        
        _signLine = [[UIView alloc] init];
        _signLine.backgroundColor = [UIColor blackColor];
        _signLine.frame = CGRectMake(0, frame.size.height-1, _signLineWitdh, 1);
        [self addSubview:_signLine];
        
        [self reloadButtonSelected:TAGBASE];
    }
    
    return self;
}

#pragma mark - Interfaces
- (void)setPhotoAblumHeaderTabClick:(TabClickBlock)clickBlock
{
    if (clickBlock) {
        _clickBlock = clickBlock;
    }
}

#pragma mark - UIButton Actions

- (void)tabButtonAction:(id)sender
{
    UIButton *tabBtn = (UIButton *)sender;
    
    // tag值 转换为外部函数 需要的参数
    PhotoAlbumHeaderTabClick tabClickIndex = PhotoAlbumHeaderTabClickUncopied;
    switch (tabBtn.tag) {
        case (0+TAGBASE):{
            tabClickIndex = PhotoAlbumHeaderTabClickUncopied;
        }
            break;
        case (1+TAGBASE):
            tabClickIndex = PhotoAlbumHeaderTabClickCopied;
            break;
        case (2+TAGBASE):{
            tabClickIndex = PhotoAlbumHeaderTabClickAll;
        }
            
        default:
            break;
    }
    
    
    // block回调
    if (_clickBlock) {
        _clickBlock(tabClickIndex);
    }
    
    // Button State
    [self reloadButtonSelected:tabBtn.tag];
    // signLine
    [self signLineScroll:tabClickIndex];
}

#pragma mark private methods

- (void)reloadButtonSelected:(NSInteger)btnTag
{
    for (int i=0; i<3; i++) {
        NSInteger curTag = i + TAGBASE;
        UIButton *btn = (UIButton *)[self viewWithTag:curTag];
        btn.selected = (btnTag==curTag)?YES:NO;
    }
}

- (void)signLineScroll:(PhotoAlbumHeaderTabClick)tabClick
{
    CGRect endFrame = [self getSignLineFrameByPhotoAlbumHeaderTabClick:tabClick];
    [UIView animateWithDuration:0.2 animations:^{
        _signLine.frame = endFrame;
    }];
}

- (CGRect)getSignLineFrameByPhotoAlbumHeaderTabClick:(PhotoAlbumHeaderTabClick)tabClick
{
    CGRect signLineFrame = _signLine.frame;
    switch (tabClick) {
        case PhotoAlbumHeaderTabClickUncopied:
            signLineFrame = CGRectMake(0, self.frame.size.height-1, _signLineWitdh, 1);
            break;
        case PhotoAlbumHeaderTabClickCopied:
            signLineFrame = CGRectMake(_signLineWitdh, self.frame.size.height-1, _signLineWitdh, 1);
            break;
        case PhotoAlbumHeaderTabClickAll:
            signLineFrame = CGRectMake(_signLineWitdh*2, self.frame.size.height-1, _signLineWitdh, 1);
            break;
            
        default:
            break;
    }
    
    return signLineFrame;
}


@end

