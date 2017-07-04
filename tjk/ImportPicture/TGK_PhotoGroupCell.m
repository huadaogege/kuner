//
//  TGK_PhotoGroupCell.m
//  tjk
//
//  Created by Ching on 14-9-25.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "TGK_PhotoGroupCell.h"
#import "UIImage+Bundle.h"


#define XX [UIScreen mainScreen].bounds.size.width / 320.0
@implementation TGK_PhotoGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _index = -1;
        
        _PhotoGroupName = [[UILabel alloc]init];
        _PhotoGroupName.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _PhotoGroupName.frame = CGRectMake(100*XX, 25*XX, 180*XX, 25*XX);
        
        _photoNumber = [[UILabel alloc]init];
        _photoNumber.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        _photoNumber.frame = CGRectMake(100*XX, 55*XX, 70*XX, 15*XX);
        
        _photoImage = [[UIImageView alloc]init];
        _photoImage.contentMode =  UIViewContentModeScaleAspectFill;
        _photoImage.clipsToBounds  = YES;
        _photoImage.frame = CGRectMake(22*XX, 16*XX, 63*XX, 63*XX);
        
        _arrowheadImage = [[UIImageView alloc]init];
        [_arrowheadImage setImage:[UIImage imageNamed:@"list_icon_arrow" bundle:@"TAIG_FILE_LIST"]];
        _arrowheadImage.frame = CGRectMake( 280*XX, 40*XX, 10*XX, 16*XX);
        
        _bgIMG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default_album.png" bundle:@"TAIG_PICTURE.bundle"]];
        _bgIMG.frame = CGRectMake(21*XX, 11*XX, 65*XX, 66*XX);
        
        _lineIMG = [[UIImageView alloc]init];
        _lineIMG.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
        
        [self addSubview:_lineIMG];
        [self addSubview:_bgIMG];
        [self addSubview:_photoNumber];
        [self addSubview:_photoImage];
        [self addSubview:_PhotoGroupName];
        [self addSubview:_arrowheadImage];
    }
    
    return self;
}

- (void)setGroupPhotoBean:(CustomPhotoGroupBean *)groupBean mediaType:(typeCode)mediaType
{
    __weak typeof(self) weakSelf = self;
    [groupBean getIcon:^(UIImage *img) {
        [weakSelf groupSetImg:img Tilte:[groupBean getName] PhotoNum:[NSString stringWithFormat:@"%d",[groupBean getPhotoCount:mediaType]]];
    } withType:mediaType];
}


-(void)groupSetImg:(UIImage *)image Tilte:(NSString *)title PhotoNum:(NSString *)photo
{
    
    _lineIMG.frame = CGRectMake(100*XX, 89*XX,self.bounds.size.width, 1);
    
    //照片数量
    _photoNumber.text = photo;
    
    //照片名字
    _PhotoGroupName.text = title;
    
    //照片
    if (image) {
        [_photoImage setImage:image];
    }else{
        [_photoImage setImage:[UIImage imageNamed:@"list_image-pic-default" bundle:@"TAIG_FILE_LIST"]];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
