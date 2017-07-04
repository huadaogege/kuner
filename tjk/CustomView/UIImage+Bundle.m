//
//  UIImage+Bundle.m
//  tjk
//
//  Created by liull on 14-3-24.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

+(UIImage*)imageNamed:(NSString *)name  bundle:(NSString*)bundle {
    
    @synchronized (self) {
        NSString * imagePath = [[NSBundle mainBundle] resourcePath];
        
        imagePath = [imagePath stringByAppendingPathComponent:bundle];
        if( ![imagePath hasSuffix:@"bundle"] )
            imagePath = [imagePath stringByAppendingString:@".bundle"];
        if ([name rangeOfString:@"."].location == NSNotFound) {
            name = [NSString stringWithFormat:@"%@.png",name];
        }
        
        imagePath = [imagePath stringByAppendingPathComponent:name];
        
        return [UIImage imageWithContentsOfFile:imagePath];
    }
}


@end
