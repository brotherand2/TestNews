
//
//  SNSharePostController.m
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShareWithCommentController.h"

#import "UIColor+ColorUtils.h"
#import "SNShareListItemCell.h"
#import "SNShareClipImageButton.h"
#import "UIImage+Utility.h"

#import "SNThemeManager.h"
#import "NSDictionaryExtend.h"
#import "SNTextView.h"
#import "CacheObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNShareConfigs.h"

#import "SNRollingNewsPublicManager.h"
#import "SNDevice.h"
#import "SNNewAlertView.h"

#define kAlertViewTagCancel     0
#define kAlertViewTagUnbingding 1

#define kLeftRightBlank         10
#define kImageViewRightBlank    8
#define kImageViewTopBlank      8
#define kImageViewWidth         37
#define kImageViewHeight        37
#define kTextLenLabelLeftBlank  9
#define kTextViewTopBlank       20
#define kTextViewHeight         110
#define kBindingActionSheetTag  777

@interface SNSharePostController () {
    // views
    UIButton *_imageViewButton;
    SNShareClipImageButton *_imageClipButton;
    
    UIViewController *_imageViewController; // 显示大图
    NSString *_cancelAuthAppId;
    NSString *_content;
    NSString *_imageUrl;
    NSString *_imagePath;
    NSString *_newsId;
    NSString *_groupId;
    long _longitude;
    long _latitude;
    id __weak _delegate;
    
    BOOL _bSelectedWeiBoChecked;
    BOOL _bBindOthers; // 标志绑定其他weibo  而非之前选择的

}

@property(nonatomic, strong)NSArray *shareListItems;
@property(nonatomic, copy)NSString *cancelAuthAppId;
@property(nonatomic, strong) UIViewController *imageViewController;


- (void)showActionSheetWithSelectedIndexpath:(NSIndexPath *)indexPath;
- (void)changeInputInfo;
- (NSArray*)getLinkFromString:(NSString*)content;
- (NSInteger)sinaCountWord:(NSString*)s;
- (BOOL)checkAndMakeSelectedWeiboReady;
- (ShareListItem *)itemByappName:(NSString *)appName; // 通过近似的name获取appId
- (void)orderShareItems;                              // 对分享的item排序：已经绑定，绑定但未打开，未绑定
- (void)shareItemEnableChanged;                       // item enable属性变化
- (void)sharelistDidChanged;                          // share list did changed
- (void)refreshShareList;
- (void)showLoading:(BOOL)bLoading;
- (void)dismissCurrentPostView:(NSNotification *)notification;

@end

@implementation SNSharePostController

@synthesize shareListItems = _shareListItems;
@synthesize cancelAuthAppId = _cancelAuthAppId;
@synthesize delegate = _delegate;
@synthesize imageViewController = _imageViewController;
@synthesize confirmAlertView = _confirmAlertView;
@synthesize bPresentFromWindowDelegate;
@synthesize isDismissing;

+ (SNSharePostController *)sharePostControllerWithShareInfo:(NSDictionary *)shareInfo {
    SNSharePostController *controller = nil;
    
    if ([shareInfo intValueForKey:kShareInfoKeyShareType defaultValue:@""] == ShareSubTypeQuoteCard ) {
        controller =[[SNShareWithCommentController alloc] initWithShareInfo:shareInfo];
    } else if ([shareInfo intValueForKey:kShareInfoKeyShareType defaultValue:@""] == ShareSubTypeTextOnly){

        NSMutableDictionary * re_shareInfo = [NSMutableDictionary dictionaryWithDictionary:shareInfo];
        SNTimelineOriginContentObject * shareInfoObj = [[SNTimelineOriginContentObject alloc] init];
        
        shareInfoObj.title = [re_shareInfo[@"content"] stringByAppendingString:@"(分享自 @搜狐新闻客户端)"];
        shareInfoObj.description = shareInfoObj.title;
        shareInfoObj.link = re_shareInfo[@"webUrl"];
        re_shareInfo[kShareInfoKeyInfoDic] = shareInfoObj;
        controller =[[SNShareWithCommentController alloc] initWithShareInfo:re_shareInfo];
    }
    else {
        controller = [[SNSharePostController alloc] initWithShareInfo:shareInfo];
    }
    return controller;
}

- (id)initWithShareInfo:(NSDictionary *)shareInfo {
    self = [super init];
    if (self) {
        self.shareListItems = [[SNShareManager defaultManager] shareList];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(sharelistDidChanged)
                                                     name:kSharelistDidChangedNotification object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(resignActiveFunction)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(Unbundling:) name:kShareUnbundlingSelectNotification object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(didReceivePushNotice) name:kNotifyExpressShow object:nil];
        
        self.shareComment = [shareInfo stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        self.content   = [shareInfo objectForKey:kShareInfoKeyContent];
        NSString *shareImage = [shareInfo objectForKey:kShareInfoKeyScreenImagePath defalutObj:nil];
        if (!shareImage) {
            shareImage = [shareInfo objectForKey:kShareInfoKeyImagePath defalutObj:@""];
        }
        self.imagePath = shareImage;
        self.imageUrl  = [shareInfo objectForKey:kShareInfoKeyImageUrl defalutObj:@""];
        
        self.newsId     = [shareInfo objectForKey:kShareInfoKeyNewsId defalutObj:@""];
        self.groupId    = [shareInfo objectForKey:kShareInfoKeyGroupId defalutObj:@""];
        self.bPresentFromWindowDelegate = [[shareInfo stringValueForKey:kPresentFromWindowDelegate
                                                                 defaultValue:@""] isEqualToString:@"1"];
        self.shareType  = SNShareContentTypeString;
        int ugcLimitWord = [shareInfo intValueForKey:kShareInfoKeyUgcLimitWord defaultValue:0];
        
        if (ugcLimitWord > 0) {
            _canInputCount = ugcLimitWord;
        }
    }
    return self;
}

- (void)didReceivePushNotice {
//    [self hideKeyboard];
    [SNNotificationCenter hideMessage];
    self.isDismissing = YES;
    //  直接推出
    if (self.bPresentFromWindowDelegate) {
//        [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else if (_delegate && _delegate == [SNUtility getApplicationDelegate].splashViewController) {
        [_delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id)kCFBooleanTrue afterDelay: 0.0];
    } else {
        //            [[TTNavigator navigator].topViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay:0.0];
        //present-style push
        [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
    }
   
}

- (SNSharePostController *)initWithContent:(NSString *)content
                                  imageUrl:(NSString *)imageUrl
                                    newsId:(NSString *)newsId
                                   groupId:(NSString *)gid
                                 longitude:(long)longitude
                                  latitude:(long)latitude
                                  delegate:(id)delegate {
    self = [super init];
    if (self) {
        self.content = [NSString stringWithFormat:@"%@ ", content];
        self.imageUrl = imageUrl;
        self.newsId = newsId;
        self.groupId = gid;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(_shareListItems);
     //(_cancelAuthAppId);
     //(_content);
     //(_imageUrl);
     //(_imagePath);
     //(_newsId);
     //(_groupId);
    _delegate = nil;
     //(_imageViewController);
     //(_sharelistTableView);
     //(_contentTextView);
     //(_imageClipButton);
     //(_contentLengthView);
     //(_contentHeaderView);
     //(_refreshShareListMaskButton);
     //(_confirmAlertView);
    
     //(confirmViewExit);
    // delegate clean
    [SNShareManager defaultManager].delegate = nil;
    [SNShareList shareInstance].delegate = nil;
}

- (void)setShareListItems:(NSArray *)shareListItems {
    _shareListItems = shareListItems;
    // 排序
    [self orderShareItems];
}

- (void)loadView
{
    [super loadView];
    [self creatView];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(dismissCurrentPostView:)
                                                 name:kNotifyDidReceive
                                               object:nil];
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(showKeyboard)
                                                 name:KGuideRegisterBackNotification
                                               object:nil];
}

- (void)creatView {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    int width, height;
    self.view.frame = appFrame;
    width = self.view.size.width;
    height = self.view.size.height;
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat offsetHeight = 0;
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
    if (t == UIDevice6iPhone || t == UIDevice6PlusiPhone || t == UIDevice7iPhone || t == UIDevice7PlusiPhone || t == UIDevice8iPhone || t == UIDevice8PlusiPhone) {
        offsetHeight = 50;
    }
    _contentHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom + 44, width, 179 - 5 + offsetHeight)];
    _contentHeaderView.backgroundColor = [UIColor clearColor];
    
    // textview
    if (!_contentTextView) {
        _contentTextView = [[SNTextView alloc] initWithFrame:CGRectMake(0, kTextViewTopBlank - 20 + 16 / 2,
                                                                        self.view.frame.size.width, kTextViewHeight + offsetHeight)];
    }
    _contentTextView.delegate = self;
    _contentTextView.font = [UIFont systemFontOfSize:16];
    _contentTextView.returnKeyType = UIReturnKeyDone;
    _contentTextView.showsVerticalScrollIndicator = NO;
    _contentTextView.tag = 10001;
    [_contentTextView becomeFirstResponder];
    
    if ([_contentTextView.text length] <= 0) {
        if (self.shareComment.length > 0 && self.content.length > 0) {
            self.content = [NSString stringWithFormat:@"%@%@",self.shareComment, self.content];
        }
        _contentTextView.text = _content;
    }
    
    if ([_contentTextView.text length] > 0) {
        _canInputCount = (int)(MAXINPUT_FOR_SINA - _contentTextView.text.length);
    }
    
    _contentTextView.backgroundColor = [UIColor clearColor];
    _contentTextView.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShareToInfoTextColor]];
    [_contentHeaderView addSubview:_contentTextView];
    
    // textview background
    UIImage *bgImgae = [UIImage imageNamed:@"share_post_sepLine.png"];
    UIImageView *imageBGN = [[UIImageView alloc] initWithImage:bgImgae];
    imageBGN.frame = CGRectMake(0, _contentTextView.bottom - bgImgae.size.height, kAppScreenWidth, bgImgae.size.height);
    [_contentHeaderView addSubview:imageBGN];
    
    // imageview
    _imageClipButton = [[SNShareClipImageButton alloc] initWithFrame:CGRectMake(_contentHeaderView.width - kImageViewWidth - 10,
                                                                                _contentTextView.top + 5,
                                                                                kImageViewWidth,
                                                                                kImageViewHeight)];
    [_imageClipButton addTarget:self selector:@selector(showImageDetail)];
    [_contentHeaderView addSubview:_imageClipButton];
    
    // content length
    _contentLengthView = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightBlank + kTextLenLabelLeftBlank,
                                                                   _contentTextView.bottom + 15, 180, 20)];
	[_contentLengthView setNumberOfLines:1];
	[_contentLengthView setTextAlignment:NSTextAlignmentLeft];
    [_contentLengthView setFont:[UIFont systemFontOfSize:11]];
	[_contentLengthView setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubHomeTableCellDetailLabelColor]]];
    [_contentLengthView setBackgroundColor:[UIColor clearColor]];
    [_contentHeaderView addSubview:_contentLengthView];
    
    CGRect screenFrame = TTApplicationFrame();
    
    UIImage *submitImg = [UIImage imageNamed:@"comment_send_button_enable.png"];
    UIButton *_submitButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width - submitImg.size.width - 6,
                                                                         _contentLengthView.top - 8,
                                                                         submitImg.size.width, submitImg.size.height)];
    [_submitButton setImage:submitImg forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton setAccessibilityLabel:@"发表"];
    _submitButton.centerY = _contentLengthView.centerY;
    
    [_contentHeaderView addSubview:_submitButton];
    
    // tableview
    _sharelistTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeadSelectViewBottom, width, height - kHeadSelectViewBottom) style:UITableViewStylePlain];
    _sharelistTableView.backgroundColor = [UIColor clearColor];
    _sharelistTableView.showsVerticalScrollIndicator = NO;
    [_sharelistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _sharelistTableView.tableHeaderView = _contentHeaderView;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _sharelistTableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
        _sharelistTableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
    
    // table bg
    _sharelistTableView.backgroundView = nil;
    _sharelistTableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    self.view.backgroundColor = _sharelistTableView.backgroundColor;
    _sharelistTableView.delegate = self;
    _sharelistTableView.dataSource = self;
    
    [self.view addSubview:_sharelistTableView];
    
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo_dark.png"]];
    [logo setFrame:CGRectMake((kAppScreenWidth-kAppLogoWidth/2)/2,-100, kAppLogoWidth/2, kAppLogoHeight/2)];
    [_sharelistTableView addSubview:logo];
    logo = nil;
    
    _refreshShareListMaskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44 + _contentHeaderView.height, width, height - 44 - _contentHeaderView.height)];
    [_refreshShareListMaskButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_refreshShareListMaskButton.titleLabel setTextColor:[UIColor lightGrayColor]];
    [_refreshShareListMaskButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    _refreshShareListMaskButton.backgroundColor = [UIColor clearColor];
    [_refreshShareListMaskButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_refreshShareListMaskButton setTitle:@"点击刷新分享列表" forState:UIControlStateNormal];
    [_refreshShareListMaskButton addTarget:self action:@selector(refreshShareList) forControlEvents:UIControlEventTouchUpInside];
    _refreshShareListMaskButton.hidden = ([_shareListItems count] > 0);
    [self.view addSubview:_refreshShareListMaskButton];
    
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObject:@"分享"]];
    
    UIImage *icon = [UIImage imageNamed:@"nickClose.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:icon forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(kAppScreenWidth - icon.size.width - 4/2, kSystemBarHeight+8/2, icon.size.width, icon.size.height);
    [self.headerView addSubview:backBtn];
    
    //2012 11 14 by diao for 盲人阅读
    [icon setAccessibilityLabel:@"关闭"];
}

- (void) showKeyboard {
    [_contentTextView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    if ([_contentTextView.text length] <= 0) {
//        _contentTextView.text = _content;
//    }
    [self setImageClipButton];
    [self changeInputInfo];
}

- (void)setImageClipButton {
    _imageClipButton.hidden = YES;
    _contentTextView.width = self.view.frame.size.width;
    if (_imageUrl && [_imageUrl length] > 0 && [SNAPI isWebURL:_imageUrl]) {
        _imageClipButton.hidden = NO;
        _contentTextView.width = _imageClipButton.left - _contentTextView.left;
        [_imageClipButton setImageUrl:_imageUrl];
    }
    else {
        _imageUrl = @"";
        if ([_imagePath length] > 0) {
            _imageClipButton.hidden = NO;
            _contentTextView.width = _imageClipButton.left - _contentTextView.left;
            [_imageClipButton setImagePath:_imagePath];
        }
    }
}

- (void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    
    // Release any retained subviews of the main view.
     //(_sharelistTableView);
//     //(_contentTextView); // content view 暂时不释放  防止用户编辑的文字信息丢失
     //(_imageClipButton);
     //(_contentLengthView);
     //(_contentHeaderView);
     //(_refreshShareListMaskButton);
     //(_confirmAlertView);
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showLoading:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)showImageDetail {
    if (self.imageViewController == nil) {
        _imageViewController = [[UIViewController alloc] init];
        
        CGRect applicationFrame     = [[UIScreen mainScreen] applicationFrame];
        self.imageViewController.view   = [[UIView alloc] initWithFrame:applicationFrame];
        self.imageViewController.view.backgroundColor   = [UIColor blackColor];
        
//        UINavigationBar *navigationBar   = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, applicationFrame.size.width, TTToolbarHeight())] autorelease];
//        navigationBar.tintColor	= [UIColor clearColor];
//        [navigationBar setBackgroundColor:[UIColor clearColor]];
//        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.imageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(5, applicationFrame.size.height - 40 - 5, 40, 40)];
        [btn setImage:[UIImage imageNamed:@"backNomal.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"backPress.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(cancelViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageViewController.view addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(applicationFrame.size.width - 40 - 5, applicationFrame.size.height - 40 - 5, 40, 40)];
        [btn setImage:[UIImage imageNamed:@"cleanUp.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"unCleanUp.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(removeSHareImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageViewController.view addSubview:btn];
        
        // 根据图片size调整下imageview
        UIImage *sourceImage = nil;
        if ([self.imagePath length] > 0 && ![SNAPI isWebURL:self.imagePath]) {
            sourceImage = [UIImage imageWithContentsOfFile:self.imagePath];
        }
        
        if (sourceImage == nil && [self.imageUrl length] > 0) {
//            sourceImage = [[TTURLCache sharedCache] imageForURL:_imageUrl fromDisk:YES];
            sourceImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_imageUrl];
        }
//        UIImageView *imageView  = [[[UIImageView alloc] initWithImage: sourceImage] autorelease];
        UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 
                                                                                 self.imageViewController.view.frame.size.width, 
                                                                                 self.imageViewController.view.frame.size.height - 44 * 2)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = sourceImage;
        [self.imageViewController.view addSubview:imageView];
        
        imageView.alpha = 1;
        
//        imageView.frame         = CGRectMake(applicationFrame.origin.x, applicationFrame.origin.y + 50
//                                             , applicationFrame.size.width, applicationFrame.size.height - 50);
//        [scrollView addSubview:imageView];
    }
    
    [[TTNavigator navigator].topViewController presentViewController:self.imageViewController animated:YES completion:nil];
}

- (void)removeSHareImage:(id)sender {
    if (self.imageViewController != nil)
    {
        [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
        [self.imageViewController dismissViewControllerAnimated:YES completion:^{
            [self showKeyboard];
        }];
         //(_imageViewController);
    }
    _imageClipButton.hidden = YES;
    _contentTextView.width = self.view.frame.size.width;
     //(_imageUrl);
     //(_imagePath);
}

-(void)cancelViewSharedImage:(id)sender {
    if (self.imageViewController != nil)
    {
        [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
        [self.imageViewController dismissViewControllerAnimated:YES completion:^{
            [self showKeyboard];
        }];
         //(_imageViewController);
    }
}

- (BOOL)startPost {
    NSString *shareContent = [_contentTextView.text trim];
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error",@"") toUrl:nil mode:SNCenterToastModeError];
        return NO;
    }
    if ([[[SNShareManager defaultManager] itemsCouldShare] count] == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kBindSinaFirst toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    if ([shareContent length] > MAXINPUT_FOR_SINA) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"分享内容应不多于140个字" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    if ([shareContent length] <= 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"分享内容不能为空" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    
    SNShareItem *shareItem = [[SNShareItem alloc] init];
    shareItem.shareId = self.newsId;
    shareItem.shareContentType = self.shareType;
    shareItem.shareContent   = shareContent;
    shareItem.shareImagePath = self.imagePath;
    shareItem.shareImageUrl  = self.imageUrl;
    
    [[SNShareManager defaultManager] postShareItemToServer:shareItem];
     //(shareItem);
    
    return YES;
}

- (void)post:(id)sender {
    if ([_shareListItems count] > 0) {
    ShareListItem *listItem = [_shareListItems objectAtIndex:0];
        NSInteger statusNum =[listItem.status integerValue];
        if (statusNum == 2) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"新浪微博绑定已过期，请重新绑定" toUrl:nil mode:SNCenterToastModeWarning];
            return;
        }
    }
    
    if ([self startPost]) {
        [_contentTextView resignFirstResponder];
        
        if (self.bPresentFromWindowDelegate) {
            [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        }
        else if (_delegate && [_delegate isKindOfClass:[SNSplashViewController class]]) {
            [_delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id)kCFBooleanTrue afterDelay:0.0];
        }
        else if (self.isQianfanShare || self.isVideoShare) {
            [SNNotificationManager postNotificationName:kAudioShareSNotification object:nil];
        }
        else {
            //present-style push
            [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
        }
        self.isDismissing = YES;
    }
}

- (void)onBack:(id)sender {
    [self hideKeyboard];
    [SNNotificationCenter hideMessage];
    
    if ([_content isEqualToString:_contentTextView.text]) {
        self.isDismissing = YES;
        // 内容没有编辑 直接推出
        if (self.bPresentFromWindowDelegate) {
//            [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else if (_delegate && _delegate == [SNUtility getApplicationDelegate].splashViewController) {
            [_delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id)kCFBooleanTrue afterDelay: 0.0];
        } else {
//            [[TTNavigator navigator].topViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay:0.0];
            //present-style push
            [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
        }
        return;
    }
    
//    if(nil == confirmViewExit){
//        confirmViewExit = [[SNConfirmFloatView alloc] init];
//        confirmViewExit.message = @"退出分享，您已经写下的文字将丢失";
//        __weak __typeof(&*self)weakSelf = self;
//        [confirmViewExit setConfirmText:@"退出" andBlock:^{
//            if (weakSelf.bPresentFromWindowDelegate) {
//                [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
//            }
//            else if (weakSelf.delegate && weakSelf.delegate == [SNUtility getApplicationDelegate].splashViewController) {
//                [weakSelf.delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
//            } else {
//                [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
//            }
//            weakSelf.isDismissing = YES;
//        }];
//    }
//    [confirmViewExit show];
    
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"退出分享，您已经写下的文字将丢失" cancelButtonTitle:@"取消" otherButtonTitle:@"退出"];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        if (self.bPresentFromWindowDelegate) {
            [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        }
        else if (self.delegate && self.delegate == [SNUtility getApplicationDelegate].splashViewController) {
            [self.delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        } else {
            [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
        }
        self.isDismissing = YES;
    }];

}

- (void)hideKeyboard {
    [_contentTextView resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text compare:@"\n" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [_contentTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self changeInputInfo];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height
           - textView.contentInset.bottom - textView.contentInset.top);
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
            [UIView animateWithDuration:.2 animations:^{
                [textView setContentOffset:offset];
            }];
        }
    }
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_shareListItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"shareCell";
    SNShareListItemCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SNShareListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    cell.shareItem = [_shareListItems objectAtIndex:[indexPath row]];
    cell.needTopSepLine = ([indexPath row] == 0);
    return cell;
}

- (void)Unbundling:(NSNotification *)notification
{
    [_contentTextView resignFirstResponder];
    NSDictionary *dict = [notification userInfo];
    if ([[dict objectForKey:kSinaBindStatus] boolValue]) {
        if (!self.isDismissing) {
            [self performSelector:@selector(showActionSheetWithSelectedIndexpath:) withObject:nil afterDelay:0.3];
        }
    }
}

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [_contentTextView resignFirstResponder];
//    ShareListItem *item = [_shareListItems objectAtIndex:[indexPath row]];
//    if ([item.status intValue] == 0 && !self.isDismissing) {
//        [self performSelector:@selector(showActionSheetWithSelectedIndexpath:) withObject:indexPath afterDelay:0.3];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSNShareListItemCellHeight;
}

#pragma mark - SNShareManagerDelegate
- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
    [self presentViewController:authNaviController animated:YES completion:nil];
}

- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager {
    _bBindOthers = YES;
    [self orderShareItems];
    [_sharelistTableView reloadData];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功,已用此账号登录" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidAuthSuccess:(SNShareManager *)manager {
    _bBindOthers = YES;
    [self orderShareItems];
    [_sharelistTableView reloadData];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定失败" toUrl:nil mode:SNCenterToastModeWarning];
    _bSelectedWeiBoChecked = NO;
}

- (void)shareManagerDidCancelAuth:(SNShareManager *)manager {
    _bSelectedWeiBoChecked = NO;
}

- (void)shareManagerDidCancelBindingSuccess:(SNShareManager *)manager {
    [_sharelistTableView reloadData];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:kRelieveSinaSucceed toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidCancelBindingFail:(SNShareManager *)manager {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法解除绑定" toUrl:nil mode:SNCenterToastModeWarning];
}

#pragma mark - SNShareListDelegate
- (void)refreshShareListSucc {
    [self showLoading:NO];
    _refreshShareListMaskButton.hidden = YES;
    [_sharelistTableView reloadData];
}

- (void)refreshShareListFail {
    [self showLoading:NO];
    _refreshShareListMaskButton.hidden = NO;
}

- (void)refreshShareListGetNoData {
    [self showLoading:NO];
    _refreshShareListMaskButton.hidden = NO;
}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == kBindingActionSheetTag) {
        if (buttonIndex == 1) {
            [[SNShareManager defaultManager] cancelAuthrizeByAppId:_cancelAuthAppId delegate:self];
        }
    }else if (actionSheet.tag == kAlertViewTagCancel) {
        if (buttonIndex == 1) {
            if (self.bPresentFromWindowDelegate) {
                [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            }
            else if (_delegate && _delegate == [SNUtility getApplicationDelegate].splashViewController) {
                [_delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            } else {
//                [[TTNavigator navigator].topViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
                //present-style push
                [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
            }
            self.isDismissing = YES;
        }
    }
}


#pragma mark - UIActionSheetDelegate
- (void)showUnbindingAlertView {
    self.confirmAlertView = [[SNAlert alloc] initWithTitle:TTLocalizedString(@"Cancel", @"")
                                              message:@"确定取消绑定吗" 
                                             delegate:self 
                                    cancelButtonTitle:TTLocalizedString(@"No", @"")
                                     otherButtonTitle:TTLocalizedString(@"Yes", @"")];
    _confirmAlertView.tag = kAlertViewTagUnbingding;
    [_confirmAlertView show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
//        [self performSelector:@selector(showUnbindingAlertView) withObject:nil afterDelay:0.1];
        [[SNShareManager defaultManager] cancelAuthrizeByAppId:_cancelAuthAppId delegate:self];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewTagCancel) {
        if (buttonIndex == 1) {
            if (self.bPresentFromWindowDelegate) {
                [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            }
            else if (_delegate && _delegate == [SNUtility getApplicationDelegate].splashViewController) {
                [_delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            } else {
                [[TTNavigator navigator].topViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
            }
            self.isDismissing = YES;
        }
    }
    else if (alertView.tag == kAlertViewTagUnbingding) {
        if (buttonIndex == 1) {
            [[SNShareManager defaultManager] cancelAuthrizeByAppId:_cancelAuthAppId delegate:self];
        }
    }
    self.confirmAlertView = nil;
}

#pragma mark - private methods
- (void)showActionSheetWithSelectedIndexpath:(NSIndexPath *)indexPath {
    if (self.isDismissing) {
        return;
    }
    
    ShareListItem *selectedItem = [_shareListItems objectAtIndex:[indexPath row]];
    self.cancelAuthAppId = selectedItem.appID;
    NSString *btnStr = [NSString stringWithFormat:@"解除绑定%@", selectedItem.appName];
    
    SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:btnStr cancelButtonTitle:@"取消" otherButtonTitle:@"解除绑定"];
    [alertView show];
    [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
         [[SNShareManager defaultManager] cancelAuthrizeByAppId:_cancelAuthAppId delegate:self];
    }];
    
}

- (void)changeInputInfo {
    NSString *shareContent	= _contentTextView.text;
    //	int nLength	= [self sinaCountWord:shareContent]; // 新浪微博  汉字为一个字符  字母 数字两个为一个字符  保险起见，舍弃这种算法
	NSInteger nLength	= [shareContent length];
	NSInteger nCanInputCount	= 0;
	if (nLength <= MAXINPUT_FOR_SINA) {
		nCanInputCount	= MAXINPUT_FOR_SINA - nLength;
        NSString *strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Can input",@""),nCanInputCount];
		[_contentLengthView setText:strContrent];
	}
	else {
		nCanInputCount	= nLength - MAXINPUT_FOR_SINA;
        NSString *strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Exceeded",@""),nCanInputCount];
        [_contentLengthView setText:strContrent];
	}
}

- (NSArray*)getLinkFromString:(NSString*)content
{
	NSMutableArray *linkList	= nil;
    NSString *linkHeader		= [SNAPI rootScheme];
	NSString *source			= content;
	NSRange	rangeHeader			= [source rangeOfString:linkHeader options:NSCaseInsensitiveSearch];
	while (rangeHeader.location != NSNotFound) {
		NSString *subString	= [source substringFromIndex:rangeHeader.location + [linkHeader length]];
		
		NSInteger nSubStringLen	= [subString length];
		unichar ch			= 0;
		NSInteger nLinkEndIndex	= nSubStringLen;
		for (int nIndex = 0; nIndex < nSubStringLen; nIndex++) {
			ch = [subString characterAtIndex:nIndex];
			if (!isascii(ch) || isblank(ch) ) {
				nLinkEndIndex = nIndex;
				break;
			}
		}
		
		if (nLinkEndIndex == 0) {
			source	= subString;
			rangeHeader = [source rangeOfString:linkHeader options:NSCaseInsensitiveSearch];
			continue;
		}
		
		NSRange linkRange	= NSMakeRange(rangeHeader.location, rangeHeader.length + nLinkEndIndex);
		NSString *link	= [source substringWithRange:linkRange];
		if (linkList == nil) {
			linkList = [[NSMutableArray alloc] init];
		}
		
		[linkList addObject:link];
		
		source	= [subString substringFromIndex:nLinkEndIndex];
		rangeHeader			= [source rangeOfString:linkHeader options:NSCaseInsensitiveSearch];
	}
	
	return linkList;
}

- (NSInteger)sinaCountWord:(NSString*)s
{
	NSInteger i,n = [s length],l = 0,a = 0,b = 0;
	unichar c;
	for(i = 0;i < n;i++){
		c = [s characterAtIndex:i];
		if(isblank(c)){
			b++;
		} else if(isascii(c)){
			a++;
		} else {
			l++;
		}
	}
	if(a == 0 && l == 0) return 0;
	return l + (int)ceilf((float)(a + b)/2.0);
}

- (BOOL)checkAndMakeSelectedWeiboReady {
    // first : check selected weibo is binded
    // second : check selected weibo is enabled
    // finaly : tell user
    NSDictionary *dicInfo = [[SNShareManager defaultManager] shareDicInfo];
    if (dicInfo) {
        ShareListItem *itemToShare = nil;
        NSString *shareTo = [dicInfo objectForKey:kShareInfoKeyShareTo];
        itemToShare = [self itemByappName:shareTo];
        
        if ([itemToShare.status intValue] == 0) {
        }
        else {
            // 绑定
            _bSelectedWeiBoChecked = YES;
            return NO;
        }
    }
    return YES;
}

- (ShareListItem *)itemByappName:(NSString *)appName {
    ShareListItem *shareItem = nil;
    for (ShareListItem *item in _shareListItems) {
        if ([item.appName rangeOfString:appName].location != NSNotFound) {
            shareItem = item;
            break;
        }
    }
    return shareItem;
}

- (void)orderShareItems {
//    NSString *shareInfo = @"";
//    id shareValue = [[[SNShareManager defaultManager] shareDicInfo] objectForKey:kShareInfoKeyShareTo];
//    if (shareValue) {
//        shareInfo = shareValue;
//    }
    NSMutableArray *shareList = [NSMutableArray array];
    NSMutableArray *binded = [NSMutableArray arrayWithCapacity:6];
    NSMutableArray *disabled = [NSMutableArray arrayWithCapacity:6];
    NSMutableArray *unBinded = [NSMutableArray arrayWithCapacity:6];
    for (ShareListItem *item in _shareListItems) {
//        if ([item.appName rangeOfString:shareInfo].location != NSNotFound) {
//            [shareList addObject:item];
//            if ([item.status intValue] == 0) {
//                [SNShareList saveItemStatusToUserDefaults:item enable:YES];
//            }
//        }
//        else 
        if ([SNShareList couldItemShare:item]) {
            [binded addObject:item];
        }
        else if ([item.status intValue] == 0) {
            [disabled addObject:item];
        }
        else {
            [unBinded addObject:item];
        }
    }
    
    [shareList addObjectsFromArray:binded];
    [shareList addObjectsFromArray:disabled];
    [shareList addObjectsFromArray:unBinded];
    
    _shareListItems = shareList;
}

- (void)shareItemEnableChanged {
    _bBindOthers = YES;
}

- (void)sharelistDidChanged {
    self.shareListItems = [[SNShareManager defaultManager] shareList];
    [_sharelistTableView reloadData];
}

- (void)refreshShareList {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    [self showLoading:YES];
    _refreshShareListMaskButton.hidden = YES;
    [SNShareList shareInstance].delegate = self;
    [[SNShareList shareInstance] refreshShareListForce];
}

- (void)showLoading:(BOOL)bLoading {
    if (bLoading) {
        [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
    }
    else {
//        [SNNotificationCenter hideLoading];
    }
}

- (void)dismissCurrentPostView:(NSNotification *)notification {
    if (self.confirmAlertView) {
        [self.confirmAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    [self hideKeyboard];
}

#pragma mark -
#pragma mark application active
- (void)resignActiveFunction
{
    [_contentTextView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 10001) {
        return;
    }
    [self resignActiveFunction];
}

@end
