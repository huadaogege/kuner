//
//  VideoViewController.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-6-6.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
//#import "TGK_CustomUISlider.h"
#import "CustomUISlider.h"
#import "CustomVolumeView.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoProtocal.h"
#import "CustomGesView.h"

@interface VideoViewController : MPMoviePlayerViewController<CustomUISliderDelegate,VolumeDelegate,CustomVideoSubViewDelegate>{
    
//    UIImageView         *_imageView;
    CustomGesView       *_topHUD;//顶部
    UIView              *_progressHUD;//底部
    CustomVolumeView    *_leftHUD;//顶部
    CustomGesView       *_bottomHUD;//控制
    CustomUISlider   *_progressSlider;
    
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIButton            *_infoButton;
    UITableView         *_tableView;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel             *_subtitlesLabel;
    
    NSTimer             *_timer;
    int      _remenber;
    
    int                 _soundValue;
    int                 _hiddenTime;
    BOOL                _hiddenHUD;
    BOOL                _isAction;
    int                 _timeValue;
    BOOL                _isPlaying;
    BOOL                _handoff;
    
    CGPoint startPoint;
    CGFloat _progressvalue;
    CGFloat originProgressWidth;
    CGFloat originVolumeHeight;
    VideoMoveDirection direction;
    UIView *gesView;
    BOOL isDragProgress;
    BOOL isLandscape;
    BOOL isplaystate;
    UIButton *midPlayBtn;
    CustomGesView *gesTipView;
    CGPoint tmpPoint;
    UIView *gesIntrView;
}

@property (nonatomic, assign) BOOL videoisplaying;
@property (nonatomic, weak) id<VideoProtocal> delegate;

+(void)setVideoPlaying:(BOOL)playing;
+(BOOL)isVideoPlaying;
- (void)playDidTouch:(id)sender;
-(void)setVideo:(NSURL *)url progress:(float)progress;
-(void)stopTikTimer;

-(void)play;

-(void)stop;

-(void)pause;

-(BOOL)canBePlaying;

-(void)playFromLastTime:(float)lasttime;

- (void) valueChanged:(NSTimeInterval)value;
- (void) endChanged:(NSTimeInterval)value;


@end
