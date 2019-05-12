//
//  SNStoryWebViewController.m
//  sohunews
//
//  Created by chuanwenwang on 16/10/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryWebViewController.h"

#import "SHWebView.h"
#import "UIWebView+Utility.h"
#import "SHH5CommonApi.h"
#import "SHH5ChannelApi.h"
#import "SNConsts.h"

#import "SNNewsComment.h"
#import "SNArticle.h"
#import "SNUserUtility.h"
#import "SNSubscribeCenterService.h"
#import "SNCommentCacheManager.h"
#import "SNCommentEditorViewController.h"
#import "SNPostFollow.h"
#import "SNSearchWebViewController.h"
#import "SNRollingNewsPublicManager.h"

#import "SNStoryJSModel.h"//h5 评论
#import "SNStoryPageViewController.h"
#import "SNStoryCatelogController.h"
#import "UIImage+Story.h"
#import "SNStoryContanst.h"
#import "SNStoryUtility.h"
#import "SNStoryPage.h"
#import "StoryBookList.h"

#import "UIColor+StoryColor.h"
#import "SNStoryWaitingActivityView.h"
#import "SNNewsShareManager.h"
#import "SNLoadingImageAnimationView.h"
#import "SNStoryRequest.h"


#import "SNNewsLoginManager.h"


#define BackgroundViewLeftOffset                          0.0//H5背景左边距

#define UniversalWebViewLeftOffset                        0.0//webview的左边距
#define UniversalWebViewTopOffset                         20.0//webview的上边距
#define NavigationBarLineHeight                           2.0//导航分割线
#define NaviBarImageViewLeftOffset                        0.0//导航图片的左边距
#define NaviBarImageViewTopOffset                         ([[SNDevice sharedInstance] isPhoneX]?30:20)//导航图片的上边距
#define ShadowImageViewEdgeInsets                         (UIEdgeInsetsMake(2, 1, 2, 1))
#define ShadowImageViewLeftOffset                         0.0//导航图片阴影的左边距
#define ShadowImageViewTopOffset                          0.0//导航图片阴影的上边距
#define IconButtonLeftOffset                              14.0//导航按钮的左边距
#define TitleLabelLeftOffset                              0.0//导航标题的左边距
#define TitleLabelRightOffset                             28.0//导航标题的右边距
#define SearchBtnLeftOffset                               0.0//导航搜索按钮左边距
#define SearchBtnRightOffset                              10.0//导航搜索按钮右边距
#define SearchBtnWidth                                    40.0//导航搜索按钮宽
#define SearchBtnHeight                                   40.0//导航搜索按钮右高
#define SearchWebViewControllerLeftOffset                 0.0//搜索Controller的左边距
#define SearchWebViewControllerTopOffset                  0.0//搜索Controller的上边距


@interface SNStoryWebViewController ()<UIWebViewDelegate,UIScrollViewDelegate, SNCommentEditorPostDelegate,PostFollowDelegate,SNSearcbBarDelegate,SNStoryWebViewControllerDelegate>
{
    NSNumber *_newsType;
    
    UIView *_backView;
    SNLoadingImageAnimationView *_animationImageView;
    BOOL _isFullScreenMode;
    
    BOOL _isKeyShow;
    
    NSString* tempCommentTextFieldStr;//记录评论内容
}
@property (nonatomic, strong)SHWebView *universalWebView;

@property (nonatomic, strong)NSString         *newsOriginLink;
@property (nonatomic, strong)NSDictionary     *storyDic;

@property (nonatomic, retain)UIImageView *naviBarImageView;
@property (nonatomic, retain)UILabel *titleLabel;
@property (nonatomic, strong)UIButton * searchBtn;
@property (nonatomic, strong)UIButton * iconButton;
@property (nonatomic, strong) SNSearchWebViewController *searchWebViewController;

@property(nonatomic, strong) NSString *shareContent;
@property(nonatomic, strong) SNPostFollow* postFollow;
@property(nonatomic, strong) SNNewsComment *shareComment;
@property(nonatomic, strong) SNNewsComment *replyComment;
@property(nonatomic, strong) SNArticle *article;
@property(nonatomic, strong) SNNewsShareManager *shareManager;
@property(nonatomic, strong) SNStoryJSModel *jsModel;
@property(nonatomic, assign) NSTimeInterval lastShareTime;
@property(nonatomic, strong) SNCommentCacheManager *commentCacheManager;
@property(nonatomic, copy) NSString *notificationNews;
@property (nonatomic,strong) NSString* bookID;
@property (nonatomic,strong) NSDictionary *novelDetailDic;

@property (nonatomic,weak) SNCommentEditorViewController* commenteditor_vc;

@end

@implementation SNStoryWebViewController

-(void)dealloc{

    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
        _animationImageView = nil;
    }
    
    if (_article) {
        _article = nil;
    }
    
    if (self.universalWebView) {
        
        self.universalWebView.delegate = nil;
        self.universalWebView = nil;
    }
    if ([[self.storyDic objectForKey:@"novelH5PageType"] isEqualToString:@"1"]) {
        //进入详情页的入口较多，不知是否点击了加入书架的按钮，所以：只要进入了详情页，就通知书架刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:kNovelDidAddBookShelfNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPostCommentSuccessNotifiaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginFromArticleReplayCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
    self = [super initWithNavigatorURL:URL query:query];
    
    if (self) {
        
        JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        [jsKitStorageMange setItem:[NSNumber numberWithBool:[[SNThemeManager sharedThemeManager] isNightTheme]] forKey:@"settings_nightMode"];
        
        self.newsOriginLink = [query objectForKey:@"link"];
        self.storyDic = query;
        self.bookID = [self.storyDic objectForKey:@"novelId"]?[self.storyDic objectForKey:@"novelId"]:nil;
        self.notificationNews = [query objectForKey:@"notification"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replayCommentLoginSuccess) name:kLoginFromArticleReplayCommentNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postStoryCommentSucccess:)
                                                     name:kPostCommentSuccessNotifiaction
                                                   object:nil];
        [SNNotificationManager addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    }
    
    return self;
}

- (void)replayCommentLoginSuccess
{
    [self presentCommentEidtorController:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    
    //刷新小说的加入书架
    [self.universalWebView callJavaScript:[NSString stringWithFormat:@"resetUI('%@')",@"addBookShelf"] forKey:nil callBack:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUniversalWebView];
    
    _jsModel = [[SNStoryJSModel alloc] init];
    self.jsModel.storyVC = self;
    self.jsModel.queryDict = [NSMutableDictionary dictionaryWithDictionary:self.storyDic];
    [self.universalWebView setJsDelegate:self];
    [self.universalWebView registerJavascriptInterface:self.jsModel forName:@"newsApi"];
    
    if (self.bookID) {
        [self loadPostFollow];
    }
    
    StoryBookList *book = [StoryBookList fecthBookByBookId:self.bookID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //提前处理书籍信息数据
        if (!book) {
            NSDictionary * dic= @{@"oid" : self.bookID?self.bookID:@""};
            SNStoryDetailRequest *detailRequest = [[SNStoryDetailRequest alloc]initWithDictionary:dic];
            [detailRequest send:^(SNBaseRequest *request, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)responseObject;
                    self.novelDetailDic = [[dic objectForKey:@"data"] objectForKey:@"content"] ;
                }
                
            } failure:^(SNBaseRequest *request, NSError *error) {
                //
            }];
        }
        
        //小说热词搜索
        [SNUtility novelSearchHotWord:nil];
    });
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)initUniversalWebView {
    
    self.universalWebView = [[SHWebView alloc] init];
    self.universalWebView.opaque = NO;
    self.universalWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.universalWebView.scalesPageToFit = YES;
    self.universalWebView.backgroundColor = [UIColor clearColor];
    [self.universalWebView startObserveProgress];
    [self.view addSubview:self.universalWebView];
    
    if (@available(iOS 11.0, *)) {
        [self.universalWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    //novelH5PageType,0:发现更多页 1:详情页 2:详情页全部评论 3:小说运营标签
    NSString *novelH5PageType =[self.storyDic objectForKey:@"novelH5PageType"];
    NSString *novelId = [self.storyDic objectForKey:@"novelId"];
    
    if ([novelH5PageType isEqualToString:@"3"]){
        
        float universalWebViewTop = [SNDevice sharedInstance].isPhoneX?(0+20):0;
        self.universalWebView.frame = CGRectMake(UniversalWebViewLeftOffset, universalWebViewTop, View_Width, View_Height - [SNToolbar toolbarHeight] - universalWebViewTop);
        [self addToolbar];//小说运营标签没有导航部分
        
        NSString *tagId = [self.storyDic objectForKey:@"tagId"];
        NSString *name = [[self.storyDic objectForKey:@"name"]URLEncodedString];
        NSString *channelId = [self.storyDic objectForKey:@"channelId"];
        NSString *string = [SNStoryUtility getStoryRequestUrlWithStr:StoryH5Label(tagId, channelId, name)];
        [self viewShouldStartLoadWithURL:string];
        self.universalWebView.scrollView.bounces = NO;
        
    }else if ([novelH5PageType isEqualToString:@"2"]) {
        
        [self webForNavigationBarAndToolbar];
        
        NSString *string = [SNStoryUtility getStoryRequestUrlWithStr:[NSString stringWithFormat:@"%@novelId=%@",StoryDetailAllComments,novelId]];
        [self viewShouldStartLoadWithURL:string];
        
    } else if ([novelH5PageType isEqualToString:@"1"]){
        
        float universalWebViewTop = [SNDevice sharedInstance].isPhoneX?(UniversalWebViewTopOffset+20):UniversalWebViewTopOffset;
        //详情页没有导航部分
        self.universalWebView.frame = CGRectMake(UniversalWebViewLeftOffset, universalWebViewTop, View_Width, View_Height - [SNToolbar toolbarHeight]);
        
        UISwipeGestureRecognizer* swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeUp.delegate = self;
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:swipeUp];
        
        UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeDown.delegate = self;
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipeDown];
        
        NSString *string = [SNStoryUtility getStoryRequestUrlWithStr:StoryH5Detail(novelId)];
        [self viewShouldStartLoadWithURL:string];
        
    }else{
    
        [self webForNavigationBarAndToolbar];
        NSString *tagId = [self.storyDic objectForKey:@"tagId"];
        NSString *type = [self.storyDic objectForKey:@"type"];
        NSString *URL = [SNStoryUtility getStoryRequestUrlWithStr:StoryH5FoundMore(type,tagId)];
        [self viewShouldStartLoadWithURL:URL];
    }
    
    self.animationImageView.status = SNImageLoadingStatusLoading;
}

-(void)webForNavigationBarAndToolbar
{
    [self initNavigationBarAndToolbar];
    self.universalWebView.frame = CGRectMake(UniversalWebViewLeftOffset, CGRectGetMaxY(self.naviBarImageView.frame)+ NavigationBarLineHeight, View_Width, View_Height - kHeaderHeight - [SNToolbar toolbarHeight] -NavigationBarLineHeight - NaviBarImageViewTopOffset);
    [self addToolbar];
}

- (void)viewShouldStartLoadWithURL:(NSString *)storyUrl
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:storyUrl]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [self addCookieToRequeset:request url:request.URL];//添加cookie
    [self.universalWebView loadRequest:request];
}

- (void)initNavigationBarAndToolbar
{
    self.naviBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(NaviBarImageViewLeftOffset, NaviBarImageViewTopOffset, View_Width, kHeaderHeight)];
    self.naviBarImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.naviBarImageView];
    
    UIEdgeInsets edgeInsets = ShadowImageViewEdgeInsets;
    UIImage *image = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ShadowImageViewLeftOffset, ShadowImageViewTopOffset, kAppScreenWidth, image.size.height/2)];
    shadowImageView.top = self.naviBarImageView.height;
    shadowImageView.image = image;
    [self.naviBarImageView addSubview:shadowImageView];
    
    image = [UIImage imageNamed:@"icotitlebar_sohu_v5.png"];
    self.iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.iconButton.backgroundColor = [UIColor clearColor];
    self.iconButton.frame = CGRectMake(IconButtonLeftOffset, (self.naviBarImageView.height - image.size.height)/2, image.size.width, image.size.height);
    [self.iconButton setImage:image forState:UIControlStateNormal];
    [self.iconButton addTarget:self action:@selector(iconSohuAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.naviBarImageView addSubview:self.iconButton];
    
    float titleLabelHeight = self.naviBarImageView.height - self.iconButton.origin.y;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TitleLabelLeftOffset, (kHeaderHeight - titleLabelHeight)/2.0, kAppScreenWidth - self.iconButton.right - TitleLabelRightOffset, titleLabelHeight)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.left = self.iconButton.right + IconButtonLeftOffset;
    
    self.titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self.naviBarImageView addSubview:self.titleLabel];
    
    if ([[self.storyDic objectForKey:@"novelH5PageType"] isEqualToString:@"2"])
    {
        self.titleLabel.text = @"全部评论";
    }
    else
    {
        self.titleLabel.text = @"发现更多";
        UIImage *searchImage = [UIImage imageNamed:@"icopersonal_search_v5.png"];
        self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.searchBtn setImage:searchImage forState:UIControlStateNormal];
        self.searchBtn.frame = CGRectMake(SearchBtnLeftOffset, (self.naviBarImageView.height - SearchBtnHeight)/2.0, SearchBtnWidth, SearchBtnHeight);
        self.searchBtn.right = kAppScreenWidth - SearchBtnRightOffset;
        [self.searchBtn addTarget:self action:@selector(prepareSearch) forControlEvents:UIControlEventTouchUpInside];
        [self.naviBarImageView addSubview:self.searchBtn];
    }
}

- (void)iconSohuAction:(UIButton *)icon {
    //不管在那个tab，点击都回到新闻tab头条流，并刷新
    UIViewController* topController = [TTNavigator navigator].topViewController;
    [SNUtility popToTabViewController:topController];
    //tab切换到新闻
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    //栏目切换到焦点
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
    [SNNotificationManager postNotificationName:kSearchWebViewCancle object:nil];
    if ([SNUtility isFromChannelManagerViewOpened]) {
        [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
    }
}

- (void)prepareSearch {
    
    if (!self.searchWebViewController) {
        self.searchWebViewController = [[SNSearchWebViewController alloc] init];
    }
    
    _searchWebViewController.refertype = SNSearchReferNovel;
    _searchWebViewController.searchBarDelegate = self;
    _searchWebViewController.view.frame = CGRectMake(SearchWebViewControllerLeftOffset, SearchWebViewControllerTopOffset, kAppScreenWidth, kAppScreenHeight);
    [self.view addSubview:_searchWebViewController.view];
    self.toolbarView.leftButton.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _searchWebViewController.view.frame = CGRectMake(SearchWebViewControllerLeftOffset, SearchWebViewControllerTopOffset, kAppScreenWidth, kAppScreenHeight);
    } completion:^(BOOL finished) {
        self.toolbarView.leftButton.enabled = YES;
        [_searchWebViewController beginSearchAndreloadHotWords];
    }];
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"objType=fic_search_clk&fromObjType=more&statType=clk&bookId=%@", self.bookID]];
}
#pragma mark -- SNSearcbBarDelegate
- (void)searchBarEndSearch {
    [UIView animateWithDuration:0.25 animations:^{
        self.searchBtn.right = kAppScreenWidth - SearchBtnRightOffset;
        self.iconButton.alpha = 1;
        self.titleLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

    if (self.searchWebViewController) {
        [self.searchWebViewController.view removeFromSuperview];
        _searchWebViewController = nil;
    }
}

- (void)searchWebViewLoadView {

}

- (void)onBack:(id)sender {
    [SNStoryUtility popViewControllerAnimated:YES];
}

// 给所有网页访问增加用户中心cookie
- (void)addCookieToRequeset:(NSMutableURLRequest*)request url:(NSURL*)url {
    if (![SNStoryUtility isLogin]) {
        return;
    }
    NSString *cookieValue = [SNStoryUtility getCookie];
    if(cookieValue) {
        NSString *cookieHeader = nil;
        if (url.absoluteString.length == 0 || [url isEqual:[NSNull null]] || [url.absoluteString isEqualToString:@"about:blank"]) {
            return;
        }
        NSArray* cookiess = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        
        if([cookiess count] > 0) {
            
            for(NSHTTPCookie *cookie in cookiess) {
                if(!cookieHeader) {
                    cookieHeader = [NSString stringWithFormat:@"%@=%@",[cookie name],[cookie value]];
                }
                else {
                    cookieHeader = [NSString stringWithFormat:@"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
                }
            }
        }
        
        //append cookie
        if (!cookieHeader) {
            cookieHeader = [NSString stringWithFormat:@"%@",cookieValue];
        }
        else {
            cookieHeader = [NSString stringWithFormat:@"%@; %@",cookieHeader,cookieValue];
        }
        
        //creat a new cookie
        [request setValue: cookieHeader forHTTPHeaderField:@"Cookie" ];
    }
}

#pragma mark UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    if ([SNUtility isProtocolV2:urlString]) {
        
        if ([urlString hasPrefix:@"js:"]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:@"js:" withString:@""];
        }
        
        if ([urlString hasPrefix:kProtocolStoryNovelDetail]) {//阅读详情页
            
            [SNStoryUtility openProtocolUrl:urlString context:nil];
            return NO;
            
        }
        else if ([urlString hasPrefix:kProtocolStoryReadChapter])//阅读某一章节
        {
            NSDictionary *dic = [SNUtility parseURLParam:urlString schema:kProtocolStoryReadChapter];
            SNStoryPageViewController *pageController = [SNStoryPageViewController new];
            NSString *novelId = [dic objectForKey:@"novelId"];
            pageController.novelId = novelId;
            pageController.chapterIndex = 0;
            pageController.chapterId = [[dic objectForKey:@"chapterIndex"]integerValue];
            pageController.pageType = StoryPageFromH5Detail;
            pageController.delegate = self;
            [SNStoryUtility pushViewController:pageController animated:YES];
            return NO;
        }
        else if ([urlString hasPrefix:kProtocolStoryChapterList])//小说的章节列表
        {
            NSDictionary *dic = [SNUtility parseURLParam:urlString schema:kProtocolStoryChapterList];
            SNStoryCatelogController *catelogController = [SNStoryCatelogController new];
            catelogController.catelogType = StoryCateLogFromH5Detail;
            catelogController.novelId = [dic objectForKey:@"novelId"];
            [SNStoryUtility pushViewController:catelogController animated:YES];
            return NO;
        }
        else if([urlString hasPrefix:kProtocolStoryNovelDetailAllComments])
        {
            [SNStoryUtility openProtocolUrl:urlString context:nil];
            return NO;
        }
    }
    
    if ([urlString isEqualToString:@"about:blank"]) {
        
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if (NO == webView.isLoading) {
        NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if (complete) {
            //[self stopProgress];
            [self performSelector:@selector(stopProgress) withObject:nil afterDelay:(0.5f)];
        }
    }
}

#pragma mark -操作栏隐藏/显示功能 begin
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //操作栏未显示时无需发通知
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification object:nil userInfo:nil];
    }
    
    if (_isFullScreenMode) {
        BOOL bBottomEx = [self scorllViewToBottomEx:scrollView];
        if (bBottomEx) // 从底部向上拖拽较长距离
        {
            [self exitFullScreenMode];
        }
    }
}

// scrollView已滚动到底部，又继续向上拖拽一定距离
- (BOOL)scorllViewToBottomEx:(UIScrollView*)scrollView
{
    float Offset = scrollView.contentOffset.y +TTApplicationFrame().size.height;
    float content = scrollView.contentSize.height;
    return  (Offset > (content + 70) ? YES:NO);
}

-(void)addBookShelfInPageView
{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已加入书架" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)gesture
{
    
    if(gesture.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if(self.universalWebView.scrollView.contentOffset.y + self.universalWebView.frame.size.height >= self.universalWebView.scrollView.contentSize.height)
        {
            
        }
        if([SNPreference sharedInstance].autoFullscreenMode)
        {
            if(!_isFullScreenMode)
            {
                [self enterFullScreenMode];
            }
        }
    }
    else if(gesture.direction == UISwipeGestureRecognizerDirectionDown)
    {
        if([SNPreference sharedInstance].autoFullscreenMode)
        {
            if(_isFullScreenMode)
            {
                [self exitFullScreenMode];
            }
        }
    }
    else if(gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (_isFullScreenMode)
        {
            [self exitFullScreenMode];
        }
        [_postFollow changeUserName];
    }
}

#pragma mark full screen
- (void)enterFullScreenMode
{
    _isFullScreenMode = YES;
    CGFloat height = kAppScreenHeight-kSystemBarHeight;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.universalWebView.height = height;
        self.universalWebView.scrollView.contentInset = UIEdgeInsetsZero;
        
        [self.postFollow show:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)exitFullScreenMode
{
    _isFullScreenMode = NO;
    CGFloat height = kAppScreenHeight-kSystemBarHeight-kToolbarViewTop;
    [UIView animateWithDuration:0.8 animations:^{
        self.universalWebView.height = height;
        self.universalWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, [SNToolbar toolbarHeight], 0);
        [self.postFollow show:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark -操作栏隐藏/显示功能 end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 评论分享
- (void)shareContent:(NSString *)content
{
    
    /*
     //因H5评论没有相应的js交互，所以评论分享现改为小说详情页的分享
     if (content) {
        SNNewsComment *comment = [[SNNewsComment alloc] init];
        comment.content = content;
        [self shareComment:comment];
    }*/
    [self shareAction];
}

#pragma mark - copy
//copy
-(void)copyComment:(NSString *)content
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [content trim];
}

- (void)setCommentNum:(NSString *)count
{
    if (count.length > 0 && [count intValue] > 0) {
        [_postFollow setCommentNum:count];
    } else {
        [_postFollow setCommentNum:@"0"];
    }
}

-(void)emptyCommentListClicked
{
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=comment&bookId=%@", self.bookID]];

    [self postFollowEditor];
}

#pragma mark - PostComment
- (void)postStoryCommentSucccess:(NSNotification *)notification
{
    NewsCommentItem *newsCommentItem = [notification object];
    if ([self.bookID isEqualToString:newsCommentItem.newsId]) {
        NSDictionary *dict = [self creatNewsCommentItem:newsCommentItem];
        if (dict) {
            NSString *jsonStr = [self dictionaryToJson:dict];
            [_universalWebView callJavaScript:[NSString stringWithFormat:@"commentAddNew(%@)", jsonStr] forKey:nil callBack:nil];
        }
    }
}

- (NSDictionary *)creatNewsCommentItem:(NewsCommentItem *)newsCommentItem
{
    if (newsCommentItem) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:newsCommentItem.author forKey:@"authorName"];
        [dict setObject:newsCommentItem.ctime forKey:@"longTime"];
        [dict setObject:@"刚刚" forKey:@"formatTime"];
        [dict setObject:newsCommentItem.content forKey:@"content"];
        [dict setObject:newsCommentItem.digNum ? newsCommentItem.digNum : @"" forKey:@"digNum"];
        [dict setObject:@"" forKey:@"resource"];
        [dict setObject:@"" forKey:@"signList"];
        [dict setObject:@"" forKey:@"tag"];
        [dict setObject:@"" forKey:@"emotion"];
        [dict setObject:@"0" forKey:@"allCount"];
        [dict setObject:@"" forKey:@"authorCity"];
        [dict setObject:@"" forKey:@"authorCityAll"];
        if ([newsCommentItem.type isEqualToString:@"reply"]) {
            NSMutableDictionary *contentDic = (NSMutableDictionary *)[self dictionaryWithJsonString:newsCommentItem.content];
            if ([contentDic objectForKey:@"imageBig"] && [[contentDic objectForKey:@"imageBig"] length] > 0) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:[contentDic objectForKey:@"imageBig"]];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                filePath = [@"jskitfile:" stringByAppendingString:filePath];
                [contentDic setObject:filePath forKey:@"imageBig"];
                [contentDic setObject:filePath forKey:@"imageSmall"];
            } else if ([contentDic objectForKey:@"imageSmall"] && [[contentDic objectForKey:@"imageSmall"] length] > 0) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:[contentDic objectForKey:@"imageSmall"]];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                [contentDic setObject:filePath forKey:@"imageBig"];
                [contentDic setObject:filePath forKey:@"imageSmall"];
            }
            
            NSString *content;
            if ([contentDic objectForKey:@"content"]) {
                [contentDic setObject:[contentDic objectForKey:@"content"] forKey:@"content"];
            } else {
                [contentDic setObject:@"" forKey:@"content"];
            }
            
            [contentDic setObject:newsCommentItem.pid forKey:@"pid"];
            [contentDic setObject:@"0" forKey:@"commentId"];
            NSString *jsonStr = [self dictionaryToJson:contentDic];
            [dict setObject:jsonStr forKey:@"mFloorData"];
        } else {
            NSMutableDictionary *floorDict = [NSMutableDictionary dictionary];
            [floorDict setObject:newsCommentItem.content forKey:@"content"];
            [floorDict setObject:newsCommentItem.author forKey:@"author"];
            [floorDict setObject:@"" forKey:@"gen"];
            [floorDict setObject:newsCommentItem.pid forKey:@"pid"];
            [floorDict setObject:@"" forKey:@"egHomePage"];
            if (newsCommentItem.imagePath) {
                NSString *fileName = [[TTURLCache sharedCache] keyForURL:newsCommentItem.imagePath];
                NSString *filePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:fileName];
                filePath = [@"jskitfile:" stringByAppendingString:filePath];
                [floorDict setObject:filePath forKey:@"imageSmall"];
                [floorDict setObject:filePath forKey:@"imageBig"];
            } else {
                [floorDict setObject:@"" forKey:@"imageSmall"];
                [floorDict setObject:@"" forKey:@"imageBig"];
            }
            [floorDict setObject:newsCommentItem.audioDuration ? newsCommentItem.audioDuration : @"" forKey:@"audLen"];
            [floorDict setObject:newsCommentItem.audioPath ? newsCommentItem.audioPath : @"" forKey:@"audUrl"];
            [floorDict setObject:newsCommentItem.authorImage forKey:@"authorimg"];
            [floorDict setObject:newsCommentItem.digNum ? newsCommentItem.digNum : @"" forKey:@"digNum"];
            [floorDict setObject:newsCommentItem.ctime forKey:@"ctime"];
            [floorDict setObject:@"0" forKey:@"commentId"];
            [floorDict setObject:@"" forKey:@"replyNum"];
            [floorDict setObject:@"" forKey:@"city"];
            [floorDict setObject:@"" forKey:@"floors"];
            NSString *jsonStr = [self dictionaryToJson:floorDict];
            [dict setObject:jsonStr forKey:@"mFloorData"];
        }
        return (NSDictionary *)dict;
    }
    return nil;
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    if (!dic) {
        return @"";
    }
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    return dic;
}

#pragma mark - 评论间 半屏登录

- (void)commentLogin:(id)sender{
    [SNNewsLoginManager halfLoginData:nil Successed:^(NSDictionary *info) {
        [self presentCommentEidtor];
        [self performSelector:@selector(autoPostComment:) withObject:sender afterDelay:0.25];
    } Failed:^(NSDictionary *errorDic) {
        if (sender && [sender isKindOfClass:[SNSendCommentObject class]]) {
            SNSendCommentObject* obj = (SNSendCommentObject*)sender;
            tempCommentTextFieldStr = obj.cmtText;
        }
        [self presentCommentEidtorController:NO];
    }];
}

- (void)presentCommentEidtor
{
    NSString *controlStaus = self.article.comtStatus;
    NSString *controlHint  =  self.article.comtHint;
    if (!_commentCacheManager) {
        self.commentCacheManager = [[SNCommentCacheManager alloc] init];
    }
    
    if (![SNUtility needCommentControlTip:controlStaus
                            currentStatus:kCommentStsForbidAll
                                      tip:controlHint
                                 isBottom:YES]) {
        
        NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextAndEmoticon];
        NSNumber *viewType = [NSNumber numberWithInteger:SNComment];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setObject:toolbarType forKey:kCommentToolBarType];
        [dic setObject:viewType forKey:kEditorKeyViewType];
        if (controlStaus.length > 0) {
            [dic setObject:controlStaus forKey:kEditorKeyComtStatus];
        }
        if (controlHint.length > 0) {
            [dic setObject:controlHint forKey:kEditorKeyComtHint];
        }
        
        //发评论数据结构
        SNSendCommentObject *cmtObj = [[SNSendCommentObject alloc] init];
        // 评论来源
        cmtObj.busiCode = @"8";
        cmtObj.newsId = self.bookID;
        cmtObj.comtProp = @"1";
        
        //回复评论数据结构
        int replyTarget = 1;
        
        cmtObj.replyComment = [SNNewsComment createReplyComment:_replyComment replyType:replyTarget];
        //缓存评论
        [self.commentCacheManager setCacheValue:cmtObj];
        
        if (cmtObj) {
            [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
        }
        
        [dic setObject:@"1" forKey:@"noshow"];
        SNCommentEditorViewController *commentEditorViewController = [[SNCommentEditorViewController alloc] initWithParams:dic];
        commentEditorViewController.isNovelComment = YES;
        commentEditorViewController.sendDelegateController= self;
        self.commenteditor_vc = commentEditorViewController;
        
        [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:commentEditorViewController animated:NO];
        
        [_universalWebView callJavaScript:@"cmtToolHide()" forKey:nil callBack:nil];
        
        dic = nil;
    }
}

- (void)autoPostComment:(id)sender{
    //contentsWillPost
    [self.commenteditor_vc autoPostComment:sender];
    [self keyboardDidHide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.commenteditor_vc popViewController];
    });
}

#pragma mark - 回复
- (void)replyComment:(NSDictionary *)comment
{
    _replyComment = nil;
    _replyComment = [self jsonStringToComment:comment topicId:nil];
    if (![SNStoryUtility isLogin]) {
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:SNGuideRegisterTypeReplayComment], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
        //[SNUtility openLoginViewWithDict:dict];
        
        
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//小说回复评论
            [self presentCommentEidtorController:NO];
        } Failed:nil];
        
//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//        [SNStoryUtility openUrlPath:@"tt://loginRegister" applyQuery:[NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:SNGuideRegisterTypeReplayComment], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil] applyAnimated:YES];
        [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
    }
    else {
        
//        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//        if (!userInfoEx.isRealName) {
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
//            [SNStoryUtility openUrlPath:@"tt://mobileNumBindLogin" applyQuery:dic applyAnimated:YES];
//        } else {
            [self presentCommentEidtorController:NO];
//        }
    }
}

-(void)loginSuccess
{
    return;
}

- (SNNewsComment *)jsonStringToComment:(NSDictionary *)commentDic topicId:(NSString *)topicId {
    SNNewsComment *comment = [[SNNewsComment alloc] init];
    
    comment.commentId = [commentDic stringValueForKey:kCommentId defaultValue:nil];
    comment.author    = [commentDic objectForKey:kAuthor];
    comment.city      = [commentDic objectForKey:kCity];
    comment.content   = [commentDic stringValueForKey:kContent defaultValue:@""];
    comment.replyNum  = [commentDic objectForKey:kReplyNum];
    comment.digNum    = [NSString stringWithFormat:@"%@",[commentDic objectForKey:kDigNum]];
    comment.from      = [[commentDic objectForKey:kFrom] stringValue];
    comment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
    comment.passport  = [commentDic objectForKey:kPassport];
    comment.linkStyle = [commentDic objectForKey:kLinkStyle];
    comment.spaceLink = [commentDic objectForKey:kSpaceLink];
    comment.pid       = [commentDic stringValueForKey:kPid defaultValue:nil];
    comment.authorimg = [commentDic objectForKey:kAuthorimg];
    comment.newsTitle = [commentDic objectForKey:kCommentNewsTitle];
    comment.newsLink  = [commentDic objectForKey:kCommentNewsLink];
    comment.commentImage = [commentDic objectForKey:kCommentImage];
    comment.commentImageSmall = [commentDic objectForKey:kCommentImageSmall];
    comment.commentImageBig = [commentDic objectForKey:kCommentImageBig];
    comment.commentAudLen = [commentDic intValueForKey:kCommentAudLen defaultValue:0];
    comment.commentAudUrl = [commentDic objectForKey:kCommentAudUrl];
    comment.userComtId = [commentDic objectForKey:kCommentUserComtId];
    comment.cmtStatus    = [commentDic stringValueForKey:kCmtStatus defaultValue:nil];
    comment.cmtHint      = [commentDic stringValueForKey:kCmtHint defaultValue:nil];
    comment.busiCode     = [commentDic stringValueForKey:kCmtBusiCode defaultValue:nil];
    //回复我的中通过二代类型协议判断busiCode
    if (comment.newsLink.length > 0) {
        NSDictionary *linkDic = [SNUtility parseLinkParams:comment.newsLink];
        if (NSNotFound != [comment.newsLink rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kLiveIdKey defaultValue:nil];
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kSNNewsId defaultValue:nil];
            comment.busiCode = @"2";
        }
        else if (NSNotFound != [comment.newsLink rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location) {
            comment.newsId = [linkDic stringValueForKey:kGid defaultValue:nil];
            comment.busiCode = @"3";
        }
    }
    comment.attachList   = commentDic[kCmtAttachList];
    if (topicId) {
        comment.topicId   = topicId;
    } else  {
        comment.topicId   = [commentDic objectForKey:kTopicId];
    }
    
    id floorsData = [commentDic objectForKey:kFloors];
    if ([floorsData isKindOfClass:[NSArray class]]) {
        comment.floors = [NSMutableArray array];
        for (NSDictionary *floorDic in floorsData) {
            if ([floorDic isKindOfClass:[NSDictionary class]]) {
                SNNewsComment *floorComment = [[SNNewsComment alloc] init];
                floorComment.commentId = [floorDic stringValueForKey:kCommentId defaultValue:nil];
                floorComment.author    = [floorDic objectForKey:kAuthor];
                floorComment.passport  = [floorDic objectForKey:kPassport];
                floorComment.spaceLink = [floorDic objectForKey:kSpaceLink];
                floorComment.pid       = [floorDic stringValueForKey:kPid defaultValue:nil];
                floorComment.linkStyle = [floorDic objectForKey:kLinkStyle];
                floorComment.city      = [floorDic objectForKey:kCity];
                floorComment.content   = [floorDic stringValueForKey:kContent defaultValue:@""];
                floorComment.replyNum  = [floorDic objectForKey:kReplyNum];
                NSNumber *dNum         = [floorDic objectForKey:kDigNum];
                floorComment.digNum    = [dNum stringValue];
                floorComment.from      = [floorDic objectForKey:kFrom];
                floorComment.ctime     = [commentDic stringValueForKey:kCtime defaultValue:nil];
                floorComment.commentImage = [floorDic objectForKey:kCommentImage];
                floorComment.commentImageBig= [floorDic objectForKey:kCommentImageBig];
                floorComment.commentImageSmall = [floorDic objectForKey:kCommentImageSmall];
                floorComment.commentAudLen = [floorDic intValueForKey:kCommentAudLen defaultValue:0];
                floorComment.commentAudUrl = [floorDic objectForKey:kCommentAudUrl];
                floorComment.userComtId = [floorDic objectForKey:kCommentUserComtId];
                if (topicId) {
                    floorComment.topicId   = topicId;
                } else  {
                    floorComment.topicId   = [floorDic objectForKey:kTopicId];
                }
                
                [comment.floors addObject:floorComment];
            }
        }
    }
    return comment;
}

#pragma mark -

- (void)enterUserCenter:(id)jsonData
{
    [SNUtility shouldUseSpreadAnimation:NO];
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if(now - _lastShareTime < 1)
    {
        return;
    }
    _lastShareTime = now;
    
    NSDictionary *dict = (NSDictionary *)jsonData;
    
    NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
    
    [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Article_CommentUser] forKey:kRefer];
    NSString *passport;
    if ([[dict objectForKey:@"commentId"] integerValue] == 0) {
        passport = [SNStoryUtility getUserId];
    } else {
        passport =[dict objectForKey:@"passport"];
    }
    
    BOOL gotoSpace = [SNUserUtility openUserWithPassport:passport
                                               spaceLink:@""
                                               linkStyle:@"" pid:[dict objectForKey:@"pid"]
                                                    push:@"0" refer:referInfo];
    if (!gotoSpace) {
        
    }
}


- (void)keyboardDidHide
{
    _isKeyShow = NO;
}

- (void)postFollowEditor
{
    if (_isKeyShow) { //键盘完全收起才能再次点击评论
        return;
    }
    _replyComment = nil;
    [self presentCommentEidtorController:NO];
}

- (void)presentCommentEidtorController:(BOOL)isEmoticon
{
    NSString *controlStaus = self.article.comtStatus;
    NSString *controlHint  =  self.article.comtHint;
    if (!_commentCacheManager) {
        self.commentCacheManager = [[SNCommentCacheManager alloc] init];
    }
    
    if (![SNUtility needCommentControlTip:controlStaus
                            currentStatus:kCommentStsForbidAll
                                      tip:controlHint
                                 isBottom:YES]) {
        
        NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextAndEmoticon];
        NSNumber *viewType = [NSNumber numberWithInteger:SNComment];
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        [dic setObject:toolbarType forKey:kCommentToolBarType];
        [dic setObject:viewType forKey:kEditorKeyViewType];
        if (controlStaus.length > 0) {
            [dic setObject:controlStaus forKey:kEditorKeyComtStatus];
        }
        if (controlHint.length > 0) {
            [dic setObject:controlHint forKey:kEditorKeyComtHint];
        }
        
        //发评论数据结构
        SNSendCommentObject *cmtObj = [[SNSendCommentObject alloc] init];
        // 评论来源
        cmtObj.busiCode = @"8";
        cmtObj.newsId = self.bookID;
        cmtObj.comtProp = @"1";
        
        //回复评论数据结构
        int replyTarget = 1;
        
        cmtObj.replyComment = [SNNewsComment createReplyComment:_replyComment replyType:replyTarget];
        //缓存评论
        [self.commentCacheManager setCacheValue:cmtObj];
        
        if (cmtObj) {
            [dic setObject:cmtObj forKey:kEditorKeySendCmtObj];
        }
        [dic setObject:@(isEmoticon) forKey:@"isEmoticon"];
        if (tempCommentTextFieldStr && tempCommentTextFieldStr.length>0) {
            [dic setObject:tempCommentTextFieldStr forKey:@"textfield.text"];
        }
        SNCommentEditorViewController *commentEditorViewController = [[SNCommentEditorViewController alloc] initWithParams:dic];
        commentEditorViewController.isNovelComment = YES;
        commentEditorViewController.sendDelegateController= self;
        self.commenteditor_vc = commentEditorViewController;
        
        [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:commentEditorViewController animated:NO];
        _isKeyShow = !isEmoticon;
        [_universalWebView callJavaScript:@"cmtToolHide()" forKey:nil callBack:nil];
        
        dic = nil;
    }
}

#pragma mark PostFollowDelegate
- (void)postFollow:(SNPostFollow*)postFollow andButtonTag:(int)iTag
{
    switch (iTag)
    {
        case 1: {
            if ([self.notificationNews isEqualToString:@"notify"]) {
                _postFollow.isFromPushNews = YES;
            }
            
            [_postFollow changeUserName];
            [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=comment&bookId=%@", self.bookID]];
            break;
        }
        case 2: {
            
            /* 不让跳入全部评论页了
             if ([[self.storyDic objectForKey:@"novelH5PageType"] isEqualToString:@"1"]) {
                
                NSString *string = [NSString stringWithFormat:@"%@novelId=%@",ProtocolStoryNovelDetailAllComments,self.bookID];
                [SNStoryUtility openProtocolUrl:string context:nil];
            }
            else if([[self.storyDic objectForKey:@"novelH5PageType"] isEqualToString:@"2"])
            {
                [self commentNumBtnClicked];
            }*/
            [self commentNumBtnClicked];
            break;
        }
        case 3: {
            [self shareAction];
            break;
        }
        default:
            break;
    }
}

// 调起评论表情键盘
- (void)h5PostFollow:(SNPostFollow *)postFollow emojiBtnClick:(UIButton *)emojiBtn {
    [self presentCommentEidtorController:YES];
}

- (void)commentNumBtnClicked
{
    [self.universalWebView callJavaScript:@"viewComment(0)" forKey:nil callBack:nil];
}

//正文分享
- (void)shareAction {
    
    NSString *title = [self.novelDetailDic objectForKey:@"title"];
    NSString *bookImg = [self.novelDetailDic objectForKey:@"img"];
    NSString *content = @"来搜狐新闻和我一起读小说";
    NSString *shareUrl = [[SNStoryUtility getStoryRequestUrlWithStr:StoryDetailShare(@"book",self.bookID)]trim];
    
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    [shareDic setObject:title?title:@"" forKey:@"shareTitle"];
    [shareDic setObject:content forKey:@"shareDescription"];
    [shareDic setObject:shareUrl?shareUrl:@"" forKey:@"shareUrl"];
    [shareDic setObject:@"" forKey:@"link"];
    [shareDic setObject:@"web" forKey:@"contentType"];
    [shareDic setObject:bookImg?bookImg:@"" forKey:@"shareImage"];
    [shareDic setObject:@"50" forKey:@"sourceType"];
    
    [SNStoryUtility shareActionWith:shareDic];
}


- (void)loadPostFollow
{
    if (!_postFollow) {
        NSString *strTitle = NSLocalizedString(@"ComposeComment", nil);
        SNPostFollow *postFollow = [[SNPostFollow alloc] init];
        self.postFollow = postFollow;
        _postFollow.bookID = self.bookID;
        _postFollow._strPostOrComment = strTitle;
        _postFollow._viewController = self;
        _postFollow._delegate = self;
        [_postFollow createWithType:SNPostFollowTypeBackAndCommentAndShare];
        [_postFollow setShareBtnEnabel:YES];
    }
}


- (BOOL)checkIfHadBeenMyFavourite
{
    return NO;
}

#pragma mark - loadingImageAnimationView
- (SNLoadingImageAnimationView *)animationImageView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.view.frame];
        _backView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self.view addSubview:_backView];
    }
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = _backView;
    }
    
    return _animationImageView;
}

- (void)stopProgress
{
    self.animationImageView.status = SNImageLoadingStatusStopped;
    _backView.hidden = YES;
}

@end
