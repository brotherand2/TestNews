//
//  SNStoryBaseViewController.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNStoryBottomToolbar;
@class SNStoryHeadSelectView;

@interface SNStoryBaseViewController : UIViewController


@property(nonatomic, strong) UIView                *headerView;
@property(nonatomic, strong) SNStoryBottomToolbar    *toolbarView;

-(void)addHeaderView;
-(void)storyPopViewController:(UIButton *)btn;
-(void)addBottomBar;
-(void)resetToolBarOrigin;
- (void)updateTheme;
@end
