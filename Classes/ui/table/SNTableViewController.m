//
//  SNTableViewController.m
//  sohunews
//
//  Created by Dan on 7/19/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNTableViewController.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNTabBarController.h"
#import "SNRollingNewsModel.h"
#import "SNRollingNewsPublicManager.h"

#define kErrorViewTag     (100000)
#define kEmptyViewTag     (100001)
@implementation SNTableViewController

-(void)loadView
{
	[super loadView];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)dealloc
{
     //(_loadView);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)defaultTitleForLoading {
	return TTLocalizedString(@"Loading...", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (show) {
//            if (!self.model.isLoaded || ![self canShowModel]) {
//                if (!_loadView) {
//                    _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
//                    _loadView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
//                    _loadView.hidesWhenStopped = YES;
//                    _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
//                }
//                
//                self.loadingView = _loadView;
//                _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
//                
//            }
//            
//        } else {
//            _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
//            self.loadingView = nil;
//        }
//    });
    if (show) {
        if (!self.model.isLoaded || ![self canShowModel]) {
            if (!_loadView) {
                _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
                _loadView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                _loadView.hidesWhenStopped = YES;
                _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
            }
            
            self.loadingView = _loadView;
            _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
            
        }
        
    } else {
        _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
        self.loadingView = nil;
    }
}

- (void)hideKeyboard
{
    //to be overrided
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (show) {
//            if (!self.model.isLoaded || ![self canShowModel]) {
//                _tableView.dataSource = nil;
//                [_tableView reloadData];
//                
//                if (!_loadView) {
//                    _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
//                    _loadView.hidesWhenStopped = YES;
//                    _loadView.frame = [self rectForLoadingView];
//                    _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
//                }
//                _loadView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
//                [self.tableView addSubview:_loadView];
//            }
//            
//        } else {
//            _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
//        }
//    });
    if (show) {
        if (!self.model.isLoaded || ![self canShowModel]) {
            _tableView.dataSource = nil;
            [_tableView reloadData];
            
            if (!_loadView) {
                _loadView = [[SNEmbededActivityIndicator alloc] initWithDelegate:self];
                _loadView.hidesWhenStopped = YES;
                _loadView.frame = [self rectForLoadingView];
                _loadView.status = SNEmbededActivityIndicatorStatusStartLoading;
            }
            _loadView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
            [self.tableView addSubview:_loadView];
        }
        
    } else {
        _loadView.status = SNEmbededActivityIndicatorStatusStopLoading;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
    /* http://code.mtc.sohu-inc.com/ticket/28887
    新闻Tab中无数据时有一种提示，网络连接失败时有一种提示；UED组的要求是，服务器返回无数据时也显示网络连接失败的提示；不让用户看到暂无新闻的提示。
    视频Tab中也按同样的方式来处理。*/
    
    [_tableView reloadData];

    [self showError:show];
}


- (CGRect)rectForLoadingView {
    return CGRectMake(0, _tableView.tableHeaderView.height, _tableView.width, _tableView.height - _tableView.tableHeaderView.height/*self.view.height - 44 -49*/);
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry
{
    //首页数据库中没有数据时，请求强制重置 （刷新请求入口太多，各种打补丁）
    if ([self.model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *newsModel = (SNRollingNewsModel *) _model;
        if ([newsModel.channelId isEqualToString:@"1"]) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
        }
    }
    
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

@end
