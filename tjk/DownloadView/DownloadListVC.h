//
//  DownloadListVC.h
//  tjk
//
//  Created by Youqs on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadTask.h"

@interface DownloadListVC : UIViewController

+(DownloadListVC *)sharedInstance;


-(void)addDownloadTask:(DownloadInfo*)info;
-(void)addDownloadTaskWithArray:(NSMutableArray *)infoarray;
-(void)removeTaskAtPath:(NSString*)path;
-(void)changePauseBtnStatus;

-(BOOL)isTopVC;
-(BOOL)checkVideoIsPlaying;
-(void)refreshTable;

@end
