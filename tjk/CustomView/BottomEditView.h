//
//  BottomEditView.h
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomEditViewDelegate <NSObject>

-(void)editButtonClickedAt:(NSInteger)tag;

@end

@interface BottomEditView : UIView
@property(nonatomic,assign)id<BottomEditViewDelegate> editDelegate;
-(id)initWithInfos:(NSArray*)infos frame:(CGRect)frame; //infos 为字典数组。单个字典内容包括天tltle（label），img（imagename），hl_img（highlightimagename）

-(void)setMenuItemWithTag:(NSInteger)tag enable:(BOOL)enable reverse:(BOOL)reverse;
-(void)setMenuItemWithTag:(NSInteger)tag enable:(BOOL)enable showReverse:(BOOL)showReverse;
-(BOOL)menuItemIsOriginWithTag:(NSInteger)tag;

-(void)resetInfoDict:(NSArray *)arr;

@end
