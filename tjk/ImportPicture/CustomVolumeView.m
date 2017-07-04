//
//  CustomVolumeView.m
//  KyShellMovieSDK
//
//  Created by 呼啦呼啦圈 on 14-3-31.
//  Copyright (c) 2014年 呼啦呼啦圈. All rights reserved.
//

#import "CustomVolumeView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioSession.h>


@implementation CustomVolumeView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        UIImageView *imagev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a_voice_bg" bundle:@"TAIG_Photo_Mov"]];
        imagev.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:imagev];
        
        _volumeSlider = [[UIView alloc] init];
        _volumeSlider.backgroundColor = [UIColor clearColor];
        _volumeSlider.frame = CGRectMake((frame.size.width - 33) / 2, 17 - 8, 33, kVolumeHeight + 16);
        _volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _volumeSlider.delegate = self;
        
        _volumeBtn = [[UIButton alloc] init];
        _volumeBtn.tag = 0;
        //        _volumeBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _volumeBtn.frame = CGRectMake(0,
                                      frame.size.height - 30,
                                      frame.size.width,
                                      30);
        _volumeBtn.backgroundColor = [UIColor clearColor];
        [_volumeBtn addTarget:self action:@selector(soundZero) forControlEvents:UIControlEventTouchUpInside];
        
        _btnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TAIG_Photo_Mov.bundle/volume.png"]];
        _btnImage.userInteractionEnabled = NO;
        _btnImage.frame = CGRectMake((_volumeBtn.bounds.size.width - 22) / 2,
                                     0,
                                     22,
                                     19);
        [_volumeBtn addSubview:_btnImage];
        
        [self addSubview:_volumeSlider];
        [self addSubview:_volumeBtn];
        
        _emptyImg = [[UIImageView alloc]init];
        _emptyImg.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        [_volumeSlider addSubview:_emptyImg];
        
        _fullImg = [[UIImageView alloc]init];
        _fullImg.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        [_volumeSlider addSubview:_fullImg];
        
        //拖动图
        _iconImg = [[UIImageView alloc]init];
        [_volumeSlider addSubview:_iconImg];
        
        _emptyImg.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
        _emptyImg.opaque = NO;
        _emptyImg.layer.borderWidth = 0.0;
        _emptyImg.layer.cornerRadius = 1.5;
        _emptyImg.layer.masksToBounds= YES;
        
        _fullImg.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:140.0/255.0 blue:206.0/255.0 alpha:1.0];
        _fullImg.opaque = NO;
        _fullImg.layer.borderWidth = 0.0;
        _fullImg.layer.cornerRadius = 1.5;
        _fullImg.layer.masksToBounds= YES;
        
        _iconImg.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_slider"];
        
        [self addHardKeyVolumeListener];
        //        [self addMutedListener];
        _isFirstRun = YES;
    }
    
    return self;
}


-(void)soundZero{
    
    if(_volumeBtn.tag == 0 || _soundValue == 0){
        
        _volumeBtn.tag = 1;
        _soundValue = [self volume];
        [self setVolume:0];
        _btnImage.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/volume_none.png"];
    }else{
        
        _volumeBtn.tag = 0;
        [self setVolume:_soundValue];
        _btnImage.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/volume.png"];
    }
}


-(void)dealloc{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   audioVolumeChangeListenerCallback,
                                                   (__bridge void *)(self));
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,
                                                   audioRouteChangeListenerCallback,
                                                   (__bridge void *)(self));
}

-(void)layoutSubviews{

    if(_isFirstRun)
        _isFirstRun = NO;
    else
        return;
    
    _emptyImg.frame = CGRectMake((_volumeSlider.bounds.size.width - 3.0)/2.0,
                                8,
                                3,
                                _volumeSlider.bounds.size.height - 16);
    
    [self volumeChange:[self volume]];
//    _iconImg.frame = CGRectMake((self.bounds.size.width - 16.0)/2.0,
//                               _emptyImg.frame.origin.y + _emptyImg.frame.size.height - 8,
//                               16,
//                               16);
//    
//    _fullImg.frame = CGRectMake((self.bounds.size.width - 3.0)/2.0,
//                                _emptyImg.frame.origin.y + _emptyImg.frame.size.height,
//                                3,
//                                0);
    
}

-(CGFloat)getVolumeViewHeight
{
    return _fullImg.frame.size.height;
}

-(void)setVolumeBtnImageBy:(float)newVolume{
    if (newVolume <= 0) {
        _volumeBtn.tag = 1;
        _btnImage.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/volume_none.png"];
    }
    else{
        _volumeBtn.tag = 0;
        _btnImage.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/volume.png"];
    }
}

- (float)volume {
    
    return [[MPMusicPlayerController applicationMusicPlayer] volume];
}

- (void)setVolume:(float)newVolume {
    
//    if(newVolume < 0.1)
//        newVolume = 0;
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolume];
    
    [self setVolumeBtnImageBy:newVolume];
}

-(void)volumeChange:(float) value{

//    if(_isAction){
//        return;
//    }
    _iconImg.frame = CGRectMake((_volumeSlider.bounds.size.width - 22.0)/2.0,
                                (1.0 - value) * (_volumeSlider.bounds.size.height - 22),
                                22,
                                22);
    
    _fullImg.frame = CGRectMake((_volumeSlider.bounds.size.width - 3.0)/2.0,
                                _iconImg.frame.origin.y + 8,
                                3,
                                _volumeSlider.bounds.size.height - 8 - _iconImg.frame.origin.y - 8);
    [self setVolumeBtnImageBy:value];
}

- (BOOL)addHardKeyVolumeListener {
    
    OSStatus s = AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                 audioVolumeChangeListenerCallback,
                                                 (__bridge void *)(self));
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                    audioRouteChangeListenerCallback,
                                    (__bridge void *)(self));
    return s == kAudioSessionNoError;
}

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize,const void *inPropertyValue ) {
    if (inPropertyID == kAudioSessionProperty_AudioRouteChange)
    {
        // Determines the reason for the route change, to ensure that it is not
        //      because of a category change.
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
        SInt32 routeChangeReason;
        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
            //Handle Headset Unplugged
            NSLog(@"没有耳机！");
            CustomVolumeView * volume = (__bridge CustomVolumeView *)(inUserData);
            if (volume.delegate && [volume.delegate respondsToSelector:@selector(routeChangeReason_OldDeviceUnavailable)]) {
                [volume.delegate routeChangeReason_OldDeviceUnavailable];
            }
            
        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            //Handle Headset plugged in
            NSLog(@"有耳机！");
        }
        
    }
}

void audioVolumeChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    
    
    if (inPropertyID == kAudioSessionProperty_CurrentHardwareOutputVolume)
    {
        CustomVolumeView * volume = (__bridge CustomVolumeView *)(inUserData);
        
        Float32 value = *(Float32 *)inPropertyValue;
        
        [volume volumeChange:value];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [event.allTouches anyObject];
    
	CGPoint touchBeganPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(_iconImg.frame.origin.x - 15,
                                      _iconImg.frame.origin.y - 15,
                                      _iconImg.frame.size.width + 30,
                                      _iconImg.frame.size.height + 15),
                           touchBeganPoint)){
        
        _isAction = YES;
    }else{
        _isAction = NO;
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if(_isAction){
        UITouch *touch = [event.allTouches anyObject];
        
        CGPoint touchPoint = [touch locationInView:self];
        float y;

        y = _emptyImg.bounds.size.height - touchPoint.y;
        if(y < 0){
            
            y = 0;
        }else if (y > _emptyImg.bounds.size.height){
            
            y = _emptyImg.bounds.size.height;
        }
        
        [self volumeChange:y/_emptyImg.bounds.size.height];
        [self setVolume:y/_emptyImg.bounds.size.height];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(volumeChange:)]){
            
            [self.delegate volumeChange:y/_emptyImg.bounds.size.height];
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(_isAction){
        _isAction = NO;
//        [self setVolume:_iconImg.frame.origin.y/_emptyImg.bounds.size.height];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    if(_isAction){
        _isAction = NO;
//        [self setVolume:_iconImg.frame.origin.y/_emptyImg.bounds.size.height];
    }
}

//- (BOOL)isMuted
//{
//    CFStringRef route;
//    UInt32 routeSize = sizeof(CFStringRef);
//    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute,&routeSize, &route);
//    if (status == kAudioSessionNoError)
//    {
//        if (route == NULL || !CFStringGetLength(route))
//            return TRUE;
//    }
//    return FALSE;
//}
//
//- (BOOL)addMutedListener
//{
//    OSStatus s = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
//                                                 audioRouteChangeListenerCallback,
//                                                 (__bridge void *)(self));
//    return s == kAudioSessionNoError;
//}
//
//void audioRouteChangeListenerCallback (void *inUserData,
//                                       AudioSessionPropertyID inPropertyID,
//                                       UInt32 inPropertyValueSize,
//                                       const void *inPropertyValue
//                                       )
//{
//    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
//    
//    CustomVolumeView * volume = (__bridge CustomVolumeView *)(inUserData);
//    BOOL muted = [volume isMuted];
//    // add code here
//    if(muted){
//        NSLog(@"1");
//    }else{
//        NSLog(@"2");
//    }
//}

@end
