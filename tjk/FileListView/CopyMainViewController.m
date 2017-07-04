//
//  CopyMainViewController.m
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "CopyMainViewController.h"
#import "CustomNavigationBar.h"
#import "MainViewMenuCell.h"
#import "FileViewController.h"

@interface CopyMainViewController ()<NavBarDelegate,MainViewMenuCellDelegate,UITableViewDataSource,UITableViewDelegate>{
    CustomNavigationBar          *_customNavigationBar;
    UITableView                  *_menuTable;
    BOOL                         _registerNib;
}
@property(nonatomic, retain) NSMutableArray* vcArr;
@end

@implementation CopyMainViewController

-(id)init{
    self = [super init];
    if (self) {
        self.vcArr = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:1], nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"copymaintitle", @"");
    _customNavigationBar.leftBtn.hidden = YES;
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"取消") forState:UIControlStateNormal];
    
    _menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _customNavigationBar.frame.origin.y + _customNavigationBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    _menuTable.delegate = self;
    _menuTable.dataSource = self;
    _menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_menuTable];
    [self.view addSubview:_customNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionNotification:) name:DEVICE_NOTF object:nil];
}

-(void)connectionNotification:(NSNotification*)noti {
    if([noti.object intValue] == CU_NOTIFY_DEVOFF){
         [self.pathDelegate dismissViewController:self];
    }
}


-(void)viewDidLayoutSubviews{
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    CGFloat topViewY = _customNavigationBar.frame.origin.y +_customNavigationBar.frame.size.height;
    _menuTable.frame = CGRectMake(0,topViewY ,
                                SCREEN_WIDTH,
                                38*WINDOW_SCALE);
    CGFloat tableViewOffsetY = topViewY;
    _menuTable.frame = CGRectMake(0,
                                  tableViewOffsetY,
                                  SCREEN_WIDTH,
                                  SCREEN_HEIGHT - tableViewOffsetY);
    _menuTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)clickLeft:(UIButton *)leftBtn{
}

-(void)clickRight:(UIButton *)rightBtn {
    [self.pathDelegate dismissViewController:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_registerNib) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([MainViewMenuCell class]) bundle:nil];
        [_menuTable registerNib:nib forCellReuseIdentifier:@"MenuCell"];
        _registerNib = YES;
    }
    static NSString *CellIdentifier = @"MenuCell";
    MainViewMenuCell*cell = [_menuTable dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.title.text = [self getMenuItemTitle:indexPath.row];
    cell.icon.image = [self getTypeImg:indexPath.row];
    cell.line.frame = CGRectMake(indexPath.row == 3 ? 0 : 70, cell.line.frame.origin.y, self.view.frame.size.width, cell.line.frame.size.height);
    cell.row = indexPath.row;
    cell.clickDelegate = self;
    return cell;
}

-(void)cellClickedAt:(NSInteger)row {
    NSString* title = [self getMenuItemTitle:row];
    int resType = [self getResType:row];
    
    [self gotoResUI:Copy_UI_Type title:title resType:resType toKe:[FileSystem isConnectedKE] animation:YES];
}

-(int)getResType:(NSInteger)row{
    int resType = -1;
    if (row == 0) {
        resType = Picture_Res_Type;
    }
    else if (row == 1) {
        resType = Video_Res_Type;
    }
    else if (row == 2) {
        resType = Music_Res_Type;
    }
    else if (row == 3) {
        resType = Document_Res_Type;
    }
    return resType;
}

-(NSInteger)getPathRow:(NSString*)path{
    if( [path isKindOfClass:[NSNull class]]|| !path){
        return -1;
    }
    if ([path rangeOfString:PHONE_PHOTO].location != NSNotFound || [path rangeOfString:KE_PHOTO].location != NSNotFound) {
        return 0;
    }
    else if ([path rangeOfString:PHONE_VIDEO].location != NSNotFound || [path rangeOfString:KE_VIDEO].location != NSNotFound) {
        return 1;
    }
    else if ([path rangeOfString:PHONE_MUSIC].location != NSNotFound || [path rangeOfString:KE_MUSIC].location != NSNotFound) {
        return 2;
    }
    else if ([path rangeOfString:PHONE_DOC].location != NSNotFound || [path rangeOfString:KE_DOC].location != NSNotFound) {
        return 3;
    }
    return -1;
}

-(NSString*)getPathRoot:(NSString*)path{
    if ([path isKindOfClass:[NSNull class]]) {
        return nil;
    }
    if ([path rangeOfString:PHONE_PHOTO].location != NSNotFound) {
        return PHONE_PHOTO;
    }
    else if ([path rangeOfString:KE_PHOTO].location != NSNotFound) {
        return KE_PHOTO;
    }
    else if ([path rangeOfString:PHONE_VIDEO].location != NSNotFound) {
        return PHONE_VIDEO;
    }
    else if ([path rangeOfString:KE_VIDEO].location != NSNotFound) {
        return KE_VIDEO;
    }
    else if ([path rangeOfString:PHONE_MUSIC].location != NSNotFound) {
        return PHONE_MUSIC;
    }
    else if ([path rangeOfString:KE_MUSIC].location != NSNotFound) {
        return KE_MUSIC;
    }
    else if ([path rangeOfString:PHONE_DOC].location != NSNotFound) {
        return PHONE_DOC;
    }
    else if ([path rangeOfString:KE_DOC].location != NSNotFound) {
        return KE_DOC;
    }
    return nil;
}

-(BOOL)isPathToKe:(NSString*)path{
    if ([path isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    if ([path rangeOfString:PHONE_PHOTO].location != NSNotFound || [path rangeOfString:PHONE_VIDEO].location != NSNotFound || [path rangeOfString:PHONE_MUSIC].location != NSNotFound || [path rangeOfString:PHONE_DOC].location != NSNotFound) {
        return NO;
    }
    else if ([path rangeOfString:KE_PHOTO].location != NSNotFound || [path rangeOfString:KE_VIDEO].location != NSNotFound || [path rangeOfString:KE_MUSIC].location != NSNotFound || [path rangeOfString:KE_DOC].location != NSNotFound) {
        return YES;
    }
    return NO;
}

-(void)setLastCopyPath:(NSString *)lastPath{
    NSInteger row = [self getPathRow:lastPath];
    if (row < 0) {
        return;
    }
    BOOL toKe = [self isPathToKe:lastPath];
    
    if (toKe) {
        if (![FileSystem checkInit]) {
            return;
        }
    }
    else{
        if ([FileSystem isConnectedKE]) {
            return;
        }
    }
    
//    if(toKe && ![FileSystem checkInit]){
//        return;
//    }
    NSString* title = [self getMenuItemTitle:row];
    int resType = [self getResType:row];
    [self gotoResUI:Copy_UI_Type title:title resType:resType toKe:toKe animation:NO];
    NSString* rootPath = [self getPathRoot:lastPath];
    if (![rootPath isEqualToString:lastPath] && [[CustomFileManage instance] existFile:rootPath]) {
        NSArray* subPathNames = [[lastPath substringFromIndex:(rootPath.length + 1)] componentsSeparatedByString:@"/"];
        NSString* parentPath = rootPath;
        for (NSInteger i = 0 ; i < subPathNames.count; i ++) {
            NSString* subTitle = [subPathNames objectAtIndex:i];
            NSString* subPath = [parentPath stringByAppendingPathComponent:subTitle];
            if([[CustomFileManage instance] existFile:subPath]){
                [self gotoNextPathUI:parentPath title:subTitle rootTitle:title resType:resType toKe:toKe];
                parentPath = subPath;
            }
            else {
                break;
            }
        }
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)gotoNextPathUI:(NSString*)parentDir title:(NSString*)title rootTitle:(NSString*)rootTitle resType:(int)resType toKe:(BOOL)toKe{
    FileViewController* copyUI = [[FileViewController alloc] init];
    copyUI.uiType = Copy_UI_Type;
    copyUI.titleStr = title;
    copyUI.resType = resType;
    copyUI.subCopyPath = [parentDir stringByAppendingPathComponent:copyUI.titleStr];
    //    NSLog(@"self.rootStr : %@",self.rootStr);
    copyUI.rootStr = rootTitle;
    copyUI.fromDisplay = toKe ? RIGHT_TAG : LEFT_TAG;
    copyUI.pathDelegate = self.pathDelegate;
    [self.pathDelegate pushViewController:copyUI animation:NO];
}


-(void)gotoResUI:(int)uiType title:(NSString*)title resType:(int)resType toKe:(BOOL)toKe animation:(BOOL)need{
    UIViewController* vc = [self.vcArr objectAtIndex:resType];
    if ([vc isKindOfClass:[NSNumber class]]) {
        FileViewController *newVC = [[FileViewController alloc] init];
        newVC.uiType = uiType;
        newVC.resType = resType;
        newVC.isTypeUIRoot = YES;
        newVC.titleStr = title;
        newVC.pathDelegate = self.pathDelegate;
        [self.vcArr replaceObjectAtIndex:resType withObject:newVC];
        vc = newVC;
    }
    [self.pathDelegate pushViewController:vc animation:need];
    [((FileViewController *)vc) changeTab:toKe ? RIGHT_TAG : LEFT_TAG];
}


-(UIImage*)getTypeImg:(NSInteger)row{
    if (row == 0) {
        return [UIImage imageNamed:@"main_photo.png" bundle:@"TAIG_MainImg.bundle"];
    }
    else if (row == 1) {
        return [UIImage imageNamed:@"main_video.png" bundle:@"TAIG_MainImg.bundle"];
    }
    else if (row == 2) {
        return  [UIImage imageNamed:@"imain_music.png" bundle:@"TAIG_MainImg.bundle"];
    }
    else if (row == 3) {
        return  [UIImage imageNamed:@"main_file.png" bundle:@"TAIG_MainImg.bundle"];
    }
    return nil;
}

-(NSString*)getMenuItemTitle:(NSInteger)row{
    if (row == 0) {
        return NSLocalizedString(@"picture", @"");
    }
    else if (row == 1) {
        return NSLocalizedString(@"video", @"");
    }
    else if (row == 2) {
        return NSLocalizedString(@"music", @"");
    }
    else if (row == 3) {
        return NSLocalizedString(@"document", @"");
    }
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
