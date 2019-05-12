//
//  SNLoadingImageAnimationView.h
//  sohunews
//
//  Created by Scarlett on 16/9/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kImageAnimationStatus @"kImageAnimationStatus"

@interface SNLoadingImageAnimationView : UIView

typedef NS_ENUM(NSInteger, SNImageLoadingStatus) {
    SNImageLoadingStatusStopped,
    SNImageLoadingStatusLoading,
};

@property (nonatomic, assign) SNImageLoadingStatus status;
@property (nonatomic, strong) UIView *targetView;

@end
