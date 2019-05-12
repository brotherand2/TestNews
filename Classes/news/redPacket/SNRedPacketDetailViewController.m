//
//  SNRedPacketDetailViewController.m
//  sohunews
//
//  Created by wangyy on 16/2/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedPacketDetailViewController.h"

@interface SNRedPacketDetailViewController ()

@property (nonatomic, strong) SNToolbar *iToolbarView;

@end

@implementation SNRedPacketDetailViewController

@synthesize iToolbarView = _iToolbarView;

- (void)dealloc{
     //(_iToolbarView);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addToolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addToolbar
{
    self.iToolbarView =  [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [self.iToolbarView setLeftButton:leftButton];
    [self.view addSubview:self.iToolbarView];
}

- (void)onBack{
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

@end
