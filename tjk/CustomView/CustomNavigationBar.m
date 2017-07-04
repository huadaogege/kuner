//
//  CustomNavigationBar.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14/12/12.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "CustomNavigationBar.h"
#import "UIImage+Bundle.h"


@implementation CustomNavigationBar

-(id)init{
    self = [super init];
    if(self){
        self.backgroundColor = BASE_COLOR;
        
        self.title = [[UILabel alloc] init];
        self.title.text = @"";
        self.title.textColor = [UIColor whiteColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.frame = CGRectMake(65 * WINDOW_SCALE, 0, [UIScreen mainScreen].bounds.size.width - 130 * WINDOW_SCALE, 44*WINDOW_SCALE);
        [self addSubview:self.title];
        
        self.leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(4*WINDOW_SCALE, 0, 60*WINDOW_SCALE, 44*WINDOW_SCALE)];
        self.leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [self.leftBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self.leftBtn addTarget:self action:@selector(touchLeftDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftBtn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self.leftBtn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:self.leftBtn];
        
        flagView = [[UIView alloc] init];
        flagView.frame = CGRectMake(self.leftBtn.frame.origin.x, self.leftBtn.frame.origin.y + 10, self.leftBtn.frame.size.width, self.leftBtn.frame.size.height - 20);
        flagView.backgroundColor = BASE_COLOR;
        flagView.alpha = 0.0;
        [self addSubview:flagView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_icon-back" bundle:@"TAIG_FILE_LIST"]];
        imgView.frame = CGRectMake(9*WINDOW_SCALE, 5*WINDOW_SCALE, 34*WINDOW_SCALE, 34*WINDOW_SCALE);
        [self.leftBtn addSubview:imgView];

        self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60*WINDOW_SCALE, 2*WINDOW_SCALE, 60*WINDOW_SCALE, 40*WINDOW_SCALE)];
        [self.rightBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self.rightBtn addTarget:self action:@selector(touchRightDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBtn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self.rightBtn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchCancel];
        [self.rightBtn setTitle:NSLocalizedString(@"select",@"") forState:UIControlStateNormal];
        self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.rightBtn];
        
        flagView2 = [[UIView alloc] init];
        flagView2.frame = CGRectMake(self.rightBtn.frame.origin.x, self.rightBtn.frame.origin.y + 10, self.rightBtn.frame.size.width, self.rightBtn.frame.size.height - 20);
        flagView2.backgroundColor = BASE_COLOR;
        flagView2.alpha = 0.0;
        [self addSubview:flagView2];
    }
    return self;
}

-(void)fitSystem {
    self.title.frame = CGRectMake(65 * WINDOW_SCALE, self.frame.size.height - 42*WINDOW_SCALE, [UIScreen mainScreen].bounds.size.width - 130 * WINDOW_SCALE, 44*WINDOW_SCALE);
    self.leftBtn.frame = CGRectMake(4*WINDOW_SCALE, self.frame.size.height - 42*WINDOW_SCALE, 60*WINDOW_SCALE, 44*WINDOW_SCALE);
    self.rightBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60*WINDOW_SCALE, self.frame.size.height - 40*WINDOW_SCALE, 60*WINDOW_SCALE, 40*WINDOW_SCALE);
    flagView.frame = CGRectMake(self.leftBtn.frame.origin.x, self.leftBtn.frame.origin.y + 10, self.leftBtn.frame.size.width, self.leftBtn.frame.size.height - 20);
    flagView2.frame = CGRectMake(self.rightBtn.frame.origin.x, self.rightBtn.frame.origin.y + 10, self.rightBtn.frame.size.width, self.rightBtn.frame.size.height - 20);
}

-(void)touchDown:(UIButton *)btn{
    
    if(self.rightBtn == btn){
        [UIView animateWithDuration:0.2 animations:^{
            flagView2.alpha = 0.8;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            flagView.alpha = 0.8;
        }];
    }
}

-(void)touchLeftDown:(UIButton *)btn{

    if(self.delegate && [self.delegate respondsToSelector:@selector(clickLeft:)]){
        
        [self.delegate clickLeft:btn];
    }
    [self reView:btn];
}

-(void)touchRightDown:(UIButton *)btn{

    if(self.delegate && [self.delegate respondsToSelector:@selector(clickRight:)]){
        
        [self.delegate clickRight:btn];
    }
    [self reView:btn];
}

-(void)touchUp:(UIButton *)btn{
    
    [self reView:btn];
}

-(void)reView:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        flagView2.alpha = 0.0;
        flagView.alpha = 0.0;
    }];
}

@end
