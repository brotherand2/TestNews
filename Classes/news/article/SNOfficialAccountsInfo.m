//
//  SNOfficialAccountsInfo.m
//  sohunews
//
//  Created by HuangZhen on 21/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNOfficialAccountsInfo.h"
#import "NSString+Utilities.h"
#import "SNDBManager.h"
#import "SNSubscribeCenterOperation.h"
#import "SNSubscribeCenterService.h"
#import "SNSoundManager.h"
#import "SNGalleryBrowserController.h"
#import "SNUserManager.h"
#import "SNCheckFollowRequest.h"
#import "SNWaitingActivityView.h"

#import "SNNewsLogin.h"
#import "SNNewsLoginManager.h"

static const CGFloat marginLeft     = 14.0f;
static const CGFloat infoViewHeight = 30.0f;
static const CGFloat headImgWidth   = 26.0f;
static const CGFloat minHeadImgWidth  = 20.0f;

static const CGFloat limitSpaceWidth = 25.0f;

static const CGFloat followButtonWidth  = 49.0f;
static const CGFloat followButtonHeight = 24.0f;

static const CGFloat nameLabelLeadingSpace   = 11.0f;
static const CGFloat timeLabelLeadingSpace   = 10.0f;

static const NSString * kProfilePageReferAccountsIcon = @"10002";
static const NSString * kProfilePageReferAccountsName = @"10003";

static const CGFloat h5MarginLeft     = 12.0f;
static const CGFloat h5InfoViewHeight = 44.0f;
static const CGFloat h5HeadImgWidth   = 24.0f;
static const CGFloat h5MinHeadImgWidth  = 21.0f;

static const CGFloat h5LineLeftSpaceWidth  = 16.0f;
static const CGFloat h5LineWidth  = 0.5f;

@interface SNOfficialAccountsInfo (){
    ///位置 Y坐标
    CGFloat        _positionY;
    /// 目标 scrollview
    UIScrollView * _backScrollView;
    /// 目标 webview
    UIWebView    * _webView;
    ///主要的视图
    UIView       * _officialAccountsInfoView;
    
    ///h5页分割线
    UIView       *_lineView;
    
    ///公众号名字
    UILabel      * _officialAccountsName;
    UILabel      * _fullOfficialAccountsName;
    
    UIButton     * _iconButton;
    UIButton     * _nameButton;
    
    ///用于回顶的 button
//    UIButton     * _scrollToTopButton;
    ///公众号头像
    UIImageView  * _officialAccountsHeadImg;
    ///时间戳 label
    UILabel      * _timestampLabel;
    ///关注按钮
    UIButton     * _followButton;
    ///状态栏视图
    UIView       * _statusbarView;
    ///状态栏截图
    UIView       * _snapshotView;
    ///night theme
    UIView       * _headMask;
    /// iconview
    UIView       * _iconView;
    SNWaitingActivityView *_loadingView;
    /// update time
    NSString     * _updateTime;
    
    BOOL _ignorScrolling;//如果没有任何subinfo，那么也不需要监听 webview 滚动了
    
    BOOL _isLoginSuccessDeal;///用于处理搜狐帐号登录成功的回调
    
    BOOL _nameLineOver;///名字长度超出限制
    
    CGPoint iconCenter;
    
    NSString *_h5Type; //"0"普通正文，"1"非合作H5
    
    CGFloat flowButtonBorderAlpha;
}

/// subobj
@property (nonatomic, strong) SCSubscribeObject * subObj;
/// subid
@property (nonatomic, copy) NSString    * subId;
/// sublink
@property (nonatomic, copy) NSString    * subLink;

@property (nonatomic, assign) SNFollowedStatus followedStatus;

@end

@implementation SNOfficialAccountsInfo

#pragma mark - static
+ (void)checkFollowStatusWithSubId:(NSString *)subId completed:(CheckFollowStatusCompleted)completed {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (![SNUserManager isLogin]) {
            return;
        }
        NSString *subIDString = [[NSString alloc] initWithString:subId];
        SNCheckFollowRequest * request = [SNCheckFollowRequest new];
        request.subId = subIDString;
        [request send:^(SNBaseRequest *request, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                        NSInteger bilateral = [(NSDictionary *)responseObject intValueForKey:@"bilateral" defaultValue:SNFollowedStatusNone];
                        SCSubscribeObject * subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subIDString];
                        if (subObj) {
                            if (bilateral == SNFollowedStatusFollowing || bilateral == SNFollowedStatusFriend) {
                                subObj.isSubscribed = @"1";
                            }else{
                                subObj.isSubscribed = @"0";
                            }
                            
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
                            
                        }
                        completed(bilateral);
                    }else{
                        completed(SNFollowedStatusNone);
                    }
                } @catch (NSException *exception) {
                    SNDebugLog(@"SNCheckFollowRequest exception reason--%@", exception.reason);
                } @finally {
                }
            });
        } failure:^(SNBaseRequest *request, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completed(SNFollowedStatusFailed);
            });
        }];
    });
}

#pragma mark - public
- (instancetype)initWithTargetWebView:(UIWebView *)webView position:(CGPoint)position h5Type:(NSString *)h5Type {
    if (self = [super init]) {
        _h5Type = h5Type;
        _positionY = position.y;
        _backScrollView = webView.scrollView;
        _webView = webView;
        _webView.scrollView.clipsToBounds = NO;
        _isLoginSuccessDeal = NO;
        _followedStatus = SNFollowedStatusNone;
        if ([_h5Type isEqualToString:@"0"]) {
            [_backScrollView addSubview:self.officialAccountsInfoView];
            self.officialAccountsInfoView.hidden = YES;
        } else {
            [_webView.superview addSubview:self.officialAccountsInfoView];
        }
        [_backScrollView addObserver:self
                          forKeyPath:@"contentOffset"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
        [SNNotificationManager addObserver:self
                                  selector:@selector(handleMySubDidChangeNotification:)
                                      name:kSubscribeCenterMySubDidChangedNotify
                                    object:nil];

    }
    return self;
}

- (void)show {
    self.officialAccountsInfoView.hidden = NO;
}

- (void)hide {
    self.officialAccountsInfoView.hidden = YES;
//    [self removeStatusBarShot];
}

- (void)updateWithJSON:(NSDictionary *)json {
    /// update infoview posion
    CGFloat posionY = [json floatValueForKey:kOffsetTopKey defaultValue:-1];
    if (posionY > 0 && self.officialAccountsInfoView.superview == _backScrollView) {
        self.officialAccountsInfoView.top = posionY;
    }
    _positionY = posionY;
    [self backScrollViewDidScroll:_backScrollView];
    
    /// data
    _ignorScrolling = NO;
    self.officialAccountsInfoView.hidden = NO;
    self.subId = [json stringValueForKey:kSubIdKey defaultValue:@""];
    self.subLink = [json stringValueForKey:kSubLinkKey defaultValue:@""];
    _updateTime = [json stringValueForKey:kTimeKey defaultValue:@""];
    NSString * imgUrl = [json stringValueForKey:kSubIconKey defaultValue:@""];
    NSString * nameString = [json stringValueForKey:kSubNameKey defaultValue:@""];
    [self checkFollowedStatus];

    /// label size changed
    CGFloat leftSpace = marginLeft;
    if (imgUrl.length > 0 ) {
        [_officialAccountsHeadImg sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    }else {
        [_officialAccountsHeadImg setImage:[UIImage themeImageNamed:@"feedBack_defaultIcon_v5.png"]];
    }
    leftSpace = marginLeft + headImgWidth + nameLabelLeadingSpace;
    [_officialAccountsHeadImg addSubview:self.headImgThemeMaskView];
    
    CGSize timeLabelSize = [_updateTime textSizeWithFont:_timestampLabel.font];
    _timestampLabel.width = timeLabelSize.width;
    CGFloat maxNameLabelSizeWidth = kAppScreenWidth - (marginLeft + headImgWidth + nameLabelLeadingSpace + _timestampLabel.width + timeLabelLeadingSpace + followButtonWidth + limitSpaceWidth);
    CGSize nameSize = [nameString textSizeWithFont:_officialAccountsName.font];
    /// 内容太多超出屏幕宽度限制
    if (nameSize.width > maxNameLabelSizeWidth) {
        _officialAccountsName.frame = CGRectMake(leftSpace, 0, maxNameLabelSizeWidth, infoViewHeight);
        _fullOfficialAccountsName.frame = CGRectMake(leftSpace, 0, maxNameLabelSizeWidth + _timestampLabel.width + timeLabelLeadingSpace, infoViewHeight);
        _nameLineOver = YES;
    }else{
        _officialAccountsName.frame = CGRectMake(leftSpace, 0, nameSize.width, infoViewHeight);
        _nameLineOver = NO;
    }
    _fullOfficialAccountsName.text = nameString;
    _officialAccountsName.text = nameString;
    _timestampLabel.left = _officialAccountsName.right + timeLabelLeadingSpace;
    _timestampLabel.text = _updateTime;
//    _scrollToTopButton.left = _timestampLabel.left;
//    _scrollToTopButton.width = _followButton.left - _timestampLabel.left - timeLabelLeadingSpace;
    _iconButton.frame = CGRectMake(0, 0, _iconView.right + nameLabelLeadingSpace, infoViewHeight);
    _nameButton.frame = CGRectMake(_iconView.right + nameLabelLeadingSpace, 0, _officialAccountsName.width + timeLabelLeadingSpace, infoViewHeight);
}

- (void)h5UpdateWithJSON:(NSDictionary *)json {
    [self h5BackScrollViewDidScroll:_backScrollView];

    /// data
    _ignorScrolling = NO;
    self.officialAccountsInfoView.hidden = NO;
    self.subId = [json stringValueForKey:kSubIdKey defaultValue:@""];
    self.subLink = [json stringValueForKey:kSubLinkKey defaultValue:@""];
    NSString * nameString = [json stringValueForKey:kSubNameKey defaultValue:@""];
    [self checkFollowedStatus];
    
    _fullOfficialAccountsName.text = nameString;
    _fullOfficialAccountsName.alpha = 1;
    _lineView.alpha = 1;
    _followButton.alpha = 1;

    CGSize nameSize = [nameString textSizeWithFont:_fullOfficialAccountsName.font];
    _nameButton.width = nameSize.width + h5LineLeftSpaceWidth;
    
//    _scrollToTopButton.left = _fullOfficialAccountsName.right;
//    _scrollToTopButton.width = _followButton.left - _nameButton.right;
}

- (void)checkFollowedStatus {
    if (_subId && _subId.length > 0) {
        [SNOfficialAccountsInfo checkFollowStatusWithSubId:_subId completed:^(SNFollowedStatus followedStatus) {
            self.followedStatus = followedStatus;
        }];
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == _backScrollView &&
        [keyPath isEqualToString:@"contentOffset"]) {
        if ([_h5Type isEqualToString:@"0"]) {
            [self backScrollViewDidScroll:_backScrollView];
        } else {
            [self h5BackScrollViewDidScroll:_backScrollView];
        }
    }
}

#pragma mark - private
- (UIView *)officialAccountsInfoView {
    if ([_h5Type isEqualToString:@"0"]) {
        if (!_officialAccountsInfoView) {
            _officialAccountsInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, _positionY, kAppScreenWidth - marginLeft, infoViewHeight)];
            //by wangchuanwen 5.9.4 modify
            //_officialAccountsInfoView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
            _officialAccountsInfoView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor_Attention];
            //modify end
            _officialAccountsHeadImg.backgroundColor = [UIColor whiteColor];
            _officialAccountsHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(marginLeft, 0, headImgWidth, headImgWidth)];
            _officialAccountsHeadImg.contentMode = UIViewContentModeScaleAspectFill;
            _officialAccountsHeadImg.centerY = infoViewHeight/2.f;
            
            _iconView = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, 0, headImgWidth, headImgWidth)];
            _iconView.backgroundColor = [UIColor whiteColor];
            _iconView.centerY = infoViewHeight/2.f;
            _iconView.layer.cornerRadius = headImgWidth/2;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = SNUICOLORREF(kThemeBg1Color);
            _iconView.clipsToBounds = YES;
            iconCenter = _iconView.center;
            _officialAccountsHeadImg.frame = CGRectMake(0, 0, headImgWidth, headImgWidth);
            [_iconView addSubview:_officialAccountsHeadImg];
            [_officialAccountsInfoView addSubview:_iconView];
            
            UIFont * textFont = [UIFont systemFontOfSize:kThemeFontSizeC];
            _fullOfficialAccountsName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, infoViewHeight, infoViewHeight)];
            _fullOfficialAccountsName.left = _iconView.right + nameLabelLeadingSpace;
            _fullOfficialAccountsName.textColor = SNUICOLOR(kThemeText10Color);
            _fullOfficialAccountsName.textAlignment = NSTextAlignmentLeft;
            _fullOfficialAccountsName.font = textFont;
            _fullOfficialAccountsName.lineBreakMode = NSLineBreakByTruncatingTail;
            [_officialAccountsInfoView addSubview:_fullOfficialAccountsName];
            _fullOfficialAccountsName.alpha = 0;
            
            _officialAccountsName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, infoViewHeight, infoViewHeight)];
            _officialAccountsName.left = _iconView.right + nameLabelLeadingSpace;
            _officialAccountsName.textColor = SNUICOLOR(kThemeText10Color);
            _officialAccountsName.textAlignment = NSTextAlignmentLeft;
            _officialAccountsName.font = textFont;
            _officialAccountsName.lineBreakMode = NSLineBreakByTruncatingTail;
            [_officialAccountsInfoView addSubview:_officialAccountsName];
            
            _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _iconButton.frame = CGRectMake(0, 0, 50, infoViewHeight);
            [_iconButton addTarget:self action:@selector(goProfilePage:) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_iconButton];
            
            _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _nameButton.frame = CGRectMake(0, 0, 50, infoViewHeight);
            _nameButton.left = _iconButton.right;
            [_nameButton addTarget:self action:@selector(goProfilePage:) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_nameButton];
            
            _timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, infoViewHeight)];
            _timestampLabel.left = _officialAccountsName.right + timeLabelLeadingSpace;
            _timestampLabel.textAlignment = NSTextAlignmentLeft;
            _timestampLabel.font = textFont;
            _timestampLabel.textColor = SNUICOLOR(kThemeText3Color);
            [_officialAccountsInfoView addSubview:_timestampLabel];
            
            _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_followButton setFrame:CGRectMake(0, 0, followButtonWidth, followButtonHeight)];
            _followButton.layer.borderWidth = 0.5;
            _followButton.layer.borderColor = SNUICOLORREF(kThemeGreen1Color);
            _followButton.layer.cornerRadius = 2;
            _followButton.clipsToBounds = YES;
            _followButton.right = _officialAccountsInfoView.width;
            [_followButton setTitle:NSLocalizedString(@"Follow",@"") forState:UIControlStateNormal];
            [_followButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
            _followButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
            
            _followButton.centerY = _officialAccountsInfoView.height/2.f;
            [_followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_followButton];
            
//            _scrollToTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            _scrollToTopButton.frame = CGRectMake(_officialAccountsName.right, 0, 100, infoViewHeight);
//            [_scrollToTopButton addTarget:self action:@selector(scrollToTop:) forControlEvents:UIControlEventTouchUpInside];
//            _scrollToTopButton.hidden = YES;
//            [_officialAccountsInfoView addSubview:_scrollToTopButton];
        }
    } else {
        if (!_officialAccountsInfoView) {
            _officialAccountsInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, _positionY, kAppScreenWidth, h5InfoViewHeight)];
            //by wangchuanwen 5.9.4 modify
            //_officialAccountsInfoView.backgroundColor = SNUICOLOR(kBackgroundColor);
            _officialAccountsInfoView.backgroundColor = SNUICOLOR(kBackgroundColor_Attention);
            //modify end
            _officialAccountsInfoView.alpha = 0.95;

            _officialAccountsHeadImg.backgroundColor = SNUICOLOR(kBackgroundColor);
            _officialAccountsHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, h5HeadImgWidth, h5HeadImgWidth)];
            _officialAccountsHeadImg.contentMode = UIViewContentModeScaleAspectFill;
            _officialAccountsHeadImg.image = [UIImage imageNamed:@"icotitlebar_sohu_v5.png"];
            
            _iconView = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, 0, h5HeadImgWidth, h5HeadImgWidth)];
            _iconView.backgroundColor = SNUICOLOR(kBackgroundColor);
            _iconView.centerY = h5InfoViewHeight/2.f;
            iconCenter = _iconView.center;
            [_iconView addSubview:_officialAccountsHeadImg];
            [_officialAccountsInfoView addSubview:_iconView];
            
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(_officialAccountsHeadImg.right + h5LineLeftSpaceWidth, 0, h5LineWidth, h5HeadImgWidth)];
            _lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
            _lineView.centerY = h5InfoViewHeight/2.f;
            [_officialAccountsInfoView addSubview:_lineView];
            _lineView.alpha = 0;
            
            UIFont * textFont = [UIFont systemFontOfSize:kThemeFontSizeD];
            _fullOfficialAccountsName = [[UILabel alloc] initWithFrame:CGRectMake(_lineView.right + h5LineLeftSpaceWidth, 0, kAppScreenWidth - _lineView.right - h5LineLeftSpaceWidth * 2 - followButtonWidth - h5MarginLeft, h5InfoViewHeight)];
            _fullOfficialAccountsName.textColor = SNUICOLOR(kThemeText10Color);
            _fullOfficialAccountsName.textAlignment = NSTextAlignmentLeft;
            _fullOfficialAccountsName.font = textFont;
            _fullOfficialAccountsName.lineBreakMode = NSLineBreakByTruncatingTail;
            [_officialAccountsInfoView addSubview:_fullOfficialAccountsName];
            _fullOfficialAccountsName.alpha = 0;
            
            _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _iconButton.frame = CGRectMake(0, 0, _lineView.left, h5InfoViewHeight);
            [_iconButton addTarget:self action:@selector(iconImageViewClick) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_iconButton];
            
            _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _nameButton.frame = CGRectMake(_lineView.right, 0, 0, infoViewHeight);
            [_nameButton addTarget:self action:@selector(goProfilePage:) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_nameButton];
            
            _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_followButton setFrame:CGRectMake(0, 0, followButtonWidth, followButtonHeight)];
            _followButton.layer.borderWidth = 0.5;
            _followButton.layer.borderColor = SNUICOLORREF(kThemeGreen1Color);
            _followButton.layer.cornerRadius = 2;
            _followButton.clipsToBounds = YES;
            _followButton.right = kAppScreenWidth - h5MarginLeft;
            [_followButton setTitle:NSLocalizedString(@"Follow",@"") forState:UIControlStateNormal];
            [_followButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
            _followButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
            _followButton.alpha = 0;
            
            _followButton.centerY = _officialAccountsInfoView.height/2.f;
            [_followButton addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchUpInside];
            [_officialAccountsInfoView addSubview:_followButton];
            
//            _scrollToTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            _scrollToTopButton.frame = CGRectMake(_nameButton.right, 0, kAppScreenWidth - _nameButton.right - h5MarginLeft - followButtonWidth, h5InfoViewHeight);
//            [_scrollToTopButton addTarget:self action:@selector(scrollToTop:) forControlEvents:UIControlEventTouchUpInside];
//            _scrollToTopButton.hidden = YES;
//            [_officialAccountsInfoView addSubview:_scrollToTopButton];
        }
    }
    
    return _officialAccountsInfoView;
}

- (void)setFollowedStatus:(SNFollowedStatus)followedStatus {
    _followedStatus = followedStatus;
    switch (followedStatus) {
        case SNFollowedStatusNone:
        {
            [_followButton setTitle:NSLocalizedString(@"Follow",@"") forState:UIControlStateNormal];
            _followButton.layer.borderColor = [SNUICOLOR(kThemeGreen1Color) colorWithAlphaComponent: flowButtonBorderAlpha].CGColor;
            [_followButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
            _followButton.hidden = NO;
            break;
        }
        case SNFollowedStatusFollower:
        {
            [_followButton setTitle:NSLocalizedString(@"Follow",@"") forState:UIControlStateNormal];
            _followButton.layer.borderColor = [SNUICOLOR(kThemeGreen1Color) colorWithAlphaComponent: flowButtonBorderAlpha].CGColor;
            [_followButton setTitleColor:SNUICOLOR(kThemeGreen1Color) forState:UIControlStateNormal];
            _followButton.hidden = NO;
            break;
        }
        case SNFollowedStatusFriend:
        {
            [_followButton setTitle:NSLocalizedString(@"Friend",@"") forState:UIControlStateNormal];
            _followButton.layer.borderColor = [SNUICOLOR(kThemeText3Color) colorWithAlphaComponent: flowButtonBorderAlpha].CGColor;
            [_followButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
            _followButton.hidden = NO;
            break;
        }
        case SNFollowedStatusFollowing:
        {
            [_followButton setTitle:NSLocalizedString(@"Following",@"") forState:UIControlStateNormal];
            _followButton.layer.borderColor = [SNUICOLOR(kThemeText3Color) colorWithAlphaComponent: flowButtonBorderAlpha].CGColor;
            [_followButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
            _followButton.hidden = NO;
            break;
        }
        case SNFollowedStatusSelf:
        {
            _followButton.hidden = YES;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Theme 
- (void)updateTheme {
    [_officialAccountsHeadImg addSubview:self.headImgThemeMaskView];
    //by wangchuanwen 5.9.4 modify
    //_officialAccountsInfoView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    _officialAccountsInfoView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor_Attention];
    //modify end
    _officialAccountsName.textColor = SNUICOLOR(kThemeText10Color);
    _fullOfficialAccountsName.textColor = SNUICOLOR(kThemeText10Color);
    _timestampLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self setFollowedStatus:_followedStatus];
}

#pragma mark - Action

- (void)loginSuccess {
    [self follow:_followButton];
    _isLoginSuccessDeal = YES;
}

- (void)loginOnBack {
    if ([SNUserManager isLogin] && !_isLoginSuccessDeal) {
        [self loginSuccess];
    }
}

- (void)follow:(UIButton *)sender {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (_subId.length <= 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"subId 不存在哦~" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    
    if (_followedStatus == SNFollowedStatusSelf) {
        /// 如果是自己，关注按钮就隐藏掉了，如果走到这里说明出 bug 了。
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"不能关注自己哦~" toUrl:nil mode:SNCenterToastModeOnlyText];
        return;//不能关注自己
    }
    
    ///表示已关注
    BOOL isSub = (_followedStatus == SNFollowedStatusFollowing || _followedStatus == SNFollowedStatusFriend);
    
    ///关注前必须登录
    if (![SNUserManager isLogin] && !isSub) {
        [SNUtility shouldUseSpreadAnimation:NO];
//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//        NSValue* onbackMethod = [NSValue valueWithPointer:@selector(loginOnBack)];
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method",onbackMethod,@"onBackMethod", self,@"delegate", [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
//        [SNUtility openLoginViewWithDict:dict];
        //wangshun 登录埋点 关注 100030 2017.8.9
        //halfScreenTitle
        [SNNewsLoginManager halfLoginData:@{@"loginFrom":@"100030",@"halfScreenTitle":@"一键登录即可关注",@"entrance":@"6"} Successed:^(NSDictionary *info) {
            [self follow:sender];
        } Failed:nil];
        
    }else{
        _followButton.enabled = NO;
        if (!_loadingView) {
            _loadingView = [[SNWaitingActivityView alloc] init];
            _loadingView.center = _followButton.center;
            [[self officialAccountsInfoView] insertSubview:_loadingView aboveSubview:_followButton];
        }
        [_loadingView startAnimating];
        _followButton.hidden = YES;
        _loadingView.hidden = NO;

        if (isSub) {
            ///取消关注
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
            [[SNSubscribeCenterService defaultService] removeMySubToServerBySubId:_subId from:0];
        } else {
            ///添加关注
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubId:_subId from:0];
        }
    }
}

- (void)goProfilePage:(UIButton *)sender {
    if (_h5Type && [_h5Type isEqualToString:@"1"]) {
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=h5news_sub&_tp=clk&subid=%@&channelid=%@&newsId=%@&newstype=8",self.subId, self.channelId, self.newsId]];
    }
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];
    //打开刊物前停止音频播放
    [[SNSoundManager sharedInstance] stopAll];
    NSMutableDictionary * contextDic = [NSMutableDictionary dictionary];
    if (sender == _iconButton) {
        [contextDic setObject:kProfilePageReferAccountsIcon forKey:@"channelId"];
    }else {
        [contextDic setObject:kProfilePageReferAccountsName forKey:@"channelId"];
    }
    [contextDic setObject:[NSNumber numberWithInt:SNProfileRefer_Article_Subscribe] forKey:kRefer];
    [contextDic setObject:@"Newsid" forKey:kReferType];
    [contextDic setObject:self.newsId?:@"0" forKey:kReferValue];
    [contextDic setObject:[NSNumber numberWithBool:YES] forKey:kFromRollingChannelWebKey];
    if (self.subLink.length > 0 ){
        [SNUtility openProtocolUrl:self.subLink
                           context:contextDic];
    }else{
        NSString * link = [NSString stringWithFormat:@"subHome://subId=%@",_subId];
        [SNUtility openProtocolUrl:link
                           context:contextDic];
    }
}

- (void)iconImageViewClick {
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=h5news_logo&_tp=clk&channelid=%@&newsId=%@&newstype=8", self.channelId, self.newsId]];
    //不管在那个tab，点击都回到新闻tab头条流，并刷新
    UIViewController* topController = [TTNavigator navigator].topViewController;
    [SNUtility popToTabViewController:topController];
    //tab切换到新闻
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    //栏目切换到焦点
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
    [SNNotificationManager postNotificationName:kCloseSearchWebNotification object:nil];
    if ([SNUtility isFromChannelManagerViewOpened]) {
        [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
    }
}

#pragma mark - Scroll Observer

- (void)scrollToTop:(id)sender {
    [_backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)moveToScrollView {
    if (_backScrollView && self.officialAccountsInfoView.superview == _webView.superview) {
        self.officialAccountsInfoView.top = _positionY;
        self.officialAccountsInfoView.width = kAppScreenWidth - marginLeft;
        _officialAccountsInfoView.alpha = 1;
        [_backScrollView addSubview:[self officialAccountsInfoView]];
    }
}

- (void)moveToScrollSuperView {
    if (_webView.superview && self.officialAccountsInfoView.superview == _backScrollView) {
        self.officialAccountsInfoView.top = kSystemBarHeight;
//        self.officialAccountsInfoView.width = kAppScreenWidth;
        _officialAccountsInfoView.alpha = 0.95;
        [_webView.superview addSubview:self.officialAccountsInfoView];
    }
}

- (void)changeAlphaWithRatio:(CGFloat)ratio {
    if (ratio > 1) {
        ratio = 1;
    }
    if (ratio < 0) {
        ratio = 0;
    }
    /// alpha
    _timestampLabel.alpha = ratio;
    flowButtonBorderAlpha = ratio;
    _followButton.layer.borderColor = [[UIColor colorWithCGColor:_followButton.layer.borderColor] colorWithAlphaComponent:ratio].CGColor;
}

- (void)h5ChangeAlphaWithRatio:(CGFloat)ratio {
    if (ratio > 1) {
        ratio = 1;
    }
    if (ratio < 0) {
        ratio = 0;
    }
    flowButtonBorderAlpha = ratio;
    _followButton.layer.borderColor = [[UIColor colorWithCGColor:_followButton.layer.borderColor] colorWithAlphaComponent:ratio].CGColor;
}

- (void)changeFrameWithRatio:(CGFloat)ratio {
    /// icon size
    CGFloat widthDiff = headImgWidth - minHeadImgWidth;
    CGFloat value = widthDiff * ratio;
    if (value < 0) {
        value = 0;
    }
    if (value > widthDiff) {
        value = widthDiff;
    }
    _iconView.center = iconCenter;
    _iconView.width = headImgWidth - value;
    _iconView.height = headImgWidth - value;
    _iconView.layer.cornerRadius = _iconView.width/2.f;
    _officialAccountsHeadImg.width = _iconView.width;
    _officialAccountsHeadImg.height = _iconView.height;
    _officialAccountsHeadImg.center = CGPointMake(_iconView.width/2.f, _iconView.height/2.f);
}

- (void)h5ChangeFrameWithRatio:(CGFloat)ratio {
    if (ratio > 1) {
        ratio = 1;
    }
    if (ratio < 0) {
        ratio = 0;
    }
    
    _statusbarView.top = 0 - kSystemBarHeight * ratio;
    
    _officialAccountsInfoView.height = h5InfoViewHeight - (h5InfoViewHeight - infoViewHeight) * ratio;
    _officialAccountsInfoView.top = _positionY;
    
    _iconView.width = h5HeadImgWidth - (h5HeadImgWidth - h5MinHeadImgWidth) * ratio;
    _iconView.height = h5HeadImgWidth - (h5HeadImgWidth - h5MinHeadImgWidth) * ratio;
    _iconView.centerY = _officialAccountsInfoView.height/2.0f;
    
    _officialAccountsHeadImg.width = _iconView.width;
    _officialAccountsHeadImg.height = _iconView.height;

    _lineView.left = _iconView.right + h5LineLeftSpaceWidth;
    _lineView.centerY = _iconView.centerY;
    _lineView.height = _iconView.height;
    
    _fullOfficialAccountsName.font = [UIFont systemFontOfSize:kThemeFontSizeD - (kThemeFontSizeD - kThemeFontSizeC)*ratio];
    _fullOfficialAccountsName.height = _officialAccountsInfoView.height;
    _fullOfficialAccountsName.left = _lineView.right + h5LineLeftSpaceWidth;
    _fullOfficialAccountsName.textAlignment = NSTextAlignmentLeft;
    
    _iconButton.height = _officialAccountsInfoView.height;
    _iconButton.width = _lineView.left;
   
    CGSize nameSize = [_fullOfficialAccountsName.text textSizeWithFont:_fullOfficialAccountsName.font];
    _nameButton.width = nameSize.width + h5LineLeftSpaceWidth;
    _nameButton.height = _officialAccountsInfoView.height;
    _nameButton.left = _lineView.right;
    
    _followButton.centerY = _iconView.centerY;
    
//    _scrollToTopButton.width = _followButton.left - _nameButton.right;
//    _scrollToTopButton.height = _officialAccountsInfoView.height;
//    _scrollToTopButton.left = _nameButton.right;
}

- (void)backScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_ignorScrolling || self.officialAccountsInfoView.hidden) {
        return;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat increaseRatio = (offsetY - _positionY)/kSystemBarHeight;
    CGFloat decreaseRatio = (1 - increaseRatio);
    
    [self changeAlphaWithRatio:decreaseRatio];
    [self changeFrameWithRatio:increaseRatio];
    
    if (offsetY > _positionY) {
//        _scrollToTopButton.hidden = NO;
//        [self addStatusBarShot];
    }else {
//        _scrollToTopButton.hidden = YES;
//        [self removeStatusBarShot];
    }

    if (offsetY >= _positionY) {
        if (_nameLineOver && _fullOfficialAccountsName.alpha == 0) {
            [UIView animateWithDuration:0.1 animations:^{
                _officialAccountsName.alpha = 0;
                _fullOfficialAccountsName.alpha = 1;
            }];
        }
        [self moveToScrollSuperView];
    }else{
        if (_nameLineOver && _fullOfficialAccountsName.alpha == 1) {
            [UIView animateWithDuration:0.1 animations:^{
                _officialAccountsName.alpha = 1;
                _fullOfficialAccountsName.alpha = 0;
            }];
        }
        [self moveToScrollView];
    }
}

- (void)h5BackScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_ignorScrolling || self.officialAccountsInfoView.hidden) {
        return;
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat increaseRatio = (offsetY)/kSystemBarHeight;
    CGFloat decreaseRatio = (1 - increaseRatio);
    
    [self h5ChangeAlphaWithRatio:decreaseRatio];
    [self h5ChangeFrameWithRatio:increaseRatio];
    
    if (offsetY > 0) {
//        _scrollToTopButton.hidden = NO;
//        [self addStatusBarShot];
    }else {
//        _scrollToTopButton.hidden = YES;
//        [self removeStatusBarShot];
    }
}

//- (void)autoHideFakeStatusBar {
//    CGFloat offsetY = _backScrollView.contentOffset.y;
//    CGFloat divide = kSystemBarHeight/2.f;
//    if (offsetY > _positionY && offsetY < _positionY + divide) {
//        [_backScrollView setContentOffset:CGPointMake(0, _positionY) animated:YES];
//    }else if (offsetY >= _positionY + divide && offsetY < _positionY + kSystemBarHeight) {
//        [_backScrollView setContentOffset:CGPointMake(0, _positionY + kSystemBarHeight) animated:YES];
//    }
//}

/*
 状态栏截图
 */
//- (void)addStatusBarShot {
//    if (!self.needHideStatusBar) {
//        if (!_statusbarView) {
//            _statusbarView = [[UIView alloc] initWithFrame:CGRectMake(0, _positionY - kSystemBarHeight, kAppScreenWidth, kSystemBarHeight)];
//        }
//        _statusbarView.top = _positionY - kSystemBarHeight;
//        [_statusbarView addSubview:self.snapshotView];
//        [_statusbarView setClipsToBounds:YES];
//        if ([_h5Type isEqualToString:@"0"]) {
//            [_backScrollView addSubview:_statusbarView];
//        } else {
//            [_webView.superview addSubview:_statusbarView];
//        }
//        self.needHideStatusBar = YES;
//        _statusbarView.hidden = NO;
//        [self.controller setNeedsStatusBarAppearanceUpdate];
//    }
//}

//- (void)setNeedHideStatusBar:(BOOL)needHideStatusBar {
//    if (_needHideStatusBar != needHideStatusBar) {
//        if (needHideStatusBar) {
//            [self updateNavigatorStatusBarView];
//        }
//        _needHideStatusBar = needHideStatusBar;
//    }
//}

//- (UIView *)snapshotView {
//    if (!_snapshotView) {
//        _snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
//    }
//
//    return _snapshotView;
//}

//- (void)cropCurrentStatusBar {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self updateNavigatorStatusBarView];
//    });
//}

//- (void)updateNavigatorStatusBarView {
//    SNNavigationController * navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
//    if ([navigationController.currentViewController isKindOfClass:[SNGalleryBrowserController class]]) {
//        return;
//    }
//    UIView * tempV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSystemBarHeight)];
//    [tempV addSubview:[[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES]];
//    [tempV setClipsToBounds:YES];
//    [navigationController updateStatusBarShotView:tempV];
//}
//
//- (void)removeNavigatorStatusBarView {
//    SNNavigationController * navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
//    if ([navigationController.currentViewController isKindOfClass:[SNGalleryBrowserController class]]) {
//        return;
//    }
//    [navigationController updateStatusBarShotView:nil];
//}

- (UIView *)headImgThemeMaskView {
    
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if (!_headMask) {
            _headMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headImgWidth, headImgWidth)];
            _headMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        }
        return _headMask;
    }else{
        [_headMask removeFromSuperview];
        _headMask = nil;
        return nil;
    }
}

//- (void)removeStatusBarShot {
//    if (self.needHideStatusBar) {
//        self.needHideStatusBar = NO;
//        _statusbarView.hidden = YES;
//        [self.controller setNeedsStatusBarAppearanceUpdate];
//        [_snapshotView removeFromSuperview];
//        _snapshotView = nil;
//        [self removeNavigatorStatusBarView];
//    }
//}

- (void)dealloc {
    [_backScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [SNNotificationManager removeObserver: self];
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

#pragma mark - MySubDidChangeNotification
- (void)handleMySubDidChangeNotification:(id)sender {
    [self checkFollowedStatus];
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        // 关注成功
    } else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        /// 取消关注
    }
    [SNOfficialAccountsInfo checkFollowStatusWithSubId:_subId completed:^(SNFollowedStatus followedStatus) {
        self.followedStatus = followedStatus;
        if (followedStatus == SNFollowedStatusFollowing || followedStatus == SNFollowedStatusFriend) {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"增加推荐此搜狐号内容" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        [_loadingView stopAnimating];
        _followButton.hidden = NO;
        _loadingView.hidden = YES;
        _followButton.enabled = YES;
    }];
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer
//        || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer
        ) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"关注失败，请重试" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    _followButton.enabled = YES;
    [_loadingView stopAnimating];
    _followButton.hidden = NO;
    _loadingView.hidden = YES;
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    _followButton.enabled = YES;
    [_loadingView stopAnimating];
    _followButton.hidden = NO;
    _loadingView.hidden = YES;
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
    }
}

@end
