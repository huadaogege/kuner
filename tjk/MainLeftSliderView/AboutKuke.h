//
//  AboutKuke.h
//  tjk
//
//  Created by huadao on 15/4/27.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBackDelegate.h"

@interface AboutKuke : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIImageView * _iconimage;
    
    UILabel     * _myKukeLabel;
    UILabel     * _version;
    UILabel     * _cooperate;
    UILabel     * _bottom1;
    UILabel     * _bottom2;
    UITableView * _tableView;
    UIView     * view;
    NSMutableArray * _linkNameAry;
    NSMutableArray * _unLinkNameAry;
    NSMutableArray * _unActivityNameAry;
    BOOL           _deviceOn;
    NSMutableArray * _currentNameAry;
    NSArray        * _infoAry;
    UIView         * _weChatView;
    UIButton       * _weChatCancelBtn;

}
@property (nonatomic,assign) id<UIBackDelegate> backDelegate;
@end
