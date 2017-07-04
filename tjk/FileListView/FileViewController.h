//
//  FileViewController.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoicePathDeleagte.h"
#import "MusicPlayerViewController.h"
#import "KxMovieViewController.h"
#import "WebViewController.h"
#import "CustomMusicPlayer.h"
#import "VideoViewController.h"
#import "CustomFileManage.h"
#import "LogUtils.h"
//#import "TGK_FFPlayerViewController.h"

#define LEFT_TAG 111
#define RIGHT_TAG 112

enum{
    Picture_UI_Type,
    Document_UI_Type,
    Copy_UI_Type,

}ListUIType;



@protocol FileViewDelete <NSObject>
-(void)showPlayer;
-(void)hiddenPlayer;
@end


@interface FileViewController : UIViewController<ChoicePathDeleagte,KxBackDelegate>

@property(nonatomic, assign) int uiType;//ListUIType
@property(nonatomic, assign) int resType;//ListUIType
@property(nonatomic, assign) BOOL isTypeUIRoot;//ListUIType
@property(nonatomic, assign) NSInteger  fromDisplay;;
@property(nonatomic, assign) id<ChoicePathDeleagte> pathDelegate;
@property(nonatomic, retain) NSString* subCopyPath;
@property(nonatomic, retain) NSString* rootStr;
@property(nonatomic, retain) NSString* titleStr;
@property(nonatomic, assign) BOOL needReload;
@property(nonatomic, assign) float appOutPlayTime;

@property (assign)id <FileViewDelete>  delegate;
-(void)checkAndChangeTab;
-(void)readData:(BOOL)showLoading;
-(void)changeTab:(NSInteger)tabTag;
@end
