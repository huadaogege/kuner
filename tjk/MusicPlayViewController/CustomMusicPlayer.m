//
//  CustomMusicPlayer.m
//  LockScreenInfo
//
//  Created by 呼啦呼啦圈 on 14-6-5.
//  Copyright (c) 2014年 Sparq Media. All rights reserved.
//

#import "CustomMusicPlayer.h"
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import "UIImage+Bundle.h"
#import "MusicPlayerViewController.h"
#import "AppDelegate.h"
#import "Context.h"
#define IPHONE_SIX (self.frame.size.height/568.0)
@implementation CustomMusicPlayer
@synthesize nowPlayingItem;
@synthesize currentTim;


static CustomMusicPlayer *customPlayer = nil;

+(CustomMusicPlayer *)shareCustomMusicPlayer{
    
    if(customPlayer == nil){
        [[AVAudioSession sharedInstance] setDelegate: self];
        NSError *myErr;
        
        // Initialize the AVAudioSession here.
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr]) {
            // Handle the error here.
          
        }
        else{
            
//            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        }
        customPlayer = [[CustomMusicPlayer alloc] init];
    }
    
    return customPlayer;
}

-(id)init{
    
    self = [super init];
    if(self){
        nowPlayingItem=nil;
        state=123;
        _canmove = NO;
        _audioPlayer = [[MPMoviePlayerController alloc] init];
        
        _audioPlayer.allowsAirPlay = NO;

        [_audioPlayer setControlStyle: MPMovieControlStyleNone];
        
        _audioPlayer.view.hidden = YES;
        self.view.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:54.0/255.0 blue:62.0/255.0 alpha:1.0];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(fresh)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
        songInfo = [[NSMutableDictionary alloc] init];


       
            }
    
    return self;
}

-(void)playorpause
{
    if ([self isPlaying])
    {
        [self pause];
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    }
    else
    {
        [self play];
        
        if ([self isPlaying]) {
            
        }else{
          UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"sorry", @"") message:NSLocalizedString(@"cannotplay", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nextsong", @""), nil];
            alert.delegate=self;
            alert.tag=22222;
            [alert show];

        }
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (alertView.tag==22222) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"failandnext" object:nil];
        }
    }
}
-(MPMoviePlayerController *)player
{
   return _audioPlayer;

}


-(void)changeCurrentTime
{
    if (self.nowPlayingItem != nil) {
        [self setNowTime:self.currentTim countTime:_audioPlayer.duration];
    }else{
    
    }
}

-(void)slides:(CustomSliderView *)slider ValueChangeToValue:(float)value
{
    [self setPlayTime:value];
    [_timer setFireDate:[NSDate distantFuture]];
    
    _canmove = YES;
    //动态改变时间
}


-(void)setPlayTime:(float)time{
    
    if (self.nowPlayingItem != nil) {
        self.currentTim = time * _audioPlayer.duration;
        
    }else{
    
    }

    //改变播放时间
    [self changeCurrentTime];
}

- (void) endChanges:(float)value{
    if (_canmove) {
        [self setPlayTime:value];
        [_timer setFireDate:[NSDate date]];
        _audioPlayer.currentPlaybackTime = value * (_audioPlayer.duration);
        _canmove = NO;
    }
   
    
}

-(void)setNowTime:(float)nowTime countTime:(float)countTime{
    
    [[MusicPlayerViewController instance]setNowTime:nowTime countTime:countTime];
}

-(void)playerMusic:(FileBean *)item path:(NSString *)path
{
    self.nowPlayingItem = item;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    _audioPlayer.contentURL = url;
    
    musicname = [FileSystem getModelNameWith:[item.filePath lastPathComponent]];
    self.title = musicname;
    
    [songInfo setObject:NSLocalizedString(@"unknown",@"") forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:musicname forKey:MPMediaItemPropertyAlbumTitle];
    [songInfo setObject:musicname forKey:MPMediaItemPropertyTitle];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasImage = NO;
        image = [UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        
        // 获取 mediaBean 放在子线程中
        MediaBean *bean = [[CustomFileManage instance] getMediaCache:item];
        
        if (bean.img) {
            hasImage = YES;
            image = bean.img;
        }
        
        MPMediaItemArtwork *tempAlbumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        if (tempAlbumArt!=nil) {
            [songInfo setObject:tempAlbumArt forKey:MPMediaItemPropertyArtwork];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MusicPlayerViewController instance] setTitle:musicname
                                                      Icon:image
                                                 musicName:musicname
                                                singerName:NSLocalizedString(@"unknown",@"")
                                                  hasimage:hasImage];
            
        });
        
    });
}

#pragma mark-----customMusicPlayer fresh
-(void)fresh{
    
    [songInfo setObject:[NSNumber numberWithDouble:[_audioPlayer duration]] forKey:MPMediaItemPropertyPlaybackDuration];
    [songInfo setObject:[NSNumber numberWithDouble:[_audioPlayer currentPlaybackTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
    if (_audioPlayer.currentPlaybackTime>_audioPlayer.duration) {
        _audioPlayer.currentPlaybackTime=_audioPlayer.duration;
    }
    
    [[MusicPlayerViewController instance]setNowTime:_audioPlayer.currentPlaybackTime countTime:_audioPlayer.duration];
    self.currTime = _audioPlayer.currentPlaybackTime;
    self.totalTime = _audioPlayer.duration;
    
    if (_audioPlayer.currentPlaybackTime==_audioPlayer.duration) {
        if (_audioPlayer.duration!=0) {
            [self performSelector:@selector(checkchange) withObject:self afterDelay:0.5];
        }
     }
}
-(void)checkchange{
    
    int current = _audioPlayer.currentPlaybackTime;
    int total = _audioPlayer.duration;
    
    if (current==total) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"changenext" object:nil];
    }

}
-(void)play:(FileBean *)item path:(NSString *)path
{
    [self playerMusic:item path:path];
    
    if ([Context shareInstance].stopPlayingAfterCurMusicPlay) {
        if ([self isPlaying]) {
            //不存在重置变量
            [Context shareInstance]._musicIndex = 0;
            [Context shareInstance].musicClockState = NO;
            
            // settingViewController 存在即刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_SETTING_MUSICTIMER object:nil];
        }
        return;
    }
    
    [self play];
    
}

-(void)play{
//   [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate stopBackground];
    [_audioPlayer play];
    [_timer setFireDate:[NSDate date]];
    _nowPlaying=YES;
    NSLog(@"%@",self.nowPlayingItem.filePath);
     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self performSelector:@selector(beginReceive) withObject:nil afterDelay:0.5];
   
}

-(void)beginReceive{

//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

}

-(void)pause{
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate isAppActive] && [self isPlaying]) {
        [appDelegate playBackground];
    }
    
    [_audioPlayer pause];
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)stop{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate isAppActive] && [self isPlaying]) {
        [appDelegate playBackground];
    }
    [_audioPlayer stop];
    [_timer setFireDate:[NSDate distantFuture]];
}

-(bool)isPreparedToPlay{
     return [_audioPlayer isPreparedToPlay];
}

-(void)prepareToPlay{
    [_audioPlayer prepareToPlay];
}

-(BOOL)isPlaying
{
    return  _audioPlayer.playbackState==MPMoviePlaybackStatePlaying;
}



@end
