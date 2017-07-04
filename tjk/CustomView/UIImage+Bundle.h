//
//  UIImage+Bundle.h
//  tjk
//
//  Created by liull on 14-3-24.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Bundle)

//param  name: 图片的名字，带后缀名
//param  bundle: bundle的名字
+(UIImage*)imageNamed:(NSString *)name bundle:(NSString*)bundle;

@end
