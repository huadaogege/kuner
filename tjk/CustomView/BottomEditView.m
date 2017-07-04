//
//  BottomEditView.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "BottomEditView.h"
#import "UIImage+Bundle.h"

@interface BottomEditView ()

@property(nonatomic,retain) NSMutableDictionary* btnImgs;
@property(nonatomic,retain) NSMutableArray* btnLabs;
@property(nonatomic,retain) NSArray* infosCopy;
@end

@implementation BottomEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

-(id)initWithInfos:(NSArray*)infos frame:(CGRect)frame{
    self = [[BottomEditView alloc] initWithFrame:frame];
    if (self) {
        self.backgroundColor = BASE_COLOR;
        CGFloat cellWidth = SCREEN_WIDTH / infos.count;
        self.btnImgs = [NSMutableDictionary dictionary];
        self.btnLabs = [NSMutableArray array];
        if (infos.count > 0) {
            self.infosCopy = [NSArray arrayWithArray:infos];
        }
        for (NSInteger i = 0; i < infos.count; i ++) {
            NSDictionary* dict = [infos objectAtIndex:i];
            UIView* item = [[UIView alloc] initWithFrame:CGRectMake(i * cellWidth, 0, cellWidth, frame.size.height)];
           
            if ([dict objectForKey:@"img"]) {
                CGFloat imgHeight = frame.size.height - 28;
                UIImageView* btnImg = [[UIImageView alloc] initWithFrame:CGRectMake((cellWidth - imgHeight)/2.0f, frame.size.height - 22 - imgHeight, imgHeight, imgHeight)];
                [btnImg setImage:[UIImage imageNamed:[dict objectForKey:@"img"] bundle:@"TAIG_FILE_LIST"]];
                [item addSubview:btnImg];
                [self.btnImgs setObject:btnImg forKey:[NSString stringWithFormat:@"%ld",(long)i]];
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, cellWidth, 18)];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:11];
                label.textColor = [UIColor grayColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [dict objectForKey:@"title"];
                [item addSubview:label];
                [self.btnLabs addObject:label];
            }
            else {
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, frame.size.height)];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:15];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [dict objectForKey:@"title"];
                [item addSubview:label];
                [self.btnLabs addObject:label];
            }
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, cellWidth, frame.size.height);
            btn.tag = ((NSNumber*)[dict objectForKey:@"tag"]).integerValue;
            [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [item addSubview:btn];
            item.tag = i + 100;
            [self addSubview:item];
        }
        
    }
    return self;
}

-(void)setMenuItemWithTag:(NSInteger)tag enable:(BOOL)enable reverse:(BOOL)reverse {
    for (NSInteger i = 0 ; i < self.infosCopy.count; i ++) {
        NSDictionary* info = [self.infosCopy objectAtIndex:i];
        NSNumber* tagNum = [info objectForKey:@"tag"];
        if (tagNum.integerValue == tag) {
            UILabel* label = [self.btnLabs objectAtIndex:i];
            if (reverse && [info objectForKey:@"reverse_title"]) {
                
                label.text = [label.text isEqualToString:[info objectForKey:@"reverse_title"]] ? [info objectForKey:@"title"] : [info objectForKey:@"reverse_title"];
            }
            UIImageView* btnImg = [self.btnImgs objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
            UIView* item = [self viewWithTag:(i + 100)];
            UIButton* btn = (UIButton*)[item viewWithTag:tag];
            btn.hidden = !enable;
            if (enable) {
                label.textColor = [UIColor whiteColor];
                
                if (btnImg) {
                    if (reverse && [info objectForKey:@"reverse_hl_img"]) {
                        [btnImg setImage:[UIImage imageNamed:([label.text isEqualToString:[info objectForKey:@"reverse_title"]] ? [info objectForKey:@"reverse_hl_img"] : [info objectForKey:@"hl_img"]) bundle:@"TAIG_FILE_LIST"]];
                    }
                    else {
                        [btnImg setImage:[UIImage imageNamed:[info objectForKey:@"hl_img"]bundle:@"TAIG_FILE_LIST"]];
                    }
                }
//                NSString* isDelete = [info objectForKey:@"is_delete"];
//                if (isDelete.integerValue == 1) {
//                    item.backgroundColor = MENU_DELETE_RED;
//                }
            }
            else {
                label.textColor = [UIColor grayColor];
                if (btnImg) {
                    if (reverse && [info objectForKey:@"reverse_hl_img"]) {
                        [btnImg setImage:[UIImage imageNamed:([label.text isEqualToString:[info objectForKey:@"reverse_title"]] ? [info objectForKey:@"reverse_img"] : [info objectForKey:@"img"]) bundle:@"TAIG_FILE_LIST"]];
                    }
                    else {
                        [btnImg setImage:[UIImage imageNamed:[info objectForKey:@"img"]bundle:@"TAIG_FILE_LIST"]];
                    }
                }
                item.backgroundColor = BASE_COLOR;
            }
            break;
        }
    }
}

-(void)setMenuItemWithTag:(NSInteger)tag enable:(BOOL)enable showReverse:(BOOL)showReverse{
    for (NSInteger i = 0 ; i < self.infosCopy.count; i ++) {
        NSDictionary* info = [self.infosCopy objectAtIndex:i];
        NSNumber* tagNum = [info objectForKey:@"tag"];
        if (tagNum.integerValue == tag) {
            UILabel* label = [self.btnLabs objectAtIndex:i];
            if (showReverse && [info objectForKey:@"reverse_title"]) {
                label.text = [info objectForKey:@"reverse_title"];
            }
            else {
                label.text = [info objectForKey:@"title"];
            }
            UIImageView* btnImg = [self.btnImgs objectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
            UIView* item = [self viewWithTag:(i + 100)];
            UIButton* btn = (UIButton*)[item viewWithTag:tag];
            btn.hidden = !enable;
            if (enable) {
                label.textColor = [UIColor whiteColor];
                
                if (btnImg) {
                    if (showReverse && [info objectForKey:@"reverse_hl_img"]) {
                        [btnImg setImage:[UIImage imageNamed:([label.text isEqualToString:[info objectForKey:@"reverse_title"]] ? [info objectForKey:@"reverse_hl_img"] : [info objectForKey:@"hl_img"]) bundle:@"TAIG_FILE_LIST"]];
                    }
                    else {
                        [btnImg setImage:[UIImage imageNamed:[info objectForKey:@"hl_img"]bundle:@"TAIG_FILE_LIST"]];
                    }
                }
//                NSString* isDelete = [info objectForKey:@"is_delete"];
//                if (isDelete.integerValue == 1) {
//                    item.backgroundColor = MENU_DELETE_RED;
//                }
            }
            else {
                label.textColor = [UIColor grayColor];
                if (btnImg) {
                    if (showReverse && [info objectForKey:@"reverse_hl_img"]) {
                        [btnImg setImage:[UIImage imageNamed:([label.text isEqualToString:[info objectForKey:@"reverse_title"]] ? [info objectForKey:@"reverse_img"] : [info objectForKey:@"img"]) bundle:@"TAIG_FILE_LIST"]];
                    }
                    else {
                        [btnImg setImage:[UIImage imageNamed:[info objectForKey:@"img"]bundle:@"TAIG_FILE_LIST"]];
                    }
                }
                item.backgroundColor = BASE_COLOR;
            }
            break;
        }
    }
}

-(BOOL)menuItemIsOriginWithTag:(NSInteger)tag {
    for (NSInteger i = 0 ; i < self.infosCopy.count; i ++) {
        NSDictionary* info = [self.infosCopy objectAtIndex:i];
        NSNumber* tagNum = [info objectForKey:@"tag"];
        if (tagNum.integerValue == tag) {
            UILabel* label = [self.btnLabs objectAtIndex:i];
            return [label.text isEqualToString:[info objectForKey:@"title"]];
        }
    }
    return NO;
}

-(void)resetInfoDict:(NSArray *)arr
{
    self.infosCopy = [NSArray arrayWithArray:arr];
}

-(void)btnPressed:(UIButton*)btn{
    if ([self.editDelegate respondsToSelector:@selector(editButtonClickedAt:)]) {
        [self.editDelegate editButtonClickedAt:btn.tag];
    }
}

@end
