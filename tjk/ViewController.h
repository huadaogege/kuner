//
//  ViewController.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSwepView.h"
#import "FileViewController.h"
#import "CustomNavigationController.h"
#import "HomePageView.h"
#import "YpcCustomProgress.h"
#import "PAPasscodeViewController.h"


@interface ViewController : UIViewController<FileViewDelete,HomePageDeletage,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,YpcCustomProgressDelegate,UIScrollViewDelegate,UIAlertViewDelegate,PAPasscodeViewControllerDelegate,ScanFileDelegate,UIDocumentInteractionControllerDelegate>

{
    LeftSwepView                *_leftView;
    UIScrollView                *_scrView;
    UITableView                 *_btnTableview;
    NSArray                     *_nameArr;
    NSArray                     *_iconAry;
    UIView                      *_topView;
    UIView                      *_contentView;
    UIView                      *_bottomView;
    UIButton                    *_topLeftButton;
    UIButton                    *_topRightButton;
    UIImageView                 *_topLeftButtonImgV;
    UIImageView                 *_topRightButtonImgV;
    UILabel                     *_topTitleLab;
    UISwipeGestureRecognizer    *_leftSwipeGestureRecognizer;
    UITapGestureRecognizer      *_leftSwipeTapGesture;
    
    
    NSTimer                         *timer;
    UIView                          *backView;
    UIView                          *kunerView;
    UIButton                        *_maskButton;
    UIImageView                     *_shadowImg;
    HomePageView                    *lightView;
    CustomNavigationController      *_mainNavigationController;
    BOOL                            _turnRight;
    BOOL                            _keOn;
    BOOL                            nowthe;
    BOOL                            ret;
    BOOL                            _dontTouch;
    dispatch_queue_t                _dispatchQueue;
    YpcCustomProgress               *_test;
    
    UIImageView                     * _musicplaystop,*_musicplayanimateImgV;
    NSString                        * _nowPath;
    UIButton                        *allResBtn;
    BOOL                            fromsafenum;
    BOOL                            _kunerlost;
    UIAlertView                     *_failAlert;
    NSString                        *_copyfile;
    NSString                        * _thirdAppCopyPath;
    NSString                        * _copyTips;
    BOOL                              _thirdAppFile;
    FileBean                        * _thirdAppBean;
    NSURL                           * _thirdAppUrl;
    NSString                        * _thirdBoxFilePath;
    BOOL                              _copyOrNot;
    UIDocumentInteractionController *documentController;
}



@property (readwrite, nonatomic) CGFloat angle;

-(UIView *)getleftView;
- (void)needVolume;

-(void)resetPlayingKeMusic;
-(void)stopcycle;

-(void)topicBtnPressed;
-(void)gotoWebUI:(NSURL*)url title:(NSString*)title downloadWeb:(BOOL)downloadWeb backToHomeWeb:(BOOL)isBackToHomeWeb;
-(void)gotoResUI:(int)uiType title:(NSString*)title resType:(int)resType;

-(void)popToSelfWithoutLeftView;

@end

