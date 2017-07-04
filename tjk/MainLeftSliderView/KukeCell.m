//
//  KukeCell.m
//  tjk
//
//  Created by huadao on 15/4/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "KukeCell.h"

@interface KukeCell (){
    CGFloat _labWidth;
}

@end

@implementation KukeCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _labWidth = 140*WINDOW_SCALE_SIX;
        UIColor *textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        
        _aboutKuke = [[UILabel alloc] init];
        _aboutKuke.textColor = textColor;
        _aboutKuke.textAlignment = NSTextAlignmentLeft;
        _aboutKuke.font = [UIFont systemFontOfSize:16.0*WINDOW_SCALE_SIX];
        
        _aboutRight = [[UILabel alloc] init];
        _aboutRight.textColor = textColor;
        _aboutRight.textAlignment = NSTextAlignmentRight;
        _aboutRight.font = [UIFont systemFontOfSize:15.0*WINDOW_SCALE_SIX];
        
        [self.contentView addSubview:_aboutKuke];
        [self.contentView addSubview:_aboutRight];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _aboutKuke.frame  = CGRectMake(20*WINDOW_SCALE_SIX, 0, _labWidth, self.frame.size.height);
    _aboutRight.frame = CGRectMake(90*WINDOW_SCALE_SIX, 0, SCREEN_WIDTH-110*WINDOW_SCALE_SIX, self.frame.size.height);
}

- (void)setCellName:(NSString *)name longer:(BOOL)lFlag{
    _aboutKuke.text = name;
    
    _labWidth = lFlag?(self.frame.size.width-45*WINDOW_SCALE_SIX):140*WINDOW_SCALE_SIX;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
