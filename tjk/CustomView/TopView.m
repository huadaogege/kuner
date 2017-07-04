//
//  TopView.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-4-9.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "TopView.h"
#import "config.h"

#define SELECT_COLOR [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:57.0/255.0 alpha:1.0]
#define UNSELECT_COLOR [UIColor colorWithRed:150/255.0 green:152/255.0 blue:155/255.0 alpha:1.0]

@implementation TopView
@synthesize leftBtn = _leftBtn;
@synthesize rightBtn = _rightBtn;
@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1];;
        
//        _topView = [[UIView alloc]init];;
//        _topView.opaque = NO;
//        _topView.backgroundColor = [UIColor whiteColor];
//        _topView.layer.borderColor = [UIColor whiteColor].CGColor;
//        _topView.layer.borderWidth = 1.0;
//        _topView.layer.cornerRadius = 6.0;
//        _topView.layer.masksToBounds= YES;
        
        _leftBtn = [[UIButton alloc]init];;
        
        _rightBtn = [[UIButton alloc]init];
        
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.text = NSLocalizedString(@"phone",@"");
        _leftLabel.textColor = SELECT_COLOR;//BASE_COLOR;
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        
        _rightLabel = [[UILabel alloc]init];
        _rightLabel.text = NSLocalizedString(@"kuner",@"");
        _rightLabel.textColor = UNSELECT_COLOR;//BASE_COLOR;
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        
//        [self addSubview:_topView];
        [self addSubview:_leftBtn];
        [self addSubview:_rightBtn];
        [self addSubview:_leftLabel];
        [self addSubview:_rightLabel];
        _bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(20,
                                                              self.bounds.size.height - 1,
                                                              self.bounds.size.width * 0.5,
                                                              1)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:56.0/255.0 blue:57.0/255.0 alpha:1.0];//BASE_COLOR;
        
        _bottomWidthLine = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                     self.bounds.size.height - 1,
                                                                                     self.bounds.size.width,
                                                                                     1)];
        _bottomWidthLine.backgroundColor = [UIColor colorWithRed:228/255.0 green:227/255.0 blue:230/255.0 alpha:1.0];//BASE_COLOR;
//        _bottomWidthLine.alpha = 0.2f;
        [self addSubview:_bottomWidthLine];
        [self addSubview:_bottomLine];
        
        _centerLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0.5f,
                                                                               (self.frame.size.height - 16*WINDOW_SCALE_SIX)/2.0,
                                                                               1,
                                                                               16*WINDOW_SCALE_SIX)];
        _centerLine.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:190/255.0 blue:193/255.0 alpha:1];//BASE_COLOR;
//        _centerLine.alpha = 0.2f;
        [self addSubview:_centerLine];
    }
    return self;
}

-(void)layoutSubviews{
//    
//    _topView.frame = CGRectMake((self.bounds.size.width - 290 * WINDOW_SCALE) * 0.5,
//                                0,
//                                290 * WINDOW_SCALE,
//                                29 * WINDOW_SCALE);
    
    _leftBtn.frame = CGRectMake(0,
                                0,
                                self.bounds.size.width * 0.5,
                                self.bounds.size.height - 5 * WINDOW_SCALE);
    
    _rightBtn.frame = CGRectMake(self.bounds.size.width * 0.5,
                                 0,
                                 self.bounds.size.width * 0.5,
                                 self.bounds.size.height - 5 * WINDOW_SCALE);
    
    _leftLabel.frame = CGRectMake(0,
                                  0,
                                  self.bounds.size.width * 0.5,
                                  self.bounds.size.height);
    
    _rightLabel.frame = CGRectMake(self.bounds.size.width * 0.5,
                                   0,
                                   self.bounds.size.width * 0.5,
                                   self.bounds.size.height);
    _bottomLine.frame = CGRectMake(_bottomLine.frame.origin.x,
                             self.bounds.size.height - 1,
                             self.bounds.size.width * 0.5,
                             1);
    _centerLine.frame = CGRectMake(self.bounds.size.width * 0.5f,
                                   (self.frame.size.height - 16*WINDOW_SCALE_SIX)/2.0,
                                   1,
                                   16*WINDOW_SCALE_SIX);
    _bottomWidthLine.frame = CGRectMake(0,
                                  self.bounds.size.height - 1,
                                  self.bounds.size.width,
                                  1);
}

- (void)setLeftCount:(int)leftCount{
//    [[NSString stringWithFormat:NSLocalizedString(@"phone",@"")]componentsSeparatedByString:[NSString stringWithFormat: @"(%d)",leftCount]];
    
    _leftLabel.text = [[NSString stringWithFormat:NSLocalizedString(@"phone",@"")]stringByAppendingString:[NSString stringWithFormat: @"(%d)",leftCount]];
}

- (void)setRightCount:(int)rightCount{

    _rightLabel.text = [[NSString stringWithFormat:NSLocalizedString(@"kuner",@"")]stringByAppendingString:[NSString stringWithFormat: @"(%d)",rightCount]];
}

- (void)changeMode:(ChangeMode)mode{
    if (mode == LEFT) {
        _leftLabel.textColor = SELECT_COLOR;
        _rightLabel.textColor = UNSELECT_COLOR;
    }
    else{
        _leftLabel.textColor = UNSELECT_COLOR;
        _rightLabel.textColor = SELECT_COLOR;
    }
    
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _bottomLine.frame = CGRectMake((mode == LEFT ? 0 : self.bounds.size.width * 0.5),
                                       self.bounds.size.height - 1,
                                       _bottomLine.frame.size.width,
                                       1);
    } completion:^(BOOL finished) {
        
    }];
}

@end
