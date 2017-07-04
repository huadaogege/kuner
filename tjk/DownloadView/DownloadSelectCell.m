//
//  DownloadSelectCell.m
//  tjk
//
//  Created by huadao on 15/10/13.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "DownloadSelectCell.h"
#import "UIImage+Bundle.h"
#import "DownloadManager.h"

@implementation DownloadSelectCell

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        self.cellBackimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.cellBackimage.image = [UIImage imageNamed:@"" bundle:@""];
        [self.contentView addSubview:self.cellBackimage];
        
        self.backgroundColor = [UIColor whiteColor];
        self.label = [[UILabel alloc]init];
        self.label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:self.label];
        
        self.cellState = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-12*WINDOW_SCALE_SIX
                                                                      , self.frame.size.height-12*WINDOW_SCALE_SIX,
                                                                      12*WINDOW_SCALE_SIX,
                                                                      12*WINDOW_SCALE_SIX)];
        [self.contentView addSubview:self.cellState];
        
    }
    return self;
}

-(void)setbtnState:(int)state style:(int)style{
   
    switch (state) {
        case (IN_STATUS_DOWNING):
            
            self.cellBackimage.image = [UIImage imageNamed:style!=1? @"show_downloading_bg":@"tv_downloading_bg" bundle:@"TAIG_ResourceDownload"];
            self.cellState.image = [UIImage imageNamed:@"download_list_downloading" bundle:@"TAIG_ResourceDownload"];
            self.label.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
            
            break;
        case IN_STATUS_DOWNED:
            self.cellBackimage.image = [UIImage imageNamed:@"" bundle:@"TAIG_ResourceDownload"];
            self.cellState.image = [UIImage imageNamed:@"download_list_downloaded" bundle:@"TAIG_ResourceDownload"];
            self.label.textColor = [UIColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0];
            
            break;
        case IN_STATUS_NONEFONND:
            self.cellBackimage.image = [UIImage imageNamed:@"" bundle:@"TAIG_ResourceDownload"];
            self.cellState.image = [UIImage imageNamed:@"" bundle:@"TAIG_ResourceDownload"];
            self.label.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
            break;
        case IN_STATUS_DOWNLOADMUSIC_SAMENAMEDIFFPATH:
            self.cellBackimage.image = [UIImage imageNamed:@"" bundle:@"TAIG_ResourceDownload"];
            self.cellState.image = [UIImage imageNamed:@"" bundle:@"TAIG_ResourceDownload"];
            self.label.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
            break;
        default:
            break;
    }
}

@end
