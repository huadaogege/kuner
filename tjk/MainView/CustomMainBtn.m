//
//  CustomMainBtn.m
//  tjk
//
//  Created by Ching on 15-3-25.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "CustomMainBtn.h"
#import "UIImage+Bundle.h"


@implementation CustomMainBtn

- (id)init{
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _iconView  = [[UIImageView alloc] init];
        _rightView = [[UIImageView alloc] init];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12 * WINDOW_SCALE];
        _nameLabel.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
        
        [self addSubview:_iconView];
        [self addSubview:_rightView];
        [self addSubview:_nameLabel];
        [self addSubview:_lineView];
    }
    return self;
}
-(void)myViewHigh:(float)nowHight{
    _iconView.frame = CGRectMake(15*WINDOW_SCALE_SIX, (nowHight-36*WINDOW_SCALE_SIX)/2.0, 36*WINDOW_SCALE_SIX, 36*WINDOW_SCALE_SIX);
    _rightView.frame = CGRectMake( SCREEN_WIDTH-35*WINDOW_SCALE_SIX,(nowHight - 16*WINDOW_SCALE)/2.0, 16*WINDOW_SCALE_SIX, 16*WINDOW_SCALE);
    _nameLabel.frame = CGRectMake(67*WINDOW_SCALE_SIX, (nowHight-25*WINDOW_SCALE_SIX)/2.0, 30*WINDOW_SCALE, 25*WINDOW_SCALE);
    _lineView.frame = CGRectMake(67*WINDOW_SCALE_SIX, nowHight-1*WINDOW_SCALE_SIX, SCREEN_WIDTH-67*WINDOW_SCALE_SIX, 1*WINDOW_SCALE_SIX);
    [_rightView setImage:[UIImage imageNamed:@"main_arrow.png" bundle:@"TAIG_MainImg.bundle"]];
}


-(void)setName:(NSString *)name{
    
    _nameLabel.text = name;
}

-(void)setImage:(UIImage *)img{
    
    _iconView.image = img;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
