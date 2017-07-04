//
//  PhotoClass.m
//  tjk
//
//  Created by 呼啦呼啦圈 on 15/3/13.
//  Copyright (c) 2015年 taig. All rights reserved.
//

#import "PhotoClass.h"

#define IMG_WIDTH 156*1*WINDOW_SCALE
#pragma mark 图片组超类
@implementation CustomPhotoGroupBean

-(void)getIcon:(void (^)(UIImage *img))block{
    
}

-(NSString *)getName{
        return @"";
}

-(int)getPhotoCount:(typeCode)typecode{
    return 0;
}

-(void)getPhotos:(typeCode)typeCode withBlock:(void (^)(NSArray *allAry))block{
}

@end

@implementation CustomPhotoGroup8_AllBean

-(id)getAsset{
    return nil;
}

-(BOOL)isThisGroup:(id)flag{
    return YES;
}

-(void)getIcon:(void (^)(UIImage *img))block{
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhoto = [PHAsset fetchAssetsWithOptions:options];
    if(allPhoto.count > 0){
    
        PHAsset *ass = [allPhoto lastObject];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:ass
                                                   targetSize:CGSizeMake(IMG_WIDTH, IMG_WIDTH)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    
                                                    if([info objectForKey:@"PHImageResultWantedImageFormatKey"])
                                                        block(result);
                                                }];
    }
}

-(NSString *)getName{
    
    return NSLocalizedString(@"allphoto", @"");
}

-(int)getPhotoCount:(typeCode)typecode{
    PHFetchResult *allPhoto = [PHAsset fetchAssetsWithOptions:nil];
    if (typecode == TYPE_ALL) {
        return (int)allPhoto.count;
    }
    else if(typecode == TYPE_PHOTO || typecode == TYPE_GIF){
        return  (int)[allPhoto countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }
    else if(typecode == TYPE_VIDEO){
        return  (int)[allPhoto countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    }
    return 0;
}

-(void)getPhotos:(typeCode)typeCode withBlock:(void (^)(NSArray *allAry))block{
    
    NSMutableArray *allAry = [[NSMutableArray alloc] init];

    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    if (typeCode == TYPE_PHOTO) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    else if(typeCode == TYPE_VIDEO){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    }
    PHFetchResult *allPhoto = [PHAsset fetchAssetsWithOptions:options];
    if (allPhoto.count > 0) {
        for (int i = 0; i < allPhoto.count; i++) {
            
            PHAsset *result = [allPhoto objectAtIndex:i];
            if (result) {
                CustomPhoto8_Bean *bean = [[CustomPhoto8_Bean alloc] init];
                [bean setAsset:result];
                [allAry addObject:bean];
//                if (allAry.count > 0) {
//                    BOOL hasAdded = NO;
//                    for(int i = 0 ; i < allAry.count ; i ++){
//                        CustomPhoto8_Bean *tmp = [allAry objectAtIndex:i];
//                        if ([tmp getDateNumber] < [bean getDateNumber]) {
//                            [allAry insertObject:bean atIndex:i];
//                            hasAdded = YES;
//                            break;
//                        }
//                    }
//                    if (!hasAdded) {
//                        [allAry addObject:bean];
//                    }
//                }
//                else {
//                    [allAry addObject:bean];
//                }
            }
        }
        block(allAry);
    }else {
        block(nil);
    }
}

@end
#pragma mark 图片组 ios8 子类
@implementation CustomPhotoGroup8_Bean

-(void)setAsset:(PHAssetCollection *)asset{
    
    _asset = asset;
    switch (_asset.assetCollectionSubtype) {
  
        case PHAssetCollectionSubtypeAlbumMyPhotoStream:
        {
            _name = @"000000aaaaaaaaaaa";

            break;
        }
        case PHAssetCollectionSubtypeAlbumCloudShared:
        {
            _name = @"000000aaaaaaaaaaa";

            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumAllHidden:
        {
            _name = NSLocalizedString(@"photohidden", @"");

            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
        {
            _name = NSLocalizedString(@"photobig", @"");

            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumFavorites:
        {
            _name = NSLocalizedString(@"photocollect", @"");

            break;
        }
        case 1000000201:
        {
            _name = NSLocalizedString(@"photodelete", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
        {
            _name = NSLocalizedString(@"photoall", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumTimelapses:
        {
            _name = NSLocalizedString(@"photodelay", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
        {
            _name = NSLocalizedString(@"photoslow", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumRecentlyAdded:
        {
            _name = NSLocalizedString(@"photoadd", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumVideos:
        {
            _name = NSLocalizedString(@"video", @"");
            break;
        }
        case PHAssetCollectionSubtypeSmartAlbumBursts:
        {
            _name = NSLocalizedString(@"photolian", @"");
            break;
        }
        default:
        {
            _name = _asset.localizedTitle;
            break;
        }
    }
}

-(id)getAsset{
    return _asset;
}

-(BOOL)isThisGroup:(id)flag{
    PHChange *change = flag;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:_asset options:nil];
    PHFetchResultChangeDetails *changeDetails = [change changeDetailsForFetchResult:fetchResult];
    if (changeDetails) {
        [changeDetails fetchResultAfterChanges];
        return YES;
    }
    return NO;
}

-(void)getIcon:(void (^)(UIImage *img))block withType:(typeCode)mediaType{

    PHAsset *ass;
    
    PHFetchOptions *fetchoptions = [[PHFetchOptions alloc] init];
    //    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    if (mediaType == TYPE_PHOTO) {
        fetchoptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    else if(mediaType == TYPE_VIDEO){
        fetchoptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    }
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:_asset options:fetchoptions];
    if(_asset.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumCloudShared || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos || _asset.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
        
        ass = [fetchResult lastObject];
    }else{
        
        ass = [fetchResult firstObject];
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:ass
                                               targetSize:CGSizeMake(IMG_WIDTH, IMG_WIDTH)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                block(result);
                                            }];
}

-(NSString *)getName{
    
    return _name;
}

-(int)getPhotoCount:(typeCode)typecode{
//    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    
    PHFetchResult *allPhoto = [PHAsset fetchAssetsInAssetCollection:_asset options:nil];
    if (typecode == TYPE_ALL) {
        return (int)allPhoto.count;
    }
    else if(typecode == TYPE_PHOTO || typecode == TYPE_GIF){
        int count = (int)[allPhoto countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        return  count;
    }
    else if(typecode == TYPE_VIDEO){
        return  (int)[allPhoto countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    }
    return (int)allPhoto.count;
}

-(void)getPhotos:(typeCode)typeCode withBlock:(void (^)(NSArray *allAry))block{
    
    NSMutableArray *allAry = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    
    if (typeCode == TYPE_PHOTO) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    else if(typeCode == TYPE_VIDEO){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    }
    PHFetchResult *allPhoto = [PHAsset fetchAssetsInAssetCollection:_asset options:options];
    if (allPhoto.count > 0) {
        NSLog(@"get photo begin");
        for (int i = 0; i < allPhoto.count; i++) {
            
            PHAsset *result = [allPhoto objectAtIndex:i];
            if (result) {
                CustomPhoto8_Bean *bean = [[CustomPhoto8_Bean alloc] init];
                [bean setAsset:result];
                [allAry addObject:bean];
            }
        }
        NSLog(@"get photo end");
        block(allAry);
    }else {
        block(nil);
    }
}

-(NSArray *)getPhotos:(typeCode)typeCode{
    
    NSMutableArray *allAry = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    //    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    if (typeCode == TYPE_PHOTO) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    }
    else if(typeCode == TYPE_VIDEO){
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
    }
    PHFetchResult *allPhoto = [PHAsset fetchAssetsInAssetCollection:_asset options:options];
    if (allPhoto.count > 0) {
        for (int i = 0; i < allPhoto.count; i++) {
            
            PHAsset *result = [allPhoto objectAtIndex:i];
            if (result) {
                CustomPhoto8_Bean *bean = [[CustomPhoto8_Bean alloc] init];
                [bean setAsset:result];
                [allAry addObject:bean];
            }
        }
        
        return allAry;
     
    }else {
        return nil;
//        block(nil);
    }
}

//-(void)

@end

#pragma mark 图片组 ios7 子类
@implementation CustomPhotoGroup7_Bean

-(void)setAsset:(ALAssetsGroup *)asset{
    
    _asset = asset;
}

-(id)getAsset{
    return _asset;
}

-(BOOL)isThisGroup:(id)url{
    
    return [[_asset valueForProperty:ALAssetsGroupPropertyURL] isEqual:url];
}

-(void)getIcon:(void (^)(UIImage *img))block withType:(typeCode)mediaType{
    
    if (mediaType == TYPE_ALL) {
        block([UIImage imageWithCGImage:[_asset posterImage]]);
    }
    else{
        __block BOOL isget = NO;
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            
            if (!isget) {
                if (result != nil && [result valueForProperty:ALAssetPropertyAssetURL]) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:(mediaType == TYPE_PHOTO ? ALAssetTypePhoto : ALAssetTypeVideo)])
                    {
                        isget = YES;
                        block([UIImage imageWithCGImage:[result thumbnail]]);
                    }
                    
                }
            }
            
        };
        [_asset enumerateAssetsUsingBlock:groupEnumerAtion];
    }
    
    block([UIImage imageWithCGImage:[_asset posterImage]]);
}

-(NSString *)getName{
    
    return [_asset valueForProperty:ALAssetsGroupPropertyName];
}

-(int)getPhotoCount:(typeCode)typecode{
    if (typecode == TYPE_ALL) {
        [_asset setAssetsFilter:[ALAssetsFilter allAssets]];
        return (int)[_asset numberOfAssets];
    }
    else if(typecode == TYPE_PHOTO || typecode == TYPE_GIF){
        [_asset setAssetsFilter:[ALAssetsFilter allPhotos]];
        return (int)[_asset numberOfAssets];
    }
    else if(typecode == TYPE_VIDEO){
        [_asset setAssetsFilter:[ALAssetsFilter allVideos]];
        return (int)[_asset numberOfAssets];
    }
    return 0;
}

-(void)getPhotos:(typeCode)typeCode withBlock:(void (^)(NSArray *allAry))block{
    
    NSMutableArray *allAry = [NSMutableArray array];
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        
        if (result != nil && [result valueForProperty:ALAssetPropertyAssetURL]) {
            
            CustomPhoto7_Bean *bean = [[CustomPhoto7_Bean alloc] init];
            
            [bean setAsset:result];
            if (allAry.count > 0) {
                BOOL hasAdded = NO;
                for(int i = 0 ; i < allAry.count ; i ++){
                    CustomPhoto7_Bean *tmp = [allAry objectAtIndex:i];
                    if ([tmp getDateNumber] < [bean getDateNumber]) {
                        [allAry insertObject:bean atIndex:i];
                        hasAdded = YES;
                        break;
                    }
                }
                if (!hasAdded){
                    [allAry addObject:bean];
                }
            }
            else {
                [allAry addObject:bean];
            }
            
        }
        if(*stop || result == nil){
            block(allAry);
        }
    };
    
    [_asset enumerateAssetsUsingBlock:groupEnumerAtion];
}
@end

#pragma mark 图片超类
@implementation CustomPhotoBean

-(NSString *)getPhotoId{
        return @"";
}

-(int)videoTime{
    return 0;
}

-(long long)getDateNumber{
    return 0;
}

-(NSTimeInterval)getCreateTime
{
    return 0.0;
}

-(typeCode)mediaType{
    
    return 0;
}

-(void)getIcon:(void (^)(UIImage *img, NSString *name))block{
    
    block(nil, @"");
}

-(void)getFull:(void (^)(UIImage *img, NSString *photoId))block{
    
    block(nil, @"");
}

-(void)getImgData:(void (^)(NSData *data, NSString *name, NSString *photoId))block{
    
    block(nil, @"", @"");
}

-(void)getPhotoName:(void (^)(NSString *name))block{
    
    block(nil);
}

-(void)getPhotoSize:(void (^)(NSUInteger size))block{
 
    block(0);
}

-(void)deleteFormPhotos:(void (^)(BOOL isSuccess))block{
    block(NO);
}

@end

#pragma mark 图片 ios7 子类
@implementation CustomPhoto7_Bean

-(NSUInteger)getExistPhotoSize
{
    return _photoSize;
}

-(NSString *)getPhotoId{
    NSURL *url = [_asset valueForProperty:ALAssetPropertyAssetURL];
    return url.absoluteString;
}

-(int)videoTime{
    
    return [[_asset valueForProperty:ALAssetPropertyDuration] intValue];
}

-(long long)getDateNumber{
    NSDate *date = [_asset valueForProperty:ALAssetPropertyDate];
    return date.timeIntervalSince1970;
}

-(void)setAsset:(ALAsset *)asset{
    _asset = asset;
}

- (NSTimeInterval)getCreateTime
{
    NSDate *date = [_asset valueForProperty:ALAssetPropertyDate];
    return date.timeIntervalSince1970;
}

-(typeCode)mediaType{
    if([[_asset valueForProperty:ALAssetPropertyType] isEqualToString:@"ALAssetTypeVideo"]){
        return TYPE_VIDEO;
    }else{
        return TYPE_PHOTO;
    }
}

-(void)getIcon:(void (^)(UIImage *img, NSString *photoId))block{
    NSURL *url = [_asset valueForProperty:ALAssetPropertyAssetURL];
    block([UIImage imageWithCGImage:[_asset thumbnail]], url.absoluteString);
}

-(void)getFull:(void (^)(UIImage *img, NSString *photoId))block{
    
    NSURL *url = [_asset valueForProperty:ALAssetPropertyAssetURL];
    block([UIImage imageWithCGImage:[_asset thumbnail]], url.absoluteString);
}

-(void)getImgData:(void (^)(NSData *data, NSString *name, NSString *photoId))block{
    
    size_t sizeof_buff = RW_BUFFER_SIZE;
    
    NSUInteger wl = 0;
    NSUInteger length = (NSUInteger)[_asset defaultRepresentation].size;
    NSError *error;
    NSMutableData *data = [[NSMutableData alloc] init];
    uint8_t* buff = (uint8_t*)malloc(sizeof_buff);
    if(buff){
        while (wl < length) {
            memset(buff, 0, sizeof_buff);
            NSInteger SomeDataSize = [[_asset defaultRepresentation] getBytes:buff
                                                                   fromOffset:wl
                                                                       length:RW_BUFFER_SIZE
                                                                        error:&error];
            if(error == nil){
                
                [data appendBytes:buff length:SomeDataSize];
            }else{
                break;
            }
            wl += SomeDataSize;
        }
        free(buff);
        buff = NULL;
    }
    
    NSURL *url = [_asset valueForProperty:ALAssetPropertyAssetURL];
    NSString *name = [[_asset defaultRepresentation] filename];
    if (!name) {
        NSUInteger value = arc4random() % 10000;
        name = [NSString stringWithFormat:@"iCloud_%lu.jpg",(data?data.length:value)];
        _name = name;
    }
    block(data,name, url.absoluteString);
}

-(void)getPhotoName:(void (^)(NSString *name))block{
    if(_name){
        block(_name);
        return;
    }
    _name = [[_asset defaultRepresentation] filename];
    block(_name);
}

-(void)getPhotoSize:(void (^)(NSUInteger size))block{
    _photoSize = [_asset defaultRepresentation].size;
    block((float)_photoSize);
}

-(void)deleteFormPhotos:(void (^)(BOOL))block
{
    if (_asset) {
        [_asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                
                block(NO);
            }
            else{
                block(YES);
            }
        }];
    }
}

@end

#pragma mark 图片 ios8 子类
@implementation CustomPhoto8_Bean

-(NSUInteger)getExistPhotoSize
{
    return _photoSize;
}

-(NSString *)getPhotoId{
    
    return _photoId;
}

-(int)videoTime{
    
    return _asset.duration;
}

-(long long)getDateNumber{
    
    NSDate *date = [_asset creationDate];
    return date.timeIntervalSince1970;
}

- (NSTimeInterval)getCreateTime
{
    NSDate *date = [_asset creationDate];
    return date.timeIntervalSince1970;
}

-(PHAsset *)getAsset
{
    return _asset;
}

-(void)setAsset:(PHAsset *)asset{
    
    _asset = asset;
    _photoId = [_asset localIdentifier/*burstIdentifier*/];
}


-(typeCode)mediaType{
    if(_asset.mediaType == PHAssetMediaTypeVideo){
        return TYPE_VIDEO;
    }else{
        return TYPE_PHOTO;
    }
}

-(void)getFull:(void (^)(UIImage *img, NSString *photoId))block{

    [self getPhoto:block size:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill];
}

-(void)getIcon:(void (^)(UIImage *img, NSString *name))block{
    
    [self getPhoto:block size:CGSizeMake(IMG_WIDTH, IMG_WIDTH) contentMode:PHImageContentModeAspectFill];
}

-(void)getPhoto:(void (^)(UIImage *img, NSString *name))block size:(CGSize)size contentMode:(PHImageContentMode)contentMode{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:_asset
                                               targetSize:size
                                              contentMode:contentMode
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {

                                                if(![info objectForKey:@"PHImageFileUTIKey"])
                                                    block(result, _photoId);
                                            }];
}

-(void)getImgData:(void (^)(NSData *data, NSString *name, NSString *photoId))block{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset
                                                      options:options
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                                                    if(!imageData || ([self mediaType] == TYPE_VIDEO && (![[[[url.absoluteString lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mov"]))){
                                                        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info){//info ::PHImageFileSandboxExtensionTokenKey :: ffeeb8878e0495210a670e9d87625ca314ff3b6e;00000000;00000000;000000000000001b;com.apple.avasset.read-only;00000001;01000004;00000000001e9ae4;/private/var/mobile/Media/DCIM/102APPLE/IMG_2589.MOV
                                                            NSString* tokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                                                            NSArray* strs = [tokenKey componentsSeparatedByString:@";"];
                                                            NSString* path = [strs objectAtIndex:(strs.count - 1)];
                                                            NSString* name = [path lastPathComponent];
                                                            if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [path rangeOfString:@"Adjustments"].location != NSNotFound){
                                                                name = [NSString stringWithFormat:@"%@.jpg",[[path substringToIndex:[path rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                            }
                                                            
                                                            if (!name) {
                                                                int value = arc4random() % 10000;
                                                                name = [NSString stringWithFormat:@"iCloud_%ld.jpg",imageData?imageData.length : value];
                                                                _name = name;
                                                            }
                                                            block(path, name, _photoId);
//                                                            block([NSData dataWithContentsOfFile:path], name, _photoId);
                                                        }];
                                                    }
                                                    else {
                                                        NSString* name;
                                                        if (url) {
                                                            NSString* urlStr = url.absoluteString;
                                                            name = [urlStr lastPathComponent];
                                                            if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [urlStr rangeOfString:@"Adjustments"].location != NSNotFound){
                                                                name = [NSString stringWithFormat:@"%@.jpg",[[urlStr substringToIndex:[urlStr rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                            }
                                                        }
                                                        else{
                                                            int value = arc4random() % 10000;
                                                            name = [NSString stringWithFormat:@"iCloud_%ld.jpg",imageData?imageData.length : value];
                                                            _name = name;
                                                        }
//                                                        if (imageData.length > 524288000) {
//                                                            block(nil, name, _photoId);
//                                                        }
//                                                        else {
                                                            block(imageData, name, _photoId);
//                                                        }
                                                    }
                                                }];
}

-(void)getPhotoName:(void (^)(NSString *name))block{
    if(_name){
        block(_name);
        return;
    }
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset
                                                      options:nil
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {                                                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                                                    if([self mediaType] == TYPE_VIDEO && ![[[[url.absoluteString lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mov"]){
                                                        
                                                        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info){
                                                            NSString* tokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                                                            NSArray* strs = [tokenKey componentsSeparatedByString:@";"];
                                                            NSString* path = [strs objectAtIndex:(strs.count - 1)];
                                                            NSString* name = [path lastPathComponent];
                                                            if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [path rangeOfString:@"Adjustments"].location != NSNotFound){
                                                                name = [NSString stringWithFormat:@"%@.jpg",[[path substringToIndex:[path rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                            }
                                                            _name = name;
                                                            block(name);
                                                        }];
                                                    }
                                                    else {
                                                        NSString* urlStr = url.absoluteString;
                                                        NSString* name = [urlStr lastPathComponent];
                                                        if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [urlStr rangeOfString:@"Adjustments"].location != NSNotFound){
                                                            name = [NSString stringWithFormat:@"%@.jpg",[[urlStr substringToIndex:[urlStr rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                        }
                                                        _name = name;
                                                        block(name);
                                                    }
                                                    
                                                }];
    
}
-(void)getPhotoNameAndData:(void (^)(NSString *name,NSInteger size))block{
    
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset
                                                      options:nil
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {                                                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                                                    if([self mediaType] == TYPE_VIDEO && ![[[[url.absoluteString lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mov"]){
                                                        
                                                        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info){
                                                            NSString* tokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                                                            NSArray* strs = [tokenKey componentsSeparatedByString:@";"];
                                                            NSString* path = [strs objectAtIndex:(strs.count - 1)];
                                                            NSString* name = [path lastPathComponent];
                                                            if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [path rangeOfString:@"Adjustments"].location != NSNotFound){
                                                                name = [NSString stringWithFormat:@"%@.jpg",[[path substringToIndex:[path rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                            }
                                                            _name = name;
                                                            NSUInteger size = [FileSystem readFileProperty:path].size;
                                                            _photoSize = size;
                                                            
                                                            block(name,size);
                                                        
                                                        }];
                                                    }
                                                    else {
                                                        NSString* urlStr = url.absoluteString;
                                                        NSString* name = [urlStr lastPathComponent];
                                                        if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [urlStr rangeOfString:@"Adjustments"].location != NSNotFound){
                                                            name = [NSString stringWithFormat:@"%@.jpg",[[urlStr substringToIndex:[urlStr rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                        }
                                                        _name = name;
                                                        NSUInteger size = imageData.length;
                                                        _photoSize = size;
                                                        block(name,size);
                                                    }
                                                    
                                                }];
    
}

-(void)getPhotoSize:(void (^)(NSUInteger size))block{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset
                                                      options:options
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {                                                    NSURL *url = [info objectForKey:@"PHImageFileURLKey"];
                                                    if(!imageData || ([self mediaType] == TYPE_VIDEO && ![[[[url.absoluteString lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mov"])){
                                                        
                                                        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info){
                                                            NSString* tokenKey = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                                                            NSArray* strs = [tokenKey componentsSeparatedByString:@";"];
                                                            NSString* path = [strs objectAtIndex:(strs.count - 1)];
                                                            NSString* name = [path lastPathComponent];
                                                            if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [path rangeOfString:@"Adjustments"].location != NSNotFound){
                                                                name = [NSString stringWithFormat:@"%@.jpg",[[path substringToIndex:[path rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                            }
                                                            _name = name;
                                                            NSUInteger size = [FileSystem readFileProperty:path].size;
                                                            _photoSize = size;
//                                                            NSUInteger size = [NSData dataWithContentsOfFile:path].length;
                                                           block(size);
                                                        }];
                                                    }
                                                    else {
                                                        NSString* urlStr = url.absoluteString;
                                                        NSString* name = [urlStr lastPathComponent];
                                                        if([[name lowercaseString] isEqualToString:@"fullsizerender.jpg"] && [urlStr rangeOfString:@"Adjustments"].location != NSNotFound){
                                                            name = [NSString stringWithFormat:@"%@.jpg",[[urlStr substringToIndex:[urlStr rangeOfString:@"Adjustments"].location] lastPathComponent]];
                                                        }
                                                        _name = name;
                                                        NSUInteger size = imageData.length;
                                                        _photoSize = size;
                                                        block(size);
                                                    }
                                                }];
}



-(void)deleteFormPhotos:(void (^)(BOOL isSuccess))block
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[_asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        block(success);
    }];
}

+(void)deletePhotosWith:(NSArray *)array callback:(void (^)(BOOL isSuccess))block
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:array];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        block(success);
    }];
}

@end