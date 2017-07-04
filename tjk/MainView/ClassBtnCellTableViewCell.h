//
//  ClassBtnCellTableViewCell.h
//  tjk
//
//  Created by Ching on 15-4-8.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassBtnCellTableViewCell : UITableViewCell
{
    UIImageView *_iconView;
    UILabel     *_nameLabel;
    UILabel     *_subTitleLab;
    UIView      *_lineView;
    
}

-(void)setName:(NSString *)name;
- (void)setSubTitle:(NSString *)subTitle;
-(void)setImage:(UIImage *)img;

-(void)myViewHigh:(float)nowHight;
-(void)setLineLast:(float)nowHight;
-(void)setLineNormal:(float)nowHight;


@end
