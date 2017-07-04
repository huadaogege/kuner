//
//  CustomProgressView.h
//  KUKE
//
//  Created by 呼啦呼啦圈 on 15/3/31.
//  Copyright (c) 2015年 呼啦呼啦圈. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VIEW_COUNT 51.0 //共72个 只显示51个

@interface CustomProgressView : UIView{
    
    UIView  *_backView;
    int     _progress;
    int     _number;
    UIColor *_color;
    UIColor *_limitColor;
    float   _limit;
}
//设置最小限度的值, 影响在什么情况下变色
-(void)setLimitValue:(float)limit;
-(float)getLimitValue;
//设置进度百分比
-(void)setProgress:(float)progress anim:(BOOL)anim;
-(void)resetProgress;
/*
 初始化
 radiusWidth:圆的半径
 size:小点的大小
 cornerRadius:小点的弧度
 */
-(void)initView:(float)radiusWidth point:(CGSize)size cornerRadius:(float)cornerRadius;
-(BOOL)isAnimating;
@end
