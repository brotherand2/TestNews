//
//  SNUnFollowingListView.h
//  sohunews
//
//  Created by HuangZhen on 2017/6/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSohuHaoViewController.h"

@interface SNUnFollowingListView : UIView

@property (nonatomic, weak) SNSohuHaoViewController * superController;

- (void)viewWillAppear;

- (void)viewDidAppear;

- (void)viewScrollDidShow;

- (void)refreshCurrentTab;

@end
