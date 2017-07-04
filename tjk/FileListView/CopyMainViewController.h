//
//  CopyMainViewController.h
//  tjk
//
//  Created by lengyue on 15/3/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoicePathDeleagte.h"

@interface CopyMainViewController : UIViewController
@property(nonatomic, assign) id<ChoicePathDeleagte> pathDelegate;
-(void)setLastCopyPath:(NSString*)lastPath;
@end
