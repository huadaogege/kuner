//
//  FileSystem.m
//  tjk
//
//  Created by ??ºÂ????ºÂ????? on 15/3/24.
//  Copyright (c) 2015Âπ? taig. All rights reserved.
//

#import "FileSystem.h"
#import "kac_http.h"
#import "kac_fso.h"
#import "kac_emmc.h"
#import "kac_dev_ctrl.h"
#import "CustomFileManage.h"
#import "LogUtils.h"
#import "MobClickUtils.h"
#import "AppUpdateUtils.h"


@implementation FileSystem

void sendNotf(DEVICE_NOTIFY notf){
    [[FileSystem shareInstance] performSelectorOnMainThread:@selector(postOnMainThread:) withObject:[NSNumber numberWithInt:notf] waitUntilDone:NO];
}

static void notif(int flag, const void* msg, int msg_len){
    
    int cmd = flag - FS_NOTIFY_BASE;
    
    NSLog(@"notify cmd: %d",cmd);
    switch (cmd) {
        case FS_NOTIFY_PWR_LOW: {
            sendNotf(CU_NOTIFY_PWR_LOW);
            break;
        }
        case FS_NOTIFY_HOT: {
            sendNotf(CU_NOTIFY_HOT);
            break;
        }
        case FS_NOTIFY_USB_OFF: {
            sendNotf(CU_NOTIFY_USB_OFF);
            break;
        }
        case FS_NOTIFY_SD_INSERT:
            NSLog(@"FS_NOTIFY_SD_INSERT");
            break;
        case FS_NOTIFY_SD_REMOVE:
            NSLog(@"FS_NOTIFY_SD_REMOVE");
            break;
        case FS_NOTIFY_ADP_INST:{
            
            sendNotf(CU_NOTIFY_USB_ON);
            break;
        }
        case FS_NOTIFY_TRANPARENT_INST:{
            
            sendNotf(CU_NOTIFY_PC_INST);
            break;
        }
        case FS_NOTIFY_U_DISK:{
            //U???
            sendNotf(CU_NOTIFY_PC_USB);
            break;
        }
        case FS_NOTIFY_DEVCON: {
            
            mode = DEVICE_H;
            [LogUtils writeLog:@"DEBUGMODEL FS_NOTIFY_DEVCON"];
            NSLog(@"[%ld] got FS_NOTIFY_DEVCON", time(NULL));
            [[CustomFileManage instance] cleanPathCacheAll];
            [[CustomFileManage instance] setCache:YES];
            isConnected = YES;
            sendNotf(CU_NOTIFY_DEVCON);
            break;
        }
        case FS_NOTIFY_POWERDOWN_REQUEST:
        case FS_NOTIFY_DEVOFF:{
            
            NSLog(@"got FS_NOTIFY_DEVOFF");
            [LogUtils writeLog:@"DEBUGMODEL FS_NOTIFY_DEVOFF"];
            [[CustomFileManage instance] setCache:NO];
            [[CustomFileManage instance] cleanPathCacheAll];
            [FileSystem clearSNStr];
            sendNotf(CU_NOTIFY_DEVOFF);
            break;
        }
        case FS_NOTIFY_PAIR:{
            
            //???Ë¶?È™?ËØ?ÂÆ???®Á??
            sendNotf(CU_NOTIFY_CODE);
            break;
        }
        case FS_NOTIFY_PWR_INF:{
            
            
            break;
        }
#ifdef _LOG_APP_
        case FS_NOTIFY_DEBUG: {
            const char *strLog = (const char *)msg;
            app_log_file("DEBUGMODEL FS_NOTIFY_DEBUG: %s", strLog);
            break;
        }
#endif
    }
}

static BOOL isLocked = NO;
static BOOL isLockReaded = NO;

static BOOL isBinded = NO;
static BOOL isBindReaded = NO;

static BOOL isConnected = NO;



+(id)shareInstance{
    static FileSystem * instace = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instace = [[self alloc]init];
    });
    return instace;
}

+(int)tgk_fso_init{
    if(![MobClickUtils MobClickIsActive]){
        return 0;
    }
    errno = 0;
    int rt;
    rt = fso_init([[[NSBundle mainBundle] bundleIdentifier] UTF8String], DEV_TYPE_KUKE, notif, 0);
    fso_set_timeout(5);
    [self creatDir:[self getCachePath]];
    [self creatDir:[self getIconCachePath]];
    [self creatDir:[self getMediaCachePath]];
    return rt;
}

+(int)tgk_fso_re_init {
    int ret = fso_active([[[NSBundle mainBundle] bundleIdentifier] UTF8String], notif, 0);
    return ret;
}

+(int)tgk_fso_destroy{
    // App should'n call this func directly.
//    assert(0);
    int ret = fso_destroy();
    return ret;
}

+(int)tgk_system_exit{
    int ret = fso_shutdown();
    return ret;
}

+(BOOL)fso_format{
    
    uuid_t uuid = {0};
    uuid_generate(uuid);
#if 0 
//    fso_format(uuid);
    int res = 0;
    const char* ques = [@"我生活在那个城市？？？？？" UTF8String];
    const char* answer = [@"你猜猜看。" UTF8String];
    const char* wrong_answer = [@"数量的风景" UTF8String];
    res = fso_is_bind_passcode();
    res = fso_set_init_security_question_answer_and_passcode((char*)ques, (char*)answer, "1234567");
    res = fso_set_init_security_question_answer_and_passcode((char*)ques, (char*)answer, "1234567");
    char buffer[101] = {0};
    res = fso_query_security_question(buffer, 100);
    res = fso_is_match_passcode("23456");
    res = fso_is_match_passcode("1234567");
    res = fso_is_match_security_answer((char*)wrong_answer);
    res = fso_is_match_security_answer((char*)answer);
    res = fso_modify_passcode_with_security_answer((char*)wrong_answer, "9889889");
    res = fso_modify_passcode_with_security_answer((char*)answer, "9889889");
    res = fso_modify_passcode_with_old_passcode("2345678", "9889889");
    res = fso_modify_passcode_with_old_passcode("9889889", "1234567");
    res = fso_clear_security_question_answer_and_current_passcode_with_security_answer((char*)wrong_answer);
    res = fso_clear_security_question_answer_and_current_passcode_with_security_answer((char*)answer);
    res = fso_clear_security_question_answer_and_current_passcode_with_current_passcode("hskfdjskf");
    res = fso_clear_security_question_answer_and_current_passcode_with_current_passcode("1234567");
#endif
    
#ifdef TEST_READ_SPEED
    DIR *dir = NULL;
    int fd_read = -1;
    int cnt_file = 0;
    double len_all = 0.0;
    ssize_t len_read = 0;
    NSString *nspath = NULL;
    NSString *nspath_video = [NSString stringWithUTF8String:"/.KUKE.01/视频"];
    dir = fso_opendir([nspath_video UTF8String]);
    if (dir) {
        time_t time_start = time(NULL);
        struct dirent *file = NULL;
        char * buff = (char *)calloc(RW_BUFFER_SIZE, 1);
        while ((file = fso_readdir(dir)) != NULL) {
            
            
            nspath = [NSString stringWithFormat:@"%@/%s", nspath_video, file->d_name];
//            NSLog(@"read file: %@", nspath);
            if (file->d_type == DT_REG) {
                
                fd_read = fso_open([nspath UTF8String], O_RDONLY, ACCESSPERMS);
                if (fd_read > 0) {
                    cnt_file++;
                    while ((len_read = fso_read(fd_read, buff, RW_BUFFER_SIZE)) > 0) {
                        len_all += len_read;
                        memset(buff, 0, RW_BUFFER_SIZE);
                    }
                    fso_close(fd_read);
                }
            }
        }
        free(buff);
        fso_closedir(dir);
        time_start = time(NULL) - time_start;
        len_all /= 1024.0;
        len_all /= 1024.0;
        [LogUtils writeLog: [NSString stringWithFormat:@"DEBUGMODEL test read file, cnt: %d, file_len: %fM, seconds: %ld, read speed: %f",
                             cnt_file, len_all, time_start, len_all/time_start]];
//        NSLog(@"test read file, cnt: %d, seconds: %ld",cnt_file, time_start);
    }
    return YES;
#endif
    
    BOOL result = fso_format(uuid) == 0?YES:NO;
    return result;
}

static NSString* version = nil;
//static NSString* sn = nil;

+(NSString*)getVersion {
    return version;
}

+(void)clearVersion
{
    version = nil;
}

//+(NSString*)getSN {
//    return sn;
//}

+(HardwareInfoBean *)get_info{

    fso_proto_init info;
    
    NSLog(@"[%ld] enter get_info", time(NULL));
    
    errno = 0;
    int re = fso_get_configuration(&info);
    if(re == 0){
        
        HardwareInfoBean *bean = [[HardwareInfoBean alloc] init];
        bean.path = [NSString stringWithUTF8String:info.name];
        bean.uuid = [NSData dataWithBytes:info.uuid length:sizeof(info.uuid)];
        bean.free_size = info.emmc.fs_free;
        bean.serial = [NSString stringWithFormat:@"%d", info.emmc.serial];
        bean.size = info.emmc.egrp_len[EGRP_FS_DAT];
        if (bean.free_size > bean.size) {
            bean.free_size = bean.size;
        }
        
        NSLog(@"[%ld] get_info ok with free_size: %llu， size: %llu", time(NULL), bean.free_size,bean.size);
        bean.INFO_VERSION_MA = info.emmc.fwver.major;
        bean.INFO_VERSION_MI = info.emmc.fwver.minor;
        bean.INFO_VERSION_IN = info.emmc.fwver.inner;
        bean.INFO_SN = [NSString stringWithFormat:@"%s", info.emmc.sn];
        if (!version) {
            version = [NSString stringWithFormat:@"%d.%d.%d",bean.INFO_VERSION_MA,bean.INFO_VERSION_MI,bean.INFO_VERSION_IN];
        }
        if (!sn) {
            sn = bean.INFO_SN;
        }
        filePath = bean.path;
        return bean;
    }else{
        NSLog(@"[%ld] get_info errno :: %d, errno: %d", time(NULL), re, errno);
        return nil;
    }
}

+(BOOL)set_deviceModel:(DEVICE_MODEL)model{
    
    DEVICE_MODEL finModel = DEVICE_H;
    dev_ctrl ctrl;
    ctrl.set_dev = 0;
    switch (model) {
        case DEVICE_U:
            ctrl.class_mass_storage = 1;
            finModel = DEVICE_U;
            [LogUtils writeLog:@"DEVICE_U"];
            break;
        case DEVICE_H:
            ctrl.class_transparent = 1;
            finModel = DEVICE_H;
            [LogUtils writeLog:@"DEVICE_H"];
            break;
        case DEVICE_R:
            ctrl.reboot = 1;    //??????
            break;
        case DEVICE_D: 
            ctrl.shutdown = 1;
            break;
        case CHARGING_DEFAULT:            // 应用启动时缺省充电策略
            ctrl.charging_default = 1;
            break;
        case CHARGING_STORAGE_PREFERRED:  // 应用启动时扩容优先充电策略
            ctrl.charging_storage_preferred = 1;
            break;
        default:
            break;
    }
    int re = fso_set_device_type(&ctrl);
    if(re == 0) mode = finModel;
    return re == 0 ? YES : NO;
}

static DEVICE_MODEL mode = DEVICE_H;
+(DEVICE_MODEL)get_deviceModel{
    return mode;
}

+(PowerBean *)getPoweInfo{
    if(![self checkInit]){
        return nil;
    }
    powr_inf info;
//    [LogUtils writeLog:@"getPoweInfo aaa"];
    int re = fso_get_power_info(&info);
//    [LogUtils writeLog:@"getPoweInfo bbb"];
    if(re == 0){
        
        PowerBean *bean = [[PowerBean alloc] init];
        bean.all = info.FullChargeCapacity;
        bean.surplus = info.StateOfCharge/100.0;
        bean.speed = (SPEED_STAT)info.charging_gear;
        bean.current = info.AverageCurrent;
        bean.thermal = info.Temperature;
        bean.health = info.StateOfHealth;
        bean.limit = info.charging_limit;
        bean.vol = info.voltage;
        bean.model = (MODEL_STAT)info.dsg;
        bean.usb1_stat = (USB_STAT)info.usb1_line_stat;
        bean.usb1_model = (USB_MODEL)info.usb1_kuke_stat;
        return bean;
    }else{
        [LogUtils writeLog:[NSString stringWithFormat:@"%@ getPoweInfo failed, re: %d, errno: %d", DEBUGMODEL,re, errno]];
        return nil;
    }
}

+(int)updateDevice:(NSData *)data{
    
    Byte *buff = (Byte *)[data bytes];
    int re = fso_write_to_firmware_zone(0, &buff[0], data.length);
    if(re != -1)
        [FileSystem set_deviceModel:DEVICE_R];
    return re;
}

+(BOOL)setPwdCode:(NSString *)newPwd old:(NSString *)oldPwd{
    
    int flag = fso_set_pair_password((char *)[oldPwd UTF8String], (char *)[newPwd UTF8String]);
    return flag == 0 ? YES : NO;
}

+(BOOL)setChargingLimit:(float)vlaue{
    
    if(vlaue > 1) vlaue = 1.0;
    else if (vlaue < 0) vlaue = 0.05;

    powr_ctrl ctrl;
    ctrl.set_powr = 0;
    ctrl.mask = 2;
    ctrl.charging_limit = vlaue * 100;
    
    int re = fso_set_charging_gear(&ctrl);
    
    if(re == 0){
        
        return YES;
    }else{

        return NO;
    }
}

+(BOOL)setChargingGear:(SPEED_STAT)vlaue{

    powr_ctrl ctrl;
    ctrl.set_powr = 0;
    ctrl.mask = 1;
    ctrl.charging_gear = vlaue;
    
    int re = fso_set_charging_gear(&ctrl);
    if(re == 0){
        return YES;
    }else{
        return NO;
    }
}

static NSString* filePath = nil;

+(NSString *)getFilePath{
    if (!filePath && [FileSystem checkInit]) {
//        NSLog(@"getFilePath");
        HardwareInfoBean* info = [FileSystem get_info];
        if(info){
            filePath = info.path;
            return filePath;
        }else{
//            filePath = @"error";
            return filePath;
        }
    }
    else{
        return filePath;
    }
}

+(NSString *)getCachePath{
    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/FileCache"];
}

+(NSString *)getIconCachePath{
    
    return [[FileSystem getCachePath] stringByAppendingPathComponent:[DESUtils getMD5:@"iconDic"]];
}

+(NSString *)getMediaCachePath{
    
    return [[FileSystem getCachePath] stringByAppendingPathComponent:[DESUtils getMD5:@"mediaDic"]];
}

+(NSString *)getHarddiskIconCachePath{
    
    return [[FileSystem getCachePath] stringByAppendingPathComponent:[FileSystem getSN]];
}

+(NSString *)getDevUDID{
    
    dev_inf* dev = 0;
    int rt = fso_get_dev_info(&dev);
    if(rt == 0)
        return [NSString stringWithFormat:@"%s", dev->serial];
    else
        return nil;
}

static NSString* sn = nil;

+(NSString *)getSN{
    return sn;
}

+(void)setSN:(NSString *)snstr
{
    sn = snstr;
}

+(void)clearSNStr
{
    sn = nil;
}

static NSString* serial = nil;

+(NSString *)getSerial{
    if (serial) {
        return serial;
    }
    serial = [FileSystem get_info].serial;
    return serial;
}

+(BOOL)checkInit{
    
    int re = fso_get_device_status();
    if(re == DEVICE_STATUS_WORK){
        return YES;
    }
    return NO;
}

//#define _TIME_STAMP

#ifdef _TIME_STAMP
static int fd_open = -1;
static time_t time_start = 0;
#endif

+(int) kr_open:(NSString *)path flag:(int)format,...{
    
    int mode = 0;
    va_list vlist;
    va_start(vlist, format);
    mode = va_arg(vlist, int);
    va_end(vlist);
    errno = 0;
    debugf("path: %s", [path UTF8String]);
    int re = fso_open([path UTF8String], format, mode);
#ifdef _TIME_STAMP
    if (re >= 0) {
        [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL open file: %@ with fd: %x", path, re]];
        fd_open = re;
        time_start = time(NULL);
    }
#endif
    debugf("fd: %d", re);
    return re;
}


+(int)kr_close:(int)fg{
    
    debugf("fd: %d", fg);
    int re = fso_close(fg);
    if(re != 0){
        re = fso_close(fg);
    }
#ifdef _TIME_STAMP
    if (fd_open == fg) {
        time_t time_end = time(NULL);
        [LogUtils writeLog:[NSString stringWithFormat:@"DEBUGMODEL close file: %x, time eclips: %ld", fd_open, (time_end - time_start)]];
        fd_open = -1;
    }
#endif
    return re;
}

+(int)kr_fso_setattr:(NSString*)path size:(long long)size cttime:(float)cttime chtime:(float)chtime
{
    if (![FileSystem isConnectedKEInUserDefaults] && ![FileSystem checkInit]) {
        
        BOOL issuccess = NO;
        
        if (cttime > 0) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:cttime];
            NSFileManager *mannager = [NSFileManager defaultManager];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:date forKey:@"NSFileCreationDate"];
            if (chtime > 0) {
                NSDate *chdate = [NSDate dateWithTimeIntervalSince1970:chtime];
                [dict setObject:chdate forKey:@"NSFileModificationDate"];
            }
            [mannager setAttributes:dict ofItemAtPath:path error:nil];
        }
        return issuccess?0:1;
    }
    else{
        struct stat _stat;
        int sizeFlag = 0;
        
        if(time > 0) {
            _stat.st_mtimespec.tv_sec = chtime;
            _stat.st_ctimespec.tv_sec = cttime;
            sizeFlag = (sizeFlag | SETATTR_MASK_CTIME | SETATTR_MASK_MTIME);
        }
        int re = fso_setattr([path UTF8String], &_stat, sizeFlag);
        return re;
    }
}

+(int) kr_fso_setattr:(NSString*)path size:(long long)size time:(float)time {
    
    if (![FileSystem isConnectedKEInUserDefaults] && ![FileSystem checkInit]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSFileManager *mannager = [NSFileManager defaultManager];
        BOOL issuccess = [mannager setAttributes:[NSDictionary dictionaryWithObject:date forKey:@"NSFileCreationDate"] ofItemAtPath:path error:nil];
        return issuccess?0:1;
    }
    else{
        struct stat _stat;
        int sizeFlag = 0;
        
        if(time > 0) {
            _stat.st_mtimespec.tv_sec = 0;
            _stat.st_ctimespec.tv_sec = time;
            sizeFlag |= SETATTR_MASK_CTIME;
        }
        int re = fso_setattr([path UTF8String], &_stat, sizeFlag);
        return re;
    }
}

+(int)kr_fso_fsetattr:(int)fg size:(long long)size time:(float)time{

//    struct stat _stat;
//    int sizeFlag = 0;
//
//    if(time > 0) {
//        _stat.st_mtimespec.tv_sec = 0;
//        _stat.st_ctimespec.tv_sec = time;
//        sizeFlag |= SETATTR_MASK_CTIME;
//    }
//    int re = fso_fsetattr(fg, &_stat, sizeFlag);
//    return re;
    return [FileSystem kr_fso_fsetattr:fg size:size cttime:time chtime:0];
}

+(int)kr_fso_fsetattr:(int)fg size:(long long)size cttime:(float)cttime chtime:(float)chtime{
    
    struct stat _stat;
    int sizeFlag = 0;
    
    if(time > 0) {
        _stat.st_mtimespec.tv_sec = chtime;
        _stat.st_ctimespec.tv_sec = cttime;
        if (chtime != 0) {
            sizeFlag = (sizeFlag | SETATTR_MASK_CTIME | SETATTR_MASK_MTIME);
        }
        else{
            sizeFlag |= SETATTR_MASK_CTIME;
        }
    }
    int re = fso_fsetattr(fg, &_stat, sizeFlag);
    return re;
}

+(off_t) kr_seek:(int)fd offset:(int)offset fromwhere:(int)fromwhere {
    off_t re =  fso_lseek(fd, offset,fromwhere);
    return re;
}

+(ssize_t)kr_writr:(int)fd buffer:(const void *)buffer size:(size_t)size{

    errno = 0;
    ssize_t re = fso_write(fd, buffer, size);
    return re;
}

+(void) flushData{

    fso_fsync(0);
}

+(int)kr_closeDir:(DIR*)dir{

    debugf("dir: %p", dir);
    return fso_closedir(dir);
}

+(DIR *)kr_openDir:(NSString *)path{
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked] && [CustomFileManage getFilePosition:path] == POSITION_HARDDISK) {
        return nil;
    }
    debugf("path: %s", [path UTF8String]);
    DIR *dir = fso_opendir([path UTF8String]);
    debugf("dir: %p", dir);
    return dir;
}

+(int)kr_rmDir:(NSString *)path{

    int re = fso_rmdir([path UTF8String]);
    return re;
}

+(int)kr_makeDir:(NSString *)path mode:(mode_t)mode{
    int re = fso_mkdir([path UTF8String], mode);
    return re;
}

+(int)getStat{

    int re = fso_get_fs_status();
    return re;
}

+(ssize_t)kr_read:(int)fd buffer:(void*)buffer size:(size_t)size{
    ssize_t readSize = fso_read(fd, buffer, size);
    // debugf("fd: %d, size: %zu, readSize: %d", fd, size, readSize);
    return readSize;
}

+(int)kr_stat:(NSString *)path stat:(struct stat *)st{
    
    int re = fso_stat([path UTF8String], st);
    return re;
}

+(struct dirent *)kr_readDir:(DIR *)dir{
    //     int *ptr = (int *)dir;
    // debugf("dir: %p, fid: %d", dir, *(ptr+1));
//    [LogUtils writeLog:[NSString stringWithFormat:@"kr_readDir aaa %p",dir]];
    struct dirent *file = fso_readdir(dir);
//    [LogUtils writeLog:[NSString stringWithFormat:@"kr_readDir bbb %p",dir]];
    // debugf("after fso_readdir: dir: %p, fid: %d", dir, *(ptr+1));
    return file;
}

+(int)kr_unlink:(NSString *)path{
    
    int re = fso_unlink([path UTF8String]);
    return re;
}

+(NSData *)kr_readData:(NSString *)path{
    int sfp;
    NSMutableData *temp = [NSMutableData data];
    
    sfp = [FileSystem kr_open:path flag:O_RDONLY, ACCESSPERMS];
    if(sfp <= 0){
        
        return nil;
    }
    
    size_t sizeof_buff = RW_BUFFER_SIZE;
    
    
    ssize_t length = 0;
    char* buff = (char*)malloc(sizeof_buff);
    if(buff){
        while (true) {
            memset(buff, 0, sizeof_buff);
            length = [FileSystem kr_read:sfp buffer:buff size:sizeof_buff];
            if (length > 0) {
                [temp appendBytes:buff length:length];
            }
            else {
                break;
            }
        }
        free(buff);
        buff = NULL;
    }
    
//    [_cancelDic removeObjectForKey:filePath];
    [FileSystem kr_close:sfp];
    return temp;
}

+(NSData *)kr_readData:(NSString *)path withBlock:(GetDataBlock)block{
    int sfp;
    NSMutableData *temp = [NSMutableData data];
    
    //    [_cancelDic setObject:@"1" forKey:filePath];
    sfp = [FileSystem kr_open:path flag:O_RDONLY, ACCESSPERMS];
    if(sfp <= 0){
        
        return nil;
    }
    
    size_t sizeof_buff = RW_BUFFER_SIZE;
    
    
    ssize_t length = 0;
    char* buff = (char*)malloc(sizeof_buff);
    BOOL needContinue = true;
    if(buff){
        while (needContinue) {
            memset(buff, 0, sizeof_buff);
            length = [FileSystem kr_read:sfp buffer:buff size:sizeof_buff];
            if (length > 0) {
                [temp appendBytes:buff length:length];
            }
            else {
                break;
            }
            needContinue = block();
        }
        free(buff);
        buff = NULL;
    }
    
    //    [_cancelDic removeObjectForKey:filePath];
    [FileSystem kr_close:sfp];
    return needContinue ? temp : nil;
}

+(int)kr_renameFromPath:(NSString *)from toPath:(NSString *)to{
    @synchronized (self) {
        
        int re = fso_rename([from UTF8String], [to UTF8String]);
        
        return re;
    }
}

+(int) creatDir:(NSString *)path{

    @synchronized (self) {
        NSArray *pathAry = [path componentsSeparatedByString:@"/"];
        NSString *strBuf = @"/";
        
        for (int i = 1; i<pathAry.count; i++) {
            
            strBuf = [strBuf stringByAppendingPathComponent:[pathAry objectAtIndex:i]];
            
            FilePropertyBean * tempDic = [FileSystem readFileProperty:strBuf];
            if(tempDic == nil){
                
                int re = [FileSystem kr_makeDir:strBuf mode:ACCESSPERMS];
                
                if(re != 0){
                    
                    if(errno != EEXIST){
                        return -1;
                    }
                };
                [self flushData];
            }
        }
        
        return 0;
    }
}

+(BOOL)isExistPhotoAt:(NSString *)path
{
    struct stat buf;
    int ret = -1;
    BOOL isexist = NO;
    ret = [FileSystem kr_stat:path stat:&buf];
    if(ret == 0){
        if(!S_ISDIR(buf.st_mode) && buf.st_size > 0){
            isexist = YES;
        }
    }
    return isexist;
}

+(FilePropertyBean *)readFileProperty:(NSString *)path{
//    NSLog(@"readFileProperty : %@",path);
    struct stat buf;
    int ret = -1;
    ret = [FileSystem kr_stat:path stat:&buf];
    if(ret == 0){
        
        PROPERTY_KIND flag;
        if(S_ISDIR(buf.st_mode)){
            
            flag = FILE_KIND_DIR;
        }else{
            
            flag = FILE_KIND_FILE;
        }
        FilePropertyBean *bean = [FilePropertyBean alloc];
        bean.size = buf.st_size;
        bean.creatTime = buf.st_ctimespec.tv_sec;
        bean.changeTime = buf.st_mtimespec.tv_sec;
        bean.fileKind = flag;
        return bean;
    }else{
        return nil;
    }
}

+(BOOL) writeFileToPath:(NSString *)path DataFile:(NSData *)data{
    
    int sfp;
    sfp = [FileSystem kr_open:path flag:O_CREAT|O_RDWR, ACCESSPERMS];
    if(sfp <= 0){

        return NO;
    }
    if(sfp > 0){
        
        int pos = 0;
        Byte *testByte = (Byte *)[data bytes];
        ssize_t length = 0;
        while(pos < data.length){
            
            length = [self kr_writr:sfp buffer:&testByte[pos] size:data.length - pos];
            if(length <= 0){
                
                [FileSystem kr_unlink:path];
                break;
            }
            
            pos += length;
        }
        [FileSystem kr_close:sfp];
        [FileSystem flushData];
        if(pos == length){
            
            return YES;
        }
    }
    return NO;
}

+(NSURL *)changeURL:(NSString *)path{
    if(![MobClickUtils MobClickIsActive]){
        return [NSURL fileURLWithPath:path];
    }
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    const char* filename = [path UTF8String];
    char taig_url[1024];
    size_t taig_url_len = sizeof(taig_url);
    
    int rt = taig_http_prepare_url(filename, taig_url, &taig_url_len);
    if (rt) return nil;
    
    NSString *str = [NSString stringWithFormat:@"%s", taig_url];
    
    return [NSURL URLWithString:str];
}

+(void)clearKeVideoURL{
    taig_http_disconnect_all();
}

+(void)createPath:(NSString *)path withComponentKey:(NSString *)cKey isHardDisk:(BOOL)isdisk
{
    if ([path isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if (![FileSystem readFileProperty:path]) {
        
        NSString *lastPath = [[Context shareInstance] getExistPathWithKey:cKey onPhone:!isdisk];
        if (lastPath){
            [FileSystem kr_renameFromPath:lastPath toPath:path];
        }
        else
        {
            int createState = [FileSystem creatDir:path];
            NSLog(@"FileSystem createDir: %d",createState);
        }
    }
}

+(void)createDirIfNotExist {
    
    if ([FileSystem checkBindPhone] && [FileSystem iphoneislocked]) {
        return;
    }
    
    BOOL inKe = [self isConnectedKE] || [self checkInit];
    if (inKe) {
        //        Photos Videos Musics Documentz
        NSString *path = KE_PHOTO;
        [self createPath:path withComponentKey:kMultLanguagePicturePathKey isHardDisk:YES];
        
        path = KE_VIDEO;
        [self createPath:path withComponentKey:kMultLanguageVideoPathKey isHardDisk:YES];
        
        path = KE_MUSIC;
        [self createPath:path withComponentKey:kMultLanguageMusicPathKey isHardDisk:YES];
        
        path = KE_DOC;
        [self createPath:path withComponentKey:kMultLanguageDocumentPathKey isHardDisk:YES];
    }
    else {
        NSString *path = PHONE_PHOTO;
        [self createPath:path withComponentKey:kMultLanguagePicturePathKey isHardDisk:NO];
        
        path = PHONE_VIDEO;
        [self createPath:path withComponentKey:kMultLanguageVideoPathKey isHardDisk:NO];
        
        path = PHONE_MUSIC;
        [self createPath:path withComponentKey:kMultLanguageMusicPathKey isHardDisk:NO];
        
        path = PHONE_DOC;
        [self createPath:path withComponentKey:kMultLanguageDocumentPathKey isHardDisk:NO];
    }
}

+(void)changeCopyPathConfig:(NSString*)path{
   [FileSystem changeConfigWithKey:@"copy_path" value:path];
}

+(NSString*)getCopyPath{
    return [FileSystem getConfigWithKey:@"copy_path"];
}

+(void)setConnectedInit {
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"isConnected"]) {
        [[AppUpdateUtils instance]sendSNnumber];
    }
    [FileSystem changeConfigWithKey:@"isConnected" value:@"1"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isConnected"];
}

+(BOOL)isConnectedKE{
    BOOL iscon = [FileSystem getConfigWithKey:@"isConnected"] != nil;
    return  iscon || FOR_STORE != 1;
}

+(void)setConnectCopiedInit {
    [FileSystem changeConfigWithKey:@"isConnectCopied2KE" value:@"1"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isConnectCopied2KE"];
}

+(BOOL)isConnectCopied2KE{
    BOOL iscon = [FileSystem getConfigWithKey:@"isConnectCopied2KE"] != nil;
    return  iscon || FOR_STORE != 1;
}

+(BOOL)isConnectedKEInUserDefaults
{
    BOOL iscon = [[NSUserDefaults standardUserDefaults] boolForKey:@"isConnected"];
    return  iscon || FOR_STORE != 1;
}

+(void)setMoveFileIngValue:(NSString *)str
{
    [FileSystem changeConfigWithKey:@"isMoveFileIng" value:str];
}

+(BOOL)isMoveFileIngValue
{
    return [FileSystem getConfigWithKey:@"isMoveFileIng"] != nil && [[FileSystem getConfigWithKey:@"isMoveFileIng"] isEqualToString:@"1"];
}

+(void)changeConfigWithKey:(NSString*)key value:(NSString*)value{
    NSMutableDictionary* dict = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:CONFIG_DIR_PATH]) {
        [[CustomFileManage instance] creatDir:CONFIG_DIR_PATH];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CONFIG_FILE_PATH]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:CONFIG_FILE_PATH]];
    }
    else {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setValue:value forKey:key];
    [dict writeToFile:CONFIG_FILE_PATH atomically:YES];
}

+(NSString*)getConfigWithKey:(NSString*)key{
    NSMutableDictionary* dict = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:CONFIG_DIR_PATH]) {
        return nil;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CONFIG_FILE_PATH]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:CONFIG_FILE_PATH]];
        NSString* path = [dict objectForKey:key];
        //        NSLog(@"path : %@",path);
        if ([path isKindOfClass:[NSString class]]&& path && [path rangeOfString:@"/var"].location == 0) {
            path = [NSString stringWithFormat:@"%@%@",APP_DOC_ROOT,[path substringFromIndex:((NSString*)APP_DOC_ROOT).length]];
        }
        return path;
    }
    return nil;
}

void WRITE_LOG(NSString* format,...){
    
    va_list args;
    va_start( args, format );
    NSString* str = [ [ NSString alloc ] initWithFormat: format arguments: args ];
    va_end( args );
    
    NSString *logPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/log.log"];
    BOOL lbExist = [[NSFileManager defaultManager] fileExistsAtPath:logPath];
    if (!lbExist) {
        [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil] ;
    }

    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath: logPath];
    [handle seekToEndOfFile];
    [handle writeData: [str dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}
//设置密码及密保信息
+(BOOL)setQuestion:(NSString*)question Answer:(NSString*)answer Password:(NSString*)password{

    int flag = fso_set_init_security_question_answer_and_passcode((char*)[question UTF8String],
                                                                  (char*)[answer UTF8String],
                                                                  (char*)[password UTF8String]);
    return flag==0 ?YES:NO;
}
//壳里是否有安全码
+(BOOL)checkBindPhone{
    if (isBindReaded) {
        return isBinded;
    }
    int flag =  fso_is_bind_passcode();
    isBinded = (flag == 1);
    isBindReaded = (flag ==1 || flag ==0);
    return isBinded;
}
//获取密保问题
+(NSString *)getQuestion{
    NSString* question = NULL;
    char* buffer = (char*)calloc(1, 101);
    if (!buffer) {
        return question;
    }
    int flag =  fso_query_security_question(buffer , 101);
    if (!flag) {
        question = [NSString stringWithUTF8String:buffer];
        free(buffer);
    }
    return question;
}
//判定密保是否正确
+(BOOL)checkAnswer:(NSString*)answer{
    int flag = fso_is_match_security_answer((char*)[answer UTF8String]);
    return flag ==1 ?YES : NO;
 
}
//判定密码是否正确
+(BOOL)checkPassWord:(NSString *)password{
    [LogUtils writeLog:@" before checkPassWord"];
  int flag = fso_is_match_passcode((char*)[password UTF8String]);
    [LogUtils writeLog:@" after checkPassWord"];
    if (flag == 1) {
        isLockReaded = NO;
    }
    return flag == 1 ?YES:NO;
}
//根据密保问题更改安全码
+(BOOL)modifyPassWord:(NSString*)password withAnswer:(NSString*)answer{
    int flag = fso_modify_passcode_with_security_answer((char*)[answer UTF8String], (char*)[password UTF8String]);
    return flag==0 ? YES:NO;
}
//根据旧密码更改密码
+(BOOL)modifyoldPassWord:(NSString*)oldPassWord withnewPassWord:(NSString*)newPassWord{
    int flag = fso_modify_passcode_with_old_passcode((char*)[oldPassWord UTF8String], (char*)[newPassWord UTF8String]);
    return flag==0 ? YES:NO;
}
//根据密保问题擦除安全码密保问题

+(BOOL)clearAllWithAnswer:(NSString *)answer{
    int flag = fso_clear_security_question_answer_and_current_passcode_with_security_answer((char*)[answer UTF8String]);
    return flag==0 ? YES:NO;
}
//根据密码擦除所有密码
+(BOOL)clearAllWithPassWord:(NSString *)PassWord{
     [LogUtils writeLog:@" before clearAllWithPassWord"];
     int flag = fso_clear_security_question_answer_and_current_passcode_with_current_passcode((char*)[PassWord UTF8String]);
     [LogUtils writeLog:@" before clearAllWithPassWord"];
    return flag==0 ? YES:NO;
};
//手机是否被锁住
+(BOOL)iphoneislocked{
    if (isLockReaded) {
        return isLocked;
    }
    errno = 0;
    
    int flag = fso_query_is_locked();
    isLocked = (flag == 1);
    isLockReaded = (flag ==1 || flag ==0);
    return  isLocked;
}

+(void)resetLocked{
    isLockReaded  = NO;
    isLocked = NO;
    isBinded = NO;
    isBindReaded = NO;
    [self clearVersion];
    [self clearSNStr];
}

+ (float) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace/1024;
}

//截取名称
+(NSString *)getModelNameWith:(NSString *)filename
{
    NSArray *array = [filename componentsSeparatedByString:@"."];
    NSString *name;
    if (array.count > 2) {
        name = [array firstObject];
        for (int i = 1; i < array.count -1; i ++) {
            name = [NSString stringWithFormat:@"%@.%@",name,[array objectAtIndex:i]];
        }
    }
    else{
        name = [filename stringByDeletingPathExtension];
    }
    
    return name;
}

-(void)postOnMainThread:(NSNumber*)notf{
    [LogUtils writeLog:[NSString stringWithFormat:@"%@ sendNotf : %lu",DEBUGMODEL,(unsigned long)notf]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_NOTF object:notf];
    if (notf.integerValue == CU_NOTIFY_DEVOFF) {
        isConnected = NO;
    }
}

+(BOOL)isChinaLan
{    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    return  [currentLanguage isKindOfClass:[NSString class]] && ([currentLanguage isEqualToString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hans-CN"]);
}

+(BOOL)isEngLish
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [currentLanguage isKindOfClass:[NSString class]]&& ([currentLanguage rangeOfString:@"en"].location != NSNotFound);
}

+(BOOL)isCzechLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [currentLanguage isKindOfClass:[NSString class]]&& ([currentLanguage rangeOfString:@"cs"].location != NSNotFound);
}

+(BOOL)isJapanese
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [currentLanguage isKindOfClass:[NSString class]]&& ([currentLanguage rangeOfString:@"ja"].location != NSNotFound);
}

+(NSString *)readLastPathWithKey:(NSString *)key
{
    NSString *pathName;
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    pathName = [userdefault objectForKey:key];
    return pathName;
}

+(NSString *)readFirstLanguageMainPathWithKey:(NSString *)key
{
    NSString *pathName;
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    pathName = [userdefault objectForKey:key];
    return pathName;
}

+(void)saveMainPathWith:(NSString *)key path:(NSString *)path
{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if (![userdefault objectForKey:key]) {
        [userdefault setObject:path forKey:key];
    }
}

+(void)rotateWindow:(BOOL)isLand{
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    
    [invocation setSelector:selector];
    
    [invocation setTarget:[UIDevice currentDevice]];
    
    int val = isLand?UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait;
    
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

@end
