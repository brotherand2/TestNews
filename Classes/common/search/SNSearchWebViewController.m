//
//  SNSearchWebViewController.m
//  sohunews
//
//  Created by tt on 15/4/19.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSearchWebViewController.h"
#import "SNSkinManager.h"
#import "SNClientRegister.h"
#import "SNUserManager.h"
#import "NSJSONSerialization+String.h"
#import "SNSearchSuggestionTool.h"
#import "SNConsts.h"
#import "SHUrlMaping.h"
#import "SHH5SearchApi.h"
#import "SHWebView.h"
#import "SNSubscribeCenterService.h"
#import "UIFont+Theme.h"
#import "SNRollingNewsPublicManager.h"
#import "SHH5SearchJSModel.h"
#import "SNFeedBackApi.h"
#import "SNNewAlertView.h"
#import "SNStoryUtility.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNCloseAdImageView.h"
#import "UIViewAdditions.h"
#import "SNAdvertiseManager.h"
static const CGFloat kWebViewTop = 44.0f;
static const CGFloat kHeadViewTop = 20.0f;
static const CGFloat kCs1 = (20 / 3.0);

static NSString * const kSNSearchWebViewHistoryKey = @"kSNSearchWebViewHistoryKey";
static NSString * const kSNSearchWebViewNovelHistoryKey = @"kSNSearchWebViewNovelHistoryKey";
static NSString * const kSNSearchWebHistoryCellIdentifier = @"SNSearchWebHistoryCell";

static void *SNSearchWebHistoryCellObserverContext = &SNSearchWebHistoryCellObserverContext;


typedef NS_ENUM(NSInteger, SNSearchWebViewStatus) {
    SNSearchWebViewInputing,
    SNSearchWebViewResult,
};

@interface SNSearchWebHistoryCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *keywordLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIcon;
@property (strong, nonatomic) IBOutlet UIButton *arrowButton;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *arrowBgView;

@property (nonatomic, strong) UIButton *leftKeyWord;
@property (nonatomic, strong) UIButton *rightKeyWord;

- (void)updateKeyWordLabelTextColorWithKeyWord:(NSString *)keyWord;

@end

@implementation SNSearchWebHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.keywordLabel.textColor = [SNSkinManager color:SkinText1];
 
    self.bottomView.backgroundColor = [SNSkinManager color:SkinBg1];
    self.contentView.backgroundColor = [SNSkinManager color:SkinBg3];
    self.arrowBgView.backgroundColor = [SNSkinManager color:SkinBg3];
    [self.arrowButton setImage:[UIImage imageNamed:@"search_history_arrow.png"] forState:UIControlStateNormal];
    self.arrowButton.backgroundColor = [UIColor clearColor];

    if (self.leftKeyWord == nil) {
        self.leftKeyWord = [[UIButton alloc] initWithFrame:CGRectMake(14, 0, (kAppScreenWidth / 2) - 21, self.size.height)];
        self.leftKeyWord.backgroundColor = [UIColor clearColor];
        [self.leftKeyWord setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        [self.leftKeyWord setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
        self.leftKeyWord.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.leftKeyWord.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
        [self.contentView addSubview:self.leftKeyWord];
        self.leftKeyWord.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    self.leftKeyWord.hidden = YES;
    
    if (self.rightKeyWord == nil) {
        self.rightKeyWord = [[UIButton alloc] initWithFrame:CGRectMake(self.leftKeyWord.right + 14, 0, self.leftKeyWord.size.width, self.size.height)];
        self.rightKeyWord.backgroundColor = [UIColor clearColor];
        [self.rightKeyWord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rightKeyWord setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self.rightKeyWord setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        [self.rightKeyWord setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
        self.rightKeyWord.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.rightKeyWord.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
        [self.contentView addSubview:self.rightKeyWord];
        self.rightKeyWord.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    self.rightKeyWord.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.contentView.backgroundColor = [SNSkinManager color:SkinBg2];
    } else {
        self.contentView.backgroundColor = [SNSkinManager color:SkinBg3];
    }
    
    self.arrowBgView.backgroundColor = [SNSkinManager color:SkinBg3];
    self.arrowButton.backgroundColor = [UIColor clearColor];
}

- (void)updateKeyWordLabelTextColorWithKeyWord:(NSString *)keyWord
{
    if (keyWord.length == 0) {
        return;
    }
    NSString *title = self.keywordLabel.text;
    NSRange range = [title rangeOfString:keyWord];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:title];
    [str addAttribute:NSForegroundColorAttributeName value:[SNSkinManager color:SkinRed] range:range];
    self.keywordLabel.attributedText = str;
    
}

- (void)setLeftKeyWord:(NSString *)leftKeyWord RightKeyWord:(NSString *)rightKeyWord{
    [self.leftKeyWord setTitle:leftKeyWord forState:UIControlStateNormal];
    [self.leftKeyWord setTitle:leftKeyWord forState:UIControlStateHighlighted];
    
    [self.rightKeyWord setTitle:rightKeyWord forState:UIControlStateNormal];
    [self.rightKeyWord setTitle:rightKeyWord forState:UIControlStateHighlighted];
    
    if (leftKeyWord == nil && rightKeyWord == nil) {
        self.leftKeyWord.hidden = YES;
        self.rightKeyWord.hidden = YES;
        self.arrowBgView.hidden = NO;
        self.arrowButton.hidden = NO;
        self.bottomView.hidden = NO;
    }
    else{
        self.leftKeyWord.hidden = NO;
        self.rightKeyWord.hidden = NO;
        self.keywordLabel.text = @"";
        self.arrowBgView.hidden = YES;
        self.arrowButton.hidden = YES;
        self.bottomView.hidden = YES;
    }
}

- (void)dealloc {
    
}
@end


@interface SNSearchWebViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SNActionSheetDelegate, UIWebViewDelegate> {
    BOOL _isSearchResultsDisplayed;
    BOOL _isNightMode;
    BOOL _isNoPicMode;
    BOOL _isInitByUrl;
    BOOL _is3DTouch;
    BOOL _isEnterForeground;

    NSUserDefaults *_userDefaults;
}

@property (copy, nonatomic) NSString *lastSearchWord;

@property (strong, nonatomic) NSArray *historyList;
@property (strong, nonatomic) NSArray *suggestionList;

@property (strong, nonatomic) IBOutlet SHWebView *webView;
@property (strong, nonatomic) IBOutlet SHWebView *webView1; // 另一个webView

@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIView *statusBgView;
@property (strong, nonatomic, readwrite) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *historyViewNoData;
@property (strong, nonatomic) IBOutlet UIView *historyView;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeading;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *csWebViewTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *csHeadViewTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cs1; // 对应xib看
@property (nonatomic, copy)NSString *keyfrom;

@property (nonatomic, strong) NSArray *hotSearchWords;
@property (nonatomic, strong) NSString *searchType;

@property (nonatomic, strong) SHH5SearchJSModel *jsModel;

@property (nonatomic, assign,getter=isHideHotWords) BOOL hideHotWords;   // 是否隐藏热门搜索

@property (nonatomic, strong) UIView * adview;//搜索页的非标渠道广告view

@end

@implementation SNSearchWebViewController

- (void)setHistoryList:(NSArray *)newHistoryList {
    
    if (_historyList != newHistoryList) {
        _historyList = newHistoryList;
    }
    
    if (self.refertype == SNSearchReferNovel) {
        [_userDefaults setObject:newHistoryList forKey:kSNSearchWebViewNovelHistoryKey];
    } else {
        [_userDefaults setObject:newHistoryList forKey:kSNSearchWebViewHistoryKey];
    }
    [_userDefaults synchronize];
}

#pragma mark base

- (instancetype)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        _isInitByUrl = YES;
        self.lastSearchWord = query[@"searchText"];
        if ([[query objectForKey:kIs3DTouchOpen] boolValue]) {
            _is3DTouch = YES;
        } else {
            _is3DTouch = NO;
        }
        if ([[query objectForKey:@"isEnterForeground"] boolValue]) {
            _isEnterForeground = YES;
        } else {
            _isEnterForeground = NO;
        }
        if ([query objectForKey:@"hideHotWords"]) {
            
            BOOL hide = [[query objectForKey:@"hideHotWords"] boolValue];
            if (!hide) {
                _hideHotWords = YES;
            }
        }
        
        NSNumber *number = [query objectForKey:kSearchReferType];
        _refertype = [number intValue];
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:(nibNameOrNil ? : @"SNSearchWebViewController") bundle:nibBundleOrNil];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _isInitByUrl = NO;
        
        [SNNotificationManager addObserver:self selector:@selector(cancel:) name:k3DTouchHomeKeyBoardClose object:nil];
        [SNNotificationManager addObserver:self selector:@selector(cancel:) name:kSearchWebViewCancle object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(closeKeyPad) name:kNotifyDidReceive object:nil];
        [SNNotificationManager addObserver:self selector:@selector(clearDataAndExit) name:kCloseSearchWebNotification object:nil];
        
        [self initMode];
    }
    return self;
}

- (void)initMode {
    [self initNightMode];
    [self initNoPicMode];
}

- (void)initNightMode {
    _isNightMode = [[SNThemeManager sharedThemeManager] isNightTheme];
}

- (void)initNoPicMode {
    // 改成和频道预览页一样
    NSString *picMode = [_userDefaults objectForKey:kNonePictureModeKey];
    _isNoPicMode = ([picMode integerValue] == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.refertype == SNSearchReferNovel) {//这么做，后续数据修改要少，减少各种逻辑判断
        _historyList = [_userDefaults objectForKey:kSNSearchWebViewNovelHistoryKey];
    }else{
        _historyList = [_userDefaults objectForKey:kSNSearchWebViewHistoryKey];
        [self addAdView];
    }
    
    [self initUI];
    [self initData];
    
    //@qz 写死了 2017.7.25
    //SNAppABTestStyle curr = [SNUtility getSettingParamMode];
    SNAppABTestStyle curr = SNAppABTestStyleNO;
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInt:curr] forKey:@"settings_abtest_mode"];
    
    _oldRefertype = _refertype;
    [self performSelector:@selector(hideTabBar) withObject:nil afterDelay:1.0];
}

- (void)addAdView {
    SNChannelsAdData * searchPageAD = [[SNAdvertiseManager sharedManager] searchPageAD];
    if (searchPageAD.enable) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * scale;
        CGFloat imageHeight = scale == 3 ? 215 : 130;
        __weak __typeof(self)weakSelf = self;
        SNCloseAdImageView * adImage = [[SNCloseAdImageView alloc] initWithFrame:CGRectMake(0, 32, [UIScreen mainScreen].bounds.size.width, imageHeight/scale) closeAction:^(id sender) {
            [searchPageAD didManualClosedAD];
            [weakSelf.adview removeFromSuperview];
            weakSelf.adview = nil;
            weakSelf.historyTable.tableHeaderView = nil;
        } clikcAction:^{
            if (searchPageAD.adClickUrl.length > 0) {
                /// 点击前往广告落地页 并上报click
                [_textField resignFirstResponder];
                [SNUtility shouldUseSpreadAnimation:NO];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_clk&_tp=pv&apid=%@&from=1",searchPageAD.adId]];
                [SNUtility openProtocolUrl:searchPageAD.adClickUrl context:nil];
            }
        }];
        adImage.backgroundColor = [UIColor clearColor];
        [adImage setBackgroundViewHidden:YES];
        [adImage setBottomLineHidden:YES];
        [adImage setCloseButtonOrigin:CGPointMake(adImage.width - 40, -10)];
        [adImage loadImageWithUrl:searchPageAD.adImageUrl size:CGSizeMake(imageWidth, imageHeight) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 130/2.f + 32)];
                self.adview.backgroundColor = [UIColor clearColor];
                [self.adview addSubview:adImage];
                adImage.closeEnable = YES;
                self.historyTable.tableHeaderView = self.adview;
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_expos&_tp=pv&apid=%@&from=1",searchPageAD.adId]];
            }else{
                [self.adview removeFromSuperview];
                self.adview = nil;
                self.historyTable.tableHeaderView = nil;
            }
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)hideTabBar{
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:@selector(searchWebViewLoadView)]) {
        [self.searchBarDelegate searchWebViewLoadView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [SNNotificationManager addObserver:self selector:@selector(closeKeyPad) name:kCloseKeyboardNotification object:nil];
    
    static int i = 0;
    if (_textField.text.length == 0) {
        if (_is3DTouch && i == 0 && !_isEnterForeground) {
            [SNNotificationManager addObserver:self selector:@selector(showKeyboard) name:kIs3DTouchShowKeyboard object:nil];
        } else {
            [self.textField becomeFirstResponder];
        }
    }
    
    i++;
}

- (void)showKeyboard {
    [self.textField becomeFirstResponder];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        // 改用改变 constant
        self.csHeadViewTop.constant = self.topLayoutGuide.length;
        self.csWebViewTop.constant = self.topLayoutGuide.length;
        
        self.csHeadViewTop.constant = kHeadViewTop;
        self.csWebViewTop.constant = kHeadViewTop;
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            self.csHeadViewTop.constant =
            self.csWebViewTop.constant = 44;
        }
    }
    // 6p的布局
    if (kAppScreenWidth > kIPHONE_6_WIDTH) {
        self.cs1.constant = kCs1;
    }

}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    // 防止特殊情况了下的crash http://stackoverflow.com/questions/15016348/set-delegates-to-nil-under-arc
    _webView.delegate = nil;
    _webView1.delegate = nil;
    _webView.jsDelegate = nil;
    _webView1.jsDelegate = nil;
    _textField.delegate = nil;
    _historyTable.delegate = nil;
    self.webView = nil;
    self.webView1 = nil;
    
    if (self.searchBarDelegate) {
        self.searchBarDelegate = nil;
    }
}

- (void)onBack:(id)sender {
    // 判断哪个WebView
    if (!_webView1.hidden) {
        // 回到第一个WebView
        [self goBackToFirstWebView];
        return ;
    }
    
    // 直接退出吧
    [self clearDataAndExit];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    [self initNightMode];
    [self updateDayAndNightColor];
}

- (void)updateNonePicMode:(NSNotification *)notifiction {
    [self initNoPicMode];
    [self updateDayAndNightColor];
}

#pragma mark own
- (void)initUI {
    // 状态栏底色
    _statusBgView.alpha = 0.95;
    
    // 顶部栏阴影
    _headView.layer.shadowOffset = CGSizeMake(0, 0.8);
    _headView.layer.shadowRadius = 0.6;
    _headView.layer.shadowOpacity = 0.2;
    _headView.layer.shadowColor = [UIColor grayColor].CGColor;
    _headView.alpha = 1.0f;//_statusBgView.alpha;
    
    // 输入框
    _textField.font = [SNSkinManager font:SkinFontD];
    // iOS8.0 上的系统bug 直接输入预测的文字 搜索按钮不变成可点击
    if (SYSTEM_VERSION_EQUAL_TO(@"8.0")) {
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.borderStyle = UITextBorderStyleNone;
    
    // WebView
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    //self.webView.scrollView.contentInset = UIEdgeInsetsMake(kWebViewTop, 0.f, kToolbarHeight, 0.f);
    //@qz 适配iPhone X  2017.10.9
    _webView.scrollView.contentInset = UIEdgeInsetsMake(kWebViewTop, 0.f, [SNToolbar toolbarHeight], 0.f);
    self.webView.scrollView.scrollIndicatorInsets = self.webView.scrollView.contentInset;
    
    self.webView1.scrollView.decelerationRate = self.webView.scrollView.decelerationRate;
    self.webView1.scrollView.contentInset = self.webView.scrollView.contentInset;
    self.webView1.scrollView.scrollIndicatorInsets = self.webView.scrollView.scrollIndicatorInsets;
    
    [self addToolbar];
    [self updateDayAndNightColor];
}

- (void)initData {
      //用于接收JS事件
    _jsModel = [[SHH5SearchJSModel alloc] init];
    self.jsModel.searchWebViewController = self;
    
    [self.webView setJsDelegate:self];
    [self.webView registerJavascriptInterface:self.jsModel forName:@"searchApi"];
    
    [self.webView1 setJsDelegate:self];
    [self.webView1 registerJavascriptInterface:self.jsModel forName:@"searchApi"];
    
    if (self.isHideHotWords) { // 添加跳转反馈页面
        [self.webView registerJavascriptInterface:[[SNFeedBackApi alloc] init] forName:@"FeedBackApi"];
        [self.webView1 registerJavascriptInterface:[[SNFeedBackApi alloc] init] forName:@"FeedBackApi"];
    }
    
    _keyfrom = @"&keyfrom=input0";
    // 判断初始化进入情况
    if ([self.lastSearchWord isKindOfClass:[NSString class]] && self.lastSearchWord.length > 0) {
        _textField.text = self.lastSearchWord;
        _keyfrom = @"&keyfrom=input1";
        self.noAutoCorrection = YES;
        [self textFieldShouldReturn:_textField];
        
    } else {
        [self switchToView:SNSearchWebViewInputing];
    }
}

- (void)updateDayAndNightColor {
    
    // 底色
    if (_isInitByUrl) {
        self.view.backgroundColor = [SNSkinManager color:SkinBg4];
    } else {
        self.view.backgroundColor = [SNSkinManager color:SkinBg4];
    }
    
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        //@qz 更改webview 闪白的问题 第一步
        self.view.backgroundColor = [SNSkinManager color:SkinBg4];
    }
    
    _statusBgView.backgroundColor = [SNSkinManager color:SkinBg4];
    
    // 搜索icon
    _searchIcon.image = [UIImage imageNamed:@"icopersonal_search_v5.png"];
    
    _headView.backgroundColor = _statusBgView.backgroundColor;
    _historyView.backgroundColor = _statusBgView.backgroundColor;
    
    // webView
    _webView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    _webView1.backgroundColor = _webView.backgroundColor;
    
    
    _textField.textColor = [SNSkinManager color:SkinText1];
    NSString *holderText = nil;
    if ([self isChannelSearch]) {
        holderText = kChannelBottomSearchText;
    }
    else if (!self.isHideHotWords) {
        holderText = kRollingNewsSearchText;
    } else {
       holderText = @"有问题?搜一下";
    }
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:holderText attributes:@{
                                                                                                            NSForegroundColorAttributeName: [SNSkinManager color:SkinText4],
                                                                                                            NSFontAttributeName : [SNSkinManager font:SkinFontD]
                                                                                                            }];
    
    UIButton *clearButton = [_textField valueForKey:@"_clearButton"];
    // 自定义clearButton 有风险 在不同的iOS版本中
    if (clearButton && [clearButton isKindOfClass:[UIButton class]]) {
        UIImage *image = [UIImage imageWithBundleName:@"icosearch_delete_v5.png"];
        UIImage *image2 = [UIImage imageWithBundleName:@"icosearch_deletepress_v5.png"];
        [clearButton setImage:image forState:UIControlStateNormal];
        [clearButton setImage:image2 forState:UIControlStateHighlighted];
    }
    
    [self setCancelButtonState:NO];
    
    // 历史记录列表
    _historyTable.backgroundColor = [SNSkinManager color:SkinBg3];
    [_historyTable reloadData];
    
    BOOL testServerEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"preference_test_mode_enabled"];
    if (testServerEnabled) {//apn token 显示，方便测试
        _textField.text = [SNClientRegister sharedInstance].deviceToken;
    }
}
- (void)goToSearch:(id)sender
{
    if (_textField.text.length) {
        [self startSearch:_textField.text keyFrom:@"&keyfrom=input"];
    }
}

- (void)cancel:(id)sender {
    if (_isSearchResultsDisplayed) {
        [self closeKeyPad];
        // 判断当前页面状态
        if (_historyViewNoData.hidden && _historyView.hidden) {
            // 退出整个模块
            [self clearDataAndExit];
        } else {
            // 返回上次搜索结果
            [self switchToView:SNSearchWebViewResult];
            _textField.text = _lastSearchWord;
        }
    } else {
        [self closeKeyPad];
        [self clearDataAndExit];
    }
}
- (void)setCancelButtonState:(BOOL)bSearchState
{
    if (bSearchState) {
        [_cancelButton setTitle:@"搜索" forState:UIControlStateNormal];
        [_cancelButton setTitle:@"搜索" forState:UIControlStateHighlighted];
        [_cancelButton setTitleColor:[SNSkinManager color:SkinRed] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[SNSkinManager color:SkinRedTouch] forState:UIControlStateHighlighted];
        [_cancelButton removeTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton addTarget:self action:@selector(goToSearch:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        
        NSString *title = @"取消";
        UIColor *color = [SNSkinManager color:SkinText4];
        UIColor *selectColor = [SNSkinManager color:SkinText4Touch];
        [_cancelButton setTitle:title forState:UIControlStateNormal];
        [_cancelButton setTitle:title forState:UIControlStateHighlighted];
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
        [_cancelButton setTitleColor:selectColor forState:UIControlStateHighlighted];
        [_cancelButton removeTarget:self action:@selector(goToSearch:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)switchToView:(SNSearchWebViewStatus)status {
    switch (status) {
        case SNSearchWebViewInputing : {
            // 隐藏底部栏
            _toolbarView.hidden = YES;
           
            NSArray *suggestionList = self.suggestionList;
            if (suggestionList && suggestionList.count > 0) {
                 self.historyTable.tableHeaderView = nil;
                _historyViewNoData.hidden = YES;
                _historyView.hidden = NO;
                [_historyTable reloadData];
            }else{
                self.historyTable.tableHeaderView = self.adview;
                // 判断有无历史记录 和搜索热词
                NSArray *historyList = self.historyList;
                NSArray *hotList = self.hotSearchWords;
                if (self.isHideHotWords) {
                    hotList = nil;
                }
                
                if ((historyList == nil || [historyList count] == 0) && (hotList == nil || [hotList count] == 0)) {
                    if (self.isHideHotWords) {
                        _historyViewNoData.hidden = YES;
                    } else {
                        _historyViewNoData.hidden = NO;
                    }
                    if (_historyTable.tableHeaderView) {
                        _historyView.hidden = NO;
                        [_historyTable reloadData];
                    }else{
                        _historyView.hidden = YES;
                    }
                }
                else{
                    _historyViewNoData.hidden = YES;
                    _historyView.hidden = NO;
                    [_historyTable reloadData];
                }
            }
            
        }
            break;
            
        case SNSearchWebViewResult : {
            [self setCancelButtonState:NO];
            _historyViewNoData.hidden = YES;
            _historyView.hidden = YES;
            self.historyTable.tableHeaderView = nil;
            
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                //@qz 更改webview 闪白的问题 第二步 屏蔽掉 这里还是隐藏did时候在展示
                //_webView.hidden = NO;
            }else{
                _webView.hidden = NO;
            }
            _toolbarView.hidden = NO;
        }
            break;
    }
}

- (void)handleSearchText:(NSString *)text keyFrom:(NSString *)keyFromStr {
    // 回到第一个WebView
    [self goBackToFirstWebView];
    NSString *urlString = [[SHUrlMaping getLocalPathWithKey:SH_JSURL_SEARCH] stringByAppendingFormat:@"?refertype=%@%@",@(_refertype).stringValue,keyFromStr];
    if (!self.noAutoCorrection) {
        urlString = [urlString stringByAppendingString:@"&autoCorrection=1"];
    }
    else {
        self.noAutoCorrection = NO;
    }
    if (self.isHideHotWords) {
        urlString = [urlString stringByAppendingString:@"&type=feedback"];
    }
    if (self.refertype == SNSearchReferNovel) {
        urlString = [urlString stringByAppendingString:@"&type=novel"];
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    _isSearchResultsDisplayed = YES;
    self.lastSearchWord = text;
    
    // 持久化
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.historyList];
    if ([array containsObject:text]) {
        [array removeObject:text];
    }
    
    [array insertObject:text atIndex:0];
    
    if (array.count > 8) {
        [array removeLastObject];
    }
    
    self.historyList = array;
}

- (void)closeKeyPad {
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
}

- (void)goBackToFirstWebView {
    // 回到第一个WebView
    _webView1.hidden = YES;
}

- (void)goToSecondWebView {
    self.webView1.hidden = NO;
}

- (void)toClearAllHistoryAction {
    [self closeKeyPad];
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"确定清空搜索历史吗?" cancelButtonTitle:@"取消" otherButtonTitle:@"清除"];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
         [self clearAllHistory];
    }];
}

- (void)clearAllHistory {
    self.historyList = [NSArray array];
    
    [self switchToView:SNSearchWebViewInputing];
    
}

- (void)clearDataAndExit {
    // 不同进入方式的 不同的退出
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
    else {
        self.historyTable = nil;
         // 避免调set方法
        _historyList = nil;
        
        self.historyView = nil;
        self.historyViewNoData = nil;
        self.headView = nil;
        
        [self.view removeFromSuperview];
    }
    if (self.searchBarDelegate && [self.searchBarDelegate respondsToSelector:@selector(searchBarEndSearch)]) {
        [self.textField resignFirstResponder];
        [self.searchBarDelegate searchBarEndSearch];
    }
}

- (IBAction)tapNoHistoryView:(id)sender {
    [self clearDataAndExit];
}

- (IBAction)swipeNoHistoryView:(id)sender {
    
}

- (IBAction)panHistoryView:(id)sender {
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan : {
            [self clearDataAndExit];
        }
            break;
            
        default:
            break;
    }
}

- (void)btnCellClicked:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.historyTable];
    NSIndexPath *indexPath = [self.historyTable indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        SNSearchWebHistoryCell *cell = (SNSearchWebHistoryCell *)[self.historyTable cellForRowAtIndexPath:indexPath];
        _textField.text = cell.keywordLabel.text;
        [self setCancelButtonState:YES];
        [self searchTipsWithKey:cell.keywordLabel.text];
    }
}

- (void)leftBtnCellClicked:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.historyTable];
    NSIndexPath *indexPath = [self.historyTable indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSString *keyWord = nil;
        if (_historyList.count != 0 && indexPath.section == 0) {
            if (_historyList.count > (indexPath.row*2)) {
                keyWord = [_historyList objectAtIndex:(indexPath.row*2)];
                self.searchType = kSearchNews;
                
                _refertype = _oldRefertype;
                self.noAutoCorrection = NO;
            }
        }
        else{
            if (_hotSearchWords.count > indexPath.row*2) {
                keyWord = [_hotSearchWords objectAtIndex:(indexPath.row*2)];
                if (self.homeSearch) {
                    self.searchType = kHomePagePullSearch;
                }
                else {
                    self.searchType = khotSearch;
                }
                
                if (self.refertype == SNSearchReferNovel) {
                    _refertype = SNSearchReferNovel;
                    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"objType=fic_todetail&fromObjType=6&statType=clk&bookId="]];
                } else {
                    _refertype = SNSearchReferHotSearch;
                }
                self.noAutoCorrection = YES;
            }
        }
       
        _textField.text = keyWord;
        _keyfrom = @"&keyfrom=input0";
    
        [self textFieldShouldReturn:_textField];
    
        [self.historyTable deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)rightBtnCellClicked:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.historyTable];
    NSIndexPath *indexPath = [self.historyTable indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath) {
        NSString *keyWord = nil;
        if (_historyList.count != 0 && indexPath.section == 0) {
            if (_historyList.count > (indexPath.row*2 + 1)) {
                keyWord = [_historyList objectAtIndex:(indexPath.row*2 + 1)];
                self.searchType = kSearchNews;
                _refertype = _oldRefertype;
                self.noAutoCorrection = NO;
            }
        }
        else{
            if (_hotSearchWords.count > (indexPath.row*2 + 1)) {
                keyWord = [_hotSearchWords objectAtIndex:(indexPath.row*2 + 1)];
                if (self.homeSearch) {
                    self.searchType = kHomePagePullSearch;
                }
                else {
                    self.searchType = khotSearch;
                }
                if (self.refertype == SNSearchReferNovel) {
                    _refertype = SNSearchReferNovel;
                    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"objType=fic_todetail&fromObjType=6&statType=clk&bookId="]];
                } else {
                    _refertype = SNSearchReferHotSearch;
                }
                self.noAutoCorrection = YES;
            }
        }
        _textField.text = keyWord;
        _keyfrom = @"&keyfrom=input0";
        
        [self textFieldShouldReturn:_textField];
        
        [self.historyTable deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

// 参数小区别
- (NSString *)modeUrlString {
    return [NSString stringWithFormat:@"?mode=%@&imgs=%@&refertype=%@",@(_isNightMode).stringValue,@(_isNoPicMode).stringValue, @(_refertype).stringValue];
}

- (NSString *)modeUrlString1 {
    return [NSString stringWithFormat:@"&mode=%@&imgs=%@",@(_isNightMode).stringValue,@(_isNoPicMode).stringValue];
}

- (void)startSearch:(NSString *)text keyFrom:(NSString *)keyFromStr {
    
    NSString* res = [[NSString alloc] initWithString:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if ([res length] == 0) {
        return;
    }
    
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    } else {
        NSTimeInterval delayTime = ([_textField isFirstResponder]) ? 0.25:0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 延迟0.25s,待键盘退出后再执行 2017.3.20 liteng （NEWSCLIENT-16782）
            [self switchToView:SNSearchWebViewResult];
            [self handleSearchText:res keyFrom:keyFromStr];
        });
    }
    [self closeKeyPad];
}

- (void)textFieldDidChange:(UITextField *)textField{
    [self searchTipsWithKey:textField.text];
}

- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        [self setCancelButtonState:NO];
        self.suggestionList = nil;
        [self switchToView:SNSearchWebViewInputing];
        return;
    }
    [self setCancelButtonState:YES];
    
    [self goToSearchSuggestByKeyWord:key];
    
}
- (void)goToSearchSuggestByKeyWord:(NSString *)keyword
{
    BOOL showSuggestion = YES;//是否显示联想词，目前仅频道管理中搜索不显示
    if (_refertype == SNSearchReferChannel || _refertype == SNSearchReferChannelMannagerBottomSearch) {
        showSuggestion = NO;
    }
    SNSearchSuggestionTool *suggestionTool = [SNSearchSuggestionTool sharedManager];
    
    [suggestionTool searchSuggestion:keyword  showSuggestion:showSuggestion success:^(NSArray *suggesstionList) {
        
        self.suggestionList = suggesstionList;
        [self switchToView:SNSearchWebViewInputing];
        
    } failure:^{
    }];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *keyWord = textField.text;
    if (keyWord == nil || [textField.text length] == 0) {
        if (self.isHideHotWords) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"搜索内容不能为空哦" toUrl:nil mode:SNCenterToastModeOnlyText];
            return NO;
        }
        keyWord = textField.placeholder;
        if ([keyWord isEqualToString:kRollingNewsSearchText] || [keyWord isEqualToString:kChannelBottomSearchText]) {
            return NO;
        }
        textField.text = keyWord;
        if (self.homeSearch) {
           self.searchType = kHomePagePullSearch;
        }
        else {
            self.searchType = khotSearch;
        }
        
        if (self.refertype == SNSearchReferNovel) {
            _refertype = SNSearchReferNovel;
        } else {
            _refertype = SNSearchReferHotSearch;
        }
    }
    [self startSearch:keyWord keyFrom:_keyfrom];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.suggestionList = nil;
    textField.text = nil;
    [self setCancelButtonState:NO];
    [self switchToView:SNSearchWebViewInputing];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
    if (textField.text.length > 0) {
        [self setCancelButtonState:YES];
    }else{
        [self setCancelButtonState:NO];
    }
    if (!self.isHideHotWords && ![self isChannelSearch]) {
        
        if (self.hotSearchWords.count == 0) {
            [self beginSearchAndreloadHotWords];
        }
    }
    
    [self switchToView:SNSearchWebViewInputing];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isHideHotWords) {
        return 0;
    }
    if (_suggestionList.count) {
        return 1;
    }
    
    return _historyList.count == 0 ? 1 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.isHideHotWords) {
        _suggestionList = nil;
        _hotSearchWords = nil;
        if (_historyList.count == 0) {
            return 0;
        }
    }
    
    if (_suggestionList.count) {
        return 0;
    }
    
    if (_hotSearchWords.count == 0 && section != 0) {
        return 0;
    }
    if (_historyList.count == 0 && _hotSearchWords.count == 0) {
        return 0;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.isHideHotWords) {
        _suggestionList = nil;
        _hotSearchWords = nil;
    }
    if (_suggestionList.count) {
        return nil;
    }
    
    if (_historyList.count != 0 && section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 50)];
        view.backgroundColor = [SNSkinManager color:SkinBg3];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 100, 30)];
        label.text = @"搜索历史";
        label.textColor = SNUICOLOR(kThemeText4Color);
        if ([SNDevice sharedInstance].isPlus) {
            label.font = [UIFont systemFontOfSizeType:UIFontSizeTypeG];
        }
        else{
            label.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        }
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        CGFloat width = [SNDevice sharedInstance].isPlus ? 70 : 50;
        UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - 14 - width, 20, width, 30)];
        clearBtn.backgroundColor = [UIColor clearColor];
        [clearBtn setTitle:@"清除历史" forState:UIControlStateNormal];
        [clearBtn setTitle:@"清除历史" forState:UIControlStateHighlighted];
        [clearBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
        [clearBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateHighlighted];
        if ([SNDevice sharedInstance].isPlus) {
            clearBtn.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeG];
        }
        else{
            clearBtn.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        }
        [clearBtn addTarget:self action:@selector(toClearAllHistoryAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:clearBtn];
        
        return view;
    }
    if (!self.isHideHotWords) {
        
        if (_hotSearchWords.count) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 50)];
            view.backgroundColor = [SNSkinManager color:SkinBg3];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 100, 30)];
            label.text = @"热门搜索";
            label.textColor = SNUICOLOR(kThemeText4Color);
            if ([SNDevice sharedInstance].isPlus) {
                label.font = [UIFont systemFontOfSizeType:UIFontSizeTypeG];
            }
            else{
                label.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
            }
            label.backgroundColor = [UIColor clearColor];
            [view addSubview:label];
            
            return view;
        }
    }
    
    return nil;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isHideHotWords) {
        _suggestionList = nil;
        _hotSearchWords = nil;
    }
    if (_suggestionList.count) {
        return _suggestionList.count;
    }
    
    if (_historyList.count != 0 && section == 0) {
        int maxNum = _historyList.count > 4 ? 4 : _historyList.count;
        int num = maxNum / 2;
        return (maxNum % 2 == 0) ? num : num+1;
    }
    
    int num = _hotSearchWords.count / 2;
    return (_hotSearchWords.count % 2 == 0) ? num : num+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNSearchWebHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kSNSearchWebHistoryCellIdentifier];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SNSearchWebHistoryCell" owner:self options:nil][0];
    }
    
    [cell awakeFromNib]; // for 皮肤
    if (_suggestionList.count) {
        cell.keywordLabel.text = _suggestionList[indexPath.row];
        [cell setLeftKeyWord:nil RightKeyWord:nil];
        // 箭头点击
        [cell.arrowButton addTarget:self action:@selector(btnCellClicked:event:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        NSString *leftWord = nil;
        NSString *rightWord = nil;
        if (indexPath.section == 0 && _historyList.count != 0) {
            leftWord = _historyList[indexPath.row*2];
            if (_historyList.count > indexPath.row*2 + 1) {
                rightWord = _historyList[indexPath.row*2 + 1];
            }
        }
        else{
            leftWord = _hotSearchWords[indexPath.row*2];
            if (_hotSearchWords.count > indexPath.row *2 + 1) {
                rightWord = _hotSearchWords[indexPath.row*2 + 1];
            }
        }
        [cell setLeftKeyWord:leftWord RightKeyWord:rightWord];
        
        [cell.leftKeyWord addTarget:self action:@selector(leftBtnCellClicked:event:) forControlEvents:UIControlEventTouchUpInside];
        [cell.rightKeyWord addTarget:self action:@selector(rightBtnCellClicked:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell updateKeyWordLabelTextColorWithKeyWord:_textField.text];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_suggestionList.count) {
        if (kAppScreenWidth > kIPHONE_6_WIDTH) {
            return (186 / 3.0);
        }
        return 56.0f;
    }
    
    if (kAppScreenWidth > kIPHONE_6_WIDTH) {
        return (111 / 3.0);
    }
    return 35.0f;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_suggestionList.count) {
        _textField.text = _suggestionList[indexPath.row];
        _keyfrom = @"&keyfrom=suggest";
        self.noAutoCorrection = YES;
        [self textFieldShouldReturn:_textField];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideTabBar];
    [self closeKeyPad];
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:@"js:"]) {
        url = [url substringFromIndex:3];
    }
    BOOL isFromH5 = [url containsString:kH5NoTriggerIOSClick] && [SNUtility isProtocolV2:url];
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked || isFromH5) {
        // 截获判断
        if ([url rangeOfString:@"media.html?words="].location != NSNotFound || [url rangeOfString:@"channelList.html?words="].location != NSNotFound) {
            [self goToSecondWebView];
            NSString *finalUrl = [url stringByAppendingString:[self modeUrlString1]];
            [self.webView1 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalUrl]]];
            return NO;
        }
        else if ([url hasPrefix:kProtocolSubscirbe]){
            NSString *prefixStr = [NSString stringWithFormat:@"%@subId=",kProtocolSubscirbe];
            NSString *subId = [url substringFromIndex:[prefixStr length]];
            [[SNSubscribeCenterService defaultService] dealSubInfoFromServerBySubId:subId operationTopic:kTopicAddSubInfo];
        }
        else if ([url hasPrefix:kProtocolUnsubscirbe]){
            NSString *prefixStr = [NSString stringWithFormat:@"%@subId=",kProtocolUnsubscirbe];
            NSString *subId = [url substringFromIndex:[prefixStr length]];
            [[SNSubscribeCenterService defaultService] dealSubInfoFromServerBySubId:subId operationTopic:kTopicDelSubInfo];
        }
        else {
            NSMutableDictionary *context = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.searchType, kNewsFrom,nil];
            NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
            [referInfo setObject:@"0" forKey:kReferValue];
            [referInfo setObject:@"0" forKey:kReferType];
            [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Search_UserName] forKey:kRefer];
            if (_refertype == SNSearchReferChannel || _refertype == SNSearchReferChannelMannagerBottomSearch) {
                self.searchType = kChannelListSearch;
            }
            else if (_refertype == SNSearchReferArticle) {
                self.searchType = kArticleBlueWordsSearch;
            }
            else if (_refertype == SNSearchReferHomePage) {
                self.searchType = kHomePagePullSearch;
            }
            else if (_refertype == SNSearchReferHotSearch) {
                self.searchType = khotSearch;
            }

            if (self.searchType.length == 0) {
                self.searchType = kSearchNews;
            }
            [referInfo setObject:self.searchType forKey:kNewsFrom];
            [context setValuesForKeysWithDictionary:referInfo];
            if ([SNUtility isProtocolV2:[url URLDecodedString]] && [url hasPrefix:kProtocolNews]) {
                [SNUtility shouldUseSpreadAnimation:YES];
            }
            else {
                [SNUtility shouldUseSpreadAnimation:NO];
            }
            BOOL result = [SNUtility openProtocolUrl:url context:context];
            return !result;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //@qz 更改webview 闪白的问题 第三步
    _webView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

#pragma mark SNActionSheetDelegate
- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0 : {
        }
            break;
        case 1 : {
            [self clearAllHistory];
        }
            break;
        default:
            break;
    }
}

#pragma mark 对外
- (void)search:(NSString *)searchText{
    _textField.text = searchText;
    NSString * keyFrom = @"&keyfrom=hot";
    [self startSearch:searchText keyFrom:keyFrom];
}
- (void)searchNoAutoCorrection:(NSString *)searchText
{
    _textField.text = searchText;
    NSString *keyFrom = @"&keyfrom=input2&autoCorrection=0";
    [self startSearch:searchText keyFrom:keyFrom];
}

#pragma mark 首页搜索

- (void)beginSearchAndreloadHotWords{
    _suggestionList = nil;
    self.textField.text = @"";
    [self.textField becomeFirstResponder];
    //频道管理搜索不需要搜索热词
    if (!self.isHideHotWords && ![self isChannelSearch]) {
        NSArray *hotwords = [SNRollingNewsPublicManager sharedInstance].searchHotWord;
        if (self.refertype == SNSearchReferNovel) {
            hotwords = [SNRollingNewsPublicManager sharedInstance].novelSearchHotWord;
        }
        
        if (hotwords.count != 0) {
            NSString *keyWords = [hotwords objectAtIndex:0];
            self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:keyWords attributes:@{NSForegroundColorAttributeName: [SNSkinManager color:SkinText4], NSFontAttributeName : [SNSkinManager font:SkinFontD]}];
            self.hotSearchWords = [NSArray arrayWithArray:hotwords];
            //@qz 原来的逻辑加载热词时候就把输入的搜索词清空了 但是取消按钮可能之前的状态还是"搜索"
            [self setCancelButtonState:NO];
        }
        [self switchToView:SNSearchWebViewInputing];
    }
}

#pragma mark SHH5SearchApiProtocol

- (NSString *)jsGetSearchHotWord{
    return _textField.text;
}

- (void)jsSetSearchWord:(NSString *)keyWrods{
    _textField.text = keyWrods;
    [self startSearch:keyWrods keyFrom:@"&keyfrom=hot"];
}
- (void)directSearch:(NSString *)keyWrods{
    [self searchNoAutoCorrection:_textField.text];
}

- (void)updateFontTheme {
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.fontChanged" withObject:[NSNumber numberWithInteger:[SNUtility getNewsFontSizeIndex] - 2]];
}

- (BOOL)isChannelSearch
{
    return _refertype == SNSearchReferChannelMannagerBottomSearch || _refertype == SNSearchReferChannel;
}

@end
