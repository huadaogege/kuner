//
//  SetUpdateAlertView.m
//  tjk
//
//  Created by 张旭东 on 14-4-16.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "SetUpdateAlertView.h"
#import "UIImage+Bundle.h"
#import "AppDelegate.h"

#import "AppUpdateUtils.h"
#define appDelegate   ((AppDelegate*)([UIApplication sharedApplication].delegate))
@interface SetUpdateAlertView()
{
    UIView   *_segregateView;
    UIWindow *_window;
    UIImageView * selectimage;
    BOOL        selected;
}
@end


@implementation SetUpdateAlertView

static SetUpdateAlertView * alert=nil;
+(SetUpdateAlertView *)instance
{
    if (alert==nil) {
        alert=[[SetUpdateAlertView alloc]init];
    }
    return alert;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _window = appDelegate.window;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.frame = CGRectMake(0,
                                0,
                                180,
                                200);
        self.center = _window.center;
        //蒙版
        _segregateView = [[UIView alloc]init];
        
        
        [_segregateView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4 ]];
        
      
        
        _segregateView.frame = _window.bounds;
    
       
        
    }
    return self;
}


-(void)dismissalert{
    [self dismiss];

}
- (id)initWithUpdateMessage:(NSString *)updateMessage downloadplist:(NSString *)downplist version:(NSString*)version isApp:(BOOL)isApp
{
    isapp = isApp;
    if (self = [super init])
    {
        UILabel *titleLab = [[UILabel alloc]
                             initWithFrame:CGRectMake(0,
                                                      15,
                                                      270,
                                                      20)];
        [self addSubview:titleLab];
        
        titleLab.textAlignment = NSTextAlignmentCenter;
        
        
        UILabel *updateMessageLab = [[UILabel alloc]
                                     initWithFrame:CGRectMake((self.frame.size.width-240)/2,
                                                              60,
                                                              240,
                                                              15)];
        
        [self addSubview:updateMessageLab];
        
        UIFont *font = [UIFont systemFontOfSize:13.0];
        
        updateMessageLab.font = font;
        
        updateMessageLab.numberOfLines = 100;
        
        updateMessageLab.textAlignment=NSTextAlignmentCenter;
        
        updateMessageLab.lineBreakMode =  NSLineBreakByWordWrapping;
        
        
        updateMessage = [updateMessage stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        
        
        if (updateMessage)
        {
            
            titleLab.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"newversion",@""),version];
            titleLab.font=[UIFont boldSystemFontOfSize:17.0];
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
            
            //ios7方法，获取文本需要的size，限制宽度
            CGSize size = CGSizeMake(240, 1000);
            
            CGSize  actualsize =[updateMessage boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
            
            updateMessageLab.frame = CGRectMake(updateMessageLab.frame.origin.x,
                                                updateMessageLab.frame.origin.y,
                                                240,
                                                actualsize.height);
            updateMessageLab.textColor = [UIColor grayColor];
            updateMessageLab.numberOfLines=0;
            
            UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(11, 45, 100, 20)];
            lab.font = [UIFont systemFontOfSize:15.0];
            lab.text = NSLocalizedString(@"updateThing",@"");
            lab.textAlignment = NSTextAlignmentLeft;
            [self addSubview:lab];
            
            
            UITextView * text=[[UITextView alloc]init];
            text.editable=NO;
            text.frame=CGRectMake(17,
                                  67,
                                  240,
                                  updateMessageLab.frame.origin.y + updateMessageLab.frame.size.height-30);
            text.font=[UIFont systemFontOfSize:13.0];
            text.text=updateMessage;
            [self addSubview:text];

            
            UIView *splitLine2 = [[UIView alloc]
                                 initWithFrame:CGRectMake(0,
                                                          updateMessageLab.frame.origin.y + updateMessageLab.frame.size.height + 15+50,
                                                          270,
                                                          1)];
            
            splitLine2.backgroundColor = [UIColor colorWithRed:200.0 / 255.0
                                                         green:200.0 / 255.0
                                                          blue:200.0 / 255.0
                                                         alpha:1.0];
            
            [self addSubview:splitLine2];
            UIView *splitLine = [[UIView alloc]
                                 initWithFrame:CGRectMake(270.0/2.0,
                                                          splitLine2.frame.origin.y,
                                                          1,
                                                          50)];
            
            splitLine.backgroundColor = [UIColor
                                         colorWithRed:200.0 / 255.0
                                         green:200.0 / 255.0
                                         blue:200.0 / 255.0
                                         alpha:1.0];
            
            [self addSubview:splitLine];
            
            UIView *splitLine3 = [[UIView alloc]
                                  initWithFrame:CGRectMake(0,
                                                           splitLine.frame.origin.y + splitLine.frame.size.height,
                                                           270,
                                                           1)];
            
            splitLine3.backgroundColor = [UIColor colorWithRed:200.0 / 255.0
                                                         green:200.0 / 255.0
                                                          blue:200.0 / 255.0
                                                         alpha:1.0];
            
            [self addSubview:splitLine3];

            

            //更新plist
            downloadplist=downplist;
            binversion = version;           
            UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];

            [okBtn setTitle:NSLocalizedString(@"updatenow",@"") forState:UIControlStateNormal];
           
            [okBtn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            okBtn.frame = CGRectMake(153,
                                     updateMessageLab.frame.size.height + updateMessageLab.frame.origin.y + 30+50,
                                     85,
                                     30);
            
            okBtn.tag = 2;
            if (downloadplist!=nil) {
                [okBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                [okBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self addSubview:okBtn];
            
            
            
            UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
           
            [cancleBtn setTitle:NSLocalizedString(@"donotupdate",@"")forState:UIControlStateNormal];
            [cancleBtn setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            cancleBtn.tag = 1;
            if (downloadplist !=nil) {
                [cancleBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                [cancleBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            cancleBtn.frame = CGRectMake(31,
                                         updateMessageLab.frame.size.height + updateMessageLab.frame.origin.y + 30+50,
                                         85,
                                         30);
            
            [self addSubview:cancleBtn];
            
            
            
            UILabel * notips = [[UILabel alloc]initWithFrame:CGRectMake(90.0, splitLine3.frame.size.height+splitLine3.frame.origin.y, 125.0, 50.0)];
            notips.textColor =[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
            notips.text = NSLocalizedString(@"versionnotips", @"");
            [self addSubview:notips];
            
            selectimage =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"index_select_bg" bundle:@"TAIG_MainImg"]];
            selectimage.frame = CGRectMake(60, notips.frame.origin.y+15, 20, 20);
            [self addSubview:selectimage];
            
            UIButton * notipsbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, notips.frame.origin.y, 270, 50)];
            [notipsbtn addTarget:self action:@selector(selectNoTips) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:notipsbtn];

           
            self.frame = CGRectMake(0,
                                    0,
                                    270,
                                    45 + 30 + 30 + 20 + updateMessageLab.frame.size.height+50+50);
            
            self.center = _window.center;
            
        }
        else
        {
            /*
            titleLab.text = NSLocalizedString(@"checkupdate",@"");
            
            updateMessage = NSLocalizedString(@"nonewversion",@"");
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
            
            //ios7方法，获取文本需要的size，限制宽度
            CGSize size = CGSizeMake(240, 1000);
            
            CGSize  actualsize =[updateMessage boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
            
            updateMessageLab.frame = CGRectMake((240-actualsize.width)/2.0,
                                                updateMessageLab.frame.origin.y-10.0,
                                                actualsize.width,
                                                actualsize.height);
            
            updateMessageLab.textColor = [UIColor grayColor];
            updateMessageLab.textAlignment=NSTextAlignmentCenter;
            
            updateMessageLab.text = updateMessage;
            
            
            UIButton *noneUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
          
            [noneUpdate setTitle:NSLocalizedString(@"sure",@"") forState:UIControlStateNormal];
            [noneUpdate setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];

            
            
            
            [noneUpdate addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            
            
            noneUpdate.frame = CGRectMake(270 / 2.0 - 85 / 2.0,
                                         updateMessageLab.frame.size.height + updateMessageLab.frame.origin.y + 30,
                                         85,
                                         30);
            
            [self addSubview:noneUpdate];
            
            UIView *splitLine2 = [[UIView alloc]
                                  initWithFrame:CGRectMake(0,
                                                          noneUpdate.frame.origin.y-5.0,
                                                           270,
                                                           1)];
            splitLine2.backgroundColor = [UIColor colorWithRed:200.0 / 255.0
                                                         green:200.0 / 255.0
                                                          blue:200.0 / 255.0
                                                         alpha:1.0];
            
            [self addSubview:splitLine2];

            self.frame = CGRectMake(0,
                                    0,
                                    270,
                                    45 + 30 + 30 + 20 + updateMessageLab.frame.size.height);
            
               self.center = _window.center;
             */
        }
        
        
     
        
        
    }
    
  
    return self;
}

-(void)selectNoTips{
    
    if (selected) {
        selectimage.image = [UIImage imageNamed:@"index_select_bg" bundle:@"TAIG_MainImg"];
        selected = NO;
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"selectnotips"];
    }else{
        selectimage.image = [UIImage imageNamed:@"index_selected" bundle:@"TAIG_MainImg"];
        selected = YES;
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"selectnotips"];
    }

}

- (id)initWithUpdateErrorMessage:(NSString *)updateMessage
{
    if ( self = [super init])
    {
        UILabel *titleLab = [[UILabel alloc]
                             initWithFrame:CGRectMake(0,
                                                      15,
                                                      270,
                                                      20)];
        [self addSubview:titleLab];
        
        titleLab.textAlignment = NSTextAlignmentCenter;
        
        UIView *splitLine = [[UIView alloc]
                             initWithFrame:CGRectMake(10,
                                                      100,
                                                      250,
                                                      1)];
        
        splitLine.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:180.0/255.0 blue:189.0/255.0 alpha:1.0];
        
        [self addSubview:splitLine];
        
        
        UILabel *updateMessageLab = [[UILabel alloc]
                                     initWithFrame:CGRectMake(15,
                                                              60,
                                                              240,
                                                              15)];
        
        [self addSubview:updateMessageLab];
        
        UIFont *font = [UIFont systemFontOfSize:12.0];
        
        updateMessageLab.font = font;
        
        updateMessageLab.numberOfLines = 100;
        
        updateMessageLab.lineBreakMode =  NSLineBreakByWordWrapping;
        
        [self addSubview:splitLine];
        
    
        titleLab.text = NSLocalizedString(@"checkupdate",@"");
        
        updateMessage = updateMessage;
        
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
        
        //ios7方法，获取文本需要的size，限制宽度
        CGSize size = CGSizeMake(240, 1000);
        
        CGSize  actualsize =[updateMessage boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
        
        updateMessageLab.frame = CGRectMake(updateMessageLab.frame.origin.x,
                                            updateMessageLab.frame.origin.y,
                                            240,
                                            actualsize.height);
        
        
        updateMessageLab.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
        
        updateMessageLab.textAlignment=NSTextAlignmentCenter;
        updateMessageLab.text = updateMessage;
        
        
        
        UIButton *noneUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
        [noneUpdate setTitle:NSLocalizedString(@"sure",@"") forState:UIControlStateNormal];
        [noneUpdate setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
       
        
        
        
        [noneUpdate addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        
        noneUpdate.frame = CGRectMake(270 / 2.0 - 85 / 2.0,
                                      updateMessageLab.frame.size.height + updateMessageLab.frame.origin.y + 35,
                                      85,
                                      30);
       
        [self addSubview:noneUpdate];
        
        self.frame = CGRectMake(0,
                                0,
                                270,
                                45 + 30 + 30 + 35 + updateMessageLab.frame.size.height);
        self.center = _window.center;
        


    }
    return self;
}

- (void)show
{
    if ([self.superview isKindOfClass:[AppDelegate class]])
    {
        return;
    }
    
   
    [_window addSubview:_segregateView];
    [_window addSubview:self];
    
    
}

- (void)dismissAnimationed
{
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 0.0;
        _segregateView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [_segregateView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)dismiss
{
    [_segregateView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)dismissWithCompletion:(completion)completionBlock
{
    [UIView animateWithDuration:0.28 animations:^{
        self.alpha = 0.0;
        _segregateView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [_segregateView removeFromSuperview];
            [self removeFromSuperview];
            completionBlock();
        }
       
    }];
}

- (void)timerFireMethods:(NSTimer*)theTimer
{
    UIAlertView *failed = (UIAlertView*)[theTimer userInfo];
    [failed dismissWithClickedButtonIndex:0 animated:NO];
    failed =NULL;
}
//版本更新调用方法
- (void)btnClicked:(UIButton *)btn
{
        if (btn.tag==2)
        {
            if (isapp) {
                if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:downloadplist]])
                {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadplist]];
                    exit(0);
                }else
                {
                    UIAlertView * alertdown=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"updatefail",@"") message:NSLocalizedString(@"serverfail_again",@"") delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
                    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                     target:self
                                                   selector:@selector(timerFireMethods:)
                                                   userInfo:alertdown
                                                    repeats:YES];
                    [alertdown show];
                }
            }else{
                [[AppUpdateUtils instance]updateVersion];
            }
            [self dismiss];
        }
        else if (btn.tag==1)
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"selectnotips"]) {
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                [ defaults setObject:binversion forKey:@"binversion"];
            }
            [self dismiss];
        }

}


-(void)btnClick:(UIButton *)button
{
    
    
    if ([self.delegate respondsToSelector:@selector(setUpdateAlertView:clickedAtIndex:)])
    {
        if (button.tag==2) {
            [self.delegate setUpdateAlertView:self clickedAtIndex:button.tag];

        }else{
        
                }
            [self dismiss];
        
   
    }


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
