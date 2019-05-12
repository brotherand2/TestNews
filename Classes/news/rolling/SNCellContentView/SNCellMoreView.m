//
//  SNCellMoreView.m
//  sohunews
//
//  Created by lhp on 5/16/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNCellMoreView.h"
#import "NSCellLayout.h"
#import "SNRollingNewsPublicManager.h"
#import "SNMyFavouriteManager.h"
#import "SNUserManager.h"
#import "SNVideoDetailModel.h"

#define kCloseButtonTag 8769

typedef enum SNMoreButtonType {
    SNMoreButtonListenReport,
    SNMoreButtonListenNews,
    SNMoreButtonFavorites,
    SNMoreButtonUninterested,
    SNMoveButtonAllScreen,  //lijian 2015.1.1 增加视频广告的全屏欣赏
    SNMoreButtonShare,
    SNMoreButtonAddBookShelf,
    SNMoreButtonClose,
}SNMoreButtonType;

@interface SNMoreButton : UIButton
{
    BOOL favoritedNews;
    UIImageView *imageView;
    UILabel *titleLabel;
    SNMoreButtonType buttonType;
}

@end

#define kImageWidth   (50/2)

@implementation SNMoreButton

- (id)initWithFrame:(CGRect)frame buttonType:(SNMoreButtonType) type favorited:(BOOL) favorited isAddBookShelf:(BOOL)isAddBookShelf;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsTouchWhenHighlighted = YES;
        buttonType = type;
        favoritedNews = favorited;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kImageWidth+24)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = NO;
        contentView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:contentView];
        
        NSString *title = @"";
        UIImage *normalImage = nil;
        UIImage *highlightedImage = nil;
        int imageWidth = kImageWidth;
        int imageTop = 0;
        switch (type) {
            case SNMoreButtonFavorites:
                title = favorited ? @"取消" : @"收藏";
                normalImage =  !favorited ? [UIImage imageNamed:@"icohome_hollowstar_v5.png"] : [UIImage imageNamed:@"icohome_star_v5.png"];
                highlightedImage = !favorited ? [UIImage imageNamed:@"icohome_hollowstarpress_v5.png"] : [UIImage imageNamed:@"icohome_starpress_v5.png"];
                break;
            case SNMoreButtonUninterested:
                title = @"不感兴趣";
                normalImage = [UIImage imageNamed:@"icohome_cry_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_crypress_v5.png"];
                break;
            case SNMoreButtonClose:
                normalImage = [UIImage imageNamed:@"icohome_closesmall_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_closesmallpress_v5.png"];
                imageWidth = 11;
                imageTop = 20;
                break;
            case SNMoreButtonListenNews:
                title = @"听新闻";
                normalImage = [UIImage imageNamed:@"icohome_hear_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_hearpress_v5.png"];
                break;
            case SNMoreButtonListenReport:
                title = @"举报";
                normalImage = [UIImage imageNamed:@"icohome_report_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_reportpress_v5.png"];
                break;
            case SNMoreButtonShare:
                title = @"分享";
                normalImage = [UIImage imageNamed:@"icohome_share_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_sharepress_v5.png"];
                break;
            case SNMoveButtonAllScreen:
                title = @"全屏欣赏";
                normalImage = [UIImage imageNamed:@"icohome_ad_full-screen_v5.png"];
                highlightedImage = [UIImage imageNamed:@"icohome_ad_full-screenpress_v5.png"];
                break;
            case SNMoreButtonAddBookShelf:
                if (isAddBookShelf) {
                    title = @"移除书架";
                    normalImage = [UIImage imageNamed:@"icofiction_ycsj_v5.png"];
                    highlightedImage = [UIImage imageNamed:@"icofiction_ycsjpress_v5.png"];
                } else {
                    title = @"加入书架";
                    normalImage = [UIImage imageNamed:@"icofiction_jrsj_v5.png"];
                    highlightedImage = [UIImage imageNamed:@"icofiction_jrsjpress_v5.png"];
                }
                break;
            default:
                break;
        }
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageTop, imageWidth, imageWidth)];
        imageView.image = normalImage;
        imageView.highlightedImage = highlightedImage;
        imageView.centerX = self.frame.size.width / 2;
        imageView.alpha = themeImageAlphaValue();
        [contentView addSubview:imageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, 13)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:11.0f];
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.top = imageView.bottom +10;
        [contentView addSubview:titleLabel];
        
    }
    return self;
}

- (void)setFavoriteStatus:(BOOL) isFavorites
{
    NSString *title = @"";
    UIImage *normalImage = nil;
    UIImage *highlightedImage = nil;
    title = isFavorites ? @"取消" : @"收藏";
    normalImage =  !isFavorites ? [UIImage imageNamed:@"icohome_hollowstar_v5.png"] : [UIImage imageNamed:@"icohome_star_v5.png"];
    highlightedImage = !isFavorites ? [UIImage imageNamed:@"icohome_hollowstarpress_v5.png"] : [UIImage imageNamed:@"icohome_starpress_v5.png"];
    titleLabel.text = title;
    imageView.image = normalImage;
    imageView.highlightedImage = highlightedImage;
}

- (void)setTitleWithString:(NSString *) title
{
    if (title.length > 0) {
        titleLabel.text = title;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    imageView.highlighted = highlighted;
}

- (void)dealloc
{
}

@end

@interface SNCellMoreView () /*<SNClickItemOnHalfViewDelegate>*/
{
    SNMoreButton *favoritesButton;
}

@end

#define kCloseButtonWidth   (88/2)
#define kNavigationBarTag   5555
@implementation SNCellMoreView

@synthesize identifier;

- (id)initWithFrame:(CGRect)frame buttonOptions:(SNCellMoreViewButtonOptions) options newsFavorited:(BOOL) favorited isAddBookShelf:(BOOL)isAddBookShelf
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonOptions = options;
        newsFavorited = favorited;
        addBookShelf = isAddBookShelf;
        self.identifier = [SNUtility CreateUUID];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        SNNavigationBar *backgroundView = [[SNNavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height+10)];
        backgroundView.tag = kNavigationBarTag;
        [self addSubview:backgroundView];
        
        //为解决点击边缘导致执行cell点击事件问题
        UIControl *contentControl = [[UIControl alloc] initWithFrame:frame];
        [contentControl setBackgroundColor:[UIColor clearColor]];
        [self addSubview:contentControl];
        
        [self initAllButtons];
    }
    return self;
}

- (void)setUninterestBlock:(void (^)(void)) uniBlock favoritesBlock:(SNCellMoreFavoritesBlock) favBlock listenBlock:(void (^)(void))lisBlock reportBlock:(void (^)(void)) reBlock addBookShelfBlock:(void (^)(void)) addBookShelfBlock
{
    if (uniBlock) {
        uninterestBlock = [uniBlock copy];
    }
    if  (favBlock) {
        favoritesBlock = [favBlock copy];
    }
    if (lisBlock) {
        listenBlock = [lisBlock copy];
    }
    if (reBlock) {
        reportBlock = [reBlock copy];
    }
    if (addBookShelfBlock) {
        addBookBlock = [addBookShelfBlock copy];
    }
}

- (int)getButtonCount
{
    int buttonCount = 0;
    if (SNCellMoreButtonOptionsUninterested & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionsFavorites & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionListenNews & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionVideoAd & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionNewsVideo & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionShare & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionReport & buttonOptions) {
        buttonCount++;
    }
    if (SNCellMoreButtonOptionAddBookShelf & buttonOptions) {
        buttonCount++;
    }
    return buttonCount;
}

- (void)initAllButtons
{
    int left = 36/2;
    if (![[SNDevice sharedInstance] isMoreThan320] ) {
        left = 44/2;
    }
    int buttonCount = [self getButtonCount];
    int buttonWidth = (kAppScreenWidth - 2*left) / buttonCount;
    int buttonDistance = 0;
    switch (buttonCount) {
        case 1:
            buttonDistance = 0;
            break;
        case 2:
            buttonDistance = 0;
            break;
        default:
            buttonDistance = 0;
            break;
    }
    if (SNCellMoreButtonOptionAddBookShelf & buttonOptions) {
        SNMoreButton *addButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                              buttonType:SNMoreButtonAddBookShelf
                                                               favorited:NO isAddBookShelf:addBookShelf];
        addButton.accessibilityLabel = @"加入书架";
        [addButton addTarget:self action:@selector(addBookButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addButton];
        
        left += buttonWidth + buttonDistance;
    }

    if (SNCellMoreButtonOptionReport & buttonOptions) {
        SNMoreButton *reportButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                              buttonType:SNMoreButtonListenReport
                                                               favorited:NO isAddBookShelf:NO];
        reportButton.accessibilityLabel = @"举报";
        [reportButton addTarget:self action:@selector(reportButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:reportButton];
        
        left += buttonWidth + buttonDistance;
    }
    
    
    if (SNCellMoreButtonOptionListenNews & buttonOptions) {
        SNMoreButton *listenButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                              buttonType:SNMoreButtonListenNews
                                                               favorited:NO isAddBookShelf:NO];
        listenButton.accessibilityLabel = @"听新闻";
        [listenButton addTarget:self action:@selector(listenNews) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:listenButton];
        
        left += buttonWidth + buttonDistance;
    }
    
    if (SNCellMoreButtonOptionNewsVideo & buttonOptions) {
        SNMoreButton *allScreenButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                                 buttonType:SNMoveButtonAllScreen
                                                                  favorited:NO isAddBookShelf:NO];
        allScreenButton.accessibilityLabel = @"全屏欣赏";
        [allScreenButton addTarget:self action:@selector(allScreen) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allScreenButton];
        //allScreenButton.backgroundColor = [UIColor redColor];
        
        left += buttonWidth + buttonDistance;
    }
    
    if (SNCellMoreButtonOptionsFavorites & buttonOptions) {
        favoritesButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                   buttonType:SNMoreButtonFavorites
                                                    favorited:newsFavorited isAddBookShelf:NO];
        favoritesButton.accessibilityLabel = @"收藏";
        [favoritesButton addTarget:self action:@selector(favoriteNews) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favoritesButton];
        
        left += buttonWidth + buttonDistance;
    }
    
    if (SNCellMoreButtonOptionShare & buttonOptions) {
        SNMoreButton *shareBtn = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                   buttonType:SNMoreButtonShare
                                                    favorited:NO isAddBookShelf:NO];
        shareBtn.accessibilityLabel = @"分享";
        [shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
//        shareBtn.backgroundColor = [UIColor redColor];
        [self addSubview:shareBtn];
        left += buttonWidth + buttonDistance;
    }
    
    if (SNCellMoreButtonOptionVideoAd & buttonOptions) {
        SNMoreButton *allScreenButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                              buttonType:SNMoveButtonAllScreen
                                                               favorited:NO isAddBookShelf:NO];
        allScreenButton.accessibilityLabel = @"全屏欣赏";
        [allScreenButton addTarget:self action:@selector(allScreen) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allScreenButton];
        //allScreenButton.backgroundColor = [UIColor redColor];
        
        left += buttonWidth + buttonDistance;
    }
    
    
    if (SNCellMoreButtonOptionsUninterested & buttonOptions) {
        SNMoreButton *uninterestButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(left, 0, buttonWidth, self.height)
                                                                  buttonType:SNMoreButtonUninterested
                                                                   favorited:NO isAddBookShelf:NO];
        uninterestButton.accessibilityLabel = @"不感兴趣";
        [uninterestButton addTarget:self action:@selector(uninterestNews) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:uninterestButton];
    }

    int close_x = self.width - kCloseButtonWidth + 3;
    int close_y = self.height - kCloseButtonWidth;
    SNMoreButton *closeButton = [[SNMoreButton alloc] initWithFrame:CGRectMake(close_x, close_y, kCloseButtonWidth, kCloseButtonWidth)
                                                         buttonType:SNMoreButtonClose
                                                          favorited:NO isAddBookShelf:NO];
    closeButton.accessibilityLabel = @"关闭";
    closeButton.tag = kCloseButtonTag;
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}

- (void)favoriteNews
{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (newsFavorited) {
        [self executeFavoriteNews:nil];
    }
    else {
        [self close];
        [SNUtility executeFloatView:self selector:@selector(executeFavoriteNews:)];
    }
}

- (void)share
{
    
    if (self.shareActionDelegate && [self.shareActionDelegate respondsToSelector:@selector(share)]) {
        [self.shareActionDelegate share];
        [self close];
    }
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavoriteNews:dict];
}

- (void)executeFavoriteNews:(NSDictionary *)dict {
    if (favoritesBlock) {
        favoritesBlock(dict);
        if (![SNUserManager isLogin]) {
            [self close];
        }else {
            [favoritesButton setFavoriteStatus:newsFavorited];
            [self performSelector:@selector(close) withObject:nil afterDelay:0.2];
        }
    }
}

- (void)uninterestNews
{
    if (uninterestBlock) {
        uninterestBlock();
        [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    }
}

- (void)allScreen
{
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
    if (self.fullActionDelegate && [self.fullActionDelegate respondsToSelector:@selector(fullScreenEnjoy)]) {
        [self.fullActionDelegate fullScreenEnjoy];
        if (_assignBaseCellDelegate && [_assignBaseCellDelegate respondsToSelector:@selector(dismissPopover)]) {
            [_assignBaseCellDelegate dismissPopover];
        }
    }
}

- (void)close
{
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:YES];
    if (_assignBaseCellDelegate && [_assignBaseCellDelegate respondsToSelector:@selector(dismissPopover)]) {
        [_assignBaseCellDelegate dismissPopover];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)addBookButtonClick {
    if (addBookBlock) {
        addBookBlock();
        [self close];
    }
}

- (void)reportButtonClick{
    if (reportBlock) {
        reportBlock();
        [self close];
    }
}

- (void)listenNews
{
    if (listenBlock) {
        listenBlock();
        [self close];
    }
}

- (void)hideBlurEffort{
    if ([self viewWithTag:kNavigationBarTag]) {
        SNNavigationBar *backgroundView = (SNNavigationBar *)[self viewWithTag:kNavigationBarTag];
        [backgroundView hideBlur];
    }
}

- (void)removeCloseButton
{
    if ([self viewWithTag:kCloseButtonTag]) {
        UIView *btn = [self viewWithTag:kCloseButtonTag];
        if(btn && btn.superview)
           [btn removeFromSuperview];
    }
}

- (void)dealloc
{
}

@end
