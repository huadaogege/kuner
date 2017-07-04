
#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "FileBean.h"
#import "CustomFileManage.h"
#import "BottomEditView.h"
#import "ScanFileDelegate.h"
#import "FileSystem.h"
@interface PreviewViewController : UIViewController<NavBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,BottomEditViewDelegate>



@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger nowPhotoNum;
@property (nonatomic, assign) BOOL  isFromDown;
@property (assign) id <ScanFileDelegate>scanDelegate;
@property (assign) BOOL isPresentView;

-(void)allPhotoArr:(NSMutableArray*)allArr nowNum:(NSInteger)nowNum fromDownList:(BOOL)isDowned;
-(void)removeOverReloadArray:(NSArray*)arr;
-(UIInterfaceOrientation)getOrientation;
-(BOOL)showingShareUI;
@end
