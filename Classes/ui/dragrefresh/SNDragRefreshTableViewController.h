//
//  SNDragRefreshTableViewController.h
//  sohunews
//
//  Created by Dan on 8/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNBaseTableViewController.h"

@interface SNDragRefreshTableViewController : SNBaseTableViewController
- (void)resetTableDelegate:(id)aDelegate;
@end
