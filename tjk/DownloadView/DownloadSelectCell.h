//
//  DownloadSelectCell.h
//  tjk
//
//  Created by huadao on 15/10/13.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadSelectCell : UICollectionViewCell
@property (nonatomic,retain)UILabel * label;
@property (nonatomic,retain)UIImageView * cellState;
@property (nonatomic,retain)UIImageView * cellBackimage;

-(void)setSelected:(BOOL)selected;
-(void)setbtnState:(int)state style:(int)style;

@end
