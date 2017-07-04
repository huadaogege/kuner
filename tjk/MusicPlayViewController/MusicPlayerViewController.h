//
//  MusicPlayerViewController.h
//  tjk
//
//  Created by huadao on 14-12-2.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TGK_FFPlayerViewController.h"
#import "CustomMusicPlayer.h"
#import "CustomSliderView.h"
//#import "GetFileInfo.h"
#import "CustomNavigationBar.h"
#import "CustomFileManage.h"
#import "FileBean.h"
#import "ScanFileDelegate.h"
#import "FileOperate.h"
#import "CustomNotificationView.h"
#import "DownloadManager.h"

#define NOWMUSICPLAYBEAN @"Music_Playing"
#define PLAYMUSIC @"PlayMusic"


@interface MusicPlayerViewController : UIViewController<CustomFileBeanDelegate,CustomSliderDelegate,UIGestureRecognizerDelegate,NavBarDelegate,UIAlertViewDelegate,OperateFiles>
{
    int                              state;//播放模式状态
    FileOperate                   * _operation;
    dispatch_queue_t                _dispatchQueue;
    NSInteger                        nowrow;//列表中当前播放的歌曲位置
    BOOL                            _iskuke;//是否是酷壳里音乐
    NSString                      *  documentsDirectory;
    BOOL                            _deletenext;//是否是删除歌曲之后播的下一首
    BOOL                            _movPlay;// 播放视频时候防止音乐回调调起
    BOOL                            _copyfinish;//是否拷贝完成
    BOOL                            _conflict; //控制台操作后台音乐播放时防止引起音乐播放完成回调
    BOOL                            _isplayerview;//判断删除的时候是否在音乐播放界面
    BOOL                            _setdisk; // 设置u盘模式操作
    UIView                        * _noneSongView;//歌曲背景视图
    UIImage                       * _songImage;   //背景图片
    BOOL                            _has;//是否有图片
    UILabel                       * _cancelVolumelabel;
    UIButton                      * _cancelVolumebutton; //音量界面取消按钮
    UIImageView                   * _volumeImage;
    UIView                        * _line;//音量线
    BOOL                            _isvolume;
    FileBean                      * _prepareBean;//下一首要播放的音乐
    int                              playModelIdentify;
    BOOL                             playlastsong;
    FileBean                      * _lastsong;
   
}
@property(nonatomic,retain)NSString                    * nowSongs;//歌曲路径
@property(nonatomic,retain)UIImageView                 * songImageView;//模糊背景图
@property(nonatomic,retain)FileBean                    * currentBean;
@property(nonatomic,retain)CustomSliderView            * progress;
@property(nonatomic,retain)CustomSliderView            * volumeSlider;
@property(nonatomic,retain)UIButton                    * playBtn;
@property(nonatomic,retain)UIButton                    * previou;
@property(nonatomic,retain)UIButton                    * nextt;
@property(nonatomic,retain)UIButton                    * deletee;
@property(nonatomic,retain)UIImageView                 * iconView;//专辑封面
@property(nonatomic,retain)UILabel                     * musicName;
@property(nonatomic,retain)UILabel                     * singerName;
@property(nonatomic,retain)UILabel                     * currentTime;
@property(nonatomic,retain)UILabel                     * TotalTime;
@property(nonatomic,retain)UIButton                    * changePlayModel;
@property(nonatomic,retain)UIImageView                 * changeimage;
@property(nonatomic,retain)CustomNavigationBar         * customNavigationBar;
@property(nonatomic,strong)NSMutableDictionary         * noplayMusicplistDict;
@property(nonatomic,copy)NSMutableArray                * nowPlayList;
@property(nonatomic,copy)NSString                      * musicname;
@property(nonatomic,assign)BOOL                         fromRoot;


+(MusicPlayerViewController *)instance;
-(void)setTitle:(NSString *)title
           Icon:(UIImage *)image
      musicName:(NSString *)musicName
     singerName:(NSString *)singerName hasimage:(BOOL)has;

-(void)setNowTime:(float)nowTime
        countTime:(float)countTime;
-(FileBean *)getCurrentBean;
-(void)addobservers;
-(void)removeobservers;
-(void)playorpause;
-(void)setdisk:(BOOL)disk;
-(void)setNoneMusicViewHidden:(BOOL)hidden;

@property (nonatomic,assign) id <ScanFileDelegate>scanDelegate;

-(void)setDeleteState:(BOOL)states;
-(void)setMovPlay:(BOOL) movplay;
-(void)avoidconflict:(BOOL)conflict;
-(void)checkthesong;
//获取列表中的歌曲路径
-(void)setArray:(NSArray *)Ary;
-(void)getTheLastSong:(FileBean *)bean LastSongList:(NSArray *)List;
-(void)setSongPath:(FileBean *)bean kuke:(BOOL)iskuke;

-(void)deletefinishrefresh:(NSArray *)array deletenowplay:(BOOL)deletenowplay;
-(void)resetPlayArray;
//播放操作
-(void)previous:(BOOL)hand;
-(void)next:(BOOL)hand;
-(void)onerun;
-(void)randomrun;

-(void)removeNewIdentify:(NSString *)filepath;
-(void)writeNewPath:(NSString *)newpath;
@end
