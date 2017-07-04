//
//  ChoicePathDeleagte.h
//  tjk
//
//  Created by lengyue on 15/3/25.
//  Copyright (c) 2015年 taig. All rights reserved.
//

@protocol ChoicePathDeleagte <NSObject>

-(void)choicedPathAt:(NSString*)path;
-(void)pushViewController:(UIViewController*)vc animation:(BOOL)need;
-(void)uichangeFrom:(UIViewController*)vc1 to:(UIViewController*)vc2;
-(void)popViewController;
-(void)popToRootViewController;
-(void)dismissViewController:(UIViewController*)vc;
@end
