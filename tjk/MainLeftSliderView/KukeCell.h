//
//  KukeCell.h
//  tjk
//
//  Created by huadao on 15/4/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KukeCell : UITableViewCell

@property (nonatomic, strong) UILabel * aboutKuke;
@property (nonatomic, strong) UILabel * aboutRight;

- (void)setCellName:(NSString *)name longer:(BOOL)lFlag;

@end
