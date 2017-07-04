//
//  DownloadSelectList.m
//  tjk
//
//  Created by huadao on 15/10/13.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadSelectList.h"
#import "DownloadSelectCell.h"
#import "BottomEditView.h"
#import "DownloadManager.h"
#import "ServiceRequest.h"
#import "DownloadListVC.h"


@interface DownloadSelectList ()<ServiceRequestDelegate>{

    UICollectionView         * _collectionView;
    CustomNavigationBar      * _customNavigationBar;
    CGFloat                  _barOffsetY;
    BottomEditView           *_bomView;
    BOOL                     _selectAll;
    UIImageView              *_newTaskIcon;
    UILabel                  * _downloadnum;
    UIView                       *_downtip;
    NSMutableDictionary *statusDict;
    UILabel                  *tiplabel;

}

@end

@implementation DownloadSelectList

-(id)initWithType:(int)restype setdataArray:(NSArray *)dataArray listurl:(NSString *)url{

    self = [super init];
    if (self) {
        self.restype = restype;
        self.videotype = restype;
        self.dataArray = dataArray;
        self.listurl = url;
        statusDict = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_collectionView reloadData];
    [self refreshCurrentDownloadNum];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.restype == 1) {
        NSDictionary *firstdict = [_dataArray firstObject];
        if (firstdict) {
            NSString *name = [firstdict objectForKey:@"name"];
            if ([name isKindOfClass:[NSString class]] && !([name rangeOfString:@"第"].location != NSNotFound && [name rangeOfString:@"集"].location != NSNotFound)) {
                self.restype = 2;
            }
        }
    }
    _downtip = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 150.0*WINDOW_SCALE_SIX)/2.0,
                                                       SCREEN_HEIGHT-120.0*WINDOW_SCALE_SIX,
                                                       150.0*WINDOW_SCALE_SIX,
                                                       45.0*WINDOW_SCALE_SIX)];
    UIImageView * imagetip = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _downtip.frame.size.width, _downtip.frame.size.height)];
    imagetip.image = [UIImage imageNamed:@"download_list_07" bundle:@"TAIG_ResourceDownload"];
    [_downtip addSubview:imagetip];
    
    tiplabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _downtip.frame.size.width, _downtip.frame.size.height)];
    
    tiplabel.text = self.restype == 0 ? NSLocalizedString(@"musiccacle", @""):NSLocalizedString(@"videocacle", @"");
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.font = [UIFont systemFontOfSize:14.0];
    tiplabel.textColor = [UIColor whiteColor];
    [_downtip addSubview:tiplabel];

    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"close",@"") forState:UIControlStateNormal];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_downloadmanage" bundle:@"TAIG_MainImg"]];
    imgView.frame = CGRectMake(24*WINDOW_SCALE, 12*WINDOW_SCALE, 24*WINDOW_SCALE_SIX, 24*WINDOW_SCALE_SIX);
    [_customNavigationBar.rightBtn setTitle:@"" forState:UIControlStateNormal];
    [_customNavigationBar.rightBtn addSubview:imgView];
    
    _customNavigationBar.title.text = self.videotype == DOWN_TYPE_VIDEO?NSLocalizedString(@"selectvideocecle", @""):NSLocalizedString(@"selectaudiocecle", @"");
    if([self checkisFromYunWith:self.listurl] && self.dataArray.count > 0){
        _customNavigationBar.title.text = NSLocalizedString(@"selectfilececle", @"");
    }
    _barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            _barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - _barOffsetY);
    [_customNavigationBar fitSystem];
     [self.view addSubview:_customNavigationBar];

    
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 0;
    if (self.restype !=1) {
        [flowLayout setItemSize:CGSizeMake(SCREEN_WIDTH-10, 40.0*WINDOW_SCALE_SIX)];
    }else{
        [flowLayout setItemSize:CGSizeMake(66*WINDOW_SCALE_SIX, 40.0*WINDOW_SCALE_SIX)];
    }
    
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.sectionInset = UIEdgeInsetsMake(7.5*WINDOW_SCALE_SIX, 7.5*WINDOW_SCALE_SIX, 7.5*WINDOW_SCALE_SIX, 7.5*WINDOW_SCALE_SIX);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height, SCREEN_WIDTH, self.view.frame.size.height-45-64 + _barOffsetY) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[DownloadSelectCell class] forCellWithReuseIdentifier:@"selectcell"];
    [self.view addSubview:_collectionView];
    
    _bomView = [[BottomEditView alloc] initWithInfos:
                [NSArray arrayWithObjects:
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  @"下载全部", @"title" ,
                  nil],nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
    _bomView.editDelegate = self;
    [self.view addSubview:_bomView];
    
    _newTaskIcon = [[UIImageView alloc] init];
    _downloadnum = [[UILabel alloc]init];
    _downloadnum.textAlignment = NSTextAlignmentCenter;
    _downloadnum.textColor = [UIColor whiteColor];
    _downloadnum.font =[UIFont systemFontOfSize:10.0];
    [self refreshCurrentDownloadNum];
    NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
    [_customNavigationBar.rightBtn addSubview:_newTaskIcon];
    [_customNavigationBar.rightBtn addSubview:_downloadnum];
    _newTaskIcon.hidden = downnum == 0;
    _downloadnum.hidden = downnum == 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentDownload:) name:DOWNCOMPELETE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDeleteNoti:) name:DOWNDELETE_NOTI object:nil];
   
    // Do any additional setup after loading the view.
}

-(void)downloadDeleteNoti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:DOWNDELETE_NOTI]) {
        NSArray *urlstrarr = noti.object;
        for (NSString *urlstr in urlstrarr) {
            NSString* key = [self getStatusKey:urlstr];
            [statusDict setObject:[NSNumber numberWithInt:IN_STATUS_NONEFONND] forKey:key];
        }
    }
}

-(NSString*)getStatusKey:(NSString*)webURL{
    NSInteger location = [webURL rangeOfString:@"subid="].location + 6;
    if ([self checkisFromYunWith:webURL] && location != NSNotFound) {
        return [webURL substringFromIndex:location];
    }
    else {
        return webURL;
    }
}

-(void)refreshCurrentDownload:(NSNotification *)noti{
    
    if ([noti.name isEqualToString:DOWNCOMPELETE_NOTI]) {
        NSString *urlstr = [noti.userInfo objectForKey:@"weburl"];
        NSString* key = [self getStatusKey:urlstr];
        [statusDict setObject:[NSNumber numberWithInt:IN_STATUS_DOWNED] forKey:key];
    }
    
    [self refreshCurrentDownloadNum];
    [_collectionView reloadData];
}
-(void)refreshCurrentDownloadNum{
    
    NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
    [self addTopViewNumber:downnum];
}

-(void)addTopViewNumber:(NSInteger)downnum
{
//    downnum = downnum > 99? 99 :downnum;
    
    if (downnum>=10) {
        _newTaskIcon.frame = CGRectMake(_customNavigationBar.rightBtn.frame.size.width - 21, 13, 20, 15);
        _newTaskIcon.image = [UIImage imageNamed:@"new_2num" bundle:@"TAIG_MainImg"];
    }else{
        _newTaskIcon.frame = CGRectMake(_customNavigationBar.rightBtn.frame.size.width - 21, 13, 15, 15);
        _newTaskIcon.image = [UIImage imageNamed:@"new_1num" bundle:@"TAIG_MainImg"];
        
    }
    _downloadnum.frame = _newTaskIcon.frame;
    _downloadnum.text = [NSString stringWithFormat:@"%lu",(unsigned long)downnum];
    _newTaskIcon.hidden = downnum == 0;
    _downloadnum.hidden = downnum == 0;
}

-(void)clickLeft:(UIButton *)leftBtn{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)clickRight:(UIButton *)leftBtn{
    
    DownloadListVC *listVC = [DownloadListVC sharedInstance];
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DownloadListVC class]]) {
            [vc removeFromParentViewController];
            break;
        }
    }
    
    [self.navigationController pushViewController:listVC animated:YES];
}

-(void)editButtonClickedAt:(NSInteger)tag{

    NSInteger num = [[DownloadManager shareInstance] getDownloadingArray].count;
    NSInteger nums = num;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i=0; i< _dataArray.count; i++) {
        NSDictionary * dic = [self.dataArray objectAtIndex:i];
        
        if (!dic) {
            continue;
        }
        
        if (num >= 99) {
            
            [[DownloadManager shareInstance] showFullDownloadingAlert];
            
            break;
        }
        
        INDOWNLOADMANAGERSTATUS status = [self isDownloadedWithNumber:i fileid:dic];
        if (status!=IN_STATUS_DOWNING&&status!=IN_STATUS_DOWNED) {
            [array addObject:dic];
            NSString *urlKey = [NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dic objectForKey:@"id"]];
            BOOL fromYunPan = [self checkisFromYunWith:self.listurl];
            if(fromYunPan){
                urlKey = [self getStatusKey:urlKey];
            }
            [statusDict setObject:[NSNumber numberWithInt:IN_STATUS_DOWNING] forKey:urlKey];
            DownloadSelectCell *cell = (DownloadSelectCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            [cell setbtnState:IN_STATUS_DOWNING style:self.restype];
            num ++;
        }
    }
    
    [self addTopViewNumber:num];
    if (num > nums) {
         tiplabel.text = NSLocalizedString(@"allcacle", @"");
        [self.view addSubview:_downtip];
        [self performSelector:@selector(downtipremove) withObject:nil afterDelay:1.0];

    }
    
    if (self.downselectdelegate && [self.downselectdelegate respondsToSelector:@selector(downloadJuJiFileWithArray:type:)]) {
        [self.downselectdelegate downloadJuJiFileWithArray:array type:self.videotype];
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.restype !=1) {
        return CGSizeMake(SCREEN_WIDTH-10, 40.0*WINDOW_SCALE_SIX);
    }else{
        return CGSizeMake(66*WINDOW_SCALE_SIX, 40.0*WINDOW_SCALE_SIX);
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selectcell" forIndexPath:indexPath];
    NSDictionary * dic = [self.dataArray objectAtIndex:indexPath.row];
    
    int no = [[dic objectForKey:@"no"]intValue] +1;
    if (self.restype !=1) {
        cell.label.text = [NSString stringWithFormat:@"  %d  %@",no,[dic objectForKey:@"name"]];
        cell.label.textAlignment = NSTextAlignmentLeft;

    }else{
        cell.label.text = [NSString stringWithFormat:@"%d",no];
    }
    INDOWNLOADMANAGERSTATUS status = IN_STATUS_NONEFONND;
    NSString *urlKey = [NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dic objectForKey:@"id"]];
    BOOL fromYunPan = [self checkisFromYunWith:self.listurl];
    if(fromYunPan){
        urlKey = [self getStatusKey:urlKey];
    }
    if ([statusDict valueForKey:urlKey]) {
        NSNumber *statusnum = [statusDict valueForKey:urlKey];
        status = statusnum.intValue;
    }
    else{
        status = [self isDownloadedWithNumber:indexPath.row fileid:dic];
        [statusDict setObject:[NSNumber numberWithInt:status] forKey:urlKey];
    }
    
    [cell setbtnState:status style:self.restype];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        DownloadSelectCell * cell = (DownloadSelectCell*)[collectionView cellForItemAtIndexPath:indexPath];
        NSDictionary * dic = [self.dataArray objectAtIndex:indexPath.row];
    
        INDOWNLOADMANAGERSTATUS status = [self isDownloadedWithNumber:indexPath.row fileid:dic];

        if (status!=IN_STATUS_DOWNING&&status!=IN_STATUS_DOWNED) {
            NSInteger downnum = [[[DownloadManager shareInstance]getDownloadingArray]count];
            
            if (downnum >= 99) {
                [[DownloadManager shareInstance] showFullDownloadingAlert];
                return;
            }
            
            downnum = downnum + 1;
            [self addTopViewNumber:downnum];
            if (self.downselectdelegate && [self.downselectdelegate respondsToSelector:@selector(downloadJuJiFileWith:type:)]) {
                BOOL fromYunPan = [self checkisFromYunWith:self.listurl];
                if(fromYunPan){
                    NSString* key = [self getStatusKey:[dic objectForKey:@"id"]];
                    [statusDict setObject:[NSNumber numberWithInt:IN_STATUS_DOWNING] forKey:key];
                }
                else {
                    NSString *urlKey = [NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dic objectForKey:@"id"]];
                    [statusDict setObject:[NSNumber numberWithInt:IN_STATUS_DOWNING] forKey:urlKey];
                    
                }
                [self.downselectdelegate downloadJuJiFileWith:dic type:self.videotype];
            }
//            [self download:[NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dic objectForKey:@"id"]]];
            [cell setbtnState:IN_STATUS_DOWNING style:self.restype];
            tiplabel.text = NSLocalizedString(@"indownloadlist", @"");//self.restype == 0 ? NSLocalizedString(@"musiccacle", @""):NSLocalizedString(@"videocacle", @"");
            [self.view addSubview:_downtip];
            [self performSelector:@selector(downtipremove) withObject:nil afterDelay:1.0];
        }
    
}

#pragma mark -

-(BOOL)checkisFromYunWith:(NSString *)url
{
    NSString* BDUSS = [[NSUserDefaults standardUserDefaults] objectForKey:@"BDUSS"];
    BOOL fromYunPan = ([url rangeOfString:@"pan.baidu.com"].location != NSNotFound || [url rangeOfString:@"yun.baidu.com"].location != NSNotFound) && BDUSS;
    return fromYunPan;
}

-(void)downtipremove{
    [UIView animateWithDuration:1.0 animations:^{
        [_downtip removeFromSuperview];
    }];

}
-(INDOWNLOADMANAGERSTATUS)isDownloadedWithNumber:(NSInteger)number fileid:(NSDictionary *)dict{
    NSString* tmpUrl;
    NSString *itemname;
    tmpUrl = [NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dict objectForKey:@"id"]];
    BOOL fromYunPan = [self checkisFromYunWith:self.listurl];
    if(fromYunPan){
        tmpUrl = [self getStatusKey:tmpUrl];
    }
    itemname = [[_dataArray objectAtIndex:number] objectForKey:@"name"];
    
    itemname = [itemname stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
//    itemname = [itemname stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    itemname = [DownloadTask dealWithPointChar:itemname deletingPathExtension:NO];
    
    if(fromYunPan && ![tmpUrl isEqualToString:[NSString stringWithFormat:@"%@&subid=%@",self.listurl,[dict objectForKey:@"id"]]]){
        return [[DownloadManager shareInstance] isdownloadingBaiDuYunInListWith:tmpUrl name:itemname];
    }
    else if (self.videotype == 0 &&[tmpUrl isKindOfClass:[NSString class]] &&[tmpUrl rangeOfString:@"http://music.baidu.com"].location != NSNotFound) {
        return [[DownloadManager shareInstance] isMusicSameNameAndDiffFpathIndownloadingListWith:tmpUrl name:itemname];
    }
    else{
       return [[DownloadManager shareInstance] isdownloadingInListWith:tmpUrl name:itemname];
    }
}

-(void)download:(NSString *)url{
    [[ServiceRequest instance] requestService:nil urlAddress:url info:nil delegate:self isBanben:NO];
}

-(void)resultSuccess:(NSData *)data info:(id)info isBanben:(BOOL)isbanben originUrl:(NSString *)url{
    NSDictionary* weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSArray* list  = [weatherDic objectForKey:@"list"];
    NSString *type = (NSString *)[weatherDic objectForKey:@"video"];
    
    int restype = type.intValue;//? type.intValue : TYPE_VIDEO;
    
    if (list && ![list isEqual:[NSNull null]] && list.count > 0) {
//        nowlist = list;
//        nowtype = restype;
//        nowDict = weatherDic;
        
//        if (self.downselectdelegate && [self.downselectdelegate respondsToSelector:@selector(downloadSingleFileWith:filetype:webUrl:isMore:)]) {
//            [self.downselectdelegate downloadSingleFileWith:list filetype:restype webUrl:url isMore:YES];
//        }
        
    }
    else{
       
    }
}

-(void)resultFaile:(NSError *)error info:(id)info
{
    
}

-(void)dealloc{
    NSLog(@"DownloadSelectList dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.downselectdelegate = nil;
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
