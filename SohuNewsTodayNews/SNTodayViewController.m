//
//  SNTodayViewController.m
//  TodayNews
//
//  Created by WongHandy on 8/4/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "SNTodayWidgetNewsService.h"
#import "SNTodayWidgetContentView.h"
#import "SNTodayWidgetNews.h"
#import "SNTodayWidgetConst.h"
#import "SNDebug.h"
#import "UIImageView+WebCache.h"
#import "SNStateButton.h"
#import "SNCollectModeButton.h"

static NSString *const kNewsProtocol = @"sohunewsiphone://pr/%@";
static NSString *const kNewsChannelProtocol = @"sohunewsiphone://pr/newsTab://channelId=1";
#define kWidgetHeight     110.0
#define kBottomBtnHeight  37.0
#define kTopBtnHeight     (self.view.bounds.size.height - kBottomBtnHeight)
#define kCollectMode      @"kCollectMode"
#define kPasteboard       @"Pasteboard"


typedef void(^WidgetCompletionHandler)(NCUpdateResult result);

@interface SNTodayViewController () <NCWidgetProviding> {
    SNTodayWidgetNewsService *_service;
    SNTodayWidgetContentView *_contentView;
    NSExtensionContext *_extensionContext;
    CGSize widgetSize;
}
@property (nonatomic, weak) SNStateButton *topBtn;
@property (nonatomic, weak) SNCollectModeButton *leftBtn;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIImageView *yellowView;
@end

@implementation SNTodayViewController

#pragma mark - Lifecycle
// Tells the extension to prepare its interface for the requesting context, and request related data items. At this point [(NS|UI)ViewController extensionContext] returns a non-nil value. This message is delivered after initialization, but before the conforming object will be asked to "do something" with the context (i.e. before -[(NS|UI)ViewController loadView]). Subclasses of classes conforming to this protocol are expected to call [super beginRequestWithExtensionContext:] if this method is overridden.
- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    SNDebugLog(@"...%@", NSStringFromSelector(_cmd));
    [super beginRequestWithExtensionContext:context];
    if ([self newsGrabAuthorities]) return;
    _extensionContext = context;
    
    if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        _extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    }
    
    if (!_contentView) {
        CGRect contentViewFrame = CGRectMake(0,
                                             0,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height
                                             );
        _contentView = [[SNTodayWidgetContentView alloc] initWithFrame:contentViewFrame];
        _contentView.delegate = self;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_contentView];
    }
    _service = [[SNTodayWidgetNewsService alloc] init];
    _service.delegate = self;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    SNDebugLog(@"...%@", NSStringFromSelector(_cmd));
    //使得widget列表两头都顶到屏幕左右两边的边界
    return UIEdgeInsetsMake(defaultMarginInsets.top, 35, 5, 0);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    SNDebugLog(@"...%@", NSStringFromSelector(_cmd));
    completionHandler(NCUpdateResultNoData);
}

#pragma mark 在iOS10新增了展开/折叠功能
// 5.7.2 by wangchuanwen
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    if(activeDisplayMode == NCWidgetDisplayModeCompact)
    {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, maxSize.height);
    }
    else
    {
        self.preferredContentSize = widgetSize;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SNDebugLog(@"Really, to load data from server...");
    if ([self newsGrabAuthorities]) return;
    [_service requestFromLocalAsynchrously];
    [_service requestFromServerAsynchrously];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![self newsGrabAuthorities]) return;
    if (self.topBtn.collectState == SNStateButtonAdded) {
        self.topBtn.collectState = SNStateButtonNormal;
        self.yellowView.transform = CGAffineTransformIdentity;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)dealloc {
    SNDebugLog(@"%@---%@...", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [_service cancel];
    _service = nil;
    _contentView.delegate = nil;
    _contentView = nil;
    _extensionContext = nil;
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - SNTodayWidgetNewsServiceDelegate
- (void)didFinishWithNewsList:(NSArray *)newsList {
    SNDebugLog(@"Finshed to get newslist %@", newsList);
    
    CGFloat ZKHeight = [_contentView heightForNewsList:newsList];
    widgetSize = CGSizeMake(self.view.bounds.size.width, ZKHeight);

    //在iOS10及以后，preferredContentSize要在展开／折叠的回调里面设置(在这里设置无用，同时会造成影响)，但iOS10以前必须在这里设置  5.7.2 by wangchuanwen
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        
        self.preferredContentSize = widgetSize;
    }
    else{
        
        if (_extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeExpanded) {
            
            [self widgetActiveDisplayModeDidChange:_extensionContext.widgetActiveDisplayMode withMaximumSize:widgetSize];
        }
        
    }
    [_contentView reload:newsList];
}

- (void)didFailedWithError:(NSError *)error {
    SNDebugLog(@"...Error %@", error.localizedDescription);
}

#pragma mark -  SNTodayWidgetContentViewDelegate
- (void)didTapOnMoreNewsBtnInContentView:(SNTodayWidgetContentView *)contentView {
    [_extensionContext openURL:[NSURL URLWithString:kNewsChannelProtocol] completionHandler:^(BOOL success) {
        SNDebugLog(@"Had open sohunews app.");
    }];
}

- (void)didSelectNews:(SNTodayWidgetNews *)news {
    NSString *urlString = nil;
    if (news.link2 > 0) {
        urlString = [NSString stringWithFormat:kNewsProtocol, news.link2];
    } else {
        urlString = kNewsChannelProtocol;
    }
    [_extensionContext openURL:[NSURL URLWithString:urlString] completionHandler:^(BOOL success) {
        SNDebugLog(@"Had open sohunews app.");
    }];
}

#pragma mark - newsGrab

- (void)setupUI {
    
    /// yellowView
    UIImageView *yellowView = [[UIImageView alloc] initWithFrame:CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, kTopBtnHeight)];
    yellowView.image = [UIImage imageNamed:@"ico_jdbg_v5.png"];
    self.yellowView = yellowView;
    [self.view addSubview:yellowView];
    
    
    /// topBtn
    SNStateButton *topBtn = [[SNStateButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kTopBtnHeight)];
    [topBtn addTarget:self action:@selector(handleBoardString:) forControlEvents:UIControlEventTouchUpInside];
    topBtn.collectState = SNCollectModeNormal;
    self.topBtn = topBtn;
    [self.view addSubview:topBtn];
    
    
    /// bottomView
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, topBtn.bounds.size.height, [UIScreen mainScreen].bounds.size.width, 37)];
    bottomView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.bottomView = bottomView;
    [self.view addSubview:bottomView];
    
    /// bottomMidLine
    UIView *bottomMidLine = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 5, 1, bottomView.bounds.size.height - 5*2)];
    bottomMidLine.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.7];
    [bottomView addSubview:bottomMidLine];
    
    /// leftBtn
    SNCollectModeButton *leftBtn = [[SNCollectModeButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, bottomView.bounds.size.height)];
    SNCollectModeType collectMode = [[NSUserDefaults standardUserDefaults] integerForKey:kCollectMode];
    if (collectMode) {
        leftBtn.collectMode = collectMode;
    } else {
        leftBtn.collectMode = SNCollectModeAuto;
    }
    self.leftBtn = leftBtn;
    [leftBtn addTarget:self action:@selector(changeIncludeMethod:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:leftBtn];
    
    /// rightBtn
    SNCollectModeButton *rightBtn = [[SNCollectModeButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 0, [UIScreen mainScreen].bounds.size.width/2, bottomView.bounds.size.height)];
    [rightBtn setTitle:@"打开搜狐新闻" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(openSohuApp) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rightBtn];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (![self newsGrabAuthorities]) return;
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeCompact;
    self.preferredContentSize = CGSizeMake(0, kWidgetHeight);
    
    [self setupUI];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *boardString = pasteboard.string;
    
    NSString *value = [[NSUserDefaults standardUserDefaults] valueForKey:kPasteboard];
    if (boardString.length > 0 &&[value isEqualToString:boardString]) { // 剪贴板内容和上次收藏的链接相同
        
        if (self.topBtn.collectState == SNStateButtonAdded) { // 已成功收录,置回初始状态
            self.topBtn.collectState = SNStateButtonNormal;
            self.yellowView.transform = CGAffineTransformIdentity;
        }
        return;
    }
    if (![self isLogin]) return;
    if ([self isAvailableUrl:boardString]) { // 是有效的url
        if (self.leftBtn.collectMode == SNCollectModeAuto) { // 自动收录
            [self grabNews:boardString];
        } else if (self.leftBtn.collectMode == SNCollectModeManually) { // 手动收录
            self.topBtn.collectState = SNStateButtonAddTo;
        }
    } else {  // 无效的url,收录状态置回初始状态
        self.topBtn.collectState = SNStateButtonNormal;
        self.yellowView.transform = CGAffineTransformIdentity;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (![self newsGrabAuthorities]) return;
    self.bottomView.frame = CGRectMake(0, kTopBtnHeight, self.view.bounds.size.width, self.bottomView.bounds.size.height);
    self.yellowView.frame = CGRectMake(self.yellowView.frame.origin.x, 0, self.view.bounds.size.width, kTopBtnHeight);
    self.topBtn.frame = CGRectMake(0, 0, self.view.bounds.size.width, kTopBtnHeight);
}

- (void)changeIncludeMethod:(SNCollectModeButton *)leftBtn {
    
    leftBtn.collectMode = (leftBtn.collectMode == SNCollectModeAuto) ? SNCollectModeManually : SNCollectModeAuto;
    [[NSUserDefaults standardUserDefaults] setInteger:leftBtn.collectMode forKey:kCollectMode];
}

- (void)handleBoardString:(SNStateButton *)topBtn {
    if (topBtn.collectState == SNStateButtonAddTo) {
        [self grabNews:[UIPasteboard generalPasteboard].string];
    } else if (topBtn.collectState == SNStateButtonAdded) {
        [self openSohuApp];
    }
}

- (void)grabNews:(NSString *)boardString {
    
    NSString *pid = [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] objectForKey:kTodaynewswidgetPid];
    self.topBtn.collectState = SNStateButtonAdding;
    
    [SNTodayWidgetNewsService uploadPasteBoardToServer:boardString pid:pid success:^{
        [UIView animateWithDuration:1.0 animations:^{
            self.yellowView.transform = CGAffineTransformTranslate(self.yellowView.transform, [UIScreen mainScreen].bounds.size.width, 0);
        } completion:^(BOOL finished) {
            [[NSUserDefaults standardUserDefaults] setObject:boardString forKey:kPasteboard];
            self.topBtn.collectState = SNStateButtonAdded;
        }];
    } failure:^{
        self.topBtn.collectState = SNStateButtonNormal;
        self.yellowView.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)isLogin {
    NSString *pid = [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] objectForKey:kTodaynewswidgetPid];
    if (pid.length <=0 || [pid isEqualToString:@"-1"]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)newsGrabAuthorities {
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        return NO;
    }
    if ([self isLogin] && [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] boolForKey:kNewsGrabAuthority]) {
        return YES;
    }
    return NO;
}

- (void)openSohuApp {
    NSURL *url = [NSURL URLWithString:@"sohunewsiphone://com.sohu.newspaper.collection"];
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        SNDebugLog(@"打开收藏");
    }];
}


/// 判断字符串是不是一个有效的url
- (BOOL)isAvailableUrl:(NSString *)boardString {
    if(boardString == nil) return NO;
    
    NSError *error;
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:boardString options:0 range:NSMakeRange(0, [boardString length])];
    if (error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }
    if (arrayOfAllMatches.count > 0) {
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString *substringForMatch = [boardString substringWithRange:match.range];
            NSLog(@"%@",substringForMatch);
        }
        return YES;
    } else {
        return NO;
    }
}


@end

