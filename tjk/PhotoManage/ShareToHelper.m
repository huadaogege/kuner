//
//  ShareToHelper.m
//
//  Created by You on 14-8-19.
//

#import "ShareToHelper.h"
#import "WXApi.h"

@implementation ShareToHelper

+ (BOOL)checkWerXinStatus
{
    if (![WXApi isWXAppInstalled]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"")
														message:NSLocalizedString(@"notinstallwx", @"")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"sure", @"")
											  otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"wxversionlowtip", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

+ (BOOL)sendImageContentWith:(UIImage *)image scene:(int)scene
{
    BOOL isinstall = [self checkWerXinStatus];
    if (!isinstall) {
        return NO;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = NSLocalizedString(@"copymaintitle", @"");
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (scene == WXSceneSession) {
        [message setThumbImage:image];
        if (imageData.length > 1024 * 32) {
            float scale = image.size.width / 200.0;
            UIImage *img = [self scaleToSize:image size:CGSizeMake(200, image.size.height / scale)];
            [message setThumbImage:img];
            
//            NSUInteger scale = sqrtf(imageData.length / (1024 * 32)) > 2? sqrtf(imageData.length / (1024 * 32)) : 2;
//            NSData *scaleData = UIImagePNGRepresentation([self imageByScalingAndCroppingForSize:image withTargetSize:CGSizeMake(image.size.width/scale, image.size.height / scale)]);
//            if (scaleData.length > 1024 *32) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"压缩后的缩略图过大" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alert show];
//            }
//            [message setThumbData:scaleData];
        }
    }
    
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    if (imageData.length > 1024 * 1024 * 10) {
        ext.imageData = UIImageJPEGRepresentation(image, 0.5);
        if (ext.imageData.length > 1024 * 1024 * 10) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"imageistoobig", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
            [alert show];
        }
    }
    
    message.mediaObject = ext;
//    message.mediaTagName = @"WECHAT_TAG_JUMP_APP";
//    message.messageExt = @"这是第三方带的测试字段";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    return [WXApi sendReq:req];
}

+ (void)sendContent:(NSString *)content image:(UIImage *)image linkUrl:(NSString *)linkurl isToWChatCircle:(BOOL)istoCircle
{
    BOOL isinstall = [self checkWerXinStatus];
    if (!isinstall) {
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = NSLocalizedString(@"copymaintitle", @"");
    @try
    {
        message.description = content;
        if (istoCircle) {
            message.title = content;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        
    }
    
    if (image)
    {
        [message setThumbImage:image];
    }
    else
    {
        [message setThumbImage:[UIImage imageNamed:@"logo.png"]];
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    
    ext.webpageUrl = linkurl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (istoCircle) {
        req.scene = WXSceneTimeline;
    }
    else{
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}


+ (void)sendTitle:(NSString *)title Content:(NSString *)content image:(UIImage *)image linkUrl:(NSString *)linkurl isToWChatCircle:(BOOL)istoCircle
{
    BOOL isinstall = [self checkWerXinStatus];
    if (!isinstall) {
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    @try
    {
        message.description = content;
        if (istoCircle) {
            message.title = content;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        
    }
    
    if (image)
    {
        [message setThumbImage:image];
    }
    else
    {
        [message setThumbImage:[UIImage imageNamed:@"logo.png"]];
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    
    ext.webpageUrl = linkurl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (istoCircle) {
        req.scene = WXSceneTimeline;
    }
    else{
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}



+ (void) sendAppContent:(NSString *)content linkUrl:(NSString *)linkurl View:(UIViewController *)view isToWChatCircle:(BOOL)istoCircle
{
    BOOL isinstall = [self checkWerXinStatus];
    if (!isinstall) {
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = NSLocalizedString(@"copymaintitle", @"");
    @try
    {
        message.description = content;
        if (istoCircle) {
            message.title = content;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally
    {
        
    }
    [message setThumbImage:[UIImage imageNamed:@"logo.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    
    ext.webpageUrl = linkurl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (istoCircle) {
        req.scene = WXSceneTimeline;
    }
    else{
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}

#pragma mark - 处理图片大小

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage withTargetSize: (CGSize)targetSize
{
    
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    //(newImage == nil)
        //NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    //NSLog(@"%f,%f",newImage.size.width,newImage.size.height);
    
    return newImage;
    
    
}
@end
