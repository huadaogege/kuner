#import <UIKit/UIKit.h>

#define CUSTUM_ALERT_ATG 444

#define CUSTOMALERTSHOWPROGRESS @"CUSTOMALERTSHOWPROGRESS"

typedef NS_ENUM(NSInteger, CustomAlertType) {
    Alert_Hidden = -1,
    Alert_Normal = 0,
    Alert_Delete = 1,
    Alert_Copy = 2,
    Alert_PhotoIn = 3,
    Alert_PhotoOut  = 4,
};

@interface CustomAlertView : UIView{
    UIView              *_alphaView;
    UIView              *_formsView;
    UILabel             *_formsMsgLabel;
    UILabel             *_progressLabel;
    UIView              *_progressEmptyView;
    UIView              *_progressFullView;
    int                 _allCount;
    int                 _nowNumber;
    UIButton            *_cancelBtn;
}

+(CustomAlertView *)instance;

@property(nonatomic,assign) CustomAlertType alertType;
@property(nonatomic,assign) BOOL notshowcancelBtn;
//是否显示
-(BOOL)hasShown;

//展示带进度条的alert
-(void) showProgress;
//展示仅带文字的alert
-(void) showMsg;
//隐藏
-(void) hidden;
//设置提示文字
-(void) setMsg:(NSString *)str;
//设置执行总数量
-(void) setFilesCount:(int)allCount;
//得到执行总数量
-(int) getFilesCount;
//设置执行的当前数量
-(void) setNowNum:(int)num;
-(void)setNowNum:(int)num fileName:(NSString *)filaname;
-(void) setNowNum:(int)num currentSize:(float)currentSize allSize:(float)allSize;
-(void)setNowCountSize:(float)countsize;
//设置进度条
-(void) progress:(float)pro;

@end
