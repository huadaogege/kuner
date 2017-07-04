//
//  PAPasscodeViewController.h
//  PAPasscode
//
//  Created by Denis Hennessy on 15/10/2012.
//  Copyright (c) 2012 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "UIBackDelegate.h"
#import "SafeGuard.h"
typedef enum {
    PasscodeActionSet,
    PasscodeActionEnter,
    PasscodeActionChange
} PasscodeAction;

@class PAPasscodeViewController;

@protocol PAPasscodeViewControllerDelegate <NSObject>



@optional
- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller;
- (void)PAPasscodeViewController:(PAPasscodeViewController *)controller didFailToEnterPasscode:(NSInteger)attempts;

@end

@interface PAPasscodeViewController : UIViewController <UITextFieldDelegate,NavBarDelegate>{
    UIView *contentView;
    NSInteger phase;
    UILabel *promptLabel;
    UILabel *messageLabel;
    UIImageView *failedImageView;
    UILabel *failedAttemptsLabel;
    UITextField *passcodeTextField;
    UIImageView *digitImageViews[4];
    UIImageView *snapshotImageView;
    CustomNavigationBar * _customNavigationBar;
    NSString            * _what;
    UIImageView         * _safeIsFalse;
    UILabel             * _labFalse;
    BOOL                 _newpassword;
    
    UIView *tipView;
    
    NSString * _lastAnswer;
}
@property (nonatomic,assign) id<UIBackDelegate> backDelegate;
@property (readonly) PasscodeAction action;
@property (weak) id<PAPasscodeViewControllerDelegate> delegate;
@property (strong) NSString *passcode;
@property (assign) BOOL simple;
@property (assign) NSInteger failedAttempts;
//@property (strong) NSString *enterPrompt;
@property (strong) NSString *confirmPrompt;
@property (strong) NSString *changePrompt;
@property (strong) NSString *message;

- (id)initForAction:(PasscodeAction)action whatview:(NSString *)what newPassWord:(BOOL)word lastAnswer:(NSString*)answer;

@end
