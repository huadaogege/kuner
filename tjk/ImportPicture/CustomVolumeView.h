//
//  CustomVolumeView.h
//  KyShellMovieSDK
//
//  Created by 呼啦呼啦圈 on 14-3-31.
//  Copyright (c) 2014年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kVolumeHeight 147

@protocol VolumeDelegate <NSObject>

-(void)volumeChange:(float)value;
-(void)routeChangeReason_OldDeviceUnavailable;

@end
@interface CustomVolumeView : UIView{
    
    UIImageView * _emptyImg;

    UIImageView * _fullImg;
    
    UIImageView * _iconImg;
    
    BOOL _isFirstRun;
    
    BOOL _isAction;
    UIButton *_volumeBtn;
    UIView *_volumeSlider;
    UIImageView *_btnImage;
    float _soundValue;
}

@property(nonatomic, assign) id<VolumeDelegate>delegate;

- (float)volume;

- (void)setVolume:(float)newVolume;
-(void)volumeChange:(float)value;
-(CGFloat)getVolumeViewHeight;

@end
