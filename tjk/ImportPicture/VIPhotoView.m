//
//  VIPhotoView.m
//  VIPhotoViewDemo
//

#import "VIPhotoView.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end

@interface VIPhotoView () <UIScrollViewDelegate>

@property (nonatomic) BOOL rotating;
@property (nonatomic) CGSize minSize;

@end

@implementation VIPhotoView


- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollEnabled = NO;
        
        // Add container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Add image view
        if (image) {
            _imageView = [[UIImageView alloc] initWithImage:image];
        }
        else{
            _imageView = [[UIImageView alloc] init];
        }
        
        _imageView.frame = containerView.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:_imageView];
//        [self fitContainerViewWith:_imageView.contentSize];
        
//        [self setMaxMinZoomScale];
//        
//        // Center containerView by set insets
//        [self centerContent];
        [self addSingleTap];
        
        // Setup other events
//        [self setupGestureRecognizer];
//        [self setupRotationNotification];
    }
    
    return self;
}

-(void)setimage:(UIImage *)image
{
    [_imageView removeFromSuperview];
    if (image) {
        _imageView = [[UIImageView alloc] initWithImage:image];
    }
    else{
        _imageView = [[UIImageView alloc] init];
    }
    
    _imageView.frame = _containerView.bounds;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_containerView addSubview:_imageView];
    CGSize imageSize = _imageView.contentSize;
    _doubleTapGesture.enabled = YES;
    [self fitContainerViewWith:imageSize];
    [self setMaxMinZoomScale];
    [self centerContent];
    
    NSLog(@"image size:%@",NSStringFromCGSize(image.size));
    NSLog(@"iamge view size:%@",NSStringFromCGRect(_imageView.frame));
}

-(void)fitContainerViewWith:(CGSize)imageSize
{
    // Fit container view's size to image size
    self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
    
    self.contentSize = imageSize;
    self.minSize = imageSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating) {
        self.rotating = NO;
        
        // update container view frame
        CGSize containerSize = self.containerView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        
        // Center container view
        [self centerContent];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_containerView removeGestureRecognizer:_singleTapGesture];
    [_containerView removeGestureRecognizer:_doubleTapGesture];
    [_containerView removeFromSuperview];
    _containerView = nil;
    [_imageView removeFromSuperview];
    _imageView = nil;
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"handleSingleTap" object:nil];
}

-(void)addSingleTap
{
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_singleTapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:_singleTapGesture];
}

-(void)addTapGesture{
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [_doubleTapGesture setNumberOfTapsRequired:2];
    _doubleTapGesture.enabled = NO;
    [self addGestureRecognizer:_doubleTapGesture];
    [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
}

#pragma mark - UIScrollViewDelegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (self.zoomScale > self.minimumZoomScale) {
        self.scrollEnabled = YES;
    }
    else{
        self.scrollEnabled = NO;
    }
    [self centerContent];
}

#pragma mark - GestureRecognizer

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    if (self.zoomScale > self.minimumZoomScale) {
        self.scrollEnabled = NO;
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        self.scrollEnabled = YES;
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxMinZoomScale
{
//    CGSize imageSize = self.imageView.image.size;
//    CGSize imagePresentationSize = self.imageView.contentSize;
//    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
//    maxScale = maxScale<3?3:maxScale;
    self.maximumZoomScale = 3; // Should not less than 1
    self.minimumZoomScale = 1.0;
}

- (void)centerContent
{
    CGRect frame = self.containerView.frame;
    
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    
    top -= frame.origin.y;
    left -= frame.origin.x;
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    
    
}

@end
