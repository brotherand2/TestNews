//
//  SNTableViewController.h
//  sohunews
//
//  Created by Dan on 7/19/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNThemeTableViewController.h"
#import "SNEmbededActivityIndicator.h"

@interface SNTableViewController : SNThemeTableViewController<SNEmbededActivityIndicatorDelegate>
{//TTTableViewController {

    SNEmbededActivityIndicator *_loadView;
}
//- (void)flashTabItem:(BOOL)bFlash atIndex:(int)index;
- (CGRect)rectForLoadingView;

@end
