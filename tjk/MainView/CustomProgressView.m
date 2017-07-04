//
//  CustomProgressView.m
//  KUKE
//
//  Created by 呼啦呼啦圈 on 15/3/31.
//  Copyright (c) 2015年 呼啦呼啦圈. All rights reserved.
//

#import "CustomProgressView.h"

#define VIEW_TAG 111

@implementation CustomProgressView

-(instancetype)init{
    self = [super init];
    if(self){
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backView];
        _color = [UIColor colorWithRed:29.0/255.0 green:221.0/255.0 blue:165.0/255.0 alpha:1.0];
        _limitColor = [UIColor redColor];
        
        _number = 0;
        _progress = 0;
        _limit = 0.3;
    }
    return self;
}

-(void)setProColor:(UIColor *)color{
    _color = color;
}

-(void)setLimitColor:(UIColor *)color{
    _limitColor = color;
}

-(void)setLimitValue:(float)limit{
    _limit = limit;
}
-(float)getLimitValue
{
    return _limit * VIEW_COUNT;
}

-(void)setProgress:(float)progress anim:(BOOL)anim{

    if(progress > 1) progress = 1;
    else if(progress < 0) progress = 0;
    int count = progress * VIEW_COUNT;
    if(_number == _progress){
        
        if(count != _progress){
            _progress = progress * VIEW_COUNT;
            if(anim){
                
                [self xxxxxxx];
            }else{
                for (int i = 0; i < VIEW_COUNT; i++) {
                    
                    if(i<_progress)
                        [self setColor:i];
                    else
                        [self clearColor:i];
                }
                _number = _progress;
            }
        }
    }else{
        
        _progress = count;
    }
}

-(void)resetProgress{
    _number = _progress;
}

-(BOOL)isAnimating{
//    NSLog(@"_number : %d , _progress : %d",_number,_progress);
    return _number != _progress;
}

-(void)add{
    //(0.15 * (float)_number / (float)_progress + 0.05)
    [UIView animateWithDuration:((float)_number / (float)_progress) * ((float)_number / (float)_progress) * 0.2 animations:^{
        [self setColor:_number++];
    } completion:^(BOOL finished) {
        [self xxxxxxx];
    }];
}

-(void)reduce{
    
    [UIView animateWithDuration:((float)_progress / (float)_number) * ((float)_progress / (float)_number) * 0.2 animations:^{
        [self clearColor:_number--];
    } completion:^(BOOL finished) {
        [self xxxxxxx];
    }];
}

-(void)xxxxxxx{

    for (int i = 0; i<_number; i++) {
        [self setColor:i];
    }
    if(_number > _progress){
        [self reduce];
    }else if(_number < _progress){
        [self add];
    }
}

-(void)setColor:(int)index{
    
    int limitValue = [self getLimitValue];
    [_backView viewWithTag:(index + VIEW_TAG)].backgroundColor = _progress < limitValue ? _limitColor : _color;
}

-(void)clearColor:(int)index{
    
    [_backView viewWithTag:(index + VIEW_TAG)].backgroundColor = [UIColor colorWithRed:29.0/255.0 green:31.0/255.0 blue:38.0/255.0 alpha:1.0];
}

-(void)doAnim{

    if(_number < _progress){

        [UIView animateWithDuration:0.05 + (0.2*(1 - (float)_number/(float)_progress)) animations:^{
            [self setColor:_number++];
        } completion:^(BOOL finished) {
            [self performSelectorInBackground:@selector(doAnim) withObject:nil];
        }];
    }
}

-(void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    _backView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)initView:(float)radiusWidth point:(CGSize)size cornerRadius:(float)cornerRadius{

    _backView.transform = CGAffineTransformMakeRotation(-M_PI * 25.0/36.0);
    float raWidth = radiusWidth - size.height * 0.5;
    for (float i = 0; i < 51; i++) {
        
        float x = M_PI * i * 1.0/36.0;
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(raWidth + sin(x) * raWidth + fabs((sin(x) * size.width)),
                                (1 - cos(x)) * raWidth,
                                size.width,
                                size.height);
        view.transform = CGAffineTransformMakeRotation(x);
        view.tag = i + VIEW_TAG;
        view.backgroundColor = [UIColor colorWithRed:29.0/255.0 green:31.0/255.0 blue:38.0/255.0 alpha:1.0];//[UIColor colorWithRed:44.0/255.0 green:46.0/255.0 blue:52.0/255.0 alpha:1.0];
        view.layer.cornerRadius = cornerRadius;
        view.layer.edgeAntialiasingMask = kCALayerLeftEdge|kCALayerRightEdge|kCALayerBottomEdge|kCALayerTopEdge;
        [_backView addSubview:view];
    }
}

@end
