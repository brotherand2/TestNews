//
//  SNMyConcernViewController.h
//  sohunews
//
//  Created by 赵青 on 16/8/29.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDragRefreshTableViewController.h"
#import "SNSubscribeNewsTableViewDelegate.h"
#import "SNSohuHaoViewController.h"

@interface SNMyConcernViewController : SNDragRefreshTableViewController

@property(nonatomic, strong) SNSubscribeNewsTableViewDelegate *dragDelegate;

@property (nonatomic, weak) SNSohuHaoViewController * superController;

- (void)showFollowingEmpty:(BOOL)show;

-(void)refreshWithNoAnimation;

@end
