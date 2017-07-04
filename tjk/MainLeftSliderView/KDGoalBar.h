
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KDGoalBarPercentLayer.h"


@interface KDGoalBar : UIView  {
    UIImage * thumb;
    KDGoalBarPercentLayer *percentLayer;
    CALayer *thumbLayer;
    int   _isPower;
          
}

@property (nonatomic, strong) UILabel *percentLabel;

- (void)setPercent:(int)percent animated:(BOOL)animated power:(BOOL)ispower;


@end
