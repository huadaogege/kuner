//
//  PhotoLineCell.m
//  tjk
//
//  Created by lengyue on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PhotoLineCell.h"
#import "PhotoItemCell.h"

@interface PhotoLineCell ()
@property(nonatomic,retain) NSMutableArray* itemCellArr;
@property(nonatomic,retain) NSMutableArray* itemModelArr;
@end

@implementation PhotoLineCell

-(void)setData:(NSArray*)aData selectedStatus:(NSArray*)selectedArr row:(NSInteger)row needLoadIcon:(BOOL)need{
    if (!self.itemModelArr) {
        self.itemModelArr = [NSMutableArray array];
        if (aData.count > 0) {
            FileBean* model = [aData objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopCacheIconRequest)  name:[model.filePath stringByDeletingLastPathComponent] object:nil];
        }
    }
    [self.itemModelArr removeAllObjects];
    [self.itemModelArr addObjectsFromArray:aData];
    CGFloat cellHeight = (SCREEN_WIDTH-10)/4.0 + 2;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH, (SCREEN_WIDTH-20)/4.0 + 4);
    if (!self.itemCellArr) {
        self.itemCellArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 4; i ++) {
            PhotoItemCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"PhotoItemCell" owner:nil options:nil] objectAtIndex:0];
            cell.frame = CGRectMake(i * cellHeight + 2, 1, (SCREEN_WIDTH-10)/4.0, (SCREEN_WIDTH-10)/4.0);
            if (i < aData.count) {
                cell.hidden = NO;
                NSNumber* selected = [selectedArr objectAtIndex:i];
                [cell setSelected:selected.boolValue];
                [cell setData:[aData objectAtIndex:i] index:(row * 4 + i) needLoadIcon:need];
            }
            else {
                cell.hidden = YES;
                [cell setSelected:NO];
            }
            
            cell.itemSelectDelegate = self.itemSelectDelegate;
            [self.itemCellArr addObject:cell];
            [self addSubview:cell];
        }
    }
    else {
        for (NSInteger i = 0; i < 4; i ++) {
            PhotoItemCell* cell = [self.itemCellArr objectAtIndex:i];
            if (i < aData.count) {
                cell.hidden = NO;
                NSNumber* selected = [selectedArr objectAtIndex:i];
                [cell setSelected:selected.boolValue];
                [cell setData:[aData objectAtIndex:i] index:(row * 4 + i) needLoadIcon:need];
            }
            else {
                cell.hidden = YES;
                [cell setSelected:NO];
            }
            cell.itemSelectDelegate = self.itemSelectDelegate;
//            [self addSubview:cell];
        }
    }
}
-(void)setNewIdentify:(BOOL)previewed{
    
    
}
-(void)setEditStatus:(NSInteger)editStatusType {
    for (NSInteger i = 0; i < 4; i ++) {
        PhotoItemCell* cell = [self.itemCellArr objectAtIndex:i];
        if (editStatusType == Edit_Export) {
            if (i < self.itemModelArr.count) {
                FileBean* bean = [self.itemModelArr objectAtIndex:i];
                if (bean.fileType == FILE_GIF || bean.fileType == FILE_IMG || bean.fileType == FILE_MOV) {
                    [cell setEditStatus:Edit_Export isExport:YES];
                }
                else {
                    [cell setEditStatus:Edit_None isExport:YES];
                }
            }
            else {
                [cell setEditStatus:Edit_None isExport:YES];
            }
        }
        else {
            [cell setEditStatus:editStatusType isExport:NO];
        }
        
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:NO];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:NO];
}

-(void)resetContent {
    [self.itemModelArr removeAllObjects];
    for (PhotoItemCell* cell in self.itemCellArr) {
        [cell removeFromSuperview];
    }
    [self.itemCellArr removeAllObjects];
}

-(void)stopCacheIconRequest {
    for (PhotoItemCell* cell in self.itemCellArr) {
        [cell stopCacheIconRequest];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.itemModelArr removeAllObjects];
    for (PhotoItemCell* cell in self.itemCellArr) {
        [cell removeFromSuperview];
    }
    [self.itemCellArr removeAllObjects];
}

@end
