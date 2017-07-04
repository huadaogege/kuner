//
//  ClassBtnCellTableViewCell.m
//  tjk
//
//  Created by Ching on 15-4-8.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "ClassBtnCellTableViewCell.h"

@implementation ClassBtnCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconView  = [[UIImageView alloc] init];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:12 * WINDOW_SCALE];
        _nameLabel.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        
        _subTitleLab = [[UILabel alloc] init];
        _subTitleLab.textAlignment = NSTextAlignmentRight;
        _subTitleLab.font = [UIFont systemFontOfSize:10 * WINDOW_SCALE];
        _subTitleLab.backgroundColor = [UIColor clearColor];
        _subTitleLab.textColor = [UIColor redColor];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
        
        [self addSubview:_iconView];
        [self addSubview:_nameLabel];
        [self addSubview:_subTitleLab];
        [self addSubview:_lineView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat nowHight = self.frame.size.height;
    _iconView.frame = CGRectMake(15*WINDOW_SCALE_SIX, (nowHight-36*WINDOW_SCALE_SIX)/2.0, 36*WINDOW_SCALE_SIX, 36*WINDOW_SCALE_SIX);
    _nameLabel.frame = CGRectMake(70*WINDOW_SCALE_SIX, 0, 100*WINDOW_SCALE, nowHight);
    
    CGFloat subOriX = self.frame.size.width-140*WINDOW_SCALE_SIX;
    _subTitleLab.frame = CGRectMake(subOriX, 0, 100*WINDOW_SCALE_SIX, nowHight);
    _lineView.frame = CGRectMake(67*WINDOW_SCALE_SIX, nowHight -0.5, SCREEN_WIDTH-67*WINDOW_SCALE_SIX, 0.5);
}

-(void)setLineNormal:(float)nowHight{
    
    _lineView.hidden = NO;
    _lineView.frame = CGRectMake(67*WINDOW_SCALE_SIX, nowHight -0.5, SCREEN_WIDTH-67*WINDOW_SCALE_SIX, 0.5);
}

-(void)setLineLast:(float)nowHight
{
    _lineView.frame = CGRectMake(0, _lineView.frame.origin.y, SCREEN_WIDTH, _lineView.frame.size.height);
}

-(void)setName:(NSString *)name{
    
    _nameLabel.text = name;
}

- (void)setSubTitle:(NSString *)subTitle
{
    _subTitleLab.text = subTitle;
}

-(void)setImage:(UIImage *)img{
    
    _iconView.image = img;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
