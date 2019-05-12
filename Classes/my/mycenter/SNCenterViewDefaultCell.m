//
//  SNCenterViewTable.m
//  sohunews
//
//  Created by jialei on 13-12-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCenterViewDefaultCell.h"
#import "SNMoreCellForMediaEntry.h"

@interface SNCenterViewDefaultCell() {
    BOOL _isLoading;
    BOOL _shouldUpdateRefreshTime;
    
    UIImageView *_emptyView;
    SNEmbededActivityIndicatorEx *_loadingView;
}

@end

@implementation SNCenterViewDefaultCell

@synthesize eventDelegate;
@synthesize tableTag;
@synthesize isLoading;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _isLoading = NO;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //loading页面
        [self showLoading];
    }
    return self;
}

- (void)dealloc
{
}

- (BOOL)checkNetworkIsEnableAndTell {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        bRet = NO;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    return bRet;
}

#pragma mark- maskPage
- (void)showLoading {
	if (!_loadingView) {
		_loadingView = [[SNEmbededActivityIndicatorEx alloc] initWithFrame:CGRectZero andDelegate:self];
        _loadingView.hidesWhenStopped = YES;
        _loadingView.delegate = self;
        _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
        [_loadingView setFrame:CGRectMake(0, kMoreCellForMediaEntryHeight, kAppScreenWidth, self.height)];
        _loadingView.backgroundColor = [UIColor clearColor];
        [self addSubview:_loadingView];
	}
//    [self bringSubviewToFront:_loadingView];
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
}

- (void)hideLoading {
    //    _photoTextTable.hidden = NO;
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    [_loadingView removeFromSuperview];
}

- (void)showError {
    _loadingView.status = SNEmbededActivityIndicatorStatusUnstableNetwork;
    //    _photoTextTable.hidden = YES;
}

- (void)hideError {
    _loadingView.status = SNEmbededActivityIndicatorStatusInit;
}

- (void)showEmpty:(BOOL)show
{
//    [self hideLoading];
    if (show)
    {
        if (!_emptyView)
        {
            
            UIImage *emptyImage = [UIImage imageNamed:@"circle_no_action_self.png"];
            _emptyView = [[UIImageView alloc] initWithImage:emptyImage];
            _emptyView.top = kMoreCellForMediaEntryHeight;
            _emptyView.left = (kAppScreenWidth - emptyImage.size.width)/2;
            [self addSubview:_emptyView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
            [self addGestureRecognizer:tap];
        }
    }
    else
    {
        if (_emptyView)
        {
            [_emptyView removeFromSuperview];
        }
    }
}

- (void)setStatus:(SNCircleErrorCode)status
{
    switch (status) {
        case kSNCircleErrorCodeDisconnect:
        {
            [self showError];
            break;
        }
        case kSNCircleErrorCodeNoData:
        {
            [self showEmpty:YES];
            break;
        }
        case kSNCircleErrorCodeNoError://5.0 new add
        {
            [self showLoading];
        }
        default:
        {
//            [self showLoading];
            break;
        }
    }
}

- (void)handleTap {
    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(commentTableEmptyTap)]) {
        [self.eventDelegate commentTableEmptyTap];
    }
}

- (void)updateTheme
{
    if(_emptyView)
    {
        _emptyView.image = [UIImage imageNamed:@"circle_no_action_self.png"];
    }
}
#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

#pragma mark - SNEmbededActivityIndicatorDelegate
- (void)didTapRetry {
    [self showLoading];
    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(commentTableRefreshModel)]) {
        [self.eventDelegate commentTableRefreshModel];
    }
}

@end

