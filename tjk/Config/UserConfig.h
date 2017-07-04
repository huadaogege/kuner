//
//  UserConfig.h
//  tjk
//
//  Created by liull on 14-3-26.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "config.h"

@interface UserConfig : NSObject

//sharedUserConfig
DEFINE_SINGLETON_FOR_HEADER(UserConfig)

//初始化配置文件的路径
@property(strong, nonatomic) NSString * path;

//设置默认配置
-(void)setDefaultConfig:(NSDictionary*)config;

//取配置信息
- (id) configForKey:(NSString*)key;
- (void) setConfigForKey:(NSString*)key value:(id)value;

@end
