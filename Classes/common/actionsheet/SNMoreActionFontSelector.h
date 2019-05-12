//
//  SNMoreActionFontSelector.h
//  sohunews
//
//  Created by weibin cheng on 14-10-21.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSNMoreActionFontSelctorWidth 162

@interface SNMoreActionFontSelector : UIView
{
    UIButton* _largeButton;
    UIButton* _normalButton;
    UIButton* _smallButton;
}

- (void)updateTheme;

@end
