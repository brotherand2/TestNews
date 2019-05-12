//
//  SNSubInfoView.m
//  sohunews
//
//  Created by wang yanchen on 13-6-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubInfoView.h"
#import "SNDBManager.h"
#import "SNSoundManager.h"
#import "SNSubscribeCenterService.h"
#import "SNUserManager.h"
#import "SNOfficialAccountsInfo.h"
#import "SNNewsLoginManager.h"

@interface SNSubInfoView ()
{
    BOOL _isLoginSuccessDeal;
}

@end

@implementation SNSubInfoView

- (void)updateFollowedInfo {
    self.subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subObj.subId];
}

- (id)initWithSubInfoViewType:(SNSubInfoViewType)type {
    CGRect rect = CGRectZero;

    if (SNSubInfoViewTypeArticle == type) {
        rect = CGRectMake(0, 0,
                          kViewWidth_Article,
                          kViewHeight_Article);
    }
    else if (SNSubInfoViewTypeGallery == type) {
        rect = CGRectMake(0, 0,
                          kAppScreenWidth - 20,
                          kViewHeight_Gallery);
    }
    
    self = [super initWithFrame:rect];
    if (self) {
        _type = type;
        if (SNSubInfoViewTypeArticle == type) {
            self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
        }
        else if (SNSubInfoViewTypeGallery == type) {
            self.backgroundColor = [UIColor clearColor];
        }
        [SNNotificationManager addObserver:self
                                  selector:@selector(handleMySubDidChangeNotification:)
                                      name:kSubscribeCenterMySubDidChangedNotify
                                    object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme)
                                      name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size = CGSizeMake(kViewWidth_Article, kViewHeight_Article);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = SNSubInfoViewTypeArticle;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    if (SNSubInfoViewTypeArticle == _type)
        frame.size = CGSizeMake(kViewWidth_Article, kViewHeight_Article);
    else if (SNSubInfoViewTypeGallery == _type)
        frame.size = CGSizeMake(kAppScreenWidth - 20, kViewHeight_Gallery);
    [super setFrame:frame];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (_delegate) {
        _delegate = nil;
    }
}

- (void)setSubObj:(SCSubscribeObject *)subObj {
    if (_subObj != subObj) {
         //(_subObj);
        _subObj = subObj;
    }
    
    [self resetSubviews];
    [self setNeedsDisplay];
}

- (void)updateFollowedRelationship {
    [SNOfficialAccountsInfo checkFollowStatusWithSubId:self.subObj.subId completed:^(SNFollowedStatus followedStatus) {
        switch (followedStatus) {
            case SNFollowedStatusNone:
            {
                [_addFollowButton setTitle:@"关注" forState:UIControlStateNormal];
                [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
                break;
            }
            case SNFollowedStatusFollowing:
            {
                [_addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
                [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
//                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"增加推荐此搜狐号内容" toUrl:nil mode:SNCenterToastModeOnlyText];
                break;
            }
            case SNFollowedStatusFriend:
            {
                [_addFollowButton setTitle:@"互关" forState:UIControlStateNormal];
                [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
//                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"增加推荐此搜狐号内容" toUrl:nil mode:SNCenterToastModeOnlyText];
                break;
            }
            case SNFollowedStatusFollower:
            {
                [_addFollowButton setTitle:@"关注" forState:UIControlStateNormal];
                [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
                break;
            }
            case SNFollowedStatusSelf:
            {
                _addFollowButton.hidden = YES;
                break;
            }
            default:
                break;
        }
        [_loadingView stopAnimating];
        _loadingView.hidden = YES;
        _addFollowButton.hidden = NO;
    }];
}

- (void)updateTheme {
    [self resetSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    UIImage *bgImgae = nil;

    if (_type == SNSubInfoViewTypeGallery)
    {
        bgImgae = [UIImage themeImageNamed:@"subInfo_gallery_bg.png"];
    }
    
    if (bgImgae)
        [bgImgae drawInRect:rect];
    
    UIImage *iconBgImage = [UIImage themeImageNamed:@"subinfo_article_iconBg.png"];
    [iconBgImage drawInRect:_iconView.frame];

    if (_type == SNSubInfoViewTypeArticle)
        [self drawSubViewForArticle];
    else if (_type == SNSubInfoViewTypeGallery)
        [self drawSubViewForGallery];
}

#pragma mark - draw methods
- (void)drawSubViewForArticle {
    CGFloat startX = _iconView.right + (14 / 2), startY = (34 / 2);
    
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListDetailColor]] set];
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]];
        _subTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [self addSubview:_subTitleLabel];
    }
    _subTitleLabel.text = self.subObj.subName;
    _subTitleLabel.frame = CGRectMake(startX, startY, (378 / 2), (28 / 2 + 1));
}

- (void)drawSubViewForGallery {
    CGFloat startX = _iconView.right + (14 / 2), startY = 10 / 2;
    
    // todo theme color 翔鹤说组图  文字 全用白色
    [[UIColor whiteColor] set];
    UIImage *accImage = [UIImage imageNamed:@"icotoast_link_v5.png"];
    [_subTitleLabel removeFromSuperview];
    _subTitleLabel = nil;
    
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textColor = SNUICOLOR(kThemeText4Color);
        _subTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];

        [self addSubview:_subTitleLabel];
    }

    CGSize textSize = [self.subObj.subName sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    _subTitleLabel.text = self.subObj.subName;
    _subTitleLabel.size = CGSizeMake(textSize.width, (28 / 2 + 1));
    _subTitleLabel.centerY = self.height / 2;
    _subTitleLabel.left = startX;
    startY = _subTitleLabel.origin.y - 1;
    startX = _subTitleLabel.right + 7;
    [accImage drawAtPoint:CGPointMake(startX, startY)];
}

#pragma mark - private

- (void)resetSubviews {
    CGRect iconFrame = CGRectZero;
    CGFloat btnTop = 0, btnRight = 0;
    
    if (SNSubInfoViewTypeArticle == _type) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    }
    else if (SNSubInfoViewTypeGallery == _type) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    if (_type == SNSubInfoViewTypeArticle) {
        iconFrame = CGRectMake(kIconLeftMargin_Article,
                               self.height - kIconBottomMargin_Article - kIconSize_Article,
                               kIconSize_Article,
                               kIconSize_Article);
        btnTop = kBtnTopMargin_Article;
        btnRight = self.width - kBtnRightMargin_Article;
    }
    else if (_type == SNSubInfoViewTypeGallery) {
        iconFrame = CGRectMake(kIconLeftMargin_Gallery,
                               kIconTopMargin_Gallery,
                               kIconSize_Gallery,
                               kIconSize_Gallery);
        btnTop = kBtnTopMargin_Gallery;
        btnRight = self.width - kBtnRightMargin_Gallery;
    }
    
    if (!_iconView) {
        _iconView = [[SNWebImageView alloc] initWithFrame:iconFrame];
        _iconView.defaultImage = [UIImage imageNamed:kThemeImgPlaceholder2/*@"defaulticon.png"*/];
        [self addSubview:_iconView];
    }
    _iconView.alpha = themeImageAlphaValue();
    [_iconView loadUrlPath:self.subObj.subIcon];
    
    if (!_addFollowButton) {
        _addFollowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                      40,
                                                                      self.height)];
        _addFollowButton.backgroundColor = [UIColor clearColor];
        [_addFollowButton setTitle:@"关注" forState:UIControlStateNormal];
        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        _addFollowButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [_addFollowButton addTarget:self
                             action:@selector(addFollowAction:)
                   forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addFollowButton];
    }
    else {
        //_addFollowButton.hidden = NO;
        _addFollowButton.userInteractionEnabled = YES;
        //[_addFollowButton setImage:btnImage forState:UIControlStateNormal];
        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        [self setNeedsDisplay];
    }
    
    _addFollowButton.top = btnTop;
    _addFollowButton.right = btnRight;

    _addFollowButton.accessibilityLabel = @"添加关注";
    // 这里改ue了  如果订阅了 显示所属刊物的view  只是不显示订阅按钮
    //_addFollowButton.hidden = [self.subObj.isSubscribed isEqualToString:@"1"];
    
    _addFollowButton.userInteractionEnabled = YES;
    //如果已经订阅，则显示已定
    if([self.subObj.isSubscribed isEqualToString:@"1"])
    {
        [_addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
    }
    else
    {
        [_addFollowButton setTitle:@"关注" forState:UIControlStateNormal];
        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
    }
    if (!_maskButton) {
        _maskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                 _addFollowButton.left - 5,
                                                                 self.height)];
        [_maskButton addTarget:self
                        action:@selector(subDetailAction:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_maskButton];
    }
    _maskButton.accessibilityLabel = [NSString stringWithFormat:@"所属媒体%@ 点击查看媒体详情", self.subObj.subName];
}

#pragma mark - actions
- (void)loginSuccess {
    [self addFollowAction:_addFollowButton];
    _isLoginSuccessDeal = YES;
}

- (void)loginOnBack {
    if ([SNUserManager isLogin] && !_isLoginSuccessDeal) {
        [self loginSuccess];
    }
}


- (void)addFollowAction:(id)sender {
    
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (self.subObj) {
        BOOL isSub = [self.subObj.isSubscribed isEqualToString:@"1"];
        ///关注前必须登录
        if (![SNUserManager isLogin] && !isSub) {
            [SNUtility shouldUseSpreadAnimation:NO];
            NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
            NSValue* onbackMethod = [NSValue valueWithPointer:@selector(loginOnBack)];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method",onbackMethod,@"onBackMethod", self,@"delegate", [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
            //[SNUtility openLoginViewWithDict:dict];
            
            //wangshun login open
            [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111大图关注
                
                [self addFollowAction:sender];
            } Failed:nil];
            return;
        }
        
        if (!_loadingView) {
            _loadingView = [[SNWaitingActivityView alloc] init];
            _loadingView.center = _addFollowButton.center;
            [self insertSubview:_loadingView aboveSubview:_addFollowButton];
        }
        _loadingView.hidden = NO;
        [_loadingView startAnimating];
        _addFollowButton.hidden = YES;
   
        // 统计refer
        if (self.subObj.from != self.refer) self.subObj.from = self.refer;
        
        if (isSub) {
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
            [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:self.subObj];
        } else {
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:self.subObj];
        }
    }
}

- (void)subDetailAction:(id)sender {
    if (self.subTitleLabel.alpha <= 0 || self.subTitleLabel.hidden) {
        return;
    }
    
    [[SNSkinMaskWindow sharedInstance] updateStatusBarAppearanceWithLightContentMode:NO];
    if (self.subObj)
    {
        //打开刊物前停止音频播放
        [[SNSoundManager sharedInstance] stopAll];
       
        NSMutableDictionary * contextDic = [NSMutableDictionary dictionary];
        [contextDic setObject:[NSNumber numberWithInt:SNProfileRefer_Article_Subscribe] forKey:kRefer];
        [contextDic setObject:@"Newsid" forKey:kReferType];
        [contextDic setObject:self.newsId?:@"0" forKey:kReferValue];
        [contextDic setObject:[NSNumber numberWithBool:YES] forKey:kFromRollingChannelWebKey];
        
        // 首先通过link来打开 服务端控制
        if (self.subObj.link.length > 0 && [SNUtility openProtocolUrl:self.subObj.link context:contextDic])
        {
            if (_delegate && [_delegate respondsToSelector:@selector(subInfoViewDetailDidShow)])
            {
                [_delegate performSelector:@selector(subInfoViewDetailDidShow)];
            }
            return;
        }
        // 其次 看能否打开刊物详情页
        else
        {
            self.subObj.openContext = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.refer] forKey:kRefer];
            if ([self.subObj openDetail])
            {
                if (_delegate && [_delegate respondsToSelector:@selector(subInfoViewDetailDidShow)])
                {
                    [_delegate performSelector:@selector(subInfoViewDetailDidShow)];
                }
            }
        }
    }
}

- (void)handleMySubDidChangeNotification:(id)sender {
    self.subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subObj.subId];
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
//        [_loadingView stopAnimating];
//        _loadingView.hidden = YES;
//        // 订阅成功
//        _addFollowButton.hidden = NO;
//        [_addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
//        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
    } else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {

//        [_addFollowButton setTitle:@"关注" forState:UIControlStateNormal];
//        [_addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
    }
    [self updateFollowedRelationship];
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer
        || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer
        ) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"关注失败，请重试" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    [_loadingView stopAnimating];
    _addFollowButton.hidden = NO;
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        [_loadingView stopAnimating];
        _loadingView.hidden = YES;
        _addFollowButton.hidden = NO;
    }
}

@end
