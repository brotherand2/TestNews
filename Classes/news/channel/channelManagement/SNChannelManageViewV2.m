//
//  SNChannelManageViewV2.m
//  sohunews
//
//  Created by jojo on 13-10-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNChannelManageViewV2.h"
#import "SNChannelView.h"
#import "SNChannelLayoutManager.h"
#import "SNChannelManageContants.h"
#import "SNRollingNewsPublicManager.h"
#import "SNUserManager.h"
#import "SNChannelScrollTabBarDataSource.h"
#import "SNNewsReport.h"
#import "SNCorpusGuideView.h"
#import "SNSearchWebViewController.h"
#import "SNPopOverMenu.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNDBManager.h"
#import <JsKitFramework/JsKitFramework.h>
#import "SNCheckManager.h"

#define kEditMoveHeight  25
#define kEditChannelTabBarCount 4

@interface SNChannelSectionView : UIView {
    UILabel *titleLabel;
}

@property (nonatomic, assign) BOOL isDrawSeparateLine;
@property (nonatomic, strong) UILabel *pressChannelSortLabel;
@property (nonatomic, strong) UILabel *clickChannelAddLabel;

- (id)initWithFrame:(CGRect)frame Type:(BOOL)isMoreType;

@end

@implementation SNChannelSectionView

- (id)initWithFrame:(CGRect)frame Type:(BOOL)isMoreType {
    self = [self initWithFrame:frame];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = NO;
        self.backgroundColor = [UIColor clearColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kIcoNormalSettingLeft, kIconNormalSettingMyChannelTextTopDistance, self.width, kThemeFontSizeC + 2)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:kStaticMyChannelTextFont];
        titleLabel.isAccessibilityElement = NO;
        titleLabel.alpha = 0.0;
        [self addSubview:titleLabel];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setTitleWithString:(NSString *)title {
    if (title.length > 0) {
        titleLabel.text = title;
        if ([title isEqualToString:kMyChannelSectionTitle]) {
            titleLabel.textColor = SNUICOLOR(kThemeText2Color);
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
            self.pressChannelSortLabel.center = titleLabel.center;
            self.pressChannelSortLabel.right = kAppScreenWidth - kIcoNormalSettingLeft;
        } else {
            titleLabel.textColor = SNUICOLOR(kThemeText5Color);
            titleLabel.backgroundColor = SNUICOLOR(kThemeRed1Color);
            titleLabel.left = 0;
            titleLabel.top = titleLabel.top + 5;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.size = CGSizeMake(76, 21);
            self.clickChannelAddLabel.center = titleLabel.center;
            self.clickChannelAddLabel.right = kAppScreenWidth - kIcoNormalSettingLeft;
        }
    }
}

- (void)setTitleHidden:(BOOL)hidden {
    float delayTime = hidden ? 0.0 : 0.3;
    float animationDuration = hidden ? 0.1 : 0.3;
    [UIView animateWithDuration:animationDuration
                          delay:delayTime
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         titleLabel.alpha = hidden ? 0.f : 1.0f;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)drawTopCellSeperateLine:(CGRect)bounds margin:(float)margin {
    if (margin < 0) {
        margin = 0;
    }
    float lineW = 0.5f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
    CGContextSetFillColorWithColor(context, grayColor.CGColor);
    CGRect rect = CGRectMake(bounds.origin.x + margin, 8.0, bounds.size.width - margin * 2, lineW);
    CGContextFillRect(context, rect);
}

- (void)drawRect:(CGRect)rect {
    if (_isDrawSeparateLine) {
        [self drawTopCellSeperateLine:rect margin:0];
    }
}

- (UILabel *)pressChannelSortLabel {
    if (!_pressChannelSortLabel) {
        _pressChannelSortLabel = [[UILabel alloc] init];
        _pressChannelSortLabel.backgroundColor = [UIColor clearColor];
        _pressChannelSortLabel.textColor = SNUICOLOR(kThemeText2Color);
        _pressChannelSortLabel.text = kPressChannelSortText;
        _pressChannelSortLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [_pressChannelSortLabel sizeToFit];
        [self addSubview:_pressChannelSortLabel];
    }
    return _pressChannelSortLabel;
}

- (UILabel *)clickChannelAddLabel {
    if (!_clickChannelAddLabel) {
        _clickChannelAddLabel = [[UILabel alloc] init];
        _clickChannelAddLabel.backgroundColor = [UIColor clearColor];
        _clickChannelAddLabel.textColor = SNUICOLOR(kThemeText2Color);
        _clickChannelAddLabel.text = kClickAddChannelText;
        _clickChannelAddLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [_clickChannelAddLabel sizeToFit];
        [self addSubview:_clickChannelAddLabel];
    }
    return _clickChannelAddLabel;
}

- (void)updateTheme {
    if ([titleLabel.text isEqualToString:kMyChannelSectionTitle]) {
        titleLabel.textColor = SNUICOLOR(kThemeText2Color);
        self.pressChannelSortLabel.textColor = SNUICOLOR(kThemeText2Color);
    } else {
        titleLabel.textColor = SNUICOLOR(kThemeText5Color);
        titleLabel.backgroundColor = SNUICOLOR(kThemeRed1Color);
        self.clickChannelAddLabel.textColor = SNUICOLOR(kThemeText2Color);
    }
    [self setNeedsDisplay];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end

@protocol SNChannelSubscribeDelegate <NSObject>
- (void)addSubscribeChannelViewWithID:(NSString *)channelID;
- (void)deleteSubscribeChannelViewWithID:(NSString *)channelID;

- (void)addStockRequest:(NSString *)stockCode;
- (void)deleteStockRequest:(NSString *)stockCode;
@end

@interface SNChannelManageViewV2 () <SNChannelViewDelegate, UIScrollViewDelegate, SNChannelSubscribeDelegate> {
    SNChannelSectionView *_moreChannelSectionView;
    UIView *channelTabView;
    CGFloat channelViewCenterX;
    CGFloat channelViewCenterY;
    SNChannelScrollTabBarDataSource *_channelDatasource;
    NSTimeInterval _beginTouchEditTime;
    SNCorpusGuideView *_guideView;
}

@property (nonatomic, strong) UIScrollView *channelsContainer;
@property (nonatomic, strong) UIView *channelEmptyView;
@property (nonatomic, strong) UIImageView *channelEmptySmileImageView;
@property (nonatomic, strong) UILabel *channelEmptyLabel;
@property (nonatomic, strong) UIView *moreChannelSectionView;
@property (nonatomic, strong) SNChannelSectionView *myChannelSectionView;

@property (nonatomic, strong) SNChannelLayoutManager *myChannelLayoutManager;
@property (nonatomic, strong) SNChannelLayoutManager *moreChannelLayoutManager;
@property (nonatomic, strong) SNChannelLayoutHolder *currentMovingViewHolder;
@property (nonatomic, strong) SNChannelView *currentExpandingChannelView;

@property (nonatomic, strong) NSMutableArray *allLayoutHolders;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, strong) NSArray *tabBarImageNameArray;
@property (nonatomic, strong) NSArray *tabBarImageNamePressArray;
@property (nonatomic, strong) UIButton *moreItemButton;
@property (nonatomic, assign) BOOL isRollingNewsTab;
@property (nonatomic, strong) UITapGestureRecognizer *tapMoreItemBackGesture;
@property (nonatomic, assign) BOOL showChannelTag;
@property (nonatomic, strong) UIButton *channelSearchButton;
@property (nonatomic, strong) SNSearchWebViewController *searchWebViewController;
@property (nonatomic, assign) BOOL isEditFinish;
@end

@implementation SNChannelManageViewV2
@synthesize delegate;
@synthesize hasEditedChannel;
@synthesize shouldHideLocalsChannel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SNUICOLOR(kThemeBg3Color);
        
        CGFloat originY = 64;
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            originY = 88;
        }
        self.channelsContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, originY, self.width, self.height - originY - [self channelTabHeight])];
        
        self.channelsContainer.delegate = self;
        [self addSubview:self.channelsContainer];
        
        [self initEditChannelTabView];
        
        if ([[SNUserDefaults objectForKey:kSecondEnterChannelList] isEqualToString:@"1"]) {
            _guideView = [[SNCorpusGuideView alloc] init];
            [_guideView setGuideWithImageName:@"icotoast_message_v5.png" backImageName:@"ico_backgroundInChannel_v5.png" title:kCorpusGuideInChannelList];
            _guideView.left = kCorpusGuideLeftDistance;
            _guideView.bottom = channelTabView.top - 5;
            [self addSubview:_guideView];
            [SNUserDefaults setObject:@"2" forKey:kSecondEnterChannelList];
        } else {
            NSString *tag = [SNUserDefaults objectForKey:kSecondEnterChannelList];
            if (!tag) {
                [SNUserDefaults setObject:@"1" forKey:kSecondEnterChannelList];
            }
        }
        
        [SNNotificationManager addObserver:self selector:@selector(handleChannelManageViewBeginEditNotification:) name:kChannelManageBeginEditNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleChannelManageFinishEditNotification:) name:kChannelManageFinishEditNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(bottomBtnAction:) name:kChannelManagerViewCloseNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(processChannelFromSearchNotification:) name:kProcessChannelFromSearchNotification object:nil];
        
//        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([change[@"new"] isKindOfClass: NSClassFromString(@"NSConcreteValue")]) {
//        NSValue *value = change[@"new"];
//        if ([value CGPointValue].y == -64) {
//
//        }
//    }
//}
#pragma mark  editChannel tabbar
//5.2 add
- (void)initEditChannelTabView {
    channelTabView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight-[self channelTabHeight], kAppScreenWidth, [self channelTabHeight])];
    channelTabView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    channelTabView.alpha = kChannelEditTabBarAlpha;
    [self addSubview:channelTabView];
    [self addShadowForChannelTabView];
    NSArray *titleArray = nil;
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault]) {
        titleArray = [NSArray arrayWithObjects:@"夜间", @"收藏", @"设置", @"更多", nil];
    } else {
        titleArray = [NSArray arrayWithObjects:@"日间", @"收藏", @"设置", @"更多", nil];
    }
    
    _tabBarImageNameArray = [[NSArray alloc] initWithObjects:@"iconormalsetting_moon_v5.png", @"iconormalsetting_favorite_v5.png", @"iconormalsetting_setting_v5.png", @"iconormalsetting_more_v5.png", nil];
    _tabBarImageNamePressArray = [[NSArray alloc] initWithObjects:@"iconormalsetting_moonpress_v5.png", @"iconormalsetting_favoritepress_v5.png", @"iconormalsetting_settingpress_v5.png", @"iconormalsetting_morepress_v5.png", nil];
    for (NSInteger i = 0; i < kEditChannelTabBarCount; i++) {
        UIButton *button = (UIButton *)[self creatButtonWithTitle:[titleArray objectAtIndex:i] tag:i centerX:kChannelEditTabBarButtonWidth / 2 +kChannelEditTabBarButtonWidth * i imageName:[_tabBarImageNameArray objectAtIndex:i] imagePressName:[_tabBarImageNamePressArray objectAtIndex:i]];
        [channelTabView addSubview:button];
    }
}

- (void)addShadowForChannelTabView {
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_shadow_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, kAppScreenWidth, 2)];
    shadowImageView.image = image;
    [channelTabView addSubview:shadowImageView];
}

- (UIButton *)creatButtonWithTitle:(NSString *)title
                               tag:(NSInteger)tag
                           centerX:(CGFloat)centerX
                         imageName:(NSString *)imageName
                    imagePressName:(NSString *)imagePressName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.center = CGPointMake(centerX, [self channelTabHeight]/2.0);
    button.bounds = CGRectMake(0, 0, kChannelEditTabBarButtonWidth, [self channelTabHeight]);//宽度至少为图片和文字宽度,高度至少为图片和文字高度
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        button.center = CGPointMake(centerX, ([self channelTabHeight]-20)/2.0);
        button.bounds = CGRectMake(0, 0, kChannelEditTabBarButtonWidth, ([self channelTabHeight]-20));
    }
    button.tag = tag;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imagePressName] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tabButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.accessibilityLabel = [NSString stringWithFormat:@"%@", title];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    [button setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    
    CGPoint buttonCenter = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
    CGPoint endImageViewCenter = CGPointMake(buttonCenter.x, kChannelEditImageTopDistance + kMoreItemImageWidth / 2);
    CGPoint endTitleLabelCenter = CGPointMake(buttonCenter.x, kChannelEditImageTopDistance + kMoreItemImageWidth + kChannelEditBetweenImageAndLabelDistance + (kThemeFontSizeB + 2) / 2);
    
    CGPoint startImageViewCenter = button.imageView.center;
    CGPoint startTitleLabelCenter = button.titleLabel.center;
    button.imageEdgeInsets =
    UIEdgeInsetsMake(endImageViewCenter.y - startImageViewCenter.y,
                     endImageViewCenter.x - startImageViewCenter.x,
                     startImageViewCenter.y - endImageViewCenter.y,
                     startImageViewCenter.x - endImageViewCenter.x);
    button.titleEdgeInsets =
    UIEdgeInsetsMake(endTitleLabelCenter.y - startTitleLabelCenter.y,
                     endTitleLabelCenter.x - startTitleLabelCenter.x,
                     startTitleLabelCenter.y - endTitleLabelCenter.y,
                     startTitleLabelCenter.x - endTitleLabelCenter.x);
    return button;
}

- (void)tabButtonClick:(id)sender {
    if ((CFAbsoluteTimeGetCurrent() - _beginTouchEditTime) > 0 && (CFAbsoluteTimeGetCurrent() - _beginTouchEditTime) < 0.15) {
        return;
    }
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 0://夜间
        {
            if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault]) {
                [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeNight];
                [button setTitle:@"日间" forState:UIControlStateNormal];
                
                JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
                [jsKitStorage setItem:[NSNumber numberWithBool:YES] forKey:@"settings_nightMode"];
                
                [SNNewsReport reportADotGif:@"act=cc&page=12&topage=0&fun=43"];

                [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"1"];
                [DKNightVersionManager nightFalling];
                
                
                NSNumber *switche =  [SNUserDefaults objectForKey:kNewsThemeNightSwitch];
                BOOL switchValue = NO;
                if (switche == nil) {
                    switchValue = YES;//默认开关打开
                }
                else{
                    switchValue = [switche boolValue];
                }
                if (switchValue) {
                    //获取自动关闭夜间模式时间戳 (业务规定早上7点)
                    NSDate *date = [SNUtility getSettingValidTime:7];
                    [SNUserDefaults setObject:date forKey:kNewsThemeNightValidTime];
                }
                
            } else {
                [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeDefault];
                [button setTitle:@"夜间" forState:UIControlStateNormal];
                
                JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
                [jsKitStorage setItem:[NSNumber numberWithBool:NO] forKey:@"settings_nightMode"];
                
                [SNNewsReport reportADotGif:@"act=cc&page=12&topage=1&fun=43"];

                [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"0"];
                [DKNightVersionManager dawnComing];
            }
        }
            break;
        case 1://收藏
        {
            [self bottomBtnAction:nil];
            [self onClickCollection];
        }
            break;
        case 2://设置
        {
            [self bottomBtnAction:nil];
            [self onClickSetting];
        }
            break;
        case 3://更多
        {
            [self onClickMoreItem:sender];
            [button setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"iconormalsetting_morered_v5.png"] forState:UIControlStateNormal];
            _moreItemButton = button;
        }
            break;
        default:
            break;
    }
    
    _beginTouchEditTime = CFAbsoluteTimeGetCurrent();
}

- (void)onClickCollection {
    [SNUtility shouldUseSpreadAnimation:NO];
    if (_guideView) {
        [_guideView removeFromSuperview];
    }
    
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://homeCorpus"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

- (void)onClickSetting {
    [SNUtility shouldUseSpreadAnimation:NO];
    if (_guideView) {
        [_guideView removeFromSuperview];
    }
    
    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://setting"] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:_urlAction];
    
    NSArray *viewsArray = [UIApplication sharedApplication].keyWindow.subviews;
    for (UIView *view in viewsArray) {
        if (view.tag == 10000) {//_moreItemView
            [view removeFromSuperview];
            continue;
        }
    }
}

- (void)onClickMoreItem:(UIButton *)sender {
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNPopOverMenu showForSender:sender senderFrame:sender.frame withMenu:@[@"离线视频", @"活动", @"用户评论"] imageNameArray:@[@"icofloat_lxsp_v5.png", @"icofloat_hd_v5.png", @"icofloat_yjfk_v5.png"] doneBlock:^(NSInteger selectedIndex) {
        [self bottomBtnAction:nil];

        switch (selectedIndex) {
            case 0: {
                if ([[SNCheckManager sharedInstance] supportVideoDownload])
                {
                    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://videoDownloadViewController"] applyAnimated:YES];
                    [[TTNavigator navigator] openURLAction:_urlAction];
                } else {
                    TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES];
                    [[TTNavigator navigator] openURLAction:_urlAction];
                }

            }
                break;
            case 1: {
                NSString *actionURLString = nil;
                SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
                if ([themeManager.currentTheme isEqualToString:@"night"]) {
                    actionURLString = [SNUtility addParamModeToURL:kUrlNewActionList];
                    actionURLString = [actionURLString stringByAppendingString:@"&platformId=5"];
                } else {
                    actionURLString = [NSString stringWithFormat:@"%@?platformId=5", kUrlNewActionList];
                }
                actionURLString = [NSString stringWithFormat:@"%@&p1=%@", actionURLString, [SNUserManager getP1]];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:actionURLString, kLink, kActionName_ActivePage, kActionType, [NSNumber numberWithInteger:ActivityWebViewType], kUniversalWebViewType, nil];
                [SNUtility openUniversalWebView:dic];
            }
                break;
            case 2:{
                TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:YES];
                [[TTNavigator navigator] openURLAction:action];
            }
                break;
        }
        [sender setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"iconormalsetting_more_v5.png"] forState:UIControlStateNormal];
    } dismissBlock:^{
        [sender setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"iconormalsetting_more_v5.png"] forState:UIControlStateNormal];
    }];
}

- (SNCCPVPage)currentPage {
    return tab_me;
}

- (void)updateTheme {
    channelTabView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    self.backgroundColor = SNUICOLOR(kThemeBg3Color);
    _channelEmptySmileImageView.image = [UIImage imageNamed:@"iconormalsetting_smile_v5.png"];
    _channelEmptyLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    
    for (UIView *view in channelTabView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *tabButton = (UIButton *)view;
            [tabButton setImage:[UIImage imageNamed:[_tabBarImageNameArray objectAtIndex:tabButton.tag]] forState:UIControlStateNormal];
            [tabButton setImage:[UIImage imageNamed:[_tabBarImageNamePressArray objectAtIndex:tabButton.tag]] forState:UIControlStateHighlighted];
            [tabButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
            
            //在频道预览页面，启动app，自动切换日间模式时，日夜切换按钮文字不变bug wyy
            if (tabButton.tag == 0) {
                if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault])
                {
                    [tabButton setTitle:@"夜间" forState:UIControlStateNormal];
                }
                else{
                    [tabButton setTitle:@"日间" forState:UIControlStateNormal];
                }
            }
            
        } else if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            imageView.image = [UIImage imageNamed:@"icotitlebar_shadow_v5.png"];
        }
    }
    
    [self.moreChannelLayoutManager updateTheme];
    
    [self updateSeachChannelView];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    self.delegate = nil;
}

- (void)setOtherChannelsArray:(NSArray *)newOtherChannels
        andLocalChannelsArray:(NSArray *)newLocalChannels {
    [self.otherChannels removeAllObjects];
    [self.localChannels removeAllObjects];
    
    [self.otherChannels addObjectsFromArray:newOtherChannels];
    [self.localChannels addObjectsFromArray:newLocalChannels];
}

- (void)setSubedArray:(NSArray *)subedArray
      andUnsubedArray:(NSArray *)unsubedArray
     isRollingNewsTab:(BOOL)isRollingNewsTab {
    _isRollingNewsTab = isRollingNewsTab;
    
    [self.subedChannels removeAllObjects];
    [self.unsubedChannels removeAllObjects];
    
    [self.subedChannels addObjectsFromArray:subedArray];
    [self.unsubedChannels addObjectsFromArray:unsubedArray];
    
    NSMutableArray *otherChannels = [NSMutableArray array];
    NSMutableArray *localChannels = [NSMutableArray array];
    
    for (SNChannelManageObject *channnelObject in unsubedArray) {
        [otherChannels addObject:channnelObject];//不区分localType,避免本地和房产频道拖动至待选区不显示
        int localType = [channnelObject.localType intValue];
        if (localType == 1) {
            [localChannels addObject:channnelObject];
        }
    }
    
    [self setOtherChannelsArray:otherChannels andLocalChannelsArray:localChannels];
    
    [self setUpAllSubViews];
}

- (void)addUnsubedChannelsObject:(SNChannelLayoutHolder *)object {
    if ([object.guestView isKindOfClass:[SNChannelView class]]) {
        SNChannelManageObject *chObj = [(SNChannelView *)object.guestView chObj];
        if ([chObj.localType intValue] == 0) {
            [self.otherChannels addObject:chObj];
        } else {
            [self.localChannels addObject:chObj];
        }
    }
}

- (void)insertUnsubedChannelsObject:(SNChannelLayoutHolder *)object
                            atIndex:(int)index {
    if ([object.guestView isKindOfClass:[SNChannelView class]]) {
        SNChannelManageObject *chObj = [(SNChannelView *)object.guestView chObj];
        if (index >= 0 && index < self.otherChannels.count) {
            [self.otherChannels insertObject:chObj atIndex:index];
        } else {
            [self.otherChannels addObject:chObj];
        }
    }
}

- (void)removeUnsubedChannelObject:(SNChannelLayoutHolder *)object {
    if ([object.guestView isKindOfClass:[SNChannelView class]]) {
        SNChannelManageObject *chObj = [(SNChannelView *)object.guestView chObj];
        if ([chObj.localType intValue] == 0) {
            [self.otherChannels removeObject:chObj];
        } else {
            [self.localChannels removeObject:chObj];
        }
    }
}

- (NSArray *)subedArray {
    NSMutableArray *arr = [NSMutableArray array];
    for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
            SNChannelManageObject *chObj = [(SNChannelView *)hd.guestView chObj];
            if (chObj) {
                [arr addObject:chObj];
            }
        }
    }
    return arr;
}

- (NSArray *)unsubedArray {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObjectsFromArray:self.otherChannels];
    [arr addObjectsFromArray:self.localChannels];
    return arr;
}

- (NSMutableArray *)subedChannels {
    if (!_subedChannels) {
        _subedChannels = [[NSMutableArray alloc] init];
    }
    return _subedChannels;
}

- (NSMutableArray *)unsubedChannels {
    if (!_unsubedChannels) {
        _unsubedChannels = [[NSMutableArray alloc] init];
    }
    return _unsubedChannels;
}

- (NSMutableArray *)otherChannels {
    if (!_otherChannels) {
        _otherChannels = [[NSMutableArray alloc] init];
    }
    return _otherChannels;
}

- (NSMutableArray *)localChannels {
    if (!_localChannels) {
        _localChannels = [[NSMutableArray alloc] init];
    }
    return _localChannels;
}

- (NSMutableArray *)allLayoutHolders {
    if (!_allLayoutHolders) {
        _allLayoutHolders = [[NSMutableArray alloc] init];
    }
    return _allLayoutHolders;
}

- (UIView *)channelEmptyView {
    if (!_channelEmptyView) {
        _channelEmptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kEmptyChannelViewHeight)];
        _channelEmptyView.backgroundColor = [UIColor clearColor];
        _channelEmptyView.hidden = YES;
        _channelEmptyView.alpha = 0;
        [self.channelsContainer insertSubview:_channelEmptyView atIndex:0];
        _channelEmptyView.centerX = self.width / 2;
        
        _channelEmptySmileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconormalsetting_smile_v5.png"]];
        _channelEmptySmileImageView.centerX = _channelEmptyView.centerX;
        _channelEmptySmileImageView.top = kEmptyChannelImageViewTop;
        [_channelEmptyView addSubview:_channelEmptySmileImageView];
        
        _channelEmptyLabel = [[UILabel alloc] init];
        _channelEmptyLabel.text = @"更多精彩,敬请期待";
        _channelEmptyLabel.backgroundColor = [UIColor clearColor];
        _channelEmptyLabel.textAlignment = NSTextAlignmentCenter;
        _channelEmptyLabel.font = [UIFont systemFontOfSize:kStaticMyChannelTextFont];
        [_channelEmptyLabel sizeToFit];
        _channelEmptyLabel.centerX = _channelEmptyView.centerX;
        _channelEmptyLabel.top = _channelEmptySmileImageView.bottom + kEmptyChannelImageViewBellow;
        _channelEmptyLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
        [_channelEmptyView addSubview:_channelEmptyLabel];
    }
    return _channelEmptyView;
}

- (UIView *)moreChannelSectionView {
    if (!_moreChannelSectionView) {
        _moreChannelSectionView = [[SNChannelSectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, kIconNormalSettingMyChannelTextTopDistance + kThemeFontSizeC + 2) Type:YES];
        _moreChannelSectionView.isDrawSeparateLine = YES;
        [self.channelsContainer insertSubview:_moreChannelSectionView atIndex:0];
    }
    return _moreChannelSectionView;
}

- (SNChannelSectionView *)myChannelSectionView {
    if (!_myChannelSectionView) {
        if (self.isNotNewsTab) {
            _myChannelSectionView = [[SNChannelSectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, kIconNormalSettingMyChannelTextTopDistance + kThemeFontSizeC + 2) Type:YES];
        } else {
            _myChannelSectionView = [[SNChannelSectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, kIconNormalSettingMyChannelTextTopDistance + kThemeFontSizeC + 2) Type:NO];
        }
        _myChannelSectionView.isDrawSeparateLine = NO;
        [self.channelsContainer insertSubview:_myChannelSectionView atIndex:0];
    }
    return _myChannelSectionView;
}

- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    if (_isRollingNewsTab) {
        [_myChannelSectionView setTitleWithString: _isEditMode ? kMyChannelSectionTitle : @""];
        [_myChannelSectionView setTitleHidden: _isEditMode ? NO : YES];
    }
    
    [_moreChannelSectionView setTitleWithString: _isEditMode ? kMoreChannelSectionTitle : @""];
    [_moreChannelSectionView setTitleHidden: _isEditMode ? NO : YES];
}

- (void)createMoreChannelView {
    NSMutableArray *unsubedChannelsArray = self.otherChannels;
    for (SNChannelManageObject *chObj in unsubedChannelsArray) {
        SNChannelView *chView = [self.moreChannelLayoutManager buildChannelViewWithChannelObj:chObj];
        chView.delegate = self;
        chView.isSelected = NO;
        chView.editMode = self.isEditMode;
        [self.channelsContainer addSubview:chView];
        
        SNChannelLayoutHolder *aHd = [self.moreChannelLayoutManager appendAGuestView:chView];
        if (aHd) {
            [self.allLayoutHolders addObject:aHd];
        }
    }
    
    if (!_isRollingNewsTab) {
        self.isEditMode = YES;
    }
    
    [self.moreChannelLayoutManager calculateAllGuestViews];
    [self.moreChannelLayoutManager layoutAllGuestViews];
    
    int startY = self.moreChannelLayoutManager.startY + self.moreChannelLayoutManager.totalHeight;
    
    if (self.moreChannelLayoutManager.guests.count == 0) {
        self.channelEmptyView.hidden = NO;
        self.channelEmptyView.alpha = 1;
        startY = self.myChannelLayoutManager.startY + self.myChannelLayoutManager.totalHeight;
        self.channelEmptyView.top = startY;
        _channelSearchButton.bottom = startY + kEmptyChannelViewHeight + 17.0;
        self.channelsContainer.contentSize = CGSizeMake(self.channelsContainer.width, startY + kEmptyChannelViewHeight + 66.0);
    } else {
        self.channelEmptyView.alpha = 0.0f;
        self.channelsContainer.contentSize = CGSizeMake(self.channelsContainer.width, startY + kEmptyChannelViewHeight - 100);
    }    
}

- (UILabel *)addHeadLabelForChannel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = SNUICOLOR(kThemeRed1Color);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    label.text = title;
    [label sizeToFit];
    return label;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.currentExpandingChannelView) {
        [self.currentExpandingChannelView showExpanding:NO];
        self.currentExpandingChannelView = nil;
    }
}

#pragma mark - SNChannelViewDelegate
- (void)channelViewDidStartMove:(SNChannelView *)channelView {
    channelViewCenterX = channelView.centerX;
    channelViewCenterY = channelView.centerY;
    [self.channelsContainer setScrollEnabled:NO];
    if (channelView.isSubed) {
        self.hasEditedChannel = YES;
    }
    
    SNChannelLayoutHolder *hdFound = nil;
    hdFound = [self.myChannelLayoutManager removeAGuestView:channelView];
    if (!hdFound) {
        hdFound = [self.moreChannelLayoutManager removeAGuestView:channelView];
        [self removeUnsubedChannelObject:hdFound];
    }
    
    self.currentMovingViewHolder = hdFound;
    [self.channelsContainer bringSubviewToFront:channelView];
    //修改第一个频道字体颜色
    for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
        SNChannelView *chView = (SNChannelView *)hd.guestView;
        if ([chView.chObj.channelTop isEqualToString:kHomePageChannelTop]) {
            chView.titleLabel.textColor = SNUICOLOR(kThemeText4Color);
        }
    }
}

- (void)channelViewDidMoved:(SNChannelView *)channelView {
    if (!channelView.titleMarkImageView.hidden) {
        self.showChannelTag = YES;
        channelView.titleMarkImageView.hidden = YES;
    }
    CGFloat delta = _moreChannelSectionView.centerY;
    BOOL needOutLine = NO;
    BOOL isReposition = YES;
    if (channelView.centerY <= delta) {
        int index = [self.myChannelLayoutManager receiveHitAtPoint:channelView.center];
        needOutLine = (index != -1 && index >= 0);
    } else {
        [self.myChannelLayoutManager clearBlankOutline];
        if (!channelView.isSubed) {
            isReposition = channelView.isMoveOut;
        }
    }
    
    if (channelView.centerY < self.channelsContainer.contentOffset.y + 60) {
        int offsetY = channelView.centerY - 60;
        offsetY = MAX(offsetY, 0);
        [self.channelsContainer setContentOffset:CGPointMake(0, offsetY) animated:NO];
    }
    if (channelView.centerY + 60 > self.channelsContainer.contentOffset.y + self.channelsContainer.frame.size.height) {
        int offsetY = channelView.centerY + 60 - self.channelsContainer.frame.size.height;
        int maxOffsetY = self.channelsContainer.contentSize.height > self.channelsContainer.frame.size.height ?
        self.channelsContainer.contentSize.height - self.channelsContainer.frame.size.height : 0;
        offsetY = MIN(offsetY, maxOffsetY);
        [self.channelsContainer setContentOffset:CGPointMake(0, offsetY) animated:NO];
    }
    
    [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
        if (isReposition) {
            [self rePositionAllSubviews];
            [self.moreChannelLayoutManager removeEmptyCategoryLabel];
        }
    } completion:^(BOOL finished) {
        [self.myChannelLayoutManager showPositionOutLine:needOutLine animated:YES];
    }];
}

- (void)channelViewDidEndMove:(SNChannelView *)channelView {
    self.moreChannelLayoutManager.isChannelMoveOut = channelView.isMoveOut;
    if (self.showChannelTag) {
        channelView.titleMarkImageView.hidden = NO;
        self.showChannelTag = NO;
    }
    [channelView showExpanding:NO];
    [self.channelsContainer setScrollEnabled:YES];

    CGFloat delta = _moreChannelSectionView.centerY;
    if (channelView.centerY <= delta) {
        // 订阅的频道  排序
        if (channelView.isSubed) {
            int index = [self.myChannelLayoutManager receiveHitAtPoint:channelView.center];
            // 如果index 为 -1 则 应该是有强制置顶的频道
            if (!self.currentMovingViewHolder) {
                self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
            }
            [self.myChannelLayoutManager insertAGuestViewHolder:self.currentMovingViewHolder atIndex:index];
        }
        // 未订阅的频道 订阅
        else {
            int index = [self.myChannelLayoutManager receiveHitAtPoint:channelView.center];
            if (!self.currentMovingViewHolder) {
                self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
            }
            SNChannelView *movingView = (SNChannelView *)self.currentMovingViewHolder.guestView;
            movingView.chObj.isSubed = @"1";
            movingView.isSubed = YES;
            self.currentMovingViewHolder.guestView = movingView;
            
            self.hasEditedChannel = YES;
            
            [self.myChannelLayoutManager insertAGuestViewHolder:self.currentMovingViewHolder atIndex:index];
            channelView.chObj.isSubed = @"1";
            channelView.isSubed = YES;
            [channelView showEditMode:YES];
            
            //针对小说频道做一些特殊处理
            if ([channelView.chObj.ID isEqualToString:@"960415"]) {
                //如果订阅小说频道, 清理一下小说的缓存数据
                [[SNDBManager currentDataBase] clearRollingEditNewsListByChannelId:channelView.chObj.ID];
            }
        }
    } else {
        //可排序不可删除
        if ([channelView.chObj.channelTop isEqualToString:kBanChannelMoveToUnSub]) {
            if (!self.currentMovingViewHolder) {
                self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
            }
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"该频道无法删除" toUrl:nil mode:SNCenterToastModeWarning];
            [self.myChannelLayoutManager appendAGuestViewHolder:self.currentMovingViewHolder];
        } else {
            // 订阅的频道 退订
            if (channelView.isSubed) {
                if (!self.currentMovingViewHolder) {
                    self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
                }
                
                if ([self.myChannelLayoutManager totalCountOfChannelView] < kChannelMininumChannelCount) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"请至少保留%d个频道", kChannelMininumChannelCount] toUrl:nil mode:SNCenterToastModeOnlyText];
                    [self.myChannelLayoutManager appendAGuestViewHolder:self.currentMovingViewHolder];
                } else {
                    SNChannelView *movingView  = (SNChannelView *)self.currentMovingViewHolder.guestView;
                    movingView.chObj.isSubed = @"0";
                    movingView.isSubed = NO;
                    if ([movingView.chObj.channelCategoryName isEqualToString:kMyChannelTitle]) {//推荐频道
                        movingView.chObj.channelCategoryID = @"2";
                    }
                    
                    self.currentMovingViewHolder.guestView = movingView;
                    [self.moreChannelLayoutManager appendAGuestViewHolder:self.currentMovingViewHolder];
                    [self addUnsubedChannelsObject:self.currentMovingViewHolder];
                    
                    channelView.chObj.isSubed = @"0";
                    channelView.isSubed = NO;
                    [channelView showEditMode:NO];
                    
                    // 处理当前频道选中状态
                    if (channelView.isSelected && [channelView.chObj.ID isEqualToString:self.currentSelectedChannelId]) {
                        channelView.isSelected = NO;
                        [self selectFirstChannel];
                    }
                }
            }
            // 为订阅的频道 不能排序 什么也不做
            else {
                if (!self.currentMovingViewHolder) {
                    self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
                }
                
                if (!channelView.isMoveOut) {
                    int index = [self.moreChannelLayoutManager receiveHitAtPoint:channelView.center];
                    [self.moreChannelLayoutManager insertAGuestViewHolder:self.currentMovingViewHolder atIndex:index];
                    [self insertUnsubedChannelsObject:self.currentMovingViewHolder atIndex:index];
                } else {
                    [self.moreChannelLayoutManager appendAGuestViewHolder:self.currentMovingViewHolder];
                    [self addUnsubedChannelsObject:self.currentMovingViewHolder];
                }
            }
        }
    }
    
    [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
        if (channelViewCenterX != channelView.centerX || channelViewCenterY != channelView.centerY) {
            [self rePositionAllSubviews];
            [self.moreChannelLayoutManager removeEmptyCategoryLabel];
        }
     
        //修改第一个频道字体颜色
        for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
            SNChannelView *chView = (SNChannelView *)hd.guestView;
            if ([chView.chObj.channelTop isEqualToString:kHomePageChannelTop]) {
                if (chView.isSelected) {
                    chView.titleLabel.textColor = SNUICOLOR(kThemeRed1Color);
                }
                else {
                    chView.titleLabel.textColor = SNUICOLOR(kThemeText4Color);
                }
            }
        }
    } completion:^(BOOL finished) {
        [self.myChannelLayoutManager showPositionOutLine:NO animated:NO];
        [self checkIfNeedChannelEmptyView];
    }];
}

- (void)channelViewDidExpading:(SNChannelView *)channelView {
    self.currentExpandingChannelView = channelView;
}

- (BOOL)channelViewShouldActiveEditModeAfterLongPressed:(SNChannelView *)channelView {
    // change to edit mode
    [SNNotificationManager postNotificationName:kChannelManageDidBeginEditModeNotification object:self.delegate];
    return YES;
}

- (void)channelViewDidTapped:(SNChannelView *)channelView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelManageViewDidSelectChannel:)]) {
        // 如果没有订阅 帮用户订阅该频道
        if (!channelView.isSubed) {
            if (!_isRollingNewsTab) {
                [self processChannelView:channelView];
                [self.delegate channelManageViewDidSelectChannel:channelView.chObj];
            } else {
                [self clickUnSubedChannelView:channelView];
            }
        } else {
            if ([channelView.chObj.channelType isEqualToString:@"8"]) {
                [SNUserDefaults setObject:@"0" forKey:@"slideToSubscribe"];
            }
            [self.delegate channelManageViewDidSelectChannel:channelView.chObj];
        }
    }
}

- (void)channelViewDidSelectDelete:(SNChannelView *)channelView {
    if (channelView.isSubed) {
        self.hasEditedChannel = YES;
        if ([self.myChannelLayoutManager totalCountOfChannelView] - 1 < kChannelMininumChannelCount) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"请至少保留%d个频道", kChannelMininumChannelCount] toUrl:nil mode:SNCenterToastModeOnlyText];
            return;
        }
        channelView.isSubed = NO;
        channelView.chObj.isSubed = @"0";
        [channelView showEditMode:NO];
        SNChannelLayoutHolder *hd = [self.myChannelLayoutManager removeAGuestView:channelView];
        [self.moreChannelLayoutManager appendAGuestViewHolder:hd];
        [self addUnsubedChannelsObject:hd];
        
        // 处理当前频道选中状态
        if (channelView.isSelected && [channelView.chObj.ID isEqualToString:self.currentSelectedChannelId]) {
            channelView.isSelected = NO;
            [self selectFirstChannel];
        }
        
        [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
            [self rePositionAllSubviews];
        } completion:^(BOOL finished) {
            [self.myChannelLayoutManager showPositionOutLine:NO animated:NO];
        }];
    }
}

- (void)resetChannelMoveOut {
    self.moreChannelLayoutManager.isChannelMoveOut = YES;
}

#pragma mark process channel preview
- (void)processChannelPreview:(SNChannelView *)channelView {
    if (NO) {//没有频道预览页，直接打开频道页
        [self processChannelView:channelView];
        [self.delegate channelManageViewDidSelectChannel:channelView.chObj];
    }
    else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:channelView.titleLabel.text, kTitle, channelView.chObj.ID, @"channelId", channelView.chObj.channelCategoryID, @"categoryId", self, @"delegate", [NSNumber numberWithInteger:ChannelPreviewWebViewType], kUniversalWebViewType, nil];
        [SNUtility openUniversalWebView:dict];
    }
}

- (void)processChannelView:(SNChannelView *)channelView {
    channelView.isSubed = YES;
    channelView.chObj.isSubed = @"1";
    self.hasEditedChannel = YES;
    
    SNChannelLayoutHolder *hd = [self.moreChannelLayoutManager removeAGuestView:channelView];
    if (!hd) {
        hd = [self layoutHolderForChannelView:channelView];
    }
    [self removeUnsubedChannelObject:hd];
    [self.myChannelLayoutManager appendAGuestViewHolder:hd];
    
    if (!_isRollingNewsTab) {
        // 处理当前频道的选中状态
        self.currentSelectedChannelId = channelView.chObj.ID;
        for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
            if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
                SNChannelView *chView = (SNChannelView *)hd.guestView;
                chView.isSelected = [chView.chObj.ID isEqualToString:self.currentSelectedChannelId];
            }
        }
    }
}

- (void)clickUnSubedChannelView:(SNChannelView *)channelView {
    self.hasEditedChannel = YES;
    
    NSInteger clickTimes = [SNUserDefaults integerForKey:kClickUnSubedChannelKey];
    clickTimes++;
    [SNUserDefaults setInteger:clickTimes forKey:kClickUnSubedChannelKey];
    
    SNChannelLayoutHolder *hdFound = nil;
    hdFound = [self.myChannelLayoutManager removeAGuestView:channelView];
    if (!hdFound) {
        hdFound = [self.moreChannelLayoutManager removeAGuestView:channelView];
        [self removeUnsubedChannelObject:hdFound];
    }
    
    int index = [self.myChannelLayoutManager receiveHitAtPoint:channelView.center];
    self.currentMovingViewHolder = [self layoutHolderForChannelView:channelView];
    SNChannelView *movingView = (SNChannelView *)self.currentMovingViewHolder.guestView;
    movingView.chObj.isSubed = @"1";
    movingView.isSubed = YES;
    self.currentMovingViewHolder.guestView = movingView;
    
    [self.myChannelLayoutManager insertAGuestViewHolder:self.currentMovingViewHolder atIndex:index];
    channelView.chObj.isSubed = @"1";
    channelView.isSubed = YES;
    [channelView showEditMode:YES];
    
    //针对小说频道做一些特殊处理
    if ([channelView.chObj.ID isEqualToString:@"960415"]) {
        //如果订阅小说频道, 清理一下小说的缓存数据
        [[SNDBManager currentDataBase] clearRollingEditNewsListByChannelId:channelView.chObj.ID];
    }
    
    [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
        [self rePositionAllSubviews];
        [self.moreChannelLayoutManager removeEmptyCategoryLabel];
    } completion:^(BOOL finished) {
        [self.myChannelLayoutManager showPositionOutLine:NO animated:NO];
        [self checkIfNeedChannelEmptyView];
    }];
}

#pragma mark subscribe channelView delegate
- (void)addSubscribeChannelViewWithID:(NSString *)channelID {
    //针对小说频道做一些特殊处理
    if ([channelID isEqualToString:@"960415"]) {
        //如果订阅小说频道, 清理一下小说的缓存数据
        [[SNDBManager currentDataBase] clearRollingEditNewsListByChannelId:channelID];
    }
    SNChannelView *channelView = nil;
    for (SNChannelLayoutHolder *hd in self.moreChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
            channelView = (SNChannelView *)hd.guestView;
            if ([channelView.chObj.ID isEqualToString:channelID]) {
                break;
            }
        }
    }
    [self processChannelView:channelView];
    [self rePositionAllSubviews];
}

- (void)processChannelFromSearchNotification:(NSNotification *)notification {
    [self processOldChannels];
    
    _channelDatasource = [[SNChannelScrollTabBarDataSource alloc] initWithController:nil];
    [_channelDatasource loadFromCache];
    NSArray *channels = _channelDatasource.model.channels;
    NSMutableArray *subed = [NSMutableArray array];
    NSMutableArray *unsubed = [NSMutableArray array];
    for (SNChannel *ch in channels) {
        SNChannelManageObject *obj = [[SNChannelManageObject alloc] initWithObj:ch type:SNChannelManageObjTypeChannel];
        obj.addNew = ch.add;
        if ([obj.isSubed isEqualToString:@"1"]) {
            [subed addObject:obj];
        }
        else {
            [unsubed addObject:obj];
        }
    }
    
    [self setSubedArray:subed andUnsubedArray:unsubed isRollingNewsTab:YES];
}

- (void)processOldChannels {
    if ([self.subedArray count] == 0) {
        return;
    }
    
    for (UIView *view in self.channelsContainer.subviews) {
        if ([view isKindOfClass:[SNChannelView class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self.allLayoutHolders removeAllObjects];
}

- (void)deleteSubscribeChannelViewWithID:(NSString *)channelID {
    SNChannelView *channelView = nil;
    for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
            channelView = (SNChannelView *)hd.guestView;
            if ([channelView.chObj.ID isEqualToString:channelID]) {
                break;
            }
        }
    }
    [self channelViewDidSelectDelete:channelView];
}

#pragma mark - actions

- (void)bottomBtnAction:(id)sender {
    [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelManageViewWillClose:)]) {
        [self.delegate channelManageViewWillClose:self];
    }
}

- (void)handleChannelManageViewBeginEditNotification:(id)sender {
    if (self.isEditFinish) {
        return;
    }

    for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
        SNChannelView *chView = (SNChannelView *)hd.guestView;
        chView.editMode = YES;
        [chView showEditMode:YES];
    }
    
    for (SNChannelLayoutHolder *hd in self.moreChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[UILabel class]]) {
            continue;
        }
        SNChannelView *chView = (SNChannelView *)hd.guestView;
        chView.editMode = YES;
    }
    
    CGSize channelContentSize = self.channelsContainer.contentSize;
    self.channelsContainer.contentSize = channelContentSize;
    
    self.isEditMode = YES;
}

- (void)handleChannelManageFinishEditNotification:(id)sender {
    for (SNChannelLayoutHolder *hd in self.myChannelLayoutManager.guests) {
        SNChannelView *chView = (SNChannelView *)hd.guestView;
        chView.editMode = NO;
        [chView showEditMode:NO];
    }
    
    for (SNChannelLayoutHolder *hd in self.moreChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[UILabel class]]) {
            continue;
        }
        SNChannelView *chView = (SNChannelView *)hd.guestView;
        chView.editMode = NO;
    }
    
    CGSize channelContentSize = self.channelsContainer.contentSize;
    channelContentSize.height -= kEditMoveHeight;
    self.channelsContainer.contentSize = channelContentSize;
    
    self.isEditMode = NO;
    self.isEditFinish = YES;
}

#pragma mark - private

- (void)setUpAllSubViews {
    CGFloat startY = 0;
    self.myChannelLayoutManager = [[SNChannelLayoutManager alloc] init];
    self.myChannelLayoutManager.channelsContainer = self.channelsContainer;
    self.myChannelLayoutManager.startY = startY;
    self.myChannelSectionView.top = startY;
    self.myChannelLayoutManager.isMyChannelManager = YES;
    
    for (SNChannelManageObject *chObj in self.subedChannels) {
        SNChannelView *chView = [self.myChannelLayoutManager buildChannelViewWithChannelObj:chObj];
        chView.delegate = self;
        chView.isSelected = [chObj.ID isEqualToString:self.currentSelectedChannelId];
        [self.channelsContainer addSubview:chView];
        
        SNChannelLayoutHolder *aHd = [self.myChannelLayoutManager appendAGuestView:chView];
        if (aHd) {
            [self.allLayoutHolders addObject:aHd];
        }
    }
    if (!_isRollingNewsTab) {
        self.myChannelLayoutManager.topMargin = kIconNormalSettingMyChannelTextTopDistance;
    }
    
    [self.myChannelLayoutManager calculateAllGuestViews];
    [self.myChannelLayoutManager layoutAllGuestViews];

    startY = self.myChannelLayoutManager.startY + self.myChannelLayoutManager.totalHeight;
    
    self.moreChannelSectionView.top = startY;
    
    self.moreChannelLayoutManager = [[SNChannelLayoutManager alloc] init];
    self.moreChannelLayoutManager.channelsContainer = self.channelsContainer;
    self.moreChannelLayoutManager.startY = startY;
    self.moreChannelLayoutManager.isMyChannelManager = NO;
    [self createMoreChannelView];
    [self creatChannelSearchButton];
}

- (void)rePositionAllSubviews {
    if (!_isRollingNewsTab) {
        self.myChannelLayoutManager.topMargin = kIconNormalSettingMyChannelTextTopDistance;
    }
    
    [self.myChannelLayoutManager calculateAllGuestViews];
    [self.myChannelLayoutManager layoutAllGuestViews];
    
    CGFloat startY = self.myChannelLayoutManager.startY + self.myChannelLayoutManager.totalHeight;
    _moreChannelSectionView.top = startY;
    self.moreChannelLayoutManager.startY = startY;
    [self.moreChannelLayoutManager calculateAllGuestViews];
    [self.moreChannelLayoutManager layoutAllGuestViews];
    
    startY = self.moreChannelLayoutManager.startY + self.moreChannelLayoutManager.totalHeight;
    self.channelsContainer.contentSize = CGSizeMake(self.channelsContainer.width, startY + kEmptyChannelViewHeight-100);
    [self creatChannelSearchButton];
}

- (void)checkIfNeedChannelEmptyView {
    if (self.moreChannelLayoutManager.guests.count == 0) {
        CGFloat startY = 0;
        [self.myChannelLayoutManager calculateAllGuestViews];
        startY = self.myChannelLayoutManager.startY + self.myChannelLayoutManager.totalHeight;
        self.channelEmptyView.top = startY;
        self.moreChannelLayoutManager.startY = startY;
        [self.moreChannelLayoutManager calculateAllGuestViews];
        _channelSearchButton.bottom = startY + kEmptyChannelViewHeight + 17.0;
        self.channelsContainer.contentSize = CGSizeMake(self.channelsContainer.width, startY + kEmptyChannelViewHeight + 66.0);
        
        self.channelEmptyView.hidden = NO;
        [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
            self.channelEmptyView.alpha = 1.0;
        }];
    } else {
        if (self.channelEmptyView.alpha == 1 || !self.channelEmptyView.isHidden) {
            [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
                self.channelEmptyView.alpha = 0;
            } completion:^(BOOL finished) {
                self.channelEmptyView.hidden = YES;
            }];
        }
    }
}

- (SNChannelLayoutHolder *)layoutHolderForChannelView:(SNChannelView *)channelView {
    SNChannelLayoutHolder *hdFound = nil;
    for (SNChannelLayoutHolder *hd in self.allLayoutHolders) {
        if (hd.guestView == channelView) {
            hdFound = hd;
            break;
        }
    }
    return hdFound;
}

- (void)selectFirstChannel {
    for (int i = 0; i< self.myChannelLayoutManager.guests.count; ++i) {
        SNChannelLayoutHolder *hd = self.myChannelLayoutManager.guests[i];
        if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
            SNChannelView *chView = (SNChannelView *)hd.guestView;
            if (i == 0) {
                chView.isSelected = YES;
                self.currentSelectedChannelId = chView.chObj.ID;
            }
            else {
                chView.isSelected = NO;
            }
        }
    }
    
    for (SNChannelLayoutHolder *hd in self.moreChannelLayoutManager.guests) {
        if ([hd.guestView isKindOfClass:[SNChannelView class]]) {
            SNChannelView *chView = (SNChannelView *)hd.guestView;
            chView.isSelected = NO;
        }
    }
}

- (void)creatChannelSearchButton {
    if (!_channelSearchButton) {
        _channelSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _channelSearchButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
        _channelSearchButton.frame = CGRectMake(kIcoNormalSettingLeft, 0, kAppScreenWidth - kIcoNormalSettingLeft * 2, kChannelTitleHeight);
        [_channelSearchButton setTitle:kChannelBottomSearchText forState:UIControlStateNormal];
        [_channelSearchButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
        [_channelSearchButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
        [_channelSearchButton setImage:[UIImage imageNamed:@"icopersonal_search_v5.png"] forState:UIControlStateNormal];
        [_channelSearchButton setImage:[UIImage imageNamed:@"icopersonal_search_v5.png"] forState:UIControlStateHighlighted];
        [_channelSearchButton addTarget:self action:@selector(openSearchView:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat left = 0;
        CGFloat right = 0;
        if (kAppScreenWidth == 320) {
            right = 115;
            left = -50;
        }
        else if (kAppScreenWidth == 375.0) {
            right = 115;
            left = -100;
        }
        else {
            right = 150;
            left = -135;
        }
        [_channelSearchButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, right)];
        
        [_channelSearchButton setTitleEdgeInsets:UIEdgeInsetsMake(5, left, 5, 0)];
        
        _channelSearchButton.bottom = self.channelsContainer.contentSize.height - 13.0;
        [self.channelsContainer addSubview:_channelSearchButton];
        
    } else {
        _channelSearchButton.bottom = self.channelsContainer.contentSize.height - 13.0;
        [self.channelsContainer addSubview:_channelSearchButton];
    }
    self.channelsContainer.contentSize = CGSizeMake(self.channelsContainer.contentSize.width, self.channelsContainer.contentSize.height + 66.0);
}

- (void)openSearchView:(id)sender {
    self.searchWebViewController = [[SNSearchWebViewController alloc] initWithNibName:nil bundle:nil];
    _searchWebViewController.refertype = SNSearchReferChannelMannagerBottomSearch;
    [self.superview.superview addSubview:_searchWebViewController.view];
    [_searchWebViewController beginSearchAndreloadHotWords];
    _searchWebViewController.view.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    [_searchWebViewController.view layoutIfNeeded];
}

- (void)updateSeachChannelView {
    _channelSearchButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [_channelSearchButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_channelSearchButton setImage:[UIImage imageNamed:@"icopersonal_search_v5.png"] forState:UIControlStateNormal];
    [_channelSearchButton setImage:[UIImage imageNamed:@"icopersonal_search_v5.png"] forState:UIControlStateHighlighted];
}

-(CGFloat)channelTabHeight{
    if (kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0) {
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            return 80;
        }
        return 60.0;
    }else if(kAppScreenWidth == 414){
        return 200.0/3;
    }
    return 60.0;
}

@end
