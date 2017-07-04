//
//  HardwareInfoBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HardwareInfoBean : NSObject

@property (nonatomic, retain) NSData    *uuid;              //设备uuid
@property (nonatomic, retain) NSString  *path;              //根路径
@property uint64_t  size;                                   //总空间
@property uint64_t  free_size;                              //剩余空间
@property (nonatomic, retain) NSString  *serial;            //emc串号
@property uint32_t  INFO_VERSION_MA;                        //版本号
@property uint32_t  INFO_VERSION_MI;                        //版本号
@property uint32_t  INFO_VERSION_IN;                        //版本号
@property (nonatomic, retain) NSString  *INFO_SN;           //序列

@end
