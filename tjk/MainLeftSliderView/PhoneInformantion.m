//
//  PhoneInformantion.m
//  tjk
//
//  Created by huadao on 16/4/1.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "PhoneInformantion.h"
#import "CellView.h"
#include <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "Context.h"
@interface PhoneInformantion ()

@end

@implementation PhoneInformantion

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _customNavigationBar = [[CustomNavigationBar alloc] init];
    _customNavigationBar.delegate = self;
    _customNavigationBar.title.text = NSLocalizedString(@"phoneinfo",@"");
    _customNavigationBar.rightBtn.hidden = YES;
    
    CGFloat barOffsetY = [[UIDevice currentDevice] systemVersion].floatValue < 7 ? 20 : 0;
    _customNavigationBar.frame = CGRectMake(0,
                                            barOffsetY,
                                            [UIScreen mainScreen].bounds.size.width,
                                            64 - barOffsetY);
    [_customNavigationBar fitSystem];
    
    _customNavigationBar.leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_customNavigationBar.leftBtn setTitle:NSLocalizedString(@"back",@"") forState:UIControlStateNormal];
    [self.view addSubview:_customNavigationBar];
    
    UIView * phoneInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 80)];
    phoneInfoView.backgroundColor = BASE_COLOR;
    [self.view addSubview:phoneInfoView];
    
    UIImageView * iphoneImg = [[UIImageView alloc]initWithFrame:CGRectMake(15*WINDOW_SCALE_SIX, (80-45)*WINDOW_SCALE_SIX/2.0, 23.0*WINDOW_SCALE_SIX, 45*WINDOW_SCALE_SIX)];
    iphoneImg.image = [UIImage imageNamed:@"iphone5.png" bundle:@"TAIG_LEFTVIEW.bundle"];
    [phoneInfoView addSubview:iphoneImg];
    
    UILabel * infolabel = [[UILabel alloc]initWithFrame:CGRectMake(iphoneImg.frame.origin.x+iphoneImg.frame.size.width+22*WINDOW_SCALE_SIX,
                                                                   iphoneImg.frame.origin.y+7,
                                                                   280*WINDOW_SCALE_SIX,
                                                                   15*WINDOW_SCALE_SIX)];
    infolabel.textColor = [UIColor whiteColor];
    infolabel.textAlignment = NSTextAlignmentLeft;
    infolabel.font = [UIFont systemFontOfSize:13];
    [phoneInfoView addSubview:infolabel];
    
    infolabel.text = [NSString stringWithFormat:@"%@ %@",[Context shareInstance].phoneType,[Context shareInstance].phoneName];
    
    UILabel * versionlabel = [[UILabel alloc]initWithFrame:CGRectMake(infolabel.frame.origin.x,
                                                                      infolabel.frame.origin.y+infolabel.frame.size.height+5*WINDOW_SCALE_SIX,
                                                                      200*WINDOW_SCALE_SIX,
                                                                      15*WINDOW_SCALE_SIX)];
    versionlabel.textColor = [UIColor whiteColor];
    versionlabel.textAlignment = NSTextAlignmentLeft;
    versionlabel.font = [UIFont systemFontOfSize:13];
    [phoneInfoView addSubview:versionlabel];
    versionlabel.text = [NSString stringWithFormat:@"%@",[Context shareInstance].phoneVersion];
    
    NSArray *colorAry = [NSArray arrayWithObjects:
                         [UIColor colorWithRed:29.0/255.0 green:221.0/255.0 blue:166.1/255.0 alpha:1.0],
                         [UIColor colorWithRed:22.0/255.0 green:163.0/255.0 blue:255.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:246.0/255.0 green:186.0/255.0 blue:61.0/255.0 alpha:1.0],
                         nil];
    NSArray *nameAry = [NSArray arrayWithObjects:NSLocalizedString(@"phpower",@""),NSLocalizedString(@"phcapacity",@""),
                        NSLocalizedString(@"phram",@""),
                        nil];
    NSArray * imageAry=[NSArray arrayWithObjects:
                        [UIImage imageNamed:@"battery.png" bundle:@"TAIG_125"],
                        [UIImage imageNamed:@"disk.png" bundle:@"TAIG_125"],
                        [UIImage imageNamed:@"ram.png" bundle:@"TAIG_125"],
                        nil];
    [self getDeviceModel];
    for (int i=0; i<3; i++) {
        CellView * view=[[CellView alloc]initWithFrame:CGRectMake(0,
                                                                  (phoneInfoView.frame.origin.y+phoneInfoView.frame.size.height+i*170.0*WINDOW_SCALE_SIX/2.0),
                                                                  SCREEN_WIDTH,
                                                                  170.0*WINDOW_SCALE_SIX/2.0)];
        view.tag=i+1;
        [view setName:[nameAry objectAtIndex:i]];
        [view setImage:[colorAry objectAtIndex:i]];
        [view setimagicon:[imageAry objectAtIndex:i]];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.5;
        [view addSubview:line];
        if (i<2) {
            line.frame = CGRectMake(15, view.frame.size.height-0.5, SCREEN_WIDTH, 0.5);
        }else{
            line.frame = CGRectMake(0, view.frame.size.height-0.5, SCREEN_WIDTH, 0.5);
        }
        if (i==0) {
            [UIDevice currentDevice].batteryMonitoringEnabled = YES;
            double  devicepower = [UIDevice currentDevice].batteryLevel;
            int allminute = 1200.0*devicepower;
            int hour = allminute/60;
            int min = allminute%60;
            NSString * batterytime= [[[[[[NSString stringWithFormat:@"("]
                                         stringByAppendingString:[NSString stringWithFormat:@"%d",hour]]stringByAppendingString:NSLocalizedString(@"phhour",@"")]stringByAppendingString:[NSString stringWithFormat:@"%d",min]]stringByAppendingString:NSLocalizedString(@"phminute",@"")]stringByAppendingString:@")"];
            
            [view setnum:[[NSString stringWithFormat:@"%.0lf%%",devicepower*100]stringByAppendingString:NSLocalizedString(@"phfree",@"")]
                     num:nil];
            
            [view setsliderframe:(devicepower)*(560.0*WINDOW_SCALE_SIX/2.0)];
            view.cycle2.hidden=YES;
            [view setlab3:batterytime];
            
        }else if (i==1){
            
            double totaldisk=[[self totalDiskSpace]doubleValue]/1024/1024/1024;
            double surplusdisk=[[self freeDiskSpace]doubleValue]/1024/1024/1024;
            [view setnum:[[NSString stringWithFormat:@"%.1lfG ",totaldisk-surplusdisk]stringByAppendingString:NSLocalizedString(@"phused",@"")]
                     num:[[NSString stringWithFormat:@"%.1lfG ",surplusdisk]stringByAppendingString:NSLocalizedString(@"phfree",@"")]];
            
            [view setsliderframe:(totaldisk-surplusdisk)/totaldisk*(560.0*WINDOW_SCALE_SIX/2.0)];
        }else if (i==2){
            [view setnum:[[NSString stringWithFormat:@"%.0lfM ",totalRAM-availRAM]stringByAppendingString:NSLocalizedString(@"phused",@"")]num:[[NSString stringWithFormat:@"%.0lfM ",availRAM]stringByAppendingString:NSLocalizedString(@"phfree",@"")]];
            
            [view setsliderframe:percentage*(560.0*WINDOW_SCALE_SIX/2.0)];
            [view setlab3:[[[NSString stringWithFormat:@"("]stringByAppendingString:NSLocalizedString(@"phtotal",@"")]stringByAppendingString:[NSString stringWithFormat:@"%.0lfM)",totalRAM]]];
           
        }else if (i==3){
            
            
        }
        [self.view addSubview:view];
        
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getCurrentCpuUsed) userInfo:nil repeats:YES];

}
- (void)viewWillAppear:(BOOL)animated{

    [self getCurrentCpuUsed];
}
-(NSString *)getDeviceModel{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * version;
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]){
        iphone=2; version= @"iPhone 2G";}
    if ([platform isEqualToString:@"iPhone1,2"]){
        iphone=3;version= @"iPhone 3G";}
    if ([platform isEqualToString:@"iPhone2,1"]){
        iphone=3; version= @"iPhone 3GS";}
    if ([platform isEqualToString:@"iPhone3,1"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone3,2"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone3,3"]){
        iphone=4; version= @"iPhone 4";}
    if ([platform isEqualToString:@"iPhone4,1"]){
        iphone=4; version= @"iPhone 4S";}
    if ([platform isEqualToString:@"iPhone5,1"]){
        iphone=5; version= @"iPhone 5";}
    if ([platform isEqualToString:@"iPhone5,2"]){
        iphone=5; version= @"iPhone 5";}
    if ([platform isEqualToString:@"iPhone5,3"]){
        iphone=5; version= @"iPhone 5c";}
    if ([platform isEqualToString:@"iPhone5,4"]){
        iphone=5; version= @"iPhone 5c";}
    if ([platform isEqualToString:@"iPhone6,1"]){
        iphone=5; version= @"iPhone 5s";}
    if ([platform isEqualToString:@"iPhone6,2"]){
        iphone=5; version= @"iPhone 5s";}
    if ([platform isEqualToString:@"iPhone7,1"]){
        iphone=6; version= @"iPhone 6 Plus";}
    if ([platform isEqualToString:@"iPhone7,2"]){
        iphone=6; version= @"iPhone 6";}
    if ([platform isEqualToString:@"iPhone8,1"]){
        iphone=7; version= @"iPhone 6s";}
    if ([platform isEqualToString:@"iPhone8,2"]){
        iphone=7; version= @"iPhone 6s plus";}
    return version;
    
}

-(void)clickLeft:(UIButton *)leftBtn {
    if([self.backDelegate respondsToSelector:@selector(onBackBtnPressed:)]){
        [self.backDelegate onBackBtnPressed:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//获取设备的总容量
-(NSNumber *)totalDiskSpace
{
    
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
    
}
//获取设备的当前剩余容量
- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
    
}
-(void)getpower{
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double  devicepower = [UIDevice currentDevice].batteryLevel;
    int allminute = 1200.0*devicepower;
    int hour = allminute/60;
    int min = allminute%60;
    NSString * batterytime= [[[[[[NSString stringWithFormat:@"("]
                                 //                                  stringByAppendingString:NSLocalizedString(@"phcanuse",@"")]
                                 stringByAppendingString:[NSString stringWithFormat:@"%d",hour]]stringByAppendingString:NSLocalizedString(@"phhour",@"")]stringByAppendingString:[NSString stringWithFormat:@"%d",min]]stringByAppendingString:NSLocalizedString(@"phminute",@"")]stringByAppendingString:@")"];
    
    CellView * view=(CellView *)[self.view viewWithTag:1.0];
    [view setnum: [[NSString stringWithFormat:@"%.0lf%%",devicepower*100]stringByAppendingString:NSLocalizedString(@"phfree",@"")]
             num:nil];
    [view setsliderframe:(devicepower)*(560.0*WINDOW_SCALE_SIX/2.0)];
    
    [view setlab3:batterytime];
    
    
}


//获取cpu占用率

-(void)getCurrentCpuUsed{
    
    
    availRAM = [self availableMemory];
    
    if (iphone>=7) {
        totalRAM=2048;
    }else if (iphone>=5) {
        totalRAM=1024;
    }
    else{
        totalRAM=512;
    }
    if (availRAM>totalRAM) {
        availRAM=totalRAM;
    }
    percentage = (totalRAM-availRAM)/totalRAM;
    if (percentage<0) {
        percentage=0;
    }
    CellView * view2 = (CellView *)[self.view viewWithTag:3];
    [view2 setnum:[[NSString stringWithFormat:@"%.0lfM ",totalRAM-availRAM]stringByAppendingString:NSLocalizedString(@"phused",@"")]num:[[NSString stringWithFormat:@"%.0lfM ",availRAM]stringByAppendingString:NSLocalizedString(@"phfree",@"")]];
    [view2 setsliderframe:percentage*(560.0*WINDOW_SCALE_SIX/2.0)];
    [view2 setlab3:[[[NSString stringWithFormat:@"("]stringByAppendingString:NSLocalizedString(@"phtotal",@"")]stringByAppendingString:[NSString stringWithFormat:@"%.0lfM )",totalRAM]]];
    
}
//获取RAM
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}


-(void) logMemoryInfo {
    
    
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    double unit = 1024 * 1024;
    double total = (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize / unit;
    double wired = vmstat.wire_count * pagesize / unit;
    double active = vmstat.active_count * pagesize / unit;
    double inactive = vmstat.inactive_count * pagesize / unit;
    double free = vmstat.free_count * pagesize / unit;
    double resident = info.resident_size / unit;
    NSLog(@"===================================================");
    NSLog(@"Total:%.2lfMb", total);
    NSLog(@"Wired:%.2lfMb", wired);
    NSLog(@"Active:%.2lfMb", active);
    NSLog(@"Inactive:%.2lfMb", inactive);
    NSLog(@"Free:%.2lfMb", free);
    NSLog(@"Resident:%.2lfMb", resident);
}
- (double)totalMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.active_count) / 1024.0) / 1024.0;
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
