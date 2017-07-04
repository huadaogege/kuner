//
//  HomeCell.m
//  CollectionDemo
//
//  Created by liguiyang on 14-9-2.
//  Copyright (c) 2014年 lgy. All rights reserved.
//

#import "HomeCell.h"
#import "UIImage+Bundle.h"
#import "CustomFileManage.h"
#import "FilterLoading.h"

#define THE_PATH @"thePath"

#define Width_scale [[UIScreen mainScreen] currentMode].size.width * 3


@implementation HomeCell{
    
    UIImage             *_image;
    UILabel             *_PicName;
    UIView              *_PickBack;
    NSMutableArray      *_GCDArray;
    dispatch_queue_t    _dispatchQueue;
    NSMutableDictionary *_infoMap;
    NSMutableDictionary *_beanMap;
    UIGestureRecognizer *_gesture;
    BOOL                _doDouble;
    UITapGestureRecognizer *singleRecognizerImg;
    UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *singleRecognizerOl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _GCDArray = [[NSMutableArray alloc]init];
        
//        _PicName = [[UILabel alloc]init];
//        //        _PicName.alpha = 0.5;
//        _PicName.font = [UIFont systemFontOfSize:20];
//        _PicName.backgroundColor = [UIColor clearColor];
//        [_PicName setNumberOfLines:0];
//        //        _PicName.textColor = [UIColor redColor];
//        _PicName.hidden = YES;
//        _PicName.frame = CGRectMake(0,  self.frame.size.height-100, self.frame.size.width, 100);
        
        //        _PickBack = [[UIView alloc]init];
        //        _PickBack.frame = _PicName.bounds;
        //        _PickBack.backgroundColor = [UIColor grayColor];
        //        _PickBack.alpha = 0.5;
        //        _PickBack.hidden = YES;
        
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:60];
        [self addSubview:label];
        self.textLabel = label;
        
        
        _infoMap = [[NSMutableDictionary alloc]init];
        _beanMap = [[NSMutableDictionary alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needData:) name:@"needData" object:nil];
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _playBtn.frame = CGRectMake((self.bounds.size.width-70)/2.0, (self.bounds.size.height-70)/2.0, 70, 70);
        _playBtn.backgroundColor =[UIColor clearColor];
        
        _playBenBack = [[UIImageView alloc]init];
        _playBenBack.frame = _playBtn.frame;
        _playBenBack.image = [UIImage imageNamed:@"list_image-videoplay.png" bundle:@"TAIG_FILE_LIST.bundle"];
        
        _olImageView = [[OLImageView alloc]init];
        _olImageView.userInteractionEnabled = YES;
        _olImageView.contentMode = UIViewContentModeScaleAspectFit;
        _olImageView.frame = self.bounds;
        //        [self addSubview:_olImageView];
        
        
//        self.imageView = [[UIImageView alloc]init];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.backgroundColor = [UIColor clearColor];
//        _imageView.userInteractionEnabled = YES;
//        
//        self.scrollview = [[UIScrollView alloc]init];
//        _scrollview.backgroundColor = [UIColor clearColor];
//        [_scrollview setZoomScale:1.0];
//        _scrollview.minimumZoomScale = 1.0;
//        _scrollview.maximumZoomScale = 2.0;
//        _scrollview.delegate = self;
//        _scrollview.bouncesZoom = YES;
//        //        _scrollview.translatesAutoresizingMaskIntoConstraints = NO;
//        //        _imageView .translatesAutoresizingMaskIntoConstraints = NO;
//        //        _scrollview.contentInset = UIEdgeInsetsMake(5, 10, 20, 40);
//        _scrollview.frame = self.bounds;
//        _scrollview.contentSize =_imageView.image.size;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_scrollview addSubview:self.imageView];
//            
//        });
//        
//        [self addSubview:_scrollview];
        
        _photoView = [[VIPhotoView alloc] initWithFrame:self.bounds andImage:[UIImage imageNamed:@"image_loading.png" bundle:@"TAIG_PICTURE.bundle"]];
        _photoView.autoresizingMask = (1 << 6) -1;
        
        [self addSubview:_photoView];
        
        
//        UIView *chingView = [[UIView alloc]init];
//        chingView.frame = CGRectMake(0, 0, 120*WINDOW_SCALE, 100*WINDOW_SCALE);
//        chingView.backgroundColor = [UIColor blackColor];
//        chingView.alpha = 0.4;
//        chingView.layer.masksToBounds = YES;
//        chingView.layer.cornerRadius = 4.0;
        
        
//        UILabel *jiaZai = [[UILabel alloc]init];
//        jiaZai.frame = CGRectMake(0, 0, chingView.bounds.size.width, 30*WINDOW_SCALE);
////        jiaZai.text = @"加载中....";
//        jiaZai.textColor = [UIColor whiteColor];
//        jiaZai.textAlignment = NSTextAlignmentCenter;
//        [jiaZai setCenter:CGPointMake(chingView.bounds.size.width/2, chingView.bounds.size.height/2+20*WINDOW_SCALE)];
        
//        _activityIndicatorView = [[UIActivityIndicatorView alloc]init];
//        [_activityIndicatorView setCenter:CGPointMake(chingView.bounds.size.width/2, chingView.bounds.size.height/2-10*WINDOW_SCALE)];
//        [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        [_activityIndicatorView startAnimating];
        
        _dispatchQueue  = dispatch_queue_create("HomeCell", DISPATCH_QUEUE_SERIAL);
        
        self.gifScrollview = [[UIScrollView alloc]init];
        self.gifScrollview.backgroundColor = [UIColor clearColor];
        [self.gifScrollview setZoomScale:1.0];
        self.gifScrollview.delegate = self;
        self.gifScrollview.bouncesZoom = YES;
        self.gifScrollview.frame = self.bounds;
        self.gifScrollview.contentSize =_olImageView.image.size;
        [self.gifScrollview addSubview:_olImageView];
        [self addSubview:self.gifScrollview];
        
        
        
        //添加手势
//        singleRecognizerImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//        [doubleTapGesture setNumberOfTapsRequired:1];
//        [self.imageView addGestureRecognizer:singleRecognizerImg];
        
        
        singleRecognizerOl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_olImageView addGestureRecognizer:singleRecognizerOl];
        _doDouble = NO;
        
    }
    return self;
}

-(void)addPhotoView:(BOOL)isnotReloadData
{
    UIImage *img = [UIImage imageNamed:@"image_loading.png" bundle:@"TAIG_PICTURE.bundle"];
    NSInteger tag;
    if (_photoView) {
        if (isnotReloadData) {
            img = _photoView.imageView.image;
            tag = _photoView.imageView.tag;
        }
        else{
            _photoView.imageView.image = nil;
        }
        if (_photoView.superview) {
            [_photoView removeFromSuperview];
        }
        _photoView = nil;
    }
    _photoView = [[VIPhotoView alloc] initWithFrame:self.bounds andImage:img];
    _photoView.autoresizingMask = (1 << 6) -1;
    if (isnotReloadData) {
        [_photoView setimage:img];
    }
    _photoView.imageView.tag = tag;
    
    [self insertSubview:_photoView belowSubview:self.gifScrollview];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"handleSingleTap" object:nil];
}

-(void)addTapGesture{
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:doubleTapGesture];
    [singleRecognizerImg requireGestureRecognizerToFail:doubleTapGesture];
}
//双击手势方法
#pragma mark -
-(void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    _doDouble = !_doDouble;
    if (_doDouble) {
        float newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 2.0;
        CGRect zoomRect = [self zoomRectForScale:newScale  inView:(UIScrollView*)gesture.view.superview withCenter:[gesture locationInView:gesture.view]isChang:_doDouble];
        [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
    }else{
        float newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 1.0;
        CGRect zoomRect = [self zoomRectForScale:newScale  inView:(UIScrollView*)gesture.view.superview withCenter:[gesture locationInView:gesture.view]isChang:_doDouble];
        [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
    }
    
}

#pragma mark - Utility methods

- (CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center isChang:(BOOL)change {
    CGRect zoomRect;
    
    
    if (change) {
        zoomRect.size.height = [scrollView frame].size.height / scale;
        zoomRect.size.width  = [scrollView frame].size.width  / scale;
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    }else{
        zoomRect.size.height = [scrollView frame].size.height ;
        zoomRect.size.width  = [scrollView frame].size.width  ;
        zoomRect.origin.x    = center.x ;
        zoomRect.origin.y    = center.y ;
    }
    
    return zoomRect;
}


-(void)dealloc{
    
    NSLog(@"home cell dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
//    [self.imageView removeGestureRecognizer:singleRecognizerImg];
//    [self.imageView removeGestureRecognizer:doubleTapGesture];
    [_olImageView removeGestureRecognizer:singleRecognizerOl];
    if (_dispatchQueue) {
        dispatch_object_t _o = (_dispatchQueue);
        _dispatch_object_validate(_o);
        _dispatchQueue = NULL;
    }
    
}

//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    //    [scrollView setZoomScale:scale+0.01 animated:NO];
//    //    [scrollView setZoomScale:scale animated:NO];
//    //    if (scrollView.contentSize.height > self.imageView.image.size.height) {
//    
//    if ([UIScreen mainScreen].bounds.size.width / self.imageView.image.size.width * self.imageView.image.size.height <= [UIScreen mainScreen].bounds.size.height / 2) {
//        [UIView animateWithDuration:0.5 animations:^{
////            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, self.frame.size.height);
//            self.imageView.center = CGPointMake(self.imageView.center.x, scrollView.contentSize.height/2);
//        }];
//        
//    }else{
//        [UIView animateWithDuration:0.5 animations:^{
//            self.imageView.center = CGPointMake(scrollView.contentSize.width/2, scrollView.contentSize.height/2);
//        }];
//    }
//}
//
//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    //    return _imageView;
//    //    for (UIView *v in scrollView.subviews){
//    //        return v;
//    //    }
//    //    return nil;
//    return _imageView;
//}
//-(void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    FileBean *bean = [_beanMap objectForKey:THE_PATH];
//    if ([bean getFileType] != FILE_MOV) {
//        CGFloat centerX = self.imageView.center.x;
//        CGFloat centerY = self.imageView.center.y;
//        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
//        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
//        self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
//        if (centerX != self.imageView.center.x &&centerY != self.imageView.center.y) {
//            _doDouble = YES;
//        }
//    }
//    
//    
//}

-(void)layoutSubviews
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.textLabel.frame = self.bounds;
        
    });
}
//************************************************************************************************************
//************************************************************************************************************

-(void)loadingPhotoFinishWith:(NSMutableDictionary *)dict
{
    if ([[_infoMap objectForKey:THE_PATH]isEqualToString:[[dict objectForKey:@"url"]getFilePath] ]) {
        NSData  *keData = nil;
        
        FileBean *bean = [dict objectForKey:@"url"];
        keData = [dict objectForKey:@"data"];
        if ([bean getFileType] == FILE_GIF) {
            if (keData) {
                
                //                self.scrollview.hidden = YES;
                self.photoView.hidden = YES;
                self.gifScrollview.hidden = NO;
                [self addGif:keData];
                
            }else{
                [self keImage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"] Hidden:YES];
                
            }
        }else if ([bean getFileType] == FILE_MOV){
            
        }else{
            UIImage *image = [UIImage imageWithData:keData];
            if (image) {
                
                if (image.size.height / image.size.width >= [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width) {
                    
                    //                float nowWidth = [UIScreen mainScreen].bounds.size.width / image.size.width;
                    //                cell.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, image.size.height*nowWidth);
                    float nowWidth = [UIScreen mainScreen].bounds.size.height / image.size.height;
                    //                    self.imageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - image.size.width*nowWidth)/2, 0, image.size.width*nowWidth , [UIScreen mainScreen].bounds.size.height);
                    self.photoView.containerView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - image.size.width*nowWidth)/2, 0, image.size.width*nowWidth , [UIScreen mainScreen].bounds.size.height);
                    self.photoView.imageView.frame = self.photoView.containerView.bounds;
                    
                }
                CGFloat ff = [[UIScreen mainScreen] currentMode].size.width;
                if(image.size.width > ff*5.1 ){
                    int ww = ff*5.1;
                    int hh = image.size.height / image.size.width * ww;
                    UIGraphicsBeginImageContext(CGSizeMake(ww, hh));
                    [image drawInRect:CGRectMake(0, 0, ww, hh)];
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                [self setimage:image ];
                
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self keImage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"] Hidden:YES];
                });
            }
            
            
        }
        
    }
}

-(void)needData:(NSNotification *)nito{
    if ([[_infoMap objectForKey:THE_PATH]isEqualToString:[[nito.object objectForKey:@"url"]getFilePath] ]) {
        NSData  *keData = nil;
        
        FileBean *bean = [nito.object objectForKey:@"url"];
        keData = [[FilterLoading instance] getDataWith:bean.filePath];//[nito.object objectForKey:@"data"];
        if ([bean getFileType] == FILE_GIF) {
            if (keData) {
                
//                self.scrollview.hidden = YES;
                self.photoView.hidden = YES;
                self.gifScrollview.hidden = NO;
                [self addGif:keData];
                
            }else{
                [self keImage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"] Hidden:YES];
                
            }
        }else if ([bean getFileType] == FILE_MOV){
            
        }else{
            UIImage *image = [UIImage imageWithData:keData];
            if (image) {
                
                if (image.size.height / image.size.width >= [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width) {
                    
                    //                float nowWidth = [UIScreen mainScreen].bounds.size.width / image.size.width;
                    //                cell.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, image.size.height*nowWidth);
                    float nowWidth = [UIScreen mainScreen].bounds.size.height / image.size.height;
//                    self.imageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - image.size.width*nowWidth)/2, 0, image.size.width*nowWidth , [UIScreen mainScreen].bounds.size.height);
                    self.photoView.containerView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - image.size.width*nowWidth)/2, 0, image.size.width*nowWidth , [UIScreen mainScreen].bounds.size.height);
                    self.photoView.imageView.frame = self.photoView.containerView.bounds;
                    
                }
                CGFloat ff = [[UIScreen mainScreen] currentMode].size.width;
                if(image.size.width > ff*5.1 ){
                    int ww = ff*5.1;
                    int hh = image.size.height / image.size.width * ww;
                    UIGraphicsBeginImageContext(CGSizeMake(ww, hh));
                    [image drawInRect:CGRectMake(0, 0, ww, hh)];
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                
                NSLog(@"home cell setimage");
                if (_photoView && _photoView.imageView) {
                    [self setimage:image ];
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self keImage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"] Hidden:YES];
                });
            }
            
            
        }
        
    }
    
}
//************************************************************************************************************
-(void)BigPictor:(FileBean *)bean {
    _doDouble = NO;
    [_infoMap setObject:[bean getFilePath] forKey:THE_PATH];
    [_beanMap setObject:bean forKey:THE_PATH];
    if ([bean getFileType] == FILE_MOV) {
        _photoView.maximumZoomScale = 1.0;
//       _scrollview.maximumZoomScale = 1.0; 
    }else{
        _photoView.maximumZoomScale = 3.0;
//        _scrollview.maximumZoomScale = 2.0;
    }
    
    
}
-(void)addGif:(NSData*)data{
        dispatch_async(dispatch_get_main_queue(), ^{
    _olImageView.image = [OLImage imageWithData:data];
        });
    
}
-(void)keImage:(UIImage *)img Hidden:(BOOL)hid{
    return;
    CGRect rect;
    if (img.size.height / img.size.width > [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width) {
        
        rect = CGRectMake(0,
                          0,
                          [UIScreen mainScreen].bounds.size.width,
                          img.size.height*[UIScreen mainScreen].bounds.size.width / img.size.width);
        
    }else{
        
        rect = self.bounds;
    }
    //    CGFloat ff = [[UIScreen mainScreen] currentMode].size.width;
    
    
    if(img.size.width > self.imageView.bounds.size.width ){
        
        int ww = self.photoView.bounds.size.width ;
        int hh = img.size.height / img.size.width * ww;
        UIGraphicsBeginImageContext(CGSizeMake(ww, hh));
        [img drawInRect:CGRectMake(0, 0, ww, hh)];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.frame = rect;
        [self.imageView setImage:img];
    });
}

-(void)setVideoImg:(UIImage *)img{
    
}
-(void)setimage:(UIImage *)img
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        _scrollview.contentSize =_imageView.image.size;
        
        if(img){
//            [self.imageView setImage:img];
            [self.photoView setimage:img];
            self.photoView.imageView.tag = HOMECELL_GET_IMAGE;
        }else{
//            [self.imageView setImage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"]];
            [self.photoView setimage:[UIImage imageNamed:@"default_imagedamage.png" bundle:@"TAIG_PICTURE.bundle"]];
        }
    });
}
-(void)addTheGif:(UIImage *)img
{
    _olImageView.image = img;
    
}

-(void)addPlayBtn
{
    _playBtn.hidden = NO;
    _playBenBack.hidden = NO;
    [self addSubview:_playBenBack];
    [self addSubview:_playBtn];
}
-(void)hiddenBtnAndBackView
{
    _playBtn.hidden = YES;
    _playBenBack.hidden = YES;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
