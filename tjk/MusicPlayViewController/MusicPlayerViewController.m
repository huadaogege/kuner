//
//  MusicPlayerViewController.m
//  tjk
//
//  Created by huadao on 14-12-2.
//  Copyright (c) 2014年 taig. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "AppDelegate.h"
#import "MusicListVC.h"
#import "UIImage+ImageEffects.h"
#import <Accelerate/Accelerate.h>
#import "MobClickUtils.h"
#import "LogUtils.h"
#import "Context.h"
#define DELETE_ITEM_ALERT_TAG   555
#define NEXT 22222
#define ACTION_DONE @"ACTION_DONE"

#define FIRST @"first"
#define SECOND @"second"
#define THIRD @"third"
#define TIPS 33333

@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController
static  MusicPlayerViewController * player=nil;
+(MusicPlayerViewController *)instance
{
    if (!player) {
        player=[[MusicPlayerViewController alloc]init];
        
    }
    return player;
}
-(id)init
{
    self=[super init];
    if (self) {
        self.noplayMusicplistDict = [NSMutableDictionary dictionary];
        documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/musiccache"];
        NSString * paths = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
        NSFileManager * manger = [NSFileManager defaultManager];
        if ([manger fileExistsAtPath:paths]) {
            self.noplayMusicplistDict = [NSMutableDictionary dictionaryWithContentsOfFile:paths];
        }
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        
        _nowSongs=[[NSString alloc]init];
        
        _musicname=[[NSString alloc]init];
        _musicName = [[UILabel alloc] init];
        _musicName.textColor = [UIColor whiteColor];
        _musicName.textAlignment=NSTextAlignmentCenter;
        _musicName.font = [UIFont systemFontOfSize:17*WINDOW_SCALE];
        
        _singerName = [[UILabel alloc] init];
        _singerName.textColor = [UIColor whiteColor];
        _singerName.textAlignment=NSTextAlignmentCenter;
        _singerName.font = [UIFont systemFontOfSize:14*WINDOW_SCALE];
        
        _customNavigationBar = [[CustomNavigationBar alloc] init];
        _customNavigationBar.delegate = self;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_musiclist" bundle:@"TAIG_Photo_Mov"]];
        imgView.frame = CGRectMake(24*WINDOW_SCALE, 12*WINDOW_SCALE, 24*WINDOW_SCALE_SIX, 24*WINDOW_SCALE_SIX);
        [_customNavigationBar.rightBtn setTitle:@"" forState:UIControlStateNormal];
        [_customNavigationBar.rightBtn addSubview:imgView];
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
   
    _setdisk = NO;
    _deletenext=NO;//删除歌曲的时候防止引起音乐播放完成回调
    _movPlay = NO; //播放视频时候防止引起音乐播放完成回调
    _conflict = NO;//控制台操作后台音乐播放时防止引起音乐播放完成回调
    _copyfinish = YES; //音乐即将拷贝和拷贝完成变换值，防止频繁操作
    
    self.view.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:54.0/255.0 blue:62.0/255.0 alpha:1.0];
    self.view.clipsToBounds=YES;
    self.view.backgroundColor = BASE_COLOR;
    
    _progress = [[CustomSliderView alloc] init];
    _progress.delegate = self;
    _progress.changeVolume = NO;
    
    _volumeSlider = [[CustomSliderView alloc]init];
    _volumeSlider.delegate =self;
    _volumeSlider.changeVolume = YES;
  
    _currentTime = [[UILabel alloc] init];
    _currentTime.textColor = [UIColor whiteColor];
    _currentTime.textAlignment=NSTextAlignmentCenter;
    _currentTime.font = [UIFont systemFontOfSize:8*WINDOW_SCALE];
    
    _TotalTime = [[UILabel alloc] init];
    _TotalTime.textColor = [UIColor whiteColor];
    _TotalTime.textAlignment=NSTextAlignmentCenter;
    _TotalTime.font = [UIFont systemFontOfSize:8*WINDOW_SCALE];
    
    _currentTime.text=@"00:00";
    _TotalTime.text=@"00:00";
    
    _playBtn = [[UIButton alloc] init];
    [_playBtn setBackgroundImage:[UIImage imageNamed:[[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]?@"icon_stop.png":@"icon_play.png" bundle:@"TAIG_LEFTVIEW.bundle"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playorpause) forControlEvents:UIControlEventTouchUpInside];
    
    
    _previou=[[UIButton  alloc]init];
    [_previou setBackgroundImage:[UIImage imageNamed:@"icon_on.png"bundle:@"TAIG_LEFTVIEW.bundle"] forState:UIControlStateNormal];
    [_previou addTarget:self action:@selector(previousSong) forControlEvents:UIControlEventTouchUpInside];
    
    
    _nextt=[[UIButton alloc]init];
    [_nextt setBackgroundImage:[UIImage imageNamed:@"icon_next.png"bundle:@"TAIG_LEFTVIEW.bundle"] forState:UIControlStateNormal];
    [_nextt addTarget:self action:@selector(nextsong) forControlEvents:UIControlEventTouchUpInside];
    
    
    _deletee=[[UIButton alloc]init];
    [_deletee setBackgroundImage:[UIImage imageNamed:@"music_icon_2.png" bundle:@"TAIG_LEFTVIEW.bundle"] forState:UIControlStateNormal];
    [_deletee addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    
    _changePlayModel=[[UIButton alloc]init];
    _changeimage = [[UIImageView alloc]init];
    [_changePlayModel addTarget:self action:@selector(changeplaymodel) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults * playModel = [NSUserDefaults standardUserDefaults];
    NSString * states = [playModel objectForKey:@"playmodel"];
    
    if (states) {
       if ([states isEqualToString:NSLocalizedString(@"playmusicone", @"")]){
            _changeimage.image=[UIImage imageNamed:@"icon_play_one.png" bundle:@"TAIG_LEFTVIEW.bundle"];
            state=456;
           playModelIdentify =1;
   
        }else if ([states isEqualToString:NSLocalizedString(@"playmusicrandom", @"")]){
            _changeimage.image=[UIImage imageNamed:@"icon_play_random.png" bundle:@"TAIG_LEFTVIEW.bundle"];
            state=789;
            playModelIdentify = 2;
        }else {
            _changeimage.image=[UIImage imageNamed:@"icon_play_list.png" bundle:@"TAIG_LEFTVIEW.bundle"];
            state = 123;
            playModelIdentify = 0;
        }
        
    }else{
        playModelIdentify = 0;
        state = 123;
        _changeimage.image=[UIImage imageNamed:@"icon_play_list.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    }
    
    _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
    
     CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    
      _songImageView = [[UIImageView alloc] init];
    if (_has) {
         UIImage * blurredImage = [_songImage applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.f maskImage:nil];
        _songImageView.image = blurredImage;
    }
    _songImageView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:54.0/255.0 blue:62.0/255.0 alpha:1.0];
    _songImageView.frame = CGRectMake(-(SCREEN_HEIGHT-(_customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height)-SCREEN_WIDTH)/2.0,
                                 _customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height,
                                 SCREEN_HEIGHT-(_customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height),
                                 SCREEN_HEIGHT-(_customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height));
    
    
    _iconView.frame = CGRectMake(0,
                                 _customNavigationBar.frame.origin.y+_customNavigationBar.frame.size.height,
                                 self.view.frame.size.width,
                                 self.view.frame.size.width);
    _musicName.frame = CGRectMake((self.view.frame.size.width-200*WINDOW_SCALE)*0.5,
                                  _iconView.frame.origin.y+_iconView.frame.size.height+15.0,
                                  200*WINDOW_SCALE,
                                  18*WINDOW_SCALE);
    _singerName.frame=CGRectMake((self.view.frame.size.width-150*WINDOW_SCALE)*0.5,
                                 _musicName.frame.origin.y+_musicName.frame.size.height+7.5*WINDOW_SCALE,
                                 150*WINDOW_SCALE,
                                 15*WINDOW_SCALE);
    
    
    _progress.frame =CGRectMake((self.view.frame.size.width-230*WINDOW_SCALE)*0.5,
                                _singerName.frame.origin.y+_singerName.frame.size.height+15*WINDOW_SCALE,
                                230*WINDOW_SCALE,
                                20*WINDOW_SCALE);
    
    _volumeSlider.frame = CGRectMake(41.0*WINDOW_SCALE,
                                     _singerName.frame.origin.y+_singerName.frame.size.height+15*WINDOW_SCALE,
                                     250*WINDOW_SCALE,
                                     20*WINDOW_SCALE);
    _currentTime.frame = CGRectMake(5,
                                    _progress.frame.origin.y,
                                    40*WINDOW_SCALE,
                                    20*WINDOW_SCALE);
    _TotalTime.frame=CGRectMake(self.view.frame.size.width-40*WINDOW_SCALE,
                                _progress.frame.origin.y,
                                40*WINDOW_SCALE,
                                20*WINDOW_SCALE);
    
    _playBtn.frame = CGRectMake((self.view.frame.size.width-50*WINDOW_SCALE)*0.5,
                                _progress.frame.origin.y+_progress.frame.size.height+29*WINDOW_SCALE,
                                50*WINDOW_SCALE,
                                50*WINDOW_SCALE);
    _previou.frame=CGRectMake(_playBtn.frame.origin.x-73.0*WINDOW_SCALE/2.0-40*WINDOW_SCALE,
                              _progress.frame.origin.y+_progress.frame.size.height+34*WINDOW_SCALE,
                              40*WINDOW_SCALE,
                              40*WINDOW_SCALE);
    _nextt.frame=CGRectMake(_playBtn.frame.origin.x+_playBtn.frame.size.width+73.0*WINDOW_SCALE/2.0,
                            _progress.frame.origin.y+_progress.frame.size.height+34*WINDOW_SCALE,
                            40*WINDOW_SCALE,
                            40*WINDOW_SCALE);
    _deletee.frame=CGRectMake(15,
                              _previou.frame.origin.y+9*WINDOW_SCALE,
                              22*WINDOW_SCALE,
                              22*WINDOW_SCALE);
    
    _changeimage.frame=CGRectMake(self.view.frame.size.width-37*WINDOW_SCALE,
                                  _nextt.frame.origin.y+9*WINDOW_SCALE,
                                  22*WINDOW_SCALE,
                                  22*WINDOW_SCALE);
    
    _changePlayModel.frame=CGRectMake(self.view.frame.size.width-40*WINDOW_SCALE,
                                      _nextt.frame.origin.y+6*WINDOW_SCALE,
                                      32*WINDOW_SCALE,
                                      28*WINDOW_SCALE);
    
    
    _noneSongView = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                            64,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height-64)];
    
    _noneSongView.backgroundColor = [UIColor whiteColor];
    _noneSongView.hidden = YES;
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200.0*WINDOW_SCALE_SIX)/2.0,
                                                                           140.0*WINDOW_SCALE_SIX,
                                                                           200.0*WINDOW_SCALE_SIX,
                                                                           180.0*WINDOW_SCALE_SIX)];
    imageview.image = [UIImage imageNamed:@"icon_musicplay_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    
 
    
    
    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-200.0*WINDOW_SCALE_SIX)/2.0,
                                                                      imageview.frame.origin.y+80*WINDOW_SCALE_SIX,
                                                                      200.0*WINDOW_SCALE_SIX,
                                                                      50.0*WINDOW_SCALE_SIX)];
    image.image = [UIImage imageNamed:@"btn_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    UILabel * labels = [[UILabel alloc]initWithFrame:image.frame];
    labels.textAlignment = NSTextAlignmentCenter;
    labels.text = NSLocalizedString(@"gofindmusic", @"");
    labels.font = [UIFont systemFontOfSize:17.0*WINDOW_SCALE_SIX];
    if ([FileSystem isChinaLan]) {
        [_noneSongView addSubview:imageview];
    }
    else
    {
        [_noneSongView addSubview:labels];
    }
    
    UIButton * btn = [[UIButton alloc]initWithFrame:image.frame];
    [btn addTarget:self action:@selector(goToMusic) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_customNavigationBar];
    [self.view addSubview:_songImageView];
  
    [self.view addSubview:_iconView];
    [self.view addSubview:_musicName];
    [self.view addSubview:_progress];
    [self.view addSubview:_currentTime];
    [self.view addSubview:_TotalTime];
    [self.view addSubview:_playBtn];
    
    [self.view addSubview:_previou];
    [self.view addSubview:_nextt];
    
    [self.view addSubview:_deletee];
    [self.view addSubview:_changeimage];
    [self.view addSubview:_changePlayModel];
    
    [self addobservers];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sliderr) name:@"slider" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(failandnext) name:@"failandnext" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kunerOn:) name:DEVICE_NOTF object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changenext) name:@"changenext" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadCompelete) name:DOWNCOMPELETE_NOTI object:nil];
    
    [self checkthesong];
    
    //音量调节
    [self.view addSubview:_volumeSlider];
    _volumeSlider.hidden = YES;
    
    _cancelVolumelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-45*WINDOW_SCALE, SCREEN_WIDTH, 45*WINDOW_SCALE)];
    _cancelVolumelabel.text = NSLocalizedString(@"cancel",@"取消");
    _cancelVolumelabel.font = [UIFont systemFontOfSize:17*WINDOW_SCALE];
    _cancelVolumelabel.textColor = [UIColor whiteColor];
    _cancelVolumelabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_cancelVolumelabel];
    _cancelVolumelabel.hidden = YES;
    
    _cancelVolumebutton = [[UIButton alloc]initWithFrame:_cancelVolumelabel.frame];
    [_cancelVolumebutton addTarget:self action:@selector(cancelVolume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelVolumebutton];
    _cancelVolumebutton.hidden =YES;
    _volumeImage = [[UIImageView alloc]initWithFrame:CGRectMake(21*WINDOW_SCALE, _volumeSlider.frame.origin.y+2.0*WINDOW_SCALE, 11*WINDOW_SCALE, 15*WINDOW_SCALE)];
    _volumeImage.image = [UIImage imageNamed:@"music_icon_1.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    [self.view addSubview:_volumeImage];
    _volumeImage.hidden = YES;
    _line = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-46*WINDOW_SCALE, SCREEN_WIDTH, 1.0*WINDOW_SCALE)];
    _line.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:50.0/255.0 blue:42.0/255.0 alpha:1.0];
    _line.hidden =YES;
    [self.view addSubview:_line];
    [self.view addSubview:_noneSongView];
   
}

-(void)removeNewIdentify:(NSString *)filepath{
    
    NSString * paths = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic = self.noplayMusicplistDict;
    if (dic.count>0) {
        if ([dic objectForKey:filepath]) {
            [dic removeObjectForKey:filepath];
            self.noplayMusicplistDict = dic;
            [dic writeToFile:paths atomically:YES];
          
        }
    }
}

-(void)writeNewPath:(NSString *)newpath{
    
    NSString * paths = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic = self.noplayMusicplistDict;
    [dic setObject:@"1" forKey:newpath];
    self.noplayMusicplistDict = dic;
    [dic writeToFile:paths atomically:YES];
    
}

-(void)nextsong{
    
    [self next:YES];
}
-(void)previousSong{
    
    [self previous:YES];
}
//获取当前音量信息
-(float) getVolumeLevel
{
    return [[MPMusicPlayerController applicationMusicPlayer] volume];
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self cancelVolume];
}
-(void)cancelVolume{
    _isvolume = NO;
    self.progress.hidden = NO;
    self.musicName.hidden = NO;
    self.currentTime.hidden = NO;
    self.TotalTime.hidden = NO;
    self.nextt.hidden = NO;
    self.previou.hidden = NO;
    self.playBtn.hidden = NO;
    self.deletee.hidden =NO;
    self.changePlayModel.hidden = NO;
    self.changeimage.hidden =NO;
    _volumeSlider.hidden = YES;
    _cancelVolumebutton.hidden = YES;
    _cancelVolumelabel.hidden = YES;
    _volumeImage.hidden =YES;
    _line.hidden = YES;

}
-(void)goToMusic{

    [self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gotomusic" object:nil];
}

-(void)getTheLastSong:(FileBean *)bean LastSongList:(NSArray *)List{
    
    playlastsong = YES;
    [self setArray:List];
    _lastsong = bean;
    NSString * musicpath=[[NSString stringWithString:documentsDirectory]stringByAppendingPathComponent:[bean.filePath lastPathComponent]];
    [[CustomMusicPlayer shareCustomMusicPlayer]playerMusic:bean path:musicpath];
}

-(void)checkthesong{
    if (self.nowPlayList.count>0){
        _noneSongView.hidden = YES;
    }else{
        [self setNoneMusicViewHidden:NO];
    }
}

-(void)changenext{
    [self next:NO];
}
-(void)kunerOn:(NSNotification * )noti{
    if ([noti.name isEqualToString:DEVICE_NOTF]) {
        //断开。连接
        if ([noti.object intValue] == CU_NOTIFY_DEVCON) {
            _noneSongView.hidden = _nowPlayList.count!=0;
            
        }else if ([noti.object intValue] == CU_NOTIFY_DEVOFF){
            
            if (_iskuke) {
                [self setdisk:YES];
                
                [LogUtils writeLog:@"断壳111"];
                [self setNoneMusicViewHidden:NO];
                
                if (_nowPlayList.count>0) {
                    [_nowPlayList removeAllObjects];
                    _currentBean=nil;
                }
                [self endControlDelay];
                [self performSelector:@selector(endControlDelay) withObject:nil afterDelay:0.5];
            }
            [[CustomMusicPlayer shareCustomMusicPlayer]pause];
        }
    }
}
-(void)endControlDelay{
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
}

//音乐播放完成方法中避免冲突
-(void)avoidconflict:(BOOL)conflict{
    _conflict = conflict;
}
-(void)setMovPlay:(BOOL) movplay{

    _movPlay = movplay;
}
-(void)setDeleteState:(BOOL)states{

    _deletenext = states;
}
//////////////////////////////////////
-(void)failandnext{
  
    [self next:NO];
}

#pragma mark - nav bar delegate

-(void)clickLeft:(UIButton *)leftBtn{
    
    if (self.scanDelegate && [self.scanDelegate respondsToSelector:@selector(scanedItemWith:)]) {
        [self.scanDelegate scanedItemWith:_currentBean];
    }
    if (self.fromRoot) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)clickRight:(UIButton *)leftBtn
{
    if (_nowPlayList == nil || _nowPlayList.count == 0) {
        return;
    }
    _customNavigationBar.rightBtn.userInteractionEnabled = NO;
    MusicListVC *vc = [[MusicListVC alloc] init];
    vc.musicList = _nowPlayList;
    [self.navigationController pushViewController:vc animated:YES];
    [self performSelector:@selector(rightBtnClickDone) withObject:nil afterDelay:.5];
}

-(void)rightBtnClickDone
{
    _customNavigationBar.rightBtn.userInteractionEnabled = YES;
}

#pragma mark -

-(void)sliderr{//暂停状态下滑动进度条的时候播放，然后改变播放按钮的状态

    [self playorpause];

}
-(FileBean *)getCurrentBean{
    return _currentBean;
}
//调节音量
-(void)delete{
    _isvolume = YES;
    [MobClickUtils event:@"MUSIC_VOLUME_CONTROL"];
    self.progress.hidden = YES;
    self.musicName.hidden = YES;
    self.currentTime.hidden = YES;
    self.TotalTime.hidden = YES;
    self.nextt.hidden = YES;
    self.previou.hidden = YES;
    self.playBtn.hidden = YES;
    self.deletee.hidden =YES;
    self.changePlayModel.hidden = YES;
    self.changeimage.hidden =YES;
    self.volumeSlider.hidden = NO;
    [_volumeSlider setValue:[self getVolumeLevel]];
    _cancelVolumelabel.hidden = NO;
    _cancelVolumebutton.hidden = NO;
    _volumeImage.hidden =NO;
    _line.hidden =NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        if (alertView.tag == DELETE_ITEM_ALERT_TAG) {
            _deletenext=YES;
            [self doDeleteModel];
           
        }else if(alertView.tag == NEXT){
            [self next:NO];
        }

    }
}

-(void)doDeleteModel{
    
    _deletenext = YES;
    BOOL removeNowPlay = YES;
        [[CustomMusicPlayer shareCustomMusicPlayer]stop];
    if (!_operation) {
        _operation = [[FileOperate alloc] init];
        _operation.delegate = self;
    }
    NSMutableArray * array=[[NSMutableArray alloc]initWithObjects:_currentBean, nil];
    [_operation deleteFiles:array userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            @"delete",@"action",
                                                            _currentBean.filePath,@"dirpath",
                                                            [NSNumber numberWithBool:removeNowPlay],@"deleteplaying", nil]];
    if (self.scanDelegate==nil) {
        [_nowPlayList removeObject:_currentBean];
    }
}
-(void)fileActionResult:(BOOL)result userInfo:(id)info{
    _deletenext=NO;
    if (result) {
        NSDictionary* actionInfo = [NSDictionary dictionaryWithObjectsAndKeys:_currentBean.filePath,@"path",@"delete",@"action",[NSNumber numberWithBool:YES],@"deleteplaying", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_DONE object:actionInfo];
    }
    if (self.scanDelegate==nil) {
        if (_nowPlayList.count==0) {
            
            [self setNoneMusicViewHidden:NO];
            [self.navigationController popViewControllerAnimated:YES];
 
        }else{
         [self deletenext];
        }
    }
}

-(void)setNoneMusicViewHidden:(BOOL)hidden
{
    _noneSongView.hidden = hidden;
    if (!hidden) {
        _customNavigationBar.title.text = NSLocalizedString(@"songisnone",@"");
    }
}

-(void)resetPlayArray{
    _deletenext=NO;
    _nowPlayList=[[NSMutableArray alloc] init];
    
    [[CustomMusicPlayer shareCustomMusicPlayer] pause];
    [self setNoneMusicViewHidden:NO];
}


-(void)deletefinishrefresh:(NSArray *)array deletenowplay:(BOOL)deletenowplay{
    _deletenext=NO;
    [self dealPlayMusicArray:array];
    if (_isplayerview) {
        deletenowplay = YES;
    }
    if (_nowPlayList.count==0) {
        [[CustomMusicPlayer shareCustomMusicPlayer]pause];
        [self setNoneMusicViewHidden:NO];
        _songImageView = nil;
    }else{
        if (deletenowplay) {
            [self deletenext];
        }else{
            nowrow = 0;
            for (int i=0; i<_nowPlayList.count; i++) {
                FileBean * bean=[_nowPlayList objectAtIndex:i];
                if ([bean.filePath isEqualToString:_currentBean.filePath]) {
                    nowrow = i;
                    break;
                }
            }
            if (nowrow<_nowPlayList.count-1) {
                [[CustomFileManage instance]copyFileMusic:[_nowPlayList objectAtIndex:nowrow+1] toPath:documentsDirectory delegate:self info:nil];
            }else if (nowrow==_nowPlayList.count-1){
                [[CustomFileManage instance]copyFileMusic:[_nowPlayList objectAtIndex:0] toPath:documentsDirectory delegate:self info:nil];
            }
            if (![[CustomMusicPlayer shareCustomMusicPlayer]isPlaying]) {
                
                [self getTheLastSong:[_nowPlayList objectAtIndex:nowrow] LastSongList:_nowPlayList];
                
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    _isplayerview = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    
    _isplayerview = NO;
}
-(void)addobservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playnextsong) name:@"playnextsong" object:nil];

}
-(void)playnextsong{

    [self next:NO];
}
-(void)removeobservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"playnextsong" object:nil];

}

-(void)dealPlayMusicArray:(NSArray *)musicArray{
    if (_currentBean && [[_currentBean.filePath stringByDeletingLastPathComponent] isEqualToString:RealDownloadAudioPath]) {
        NSMutableArray * newArray = [NSMutableArray array];
        if (musicArray.count>0) {
            for (FileBean * bean in musicArray) {
                if (![self checkDocmentCellIsInDownloadingList:bean]) {
                    [newArray addObject:bean];
                }
            }
        }
        _nowPlayList = newArray;
    }
    else{
        _nowPlayList = (NSMutableArray *)musicArray;
    }
    
}

-(BOOL)checkDocmentCellIsInDownloadingList:(FileBean *)bean
{
    BOOL isIn = NO;
    NSMutableArray *downloadingArray = [[DownloadManager shareInstance] getDownloadingArray];
    
    for (NSDictionary *tmp in downloadingArray) {
        DownloadInfo* tmpInfo = [tmp objectForKey:@"item"];
        if ([tmpInfo.filepath isEqualToString:bean.filePath]) {
            isIn = YES;
            break;
        }
    }
    return isIn;
}

-(void)downloadCompelete
{
    if (_currentBean && [[_currentBean.filePath stringByDeletingLastPathComponent] isEqualToString:RealDownloadAudioPath]) {
        [[CustomFileManage instance] cleanPathCache:RealDownloadAudioPath];
        PathBean *current = [[CustomFileManage instance] getFiles:RealDownloadAudioPath fromPhotoRoot:NO];
        [self setArray:current.musicPathAry];
    }
}

#pragma mark -获取播放列表信息开始播放
-(void)setArray:(NSArray *)Ary
{
    [self dealPlayMusicArray:Ary];
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[MusicListVC class]]) {
        MusicListVC *listvc = (MusicListVC *)[self.navigationController.viewControllers lastObject];
        listvc.musicList = _nowPlayList;
        [listvc doReloadTable];
    }
}
//创建缓存文件夹
-(void)createMusicCacheFile{
    
    NSFileManager * filemanger =[NSFileManager defaultManager];
    if (![filemanger fileExistsAtPath:documentsDirectory]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *testDirectory = [libraryDirectory stringByAppendingPathComponent:@"musiccache"];
        [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

-(void)setdisk:(BOOL)disk{
    _setdisk = disk;
}

-(void)SongPath:(FileBean *)bean kuke:(BOOL)iskuke{
    _iskuke = iskuke;

    [self createMusicCacheFile];
    [self cantouch];
    if (!(!_setdisk&&[_currentBean.filePath isEqual:bean.filePath])) {
        _setdisk = NO;
        _currentBean =  bean;
         nowrow = [_nowPlayList indexOfObject:bean];
        [[CustomFileManage instance] copyFileMusic:bean toPath:documentsDirectory delegate:self info:nil];
        [self prepareForPreAndNextSong:bean];
    }

}
-(void)prepareForPreAndNextSong:(FileBean*)bean{
    
    NSInteger row = [_nowPlayList indexOfObject:bean];
    if (row == NSNotFound) {
        return;
    }
    FileBean * bean0;
    FileBean * bean2;
    if (row==0&&row==_nowPlayList.count-1) {
        
    }else if (row==0&&row<_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:_nowPlayList.count-1];
        bean2=[_nowPlayList objectAtIndex:row+1];
    }else if (row>0&&row==_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:row-1];
        bean2=[_nowPlayList objectAtIndex:0];
    }else if (row>0&&row<_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:row-1];
        bean2=[_nowPlayList objectAtIndex:row+1];
    }
    if (bean0) {
        [[CustomFileManage instance]copyFileMusic:bean0 toPath:documentsDirectory delegate:self info:nil];
    }
    if (bean2) {
        [[CustomFileManage instance]copyFileMusic:bean2 toPath:documentsDirectory delegate:self info:nil];
    }
    

}
-(void)setSongPath:(FileBean *)bean kuke:(BOOL)iskuke{
    _iskuke = iskuke;
    playlastsong = NO;
    [self createMusicCacheFile];
    if (iskuke) {
        [self cantouch];
        if (!_setdisk&&[_currentBean.filePath isEqual:bean.filePath]) {
            if (![CustomMusicPlayer shareCustomMusicPlayer].isPlaying) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PLAYMUSIC
                                                                    object:@"PlayMusic" userInfo:nil];
                [[MusicPlayerViewController instance] playorpause];
            }
            
        }else{
            _setdisk = NO;
            [self removefilers];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:bean.filePath forKey:@"bean"];
            [dic setObject:FIRST forKey:@"info"];
            _prepareBean = bean;
            [[CustomFileManage instance] copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
            [self prepareForPreAndNextSong:bean];
        }
    }else{
        if ([_currentBean.filePath isEqual:bean.filePath]) {
            if (![CustomMusicPlayer shareCustomMusicPlayer].isPlaying) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PLAYMUSIC
                                                                    object:@"PlayMusic" userInfo:nil];
                [[MusicPlayerViewController instance]playorpause];
            }
        }else{
            _currentBean=bean;
            _nowSongs=_currentBean.filePath;
            nowrow=[_nowPlayList indexOfObject:bean];
            [self playmusic];
            
        }
    }
}
//拷贝完成的通知
-(void)actionResult:(ACTIONCODE)action result:(RESULTCODE)result info:(id)info fileBean:(FileBean *)bean{
    _copyfinish = YES;
    if (action==FILE_ACTION_COPY&&info!=nil) {
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        if (result==RESULT_FINISH || ![appDelegate isAppActive]) {
            NSDictionary * dic =info;
            NSString * musicname;
            if ([[dic objectForKey:@"info"] isEqual:FIRST])
            {
                musicname=[bean.filePath lastPathComponent];
            }else{
                musicname=[[info objectForKey:@"bean"] lastPathComponent];
            }
            NSString * musicpath=[[NSString stringWithString:documentsDirectory]stringByAppendingPathComponent:musicname];
            for (int i=0; i<_nowPlayList.count; i++) {
                FileBean * bean =[_nowPlayList objectAtIndex:i];
                if ([musicname isEqual:[bean.filePath lastPathComponent]]) {
                    _currentBean=bean;
                    _nowSongs=musicpath;
                    [FileSystem changeConfigWithKey:@"lastmusic" value:_currentBean.filePath];
                    break;
                }
            }
            if ([[dic objectForKey:@"bean"] isEqualToString:_prepareBean.filePath]) {
                [self playmusic];
            }
        }
        else if (result == RESULT_ERROR){
            if (_nowPlayList.count!=0) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"sorry", @"") message:NSLocalizedString(@"cannotplay", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nextsong", @""), nil];
                alert.delegate=self;
                alert.tag=NEXT;
                [alert show];
            }
        }
    }
}
//清空文件夹下所有的文件
-(void)removefilers{
    
    NSFileManager * filemanger = [NSFileManager defaultManager];
    if (documentsDirectory) {
        if ([filemanger fileExistsAtPath:documentsDirectory]) {
            NSArray * cachemusic=[filemanger contentsOfDirectoryAtPath:documentsDirectory error:nil];
            if (cachemusic.count>0) {
                for (int i=0; i<cachemusic.count; i++) {
                    [filemanger removeItemAtPath:[[NSString stringWithString:documentsDirectory]stringByAppendingPathComponent:[cachemusic objectAtIndex:i]] error:nil];
                }
            }
        }
    }
}

#pragma mark-ipod播放结束通知
-(void)playEnd:(NSNotification *)noti{
    
    NSLog(@"playEnd result : %d",[Context shareInstance].stopPlayingAfterCurMusicPlay);
    if ([Context shareInstance].stopPlayingAfterCurMusicPlay) {
        // 不显示SettingViewController
        [Context shareInstance]._musicIndex = 0;
        [Context shareInstance].musicClockState = NO;
        
        // 正在显示SettingViewController 刷新UI
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_SETTING_MUSICTIMER object:nil];
        if ([CustomMusicPlayer shareCustomMusicPlayer].isPlaying) {
            [[MusicPlayerViewController instance] playorpause];
        }
        return;
    }
    
    if (_conflict) {
        //后台操作
    }else{
        MPMoviePlayerController *notifPlayer = [noti object];
        if([[CustomMusicPlayer shareCustomMusicPlayer] player] == notifPlayer)
        {
            NSNumber * reason =[noti.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
            NSInteger reasonAsInteger = [reason integerValue];
            if (reasonAsInteger==MPMovieFinishReasonPlaybackError) {
                AppDelegate* appdelegate = [[UIApplication sharedApplication] delegate];//后台播放遇到不能播放的歌曲直接跳过
                if ([appdelegate isAppActive]) {
                    NSLog(@"错误引起播放结束");
                    if (_nowPlayList.count!=0) {
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"sorry", @"") message:NSLocalizedString(@"cannotplay", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nextsong", @""), nil];
                        alert.delegate=self;
                        alert.tag=NEXT;
                        [alert show];
                    }
                }else{
                    [self next:NO];
                }
            }else if (reasonAsInteger==MPMovieFinishReasonUserExited){
                NSLog(@"用户退出");
            }else if(reasonAsInteger== MPMovieFinishReasonPlaybackEnded){
                NSLog(@"正常播放完成");
                if (!_movPlay){
                    if (_deletenext) {//播放中删除歌曲
                        if (_iskuke){
                            for (int i=0; i<_nowPlayList.count; i++) {
                                FileBean * bean=[_nowPlayList objectAtIndex:i];
                                
                                if ([bean.filePath isEqualToString:_currentBean.filePath]) {
                                    nowrow = i;
                                    break;
                                }
                            }
                        }
                    }else{
                        //正常播放完成
                        if (state==123)
                        {
                            [self next:NO];
                        }
                        else if (state==456)
                        {
                            [self onerun];
                        }
                        else if (state==789)
                        {
                            [self randomrun];
                        }
                    }
                }
            }
        }
    }
}

//播放暂停
-(void)playorpause
{
    if (playlastsong) {
        [self setSongPath:_lastsong kuke:YES];
    }else{
        [[CustomMusicPlayer shareCustomMusicPlayer] playorpause];
        [self checkNewSong:_currentBean.filePath];
    }
}
#pragma mark -播放逻辑
-(void)changeplaymodel
{
    playModelIdentify++;
    if (playModelIdentify%3==0)
    {
        _changeimage.image=[UIImage imageNamed:@"icon_play_list.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        state=123;
        [self changeMuaicPlay:NSLocalizedString(@"playmusicround", @"")];
        [self rememberPlayModel:NSLocalizedString(@"playmusicround", @"")];
    }
    else if (playModelIdentify%3==1)
    {
        _changeimage.image=[UIImage imageNamed:@"icon_play_one.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        state=456;
        [self changeMuaicPlay:NSLocalizedString(@"playmusicone", @"")];
        [self rememberPlayModel:NSLocalizedString(@"playmusicone", @"")];
        
    }
    else if(playModelIdentify%3==2)
    {
        _changeimage.image=[UIImage imageNamed:@"icon_play_random.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        state=789;
        [self changeMuaicPlay:NSLocalizedString(@"playmusicrandom", @"")];
        [self rememberPlayModel:NSLocalizedString(@"playmusicrandom", @"")];
    }
}

-(void)rememberPlayModel:(NSString *)states{
    
    NSUserDefaults * playState = [NSUserDefaults standardUserDefaults];
    [playState setObject:states forKey:@"playmodel"];
}

-(void)changeMuaicPlay :(NSString *)label{

    UIImageView * tips = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-130.0*WINDOW_SCALE_SIX)/2.0,
                                                                      (SCREEN_HEIGHT-64-60.0*WINDOW_SCALE_SIX)/2.0,
                                                                      130.0*WINDOW_SCALE_SIX,
                                                                      60.0*WINDOW_SCALE_SIX)];
    tips.tag=TIPS;
    tips.image = [UIImage imageNamed:@"tips_bg_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    [self.view addSubview:tips];
    
    UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                             0,
                                                             130.0*WINDOW_SCALE_SIX,
                                                             60.0*WINDOW_SCALE_SIX)];
    lab.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:18.0*WINDOW_SCALE_SIX];
    lab.text = label;
    [tips addSubview:lab];
    [self performSelector:@selector(hiddenTheTips) withObject:nil afterDelay:1.0];

}

-(void)hiddenTheTips{
    UIImageView * image = (UIImageView*)[self.view viewWithTag:TIPS];
    [image removeFromSuperview];
}
//上一首
-(void)previous:(BOOL)hand{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    if (_iskuke) {
        if (_copyfinish) {
            
            if (state==789) {
                [self randomNext];
            }else{
                if (_nowPlayList.count==1) {
                    FileBean * bean =[_nowPlayList objectAtIndex:0];
                    _prepareBean = bean;
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:bean.filePath forKey:@"bean"];
                    [dic setObject:@"" forKey:@"info"];
                    
                    [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
                    _copyfinish =NO;
                }else{
                    if (_nowPlayList.count==0) {
                        return;
                    }
                    for (int i=0; i<_nowPlayList.count; i++) {
                        FileBean * bean=[_nowPlayList objectAtIndex:i];
                        if ([bean.filePath isEqualToString:_currentBean.filePath]) {
                            nowrow = i;
                            break;
                        }
                    }
                    NSFileManager * filemanger = [NSFileManager defaultManager];
                    FileBean * bean;
                    if (nowrow>1) {
                        bean =[_nowPlayList objectAtIndex:nowrow-1];
                        [self copyMusicBean:bean nextIndex:(int)nowrow-2];
                    }
                    if (nowrow==1) {
                        bean =[_nowPlayList objectAtIndex:nowrow-1];
                        [self copyMusicBean:bean nextIndex:(int)_nowPlayList.count-1];
                    }
                    if (nowrow==0) {
                        bean =[_nowPlayList objectAtIndex:_nowPlayList.count-1];
                        [self copyMusicBean:bean nextIndex:(int)_nowPlayList.count-2];
                    }
                    [self checkNewSong:bean.filePath];
                    if (_nowPlayList.count>3) {
                        NSInteger index = (nowrow+1 + _nowPlayList.count)%_nowPlayList.count;
                        FileBean * bean1=[_nowPlayList objectAtIndex:index];
                        NSString* localPath = [documentsDirectory stringByAppendingPathComponent:[bean1.filePath lastPathComponent]];
                        BOOL result = [filemanger removeItemAtPath:localPath error:nil];
                        NSLog(@"p remove index : %ld ,  path : %@ , result : %d",(long)index,localPath,result);
                    }
                }
            }
        }else{
            if (hand) {
                [CustomNotificationView showToast:NSLocalizedString(@"operatetoofast", @"")];
            }
        }
    }else{
        if (nowrow<_nowPlayList.count) {
            if (nowrow>0) {
                nowrow --;
            }else if(nowrow==0){
                nowrow=_nowPlayList.count-1;
            }
            _currentBean=[_nowPlayList objectAtIndex:nowrow];
            _nowSongs=_currentBean.filePath;
            [self checkNewSong:_nowSongs];
            [self playmusic];
        }
    }

}

-(void)randomNext{
    _copyfinish = NO;
    [self removefilers];
    NSInteger index = arc4random() % _nowPlayList.count;
    nowrow = index;

    FileBean * bean =[_nowPlayList objectAtIndex:nowrow];
    _prepareBean = bean;
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:bean.filePath forKey:@"bean"];
    [dic setObject:@"" forKey:@"info"];
    [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
    [self checkNewSong:bean.filePath];
    NSInteger row = index;
    FileBean * bean0;
    FileBean * bean2;
    if (row==0&&row==_nowPlayList.count-1) {
        
    }else if (row==0&&row<_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:_nowPlayList.count-1];
        bean2=[_nowPlayList objectAtIndex:row+1];
    }else if (row>0&&row==_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:row-1];
        bean2=[_nowPlayList objectAtIndex:0];
    }else if (row>0&&row<_nowPlayList.count-1){
        bean0=[_nowPlayList objectAtIndex:row-1];
        bean2=[_nowPlayList objectAtIndex:row+1];
    }
    if (bean0) {
        [[CustomFileManage instance]copyFileMusic:bean0 toPath:documentsDirectory delegate:self info:nil];
    }
    if (bean2) {
        [[CustomFileManage instance]copyFileMusic:bean2 toPath:documentsDirectory delegate:self info:nil];
    }
}
//下一首
-(void)next:(BOOL)hand{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    if (_iskuke) {
        if (_copyfinish) {
            if (_nowPlayList.count == 0) {
                
            }else{
                if (state==789) {
                    [self randomNext];
                    
                }else{
                    if (_nowPlayList.count==1) {
                        FileBean * bean =[_nowPlayList objectAtIndex:0];
                        _prepareBean = bean;
                        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                        [dic setObject:bean.filePath forKey:@"bean"];
                        [dic setObject:@"" forKey:@"info"];
                        [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
                        _copyfinish =NO;
                    }else{
                        if (_nowPlayList.count==0) {
                            return;
                        }
                        for (int i=0; i<_nowPlayList.count; i++) {
                            FileBean * bean=[_nowPlayList objectAtIndex:i];
                            
                            if ([bean.filePath isEqualToString:_currentBean.filePath]) {
                                nowrow = i;
                                break;
                            }
                        }
                        FileBean * bean;
                        if (nowrow<_nowPlayList.count-2) {
                            bean =[_nowPlayList objectAtIndex:nowrow+1];
                            [self copyMusicBean:bean nextIndex:(int)nowrow+2];
                        }else if (nowrow==_nowPlayList.count-2){
                            bean =[_nowPlayList objectAtIndex:nowrow+1];
                            [self copyMusicBean:bean nextIndex:0];
                        }
                        else if (nowrow==_nowPlayList.count-1){
                            bean =[_nowPlayList objectAtIndex:0];
                            [self copyMusicBean:bean nextIndex:1];
                        }
                        
                        [self checkNewSong:bean.filePath];
                        
                        if (_nowPlayList.count>3) {
                            NSFileManager * filemanger = [NSFileManager defaultManager];
                            NSInteger index = (nowrow - 1 + _nowPlayList.count)%_nowPlayList.count;
                            FileBean * bean1=[_nowPlayList objectAtIndex:index];
                            NSString* localPath = [documentsDirectory stringByAppendingPathComponent:[bean1.filePath lastPathComponent]];
                            BOOL result = [filemanger removeItemAtPath:localPath error:nil];
                            NSLog(@"bb remove index : %ld ,  path : %@ , result : %d",(long)index,localPath,result);
                        }
                    }
                }
            }
        }else{
            if (hand) {
                [CustomNotificationView showToast:NSLocalizedString(@"operatetoofast", @"")];
            }
        }
    }else{
        if (nowrow<_nowPlayList.count) {
            if (nowrow<_nowPlayList.count-1) {
                nowrow++;
            }
            else if (nowrow==_nowPlayList.count-1||nowrow==_nowPlayList.count){
                nowrow=0;
            }
            _currentBean=[_nowPlayList objectAtIndex:nowrow];
            _nowSongs=_currentBean.filePath;
            [self playmusic];
            [self checkNewSong:_nowSongs];
        }
    }

}

-(void)copyMusicBean:(FileBean*)bean nextIndex:(int)index{
    
    NSFileManager * filemanger = [NSFileManager defaultManager];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:bean.filePath forKey:@"bean"];
    [dic setObject:@"" forKey:@"info"];
    _prepareBean = bean;
    if (![filemanger fileExistsAtPath:[[NSString stringWithString:documentsDirectory]stringByAppendingPathComponent:bean.fileName]]) {
        [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
    }
    else{
        if (index<_nowPlayList.count) {
            [[CustomFileManage instance]copyFileMusic:[_nowPlayList objectAtIndex:index] toPath:documentsDirectory delegate:self info:dic];
         }
     }
    _copyfinish =NO;

}

-(void)checkNewSong:(NSString *)filepath{
    
    NSFileManager * manger = [NSFileManager defaultManager];
    NSString * paths = [APP_LIB_ROOT stringByAppendingPathComponent:@"news.plist"];
    
    if (!self.noplayMusicplistDict) {
        
        if ([manger fileExistsAtPath:paths]) {
            self.noplayMusicplistDict= [NSMutableDictionary dictionaryWithContentsOfFile:paths];
        }
    }
    if (self.noplayMusicplistDict) {
        if ([self.noplayMusicplistDict objectForKey:filepath]) {
            [self.noplayMusicplistDict removeObjectForKey:filepath];
            [self.noplayMusicplistDict writeToFile:paths atomically:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"checknewsong" object:nil];
        }
    }

}

-(void)kukedeletenext{
    FileBean * bean;
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    NSInteger index = nowrow;
    if (nowrow<_nowPlayList.count-1) {
        bean =[_nowPlayList objectAtIndex:nowrow];
        index = nowrow +1;
    }else if(nowrow==_nowPlayList.count-1){
        bean =[_nowPlayList objectAtIndex:nowrow];
        index = 0;
    }else if (nowrow==_nowPlayList.count){
        bean =[_nowPlayList objectAtIndex:0];
        [dic setObject:bean.filePath forKey:@"bean"];
        if (_nowPlayList.count-1>0) {
            index = 1;
        }
    }
    [self checkNewSong:bean.filePath];
    [dic setObject:@"" forKey:@"info"];
    [dic setObject:bean.filePath forKey:@"bean"];
    _prepareBean = bean;
    [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
    if (nowrow==_nowPlayList.count){
        if (_nowPlayList.count-1>0) {
            [[CustomFileManage instance]copyFileMusic:[_nowPlayList objectAtIndex:1] toPath:documentsDirectory delegate:self info:nil];
        }
    }else{
        [[CustomFileManage instance]copyFileMusic:[_nowPlayList objectAtIndex:index]toPath:documentsDirectory delegate:self info:nil];
    }
    if (nowrow>0) {
        FileBean *bean =[_nowPlayList objectAtIndex:nowrow-1];
        [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:nil];
    }
    if (nowrow==0) {
        FileBean *bean =[_nowPlayList objectAtIndex:_nowPlayList.count-1];
        [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:nil];
    }
    if (nowrow>1&&_nowPlayList.count>1) {
        NSFileManager * filemanger = [NSFileManager defaultManager];
        FileBean * bean =[_nowPlayList objectAtIndex:nowrow-1];
        [filemanger removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[bean.filePath lastPathComponent]] error:nil];
    }
}
-(void)deletenext{
 
    if (nowrow<=_nowPlayList.count) {
        if (_iskuke) {
            [self kukedeletenext];
        }else{
            if (nowrow<_nowPlayList.count-1) {
            }
            else if (nowrow==_nowPlayList.count-1){
                nowrow=_nowPlayList.count-1;
            }else if(nowrow==_nowPlayList.count){
                nowrow=0;
            }
            if (nowrow<_nowPlayList.count) {
                _currentBean=[_nowPlayList objectAtIndex:nowrow];
                [self checkNewSong:_currentBean.filePath];
                _nowSongs=_currentBean.filePath;
                [self playmusic];
            }
        }
    }else if(_nowPlayList.count==0){
        [[CustomMusicPlayer shareCustomMusicPlayer]stop];
        _iconView.image = [UIImage imageNamed:@"musicplayer_new.png" bundle:@"TAIG_LEFTVIEW.bundle"];
        _customNavigationBar.title.text=NSLocalizedString(@"songisnone",@"");
        _musicName.text=nil;
        _singerName.text=nil;
        _currentTime.text=@"00:00";
        _TotalTime.text=@"00:00";
        [_progress setValue:0.0];
    }
}

//单曲
-(void)onerun
{
    if (_iskuke) {
        for (int i=0; i<_nowPlayList.count; i++) {
            FileBean * bean=[_nowPlayList objectAtIndex:i];
            
            if ([bean.filePath isEqualToString:_currentBean.filePath]) {
                nowrow = i;
                break;
            }
        }
        if (_nowPlayList.count <= nowrow) {
            return;
        }
        FileBean * bean =[_nowPlayList objectAtIndex:nowrow];
        _currentBean =bean;
        _nowSongs = [documentsDirectory stringByAppendingPathComponent:[bean.filePath lastPathComponent]];
        [self playmusic];
    }else{
        if (nowrow<_nowPlayList.count) {
            _currentBean=[_nowPlayList objectAtIndex:nowrow];
            _nowSongs=_currentBean.filePath;
            [self playmusic];
        }
    }
}
//随机
-(void)randomrun
{
    NSArray * array = [self randomizedArrayWithArray:_nowPlayList];
    if (_iskuke) {
        if (array.count>0) {
            if (nowrow<array.count-1) {
                nowrow++;
            }else if(nowrow==array.count-1||nowrow==array.count){
                nowrow=0;
            }
            FileBean * bean;
            if (nowrow<array.count) {
                bean = [array objectAtIndex:nowrow];
            }
            _prepareBean = bean;
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:bean.filePath forKey:@"bean"];
            [dic setObject:FIRST forKey:@"info"];
            _prepareBean = bean;
            [[CustomFileManage instance]copyFileMusic:bean toPath:documentsDirectory delegate:self info:dic];
            [self checkNewSong:bean.filePath];
            NSInteger row = [_nowPlayList indexOfObject:bean];
            FileBean * bean0;
            FileBean * bean2;
            if (row==0&&row==_nowPlayList.count-1) {
                
            }else if (row==0&&row<_nowPlayList.count-1){
                bean0=[_nowPlayList objectAtIndex:_nowPlayList.count-1];
                bean2=[_nowPlayList objectAtIndex:row+1];
            }else if (row>0&&row==_nowPlayList.count-1){
                bean0=[_nowPlayList objectAtIndex:row-1];
                bean2=[_nowPlayList objectAtIndex:0];
            }else if (row>0&&row<_nowPlayList.count-1){
                bean0=[_nowPlayList objectAtIndex:row-1];
                bean2=[_nowPlayList objectAtIndex:row+1];
            }
            if (bean0) {
                [[CustomFileManage instance]copyFileMusic:bean0 toPath:documentsDirectory delegate:self info:nil];
            }
            if (bean2) {
                [[CustomFileManage instance]copyFileMusic:bean2 toPath:documentsDirectory delegate:self info:nil];
            }
            NSFileManager * filemanger = [NSFileManager defaultManager];
            if (nowrow>0) {
                FileBean * bean =[array objectAtIndex:nowrow-1];
                [filemanger removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[bean.filePath lastPathComponent]] error:nil];
            }
            if (nowrow==0) {
                FileBean * bean =[array objectAtIndex:array.count-1];
                [filemanger removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[bean.filePath lastPathComponent]] error:nil];
            }
        }
    }else{
        if (nowrow<array.count-1) {
            nowrow++;
        }
        else if (nowrow==array.count-1||nowrow==array.count){
            nowrow=0;
        }
        if (nowrow<array.count) {
            _currentBean=[array objectAtIndex:nowrow];
            _nowSongs=_currentBean.filePath;
            [self playmusic];
        }
    }
}


//数组随机排列
- (NSMutableArray *) randomizedArrayWithArray:(NSArray *)array {
    
    NSMutableArray *results = [[NSMutableArray alloc]initWithArray:array];
    NSInteger i = [results count];
    while(--i > 0) {
        int j = rand() % (i+1);
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return results ;
}
//选择播放器

-(void)cantouch{
    self.playBtn.userInteractionEnabled=YES;
    self.nextt.userInteractionEnabled=YES;
    self.previou.userInteractionEnabled=YES;
    self.progress.userInteractionEnabled=YES;
    self.deletee.userInteractionEnabled=YES;
}
-(void)playmusic
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOWMUSICPLAYBEAN
                                                        object:@"NOWPLAYING" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_currentBean.filePath,@"FILE_PATH", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYMUSIC
                                                        object:@"PlayMusic" userInfo:nil];
    [self cantouch];
        [_progress setValue:0.0];
        [[CustomMusicPlayer shareCustomMusicPlayer]play:_currentBean path:_nowSongs];
    
}

//ipod歌曲改变时
-(void)playStateChange:(NSNotification*)noti
{
     MPMoviePlayerController *notifPlayer = [noti object];
    if ([[CustomMusicPlayer shareCustomMusicPlayer]player]==notifPlayer )
    {
        [_playBtn setBackgroundImage:[UIImage imageNamed:[[CustomMusicPlayer shareCustomMusicPlayer] isPlaying]?@"icon_stop.png":@"icon_play.png" bundle:@"TAIG_LEFTVIEW.bundle"] forState:UIControlStateNormal];
    }
}
//滑动进度条
-(void)slide:(CustomSliderView *)slider ValueChangeToValue:(float)value
{
    [[CustomMusicPlayer shareCustomMusicPlayer] slides:slider ValueChangeToValue:value];
}
//滑动改变音量
- (void) slide:(CustomSliderView *)slider VolumeChangeToValue:(float)volume{
    [_volumeSlider setVolume:volume];
}
- (void) endChange:(float)value{
    [[CustomMusicPlayer shareCustomMusicPlayer]endChanges:value];
}


#pragma mark ----------
//获取播放歌曲歌曲名，封面信息
-(void)setTitle:(NSString *)title
           Icon:(UIImage *)image
      musicName:(NSString *)musicName
     singerName:(NSString *)singerName hasimage:(BOOL)has
{
    _noneSongView.hidden = YES;
    _has = has;
    if (title) {
        _customNavigationBar.title.text=title;
    }else{
        _customNavigationBar.title.text=nil;
    }
    if (image) {
        if (has) {
            _songImage = image;
            _iconView.image=image;
            UIImage * blurredImage = [image applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.f maskImage:nil];
            _songImageView.image = blurredImage;
        }else{
            _iconView.image=image;
            _songImageView.image = nil;
        }
        
    }else{
        _iconView.image=nil;
        _songImageView.image = nil;
    }
    if (musicName) {
        _musicName.text=musicName;
        _musicname=musicName;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"musicbartitle" object:self];
    }else{
        _musicName.text=nil;
        _musicname=nil;
    }
    if (singerName) {
        _singerName.text=singerName;
    }else{
        _singerName.text=nil;
    }

}
//获取播放歌曲的时间和进度条
-(void)setNowTime:(float)nowTime
        countTime:(float)countTime
{
    int countSS = countTime;
    int nowSS = nowTime;
    if (countTime>0) {
        _currentTime.text = [NSString stringWithFormat:@"%@%d:%@%d",
                             nowSS/60>9?@"":@"0",
                             nowSS/60,
                             nowSS%60>9?@"":@"0",
                             nowSS%60];
        _TotalTime.text=[NSString stringWithFormat:@"%@%d:%@%d",
                         countSS/60>9?@"":@"0",
                         countSS/60,
                         countSS%60>9?@"":@"0",
                         countSS%60];
        [_progress setValue:nowTime/countTime];
    }
    else
    {
        //避免取不到总时间引起的崩溃
        _currentTime.text=@"00:00";
        _TotalTime.text=@"00:00";
        [_progress setValue:0];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
