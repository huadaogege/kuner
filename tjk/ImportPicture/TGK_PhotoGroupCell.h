//
//  TGK_PhotoGroupCell.h
//  tjk
//
//  Created by Ching on 14-9-25.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoClass.h"

@interface TGK_PhotoGroupCell : UITableViewCell

@property(nonatomic,strong) UILabel *PhotoGroupName;
@property(nonatomic,strong) UILabel *photoNumber;
@property(nonatomic,strong) UIImageView *photoImage;
@property(nonatomic,strong) UIImageView *arrowheadImage;
@property(nonatomic,strong) UIImageView *bgIMG;
@property(nonatomic,strong) UIImageView *lineIMG;

@property(nonatomic,assign) int index;

- (void)setGroupPhotoBean:(CustomPhotoGroupBean *)groupBean mediaType:(typeCode)mediaType;

@end
