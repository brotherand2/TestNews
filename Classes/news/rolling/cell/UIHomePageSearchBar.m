//
//  UIHomePageSearchBar.m
//  sohunews
//
//  Created by wangyy on 15/11/13.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "UIHomePageSearchBar.h"
//#import "SNScanMenuView.h"
#import "SNNewsFullscreenManager.h"

@interface UIHomePageSearchBar ()

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *bgBtn;
@property (nonatomic, strong) UIButton *qrCodeBtn;

@end

@implementation UIHomePageSearchBar

@synthesize hotWords = _hotWords;
@synthesize currentIndex = _currentIndex;
@synthesize searchButton = _searchButton;
@synthesize bgBtn = _bgBtn;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hotWords = [NSArray arrayWithObjects:@"abc", @"123", @"456",nil];
        self.currentIndex = 0;
        [self setTintColor:nil];
        self.clipsToBounds = YES;
//        self.enablesReturnKeyAutomatically = NO;
        
//        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshHotWord) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)openQrCode {
    [SNUtility openQRCodeViewWith:@{kRefer:@1}];
//    [SNUtility openProtocolUrl:@"scan://tab=qr"];
//    [SNScanMenuView showMenu];
}

- (void)hideQrCodeBtn:(BOOL)hidden{
    if (_qrCodeBtn) {
        _qrCodeBtn.hidden = hidden;
    }
}

- (void)addSearchButtonWithTarget:(id)target action:(SEL)action{
    self.bgBtn = [[UIButton alloc] initWithFrame:self.bounds];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
         self.bgBtn.frame = CGRectMake(0, -1, self.bounds.size.width, self.bounds.size.height+1);
    }else{
         self.bgBtn.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    //by 5.9.4 wangchuanwen add
    //self.bgBtn.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg2Color]];
    self.bgBtn.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBgRIColor]];
    // add end
    self.bgBtn.clipsToBounds = YES;
    [self addSubview:self.bgBtn];
    
    NSString *title = [NSString stringWithFormat:@"%@", kRollingNewsSearchText];
    
    float value = [SNNewsFullscreenManager newsChannelChanged] ? 10 : 20;
    float searchButtonHeight = self.bounds.size.height - value;
    if ([self.channelId isEqualToString:@"13557"]) {//推荐频道与搜索框间距过大，稍作调整
        searchButtonHeight = self.bounds.size.height - 10;
    }
    
    CGRect frame = CGRectMake(14 , 10, self.bounds.size.width - 2*14, searchButtonHeight);
    self.searchButton = [[UIButton alloc] initWithFrame:frame];
    [self.searchButton setTitle:title forState:UIControlStateNormal];
    [self.searchButton setTitle:title forState:UIControlStateHighlighted];
    //by 5.9.4 wangchuanwen modify
    /*[self.searchButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [self.searchButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateHighlighted];
    UIImage *btnImage = [UIImage themeImageNamed:@"icopersonal_search_v5.png"];
    [self.searchButton setImage:btnImage forState:UIControlStateNormal];
    [self.searchButton setImage:btnImage forState:UIControlStateHighlighted];
    NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg4Color];
     [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
     [self.searchButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];*/
    NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeHomeSearchBgColor];
    [self.searchButton setTitleColor:SNUICOLOR(kThemeHomeSearchTextColor) forState:UIControlStateNormal];
    [self.searchButton setTitleColor:SNUICOLOR(kThemeHomeSearchTextColor) forState:UIControlStateHighlighted];
    UIImage *btnImage = [UIImage themeImageNamed:@"icohome_search_v5.png"];
    [self.searchButton setImage:btnImage forState:UIControlStateNormal];
    [self.searchButton setImage:btnImage forState:UIControlStateHighlighted];
    [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.searchButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 0)];
    //modify end
    self.searchButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    
    [self.searchButton setBackgroundColor:[UIColor colorFromString:bgColorString]];
    [self addSubview:self.searchButton];

    self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [self.searchButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.qrCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 30, self.searchButton.size.height)];
    [self.qrCodeBtn setBackgroundColor:[UIColor clearColor]];
    //by 5.9.4 wangchuanwen modify
    //[self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scan_v5.png"] forState:UIControlStateNormal];
    //[self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanpress_v5.png"] forState:UIControlStateHighlighted];
    //self.qrCodeBtn.right = self.searchButton.right - 4/2.f;
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanning_v5.png"] forState:UIControlStateNormal];
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanning_v5.png"] forState:UIControlStateHighlighted];
    self.qrCodeBtn.right = self.searchButton.right - 22/2.f;
    //modify end
    [self.qrCodeBtn addTarget:self action:@selector(openQrCode) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.qrCodeBtn];
}
- (NSString *)getCurrentHotWords{
    if (self.currentIndex < [self.hotWords count]) {
        return [self.hotWords objectAtIndex:self.currentIndex];
    }
    
    return nil;
}

- (void)setHotWords:(NSArray *)newHotWords{
    self.currentIndex = 0;
    self.placeholder = [NSString stringWithFormat:@"%@", kRollingNewsSearchText];
    
    _hotWords = newHotWords;
}

- (void)refreshHotWord:(NSString *)hotWord{
    NSString *title = [NSString stringWithFormat:@"大家都在搜：%@", hotWord];
    [self.searchButton setTitle:title forState:UIControlStateNormal];
    [self.searchButton setTitle:title forState:UIControlStateHighlighted];
}

- (void)updateTheme{
     //by 5.9.4 wangchuanwen add
    //NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg4Color];
    NSString *bgColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeHomeSearchBgColor];
    [self.searchButton setBackgroundColor:[UIColor colorFromString:bgColorString]];
    //add end
    
    [self.searchButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [self.searchButton setTitleColor:SNUICOLOR(kPostTextViewBgColor) forState:UIControlStateHighlighted];
    
    //by 5.9.4 wangchuanwen add
    /*UIImage *btnImage = [UIImage themeImageNamed:@"icopersonal_search_v5.png"];
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scan_v5.png"] forState:UIControlStateNormal];
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanpress_v5.png"] forState:UIControlEventTouchUpInside];*/
    
    UIImage *btnImage = [UIImage themeImageNamed:@"icohome_search_v5.png"];
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanning_v5.png"] forState:UIControlStateNormal];
    [self.qrCodeBtn setImage:[UIImage themeImageNamed:@"icohome_scanning_v5.png"] forState:UIControlEventTouchUpInside];

    [self.searchButton setImage:btnImage forState:UIControlStateNormal];
    [self.searchButton setImage:btnImage forState:UIControlStateHighlighted];
    
    //self.bgBtn.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg2Color]];
    self.bgBtn.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBgRIColor]];
    //add end
    
    [self bringSubviewToFront:self.bgBtn];
    [self bringSubviewToFront:self.searchButton];
    [self bringSubviewToFront:self.qrCodeBtn];
}

- (void)setSearchbarHeight:(CGFloat)value{
    float searchButtonHeight = self.bounds.size.height - value;
    self.searchButton.frame = CGRectMake(14 , 10, self.bounds.size.width - 2*14, searchButtonHeight);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.bgBtn.frame = CGRectMake(0, -1, self.bounds.size.width, self.bounds.size.height+1);
    }else{
        self.bgBtn.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
}

@end
