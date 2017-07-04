//
//  WebViewController.h
//  FilesViewController
//
//  Created by huadao on 15-3-24.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileBean.h"
#import "FileSystem.h"
#import "CustomNavigationBar.h"
#import "BottomEditView.h"
#import "ScanFileDelegate.h"
#import "CustomNotificationView.h"
@interface WebViewController : UIViewController<UIScrollViewDelegate,UIWebViewDelegate,NavBarDelegate,BottomEditViewDelegate,UITextViewDelegate>
{
    UIScrollView * _scrollview;
    NSArray      * _pathArray;
    NSString     * _path,* _prePath,* _nextPath;
    float          _oldContentOffSet;
    NSInteger      _index;
    NSInteger      _direction;
    CustomNavigationBar  *_customNavigationBar;
    BOOL           edit;
    BottomEditView          *_bottomView;
    FileBean                * _nowFile;
    NSInteger                idx;
    BOOL                   _delete;
    NSInteger                    _beforedelete;
     dispatch_queue_t                        _dispatchQueue;
    NSString               *_name;
    NSMutableArray         * _queueArray;
   
    BOOL                   _exist;
    BOOL                   _isAction;
    CustomNotificationView *   _loadingViews;
    CustomNotificationView *   _webloading;
    BOOL                      _first;
    FileBean               * _firstbean;
    FileBean                * _webbean;
    int                    _lastPosition;
     int                    _lastPosition1;
    CGFloat                  _barOffsetY;
    BOOL                    _zool;
    BOOL                      _moving;
    NSInteger               _clickrow;
    UIDocumentInteractionController *documentController;
    int current;
    UIAlertView * _alert;
    
}
- (void)thirdAppWebUrl:(NSURL*)url;
+(WebViewController *)instance;

@property (assign) id <ScanFileDelegate>scanDelegate;
-(void)getPath:(FileBean *)path pathArray:(NSArray *)array;

@end
