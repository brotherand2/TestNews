//
//  SNThemeManager.m
//  sohunews
//
//  Created by qi pei on 5/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "sohunewsAppDelegate.h"
#import "WSMVConst.h"
#import "SNThemeManagerContenxt.h"
#import "UIDevice-Hardware.h"
#import "SNConsts.h"

#import "SNMySDK.h"
#import "SNSkinManager.h"

#define TEST 0
#define CACHE_LOG(...)

static int img_count = 0;

@implementation SNThemeManager

@synthesize currentTheme;
@synthesize currentThemeDictionary;
@synthesize themeDirFullPath;
@synthesize isRetina;

@synthesize imageCachedDictionary;

+ (SNThemeManager *)sharedThemeManager {
    static SNThemeManager *instance = nil;
    if (!instance) {
        instance = [[SNThemeManager alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {

        isRetina = [UIDevice isRetina];
        themeDirFullPath = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                                  stringByAppendingPathComponent:kThemeDirName]
                                 stringByAppendingPathComponent:@"default"] copy];
 
        NSString *path = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = [self.themeDirFullPath stringByAppendingFormat:@"/%@.plist", @"default"];
        }
        currentThemeDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        imageCachedDictionary = [[NSCache alloc] init];
    }
    return self;
}

-(void)setCurrentTheme:(NSString *)aTheme
{
    if (![currentTheme isEqualToString:aTheme])
    {
        currentTheme = [aTheme copy];
       
        self.themeDirFullPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                                  stringByAppendingPathComponent:kThemeDirName]
                                 stringByAppendingPathComponent:currentTheme];
        
        [[NSUserDefaults standardUserDefaults] setObject:aTheme forKey:kThemeSelectedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
         //(currentThemeDictionary);
        NSString *path = [[NSBundle mainBundle] pathForResource:currentTheme ofType:@"plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = [self.themeDirFullPath stringByAppendingFormat:@"/%@.plist", currentTheme];
        }
        currentThemeDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];

        if (imageCachedDictionary) {
            [self dumpAllCachedImages];
            [self clearAllCachedImages];
             //(imageCachedDictionary);
        }
        imageCachedDictionary = [[NSCache alloc] init];
    }
}

-(void)launchCurrentTheme:(NSString *)aTheme {
    if (![currentTheme isEqualToString:aTheme]) {
        [self setCurrentTheme:aTheme];
        
        // v5.2.0 皮肤管理类
        [[SNSkinManager skinInstance] updateCurrentTheme];
        
        SNTabBarController *tabbarController = [(sohunewsAppDelegate *)[[UIApplication sharedApplication] delegate] appTabbarController];
        [tabbarController updateAppTheme];
        
        [[SNMySDK sharedInstance] updateAppTheme];
    }
}

- (void)clearAllCachedImages {
    img_count = 0;
    [imageCachedDictionary removeAllObjects];
}

- (void)dumpAllCachedImages {
#if TEST
    int index = 0;
    float totalSize = 0;
    
    printf("\n\n********************************************************\n");
    for (NSString *aKey in [imageCachedDictionary keyEnumerator]) {
        UIImage *img = [imageCachedDictionary objectForKey:aKey];
        NSAssert([img isKindOfClass:[UIImage class]], @"possiblly error object with key: %@", aKey);
        totalSize += img.size.width*img.scale*img.size.height*img.scale*4;
        
        printf("[%04d] size: %d x %d %fk %s \n", ++index, (int)(img.size.width*img.scale), (int)(img.size.height*img.scale), img.size.width*img.scale*img.size.height*img.scale*4/1024, [aKey UTF8String]);
    }
    printf("\n total: %d images, %fk bytes", index, totalSize/1024);
    printf("\n\n********************************************************\n");
#endif
}

-(void)customerNavgationBar {

}

-(NSString*)currentThemeValueForKey:(NSString*)key {
    return [currentThemeDictionary objectForKey:key];
}

-(UIColor *)currentThemeColorForKey:(NSString*)key {
    NSString *colorString = [self currentThemeValueForKey:key];
    UIColor *themeColor = [UIColor colorFromString:colorString];
    return themeColor;
}

//这个方法废弃了，不要用了，直接使用[UIImage imageNamed:iconName]，我们做了扩展，自动识别主题
-(NSString*)themeFileName:(NSString*)fileName {
    //    if (![currentTheme isEqualToString:kThemeDefault]) {
    //        return [NSString stringWithFormat:@"%@_%@",currentTheme,fileName];
    //    }
    return fileName;
}

//直接使用[UIImage imageNamed:iconName]，我们做了扩展，自动识别主题
- (NSString *)themeFileNameEx:(NSString *)fileName {
    if (currentTheme && ![currentTheme isEqualToString:kThemeDefault]) {
        return [NSString stringWithFormat:@"%@_%@",currentTheme,fileName];
    }
    return fileName;
}

- (BOOL)isNightTheme {
    return ([currentTheme isEqualToString:kThemeNight]);
}

- (NSString*)currentTheme {
    return currentTheme;
}

- (UIColor *)themeWithColor:(UIColor *) color nightColor:(UIColor *) nightColor {
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        return nightColor;
    }else {
        return color;
    }
}

- (void)dealloc {
     //(currentTheme);
     //(currentThemeDictionary);
     //(themeDirFullPath);
     //(imageCachedDictionary);
}

@end

@implementation UIImage (themeImage)

+ (UIImage *)themeImageNamed:(NSString *)name {
    return [self snImageNamed:name];
}

+ (UIImage *)altImageNamed:(NSString *)name {
    return [self themeImageNamed:name];
}

#pragma mark - 根据倍屏加载对应的本地图片素材
+ (UIImage *)snImageNamed:(NSString *)imageName {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    

    NSString *themeImageName = [themeManager themeFileNameEx:imageName];
    if (imageName.length <= 0 || themeImageName.length <= 0) {
        NSLogFatal(@"imageName %@ or themeImageName %@ is nil", imageName, themeImageName);
        return nil;
    }
    
    NSArray *themeImageNameComponents = [themeImageName componentsSeparatedByString:@"."];
    NSArray *imageNameComponents = [imageName componentsSeparatedByString:@"."];
    NSRange range = [themeImageName rangeOfString:@"SVVideoForNews.bundle"];//判断字符串是否包含
    if (range.length >0)//包含
    {
        NSLogFatal(@"Invalid imagename %@ or themeImageName %@", imageName, themeImageName);
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        return image;
    }
    if (imageNameComponents.count!= 2 && themeImageNameComponents.count != 2) {
        NSLogFatal(@"Invalid imagename %@ or themeImageName %@", imageName, themeImageName);
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        return image;
    }

    //首先从内存缓存中读取，如无，则从文件系统中读取
    UIImage *image = [themeManager.imageCachedDictionary objectForKey:themeImageName];
    if (!image) {//无缓存则从本地文件系统目录读取
        SNThemeManagerContenxt *context = [[SNThemeManagerContenxt alloc] init];
        context.imageName = imageName;
        context.imageNameComponents = imageNameComponents;
        context.themeImageName = themeImageName;
        context.themeImageNameComponents = themeImageNameComponents;
        context.scale = [[UIScreen mainScreen] scale];

        
        //兼容非完美适配下iPhone6plus的scale为2.0但需要加载@3x素材的情况
        if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice6PlusiPhone || [[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice7PlusiPhone || [[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice8PlusiPhone) {
            context.scale = SNThemeManagerContenxtScale3X;
        }
        //兼容scale 3.0以下以及iOS7+系统优先使用@ios7@2x的素材
        if (context.scale < SNThemeManagerContenxtScale3X
            && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            context.scale = SNThemeManagerContenxtScaleiOS7;
        }
        //兼容scale 1.0时优先使用@2x素材
        if (context.scale <= SNThemeManagerContenxtScale2X) {//兼容1倍屏
            context.scale = SNThemeManagerContenxtScale2X;
        }
        
        //lijian 2015.03.04 不用递归用循环
        /*
        NSString *imageFilePath = [[self imageFilePathWithContext:context] copy];
        image = [self readImageFromDisk:imageFilePath context:context];
        [imageFilePath release];
        imageFilePath = nil;
        [context release];
        context = nil;
        */
        NSString *imageFilePath = [self imageFilePathWithContext:context];
        for(;nil == imageFilePath;)
        {
            if (context.scale > SNThemeManagerContenxtScale1X) {
                [context downscale];
                imageFilePath = [self imageFilePathWithContext:context];
            }else{
                break;
            }
        }
        
        if(nil != imageFilePath){
            image = [self readImageFromDisk:imageFilePath context:context];
        }
        // v5.2.0
        context = nil;
    }
    if (nil == image) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
        image = [UIImage imageWithContentsOfFile:path];
    }
    return image;
}

+ (NSString *)imageFilePathWithContext:(SNThemeManagerContenxt *)context {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    BOOL isNightTheme = ![themeManager.currentTheme isEqualToString:kThemeDefault];
    NSFileManager *fileManager = [NSFileManager defaultManager]; // v5.2.0 改为单例获取
    NSString *themeImageFilePath = nil;
    
    NSString *imageNamePattern = [context imageNamePatterByScale];
    NSString *tempName = [NSString stringWithFormat:imageNamePattern,
                          [context.themeImageNameComponents objectAtIndex:0],
                          [context.themeImageNameComponents objectAtIndex:1]];
    themeImageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempName];
    //如果无contenxt中scale指定倍屏夜间素材则查找对应倍屏的日间素材
    BOOL isDirectory = NO;
    if (isNightTheme && ![fileManager fileExistsAtPath:themeImageFilePath isDirectory:&isDirectory]) {
        tempName = [NSString stringWithFormat:imageNamePattern,
                    [context.imageNameComponents objectAtIndex:0],
                    [context.imageNameComponents objectAtIndex:1]];
        //日间素材路径
        themeImageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempName];
    }
    
    if ([fileManager fileExistsAtPath:themeImageFilePath isDirectory:&isDirectory]) {
        return themeImageFilePath;
    }

    //lijian 2015.03.04 不用递归也可以
    /*
    //如果无contenxt中scale指定倍屏日夜间素材都没有，则再查找低倍屏下同名的日夜间素材
    else {
        [fileManager release];
        fileManager = nil;
        if (context.scale > 1.0) {
            [context downscale];
            return [self imageFilePathWithContext:context];
        } else {
            return nil;
        }
    }
    */
    
    return nil;
}

+ (UIImage *)readImageFromDisk:(NSString *)imageFilePath context:(SNThemeManagerContenxt *)context {
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    if (image) {
        if (!themeManager.isRetina && image.scale == SNThemeManagerContenxtScale2X) {//在低分屏上把二倍图压缩成一倍图
            UIGraphicsBeginImageContextWithOptions(image.size, NO, SNThemeManagerContenxtScale1X);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        if (!!image) {
            [themeManager.imageCachedDictionary setObject:image forKey:context.themeImageName];
            NSLogInfo(@"Had load image %@ from %@", context.imageName, imageFilePath);
        } else {
            NSLogFatal(@"Failed to load image %@ from %@", context.imageName, imageFilePath);
        }
    } else {
        NSLogFatal(@"Failed to load image %@ from %@", context.imageName, imageFilePath);
    }
    return image;
}

@end

@implementation UIButton(themeButton)
- (void)altSetTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self altSetTitleColor:color forState:state];
    if (state == UIControlStateNormal) {
        CGFloat rgba[4];
        [color getColorComponents:rgba];
        uint8_t red = rgba[0]*255;
        uint8_t green = rgba[1]*255;
        uint8_t blue = rgba[2]*255;
        uint8_t alpha = kThemeUIButtonHighlightedTitleColorAlpha*255;
        int32_t RGBAValue = (red << 24) + (green << 16) + (blue << 8) + alpha;
        UIColor *themeColor = [UIColor initWithRGBAValue:RGBAValue];
        [self altSetTitleColor:themeColor forState:UIControlStateHighlighted];
        themeColor = nil;
    }
}
@end
