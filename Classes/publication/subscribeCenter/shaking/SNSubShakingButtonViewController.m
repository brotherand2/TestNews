//
//  SNSubShakingButtonViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingButtonViewController.h"
#import "SNSubShakingCenterViewController.h"

@interface SNSubShakingButtonViewController()
-(void)customerBg;
-(void)submitHangout:(id)sender;
-(void)submitSubnow:(id)sender;
-(void)viewTaped:(id)sender;
@end

@implementation SNSubShakingButtonViewController
@synthesize _subViewController;


//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    UIColor* protocolLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingPushLabelColor]];
    UIColor* buttonTitleColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingButtonTitleColor]];
    
    //check box
    CGRect subRect = CGRectMake(94, 17, 24, 24);
    UIImage* itemImage = [UIImage imageNamed:@"userinfo_check.png"];
    UIImage* itemImagehl = [UIImage imageNamed:@"userinfo_check_hl.png"];
    UIButton* checkboxView = [[UIButton alloc] initWithFrame:subRect];
    checkboxView.tag = 101;
    checkboxView.selected = NO;
    [checkboxView setBackgroundImage:itemImage forState:UIControlStateNormal];
    [checkboxView setBackgroundImage:itemImagehl forState:UIControlStateSelected];
    [self.view addSubview:checkboxView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [checkboxView addGestureRecognizer:tap];
    
    //push
    subRect = CGRectMake(117, 20, 120, 18);
    UILabel* push = [[UILabel alloc] initWithFrame:subRect];
    push.tag = 104;
    push.font = [UIFont systemFontOfSize:13];
    push.textColor = protocolLabelColor;
    push.backgroundColor = [UIColor clearColor];
    push.userInteractionEnabled = YES;
    push.text = NSLocalizedString(@"shaking_push_tip", nil);
    [self.view addSubview:push];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    [push addGestureRecognizer:tap];
    
    //逛一逛
    UIButton* hangoutButton = [[UIButton alloc] initWithFrame:CGRectMake(32, 51, 120, 43)];
    hangoutButton.tag = 102;
    [hangoutButton setTitleColor:buttonTitleColor forState:UIControlStateNormal];
    [hangoutButton setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
    [hangoutButton setTitle:NSLocalizedString(@"shaking_hangout", nil) forState:UIControlStateNormal];
    [hangoutButton setTitle:NSLocalizedString(@"shaking_hangout", nil) forState:UIControlStateHighlighted];
	[hangoutButton setBackgroundImage:[UIImage imageNamed:@"shaking_button.png"] forState:UIControlStateNormal];
	[hangoutButton setBackgroundImage:[UIImage imageNamed:@"shaking_button_hl.png"] forState:UIControlStateHighlighted];
	[hangoutButton addTarget:self action:@selector(submitHangout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hangoutButton];
    
    //立即关注
    UIButton* subButton = [[UIButton alloc] initWithFrame:CGRectMake(168, 51, 120, 43)];
    subButton.tag = 103;
    [subButton setTitleColor:buttonTitleColor forState:UIControlStateNormal];
    [subButton setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
    [subButton setTitle:NSLocalizedString(@"shaking_subnow", nil) forState:UIControlStateNormal];
    [subButton setTitle:NSLocalizedString(@"shaking_subnow", nil) forState:UIControlStateHighlighted];
	[subButton setBackgroundImage:[UIImage imageNamed:@"shaking_button.png"]forState:UIControlStateNormal];
	[subButton setBackgroundImage:[UIImage imageNamed:@"shaking_button_hl.png"] forState:UIControlStateHighlighted];
	[subButton addTarget:self action:@selector(submitSubnow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subButton];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	[self customerBg];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTheme:(NSNotification*)notifiction
{
    [super updateTheme:notifiction];
    [self customerBg];

    UIColor* protocolLabelColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingPushLabelColor]];
    UIColor* buttonTitleColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShakingButtonTitleColor]];
    
    //check box
    UIButton* checkboxView = (UIButton*)[self.view viewWithTag:101];
    UIImage* itemImage = [UIImage imageNamed:@"userinfo_check.png"];
    UIImage* itemImagehl = [UIImage imageNamed:@"userinfo_check_hl.png"];
    [checkboxView setBackgroundImage:itemImage forState:UIControlStateNormal];
    [checkboxView setBackgroundImage:itemImagehl forState:UIControlStateSelected];
    
    //逛一逛
    UIButton* hangoutButton = (UIButton*)[self.view viewWithTag:102];
    itemImage = [UIImage imageNamed:@"shaking_button.png"];
    itemImagehl = [UIImage imageNamed:@"shaking_button_hl.png"];
    [hangoutButton setBackgroundImage:itemImage forState:UIControlStateNormal];
    [hangoutButton setBackgroundImage:itemImagehl forState:UIControlStateSelected];
    [hangoutButton setTitleColor:buttonTitleColor forState:UIControlStateNormal];
    [hangoutButton setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
    
    //立即关注
    UIButton* subButton = (UIButton*)[self.view viewWithTag:103];
    itemImage = [UIImage imageNamed:@"shaking_button.png"];
    itemImagehl = [UIImage imageNamed:@"shaking_button_hl.png"];
    [subButton setBackgroundImage:itemImage forState:UIControlStateNormal];
    [subButton setBackgroundImage:itemImagehl forState:UIControlStateSelected];
    [subButton setTitleColor:buttonTitleColor forState:UIControlStateNormal];
    [subButton setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
    
    //push
    UILabel* push = (UILabel*)[self.view viewWithTag:104];
    push.textColor = protocolLabelColor;
}

//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(BOOL)ischecking
{
    UIButton* checkbox = (UIButton*)[self.view viewWithTag:101];
    return checkbox.isSelected;
}

-(void)appearWithAnimation
{
    //Add alpha animation
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue= [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue= [NSNumber numberWithFloat:1.0];
    fadeAnimation.duration= 0.5f;
    [self.view.layer addAnimation:fadeAnimation forKey:@"fadeInOut"];
    self.view.alpha = 1.0f;
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)viewTaped:(id)sender
{
    UIButton* checkbox = (UIButton*)[self.view viewWithTag:101];
    checkbox.selected = !checkbox.selected;
}

-(void)submitHangout:(id)sender
{
    SNDebugLog(@"submitHangout");
    [_subViewController submitHangout:sender];
}

-(void)submitSubnow:(id)sender
{
    SNDebugLog(@"submitSubnow");
    [_subViewController submitSubnow:sender];
}

-(void)customerBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}
@end
