//
//  MediaBean.h
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/26.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaBean : NSObject

//专辑
@property NSString  *album;
//作者
@property NSString  *artist;
//时间
@property int64_t   time;
//图
@property UIImage   *img;

-(NSDictionary *)getDic;

@end
