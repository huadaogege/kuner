//
//  CustomMainBtn.h
//  tjk
//
//  Created by Ching on 15-3-25.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomMainBtn : UIButton{
    
    UIImageView *_iconView;
    UIImageView *_rightView;
    
    UILabel     *_nameLabel;
    
    UIView      *_lineView;
    
}

-(void)setName:(NSString *)name;
-(void)setImage:(UIImage *)img;
-(void)myViewHigh:(float)nowHight;
@end
