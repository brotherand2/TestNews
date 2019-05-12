//
//  SNToastView.h
//  sohunews
//
//  Created by jialei on 14-10-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSNToastHeight          (116 / 2)
#define kSNToastShowInterval    3.0
#define kSNToastMutiShowInterval    1.0

typedef void(^SNToastViewHideFinished)(id view);
typedef void(^SNToastViewUrlButtonClicked)(void);
@interface SNToastView : UIView

@property (nonatomic, assign)float startInterval;
@property (nonatomic, assign)float endInterval;
@property (nonatomic, assign)BOOL useAnimation;
@property (nonatomic, strong)NSDate *startData;

@property (nonatomic, strong)NSString *iconImageName;
@property (nonatomic, strong)NSString *toastText;
@property (nonatomic, strong)NSString *toastUrl;
@property (nonatomic, strong)NSDictionary *userInfo;

@property (nonatomic, copy)SNToastViewHideFinished finishedBlock;
@property (nonatomic, copy)SNToastViewUrlButtonClicked urlButtonClickedblock;
@property (nonatomic, assign)BOOL toProfile;//是否跳转到profile页面

//+ (SNToastView *)showToastAddedTo:(UIView *)view animated:(BOOL)animated;
- (id)initWithFrame:(CGRect)frame;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (void)setUpToastActionButtonWithTitle:(NSString *)title;

@end
