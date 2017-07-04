//
//  CustomGesView.h
//  tjk
//
//  Created by You on 15/12/16.
//  Copyright © 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSInteger {
    
    kVideoMoveDirectionNone = 0,
    
    kVideoMoveDirectionUp,
    
    kVideoMoveDirectionDown,
    
    kVideoMoveDirectionRight,
    
    kVideoMoveDirectionLeft
    
} VideoMoveDirection ;


@protocol CustomVideoSubViewDelegate <NSObject>

@optional

- (void) rewindDidTouch:(id)sender;
- (void) playDidTouch:(id)sender;
- (void) forwardDidTouch:(id)sender;
-(void)ratoteBtnClick;



- (void)doneDidTouch:(id)sender;

@end

@interface CustomGesView : UIView
{
    UIImageView *directionView;
    UILabel *nowTimeLabel;
    UILabel *totalTimeLabel;
    
    
    UIButton            *_playButton;
    UIButton            *_rewindButton;
    UIButton            *_forwardButton;
    UIButton *rotateBtn;
    
    UIButton *_doneButton;
    UILabel *_videoName;
    
}

@property(nonatomic,weak) id<CustomVideoSubViewDelegate> delegate;
@property(nonatomic,retain) UIButton * leftBtn;
@property(nonatomic,retain) UIButton * rightBtn;
@property(nonatomic,retain) UILabel * titleLab;
@property(nonatomic,retain) UILabel * contentLab;
-(void)setDirection:(VideoMoveDirection)direction nowtime:(NSString *)nowStr totalTime:(NSString *)totalStr;

-(instancetype)initBottomViewWith:(CGRect)frame;
-(void)setPlayBtnStatus:(BOOL)isplay;
-(void)setRotateBtnStatus:(BOOL)isLand;

-(instancetype)initTopViewWith:(CGRect)frame;
-(void)setVideoNameWith:(NSString *)name;

-(instancetype)initAlertwith:(CGRect)frame;
@end
