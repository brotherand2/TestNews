//
//  SNNewsShareManager.h
//  sohunews
//
//  Created by wang shun on 2017/1/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNShareConfigs.h"
#import "SNNewsShareParamsHeader.h"
#import "SNNewsShareHeader.h"
#import "SNShareMenuViewController.h"

@protocol SNNewsShareManagerDelegate;

typedef void(^SNShareVideoToLogin)(id objc);
//typedef void (^ShareCompletionBlock)(NSDictionary* dic);

@interface SNNewsShareManager : NSObject<SNShareMenuControllerDelegate>

@property (nonatomic, strong) SNShareMenuViewController *menuVc;
@property (nonatomic, weak) id <SNNewsShareManagerDelegate> delegate;

@property (nonatomic, strong) SNShareOn *shareOn;
@property (nonatomic, strong) SNShareUpload *upload;
@property (nonatomic, strong) SNSharePlatformBase* sharePlatForm;
@property (nonatomic, copy)   SNShareVideoToLogin shareToLogin;

//唤起分享
+ (SNNewsShareManager*)loadShareData:(NSDictionary*)dic Delegate:(id)obj;

//用于splashViewController
+ (SNNewsShareManager*)loadShareData:(NSDictionary*)dic FromView:(UIView *)fromView Delegate:(id)obj;

//点击icon
- (void)shareIconSelected:(NSString*)iconTitle ShareData:(NSDictionary *)shareData;

@end

@protocol SNNewsShareManagerDelegate <NSObject>

@optional
- (void)actionMenuControllerShareSuccess:(NSString *)message;
- (void)actionMenuControllerShareFailed:(NSString *)message;

- (void)actionmenuDidSelectLikeBtn;
- (void)actionmenuDidSelectDownloadBtn;
- (void)actionmenuWillSelectItemType:(SNActionMenuOption)type;


- (void)actionmenuDidSelectItemTypeCallback:(SNActionMenuOption)type;

- (void)shareOnFinished:(SNSharePlatformBase*)platform;

@end
