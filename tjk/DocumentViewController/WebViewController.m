//
//  WebViewController.m
//  FilesViewController
//
//  Created by huadao on 15-3-24.
//  Copyright (c) 2015年 cuiyuguan. All rights reserved.
//

#import "WebViewController.h"
#import "CustomFileManage.h"
#import "MusicPlayerViewController.h"

#define RIGHT 123
#define LEFT  456
#define TXTTAG 312
#define WEBTAG 316

#define DOCUMENT_PDF    @"pdf"
#define DOCUMENT_TXT    @"txt"
#define DOCUMENT_RTF    @"rtf"
#define DOCUMENT_DOC    @"doc"
#define DOCUMENT_DOCX   @"docx"
#define DOCUMENT_HTML   @"html"
#define DOCUMENT_PPT    @"ppt"
#define DOCUMENT_XLS    @"xls"
#define DOCUMENT_PPTX    @"pptx"
#define DOCUMENT_XLSX    @"xlsx"


#define MENU_COPY_PICTURE_TAG  520
#define MENU_DELET_PICTURE_TAG 521
#define MENU_OPEN_PICTURE_TAG 522
#define DELETE_ALERT_TAG 523

@interface WebViewController ()<UIDocumentInteractionControllerDelegate>{
    NSInteger _selected;
}
@property NSMutableArray* webArr;
@end
@implementation WebViewController
static  WebViewController * webview=nil;
+(WebViewController *)instance
{
    if (!webview) {
        webview=[[WebViewController alloc]init];
    }
    return webview;
}
-(id)init{
    self=[super init];
    if (self) {
      
        _first = YES;
//        _movedirection = YES;
        
        _customNavigationBar = [[CustomNavigationBar alloc] init];
        _customNavigationBar.delegate = self;
        
        _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
        
        [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"browse",@"") forState:UIControlStateNormal];
        edit=YES;
        
        _barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
        _customNavigationBar.frame = CGRectMake(0,
                                                _barOffsetY,
                                                [UIScreen mainScreen].bounds.size.width,
                                                64 - _barOffsetY);
        [_customNavigationBar fitSystem];

        
        _dispatchQueue = dispatch_queue_create("WebViewController", DISPATCH_QUEUE_SERIAL);
        _queueArray = [[NSMutableArray alloc]init];
        _loadingViews = [[CustomNotificationView alloc] initWithTitle: NSLocalizedString(@"adding",@"")];
        _webloading = [[CustomNotificationView alloc] initWithTitle: NSLocalizedString(@"adding",@"")];

        _isAction = NO;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//判定要load的文件类型

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _zool = YES;
    _delete = NO;
    _moving = YES;
    self.view.autoresizesSubviews = NO;
    self.view.backgroundColor =BASE_COLOR ;
    
    _bottomView = [[BottomEditView alloc] initWithInfos:
                   [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     NSLocalizedString(@"openway",@""), @"title" ,
                     @"list_icon_openway", @"img" ,
                     @"list_icon_openway_light", @"hl_img" ,
                     [NSNumber numberWithInteger:MENU_OPEN_PICTURE_TAG], @"tag" ,
                     nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     NSLocalizedString(@"copy",@""), @"title" ,
                     @"list_icon-copy-nouse", @"img" ,
                     @"list_icon-copy", @"hl_img" ,
                     [NSNumber numberWithInteger:MENU_COPY_PICTURE_TAG], @"tag" ,
                     nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:
                     NSLocalizedString(@"delete",@""), @"title" ,
                     @"list_icon-delete-nouse", @"img" ,
                     @"list_icon-delete", @"hl_img" ,
                     @"1", @"is_delete" ,
                     [NSNumber numberWithInteger:MENU_DELET_PICTURE_TAG], @"tag" ,
                     nil],
                    nil] frame:CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45)];
    _bottomView.editDelegate = self;
   
    [_bottomView setMenuItemWithTag:MENU_COPY_PICTURE_TAG enable:YES reverse:NO];
    [_bottomView setMenuItemWithTag:MENU_DELET_PICTURE_TAG enable:YES reverse:NO];
    [_bottomView setMenuItemWithTag:MENU_OPEN_PICTURE_TAG enable:YES reverse:NO];

    if (_selected < _pathArray.count) {
        FileBean * tmp =[_pathArray objectAtIndex:_selected];
        _customNavigationBar.title.text= tmp.fileName;
    }

    CGRect frame=self.view.frame;
   
    _scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                              64.0,
                                                              SCREEN_WIDTH+6,
                                                              self.view.frame.size.height-64-45)];
    _scrollview.contentSize=CGSizeMake(frame.size.width*3+18.0, self.view.frame.size.height-64-45);
    _scrollview.pagingEnabled=YES;
    _scrollview.delegate=self;
    _scrollview.showsHorizontalScrollIndicator=NO;
    _scrollview.showsVerticalScrollIndicator=NO;
    _scrollview.bounces = NO;
    _scrollview.backgroundColor= [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0];
    _scrollview.scrollEnabled=NO;
    
    _scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollview.contentOffset = CGPointMake(frame.size.width+6, 0);
    _scrollview.decelerationRate= 0.5;
    UIView * topbar=[[UIView alloc]initWithFrame:CGRectMake(0,
                                                            0,
                                                            SCREEN_WIDTH,
                                                            20.0*WINDOW_SCALE)];
    topbar.backgroundColor=BASE_COLOR;
    
    [self.view addSubview:_scrollview];
    [self.view addSubview:_customNavigationBar];
    [self.view addSubview:topbar];
    [self.view addSubview:_bottomView];
    
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(body:) name:@"body" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
        // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated{

    [self removeThirdCache];
}
- (void)removeThirdCache{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * string = [APP_DOC_ROOT stringByAppendingPathComponent:@"Inbox"];
    if ([fm fileExistsAtPath:string]) {
        [fm removeItemAtPath:string error:nil];
    }
}

- (void)thirdAppWebUrl:(NSURL*)url{
    NSString * kind = [[url.absoluteString pathExtension]lowercaseString];
    NSString *unicodeStr = [NSString stringWithString:[url.absoluteString.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _customNavigationBar.title.text = unicodeStr;
   
    if ([kind isEqualToString:@"txt"]) {
        
        _webloading.hidden = YES;
        UITextView * view = [[UITextView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-44)];
        [self.view addSubview:view];
        __block  NSString * body ;
        dispatch_async(dispatch_queue_create(0, 0), ^{
            
            body = [NSString stringWithContentsOfURL:url encoding:0x80000632 error:nil];
            if (body==nil) {
                body =  [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:url ]  encoding:NSUTF8StringEncoding];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                view.text = body;
            });
        });
        
    }else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
        UIWebView * web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        [self.view addSubview:web];
        [web loadRequest:request];
    }
}
-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            if (_alert ) {
                [_alert dismissWithClickedButtonIndex:0 animated:NO];
            }
        }
    }
    
}

-(void)body:(NSNotification *)noti{
    
    FileBean * bean = [noti.object valueForKey:@"bean"];
    if ([_firstbean.filePath isEqual:bean.filePath]) {
        [_loadingViews dismiss];
    }
    FileBean * laterbean = [noti.object valueForKey:@"bean"];
    
    NSInteger  index = [_pathArray indexOfObject:_nowFile];
    
    BOOL offer = false;
    NSInteger row=2;
    
    for (int i=(int)index-1; i<(int)index+2; i++) {
        if (i>=0&&i<_pathArray.count) {
            FileBean * bean = [_pathArray objectAtIndex:i];
            if ([bean.filePath isEqualToString:laterbean.filePath]) {
                offer = YES;
                row=i -index+1;
                break;
            }else{
                offer = NO;
                
            }
            
        }
    }
    //处理目前数组中只有两个txt且点击为第二个时候
    if (_pathArray.count==2&&_clickrow==1) {
        row=row-1;
    }
    
    if (offer) {
        UIWebView * web =[self.webArr objectAtIndex:row];
        UITextView * text = (UITextView*)[web viewWithTag:312];
        text.font = [UIFont systemFontOfSize:18.0];
        text.text = [noti.object valueForKey:@"body"];
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
  
    [self performSelector:@selector(setInSet) withObject:nil afterDelay:0.1];
   
}
-(void)setInSet{
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==DELETE_ALERT_TAG&&buttonIndex==1) {
        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(needRemoveItemWith:)]) {
            if (_selected<_pathArray.count) {
                FileBean * bean = [_pathArray objectAtIndex:_selected];
                [self.scanDelegate needRemoveItemWith:bean];
            }
         }

    }else if (alertView.tag == 898){
        
        if (buttonIndex == 0) {
            [self clickLeft:nil];
        }else{
            [self getPath:_webbean pathArray:_pathArray];
        }
    }

}
-(void)editButtonClickedAt:(NSInteger)tag{
    if (tag == MENU_COPY_PICTURE_TAG) {
        if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(needCopyItemWith:)]) {
            if (_selected<_pathArray.count) {
                FileBean * bean = [_pathArray objectAtIndex:_selected];
                [self.scanDelegate needCopyItemWith:bean];
            }
        }
    }
    else if (tag == MENU_DELET_PICTURE_TAG) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletealert", @"") message:
                                  /*(self.resType == Music_Res_Type?@"确定要删除所选歌单吗？" :*/
                                  NSLocalizedString(@"deletefilesy", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"yes", @""), nil];
        alertView.tag = DELETE_ALERT_TAG;
        [alertView show];

        
      }
    else if (tag == MENU_OPEN_PICTURE_TAG)
    {
        if (_selected<_pathArray.count) {
            FileBean * bean = [_pathArray objectAtIndex:_selected];
            [self openDocumentIn:bean];
        }
    }
}

-(void)openDocumentIn:(FileBean *)bean{
    [CustomNotificationView showToastWithoutDismiss:NSLocalizedString(@"readying",@"")];
    dispatch_async(dispatch_queue_create(0, 0), ^{
        BOOL result = [[CustomFileManage instance] copyToTempWith:bean];
        dispatch_async(dispatch_get_main_queue(), ^{
            [CustomNotificationView clearToast];
            if (result) {
                NSString *path = [[[CustomFileManage instance] getLibraryTempPath] stringByAppendingPathComponent:bean.fileName];
                NSURL *URL= [NSURL fileURLWithPath:path];
                if (URL) {
                    documentController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                    documentController.delegate = self;
                    [documentController presentOpenInMenuFromRect:CGRectMake(0, 300, 100, 100) inView:self.view animated:YES];
                }
            }
            else{
                [CustomNotificationView showToast:NSLocalizedString(@"readyfail",@"")];
            }
        });
        
    });
}

-(void)clickLeft:(UIButton *)leftBtn{

    _scrollview.delegate=nil;
    _scrollview=nil;
    [self.navigationController popViewControllerAnimated:YES];
    if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(scanedItemWith:)]) {
        if (_selected<_pathArray.count) {
            [self.scanDelegate scanedItemWith: [_pathArray objectAtIndex:_selected] ];
        }
    }

}
-(void)clickRight:(UIButton *)leftBtn{
    
    CGRect frame = _customNavigationBar.frame;
    
    if (frame.origin.y==-64) {
        
    }else{
        if (edit) {
            [self readstate];
            UIAlertView * alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"browsestatus",@"") message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            alert.delegate=self;
            [alert show];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethod:)
                                           userInfo:alert
                                            repeats:YES];
            edit=NO;
        }else{
            [self browsestate];
            UIAlertView * alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"readingstatus",@"") message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            alert.delegate=self;
            [alert show];
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timerFireMethod:)
                                           userInfo:alert
                                            repeats:YES];
            edit=YES;
        }
     }
    
}

-(void)readstate{
    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"read",@"") forState:UIControlStateNormal];
    _scrollview.scrollEnabled=YES;
    
    NSArray *array=[_scrollview subviews];
    for (int i=0; i<array.count; i++) {
        
        UIWebView *web = [array objectAtIndex:i];
        web.userInteractionEnabled=NO;
        
    }
    for (int i=0; i<self.webArr.count; i++) {
        UIWebView *web = [array objectAtIndex:i];
        [web loadRequest:web.request];
        web.userInteractionEnabled=NO;
        
    }
}
-(void)browsestate{

    [_customNavigationBar.rightBtn setTitle:NSLocalizedString(@"browse",@"") forState:UIControlStateNormal];
    _scrollview.scrollEnabled=NO;
    
    NSArray *array=[_scrollview subviews];
    for (int i=0; i<array.count; i++) {
        
        UIWebView *web = [array objectAtIndex:i];
        web.userInteractionEnabled=YES;
    }
    for (int i=0; i<self.webArr.count; i++) {
        UIWebView *web = [array objectAtIndex:i];
        web.userInteractionEnabled=YES;
    }

}

- (void)timerFireMethod:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    promptAlert =NULL;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
       if (scrollView.tag==WEBTAG||scrollView.tag==TXTTAG) {
            current = scrollView.contentOffset.y;
           if (current>=0&&current<scrollView.contentSize.height-SCREEN_HEIGHT&&_zool&&_moving) {
               if (current-_lastPosition>5) {
                   _lastPosition = current;
                   [self scrollViewUp];
                   NSLog(@"上划");
               }else if (_lastPosition-current>5){
                   _lastPosition = current;
                   NSLog(@"下划");
                   [self scrollviewDown];
               }
           }
           
    }else{
        
        if (_selected == 0 && scrollView.contentOffset.x < self.view.frame.size.width) {
            scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0);
            
        }
        else if(_selected == _pathArray.count - 1 && scrollView.contentOffset.x > self.view.frame.size.width) {
            scrollView.contentOffset = CGPointMake(self.view.frame.size.width+6, 0);
            
        }

    }
}


-(void)scrollViewUp{

    [UIView animateWithDuration:0.5 animations:^{
        _customNavigationBar.frame = CGRectMake(0,
                                                _barOffsetY-64,
                                                [UIScreen mainScreen].bounds.size.width,
                                                64 - _barOffsetY);
        [_customNavigationBar fitSystem];
        _bottomView.frame = CGRectMake(0,
                                       SCREEN_HEIGHT,
                                       SCREEN_WIDTH,
                                       45);
        _scrollview.frame = CGRectMake(0,
                                       _customNavigationBar.frame.origin.y+64 - _barOffsetY,
                                       SCREEN_WIDTH+6,
                                       SCREEN_HEIGHT);
        
       
           } completion:^(BOOL finished) {
        
    }];
}
-(void)scrollviewDown{
    
    [UIView animateWithDuration:0.5 animations:^{
        _customNavigationBar.frame = CGRectMake(0,
                                                _barOffsetY,
                                                [UIScreen mainScreen].bounds.size.width,
                                                64 - _barOffsetY);
      
        [_customNavigationBar fitSystem];
        _bottomView.frame = CGRectMake(0,
                                       SCREEN_HEIGHT - 45,
                                       SCREEN_WIDTH,
                                       45);
        _scrollview.frame = CGRectMake(0,
                                       64.0,
                                       SCREEN_WIDTH+6,
                                       self.view.frame.size.height-64-45);
    } completion:^(BOOL finished) {
        
    }];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.tag!=WEBTAG&&scrollView.tag!=TXTTAG) {
        idx = scrollView.contentOffset.x / (self.view.frame.size.width+6);
        CGFloat floatX = (NSInteger)scrollView.contentOffset.x % (NSInteger)(self.view.frame.size.width+6);
        NSInteger del = idx - 1;
        if (floatX > 0) {
            if (scrollView.contentOffset.x - (self.view.frame.size.width+6) * del < (self.view.frame.size.width+6) * idx - scrollView.contentOffset.x) {
                scrollView.contentOffset = CGPointMake(self.view.frame.size.width+6, 0);
            }
            else {
                scrollView.contentOffset = CGPointMake(self.view.frame.size.width+6, 0);
            }
            idx = scrollView.contentOffset.x / (self.view.frame.size.width+6);
            del = idx - 1;
        }
        [self scrollNextOrPre:del];
    }
}
-(void)scrollNextOrPre:(NSInteger)del{
    _zool =YES;
    if (del > 0) {
        _selected ++;
        UIWebView* web = [self.webArr objectAtIndex:0];
        web.scalesPageToFit=YES;
        if ([web isKindOfClass:[NSNumber class]]) {
            UIWebView* tmp = [[UIWebView alloc] init];
            tmp.frame=CGRectMake(self.view.frame.size.width*idx+idx*6,
                                 0,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
            
            
            tmp.tag = idx;
            tmp.delegate=self;
            [self.webArr replaceObjectAtIndex:0 withObject:tmp];
            web = tmp;
            [_scrollview addSubview:web];
        }
        //为title赋值
        if (_selected>=0&&_selected<_pathArray.count){
            FileBean * bean=[_pathArray objectAtIndex:_selected];
            _nowFile = bean;
            _customNavigationBar.title.text=bean.fileName;
            web.frame = CGRectMake(self.view.frame.size.width * 2+2*6, 0, web.frame.size.width, web.frame.size.height);
            
            [self.webArr removeObject:web];
            [self.webArr addObject:web];
            for (NSInteger i = 0 ; i < 2; i ++) {
                UIWebView* web = [self.webArr objectAtIndex:i];
                 web.frame = CGRectMake(self.view.frame.size.width *i+i*6, 0, web.frame.size.width, web.frame.size.height);
            }
            
        }
        
        if (_selected<_pathArray.count-1) {
           
            //清除之前的text
            if (_selected < _pathArray.count - 1) {
                FileBean * bean=[_pathArray objectAtIndex:(_selected + 1)];
                NSString * kind = [[bean.filePath pathExtension] lowercaseString];
                NSArray * array = [web subviews];
                if (array.count>0) {
                    for (int i = 0; i<array.count; i++) {
                        UITextView * text = [array objectAtIndex:i];
                        if ([text isKindOfClass:[UITextView class]]) {
                            [text removeFromSuperview];
                        }
                        
                    }
                }
                if ([[bean.fileName pathExtension]isEqualToString:DOCUMENT_TXT]) {
                    _firstbean =bean;
                    [_loadingViews show];
                   
                    
                }else{
                     [self performSelector:@selector(dismissTheView) withObject:self afterDelay:4.0];
                    _first = NO;
                }
    
                if([kind isEqualToString:DOCUMENT_TXT]){
                    
                    //优化
                    if (_selected>=2&&_pathArray.count>0) {
                        FileBean * removebean = [_pathArray objectAtIndex:_selected-2];
                        for (FileBean * bean in _queueArray) {
                            if ([bean isEqual:removebean]) {
                                [_queueArray removeObject:bean];
                            }
                        }
                        
                    }
                    
                    UITextView * text = [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    self.view.frame.size.width,
                                                                                    SCREEN_HEIGHT)];
                    text.editable=NO;
                    text.contentOffset = CGPointMake(0, 0);
                    text.tag = TXTTAG;
                    text.bounces=NO;
                    text.delegate=self;
                    [web addSubview:text];
                    
                    
                    [self addtext:bean first:NO];
                    
                }else if ([DOC_DIC objectForKey:kind]){
                    [web loadRequest:[self loadPdfAndOtherWebView:bean.filePath]];
                    _webbean = bean;
                    [_webloading show];
              
                    
                }
            }
            
        }
        
        _scrollview.contentOffset = CGPointMake(self.view.frame.size.width+6, 0);
        
        
    }
    else if (del < 0) {

        _selected --;
        UIWebView* web = [self.webArr objectAtIndex:2];
        web.scalesPageToFit=YES;
        web.delegate=self;
      
        web.frame = CGRectMake(self.view.frame.size.width * 0, 0, web.frame.size.width, web.frame.size.height);
        if (_selected>=0&&_selected<_pathArray.count) {
            FileBean * bean=[_pathArray objectAtIndex:_selected];
           _nowFile = bean;
            _customNavigationBar.title.text=bean.fileName;
            [self.webArr removeObject:web];
            if (web) {
                [self.webArr insertObject:web atIndex:0];
            }
            for (NSInteger i = 1 ; i < 3; i ++) {
                UIWebView* web = [self.webArr objectAtIndex:i];
                web.frame = CGRectMake(self.view.frame.size.width * i+i*6, 0, web.frame.size.width, web.frame.size.height);
            }
            
        }

        
        if (_selected>0) {
            if (_selected > 0&&_selected-1<_pathArray.count) {
                FileBean * bean=[_pathArray objectAtIndex:(_selected - 1)];
                NSString * kind = [[bean.filePath pathExtension] lowercaseString];
                NSArray * array = [web subviews];
                if (array.count>0) {
                    for (int i = 0; i<array.count; i++) {
                        UITextView * text = [array objectAtIndex:i];
                        if ([text isKindOfClass:[UITextView class]]) {
                            [text removeFromSuperview];
                        }
                        
                    }
                }
                if ([[bean.fileName pathExtension]isEqualToString:@"txt"]) {
                    _firstbean =bean;
                    [_loadingViews show];
                    
                }else{
                    [self performSelector:@selector(dismissTheView) withObject:self afterDelay:4.0];
                    _first = NO;
                }
                
             
                if([kind isEqualToString:DOCUMENT_TXT]){
                    //优化
                    if (_selected+2<_pathArray.count) {
                        FileBean * removebean = [_pathArray objectAtIndex:_selected+2];
                        for (FileBean * bean in _queueArray) {
                            if ([bean isEqual:removebean]) {
                                [_queueArray removeObject:bean];
                            }
                        }
                        
                    }
                    
                    UITextView * text = [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    self.view.frame.size.width,
                                                                                    SCREEN_HEIGHT)];
                    text.editable=NO;
                    text.contentOffset = CGPointMake(0, 0);
                    text.tag = TXTTAG;
                    text.bounces=NO;
                    text.delegate=self;
                    [web addSubview:text];
                    
                    [self addtext:bean first:NO];
                }else if ([DOC_DIC objectForKey:kind]){
                    [web loadRequest:[self loadPdfAndOtherWebView:bean.filePath]];
                
                    _webbean = bean;
                    [_webloading show];
                    
                }
            }
            
        }
        
        _scrollview.contentOffset = CGPointMake(self.view.frame.size.width+6, 0);
    }
    [[MusicPlayerViewController instance]removeNewIdentify:_nowFile.filePath];
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}


-(void)dismissTheView{

    [_loadingViews dismiss];

}
-(void)addtext:(FileBean *)bean first:(BOOL)first{
    
    _exist = NO;
    
    for (FileBean * tmp in _queueArray) {
        if ([tmp.filePath isEqualToString:bean.filePath]) {
            _exist = YES;
            break;
        }
      
    }
    if (_queueArray.count==1) {
        FileBean * beans = [_queueArray objectAtIndex:0];
        if ([beans.fileName isEqualToString:bean.fileName]) {
            if (!_isAction) {
                 [self addTextOnweb];
            }
            
        }
    }
    if(!_exist) {
        [_queueArray addObject:bean];
        
        if (!_isAction) {
            [self addTextOnweb];
           
        }
    }
    
}


-(void)addTextOnweb{
    
    _isAction = YES;
    
        dispatch_async(dispatch_queue_create(0, 0), ^{
            FileBean *bean = [_queueArray firstObject];
            NSString * body = nil;
            if ([bean.filePath hasPrefix:KE_PHOTO] || [bean.filePath hasPrefix:KE_VIDEO] || [bean.filePath hasPrefix:KE_MUSIC] || [bean.filePath hasPrefix:KE_DOC]|| [bean.filePath hasPrefix:KE_ROOT] ){
                body =  [[NSString alloc] initWithData:[FileSystem  kr_readData:bean.filePath]  encoding:0x80000632];
                if (body==nil) {
                    body =  [[NSString alloc] initWithData:[FileSystem  kr_readData:bean.filePath]  encoding:NSUTF8StringEncoding];
                }
                
            }else{
                body = [NSString stringWithContentsOfFile:bean.filePath encoding:0x80000632 error:nil];
                if (body==nil) {
                    body =  [[NSString alloc] initWithData:[FileSystem  kr_readData:bean.filePath]  encoding:NSUTF8StringEncoding];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
               
                NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                [dic setValue:body forKey:@"body"];
                [dic setValue:bean forKey:@"bean"];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"body" object:dic];
                
                if (_queueArray.count>1) {
                    if ([_queueArray containsObject:bean]) {
                        [_queueArray removeObject:bean];
                    }
                    [self addTextOnweb];
                }else{
                    _isAction = NO;
                }
            });
        });

}
-(void)deleterefreshtitle{
    
    if (_selected < _pathArray.count) {
        if (_selected<_pathArray.count) {
            FileBean * tmp =[_pathArray objectAtIndex:_selected];
            _customNavigationBar.title.text= tmp.fileName;
        }
    }

}
-(void)getPath:(FileBean *)bean pathArray:(NSArray *)array{
    if (array.count==0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSMutableArray * dealArray = [NSMutableArray array];
    for (FileBean * bean in array) {
        FilePropertyBean * proporty = [FileSystem readFileProperty:bean.filePath];
        float size = proporty.size/1024.0/1024.0;
        if (size<=80.0) {
            [dealArray addObject:bean];
        }
    }
    array = dealArray;
   
    if ([[bean.fileName pathExtension]isEqualToString:@"txt"]) {
        
        _firstbean =bean;
        _clickrow = [array indexOfObject:bean];
    }else{
        _first = NO;
        _webbean =bean;
    }
    
    if(array.count!=_beforedelete&&_pathArray.count!=0){
        _delete=YES;
    }
    if (_pathArray.count==0) {
        
        _nowFile=bean;
        [_queueArray removeAllObjects];
    }

    _beforedelete = array.count;
    _pathArray=array;
    
    if (array.count==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.webArr.count!=0) {
        [self.webArr removeAllObjects];
    }
     self.webArr = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0], nil];
       if (bean!=nil) {
        _selected=[_pathArray indexOfObject:bean];
    }else{
        if (_selected==_pathArray.count) {
            _selected=_pathArray.count-1;
        }
        [self deleterefreshtitle];
    }
    if (_delete) {
        if (_selected<_pathArray.count) {
            _nowFile=[_pathArray objectAtIndex:_selected];
            _firstbean = _nowFile;
            [_queueArray removeAllObjects];
        }
    }

    for (NSInteger i = 0 ; i < 3; i ++) {
        NSInteger idX = i;
        UIWebView * web = [[UIWebView alloc] init];
        web.frame=CGRectMake(self.view.frame.size.width*idX+idX*6,
                             0,
                             self.view.frame.size.width,
                             SCREEN_HEIGHT);
        web.delegate = self;
     
        web.scrollView.tag =WEBTAG;
    
        web.scrollView.delegate=self;
        web.tag = idx;
        web.scalesPageToFit=YES;
        NSArray * array = [web subviews];
        if (array.count>0) {
            for (int i = 0; i<array.count; i++) {
                UITextView * text = [array objectAtIndex:i];
                if ([text isKindOfClass:[UITextView class]]) {
                    [text removeFromSuperview];
                }
                
            }
        }

        if (i+_selected-1<_pathArray.count&&i+_selected-1>=0) {
            FileBean * bean=[_pathArray objectAtIndex:i+ _selected-1];
           
            NSString * kind = [[bean.filePath pathExtension] lowercaseString];
            if([kind isEqualToString:DOCUMENT_TXT]){
                
               
                UITextView * text = [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                self.view.frame.size.width,
                                                                                SCREEN_HEIGHT)];
                text.editable=NO;
                text.contentOffset = CGPointMake(0, 0);
                text.tag = TXTTAG;
                text.delegate =self;
                text.bounces = NO;
                [web addSubview:text];
               
                    if ([bean isEqual:_firstbean]) {
                        [self addtext:bean first:NO];
                        
                        [_loadingViews show];
                       
                    }else{
                        [self addtext:bean first:YES];
                    }
            }else if ([DOC_DIC objectForKey:kind]){
                [web loadRequest:[self loadPdfAndOtherWebView:bean.filePath]];
             
                if ([_webbean.fileName isEqualToString:bean.fileName]) {
                    [_webloading show];
                }
            }
        }else if(i+_index==_pathArray.count&&_pathArray.count>0){
            FileBean* bean=[_pathArray objectAtIndex:0];
            _nowFile = bean;
             NSString * kind = [[bean.filePath pathExtension] lowercaseString];
            if([kind isEqualToString:DOCUMENT_TXT]){
                UITextView * text = [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                self.view.frame.size.width,
                                                                                web.frame.size.height-12)];
                text.editable=NO;
                text.contentOffset = CGPointMake(0, 0);
                text.tag = TXTTAG;
                text.delegate =self;
                text.bounces=NO;
                [web addSubview:text];
                
                if ([bean isEqual:_firstbean]) {
                    [self addtext:bean first:NO];
                    [_loadingViews show];
                }else{
                    [self addtext:bean first:YES];
                }
            }else if ([DOC_DIC objectForKey:kind]){
                [web loadRequest:[self loadPdfAndOtherWebView:bean.filePath]];
              
                if ([_webbean.fileName isEqualToString:bean.fileName]) {
                    [_webloading show];
                }
            }
        }
        
        [_scrollview addSubview:web];
        [self.webArr replaceObjectAtIndex:idX withObject:web];
        _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
    if (_delete) {
        if (edit) {
            [self browsestate];
        }else{
            [self readstate];
        }
    }
    _delete =NO;
}

-(NSURLRequest*)loadPdfAndOtherWebView:(NSString *)path{
    NSURL *url = [FileSystem changeURL:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    return request;
}

-(NSString*)loadTxtWebView:(FileBean *)bean{
   
    NSData * data=bean.fileData;
    NSString *body = [self readStr:data];
    
    if (!body) {
        body = [NSString stringWithContentsOfFile:bean.filePath encoding:0x80000632 error:nil];
    }
    if (!body) {
        body = [NSString stringWithContentsOfFile:bean.filePath encoding:0x80000631 error:nil];
    }
    NSString *jsString;
    if (body) {
        NSString *htmlText = [body stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        jsString = [NSString stringWithFormat:@"<html> \n"
                              "<head> \n"
                              "<style type=\"text/css\"> \n"
                              "body {font-size: %f; font-family: \"%@\"; color: %@;}\n"
                              "</style> \n"
                              "</head> \n"
                              "<body>%@</body> \n"
                              "</html>", 15.0*WINDOW_SCALE, @"宋体", @"黑色", htmlText];
        
    }
    return jsString;
    return body;

}
-(NSString*)readStr:(NSData*)data{

    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSArray * ary = [NSArray arrayWithObjects:[NSNumber numberWithInt:NSUTF8StringEncoding], [NSNumber numberWithInt:gbkEncoding], [NSNumber numberWithInt:NSASCIIStringEncoding], nil];
    for (NSNumber *encoding in ary) {
        
        NSString *str = [self encodeStr:data encoding:[encoding intValue]];
        if(str)
            return str;
    }
    
    NSLog(@"字符串读取失败");
    return nil;

}
- (NSString *)encodeStr:(NSData *)strData encoding:(NSStringEncoding)encoding{
    
    return [[NSString alloc] initWithData:strData encoding:encoding];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if (_webbean&&[[FileSystem changeURL:_webbean.filePath].absoluteString isEqual:webView.request.URL.absoluteString] ) {
        [_webloading dismiss];
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
   
//    NSInteger code = error.code;
    [_webloading dismiss];
//    NSLog(@"_webbean:%@  ;webView:%@  filepath:%@  localizedDescription:%@  localizedFailureReason:%@  code:%ld",[FileSystem changeURL:_webbean.filePath].absoluteString ,webView.request.URL.absoluteString,_webbean.filePath,error.localizedDescription,error.localizedFailureReason,(long)code);
//    
    if (_webbean&&[[FileSystem changeURL:_webbean.filePath].absoluteString isEqual:webView.request.URL.absoluteString] ) {
        [webView loadHTMLString:@"" baseURL:nil];
        _alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"loadfailed", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"again", @""), nil];
       _alert.tag = 898;
        [_alert show];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{

    _moving = NO;
    int current = scrollView.contentOffset.y;
    if (current>=0&&current<=scrollView.contentSize.height-SCREEN_HEIGHT){
        _zool = YES;
    }else{
        _zool = NO;
    }
      
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{

    _moving =YES;
    int current = scrollView.contentOffset.y;
    if (current>=0&&current<=scrollView.contentSize.height-SCREEN_HEIGHT){
        _zool = YES;
    }else{
        _zool = NO;
    }


}

#pragma mark - uidocument delegate


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
