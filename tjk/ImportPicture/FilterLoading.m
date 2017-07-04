//
//  FilterLoading.m
//  tjk
//
//  Created by Ching on 15-1-13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "FilterLoading.h"
#import "CustomFileManage.h"
#import "FileSystem.h"

#define NOWPATH @"nowPath"
@implementation FilterLoading
static  FilterLoading *instance;


+(FilterLoading *)instance{
    
    if(instance == nil){
        instance = [[FilterLoading alloc] init];
    }
    return instance;
}
-(id)init{
    self = [super init];
    if(self){
        
        self.requestDict = [NSMutableDictionary dictionary];
        self.cacheDict = [NSMutableDictionary dictionary];
        
        _dispatchQueue  = dispatch_queue_create("FilterLoading", DISPATCH_QUEUE_SERIAL);
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notiTheBigPic:) name:@"dododododod" object:nil];
        
    }
    return self;
}


-(void)dealloc{
    if (_dispatchQueue) {
        dispatch_object_t _o = (_dispatchQueue);
        _dispatch_object_validate(_o);
        _dispatchQueue = NULL;
    }
}
//****************************不用数组处理**************************************


-(void)needMessage:(FileBean*)url allPhoneArr:(NSMutableArray*)arr{
    
    [self addRequestToDict:url from:arr];
}

-(void)addRequestToDict:(FileBean*)url from:(NSMutableArray *)arr
{
    NSInteger nowNum = 0;
    FileBean *onePhoto;
    FileBean *ThrPhoto;
    [self.requestDict removeObjectsForKeys:@[@"MiddleBean",@"BeforeBean",@"AfterBean"]];
    [self.requestDict setObject:url forKey:@"MiddleBean"];
    
    for (int i = 0; i<arr.count; i++) {
        if ([url.filePath isEqualToString:[[arr objectAtIndex:i]getFilePath]]) {
            nowNum = i;
            break;
        }
    }
    if (nowNum - 1 >= 0 && (nowNum -1 < arr.count)) {
        onePhoto = [arr objectAtIndex:nowNum-1] ;
        if ([onePhoto getFileType] == FILE_MOV) {
            onePhoto = nil;
        }
        if (onePhoto) {
            
            [self.requestDict setObject:onePhoto forKey:@"BeforeBean"];
        }
    }
    if (nowNum + 1 <= arr.count-1) {
        ThrPhoto = [arr objectAtIndex:nowNum+1] ;
        if ([ThrPhoto getFileType] == FILE_MOV) {
            ThrPhoto = nil;
        }
        
        if (ThrPhoto) {
            
            [self.requestDict setObject:ThrPhoto forKey:@"AfterBean"];
        }
    }
    
    dispatch_async(_dispatchQueue, ^{
        
        NSData *keData = nil;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *clearDic = [[NSMutableDictionary alloc] init];
        
        [self getPhotoDictWith:url nowBeanKey:@"MiddleBean" postDic:dic cacheDict:clearDic cacheData:keData];
        FileBean *midbean2 = [self.requestDict objectForKey:@"MiddleBean"];
        if ([midbean2.filePath isEqualToString:url.filePath]) {
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"needData" object:dic userInfo:nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"needData" object:[NSDictionary dictionaryWithObjectsAndKeys:midbean2,@"url", nil] userInfo:nil];
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(loadingPhotoFinishWith:)]) {
//                [self.delegate loadingPhotoFinishWith:dic];
//            }
        }
        
        if (onePhoto) {
            [self getPhotoDictWith:onePhoto nowBeanKey:@"BeforeBean" postDic:nil cacheDict:clearDic cacheData:keData];
        }
        
        if (ThrPhoto) {
            [self getPhotoDictWith:ThrPhoto nowBeanKey:@"AfterBean" postDic:nil cacheDict:clearDic cacheData:keData];
        }
        
        [self.cacheDict removeAllObjects];
        [self.cacheDict setDictionary:clearDic];
        
    });
}

-(void)getPhotoDictWith:(FileBean *)bean nowBeanKey:(NSString *)key postDic:(NSMutableDictionary *)dict cacheDict:(NSMutableDictionary *)cachedict cacheData:(NSData *)keData
{
    FileBean *midbean = [self.requestDict objectForKey:key];
    if ([midbean.filePath isEqualToString:bean.filePath]) {
        if (![self.cacheDict objectForKey:bean.filePath]) {
            
            keData = [FileSystem kr_readData:bean.filePath withBlock:^BOOL{
                FileBean *continuebean = [self.requestDict objectForKey:key];
                return [continuebean.filePath isEqualToString:bean.filePath];
            }];
            if (keData) {
                [self.cacheDict setObject: keData forKey:bean.filePath];
                [cachedict setObject:keData forKey:[bean getFilePath]];
                
                if (dict) {
                    [dict setObject:keData forKey:@"data"];
                }
            }
            if (dict) {
                [dict setObject:bean forKey:@"url"];
            }
            
        }else{
            
            [cachedict setObject:[self.cacheDict objectForKey:bean.filePath] forKey:bean.filePath];
            if (dict) {
                [dict setObject:[self.cacheDict objectForKey:bean.filePath] forKey:@"data"];
                [dict setObject:bean forKey:@"url"];
            }
        }
    }
}

-(NSData *)getDataWith:(NSString *)filepath
{
    NSData *data = [_cacheDict objectForKey:filepath];
    return data;
}

-(void)clearCache
{
    [_cacheDict removeAllObjects];
}

@end
