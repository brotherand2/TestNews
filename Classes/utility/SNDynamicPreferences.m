//
//  SNDynamicPreferences.m
//  sohunews
//
//  Created by wangyy on 15/4/16.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNDynamicPreferences.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNCheckManager.h"
#import "SNClientSpecialSkinRequest.h"

@implementation SNDynamicPreferences

@synthesize imageSize = _imageSize;


#define kBottomFontColorDefault     ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"bottomFontColorDefaultNight" : @"bottomFontColorDefault")//底部tab未选中颜色
#define kBottomFontColorSelected    ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"bottomFontColorSelectedNight" : @"bottomFontColorSelected")//底部tab选中颜色
#define kTopFontColorDefault        ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"topFontColorDefaultNight" : @"topFontColorDefault")//频道未选中字体颜色
#define kTopFontColorSelected       ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"topFontColorSelectedNight" : @"topFontColorSelected")//频道选中字体颜色
#define kTopChannelEditorLineColor  ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"topChannelEditLineColorNight" : @"topChannelEditLineColor")//频道管理按钮颜色（三根线）
#define kStatusTextColor            ([[SNThemeManager sharedThemeManager] isNightTheme] ? @"statusBarTextColorNight" : @"statusBarTextColor")//状态栏字体颜色，0默认，1高亮
#define kupdateTime                 @"updateTime"
#define kSkinPicZip                 @"skinPicZip"
#define kSkinPicPath                @"skinPicPath"
#define kIcoTabBarNewImage          @"iOS_new"
#define kSkinBottomNewsName         @"bottomNewsName"
#define kSkinBottomVideoName        @"bottomVideoName"
#define kSkinBottomMyselfName       @"bottomMyselfName"
#define kSkinBottomSohuFriend       @"bottomSohuFriend"
#define kResultValue                @"resultValue"


+ (SNDynamicPreferences *)sharedInstance {
    static SNDynamicPreferences *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDynamicPreferences alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self) {
        if ([SNUserDefaults boolForKey:kNewUserGuideHadBeenShown]) {
            self.resultDic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:kResultValue]];
        }
        else {
            //覆盖安装，删除缓存
            [self clearData];
        }
    }
    
    return self;
}


- (void)dealloc{

}

- (void)requestDynamicPreferences{
   
    if ([[SNDevice sharedInstance] isPlus]) {
        self.imageSize = @"1242";
    } else {
        self.imageSize = @"750";
    }
    [[[SNClientSpecialSkinRequest alloc] initWithImageSize:self.imageSize] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *lastUpdateTime = [self.resultDic objectForKey:kupdateTime];
            NSString *newUpdateTime = [responseObject objectForKey:kupdateTime];
            if (![lastUpdateTime isEqualToString:newUpdateTime]) {
                [self dealSkinPicZip:responseObject];
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

- (NSNumber *)getScaleValue{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [UIScreen mainScreen].scale;
    
    return [NSNumber numberWithFloat:rect.size.width * scale];
}


+ (void)refreshView{
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新
        SNTabBarController *tabbarController = [(sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate] appTabbarController];
        [tabbarController refreshTabbarView];
        
        [SNNotificationManager postNotificationName:kLoadFinishDynamicPreferencesNotification object:nil];
        if ([SNNewsFullscreenManager manager].isFullscreenMode && [[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
            //当前为全屏模式并且为首页频道，使用白色状态条
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
        }else {
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
        }
    });
    
}

- (NSString *)dealColorValue:(NSString *)colorStr defaultColorStr:(NSString *)defaultColorStr {
    if (colorStr != nil && [colorStr length] != 0) {
        return [NSString stringWithFormat:@"#%@", colorStr];
    }
    return [[SNThemeManager sharedThemeManager] currentThemeValueForKey:defaultColorStr];
}

- (void)dealSkinPicZip:(NSDictionary *)dict {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *skinPicZipDic = [dict objectForKey:kSkinPicZip];
        if ([skinPicZipDic isKindOfClass:[NSDictionary class]]) {
            NSString *zipFileUrl = [skinPicZipDic objectForKey:@"url"];
            NSString *md5Value = [skinPicZipDic objectForKey:@"md5"];
            
            NSURL *url = [NSURL URLWithString:zipFileUrl];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.timeoutInterval = 3;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                   returningResponse:nil
                                                               error:&error];
            
            NSString *path = [SNUtility getDocumentPath];
            path = [path stringByAppendingPathComponent:@"skinPic"];
            BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            NSString* filePath = [path stringByAppendingPathComponent:@"skinPic.zip"];
            
            /* 下载的数据 */
            if (data != nil){
                if ([data writeToFile:filePath atomically:YES]) {
                    CFStringRef cfRef = FileMD5HashCreateWithPath((__bridge CFStringRef)(filePath));
                    NSString *fileMD5 = (__bridge NSString *)cfRef;
                    if ([fileMD5 isEqualToString:md5Value]) {
                        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                        [SNUtility unZipFile:filePath zipFileTo:path];
 
                        path = [NSString stringWithFormat:@"skinPic/%@", self.imageSize];
                        
                        self.resultDic = [dict mutableCopy];
                        [self.resultDic setValue:path forKey:kSkinPicPath];
                        [SNUserDefaults setObject:self.resultDic forKey:kResultValue];
                        
                        [SNDynamicPreferences refreshView];
                    }
                    
                    CFRelease(cfRef);
                }
                else {
                    SNDebugLog(@"保存失败.");
                }
            } else {
                SNDebugLog(@"%@", error);
            }
        }
        
    });
}

#pragma mark UIImage

+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            //opaque=YES，透明部分会变黑
            UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [SNDynamicPreferences beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)getDynamicSkinImage:(NSString *)imageName ImageSize:(CGSize)imageSize{
    //红包土豪不参加功能
//    if (![[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
//        return [UIImage themeImageNamed:imageName];
//    }
    
    //开关关闭
    if([SNCheckManager checkDynamicPreferences] == NO){
        return [UIImage themeImageNamed:imageName];
    }
    
    if (self.resultDic == nil || [self.resultDic count] <= 0) {
        return [UIImage themeImageNamed:imageName];
    }
    
    NSString *fileImageName = imageName;
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        fileImageName = [NSString stringWithFormat:@"night_%@", imageName];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@/%@/%@",[SNUtility getDocumentPath], [self.resultDic valueForKey:kSkinPicPath], kIcoTabBarNewImage, fileImageName];
    
    UIImage *bgImage = [[UIImage alloc] initWithContentsOfFile: fileName];
    if (bgImage == nil) {
        return [UIImage themeImageNamed:imageName];
    }
    
    return bgImage;
}

- (NSString *)getDynmicColor:(NSString *)defautlColor type:(SNDynamicColorType)colorType{
//    //红包土豪不参加功能
//    if (![[SNRedPacketManager sharedInstance] showRedPacketActivityTheme]) {
//        return [[SNThemeManager sharedThemeManager] currentThemeValueForKey:defautlColor];
//    }
    
    //开关关闭
    if([SNCheckManager checkDynamicPreferences] == NO){
        return [[SNThemeManager sharedThemeManager] currentThemeValueForKey:defautlColor];
    }
    
    if (self.resultDic == nil || [self.resultDic count] <= 0 || ![self.resultDic stringValueForKey:kSkinPicPath defaultValue:nil]) {
        return [[SNThemeManager sharedThemeManager] currentThemeValueForKey:defautlColor];
    }
    
    switch (colorType) {
        case SNBottomFontColorDefaultType:
            return [self dealColorValue:[self.resultDic valueForKey:kBottomFontColorDefault] defaultColorStr:defautlColor];
            break;
            
        case SNBottomFontColorSelectedType:
            return [self dealColorValue:[self.resultDic valueForKey:kBottomFontColorSelected] defaultColorStr:defautlColor];
            break;
            
        case SNTopFontColorDefaultType:
            return [self dealColorValue:[self.resultDic valueForKey:kTopFontColorDefault] defaultColorStr:defautlColor];
            break;
            
        case SNTopFontColorSelectedType:
            return [self dealColorValue:[self.resultDic valueForKey:kTopFontColorSelected] defaultColorStr:defautlColor];
            break;
            
        case SNTopChannelEditButtonColorType:
            return [self dealColorValue:[self.resultDic valueForKey:kTopChannelEditorLineColor] defaultColorStr:defautlColor];
            break;
            
        default:
            return [[SNThemeManager sharedThemeManager] currentThemeValueForKey:defautlColor];
            break;
    }
}

- (NSString *)getDynmicTabBarTitle:(NSString *)defaultTitle {
    if(![SNCheckManager checkDynamicPreferences]) {
        return defaultTitle;
    }
    
    NSString *newTitle = nil;
    if ([defaultTitle isEqualToString:NSLocalizedString(@"News", nil)]) {
        newTitle = [self.resultDic stringValueForKey:kSkinBottomNewsName defaultValue:defaultTitle];
    }
    else if ([defaultTitle isEqualToString:NSLocalizedString(@"videoTabbarName", nil)]) {
        newTitle = [self.resultDic stringValueForKey:kSkinBottomVideoName defaultValue:defaultTitle];
    }
    else if ([defaultTitle isEqualToString:NSLocalizedString(@"Me", nil)]) {
        newTitle = [self.resultDic stringValueForKey:kSkinBottomSohuFriend defaultValue:defaultTitle];
    }
    else if ([defaultTitle isEqualToString:NSLocalizedString(@"MeName", nil)]) {
        newTitle = [self.resultDic stringValueForKey:kSkinBottomMyselfName defaultValue:defaultTitle];
    }
    
    if (newTitle.length == 0) {
        return defaultTitle;
    }
    
    return newTitle;
}

- (BOOL)statusTextColorShouldChange {
    return [[self.resultDic stringValueForKey:kStatusTextColor defaultValue:@""] boolValue];
}

- (void)clearData {
    if (!self.resultDic) {
        return;
    }
    
    [SNUserDefaults removeObjectForKey:kResultValue];
    
    //删除资源
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[SNUtility getDocumentPath], [self.resultDic valueForKey:kSkinPicPath]];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    self.resultDic = nil;
    self.haveAlreadyClearData = YES;
}

- (BOOL)needRefresh {
    if (self.haveAlreadyClearData) {
        self.haveAlreadyClearData = NO;
        return YES;
    }
    return NO;
}

@end
