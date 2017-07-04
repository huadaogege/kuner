//
//  ShareToHelper.h
//
//  Created by You on 14-8-19.
//

#import <Foundation/Foundation.h>
@interface ShareToHelper : NSObject

+ (BOOL)checkWerXinStatus;
+ (BOOL)sendImageContentWith:(UIImage *)image scene:(int)scene;

+ (void) sendAppContent:(NSString *)content linkUrl:(NSString *)linkurl View:(UIViewController *)view isToWChatCircle:(BOOL)istoCircle;

+ (void)sendContent:(NSString *)content image:(UIImage *)image linkUrl:(NSString *)linkurl isToWChatCircle:(BOOL)istoCircle;
+ (void)sendTitle:(NSString *)title Content:(NSString *)content image:(UIImage *)image linkUrl:(NSString *)linkurl isToWChatCircle:(BOOL)istoCircle;
@end
