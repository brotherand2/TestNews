//
//  SNRollingChannelWebViewController.h
//  sohunews
//
//  Created by yangln on 2016/12/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDragRefreshTableViewController.h"
#import "SNTwinsLoadingView.h"

@interface SNRollingChannelWebViewController : SNDragRefreshTableViewController

@property (nonatomic, strong) SNTwinsLoadingView *dragLoadingView;
@property (nonatomic, weak) id delegate;

- (void)doRequest:(NSString *)channelID;
- (void)webViewReload;
@end
