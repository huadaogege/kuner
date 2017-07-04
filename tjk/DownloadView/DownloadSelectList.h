//
//  DownloadSelectList.h
//  tjk
//
//  Created by huadao on 15/10/13.
//  Copyright (c) 2015年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "BottomEditView.h"
#import "DownloadTask.h"

@protocol DownloadSelectListDelegate <NSObject>

-(void)downloadJuJiFileWith:(NSDictionary *)dict type:(int)type;
-(void)downloadJuJiFileWithArray:(NSArray *)array type:(int)type;

@end

@interface DownloadSelectList : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,NavBarDelegate,BottomEditViewDelegate>

@property (nonatomic,assign) int restype;
@property (nonatomic,assign) int videotype;

@property (nonatomic,strong) NSArray * dataArray;

@property (nonatomic,strong) NSString * listurl;

-(id)initWithType:(int)restype setdataArray:(NSArray *)dataArray listurl:(NSString *)url;

@property (nonatomic,assign) id<DownloadSelectListDelegate> downselectdelegate;
@end
