#import "CustomAlertView.h"


@implementation CustomAlertView

- (id)init
{
    self = [super init];
    if (self) {

        _backWindow = [[UIWindow alloc] init];
        _backWindow.windowLevel = 99;
        _backWindow.frame = [[UIScreen mainScreen] bounds];

        _formsView = [[UIView alloc] init];
        _formsView.backgroundColor = [UIColor clearColor];
        [_backWindow addSubview:_formsView];
        
        _alphaView = [[UIView alloc] init];
        _alphaView.backgroundColor = [UIColor blackColor];
        _alphaView.alpha = 0.4;
        [_formsView addSubview:_alphaView];
        
        _formsMsgLabel = [[UILabel alloc] init];
        _formsMsgLabel.numberOfLines = 3;
        _formsMsgLabel.backgroundColor = [UIColor clearColor];
        [_backWindow addSubview:_formsView];
        
        _progressEmptyView = [[UIView alloc] init];
        _progressEmptyView.backgroundColor = [UIColor clearColor];
        [_formsView addSubview:_progressEmptyView];
        
        _progressFullView = [[UIView alloc] init];
        _progressFullView.backgroundColor = [UIColor clearColor];
        [_formsView addSubview:_progressFullView];

        msg = [[NSString alloc] init];
    }
    return self;
}

-(void) showProgress{
    
    _formsView.frame = CGRectMake(0, 0, 0, 0);
    [_backWindow makeKeyAndVisible];
}

-(void) showMsg{
    
    [_backWindow makeKeyAndVisible];
}

-(void) hidden{
    
}

-(void) setMsg:(NSString *)str{
//    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10] forKey:NSFontAttributeName];
//    CGSize sizeName = [str sizeWithAttributes:attributes];
//    CGSize sizeName = [str sizeWithFont:[UIFont systemFontOfSize:10]
//                    constrainedToSize:_formsMsgLabel.bounds.size
//                            lineBreakMode:NSLineBreakByWordWrapping];
    _formsMsgLabel.text = str;
}

-(void) setFilesCount:(int)allCount{
    
}

-(void) setNowNum:(int)num{
    
}

//- (void) progressAction:(NSString *)title message:(NSString *)msg nowNumber:(float)nowNum allCount:(float)allCount progress:(float)pro{
//
//    if(pro > 1.0){
//        pro = 1.0;
//    }
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        _blueView.layer.cornerRadius = 4.0;
//        _blueView.frame = CGRectMake(_grayView.frame.origin.x,
//                                     _grayView.frame.origin.y,
//                                     _grayView.bounds.size.width * pro,
//                                     _grayView.frame.size.height);
//    }];
//    
//    if(nowNum >= 0 && allCount >= 0){
//        _pickLable.text = [NSString stringWithFormat:@"%@%@%@  %d/%d",
//                           NSLocalizedString(@"now", @"正在"),
//                           [self getActionStr:action],
//                           [self getMoldStr:mold],
//                           (int)nowNum,
//                           (int)allCount];
//        
//        if (nowNum == allCount) {
//
//            [self removeTheFormatView];
//        }else{
//            
//            _window.alpha = 1.0;
//            _window.hidden = NO;
//        }
//    }
//}

@end