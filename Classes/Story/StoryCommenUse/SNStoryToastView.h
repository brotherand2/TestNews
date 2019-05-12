//
//  SNStoryToastView.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kStoryToastHeight          (116 / 2)
#define kStoryToastShowInterval    3.0
#define kStoryToastMutiShowInterval    1.0

typedef void(^StoryToastViewHideFinished)(id view);
typedef void(^StoryToastViewUrlButtonClicked)(void);
@interface SNStoryToastView : UIView

@property (nonatomic, assign)float startInterval;
@property (nonatomic, assign)float endInterval;
@property (nonatomic, assign)BOOL useAnimation;
@property (nonatomic, strong)NSDate *startData;

@property (nonatomic, strong)NSString *toastText;
@property (nonatomic, strong)NSString *toastUrl;
@property (nonatomic, strong)NSDictionary *userInfo;

@property (nonatomic, copy)StoryToastViewHideFinished finishedBlock;
@property (nonatomic, copy)StoryToastViewUrlButtonClicked urlButtonClickedblock;
@property (nonatomic, assign)BOOL toProfile;//是否跳转到profile页面

- (id)initWithFrame:(CGRect)frame;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
