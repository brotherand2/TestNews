//
//  UISwitchCityButton.h
//  sohunews
//
//  Created by wangyy on 15/5/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSwitchCityWidth (100)

@interface UISwitchCityButton : UIButton{
    UILabel *titleLabel;
    UIImageView *backGroundImageView;
    UIImageView *iconImageView;
}

- (void)updateTheme;

@end
