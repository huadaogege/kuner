//
//  VideoViewController.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-6-6.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "VideoViewController.h"

@implementation VideoViewController

static bool isVideoPlaying = NO;

+(void)setVideoPlaying:(BOOL)playing{
    
    isVideoPlaying = playing;
}

+(BOOL)isVideoPlaying{
    return isVideoPlaying;
}

-(void)setVideo:(NSURL *)url progress:(float)progress{
    

    [self hiddenTime];
    [_timer invalidate];
    [_progressSlider setValue:progress];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];

    
    [[self moviePlayer] setContentURL:url];
    if ([[url pathExtension] isEqualToString:@"mp4"]||[[url pathExtension] isEqualToString:@"mov"]) {
        [_topHUD setVideoNameWith:[url lastPathComponent]];
    }else{
        [_topHUD setVideoNameWith:[[url.absoluteString lastPathComponent]stringByDeletingPathExtension]];
    }
  
   
}

-(void)playFromLastTime:(float)lasttime{
    
    _remenber = 0;
    _hiddenTime = 0;
    _isPlaying = YES;
    [_bottomHUD setPlayBtnStatus:YES];
    [[self moviePlayer] setInitialPlaybackTime:lasttime];
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
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.frame = self.view.bounds;
        [self.view addSubview:view];
        
        gesView = view;
        
        [[self moviePlayer]setControlStyle:MPMovieControlStyleNone];
        
        UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGes.numberOfTapsRequired = 2;
        [gesView addGestureRecognizer:doubleTapGes];
        
        UITapGestureRecognizer *_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [view addGestureRecognizer:_tapGestureRecognizer];
        [_tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGes];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        
        _bottomHUD = [[CustomGesView alloc] initBottomViewWith:CGRectMake(0,height - 90,width,45)];
        _bottomHUD.delegate = self;
        
        _leftHUD = [[CustomVolumeView alloc] initWithFrame:CGRectMake(width - 45 - 15,(height - 210) / 2,45,210)];
        _leftHUD.backgroundColor = [UIColor clearColor];
        _leftHUD.layer.cornerRadius = 20;
        _leftHUD.layer.masksToBounds = YES;
        _leftHUD.delegate = self;
        
        _progressHUD = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)];
        _progressHUD.backgroundColor = [UIColor blackColor];
        
        _topHUD = [[CustomGesView alloc] initTopViewWith:CGRectMake(0,0,width,30*WINDOW_SCALE+20)];
        _topHUD.delegate = self;
        
        _progressHUD.frame  = CGRectMake(0,
                                         height - 38,
                                         width,
                                         38);
        _progressHUD.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        
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
        _leftLabel.frame = CGRectMake(width-60, 12, 60, _progressLabel.bounds.size.height);
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
        
        
        [self addGestureRecognizer];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  移除 MPMoviePlayerViewController 本身注册的播放完成的通知
     *  @see http://stackoverflow.com/questions/13420564/how-to-stop-mpmovieplayerviewcontrollers-automatic-dismiss-on-movieplaybackdidf
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkIsShowGesIntr];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stop];
    [FileSystem clearKeVideoURL];
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
    gesIntrView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        if (direction == kVideoMoveDirectionNone) {
            direction = [self determineCameraDirection:touchPoint ifRefresh:NO];
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
            NSTimeInterval duration = [[self moviePlayer] duration];
            CGFloat lastvar = duration > 60? 5 : 2;
            CGFloat lastpro = (duration -lastvar)/duration;
            _progressvalue = _progressvalue >= lastpro?(duration -lastvar)/duration:_progressvalue;
            [_progressSlider setValue:_progressvalue];
            NSString *nowtime = formatTimeInterval(duration * _progressvalue,NO);
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
            [gesTipView setDirection:tmpd nowtime:nowtime totalTime:formatTimeInterval(duration,NO)];
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


-(void)handleTap:(UITapGestureRecognizer *) sender{
    
    [self showHUD:_hiddenHUD];
}


-(void)doubleTap:(UITapGestureRecognizer *) sender{
    
    [self playDidTouch:nil];
}

-(VideoMoveDirection )determineCameraDirection:(CGPoint )translation ifRefresh:(BOOL)isrefresh
{
    if (direction != kVideoMoveDirectionNone && !isrefresh)
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


#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    [self hiddenTime];
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
}

-(void)stopTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

-(void)updateTime{

    _remenber++;
    if (_remenber >= 6 && [[self moviePlayer] duration] == 0) {
        if (![[self moviePlayer] readyForDisplay]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"stopMov" object:@"stopMov" userInfo:nil];
             [_timer invalidate];
           
        }
    }
    if(_isAction == NO){
        _timeValue = [[self moviePlayer] currentPlaybackTime];
        _leftLabel.text = formatTimeInterval([[self moviePlayer] duration], NO);
        if (!isDragProgress) {
            _progressLabel.text = formatTimeInterval([[self moviePlayer] currentPlaybackTime], NO);
            [_progressSlider setValue:(([[self moviePlayer] currentPlaybackTime]>0?[[self moviePlayer] currentPlaybackTime]:0) / ([[self moviePlayer] duration]>0?[[self moviePlayer] duration]:1000.0))];
        }
    }
    
}

-(void)doneDidTouch:(id)sender{

    [[self moviePlayer] pause];
    
    [self stopTikTimer];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(saveMPmovie:totalTime:player:)]) {
        [self.delegate saveMPmovie:[self moviePlayer].currentPlaybackTime totalTime:[self moviePlayer].duration player:[self moviePlayer]];
    }
    
}

-(void)stopTikTimer
{
    isplaystate = NO;
    [self stopTimer];
    _hiddenTime = 0;
}

- (void) valueChange:(float)value{
    _isAction = YES;
    _hiddenTime = 0;
    [[self moviePlayer] setCurrentPlaybackTime:([[self moviePlayer] duration] * value)];
    _progressLabel.text = formatTimeInterval([[self moviePlayer] currentPlaybackTime], NO);
}

- (void) endChange:(float)value{
    _isAction = NO;
//    [[self moviePlayer] setCurrentPlaybackTime:([[self moviePlayer] duration] * value)];
//    [self updateTime];
}

- (void) valueChanged:(NSTimeInterval)value{
    _isAction = YES;
    _hiddenTime = 0;
    [[self moviePlayer] setCurrentPlaybackTime:value];
    _progressLabel.text = formatTimeInterval([[self moviePlayer] currentPlaybackTime], NO);
}

- (void) endChanged:(NSTimeInterval)value{
    _isAction = NO;
    [[self moviePlayer] setCurrentPlaybackTime:value];
    [self updateTime];
}


- (void) rewindDidTouch:(id)sender{
    
    _hiddenTime = 0;
    _timeValue -= 5;
    [[self moviePlayer] setCurrentPlaybackTime:_timeValue];
    [self play];
}

- (void) playDidTouch:(id)sender{

    if(_isPlaying){
        if ([[self moviePlayer] currentPlaybackRate] == 0) {
            _hiddenTime = 0;
            isplaystate = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification
                                                                object:[self moviePlayer]];
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
    _timeValue += 5;
    [[self moviePlayer] setCurrentPlaybackTime:_timeValue];
    [self play];
}

-(void)volumeChange:(float)value{
    ///
}

-(void)routeChangeReason_OldDeviceUnavailable
{
    if (_isPlaying) {
        [self pause];
    }
}

- (void) showHUD: (BOOL) show
{
    _hiddenHUD = !show;
    NSLog(@"hidden Hud:%d,playstate:%d",_hiddenHUD,isplaystate);
    [[UIApplication sharedApplication] setStatusBarHidden:isplaystate && _hiddenHUD];
    [[UIApplication sharedApplication] setIdleTimerDisabled:isplaystate && _hiddenHUD];
    
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

-(BOOL)canBePlaying{
    return [[self moviePlayer] isPreparedToPlay];
}
-(void)play{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    

    _remenber = 0;
    _hiddenTime = 0;
    _isPlaying = YES;
    [[self moviePlayer] readyForDisplay];
    [[self moviePlayer] play];
    
    [_bottomHUD setPlayBtnStatus:YES];
}

-(void)pause{
    _isPlaying = NO;
    _hiddenTime = 0;
    [[self moviePlayer] pause];
    [_bottomHUD setPlayBtnStatus:NO];
}
-(void)stop{
    _isPlaying = NO;
    _hiddenTime = 0;
    [self stopTimer];
    [[self moviePlayer] stop];
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




- (void)dealloc {
    isplaystate = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
}




@end
