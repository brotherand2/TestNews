//
//  SNNewsScreenShare.m
//  sohunews
//
//  Created by wang shun on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShare.h"
#import "SNDevice.h"
#import "sohunewsAppDelegate.h"

#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"

#import "SNShareItemsView.h"
#import "SNNewAlertView.h"
#import "SNNewsShareManager.h"
#import "SNBaseWebViewController.h"

#import "SNNewsScreenShareViewController.h"
#import "SNNewsShareDrawBoardViewController.h"

#import "SNCommonNewsController.h"

#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface SNNewsScreenShare ()<SNNewsScreenShareVCDelegate,SNNewsShareDrawBoardVCDelegate>
{
    BOOL isSHH5News;
    BOOL isRemovedSelf;
}

@property (nonatomic,strong) UIImage* basic_img;
@property (nonatomic,strong) UIImage* clip_img;
@property (nonatomic,strong) UIImage* brush_img;
@property (nonatomic,strong) UIImage* share_img;

@property (nonatomic,strong) UIImageView* qr_code_view;
@property (nonatomic,strong) UIView* share_imageview;

@property (nonatomic,strong) NSDictionary* shareonDic;

@property (nonatomic,strong) SNNewsShareManager* shareManager;

@property (nonatomic,strong) SNNewsScreenShareViewController* screenShareViewController;
@property (nonatomic,strong) SNNewsShareDrawBoardViewController* drawBoardViewController;

@end

@implementation SNNewsScreenShare


-(instancetype)initWithImage:(UIImage *)image WithParams:(NSDictionary *)dic{
    if (self = [super init]) {
        self.basic_img = image;
        isSHH5News = NO;
        
        [self isSHH5webWithData:dic];
        
//        [self clipImage];
        
        [self enterDrawBoardView:nil];
    }
    return self;
}

- (void)reEnter{
    [self enterDrawBoardView:nil];
}


+ (SHH5NewsWebViewController*)isNewsWebPage{//是否是正文页
    NSArray* arr = [TTNavigator navigator].visibleViewController.flipboardNavigationController.viewControllers;
    if ([arr lastObject]) {
        id vc = [arr lastObject];
        if ([vc isKindOfClass:[SNCommonNewsController class]]) {
            SNCommonNewsController* cvc = (SNCommonNewsController*)vc;
            if ([cvc.currentController isKindOfClass:[SHH5NewsWebViewController class]]) {
                SHH5NewsWebViewController* nvc = (SHH5NewsWebViewController*)cvc.currentController;
                return nvc;
            }
        }
        else if ([vc isKindOfClass:[SHH5NewsWebViewController class]]){
            return vc;
        }
        else if ([vc isKindOfClass:[SNBaseWebViewController class]]){
            return vc;
        }
    }
    
    return nil;
}

- (void)isSHH5webWithData:(NSDictionary*)data{
    
    SHH5NewsWebViewController* nvc = [SNNewsScreenShare isNewsWebPage];
    NSDictionary* dic = @{};
    if ([nvc isKindOfClass:[SHH5NewsWebViewController class]]) {
        isSHH5News = YES;
        dic = [nvc mainBodyShareData];
        self.shareonDic = dic;
    }
    else{
        isSHH5News = NO;
        if (data) {//如果data 是点击来的
            self.shareonDic = data;
        }
        else{//截屏进来的
            if ([nvc isKindOfClass:[SNBaseWebViewController class]]) {
                SNBaseWebViewController* base = (SNBaseWebViewController*)nvc;
                NSDictionary* d = [base getShareData];
                if (d) {
                    self.shareonDic = d;
                }
            }
        }
        
    }
    
}

- (void)clipImage{
    
    CGFloat height = [[SNDevice sharedInstance] isPlus]? 20*3:20*2;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        height = 44*3;
    }
    CGRect rect = CGRectMake(0, height, self.basic_img.size.width, self.basic_img.size.height-height);
    //裁剪电池栏
    self.clip_img = [SNNewsScreenShare clipWithImageRect:rect clipImage:self.basic_img];
   
    //if (isSHH5News == YES) {
        //裁剪评论分享toolbar
    height = [[SNDevice sharedInstance] isPlus]? 44*3:44*2;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        height = 64*3;
    }
    rect = CGRectMake(0, 0, self.clip_img.size.width, self.clip_img.size.height-height);
    self.clip_img = [SNNewsScreenShare clipWithImageRect:rect clipImage:self.clip_img];
    //}
    
    //[self showScreenView];
}

- (UIImage*)clipImageAgain:(UIImage*)image{
    
    CGFloat height = [[SNDevice sharedInstance] isPlus]? 20*3:20*2;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        height = 44*3;
    }
    CGRect rect = CGRectMake(0, height, self.basic_img.size.width, self.basic_img.size.height-height);
    //裁剪电池栏
    self.clip_img = [SNNewsScreenShare clipWithImageRect:rect clipImage:self.basic_img];
    
//    if (isSHH5News == YES) {
        //裁剪评论分享toolbar
        height = [[SNDevice sharedInstance] isPlus]? 44*3:44*2;
        if ([[SNDevice sharedInstance] isPhoneX]) {
            height = 64*3;
        }
        rect = CGRectMake(0, 0, self.clip_img.size.width, self.clip_img.size.height-height);
        self.clip_img = [SNNewsScreenShare clipWithImageRect:rect clipImage:self.clip_img];
//    }
    
    //二期不用再次
//    CGFloat  height = [[SNDevice sharedInstance] isPlus]? 20*3:20*2;
//    CGRect   rect = CGRectMake(0, height, image.size.width, image.size.height-height);
//    //裁剪电池栏
//    final_image = [SNNewsScreenShare clipWithImageRect:rect clipImage:image];
//    
//    if (isSHH5News == YES) {
//        //裁剪评论分享toolbar
//        CGFloat height = [[SNDevice sharedInstance] isPlus]? 44*3:44*2;
//        CGRect rect = CGRectMake(0, 0, final_image.size.width, final_image.size.height-height);
//        final_image = [SNNewsScreenShare clipWithImageRect:rect clipImage:final_image];
//    }
    return self.clip_img;
}

- (void)showScreenView{
    NSString* isSHH5News_str = @"0";
    if (isSHH5News == YES) {
        isSHH5News_str = @"1";
    }
    self.screenShareViewController = [[SNNewsScreenShareViewController alloc] initWithClipImage:self.clip_img WithBrushImage:self.brush_img BaseImage:self.basic_img WithData:@{@"isSHH5News":isSHH5News_str,@"shareon":self.shareonDic}];
    
    [self.screenShareViewController.view setFrame:[UIScreen mainScreen].bounds];
    [self.screenShareViewController.view setBackgroundColor:[UIColor whiteColor]];
    
    self.screenShareViewController.delgate = self;
    
//    sohunewsAppDelegate* app = (sohunewsAppDelegate*)[UIApplication sharedApplication].delegate;
//    [app.window addSubview:self.screenShareViewController.view];
    
//    UIViewController* vc = [SNNewsScreenShare isNewsWebPage];
//    [vc.view addSubview:self.screenShareViewController.view];
    
     [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:self.screenShareViewController animated:NO];
    
    isRemovedSelf = NO;
}

- (void)enterDrawBoardView:(UIButton*)b{
    if (self.drawBoardViewController) {
        
        [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:self.drawBoardViewController animated:YES];
        [self.drawBoardViewController reEnterSelf];
        return;
    }
    
    [self clipImage];
    
    self.drawBoardViewController = [[SNNewsShareDrawBoardViewController alloc] initWithEditorImage:self.clip_img];
    //[self addChildViewController:self.drawBoardViewController];
    self.drawBoardViewController.delegate = self;
    [SNUtility shouldUseSpreadAnimation:NO];
    [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:self.drawBoardViewController animated:YES];
    
    isRemovedSelf = NO;
    
    [SNNewsReport reportADotGif:@"_act=highlight&_tp=clk&newsId=&channelid="];
}

- (void)pushPreViewController:(id)sender{
    [self showScreenView];
}

-(UIImage *)getClipImage:(UIImage *)img{
    if (img) {
        self.brush_img = img;//笔刷
    }
    
    if (self.basic_img) {
        self.clip_img = [self clipImageAgain:self.basic_img];
        return self.clip_img;
    }
    return nil;
}



- (void)removedSelf{
    isRemovedSelf = YES;
}

- (BOOL)isShowSelf{
    return !isRemovedSelf;
}

- (void)closeScreenShare{
    [self removedSelf];
//    sohunewsAppDelegate* app = (sohunewsAppDelegate*)[UIApplication sharedApplication].delegate;
//    if ([self.screenShareViewController.view isDescendantOfView:app.window]) {
//        [self.screenShareViewController closeSelf];
//    }
}


//返回裁剪区域图片,返回裁剪区域大小图片
+ (UIImage *)clipWithImageRect:(CGRect)clipRect clipImage:(UIImage *)clipImage{
    
    UIGraphicsBeginImageContext(clipRect.size);
    
    [clipImage drawInRect:CGRectMake(-clipRect.origin.x,-clipRect.origin.y,clipImage.size.width,clipImage.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return  newImage;
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
+ (UIImage*)createQRcodeImage:(NSString*)url{
    
    UIImage *codeImage = nil;
    CGSize size = CGSizeMake(300, 300);
    if (IOS8_OR_LATER) {
        NSData *stringData = [url dataUsingEncoding:NSUTF8StringEncoding];
        
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
        
        UIColor *onColor = [UIColor blackColor];
        UIColor *offColor = [UIColor whiteColor];
        
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
    } else {
        
        NSError* error = nil;
        ZXMultiFormatWriter* writer = [ZXMultiFormatWriter writer];
        ZXBitMatrix* result = [writer encode:url format:kBarcodeFormatQRCode width:114 height:114 error:&error];
        if (result) {
            CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
            
            codeImage = [UIImage imageWithCGImage:image];
            
            // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
        }
    }
    return codeImage;
}

+ (UIImage *)getImageFromView:(UIView *)theView
{
    //UIGraphicsBeginImageContext(theView.bounds.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, theView.layer.contentsScale);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//获取时间间隔
+ (double)getDateInterval:(NSDate*)date1 Date2:(NSDate*)date2{
    // 时间1
    NSTimeZone *zone1 = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone1 secondsFromGMTForDate:date1];
    NSDate *localDate1 = [date1 dateByAddingTimeInterval:interval1];
    
    // 时间2
    NSTimeZone *zone2 = [NSTimeZone systemTimeZone];
    NSInteger interval2 = [zone2 secondsFromGMTForDate:date2];
    NSDate *localDate2 = [date2 dateByAddingTimeInterval:interval2];
    
    // 时间2与时间1之间的时间差（秒）
    double intervalTime = [localDate2 timeIntervalSinceReferenceDate] - [localDate1 timeIntervalSinceReferenceDate];
    return intervalTime;
}


@end
