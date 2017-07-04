//
//  CustomGesView.m
//  tjk
//
//  Created by You on 15/12/16.
//  Copyright © 2015年 kuner. All rights reserved.
//

#import "CustomGesView.h"

@implementation CustomGesView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
//        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        directionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        directionView.backgroundColor = [UIColor clearColor];
        directionView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self addSubview:directionView];
        
        nowTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 28, frame.size.width / 2.0 - 3, 20)];
        nowTimeLabel.textColor = [UIColor colorWithRed:0 green:185.0/255.0 blue:1 alpha:1.0];
        nowTimeLabel.font = [UIFont systemFontOfSize:12];
        nowTimeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:nowTimeLabel];
        
        totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nowTimeLabel.frame.size.width, nowTimeLabel.frame.origin.y, frame.size.width / 2.0 + 3, 20)];
        totalTimeLabel.textColor = [UIColor whiteColor];
        totalTimeLabel.font = [UIFont systemFontOfSize:12];
        totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:totalTimeLabel];
        
    }
    return self;
}

-(void)setDirection:(VideoMoveDirection)direction nowtime:(NSString *)nowStr totalTime:(NSString *)totalStr
{
    if (direction == kVideoMoveDirectionNone) {
        return;
    }
    UIImage *image = direction == kVideoMoveDirectionLeft?[UIImage imageNamed:@"a_fast_reverse.png" bundle:@"TAIG_Photo_Mov"] :[UIImage imageNamed:@"a_Fast_forward.png" bundle:@"TAIG_Photo_Mov"];
    [directionView setImage:image];
    nowTimeLabel.text = nowStr;
    totalTimeLabel.text = [NSString stringWithFormat:@"/%@",totalStr];
}

#pragma mark - bottom view

-(instancetype)initBottomViewWith:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        // bottom hud
        
        CGFloat width = 210;
        
        UIImageView * bottomBackGorund = [[UIImageView alloc] init];
        bottomBackGorund.frame = CGRectMake((frame.size.width - width) / 2,0,width,frame.size.height);
        bottomBackGorund.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_control_bg"];
        
        UIView * bottomBackGorundView = [[UIView alloc] init];
        bottomBackGorundView.backgroundColor = [UIColor clearColor];
        bottomBackGorundView.frame = bottomBackGorund.frame;
        bottomBackGorund.frame = CGRectMake(0,0,width,frame.size.height);
        [bottomBackGorundView addSubview:bottomBackGorund];
        
        CGFloat leftrightblock = 27.0;
        CGFloat midblock = 45.0;
        CGFloat btnwidth = 22.0;
        CGFloat btnoriginY = (bottomBackGorund.frame.size.height - btnwidth)/2.0;
        
        _rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rewindButton.frame = CGRectMake(0, 0, width/3,frame.size.height);
        _rewindButton.backgroundColor = [UIColor clearColor];
        _rewindButton.showsTouchWhenHighlighted = YES;
        [_rewindButton addTarget:self action:@selector(rewindDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * rewindImg = [[UIImageView alloc] init];
        rewindImg.userInteractionEnabled = NO;
        rewindImg.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_reverse"];
        rewindImg.frame = CGRectMake(leftrightblock,
                                     btnoriginY,
                                     btnwidth,
                                     btnwidth);
        
        [_rewindButton addSubview:rewindImg];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(width * 0.5 - btnwidth/2.0, (midblock - btnwidth)/2, btnwidth, btnwidth);
        _playButton.backgroundColor = [UIColor clearColor];
        _playButton.showsTouchWhenHighlighted = YES;
        [_playButton setImage:[UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardButton.frame = CGRectMake(width*2/3, 0, width/3, frame.size.height);
        
        UIImageView * forwardImg = [[UIImageView alloc] init];
        forwardImg.userInteractionEnabled = NO;
        forwardImg.image = [UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_forward"];
        forwardImg.frame = CGRectMake((_forwardButton.bounds.size.width - leftrightblock)/2.0,
                                      btnoriginY,
                                      btnwidth,
                                      btnwidth);
        
        [_forwardButton addSubview:forwardImg];
        
        _forwardButton.backgroundColor = [UIColor clearColor];
        _forwardButton.showsTouchWhenHighlighted = YES;
        
        [_forwardButton addTarget:self action:@selector(forwardDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rotateBtn.backgroundColor = [UIColor clearColor];
        [rotateBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        BOOL island = ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeRight);
        [self setRotateBtnStatus:island];
        [rotateBtn addTarget:self action:@selector(ratoteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        rotateBtn.frame = CGRectMake(frame.size.width - 50, 0,45, 45);
//        rotateBtn.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin;
        
        [self addSubview:bottomBackGorundView];
        [bottomBackGorundView addSubview:_rewindButton];
        [bottomBackGorundView addSubview:_playButton];
        [bottomBackGorundView addSubview:_forwardButton];
        [self addSubview:rotateBtn];
    }
    return self;
}

- (void) rewindDidTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(rewindDidTouch:)]) {
        [_delegate rewindDidTouch:sender];
    }
}

- (void) playDidTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(playDidTouch:)]) {
        [_delegate playDidTouch:sender];
    }
}

- (void) forwardDidTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(forwardDidTouch:)]) {
        [_delegate forwardDidTouch:sender];
    }
}

-(void)ratoteBtnClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(ratoteBtnClick)]) {
        [_delegate ratoteBtnClick];
    }
}

-(void)setPlayBtnStatus:(BOOL)isplay{
    UIImage *image = isplay?[UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_pause"] :[UIImage imageNamed:@"TAIG_Photo_Mov.bundle/a_icon_play"];
    [_playButton setImage:image forState:UIControlStateNormal];
}

-(void)setRotateBtnStatus:(BOOL)isLand
{
    UIImage *image = isLand? [UIImage imageNamed:@"video_poscreen.png" bundle:@"TAIG_Photo_Mov"]: [UIImage imageNamed:@"video_allscreen.png" bundle:@"TAIG_Photo_Mov"];
    [rotateBtn setImage:image forState:UIControlStateNormal];
}

#pragma - video top view

-(instancetype)initTopViewWith:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(0,
                                       20,
                                       80*WINDOW_SCALE_SIX,
                                       40*WINDOW_SCALE_SIX);
        _doneButton.backgroundColor = [UIColor clearColor];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _doneButton.showsTouchWhenHighlighted = YES;
        [_doneButton addTarget:self action:@selector(doneDidTouch:) forControlEvents:UIControlEventTouchUpInside];
        UIView * btnview = [[UIView alloc]initWithFrame:_doneButton.frame];
        UIView *topTemp = [[UIView alloc] init];
        topTemp.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topTemp.backgroundColor = [UIColor blackColor];
        topTemp.frame = CGRectMake(0,
                                   0,
                                   frame.size.width,
                                   30*WINDOW_SCALE);
        
        _videoName = [[UILabel alloc] init];
        _videoName.textColor = [UIColor whiteColor];
        _videoName.backgroundColor = [UIColor clearColor];
        _videoName.font = [UIFont systemFontOfSize:14*WINDOW_SCALE];
        _videoName.textAlignment = NSTextAlignmentCenter;
        _videoName.frame = CGRectMake(65*WINDOW_SCALE, _doneButton.frame.origin.y,frame.size.width - 130*WINDOW_SCALE, topTemp.bounds.size.height);
        _videoName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIImageView * doneBtnImg = [[UIImageView alloc] init];
        doneBtnImg.userInteractionEnabled = YES;
        doneBtnImg.frame = CGRectMake(14.5*WINDOW_SCALE,
                                      (_doneButton.bounds.size.height - 34*WINDOW_SCALE) / 2,
                                      34*WINDOW_SCALE,
                                      34*WINDOW_SCALE);
        doneBtnImg.image = [UIImage imageNamed:@"list_icon-back" bundle:@"TAIG_FILE_LIST"];
        [_doneButton addSubview:doneBtnImg];
        
        UILabel * backlabel = [[UILabel alloc]initWithFrame:CGRectMake(doneBtnImg.frame.origin.x+doneBtnImg.frame.size.width - 16*WINDOW_SCALE_SIX, doneBtnImg.frame.origin.y, 60.0*WINDOW_SCALE_SIX, doneBtnImg.frame.size.height)];
        backlabel.font = [UIFont systemFontOfSize:14.0];
        backlabel.textColor = [UIColor whiteColor];
        backlabel.text = NSLocalizedString(@"back", @"");
        [btnview addSubview:backlabel];
        
        [btnview addSubview:doneBtnImg];
        [self addSubview:btnview];
        [self addSubview:_doneButton];
        [self addSubview:_videoName];
    }
    return self;
}

-(void)setVideoNameWith:(NSString *)name
{
    _videoName.text = name;
}

- (void)doneDidTouch:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(doneDidTouch:)]) {
        [_delegate doneDidTouch:sender];
    }
}

-(void)dealloc
{
    _delegate = nil;
}

-(instancetype)initAlertwith:(CGRect)frame{
    self= [super initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        [self addSubview:bgView];
        
        UIView *contanierview = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-270)/2.0, (SCREEN_HEIGHT-250-64)/2.0, 270, 250)];
        contanierview.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.95];
        [self addSubview:contanierview];
        
        contanierview.layer.cornerRadius = 8.0;
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 15*WINDOW_SCALE_SIX, contanierview.frame.size.width, 25)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
       
        _titleLab.font = [UIFont systemFontOfSize:18];
        [contanierview addSubview:_titleLab];
        
        _contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, _titleLab.frame.size.height+_titleLab.frame.origin.y, contanierview.frame.size.width-20, 150)];
        _contentLab.textAlignment = NSTextAlignmentLeft;

        _contentLab.numberOfLines = 0;
        _contentLab.font = [UIFont systemFontOfSize:15];
        [contanierview addSubview:_contentLab];
        
        _leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,  _contentLab.frame.size.height+_contentLab.frame.origin.y+10, contanierview.frame.size.width/2.0, 50.0)];
        _leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
        _leftBtn.tag = 123;
        [_leftBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1]  forState:UIControlStateNormal];
        [contanierview addSubview:_leftBtn];
        
        _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(contanierview.frame.size.width/2.0,  _contentLab.frame.size.height+_contentLab.frame.origin.y+10, contanierview.frame.size.width/2.0, 50.0)];

        [_rightBtn setTitleColor:[UIColor colorWithRed:42/255.0f green:100/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _rightBtn.tag = 456;
        [contanierview addSubview:_rightBtn];
        
        UIView * lineA = [[UIView alloc]initWithFrame:CGRectMake(0, _leftBtn.frame.origin.y-0.5, contanierview.frame.size.width, 0.5)];
        lineA.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
        [contanierview addSubview:lineA];
        
        UIView * lineB = [[UIView alloc]initWithFrame:CGRectMake(contanierview.frame.size.width/2.0, _leftBtn.frame.origin.y-0.5, 0.5, contanierview.frame.size.height-_leftBtn.frame.origin.y+0.5)];
        lineB.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
        [contanierview addSubview:lineB];
    }
    return self;
}



@end
