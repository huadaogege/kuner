//
//  AppUpdateUtils.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-4-14.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "AppUpdateUtils.h"
#import "DESUtils.h"
#import "config.h"

#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCryptor.h>
#include "HardwareInfoBean.h"
#define  GUJIAN 123


#define GET_TG_FLAG @"get_tg_info"

#define DOWN_TG_FLAG @"download_tg"


@implementation AppUpdateUtils


static AppUpdateUtils *instance;

+(AppUpdateUtils *)instance{
    
    if(instance == nil){
        instance = [[AppUpdateUtils alloc] init];
    }
    return instance;
}

-(id)init{
    
    self = [super init];
    if(self){
        
        _downInfoMap = [[NSDictionary alloc] init];
        _dispatchQueue  = dispatch_queue_create("AppUpdateUtils", DISPATCH_QUEUE_SERIAL);
        _loadingView = [[CustomNotificationView alloc] initWithTitle:NSLocalizedString(@"dataasync",@"")];
    }
    return self;
}

-(void)cancleRequest{
    
    [[ServiceRequest instance] cancelRequest];
}

-(void)checkUpdate:(NSString *)version Url:(NSString *)url
{
    [[ServiceRequest instance] requestService:nil
                                   urlAddress:UPDATE_URL
                                         info:[NSDictionary dictionaryWithObjectsAndKeys:UPDATE_INFO_FLAG, @"flag", nil]
                                     delegate:self isBanben:_isBanben];
}

-(void)sendSNnumber{

    NSString * snnumber = [FileSystem getSN];
    NSString * snurl = [SN_SEND_URL stringByAppendingString:[NSString stringWithFormat:@"?sn=%@&proId=0",snnumber]];
    [[ServiceRequest instance] requestService:nil
                                   urlAddress:snurl
                                         info:[NSDictionary dictionaryWithObjectsAndKeys:SN_NUMBER, @"flag", nil]
                                     delegate:self isBanben:_isBanben];

}
-(void)checkUpdate{
    
    NSString * localgujian = [FileSystem getVersion];
    NSString * localApp = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString];
    NSString * gujianUrl = [GUJIAN_UPDATE_URL stringByAppendingString:[NSString stringWithFormat:@"?proId=0&fwVer=%@&appVer=%@",localgujian,localApp]];
    [[ServiceRequest instance] requestService:nil
                                   urlAddress:gujianUrl
                                         info:[NSDictionary dictionaryWithObjectsAndKeys:UPDATE_INFO_FLAG, @"flag", nil] delegate:self isBanben:_isBanben];
}

-(void)updateVersion{
    NSString * downurl = [_downInfoMap objectForKey:@"new_fw_url"];
    [[ServiceRequest instance] requestService:nil
                                   urlAddress:downurl
                                         info:[NSDictionary dictionaryWithObjectsAndKeys:UPDATE_DOWNLOAD_FLAG, @"flag", nil] delegate:self isBanben:_isBanben];
}

-(void)downloadTg{
    
    NSString *uuid = @"";
//    if([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]){
//        
//        uuid = objc_msgSend([UIDevice currentDevice], @selector(uniqueIdentifier));
//    }

    NSString * mac = [DESUtils encodeToPercentEscapeString:[[DESUtils macaddress] lowercaseString]];

    NSString * client = [DESUtils encodeToPercentEscapeString:[[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] lowercaseString]];
    NSString * device = [DESUtils encodeToPercentEscapeString:[[UIDevice currentDevice].model lowercaseString]];
    [DESUtils macaddress];
    NSMutableDictionary * dic=[[NSMutableDictionary alloc]init];
    [dic setObject:client forKey:@"client"];
    [dic setObject:uuid forKey:@"uuid"];
    [dic setObject:mac forKey:@"mac"];
    [dic setObject:device forKey:@"device"];
    NSString * urlStr=[NSString stringWithFormat:DOWNLOAD_TG_ADDRESS];
    NSRange foundObj = [urlStr rangeOfString:@"?"];

    NSString * dataStr = [urlStr substringFromIndex:foundObj.location + 1];
    NSString *urlAsString = [NSString stringWithFormat:@"%@?data=%@",
                             [urlStr substringToIndex:foundObj.location],
                             [DESUtils encodeToPercentEscapeString:[DESUtils encryptUseDES:dataStr key:@"wegte4o9rux2"]]];;

    [[ServiceRequest instance] requestService:nil
                                   urlAddress:urlAsString
                                         info:[NSDictionary dictionaryWithObjectsAndKeys:GET_TG_FLAG, @"flag", nil]
                                     delegate:self isBanben:nil];
}

- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
    
    [Context shareInstance].isShowingUpdateResult = NO; // 设置固件升级结果弹框状态
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0 && alertView.tag == GUJIAN) {
        // 服务器获取固件版本
        [self updateVersion];
    }
}

-(void)resultSuccess:(NSData *)data info:(id)info isBanben:(BOOL)isbanben originUrl:(NSString *)url{

    
    NSDictionary *dataInfo = info;
    if([UPDATE_INFO_FLAG isEqualToString:[dataInfo objectForKey:@"flag"]]){
        //得到下载信息
        weatherDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        _downInfoMap = weatherDic;
        NSString *  code = [weatherDic objectForKey:@"code"];
        NSString *  message = [weatherDic objectForKey:@"msg"];
        NSString * isupdateApp = [weatherDic objectForKey:@"app_upgrade"];
        NSString * serveGuJianVersion = [weatherDic objectForKey:@"new_fw_ver"];
        NSString * serverAppVersion=[weatherDic objectForKey:BIN_VERSION];
        
        if ([isupdateApp intValue] == 1) {
            [self checkUpdate:nil Url:nil];
        }
        if (serverAppVersion && [weatherDic objectForKey:@"bininfo"] && [weatherDic objectForKey:@"dlbin"]) {
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSString * noTipsVersion = [defaults objectForKey:@"binversion"];
            if ([noTipsVersion isEqualToString:serverAppVersion]) {
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FINDVERSION
                                                                object:
             [NSString stringWithFormat:@"%d", YES]
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:serverAppVersion, APP_VERSION,
                                                                        [weatherDic objectForKey:@"bininfo"], APP_INFO,
                                                                        [weatherDic objectForKey:@"dlbin"],APP_UPDATE_PLIST,
                                                                        nil]];
            
        }else{
            if ([isupdateApp intValue] !=1 && [code integerValue] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FINDVERSION object:
                 [NSString stringWithFormat:@"%d", YES]
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:serveGuJianVersion, BIN_VERSION,
                                                                            [weatherDic objectForKey:@"new_fw_info"], BIN_INFO,
                                                                            [weatherDic objectForKey:@"new_fw_url"],BIN_UPDATE_PLIST,
                                                                            [weatherDic objectForKey:@"new_fw_md5"],BIN_MD5,
                                                                            nil]];
            }
        }
        
    }else if([UPDATE_DOWNLOAD_FLAG isEqualToString:[dataInfo objectForKey:@"flag"]]){
        
        NSString *dataMd5 = [[DESUtils getMD5ForData:data] lowercaseString];
        NSString * serverMd5 = [[_downInfoMap objectForKey:BIN_MD5] lowercaseString];
        if([dataMd5 isEqualToString:serverMd5]){
            
            //下载到的数据
            dispatch_async(_dispatchQueue, ^{
                int  success= [FileSystem updateDevice:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //指示器消失通知
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissalert" object:nil];
                    [Context shareInstance].isShowingUpdateResult = YES; // 设置固件升级结果弹框状态
                    
                    if (success==-1)
                    {
                        UIAlertView * fail=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"updatefail",@"") message:NSLocalizedString(@"updatefail_again",@"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                        [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                         target:self
                                                       selector:@selector(timerFireMethods:)
                                                       userInfo:fail
                                                        repeats:YES];
                        [fail show];
                    }
                    else
                    {
                        UIAlertView *success=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"update_success",@"") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                        [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                         target:self
                                                       selector:@selector(timerFireMethods:)
                                                       userInfo:success
                                                        repeats:YES];
                        [success show];
                        
                    }
                });
                
            });
        }else{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_SELF object:[NSString stringWithFormat:@"%d", NO]];
        }
        
    }else if ([SN_NUMBER isEqualToString:[dataInfo objectForKey:@"flag"]]){
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSString * code = [dic objectForKey:@"code"];
        NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:code forKey:@"sncode"];
        
    }
    else if([GET_TG_FLAG isEqualToString:[dataInfo objectForKey:@"flag"]]){
        
        NSArray *dataAry = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        NSDictionary * info = [dataAry lastObject];
        
        if([info objectForKey:@"REASON"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_TG object:[NSString stringWithFormat:@"%d", NO]];
            
        }
        NSString * updateURL = [info objectForKey:@"DOWNLOADURL"];
        NSString * updateMD5 = [info objectForKey:@"MD5"];
        
        [[ServiceRequest instance] requestService:nil
                                       urlAddress:updateURL
                                             info:[NSDictionary dictionaryWithObjectsAndKeys:DOWN_TG_FLAG, @"flag", updateMD5, @"md5", nil]
                                         delegate:self isBanben:nil];
        
    }else if([DOWN_TG_FLAG isEqualToString:[dataInfo objectForKey:@"flag"]]){
        
        NSString *dataMd5 = [[DESUtils getMD5ForData:data] lowercaseString];
        
        if([dataInfo objectForKey:@"md5"] && [dataMd5 isEqualToString:[[dataInfo objectForKey:@"md5"] lowercaseString]]){
            
            //下载到的数据
            dispatch_async(_dispatchQueue, ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_TG object:[NSString stringWithFormat:@"%d", YES]];
                
            });
        }else{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOAD_TG object:[NSString stringWithFormat:@"%d", NO]];
            
        }
        
    }
}
-(void)loaddismiss{

    [_loadingView dismiss];
}
- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)input,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
    return outputStr;
}

-(void)resultFaile:(NSError *)error info:(id)info
{
    
    NSDictionary *restultDic = [NSMutableDictionary dictionary];
    NSString *tipStr = nil;
    
    
    if ([UPDATE_DOWNLOAD_FLAG isEqualToString:[info objectForKey:@"flag"]])
    {
        switch ([error code])
        {
            case NSURLErrorNotConnectedToInternet:
                tipStr = NSLocalizedString(@"updatefail_check_again",@"");
                break;
            case NSURLErrorTimedOut:
                tipStr = NSLocalizedString(@"checkfail_timeout_again",@"");
                break;
            default:
                tipStr = NSLocalizedString(@"checkfail_again",@"");
                break;
        }
        [restultDic setValue:UPDATE_INFO_FLAG forKey:@"flag"];
        

    }else if ([UPDATE_INFO_FLAG isEqualToString:[info objectForKey:@"flag"]])
    {
        switch ([error code])
        {
            case NSURLErrorNotConnectedToInternet:
                tipStr = NSLocalizedString(@"checkfail_checkserveragain",@"");
                break;
            case NSURLErrorTimedOut:
                tipStr = NSLocalizedString(@"checkfail_timeout_again",@"");
                break;
            default:
                tipStr = NSLocalizedString(@"checkfail_again",@"");
                break;
        }
        [restultDic setValue:UPDATE_INFO_FLAG forKey:@"flag"];

    }
    [restultDic setValue:tipStr forKey:@"tips"];
        
   

    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"set_checkUpdate_error"
                                                       object:restultDic];
  }

@end
