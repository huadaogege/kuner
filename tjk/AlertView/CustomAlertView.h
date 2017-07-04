#import <UIKit/UIKit.h>


@interface CustomAlertView : UIView{
    
    UIWindow            *_backWindow;
    UIView              *_alphaView;
    UIView              *_formsView;
    UILabel             *_formsMsgLabel;
    UIView              *_progressEmptyView;
    UIView              *_progressFullView;
    NSString            *msg;
}

-(void) showProgress;
-(void) showMsg;
-(void) hidden;
-(void) setMsg:(NSString *)str;
-(void) setFilesCount:(int)allCount;
-(void) setNowNum:(int)num;

@end
