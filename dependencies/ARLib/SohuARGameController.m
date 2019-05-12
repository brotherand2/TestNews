//
//  SohuARGameController.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import "SohuARGameController.h"
#import "SohuARGameSCNView.h"
#import "SohuLoadingView.h"
#import "SohuCameraView.h"
#import "SohuNetworking.h"
#import "SohuFileManager.h"
#include "SohuARMacro.h"
#import "SohuConfigurations.h"
#import "SohuARSingleton.h"
#import "SohuScreenShotTool.h"
#import "SohuARGameBaseScene.h"
#import "SNUserManager.h"

static NSString *kalertViewMessage=@"请在iPhone的“设置-隐私-相机”选项中，允许搜狐新闻访问你的相机";
static NSString *kconfirm=@"确定";

@interface SohuARGameController ()<SCNSceneRendererDelegate,SohuCameraViewDelegate,SohuARGameBaseSceneDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong) SohuARGameSCNView    *scnView;
@property(nonatomic,strong) SohuARGameBaseScene  *scene;
@property(nonatomic,strong) SohuCameraView       *cameraView;
@property(nonatomic,strong) CMMotionManager      *motionManager;
@property(nonatomic,strong) AVAudioPlayer        *audioPlayer;
@property(nonatomic,strong) SohuLoadingView      *loadingView;
@property(nonatomic,strong) SohuARSingleton      *singleton;
@property(nonatomic,strong) UILabel              *hudLabel;

@end

@implementation SohuARGameController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.activityID = [query objectForKey:kJingDongActivityID];
        self.userID = [SNUserManager getUserId];
    }
    return self;
}

#pragma mark - life Cycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserverForNotification];
    self.navigationController.navigationBar.hidden=YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled=NO;
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.userInteractionEnabled=NO;
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    if (_scnView) {
        SohuARGameBaseScene *scene=(SohuARGameBaseScene *)self.scnView.scene;
        [scene sceneDidAppear];
    }
    if(_audioPlayer){
        [_audioPlayer play];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    if (![self enableAR]) {
        return;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SohuNetworking sohuARstatistics];
    if (_audioPlayer) {
        [_audioPlayer pause];
    }
    if(_scnView){
        if ([self.scnView.scene isKindOfClass:[SohuARGameBaseScene class]]) {
            SohuARGameBaseScene *scene=(SohuARGameBaseScene *)self.scnView.scene;
            [scene sceneDidDisappear];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden=NO;
    [SohuARSingleton clean];
}


#pragma mark - setupView
-(void)setupView{
    [self setupSingleton];
    if (self.scnView) {
        [self.view addSubview:self.scnView];
        [self setupSceneWithSceneType:[self.singleton.arConfigurations[@"arType"] integerValue]];
        [self setupMotionManager];
        [self setupAudioPlayer];
    }
}
-(void)setupSceneWithSceneType:(NSInteger)type{
    self.scnView.scene=[SohuARGameBaseScene scene];
    SohuARGameBaseScene *baseScene=(SohuARGameBaseScene *)self.scnView.scene;
    baseScene.delegate=self;
    baseScene.superview=self.scnView;
    NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations];
    [baseScene setupSceneWith3DModelPathArray:dic[@"InitializationModel"]];
}

-(void)setupSingleton{
    self.singleton= [SohuARSingleton sharedInstance];
    NSDictionary *dic= [NSDictionary dictionaryWithContentsOfFile:[SohuFileManager loadAbsolutePathWithRelativePath:@"Configurations.plist"]];
    self.singleton.arConfigurations=dic;
}

#pragma mark - download Zip
-(void)downloadArZip{
    KWS(weakSelf);
    [self.view addSubview:self.loadingView];
    [SohuNetworking downloadArZipInfoWithActivityID:@"" progress:^(float progress) {
    } success:^(NSInteger state) {
        self.view.userInteractionEnabled=YES;
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        if (state==1) {
            [self setupView];
            [weakSelf.loadingView removeFromSuperview];
        }else{
            UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@""
                                                            message:@"加载失败,请重试"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alerView show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.loadingView removeFromSuperview];
            });
        }
    }];
}

#pragma mark - sohuARGameBaseScene delegate
-(void)sohuARGameBaseScene:(SohuARGameBaseScene *)sohuARGameBaseScene didClick:(NSInteger)index{
    if (index==0) {
        if (self.flipboardNavigationController) {
            [self.flipboardNavigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if (index==1){
        [self.cameraView currtenImage];
    }
}

#pragma mark - sohuCameraView Delgate
-(void)sohuCameraView:(SohuCameraView *)sohuCameraView currentImage:(UIImage *)image{
    UIImage *saveImage=[SohuScreenShotTool addImage1:image withImage1:self.scnView.snapshot];
    UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil,nil);
    self.hudLabel.text=@"配置中";
    
    NSData *data= UIImageJPEGRepresentation(saveImage, 0.5);
    saveImage=[UIImage imageWithData:data];
    if(saveImage){
        [SohuNetworking uploadImageWithURL:@"web/file/upload" image:saveImage success:^(id json) {
            NSDictionary *dic=json;
            if ([dic[@"result_code"] boolValue]==0) {
                NSString *imagePath=dic[@"data"][@"cdnPath"];
                NSString *imageName=dic[@"data"][@"urlName"];
                NSString *string=[NSString stringWithFormat:@"%@%@",imagePath,imageName];
                NSString *webViewURL=[[SohuARSingleton sharedInstance] arConfigurations][@"photographWebViewURL"];
                if([imagePath length]>0&&[webViewURL length]>0) {
                    [self sohuARGameController:self webViewParameter:@{@"gameImageUrl":string,@"webViewUrl":webViewURL}];
                }
                [_hudLabel removeFromSuperview];
                _hudLabel=nil;
            }
        } failure:^(NSError *error) {
            self.hudLabel.text=@"配置失败";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_hudLabel removeFromSuperview];
                _hudLabel=nil;
                
            });
        }];
    }
}

#pragma mark - Motion Manager
-(void)setupMotionManager{
    if (self.motionManager.gyroAvailable) {
        KWS(weakSelf);
        NSOperationQueue *magnetometerQueue = [[NSOperationQueue alloc] init];
        [self.motionManager startDeviceMotionUpdatesToQueue:magnetometerQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [weakSelf performSelectorOnMainThread:@selector(onMainThread:)
                                       withObject:motion waitUntilDone:NO];
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - add Observer For Notification
-(void)addObserverForNotification{
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(goHTMLNotification:)
                   name:kgoHTMLNotification
                 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark - some Action
-(void)goHTMLNotification:(NSNotification *)notification{
    [self sohuARGameController:self webViewParameter:notification.object];
}

-(void)applicationDidEnterBackground{
    [_audioPlayer pause];
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - setup Camera

#pragma mark - Private method
-(void)hiddenBar{
    [self addObserverForNotification];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [_scene sceneDidAppear];
    [_audioPlayer play];
}

-(void)showBar{
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_scene sceneDidDisappear];
    [_audioPlayer play];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)setupAudioPlayer{
    NSString *backgroundMausic=[[SohuARSingleton sharedInstance] arConfigurations][kBackgroundMusic];
    if ([backgroundMausic length]>0) {
        self.audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[SohuFileManager loadMusicFromCachesWithRelativePath:backgroundMausic] error:nil];
        self.audioPlayer.volume=0.5;
        self.audioPlayer.numberOfLoops=-1;
        [self.audioPlayer play];
    }
}

-(void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:kconfirm
                                          otherButtonTitles:nil, nil];
    [self.view addSubview:alerView];
    [alerView show];
}

- (void)onMainThread:(CMDeviceMotion *)motion{
    SohuARGameBaseScene *scene=(SohuARGameBaseScene *)self.scnView.scene;
    [scene deviceMotionUpdatesWithDeviceMotion:motion];
}


#pragma mark - setter
-(void)setUserID:(NSString *)userID{
    _userID=userID;
    [[SohuARSingleton sharedInstance] setUserID:_userID];
}

-(void)setActivityID:(NSString *)activityID{
    _activityID=activityID;
    [[SohuARSingleton sharedInstance] setActivityID:activityID];
}

-(void)setOtherParameter:(NSDictionary *)otherParameter{
    _otherParameter=otherParameter;
    [[SohuARSingleton sharedInstance] setParameter:otherParameter];
}


#pragma mark - getter
-(SohuARGameSCNView *)scnView{
    if (_scnView==nil) {
        _scnView=[[SohuARGameSCNView alloc]initWithFrame:self.view.frame];
        _scnView.backgroundColor=[UIColor clearColor];
    }
    return _scnView;
}

-(SohuARGameBaseScene *)scene{
    if (_scene==nil) {
        _scene=[SohuARGameBaseScene scene];
        _scene.delegate=self;
        _scene.superview=self.scnView;
        NSDictionary *dic=[[SohuARSingleton sharedInstance] arConfigurations];
        [_scene setupSceneWith3DModelPathArray:dic[@"InitializationModel"]];
    }
    return _scene;
}

-(UILabel *)hudLabel{
    if (_hudLabel==nil) {
        _hudLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-20, 100, 40)];
        _hudLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _hudLabel.textColor=[UIColor whiteColor];
        _hudLabel.font=[UIFont systemFontOfSize:14.0f];
        _hudLabel.layer.cornerRadius=3;
        _hudLabel.layer.masksToBounds=YES;
        _hudLabel.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:self.hudLabel];
    }
    return _hudLabel;
}

-(SohuCameraView *)cameraView{
    if (_cameraView==nil) {
        _cameraView=[[SohuCameraView alloc]initWithFrame:self.view.frame];
        _cameraView.enableChangeCamera=YES;
        _cameraView.delegate=self;
        [_cameraView openCameraWithCamerType:CamerTypeFront];
        _cameraView.backgroundColor=[UIColor blackColor];
    }
    return _cameraView;
}

-(CMMotionManager *)motionManager{
    if (_motionManager==nil) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.f / 60.f;
    }
    return _motionManager;
}

-(SohuLoadingView *)loadingView{
    if (_loadingView==nil) {
        _loadingView=[[SohuLoadingView alloc]initWithFrame:self.view.frame];
        _loadingView.backgroundColor=[UIColor clearColor];
    }
    return _loadingView;
}

-(void)sohuARGameController:(nullable SohuARGameController *)sohuARGameController webViewParameter:(nullable NSDictionary *)parameter {
    [self.flipboardNavigationController popViewControllerAnimated:NO];
    NSString *imageUrl = [parameter objectForKey:@"gameImageUrl"];
    NSString *webViewUrl = [parameter objectForKey:@"webViewUrl"];
    NSString *clickNumber = [parameter objectForKey:@"clickNumber"];
    NSString *loadUrl =  webViewUrl;
    if (webViewUrl.length == 0) {
        return;
    }
    if (imageUrl.length > 0) {
        if ([loadUrl containsString:@"?"]) {
            loadUrl = [loadUrl stringByAppendingFormat:@"&gameImageUrl=%@", imageUrl];
        }
        else {
            loadUrl = [loadUrl stringByAppendingFormat:@"?gameImageUrl=%@", imageUrl];
        }
        
    }
    if (clickNumber.length > 0) {
        if ([loadUrl containsString:@"?"]) {
            loadUrl = [loadUrl stringByAppendingFormat:@"&clickNumber=%@", clickNumber];
        }
        else {
            loadUrl = [loadUrl stringByAppendingFormat:@"?clickNumber=%@", clickNumber];
        }
    }
    [SNUtility openProtocolUrl:loadUrl context:@{kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType]}];
}

#pragma mark - other
- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)enableAR{
    __block BOOL enable;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]-8.0>0) {
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view addSubview:self.cameraView];
                        self.view.backgroundColor=[UIColor whiteColor];
                        [self downloadArZip];
                    });
                    enable=YES;
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.view.userInteractionEnabled=YES;
                        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@""
                                                                        message:@"请在iPhone的“设置-隐私-相机”选项中，允许搜狐新闻访问你的相机"
                                                                       delegate:self
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil, nil];
                        [self.view addSubview:alerView];
                        [alerView show];
                    });
                    enable=NO;
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:self.cameraView];
                self.view.backgroundColor=[UIColor whiteColor];
                [self downloadArZip];
            });
            enable=YES;
        }
        return enable;
    }else{
        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@""
                                                        message:@"暂不支持当前系统版本"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alerView show];
        self.view.userInteractionEnabled=YES;
        return NO;
    }
}



@end
