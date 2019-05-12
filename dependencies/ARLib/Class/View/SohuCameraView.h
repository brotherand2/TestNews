//
//  SohuCameraView.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,CamerType) {
    CamerTypeFront,
    CamerTypeRear,
};

@class SohuCameraView;

@protocol SohuCameraViewDelegate <NSObject>

-(void)sohuCameraView:(SohuCameraView *)sohuCameraView currentImage:(UIImage *)image;

@end

@interface SohuCameraView : UIView

@property(nonatomic,assign) BOOL enableChangeCamera;
@property(nonatomic,assign) CamerType camerType;
@property(nonatomic,weak) id<SohuCameraViewDelegate> delegate;

-(void)openCameraWithCamerType:(CamerType)camerType;
-(void)captureSessionStartRunning;
-(void)captureSessionStopRunning;
-(UIImage *)currentScreenShotImage;
-(UIImage *)currtenImage;

- (BOOL) isCameraAvailable;

@end
