//
//  SNChatFeedbackController.m
//  sohunews
//
//  Created by qi pei on 8/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChatFeedbackController.h"
#import "SNSuggestionFeedBackViewController.h"
#import "SNMyFeedBackViewController.h"
#import "SNUsualQuestionViewController.h"
#import "SNUserManager.h"
#import "SNCheckManager.h"
#import "SNRedResetRequest.h"

#define TitleMargin 8.0f
#define HeadBottomMargin 3.0f
#define TitleSize   [@"常见问题" sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]]
#define TitleSize1   [@"客服小秘书" sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]]

@interface SNChatFeedbackController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SNHeadSelectViewDelegate>

@property (nonatomic, strong) SNSuggestionFeedBackViewController *suggestionVc;//意见反馈
@property (nonatomic, strong) SNMyFeedBackViewController *myFeedBackVc;//客服小秘书
@property (nonatomic, strong) SNUsualQuestionViewController *usualQuestionVc;//常见问题
@property (nonatomic, strong) SNUsualQuestionViewController *userCommentVc;//用户评论
@property (nonatomic, strong) UIButton *barLabel;
@property (nonatomic, strong) NSMutableArray *scrollViewList;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL shouldShowCloseButton;
@property (nonatomic, assign) BOOL isKeyBoardShow;
@property (nonatomic, strong) NSString *backUrl;

@end

@implementation SNChatFeedbackController


- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        self.backUrl = [query stringValueForKey:kLoginBackUrlKey defaultValue:nil];
        [self addHeaderView];
        self.headerView.textFont = kThemeFontSizeE;
        self.headerView.textSideMargin = TitleMargin;
        self.headerView.unanimated = YES;
        [self.headerView setSections:[NSArray arrayWithObjects:@"用户评论",@"常见问题", @"客服小秘书", nil]];
        self.headerView.delegate = self;
//        [self.headerView registerOffsetListener:_scrollView];
//        [self.headerView setTipCount:5 withIndex:2];    // 模拟新的反馈信息提示
        // 进来时判断有无回复
        BOOL havereply = [[NSUserDefaults standardUserDefaults] boolForKey:kFbHaveReply];
        if (havereply) {
            [self.headerView setTipCount:1 withIndex:2];
        } else {
            [self.headerView setTipCount:0 withIndex:2];
        }

        [self.headerView setBottomLineForHeaderView:CGRectMake((TitleMargin - HeadBottomMargin), self.headerView.height-2, (TitleSize.width + 2 * HeadBottomMargin), 2)];
        self.headerView.bottomLineImageView.frame = CGRectMake((2 *TitleMargin + TitleSize.width/2 - 8.0), self.headerView.height-2, 16.0, 2);
        if ([query objectForKey:@"ScreenShotFeedBack"]) {
            [self gotoFeedBackTabWithIndex:2 andAnimated:NO];
        }
        if ([query objectForKey:@"jsFeedBack"]) {
            NSInteger index = [[query objectForKey:@"jsFeedBack"] integerValue];
            [self gotoFeedBackTabWithIndex:index andAnimated:NO];
        }
        if ([query objectForKey:@"feedBackDict"]) {
            self.myFeedBackVc.feedBackDict = [query objectForKey:@"feedBackDict"];
        }
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SNNotificationManager addObserver:self selector:@selector(unReadFbReply:) name:kUnReadFbReplyNotification object:nil];
    self.userCommentVc.view.frame = CGRectMake(0, kHeaderHeightWithoutBottom, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom-kToolbarHeight);
    self.usualQuestionVc.view.frame = CGRectMake(kAppScreenWidth, kHeaderHeightWithoutBottom, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom-kToolbarHeight);
//    self.suggestionVc.view.frame = CGRectMake(kAppScreenWidth, kHeaderHeightWithoutBottom, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom-kToolbarHeight);
    self.myFeedBackVc.view.frame = CGRectMake(kAppScreenWidth * 2, kHeaderHeightWithoutBottom, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom - kToolbarHeight);
    [self addToolbar];
    
    _barLabel = [self getToolBarLabelButton];
    [self.toolbarView addSubview:_barLabel];
    
    [self.toolbarView addSubview:self.closeButton];
    
    
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillAppear) name:UIKeyboardWillShowNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(closeCurrentPage) name:kCloseChatFeedbackNotification object:nil];
}

- (UIButton *)getToolBarLabelButton {
    UIButton *barLabel = [[UIButton alloc] init];
    [barLabel setTitle:@"请简要描述您的问题或建议" forState:UIControlStateNormal];
    barLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    barLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [barLabel setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];;
    barLabel.layer.borderWidth = 0.3;
    barLabel.layer.borderColor = SNUICOLOR(kThemeBg1Color).CGColor;
    barLabel.left = 45;
    barLabel.width = kAppScreenWidth - 40 - 14;
    barLabel.height = 30;
    barLabel.top = (kToolbarHeight - barLabel.height) / 2;
    
    barLabel.hidden = YES;
    [barLabel addTarget:self action:@selector(changeToQuickFeedBack) forControlEvents:UIControlEventTouchUpInside];
    return barLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIImage *image = [UIImage imageNamed:@"icotab_close_v5.png"];
        UIImage *imagePress = [UIImage imageNamed:@"icotab_closepress_v5.png"];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, 0, kToolbarButtonSize + 2.0, kToolbarButtonSize);
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton setImage:imagePress forState:UIControlStateHighlighted];
        _closeButton.left = kToolBarBackBtnLeft + kToolBarBtnImgWidth + kToolBarBtnSpace;
        _closeButton.top = self.toolbarView.frame.size.height / 2.0 -  kToolbarButtonSize / 2.0;
        _closeButton.hidden = YES;
        [_closeButton addTarget:self action:@selector(closeCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setAllScrollViewDisableScrollToTop];
    self.myFeedBackVc.fbTableView.scrollsToTop = YES;
}

- (void)setAllScrollViewDisableScrollToTop {
    [_scrollViewList removeAllObjects];
    [self wayToFindScrollViewIn:[UIApplication sharedApplication].keyWindow];
    for (UIScrollView *scrollView in _scrollViewList) {
        scrollView.scrollsToTop = NO;
    }
}

/**find all scrollView*/
- (void)wayToFindScrollViewIn:(UIView *)baseView {
    for (UIView *view in baseView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [_scrollViewList addObject:view];
        }
        if (view.subviews.count > 0) {
            [self wayToFindScrollViewIn:view];
        }
    }
}


- (void)unReadFbReply:(NSNotification *)noti {
    if (self.headerView.currentIndex == 2) {
        return;
    }
    NSNumber *numState = (NSNumber *)[noti object];
    if ([numState boolValue]) {
        
        [self.headerView setTipCount:1 withIndex:2];
    } else {
        [self.headerView setTipCount:0 withIndex:2];
    }
}

#pragma mark - SNHeadSelectViewDelegate
- (void)headView:(SNHeadSelectView *)headView didSelectIndex:(int)index {
    [_scrollView setContentOffset:CGPointMake(index * kAppScreenWidth, 0) animated:NO];
    
    if (index == 2) {
        // 统计埋点
        [SNNewsReport reportADotGif:@"act=cc&fun=97"];
        self.barLabel.hidden = NO;
        CGFloat itemW = 2 *TitleMargin + TitleSize.width;
        CGFloat commomW = itemW * index + TitleMargin - HeadBottomMargin;
        self.headerView.bottomLineImageView.frame = CGRectMake(commomW + TitleMargin + TitleSize1.width/2 + HeadBottomMargin - 8.0, self.headerView.height-2, 16.0, 2);
        
        // 取消小红点
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kFbHaveReply]) {
         
            [[[SNRedResetRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kFbHaveReply];
            } failure:nil];
        }
    } else {
       
        CGFloat itemW = 2 *TitleMargin + TitleSize.width;
        CGFloat commomW = itemW * index + TitleMargin - HeadBottomMargin;
        self.headerView.bottomLineImageView.frame = CGRectMake(commomW + TitleMargin + TitleSize.width/2 + HeadBottomMargin - 8.0, self.headerView.height-2, 16.0, 2);
        self.barLabel.hidden = YES;
    }
    if (index == 0 && self.shouldShowCloseButton) {
        self.closeButton.hidden = NO;
    }
    else {
        if (index == 0) {
            self.userCommentVc.webView.scrollView.scrollsToTop = YES;
        }
        else {
            //隐藏键盘
            if ([[UIApplication sharedApplication] canPerformAction:@selector(resignFirstResponder) withSender:nil] && self.isKeyBoardShow) {
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            }
        }
        self.closeButton.hidden = YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / kAppScreenWidth;
    [self gotoFeedBackTabWithIndex:index andAnimated:NO];
}

- (void)gotoFeedBackTabWithIndex:(NSInteger)index andAnimated:(BOOL)animated {
    [self headView:self.headerView didSelectIndex:index];
    [self.headerView setCurrentIndex:index animated:animated];
}

- (void)changeToQuickFeedBack {
    // 统计埋点
    [SNNewsReport reportADotGif:@"act=cc&fun=96"];
    TTURLAction *urlAction = [TTURLAction actionWithURLPath:@"tt://quickFeedBack"];
    TTNavigator *navigator = [TTNavigator navigator];
    [navigator openURLAction:urlAction];
}

- (void)setFeedbackDict:(NSDictionary *)feedbackDict {
    _feedbackDict = feedbackDict;
    self.myFeedBackVc.feedBackDict = feedbackDict;
    [self gotoFeedBackTabWithIndex:2 andAnimated:NO];
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer
{
    if (self.scrollView.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
        _scrollView.backgroundColor = SNUICOLOR(kBackgroundColor);
        _scrollView.contentSize = CGSizeMake(kAppScreenWidth*3, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
    }
    return _scrollView;
}

- (SNSuggestionFeedBackViewController *)suggestionVc {
    if (_suggestionVc == nil) {
        _suggestionVc = [[SNSuggestionFeedBackViewController alloc] init];
       
        [self.scrollView addSubview:_suggestionVc.view];
    }
    return _suggestionVc;
}

- (SNMyFeedBackViewController *)myFeedBackVc {
    if (_myFeedBackVc == nil) {
        _myFeedBackVc = [[SNMyFeedBackViewController alloc] init];
        
        [self.scrollView addSubview:_myFeedBackVc.view];
    }
    return _myFeedBackVc;
}

- (SNUsualQuestionViewController *)usualQuestionVc {
    if (_usualQuestionVc == nil) {
        _usualQuestionVc = [[SNUsualQuestionViewController alloc] init];
        [self.scrollView addSubview:_usualQuestionVc.view];

    }
    return _usualQuestionVc;
}

- (SNUsualQuestionViewController *)userCommentVc {
    if (_userCommentVc == nil) {
        _userCommentVc = [[SNUsualQuestionViewController alloc] init];
        _userCommentVc.isUserComment = YES;
        _userCommentVc.backUrl = self.backUrl;
        [self.scrollView addSubview:_userCommentVc.view];
    }
    return _userCommentVc;
}

- (void)onBack:(id)sender {
    if (self.headerView.currentIndex == 0) {
        if ([self.userCommentVc.webView canGoBack]) {
            self.closeButton.hidden = NO;
            self.shouldShowCloseButton = YES;
            [self.userCommentVc.webView goBack];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2), dispatch_get_main_queue(), ^() {
                [self.userCommentVc h5Refresh];
            });
        }
        else {
            [self closeCurrentPage];
        }
    }
    else {
        [self closeCurrentPage];
    }
}

- (void)closeCurrentPage {
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
}

- (void)keyboardWillAppear {
    self.isKeyBoardShow = YES;
}

- (void)keyboardWillDisappear {
    self.isKeyBoardShow = NO;
}

- (void)dealloc {
    if (self.scrollView) {
        self.scrollView.delegate = nil;
        self.scrollView = nil;
    }
    
    if (self.headerView) {
        self.headerView.delegate = nil;
        self.headerView = nil;
    }

    [SNNotificationManager removeObserver:self];
}


@end
