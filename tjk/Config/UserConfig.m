//
//  UserConfig.m
//  tjk
//
//  Created by liull on 14-3-26.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "UserConfig.h"

@interface UserConfig ()

@end


@implementation UserConfig

@synthesize path;

DEFINE_SINGLETON_FOR_CLASS(UserConfig)


//设置默认配置
-(void)setDefaultConfig:(NSDictionary*)config {
    
    NSAssert(path, @"配置文件路径不能为空！！！！");
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
        [config writeToFile:path atomically:YES];
    }else{
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if(dic){
            __block BOOL chnaged = NO;
            [config enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if( ![dic objectForKey:key] ) {
                    //不存在键值，则创建
                    [dic setObject:obj forKey:key];
                    chnaged = YES;
                }
            }];
            
            if(chnaged) {
                [dic writeToFile:path atomically:YES];
            }
        }
    }
    
}


//取配置信息
- (id) configForKey:(NSString*)key {

    NSDictionary * configDic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [configDic objectForKey:key];
}

- (void) setConfigForKey:(NSString*)key value:(id)value {
    
    NSMutableDictionary * configDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [configDic setObject:value forKey:key];
    [configDic writeToFile:path atomically:YES];
}

@end
