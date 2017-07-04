//
//  ServiceRequest.h
//  KY_PaySDK
//
//  Created by 呼啦呼啦圈 on 13-6-6.
//  Copyright (c) 2013年 吕冬剑. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ServiceRequestDelegate <NSObject>

-(void)resultSuccess:(NSData *)data info:(id)info isBanben:(BOOL)isbanben originUrl:(NSString *)url;

-(void)resultFaile:(NSError *)error info:(id)info;

@end

@interface ServiceRequest : NSObject{
    
    NSMutableArray * _connections;
    
    NSMutableDictionary * _connectionDatas;
    
    id queue;
    BOOL  _isBanben;
}

@property (retain) NSRecursiveLock *cancelledLock;
@property (nonatomic, retain) NSMutableDictionary * serviceUserInfo;
@property (nonatomic, retain) NSMutableDictionary * connectionMap;
@property (nonatomic, assign) id<ServiceRequestDelegate> delegate;

+(ServiceRequest *)instance;

- (void)requestService:(NSData *)data urlAddress:(NSString *)urlStr info:(id)baseUrl delegate:(id)delegate isBanben:(BOOL)isbanben;

-(void)cancelRequest;
- (void)cancelRequestWithDelegate:(id)delegate;
@end
