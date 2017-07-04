//
//  CustomMusicPlayer.h
//  LockScreenInfo
//
//  Created by 呼啦呼啦圈 on 14-6-5.
//  Copyright (c) 2014年 Sparq Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomSliderView.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TGK_FFPlayerViewController.h"
#import "MediaBean.h"
@interface CustomMusicPlayer : UIViewController<UIAlertViewDelegate>{
    
    MPMoviePlayerController     *_audioPlayer;
    NSTimer                     *_timer;
    NSMutableDictionary         *songInfo;
    int                          state;
    NSString                    * musicname;
    UIImage                     *image;
    BOOL                        _canmove;
}

@property(nonatomic)FileBean *nowPlayingItem;
@property(nonatomic)NSTimeInterval currentTim;
@property (nonatomic) UIButton *playBtn;
@property(nonatomic)BOOL         nowPlaying;
@property (nonatomic,assign) int currTime;
@property (nonatomic,assign) int totalTime;


+(CustomMusicPlayer *)shareCustomMusicPlayer;

-(void)slides:(CustomSliderView *)slider ValueChangeToValue:(float)value;
- (void) endChanges:(float)value;

-(void)setNowTime:(float)nowTime countTime:(float)countTime;
-(void)setIsPlaying:(BOOL)isPlaying;
-(void)play:(FileBean *)item path:(NSString *)path;


-(void)playerMusic:(FileBean *)item path:(NSString *)path;
-(MPMoviePlayerController *)player;

-(void)changeplaymodel;
-(void)playorpause;
-(void)play;
-(void)pause;
-(void)stop;

-(bool)isPreparedToPlay;
-(void)prepareToPlay;
-(BOOL)isPlaying;



-(void)setCurrentTim:(NSTimeInterval)currentTim;


@end
