//
//  MusicListVC.h
//  tjk
//
//  Created by Youqs on 15/5/29.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListVC : UIViewController

@property(nonatomic,strong) NSMutableArray *musicList;


-(void)doReloadTable;
@end
