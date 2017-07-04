//
//  VideoProtocal.h
//  tjk
//
//  Created by huadao on 15/7/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoProtocal <NSObject>

@optional
-(void)removeMPmovie;
-(void)saveMPmovie:(float)curr totalTime:(float)total player:(id)player;

@end
