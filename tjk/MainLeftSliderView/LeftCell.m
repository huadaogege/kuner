//
//  LeftCell.m
//  MainViewController
//
//  Created by huadao on 15-3-24.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import "LeftCell.h"
#import<CoreText/CoreText.h>
#import "WXApi.h"
#import "WXApiObject.h"

@implementation  LeftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        self.image = [[UIImageView alloc]initWithFrame:CGRectMake(15*WINDOW_SCALE_SIX, (60-23)*WINDOW_SCALE_SIX/2.0, 23*WINDOW_SCALE_SIX, 23*WINDOW_SCALE_SIX)];
        [self.contentView addSubview:self.image];
        
        cellName=[[UILabel alloc]initWithFrame:CGRectMake(_image.frame.origin.x+_image.frame.size.width+11*WINDOW_SCALE_SIX,
                                                          (120.0/1334.0*[UIScreen mainScreen].bounds.size.height-18)/2.0,
                                                          130*WINDOW_SCALE_SIX,
                                                          18.0*WINDOW_SCALE_SIX)];
        cellName.textColor=[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        cellName.font=[UIFont systemFontOfSize:16.0*WINDOW_SCALE_SIX];
        cellName.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:cellName];
        
        feedlabel = [[UILabel alloc]initWithFrame:CGRectMake(cellName.frame.origin.x+cellName.frame.size.width, cellName.frame.origin.y, 85*WINDOW_SCALE_SIX, cellName.frame.size.height)];
        feedlabel.text = NSLocalizedString(@"savetofeedback",@"");
        feedlabel.font = [UIFont systemFontOfSize:13*WINDOW_SCALE_SIX];
        feedlabel.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
        [self.contentView addSubview:feedlabel];
        feedlabel.hidden = YES;

        weChatView = [[UIView alloc]initWithFrame:CGRectMake(feedlabel.frame.origin.x-30*WINDOW_SCALE_SIX, 19*WINDOW_SCALE_SIX, 85*WINDOW_SCALE_SIX, 22*WINDOW_SCALE_SIX)];
        [self.contentView addSubview:weChatView];
        
        webackImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, weChatView.frame.size.width, weChatView.frame.size.height)];
        webackImg.image = [UIImage imageNamed:@"wxback" bundle:@"TAIG_125"];
        [weChatView addSubview:webackImg];
        
        wechat = [[UIImageView alloc]initWithFrame:CGRectMake(6*WINDOW_SCALE_SIX, 4*WINDOW_SCALE_SIX, 15*WINDOW_SCALE_SIX, 15*WINDOW_SCALE_SIX)];
        wechat.image = [UIImage imageNamed:@"weichat1" bundle:@"TAIG_125"];
        [weChatView addSubview:wechat];
        welabel = [[UILabel alloc]initWithFrame:CGRectMake(wechat.frame.origin.x+wechat.frame.size.width+3*WINDOW_SCALE_SIX, 5*WINDOW_SCALE_SIX, 55*WINDOW_SCALE_SIX, 13*WINDOW_SCALE_SIX)];
        welabel.font = [UIFont systemFontOfSize:13.0*WINDOW_SCALE_SIX];
        welabel.textColor = [UIColor colorWithRed:255.0/255.0 green:73.0/255.0 blue:71.0/255.0 alpha:1.0];
        welabel.text = NSLocalizedString(@"weixinfeedback",@"");
        [weChatView addSubview:welabel];

        weChatFeedBtn = [[UIButton alloc]initWithFrame:webackImg.frame];
        [weChatFeedBtn addTarget:self action:@selector(weChatClick) forControlEvents:UIControlEventTouchUpInside];
        [weChatView addSubview:weChatFeedBtn];
        [self setSelected:NO animated:NO];
        weChatView.hidden = YES;
        
        
        
        
    }
    return self;
}

- (void)showAlertView{
    weChatAlertView = [[UIView alloc]init];
    weChatAlertView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.7];
    weChatAlertView.frame= CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.window addSubview:weChatAlertView];
    
    UIView * alertView = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-300*WINDOW_SCALE_SIX)/2.0,
                                                                (SCREEN_HEIGHT-150*WINDOW_SCALE_SIX)/2.0,
                                                                300*WINDOW_SCALE_SIX,
                                                                160*WINDOW_SCALE_SIX)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 20;
    [weChatAlertView addSubview:alertView];
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10*WINDOW_SCALE_SIX, 300*WINDOW_SCALE_SIX, 30)];
//    title.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.7];
    title.text = NSLocalizedString(@"weixinkehufeed",@"");
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [alertView addSubview:title];
    
    UILabel *contentLab1 = [[UILabel alloc]initWithFrame:CGRectMake(0, title.frame.origin.y+title.frame.size.height+15.0*WINDOW_SCALE_SIX, 300*WINDOW_SCALE_SIX, 20*WINDOW_SCALE_SIX)];
    contentLab1.textColor = [UIColor blackColor];
    contentLab1.font = [UIFont systemFontOfSize:15*WINDOW_SCALE_SIX];
    contentLab1.textAlignment = NSTextAlignmentCenter;
    contentLab1.text = NSLocalizedString(@"attentionweixin",@"");
    [alertView addSubview:contentLab1];
    UILabel *contentLab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, contentLab1.frame.origin.y+contentLab1.frame.size.height, 300*WINDOW_SCALE_SIX-120*WINDOW_SCALE_SIX, 20*WINDOW_SCALE_SIX)];
    contentLab2.textColor = [UIColor blackColor];
    contentLab2.font = [UIFont systemFontOfSize:15*WINDOW_SCALE_SIX];
    contentLab2.textAlignment = NSTextAlignmentRight;
    contentLab2.text = NSLocalizedString(@"weixinnum",@"");
    [alertView addSubview:contentLab2];
    UILabel *contentLab3 = [[UILabel alloc]initWithFrame:CGRectMake(contentLab2.frame.origin.x+contentLab2.frame.size.width+5*WINDOW_SCALE_SIX, contentLab1.frame.origin.y+contentLab1.frame.size.height, 110*WINDOW_SCALE_SIX, 20*WINDOW_SCALE_SIX)];
    contentLab3.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.7];
    contentLab3.font = [UIFont systemFontOfSize:15*WINDOW_SCALE_SIX];
    contentLab3.textAlignment = NSTextAlignmentLeft;
    contentLab3.textColor = [UIColor grayColor];
    contentLab3.text = NSLocalizedString(@"copyed",@"");
    [alertView addSubview:contentLab3];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, contentLab3.frame.origin.y+contentLab3.frame.size.height+15*WINDOW_SCALE_SIX, 300*WINDOW_SCALE_SIX, 0.5)];
    line1.backgroundColor = [UIColor grayColor];
    line1.alpha = 0.5;
    [alertView addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(150*WINDOW_SCALE_SIX, contentLab3.frame.origin.y+contentLab3.frame.size.height+15*WINDOW_SCALE_SIX, 0.5, 160.0*WINDOW_SCALE_SIX-(contentLab3.frame.origin.y+contentLab3.frame.size.height+10*WINDOW_SCALE_SIX))];
    line2.backgroundColor = [UIColor grayColor];
    line2.alpha = 0.5;
    [alertView addSubview:line2];
    
    UILabel * btnLab1 =[[UILabel alloc]initWithFrame:CGRectMake(0, line2.frame.origin.y, 150*WINDOW_SCALE_SIX, line2.frame.size.height)];
    btnLab1.textColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
    btnLab1.text = NSLocalizedString(@"cancel", nil);
    btnLab1.textAlignment = NSTextAlignmentCenter;
    btnLab1.font = [UIFont systemFontOfSize:18.0];
    [alertView addSubview:btnLab1];
    
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:btnLab1.frame];
    cancelBtn.tag = 111;
    [cancelBtn addTarget:self action:@selector(cancelAlertView:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:cancelBtn];
    
    UILabel * btnLab2 =[[UILabel alloc]initWithFrame:CGRectMake(btnLab1.frame.origin.x+btnLab1.frame.size.width, line2.frame.origin.y, 150*WINDOW_SCALE_SIX, line2.frame.size.height)];
    btnLab2.textColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
    btnLab2.text = NSLocalizedString(@"gotoweixinfeedback", nil);
    btnLab2.textAlignment = NSTextAlignmentCenter;
    btnLab2.font = [UIFont systemFontOfSize:18.0];
    [alertView addSubview:btnLab2];
    
    UIButton * yesBtn = [[UIButton alloc]initWithFrame:btnLab2.frame];
    yesBtn.tag = 222;
    [yesBtn addTarget:self action:@selector(cancelAlertView:) forControlEvents:UIControlEventTouchUpInside];
    [alertView addSubview:yesBtn];
    
 
}

- (void)cancelAlertView:(UIButton*)sender{

   if (sender.tag == 222){
        if ([self checkWerXinStatus]) {
            [WXApi openWXApp];
        }
    }
    
    [weChatAlertView removeFromSuperview];
}
- (void)weChatClick {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"kuner2016";
    [self showAlertView];
}
- (BOOL)checkWerXinStatus
{
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"")
                                                        message:NSLocalizedString(@"notinstallwx", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"sure", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", @"") message:NSLocalizedString(@"wxversionlowtip", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"") otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}
-(void)setcellName:(NSString *)name{
    if (name) {
        cellName.text=name;
    }
    
    if ([name isEqualToString:NSLocalizedString(@"kehuphone",@"")]) {
        weChatView.hidden = NO;
    }else{
       weChatView.hidden = YES;
    }
    if ([name isEqualToString:NSLocalizedString(@"feedback", @"")]) {
        
        CGFloat width = [name boundingRectWithSize:CGSizeMake(cellName.frame.size.width, cellName.frame.size.height) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:cellName.font} context:nil].size.width;
        feedlabel.hidden = NO;
        
        // 国际化适配
        if ([FileSystem isEngLish] || [FileSystem isCzechLanguage]) {
            CGFloat oriX = cellName.frame.origin.x+width+11*WINDOW_SCALE_SIX;
            feedlabel.frame = CGRectMake(oriX, cellName.frame.origin.y, 215*WINDOW_SCALE_SIX-width, cellName.frame.size.height);
        }
    }else{
        feedlabel.hidden = YES;
    }
    

}


@end
