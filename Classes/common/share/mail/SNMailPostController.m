//
//  SNMailPostController.m
//  sohunews
//
//  Created by wangxiang on 3/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNMailPostController.h"
#import "SNNotificationCenter.h"
//#import "SNHeadSelectView.h"

@implementation SNMailPostController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super  viewDidAppear:animated];
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:0.2];
}
- (void)hideLoading
{
   [SNNotificationCenter hideLoading]; 
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadView
{
    [super loadView];

//    CGRect screenFrame = TTApplicationFrame();
//    UIView *mailView = [self.view.subviews objectAtIndex:0];
//    mailView.frame = CGRectMake(0, kHeaderHeightWithoutBottom + 10, 320, screenFrame.size.height - kHeaderHeightWithoutBottom);
//    self.view.backgroundColor = [UIColor whiteColor];
//    SNHeadSelectView *_headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 20, screenFrame.size.width, kHeaderTotalHeight)];
//    [self.view addSubview:_headerView];
//    _headerView.sections = [NSArray arrayWithObject:@"新邮件"];
//    UIImage *icon = [UIImage imageNamed:@"nickClose.png"];
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setImage:icon forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    CGRect frame = TTApplicationFrame();
//    backBtn.frame = CGRectMake(frame.size.width - icon.size.width - 4/2, 8/2, icon.size.width, icon.size.height);
//    [_headerView addSubview:backBtn];
//    
//    [_headerView release];
}

//- (void)back:(id)sender
//{
//    
//    self.view.backgroundColor = [UIColor clearColor];
//    [self dismissModalViewControllerAnimated:YES];
//}



@end
