//
//  SNQRViewController.m
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import "SNQRViewController.h"
#import "SNQRView.h"
#import "SNWebUrlView.h"
#import "SNToolbar.h"
#import "SNLogManager.h"
#import "ZXLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXDecodeHints.h"
#import "ZXMultiFormatReader.h"
#import "ZXResult.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXHybridBinarizer.h"
#import "SNSLib.h"
#import "SNImageProcess.h"
#import "SNAppConfigManager.h"


#import <AudioToolbox/AudioToolbox.h>


//typedef enum : NSUInteger {
//    SNCaptureOutputModePhoto,
//    SNCaptureOutputModeQRCode,
////    SNCaptureOutputModeDefault,
//} SNCaptureOutputMode;

#define kReqCount    (5)
#define kPicFeatureCount    (10)
#define kReqTimeSpace    (1.5)

static SystemSoundID scan_sound_male_id = 0;


@interface SNQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,
                                QRViewDelegate,
                                SNQRUtilityVerifyDelegate,
                                UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate,
                                AVCaptureVideoDataOutputSampleBufferDelegate,
                                UIAlertViewDelegate>
{
    BOOL _is3DTouch;
    BOOL _viewDidLoad;
    BOOL _requestLock;
}

@property (strong, nonatomic) AVCaptureDevice               * device;
@property (strong, nonatomic) AVCaptureDeviceInput          * input;
@property (strong, nonatomic) AVCaptureMetadataOutput       * output;
@property (strong, nonatomic) AVCaptureStillImageOutput     * imageOutput;
@property (strong, nonatomic) AVCaptureVideoDataOutput      * videoDataOutput;
@property (strong, nonatomic) AVCaptureSession              * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    * preview;

@property (nonatomic, retain) UIButton *back;

@property (nonatomic, retain) SNQRView *qrView;

@property (nonatomic, retain) SNToolbar *toolbar;

@property (nonatomic, assign) BOOL lightIsOn;

@property (nonatomic, assign) BOOL networkEnable;

@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, assign) QRViewReferType refer;

@property (nonatomic, retain) UIActivityIndicatorView * actIndicate;

@property (nonatomic, retain) UITapGestureRecognizer * tapGesture;

@property (nonatomic, retain) NSMutableArray * picFeatures;

@property (nonatomic, assign) QRFuncType funcType;

@end

@implementation SNQRViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        if ([[query objectForKey:kIs3DTouchOpen] boolValue]) {
            _is3DTouch = YES;
        } else {
            _is3DTouch = NO;
        }
        if ([query objectForKey:kRefer]) {
            NSNumber * num_refer = [query objectForKey:kRefer];
            switch ([num_refer integerValue]) {
                case 0:
                {
                    self.refer = QRViewRefer_Other;
                    break;
                }
                case 1:
                {
                    self.refer = QRViewRefer_HomePage;
                    break;
                }
                case 2:
                {
                    self.refer = QRViewRefer_LocalChannel;
                    break;
                }
                default:
                    break;
            }
        }
        
        NSString * configTabString = [SNAppConfigManager sharedInstance].cameraTabString;
        if (configTabString.length > 0) {
            if ([configTabString isEqualToString:@"pic"]) {
                self.funcType = QRFuncTypeScanImage;

            }else if([configTabString isEqualToString:@"2d"]){
                self.funcType = QRFuncTypeScanQrCode;

            }else{
                self.funcType = QRFuncTypeScanQrCode;

            }
        }
        
        _requestLock = NO;
        [[SNQRUtility sharedInstanced] setPicReqCount:0];
        
        NSString * scanTab = [query objectForKey:kTab];
        if (!scanTab) {
            scanTab = [query objectForKey:@"siphone://pr/scan://tab"];
        }
        if (scanTab.length > 0) {
            if ([scanTab isEqualToString:@"image"]) {
                self.funcType = QRFuncTypeScanImage;
            }else if([scanTab isEqualToString:@"qr"]){
                self.funcType = QRFuncTypeScanQrCode;
            }
        }
        if (self.funcType == QRFuncTypeScanImage) {
            [SNNewsReport reportADotGif:@"_act=mapread&_tp=openpv"];
        }
        [[SNQRUtility sharedInstanced] setQrviewController:self];
        [[SNQRUtility sharedInstanced] setVerifyDelegate:self];

    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _lastTime = 0;
    [[SNQRUtility sharedInstanced] setIsScanning:YES];
    
    [self checkNetwork];
    [self configUI];
    [self updateLayout];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueScan)];
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
    
    NSMutableDictionary * query = [NSMutableDictionary dictionary];

    [query setObject:[NSNumber numberWithInteger:_refer] forKey:kRefer];
    
    [SNLogManager sendLogWithType:kLogType_qrcode StatType:kLogStatType_open Query:query];//发送埋点数据
    
    [self registeScanSound];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(reachabilityChanged:)
                                  name:kReachabilityChangedNotification
                                object:nil];//监听网络状态
}

-(void)registeScanSound

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scan_success" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&scan_sound_male_id);
    }
}

- (void)checkNetwork{
    NetworkStatus status = [[SNUtility getApplicationDelegate] currentNetworkStatus];
    switch (status) {
        case ReachableViaWiFi:
        case ReachableVia2G:
        case ReachableVia3G:
        case ReachableVia4G:
        case ReachableViaWWAN:
            _networkEnable = YES;
            break;
        case NotReachable:
            _networkEnable = NO;
            break;
        default:
            break;
    }
    [self.qrView setScanEnable:_networkEnable errorType:QRDisableType_NoNetwork];

}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    switch (status) {
        case ReachableViaWiFi:
        case ReachableVia2G:
        case ReachableVia3G:
        case ReachableVia4G:
        case ReachableViaWWAN:
            _networkEnable = YES;
            break;
        case NotReachable:
            _networkEnable = NO;
            break;
        default:
            break;
    }
    if (_funcType == QRFuncTypeScanQrCode) {
        if (_networkEnable) {
            if ([self.session canAddOutput:self.output])
            {
                [self.session addOutput:self.output];
            }
            self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeEAN8Code,
                                            AVMetadataObjectTypeCode128Code,
                                            AVMetadataObjectTypeQRCode];
        }else {
            self.output.metadataObjectTypes = nil;
            [self.session removeOutput:self.output];
        }
        
    }else {
        if (_networkEnable) {
            if ([self.session canAddOutput:self.videoDataOutput]) {
                [self.session addOutput:self.videoDataOutput];
            }
        }else {
            [self.session removeOutput:self.videoDataOutput];
        }
        
    }
    [_qrView setScanEnable:_networkEnable errorType:QRDisableType_NoNetwork];

}


- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    if (!_viewDidLoad) {
        _viewDidLoad = YES;
        [self defaultConfig];
        [self.actIndicate stopAnimating];
    }
    if ([self.actIndicate isAnimating]) {
        [self.actIndicate stopAnimating];
    }
}

- (void)addWebUrlView
{
    SNWebUrlView* webUrlView = [[SNWebUrlView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kWebUrlViewHeight + kSystemBarHeight)];
    [self.view addSubview:webUrlView];
}

- (SNToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0,
                                                               self.view.height - kToolbarHeight,
                                                               self.view.width,
                                                               kToolbarHeight)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}


- (void)defaultConfig {
#if TARGET_IPHONE_SIMULATOR//模拟器
    return;
#elif TARGET_OS_IPHONE//真机
    
#endif
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:kCameraDenyAlertText message:@"" delegate:self cancelButtonTitle:kCameraDenyAlertConfirm otherButtonTitles: nil];
        [alert show];
        return;
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                
            }else{
                [self pop:nil];
            }
        }];
    }

    [SNQRUtility delegate:self];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    if (_funcType == QRFuncTypeScanQrCode) {
        if (!self.output) {
            self.output = [[AVCaptureMetadataOutput alloc]init];
        }
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    }else{
        if (!self.videoDataOutput) {
            self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        }
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
//        dispatch_release(queue);
    
    
        self.videoDataOutput.videoSettings =
        [NSDictionary dictionaryWithObject:
    
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        self.videoDataOutput.minFrameDuration = CMTimeMake(1, 15);

    }
    // Session
    if (!self.session) {
        self.session = [[AVCaptureSession alloc]init];
    }
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if (_funcType == QRFuncTypeScanQrCode) {
        
        if ([self.session canAddOutput:self.output])
        {
            [self.session addOutput:self.output];
        }
        
        AVCaptureConnection *outputConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
        outputConnection.videoOrientation = [SNQRUtility  videoOrientationFromCurrentDeviceOrientation];
        
        // 条码类型 AVMetadataObjectTypeQRCode
        //    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        if (_networkEnable) {
            self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeEAN8Code,
                                            AVMetadataObjectTypeCode128Code,
                                            AVMetadataObjectTypeQRCode];
        }

    }else {
        
        if ([self.session canAddOutput:self.videoDataOutput] && _networkEnable) {
            [self.session addOutput:self.videoDataOutput];
        }
    }
    
    // Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity =AVLayerVideoGravityResize;
    self.preview.frame =[SNQRUtility screenBounds];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    self.preview.connection.videoOrientation = [SNQRUtility videoOrientationFromCurrentDeviceOrientation];
    
    [self.session startRunning];
    
}

#pragma mark - AlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self pop:nil];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    
    [self stopScan];

}

- (BOOL)is6Plus{
    if ([UIScreen mainScreen].bounds.size.width > 750/2.f) {
        return YES;
    }else{
        return NO;
    }
}

- (void)configUI {
    
    [self.view addSubview:self.qrView];
    self.actIndicate = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.actIndicate.frame = CGRectMake((self.view.frame.size.width - 100)/2.f, (self.view.frame.size.height - 100)/2.f, 100, 100);
    self.actIndicate.top = (self.view.size.height )/2.f - kToolbarHeight - self.actIndicate.size.height/2.f;
    [self.view addSubview:self.actIndicate];
    [self.actIndicate startAnimating];

    //add toolbar
    self.back = [[UIButton alloc] init];
    [_back setImage:[UIImage imageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_back setImage:[UIImage imageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [_back setBackgroundColor:[UIColor clearColor]];
    [_back addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_back, nil] withType:SNToolbarAlignRight];
    
    _back.enabled = YES;

}

- (void)updateLayout {
    
    
    
    _qrView.center = CGPointMake([SNQRUtility screenBounds].size.width / 2, [SNQRUtility screenBounds].size.height / 2);
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - self.qrView.transparentArea.width) / 2,
                                 (screenHeight - self.qrView.transparentArea.height) / 2,
                                 self.qrView.transparentArea.width,
                                 self.qrView.transparentArea.height);
    [self.output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
}

- (void)pop:(UIButton *)button {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closePhotoLamp:nil];
        if (_is3DTouch) {
            UIViewController* topController = [TTNavigator navigator].topViewController;
            [SNUtility popToTabViewController:topController];
            //tab切换到新闻
            [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
            //栏目切换到焦点
            [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];

        } else {
            [[SNQRUtility sharedInstanced] setIsScanning:NO];
            [self.flipboardNavigationController popViewControllerAnimated:YES];
        }
    });
}

- (void)sendLog{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    dictionary[@"imgs"] = [SNQRUtility getDotOpenAlbum];
    dictionary[@"readfails"] = [SNQRUtility getDotImgReadFail];
    dictionary[@"flashstatus"] = [SNQRUtility getDotOpenLight];
    dictionary[@"noselect"] = [SNQRUtility getDotNoSelectedImg];
    
    [SNLogManager sendLogWithType:kLogType_qrcode StatType:kLogStatType_kp Query:dictionary];
}

#pragma mark QRViewDelegate
-(void)scanTypeConfig:(SNQRItem *)item {
        
    switch (item.type) {
        
        /**
         *  调起系统相册
         */
        case QRItemType_Album:
        {
            [self openAlubm];
            
            if (_funcType == QRFuncTypeScanImage) {
                [SNNewsReport reportADotGif:@"_act=mapread&_tp=clkalbum"];
            }else if(_funcType == QRFuncTypeScanQrCode){
            
                [SNQRUtility dotOpenAlbum];//埋点
            }
        }
            break;
            
        /**
         *  打开闪光灯
         */
        case QRItemType_Lamp:
        {
            [SNQRUtility dotOpenLight:_lightIsOn];//埋点
            if (!_lightIsOn || self.device.torchMode != AVCaptureTorchModeOn) {
                [self openPhotoLamp:item];
            }else {
                [self closePhotoLamp:item];
            }
            
        }
            break;
            
        default:
            break;
    }
}

- (void)switchScanFunctionMode:(QRFuncType)scanType {
#if TARGET_IPHONE_SIMULATOR//模拟器
    return;
#endif
    
    self.funcType = scanType;
    [[SNQRUtility sharedInstanced] setPicReqCount:0]; //计数归零

    if (_funcType == QRFuncTypeScanQrCode) {
        if (!self.output) {
            self.output = [[AVCaptureMetadataOutput alloc]init];
        }
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    }else if (_funcType == QRFuncTypeScanImage){
        if (!self.videoDataOutput) {
            self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        }
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
//        dispatch_release(queue);
        
        
        self.videoDataOutput.videoSettings =
        [NSDictionary dictionaryWithObject:
         
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        self.videoDataOutput.minFrameDuration = CMTimeMake(1, 15);
        
    }
    if (_funcType == QRFuncTypeScanQrCode) {
        
        if ([self.session canAddOutput:self.output])
        {
            [self.session addOutput:self.output];
        }
        
        AVCaptureConnection *outputConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
        outputConnection.videoOrientation = [SNQRUtility  videoOrientationFromCurrentDeviceOrientation];
        
        // 条码类型 AVMetadataObjectTypeQRCode
        //    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        if (_networkEnable) {
            self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                            AVMetadataObjectTypeEAN8Code,
                                            AVMetadataObjectTypeCode128Code,
                                            AVMetadataObjectTypeQRCode];
        }
        
    }else  if (_funcType == QRFuncTypeScanImage){
        
        if ([self.session canAddOutput:self.videoDataOutput] && _networkEnable) {
            [self.session addOutput:self.videoDataOutput];
        }
        
        [SNNewsReport reportADotGif:@"_act=mapread&_tp=clk"];
        [SNNewsReport reportADotGif:@"_act=mapread&_tp=openpv"];
    }

}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue = nil;
    BOOL ret = NO;

    switch (self.funcType) {
        case QRFuncTypeScanQrCode:
        {
            if ([metadataObjects count] > 0)
            {
                //停止扫描
                [self.session stopRunning];
                AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
                stringValue = metadataObject.stringValue;
                ret = YES;
            }
            AudioServicesPlaySystemSound(scan_sound_male_id);
            [self analyzingQRCodeFinished:ret content:stringValue];

            break;
        }
        case QRFuncTypeScanImage:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        if (_funcType == QRFuncTypeScanImage) {
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            
            ///控制取图时间间隔
            if (now - _lastTime > kReqTimeSpace) {
                _lastTime = [[NSDate date] timeIntervalSince1970];
                UIImage * image = [self imageFromSampleBuffer:sampleBuffer];
                
                ///切
                image = [SNImageProcess cutCenterImage:image size:CGSizeMake(200, 200)];
                
                ///缩
                image = [SNImageProcess compressImage:image toTargetWidth:200];
                
                ///压
                NSData * iamgeData =  UIImageJPEGRepresentation(image, 0.2);
                
                ///base64
                NSString * imageBase64tr = [iamgeData base64Encoding];
                
                ///云端验证
                [SNQRUtility verifyOnServerWithImageBase64String:imageBase64tr fromAlbum:NO];
                
                ///存相册
//                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }

        }
    }
  
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
}

#pragma mark - Getter and Setter

-(SNQRView *)qrView {
    
    if (!_qrView) {
        
        CGRect screenRect = [SNQRUtility screenBounds];
        _qrView = [[SNQRView alloc] initWithFrame:screenRect scanType:_funcType];
        [_qrView setTransparentAreaWithFuncType:self.funcType];
        _qrView.backgroundColor = [UIColor clearColor];
        _qrView.delegate = self;
    }
    return _qrView;
}

#pragma mark - UIImagePickerDelegate
-(void)openAlubm
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
        
        if (_funcType == QRFuncTypeScanQrCode) {
            
        }
        else if(_funcType == QRFuncTypeScanImage){
            [[SNQRUtility sharedInstanced] setPicReqCount:0]; //计数归零
        }
        
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
//        picker.allowsEditing = YES;//是否可以编辑
        picker.navigationBarHidden = YES;
        //打开相册选择照片
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{}];
    
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的设备没有摄像头" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alert show];
    }
}
//选中图片进入的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    if (self.funcType == QRFuncTypeScanImage) {
        [self.actIndicate startAnimating];//给个小菊花
        [_qrView setScanEnable:NO errorType:QRDisableType_Unknown];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
        switch (self.funcType) {
            case QRFuncTypeScanQrCode:
            {
                [self analyzingWithImage:image];
                break;
            }
            case QRFuncTypeScanImage:
            {
                
                UIImage * mimage = [SNImageProcess cutCenterImage:image size:CGSizeMake(200, 200)];
                mimage = [SNImageProcess compressImage:mimage toTargetWidth:200];
                NSData *  iamgeData =  UIImageJPEGRepresentation(mimage, 0.2);
                NSString * imageBase64tr = [iamgeData base64Encoding];
                
                [SNQRUtility verifyOnServerWithImageBase64String:imageBase64tr fromAlbum:YES];
                if (!self.session.running) {
                    [self.session startRunning];
                }
                break;
            }
            default:
                break;
        }
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:^{
 
        [self continueScan];
        switch (self.funcType) {
            case QRFuncTypeScanQrCode:
            {
                [SNQRUtility dotNoSelectedImg];//埋点
                break;
            }
            case QRFuncTypeScanImage:
            {
                break;
            }
            default:
                break;
        }
    }];
}

- (void)didReceiveRemote:(QRHandlePushFinish)finishBlock {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            finishBlock();
        }];
    }else{
        finishBlock();
    }
    if (!self.session.running) {
        [self.session startRunning];
    }

}

- (void)didEnterBackground {
    [self closePhotoLamp:_qrView.ligthButton];
}

/**
 *  打开闪光灯
 */
- (void)openPhotoLamp:(SNQRItem *)item {
#if TARGET_IPHONE_SIMULATOR//模拟器
    return;
#elif TARGET_OS_IPHONE//真机
    
#endif

    if (self.device.torchMode == AVCaptureTorchModeOff) {
        
        [self.session beginConfiguration];
        [self.device lockForConfiguration:nil];
        // Set torch to on
        [self.device setTorchMode:AVCaptureTorchModeOn];
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];
        // Start the session
        [self.session startRunning];
        _lightIsOn = YES;
        item.didSelected = YES;
    }
}

/**
 *  关闭闪光灯
 */
- (void)closePhotoLamp:(SNQRItem *)item {
#if TARGET_IPHONE_SIMULATOR//模拟器
    return;
#elif TARGET_OS_IPHONE//真机
    
#endif

    if (self.device.torchMode == AVCaptureTorchModeOn) {
        
        [self.session beginConfiguration];
        [self.device lockForConfiguration:nil];
        // Set torch to on
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device unlockForConfiguration];
        [self.session commitConfiguration];
        // Start the session
        [self.session startRunning];
        _lightIsOn = NO;
        item.didSelected = NO;
    }
}

/**
 *  解析从相册选择的二维码
 */
-(void)analyzingWithImage:(UIImage *)img{

    UIImage *loadImage= img;
    CGImageRef imageToDecode = loadImage.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    // The coded result as a string. The raw data can be accessed with
    // result.rawBytes and result.length.
    NSString *contents = result.text;
    [self analyzingQRCodeFinished:result content:contents];
    
}

/**
 *  统一解析结果处理
 */
- (void)analyzingQRCodeFinished:(BOOL)result content:(NSString *)content {
    [self closePhotoLamp:nil];
    if (result) {
        [self.session stopRunning];
        [SNQRUtility verifyOnServerWith:content];        
    
    }else {
        [SNQRUtility dotImgReadFail]; // 埋点
        [self showErrorView];
    }
    
}

/**
 *  未识别到二维码浮层
 */
- (void)showErrorView{
    if (!_qrView.enable) {
        [_qrView setScanEnable:YES errorType:QRDisableType_NoResult];
    }
    self.tapGesture.enabled = YES;
    self.output.metadataObjectTypes = nil;
    [self.session removeOutput:self.videoDataOutput];
    [self stopScan];
    [_qrView setScanEnable:NO errorType:QRDisableType_NoResult];
    
}

- (void)continueScan{
    if ([self.session isRunning]) {
        return;
    }
    [[self.preview connection] setEnabled:YES];
    self.tapGesture.enabled = NO;
    [self switchScanFunctionMode:_funcType];
    [_qrView setScanEnable:YES errorType:QRDisableType_NoResult];
    if (!self.session.running) {
        [self.session startRunning];
    }
}

- (void)stopScan{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self closePhotoLamp:nil];
        [[self.preview connection] setEnabled:NO];
        self.output.metadataObjectTypes = nil;
        [self.session removeOutput:self.videoDataOutput];
        [self.session removeOutput:self.output];
        [self.session stopRunning];
    });
 }

/**
 *  处理服务端返回结果
 */
- (void)verifyFinishedWithUrl:(NSString *)url message:(NSString *)msg successed:(BOOL)success {

    if (success) {
        
        if (_funcType == QRFuncTypeScanImage) {
            
            if (_requestLock) {
                return;
            }
            //url拼接夜间模式
            [self stopScan];
            [[SNQRUtility sharedInstanced] setIsScanning:NO];
            url = [self appendThemeModeWithUrl:url];
            //系统 嘀的一声id 1057
            AudioServicesPlaySystemSound(scan_sound_male_id);
            [self.flipboardNavigationController popViewControllerAnimated:NO];
            [SNUtility openProtocolUrl:url context:@{kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType]}];
            _requestLock = YES;
            
        }else if(_funcType == QRFuncTypeScanQrCode) {
            
            //url拼接夜间模式
            [self stopScan];
            [[SNQRUtility sharedInstanced] setIsScanning:NO];
            url = [self appendThemeModeWithUrl:url];
            //系统 嘀的一声id 1057
            AudioServicesPlaySystemSound(scan_sound_male_id);
            [self.flipboardNavigationController popViewControllerAnimated:NO];
            [SNUtility openProtocolUrl:url context:@{kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType]}];
        }
        
    }else {
        if (_funcType == QRFuncTypeScanImage) {
            if (_requestLock) {
                return;
            }
            if (url.length > 0 && ([[SNQRUtility sharedInstanced] picReqCount] == kReqCount || [msg isEqualToString:@"isFromAlbum"])) {
                [[SNQRUtility sharedInstanced] setPicReqCount:0]; //计数归零
                //url拼接夜间模式
                [self stopScan];
                [[SNQRUtility sharedInstanced] setIsScanning:NO];
                 [self.flipboardNavigationController popViewControllerAnimated:NO];
                url = [self appendThemeModeWithUrl:url];
                [SNUtility openProtocolUrl:url];
                _requestLock = YES;

            }else{
               //请求失败了
                if ([[SNQRUtility sharedInstanced] picReqCount] == kReqCount || [msg isEqualToString:@"isFromAlbum"]) {
                    [self showErrorView];
                    [[SNQRUtility sharedInstanced] setPicReqCount:0]; //计数归零
                }
            }
        }else if (_funcType == QRFuncTypeScanQrCode){
            [SNQRUtility dotImgReadFail]; // 埋点
            if (![self.session isRunning]) {
                [self.session startRunning];
            }
        }
    }
    if ([self.actIndicate isAnimating]) {
        [self.actIndicate stopAnimating];
    }
}

- (NSString *)appendThemeModeWithUrl:(NSString *)url {
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (!isNightTheme) {
        return url;
    }
    if ([url containsString:SNLinks_Domain_3gK]) {
        if ([url containsString:@"?"]) {
            return [url stringByAppendingString:@"&mode=1"];
        }else{
            return [url stringByAppendingString:@"?mode=1"];
        }
    }
    return url;
 }

#pragma mark - image tools

/**
 *  将屏幕捕捉到的画面转成image
 */
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
//    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

/// 拍照 【目前没有用到该功能】
- (void)takePhoto:(UIButton *)button {
    
        AVCaptureConnection *stillImageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoOrientation avcaptureOrientation = [SNQRUtility videoOrientationFromCurrentDeviceOrientation];
        [stillImageConnection setVideoOrientation:avcaptureOrientation];
        [stillImageConnection setVideoScaleAndCropFactor:1];
        
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        }];
}

@end
