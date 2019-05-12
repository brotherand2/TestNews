//
//  SNRollingAddStockCell.m
//  sohunews
//
//  Created by wangyy on 15/8/12.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingAddStockCell.h"
#import "SNUserManager.h"

#define kUnReadImageViewWidth ((kAppScreenWidth > 375) ? 18 / 3 : 10 / 2)
#define kUnReadImageViewTop ((kAppScreenWidth > 375) ? 20 / 3 : 15 / 2)
#define kRollingAddStockContentWidth        (85)

@interface SNRollingAddStockContentView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id target;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) BOOL highLighted;
@end

@implementation SNRollingAddStockContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        self.backgroundColor = [UIColor clearColor];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateTheme {
    self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    self.badgeView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    [self setNeedsDisplay];
}

- (void)initUI {
    CGFloat left = (self.frame.size.width - 18 - 6 - 60) / 2.f;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, 5, 18, 18)];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 60, kThemeFontSizeC+1)];
    self.titleLabel.left = self.imageView.right + 6;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self addSubview:self.titleLabel];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(0, 0, self.width, self.height);
    [self.btn addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    [self.btn setBackgroundColor:[UIColor clearColor]];
    [self.btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btn];
    
    self.badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(103,kUnReadImageViewTop, kUnReadImageViewWidth, kUnReadImageViewWidth)];// by hqz

    self.badgeView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    [self addSubview:self.badgeView];
    self.badgeView.hidden = YES;
}

- (void)btnAction:(UIButton *)button {
    self.imageView.highlighted = YES;
    self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kPostTextViewBgColor];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.target && [self.target respondsToSelector:_selector]) {
        [self.target performSelector:_selector];
    }
#pragma clang diagnostic pop
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _highLighted = self.btn.highlighted;
    self.imageView.highlighted = _highLighted;
    if (_highLighted) {
        self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kPostTextViewBgColor];
    } else {
        self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    }
}

- (void)dealloc {
    self.target = nil;
    self.selector = nil;
    [_btn removeObserver:self forKeyPath:@"highlighted"];
    [SNNotificationManager removeObserver:self];
}

@end

@interface SNRollingAddStockCell() {
    UIImageView *addImageView;
    UILabel *titleLabel;
    UIView *lineView;
    SNRollingAddStockContentView *changeCityView;
    SNRollingAddStockContentView *scanView;
    SNRollingAddStockContentView *couponView;
}

@end

#define kAddStockCellHeight (56 / 2)
#define kCellHeight (70 / 2)

@implementation SNRollingAddStockCell
@synthesize stockItem;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
        if (item.cellType == SNRollingNewsCellTypeChangeCity || item.cellType == SNRollingNewsCellTypeCityScanAndTickets) {
            return kCellHeight;
        }
    }
    return kAddStockCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = YES;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth / 2 - 40, 9, 18, 18)];
    addImageView.image = [UIImage themeImageNamed:@"icobooking_add_v5.png"];
    addImageView.highlightedImage = [UIImage themeImageNamed:@"icobooking_addpress_v5.png"];
    [self addSubview:addImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 150, kThemeFontSizeC+1)];
    titleLabel.left = addImageView.right + 6;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self addSubview:titleLabel];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kAddStockCellHeight - 0.5f, kAppScreenWidth, 0.5f)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    lineView.clipsToBounds = NO;
    [self addSubview:lineView];
    
    CGFloat space = (width - 3 * kRollingAddStockContentWidth)/4.f;
    
    changeCityView = [[SNRollingAddStockContentView alloc] initWithFrame:CGRectMake(space, 3, kRollingAddStockContentWidth, kCellHeight - 0.5f)];
    [self addSubview:changeCityView];
    
    scanView = [[SNRollingAddStockContentView alloc] initWithFrame:CGRectMake(space * 2 + kRollingAddStockContentWidth + 10, 3, kRollingAddStockContentWidth, kCellHeight - 0.5f)];
    [self addSubview:scanView];
    
    couponView = [[SNRollingAddStockContentView alloc] initWithFrame:CGRectMake(space * 3 + kRollingAddStockContentWidth * 2 + 10, 3, kRollingAddStockContentWidth, kCellHeight - 0.5f)];
    [self addSubview:couponView];
    
    [SNNotificationManager addObserver:self selector:@selector(updateLocalChannelBadge:) name:kResetMyCouponBadgeNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(couponReceiveSucces:) name:@"com.sohu.newssdk.action.couponReceiveSuccess" object:nil];
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    if (self.stockItem != object) {
        self.stockItem = object;
        self.stockItem.delegate = self;
        
        if (self.stockItem.cellType == SNRollingNewsCellTypeCityScanAndTickets) {

            lineView.frame = CGRectMake(0, kCellHeight - 0.5f, kAppScreenWidth, 0.5f);
            
            addImageView.hidden = YES;
            titleLabel.hidden = YES;
            changeCityView.hidden = NO;
            scanView.hidden = NO;
            couponView.hidden = NO;
            if (self.stockItem.news.newsInfoArray.count < 3) {
                return;
            }
            NSDictionary *changeCityDic = self.stockItem.news.newsInfoArray[0];
            NSDictionary *scanDic = self.stockItem.news.newsInfoArray[1];
            NSDictionary *ticketDic = self.stockItem.news.newsInfoArray[2];
            
            changeCityView.imageView.image = [UIImage themeImageNamed:@"icocity_local_v5.png"];
            changeCityView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_localpress_v5.png"];
            changeCityView.selector = @selector(changeCity);
            changeCityView.titleLabel.text = [changeCityDic stringValueForKey:@"title" defaultValue:@"切换城市"];
            changeCityView.target = self;
            
            scanView.imageView.image = [UIImage themeImageNamed:@"icocity_scan_v5.png"];
            scanView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_scanpress_v5.png"];
            scanView.selector = @selector(openQRCodeView);
            scanView.titleLabel.text = [scanDic stringValueForKey:@"title" defaultValue:@"扫一扫"];
            scanView.link = [scanDic stringValueForKey:@"link" defaultValue:nil];
            scanView.target = self;
            
            couponView.imageView.image = [UIImage themeImageNamed:@"icocity_ticket_v5.png"];
            couponView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_ticketpress_v5.png"];
            couponView.selector = @selector(openMyCoupon);
            couponView.titleLabel.text = [ticketDic stringValueForKey:@"title" defaultValue:@"优惠券"];
            couponView.target = self;
            couponView.link = [ticketDic stringValueForKey:@"link" defaultValue:nil];
            CGSize size = [couponView.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
            [couponView.badgeView setFrame:CGRectMake(size.width + couponView.titleLabel.left, couponView.badgeView.frame.origin.y, couponView.badgeView.frame.size.width, couponView.badgeView.frame.size.height)];
            NSNumber * couponViewShouldHidden = [SNUserDefaults objectForKey:kMyCouponBadgeUnRead];

            couponView.badgeView.hidden = ![couponViewShouldHidden integerValue];
        } else if (self.stockItem.cellType == SNRollingNewsCellTypeChangeCity) {
            addImageView.image = [UIImage themeImageNamed:@"icolocal_city_v5.png"];
            addImageView.highlightedImage = [UIImage themeImageNamed:@"icolocal_citypress_v5.png"];
            self.stockItem.selector = @selector(changeCity);
            titleLabel.text = self.stockItem.news.title;
            CGSize size = [self.stockItem.news.title sizeWithFont:titleLabel.font];
            addImageView.frame = CGRectMake( (kAppScreenWidth - 18 - 6 - size.width) / 2, 8, 18, 18);
            titleLabel.frame = CGRectMake(addImageView.right + 6, 10, size.width, size.height);
            lineView.frame = CGRectMake(0, kCellHeight - 0.5f, kAppScreenWidth, 0.5f);
            
            addImageView.hidden = NO;
            titleLabel.hidden = NO;
            changeCityView.hidden = YES;
            scanView.hidden = YES;
            couponView.hidden = YES;
            couponView = nil;
            scanView = nil;
            changeCityView.hidden = YES;
        } else {
            addImageView.hidden = NO;
            titleLabel.hidden = NO;
            changeCityView.hidden = YES;
            scanView.hidden = YES;
            couponView.hidden = YES;

            self.stockItem.selector = @selector(addFreeStocks);
            addImageView.image = [UIImage themeImageNamed:@"icobooking_add_v5.png"];
            addImageView.highlightedImage = [UIImage themeImageNamed:@"icobooking_addpress_v5.png"];
            titleLabel.text = self.stockItem.news.title;
            CGSize size = [self.stockItem.news.title sizeWithFont:titleLabel.font];
            addImageView.frame = CGRectMake( (kAppScreenWidth - 18 - 6 - size.width) / 2, 1, 18, 18);
            titleLabel.frame = CGRectMake(addImageView.right + 6, 3, size.width, size.height);
            lineView.frame = CGRectMake(0, kAddStockCellHeight - 0.5f, kAppScreenWidth, 0.5f);
        }
    }
}

- (void)updateTheme {
    [super updateTheme];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    if (self.stockItem.cellType == SNRollingNewsCellTypeChangeCity) {
        addImageView.image = [UIImage themeImageNamed:@"icolocal_city_v5.png"];
        addImageView.highlightedImage = [UIImage themeImageNamed:@"icolocal_citypress_v5.png"];
    } else if (self.stockItem.cellType == SNRollingNewsCellTypeCityScanAndTickets){
        changeCityView.imageView.image = [UIImage themeImageNamed:@"icocity_local_v5.png"];
        changeCityView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_localpress_v5.png"];
        scanView.imageView.image = [UIImage themeImageNamed:@"icocity_scan_v5.png"];
        scanView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_scanpress_v5.png"];
        couponView.imageView.image = [UIImage themeImageNamed:@"icocity_ticket_v5.png"];
        couponView.imageView.highlightedImage = [UIImage themeImageNamed:@"icocity_ticketpress_v5.png"];
    } else {
        addImageView.image = [UIImage themeImageNamed:@"icobooking_add_v5.png"];
        addImageView.highlightedImage = [UIImage themeImageNamed:@"icobooking_addpress_v5.png"];
    }
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    addImageView.highlighted = highlighted;
    if (highlighted) {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kPostTextViewBgColor];
    } else {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    }
}

- (void)addFreeStocks {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://freeStock"] applyQuery:nil] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)updateLocalChannelBadge:(NSNotification *)notification {
    id obj = notification.object;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        BOOL clearBadge = [(NSNumber *)obj integerValue];
        if (clearBadge) {
            couponView.badgeView.hidden = YES;
        } else {
            couponView.badgeView.hidden = NO;
        }
    }
}

- (void)changeCity {
    NSMutableDictionary *cityDic = [NSMutableDictionary dictionary];
    
    if (self.stockItem.news.city) {
        [cityDic setObject:self.stockItem.news.city forKey:kCity];
    }
    
    if (self.stockItem.news.channelId.length > 0) {
        [cityDic setObject:self.stockItem.news.channelId forKey:@"channelId"];
    }
    [SNUtility shouldUseSpreadAnimation:NO];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://localChannelList"] applyAnimated:YES] applyQuery:cityDic];
    [[TTNavigator navigator] openURLAction:urlAction];
}

/**
 *  打开扫一扫
 */
- (void)openQRCodeView {
    [SNUtility shouldUseSpreadAnimation:NO];
    if (scanView.link.length > 0) {
        [SNUtility openProtocolUrl:scanView.link context:@{kRefer:@2}];
    }
}

/**
 *  打开我的优惠券
 */
- (void)openMyCoupon {
    [SNUtility shouldUseSpreadAnimation:NO];
    //登录拦截
    if (![SNUserManager isLogin]) {
        [SNGuideRegisterManager login:kLoginFromShareMySohu];
        [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
        [SNUtility setUserDefaultSourceType:kUserActionIdForArticleComment keyString:kLoginSourceTag];
    }
    else {
        if (couponView.link.length > 0)
            {
                [SNUtility openProtocolUrl:couponView.link context:@{kUniversalWebViewType : [NSNumber numberWithInteger:MyTicketsListWebViewType]}];
                couponView.badgeView.hidden = YES;
                [SNNotificationManager postNotificationName:kResetMyCouponBadgeNotification object:[NSNumber numberWithBool:YES]];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kMyCouponBadgeUnRead];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
    }

    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=coupon&_tp=localpv&channelId=%@", [SNUtility getCurrentChannelId]]];
}

/**
 *  优惠券领取成功
 *
 *  @param notification /notification.object 就是 优惠券组ID
 */
- (void)couponReceiveSucces:(NSNotification *)notification {
    [SNNotificationManager postNotificationName:kResetMyCouponBadgeNotification object:[NSNumber numberWithBool:NO]];
    [SNUserDefaults setObject:[NSNumber numberWithBool:YES] forKey:kMyCouponBadgeUnRead];
}

@end
