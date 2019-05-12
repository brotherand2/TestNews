//
//  SNWebController.h
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SmsSupport.h"
#import "SNTableHeaderDragRefreshView.h"
#import "SNTripletsLoadingView.h"
#import "UIWebView+Utility.h"
#import "SNWebUrlView.h"
#import "SNProgressBar.h"
#import "SNRollingNewsTableController.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
#define kWebViewRefreshDeltaY (-65.0f)

// The height of the refresh header when it is in its "loading" state.
#define kWebViewHeaderVisibleHeight (60.0f)

//#define kBrowserShareContent @"browser://action=share"
#define kShareProtocal @"share://"

@class SNToolbar;
@class SharedInfo;
@class SNActionMenuController;

@protocol SNSubscribeRequestDelegate <NSObject>

- (void)subscribeRequest:(NSString *)stockCode from:(NSString *)from;
- (void)unsubscribeRequest:(NSString *)stockCode from:(NSString *)from;

@end

@interface SNWebController : TTModelViewController
<UIActionSheetDelegate,
    UIWebViewDelegate,
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate,
    SNTripletsLoadingViewDelegate,
    SNWebUrlViewDelegate>
{
    SNToolbar *_toolbar;
    SNProgressBar *_progress;
    UIWebView *_webView;
    
    SNTripletsLoadingView *_loading;
    

    UILabel *_titleView;
    
//    SNHeadSelectView *_headerView;
    

    
@protected
	
	NSURL *_url;
	
	BOOL _isFullScreen;
	NSString *_encodeUid;
	UIActionSheet *_actionSheet;
	BOOL _isLoading;
	
	UIButton *_share;
    UIButton *_more;
	UIButton *_refresh;
	UIButton *_stopBtn;
	UIButton *_back;
	UIButton *_front;
    UIButton *_dismissBtn;
    UIButton *_placeholderBtn;
    
    BOOL isResettingHTML;
	NSString *_emptyHtmlPath;
    NSString *_webUrl;
    
    BOOL _isPushed;
    
    // drag refresh
    UIScrollView *_webScrollView;
    SNTableHeaderDragRefreshView *_dragView;
    
    BOOL _firstLoaded;
    
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy)	  NSString *encodeUid;
@property (nonatomic, strong) SNToolbar *toolbar;
@property (nonatomic, strong) UIView *progress;
@property (nonatomic, strong) UIView *webView;
@property (nonatomic, strong) SNTripletsLoadingView *loading;
@property(nonatomic, copy)NSString *subId;
@property(nonatomic, copy)NSString *termId;
@property(nonatomic, copy)NSString *isHistory;
@property(nonatomic, copy)NSString *webUrl;
@property(nonatomic, copy)NSString *urlTitle;
@property(nonatomic, strong)SNActionMenuController *shareMenuController;
@property(nonatomic, strong)SNWebUrlView *webUrlView;

@property(nonatomic, strong)NSDictionary *query;    //lijian 2014.12.17 活动页要特殊处理h5的地址栏，没办法...

@property (nonatomic, strong) __block SNRollingNewsTableController *sourceVC;

//股票频道添加按钮 wangyy
@property (nonatomic, assign) SNSubscribeButtonState addChannel;
@property (nonatomic, strong) NSString *channelType;
@property (nonatomic, weak) id<SNSubscribeRequestDelegate> iDelegate;
@property (nonatomic, strong) NSString *subscribeCode;
@property (nonatomic, strong) NSString *stockfrom;

- (id)initWithParams:(NSDictionary *)query URL:(NSURL *)URL;

- (void)addWebView;
- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;
- (void)exitFullScreen;
- (void)showErrorView:(NSString *)error;
- (void)showLoading;
- (void)hideLoading;
- (BOOL)isError;
- (void)showInitProgress;
- (void)hideInitProgress;
- (void)resetEmptyHTML;
- (BOOL)checkIfHadBeenMyFavourite;
- (void)closeBrowser;
- (BOOL)canLeavePage;
- (BOOL)canRefreshBrowser;
- (void)backAction;

// methods for drag refresh
- (void)dragViewStartLoad;
- (void)dragViewFinishLoad;
- (void)dragViewFailLoad;
- (SharedInfo *)getSharedInfo;

- (void)hideGradientBackground:(UIView*)theView;

// 3.5.1
// 给所有网页访问增加用户中心cookie
- (void)appendCookieToRequeset:(NSMutableURLRequest*)request url:(NSURL*)url;

- (void)updateBackgroundColor;

- (void)shareH5Content:(NSString *)text link:(NSString *)aLink title:(NSString *)aTitle;
- (void)shareWithTitle:(NSString*)aTitle content:(NSString*)aContent link:(NSString*)aLink imageUrl:(NSString*)aImageUrl;

@end

@interface SharedInfo : NSObject {
	NSString *sharedTitle;
	NSString *sharedUrl;
}
@property (nonatomic, copy) NSString *sharedTitle;
@property (nonatomic, copy) NSString *sharedUrl;
@end
