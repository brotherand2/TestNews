//
//  SNSmsPostController.m
//  sohunews
//
//  Created by 李 雪 on 11-8-10.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNSmsPostController.h"

@implementation SNSmsPostController

- (void)loadView
{
    [super loadView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if ([self.messageComposeDelegate respondsToSelector:@selector(SmsPostControllerDidAppear)]) {
		[self.messageComposeDelegate performSelector:@selector(SmsPostControllerDidAppear)];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
