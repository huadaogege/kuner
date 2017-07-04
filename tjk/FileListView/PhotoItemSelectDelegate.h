//
//  PhotoItemSelectDelegate.h
//  tjk
//
//  Created by lengyue on 15/3/25.
//  Copyright (c) 2015年 taig. All rights reserved.
//

@protocol PhotoItemSelectDelegate <NSObject>

@optional
-(void)itemClickedAt:(NSInteger)index selected:(BOOL)selected;
-(void)itemClickedAt:(NSInteger)index model:(NSObject *)bean selected:(BOOL)selected;
-(void)deleteModel:(id)model;
-(void)swipeToControlDeleteBtn:(BOOL)show atRow:(NSInteger)row;

-(void)downloadCompleted;
-(void)downloadFailed;
-(void)pauseBtnClickWith:(NSString *)urlPath status:(int)status;

@end
