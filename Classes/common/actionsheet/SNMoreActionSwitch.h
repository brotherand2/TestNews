//
//  SNMoreActionSwitch.h
//  sohunews
//
//  Created by weibin cheng on 14-10-21.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNMoreActionSwitch;
@protocol SNMoreActionSwitchDelegate <NSObject>

- (void)moreActionSwitch:(SNMoreActionSwitch*)ationSwitch didChanged:(BOOL)open;

@end

@interface SNMoreActionSwitch : UIView
{
    UIButton* _button;
    UIImageView* _line;
    UIImageView* _indicator;
    UIView* _animateView;
}
@property (nonatomic, assign) BOOL  open;
@property (nonatomic, weak) id<SNMoreActionSwitchDelegate> delegate;

- (void)updateTheme;

@end
