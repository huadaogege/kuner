//
//  FileBean.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/24.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "FileBean.h"
#import "CustomFileManage.h"

@interface FileBean (){
    NSString* _sizeStr;
}

@end

@implementation FileBean
@synthesize filePath = _filePath;
@synthesize fileType = _fileType;
@synthesize originTypeIsDir = _originTypeIsDir;

-(instancetype)init{
    
    self = [super init];
    if(self){
        _sizeStr = nil;
        _fileInfo = nil;
    }
    return self;
}

-(void)setFilePath:(NSString *)path{
    
    _filePath = path;
    _fileInfo = [FileSystem readFileProperty:_filePath];
}

-(void)setFileType:(FILE_TYPE)type{
    
    _fileType = type;
}

-(void)setOriginTypeIsDir:(BOOL)isdir
{
    _originTypeIsDir = isdir;
}

-(NSString *)getFilePath{
    
    return _filePath;
}

-(NSString *)getFileName{
    
    return [_filePath lastPathComponent];
}

-(NSData *)getFileData{
    
    return [[CustomFileManage instance] getFileData:_filePath];
}

-(float)getFileSize{
    if ([_filePath.pathExtension isEqualToString:@"m3u8"] && !_sizeStr && [FileSystem readFileProperty:[_filePath stringByAppendingPathComponent:@"durations.txt"]]) {
        if (_sizeStr && _sizeStr.length != 0) {
            return _sizeStr.floatValue;
        }
        NSString* sizePath = [_filePath stringByAppendingPathComponent:@"size.txt"];
        NSData* sizedata = [FileSystem  kr_readData:sizePath];
        if(sizedata){
            _sizeStr = [[NSString alloc] initWithData:sizedata  encoding:NSUTF8StringEncoding];
            return _sizeStr.floatValue;
        }
        else {
            NSString* durationStr = [[NSString alloc] initWithData:[FileSystem  kr_readData:[_filePath stringByAppendingPathComponent:@"durations.txt"]]  encoding:NSUTF8StringEncoding];
            NSMutableArray* durationArray = [NSMutableArray arrayWithArray:[durationStr componentsSeparatedByString:@","]];
            NSInteger allSize = 0;
            for (NSInteger i = 0; i < durationArray.count; i ++) {
                NSString *pathTmp = [_filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%ld.mp4",[[_filePath lastPathComponent] stringByDeletingPathExtension],(i + 1)]];
                FilePropertyBean* info = [FileSystem readFileProperty:pathTmp];
                allSize += info.size;
            }
            _sizeStr = [NSString stringWithFormat:@"%ld",allSize];
            [FileSystem  writeFileToPath:sizePath DataFile:[_sizeStr dataUsingEncoding:NSUTF8StringEncoding]];
            return _sizeStr.floatValue;
        }
//
    }
    if (_sizeStr && _sizeStr.length != 0) {
        return _sizeStr.floatValue;
    }
    if(_fileInfo == nil){
        
        _fileInfo = [FileSystem readFileProperty:_filePath];
    }
    return  _fileInfo.size;
}

-(float)getFileDate{
    
    if(_fileInfo == nil){
        
        _fileInfo = [FileSystem readFileProperty:_filePath];
    }
    if ([_filePath.pathExtension isEqualToString:@"m3u8"] && [FileSystem readFileProperty:[_filePath stringByAppendingPathComponent:@"durations.txt"]]) {
        return  _fileInfo.changeTime;
    }
    else {
        return  _fileInfo.changeTime;
    }
    
}

-(long)getCreateTime
{
    if (![FileSystem isConnectedKEInUserDefaults]) {
        if (creatTimeInApp == 0) {
            NSFileManager *filemanager = [NSFileManager defaultManager];
            NSDictionary *dict = [filemanager attributesOfItemAtPath:_filePath error:nil];
            creatTimeInApp = [dict fileCreationDate].timeIntervalSince1970;
        }
        return creatTimeInApp;
    }
    else{
        if(_fileInfo == nil){
            
            _fileInfo = [FileSystem readFileProperty:_filePath];
        }
        return _fileInfo.creatTime;
    }
}

-(FILE_TYPE)getFileType{

    return _fileType;
}

-(BOOL)getOriginTypeIsDir
{
    return _originTypeIsDir;
}

-(FILE_POSITION)getFilePosition{
    if([_filePath hasPrefix:KE_PHOTO] || [_filePath hasPrefix:KE_VIDEO] || [_filePath hasPrefix:KE_MUSIC] || [_filePath hasPrefix:KE_DOC] || [_filePath hasPrefix:KE_ROOT]){
        return POSITION_HARDDISK;
    }else{
        return POSITION_DEVICE;
    }
}
-(void)resetFileSize{
    _sizeStr = nil;
}
@end
