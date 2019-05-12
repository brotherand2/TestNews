//
//  SNNovelShelfController.h
//  sohunews
//
//  Created by qz on 15/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNRollingNews.h"

@class SNStoryPageViewController;

@interface SNNovelShelfController : SNThemeViewController

@property(nonatomic,strong)SNRollingNews *dataItem;
@property(nonatomic,strong)UIView *footerView;
@property(nonatomic,assign)BOOL controllerCanPop;
@property(nonatomic,assign)BOOL bookAnimating;
@property(nonatomic,strong)NSMutableArray *selectedBooks;

@property(nonatomic,weak)SNStoryPageViewController *pageViewController;//控制书架动画frame

-(void)refreshSelectState;
@end
