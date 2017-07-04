//
//  PhotoCellView.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14-7-2.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "PhotoCellView.h"
#import "UIImage+Bundle.h"

#define PATH @"photoPath"
#define VIDEO_TIME @"videoTime"

@implementation PhotoCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cellType = PhotoCellTypeNormal;
        
        _clickImgV = [[UIImageView alloc]init];
        _clickImgV.frame = CGRectMake(frame.size.width - 22 - 3, frame.size.width - 22 - 3, 22, 22);
        [_clickImgV setImage:[UIImage imageNamed:@"list_btn-selected.png" bundle:@"TAIG_FILE_LIST.bundle"]];
        
        _infoMap = [[NSMutableDictionary alloc] init];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"list_image-pic-default" bundle:@"TAIG_FILE_LIST.bundle"];
        _imageView.contentMode =  UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
        _imageView.clipsToBounds  = YES;
        
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = [UIColor whiteColor];
        _selectView.alpha = 0;
        [_imageView addSubview:_selectView];
        
        _imgView = [[UIImageView alloc]init];
        
        _coverImgView = [[UIImageView alloc]init];
        
        _PicName = [[UILabel alloc]init];
        _PicName.font = [UIFont systemFontOfSize:10];
        _PicName.backgroundColor = [UIColor clearColor];
        [_PicName setNumberOfLines:0];
        _PicName.textColor = [UIColor redColor];
        _PicName.hidden = YES;
        _PicName.frame = CGRectMake(0, 0, self.frame.size.width, 40);
        
        _PickBack = [[UIView alloc]init];
        _PickBack.frame = _PicName.bounds;
        _PickBack.backgroundColor = [UIColor grayColor];
        _PickBack.alpha = 0.5;
        _PickBack.hidden = YES;
        
        _photoName = [[UILabel alloc]init];
        _photoName.font = [UIFont systemFontOfSize:12];
        _photoName.backgroundColor = [UIColor clearColor];
        [_photoName setNumberOfLines:0];
        _photoName.textAlignment = NSTextAlignmentCenter;
        
        _photoNum = [[UILabel alloc]init];
        _photoNum.font = [UIFont systemFontOfSize:14];
        _photoNum.textAlignment = NSTextAlignmentCenter;
        _photoNum.backgroundColor = [UIColor clearColor];
        _photoNum.textColor = [UIColor whiteColor];
        
        _videoBackView = [[UIView alloc]init];
        _videoBackView.backgroundColor = [UIColor blackColor];
        _videoBackView.alpha = 0.7;
        _videoBackView.frame = CGRectMake(0, self.bounds.size.height-18, self.bounds.size.width, 18);

        _videoSginImg = [[UIImageView alloc]init];
        _videoSginImg.frame = CGRectMake(5, self.bounds.size.height-15, 20, 12);
        _videoSginImg.image = [UIImage imageNamed:@"icon_tag_video.png" bundle:@"TAIG_PICTURE.bundle"];
        
        _gifSginImg = [[UIImageView alloc]init];
        _gifSginImg.frame = CGRectMake(self.bounds.size.width-25, 5, 20, 10);
        _gifSginImg.image = [UIImage imageNamed:@"icon_tag_gif.png" bundle:@"TAIG_PICTURE.bundle"];
        
        self.videoTimeLab = [[UILabel alloc]init];
        self.videoTimeLab.textColor = [UIColor whiteColor];
        self.videoTimeLab.font = [UIFont systemFontOfSize:10];
        self.videoTimeLab.textAlignment = NSTextAlignmentRight;
        self.videoTimeLab.frame = CGRectMake(self.bounds.size.width-45, self.bounds.size.height-15, 40, 12);
        [self addSubview:_imageView];
        [_selectView addSubview:_imgView];
        _gifSginImg.hidden = YES;
        [self addSubview:_gifSginImg];
        
        
        _videoBackView.hidden = YES;
        _videoSginImg.hidden = YES;
        _videoTimeLab.hidden = YES;
        
        vodeoImg = [[UIImageView alloc]init];
        [vodeoImg setImage:[UIImage imageNamed:@"video_play.png" bundle:@"TAIG_PICTURE.bundle"]];
        vodeoImg.frame = CGRectMake(((SCREEN_WIDTH-15*WINDOW_SCALE_SIX)/4 -40*WINDOW_SCALE_SIX)/2, ((SCREEN_WIDTH-15*WINDOW_SCALE_SIX)/4 -40*WINDOW_SCALE_SIX)/2, 40*WINDOW_SCALE_SIX, 40*WINDOW_SCALE_SIX);
        vodeoImg.hidden = YES;
        
        [self addSubview:_videoBackView];
        [self addSubview:_videoSginImg];
        [self addSubview:self.videoTimeLab];
        [self addSubview:_clickImgV];
        [self addSubview:vodeoImg];
    }
    return self;
}
-(void)SetPhotoName:(NSString*)picName{
    [self addSubview:_PickBack];
    [self addSubview:_PicName];
    _PicName.hidden = NO;
    _PickBack.hidden = NO;
    _PicName.text = picName;
}

-(void)gifSgin{
    _gifSginImg.hidden = NO;
}
-(void)VideoTime:(NSString*)videoTitle
{
    self.videoTimeLab.text = videoTitle;
    
}
-(void)videoImg{
     vodeoImg.hidden = NO;
}

-(void)videoHidden:(BOOL)hidd
{
    vodeoImg.hidden = hidd;
    _videoBackView.hidden = hidd;
    _videoSginImg.hidden = hidd;
    _videoTimeLab.hidden = hidd;
}
-(void)setImg:(UIImage *)img{
    
    _imageView.image = img;
    
}

-(void)setPhoneImg:(UIImage *)img{
    
    if (img) {
        _imageView.image = img;
    }else{
    _imageView.image = [UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"];
    }
    
    
}

-(UIImage *)getImg{
    return _imageView.image;
}

-(void)setImgValue:(NSDictionary *)dic MovRoOther:(NSString*)isMov{

    if ([dic objectForKey:@"img"]) {
       [self setImg:[dic objectForKey:@"img"]];
    }else{
        if ([isMov isEqual:@"mov"]) {
            
            [self setImg:[UIImage imageNamed:@"video_default.png" bundle:@"TAIG_PICTURE.bundle"]];
            
        }else{
            
            [self setImg:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"]];

        }
    }
    
}

-(void)layoutSubviews{
    
    _imageView.frame = self.bounds;
    _selectView.frame = self.bounds;
    _imgView.frame = self.bounds;

}
-(void)theClickImgHidden:(BOOL)isClick{
    _clickImgV.hidden = isClick;
}
-(void)isSelect:(BOOL)isSelect{
    [UIView animateWithDuration:0.3 animations:^{
        if(isSelect){
            UIImage *img = (_cellType==PhotoCellTypeNormal)?[UIImage imageNamed:@"list_btn-selected.png" bundle:@"TAIG_FILE_LIST.bundle"]:[UIImage imageNamed:@"selected" bundle:@"TAIG_125.bundle"];
            
            [_clickImgV setImage:img];
            _selectView.alpha = 0.25;
        }
        else
        {
            UIImage *img = (_cellType==PhotoCellTypeNormal)?nil:[UIImage imageNamed:@"itemUnselected" bundle:@"TAIG_125.bundle"];
            
            _selectView.alpha = 0.0;
            [_clickImgV setImage:img];
        }
    }];
}
-(void)changeIsSelect:(BOOL)isSelect{
    if(isSelect){
        
        UIImage *img = (_cellType==PhotoCellTypeNormal)?[UIImage imageNamed:@"list_btn-selected.png" bundle:@"TAIG_FILE_LIST.bundle"]:[UIImage imageNamed:@"selected" bundle:@"TAIG_125.bundle"];
        
        _selectView.alpha = 0.25;
        [_clickImgV setImage:img];
    }
    else
    {
        UIImage *img = (_cellType==PhotoCellTypeNormal)?nil:[UIImage imageNamed:@"itemUnselected" bundle:@"TAIG_125.bundle"];
        
        _selectView.alpha = 0.0;
        [_clickImgV setImage:img];
    }
}
#pragma mark- 视频时间显示

- (NSString *)Video:(NSString*)timeStr
{
    NSString *senStr;
    NSString *minStr;
    NSString *hourStr;
    NSString *videoTime;
    
    int time = [timeStr intValue];
    int iHour = time/3600;
    int iMin =( time-iHour*3600)/60;
    int iSen = time-iHour*3600-iMin*60;
    if (iSen < 10) {
        senStr = [NSString stringWithFormat:@"0%d",iSen];
    }else{
        senStr = [NSString stringWithFormat:@"%d",iSen];
    }
    if (iMin < 10) {
        minStr = [NSString stringWithFormat:@"0%d",iMin];
    }else{
        minStr = [NSString stringWithFormat:@"%d",iMin];
    }
    if (iHour < 10) {
        hourStr = [NSString stringWithFormat:@"0%d",iHour];
    }else{
        hourStr = [NSString stringWithFormat:@"%d",iHour];
    }
    
    if (iHour == 0) {
        videoTime = [NSString stringWithFormat:@"%@:%@",minStr,senStr];
    }else
    {
        videoTime = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minStr,senStr];
    }
    return videoTime;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - UICollectionDateViewCell

@interface UICollectionDateViewCell (){
    UILabel   *_dateLab;   // 时间
    UIButton  *_selectBtn; // 选择按钮
    
    BOOL       _isSelected; // 是否选中标记
    CGSize     _imgSize;    // 按钮图片尺寸
    
    ClickBlock _clickBlock; // 点击事件Block
}

@end

@implementation UICollectionDateViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.backgroundColor = [UIColor clearColor];
        _dateLab.numberOfLines = 2;
        
        UIImage *selectedImg = [UIImage imageNamed:@"selected" bundle:@"TAIG_125.bundle"];
        UIImage *unselectedImg = [UIImage imageNamed:@"unselected" bundle:@"TAIG_125.bundle"];
        _imgSize = selectedImg.size;
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:unselectedImg forState:UIControlStateNormal];
        [_selectBtn setImage:selectedImg forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_dateLab];
        [self.contentView addSubview:_selectBtn];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width  = self.bounds.size.width;
    
    _dateLab.frame = CGRectMake(0, 0, width, 16+9+8+5);
    _selectBtn.frame = CGRectMake((width-_imgSize.width*0.5)*0.5, _dateLab.frame.origin.y+_dateLab.frame.size.height+10, _imgSize.width*0.5, _imgSize.height*0.5);
}

#pragma mark Interfaces

- (void)setDateAttributedContent:(NSAttributedString *)dateStr
{
    _dateLab.attributedText = dateStr;
}

- (void)setDateSelectedFlag:(BOOL)selected
{
    _selectBtn.selected = selected;
}

- (void)setDateClickBlock:(ClickBlock)clickBlock
{
    if (clickBlock) {
        _clickBlock = clickBlock;
    }
}

#pragma mark private methods

- (void)selectBtnClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    NSInteger tag = self.tag;
    
    if (_clickBlock) {
        _clickBlock(tag,btn.selected);
    }
}

@end


