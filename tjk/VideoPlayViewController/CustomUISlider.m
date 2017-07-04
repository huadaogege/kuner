//
//  CustomUISlider.m
//  guangGaoDemo
//
//  Created by 呼啦呼啦圈 on 13-3-5.
//  Copyright (c) 2013年 呼啦呼啦圈. All rights reserved.
//

#import "CustomUISlider.h"

@implementation CustomUISlider
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

//        _emptyImg.image = [[UIImage imageNamed:@"TAIG_PLAYER.bundle/slider_empty.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];;
        _emptyImg.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0];
        _emptyImg.opaque = NO;
        _emptyImg.layer.borderWidth = 0.0;
        _emptyImg.layer.cornerRadius = 1.5;
        _emptyImg.layer.masksToBounds= YES;
        
//        _fullImg.image = [[UIImage imageNamed:@"TAIG_PLAYER.bundle/slider_full.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        _fullImg.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:140.0/255.0 blue:206.0/255.0 alpha:1.0];
        _fullImg.opaque = NO;
        _fullImg.layer.borderWidth = 0.0;
        _fullImg.layer.cornerRadius = 1.5;
        _fullImg.layer.masksToBounds= YES;
        
        _iconImg.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_slider"];

        _isFirstRun = YES;
    }
    return self;
}

-(CGFloat)getProgressViewVar
{
    return _fullImg.frame.size.width;
}

-(void)layoutSubviews{

    if(_isFirstRun)
        _isFirstRun = NO;
    else
        return;
    
    _emptyImg.frame = CGRectMake(0,
                             (self.bounds.size.height - 3)/2,
                             self.bounds.size.width,
                             3);

    _iconImg.frame = CGRectMake(22/2.0,
                               (self.bounds.size.height - 22)/2,
                               22,
                               22);

    _fullImg.frame = _emptyImg.frame;
 
}

-(void)setValue:(float)value{

    if(_isAction){
       
        return;
    }
    if (value > 1.0f || value < 0.0f) {
        value = 0.0f;
    }
    float x = self.bounds.size.width * value;
    if (x == NAN) {
        return;
    }
    if (isnan(x)) {
        return;
    }
    x = x - _iconImg.frame.size.width / 2.0;
    _iconImg.frame = CGRectMake(x, (self.bounds.size.height - 22)/2, 22, 22);
    
    _fullImg.frame = CGRectMake(0,
                                (self.bounds.size.height - 3)/2,
                                x + _iconImg.frame.size.width/2,
                                _emptyImg.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [event.allTouches anyObject];
    
	CGPoint touchBeganPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(_iconImg.frame.origin.x - 15,
                                      _iconImg.frame.origin.y - 15,
                                      _iconImg.frame.size.width + 55
                                      , _iconImg.frame.size.height + 55), touchBeganPoint)){

        _isAction = YES;
    }else{
        _isAction = NO;
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(_isAction){
        UITouch *touch = [event.allTouches anyObject];
        
        CGPoint touchPoint = [touch locationInView:self];
        float x;
        
        if(touchPoint.x - _iconImg.frame.size.width/2 < 0)
            x = 0;
        else if(touchPoint.x + _iconImg.frame.size.width/2 > self.bounds.size.width)
            x = self.bounds.size.width - _iconImg.frame.size.width;
        else
            x = touchPoint.x - _iconImg.frame.size.width/2;
        
        _iconImg.frame = CGRectMake(x-_iconImg.frame.size.width/2.0,
                                    _iconImg.frame.origin.y,
                                    _iconImg.frame.size.width,
                                    _iconImg.frame.size.height);
        
        _fullImg.frame = CGRectMake(0,
                                    (self.bounds.size.height - 3)/2,
                                    x,
                                    _emptyImg.frame.size.height);
        
        if (delegate && [delegate respondsToSelector:@selector(valueChange:)]) {

            [delegate valueChange:x/self.bounds.size.width];
 
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    if (delegate && [delegate respondsToSelector:@selector(endChange:)]) {

        [delegate endChange:_iconImg.frame.origin.x/self.bounds.size.width];
    }
    
    _isAction = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    if (delegate && [delegate respondsToSelector:@selector(endChange:)]) {

        [delegate endChange:_iconImg.frame.origin.x/self.bounds.size.width];
    }
    
    _isAction = NO;
}

-(void)dealloc {
    _iconImg = nil;
    
    _fullImg = nil;
}

@end
