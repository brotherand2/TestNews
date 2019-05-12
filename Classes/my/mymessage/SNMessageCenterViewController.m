//
//  SNMyCommenViewController.m
//  sohunews
//
//  Created by jialei on 13-4-23.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMessageCenterViewController.h"
#import "SNMyMessageTableController.h"
#import "SNNotificaitonTableController.h"
#import "SNActionMenuController.h"
#import "SNHeadSelectView.h"
#import "SNNewsComment.h"
#import "SNMyMessage.h"
#import "SNConsts.h"
#import "SNCommentEditorViewController.h"
#import "SNGuideRegisterViewController.h"
#import "NSDictionaryExtend.h"
#import "SNLiveBannerViewWithTitle.h"

#import "SNBubbleBadgeObject.h"
#import "SNSoundManager.h"
#import "SNOauthWebViewController.h"
#import "SNLoginRegisterViewController.h"
#import "SNCommentConfigs.h"
#import "SNMyMessageTable.h"
#import "SNUserManager.h"
#import "SNSoHuAccountLoginRegisterViewController.h"

@interface SNMessageCenterViewController ()
{
    SNMyMessageTableController *_messageTableController;
    SNNotificaitonTableController *_notificationTableController;
    
    UIScrollView *_scrollView;
}

//- (void)resetMenuItems;

@end

@implementation SNMessageCenterViewController

@synthesize userId = _userId;
@synthesize pid = _pid;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.userId = [SNUserManager getUserId];
        self.pid = [SNUserManager getPid];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(onBubbleMessageChange)
                                                     name:kSNBubbleBadgeChangeNotification object:nil];
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_message;
}

- (void)loadView
{
    [super loadView];
    
    //header
//    _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderTotalHeight)];
//    _headerView.delegate = self;
//    [_headerView setSections:[NSArray arrayWithObjects:@"回复我的", @"通知", nil]];
//    [self.view addSubview:_headerView];
    [self addHeaderView];
    _headerView.delegate = self;
    NSString *title = @"回复我的";
    [_headerView setSections:[NSArray arrayWithObjects:title, @"通知", nil]];
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [_headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
    //scroll panel
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeightWithoutBottom,
                                                                 kAppScreenWidth,
                                                                 kAppScreenHeight - kHeaderHeightWithoutBottom)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    [self.view insertSubview:_scrollView belowSubview:_headerView];

    // views
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    _messageTableController = [[SNMyMessageTableController alloc] initWithQuery:dic];
    _messageTableController.view.backgroundColor = [UIColor clearColor];
    _messageTableController.view.frame = CGRectMake(0, 0, _scrollView.width, _scrollView.height);
    [_scrollView addSubview:_messageTableController.view];
    
    _notificationTableController = [[SNNotificaitonTableController alloc] init];
    if(_notificationTableController) {
        CGRect rect = CGRectMake(_scrollView.width, 0, _scrollView.width, _scrollView.height);;
        _notificationTableController.view.frame = rect;
        [_scrollView addSubview:_notificationTableController.view];
        _scrollView.contentSize = CGSizeMake(_scrollView.width * 2, _scrollView.height);
    }
    
    //toolBar
    [self addToolbar];
    
    [_headerView setTipCount:[SNBubbleNumberManager shareInstance].ppnotify withIndex:1];
    [_headerView setTipCount:[SNBubbleNumberManager shareInstance].ppreply withIndex:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

     //(_messageTableController);
     //(_notificationTableController);
     //(_scrollView);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [_messageTableController viewWillAppear:animated];
    [_notificationTableController viewWillAppear:animated];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_messageTableController viewDidAppear:animated];
    [_notificationTableController viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
     //(_userId);
     //(_pid);
     //(_messageTableController);
     //(_notificationTableController);
     //(_scrollView);
    
    [SNNotificationManager removeObserver:self];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self didShowCommentViewAtIndex:0];
        [_headerView setCurrentIndex:0 animated:YES];
        [[SNSoundManager sharedInstance] stopAmr];
        NSString *title = @"回复我的";
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        _headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    else if(scrollView.contentOffset.x == _scrollView.width)
    {
        [self didShowCommentViewAtIndex:1];
        [_headerView setCurrentIndex:1 animated:YES];
        [[SNSoundManager sharedInstance] stopAmr];
        NSString *title = @"通知";
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        _headerView.bottomLineImageView.frame = CGRectMake(111 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
}

#pragma mark - SNHeadSelectView delegate
- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index {
    [self didShowCommentViewAtIndex:index];
    CGRect viewRect = CGRectMake(index * _scrollView.width, _scrollView.contentOffset.y, _scrollView.width, _scrollView.height);
    [_scrollView scrollRectToVisible:viewRect animated:NO];
    [[SNSoundManager sharedInstance] stopAmr];
    if (index == 0) {
        NSString *title = @"回复我的";
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        _headerView.bottomLineImageView.frame = CGRectMake(7 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
    else {
        NSString *title = @"通知";
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        _headerView.bottomLineImageView.frame = CGRectMake(111 + 7, self.headerView.height-2, titleSize.width+6, 2);
    }
}

- (void)didShowCommentViewAtIndex:(int)index {
    if (index == 0) {
        _messageTableController.tableView.scrollsToTop = YES;
        _notificationTableController.tableView.scrollsToTop = NO;
    }
    else if(index == 1){
        if(_notificationTableController) {
            _messageTableController.tableView.scrollsToTop = NO;
            _notificationTableController.tableView.scrollsToTop = YES;
            [_notificationTableController firstRefresh];
        }
    }
//    _currentIndex = index;
    [TTURLRequestQueue mainQueue].suspended = NO;
}

#pragma mark - SNNaviagtionController
- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    if (_scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

-(void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
}


-(void)onBubbleMessageChange
{
    int count = [SNBubbleNumberManager shareInstance].ppreply;
    [_headerView setTipCount:[SNBubbleNumberManager shareInstance].ppnotify withIndex:1];
    [_headerView setTipCount: count withIndex:0];
}

- (BOOL)isSupportPushBack
{
    NSArray *viewControllers = [TTNavigator navigator].topViewController.flipboardNavigationController.viewControllers;
    if(viewControllers.count > 1)
    {
        UIViewController* vc = [viewControllers objectAtIndex:viewControllers.count-2];
        if([vc isKindOfClass:[SNOauthWebViewController class]])
        {
            return NO;
        }
        else if([vc isKindOfClass:[SNLoginRegisterViewController class]] || [vc isKindOfClass:[SNSoHuAccountLoginRegisterViewController class]])
        {
            return NO;
        }
        else if([vc isKindOfClass:[SNGuideRegisterViewController class]])
        {
            return NO;
        }
    }
    return YES;
}
- (void)onBack:(id)sender
{
    NSArray* array = self.flipboardNavigationController.viewControllers;
    for (UIViewController *vc in array) {
//        if([vc isKindOfClass:[SNGuideRegisterViewController class]])
        if([vc isKindOfClass:[SNLoginRegisterViewController class]])
        {
            NSInteger index = [array indexOfObject:vc] - 1;
            if (index >= 0) {
                UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                [self.flipboardNavigationController popToViewController:baseView animated:YES];
                return;
            }
        }
    }
    
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

@end
