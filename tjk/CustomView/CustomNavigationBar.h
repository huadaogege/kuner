//
//  CustomNavigationBar.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14/12/12.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavBarDelegate <NSObject>

-(void)clickLeft:(UIButton *)leftBtn;
-(void)clickRight:(UIButton *)leftBtn;

@end

@interface CustomNavigationBar : UIView{
    
    UIView *flagView;
    UIView *flagView2;
}

@property UILabel *title;
@property UIButton *leftBtn;
@property UIButton *rightBtn;

@property (assign) id<NavBarDelegate> delegate;
-(void)fitSystem;
@end
