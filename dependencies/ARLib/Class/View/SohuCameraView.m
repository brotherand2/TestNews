//
//  SohuCameraView.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SohuScreenShotTool.h"

@interface SohuCameraView ()

@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) UIButton *changeCameraButton;

@end

@implementation SohuCameraView

#pragma mark - life cycle
-(instancetype)init{
    self=[super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.backgroundColor=[UIColor blackColor];
    }
    return self;
}

#pragma mark - publick method
-(void)openCameraWithCamerType:(CamerType)camerType{
    
    if(![self isCameraAvailable]){
//        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"" message:@"请在iPhone的“设置-隐私-相机”选项中，允许搜狐新闻访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [self addSubview:alerView];
//        [alerView show];
        return;
    }
    _camerType=camerType;
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    [self.layer addSublayer:self.previewLayer];
    [self captureSessionStartRunning];
}

-(void)captureSessionStartRunning{
    [self.session startRunning];
}

-(void)captureSessionStopRunning{
     [self.session stopRunning];
}

-(UIImage *)currentScreenShotImage{
    return [SohuScreenShotTool screenShotForView:nil];
}

#pragma mark - getter
-(AVCaptureSession *)session{
    if (_session==nil) {
        _session=[[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}

-(AVCaptureDevice *)device{
    if (_device==nil) {
        _device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [_device lockForConfiguration:nil];
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        [_device unlockForConfiguration];
    }
    return _device;
}

-(AVCaptureDeviceInput *)videoInput{
    if (_videoInput==nil) {
        _videoInput=[[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _videoInput;
}

-(AVCaptureStillImageOutput *)stillImageOutput{
    if (_stillImageOutput==nil) {
        _stillImageOutput= [[AVCaptureStillImageOutput alloc] init];
        ;
        [_stillImageOutput setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil]];
    }
    return _stillImageOutput;
}

-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer==nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.bounds;
        _previewLayer.contentsScale = [UIScreen mainScreen].scale;
        _previewLayer.backgroundColor = [[UIColor blackColor]CGColor];
    }
    return _previewLayer;
}

-(UIButton *)changeCameraButton{
    if (_changeCameraButton==nil) {
        _changeCameraButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _changeCameraButton.tag = 0;
        [_changeCameraButton setImage:[UIImage imageNamed:@"btn_camera_all"] forState:UIControlStateNormal];
        [_changeCameraButton addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeCameraButton;
}

#pragma mark  - setter

-(void)setEnableChangeCamera:(BOOL)enableChangeCamera{
    if (enableChangeCamera) {
    }
}

#pragma mark - some Action
-(void)buttonDidClick:(UIButton *)button{
    [self currentScreenShotImage];
}

- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;

        AVCaptureDevicePosition position = [[self.videoInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.videoInput = newInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

-(void)turnOnLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOn];
        [device unlockForConfiguration];
    }
}

-(void)turnOffLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
    }
}


#pragma mark - other
- (BOOL) isCameraAvailable{
    
        
    
    
    
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (UIImage *)currtenImage
{
    AVCaptureConnection *conntion = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        return nil;
    }
    __block UIImage *image=nil;
    __weak SohuCameraView *weakSelf=self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        image = [UIImage imageWithData:imageData];
        if ([weakSelf.delegate respondsToSelector:@selector(sohuCameraView:currentImage:)]) {
            [weakSelf.delegate sohuCameraView:weakSelf currentImage:image];
        }
    }];
    return nil;
}

@end
