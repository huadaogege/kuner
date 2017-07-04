//
//  HomePageView.h
//  tjk
//
//  Created by Ching on 15-3-31.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoViewController.h"


@protocol HomePageDeletage <NSObject>

-(void)kunerViewHidden:(BOOL)hidden isUsbOn:(BOOL)ison;
-(void)tableUserInterFace:(BOOL)isNo;
-(void)stopcycle;

@optional
-(void)showFormatAlert;
@end
@interface HomePageView : UIView{
    float _progress;

}



@property (assign) id<HomePageDeletage> delegate;

@property(nonatomic)UIButton *btnLift;
@property(nonatomic)UIButton *btnRight;
@property(nonatomic)UILabel  *labLift;
@property(nonatomic)UILabel  *labRight;
@property(nonatomic)UIAlertView * lowerPowAlert;

-(void)stopData;
-(void)beginData;
-(void)freshData;
-(void)notifPcInst;
-(void)notifyDevOff;
-(void)setLeftBtn:(NSString *)leftTxt;
-(void)setRightBtn:(NSString *)rightTxt;
-(void)resetSizeLableColor:(BOOL)isU;
-(void)AllGB:(NSString *)all UewdGB:(NSString *)used UnUseGB:(NSString *)unuse;
-(void)nowLight:(NSString *)nowTx canUseTxt:(NSString *)useTxt setProgress:(float)progress;

@end
