//
//  TableViewCell.h
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainViewMenuCellDelegate <NSObject>

-(void)cellClickedAt:(NSInteger)row;

@end

@interface MainViewMenuCell : UITableViewCell
@property(nonatomic,retain) IBOutlet UIImageView* icon;
@property(nonatomic,retain) IBOutlet UILabel* title;
@property(nonatomic,retain) IBOutlet UIImageView* line;
@property(nonatomic,assign) id<MainViewMenuCellDelegate> clickDelegate;
@property(nonatomic,assign) NSInteger row;
-(IBAction)cellClicked:(UIButton*)button;
@end
