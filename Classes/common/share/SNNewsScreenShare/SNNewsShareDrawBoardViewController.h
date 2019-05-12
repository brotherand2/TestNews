//
//  SNNewsShareDrawBoardViewController.h
//  sohunews
//
//  Created by wang shun on 2017/7/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"
@protocol SNNewsShareDrawBoardVCDelegate;
@interface SNNewsShareDrawBoardViewController : SNBaseViewController

@property (nonatomic,weak) id <SNNewsShareDrawBoardVCDelegate> delegate;

- (instancetype)initWithEditorImage:(UIImage*)image;

- (void)reEnterSelf;//再次进入 孟刘洋需求

- (void)clean;

@end

@protocol SNNewsShareDrawBoardVCDelegate <NSObject>

- (UIImage*)getClipImage:(UIImage*)img;

- (void)pushPreViewController:(id)sender;//push预览页面

- (void)removedSelf;

@end
