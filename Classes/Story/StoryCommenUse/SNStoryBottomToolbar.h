//
//  SNStoryBottomToolbar.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    StoryToolbarAlignCenter,
    StoryToolbarAlignRight
}StoryToolbarAlignType;


@interface SNStoryBottomToolbar : UIView
@property(nonatomic, retain)UIButton *leftButton;
@property(nonatomic, retain)UIButton *rightButton;
- (void)updateTheme;

@end
