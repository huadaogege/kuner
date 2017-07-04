//
//  CellView.m
//  tjk
//
//  Created by huadao on 15-3-31.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "CellView.h"

@interface CellView ()
@property(nonatomic,retain) UIImageView * animateslider;
@end

@implementation CellView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor= [UIColor clearColor];
        
        iconimage=[[UIImageView alloc]init];
        
        title=[[UILabel alloc]init];
        title.textColor=[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        title.font=[UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
        title.textAlignment=NSTextAlignmentLeft;
        title.lineBreakMode = NSLineBreakByCharWrapping;
        
        slider=[[UIImageView alloc]init];
        [[slider layer]setCornerRadius:4.0*WINDOW_SCALE_SIX];
        slider.backgroundColor=[UIColor colorWithRed:85.0/255.0 green:86.0/255.0 blue:93.0/255.0 alpha:1.0];
        self.animateslider=[[UIImageView alloc]init];
        [[self.animateslider layer]setCornerRadius:4.0*WINDOW_SCALE_SIX];
        
        cycle1=[[UIImageView alloc]init];
        [[cycle1 layer]setCornerRadius:7.5*WINDOW_SCALE_SIX/2.0];
        _cycle2=[[UIImageView alloc]init];
        [[_cycle2 layer]setCornerRadius:7.5*WINDOW_SCALE_SIX/2.0];
        _cycle2.backgroundColor=[UIColor colorWithRed:85.0/255.0 green:86.0/255.0 blue:93.0/255.0 alpha:1.0];
        
        
        lab1=[[UILabel alloc]init];
        lab1.textColor=[UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:170.0/255.0 alpha:1.0];
        lab1.font=[UIFont systemFontOfSize:12.0*WINDOW_SCALE_SIX];
        lab2=[[UILabel alloc]init];
        lab2.textColor=[UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:170.0/255.0 alpha:1.0];
        lab2.font=[UIFont systemFontOfSize:12.0*WINDOW_SCALE_SIX];
        
        lab3=[[UILabel alloc]init];
        lab3.textColor=[UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:170.0/255.0 alpha:1.0];
        lab3.font=[UIFont systemFontOfSize:12.0*WINDOW_SCALE_SIX];
        [self addSubview:iconimage];
        [self addSubview:title];
        [self addSubview:slider];
        [self addSubview:self.animateslider];
        [self addSubview:cycle1];
        [self addSubview:_cycle2];
        [self addSubview:lab1];
        [self addSubview:lab2];
        [self addSubview:lab3];
    }
    return self;
}
-(void)layoutSubviews{

    iconimage.frame=CGRectMake(40.0*WINDOW_SCALE_SIX/2.0,
                               ((170.0-52.0)/2.0)*WINDOW_SCALE_SIX/2.0,
                               52.0*WINDOW_SCALE_SIX/2.0,
                               52.0*WINDOW_SCALE_SIX/2.0);
    CGFloat width = [FileSystem isChinaLan]? 110.0*WINDOW_SCALE_SIX/2.0:title.frame.size.width;
    title.frame=CGRectMake(142.0*WINDOW_SCALE_SIX/2.0,
                           32.0*WINDOW_SCALE_SIX/2.0,
                           width,
                           30.0*WINDOW_SCALE_SIX/2.0);
    slider.frame=CGRectMake(142.0*WINDOW_SCALE_SIX/2.0,
                            ((170.0-12.0)/2.0)*WINDOW_SCALE_SIX/2.0,
                            560.0*WINDOW_SCALE_SIX/2.0,
                            12.0*WINDOW_SCALE_SIX/2.0);
    cycle1.frame=CGRectMake(142.0*WINDOW_SCALE_SIX/2.0,
                            107.0*WINDOW_SCALE_SIX/2.0,
                            15.0*WINDOW_SCALE_SIX/2.0,
                            15.0*WINDOW_SCALE_SIX/2.0);
    _cycle2.frame=CGRectMake(354.0*WINDOW_SCALE_SIX/2.0,
                            107.0*WINDOW_SCALE_SIX/2.0,
                            15.0*WINDOW_SCALE_SIX/2.0,
                            15.0*WINDOW_SCALE_SIX/2.0);
    
    lab1.frame=CGRectMake(165.0*WINDOW_SCALE_SIX/2.0,
                          105.0*WINDOW_SCALE_SIX/2.0,
                          250.0*WINDOW_SCALE_SIX/2.0,
                          24.0*WINDOW_SCALE_SIX/2.0);
    lab2.frame=CGRectMake(375.0*WINDOW_SCALE_SIX/2.0,
                          105.0*WINDOW_SCALE_SIX/2.0,
                          250.0*WINDOW_SCALE_SIX/2.0,
                          24.0*WINDOW_SCALE_SIX/2.0);
    lab3.frame=CGRectMake(title.frame.origin.x+title.frame.size.width +5,
                          title.frame.origin.y+4.0*WINDOW_SCALE_SIX,
                          self.frame.size.width,
                          25.0*WINDOW_SCALE_SIX/2.0);
    

}
-(void)setName:(NSString *)name{
    title.text=name;
    [self fitsizeWith:title.text];
}

-(void)fitsizeWith:(NSString *)name
{
    
    if ([FileSystem isChinaLan]) {
        return;
    }
    
    UIFont *font = [UIFont systemFontOfSize:14.0*WINDOW_SCALE_SIX];
    CGSize size = [name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    title.frame=CGRectMake(title.frame.origin.x,
                           title.frame.origin.y,
                           size.width,
                           title.frame.size.height);
}

-(void)setImage:(UIColor *)color{

    self.animateslider.backgroundColor=color;
    cycle1.backgroundColor=color;
}
-(void)setimagicon:(UIImage *)image{

    iconimage.image=image;
}
-(void)setnum:(NSString *)num1 num:(NSString *)num2{
    lab1.text=num1;
    lab2.text=num2;

}
-(void)setsliderframe:(float)weight{

    self.animateslider.frame=CGRectMake(142.0*WINDOW_SCALE_SIX/2.0,
                                    ((170.0-12.0)/2.0)*WINDOW_SCALE_SIX/2.0,
                                   weight,
                                   12.0*WINDOW_SCALE_SIX/2.0);;
}
-(void)setlab3:(NSString *)name{
    
    lab3.text=name;
    
    [self fitsizeWith:title.text];

}

@end
