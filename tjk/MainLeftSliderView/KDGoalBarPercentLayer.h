
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface KDGoalBarPercentLayer : CALayer
{
    int  _isPower;
}
@property (nonatomic) CGFloat percent;

-(void)isPower:(BOOL)ispower;
@end
