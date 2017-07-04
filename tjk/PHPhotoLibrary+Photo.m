//
//  PHPhotoLibrary+Photo.m
//  tjk
//
//  Created by 崔玉冠 on 16/7/18.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "PHPhotoLibrary+Photo.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>
@implementation PHPhotoLibrary (Photo)


+(void)load{

    Method  author = class_getClassMethod([PHPhotoLibrary class], @selector(authorizationStatus));
    Method  newMethod = class_getClassMethod([PHPhotoLibrary class], @selector(newMethod));
    method_exchangeImplementations(author,newMethod);
    
}

+ (ALAuthorizationStatus)newMethod{

}

@end
