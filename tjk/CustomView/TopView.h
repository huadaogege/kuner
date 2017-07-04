//
//  TopView.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-4-9.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

enum{
    
    LEFT = 0,   //左侧
    RIGHT       //右侧
}typedef ChangeMode;

@interface TopView : UIView{
    
//    UIView                  *_topView;
    UIButton                *_leftBtn;
    UIButton                *_rightBtn;
    UILabel                 *_leftLabel;
    UILabel                 *_rightLabel;
    UIImageView             *_bottomLine;
    UIImageView             *_bottomWidthLine;
    UIImageView             *_centerLine;
}

@property UIButton *leftBtn;
@property UIButton *rightBtn;
@property UILabel *leftLabel;
@property UILabel *rightLabel;

//设置数量 视频栏目专用
- (void)setLeftCount:(int)leftCount;

- (void)setRightCount:(int)rightCount;

//点击的栏目
- (void)changeMode:(ChangeMode)mode;

@end
