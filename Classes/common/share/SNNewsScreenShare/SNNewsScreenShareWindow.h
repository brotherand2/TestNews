//
//  SNNesScreenShareWindow.h
//  sohunews
//
//  Created by wang shun on 2017/7/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsScreenShareWindowDelegate;
@interface SNNewsScreenShareWindow : UIView

@property (nonatomic,weak) id <SNNewsScreenShareWindowDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithImage:(UIImage*)img;

- (void)show;

- (void)showOnlyShare;

- (void)closeWindow;

@end

@protocol SNNewsScreenShareWindowDelegate  <NSObject>

- (void)sharePress:(UIButton*)b;
- (void)fbPress:(UIButton*)b;

@end
