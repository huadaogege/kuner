//
//  TableViewCell.m
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "MainViewMenuCell.h"

@implementation MainViewMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:animated];
}

-(IBAction)cellClicked:(UIButton*)button {
    if ([self.clickDelegate respondsToSelector:@selector(cellClickedAt:)]) {
        [self.clickDelegate cellClickedAt:self.row];
    }
}

@end
