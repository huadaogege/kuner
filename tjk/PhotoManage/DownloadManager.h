//
//  DownloadItem.h
//  tjk
//
//  Created by lipeng.feng on 15/7/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadTask.h"
#import "MusicPlayerViewController.h"

typedef enum : NSUInteger {
    IN_STATUS_NONEFONND = 0,
    IN_STATUS_DOWNING,
    IN_STATUS_DOWNED,
    IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH,
    
}INDOWNLOADMANAGERSTATUS;

#define DOWNCOMPELETE_NOTI @"COMPELETE_NOTI"
#define DOWNDELETE_NOTI @"DOWNDELETE_NOTI"

#define DOWNLOADING_LARGEST_COUNT 99

@interface DownloadManager : NSObject

+(id)shareInstance;

-(void)readDownloadListFromFile;

-(void)addDownloadTask:(DownloadInfo*)itemInfo delegate:(id<DownloadProgressDelegate>)delegate;
-(void)addDownloadTaskWithArray:(NSMutableArray *)infoArrr delegate:(id<DownloadProgressDelegate>)delegate;

-(NSMutableArray *)getDownloadingArray;
-(void)removeDownloadingItem:(NSArray *)itemArray atIndex:(NSArray *)indexArray;
-(void)removeDownloadingItem:(NSArray *)itemArray atIndex:(NSArray *)indexArray fromFile:(BOOL)fromFile;

-(NSMutableArray *)getDownloadCompleteArray;
-(void)removeDownloadCompleteItems:(NSArray *)itemArray atIndex:(NSArray *)indexArray;
-(DOWNLOAD_STATUS)getItemDownloadStatus:(NSString*)path;
-(BOOL)getALLItemDownloadPaused;

-(void)startAll;
-(void)startDownloadWith:(NSString*)path;
-(void)pauseAll;
-(void)pauseDownloadWith:(NSString*)path;

-(BOOL)IsInDownloadListForYunPan:(NSString *)itemname;
-(BOOL)downloadingInList:(NSString*)path name:(NSString *)itemname;
-(INDOWNLOADMANAGERSTATUS)isdownloadingInListWith:(NSString*)path name:(NSString *)itemname;
-(INDOWNLOADMANAGERSTATUS)isMusicSameNameAndDiffFpathIndownloadingListWith:(NSString*)path name:(NSString *)itemname;
-(INDOWNLOADMANAGERSTATUS)isdownloadingBaiDuYunInListWith:(NSString*)subid name:(NSString *)itemname;

-(void)changeLocalFileToKe;
-(void)removeAllDownloadInfo;
-(void)saveJuJiInfo:(DownloadInfo *)info;

-(void)showFullDownloadingAlert;
-(void)saveDownlaodList:(BOOL)ismoveToke;
-(void)clearSnPath;

@end
