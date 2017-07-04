//
//  CustomUISlider.h
//  guangGaoDemo
//
//  Created by 呼啦呼啦圈 on 13-3-5.
//  Copyright (c) 2013年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TGK_CustomUISliderDelegate <NSObject>

- (void) valueChange:(float)value;
- (void) endChange:(float)value;
@end

@interface TGK_CustomUISlider : UIView{
    
    UIImageView * _emptyImg;

    UIImageView * _fullImg;
    
    UIImageView * _iconImg;
    
    BOOL _isAction;
    
    BOOL _isFirstRun;
}

-(void)setValue:(float)value;

@property(nonatomic, retain)id<TGK_CustomUISliderDelegate>delegate;

@end
