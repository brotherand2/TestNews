//
//  SNDragRefreshTableViewController.m
//  sohunews
//
//  Created by Dan on 8/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNDragRefreshTableViewController.h"

@implementation SNDragRefreshTableViewController

- (void)resetTableDelegate:(id)aDelegate {
    if (aDelegate != _tableView.delegate) {
        _tableDelegate = aDelegate;
        _tableView.delegate = nil;
        _tableView.delegate = _tableDelegate;
    }
}

@end
