//
//  SNNewsScreenShareViewController.h
//  sohunews
//
//  Created by wang shun on 2017/7/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"

@protocol SNNewsScreenShareVCDelegate;
@interface SNNewsScreenShareViewController : SNBaseViewController

@property (nonatomic,weak) id <SNNewsScreenShareVCDelegate> delgate;

- (instancetype)initWithClipImage:(UIImage*)image BaseImage:(UIImage*)baseImg WithData:(NSDictionary*)data;

- (instancetype)initWithClipImage:(UIImage*)image WithBrushImage:(UIImage*)brush BaseImage:(UIImage*)baseImg WithData:(NSDictionary*)data;

- (void)closeSelf;

@end

@protocol SNNewsScreenShareVCDelegate <NSObject>

- (UIImage*)getClipImage:(UIImage*)img;

- (void)removedSelf;

@end
