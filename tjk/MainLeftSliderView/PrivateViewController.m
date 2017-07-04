//
//  PrivateViewController.m
//  tjk
//
//  Created by lengyue on 15/4/17.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import "PrivateViewController.h"
#import "CustomNavigationBar.h"

@interface PrivateViewController ()<NavBarDelegate>{
    CustomNavigationBar          *_customNavigationBar;
}

@end

@implementation PrivateViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = [self getTitle];
    _customNavigationBar.rightBtn.hidden = YES;
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    [self.view addSubview:_customNavigationBar];
    
    UITextView *textView = [[UITextView alloc]init];
    textView.editable = NO;
    textView.selectable = NO;
    textView.frame = CGRectMake(8, 64 - barOffsetY, SCREEN_WIDTH - 12, SCREEN_HEIGHT - (64 - barOffsetY));
    textView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:textView];
    
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.text = [self getDiscriptionString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility

- (NSString *)getTitle
{
    return (_discType==DiscriptionTypePrivacyNote)?NSLocalizedString(@"privatel", @""):NSLocalizedString(@"kukedisc", @"");
}

- (NSString *)getDiscriptionString
{// 外语不显示“隐私说明”（隐私说用目前只有中英文，英文不显示）
    // 酷壳说说明支持多语言
    NSError * error;
    NSString *fileName = @"";
    
    switch (_discType) {
        case DiscriptionTypePrivacyNote:{
            if ([FileSystem isChinaLan]) {
                fileName = @"chPrivate";
            }
            else if ([FileSystem isCzechLanguage]){
                fileName = @"csPrivate";
            }
            else
            {
                fileName = @"enPrivate";
            }
        }
            break;
        case DiscriptionTypeKUKEDisc:{
            fileName = @"keDisconnectExplain";
        }
            break;
        default:
            break;
    }
    
    NSString *text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    
    return text;
}

#pragma mark - NavBarDelgate

-(void)clickLeft:(UIButton *)leftBtn {
    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)clickRight:(UIButton *)leftBtn{
    
}

@end
