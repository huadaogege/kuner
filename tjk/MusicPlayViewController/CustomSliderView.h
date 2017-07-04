//
//  customSliderView.h
//  tjk
//
//  Created by zhaolu  on 14-5-6.
//  Copyright (c) 2014年 taig. All rights reserved.
//1312

#import <UIKit/UIKit.h>
@class CustomSliderView;
@protocol CustomSliderDelegate <NSObject>

- (void) slide:(CustomSliderView *)slider ValueChangeToValue:(float)value;
- (void)changTimerState:(BOOL)state AndValue:(float)value;
- (void) slide:(CustomSliderView *)slider VolumeChangeToValue:(float)volume;
- (void) endChange:(float)value;


@end


@interface CustomSliderView : UIView
{
    
    UIImageView * _emptyImg;
    
    UIImageView * _fullImg;
    
    UIImageView * _iconImg;
    
   // UIButton    * _iconBtn;
    
    BOOL _isAction;
    
    BOOL _isFirstRun;
    
//    BOOL _changeVolume;
}

@property(nonatomic,assign) BOOL changeVolume;

-(void)setValue:(float)value;
- (void)setVolume:(float)newVolume ;
@property(nonatomic, assign)id<CustomSliderDelegate>delegate;
@end
