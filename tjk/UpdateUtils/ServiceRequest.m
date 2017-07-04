//
//  ServiceRequest.m
//  KY_PaySDK
//
//  Created by 呼啦呼啦圈 on 13-6-6.
//  Copyright (c) 2013年 吕冬剑. All rights reserved.
//

#import "ServiceRequest.h"

@interface ServiceRequest ()<NSURLConnectionDataDelegate>{
}
@end

@implementation ServiceRequest
//@synthesize delegate = _delegate;
@synthesize connectionMap;
@synthesize serviceUserInfo;

static ServiceRequest * instance = nil;

+(ServiceRequest *)instance{

    if(instance == nil){
        instance = [[ServiceRequest alloc]init];
    }
    return instance;
}

-(id)init{
    self = [super init];
    
    if(self){
//        connection = [[NSURLConnection alloc]init];
        _connections = [[NSMutableArray alloc] init];
        _connectionDatas = [[NSMutableDictionary alloc]init];
        
        self.connectionMap = [[NSMutableDictionary alloc]init] ;
        
        self.serviceUserInfo = [[NSMutableDictionary alloc]init] ;
    }
    
    return self;
}
 
- (void)cancelRequest{
    
    for (NSURLConnection* connection in _connections) {
        [connection cancel];
    }
    [_connections removeAllObjects];
        
}

- (void)cancelRequestWithDelegate:(id)delegate{
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    NSNumber* numKeyTmp = nil;
    NSString* keyTmp = nil;
    for (NSURLConnection* connection in _connections) {
        NSNumber * numKey = [NSNumber numberWithUnsignedLongLong:( unsigned long long)connection];
        NSString * key = [NSString stringWithFormat:@"delegate:%@", numKey];
        id delegateConnection = [self.connectionMap objectForKey:key];
        if ([delegateConnection isEqual:delegate]) {
            [connection cancel];
            [tmpArray addObject:connection];
            if (!keyTmp) {
                numKeyTmp = numKey;
                keyTmp = key;
            }
        }
    }
    if (tmpArray.count > 0) {
        if (keyTmp) {
            [self.connectionMap removeObjectForKey:numKeyTmp];
            [self.connectionMap removeObjectForKey:keyTmp];
        }
        [_connections removeObjectsInArray:tmpArray];
    }
}

- (void)requestLink:(NSData *)data urlAddress:(NSString *)urlStr info:(id)obj delegate:(id)delegate isBanben:(BOOL)isBanben{
    
    _isBanben=isBanben;
    for (NSURLConnection * connection in _connections) {
        if ([connection.originalRequest.URL.absoluteString isEqualToString:urlStr]) {
            [connection cancel];
            [_connections removeObject:connection];
            break;
        }
    }
    
    NSURL * url = [NSURL URLWithString:urlStr];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    
    if(data != nil){
        
        [request setHTTPMethod:@"POST"];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
//        [urlRequest setValue: IPADDRESS forHTTPHeaderField:@"Host"];
        [request setValue: postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        
    }
    
    //第三步，连接服务器
    
    NSURLConnection * newConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [newConnection start];
    if(obj){
        [self.connectionMap setObject:obj
                               forKey:[NSNumber numberWithUnsignedLongLong:( unsigned long long)newConnection] ];
    }
    
    if(delegate){
        [self.connectionMap setObject:delegate
                               forKey:[NSString stringWithFormat:@"delegate:%@",[NSNumber numberWithUnsignedLongLong:( unsigned long long)newConnection]] ];
    }
    
    if(newConnection != nil){
        [_connections addObject:newConnection];
        
    }
}

- (void)requestService:(NSData *)data urlAddress:(NSString *)urlStr info:(id)obj delegate:(id)delegate isBanben:(BOOL)isbanben{
    
    [self requestLink:data urlAddress:urlStr info:obj delegate:delegate isBanben:isbanben];
}

- (void) connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error{
   
    
    NSNumber * numKey = [NSNumber numberWithUnsignedLongLong:( unsigned long long)_connection];
    NSString * key = [NSString stringWithFormat:@"delegate:%@", numKey];
    id delegate = [self.connectionMap objectForKey:key];
    
    if(delegate && [delegate respondsToSelector:@selector(resultFaile:info:)]){
        
        id info = [self.connectionMap objectForKey:[NSNumber numberWithUnsignedLongLong:( unsigned long long)_connection]];
        
        [delegate resultFaile:error info:info];
    }

    [self.connectionMap removeObjectForKey:numKey];
    [self.connectionMap removeObjectForKey:key];
    [_connections removeObject:_connection];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSMutableData* connectionData = [_connectionDatas objectForKey:[NSString stringWithFormat:@"%@::%@",[NSNumber numberWithUnsignedLongLong:( unsigned long long)connection],connection.originalRequest.URL.absoluteString]];
    [connectionData appendData:data];
    
    
    
    
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection{
    // 下载的数据
    NSNumber * numKey = [NSNumber numberWithUnsignedLongLong:( unsigned long long)connection];
    NSString * key = [NSString stringWithFormat:@"delegate:%@", numKey];
    
    id info = [self.connectionMap objectForKey:numKey];
    
    id delegate = [self.connectionMap objectForKey:key];
    
    if(delegate && [delegate respondsToSelector:@selector(resultSuccess:info:isBanben:originUrl:)]){
        
        [delegate resultSuccess:[_connectionDatas objectForKey:[NSString stringWithFormat:@"%@::%@",[NSNumber numberWithUnsignedLongLong:( unsigned long long)connection],connection.originalRequest.URL.absoluteString]] info:info isBanben:_isBanben originUrl:connection.originalRequest.URL.absoluteString];
        
               
    }
    [self.connectionMap removeObjectForKey:numKey];
    [self.connectionMap removeObjectForKey:key];
    [_connections removeObject:connection];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_connectionDatas setObject:[[NSMutableData alloc]init] forKey:[NSString stringWithFormat:@"%@::%@",[NSNumber numberWithUnsignedLongLong:( unsigned long long)connection],connection.originalRequest.URL.absoluteString]];
}

@end
