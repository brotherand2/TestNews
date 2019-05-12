//
//  SNBaseWebViewController.h
//  sohunews
//
//  Created by yangln on 2016/12/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"
#import "SNProgressBar.h"
#import "UIWebView+Utility.h"
#import "SNUserManager.h"
#import "SNPopoverView.h"
#import "SNTripletsLoadingView.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNRollingNewsPublicManager.h"
#import "SHUrlMaping.h"
#import "SHWebView.h"
#import "SHH5ChannelApi.h"
#import "SNChannelScrollTabBarDataSource.h"
#import "SNDBManager.h"
#import "SHHomePageArticleViewJSModel.h"
#import "SNRedPacketManager.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNAPOpenApiHelper.h"
#import "SNSubscribeCenterService.h"
#import "SNNewsGallerySlidershowController.h"
#import "SHH5CommonApi.h"
#import "SNFeedBackApi.h"
#import "SNNewsReport.h"
#import "SNPopOverMenu.h"
#import "SNNewAlertView.h"
#import "SNDelMyStockRequest.h"
#import "SNAddMyStockRequest.h"
#import "SNIsMyStockRequest.h"
#import "SNWebViewManager.h"
#import <WebKit/WebKit.h>

@class SNWKWebView;

#define kToolBarButtonCount 4
#define kToolBarButtonTag 100000
#define kAddedButtonRightDistance 14.0
#define kAddedButtonWidth 100.0
#define kAddedTag 100001
#define kUnAddedTag 100002

@interface SNBaseWebViewController : SNBaseViewController <UIWebViewDelegate,WKNavigationDelegate , WKUIDelegate, SNTripletsLoadingViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate,SKStoreProductViewControllerDelegate>

@property (nonatomic, assign) UniversalWebViewType webViewType;
@property (nonatomic, strong) NSString *newsTitle;
@property (nonatomic, strong) NSString *newsLink;
@property (nonatomic, strong) NSString *newsOriginLink;
@property (nonatomic, strong) NSString *photoLink;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelCategoryId;
@property (nonatomic, strong) NSString *termID;
@property (nonatomic, strong) SNToolbar *toolBar;
@property (nonatomic, strong) SNProgressBar *progressBar;
@property (nonatomic, strong) SHWebView *universalWebView;
@property (nonatomic, strong) SNWKWebView *universalWKWebView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureUp;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureDown;
@property (nonatomic, strong) SNPopoverView *popoverView;
@property (nonatomic, strong) UIImageView *naviBarImageView;
@property (nonatomic, strong) SNTripletsLoadingView *loadingView;
@property (nonatomic, assign) BOOL isRedirect;
@property (nonatomic, assign) CGFloat scrollViewOffsetY;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *refer; //引用来源 newsId termId vid ...
@property (nonatomic, strong) NSString *referId; //引用ID
@property (nonatomic, assign) BOOL landscape; //横屏
@property (nonatomic, assign) BOOL isNativeH5; //是否是本地的H5页面
@property (nonatomic, assign) BOOL showTitleBar;
@property (nonatomic, assign) BOOL forceBack; //点击回退按钮是否强制关闭浏览器
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSString *predownloadKey;
@property (nonatomic, strong) NSURL *predownloadLocalUrl;
@property (nonatomic, strong) UIView *nightModeView;
@property (nonatomic, strong) SKStoreProductViewController *sKStoreProductViewController;
@property (nonatomic, assign) CGFloat pinchScale;
@property (nonatomic, strong) UIButton *addedButton;//添加到自选股、频道
@property (nonatomic, strong) NSString *stockCode;//股票编码
@property (nonatomic, strong) NSString *stockFrom;//来源
@property (nonatomic, strong) NSString *packId;//红包id

@property (nonatomic, strong) SNChannelScrollTabBarDataSource *channelDataSource;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIButton *shareButton;//分享按钮 用于非可分享页面隐藏分享按钮
@property (nonatomic, assign) BOOL shouldHideShareButton;
@property (nonatomic, strong) SNNewsGallerySlidershowController * photoCtl;//图集浏览模式

@property (nonatomic, assign) BOOL clickActivityPage;
@property (nonatomic, assign) BOOL isWebviewLoad;
@property (nonatomic, assign) BOOL isWebviewRefresh;
@property (nonatomic, assign) BOOL isShowReport;
@property (nonatomic, assign) BOOL isShowMask;
@property (nonatomic, assign) BOOL isMPHomeLink;
@property (nonatomic, assign) BOOL isClickBack;
@property (nonatomic, assign) BOOL isClickHistoryNews;
@property (nonatomic, assign) BOOL isSohunewsclient_h5_title;
@property (nonatomic, assign) BOOL isUse_h5_title;
@property (nonatomic, assign) BOOL statusHidden;

//频道添加
- (void)addSubscribeChannelViewWithID:(NSString *)channelID;
//频道删除
- (void)deleteSubscribeChannelViewWithID:(NSString *)channelID;
//返回上一级
- (void)popToPreController;
//返回当前选中tab的root页
- (void)popToTabShowViewController;

//分享到支付宝
- (void)shareToAlipay:(SNActionMenuOption)actionMenuOption shareUrl:(NSString *)shareUrl;
//处理二代协议
- (BOOL)processProtocolV2:(NSString *)urlString navigationType:(UIWebViewNavigationType)navigationType;
//处理特殊域名，转化为二代协议
- (BOOL)processSpecialDomain:(NSString *)urlString navigationType:(UIWebViewNavigationType)navigationType;

- (BOOL)processSpecialDomain:(NSString *)urlString WKNavigationType:(WKNavigationType)navigationType;
//端内打开第三方app
- (BOOL)canOpenThirdPartyApp:(NSString *)urlString;
//搜狐域名种cookie，方便h5获取登录信息、端内参数
- (BOOL)needAddCookieForUrlString:(NSString *)urlString request:(NSURLRequest *)request;
//检测是否为h5模板
- (BOOL)checkNativeURL:(NSURL *)URL;
//关闭webView
- (void)webViewClose;
//重置webview位置大小
- (void)resetWebviewWithShowTitleBar:(BOOL)show isSwipe:(BOOL)isSwipe;
/**
 JSKit调用
 */
- (void)showTitleBar:(BOOL)show animated:(BOOL)animated;

- (void)showShareBtn:(BOOL)show;

- (void)updateTitle:(NSString *)title;

- (void)forceCloseBrowser:(BOOL)force;

- (void)showMaskView:(BOOL)show;

- (void)closeBrowserImmediately;

- (void)webViewGoBack;

- (void)webViewGoBackInToolBar;

- (void)showReportBtn:(BOOL)show;
//段子，暂无
- (void)clickImage:(NSString *)imageUrl title:(NSString *)title point:(CGPoint)point;
//红包提现成功回调
- (void)cashOutCallback:(BOOL)isSuccess withRedPacketId:(NSString*)redPacketId withDrawTime:(NSString*)drawTime;
//检查登录成功和绑定回调，如果登录并绑定成功，isOK = true, 否则 isOK = false
- (void)checkLoginAndBindCallback:(BOOL)isSuccess url:(NSString *)url;

- (void)openFacePreferenceSetting:(NSString*)gender;//用户画像 唤起用户偏好设置

- (void)clickFaceInfoLayoutFaceType:(NSNumber *)faceType GenderStatus:(NSNumber *)genderStatus Gender:(NSString *)gender;

//截屏分享 wangshun 2017.9.9
- (NSDictionary*)getShareData;

/**
 end
 */

@end
