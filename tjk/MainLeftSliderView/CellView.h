//
//  CellView.h
//  tjk
//
//  Created by huadao on 15-3-31.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellView : UIView
{
    UIImageView * iconimage;
    UILabel * title;
    UIImageView * slider;
    UIImageView * cycle1;
    

    UILabel * lab1,*lab2;
    UILabel * lab3;

}
@property UIImageView *cycle2;
-(void)setName:(NSString *)name;

-(void)setImage:(UIColor *)color;

-(void)setimagicon:(UIImage *)image;

-(void)setnum:(NSString *)num1 num:(NSString *)num2;

-(void)setsliderframe:(float)weight;

-(void)setlab3:(NSString *)name;
@end
