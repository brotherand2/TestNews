//
//  SNStoryBaseViewController.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryBaseViewController.h"
#import "SNStoryBottomToolbar.h"
#import "SNStoryContanst.h"
#import "UIImage+Story.h"
#import "SNStoryUtility.h"

#define HeaderViewLeftOffset                     0.0//头部view的左边距
#define HeaderLineViewLeftOffset                 0.0//头部分割线的左边距
#define HeaderLineViewHeight                     0.5//头部分割线的高
#define StoryBottomToolbarLeftOffset             0.0//底部view的左边距
#define StoryBottomToolbar_LeftBtnLeftOffset     0.0//底部导航栏左按钮的左边距
#define StoryBottomToolbar_LeftBtnTopOffset      0.0//底部导航栏左按钮的上边距
#define StoryBottomToolbar_LeftBtnHeight         43.0//底部导航栏左按钮高度
#define StoryBottomToolbar_LeftBtnWidth          43.0//底部导航栏左按钮宽度

@interface SNStoryBaseViewController ()

@end

@implementation SNStoryBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    [self addBottomBar];
    [self addHeaderView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
}

- (void)addHeaderView
{
    if (!self.headerView)
    {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(HeaderViewLeftOffset, StoryBarHeight, View_Width, StoryHeaderHeight)];
        self.headerView.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
        [self.view addSubview:self.headerView];
        
        UIView *headerLineView = [[UIView alloc]initWithFrame:CGRectMake(HeaderLineViewLeftOffset, StoryHeaderHeight - HeaderLineViewHeight, View_Width, HeaderLineViewHeight)];
        headerLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
        headerLineView.tag = 5111;
        [self.headerView addSubview:headerLineView];
    }
}

-(void)addBottomBar
{
    SNStoryBottomToolbar *bottomBar = [[SNStoryBottomToolbar alloc] initWithFrame:CGRectMake(StoryBottomToolbarLeftOffset, View_Height - BottomBarHeight, View_Width, BottomBarHeight)];
    [self.view addSubview:bottomBar];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(StoryBottomToolbar_LeftBtnTopOffset, StoryBottomToolbar_LeftBtnTopOffset, StoryBottomToolbar_LeftBtnWidth, StoryBottomToolbar_LeftBtnHeight)];
    [leftButton setImage:[UIImage imageStoryNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageStoryNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(storyPopViewController:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    
    [bottomBar addSubview:leftButton];
    
}

- (void)resetToolBarOrigin {
    [UIView animateWithDuration:0.5 animations:^{
        self.toolbarView.frame = CGRectMake(0, View_Height - BottomBarHeight, View_Width, BottomBarHeight);
    }];
}

-(void)storyPopViewController:(UIButton *)btn
{
    [SNStoryUtility popViewControllerAnimated:YES];
}

- (void)updateTheme {
    self.headerView.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
    UIView *headerLineView = [self.headerView viewWithTag:5111];
    headerLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
