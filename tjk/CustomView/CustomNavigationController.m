//
//  CustomNavigationController.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 14/12/12.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "CustomNavigationController.h"
#import "PreviewViewController.h"
#import "FileViewController.h"
#import "ViewController.h"
#import "DownloadListVC.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if(self){
        
        self.isCanGesture = YES;
//        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    return self;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(!self.isCanGesture){
        return NO;
    }
    if(self.viewControllers.count < 2)
        return NO;
    else
        return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // fix 'nested pop animation can result in corrupted navigation bar'
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
    if(self.viewControllers.count < 2){
        
        return nil;
    }else{
        
        return [super popViewControllerAnimated:animated];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

-(BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return [self.topViewController isKindOfClass:[PreviewViewController class]] || [self.topViewController isKindOfClass:[FileViewController class]] || [self.topViewController isKindOfClass:[ViewController class]] || [self.topViewController isKindOfClass:[DownloadListVC class]];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self.topViewController isKindOfClass:[PreviewViewController class]]) {
        PreviewViewController *prVC = (PreviewViewController *)self.topViewController;
        if (prVC.isPresentView) {
            return UIInterfaceOrientationMaskPortrait;
        }
        else{
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
//    return  UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    
    return UIInterfaceOrientationPortrait;
}

@end
