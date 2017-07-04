//
//  YpcCustomProgress.h
//  CustomProgressBar
//
//  Created by Ching on 14-8-19.
//  Copyright (c) 2014年 Ching. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CUSTOM_DELEAT @"删除"
#define CUSTOM_COPY   @"复制"

@protocol YpcCustomProgressDelegate <NSObject>

-(void)formatlater;

@end

typedef enum : NSUInteger {
    ACTION_COPY         = 0,
    ACTION_DEL          = 1,
} ACTION_TYPE;

typedef enum : NSUInteger {
    MOLD_PICTURE        = 0,
    MOLD_MUSIC          = 1,
    MOLD_VIDEO          = 2,
    MOLD_FILE           = 3,
} MOLD_TYPE;

@interface YpcCustomProgress : NSObject{
    
    BOOL                _isFinish;
    
    BOOL                _firstYN;
    UIWindow            *_window;
    UILabel             *_formattingLab;  //显示格式化进度lable
    UIView              *_downView;        //白底View
//    UIView              *_blueView;        //蓝色进度条
    UIView              *_grayView;        //灰色进度条
    UILabel             *_finishLabel;
    UIView              *_picDownView;
//    UILabel             *_pickLable;
    UIView              *_backView;
    UILabel             *cancelLab;
    float                size;
    float                all;
    BOOL                 formatall;
    NSDictionary *      _dic;
}

@property (nonatomic ,strong) NSTimer *theGoTimer;
@property (nonatomic ,assign) BOOL aOrB;    //no
@property (nonatomic ,assign) BOOL copyOrDele; //YES删除 NO复制
@property (nonatomic ,strong) UIButton *cancelBtn;
@property (nonatomic ,strong) UIView *blueView;
@property (nonatomic ,strong) UILabel *pickLable;

@property(nonatomic, assign)id<YpcCustomProgressDelegate> YpcDelegate;

- (void) startPainting:(BOOL)yesOrNo;       // YES
- (void) goToHundred;                       //直接走到百分之百

- (void) showProgress:(NSString *)title;
- (void) JinDuTiao;
- (void) removeTheFormatView;               //中断操作
- (void)paint;
- (void) stopPainting;

-(void)backZero;
/**
 *  循环调用
 *  @param doc     复制还是删除   #define CUSTOM_DELEAT @"删除"  CUSTOM_COPY   @"复制"
 *  @param nowNum  当前进度
 *  @param index   所有进度
 */
@end
