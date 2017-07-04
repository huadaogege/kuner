//
//  TGK_FFPlayerViewController.h
//  tjk
//
//  Created by huadao on 14-11-11.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FFmpegDecoder.h"
#import "CustomSliderView.h"
#import "MediaBean.h"
#import "FileBean.h"
//#import "GetFileInfo.h"
//#import "TGK_MusicListController.h"

#define kNumAQBufs 3
#define kAudioBufferSeconds 3

typedef enum _AUDIO_STATE {
    AUDIO_STATE_READY           = 0,
    AUDIO_STATE_STOP            = 1,
    AUDIO_STATE_PLAYING         = 2,
    AUDIO_STATE_PAUSE           = 3,
    AUDIO_STATE_SEEKING         = 4
} AUDIO_STATE;

@interface TGK_FFPlayerViewController : UIViewController<UIAlertViewDelegate>
{
   
    AudioStreamBasicDescription audioStreamBasicDesc_;
    AudioQueueRef audioQueue_;
    AudioQueueBufferRef audioQueueBuffer_[kNumAQBufs];
    BOOL started_, finished_;
    NSTimeInterval durationTime_, startedTime_;

    NSTimer *seekTimer_;
    NSLock *decodeLock_;
    FFmpegDecoder *ffmpegDecoder_;
    NSTimeInterval currentTimeInterval ;
   NSURL                       * URL;
    int                          states;
    NSMutableDictionary         *_songInfo;
    BOOL                       copydoneplay;
     
    BOOL                      _canplay;
    UIAlertView               * _alertview;
}

@property(nonatomic)BOOL        nowPlaying;
@property(nonatomic)NSString   *nowSongs;
@property(nonatomic)NSString   *nowplaySongs;
@property(nonatomic) NSInteger state_;
@property(nonatomic)FileBean  * currentBean;

+(TGK_FFPlayerViewController *)instance;
- (void)playAudio;
- (void)pauseAudio;
- (void)updateSeekSlider:(UISlider*)sender;
- (void)updatePlaybackTime:(NSTimer*)timer;

-(BOOL)isplaying;
-(void)PlayorPause;
-(void)changeplaymodel;
-(void)getUrl:(FileBean*)filebean cacahe:( NSString*)path;

-(void)copystop;
-(void)copyplay;

- (void)startAudio_;
- (void)stopAudio_;
- (BOOL)createAudioQueue;
- (void)removeAudioQueue;
- (void)audioQueueOutputCallback:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer;
- (void)audioQueueIsRunningCallback;
- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer;
- (OSStatus)startQueue;

-(void)setNowTime:(float)nowTime countTime:(float)countTime;
-(void)slidess:(CustomSliderView *)slider ValueChangeToValue:(float)value;
- (void) endChangess:(float)value;


@end
