//
//  VIPhotoView.h
//  VIPhotoViewDemo
//

#import <UIKit/UIKit.h>

@interface VIPhotoView : UIScrollView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
-(void)addTapGesture;
-(void)setimage:(UIImage *)image;

@end
