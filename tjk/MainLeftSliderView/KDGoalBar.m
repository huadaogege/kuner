
#import "KDGoalBar.h"

@implementation KDGoalBar
@synthesize    percentLabel;

#pragma Init & Setup
- (id)init
{
	if ((self = [super init]))
	{
		[self setup];
	}
    
	 return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setup];
	}
    
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setup];
	}
    
	return self;
}


-(void)layoutSubviews {
    CGRect frame = self.frame;
    if (_isPower==123) {
        int percent = percentLayer.percent * 100;
        [percentLabel setText:[NSString stringWithFormat:@"%i%%", percent]];

    }else{
        float percent = percentLayer.percent;
        float total = [[self totalDiskSpace]doubleValue];
        float currentcapacity = total*percent/1024.0/1024.0-220.0;
        if (currentcapacity>1024.0) {
            currentcapacity=currentcapacity/1024.0;
            [percentLabel setText:[NSString stringWithFormat:@"%.2lfG", currentcapacity]];
            NSLog(@"%f",currentcapacity);
            
        }else{
            [percentLabel setText:[NSString stringWithFormat:@"%.0lfM", currentcapacity]];

        }
            }
    CGRect labelFrame = percentLabel.frame;
    labelFrame.origin.x = frame.size.width / 2 - percentLabel.frame.size.width / 2;
    labelFrame.origin.y = frame.size.height / 2 - percentLabel.frame.size.height / 2;
    percentLabel.frame = labelFrame;
    
    [super layoutSubviews];
}
//获取设备的总容量
-(NSNumber *)totalDiskSpace
{
    
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
    
}

-(void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;

    
    percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, 40, 40)];
    [percentLabel setTextColor:[UIColor whiteColor]];
    [percentLabel setBackgroundColor:[UIColor clearColor]];
    percentLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:percentLabel];
    
    thumbLayer = [CALayer layer];
    thumbLayer.contentsScale = [UIScreen mainScreen].scale;
    thumbLayer.contents = (id) thumb.CGImage;
    thumbLayer.frame = CGRectMake(self.frame.size.width / 2 - thumb.size.width/2, 0, thumb.size.width, thumb.size.height);
    thumbLayer.hidden = YES;
    percentLayer = [KDGoalBarPercentLayer layer];
    percentLayer.contentsScale = [UIScreen mainScreen].scale;
    percentLayer.percent = 0;
    percentLayer.frame = self.bounds;
    percentLayer.masksToBounds = NO;
    [percentLayer setNeedsDisplay];
    
    [self.layer addSublayer:percentLayer];
    [self.layer addSublayer:thumbLayer];
    
    
}


#pragma mark - Touch Events
- (void)moveThumbToPosition:(CGFloat)angle {
    CGRect rect = thumbLayer.frame;
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    angle -= (M_PI/2);

    rect.origin.x = center.x + 75 * cosf(angle) - (rect.size.width/2);
    rect.origin.y = center.y + 75 * sinf(angle) - (rect.size.height/2);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    thumbLayer.frame = rect;
    
    [CATransaction commit];
}
#pragma mark - Custom Getters/Setters
- (void)setPercent:(int)percent animated:(BOOL)animated power:(BOOL)ispower {
    if (ispower) {
        [percentLayer isPower:YES];
        _isPower=123;
    }else{
        [percentLayer isPower:NO];
        _isPower=456;
    }
    CGFloat floatPercent = percent / 100.0;
    floatPercent = MIN(1, MAX(0, floatPercent));
    
    percentLayer.percent = floatPercent;
    [self setNeedsLayout];
    [percentLayer setNeedsDisplay];
    
    [self moveThumbToPosition:floatPercent * (2 * M_PI) - (M_PI/2)];
    
}



@end
