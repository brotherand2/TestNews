//
//  SNDownloadingExViewController.m
//  sohunews
//
//  Created by Diaochunmeng on 13-4-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "UIColor+ColorUtils.h"
#import "SNDownloadingExViewController.h"
#import "SNDownloadingVController.h"
#import "SNDownloadManager.h"
#import "SNDownloadViewController.h"
#import "DACircularProgressView.h"
#import "SNDownloadScheduler.h"
#import "SNDatabase_SubscribeCenter.h"
#import "SNDBManager.h"
#import "SNSubDownloadManager.h"


#define SCREEN_WIDTH (TTScreenBounds().size.width)
#define SCREEN_HEIGHT (TTScreenBounds().size.height-20 + kSystemBarHeight)
#define TITLE_LINE_HEIGHT 44
#define BUTTON_LINE_HEIGHT 44
#define PROCESS_LINE_HEIGHT 44
#define TAIL_LINE_HEIGHT (5+73)
//#define kDownloadingButtonColor  @"kDownloadingButtonColor"
//#define kDownloadingSettingColor @"kDownloadingSettingColor"

@interface SNDownloadingExViewController()
-(void)createGuideView;
-(void)createEmptyView;
-(void)createTitleLine;
-(void)createButtonLine;
-(void)createProcessLine;
-(void)createTableLine;
-(void)createTailLine;

-(void)updateGuideView;
-(void)updateEmptyView;
-(void)updateTitleLine;
-(void)updateButtonLine;
-(void)updateProcessLine;
-(void)updateTableLine;
-(void)updateTailLine;

-(void)showOrHideMutipleViews;
@end

BOOL g_isPresentingNow;

@implementation SNDownloadingExViewController
@synthesize tipLabel = _tipLabel;
@synthesize percent = _percent;
@synthesize percentMark = _percentMark;
@synthesize guideView = _guideView;
@synthesize emptyView = _emptyView;
@synthesize tipButton = _tipButton;
@synthesize cancelButton = _cancelButton;
@synthesize setttingButton = _setttingButton;
@synthesize downloadedButton = _downloadedButton;
@synthesize currentPercent = _currentPercent;

@synthesize bgView = _bgView;
@synthesize progressBar = _progressBar;
@synthesize downloadingViewController = _downloadingViewController;

+(BOOL)isPresentingNow
{
    return g_isPresentingNow;
}

//+(SNDownloadingExViewController*)shareInstance
//{
//    static SNDownloadingExViewController* downloadingInstance = nil;
//    @synchronized(self){
//        if (!downloadingInstance) {
//            downloadingInstance  = [[SNDownloadingExViewController alloc] init];
//        }
//    }
//    return downloadingInstance;
//}

//-(void)presentModalView:(UIViewController*)aViewContronller
//{
//}

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
    if (self = [super initWithNavigatorURL:URL query:query])
    {
    }
    return self;
}

-(void)dealloc
{
    [[SNDownloadManager sharedInstance] setDelegate:nil];
    [[SNDownloadScheduler sharedInstance] removeDelegate:_downloadingViewController];
    
    _progressBar.delegate = nil;
    [_progressBar invalidateTimer];
    [_progressBar removeFromSuperview];
     //(_progressBar);
    
     //(_tipLabel);
     //(_percent);
     //(_percentMark);
     //(_guideView);
     //(_emptyView);
     //(_tipButton);
     //(_cancelButton);
     //(_setttingButton);
     //(_downloadedButton);
    
     //(_bgView);
    
    _downloadingViewController.progressBar = nil;
     //(_downloadingViewController);
}

-(void)loadView
{
    [super loadView];
    
    [self createTitleLine];
    [self createButtonLine];
    [self createProcessLine];
    [self createTableLine];
    [self createTailLine];
    [self createGuideView];
    [self createEmptyView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidUnload
{
    [[SNDownloadManager sharedInstance] setDelegate:nil];
    [[SNDownloadScheduler sharedInstance] removeDelegate:_downloadingViewController];
    
    [super viewDidUnload];
    
    _progressBar.delegate = nil;
    [_progressBar invalidateTimer];
    [_progressBar removeFromSuperview];
     //(_progressBar);
    
     //(_tipLabel);
     //(_percent);
     //(_percentMark);
     //(_guideView);
     //(_emptyView);
     //(_tipButton);
     //(_cancelButton);
     //(_setttingButton);
     //(_downloadedButton);
    
     //(_bgView);
    
    _downloadingViewController.progressBar = nil;
     //(_downloadingViewController);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    g_isPresentingNow = YES;
    
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    //[_downloadingViewController viewWillAppear:animated];

    [self updateGuideView];
    [self updateEmptyView];
    [self updateTitleLine];
    [self updateButtonLine];
    [self updateProcessLine];
    [self updateTableLine];
    [self updateTailLine];
    
//    BOOL isDownloading = [SNDownloadScheduler sharedInstance].isDownloading;
//    if(!isDownloading && !_referFromDownloaded)
//    {
//        [_progressBar resetNow];
//        [_downloadingViewController oneKeyDownloadMySubsAndNews];
//    }
//    
//    _referFromDownloaded = NO;
//    [self performSelector:@selector(showOrHideMutipleViews) withObject:nil afterDelay:0.3f];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([TTNavigator navigator].visibleViewController == self) {
        BOOL isDownloading = [SNDownloadScheduler sharedInstance].isDownloading;
        if(!isDownloading && !_referFromDownloaded)
        {
            [_progressBar resetNow];
            [_downloadingViewController oneKeyDownloadMySubsAndNews];
        }
        
        _referFromDownloaded = NO;
        [self performSelector:@selector(showOrHideMutipleViews) withObject:nil afterDelay:0.3f];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)createEmptyView
{
    NSInteger y_offset = 145 + kSystemBarHeight;
    CGRect frame = CGRectMake(0, y_offset, SCREEN_WIDTH, SCREEN_HEIGHT-y_offset-(TAIL_LINE_HEIGHT+2));
    self.emptyView = nil;
    _emptyView = [[UIView alloc] initWithFrame:frame];
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];
    
    frame = CGRectMake(87, 0, 215, 25);
    UILabel* line1Label = [[UILabel alloc] initWithFrame:frame];
    line1Label.tag = 201;
    line1Label.textAlignment = NSTextAlignmentRight;
    line1Label.font = [UIFont systemFontOfSize:15];
    line1Label.backgroundColor = [UIColor clearColor];
    line1Label.userInteractionEnabled = YES;
    [self.emptyView addSubview:line1Label];
}

-(void)createGuideView
{
    NSInteger y_offset = 145 + kSystemBarHeight;
    CGRect frame = CGRectMake(0, y_offset, SCREEN_WIDTH, SCREEN_HEIGHT-y_offset-(TAIL_LINE_HEIGHT+2));
    self.guideView = nil;
    _guideView = [[UIView alloc] initWithFrame:frame];
    self.guideView.hidden = YES;
    [self.view addSubview:self.guideView];
    
    frame = CGRectMake(122, 0, 215, 25);
    UILabel* line1Label = [[UILabel alloc] initWithFrame:frame];
    line1Label.tag = 201;
    line1Label.font = [UIFont systemFontOfSize:15];
    line1Label.backgroundColor = [UIColor clearColor];
    line1Label.userInteractionEnabled = YES;
    line1Label.text = NSLocalizedString(@"您还没有选择要离线的内容", nil);
    [self.guideView addSubview:line1Label];
    
    frame = CGRectMake(109+95+5, 26, 20, 25);
    UILabel* line1Label2_1 = [[UILabel alloc] initWithFrame:frame];
    line1Label2_1.tag = 202;
    line1Label2_1.font = [UIFont systemFontOfSize:15];
    line1Label2_1.backgroundColor = [UIColor clearColor];
    line1Label2_1.userInteractionEnabled = YES;
    line1Label2_1.text = NSLocalizedString(@"先", nil);
    [self.guideView addSubview:line1Label2_1];
    
    UIButton* setttingButton = [[UIButton alloc] initWithFrame:CGRectMake(109+105+1, 27, 50, 25)];
    setttingButton.tag = 203;
    setttingButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [setttingButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [setttingButton setTitle:@"设置" forState:UIControlStateNormal];
    [setttingButton addTarget:self action:@selector(onGoSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.guideView addSubview:setttingButton];
    
    frame = CGRectMake(109+148, 26, 80, 25);
    UILabel* line1Label2_2 = [[UILabel alloc] initWithFrame:frame];
    line1Label2_2.tag = 204;
    line1Label2_2.font = [UIFont systemFontOfSize:15];
    line1Label2_2.backgroundColor = [UIColor clearColor];
    line1Label2_2.userInteractionEnabled = YES;
    line1Label2_2.text = NSLocalizedString(@"一下吧", nil);
    [self.guideView addSubview:line1Label2_2];
}

-(void)createTitleLine
{
    //Head view
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"正在离线", nil),nil]];
    
    //设置label
    CGRect subRect = CGRectMake(260, 10 + kSystemBarHeight, 70, 24);
    self.tipLabel = nil;
    _tipLabel = [[UILabel alloc] initWithFrame:subRect];
    self.tipLabel.font = [UIFont systemFontOfSize:11];
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.userInteractionEnabled = YES;
    self.tipLabel.text = NSLocalizedString(@"隐藏", nil);
    [self.headerView addSubview:self.tipLabel];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBack:)];
    [self.tipLabel addGestureRecognizer:tap];
    
    //隐藏
    self.tipButton = nil;
    self.tipButton = [[UIButton alloc] initWithFrame:CGRectMake(277, kSystemBarHeight, 44, 44)];
    self.tipButton.accessibilityLabel = @"隐藏";
    [self.tipButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.tipButton];
}

-(void)createButtonLine
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    //取消
    self.cancelButton = nil;
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(119, 87 + kSystemBarHeight, 93, 46)];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton setTitle:@"取消下载" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(onCanel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    //设置
    self.setttingButton = nil;
    _setttingButton = [[UIButton alloc] initWithFrame:CGRectMake(212, 87 + kSystemBarHeight, 93, 46)];
    self.setttingButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.setttingButton setTitle:@"离线设置" forState:UIControlStateNormal];
    [self.setttingButton addTarget:self action:@selector(onGoSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.setttingButton];
}

-(void)createProcessLine
{
    CGRect progressRect = CGRectMake(17, 18+44 + kSystemBarHeight, 84, 84);
    
    self.bgView = nil;
    _bgView = [[UIImageView alloc] initWithImage:nil];
    self.bgView.tag = 101;
    self.bgView.frame = progressRect;
    [self.view addSubview:self.bgView];
    
    CGRect subRect = CGRectMake(17, 59.5 + kSystemBarHeight, 84, 84);
    self.percent = nil;
    _percent = [[UILabel alloc] initWithFrame:subRect];
    self.percent.hidden = YES;
    self.percent.tag = 102;
    self.percent.backgroundColor = [UIColor clearColor];
    self.percent.userInteractionEnabled = NO;
    self.percent.text = NSLocalizedString(@"", nil);
    self.percent.textAlignment = NSTextAlignmentCenter;
    self.percent.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:self.percent];
    
    subRect = CGRectMake(17, 113 + kSystemBarHeight, 84, 20);
    self.percentMark = nil;
    _percentMark = [[UILabel alloc] initWithFrame:subRect];
    self.percentMark.hidden = YES;
    self.percentMark.tag = 103;
    self.percentMark.textColor = [UIColor redColor];
    self.percentMark.backgroundColor = [UIColor clearColor];
    self.percentMark.userInteractionEnabled = NO;
    self.percentMark.text = NSLocalizedString(@"%", nil);
    self.percentMark.textAlignment = NSTextAlignmentCenter;
    self.percentMark.font = [UIFont systemFontOfSize:9];
    [self.view addSubview:self.percentMark];
    
    progressRect = CGRectMake(17+2, 18+44+2 + kSystemBarHeight, 80, 80);
    _progressBar = [[DACircularProgressView alloc] initWithFrame:progressRect];
    _progressBar.dySpeed = YES;
    _progressBar.increaseOnly = YES;
    _progressBar.delegate = self;
    _progressBar.innerRadius = 34;
    _progressBar.backgroundColor = [UIColor clearColor];
    _progressBar.trackTintColor = [UIColor clearColor];
    [self.view addSubview:_progressBar];
    
    //下载着一半再次进入，更新当前状态
    CGFloat percent = [SNDownloadScheduler sharedInstance].percent;
    [_progressBar updateProgress:percent anmiated:NO];
    [self updateProcessLine:percent];
    [self notifyAnimationUpdateTo:(NSInteger)(percent*100)];
}

-(void)notifyAnimationUpdateTo:(NSInteger)aPercent
{
    self.currentPercent = aPercent;
    UILabel* percent = (UILabel*)[self.view viewWithTag:102];
    percent.text = [NSString stringWithFormat:@"%ld", (long)aPercent];
    self.percent.accessibilityLabel = [NSString stringWithFormat:@"离线进度:百分之%ld",(long)aPercent];
    self.percentMark.accessibilityLabel = [NSString stringWithFormat:@"离线进度:百分之%ld",(long)aPercent];
}

-(void)createTableLine
{
    //正在下载列表
    _downloadingViewController = [[SNDownloadingVController alloc] initWithIDelegate:nil];
    _downloadingViewController.progressBar = _progressBar;
    _downloadingViewController.downloadingExViewController = self;
    _downloadingViewController.view.hidden = YES;
    
    NSInteger yOffset = 155 + kSystemBarHeight;
    NSInteger height = SCREEN_HEIGHT - TAIL_LINE_HEIGHT - yOffset - 8;
    CGRect _tableViewCGRect = CGRectMake(0, yOffset, SCREEN_WIDTH, height);
    _downloadingViewController.view.frame = _tableViewCGRect;
    _downloadingViewController.view.backgroundColor = [UIColor darkGrayColor];
    [[SNDownloadManager sharedInstance] setDelegate:_downloadingViewController];
    [self.view addSubview:_downloadingViewController.view];

    UIImage* bgimg = [UIImage imageNamed:@"downloading_view_mask.png"];
    
    UIImageView* maskView = [[UIImageView alloc] initWithImage:nil];
    maskView.hidden = YES;
    maskView.tag = 301;
    _tableViewCGRect.origin.y -= 8;
    _tableViewCGRect.size.height += 16;
    maskView.frame = _tableViewCGRect;
    maskView.image = bgimg;
    [self.view addSubview:maskView];
}

-(void)createTailLine
{
    //已离线刊物
    self.downloadedButton = nil;
    CGRect subRect = CGRectMake(SCREEN_WIDTH-105-12, SCREEN_HEIGHT-TAIL_LINE_HEIGHT, 105, 73);
    self.downloadedButton = nil;
    _downloadedButton = [[UIButton alloc] initWithFrame:subRect];
    _downloadedButton.accessibilityLabel = @"已离线内容";
    [self.downloadedButton addTarget:self action:@selector(onGoDownloaded:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadedButton];
}

-(void)updateProcessLine:(CGFloat)aPercent
{
    UIImage* bgimg = nil;
    BOOL downloading = [SNDownloadScheduler sharedInstance].isDownloading;
    
    UIImageView* bgView = (UIImageView*)[self.view viewWithTag:101];
    if(!downloading)
    {
        UILabel* percent = (UILabel*)[self.view viewWithTag:102];
        percent.hidden = YES;
        UILabel* percentMark = (UILabel*)[self.view viewWithTag:103];
        percentMark.hidden = YES;
        
        bgimg = [UIImage imageNamed:@"downloading_progressball_bg.png"];
        bgView.image = bgimg;
    }
    else
    {
        UILabel* percent = (UILabel*)[self.view viewWithTag:102];
        percent.hidden = NO;
        UILabel* percentMark = (UILabel*)[self.view viewWithTag:103];
        percentMark.hidden = NO;
        
        bgimg = [UIImage imageNamed:@"downloading_progressball_bg2.png"];
        bgView.image = bgimg;
    }
    
    //update
    [self performSelector:@selector(showOrHideMutipleViews) withObject:nil afterDelay:0.1f];
}

-(void)changeViewBg
{
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

-(void)customTheme
{
    [self customTitleView];
    [self changeViewBg];
    [self.headerView updateTheme];
}

-(void)updateTheme:(NSNotification*)notification
{
    if (![self isViewAppearing])
        return;
    
    [self customTheme];
}

 -(void)onBack:(id)sender
 {
     g_isPresentingNow = NO;
     
     if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
         [self dismissViewControllerAnimated:YES completion:nil];
     else
         [self performSelectorOnMainThread:@selector(dismissModalViewController) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
 }

-(void)updateEmptyView
{
    self.emptyView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    UIColor* fontColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingButtonColor]];
    
    UILabel* label1 = (UILabel*)[self.emptyView viewWithTag:201];
    label1.textColor = fontColor;
}

-(void)updateGuideView
{
    self.guideView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    UIColor* fontColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingButtonColor]];
    UIColor* settingFontColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingSettingColor]];
    
    UILabel* label1 = (UILabel*)[self.guideView viewWithTag:201];
    label1.textColor = fontColor;
    UILabel* label2 = (UILabel*)[self.guideView viewWithTag:202];
    label2.textColor = fontColor;
    UIButton* setting = (UIButton*)[self.guideView viewWithTag:203];
    [setting setTitleColor:settingFontColor forState:UIControlStateNormal];
    [setting setTitleColor:settingFontColor forState:UIControlStateHighlighted];
    UILabel* label3 = (UILabel*)[self.guideView viewWithTag:204];
    label3.textColor = fontColor;
}

-(void)updateTitleLine
{
    self.tipLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsChannelSelectedTextColor]];
    [self.tipButton setImage:[UIImage imageNamed:@"downloading_hide_button.png"] forState:UIControlStateNormal];
}

-(void)updateButtonLine
{
    [self.cancelButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingButtonColor]] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"downloading_button_left.png"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"downloading_button_left_hl.png"] forState:UIControlStateHighlighted];
    
    [self.setttingButton setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingButtonColor]] forState:UIControlStateNormal];
    [self.setttingButton setBackgroundImage:[UIImage imageNamed:@"downloading_button_right.png"] forState:UIControlStateNormal];
    [self.setttingButton setBackgroundImage:[UIImage imageNamed:@"downloading_button_right_hl.png"] forState:UIControlStateHighlighted];
}

-(void)updateProcessLine
{
    UIImage* bgimg = nil;
    BOOL downloading = [SNDownloadScheduler sharedInstance].isDownloading;
    
    if(self.progressBar!=nil && (self.currentPercent>0 || downloading))
        bgimg = [UIImage imageNamed:@"downloading_progressball_bg2.png"];
    else
        bgimg = [UIImage imageNamed:@"downloading_progressball_bg.png"];
    _bgView.image = bgimg;
    
    self.percent.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingPercentColor]];
    self.percentMark.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingPercentColor]];
    self.progressBar.progressTintColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingPercentColor]];
}

-(void)updateTableLine
{
    UIImageView* maskView = (UIImageView*)[self.view viewWithTag:301];
    UIImage* bgimg = [UIImage imageNamed:@"downloading_view_mask.png"];
    maskView.image = bgimg;
}

-(void)updateTailLine
{
    [self.downloadedButton setImage:[UIImage imageNamed:@"downloading_pocket.png"] forState:UIControlStateNormal];
    [self.downloadedButton setImage:[UIImage imageNamed:@"downloading_pocket.png"] forState:UIControlStateHighlighted];
}

-(void)showOrHideMutipleViews
{
    BOOL isDownloading = [SNDownloadScheduler sharedInstance].isDownloading;
    NSArray *_toBeDownloadedSubs = [[SNDBManager currentDataBase] getSubscribeCenterSelectedMySubList];    
    BOOL someFail = [[SNDownloadScheduler sharedInstance] isAllDownloadFinishedButAndSomeFail];
    BOOL someCancel = [[SNDownloadScheduler sharedInstance] isAllDownloadFinishedButAndSomeCancel];
    someCancel |= [SNDownloadScheduler sharedInstance].didUserCancelAllDownloads;
    BOOL allSuccess = [[SNDownloadScheduler sharedInstance] isAllDownloadFinishedAndNoFail];
    
    UIImageView* maskView = (UIImageView*)[self.view viewWithTag:301];
    if(isDownloading || someFail)
    {
        maskView.hidden = NO;
        self.downloadingViewController.view.hidden = NO;
        self.guideView.hidden = YES;
        self.emptyView.hidden = YES;
    }
    else if(_toBeDownloadedSubs==nil || [_toBeDownloadedSubs count]==0)
    {
        maskView.hidden = YES;
        self.downloadingViewController.view.hidden = YES;
        self.emptyView.hidden = YES;
        self.guideView.hidden = NO;
    }
    else if(allSuccess && !someCancel)
    {
        UILabel* label = (UILabel*)[self.emptyView viewWithTag:201];
        label.text = NSLocalizedString(@"所选内容暂无更新", nil);
        
        maskView.hidden = YES;
        self.downloadingViewController.view.hidden = YES;
        self.emptyView.hidden = NO;
        self.guideView.hidden = YES;
    }
    else if(someCancel)
    {
        UILabel* label = (UILabel*)[self.emptyView viewWithTag:201];
        label.text = NSLocalizedString(@"没有正在离线的内容", nil);
        
        maskView.hidden = YES;
        self.downloadingViewController.view.hidden = YES;
        self.emptyView.hidden = NO;
        self.guideView.hidden = YES;
    }
}

-(void)onCanel:(id)sender
{
    [[SNDownloadScheduler sharedInstance] cancelAll];
    [self performSelector:@selector(onBack:) withObject:nil afterDelay:0.3f];
}

-(void)onGoSetting:(id)sender
{   
    NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
    [_query setObject:[self class] forKey:@"referfrom"];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://downloadSettingViewController"] applyAnimated:YES] applyQuery:_query];
    [[TTNavigator navigator] openURLAction:_urlAction];
     //(_query);
}

-(void)onGoDownloaded:(id)sender
{
    _referFromDownloaded = YES;
    
    NSMutableDictionary *_query = [[NSMutableDictionary alloc] init];
    [_query setObject:@"SNDownloadingExViewController" forKey:@"referFrom"];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://globalDownloader"] applyAnimated:YES] applyQuery:_query];
    [[TTNavigator navigator] openURLAction:_urlAction];
     //(_query);
}

-(void)didFinishedDownloadAllInMainThread
{
    [self performSelector:@selector(showOrHideMutipleViews) withObject:nil afterDelay:0.3f];
    
    [self notifyAnimationUpdateTo:0.0f];
    [self.progressBar resetNow];
    [self updateProcessLine];
    [self updateProcessLine:0.0f];
}
@end
