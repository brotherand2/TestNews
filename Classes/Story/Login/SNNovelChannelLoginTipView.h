//
//  SNNovelChannelLoginTipView.h
//  sohunews
//
//  Created by H on 2016/11/24.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNovelChannelLoginTipViewDelegate <NSObject>

- (void)novelLoginTipDidClickClose;

- (void)novelLoginTipDidClickLogin;

@end

@interface SNNovelChannelLoginTipView : UIView

@property (nonatomic, weak) id <SNNovelChannelLoginTipViewDelegate> delegate;

- (void)updateTheme;

- (void)hideCloseButton;
@end
