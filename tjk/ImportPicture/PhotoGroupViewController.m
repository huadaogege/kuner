          //
//  PhotoGroupViewController.m
//  tjk
//
//  Created by Ching on 15-3-17.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PhotoGroupViewController.h"
#import "PhotoCellView.h"
#import "UIImage+Bundle.h"
#import "TGK_PhotoGroupCell.h"
#import "PreviewViewController.h"

#define MENU_OUT_PICTURE_TAG  55555

@interface PhotoGroupViewController ()<UITableViewDataSource,UITableViewDelegate,NavBarDelegate,BottomEditViewDelegate,CustomEditAlertViewDelegate,PhotoInfoUtiles>
{
    BOOL        _reloadTB;
    BOOL        _cantTouch;
    UIImageView *emptyImgView_;
    UILabel     *messageLab_;
    UILabel     *messageLab2_;
    NSArray     *photoOutArr;
    BOOL        isNeedToLoadData;
    CGPoint     _offset;
    
    CustomNavigationBar      *_customNavigationBar;
}
@end

@implementation PhotoGroupViewController

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _groupAry = [[NSMutableArray alloc] init];
        _photoNumber = [[NSString alloc]init];
        _clickGroup = [[ALAssetsGroup alloc]init];
        
        _reloadTB  = NO;
        _cantTouch = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"picture",@"");
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"cancel",@"") forState:UIControlStateNormal];
    _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
    _customNavigationBar.rightBtn.hidden = NO;
    _customNavigationBar.leftBtn.hidden = YES;
    _customNavigationBar.frame = CGRectMake(0,
                                            20,
                                            [UIScreen mainScreen].bounds.size.width,
                                            44);
    [self.view addSubview:_customNavigationBar];
    
    self.navigationItem.hidesBackButton = YES;
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewScrollPositionNone;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    emptyImgView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_noimage.png" bundle:@"TAIG_PICTURE.bundle"]];
    emptyImgView_.frame = CGRectMake((self.view.bounds.size.width-72.5*WINDOW_SCALE)/2.0 , 120*WINDOW_SCALE, 72.5*WINDOW_SCALE, 72.5*WINDOW_SCALE);
    emptyImgView_.hidden = YES;
    messageLab_ = [[UILabel alloc]init];
    messageLab_.textAlignment = NSTextAlignmentCenter;
    messageLab_.textColor = [UIColor grayColor];
    
    messageLab_.frame = CGRectMake(0 , 205*WINDOW_SCALE, SCREEN_WIDTH, 20*WINDOW_SCALE);
    messageLab_.font = [UIFont systemFontOfSize:17];
    messageLab_.textColor = [UIColor blackColor];
    
    messageLab2_ = [[UILabel alloc]init];
    messageLab2_.textAlignment = NSTextAlignmentCenter;
    messageLab2_.textColor = [UIColor grayColor];
    
    messageLab2_.frame = CGRectMake(0 , 225*WINDOW_SCALE, SCREEN_WIDTH, 20*WINDOW_SCALE);
    messageLab2_.font = [UIFont systemFontOfSize:17];
    messageLab2_.textColor = [UIColor blackColor];
    
    
    messageLab_.hidden = YES;
    messageLab2_.hidden = YES;
    [self.view addSubview:emptyImgView_];
    [self.view addSubview:messageLab_];
    [self.view addSubview:messageLab2_];
    
    UIView *_baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    _baseView.backgroundColor = BASE_COLOR;
    [self.view addSubview:_baseView];
    
    // load data
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(importOver:) name:@"importOver" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initDataToPath) name:GROUP_CHANGE_NOTF object:nil];
    
    [self initDataToPath];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSET_CHANGE_NOTF object:nil]; // 没有注册后期追查原因
}

#pragma mark - PhotoInfoUtiles

-(void)creatGroup:(BOOL)result userInfo:(id)info{
    if (!result) {
        NSLog(@"creatGroup falied");
        [CustomNotificationView showToast:NSLocalizedString(@"newfolderfail", @"")];
    }
    else
    {
        [self initDataToPath];
        NSLog(@"creatGroup success");
    }
}

#pragma mark - BottomEditViewDelegate

-(void)editButtonClickedAt:(NSInteger)tag{
    if (tag == MENU_OUT_PICTURE_TAG) {
        _cantTouch = YES;
        _editAlert = [[CustomEditAlertView alloc] initWithTitle:NSLocalizedString(@"createphotodirname", @"")
                      /*NSLocalizedString(@"newfoldertitle", @"")*/
                                                        message:NSLocalizedString(@"enterphotodirname", @"")
                      /*NSLocalizedString(@"inputfoldername", @"")*/
                                                   defaultLabel:nil];
        _editAlert.delegate = self;
        [_editAlert show:self.view.window];
    }
}

#pragma mark - CustomEditAlertViewDelegate

-(void)alertViewButtonClickedAt:(NSInteger)index withText:(NSString *)text {
    NSString* name = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (index == 1) {
        if(name.length == 0){
            [CustomNotificationView showToast:NSLocalizedString(@"firnillname", @"")];
        }
        else {
            [[PhotoInfoUtiles instance]creatGroup:text delegate:self userInfo:nil];
            _reloadTB = YES;
            
        }
    }
    _cantTouch = NO;
}

#pragma mark - NavBarDelegate

-(void)clickRight:(UIButton *)leftBtn{
    if (_cantTouch)return;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(photoViewdismiss)]) {
            [_delegate photoViewdismiss];
        }
    }];
}

#pragma mark -

-(void)allFrame{
    CGFloat tableheight = self.isOut?self.view.bounds.size.height-64  : self.view.bounds.size.height-64-45;
    _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width,tableheight);
    if (_bottomView) {
        [_bottomView removeFromSuperview];
    }
    if ([PhotoInfoUtiles check]) {
        _bottomView = [[BottomEditView alloc] initWithInfos:
                       [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         NSLocalizedString(@"newpic",@""), @"title" ,
                         [NSNumber numberWithInteger:MENU_OUT_PICTURE_TAG], @"tag" ,
                         @"list_icon-new.png", @"hl_img" ,
                         @"list_icon-new-nouse.png", @"img" ,
                         nil],nil]frame:CGRectMake(0, self.isOut? SCREEN_HEIGHT :SCREEN_HEIGHT- 45 , SCREEN_WIDTH, 45)];
        _bottomView.editDelegate = self;
        [_bottomView setMenuItemWithTag:MENU_OUT_PICTURE_TAG enable:YES reverse:NO];
        [self.view addSubview:_bottomView];
    }
    else{
        _bottomView = nil;
        CGRect frame = _tableView.frame;
        frame.size.height = tableheight + 45;
        
    }
}

-(void)importOver:(NSNotification*)noti{
    [_tableView removeFromSuperview];
    _tableView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(importPhoto:type:)]) {
        [self.delegate importPhoto:noti.object type:_mediaType];
    }
}

-(void)type:(BOOL)isOut moveArr:(NSArray*)movArr showType:(typeCode)showtype resType:(BOOL)isvideoPath{

    self.isResVideoType = isvideoPath;
    self.isOut = isOut;
    self.mediaType =  showtype;
    NSString *title = NSLocalizedString(@"picture",@"");
    if (showtype == TYPE_VIDEO) {
        title = NSLocalizedString(@"phonevideo",@"");
    }
    else{
        if (!self.isOut && self.isResVideoType) {
            title = NSLocalizedString(@"phonephoto",@"");
        }
    }
    
    _customNavigationBar.title.text = title;//(showtype == TYPE_VIDEO?@"手机视频":(self.isResVideoType?@"":NSLocalizedString(@"picture",@"图片")));
    photoOutArr = [[NSArray alloc]init];
    photoOutArr = movArr;
}

-(void)loadData{
    [self initDataToPath];
}

-(void)initDataToPath
{
    [self initnitPathWithRetry:[NSNumber numberWithBool:YES]];
}

-(void)initnitPathWithRetry:(NSNumber*)retry{
    if (retry.boolValue) {
        [[PhotoInfoUtiles instance] resetLib];
    }
    
    [[PhotoInfoUtiles instance]getPhotoGroup:^(NSArray *ary) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ary.count > 0 || !retry.boolValue) {
                [self allFrame];
                [_groupAry removeAllObjects];
                [_groupAry addObjectsFromArray:ary];
                
                if (_groupAry.count>0) {
                    for (int i = 0; i<_groupAry.count; i++) {
                        messageLab_.hidden = YES;
                        messageLab2_.hidden = YES;
                        _tableView.hidden = YES;
                        _tableView.hidden = NO;
                    }
                }
                else
                {
                    messageLab_.hidden = NO;
                    messageLab2_.hidden = NO;
                    _tableView.hidden = YES;
                    [self tishiTitle];
                }
                
                [_tableView reloadData];
                
                if (_reloadTB) {
                    if (_groupAry.count*90*WINDOW_SCALE > _tableView.frame.size.height) {
                        [_tableView setContentOffset:CGPointMake(0,90*WINDOW_SCALE*(_groupAry.count-5) ) animated:YES];
                    }
                    
                    _reloadTB = NO;
                }
            }
            else {
                [self performSelector:@selector(initnitPathWithRetry:) withObject:[NSNumber numberWithBool:NO] afterDelay:1];
            }
        });
    } isHiddenSys:!self.isOut showType:_mediaType];
}

-(void)tishiTitle{
    if ([PhotoInfoUtiles check]) {
        
        if (!self.isOut) {
            if (self.isResVideoType) {
                messageLab_.text = NSLocalizedString(@"phonenotvideotip", @"");
                messageLab2_.hidden = YES;
            }
            else{
                messageLab_.text = NSLocalizedString(@"photounabletosys", @"");
                messageLab2_.hidden = NO;
                messageLab2_.text =  NSLocalizedString(@"pleasreopen",@"");
            }
        }
        else{
            messageLab_.text = self.isResVideoType?NSLocalizedString(@"phonenotvideotiptwo", @""): NSLocalizedString(@"photo_empty",@"");
            messageLab2_.text =  @"";
        }
        
    }
    else
    {
        if ([FileSystem isEngLish]) {
            CGRect frame1 = messageLab_.frame;
            CGFloat height = frame1.size.height;
            frame1.size.height = height *2;
            messageLab_.frame = frame1;
            messageLab_.numberOfLines = 0;
            
            CGRect frame2 = messageLab2_.frame;
            CGFloat originY = frame2.origin.y;
            frame2.origin.y = originY + height;
            messageLab2_.frame = frame2;
        }
        messageLab_.text = NSLocalizedString(@"picture_tishione",@"");
        messageLab2_.text =  NSLocalizedString(@"picture_tishitwo",@"");
    }
    
}
#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _groupAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TGK_PhotoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"group_%d",(int)indexPath.row]];
    
    if(cell == nil){
        cell = [[TGK_PhotoGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"group_%d",(int)indexPath.row]];
    }
    
    if (indexPath.row>=_groupAry.count) {
        return cell;
    }
    
    CustomPhotoGroupBean *group = [_groupAry objectAtIndex:indexPath.row];
    if(group){
        cell.index = (int)indexPath.row;
        [cell setGroupPhotoBean:group mediaType:_mediaType];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row<_groupAry.count) {
        CustomPhotoGroupBean *group = [_groupAry objectAtIndex:indexPath.row];
        
        if (_cantTouch)return;
        
        if(!tableView.editing){
            
            PhonePhotoViewController *phonePhoto = [[PhonePhotoViewController alloc] initWithGroupBean:group TypeCode:_mediaType];
            phonePhoto.titleName = [group getName];
            phonePhoto.isOut = _isOut;
            phonePhoto.isResVideoType = _isResVideoType;
            if (photoOutArr) {
                phonePhoto.oneOutArr = photoOutArr;
            }
            
            [self.navigationController pushViewController:phonePhoto animated:YES];
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90*WINDOW_SCALE;
}

@end
