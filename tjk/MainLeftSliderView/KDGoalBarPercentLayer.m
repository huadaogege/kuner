

#import "KDGoalBarPercentLayer.h"

#define toRadians(x) ((x)*M_PI / 180.0)
#define toDegrees(x) ((x)*180.0 / M_PI)
#define innerRadius   25
#define outerRadius    33

@implementation KDGoalBarPercentLayer
@synthesize percent;

-(void)isPower:(BOOL)ispower{
    if (ispower) {
        _isPower=123;
    }else{
        _isPower=456;
    }
}

-(void)drawInContext:(CGContextRef)ctx {
    [self DrawRight:ctx isPower:_isPower];
    [self DrawLeft:ctx];
    
}
-(void)DrawRight:(CGContextRef)ctx isPower:(int)ispower {
    CGPoint center = CGPointMake(self.frame.size.width / (2), self.frame.size.height / (2));
    
    CGFloat delta = -toRadians(360 * percent);

    if (ispower==123) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:121.0/255.0 green:185.0/255.0 blue:26.0/255.0 alpha:1.0].CGColor);
    }else if(ispower ==456){
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:43.0/255.0 green:138.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor);
    }
    
    
    CGContextSetLineWidth(ctx, 1);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRelativeArc(path, NULL, center.x, center.y, innerRadius, (M_PI / 2), -delta);
    CGPathAddRelativeArc(path, NULL, center.x, center.y, outerRadius, -delta + (M_PI / 2), delta);
    CGPathAddLineToPoint(path, NULL, center.x, center.y-innerRadius);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    CFRelease(path);
}

-(void)DrawLeft:(CGContextRef)ctx {
    CGPoint center = CGPointMake(self.frame.size.width / (2), self.frame.size.height / (2));
    
    CGFloat delta = toRadians(360 * (1-percent));

    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    CGContextSetLineWidth(ctx, 1);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRelativeArc(path, NULL, center.x, center.y, innerRadius, (M_PI / 2), -delta);
    CGPathAddRelativeArc(path, NULL, center.x, center.y, outerRadius, -delta + (M_PI / 2), delta);
    CGPathAddLineToPoint(path, NULL, center.x, center.y-innerRadius);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    CFRelease(path);
}

@end
