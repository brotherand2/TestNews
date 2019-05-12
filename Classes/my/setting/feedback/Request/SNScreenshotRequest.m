//
//  SNScreenshotRequest.m
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNScreenshotRequest.h"
#import "SNUserManager.h"
#import "SNNewAlertView.h"
#import "SNPopOverMenu.h"

#import "SNNewsScreenShare.h"//截屏分享
#import "SNNewsScreenShareWindow.h"

/**
 *  -----------------------SNScreenShotView-----------------------
 */
@interface SNScreenShotView : UIView

@end

@implementation SNScreenShotView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event  {
    
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside) {
        [self removeFromSuperview];
    }
    return inside;
}

@end

/**
 *  -----------------------SNScreenshotRequest-----------------------
 */
@interface SNScreenshotRequest ()<SNNewsScreenShareWindowDelegate>

@property (nonatomic, strong) UIView *coverview;

@property (nonatomic, strong) SNNewsScreenShare *screenShare;

@property (nonatomic, strong) SNNewsScreenShareWindow* window;

@end

@implementation SNScreenshotRequest

static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}


- (NSString *)sn_requestUrl {
    return SNLinks_Path_FeedBack_ScreenShot;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

#pragma mark - =================== GetScreenShotToFeedBack ==========================

+ (void)getScreenShotToFeedBack {
    UIViewController *viewController = [TTNavigator navigator].topViewController;
    if ([viewController isKindOfClass:NSClassFromString(@"SLLiveRoomViewController")]) {
        return; // 如果当前在直播全屏界面,不显示截屏反馈
    }
    // –––––––––––––––––––––––––––––––  视频全屏界面,不显示截屏反馈和分享 2017.7.26 –––––––––––––––––––––––––––––––––––––
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:NSClassFromString(@"VideoDetailViewController")]) {
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAticleVideoIsFullScreenKey]) {
        return;
    }
    NSArray <UIWindow *> *array = [UIApplication sharedApplication].windows;
    if (array.count > 2) {
        __block BOOL isSNSVideo = NO;
        [array enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull instance, NSUInteger idx, BOOL * _Nonnull stop) {
            
                if ([instance isKindOfClass:NSClassFromString(@"SnsVideoPlayerView")]) {
                    isSNSVideo = YES;
                    *stop = YES;
                }
            }];
            if (isSNSVideo) *stop = YES;
        }];
        if (isSNSVideo) {
            return;
        }
    }
    // –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    
    NSInteger fbSwitch = [[NSUserDefaults standardUserDefaults] integerForKey:kScreenShotSwitch];
    /**
     *  fbSwitch              0    默认设置页面截屏开关打开(本地没有存储)
     *                        1    截屏开关打开
     *                        2    截屏开关关闭
     */
    
    BOOL isSHH5Web = [SNScreenshotRequest shareCondition];//是正文页
    
    if (fbSwitch == 2) {
        //分享
        if (isSHH5Web==YES) {
            [[self sharedInstance] onlyShareScreenshot];
        }
        
        return;
    }
    
    NSInteger screenShotPermission = [[NSUserDefaults standardUserDefaults] integerForKey:kFbScreenShot];
    /**
     *  screenShotPermission  0    未使用过截屏(本地没有存储)
     *                        1    没有权限截屏反馈
     *                        2    有权限截屏反馈
     */
    switch (screenShotPermission) {
        case 0: {
            // 未使用过截屏,能否截屏反馈需向服务端请求
            __weak typeof(self)weakself = self;
            [[self sharedInstance] send:^(SNBaseRequest *request, id responseObject) {
                if ([responseObject objectForKey:@"data"]) {
                    NSDictionary *dict = responseObject[@"data"];
                    BOOL isFeedBack = [[dict objectForKey:@"isScreenshot"] boolValue];
                    if (isFeedBack) {
                        if (isSHH5Web==YES) {//如果是正文页
                            [[weakself sharedInstance] fbAndShareScreenshot];
                        }
                        else{
                            [[weakself sharedInstance] onlyfbScreenShot];
                        }
                        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kFbScreenShot];
                    } else {
                        if (isSHH5Web==YES) {//如果是正文页
                            [[weakself sharedInstance] onlyShareScreenshot];
                        }
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kFbScreenShot];
                    }
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            } failure:^(SNBaseRequest *request, NSError *error) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                //如果截屏权限失败
                if (isSHH5Web==YES) {//如果是正文页
                    [[weakself sharedInstance] onlyShareScreenshot];
                }
            }];
        }
            break;
        case 1:
            //分享
            if (isSHH5Web==YES) {//如果是正文页
                [[self sharedInstance] onlyShareScreenshot];
            }
            break;
        case 2:
            //分享 反馈
            if (isSHH5Web==YES) {
                [[self sharedInstance] fbAndShareScreenshot];
            }
            else{
                [[self sharedInstance] onlyfbScreenShot];
            }
            break;
    }
}

+ (void)getScreenShotToShare{
    [[self sharedInstance] shareScreenShot];
}

+ (void)getScreenShotToShareWithAnimation:(UIImage*)image WithData:(NSDictionary*)data{
    return [[self sharedInstance] shareScreenShotWithAnimation:image WithData:data];
}

- (void)shareScreenShotWithAnimation:(UIImage*)image WithData:(NSDictionary*)dic{
    
    if (!image) {
        image = [UIImage imageWithScreenshot];
    }
    self.screenShotImage = image;
    if (self.screenShare){
        self.screenShare = nil;
    }
    
    self.screenShare = [[SNNewsScreenShare alloc] initWithImage:image WithParams:dic];
}

- (void)shareScreenShot{
    UIImage *image = [UIImage imageWithScreenshot];
    self.screenShotImage = image;
    if (self.screenShare){
        self.screenShare = nil;
    }
    
    self.screenShare = [[SNNewsScreenShare alloc] initWithImage:image WithParams:nil];
}

+ (BOOL)shareCondition{
    SHH5NewsWebViewController* vc = [SNNewsScreenShare isNewsWebPage];
    if (vc) {
        return YES;
    }
    else{
        return NO;
    }
}

- (void)sharePress:(UIButton *)b{
    [self.window closeWindow];
    
    [self shareScreenShot];
    
    [SNNewsReport reportADotGif:@"_act=share_to&_tp=clk&newsId=&channelid="];
}

- (void)fbPress:(UIButton *)b{
    [self openFeedBack];
}

- (void)fbAndShareScreenshot{
    [SNUtility registerSharePlatform];
    
    if (self.window.superview) {
        return;
    }
    
    if ([self.screenShare isShowSelf]) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    UIImage *image = [UIImage imageWithScreenshot];
    self.screenShotImage = image;
    
    //添加显示
    UIImageView *imgvPhoto = [[UIImageView alloc]initWithImage:image];
    imgvPhoto.frame = window.bounds;
    
    SNNewsScreenShareWindow* small_window = [[SNNewsScreenShareWindow alloc] initWithFrame:window.bounds WithImage:self.screenShotImage];
    small_window.delegate = self;
    [window addSubview:small_window];
    [small_window show];
    
    self.window = small_window;
 
}

- (void)onlyShareScreenshot{
    [SNUtility registerSharePlatform];

    if (self.window.superview) {
        return;
    }
    
    if ([self.screenShare isShowSelf]) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    UIImage *image = [UIImage imageWithScreenshot];
    self.screenShotImage = image;
    
    //添加显示
    UIImageView *imgvPhoto = [[UIImageView alloc]initWithImage:image];
    imgvPhoto.frame = window.bounds;
    
    SNNewsScreenShareWindow* small_window = [[SNNewsScreenShareWindow alloc] initWithFrame:window.bounds WithImage:self.screenShotImage];
    small_window.delegate = self;
    [window addSubview:small_window];
    [small_window showOnlyShare];
    
    self.window = small_window;
    
   
}

- (void)onlyfbScreenShot {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //人为截屏, 模拟用户截屏行为, 获取所截图片
    UIImage *image = [UIImage imageWithScreenshot];
    self.screenShotImage = image;
    
    //添加显示
    UIImageView *imgvPhoto = [[UIImageView alloc]initWithImage:image];
    imgvPhoto.frame = window.bounds;
    
    SNScreenShotView *coverView = [[SNScreenShotView alloc] initWithFrame:window.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    self.coverview = coverView;
    [coverView addSubview:imgvPhoto];
    UIButton *feedBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [feedBackBtn setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    feedBackBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [feedBackBtn setImage:[UIImage imageNamed:@"icoquestion_feedback_v5.png"] forState:UIControlStateNormal];
    [feedBackBtn setTitle:@"反馈" forState:UIControlStateNormal];
    feedBackBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    feedBackBtn.frame = CGRectMake(0, window.bounds.size.height, window.bounds.size.width, 32);
    [feedBackBtn addTarget:self action:@selector(openFeedBack) forControlEvents:UIControlEventTouchUpInside];
    feedBackBtn.backgroundColor = [UIColor clearColor];
    [coverView addSubview:feedBackBtn];
    [window addSubview:coverView];
    
    [UIView animateWithDuration:0.5 animations:^{
        coverView.frame = CGRectMake(window.width - 155 / 2 - 14,
                                     window.height - 64 - 44 - 130,
                                     155 / 2,
                                     209 / 2);
        coverView.backgroundColor = SNUICOLOR(kThemeCenterScreenWindowColor);
        
        coverView.layer.cornerRadius = 4;
        coverView.layer.borderWidth = 4;
        coverView.layer.borderColor = SNUICOLOR(kThemeCenterScreenWindowColor).CGColor;
        
        coverView.layer.masksToBounds = YES;
        
        imgvPhoto.frame = CGRectMake(0, 0, 155 / 2, 145 / 2);
        feedBackBtn.frame = CGRectMake(0, 145 / 2, 155 / 2, 32);
    } completion:^(BOOL finished) {
        [window endEditing:YES];
        //feedBackBtn.backgroundColor = [UIColor clearColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(2.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [coverView removeFromSuperview]; // 2s后 没有操作自动消失
        });
    }];
}

- (void)openFeedBack {
    [self.window closeWindow];
    [self.coverview removeFromSuperview];
    [SNNewAlertView forceDismissAlertView];
    [SNPopOverMenu dismiss];
    /*添加截屏反馈按钮点击埋点 */
    [SNNewsReport reportADotGif:@"act=cc&fun=96&from=pic"];
    TTURLAction *urlAction = [TTURLAction actionWithURLPath:@"tt://quickFeedBack"];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if (self.screenShotImage) {
        [query setObject:self.screenShotImage forKey:kFeedBackScreenshot];
    }
    [query setObject:@"" forKey:kScreenShotSwitch];
    if (query.count > 0) [urlAction applyQuery:query];
    [SNUtility shouldUseSpreadAnimation:NO];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)closeScreenShare{
    [self.screenShare closeScreenShare];
}

+ (void)closeScreenShotToShare{
    [[SNScreenshotRequest sharedInstance] closeScreenShare];
}

@end

