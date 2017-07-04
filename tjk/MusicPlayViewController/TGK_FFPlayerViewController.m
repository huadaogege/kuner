//
//  TGK_FFPlayerViewController.m
//  tjk
//
//  Created by huadao on 14-11-11.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "TGK_FFPlayerViewController.h"
//#import "CustomNavBackView.h"
#import "UIImage+Bundle.h"
#import "MusicPlayerViewController.h"


#define IPHONE_SIX (self.view.frame.size.height/568.0)


void audioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer);

void audioQueueIsRunningCallback(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID);

void audioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer) {
    
    TGK_FFPlayerViewController * MviewController = (__bridge TGK_FFPlayerViewController*)inClientData;
    [MviewController audioQueueOutputCallback:inAQ inBuffer:inBuffer];
  
}

void audioQueueIsRunningCallback(void *inClientData, AudioQueueRef inAQ,
                                 AudioQueuePropertyID inID) {
    
    TGK_FFPlayerViewController *MviewController = (__bridge TGK_FFPlayerViewController*)inClientData;
    [MviewController audioQueueIsRunningCallback];

}


@interface TGK_FFPlayerViewController ()

@end

@implementation TGK_FFPlayerViewController
static  TGK_FFPlayerViewController * obj=nil;
+(TGK_FFPlayerViewController *)instance
{
    if (obj==nil)
    {
        obj=[[TGK_FFPlayerViewController alloc]init];
    }
    return obj;
}
-(id)init
{
    self=[super init];
    if (self) {
        
        states=123;// 播放状态
        copydoneplay=NO; //拷贝暂停音乐参数
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.view.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:54.0/255.0 blue:62.0/255.0 alpha:1.0];
        
        _songInfo=[[NSMutableDictionary alloc]init];//向系统界面传歌曲信息
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(canplay) name:@"canplay" object:nil];
                    }
    return self;
}
-(void)canplay{
    
    [self pauseAudio];
}

-(void)getUrl:(FileBean*)filebean cacahe:(NSString *)path
{
   
    _nowSongs=path;//用来播放
    _currentBean=filebean;// 用来解析歌曲数据

      
    MediaBean * bean=[[CustomFileManage instance] getMediaCache:_currentBean];
    
    UIImage *image=[[UIImage alloc]init];
    if (bean.img)
    {
        MPMediaItemArtwork *tempAlbumArt; //= [[MPMediaItemArtwork alloc]init];
        image=bean.img;
        if (image) {
           tempAlbumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
            

        }else{
            tempAlbumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"]];
            image=[UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        }
                if (tempAlbumArt!=nil) {
            [_songInfo setObject:tempAlbumArt forKey:MPMediaItemPropertyArtwork];
        }else
        {
        
        }

    }else
    {
      image=[UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    }
    NSString * musicname=[[[path lastPathComponent] componentsSeparatedByString:@"."]objectAtIndex:0];
   
    self.title=[[[path lastPathComponent] componentsSeparatedByString:@"."]objectAtIndex:0];
    [_songInfo setObject:[[[path lastPathComponent] componentsSeparatedByString:@"."]objectAtIndex:0] forKey:MPMediaItemPropertyAlbumTitle];
    [_songInfo setObject:NSLocalizedString(@"unknown",@"") forKey:MPMediaItemPropertyArtist];
    [_songInfo setObject:[[[path lastPathComponent] componentsSeparatedByString:@"."]objectAtIndex:0] forKey:MPMediaItemPropertyTitle];
    
   //向播放界面传值
    [[MusicPlayerViewController instance]setTitle:musicname Icon:image musicName:musicname singerName:NSLocalizedString(@"unknown",@"") hasimage:nil];
}


-(void)changeCurrentTime
{
    if (started_) {
        [self setNowTime:floor(startedTime_ + currentTimeInterval) countTime:floor(durationTime_)];
    }else
    {
    
    }
    
}

-(void)slidess:(CustomSliderView *)slider ValueChangeToValue:(float)value
{
    if (_state_== AUDIO_STATE_PLAYING)//如果当前状态是播放或者暂停的时候触发进度条
    {
        [seekTimer_ setFireDate:[NSDate distantFuture]];
        
        [self setPlayTime:value];
        //动态改变时间

    }else if (_state_==AUDIO_STATE_PAUSE){
    
        [seekTimer_ setFireDate:[NSDate distantFuture]];
        
        [self setPlayTime:value];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"slider" object:nil];

    }
   
}


-(void)setPlayTime:(float)time{
    
    if (started_) {
       startedTime_ = time * durationTime_;
        }
    else
    {
       
    }
    
    //改变播放时间
    [self changeCurrentTime];
    
}

- (void) endChangess:(float)value{
    
    [self pauseAudio];
    AudioQueueStop(audioQueue_, YES);
    startedTime_ = value * ([ffmpegDecoder_ duration]);
    [ffmpegDecoder_ seekTime:startedTime_];
    
    [self playAudio];
    [[MusicPlayerViewController instance]setNowTime:startedTime_ countTime:([ffmpegDecoder_ duration])];
    [seekTimer_ setFireDate:[NSDate date]];
    
}
-(void)setNowTime:(float)nowTime countTime:(float)countTime{
    
    [[MusicPlayerViewController instance]setNowTime:nowTime countTime:countTime];
}

-(void)copystop{
    if ([self nowPlaying]) {
        [self pauseAudio];
        copydoneplay=YES;
    }
}
-(void)copyplay{
    if (copydoneplay) {
        [self playAudio];
        copydoneplay=NO;
    }

}
-(void)changeplaymodel
{
    static int n=1;
    n++;
    
    if (n%3==0)
    {
        states=123;
    }
    else if (n%3==1)
    {
        states=456;
    }
    else if(n%3==2)
    {
        states=789;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self removeAudioQueue];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)playAudio{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadlist" object:nil];
    [self startAudio_];

        _nowPlaying=YES;
}
- (void)pauseAudio {
    if (started_) {
        _state_ = AUDIO_STATE_PAUSE;
        
        AudioQueuePause(audioQueue_);
        AudioQueueReset(audioQueue_);
    }
  
    _nowPlaying=NO;
 
}


- (void)updateSeekSlider:(UISlider*)sender {
    if (started_) {
        _state_ = AUDIO_STATE_SEEKING;
        
        AudioQueueStop(audioQueue_, YES);

        
        [self startAudio_];
    }else
    {
    
    }
}

- (void)updatePlaybackTime:(NSTimer*)timer {
    AudioTimeStamp timeStamp;
    OSStatus status = AudioQueueGetCurrentTime(audioQueue_, NULL, &timeStamp, NULL);
    
    if (status == noErr) {
        SInt64 time = floor(durationTime_);
        currentTimeInterval = timeStamp.mSampleTime / audioStreamBasicDesc_.mSampleRate;
        SInt64 currentTime = floor(startedTime_ + currentTimeInterval);
        float curr=currentTime;
        float total=time;

        if (curr>=total) {
            curr=total;
        }
        [_songInfo setObject:[NSNumber numberWithFloat:total] forKey:MPMediaItemPropertyPlaybackDuration];
        [_songInfo setObject:[NSNumber numberWithFloat:curr] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_songInfo];
        
        //向播放界面传时间和进度值
        [[MusicPlayerViewController instance]setNowTime:curr countTime:total];
    }
    
}

- (void)startAudio_{
    
    if (started_)
    {
        AudioQueueStart(audioQueue_, NULL);
    }
    else
    {
        if (![self createAudioQueue])
        {
            return;
            abort();
        }else{
        
        }
        [self startQueue];
        
        seekTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self selector:@selector(updatePlaybackTime:) userInfo:nil repeats:YES];
    }
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i)
    {
        [self enqueueBuffer:audioQueueBuffer_[i]];
    }
    
    _state_ = AUDIO_STATE_PLAYING;

}

- (void)stopAudio_ {
    if (started_) {
        AudioQueueStop(audioQueue_, YES);
        startedTime_ = 0.0;
        
        [ffmpegDecoder_ seekTime:0.0];
        
        
        _state_ = AUDIO_STATE_STOP;
        finished_ = NO;
    }else{
    
    }
    _nowPlaying=NO;
    [seekTimer_ setFireDate:[NSDate distantFuture]];
}

- (BOOL)createAudioQueue {
    _state_ = AUDIO_STATE_READY;
    finished_ = NO;
    
    decodeLock_ = [[NSLock alloc] init];
    ffmpegDecoder_ = [[FFmpegDecoder alloc] init];
    NSInteger retLoaded = [ffmpegDecoder_ loadFile:_nowSongs];
    if (retLoaded) return NO;
    
    
    // 16bit PCM LE.
    audioStreamBasicDesc_.mFormatID = kAudioFormatLinearPCM;
    audioStreamBasicDesc_.mSampleRate = ffmpegDecoder_.audioCodecContext_->sample_rate;
    audioStreamBasicDesc_.mBitsPerChannel = 16;
    audioStreamBasicDesc_.mChannelsPerFrame = ffmpegDecoder_.audioCodecContext_->channels;
    audioStreamBasicDesc_.mFramesPerPacket = 1;
    audioStreamBasicDesc_.mBytesPerFrame = audioStreamBasicDesc_.mBitsPerChannel / 8
    * audioStreamBasicDesc_.mChannelsPerFrame;
    audioStreamBasicDesc_.mBytesPerPacket =
    audioStreamBasicDesc_.mBytesPerFrame * audioStreamBasicDesc_.mFramesPerPacket;
    audioStreamBasicDesc_.mReserved = 0;
    audioStreamBasicDesc_.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    
    durationTime_ = [ffmpegDecoder_ duration];  
    
    
    OSStatus status = AudioQueueNewOutput(&audioStreamBasicDesc_, audioQueueOutputCallback, (__bridge void*)self,
                                          NULL, NULL, 0, &audioQueue_);
    if (status != noErr) {
       
        return NO;
    }else {
    
    }
    
    status = AudioQueueAddPropertyListener(audioQueue_, kAudioQueueProperty_IsRunning,
                                           audioQueueIsRunningCallback, (__bridge void*)self);
    if (status != noErr) {
               return NO;
    }else{
    
    }
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i) {
        status = AudioQueueAllocateBufferWithPacketDescriptions(audioQueue_,
                                                                ffmpegDecoder_.audioCodecContext_->bit_rate * kAudioBufferSeconds / 8,
                                                                ffmpegDecoder_.audioCodecContext_->sample_rate * kAudioBufferSeconds /
                                                                ffmpegDecoder_.audioCodecContext_->frame_size + 1,
                                                                audioQueueBuffer_ + i);
        if (status != noErr) {
          
            return NO;
        }else{
        
        }
    }
    
    return YES;
}

- (void)removeAudioQueue {
    [self stopAudio_];
    started_ = NO;
    
    for (NSInteger i = 0; i < kNumAQBufs; ++i) {
        AudioQueueFreeBuffer(audioQueue_, audioQueueBuffer_[i]);
    }
    AudioQueueDispose(audioQueue_, YES);
}


- (void)audioQueueOutputCallback:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer {
    if (_state_ == AUDIO_STATE_PLAYING) {
        [self enqueueBuffer:inBuffer];
    }else{
    
    }
}

- (void)audioQueueIsRunningCallback {
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus status = AudioQueueGetProperty(audioQueue_, kAudioQueueProperty_IsRunning, &isRunning, &size);
    
    if (status == noErr && !isRunning && _state_ == AUDIO_STATE_PLAYING)
    {
        _state_ = AUDIO_STATE_STOP;
      
             [self performSelector:@selector(afterdo) withObject:nil afterDelay:0.0];
    }
}

-(void)afterdo{
    if (finished_)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (states==123) {
                [[MusicPlayerViewController instance] next:NO];
                
            }
            else if(states==456){
                [[MusicPlayerViewController instance] onerun];
            }
            else if (states==789)
            {
                [[MusicPlayerViewController instance] randomrun];
            }
            
            
        });
    }


}

- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer {
    OSStatus status = noErr;
    NSInteger decodedDataSize = 0;
    buffer->mAudioDataByteSize = 0;
    buffer->mPacketDescriptionCount = 0;
    
    [decodeLock_ lock];
    
    while (buffer->mPacketDescriptionCount < buffer->mPacketDescriptionCapacity) {
        decodedDataSize = [ffmpegDecoder_ decode];
        
        if (decodedDataSize && buffer->mAudioDataBytesCapacity - buffer->mAudioDataByteSize >= decodedDataSize) {
            memcpy(buffer->mAudioData + buffer->mAudioDataByteSize,
                   ffmpegDecoder_.audioBuffer_, decodedDataSize);
            
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mStartOffset = buffer->mAudioDataByteSize;
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mDataByteSize = decodedDataSize;
            buffer->mPacketDescriptions[buffer->mPacketDescriptionCount].mVariableFramesInPacket =
            audioStreamBasicDesc_.mFramesPerPacket;
            
            buffer->mAudioDataByteSize += decodedDataSize;
            buffer->mPacketDescriptionCount++;
            [ffmpegDecoder_ nextPacket];
        }
        else {
            break;
        }
    }
    
//    NSLog(@"111%d",buffer->mPacketDescriptionCapacity);
//    NSLog(@"222%d",buffer->mPacketDescriptionCount);
//    NSLog(@"333%d",buffer->mAudioDataBytesCapacity);
//    NSLog(@"444%d",buffer->mAudioDataByteSize);
    
    if (buffer->mPacketDescriptionCount > 0)
    {
        status = AudioQueueEnqueueBuffer(audioQueue_, buffer, 0, NULL);
        if (status != noErr)
        {
         
        }
    }
    else
    {
        NSLog(@"%d",buffer->mAudioDataByteSize);
       
            AudioQueueStop(audioQueue_, NO);
            finished_ = YES;
//            _canplay = YES;

    }
    
    [decodeLock_ unlock];
    
    return status;
}

- (OSStatus)startQueue {
    OSStatus status = noErr;
    
    if (!started_) {
        status = AudioQueueStart(audioQueue_, NULL);
        if (status == noErr) {
            started_ = YES;
        }
        else {
            
        }
    }else{
    
    }
    
    return status;
}
-(BOOL)isplaying
{
    return started_;
}
@end
