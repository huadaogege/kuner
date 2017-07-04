//
//  PowerBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

//usb状态 10未接入 11电脑 12电源
typedef enum : NSUInteger {
    ERROR       = 0,
    NONE        = 10,
    INSERTPOWER = 11,
    INSERTPC  = 12,
// 0-unknown, 10-suspended, 11-adaptor, 12-pc
} USB_STAT;

typedef enum : NSUInteger {
    UNKNOW       = 0,
    INSERTPC_H   = 110,
    INSERTPC_U   = 111,
    // 0-unknown, 110-iPhone(透传mode) 111-MSWindows(U盘mode)
} USB_MODEL;

//充电速度, 1为慢充
typedef enum : NSUInteger {
    SLOW        = 1,
    FAST        = 2,
} SPEED_STAT;

//充电还是放电 1放电
typedef enum : NSUInteger {
    POWER_OUT       = 1,
    POWER_IN        = 2,
} MODEL_STAT;

@interface PowerBean : NSObject

@property int           all;
@property float         surplus;    //电量百分比
@property SPEED_STAT    speed;      //充电速度
@property int           current;    //电流
@property int           thermal;    //温度
@property int           health;     //健康值
@property int           limit;      //预留电量
@property float           vol;      //电压
@property MODEL_STAT    model;      //充电还是放电
@property USB_STAT      usb1_stat;
@property USB_MODEL      usb1_model;

@end
