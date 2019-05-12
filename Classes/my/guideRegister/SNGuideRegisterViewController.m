//
//  SNGuideRegister.m
//  sohunews
//
//  Created by jialei on 13-7-31.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNGuideRegisterViewController.h"

#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "NSDictionaryExtend.h"
#import "SNGuideRegisterManager.h"
#import "SNMyFavouriteManager.h"
#import "SNTimelinePostService.h"
#import "SNTimelineObjects.h"
#import "SNNewsLoginManager.h"

#define kShowIconWidth      160 / 2
#define kShowIconHeight     160 / 2
#define kBackPanelBottomMargin   80 / 2
#define kNameLabelGap       7 / 2
#define kTipTextGap         22 / 2
#define kInfoLabelTopMargin             (18 / 2)
#define kShowNameLabelFont  16
#define kShowTipLabelFont   17
#define kTipTextbgGap       20
#define kTipBubbleGap       23
#define kTipTextShowCount   14
#define TIP_CONTENT_LINE_HEIGHT     26
#define TIP_CONTENT_LINE_NUM        2

@interface SNGuideRegisterViewController ()
{
    SNGuideRegisterType _guideType;
    NSString *_pid;
    NSString *_link;
    NSString *_newsId;
    UIView* _backPanel;
}

@property (nonatomic, strong)NSString *pid;
@property (nonatomic, strong)NSString *link;
@property (nonatomic, strong)NSString *newsId;
@property (nonatomic, strong)NSString *actId;
@property (nonatomic, assign)int hasApproval;

@end

@implementation SNGuideRegisterViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        _showtitle = [query objectForKey:kRegisterInfoKeyTitle];
        _showIconUrl = [query objectForKey:kRegisterInfoKeyImageUrl];
        _showName = [query objectForKey:kRegisterInfoKeyName];
        _tipText = [query objectForKey:kRegisterInfoKeyText];
        NSNumber *type = [query objectForKey:kRegisterInfoKeyGuideType];
        _guideType = [type intValue];
        self.subId = [query stringValueForKey:kRegisterInfoKeySubId defaultValue:nil];
        self.pid = [query objectForKey:kRegisterInfoKeyUserPid];
        self.link = [query objectForKey:kRegisterInfoKeyUserLink];
        self.favouriteObject = [query objectForKey:kRegisterInfoKeyFavObject];
        self.newsId = [query objectForKey:kRegisterInfoKeyNewsId];
        self.actId = [query objectForKey:kRegisterInfoKeyActId];
        self.hasApproval = [query intValueForKey:kRegisterInfoKeyApprovalType defaultValue:0];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (SNCCPVPage)currentPage {
    return login_sohu;
}

#pragma mark - 
#pragma mark layout
- (void)initInfoPanel
{
    //if (_guideType == SNGuideRegisterTypeLogin)
    {
        [super initInfoPanel];
        self.headerView.sections = [NSArray arrayWithObject:_showtitle];
        _infoImageView.image = [UIImage imageNamed:@"login_info.png"];
        _infoImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
    }
    /*else
    {
        self.headerView.sections = [NSArray arrayWithObject:_showtitle];
        UIImage *sinaImage = [UIImage imageNamed:@"timeline_login_sina.png"];
        CGFloat loginBarHeight =  sinaImage.size.height + kBtnTitleFontSize + kInfoLabelFontSize + kBtnTitleTopMargin * 2 + kBtnTopMargin;
        CGFloat backPanelHeight = [UIScreen mainScreen].bounds.size.height - loginBarHeight - self.headerView.height - kBackPanelBottomMargin - kToolbarHeightWithoutShadow + kSystemBarHeight;
        CGFloat viewCenterX = [UIScreen mainScreen].bounds.size.width / 2;
        CGFloat subViewHeight = 0;
        
        _backPanel = [[UIView alloc]initWithFrame:CGRectMake(0, self.headerView.bottom, [UIScreen mainScreen].bounds.size.width, backPanelHeight)];
        _backPanel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_backPanel];
        _infoPanelBottom = _backPanel.bottom;
        
        //自媒体icon
        UIImage *iconBack = [UIImage themeImageNamed:@"userinfo_guide_icon_back.png"];
        _showIconBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _backPanel.height / 7, iconBack.size.width, iconBack.size.height)];
        _showIconBgView.centerX = viewCenterX;
        _showIconBgView.backgroundColor = [UIColor clearColor];
        _showIconBgView.image = iconBack;
        
        [_backPanel addSubview:_showIconBgView];
        subViewHeight = _showIconBgView.bottom;
        
        UIImage *defaultImage = [UIImage imageNamed:@"userinfo_guide_default_icon.png"];
        _showIconView = [[TTImageView alloc]initWithFrame:CGRectInset(_showIconBgView.frame, 10, 10)];
        _showIconView.image = defaultImage;
        if (_showIconUrl) {
            _showIconView.urlPath = _showIconUrl;
        }
        _showIconView.delegate = self;
        [_backPanel insertSubview:_showIconView aboveSubview:_showIconBgView];
        
        UIImage *markImage = [UIImage imageNamed:@"userinfo_guide_icon_mark.png"];
        _showIconMarkView = [[UIImageView alloc]initWithFrame:_showIconBgView.frame];
        _showIconMarkView.centerX = viewCenterX;
        _showIconMarkView.backgroundColor = [UIColor clearColor];
        _showIconMarkView.image = markImage;
        
        [_backPanel insertSubview:_showIconMarkView aboveSubview:_showIconView];
        
        //自媒体名称
        //    if (_showName && [_showName length] > 0)
        //    {
        UIFont *font = [UIFont systemFontOfSize:kShowNameLabelFont];
        _showNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, subViewHeight + kNameLabelGap,
                                                                  [UIScreen mainScreen].bounds.size.width, [SNUtility newsContentFontLineheight])];
        _showNameLabel.backgroundColor = [UIColor clearColor];
        _showNameLabel.textColor = SNUICOLOR(kGuideRegisterNameColor);
        _showNameLabel.centerX = viewCenterX;
        if ([_showName length] > 0) {
            _showNameLabel.text = _showName;
        }
        else
        {
            _showNameLabel.text = @"";
        }
        _showNameLabel.text = _showName;
        _showNameLabel.textAlignment = NSTextAlignmentCenter;
        _showNameLabel.font = font;

        [_backPanel addSubview:_showNameLabel];
        subViewHeight = _showNameLabel.bottom;
        //    }
        
        //引导登陆提示
        if (_tipText && [_tipText length] > 0)
        {
            UIFont *font = [UIFont systemFontOfSize:kShowTipLabelFont];
            UIImage *bgImage = [UIImage imageNamed:@"userinfo_guide_tip_bubble.png"];
            
            CGSize revokeSize = CGSizeMake(kShowTipLabelFont * kTipTextShowCount, CGFLOAT_MAX_CORE_TEXT);
            CGSize changeSize = [SNLabel sizeForContent:_tipText maxSize:revokeSize font:font.pointSize lineHeight:TIP_CONTENT_LINE_HEIGHT];
            if ([_tipText length] <= kTipTextShowCount)
                changeSize = [_tipText sizeWithFont:font];
            
            _tipTextLabel = [[SNLabel alloc]init];
            _tipTextLabel.text = _tipText;
            _tipTextLabel.backgroundColor = [UIColor clearColor];
            _tipTextLabel.font = font;
            _tipTextLabel.textAlignment = NSTextAlignmentCenter;
            _tipTextLabel.lineHeight = TIP_CONTENT_LINE_HEIGHT;
            int contentHeight = [SNLabel heightForContent:_tipText
                                                 maxWidth:changeSize.width
                                                     font:font.pointSize
                                               lineHeight:TIP_CONTENT_LINE_HEIGHT
                                             maxLineCount:TIP_CONTENT_LINE_NUM];
            _tipTextLabel.frame = CGRectMake(0, subViewHeight + kTipTextGap + kTipTextbgGap, changeSize.width, contentHeight);
            _tipTextLabel.centerX = viewCenterX;
            
            [_backPanel addSubview:_tipTextLabel];
            
            CGRect tipTect = CGRectMake(_tipTextLabel.origin.x - 15, _tipTextLabel.top - kTipBubbleGap, _tipTextLabel.width + 30, _tipTextLabel.height + 40);
            _showTipTextView = [[UIImageView alloc]initWithFrame:tipTect];
            _showTipTextView.image = bgImage;
            
            [_backPanel insertSubview:_showTipTextView belowSubview:_tipTextLabel];
        }
        btnOffsetY = 0;

    }*/
    
}

- (void)layoutSubView
{
    [super layoutSubView];
    
    _showNameLabel.centerY = _backPanel.height / 2;
    
    _showIconBgView.bottom = _showNameLabel.top - kNameLabelGap;
    _showIconMarkView.centerY = _showIconBgView.centerY;
    
    _tipTextLabel.top = _showNameLabel.bottom + kTipTextGap + kTipTextbgGap;
    _showTipTextView.top = _tipTextLabel.top - kTipBubbleGap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
     //(_showNameLabel);
     //(_showIconBgView);
     //(_showIconMarkView);
     //(_showNameLabel);
     //(_tipTextLabel);
     //(_backPanel);
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)dealloc
{
     //(_showtitle);
     //(_showIcon);
     //(_showName);
     //(_tipText);
     //(_showIconBgView);
     //(_showIconMarkView);
     //(_showNameLabel);
     //(_subId);
     //(_pid);
     //(_link);
     //(_tipTextLabel);
     //(_backPanel);
     //(_favouriteObject);
     //(_newsId);
}

#pragma mark - SNUserAccountLoginDelegate from base controller
- (void)loginSuccess
{
    BOOL needPop = [self guideLoginSuccessFunction];
    //需要返回的页面，执行返回操作
    if (needPop) {
        NSArray* array = self.flipboardNavigationController.viewControllers;
        for (UIViewController *vc in array) {
            if([vc isKindOfClass:[SNGuideRegisterViewController class]]) {
                NSInteger index = [array indexOfObject:vc] - 1;
                if (index >= 0) {
                    UIViewController* baseView = (UIViewController*)[array objectAtIndex:index];
                    [self.flipboardNavigationController popToViewController:baseView animated:YES];
                    return ;
                }
            }
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [SNNotificationManager postNotificationName:KGuideRegisterBackNotification object:nil];
    }
}

- (void)onBack:(id)sender
{
    [SNNotificationManager postNotificationName:KGuideRegisterBackNotification object:nil];
    [super onBack:sender];
}

- (void)loginActionWithOthers:(id)sender {
    // 这个就是进之前的用户中心

    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self,@"delegate", method,@"method" , nil];
    //[SNUtility openLoginViewWithDict:dic];

//    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self,@"delegate", method,@"method" , nil];
//    
//    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dic];
//    [[TTNavigator navigator] openURLAction:_urlAction];
    
    //wangshun login open
    [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000疑似废弃
        
        [SNGuideRegisterManager gotoLoginSuccessBackUrl];
    } Failed:nil];
    
}

//引导登陆后续操作
- (BOOL)guideLoginSuccessFunction
{
    switch (_guideType) {
        case SNGuideRegisterTypeSubscribe:
        {
            [SNGuideRegisterManager guideForSubscribe:self.subId];
            return YES;
        }
        case SNGuideRegisterTypeContentComment:
        {
            [SNGuideRegisterManager guideForContentComment];
            return YES;
        }
        case SNGuideRegisterTypeMediaComment:
        {
            [SNGuideRegisterManager guideForMediaComment];
            return YES;
        }
        case SNGuideRegisterTypeShake:
        {
            if (self.subId.length > 0) 
                [SNGuideRegisterManager guideForShake:self.subId];
            
            return NO;
        }
        case SNGuideRegisterTypeUsercenter:
        {
            [SNGuideRegisterManager guideForUserCenter:self.pid userSpace:self.link];
            return NO;
        }
        case SNGuideRegisterTypeUserAttention:
        {
            [SNGuideRegisterManager guideForAttention];
            return YES;
        }
        case SNGuideRegisterTypeLogin:
        {
            //[SNGuideRegisterManager showUserCenter];
            if([SNGuideRegisterManager showAddFriend])
                return NO;
            else
                return YES;
        }
        case SNGuideRegisterTypeFav:
        {   
            [SNGuideRegisterManager showMyFav];
            return NO;
        }
        case SNGuideRegisterTypeMessage:
        {
            [SNGuideRegisterManager showMyMessage];
            return NO;
        }
        case SNGuideRegisterTypeFavNews:
        {
            if (self.favouriteObject) {
                [[SNMyFavouriteManager shareInstance] addToMyFavouriteList:self.favouriteObject];
            }
            return YES;
        }
        case SNGuideRegisterTypeReport:
        {
            if (self.newsId) {
                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.newsId,@"newsId", nil];
                NSString *urlString = [NSString stringWithFormat:kUrlReport,@"1"];
                urlString = [SNUtility addParamP1ToURL:urlString];
                urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, self.newsId];
                [dic setObject:urlString forKey:kLink];
                [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
                [SNUtility openUniversalWebView:dic];
            }
            return NO;
        }
        case SNGuideRegisterTypeStar:
        {
            return YES;
        }
        case SNGuideRegisterTypeTrendApproval:
        {
            [[SNTimelinePostService sharedService] timelineTrendApproval:self.actId
                                                                    spid:self.pid
                                                            approvalType:self.hasApproval];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if (self.actId.length) {
                [dic setObject:self.actId forKey:kSNTLTrendKeyActId];
            }
            [SNNotificationManager postNotificationName:kTLTrendSendApprovalSucNotification object:dic];
            return YES;
        }
        default:
            return NO;
    }
}

- (NSString*)reSizeString:(NSString*)inStr strlines:(int)lines fontWidth:(int)width
{
    NSInteger count = [inStr length];
    if (count <= kTipTextShowCount)
        return inStr;
    
    UIFont *font = [UIFont systemFontOfSize:kShowTipLabelFont];
    NSString *firstLineStr = [inStr substringToIndex:kTipTextShowCount];
    if (!firstLineStr) 
        return firstLineStr;
    
    CGSize firstLineSize = [firstLineStr sizeWithFont:font];
    NSMutableString *outStr = [NSMutableString stringWithString:inStr];
    NSMutableString *insertStr = [NSMutableString stringWithString:@"\r\n"];
    NSInteger insertNum = (kTipTextShowCount * lines - count) / 2;
    int insertPos = (lines - 1) * kTipTextShowCount;

    if (firstLineSize.width < kShowTipLabelFont * kTipTextShowCount)
    {
        int lack = ((int)(kShowTipLabelFont * kTipTextShowCount - firstLineSize.width) % (int)width == 0) ?
                    (kShowTipLabelFont * kTipTextShowCount - firstLineSize.width) / width :
                    (kShowTipLabelFont * kTipTextShowCount - firstLineSize.width) / width - 1;
        insertNum -= lack;
    }

    for (int i = 0; i < insertNum; i++)
    {
        [insertStr appendString:@"    "];
    }
    [outStr insertString:insertStr atIndex:insertPos];

    return outStr;
}


@end
