//
//  VideoViewController.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-6-6.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "ListVideoViewController.h"
#import "CustomNotificationView.h"

@interface ListVideoViewController ()<CustomVideoSubViewDelegate>{
    float _duration;
    UIActivityIndicatorView* _loadingView;
    BOOL _changeTime;
    
    CGPoint startPoint;
    CGFloat _progressvalue;
    CGFloat originProgressWidth;
    CGFloat originVolumeHeight;
    VideoMoveDirection direction;
    UIView *gesView;
    BOOL isDragProgress;
    BOOL isLandscape;
    UIInterfaceOrientation theOrientation;
    UIView *gesIntrView;
}

@property (nonatomic, retain) UIView *playView;
@property (nonatomic, retain) NSMutableArray *playlistData;

@property (nonatomic, retain) NSMutableArray *timeDurationArray;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;

@end

@implementation ListVideoViewController

static bool isVideoPlaying = NO;

+(void)setVideoPlaying:(BOOL)playing{
    
    isVideoPlaying = playing;
}

+(BOOL)isVideoPlaying{
    return isVideoPlaying;
}

-(void)setVideos:(NSArray *)urls title:(NSString*)title durations:(NSArray*)durations lasttime:(CGFloat)lasttime{
    
    _durationArray = durations;
    [self hiddenTime];
    _playerLayer = [[AVPlayerLayer alloc] init];
    [_playerLayer setFrame:_playView.frame];
    [_playView.layer addSublayer:_playerLayer];
    _playlistData = [[NSMutableArray alloc] init];
    _timeDurationArray = [[NSMutableArray alloc] init];
    for (int i=0; i<urls.count; i++) {
        NSURL *videoPath1 = [urls objectAtIndex:i];
        AVPlayerItem *videoItem1 = [AVPlayerItem playerItemWithURL:videoPath1];
                [_playlistData addObject:videoItem1];
    }
    _duration = 0;
    for (int i=0; i<durations.count; i++) {
        NSString* durationStr = [durations objectAtIndex:i];
        _duration += durationStr.floatValue;
        if (lasttime > _duration) {
            _nowIndex = i + 1;
        }
        [_timeDurationArray addObject:[NSNumber numberWithFloat:_duration]];
    }
//    _nowIndex = 0;
    
    
    [_progressSlider setValue:lasttime / _duration];
    _progressLabel.text = formatTimeInterval(lasttime, NO);
    _leftLabel.text = formatTimeInterval(_duration, NO);
    [self setPlayAt:_nowIndex duration:lasttime change:YES];
    
    [_topHUD setVideoNameWith:title];
   
}




- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self showHUD:YES];
    [self pause];
    
 }

-(id)init{
    
    self = [super init];
    if(self){

        self.videoisplaying = NO;
        _hiddenTime = 0;
        _hiddenHUD = NO;
        _remenber = 0;
        _handoff = NO;
        isplaystate = YES;
        _playView = [[UIView alloc] init];
        _playView.frame = self.view.bounds;
        _playView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_playView];
        gesView = _playView;
        theOrientation = UIInterfaceOrientationPortrait;
        
        UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGes.numberOfTapsRequired = 2;
        [gesView addGestureRecognizer:doubleTapGes];
        
        UITapGestureRecognizer *_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [_playView addGestureRecognizer:_tapGestureRecognizer];
        
        [_tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGes];
        
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        
        _progressHUD = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
        _progressHUD.backgroundColor = [UIColor blackColor];
        _progressHUD.frame  = CGRectMake(0,
                                         height - 38,
                                         width,
                                         38);
        _progressHUD.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        _bottomHUD = [[CustomGesView alloc] initBottomViewWith:CGRectMake(0,height - 90,width,45)];
        _bottomHUD.delegate = self;
        
        _topHUD = [[CustomGesView alloc] initTopViewWith:CGRectMake(0,0,width,30*WINDOW_SCALE+20)];
        _topHUD.delegate = self;
       
        
        _leftHUD = [[CustomVolumeView alloc] initWithFrame:CGRectMake(width - 45 - 15,(height - 210) / 2,45,210)];
        _leftHUD.backgroundColor = [UIColor clearColor];
        _leftHUD.layer.cornerRadius = 20;
        _leftHUD.layer.masksToBounds = YES;
        _leftHUD.delegate = self;
        
        _playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        gesTipView = [[CustomGesView alloc] initWithFrame:CGRectMake((width - 140)/2.0, (height - 70)/2.0, 140, 70)];
        
        [self.view addSubview:_progressHUD];
        [self.view addSubview:_bottomHUD];
        [self.view addSubview:_topHUD];
        [self.view addSubview:_leftHUD];
//        [self.view addSubview:gesTipView];
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.frame = CGRectMake(0, 12, 60, 13);
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.opaque = NO;
        _progressLabel.adjustsFontSizeToFitWidth = NO;
        _progressLabel.textAlignment = NSTextAlignmentRight;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.text = @"0:00:00";
        _progressLabel.font = [UIFont systemFontOfSize:12];
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.frame = CGRectMake(width-50, 12, 60, _progressLabel.bounds.size.height);
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.opaque = NO;
        _leftLabel.adjustsFontSizeToFitWidth = NO;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.text = @"-99:59:59";
        _leftLabel.font = [UIFont systemFontOfSize:12];
        _leftLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        _progressSlider = [[CustomUISlider alloc] init];
        _progressSlider.delegate = self;
        _progressSlider.frame = CGRectMake(_progressLabel.bounds.size.width + 10,
                                           10,
                                           _leftLabel.frame.origin.x - _progressLabel.bounds.size.width - 20,
                                           20);
        _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        
        [_progressHUD addSubview:_progressLabel];
        [_progressHUD addSubview:_progressSlider];
        [_progressHUD addSubview:_leftLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playState:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [self addGestureRecognizer];
    }
    
    return self;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkIsShowGesIntr];
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
}

-(void)handleSwipe:( UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture translationInView:gesView];
    
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        startPoint = touchPoint;
        _progressvalue = 0;
        
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
            
            CGFloat newVar = addVar/2.0 + oldVar;
            
            if(newVar < 0){
                newVar = 0;
            }else if (newVar > kVolumeHeight){
                
                newVar = kVolumeHeight;
            }
            
            [_leftHUD volumeChange:newVar/kVolumeHeight];
            [_leftHUD setVolume:newVar/kVolumeHeight];
//            startPoint = touchPoint;
        }
        else if (direction == kVideoMoveDirectionLeft || direction == kVideoMoveDirectionRight)
        {
//            _progressHUD.alpha     = 1;
//            _hiddenTime = 0;
            isDragProgress = YES;
            
            CGFloat totoalVar = _progressSlider.frame.size.width;
            CGFloat addVar = touchPoint.x - startPoint.x;
            CGFloat oldVar = originProgressWidth;
            
            CGFloat newVar = addVar/3.0 + oldVar;
            if(newVar < 0){
                newVar = 0;
            }else if (newVar > totoalVar){
                newVar = totoalVar;
            }
            
            _progressvalue = newVar/totoalVar;
            
            CGFloat lastvar = _duration > 60? 5 : 2;
            CGFloat lastpro = (_duration -lastvar)/_duration;
            _progressvalue = _progressvalue >= lastpro?(_duration -lastvar)/_duration:_progressvalue;
            
            [_progressSlider setValue:_progressvalue];
            NSString *nowtime = formatTimeInterval(_duration * _progressvalue,NO);
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
            [gesTipView setDirection:tmpd nowtime:nowtime totalTime:formatTimeInterval(_duration,NO)];
            tmpPoint = touchPoint;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded )
    {
        // now tell the camera to stop
        
        if (direction == kVideoMoveDirectionLeft || direction == kVideoMoveDirectionRight)
        {
            isDragProgress = NO;
            [self valueChange:_progressvalue];
            [self endChange:_progressvalue];
//            _hiddenTime = 3;
            //            [self hiddenTime];
            [self removeSiwpeTipView];
        }
        
        NSLog (@ "Stop" );
        
    }
}

-(void)doubleTap:(UITapGestureRecognizer *) sender{
    
    [self playDidTouch:nil];
}


-(void)handleTap:(UITapGestureRecognizer *) sender{
    
    [self showHUD:_hiddenHUD];
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
    if (isLandscape != UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self didlayoutViews:YES];
        [self gesIntrBtnClick];
    }
    isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    [self setRotateBtnImage];
    theOrientation = toInterfaceOrientation;
}

-(void)didlayoutViews:(BOOL)isWidthReverse
{
    CGFloat theheight = isWidthReverse?_playView.frame.size.width : _playView.frame.size.height;
    CGFloat theWidth = isWidthReverse?_playView.frame.size.height : _playView.frame.size.width;
    
    _playerLayer.frame = CGRectMake(0, 0,theWidth, theheight);
}

-(void)ratoteBtnClick
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        isLandscape = !isLandscape;
        [FileSystem rotateWindow:isLandscape];
        [self didlayoutViews:NO];
    }
}

-(void)setRotateBtnImage
{
    [_bottomHUD setRotateBtnStatus:isLandscape];
}

#pragma mark -

-(void)playState:(NSNotification *)notf{
    
    if (!_handoff) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(removeMPmovie)]) {
            [self.delegate removeMPmovie];
        }
    }
//

    
}



-(void)viewWillAppear:(BOOL)animated{
    
    [self hiddenTime];
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
}
-(void)stopTimer{
    [_timer invalidate];
    
}

-(void)updateTime{

    if(_isAction == NO){
        NSInteger idx = 0;
        if (_myQueuePlayer.currentItem) {
            
            idx = [_playlistData indexOfObject:_myQueuePlayer.currentItem];
        }
        _nowIndex = idx;
        _timeValue = CMTimeGetSeconds(_myQueuePlayer.currentItem.currentTime);
        if (idx < _timeDurationArray.count && idx >= 1) {
            float dur = ((NSNumber*)[_timeDurationArray objectAtIndex:idx - 1]).floatValue;
            _timeValue += dur;
        }
        if ((_lastTimeValue == _timeValue || _myQueuePlayer.rate == 0) && _isPlaying) {
            if (!_loadingView) {
                _loadingView = [[UIActivityIndicatorView alloc] init];
                _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
                _loadingView.frame = _playerLayer.frame;
            }
            [_playView addSubview:_loadingView];
            if (!_loadingView.isAnimating) {
                [_loadingView startAnimating];
            }
        }
        else {
            [_loadingView stopAnimating];
            [_loadingView removeFromSuperview];
        }
        _leftLabel.text = formatTimeInterval(_duration, NO);
        
        if (!isDragProgress) {
            _progressLabel.text = formatTimeInterval(_timeValue, NO);
            [_progressSlider setValue:((_timeValue>0?_timeValue:0) / (_duration>0?_duration:1000.0))];
        }
        
        _lastTimeValue = _timeValue;
    }
    
    
}

-(void)doneDidTouch:(id)sender{
    float  preduration;
    for (int i=0; i<_nowIndex; i++) {
        
        if (i < _durationArray.count) {
            
            NSString* durationStr = [_durationArray objectAtIndex:i];
            preduration += durationStr.floatValue;
        }

    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(saveMPmovie:totalTime:player:)]) {
        [self.delegate saveMPmovie:CMTimeGetSeconds(_myQueuePlayer.currentItem.currentTime)+preduration totalTime:0 player:_myQueuePlayer];
        
    }
    isplaystate = NO;
    _hiddenTime = 0;
}

- (void) valueChange:(float)value{
    
    _isAction = YES;
    _hiddenTime = 0;
    float toDuration = value *_duration;
    [self changeToTime:toDuration];
}

-(void)routeChangeReason_OldDeviceUnavailable
{
    if (_isPlaying) {
        [self pause];
    }
}

-(void)changeToTime:(float)toDuration {
    if (_changeTime) {
        return;
    }
    _changeTime = YES;
    [_myQueuePlayer pause];
    NSInteger toIdx = 0;
    for (NSInteger i = 0 ; i < _timeDurationArray.count; i ++) {
        NSNumber* duration = [_timeDurationArray objectAtIndex:i];
        if (toDuration < duration.floatValue) {
            toIdx = i;
             _nowIndex = toIdx;
            break;
        }
        else if (toDuration-duration.floatValue<5&&toDuration-duration.floatValue>0){
            if (i<_timeDurationArray.count-1) {
                toIdx = i+1;
                _nowIndex = toIdx;
            }else{
                toIdx = i;
                 _nowIndex = toIdx;
            }
            break;
        }
    }
    NSInteger idx = [_playlistData indexOfObject:_myQueuePlayer.currentItem];
    BOOL needReinit = NO;
    if (idx == NSNotFound) {
        idx = toIdx;
         _nowIndex = toIdx;
        needReinit = YES;
         NSLog(@"idx == NSNotFound");
    }
//    NSLog(@"toIdx : %ld , idx : %ld",(long)toIdx,(long)idx);
    if (idx != toIdx) {
//
        if (toIdx > idx) {
            AVPlayerItem *videoItemTmp = [_playlistData objectAtIndex:toIdx];
            for (NSInteger i = idx ; i < toIdx; i ++) {
                AVPlayerItem *videoItem = [_playlistData objectAtIndex:i];
                [_myQueuePlayer removeItem:videoItem];
            }
            [_myQueuePlayer replaceCurrentItemWithPlayerItem:videoItemTmp];
//            [_myQueuePlayer play];
        }
        [self setPlayAt:toIdx duration:toDuration change:toIdx < idx];
//        [_myQueuePlayer pause];
        
    }
    else {
        if (needReinit) {
            [self reinitArrayAt:idx];
        }
        float toD = toDuration;
        if (idx < _timeDurationArray.count && idx > 0) {
            toD = toD - ((NSNumber*)[_timeDurationArray objectAtIndex:idx - 1]).floatValue;
            if (toD < 0 ) {
                toD = 0;
            }
            else if(toD > ((NSNumber*)[_timeDurationArray objectAtIndex:idx]).floatValue){
                toD = ((NSNumber*)[_timeDurationArray objectAtIndex:idx]).floatValue;
            }
        }
        [_myQueuePlayer seekToTime:CMTimeMakeWithSeconds(toD, _myQueuePlayer.currentTime.timescale)];
        _progressLabel.text = formatTimeInterval(toDuration, NO);
    }
    [_myQueuePlayer pause];
    [_myQueuePlayer play];
    _isPlaying = YES;
    [_bottomHUD setPlayBtnStatus:YES];
    
//    [_playerLayer removeFromSuperlayer];
//    _playerLayer = nil;
//    [_myQueuePlayer pause];
//    _playerLayer = [[AVPlayerLayer alloc] init];
//    [_playerLayer setFrame:_playView.frame];
//    [_playerLayer setPlayer:_myQueuePlayer];
//    
//    [_playView.layer addSublayer:_playerLayer];
    _changeTime = NO;
}

-(void)changeTimeDelay{
    _changeTime = NO;
}

-(void)itemDidFinishPlaying :(NSNotification *)notification {
    
    
    AVPlayerItem *p = [notification object];
    
    NSInteger idx = [_playlistData indexOfObject:p];
    _nowIndex = idx;
    if (idx + 1 < _playlistData.count) {
        AVPlayerItem *p2 = [_playlistData objectAtIndex:(idx + 1)];
        [p2 seekToTime:CMTimeMakeWithSeconds(0, _myQueuePlayer.currentTime.timescale)];
    }
    if (idx == _playlistData.count - 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification
                                                            object:_myQueuePlayer];
    }
}

-(void)reinitArrayAt:(NSInteger)idx{
    if (idx < 0 || idx >= _playlistData.count) {
        return;
    }
    NSLog(@"**********1111*********** : %ld,items count:%ld",(long)idx,_myQueuePlayer.items.count);
    [_myQueuePlayer removeAllItems];
    for (NSInteger i = idx ; i < _playlistData.count; i ++) {
        AVPlayerItem *videoItem = [_playlistData objectAtIndex:i];
        [_myQueuePlayer insertItem:videoItem afterItem:nil];
        if (i == idx) {
            [_myQueuePlayer replaceCurrentItemWithPlayerItem:videoItem];
        }
    }
    
     NSLog(@"**********2222*********** : %ld,items count:%ld",(long)idx,_myQueuePlayer.items.count);
}

-(void)setPlayAt:(NSInteger)idx duration:(float)duration change:(BOOL)need{
    if (!_myQueuePlayer) {
        _myQueuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:_playlistData]];
        for (int i=0; i<[_playlistData count]; i++) {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_playlistData objectAtIndex:i]];
            
        }
        [_playerLayer setPlayer:_myQueuePlayer];
    }
    if(need){
        [self reinitArrayAt:idx];
    }
//    NSMutableArray* array = [NSMutableArray arrayWithArray:_myQueuePlayer.items];
//    if (array.count + idx < _playlistData.count) {
//        [self reinitArrayAt:idx];
//        NSLog(@"reinitArrayAt");
//    }
    
    if (idx != 0 && idx < _timeDurationArray.count) {
        float durationD = duration - ((NSNumber*)[_timeDurationArray objectAtIndex:(idx - 1)]).floatValue;
        
        [_myQueuePlayer seekToTime:CMTimeMakeWithSeconds(durationD, _myQueuePlayer.currentTime.timescale)];
        _progressLabel.text = formatTimeInterval(duration, NO);
        if (_myQueuePlayer.rate == 0) {
            [_myQueuePlayer pause];
            [_myQueuePlayer play];
        }
    }
}

- (void) endChange:(float)value{
    
//    float toDuration = value*_duration;
//    [self changeToTime:toDuration];
    //    [[self moviePlayer] setCurrentPlaybackTime:([[self moviePlayer] duration] * value)];
//    [self updateTime];
//    [self performSelector:@selector(doChangeTimeDelay:) withObject:[NSNumber numberWithFloat:value] afterDelay:.1];
    [self performSelector:@selector(endChangeDone) withObject:nil afterDelay:1];
}

-(void)doChangeTimeDelay:(NSNumber*)time {
    float toDuration = time.floatValue *_duration;
    [self changeToTime:toDuration];
}

-(void)endChangeDone{
    _isAction = NO;
}

- (void) valueChanged:(NSTimeInterval)value{
    _isAction = YES;
    _hiddenTime = 0;
     [_progressSlider setValue:value/_duration];
    [self changeToTime:value];
}

- (void) endChanged:(NSTimeInterval)value{
    _isAction = NO;
    [_myQueuePlayer seekToTime:CMTimeMakeWithSeconds(value, _myQueuePlayer.currentTime.timescale)];
   
    [self updateTime];
}


- (void) rewindDidTouch:(id)sender{
    _hiddenTime = 0;
    NSInteger idx = [_playlistData indexOfObject:_myQueuePlayer.currentItem];
    _timeValue = CMTimeGetSeconds(_myQueuePlayer.currentItem.currentTime);
    if (idx < _timeDurationArray.count && idx >= 1) {
        float dur = ((NSNumber*)[_timeDurationArray objectAtIndex:idx - 1]).floatValue;
        _timeValue += dur;
    }
    _timeValue -= 5;
    [self changeToTime:_timeValue];
    [self play];
}

- (void) playDidTouch:(id)sender{

    if(_isPlaying){
        if ([_myQueuePlayer rate] == 0) {
            _hiddenTime = 0;
            isplaystate = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification
                                                                object:_myQueuePlayer];
        }
        else {
            [self pause];
//            [self dealMidPlayBtn];
        }
    }else{
        if ([self canBePlaying]) {
//            [self removeMidPlayBtn];
            [self play];
        }
    }
}

- (void) forwardDidTouch:(id)sender{
    
    _hiddenTime = 0;
    NSInteger idx = [_playlistData indexOfObject:_myQueuePlayer.currentItem];
    _timeValue = CMTimeGetSeconds(_myQueuePlayer.currentItem.currentTime);
    if (idx < _timeDurationArray.count && idx >= 1) {
        float dur = ((NSNumber*)[_timeDurationArray objectAtIndex:idx - 1]).floatValue;
        _timeValue += dur;
    }
    _timeValue += 5;
    [self changeToTime:_timeValue];
    [self play];
}

-(void)volumeChange:(float)value{
    ///
}

- (void) showHUD: (BOOL) show
{
    _hiddenHUD = !show;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:isplaystate &&_hiddenHUD];
    [[UIApplication sharedApplication] setStatusBarHidden:isplaystate && _hiddenHUD];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         CGFloat alpha = _hiddenHUD ? 0 : 1;
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
//                         [self dealMidPlayBtn];
                     }];
    
}

-(void)dealMidPlayBtn
{
//    if (_hiddenHUD && !_isPlaying) {
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
//        
//        [midPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
//        midPlayBtn.backgroundColor = [UIColor clearColor];
//        [midPlayBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [midPlayBtn addTarget:self action:@selector(playDidTouch:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    CGRect frame = gesView.frame;
//    midPlayBtn.frame = CGRectMake((frame.size.width - 60)/2.0, (frame.size.height - 40)/2.0, 60, 40);
//    [gesView addSubview:midPlayBtn];
}

-(void)removeMidPlayBtn
{
//    if (midPlayBtn) {
//        if (midPlayBtn.superview) {
//            [midPlayBtn removeFromSuperview];
//        }
//        midPlayBtn = nil;
//    }
}

-(void)hiddenTime{
    if (!isplaystate) {
        return;
    }
    
    if(_hiddenTime++ > 5){
        
        [self showHUD:NO];
    }else{
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hiddenTime) userInfo:nil repeats:NO];
    }
    
}

-(BOOL)canBePlaying{
    return [_myQueuePlayer status] == AVPlayerStatusReadyToPlay;
}
-(void)play{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    

    _remenber = 0;
    _hiddenTime = 0;
    _isPlaying = YES;
    [_myQueuePlayer play];
    
    //    MPNowPlayingInfoCenter
    [_myQueuePlayer setAllowsAirPlayVideo:YES];
    [_bottomHUD setPlayBtnStatus:YES];
}

-(void)pause{
    _isPlaying = NO;
    _hiddenTime = 0;
    [_myQueuePlayer pause];
    [_bottomHUD setPlayBtnStatus:NO];
}
-(void)stop{
    _isPlaying = NO;
    _hiddenTime = 0;
    [self stopTimer];
    [_myQueuePlayer pause];
    self.videoisplaying = NO;
    isplaystate = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    //    return [NSString stringWithFormat:@"%@%d:%0.2d:%0.2d", isLeft ? @"-" : @"", h,m,s];
    return [NSString stringWithFormat:@"%ld:%0.2ld:%0.2ld", (long)h,(long)m,(long)s];
}



// Faster one-part variant, called from within a rotating animation block, for additional animations during rotation.// A subclass may override this method, or the two-part variants below, but not both.- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_AVAILABLE_IOS(3_0);




-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_loadingView stopAnimating];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    self.delegate = nil;
    [_playView removeFromSuperview];
    _myQueuePlayer = nil;
    isplaystate = NO;
     [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
}




@end
