//
//  FilterLoading.h
//  tjk
//
//  Created by Ching on 15-1-13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileBean.h"

@protocol FilterLoadingDelegate <NSObject>

@optional
-(void)loadingPhotoFinishWith:(NSMutableDictionary *)dict;

@end


@interface FilterLoading : NSObject
{
    dispatch_queue_t        _dispatchQueue;
}
@property(nonatomic,assign)NSInteger  nowTag;

@property(nonatomic,strong)NSMutableDictionary *requestDict;
@property(nonatomic,strong)NSMutableDictionary *cacheDict;

@property(nonatomic, assign) id<FilterLoadingDelegate> delegate;

+(FilterLoading *)instance;

-(void)needMessage:(FileBean*)url allPhoneArr:(NSMutableArray*)arr;
-(NSData *)getDataWith:(NSString *)filepath;
-(void)clearCache;
@end
