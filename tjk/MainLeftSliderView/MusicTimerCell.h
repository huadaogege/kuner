//
//  MusicTimerCell.h
//  tjk
//
//  Created by huadao on 16/3/24.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicTimerCell : UITableViewCell
@property (nonatomic,retain)UILabel * label;
@property (nonatomic,retain)UIImageView * imageV;
@property (nonatomic,assign)BOOL        isSelected;

- (void)selectCell:(BOOL)select;
@end
