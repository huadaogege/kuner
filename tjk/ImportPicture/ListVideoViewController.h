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


@interface ListVideoViewController : UIViewController<CustomUISliderDelegate,VolumeDelegate>{
    
//    UIImageView         *_imageView;
    CustomGesView       *_topHUD;//顶部
    UIView              *_progressHUD;//底部
    CustomVolumeView    *_leftHUD;//顶部
    CustomGesView       *_bottomHUD;//控制
    CustomUISlider      *_progressSlider;
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIButton            *_infoButton;
    UITableView         *_tableView;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel             *_subtitlesLabel;
    NSArray             *_durationArray;
    NSInteger                 _nowIndex;
    
    NSTimer             *_timer;
    int      _remenber;
    
    int                 _soundValue;
    int                 _hiddenTime;
    BOOL                _hiddenHUD;
    BOOL                _isAction;
    double                 _timeValue;
    double                 _lastTimeValue;
    BOOL                _isPlaying;
    BOOL                _handoff;
    BOOL isplaystate;
    UIButton *midPlayBtn;
    CustomGesView *gesTipView;
    CGPoint tmpPoint;
}
@property         BOOL videoisplaying;
@property    (nonatomic,assign) id<VideoProtocal> delegate;
@property (nonatomic, retain) AVQueuePlayer *myQueuePlayer;

+(void)setVideoPlaying:(BOOL)playing;
+(BOOL)isVideoPlaying;
- (void)playDidTouch:(id)sender;
-(void)setVideos:(NSArray *)urls title:(NSString*)title durations:(NSArray*)durations lasttime:(CGFloat)lasttime;

-(void)play;

-(void)stop;

-(void)pause;

-(BOOL)canBePlaying;

- (void) valueChanged:(NSTimeInterval)value;
- (void) endChanged:(NSTimeInterval)value;


@end
