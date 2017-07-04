//
//  customSliderView.m
//  tjk
//
//  Created by zhaolu  on 14-5-6.
//  Copyright (c) 2014年 taig. All rights reserved.
//123

#import "CustomSliderView.h"
#import "UIImage+Bundle.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioSession.h>
@implementation CustomSliderView

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        _emptyImg = [[UIImageView alloc]init];
        _emptyImg.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        [self addSubview:_emptyImg];
        
        _fullImg = [[UIImageView alloc]init];
        _fullImg.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        [self addSubview:_fullImg];
        
        //拖动图
        _iconImg = [[UIImageView alloc]init];
        [self addSubview:_iconImg];
        
        _emptyImg.image=[UIImage imageNamed:@"musicplay_loading.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        _emptyImg.opaque = NO;
        _emptyImg.layer.borderWidth = 0.0;
        _emptyImg.layer.cornerRadius = 1.5;
        _emptyImg.layer.masksToBounds= YES;
        

        _fullImg.image=[UIImage imageNamed:@"musicplay_loadingbar.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        _fullImg.opaque = NO;
        _fullImg.layer.borderWidth = 0.0;
        _fullImg.layer.cornerRadius = 1.5;
        _fullImg.layer.masksToBounds= YES;
        _iconImg.image = [UIImage imageNamed:@"musicplay_control.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        _isFirstRun = YES;
        
        
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVolume) name:@"changevolume" object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelvolume) name:@"cancelvolume" object:nil];
    }
    return self;
}


- (BOOL)addHardKeyVolumeListener {
    
    OSStatus s = AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                 MusicVolumeChangeListenerCallback,
                                                 (__bridge void *)(self));
    return s == kAudioSessionNoError;
}

void MusicVolumeChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    
    
    if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume)
        return;
    
    CustomSliderView * volume = (__bridge CustomSliderView *)(inUserData);
    
    Float32 value = *(Float32 *)inPropertyValue;
    
    [volume setValue:value];
}

-(void)setChangeVolume:(BOOL)changeVolume{
    _changeVolume = changeVolume;
    if (_changeVolume) {
        [self addHardKeyVolumeListener];
    }
}

//-(void)changeVolume{
//    _changeVolume = YES;
//}
//-(void)cancelvolume{
//    _changeVolume = NO;
//}
-(void)layoutSubviews{
    
    if(_isFirstRun)
        _isFirstRun = NO;
    else
        return;
    
    _emptyImg.frame = CGRectMake(0,
                                 (self.bounds.size.height - 3)/2,
                                 self.bounds.size.width,
                                 3);
    
    _iconImg.frame = CGRectMake(0,
                                (self.bounds.size.height - 10)/2,
                                10,
                                10);
    
    _fullImg.frame = _emptyImg.frame;
    
}

-(void)setValue:(float)value{
    
    if(_isAction){
        
        return;
    }
    float x = _emptyImg.bounds.size.width * value;
    if (x >0 ||x <0) {
        _iconImg.frame = CGRectMake(_emptyImg.frame.origin.x + x - _iconImg.bounds.size.width/2,
                                    _iconImg.frame.origin.y,
                                    _iconImg.frame.size.width,
                                    _iconImg.frame.size.height);
    }
    else
    {
        _iconImg.frame = CGRectMake(_emptyImg.frame.origin.x - _iconImg.bounds.size.width/2,
                                    _iconImg.frame.origin.y,
                                    _iconImg.frame.size.width,
                                    _iconImg.frame.size.height);
    }

    
    _fullImg.frame = CGRectMake(_fullImg.frame.origin.x,
                                _emptyImg.frame.origin.y,
                                _iconImg.frame.origin.x - _emptyImg.frame.origin.x + _iconImg.frame.size.width/2,
                                _emptyImg.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [event.allTouches anyObject];
    
	CGPoint touchBeganPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(_iconImg.frame.origin.x - 20,
                                      _iconImg.frame.origin.y - 20,
                                      _iconImg.frame.size.width + 40
                                      , _iconImg.frame.size.height + 40), touchBeganPoint)){
        
        _isAction = YES;
    }else{
        _isAction = NO;
    }
    //定时器暂停
    if(self.delegate && [self.delegate respondsToSelector:@selector(changTimerState: AndValue:)])
    {
        [self.delegate changTimerState:YES AndValue:_iconImg.frame.origin.x/self.bounds.size.width];
    
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(_isAction){
        UITouch *touch = [event.allTouches anyObject];
        
        CGPoint touchPoint = [touch locationInView:self];
        float x;
        
        if(touchPoint.x < _emptyImg.frame.origin.x)
            x = _emptyImg.frame.origin.x;
        else if(touchPoint.x> _emptyImg.frame.origin.x + _emptyImg.frame.size.width)
            x = _emptyImg.frame.origin.x + _emptyImg.frame.size.width;
        else
            x = touchPoint.x - _iconImg.frame.size.width/2;
        
        _iconImg.frame = CGRectMake(x - _iconImg.frame.size.width/2,
                                    _iconImg.frame.origin.y,
                                    _iconImg.frame.size.width,
                                    _iconImg.frame.size.height);
        
       
        
        _fullImg.frame = CGRectMake(0,
                                    _emptyImg.frame.origin.y,
                                    _iconImg.frame.origin.x - _emptyImg.frame.origin.x + _iconImg.frame.size.width/2,
                                    _emptyImg.frame.size.height);
        
        
        
        if (_changeVolume) {
            //改变播放音量
            
            [self setVolume:(_iconImg.center.x)/_emptyImg.frame.size.width];
//            if (self.delegate && [self.delegate respondsToSelector:@selector(slide:VolumeChangeToValue:)]) {
//                
//                [self.delegate slide:self VolumeChangeToValue:(_iconImg.center.x)/_emptyImg.frame.size.width];
//                
//            }

        }else{
            //改变播放时间
            if (self.delegate && [self.delegate respondsToSelector:@selector(slide:ValueChangeToValue:)]) {
                
                [self.delegate slide:self ValueChangeToValue:(_iconImg.center.x)/_emptyImg.frame.size.width];
                
            }

        }
        
       
    }
}
//设置音量
- (void)setVolume:(float)newVolume {
    
    //    if(newVolume < 0.1)
    //        newVolume = 0;
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolume];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // //改变播放时间
    if (delegate && [delegate respondsToSelector:@selector(endChange:)]) {
        
        [delegate endChange:(_iconImg.frame.origin.x+_iconImg.frame.size.width/2.0)/self.bounds.size.width];
    }
    
    _isAction = NO;

    //开启定时器
    if(self.delegate && [self.delegate respondsToSelector:@selector(changTimerState:AndValue:)])
    {
        [self.delegate changTimerState:NO AndValue:_iconImg.frame.origin.x/self.bounds.size.width];
        
    }

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (delegate && [delegate respondsToSelector:@selector(endChange:)]) {
        
        [delegate endChange:_iconImg.frame.origin.x/self.bounds.size.width];
    }
    
    _isAction = NO;
}


-(void)dealloc{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   MusicVolumeChangeListenerCallback,
                                                   (__bridge void *)(self));
}

@end
