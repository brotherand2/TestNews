//
//  SNNewsLoginKeyBoard.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNNewsLoginKeyBoardDelegate;
@interface SNNewsLoginKeyBoard : NSObject

@property (nonatomic,weak) id <SNNewsLoginKeyBoardDelegate> delegate;

@property (nonatomic,weak) SNToolbar* toolbarView;
@property (nonatomic,weak) UIView* half_view;

- (instancetype)initWithToolbar:(SNToolbar*)toolbar;
- (instancetype)initWithHalfLoginView:(UIView*)view;

- (void)createkeyboardNotification;
- (void)removeKeyBoardNotification;

@end

@protocol SNNewsLoginKeyBoardDelegate <NSObject>

- (void)keyBoardHeight:(CGSize)size;

@end
