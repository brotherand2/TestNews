//
//  SNCommentListTable.m
//  sohunews
//
//  Created by jialei on 13-10-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentListTable.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNCommentConfigs.h"


@interface SNCommentListTable() {
    BOOL _isLoading;
    BOOL _shouldUpdateRefreshTime;
    
    SNEmbededActivityIndicatorEx *_loadingView;
}

@end

@implementation SNCommentListTable

@synthesize dragView = _dragView;
@synthesize eventDelegate;
@synthesize tableTag;
@synthesize isLoading = _isLoading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        // Initialization code
        _isLoading = NO;
        _shouldUpdateRefreshTime = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //loading页面
//        [self showLoading];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
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
        [_loadingView setFrame:CGRectMake(0, -50, self.width, self.height)];
        [self addSubview:_loadingView];
	}
    [self bringSubviewToFront:_loadingView];
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
    if (show)
    {
        if (!_emptyView)
        {
            
            UIImage *emptyImage = [UIImage imageNamed:@"icotext_sofa_v5.png"];
             _emptyView = [[UIImageView alloc] initWithImage:emptyImage];
            _emptyView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)-20);
            
            _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _emptyView.bottom + 10, self.width, kThemeFontSizeC)];
            _emptyLabel.text = @"暂无评论，点击抢沙发";
            _emptyLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
            _emptyLabel.textColor = SNUICOLOR(kThemeText3Color);
            _emptyLabel.textAlignment = NSTextAlignmentCenter;
            _emptyLabel.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
            [self addGestureRecognizer:tap];
        }
        if(NO == [self.subviews containsObject:_emptyView]){
            [self addSubview:_emptyView];
        }
        if(NO == [self.subviews containsObject:_emptyLabel]){
            [self addSubview:_emptyLabel];
        }
    }
    else
    {
        if (_emptyView)
        {
            [_emptyView removeFromSuperview];
        }
        if (_emptyLabel) {
            [_emptyLabel removeFromSuperview];
        }
    }
}

- (void)handleTap {
    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(commentTableEmptyTap)]) {
        [self.eventDelegate commentTableEmptyTap];
    }
}

#pragma mark - notification
- (void)commentListShowEmpty
{
    [self showEmpty:YES];
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

- (void)updateTheme {
    _emptyView.image = [UIImage imageNamed:@"icotext_sofa_v5.png"];
    _emptyLabel.textColor = SNUICOLOR(kThemeText3Color);

}

@end
