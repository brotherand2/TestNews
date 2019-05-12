//
//  SNAboutController.m
//  sohunews
//
//  Created by 李 雪 on 11-8-1.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNAboutController.h"
#import "SNSettingCellWithIndicatorOnly.h"
#import <objc/runtime.h>

@implementation SNAboutController

- (SNCCPVPage)currentPage {
    return more_about;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
    
    [self addHeaderView];
    [self addToolbar];
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"About",@"")]];
    CGSize titleSize = [NSLocalizedString(@"About",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
	UIImage *aboutImg		= [UIImage imageWithBundleName:@"about_logo.png"];
	aboutImgView	= [[UIImageView alloc] initWithImage:aboutImg];
    aboutImgView.bounds = CGRectMake(0,0,aboutImg.size.width, aboutImg.size.height);
    float originY = 44;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        originY = 64;
    }
    aboutImgView.center = CGPointMake(self.view.bounds.size.width/2, 38 + originY + aboutImg.size.height/2);
    aboutImgView.alpha = themeImageAlphaValue();
	[self.view addSubview:aboutImgView];
    
    NSString *strTextColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAboutViewTextColor];
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubHomeTableSectionTitleShadowColor];
    
	NSString *copyrightTitle	= [SNUtility copyrightText];
	UILabel *copyright	= [[UILabel alloc] init];
	copyright.text		= copyrightTitle;
	copyright.textColor = [UIColor colorFromString:strTextColor];
	copyright.backgroundColor = [UIColor clearColor];
	copyright.font      = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:9];
	copyright.shadowColor = [UIColor colorFromString:strColor];
	copyright.shadowOffset = CGSizeMake(0, 1);
	
	CGSize maximumSize = TTScreenBounds().size;//CGSizeMake(320,480);
	CGSize textSize = [copyrightTitle sizeWithFont:copyright.font
                                 constrainedToSize:maximumSize
                                     lineBreakMode:NSLineBreakByWordWrapping];
    
    
    float paddingY = 44;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        paddingY = 64;
    }
	CGRect frame = CGRectMake((self.view.frame.size.width - textSize.width)/2 ,self.view.frame.size.height - textSize.height - 10 - paddingY , textSize.width, textSize.height+2);
	
	copyright.frame	= frame;
	[self.view addSubview:copyright];
	
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleBuild];
    
	NSString *strVersion = [NSString stringWithFormat:@"Version %@ Build %@", version, build];
    _versionBtn = [[UIButton alloc] init];
    [_versionBtn setTitle:strVersion forState:UIControlStateNormal];
    [_versionBtn setTitleColor:[UIColor colorFromString:strTextColor] forState:UIControlStateNormal];
    [_versionBtn setTitleShadowColor:[UIColor colorFromString:strColor] forState:UIControlStateNormal];
	_versionBtn.titleLabel.shadowOffset = CGSizeMake(0, 1);
    _versionBtn.titleLabel.backgroundColor = [UIColor clearColor];
	_versionBtn.titleLabel.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:11];
    _versionBtn.frame = CGRectMake(0,copyright.frame.origin.y - 35 + 10,kAppScreenWidth,30);
    _versionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _versionBtn.tag = 0;//用作点击计数
    [_versionBtn addTarget:self action:@selector(clickVersion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_versionBtn];
    
	NSString *serviceNum	= @"客服电话 : 4000520613";
	UILabel *service		= [[UILabel alloc] init];
	service.text			= serviceNum;
	service.textColor		= [UIColor colorFromString:strTextColor];
    
	service.shadowColor = [UIColor colorFromString:strColor];
	service.shadowOffset = CGSizeMake(0, 1);
	service.backgroundColor = [UIColor clearColor];
	service.font            = [UIFont systemFontOfSize:14];
	textSize			= [serviceNum sizeWithFont:service.font
                        constrainedToSize:maximumSize
                            lineBreakMode:NSLineBreakByWordWrapping];
	frame				= CGRectMake((self.view.frame.size.width - textSize.width)/2
									 , copyright.frame.origin.y - 40 - textSize.height + 20
									 , textSize.width, textSize.height);
	service.frame		= frame;
	[self.view addSubview:service];
	
    
    CGFloat topMargin = (CGRectGetMinY(service.frame)- CGRectGetMaxY(aboutImgView.frame)-132-44-14)/2;
    
    rowsButtonView = [[SNMultiRowsButtonView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(aboutImgView.frame)+topMargin, self.view.bounds.size.width-20, 132+44)];
    rowsButtonView.delegate = self;
    [rowsButtonView setButtonTitles:@[@"推荐给好友",@"给我们评分",@"访问官网",@"手机搜狐"]];
    [self.view addSubview:rowsButtonView];
    
    if([UIScreen mainScreen].bounds.size.height>480){
        aboutImgView.top = aboutImgView.top +11;
    }
    
    [self updateTheme];
    
}

- (void)clickVersion
{
    int index = (int)_versionBtn.tag;
    index += 1;
    index %= 5;
    _versionBtn.tag = index;
    
    switch (index) {
        case 0:
        {
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
            NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleBuild];
            
            NSString *strVersion = [NSString stringWithFormat:@"Version %@ Build %@", version, build];
            [_versionBtn setTitle:strVersion forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [_versionBtn setTitle:[UIDevice deviceUDID] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            [_versionBtn setTitle:[NSString stringWithFormat:@"%d", [SNUtility marketID]] forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            [_versionBtn setTitle:[SNUtility getP1] forState:UIControlStateNormal];
        }
            break;
        case 4:
        {
            [_versionBtn setTitle:[SNAPI productId] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    [self openDebug];
}

-(void)openDebug{
    static int index = 0;
    if (index++>10) {
        index = 0;
        [SNUtility openProtocolUrl:kOpenDebugModeURL];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    aboutImgView=nil;
    rowsButtonView = nil;
    _actionMenuController.delegate = nil;
}


- (void)updateTheme {
    [self.headerView updateTheme];
    
    [rowsButtonView updateTheme];    
}

- (void)tapButton:(UIButton *)button atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self shareToFriends];
            break;
        case 1:
            [self kickOpenUrl];
            break;
        case 2:
            [self openURL];
            break;
        case 3:
            [self openWebURL:SNLinks_FixedUrl_SohuMobile];
            break;
        default:
            break;
    }
}


#pragma mark - SNMultiButtonViewDelegate
- (void)touchAtIndex:(NSInteger)index
{
    if (index==2) {
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://m_statement"] applyAnimated:YES] applyQuery:nil];
        [[TTNavigator navigator] openURLAction:urlAction];
        
    } else if (index==1){
        
        NSString *url = SNLinks_FixedUrl_3gk_Mediain;
        if([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
            url = SNLinks_FixedUrl_3gk_Mediain_night;
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"mediaCooperation", @""), @"title", url, @"url", nil];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://m_moreApp"] applyAnimated:YES] applyQuery:dict];
        [[TTNavigator navigator] openURLAction:urlAction];
        
    } else if (index==0){
        NSString *urlStr = SNLinks_FixedUrl_SohuMobile;
        [self openWebURL:urlStr];
    }
}


- (void)openWebURL:(NSString *)url
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setValue:url forKey:kLink];
    [query setValue:[NSNumber numberWithInt:NormalWebViewType] forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:query];
}

- (void)kickOpenUrl
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //fix: ios7打不开appStore评价的问题
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/sou-hu-xin-wen-quan-wang-du/id436957087?mt=8"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=436957087"]];
    }

    return;
}

- (void)openURL
{
    [self openWebURL:SNLinks_FixedUrl_3gk];
}

- (void)shareToFriends
{
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    [mDic setObject:@"more" forKey:SNNewsShare_LOG_type];
    [mDic setObject:@"sohu" forKey:SNNewsShare_disableIcons];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    _actionMenuController.shareLogType = @"more";
    _actionMenuController.delegate = self;
    _actionMenuController.disableLikeBtn = YES;
    _actionMenuController.disableMySNSBtn = YES;
    [_actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}



- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];

    [dicShareInfo setObject:NSLocalizedString(@"SMS share to friends", nil) forKey:kShareInfoKeyContent];
    [dicShareInfo setObject:NSLocalizedString(@"SMS share to friends", nil) forKey:kShareInfoKeyShareContent];
    [dicShareInfo setObject:NSLocalizedString(@"SMS share to friends", nil) forKey:@"title"];
    [dicShareInfo setObject:SNLinks_Domain_3gK forKey:@"url"];
    [dicShareInfo setObject:[NSString stringWithFormat:@"http://%@",SNLinks_Domain_3gK] forKey:@"webUrl"];
    return dicShareInfo;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

@end
