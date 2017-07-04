//
//  ViewController.m
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt
#define DEAL_RMVB_PROC 1

#import "KxMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"
#import "CustomUISlider.h"
#import "CustomVolumeView.h"
#import "CustomGesView.h"

#define VIDEO_FILEPATH @"filepath"
#define VIDEO_FILENAME @"fileNAME"

#define KxMovieBottomViewTAG 111111

NSString * const KxMovieParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
NSString * const KxMovieParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
NSString * const KxMovieParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";

////////////////////////////////////////////////////////////////////////////////
extern int getIsNeedLongCDs();
extern float Get_Max_CD();

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
//    return [NSString stringWithFormat:@"%@%d:%0.2d:%0.2d", isLeft ? @"-" : @"", h,m,s];
    return [NSString stringWithFormat:@"%d:%0.2d:%0.2d", h,m,s];
}

////////////////////////////////////////////////////////////////////////////////

@interface HudView : UIView
@end

@implementation HudView

- (void)layoutSubviews
{
    NSArray * layers = self.layer.sublayers;
    if (layers.count > 0) {        
        CALayer *layer = layers[0];
        layer.frame = self.bounds;
    }
}
@end

////////////////////////////////////////////////////////////////////////////////

enum {

    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,    
    KxMovieInfoSectionCount,
};

enum {

    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

//static NSMutableDictionary * gHistory; //记录播放位置

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

@interface KxMovieViewController () <CustomVideoSubViewDelegate>{

    KxMovieDecoder      *_decoder;    
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
#if DEAL_RMVB_PROC
    NSMutableArray      *_videoFrameQuenBufferForRmvb;//存储1.1s之前的数据 解决rmvb的延迟问题
#endif
    
    NSMutableArray      *_audioFrames;
    NSMutableArray      *_subtitles;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    BOOL                _disableUpdateHUD;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _fullscreen;
    BOOL                _hiddenHUD;
    BOOL                _interrupted;
    BOOL                _dealloced;

    KxMovieGLView       *_glView;
    UIImageView         *_imageView;
    
    CustomGesView       *_topHUD;//顶部
    UIView              *_progressHUD;//底部
    CustomVolumeView    *_leftHUD;//顶部
    CustomGesView       *_bottomHUD;//控制
    CustomUISlider      *_progressSlider;
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIButton            *_infoButton;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel             *_subtitlesLabel;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
        
//#ifdef DEBUG
//    UILabel             *_messageLabel;
//    NSTimeInterval      _debugStartTime;
//    NSUInteger          _debugAudioStatus;
//    NSDate              *_debugAudioStatusTS;
//#endif

    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    
    BOOL                _savedIdleTimer;
    
    NSDictionary        *_parameters;
    
    NSMutableDictionary *_videoInfo;
    
    float               _soundValue;
    
    CGPoint startPoint;
    CGFloat progressvalue;
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

@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (readwrite, weak) KxArtworkFrame *artworkFrame;
@end

@implementation KxMovieViewController
@synthesize kxBackDelegate;
+ (void)initialize
{
//    if (!gHistory)
//        gHistory = [[NSMutableDictionary alloc]init];
}

- (id) init
{

    self = [super init];
    if (self) {

        _soundValue = 0;

        _videoInfo = [[NSMutableDictionary alloc] init];

        _moviePosition = 0;

        _videoFrames    = [[NSMutableArray alloc] init];
#if DEAL_RMVB_PROC
        _videoFrameQuenBufferForRmvb = [[NSMutableArray alloc] init];//初始化视频帧缓存
#endif
        _audioFrames    = [[NSMutableArray alloc] init];
        
        _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
//        self.wantsFullScreenLayout = YES;
                 [self initView];
    }
    return self;
}


-(void)setPath:(NSString *)path parameters:(NSDictionary *)parameters{
    
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];

    [self showHUD: YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];

    ////////////////////

    _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);

    _buffered = NO;

    [_activityIndicatorView startAnimating];
    
    [_videoFrames removeAllObjects];
#if DEAL_RMVB_PROC
    [_videoFrameQuenBufferForRmvb removeAllObjects];
#endif
    [_audioFrames removeAllObjects];
    
    [_videoInfo removeAllObjects];
    [_videoInfo setObject:path forKey:VIDEO_FILEPATH];
//    [_videoInfo setObject:[path lastPathComponent] forKey:VIDEO_FILENAME];
    [_topHUD setVideoNameWith:[path lastPathComponent]];
    
    _parameters = parameters;

    
    
    /**/__weak KxMovieViewController *weakSelf = self;
    KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
    
    decoder.interruptCallback = ^BOOL(){
        
        if (weakSelf) {
            /**/__strong KxMovieViewController *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        }
        else{
            return YES;
        }
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSError *error = nil;
        BOOL result = [decoder openFile:path error:&error];
        
        if(!result){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fault", @"") message:NSLocalizedString(@"unopenfiles", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"know", @"") otherButtonTitles:nil];
                [alert show];
                [self performSelector:@selector(doneDidTouch:) withObject:nil afterDelay:.3];
            });
        }else{
            /**/__strong KxMovieViewController *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        }
    });
}

- (void) dealloc
{
    NSLog(@"kxmovie view controller dealloc");
    [self self_dealloc];
}

-(void) self_dealloc{
    _dealloced = YES;
    [self pause];
    _progressSlider.delegate = nil;
    [_progressSlider removeFromSuperview];
    _progressSlider = nil;
    self.kxBackDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    _interrupted = YES;
    
    [self closFFmpeg];
    if (_dispatchQueue) {
        dispatch_object_t _o = (_dispatchQueue);
		_dispatch_object_validate(_o);
        _dispatchQueue = NULL;
    }

    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager deactivateAudioSession];
    [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
#if DEAL_RMVB_PROC
    [_videoFrameQuenBufferForRmvb removeAllObjects];
#endif
}

- (void)initView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    
    self.view.backgroundColor = [UIColor blackColor];
    
//    UIView * line =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height,1 )];
//    line.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:line];
//    UIView * line1 =[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width-1, self.view.frame.size.height, 1)];
//    line1.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:line1];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.frame = self.view.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:view];
    
    gesView = view;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:_activityIndicatorView];
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;

    _bottomHUD   = [[CustomGesView alloc] initBottomViewWith:CGRectMake(0,height - 90*WINDOW_SCALE,width,44*WINDOW_SCALE)];
    _bottomHUD.delegate = self;
    
    _topHUD = [[CustomGesView alloc] initTopViewWith:CGRectMake(0,0,width,30*WINDOW_SCALE+20)];
    _topHUD.delegate = self;
    _topHUD.alpha = 0;
    
    _leftHUD = [[CustomVolumeView alloc] initWithFrame:CGRectMake(width - 45 - 15,(height - 210) / 2,45,210)];
    _leftHUD.backgroundColor = [UIColor clearColor];
    _leftHUD.layer.cornerRadius = 20;
    _leftHUD.layer.masksToBounds = YES;
    _leftHUD.delegate = self;
    _leftHUD.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    
    _progressHUD = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    _progressHUD.backgroundColor = [UIColor blackColor];
    _progressHUD.alpha = 0;
    _progressHUD.frame  = CGRectMake(0,
                                     height - 38*WINDOW_SCALE,
                                     width,
                                     38*WINDOW_SCALE);
    
    _progressHUD.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    gesTipView = [[CustomGesView alloc] initWithFrame:CGRectMake((width - 140)/2.0, (height - 70)/2.0, 140, 70)];
    
    [self.view addSubview:_progressHUD];
    [self.view addSubview:_bottomHUD];
    [self.view addSubview:_topHUD];
    [self.view addSubview:_leftHUD];
//    [self.view addSubview:gesTipView];
    
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.frame = CGRectMake(0, 12*WINDOW_SCALE, 60*WINDOW_SCALE, 13*WINDOW_SCALE);
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.opaque = NO;
    _progressLabel.adjustsFontSizeToFitWidth = NO;
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.text = @"00:00:00";
    _progressLabel.font = [UIFont systemFontOfSize:12*WINDOW_SCALE];
    
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.frame = CGRectMake(width - 60 *WINDOW_SCALE, 12*WINDOW_SCALE, 60*WINDOW_SCALE, _progressLabel.bounds.size.height);
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.opaque = NO;
    _leftLabel.adjustsFontSizeToFitWidth = NO;
    _leftLabel.textAlignment = NSTextAlignmentLeft;
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.text = @"-99:59:59";
    _leftLabel.font = [UIFont systemFontOfSize:12*WINDOW_SCALE];
    _leftLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    _progressSlider = [[CustomUISlider alloc] init];
    _progressSlider.delegate = self;
    _progressSlider.frame = CGRectMake(_progressLabel.bounds.size.width + 10*WINDOW_SCALE,
                                       -8,
                                       _leftLabel.frame.origin.x - _progressLabel.bounds.size.width - 20*WINDOW_SCALE,
                                       50*WINDOW_SCALE);
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth ;

    [_progressHUD addSubview:_progressLabel];
    [_progressHUD addSubview:_progressSlider];
    [_progressHUD addSubview:_leftLabel];

//    if (_decoder) {
//        
//        [self setupPresentView];
//        
//    } else {
    
        _bottomHUD.hidden       = YES;
        _progressLabel.hidden   = YES;
        _progressSlider.hidden  = YES;
        _leftLabel.hidden       = YES;
        _leftHUD.hidden         = YES;
        _topHUD.hidden          = YES;
    gesView.hidden = YES;
//    }
    
    [self addGestureRecognizer];
    
}

#pragma mark - GestureRecognizer

-(void)addSiwpeTipView
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    if (!gesTipView) {
        gesTipView = [[CustomGesView alloc] initWithFrame:CGRectMake((width - 140)/2.0, (height - 70)/2.0, 140, 70)];
    }
    gesTipView.frame = CGRectMake((width - 140)/2.0, (height - 70)/2.0, 140, 70);
    [self.view addSubview:gesTipView];
}

-(void)removeSiwpeTipView
{
    if (gesTipView && gesTipView.superview) {
        [gesTipView removeFromSuperview];
    }
}


-(void)addGestureRecognizer
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [gesView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGes.numberOfTapsRequired = 2;
    [gesView addGestureRecognizer:doubleTapGes];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [gesView addGestureRecognizer:tapGesture];
    [tapGesture requireGestureRecognizerToFail:doubleTapGes];
}

-(void)handleSwipe:( UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture translationInView:gesView];
    
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        startPoint = touchPoint;
        progressvalue = 0;
        
        originProgressWidth = [_progressSlider getProgressViewVar];
        originVolumeHeight = [_leftHUD getVolumeViewHeight];
        direction = kVideoMoveDirectionNone;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged )
    {
        if (direction == kVideoMoveDirectionNone) {
            direction = [self determineCameraDirectionIfNeeded:touchPoint];
        }
        
        if (direction == kVideoMoveDirectionDown || direction == kVideoMoveDirectionUp) {
            
            CGFloat addVar = startPoint.y - touchPoint.y;
            CGFloat oldVar = originVolumeHeight;
            
            CGFloat newVar = (addVar/2.0 + oldVar);
            
            if(newVar < 0){
                newVar = 0;
            }else if (newVar > kVolumeHeight){
                
                newVar = kVolumeHeight;
            }
            
            [_leftHUD volumeChange:newVar/kVolumeHeight];
            [_leftHUD setVolume:newVar/kVolumeHeight];
        }
        else if (direction == kVideoMoveDirectionLeft || direction == kVideoMoveDirectionRight)
        {
//            _progressHUD.alpha     = 1;
//            _hiddenTime = 0;
            isDragProgress = YES;
            
            CGFloat totoalVar = _progressSlider.frame.size.width;
            CGFloat addVar = touchPoint.x - startPoint.x;
            
            //printf("add=%f\n",addVar);
           // int xyz= addVar;
            //addVar = xyz;
            CGFloat oldVar = originProgressWidth;
            
            CGFloat newVar = addVar/3.0 + oldVar;
            if(newVar < 0){
                newVar = 0;
            }else if (newVar > totoalVar){
                newVar = totoalVar;
            }
            
            progressvalue = newVar/totoalVar;
            
            CGFloat durationtime = _decoder.duration;
            CGFloat lastvar = durationtime > 60? 5 : 2;
            CGFloat lastpro = (durationtime -lastvar)/durationtime;
            progressvalue = progressvalue >= lastpro?(durationtime -lastvar)/durationtime:progressvalue;
            
            [_progressSlider setValue:progressvalue];
            NSString *nowtime = formatTimeInterval(durationtime * progressvalue,NO);
            _progressLabel.text = nowtime;
            
            [self addSiwpeTipView];
            
            VideoMoveDirection tmpd = kVideoMoveDirectionNone;
            CGFloat tmpaddVar = touchPoint.x - tmpPoint.x;
            if (fabs(tmpaddVar) >= 0.5) {
                if (tmpaddVar < 0) {
                    tmpd = kVideoMoveDirectionLeft;
                }
                else if (tmpaddVar > 0) {
                    tmpd = kVideoMoveDirectionRight;
                }
            }
            [gesTipView setDirection:tmpd nowtime:nowtime totalTime:formatTimeInterval(durationtime,NO)];
            tmpPoint = touchPoint;
        }
        else{
            
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded )
    {
        // now tell the camera to stop
        
        if (direction == kVideoMoveDirectionLeft || direction == kVideoMoveDirectionRight)
        {
            isDragProgress = NO;
            [self valueChange:progressvalue];
            [self endChange:progressvalue];
//            _hiddenTime = 3;
            //            [self hiddenTime];
            [self removeSiwpeTipView];
        }
        
        NSLog (@ "Stop" );
        direction = kVideoMoveDirectionNone;
    }
}


-(void)handleTap:(UITapGestureRecognizer *) sender{
    
    [self showHUD:_hiddenHUD];
}


-(void)doubleTap:(UITapGestureRecognizer *) sender{
    
    [self playDidTouch:nil];
}

-(VideoMoveDirection )determineCameraDirectionIfNeeded:( CGPoint )translation
{
    if (direction != kVideoMoveDirectionNone)
        return direction;
    
    // determine if horizontal swipe only if you meet some minimum velocity
    
    if (fabs(translation.x) > gestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        
        if (translation.y == 0.0 )
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        
        if (gestureHorizontal)
        {
            if (translation.x > 0.0 )
                return kVideoMoveDirectionRight;
            else
                return kVideoMoveDirectionLeft;
        }
    }
    
    // determine if vertical swipe only if you meet some minimum velocity
    
    else if (fabs(translation.y) > gestureMinimumTranslation)
    {
        BOOL gestureVertical = NO;
        
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        
        if (gestureVertical)
        {
            if (translation.y > 0.0 )
                return kVideoMoveDirectionDown;
            else
                return kVideoMoveDirectionUp;
        }
    }
    
    return direction;
}


#pragma mark - rotate

-(BOOL)shouldAutorotate {
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    [self setRotateBtnImage];
    [self gesIntrBtnClick];
}

-(void)ratoteBtnClick
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        isLandscape = !isLandscape;
        [FileSystem rotateWindow:isLandscape];
    }
}

-(void)setRotateBtnImage
{
    [_bottomHUD setRotateBtnStatus:isLandscape];
}

#pragma mark -

-(void)hiddenTime{
    
    if (_dealloced) {
        return;
    }
    
    if(_hiddenTime++ > 5){
        
        [self showHUD:NO];
    }else{
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hiddenTime) userInfo:nil repeats:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            NSLog(@"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];

            if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(playError:)]){
                
                [self.kxBackDelegate playError:nil];
            }
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

//- (void) viewDidAppear:(BOOL)animated
//{
//    // NSLog(@"viewDidAppear");
//    
//    [super viewDidAppear:animated];
//
//    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
//    
//    [self showHUD: YES];
//    
//    if (_decoder) {
//        
//        [self restorePlay];
//        
//    } else {
//
//        [_activityIndicatorView startAnimating];
//    }
//   
//        
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationWillResignActive:)
//                                                 name:UIApplicationWillResignActiveNotification
//                                               object:[UIApplication sharedApplication]];
//}
//
//- (void) viewWillDisappear:(BOOL)animated
//{    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [super viewWillDisappear:animated];
//    
//    [_activityIndicatorView stopAnimating];
//    
//    if (_decoder) {
//        
//        [self pause];
//    }
//        
//    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
//
//    _buffered = NO;
//    _interrupted = YES;
//    
//    NSLog(@"viewWillDisappear %@", self);
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
//}
//
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//- (NSUInteger)supportedInterfaceOrientations{
//    
//    return UIInterfaceOrientationMaskLandscape;
//}

- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self showHUD:YES];
    [self pause];
    
    NSLog(@"applicationWillResignActive");    
}

//#pragma mark - gesture recognizer
//
//- (void) handleTap: (UITapGestureRecognizer *) sender
//{
////    if (sender.state == UIGestureRecognizerStateEnded) {
//    
////        if (sender == _tapGestureRecognizer) {
//
//            [self showHUD: _hiddenHUD];
//            
////        } else if (sender == _doubleTapGestureRecognizer) {
////                
////            UIView *frameView = [self frameView];
////            
////            if (frameView.contentMode == UIViewContentModeScaleAspectFit)
////                frameView.contentMode = UIViewContentModeScaleAspectFill;
////            else
////                frameView.contentMode = UIViewContentModeScaleAspectFit;
////            
////        }        
////    }
//}
//
//-(void)doubleTap:(UITapGestureRecognizer *) sender{
//    
//    [self playDidTouch:nil];
//}
//
//- (void) handlePan: (UIPanGestureRecognizer *) sender
//{
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        
//        const CGPoint vt = [sender velocityInView:self.view];
//        const CGPoint pt = [sender translationInView:self.view];
//        const CGFloat sp = MAX(0.1, log10(fabsf(vt.x)) - 1.0);
//        const CGFloat sc = fabsf(pt.x) * 0.33 * sp;
//        if (sc > 10) {
//            
//            const CGFloat ff = pt.x > 0 ? 1.0 : -1.0;            
//            [self setMoviePosition: _moviePosition + ff * MIN(sc, 600.0)];
//        }
//        //NSLog(@"pan %.2f %.2f %.2f sec", pt.x, vt.x, sc);
//    }
//}

#pragma mark - public

-(void) play
{
    _hiddenTime = 0;
    _decoder.isPlaying = YES;
    isAction = NO;
    
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        
        return;
    }
    
    if (_interrupted)
        return;

    self.playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;

//#ifdef DEBUG
//    _debugStartTime = -1;
//#endif

    [self asyncDecodeFrames];
    [self updatePlayButton];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });

    if (_decoder.validAudio)
        [self enableAudio:YES];

    NSLog(@"play movie");    
}

- (void) pause
{
    _hiddenTime = 0;
    if (!self.playing)
        return;

    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    [self updatePlayButton];
    NSLog(@"pause movie");
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self updatePosition:position playMode:YES];
//    });
}

#pragma mark - actions

-(void)closFFmpeg{
    
    _decoder.isPlaying = NO;
//    [self pause];
    
    [self freeBufferedFrames];
    
    [_decoder closeFile];
//    [_decoder openFile:nil error:nil];
    _decoder.interruptCallback = nil;
    _decoder = nil;
    
    [_glView removeFromSuperview];
    _glView = nil;
    
    if (self.artworkFrame) {

        self.artworkFrame = nil;
    }
}

- (void) doneDidTouch: (id) sender
{
    _dealloced = YES;
    [self removeViewAtBottom];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(clickBackBtn)]){
        
        [self.kxBackDelegate clickBackBtn];
    }
    
}

-(void)removeViewAtBottom
{
    UIView *view = [self.view viewWithTag:KxMovieBottomViewTAG];
    if (view && view.superview) {
        [view removeFromSuperview];
    }
}

- (void) playDidTouch: (id) sender{
    
    if (self.playing){
        [self pause];
        [self dealMidPlayBtn];
        
    }
    else{
        [self removeMidPlayBtn];
        [self play];
    }
}

- (void) forwardDidTouch: (id) sender
{
    if(isAction)return;
    
    isAction = YES;
    
    [self pause];
    [self setMoviePosition: _moviePosition + 5];
//    [self play];
    
//    if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(playForward)]){
//        
//        if(![self.kxBackDelegate playForward]){
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有下一部视频" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
//        }
//    }
}

- (void) rewindDidTouch: (id) sender
{
    if(isAction)return;
    
    isAction = YES;
    
    [self pause];
    [self setMoviePosition: _moviePosition - 5];
//    [self play];
    
//    if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(playRewind)]){
//        
//        if(![self.kxBackDelegate playRewind]){
//            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有上一部视频" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
//        }
//    }
}

//- (void) progressDidChange: (id) sender
//{
//    NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
//    UISlider *slider = sender;
//    [self setMoviePosition:slider.value * _decoder.duration];
//}

-(void)valueChange:(float)value{
    _hiddenTime = 0;
}

-(void)routeChangeReason_OldDeviceUnavailable
{
    if (self.playing) {
        [self pause];
    }
}

-(void)endChange:(float)value{
    if (_dealloced) {
        return;
    }
    [self pause];
    [self setMoviePosition:value * _decoder.duration];
    [self play];
}

#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    NSLog(@"setMovieDecoder");
            
    if (!error && decoder) {
        
        _decoder        = decoder;
        
        
        if (_decoder.subtitleStreamsCount) {
            _subtitles = [NSMutableArray array];
        }
    
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
                
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        NSLog(@"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);

        [self setupPresentView];
        
        _bottomHUD.hidden       = NO;
        _progressLabel.hidden   = NO;
        _progressSlider.hidden  = NO;
        _leftLabel.hidden       = NO;
        _leftHUD.hidden         = NO;
        _topHUD.hidden          = NO;
        gesView.hidden = NO;
        
        if (_activityIndicatorView.isAnimating) {
            
            [_activityIndicatorView stopAnimating];

            [self restorePlay];
        }

    } else {
        
         if (self.isViewLoaded && self.view.window) {
        
             [_activityIndicatorView stopAnimating];
             if (!_interrupted)
                 [self handleDecoderMovieError: error];
         }
    }
}

- (void) restorePlay{

    [self play];
}

- (void) setupPresentView
{
    CGRect bounds = self.view.bounds;
    
    if (_decoder.validVideo) {
//        if(!_glView){
            _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
            _glView.contentMode = UIViewContentModeScaleAspectFit;
            _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            
            [self.view insertSubview:_glView atIndex:0];
        
        CGFloat heigth = self.view.frame.size.height;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-heigth, -heigth, 3*heigth, 3*heigth)];
        view.tag = KxMovieBottomViewTAG;
        view.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:view atIndex:0];
//        }
    }
    
    if (!_glView) {
        
        NSLog(@"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        if(!_imageView){
            _imageView = [[UIImageView alloc] initWithFrame:bounds];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
            
            [self.view insertSubview:_imageView atIndex:0];
        }
    }

    if (_decoder.validVideo) {
        
        [self checkIsShowGesIntr];
//        [self setupUserInteraction];
    
    } else {
       
        _imageView.image = [UIImage imageNamed:@"TAIG_LEFTVIEW.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (_decoder.duration == MAXFLOAT) {
        
        _leftLabel.text = @"\u221E"; // infinity
        _leftLabel.font = [UIFont systemFontOfSize:14];
        
        CGRect frame;
        
        frame = _leftLabel.frame;
        frame.origin.x += 40;
        frame.size.width -= 40;
        _leftLabel.frame = frame;
        
        frame =_progressSlider.frame;
        frame.size.width += 40;
        _progressSlider.frame = frame;
        
    } else {

    }
    
    if (_decoder.subtitleStreamsCount) {
        
        CGSize size = self.view.bounds.size;
        
        _subtitlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
        _subtitlesLabel.numberOfLines = 0;
        _subtitlesLabel.backgroundColor = [UIColor clearColor];
        _subtitlesLabel.opaque = NO;
        _subtitlesLabel.adjustsFontSizeToFitWidth = NO;
        _subtitlesLabel.textAlignment = NSTextAlignmentCenter;
        _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitlesLabel.textColor = [UIColor whiteColor];
        _subtitlesLabel.font = [UIFont systemFontOfSize:16];
        _subtitlesLabel.hidden = YES;

        [self.view addSubview:_subtitlesLabel];
    }
}

- (void) setupUserInteraction
{
    UIView * view = [self frameView];
    view.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    [_tapGestureRecognizer requireGestureRecognizerToFail: _doubleTapGestureRecognizer];
    
    [view addGestureRecognizer:_doubleTapGestureRecognizer];
    [view addGestureRecognizer:_tapGestureRecognizer];
    
//    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    _panGestureRecognizer.enabled = NO;
//    
//    [view addGestureRecognizer:_panGestureRecognizer];
}

-(void)checkIsShowGesIntr
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL isshowed = [user boolForKey:@"IsShowedGesIntr"];
    if (!isshowed) {
        [self gesIntrBtnClick];
        [self addGesIntr];
        [user setBool:YES forKey:@"IsShowedGesIntr"];
    }
}

-(void)addGesIntr
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    gesIntrView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,width , height)];
    gesIntrView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gesIntrView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blackColor];
    btn.alpha = 0.5;
    btn.frame = gesIntrView.frame;
    [btn addTarget:self action:@selector(gesIntrBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [gesIntrView addSubview:btn];
    
    CGFloat block = (gesIntrView.frame.size.width - 120*3)/4.0;
    for (int i=0; i <3; i++) {
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(block*(i+1) + 120*i, (gesIntrView.frame.size.height - 110)/2.0, 120, 110)];
        NSString *imagename = i==0?@"a_gestures_voice":(i==1?@"a_gestures_stop":@"a_gestures_progress");
        [imgv setImage:[UIImage imageNamed:imagename]];
        [gesIntrView addSubview:imgv];
    }
}

-(void)gesIntrBtnClick
{
    if (gesIntrView ) {
        if (gesIntrView.superview) {
            [gesIntrView removeFromSuperview];
        }
        gesIntrView = nil;
    }
}


- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;

    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }

    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];
                        
                        if (_decoder.validVideo) {
                        
                            CGFloat delta = _moviePosition - frame.position;
                            float cds=Get_Max_CD();
                            if (delta < 0-cds&&1) {
                                
                               // printf("delay=%d\n",delta);
                                int getflag = 0;
                                if(count>280)
                                while (1)
                                {
                                    count = _audioFrames.count;
                                    if (count<=0) {
                                        break;
                                    }
                                    frame = _audioFrames[0];
                                   CGFloat delta2 = _moviePosition - frame.position;
                                    if (delta2> 0 -cds)
                                    {
                                        getflag = 1;
                                         delta = delta2;
                                        break;
                                    }
                                    [_audioFrames removeObjectAtIndex:0];
                                }
//#ifdef DEBUG
//                                NSLog(@"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
//                                _debugAudioStatus = 1;
//                                _debugAudioStatusTS = [NSDate date];
//#endif
                                if (getflag)
                                {
                                    
                                }
                                else
                                {
                                    memset(outData, 0, numFrames * numChannels * sizeof(float));
                                    break; // silence and exit

                                }
                                                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                           
                            if (delta > cds && count > 1)
                            {

                                continue;
                            }
                           
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;                        
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;                
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //NSLog(@"silence audio");
//#ifdef DEBUG
//                _debugAudioStatus = 3;
//                _debugAudioStatusTS = [NSDate date];
//#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
            
    if (on && _decoder.validAudio) {
                
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        NSLog(@"audio device smr: %d fmt: %d chn: %d",
              (int)audioManager.samplingRate,
              (int)audioManager.numBytesPerSample,
              (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames{

    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles) {
        
        @synchronized(_subtitles) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle) {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    if(!self.playing) return NO;
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }
    return NO;
}

- (void) asyncDecodeFrames{

    if (self.decoding)
        return;
    
    /*__weak*/ KxMovieViewController *weakSelf = self;
    /*__weak*/ KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
            if (!strongSelf.playing){
                strongSelf = nil;
                return;
            }
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                /*__strong*/__weak KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    if (_dealloced) {
                        break;
                    }
                    [decoder setDecodeFrameing:YES];
                    NSArray *frames = [decoder decodeFrames:duration];
                    [decoder setDecodeFrameing:NO];

                    if (frames.count) {
                        
                        /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
                
        {
            /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void) tick
{

    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];        
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames = (_decoder.validVideo ? _videoFrames.count : 0) + (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames) {
            
            if (_decoder.isEOF) {
                
                [self pause];
                [self updateHUD];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
    
    if ((_tickCounter++ % 3) == 0) {
        [self updateHUD];
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    NSLog(@"tick correction %.4f", correction);
    static int audioFlag = 0;
    
    if (correction > 1.f || correction < -1.f) {
        
        NSLog(@"tick correction reset %.2f", correction);
        if(audioFlag == 0)//只优化一次
        {
            if (correction>1.f&&correction<1.3)
            {
                [self pause];
            }
            
            if (correction<-1.f&&correction>-1.2)
            {
                [self pause];
            }
            
            //[self setMoviePosition: _moviePosition + 1];
            //[self play];
            //_tickCorrectionTime = now;
           // _tickCorrectionPosition = _moviePosition;
            audioFlag = 1;
        }
        correction = 0;
        _tickCorrectionTime = 0;
    }
    else
    {
        audioFlag = 0;
    }
    
    return correction;
}


- (CGFloat) presentFrame
{
#if DEAL_RMVB_PROC
    if (getIsNeedLongCDs()) {
        return [self presentFramermvb];
    }
#endif
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
    //#ifdef DEBUG
    //    if (self.playing && _debugStartTime < 0)
    //        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
    //#endif
    
    return interval;
}

#if DEAL_RMVB_PROC
- (CGFloat) presentFramermvb
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            //1 准备rmvb缓存
            if (_videoFrames.count > 0) {

                frame = _videoFrames[0];
#if DEAL_RMVB_PROC
                [_videoFrameQuenBufferForRmvb addObject:frame];//将frame缓存到队列里
#endif
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
            //2播放缓存
            if (_videoFrameQuenBufferForRmvb.count > 0)
            {
                frame = _videoFrameQuenBufferForRmvb[0];
                if (_videoFrameQuenBufferForRmvb.count>33)
                {
                    [_videoFrameQuenBufferForRmvb removeObjectAtIndex:0];
                }
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {

        //interval = _bufferedDuration * 0.5;
                
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }

    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
//#ifdef DEBUG
//    if (self.playing && _debugStartTime < 0)
//        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
//#endif

    return interval;
}
#endif
- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
{
    if (_glView && self.playing) {
        
        [_glView render:frame];
        
    } else {
        
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        if([rgbFrame isKindOfClass:[KxVideoFrameRGB class]]){
            
            _imageView.image = [(KxVideoFrameRGB*)rgbFrame asImage];
        }
    }
    
    _moviePosition = frame.position;
        
    return frame.duration;
}

- (void) presentSubtitles
{
    NSArray *actual, *outdated;
    
    if ([self subtitleForPosition:_moviePosition
                           actual:&actual
                         outdated:&outdated]){
        
        if (outdated.count) {
            @synchronized(_subtitles) {
                [_subtitles removeObjectsInArray:outdated];
            }
        }
        
        if (actual.count) {
            
            NSMutableString *ms = [NSMutableString string];
            for (KxSubtitleFrame *subtitle in actual.reverseObjectEnumerator) {
                if (ms.length) [ms appendString:@"\n"];
                [ms appendString:subtitle.text];
            }
            
            if (![_subtitlesLabel.text isEqualToString:ms]) {
                
                CGSize viewSize = self.view.bounds.size;
                CGSize size = [ms sizeWithFont:_subtitlesLabel.font
                             constrainedToSize:CGSizeMake(viewSize.width, viewSize.height * 0.5)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
                _subtitlesLabel.text = ms;
                _subtitlesLabel.frame = CGRectMake(0, viewSize.height - size.height - 10,
                                                   viewSize.width, size.height);
                _subtitlesLabel.hidden = NO;
            }
            
        } else {
            
            _subtitlesLabel.text = nil;
            _subtitlesLabel.hidden = YES;
        }
    }
}

- (BOOL) subtitleForPosition: (CGFloat) position
                      actual: (NSArray **) pActual
                    outdated: (NSArray **) pOutdated
{
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (KxSubtitleFrame *subtitle in _subtitles) {
        
        if (position < subtitle.position) {
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)) {
            
            if (pOutdated) {
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual) {
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) *pActual = actual;
    if (pOutdated) *pOutdated = outdated;
    
    return actual.count || outdated.count;
}

- (void) updatePlayButton
{
    [_bottomHUD setPlayBtnStatus:self.playing];
}

-(CGFloat)getAllTime{
    return _decoder.duration;
}

-(CGFloat)getTime{
    return _moviePosition - _decoder.startTime;
}

- (void) updateHUD
{
    if (_disableUpdateHUD)
        return;
    
    if(_decoder.isEOF){
        
        if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(playEnd)]){
            
            [self.kxBackDelegate playEnd];
        }
    }
    
    const CGFloat duration = _decoder.duration;
    const CGFloat position = _moviePosition - _decoder.startTime;

    if(duration > 0 && !isDragProgress)
    {
        [_progressSlider setValue:position / duration ];
        _progressLabel.text = formatTimeInterval(position, NO);
    }
    self.currentTime = position;
    self.totalTime = duration;
    
    if (_decoder.duration != MAXFLOAT)
        _leftLabel.text = formatTimeInterval(duration, YES);//_leftLabel.text = formatTimeInterval(duration - position, YES);

}

- (void) showHUD: (BOOL) show
{
    _hiddenHUD = !show;    
    _panGestureRecognizer.enabled = _hiddenHUD;
        
    [[UIApplication sharedApplication] setIdleTimerDisabled:!_dealloced && _hiddenHUD];
    [[UIApplication sharedApplication] setStatusBarHidden:!_dealloced && _hiddenHUD];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         CGFloat alpha = _hiddenHUD ? 0 : 0.6;
                         _progressHUD.alpha     = alpha;
                         _bottomHUD.alpha       = alpha;
                         _topHUD.alpha          = alpha;
                         _leftHUD.alpha         = alpha;
                         
                         if(alpha != 0){
                             _hiddenTime = 0;
                             [self hiddenTime];
                         }else{
                             _hiddenTime = 10;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (_hiddenHUD && !self.playing) {
                             [self addMidPlayBtn];
                         }
                         else{
                             [self removeMidPlayBtn];
                         }
                     }];
}

-(void)dealMidPlayBtn
{
//    if (_hiddenHUD && !self.playing) {
//        [self addMidPlayBtn];
//    }
//    else{
//        [self removeMidPlayBtn];
//    }
}

-(void)addMidPlayBtn
{
//    if (!midPlayBtn) {
//        midPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        CGRect frame = gesView.frame;
//        midPlayBtn.frame = CGRectMake((frame.size.width - 60)/2.0, (frame.size.height - 40)/2.0, 60, 40);
//        [midPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
//        midPlayBtn.backgroundColor = [UIColor clearColor];
//        [midPlayBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [midPlayBtn addTarget:self action:@selector(playDidTouch:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    [gesView addSubview:midPlayBtn];
}

-(void)removeMidPlayBtn
{
//    if (midPlayBtn && midPlayBtn.superview) {
//        [midPlayBtn removeFromSuperview];
//    }
}

- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    if (_dealloced) {
        return;
    }
    _decoder.position = position;
}

- (void) enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    /*__weak*/ KxMovieViewController *weakSelf = self;

    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
            {
                /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
                if (!strongSelf || !_decoder) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                

                /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {
            {
                /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
                if (!strongSelf || !_decoder) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                /*__strong*/__weak KxMovieViewController *strongSelf = weakSelf;
                if (strongSelf) {
                
                    [strongSelf enableUpdateHUD];
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                    [strongSelf updateHUD];
                }
            });
        }        
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles) {
        @synchronized(_subtitles) {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}

- (void) handleDecoderMovieError: (NSError *) error{

    if(self.kxBackDelegate && [self.kxBackDelegate respondsToSelector:@selector(playError:)]){
        
        [self.kxBackDelegate playError:error];
    }

}

- (BOOL) interruptDecoder
{
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

@end

