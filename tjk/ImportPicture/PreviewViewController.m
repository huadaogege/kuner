//
//  PreviewViewController.m
//  tjk
//
//  Created by Ching on 15-3-17.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PreviewViewController.h"
#import "HomeCell.h"
#import "UIImage+Bundle.h"
#import "FilterLoading.h"
#import "VideoViewController.h"
#import "TGK_FFPlayerViewController.h"
#import "MusicPlayerViewController.h"
#import "CustomNotificationView.h"
#import "WXApi.h"
#import "ShareToHelper.h"
#import "KxMovieViewController.h"
#import "FileViewController.h"
#import "MobClickUtils.h"

#define MENU_COPY_PICTURE_TAG  520
#define MENU_DELET_PICTURE_TAG 521
#define DELETE_ALERT_TAG       522
#define MENU_SHARE_PICTURE_TAG  523

#define CRotate  (M_PI/180.0)

static NSString *homeCellIden = @"HomeCellIdentifier";

@interface PreviewViewController ()
{
    BOOL                    _isFullSCreenBrowser;
    BOOL                    _isPlaying;
    UIView                  *_baseView;
    UIView                  *_deletPhotoING;
    UIImage                 *_lastOneImage;
    NSIndexPath             *_firstIndext;
    NSMutableDictionary     *_videoDic;
    CustomNavigationBar     *_customNavigationBar;
    VideoViewController     *Viedeoview;
    dispatch_queue_t        _dispatchQueue;
    BottomEditView          *_bottomView;
    HomeCell                *_nowCell;
    UIView                  *_shareToView;
    BOOL                    isSendWChat;
    UIView *_contanierView;
    
    UIWindow *_window;
    KxMovieViewController        *_player;
    CGFloat hheight;
    CGFloat wwidth;
    
    int lastOrientation;
    BOOL isLandscape;
    UIInterfaceOrientation theOrientation;
    CGFloat angle;
    
    CGRect deleteOriginFrame;
    CGRect titleOriginFrame;
    CGRect rightOriginFrame;
    
    CGFloat deleteViewRightBlock;
    CGFloat rightBtnRightBlock;
    
    BOOL isRotate;
    BOOL _toShare;
}
@end

@implementation PreviewViewController

-(UIInterfaceOrientation)getOrientation
{
    return theOrientation;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //        CGRect bounds = [UIScreen mainScreen].bounds;
        
        _photoArray = [[NSMutableArray alloc]init];
        _videoDic = [[NSMutableDictionary alloc]init];
        
        theOrientation = UIInterfaceOrientationPortrait;
        
        wwidth = [UIScreen mainScreen].bounds.size.width;
        hheight = [UIScreen mainScreen].bounds.size.height;
        
        self.view.backgroundColor = BASE_COLOR;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        _contanierView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _contanierView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_contanierView];
        
        _isFullSCreenBrowser = NO;
        _isPlaying = NO;
        _firstIndext = [[NSIndexPath alloc]init];
//        _deletPhotoING = [[UIView alloc]init];
//        _deletPhotoING.frame = [[UIScreen mainScreen] bounds];
//        _deletPhotoING.backgroundColor = [UIColor blackColor];
//        _deletPhotoING.alpha = 0.5;
//        _lastOneImage = [[UIImage alloc]init];
        //collctionView
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _contanierView.frame.size.width + 40, _contanierView.frame.size.height) collectionViewLayout:layout];
        [collectionView registerClass:[HomeCell class] forCellWithReuseIdentifier:homeCellIden];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 40);
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView = collectionView;
        
        [_contanierView addSubview:self.collectionView];
        
        _baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,_contanierView.frame.size.width, 20)];
        _baseView.backgroundColor = BASE_COLOR;
        [_contanierView addSubview:_baseView];
        
        _customNavigationBar = [[CustomNavigationBar alloc] init];
        _customNavigationBar.delegate = self;
        CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
        _customNavigationBar.frame = CGRectMake(0,
                                                barOffsetY,
                                                [UIScreen mainScreen].bounds.size.width,
                                                64 - barOffsetY);
        [_customNavigationBar fitSystem];
        
        _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
        
        [_contanierView addSubview:_customNavigationBar];
        titleOriginFrame = _customNavigationBar.title.frame;
        
        rightOriginFrame = _customNavigationBar.rightBtn.frame;
        rightBtnRightBlock = _customNavigationBar.frame.size.width - rightOriginFrame.origin.x;
        //删除按钮
        
//        [_customNavigationBar.rightBtn setTitle:@"分享" forState:UIControlStateNormal];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_sharebtn_icon.png" bundle:@"TAIG_FILE_LIST.bundle"]];
        //        imgView.contentMode = UIViewContentModeCenter;
        imgView.frame = CGRectMake(24*WINDOW_SCALE, 12*WINDOW_SCALE, 24*WINDOW_SCALE_SIX, 24*WINDOW_SCALE_SIX);
        [_customNavigationBar.rightBtn setTitle:@"" forState:UIControlStateNormal];
        [_customNavigationBar.rightBtn addSubview:imgView];
        
        
//        if (IS_SHOWOTHER_LANGUAGE) {
//            _customNavigationBar.rightBtn.hidden = ![FileSystem isChinaLan];
//        }
//        else{
//            _customNavigationBar.rightBtn.hidden = NO;
//        }
        
        _customNavigationBar.rightBtn.hidden = YES;
        
//        _customNavigationBar.rightBtn = nil;
//        _customNavigationBar.rightBtn.backgroundColor = [UIColor clearColor];
//        UIImageView *btnBack = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 32*WINDOW_SCALE, 11*WINDOW_SCALE, 16*WINDOW_SCALE, 20*WINDOW_SCALE)];
//        btnBack.image = [UIImage imageNamed:@"icon_top_delete.png" bundle:@"TAIG_PICTURE.bundle"];
//        [_customNavigationBar addSubview:btnBack];
        
        

        _dispatchQueue  = dispatch_queue_create("HomeViewController", DISPATCH_QUEUE_SERIAL);
        
        NSMutableArray *array = [NSMutableArray arrayWithObjects:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  NSLocalizedString(@"copy",@""), @"title" ,
                                  @"list_icon-copy-nouse", @"img" ,
                                  @"list_icon-copy", @"hl_img" ,
                                  [NSNumber numberWithInteger:MENU_COPY_PICTURE_TAG], @"tag" ,
                                  nil],
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  NSLocalizedString(@"delete",@""), @"title" ,
                                  @"list_icon-delete-nouse", @"img" ,
                                  @"list_icon-delete", @"hl_img" ,
                                  @"1", @"is_delete" ,
                                  [NSNumber numberWithInteger:MENU_DELET_PICTURE_TAG], @"tag" ,
                                  nil],
                                 nil];
        
        BOOL isshow = ((IS_SHOWOTHER_LANGUAGE && [FileSystem isChinaLan]) || !IS_SHOWOTHER_LANGUAGE);
        if (isshow) {
            [array insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 NSLocalizedString(@"share",@""), @"title" ,
                                 @"list_icon_share_nouse", @"img" ,
                                 @"list_icon_share", @"hl_img" ,
                                 [NSNumber numberWithInteger:MENU_SHARE_PICTURE_TAG], @"tag" ,
                                 nil] atIndex:0];
        }
        _bottomView = [[BottomEditView alloc] initWithInfos:array
                        frame:CGRectMake(0, _contanierView.frame.size.height - 45, _contanierView.frame.size.width, 45)];
        _bottomView.editDelegate = self;
        [_contanierView addSubview:_bottomView];
        [_bottomView setMenuItemWithTag:MENU_COPY_PICTURE_TAG enable:YES reverse:NO];
        [_bottomView setMenuItemWithTag:MENU_DELET_PICTURE_TAG enable:YES reverse:NO];
        [_bottomView setMenuItemWithTag:MENU_SHARE_PICTURE_TAG enable:YES reverse:NO];
        int tag = isshow? 102 : 101;
        UIView *deleteView = [_bottomView viewWithTag:tag];
        deleteOriginFrame = deleteView.frame;
        deleteViewRightBlock = _bottomView.frame.size.width - deleteView.frame.origin.x;
        
        [self setUpAllViewsMargin];
        
    }
    return self;
}


-(void)editButtonClickedAt:(NSInteger)tag{
    if (tag == MENU_COPY_PICTURE_TAG) {
        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(needCopyItemWith:)]) {
            self.isPresentView = YES;
            [self.scanDelegate needCopyItemWith:self.photoArray[self.nowPhotoNum]];
        }
    }
    else if (tag == MENU_DELET_PICTURE_TAG) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
                                  /*(self.resType == Music_Res_Type?@"确定要删除所选歌单吗？" :*/
                                  NSLocalizedString(@"deletefilesy", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
        alertView.tag = DELETE_ALERT_TAG;
        [alertView show];
  
        
    }
    else if (tag == MENU_SHARE_PICTURE_TAG) {
        [self showShareToView];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == DELETE_ALERT_TAG && buttonIndex==1) {
        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(needRemoveItemWith:)]) {
            [self.scanDelegate needRemoveItemWith:self.photoArray[self.nowPhotoNum]];
        }
    }

}
-(void)removeOverReloadArray:(NSArray*)arr{
    [self.photoArray removeAllObjects];
    [_videoDic removeAllObjects];
    if (arr.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.photoArray addObjectsFromArray:arr];
        [self.collectionView reloadData];
        [self flashTitle];
    }
    
}
-(void)allPhotoArr:(NSMutableArray *)allArr nowNum:(NSInteger)nowNum fromDownList:(BOOL)isDowned{
    
    [self.photoArray removeAllObjects];
    [_videoDic removeAllObjects];
    [self.photoArray addObjectsFromArray:allArr];
    
    [allArr removeAllObjects];
    allArr = nil;
    
    self.nowPhotoNum = nowNum;
    self.isFromDown = isDowned;
}

-(void)dealloc{
    [self.photoArray removeAllObjects];
    self.photoArray = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (!self.scanDelegate){
        _bottomView.hidden = YES;
        _customNavigationBar.rightBtn.hidden = YES;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopMov)
                                                name:@"stopMov"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSingleTap)
                                                 name:@"handleSingleTap"
                                               object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.collectionView reloadData];
    _firstIndext = [NSIndexPath indexPathForItem:self.nowPhotoNum inSection:0];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.nowPhotoNum inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:YES];
    
    if (self.isPresentView) {
        self.isPresentView = NO;
        if (isLandscape) {
            isLandscape = NO;
            [self didlayoutViews:NO];
        }
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"handleSingleTap" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopMov" object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(scanedItemWith:)] && self.photoArray.count > self.nowPhotoNum) {
        [self.scanDelegate scanedItemWith:self.photoArray[self.nowPhotoNum]];
    }
}

-(void)clickLeft:(UIButton *)leftBtn{
    
    if (!_isPlaying) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[FilterLoading instance] clearCache];
}


#pragma mark - share to

-(void)clickRight:(UIButton *)leftBtn
{
    
}

-(void)showShareToView
{
    if (![FileSystem isChinaLan] && IS_SHOWOTHER_LANGUAGE) {
        return;
    }
    if (_shareToView == nil) {
        
        float scale = 1.0;//wwidth / 375.0;
        
        _shareToView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _shareToView.backgroundColor = [UIColor clearColor];
        
        UIButton *maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        maskBtn.frame = _shareToView.frame;
        maskBtn.backgroundColor = [UIColor blackColor];
        maskBtn.alpha = 0;
        maskBtn.tag = 1110;
        [maskBtn addTarget:self action:@selector(shareToMaskBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [_shareToView addSubview:maskBtn];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 180*scale + 50)];
        bottomView.backgroundColor = [UIColor clearColor];
        bottomView.tag = 1111;
        [_shareToView addSubview:bottomView];
        
        UIView *bottomContanier = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height)];
        bottomContanier.backgroundColor = [UIColor whiteColor];
        bottomContanier.alpha = 0.9;
        [bottomView addSubview:bottomContanier];
        
        UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,28*scale ,bottomView.frame.size.width, 20*scale)];
        shareLabel.font = [UIFont systemFontOfSize:15.0];
        shareLabel.text = NSLocalizedString(@"shareto", @"");
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.textColor = [UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:1];
        [bottomView addSubview:shareLabel];
        
        NSArray *nameArray = [NSArray arrayWithObjects:NSLocalizedString(@"wxfriend", @""),NSLocalizedString(@"wxcircle", @""),NSLocalizedString(@"more", @""), nil];
        NSArray *iconArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"list_shareto_wxfriend.png" bundle:@"TAIG_FILE_LIST.bundle"],[UIImage imageNamed:@"list_shareto_wxcircle.png" bundle:@"TAIG_FILE_LIST.bundle"],[UIImage imageNamed:@"list_shareto_more.png" bundle:@"TAIG_FILE_LIST.bundle"], nil];
        
        int iconCount = (int)nameArray.count;
        CGFloat shareIconwidth = 60*scale;
        CGFloat blockwidth = 38*scale;//(bottomView.frame.size.width - shareIconwidth * iconCount) / (iconCount + 1);
        CGFloat midblock = (bottomView.frame.size.width - 2*blockwidth - shareIconwidth*iconCount) /(iconCount - 1);
        
        for (int i = 0; i< nameArray.count; i++) {
            UIButton *firstBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [firstBtn setImage:[iconArr objectAtIndex:i] forState:UIControlStateNormal];
            firstBtn.tag = (i+1);
//            [firstBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
            firstBtn.frame = CGRectMake(blockwidth+shareIconwidth*i + midblock*i, 65*scale, shareIconwidth, shareIconwidth);
            [firstBtn addTarget:self action:@selector(shareToBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [bottomView addSubview:firstBtn];
            
            UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(firstBtn.frame.origin.x - 10 - 15, firstBtn.frame.origin.y + firstBtn.frame.size.height, firstBtn.frame.size.width + 20 + 30, 35*scale)];
            firstLabel.font = [UIFont systemFontOfSize:11.0];
            firstLabel.text = [nameArray objectAtIndex:i];
            firstLabel.textColor = [UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:1];
            firstLabel.textAlignment = NSTextAlignmentCenter;
            [bottomView addSubview:firstLabel];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, bottomView.frame.size.height - 50, bottomView.frame.size.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:197.0/255.0 green:198.0/255.0 blue:200.0/255.0 alpha:1];
        [bottomView addSubview:line];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, bottomView.frame.size.height - 50, bottomView.frame.size.width, 50);
        [cancelBtn addTarget:self action:@selector(shareToMaskBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.backgroundColor = [UIColor clearColor];
        [bottomView addSubview:cancelBtn];
        
        UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cancelBtn.frame.size.width, cancelBtn.frame.size.height)];
        cancelLabel.text = NSLocalizedString(@"cancel", @"");
        cancelLabel.textAlignment = NSTextAlignmentCenter;
        cancelLabel.textColor = [UIColor colorWithRed:29/255.0f green:137/255.0f blue:250.0/255.0f alpha:1];
        cancelLabel.font = [UIFont systemFontOfSize:16];
        [cancelBtn addSubview:cancelLabel];
        cancelLabel.userInteractionEnabled = NO;
        
    }
    
    _shareToView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [_contanierView addSubview:_shareToView];
    
    UIView *bottomView = [_shareToView viewWithTag:1111];
    UIView *maskBtn = [_shareToView viewWithTag:1110];
    [UIView animateWithDuration:.3 animations:^{
        maskBtn.alpha = 0.5;
        bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - bottomView.frame.size.height, [UIScreen mainScreen].bounds.size.width, bottomView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];

}

-(void)shareToMaskBtnPressed
{
    UIView *bottomView = [_shareToView viewWithTag:1111];
    UIView *maskBtn = [_shareToView viewWithTag:1110];
    [UIView animateWithDuration:.3 animations:^{
        maskBtn.alpha = 0;
        bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, bottomView.frame.size.height);
    } completion:^(BOOL finished) {
        [_shareToView removeFromSuperview];
        _shareToView = nil;
    }];
}

-(void)shareToBtnPressed:(UIButton *)sender
{
    HomeCell *cell = (HomeCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.nowPhotoNum inSection:0]];
    
    [self shareToMaskBtnPressed];
    FileBean *bean;
    if (self.nowPhotoNum<self.photoArray.count) {
        bean = [self.photoArray objectAtIndex:self.nowPhotoNum];
    }
    if (bean.fileType == FILE_GIF) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"sorrytosharegif", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if (cell.photoView.imageView.tag == HOMECELL_GET_IMAGE) {
        
        if (sender.tag == 2) {
            isSendWChat = [ShareToHelper sendImageContentWith:cell.photoView.imageView.image scene:WXSceneTimeline];
        }
        else if (sender.tag == 1)
        {
            isSendWChat = [ShareToHelper sendImageContentWith:cell.photoView.imageView.image scene:WXSceneSession];
        }
        else{
            [self showSystemShare:cell.photoView.imageView.image];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"notgetphotodetail", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        [alert show];
    }
}

-(void)showSystemShare:(UIImage *)image
{
    _toShare = YES;
    [FileSystem rotateWindow:NO];
    dispatch_async(dispatch_queue_create(0, 0), ^{
        // 首先初始化activityItems参数
        NSArray *activityItems = [[NSArray alloc]initWithObjects:@"",@"",
                                  image,nil];
        
        // 初始化一个UIActivityViewController
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:Nil];
        
        // 写一个bolck，用于completionHandler的初始化
        UIActivityViewControllerCompletionHandler myBlock = ^(NSString *activityType,BOOL completed) {
            [activityVC dismissViewControllerAnimated:YES completion:Nil];
            _toShare = NO;
        };
        
        activityVC.completionHandler = myBlock;
        
        // 以模态方式展现出UIActivityViewController
        
        
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
        {
            // iOS 8+
            //        UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
            //
            //        presentationController.sourceView = self.view; // if button or change to self.view.
            
            activityVC.modalPresentationStyle = UIModalPresentationPopover;
            // 取出vc所在的UIPopoverPresentationController
            
            activityVC.popoverPresentationController.sourceView = self.view;
            
            activityVC.popoverPresentationController.sourceRect = self.view.bounds;
            
            
        }
       dispatch_async(dispatch_get_main_queue(), ^{
           [self presentViewController:activityVC animated:YES completion:nil];
       });
    });
    
    
}

-(BOOL)showingShareUI {
    return _toShare;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    return self.photoArray.count;
}


#pragma mark -  Clle赋值
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.nowPhotoNum = indexPath.row;
    [self flashTitle];
    HomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:homeCellIden forIndexPath:indexPath];
    if (indexPath.row>=self.photoArray.count) {
        return cell;
    }
    FileBean *bean = [self.photoArray objectAtIndex:indexPath.row];
    [self cellChangeView:cell];
    [self cellAddPlayBtn:cell suffixStr:bean  indexParh:indexPath];
    [cell BigPictor:bean];
    cell.filetype = bean.fileType;
    [[MusicPlayerViewController instance]removeNewIdentify:bean.filePath];
    
    if ([bean getFileType] != FILE_MOV) {
        
        [cell.photoView addTapGesture];
//        NSData *thedata = [bean getFileData];
////        [cell setimage:[UIImage imageWithData:thedata]];
//        cell.scrollview.hidden = YES;
//        cell.gifScrollview.hidden = NO;
//        [cell addGif:thedata];
        cell.gifScrollview.hidden = bean.fileType != FILE_GIF;
        cell.photoView.hidden = !cell.gifScrollview.hidden;
        
//        [FilterLoading instance].delegate = nil;
//        [FilterLoading instance].delegate = cell;
        
        if (!isRotate || bean.fileType == FILE_GIF) {
            [[FilterLoading instance]needMessage:bean allPhoneArr:self.photoArray];
            if(bean.fileType == FILE_GIF)
            {
                isRotate = NO;
            }
        }
        else{
            isRotate = NO;
        }
        
    }else{
        
        [[CustomFileManage instance]getFileIconForBlock:bean info:nil block:^(UIImage *img, id info) {
            if (img) {
                [cell setimage:img];
            }
        }];
    };
    
    return cell;
}

#pragma mark 手势相应事件
- (void)handleSingleTap
{
    _isFullSCreenBrowser = !_isFullSCreenBrowser;
    [self isSelect:_isFullSCreenBrowser];
}
-(void)isSelect:(BOOL)isSelect{
    
    [[UIApplication sharedApplication] setStatusBarHidden:isSelect withAnimation:UIStatusBarAnimationNone];
    
    [UIView animateWithDuration:0.0 animations:^{
        //        self.collectionView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height);
        if(isSelect){
            
            //            [self.navigationController setNavigationBarHidden:YES animated:NO];
            self.collectionView.backgroundColor = [UIColor blackColor];
            _baseView.alpha = 0;
            _bottomView.alpha = 0;
            _customNavigationBar.alpha = 0;
        }else{
            _baseView.alpha = 1;
            _bottomView.alpha = 1;
            _customNavigationBar.alpha = 1;
            self.collectionView.backgroundColor = [UIColor whiteColor];
            //            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }];
    
}

-(void)cellChangeView:(HomeCell*)cell{
    
//    [cell.scrollview setZoomScale:1.0];
//    cell.scrollview.contentOffset = CGPointMake(0.0, 0.0);
    [cell addPhotoView:isRotate];
    
    cell.olImageView.frame = cell.bounds;
//    cell.imageView.frame = cell.bounds;
    cell.gifScrollview.frame = cell.bounds;
    
//    cell.gifScrollview.hidden = YES;
//    cell.scrollview.hidden = NO;
//    cell.imageView.image = nil;
//    cell.imageView.hidden = NO;
    cell.olImageView.image = nil;
}
-(void)cellAddPlayBtn:(HomeCell*)cell suffixStr:(FileBean *)bean  indexParh:(NSIndexPath*)indexPath{
    cell.playBtn.frame = CGRectMake((_contanierView.frame.size.width-cell.playBtn.frame.size.width)/2.0, (_contanierView.frame.size.height-cell.playBtn.frame.size.height)/2.0, cell.playBtn.frame.size.width, cell.playBtn.frame.size.height);
    cell.playBenBack.frame = cell.playBtn.frame;
    if ([bean getFileType] == FILE_MOV) {
        _nowCell = cell;
        cell.playBtn.tag = indexPath.row;
        
        [cell.playBtn addTarget:self action:@selector(playNowVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell addPlayBtn];
        [_videoDic setValue:bean forKey:[NSString stringWithFormat: @"%ld",(long)indexPath.row ]];
    }
    else{
        [cell hiddenBtnAndBackView];
    }
}
-(void)isCantDo:(BOOL)isCan{
    
    [_bottomView setMenuItemWithTag:MENU_COPY_PICTURE_TAG enable:isCan reverse:NO];
    [_bottomView setMenuItemWithTag:MENU_DELET_PICTURE_TAG enable:isCan reverse:NO];
    _isPlaying = !isCan;
}
- (void)playNowVideo:(UIButton *)btn{
    _nowCell.playBtn.hidden = YES;
    
    [self isCantDo:NO];
    FileBean *bean = [_videoDic objectForKey:[NSString stringWithFormat: @"%ld",(long)btn.tag]];
    NSString *path = bean.filePath;
    NSURL *url;
    if ([bean getFilePosition] == POSITION_HARDDISK) {
        url = [FileSystem changeURL:path];
    }else{
        url = [NSURL fileURLWithPath:path];
    }
    [self playerVideo:url];
}

-(void)playerVideo:(NSURL *)url{
    
    
    
    [[MusicPlayerViewController instance] setMovPlay:YES];
    if ([[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
        [[MusicPlayerViewController instance]playorpause];
    }
    
//    if (IS_USEDEFAULTPLAYER && [VIDEO_IOS_FORMAT objectForKey:[url.absoluteString pathExtension]]) {
    Viedeoview = [[VideoViewController alloc] init];
    //    Viedeoview.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    [[MusicPlayerViewController instance] setMovPlay:NO];
    MPMoviePlayerController *player = [Viedeoview moviePlayer];
    player.controlStyle = MPMovieControlStyleNone;
    
    [Viedeoview setVideo:url progress:0.0];
    [Viedeoview play];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    Viedeoview.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    Viedeoview.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self.view addSubview:Viedeoview.view];
    [UIView animateWithDuration:0.3 animations:^{
        
        Viedeoview.view.frame = CGRectMake(0,
                                           0,
                                           [UIScreen mainScreen].bounds.size.width,
                                           [UIScreen mainScreen].bounds.size.height);
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBarHidden = YES;

//    if (![Viedeoview canBePlaying]) {
//        [CustomNotificationView showToast:@"透传" rootView:self.view.window];
//        return;
//    }
}

-(void)stopMov{
    _nowCell.playBtn.hidden = NO;
    [self isCantDo:YES];
    [CustomNotificationView showToast:NSLocalizedString(@"movplayfail", @"")];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        //        self.navigationController.navigationBarHidden = NO;
    [FileSystem clearKeVideoURL];
    [UIView animateWithDuration:0.3 animations:^{
        
        Viedeoview.view.frame = CGRectMake(0,
                                           [UIScreen mainScreen].bounds.size.height,
                                           [UIScreen mainScreen].bounds.size.width,
                                           [UIScreen mainScreen].bounds.size.height);
        
    } completion:^(BOOL finished) {
        [Viedeoview removeFromParentViewController];
        [Viedeoview.view removeFromSuperview];
        [Viedeoview stop];
        Viedeoview = nil;
        
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}
- (void)FinishedCallback:(NSNotification *)notify{
    
        if ([Viedeoview moviePlayer] == [notify object]) {
            _nowCell.playBtn.hidden = NO;
            [self isCantDo:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            //        self.navigationController.navigationBarHidden = NO;
            [Viedeoview stop];
            [FileSystem clearKeVideoURL];
            [UIView animateWithDuration:0.3 animations:^{
                
                Viedeoview.view.frame = CGRectMake(0,
                                                   [UIScreen mainScreen].bounds.size.height,
                                                   [UIScreen mainScreen].bounds.size.width,
                                                   [UIScreen mainScreen].bounds.size.height);
                
            } completion:^(BOOL finished) {
                [Viedeoview.view removeFromSuperview];
                
                [Viedeoview removeFromParentViewController];
                Viedeoview = nil;
               
            }];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新title
    [self flashTitle];
    
}
- (void)flashTitle
{
    int contentOfSetX = self.collectionView.contentOffset.x;
    int backWidth = [UIScreen mainScreen].bounds.size.width + 40;
    _nowPhotoNum = contentOfSetX / backWidth ;
    int titleIndex = (int)(contentOfSetX % backWidth > backWidth/2 ? _nowPhotoNum + 2 : _nowPhotoNum + 1) ;
    if (self.isFromDown) {
        _customNavigationBar.title.text = @"";
    }else{
        _customNavigationBar.title.text = [NSString stringWithFormat:@"%d/%lu",titleIndex,(unsigned long)self.photoArray.count];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//        return UIEdgeInsetsMake(0, 0, 0, 20);
    return UIEdgeInsetsZero;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 40.0f;
}

//-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 40.0f;
//}


#pragma mark - rotate


-(void)setUpAllViewsMargin
{
    _contanierView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
//    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    _baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
//    _customNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
//    _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    UIView *copyView = [_bottomView viewWithTag:100];
//    UIView *deleteView = [_bottomView viewWithTag:101];
//    copyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    deleteView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
}

- (void)orientationDidChange:(NSNotification *)note
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (lastOrientation == orientation) {
        return;
    }
    
    BOOL isget = YES;
    CGFloat lastangle = angle;
    UIInterfaceOrientation ori = UIInterfaceOrientationPortrait;
    if (orientation == UIDeviceOrientationLandscapeRight) {
        ori = UIInterfaceOrientationLandscapeRight;
        isLandscape = YES;
        angle = CRotate*(-90);
        _contanierView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        
    }else if (orientation == UIDeviceOrientationLandscapeLeft) {
        ori = UIInterfaceOrientationLandscapeLeft;
        isLandscape = YES;
        angle = CRotate*(90);
        _contanierView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        
    }else if (orientation == UIDeviceOrientationPortrait) {
        ori = UIInterfaceOrientationPortrait;
        isLandscape = NO;
        angle = CRotate*(0);
        _contanierView.frame= CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    else{
        isLandscape = NO;
        isget = NO;
    }
    
    if (isget && orientation != lastOrientation) {
        lastOrientation = orientation;

        _contanierView.center = self.view.center;
        _bottomView.frame = CGRectMake(0, _contanierView.frame.size.height - 45, _contanierView.frame.size.width, 45);
        _collectionView.frame = CGRectMake(0, 0, _contanierView.frame.size.width + 40, _contanierView.frame.size.height);
        [_collectionView.collectionViewLayout invalidateLayout];
        [_collectionView reloadData];
        
        [_contanierView.layer removeAnimationForKey:@"aaa"];
        CABasicAnimation *rotationAnimation;
        if (rotationAnimation == nil) {
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.fromValue = [NSNumber numberWithFloat:lastangle];
            rotationAnimation.toValue = [NSNumber numberWithFloat:angle];
            rotationAnimation.duration = 0.3;
            rotationAnimation.removedOnCompletion = NO;
            rotationAnimation.repeatCount = 1;
            rotationAnimation.fillMode = kCAFillModeBoth;
        }
        [_contanierView.layer addAnimation:rotationAnimation forKey:@"aaa"];
    }
}

//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}
//
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    NSLog(@"willRotateToInterfaceOrientation");
    
    isRotate = YES;
    if (isLandscape != UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self didlayoutViews:YES];
    }
    
    isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    theOrientation = toInterfaceOrientation;
}

-(void)didlayoutViews:(BOOL)isWidthReverse
{
    CGFloat theheight = isWidthReverse?_contanierView.frame.size.width : _contanierView.frame.size.height;
    CGFloat theWidth = isWidthReverse?_contanierView.frame.size.height : _contanierView.frame.size.width;
    
    _bottomView.frame = CGRectMake(0, theheight - 45,theWidth, 45);
    
    _collectionView.frame = CGRectMake(0, 0, theWidth + 40, theheight);
    
    
    BOOL isshow = ((IS_SHOWOTHER_LANGUAGE && [FileSystem isChinaLan]) || !IS_SHOWOTHER_LANGUAGE);
    int tag = isshow?102:101;
    
    UIView *deleteView = [_bottomView viewWithTag:tag];
    deleteView.frame = CGRectMake(_bottomView.frame.size.width - deleteViewRightBlock, deleteOriginFrame.origin.y, deleteOriginFrame.size.width, deleteOriginFrame.size.height);
    
    if (isshow) {
        UIView * copyView = [_bottomView viewWithTag:tag-1];
        copyView.frame = CGRectMake((_bottomView.frame.size.width - copyView.frame.size.width)/2.0, copyView.frame.origin.y, copyView.frame.size.width, copyView.frame.size.height);
    }
    
    
    _customNavigationBar.frame = CGRectMake(0, _customNavigationBar.frame.origin.y, theWidth, _customNavigationBar.frame.size.height);
    _customNavigationBar.rightBtn.frame = CGRectMake(_customNavigationBar.frame.size.width - rightBtnRightBlock, rightOriginFrame.origin.y, rightOriginFrame.size.width, rightOriginFrame.size.height);
    
    _customNavigationBar.title.frame = CGRectMake((_customNavigationBar.frame.size.width - titleOriginFrame.size.width) / 2.0, titleOriginFrame.origin.y, titleOriginFrame.size.width, titleOriginFrame.size.height);
    
    CGFloat screenwidth = isWidthReverse? [UIScreen mainScreen].bounds.size.height + 40 : [UIScreen mainScreen].bounds.size.width + 40;
    
    _collectionView.contentOffset = CGPointMake(self.nowPhotoNum*screenwidth, _collectionView.contentOffset.y);
    [_collectionView reloadData];
    
    if (_shareToView) {
        [_shareToView removeFromSuperview];
        _shareToView = nil;
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
