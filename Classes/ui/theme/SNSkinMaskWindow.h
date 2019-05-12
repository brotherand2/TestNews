//
//  SNSkinMaskView.h
//  sohunews
//
//  Created by Gao Yongyue on 14-4-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSkinMaskWindow : UIWindow

+ (instancetype)sharedInstance;
- (void)show;
- (void)hide;
- (void)resignAppActive;
- (void)becameAppActive;
- (void)updateStatusBarAppearanceWithLightContentMode:(BOOL)lightContentMode;
- (void)hideStatusbar;
- (void)showStatusbar;
@end
