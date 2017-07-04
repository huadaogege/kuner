//
//  LeftCell.h
//  MainViewController
//
//  Created by huadao on 15-3-24.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftCell :  UITableViewCell
{
    UILabel * cellName;
    UIButton * weChatFeedBtn;
    UILabel  * welabel;
    UILabel  * feedlabel;
    UIImageView * webackImg;
    UIImageView * wechat;
    UIView      * weChatView;
    UIView      * weChatAlertView;
    
    
}
@property (nonatomic,retain)UIImageView * image;
-(void)setcellName:(NSString *)name;
@end
