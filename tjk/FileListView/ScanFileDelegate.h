//
//  ScanFileDelegate.h
//  tjk
//
//  Created by lengyue on 15/3/30.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "FileBean.h"

@protocol ScanFileDelegate <NSObject>

-(void)scanedItemWith:(FileBean*)item;
-(void)needRemoveItemWith:(FileBean*)item;
-(void)needCopyItemWith:(FileBean*)item;
@end
