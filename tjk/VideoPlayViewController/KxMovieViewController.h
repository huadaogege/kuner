//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>
#import "CustomUISlider.h"
#import "CustomVolumeView.h"

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@protocol KxBackDelegate <NSObject>

- (void) clickBackBtn;

- (void) playEnd;

- (void) playError:(NSError *)error;

- (BOOL) playForward;
- (BOOL) playRewind;

@end

@interface KxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CustomUISliderDelegate, VolumeDelegate>{
    
    BOOL isAction;
    
    int  _hiddenTime;
}

@property (readonly) BOOL playing;
@property float currentTime;
@property float totalTime;
@property id<KxBackDelegate> kxBackDelegate;

-(void)setPath:(NSString *)path parameters:(NSDictionary *)parameters;

- (void) play;
- (void) pause;
- (void) setMoviePositionFromDecoder;

-(CGFloat)getAllTime;
-(CGFloat)getTime;

-(void)closFFmpeg;
-(void)self_dealloc;
- (void) setMoviePosition: (CGFloat) position;
-(void)endChange:(float)value;

-(void)removeViewAtBottom;

@end
