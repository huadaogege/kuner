//
//  PhotoLineCell.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemSelectDelegate.h"

@interface PhotoLineCell : UITableViewCell
@property(nonatomic,assign) id<PhotoItemSelectDelegate> itemSelectDelegate;
-(void)setData:(NSArray*)aData selectedStatus:(NSArray*)selectedArr row:(NSInteger)row  needLoadIcon:(BOOL)need;
-(void)setEditStatus:(NSInteger)editStatusType;//ItemEditType
-(void)resetContent;
-(void)setNewIdentify:(BOOL)previewed;
@end
