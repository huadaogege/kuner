//
//  MusicTimerCell.m
//  tjk
//
//  Created by huadao on 16/3/24.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "MusicTimerCell.h"

@implementation MusicTimerCell{

}

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(15*WINDOW_SCALE_SIX, 0, 260*WINDOW_SCALE_SIX, 49*WINDOW_SCALE_SIX)];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.numberOfLines = 2;
        _label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
        [self.contentView addSubview:_label];
        
        _imageV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 50*WINDOW_SCALE_SIX, 10*WINDOW_SCALE_SIX, 30*WINDOW_SCALE_SIX, 30*WINDOW_SCALE_SIX)];
        [self.contentView addSubview:_imageV];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;

}
- (void)selectCell:(BOOL)select{
    
    if (select) {
        self.imageV.image = [UIImage imageNamed:@"musicselect" bundle:@"TAIG_125"];
    }else{
        self.imageV.image = nil;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
