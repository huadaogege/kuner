//
//  CustomUISlider.h
//  guangGaoDemo
//
//  Created by 呼啦呼啦圈 on 13-3-5.
//  Copyright (c) 2013年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>



CGFloat const gestureMinimumTranslation = 2.0;

@protocol CustomUISliderDelegate <NSObject>

- (void) valueChange:(float)value;
- (void) endChange:(float)value;
@end

@interface CustomUISlider : UIView{
    
    UIImageView * _emptyImg;

    UIImageView * _fullImg;
    
    UIImageView * _iconImg;
    
    BOOL _isAction;
    
    BOOL _isFirstRun;
}

-(void)setValue:(float)value;

@property(nonatomic, assign)id<CustomUISliderDelegate>delegate;

-(CGFloat)getProgressViewVar;

@end
