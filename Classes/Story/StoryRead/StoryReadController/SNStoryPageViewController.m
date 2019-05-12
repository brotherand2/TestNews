//
//  SNStoryPageViewController.m
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/12.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryPageViewController.h"
#import "SNStoryCatelogController.h"
#import "SNPageViewController.h"
#import "SNStoryContentLabel.h"
#import "SNNewAlertView.h"
#import "UIViewAdditions+Story.h"
#import "SNPopOverMenu.h"
#import "SNStoryDealView.h"
#import "SNStoryFontAdjustmentView.h"
#import "SNStoryFirstReadTipView.h"//阅读引导
#import "SNNovelShelfController.h"
#import "SNStoryContanst.h"
#import "SNStorySlider.h"
#import "SNNovelThemeManager.h"
#import "SNStoryPublicLinks.h"

#import "ChapterList.h"
#import "StoryBookList.h"
#import "StoryBookShelfList.h"
#import "StoryConfig.h"
#import "SNStoryChapter.h"
#import "SNStoryPage.h"
#import "SNNovelUtilities.h"
#import "SNBookShelf.h"
#import "SNStoryUtility.h"
#import "SNVoucherCenter.h"
#import "SNStoryWaitingActivityView.h"
#import "StoryBookAnchor.h"
#import "SNNewsLoginManager.h"

#define FONTSETTINGVIEWHEIGHT 332/2
#define WaitingActivityViewLeftOffset                     0.0//等待加载view的左边距
#define WaitingActivityViewTopOffset                      0.0//等待加载view的上边距
#define StatusBarHeight                                   ([[SNDevice sharedInstance] isPhoneX]?50:44)//状态栏高度
#define DealView_Slider_ProgresSlideOriginX               20//ProgresSlide起始位置


//tag值
#define StatusBar_LineTag                                 4311
#define StoryDealViewButtonBaseTag                        1000
#define DealViewHeight                                    ([[SNDevice sharedInstance] isPhoneX]?112:92)

typedef  enum
{
    StoryOpenRemindBookShelfNone,//开启提醒\加入书架不处理
    StoryOpenRemind,//开启提醒
    StoryBookShelfCheck//加入书架
}CheckBooshelType;

@interface SNStoryPageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate,SNStoryDealViewProtocol,SNStoryFontAdjustmentViewDelegate,SNStoryCatelogDelegate,SNNewAlertViewDelegate>

@property (nonatomic, strong)SNPageViewController *pageViewController;
@property (nonatomic, strong) UIFont *cur_font;//阅读页字体
@property (nonatomic, assign)BOOL isNext;//是否向下翻页
@property(nonatomic, assign)BOOL isTapCenter;//记录点击的位置
@property(nonatomic, assign)BOOL hasOpenPush;//是否开启了提醒
@property(nonatomic, assign)BOOL hasAddBookShelf;//是否开加入了书架
@property(nonatomic, assign)BOOL isRequesting;//用于控制可读章节循环下载
@property(nonatomic, strong)SNStoryDealView *dealView;//阅读操作兰
@property(nonatomic, strong)SNStoryFontAdjustmentView *fontView;//字体相关设置
@property(nonatomic, strong)SNStoryWaitingActivityView *waitingActivityView;
@property(nonatomic, strong)UIView *statusBar;//状态栏
@property (nonatomic, strong)NSDate *date;//记录进入阅读的起始时间，用于埋点统计
@property(nonatomic, assign)int downloadCount;//记录下载次数
@property(nonatomic,strong)NSString *recordPid;//记录登录状态
@property(nonatomic,assign)BOOL recordReportLogin;//记录举报登录
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
@property(nonatomic,strong)SNNovelShelfController *previousConroller;
@property(nonatomic,strong)NSString *updateFontPayContent;//更新付费内容

@end

@implementation SNStoryPageViewController

-(void)dealloc
{
    if (_dealView && _dealView.superview) {
        [_dealView removeFromSuperview];
        _dealView = nil;
    }
    [SNNotificationManager removeObserver:self];
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {//初始化值
        self.hasOpenPush = NO;
        self.hasAddBookShelf = NO;
        self.isRequesting = NO;
        self.isTapCenter = NO;
        self.downloadCount = 0;
        self.availableChapterArray = [NSMutableArray array];
        self.dealView.maxChapterCount = self.chapterArray.count;
        self.chapterCacheDic = [NSMutableDictionary dictionary];
        self.payArray = [NSMutableArray array];
        self.recordReportLogin = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.date = [NSDate date];
    
    //第一次安装初始化背景色
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    if (!storyColorTheme || storyColorTheme.length <= 0) {
        [userDefault setObject:@"0" forKey:@"storyColorTheme"];
        [userDefault setObject:@"0" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
    }
    self.recordPid = [SNStoryUtility getPid];
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    
    //根据给定的属性实例化UIPageViewController
    self.pageViewController = [[SNPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:options];
    
    //设置UIPageViewController代理和数据源
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    //设置UIPageViewController 尺寸
    self.pageViewController.view.frame = self.view.bounds;
    
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"0"] && ![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
        self.view.backgroundColor = [SNStoryPage getReadBackgroundColor];
        self.pageViewController.view.backgroundColor =[SNStoryPage getReadBackgroundColor];
    }
    else
    {
        UIColor *color = [UIColor colorFromKey:@"kThemeBg4Color"];
        self.view.backgroundColor = color;
        self.pageViewController.view.backgroundColor = color;
    }
    
    //在页面上，显示UIPageViewController对象的View
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapevent:)];
    [self.view addGestureRecognizer:self.tapGesture];
    
    SNStoryDealView *dealView = [[SNStoryDealView alloc]initWithFrame:CGRectMake(0, View_Height, View_Width, DealViewHeight)];
    dealView.hidden = YES;
    dealView.delegate = self;
    self.dealView = dealView;
    
    SNStoryFontAdjustmentView *fontView = [[SNStoryFontAdjustmentView alloc] initWithFrame:CGRectMake(0, View_Height, View_Width, FONTSETTINGVIEWHEIGHT) novelId:self.novelId];
    fontView.hidden = YES;
    fontView.delegate = self;
    self.fontView = fontView;
    
    //状态栏
    self.statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, -StatusBarHeight, View_Width, StatusBarHeight)];
    self.statusBar.backgroundColor = [SNStoryUtility getReadColor];
    self.statusBar.hidden = YES;
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, StatusBarHeight - 0.5, View_Width, 0.5)];
    viewLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    viewLine.tag = StatusBar_LineTag;
    [self.statusBar addSubview:viewLine];
    [self.view addSubview:self.statusBar];
    
    self.waitingActivityView = [[SNStoryWaitingActivityView alloc]initWithFrame:CGRectMake(WaitingActivityViewLeftOffset, WaitingActivityViewTopOffset, View_Width, View_Height)];
    self.waitingActivityView.backgroundColor = [UIColor clearColor];
    self.waitingActivityView.center = self.view.center;
    [self.pageViewController.view addSubview:self.waitingActivityView];
    
    // 第一次使用小说，浮层引导提示
    [self firstUseStoryToolForShow];
    
    //设置第一次下载
    NSString *firstReadThisBook = [userDefault objectForKey:self.novelId];
    if (!firstReadThisBook || firstReadThisBook.length <= 0) {
        [userDefault setObject:@"0" forKey:self.novelId];
    }
    
    self.cur_font =  [UIFont systemFontOfSize:18];
    NSArray *array = [StoryConfig fecthStoryConfig];
    if (array.count > 0) {
        
        StoryConfig *config = [array firstObject];
        
        if (config.chapterFont > 0) {
            self.cur_font = [UIFont systemFontOfSize:config.chapterFont];
        }
    }
    
    [SNNotificationManager addObserver:self selector:@selector(updateNovelTheme) name:kNovelThemeDidChangeNotification object:nil];
    [SNNotificationManager addObserver : self selector : @selector (statusBarFrameWillChangeForStoryPage:) name : UIApplicationWillChangeStatusBarFrameNotification object : nil ];
    
    if (![self.openAnimation isEqualToString:@"open"]) {//入口动画
        
        [self.waitingActivityView startAnimating];
    }
    
    //异步处理已读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //设置已读
         if ([SNBookShelf isOnBookshelf:self.novelId] && self.pageType != StoryPageFromChannel) {//该书籍在书架，但不是从书架进入的，也需要调已读接口
             
             [SNBookShelf setBookHasRead:self.novelId complete:nil];
         }
    });
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setDelegate:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SNStoryContentController* vc = self.pageViewController.viewControllers.firstObject;
    [vc viewWillAppear:animated];
    
    [self statusBarChange];
    
    //登录状态改变
    if (self.recordReportLogin) {
        
        NSString *pid = [SNStoryUtility getPid];
        if (self.recordPid != pid) {
            self.recordPid = pid;
            self.recordReportLogin = NO;
            SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
            [currContentController loginSuccess];
        }
        
    }
    
    [SNBookShelf getBooks:@"" count:@"" complete:^(BOOL success,NSArray *books) {
        
        if (books && books.count > 0) {
            
            BOOL ishasBook = NO;
            for (NSDictionary *dic in books) {
                
                NSString *bookId = [NSString stringWithFormat:@"%ld",[[dic objectForKey:@"bookId"]integerValue]];
                if ([bookId isEqualToString:self.novelId]) {
                    ishasBook = YES;
                    
                    if ([[dic objectForKey:@"remind"]integerValue] == 0) {
                        self.hasOpenPush = NO;
                    } else {
                        self.hasOpenPush = YES;
                    }
                    break;
                }
            }
            
            self.hasAddBookShelf = ishasBook;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (![self.openAnimation isEqualToString:@"open"]) {//入口动画
        
        if (!self.screenBrightnessView) {
            
            [self novelDetail];//为什么放在这里呢？数据初始化数据，会卡push转场动画
            NSNumber* alphaNum = [SNUserDefaults objectForKey:kSNStory_Screen_Brightness];
            UIView* view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = alphaNum?alphaNum.floatValue:0;
            
            sohunewsAppDelegate* app = (sohunewsAppDelegate*)[UIApplication sharedApplication].delegate;
            [app.window addSubview:view];
            view.userInteractionEnabled = NO;
            self.screenBrightnessView = view;
        }
    }
    
    //户进入阅读页的时候进行埋点上报(首次进入和 切后台后再次进入)
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic_read&tp=pv&bookId=%@",self.novelId]];
}

-(BOOL)needPanGesture
{
    return NO;//禁止右滑返回
}

#pragma mark - UIScrollViewDelegate
///WARNING: Be careful with scrollview.contentOffset. It resets as the controller scrolls to new pages
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        SNStoryContentController *contentController=(SNStoryContentController *)[self.pageViewController.viewControllers firstObject];
        SNStoryChapter *model = [SNStoryPage initChapterWithPageViewController:self chapterIndex:contentController.chapterIndex font:self.cur_font];
        if (contentController.pageNum == model.chapterPageArray.count - 1) {
            [self enableChangePages:NO];
        }
    }else{
        if (!self.pageViewController.view.userInteractionEnabled) {
            [self enableChangePages:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.pageViewController.view.userInteractionEnabled) {
        [self enableChangePages:YES];
    }
}

#pragma mark - 第一次使用小说，浮层引导提示
-(void)firstUseStoryToolForShow
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"isFirstUseStoryTool"] || [[userDefault objectForKey:@"isFirstUseStoryTool"] isEqualToString:@"0"]) {
        SNStoryFirstReadTipView *firstReadTipView = [[SNStoryFirstReadTipView alloc]initWithFrame:CGRectMake(0, 0, View_Width, View_Height)];
        firstReadTipView.userInteractionEnabled = YES;
        [self.pageViewController.view addSubview:firstReadTipView];
        [self.pageViewController.view bringSubviewToFront:firstReadTipView];
        [userDefault setObject:@"1" forKey:@"isFirstUseStoryTool"];
    }
}

-(void)setIsFinishOpenAnimation:(BOOL)isFinishOpenAnimation
{
    if (isFinishOpenAnimation) {
        [self.waitingActivityView startAnimating];
        //加延迟原因：在书架动画完成改成yes，但是没有走出block，初始化数据(大量)，会长时间白屏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self novelDetail];
        });
    }
}

//调节屏幕亮度
- (void)changeScreenBrightness:(CGFloat)readRate{
    
    CGFloat f = (1-readRate-0.2);
    if (f<0) {
        f = 0;
    }
    
    self.screenBrightnessView.alpha = f;
    
    NSNumber* num = [NSNumber numberWithFloat:f];
    [SNUserDefaults setObject:num forKey:kSNStory_Screen_Brightness];
}

#pragma mark 查询书籍信息
-(void)novelDetail
{
    if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {//无网络用DB中的数据
        
        [self initPageArrayWithNovelId:self.novelId chapterId:0 font:self.cur_font chapterIndex:0];
        [self hasReadchapterDealWithBook:self.book];
    } else {
        [SNStoryPage storyDetailRequestWithBookId:self.novelId pageTye:StoryNormalPage completeBlock:^(id result) {//有网络，刷新数据
            
            [self initPageArrayWithNovelId:self.novelId chapterId:0 font:self.cur_font chapterIndex:0];
            [self hasReadchapterDealWithBook:self.book];
        }];
    }
}

#pragma mark 进入阅读页，已读章节处理(阅读入口)
-(void)hasReadchapterDealWithBook:(StoryBookList *)book
{
    self.dealView.maxChapterCount = self.chapterArray.count;
    self.isAnchor = NO;
    NSInteger chapterIndex = book.hasReadChapterIndex;
    NSInteger chapterId = book.hasReadChapterId;
    NSInteger chapterPageNum = book.hasReadPageNum;
    SNStoryChapter *storyChapter = [SNStoryPage initChapterWithPageViewController:self chapterIndex:chapterIndex font:self.cur_font];
    
    if (!book) {//书籍请求失败
        chapterIndex = 0;
        chapterPageNum = 0;
        [self chapterReadDealWithChapterIndex:chapterIndex chapterPageNum:chapterPageNum storyChapter:storyChapter];
    }else{
        
        if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {//无网络直接显示
            
            [self chapterReadDealWithChapterIndex:chapterIndex chapterPageNum:chapterPageNum storyChapter:storyChapter];
        }else{
            
            if (chapterId > 0) {//已读过,且本地有记录，走本地
                [self chapterReadDealWithChapterIndex:chapterIndex chapterPageNum:chapterPageNum storyChapter:storyChapter];
            } else {
                
                //根据页码或偏移量做兼容
                __block StoryBookAnchor *anchor = [StoryBookAnchor fetchBookAnchorWithBookId:self.novelId];
                
                if (anchor && anchor.chapter > 0) {//数据库中有锚点，取数据库
                    [self anchorDealWithBookAnchor:anchor storyChapter:storyChapter];
                }else{
                    
                    //获取锚点
                    [SNStoryPage novelGet_AnchorDic:@{@"platform":@"5"} completeBlock:^(id result) {
                        
                        anchor = [StoryBookAnchor fetchBookAnchorWithBookId:self.novelId];
                        [self anchorDealWithBookAnchor:anchor storyChapter:storyChapter];
                    }];
                }
            }
        }
    }
}

#pragma mark 获取服务端锚点，计算章节及页码
-(void)anchorDealWithBookAnchor:(StoryBookAnchor *)bookAnchor storyChapter:(SNStoryChapter *)storyChapter
{
    NSInteger chapterIndex = 0;
    NSInteger chapterPageNum = 0;
    //取出库中的chapterId，算出章节索引
    if (bookAnchor && bookAnchor.chapter > 0) {
        chapterIndex = [self binaryFetchWithArray:self.chapterArray chapterId:bookAnchor.chapter];
        if (storyChapter.chapterContent.length > 0) {//有内容，取页码
            
            chapterPageNum = [SNStoryPage getPageNumFromPageOffsetWithPageOffset:bookAnchor.pageNO storyChapter:storyChapter];//5.9.1新老版本兼容，即页码与偏移量兼容(5.9.1以前是页码，之后是偏移量)
        }else{
            self.isAnchor = YES;
        }
    }else{
        //服务端没有锚点，直接走默认章节集页码
    }
    
    [self chapterReadDealWithChapterIndex:chapterIndex chapterPageNum:chapterPageNum storyChapter:storyChapter];
}

#pragma mark 阅读页码及章节处理
-(void)chapterReadDealWithChapterIndex:(NSInteger)chapterIndex chapterPageNum:(NSInteger)chapterPageNum storyChapter:(SNStoryChapter *)storyChapter
{
    //页面进入逻辑处理
    if (self.pageType == StoryPageFromH5Catelaog) {
        //有可能从书籍详情页目录进入的，此时
        if (chapterIndex != self.chapterIndex) {
            chapterIndex = self.chapterIndex;
            chapterPageNum = 0;
        }
    }
    else if (self.pageType == StoryPageFromProtocol || self.pageType == StoryPageFromH5Detail) {
        
        //二代协议跳转、详情页进入阅读页(单独处理的原因是，他们是按照章节id跳转，而原有逻辑走数组下标)
        if (self.chapterId > 0 && self.chapterId <= self.chapterArray.count) {
            
            //查找是第几章节，在数组中的位置
            chapterIndex = [self binaryFetchWithArray:self.chapterArray chapterId:self.chapterId];
            chapterPageNum = 0;
        }
    }
    else
    {
        //页面直接被杀死之前，改了字号，造成页数改变，这里需要重新记录页码
        NSInteger count = storyChapter.chapterPageArray.count;
        if (count > 0) {
            
            if (chapterPageNum >= count) {
                chapterPageNum = count - 1;
            }
        }
    }
    
    self.dealView.slider.isRefreshSlider = YES;
    [self setPageViewControllerWithChapterIndex:chapterIndex pageIndex:chapterPageNum scrollType:StoryOriginPageView scrollAnimation:StoryPageScrollAnimationNone];
}

-(void)statusBarChange
{
    
    if ([self.view.superview.subviews containsObject:self.dealView]) {
        
        if (self.dealView.hidden) {
            self.dealView.frame = CGRectMake(0, kAppScreenHeight, View_Width, DealViewHeight);
        } else {
            self.dealView.frame = CGRectMake(0, kAppScreenHeight - DealViewHeight, View_Width, DealViewHeight);
        }
    }
    else
    {
        self.dealView.frame = CGRectMake(0, kAppScreenHeight, View_Width, DealViewHeight);
    }
    
    if ([self.view.superview.subviews containsObject:self.fontView]) {
        if (self.fontView.hidden) {
            self.fontView.frame = CGRectMake(0, kAppScreenHeight, View_Width, FONTSETTINGVIEWHEIGHT);
        } else {
            self.fontView.frame = CGRectMake(0, kAppScreenHeight - FONTSETTINGVIEWHEIGHT, View_Width, FONTSETTINGVIEWHEIGHT);
        }
        
    } else {
        self.fontView.frame = CGRectMake(0, kAppScreenHeight, View_Width, FONTSETTINGVIEWHEIGHT);
    }
}

-(void)statusBarFrameWillChangeForStoryPage:(NSNotification *)notification
{
    //这里面有一个坑，当状态栏隐藏时，[UIApplication sharedApplication].statusBarFrame为0
    CGRect statusBarFrame = [notification.userInfo[UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    float originY = 0;
    if (statusBarFrame.size.height >= 40) {
        originY = kSystemBarHeight;
    }

    
    if ([self.view.superview.subviews containsObject:self.dealView]) {
        
        if (self.dealView.hidden) {
            self.dealView.frame = CGRectMake(0, View_Height, View_Width, DealViewHeight);
        } else {
            self.dealView.frame = CGRectMake(0, View_Height - DealViewHeight - originY, View_Width, DealViewHeight);
        }
    }
    else
    {
        self.dealView.frame = CGRectMake(0, View_Height, View_Width, DealViewHeight);
    }
    
    if ([self.view.superview.subviews containsObject:self.fontView]) {
        if (self.fontView.hidden) {
            self.fontView.frame = CGRectMake(0, View_Height, View_Width, FONTSETTINGVIEWHEIGHT);
        } else {
            self.fontView.frame = CGRectMake(0, View_Height - FONTSETTINGVIEWHEIGHT - originY, View_Width, FONTSETTINGVIEWHEIGHT);
        }
        
    } else {
        self.fontView.frame = CGRectMake(0, View_Height, View_Width, FONTSETTINGVIEWHEIGHT);
    }
}

-(void)setPageViewControllerWithChapterIndex:(int)chapterIndex pageIndex:(int)pageIndex scrollType:(StoryScrollType)scrollType scrollAnimation:(StoryPageScrollAnimation)scrollAnimation
{
    SNStoryContentController *contentController = [SNStoryPage viewControllerWithChapterIndex:chapterIndex pageIndex:pageIndex pageViewController:self font:self.cur_font storyScrollType:scrollType];
    [self.waitingActivityView stopAnimating];
    [self.waitingActivityView removeFromSuperview];
    self.waitingActivityView = nil;
    if (contentController) {
        
        NSArray *viewControllers = [NSArray arrayWithObject:contentController];
        __weak __typeof(self) weakSelf = self;
        
        [self.pageViewController setViewControllers:viewControllers direction:(scrollAnimation == StoryPageScrollAnimationLeftToRight)? UIPageViewControllerNavigationDirectionReverse:UIPageViewControllerNavigationDirectionForward animated:(scrollAnimation == StoryPageScrollAnimationNone)?NO:YES completion:^(BOOL finished) {
            
            //为什么这么处理，因为点击翻页有动画，快速点击有bug
            if (scrollAnimation == StoryPageScrollAnimationNone) {
                
                //翻页、章节切换动画完成处理
                [weakSelf storyPageScrollAnimationFinishWithContorller:contentController];
            } else {
                
                if (finished) {
                    
                    //翻页、章节切换动画完成处理
                    [weakSelf storyPageScrollAnimationFinishWithContorller:contentController];
                }
            }
            
        }];
        
    }
    else
    {
        [self enableChangePages:YES];
        [self.dealView enableChangeChapter:YES];
        
        if (scrollType == StoryAfterPageView) {
            [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已经是最后一章了" toUrl:nil mode:SNCenterToastModeError];
        }
        
        if (scrollType == StoryBforePageView) {
            
            [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已经是第一章了" toUrl:nil mode:SNCenterToastModeError];
        }
    }
    
}

#pragma mark 翻页、章节切换动画完成处理
-(void)storyPageScrollAnimationFinishWithContorller:(SNStoryContentController *)contentController
{
    // 自动购买 点击手势和滑动手势调用的是两个地方
    if (contentController.chapterType == StoryPayPageView) {
        //付费页面 处理自动购买逻辑
        //付费页面单独提出来，原因：1.付费章节会有限免活动，会每次刷新 2.pageviewController预加载，造成自动购买是购买下一章节的书籍
        [contentController novelContentWithIsrefresh:YES];
    }
    
    //记录页码
    [self recordHasReadChapter];
    
    if (self.dealView.slider.isRefreshSlider) {
        //调整进度条
        [self updateRateProgressWithChapterIndex:contentController.chapterIndex];
    }
    
    //翻页、章节切换手势及按钮控制
    [self enableChangePages:YES];
    [self.dealView enableChangeChapter:YES];
}

#pragma mark -二分法查找，提前已按照升序排序
-(NSInteger)binaryFetchWithArray:(NSArray *)array chapterId:(NSInteger)chapterId
{
    NSInteger chapterIndex = 0;
    NSInteger count = array.count;
    if (count > 0) {//有章节
        
        int middle;
        int low = 0;
        int high = count - 1;
        
        while (low <= high) {
            middle = (low +high) / 2;
            ChapterList *chapter = array[middle];
            if (chapterId > chapter.chapterId) {
                low = middle + 1;
            } else if (chapterId < chapter.chapterId){
                high = middle - 1;
            }
            else{
                break;
            }
        }
        chapterIndex = (low +high) / 2;
    } else {//没有章节，默认第一章节
        chapterIndex = 0;
    }
    
    return chapterIndex;
}

#pragma mark 调整进度条
-(void)updateRateProgressWithChapterIndex:(NSInteger)chapterIndex
{
    if (self.chapterArray.count > 0) {
        float index = chapterIndex + 1;
        float rate = index/self.dealView.maxChapterCount;
        self.dealView.rate = rate;
        
        ChapterList *chapter = self.chapterArray[chapterIndex];
        NSString *progressStr = [NSString stringWithFormat:@"%.2f%@", rate * 100, @"%"];
        [self rateProgressViewWithProgressStr:progressStr chapter:chapter];
    }
}

#pragma mark - StoryFontAdjustmentViewDelegate
- (void)changeFont:(CGFloat)fontSize{
    
    NSDictionary *dic = @{@"chapterFont":[NSNumber numberWithFloat:fontSize],@"externString":@""};
    [StoryConfig insertStoryConfigWithDic:dic];
    
    self.cur_font = [UIFont systemFontOfSize:fontSize];
    
    SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
    
    NSInteger currentIndex = [self countPageAginWithChapterIndex:currContentController.chapterIndex currentIndex:currContentController.pageNum];
    
    if (currContentController.chapterType == StoryPayPageView) {
        
        currContentController.chapterContentLabel.content = self.updateFontPayContent;
        currContentController.chapterContentLabel.cur_font = self.cur_font;
        [currContentController.chapterContentLabel setNeedsDisplay];
        
    } else {
        SNStoryContentController *contentController = [SNStoryPage viewControllerWithChapterIndex:currContentController.chapterIndex pageIndex:currentIndex pageViewController:self font:self.cur_font storyScrollType:StoryOriginPageView];
        contentController.cur_font = self.cur_font;
        NSArray *viewControllers = [NSArray arrayWithObject:contentController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self recordHasReadChapter];
    }
}

#pragma mark 改变字号，重新计算页数
-(NSInteger)countPageAginWithChapterIndex:(NSInteger)chapterIndex currentIndex:(NSInteger)currentIndex
{
    //取出当前章节信息
    SNStoryChapter *model = [SNStoryPage initChapterWithPageViewController:self chapterIndex:chapterIndex font:self.cur_font];
    NSArray *array = [model.chapterPageArray copy];//保存老的偏移量
    
    //重新计算章节页数，由于会有多章，先计算当前章节，其他章节异步处理
    [self updatePageArrayWithChapterId:model.chapterId isDispatch:YES font:self.cur_font chapterIndex:chapterIndex];
    model = [SNStoryPage initChapterWithPageViewController:self chapterIndex:chapterIndex font:self.cur_font];
    
    //根据偏移量计算页码
    if (array && (currentIndex < array.count)) {
        NSArray *pageIndexArray = [array[currentIndex] componentsSeparatedByString:@"_"];
        NSInteger pageOffset = [[pageIndexArray firstObject]intValue]+[[pageIndexArray lastObject]intValue];//偏移量
        currentIndex = [SNStoryPage getPageNumFromPageOffsetWithPageOffset:pageOffset storyChapter:model];
    }
    
    NSUInteger count = model.chapterPageArray.count;//改变字号后，该章节总页数
    if (count <= 0) {//小于0，有误，展示修改之前的页
        return currentIndex;
    } else {
        //只要修改之前的页码在修改之后的页数范围内，不做修改，否则，修改
        if (currentIndex >= count) {
            currentIndex = count - 1;
        }
    }
    
    self.updateFontPayContent = [SNStoryPage getContentWithModel:model currentIndex:currentIndex];
    return currentIndex;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //页面消失时，清除设置view
    if ([self.view.superview.subviews containsObject:self.dealView]) {
        
        //页面消失时，状态栏重置
        [self statusBarHidden];
        if (self.dealView.hidden) {
            [self.dealView removeFromSuperview];
        }else{
            [self storyDealViewHidden];
        }
        
    } else  if([self.view.superview.subviews containsObject:self.fontView]){
        //页面消失时，状态栏重置
        [self statusBarHidden];
        if (self.fontView.hidden) {
            [self.fontView removeFromSuperview];
        }else{
            [self storyFontAdjustmentViewHidden];
        }
    }
    
    //页面消失时，重新设置代理
    [self storyContentTapWithIsTapGesture:NO];

}

#pragma mark 记录已读章节
-(void)recordHasReadChapter
{
    if (self.chapterArray.count > 0) {
        
        SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
        ChapterList *chapter = [self.chapterArray objectAtIndex:currContentController.chapterIndex];
        NSDictionary *dic = @{@"hasReadChapterIndex":[NSNumber numberWithUnsignedInteger:currContentController.chapterIndex],@"hasReadChapterId":[NSNumber numberWithUnsignedInteger:chapter.chapterId],@"hasReadPageNum":[NSNumber numberWithUnsignedInteger:currContentController.pageNum]};
        
        [StoryBookList updateBookInfoWithRecordingHasReadChapterByBookId:self.novelId bookDic:dic];
    }
}

#pragma mark -- theme
- (void)updateNovelTheme {
    [self.dealView updateNovelTheme];
    [self.fontView updateNovelTheme];
    
    for (UIViewController *controller in self.flipboardNavigationController.viewControllers ) {
        if ([controller isKindOfClass:[SNStoryCatelogController class]]) {
            
            [((SNStoryCatelogController *)controller)updateTheme];
            break;
        }
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"0"] && ![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
        self.view.backgroundColor = [SNStoryPage getReadBackgroundColor];
        self.pageViewController.view.backgroundColor = [SNStoryPage getReadBackgroundColor];
        
    }
    else
    {
        UIColor *color = [UIColor colorFromKey:@"kThemeBg4Color"];
        self.view.backgroundColor = color;
        self.pageViewController.view.backgroundColor = color;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.statusBar.backgroundColor = [SNStoryUtility getReadColor];
    [self.statusBar viewWithTag:StatusBar_LineTag].backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    
}

#pragma mark 点击屏幕三个区域的处理
-(void)tapevent:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat districWidth = View_Width / 3.0;
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    BOOL isTapCenter = NO;
    BOOL isNext = NO;
    if (point.x <= districWidth) {//点击屏幕左边区域
        isNext = NO;
        isTapCenter = NO;
    }
    else if (point.x > 2*districWidth)//点击屏幕右边区域
    {
        isNext = YES;
        isTapCenter = NO;
    }
    else//点击屏幕中央区域
    {
        isTapCenter = YES;
    }
    
    //翻页处理
    if (!isTapCenter && !self.isTapCenter) {
        
        [self chapterPagesWithIsNext:isNext];
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=turn&from=5&bookId=%@", self.novelId]];
    }
    
    if (isTapCenter || self.isTapCenter) {//点击屏幕中央，弹出小说设置
        
        [self statusBarHidden];
        
        if (![self.view.superview.subviews containsObject:self.fontView]) {
            [self storyDealViewHidden];
        } else {
            [self storyFontAdjustmentViewHidden];
        }
    }
    
    //小说内容设置
    [self storyContentTapWithIsTapGesture:self.isTapCenter];
    
}

-(void)statusBarHidden
{
    SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
    if (![UIApplication sharedApplication].statusBarHidden) {//弹出和隐藏statusBar
        if (currContentController.chapterType == StoryNormalPageView) {
            [currContentController.bookMark setBookMarkEnable:YES];
        }
    }
    
    CGRect statusBarFrame = self.statusBar.frame;
    if (self.statusBar.hidden) {
        statusBarFrame.origin.y = 0;
        self.statusBar.hidden = NO;
    } else {
        statusBarFrame.origin.y = -(StatusBarHeight);
        self.statusBar.hidden = YES;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.statusBar.frame = statusBarFrame;
    }];
}

#pragma mark -StoryDealViewProtocol StoryDealView代理
#pragma mark - 拖动停止，切换章节
-(void)chapterChangeWithRatio:(float)ratio
{
    int chapterIndex = ratio *self.dealView.slider.maximumValue;
    
    if (self.chapterArray.count > 0) {
        
        if (chapterIndex == self.chapterArray.count) {
            chapterIndex = self.chapterArray.count - 1;
        }
    }
    else{
        return;
    }
    
    SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
    
    if (currContentController.chapterIndex != chapterIndex) {
        //切换了章节，改变页码,没有切换不用做任何切换处理
        [self chapterChangeWithIndex:chapterIndex pageNum:0 bookMarkLocation:0 scrollAnimation:StoryPageScrollAnimationNone];
    }
}

#pragma mark - 设置进度，不做操作
-(void)chapterChangeDealwithSetRatio:(float)ratio
{
    return;
}

#pragma mark - 拖动进行，刷新UI显示
-(void)chapterChangeMovedWithRate:(float)rate
{
    int chapterIndex = rate *self.dealView.slider.maximumValue;
    
    if (self.chapterArray.count > 0) {
        
        if (chapterIndex == self.chapterArray.count) {
            chapterIndex = self.chapterArray.count - 1;
        }
    }else{
        return;
    }
    
    SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
    
    if (currContentController.chapterIndex == chapterIndex) {
        
        return;
    }
    
    ChapterList *chapter = [self.chapterArray objectAtIndex:chapterIndex];
    NSString *progressStr = [NSString stringWithFormat:@"%.2f%@", rate * 100, @"%"];
    [self rateProgressViewWithProgressStr:progressStr chapter:chapter];
}

#pragma mark - 调整气泡位置
-(void)rateProgressViewWithProgressStr:(NSString *)progressStr chapter:(ChapterList *)chapter
{
    self.dealView.rateProgressView.progressLabel.text = progressStr;
    self.dealView.rateProgressView.chapterLabel.text = chapter.chapterTitle;
    
    float centerWidth = View_Width - DealView_Slider_ProgresSlideOriginX * 2 - self.dealView.rateProgressView.width;
    CGRect rateProgressViewRect = self.dealView.rateProgressView.frame;
    
    if (self.dealView.slider.width > 0) {
        rateProgressViewRect.origin.x = DealView_Slider_ProgresSlideOriginX + self.dealView.slider.progresSlide.width/self.dealView.slider.width * centerWidth;
        self.dealView.rateProgressView.frame = rateProgressViewRect;
    }
}

- (void)storySettingWithWithButton:(UIButton *)button {
    NSInteger index = button.tag - StoryDealViewButtonBaseTag;
    
    switch (index) {
        case 0://上一章
        {
            if (button.userInteractionEnabled) {
                [self.dealView enableChangeChapter:NO];
            }
            
            [self chapterBtnTapWithIsNext:NO];
        }
            break;
            
        case 1://下一章
        {
            if (button.userInteractionEnabled) {
                [self.dealView enableChangeChapter:NO];
            }
            [self chapterBtnTapWithIsNext:YES];
            
        }
            break;
            
        case 2://返回
        {
            //停留时间埋点统计
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                NSDate *date = [NSDate date];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *dateComponents = [calendar components:NSCalendarUnitSecond fromDate:self.date toDate:date options:NSCalendarMatchStrictly];
                NSInteger time = dateComponents.second;
                NSString *timeStr = [NSString stringWithFormat:@"%ld", time];
                [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=tm&time=%@&bookId=%@",timeStr,self.novelId]];
            });
            
            //返回，判断是否加入书架
            [self checkBookShelfWith:StoryBookShelfCheck];
            
        }
            break;
            
        case 3://目录
        {
            SNStoryCatelogController *catelogController = [[SNStoryCatelogController alloc]init];
            catelogController.catelogType = StoryCateLogFromReadPage;
            catelogController.delegate = self;
            catelogController.novelId = self.novelId;
            
            //埋点统计
            [SNStoryUtility pushViewController:catelogController animated:YES];
        }
            break;
            
        case 4://字体设置
        {
            [self storyFontAdjustmentViewHidden];
        }
            break;
            
        case 5://夜间模式设置
        {
            [[SNNovelThemeManager manager] setNovelThemeAlternate];
        }
            break;
            
        case 6://更多
        {
            [self storyMoreSettingWithButton:button];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark 检查书籍是否在书架
-(void)checkBookShelfWith:(CheckBooshelType)type
{
    if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {
        
        if (type != StoryOpenRemindBookShelfNone) {
            
            if (type == StoryOpenRemind) {
                [[SNCenterToast shareInstance]showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            } else {
                
                [self popViewControllerToBookshelf];
            }
        }
    }
    else
    {
        //为什么每次check，因为你不知道何时就加入、删除书架了
        StoryBookShelfList *book = [SNStoryPage fecthBookShelfListByBookId:self.novelId];
        
        if (book) {
            self.hasAddBookShelf = YES;
            if (book.remind == 1) {
                self.hasOpenPush = YES;
            } else {
                self.hasOpenPush = NO;
            }
        }
        else
        {
            self.hasAddBookShelf = NO;
            self.hasOpenPush = NO;
        }
        
        if (type != StoryOpenRemindBookShelfNone) {
            if (self.hasAddBookShelf) {
                
                if (type == StoryOpenRemind) {
                    if (self.hasOpenPush) {
                        [self openPushWithBookPushEnable:NO];
                    } else {
                        [self openPushWithBookPushEnable:YES];
                    }
                } else {
                    
                    [self popViewControllerToBookshelf];
                }
                
            } else {
                
                if (type == StoryOpenRemind) {
                    SNNewAlertView *alertView = [[SNNewAlertView alloc]initWithTitle:nil message:@"把这本书加入书架同时开启提醒？" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
                    [alertView show];
                    [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                        [SNBookShelf addBookShelf:self.novelId hasRead:YES completed:^(BOOL success) {
                            
                            if (success) {
                                self.hasAddBookShelf = YES;
                                [self openPushWithBookPushEnable:YES];
                            } else {
                                self.hasAddBookShelf = NO;
                                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"开启提醒失败" toUrl:nil mode:SNCenterToastModeError];
                            }
                        }];
                    }];
                } else {
                    
                    if (self.book.bookTitle && self.book.bookTitle.length > 0) {
                        SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否将\"%@\"加入书架，以便下次继续阅读？",self.book.bookTitle] delegate:self cancelButtonTitle:@"不加入" otherButtonTitle:@"加入"];
                        [alertView show];
                        [alertView actionWithBlocksCancelButtonHandler:^{
                            [self popViewControllerToBookshelf];
                        } otherButtonHandler:^{
                            [SNBookShelf addBookShelf:self.novelId hasRead:YES completed:^(BOOL success) {
                                
                                if (success) {
                                    
                                    if ([self.delegate respondsToSelector:@selector(addBookShelfInPageView)]) {
                                        
                                        [self.delegate addBookShelfInPageView];
                                    }
                                }
                            }];
                            [self popViewControllerToBookshelf];
                        }];
                    }
                    else
                    {
                        [self popViewControllerToBookshelf];
                    }
                }
            }
        }
    }
}

#pragma mark -点击上下章节按钮
-(void)chapterBtnTapWithIsNext:(BOOL)isNext
{
    
    SNStoryContentController *currContentController=(SNStoryContentController *)[self.pageViewController.viewControllers firstObject];
    
    if (isNext) {
        
        if (currContentController.chapterIndex >= (self.chapterArray.count - 1)) {
            [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已经是最后一章了" toUrl:nil mode:SNCenterToastModeError];
             [self.dealView enableChangeChapter:YES];
            return;
        } else {
            currContentController.chapterIndex++;
        }
    }else
    {
        
        if (currContentController.chapterIndex <= 0) {
            
            [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已经是第一章了" toUrl:nil mode:SNCenterToastModeError];
            [self.dealView enableChangeChapter:YES];
            return;
        }else {
            currContentController.chapterIndex--;
        }
    }
    
    self.dealView.slider.isRefreshSlider = YES;
    [self chapterChangeWithIndex:currContentController.chapterIndex pageNum:0 bookMarkLocation:0 scrollAnimation:isNext?StoryPageScrollAnimationRightToLeft:StoryPageScrollAnimationLeftToRight];
}

#pragma mark -控制翻页(连续点击会有bug，加此限制)
-(void)enableChangePages:(BOOL)enableChange
{
    self.pageViewController.view.userInteractionEnabled = enableChange;
    self.tapGesture.enabled = enableChange;
}

#pragma mark 更多设置
-(void)storyMoreSettingWithButton:(UIButton *)sender {
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:7];
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:7];
    
    //查询加入书架、开启提醒状态
    [self checkBookShelfWith:StoryOpenRemindBookShelfNone];
    [titleArray addObject:@"小说详情"];
    if ([SNStoryUtility isLogin]) {
        [titleArray addObject:[SNVoucherCenter autoPurchase]?@"关闭自动购买":@"开启自动购买"];
    }
    [titleArray addObject:self.hasOpenPush?@"关闭提醒":@"开启提醒"];
    [titleArray addObject:self.isRequesting?@"正在下载":(self.availableChapterArray.count > 0?@"下载可读章节":@"可读章节已下载")];
    [titleArray addObject:@"分享"];
    [titleArray addObject:@"举报"];
    [titleArray addObject:@"刷新"];
    
    [imageArray addObject:@"icofiction_xsxq_v5.png"];
    if ([SNStoryUtility isLogin]) {
        [imageArray addObject:@"icofiction_zdgm_v5.png"];
    }
    [imageArray addObject:@"icofiction_kqtx_v5.png"];
    [imageArray addObject:@"icofiction_xzkd_v5.png"];
    [imageArray addObject:@"icofiction_fx_v5.png"];
    [imageArray addObject:@"icofiction_jb_v5.png"];
    [imageArray addObject:@"icowebview_refresh.png"];
    
    CGRect rect = [sender.superview convertRect:sender.frame toView:[UIApplication sharedApplication].keyWindow];
    __weak typeof(self)weakself = self;
    [SNPopOverMenu showForStorySender:nil senderFrame:CGRectMake(rect.origin.x, rect.origin.y - 15, rect.size.width, rect.size.height) superView:self.view.superview withMenu:titleArray.copy imageNameArray:imageArray.copy doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0://小说详情
            {
                NSDictionary *dic = @{@"novelId":weakself.novelId, StoryProtocolLink:[NSString stringWithFormat:@"noveldetail://novelId=%@",weakself.novelId],@"novelH5PageType":@"1"};
                [SNStoryUtility openUrlPath:@"tt://storyWebView" applyQuery:dic applyAnimated:YES];
                //详情页埋点统计 7.阅读页-点击“更多-小说详情”
                [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&objType=fic_todetail&fromObjType=%@",@"7"]];
                break;
            }
                
            case 1://@"开启自动购买"
            {
                if ([SNStoryUtility isLogin]) {
                    if ([SNVoucherCenter autoPurchase]) {
                        [SNVoucherCenter setAutoPurchase:NO];
                    }else{
                        [SNVoucherCenter setAutoPurchase:YES];
                    }
                }else
                {
                    [weakself openRemind];
                }
                
                break;
            }
            
            case 2://@"开启提醒"
            {
                if ([SNStoryUtility isLogin]) {
                    [weakself openRemind];
                }else
                {
                    [weakself downloadAvailableChapterByNetwork];
                }
                break;
            }
                
            case 3://下载可读章节
            {
                if ([SNStoryUtility isLogin]) {
                    [weakself downloadAvailableChapterByNetwork];
                }else
                {
                    [weakself shareAction];
                }
                
                break;
            }
            
            case 4://分享
            {
                if ([SNStoryUtility isLogin]) {
                    [weakself shareAction];
                }else
                {
                    [weakself chapterContentReport];
                }
                break;
            }
                
            case 5://章节内容举报
            {
                if ([SNStoryUtility isLogin]) {
                    [weakself chapterContentReport];
                }else
                {
                    [weakself chapterContentRefresh];
                }
                break;
            }
            case 6://章节内容刷新
            {
                [weakself chapterContentRefresh];
                break;
            }
            default:
                break;
        }
    } dismissBlock:^{
        
    }];
    
}

#pragma mark  可读章节下载网络判断
-(void)downloadAvailableChapterByNetwork
{
    if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {
        [[SNCenterToast shareInstance]showCenterToastWithTitle:@"暂时无法连接网络" toUrl:nil mode:SNCenterToastModeError];
    } else {
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=more&type=download&bookId=%@",self.novelId]];
        
        if (self.availableChapterArray.count > 0) {
            if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusReachableViaWiFi) {
                if (self.isRequesting) {
                    [[SNCenterToast shareInstance]showCenterToastWithTitle:@"正在下载" toUrl:nil mode:SNCenterToastModeError];
                } else {
                    
                    [self downloadAvailableChapter];
                }
            } else {
                SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:@"即将消耗移动数据流量下载小说" delegate:self cancelButtonTitle:@"取消下载" otherButtonTitle:@"继续下载"];
                [alertView show];
                [alertView actionWithBlocksCancelButtonHandler:^{
                    
                } otherButtonHandler:^{
                    if (self.isRequesting) {
                        [[SNCenterToast shareInstance]showCenterToastWithTitle:@"正在下载" toUrl:nil mode:SNCenterToastModeError];
                    } else {
                        
                        [self downloadAvailableChapter];
                    }
                }];
            }
        } else {
            [[SNCenterToast shareInstance]showCenterToastWithTitle:@"可读章节已下载" toUrl:nil mode:SNCenterToastModeError];
        }
    }
}

#pragma mark  开启提醒
- (void)openRemind {
    
    //返回，判断开启提醒是否加入书架
    [self checkBookShelfWith:StoryOpenRemind];
}

-(void)openPushWithBookPushEnable:(BOOL)bookPushEnable
{
    [SNBookShelf bookPushEnable:bookPushEnable bookId:self.novelId complete:^(BOOL success) {
        
        if (success) {
            self.hasOpenPush = !self.hasOpenPush;
            
            if (bookPushEnable) {
                [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已开启提醒" toUrl:nil mode:SNCenterToastModeError];
            } else {
                [[SNCenterToast shareInstance]showCenterToastWithTitle:@"已关闭提醒" toUrl:nil mode:SNCenterToastModeError];
            }
            
            [SNStoryPage insertBookShelfListWithArray:@[@{@"bookId":self.novelId,@"remind":[NSNumber numberWithBool:bookPushEnable]}]];
            [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=more&type=warn&bookId=%@",self.novelId]];
        } else {
            
            if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {
                
                [[SNCenterToast shareInstance]showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            }
            else
            {
                [[SNCenterToast shareInstance]showCenterToastWithTitle:@"开启提醒失败" toUrl:nil mode:SNCenterToastModeError];
            }
        }
    }];
    
}

#pragma mark  可读章节下载
- (void)downloadAvailableChapter{
    
    self.isRequesting = YES;
    NSMutableArray *array = self.availableChapterArray;
    NSInteger downloadCount = array.count;
    
    int repeatCount = downloadCount / 100;
    
    if ((downloadCount % 100) != 0) {
        repeatCount += 1;
    }
    
    if (downloadCount > 100) {
        
        for (int i = 0; i < repeatCount; i++) {
            
            int count = downloadCount - i*100;
            int requestCount = 0;
            if (count > 100) {
                requestCount = 100;
            }
            else
            {
                requestCount = count;
            }
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i*100, requestCount)];
            NSArray *downloadArray = [array objectsAtIndexes:indexSet];
            [self downloadAvailableChapterFinshWithArray:downloadArray repeatCount:repeatCount];
        }
    } else {
        
        [self downloadAvailableChapterFinshWithArray:array repeatCount:0];
    }
}

#pragma mark  可读章节下载完成处理
- (void)downloadAvailableChapterFinshWithArray:(NSArray *)array repeatCount:(int)repeatCount
{
    [SNStoryPage downloadAvailableChapterContentRequestWithBookId:self.novelId pageViewController:self chapterIds:[array componentsJoinedByString:@","]completeBlock:^(id result) {
        
        if (repeatCount <= 0) {
            
            self.isRequesting = NO;
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)result;
                if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"1"]) {
                    
                    [[SNCenterToast shareInstance]showCenterToastWithTitle:@"可读章节下载完毕" toUrl:nil mode:SNCenterToastModeError];
                } else {
                    
                    [[SNCenterToast shareInstance]showCenterToastWithTitle:@"可读章节下载失败" toUrl:nil mode:SNCenterToastModeError];
                }
            }
            
        } else {
            
            self.downloadCount++;
            
            if (self.downloadCount == repeatCount) {
                
                self.isRequesting = NO;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)result;
                    if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"1"]) {
                        
                        [[SNCenterToast shareInstance]showCenterToastWithTitle:@"可读章节下载完毕" toUrl:nil mode:SNCenterToastModeError];
                    } else {
                        
                        [[SNCenterToast shareInstance]showCenterToastWithTitle:@"可读章节下载失败" toUrl:nil mode:SNCenterToastModeError];
                    }
                }
            }
        }
        
    }];
}
#pragma mark 章节内容分享
- (void)shareAction{
    
    NSString *title = self.book.bookTitle;
    NSString *content = @"来搜狐新闻和我一起读小说";
    NSString *shareUrl = [SNStoryUtility getStoryRequestUrlWithStr:StoryDetailShare(@"book",self.novelId)];
    
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    [shareDic setObject:title?title:@"" forKey:@"shareTitle"];
    [shareDic setObject:content forKey:@"shareDescription"];
    [shareDic setObject:shareUrl?shareUrl:@"" forKey:@"shareUrl"];
    [shareDic setObject:@"" forKey:@"link"];
    [shareDic setObject:@"web" forKey:@"contentType"];
    [shareDic setObject:self.book.bookImg?self.book.bookImg:@"" forKey:@"shareImage"];
    
    [SNStoryUtility shareActionWith:shareDic];
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=more&type=share&bookId=%@",self.novelId]];
}

#pragma mark 章节内容举报
-(void)chapterContentReport
{
    SNStoryContentController *controller = [self.pageViewController.viewControllers firstObject];
    SNStoryChapter *chapter = [SNStoryPage initChapterWithPageViewController:self chapterIndex:controller.chapterIndex font:self.cur_font];
    
    NSString *newsId = [NSString stringWithFormat:@"%ld",chapter.oid];
    NSString *urlString = [SNStoryUtility getStoryRequestUrlWithStr:H5StoryReport(newsId, @"4")];
    
    if(![SNStoryUtility isLogin])//判断是否登录，否则进入登录页
    {
        self.recordReportLogin = YES;
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:@"举报" forKey:kRegisterInfoKeyTitle];
        NSString* tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
        [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
        infoDic[kRegisterInfoKeyName] = @"举报";
        [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeReport] forKey:kRegisterInfoKeyGuideType];
        [infoDic setObject:@"1000004" forKey:kRegisterInfoKeyNewsId];
        [infoDic setObject:@"4" forKey:@"type"];
        [infoDic setObject:urlString forKey:kRegisterInfoKeyUserLink];
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
        [infoDic setObject:method forKey:@"method"];
        [infoDic setObject:kLoginFromReport forKey:kLoginFromKey];
        //[SNUtility openLoginViewWithDict:infoDic];
        [SNUtility shouldUseSpreadAnimation:NO];
        [SNUtility shouldAddAnimationOnSpread:NO];
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111小说举报
            [self openReportPage:urlString];
        } Failed:nil];
    }
    else
    {
        self.recordReportLogin = NO;
        
        [self openReportPage:urlString];
    }
    
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=more&type=report&bookId=%@",self.novelId]];
}

#pragma mark 章节内容刷新
-(void)chapterContentRefresh
{
    if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {
        
        [[SNCenterToast shareInstance]showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    else
    {
        SNStoryContentController *contentController = [self.pageViewController.viewControllers firstObject];
        
        //初始化数据
        contentController.pageNum = 0;
        contentController.storyScrollType = StoryOriginPageView;
        if (contentController.chapterContentLabel) {
            [contentController.chapterContentLabel removeFromSuperview];
            contentController.chapterContentLabel = nil;
        }
        
        //刷新章节内容
        [contentController refreshRequestWithDic:nil];
    }
}
    
- (void)openReportPage:(NSString*)urlString{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1000004",@"newsId", nil];
    [dic setObject:@"4" forKey:@"type"];
    [dic setObject:urlString forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:ReportWebViewType] forKey:kUniversalWebViewType];
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNUtility shouldAddAnimationOnSpread:NO];
    [SNUtility openUniversalWebView:dic];
}

-(void)loginSuccess
{
    return;
}

#pragma mark - 点击左右边缘上下翻页
-(void)chapterPagesWithIsNext:(BOOL)isNext
{
    if (self.chapterArray.count <= 0) {
        return;
    } else {
        
        SNStoryContentController *currController = [self.pageViewController.viewControllers firstObject];
        
        if (self.pageViewController.view.userInteractionEnabled) {
            [self enableChangePages:NO];
        }
        else
        {
            return;
        }
        
        StoryScrollType scrollType;
        if (isNext) {//向下翻页
            scrollType = StoryAfterPageView;
        }
        else
        {
            scrollType = StoryBforePageView;
        }
        
        self.dealView.slider.isRefreshSlider = YES;
        [self setPageViewControllerWithChapterIndex:currController.chapterIndex pageIndex:currController.pageNum scrollType:scrollType scrollAnimation:isNext?StoryPageScrollAnimationRightToLeft:StoryPageScrollAnimationLeftToRight];
    }
}

#pragma mark - 章节切换
-(void)chapterChangeWithIndex:(NSInteger)index pageNum:(NSInteger)pageNum bookMarkLocation:(NSInteger)bookMarkLocation scrollAnimation:(StoryPageScrollAnimation)scrollAnimation
{
    
    SNStoryChapter *model = [SNStoryPage initChapterWithPageViewController:self chapterIndex:index font:self.cur_font];
    /**
     *  有可能由于字体调整，导致页码变化，所以这里重新计算书签所在的页码
     */
    if (pageNum > 0 && bookMarkLocation > 0) {//pageNum = 0 时肯定是第一页，书签页码也肯定是第一页
        for (NSString * rangStr in model.chapterPageArray) {
            NSInteger location = [[[rangStr componentsSeparatedByString:@"_"] firstObject] integerValue];
            NSInteger length = [[[rangStr componentsSeparatedByString:@"_"] lastObject] integerValue];
            if (bookMarkLocation >= location && bookMarkLocation < (location + length)) {
                pageNum = [model.chapterPageArray indexOfObject:rangStr];
                break;
            }
        }
    }
    
    [self setPageViewControllerWithChapterIndex:index pageIndex:pageNum scrollType:StoryOriginPageView scrollAnimation:scrollAnimation];
}

#pragma mark 处理页面点击隐藏
-(void)storyDealViewHidden
{
    CGRect dealViewFrame = self.dealView.frame;
    if (self.dealView.hidden) {
        self.dealView.hidden = NO;
        dealViewFrame.origin.y -= DealViewHeight;
        self.isTapCenter = YES;
        //wangshun
        [self.view.superview addSubview:self.dealView];
        [SNStoryUtility setPanGestureWithState:NO];//解决手势冲突
    }
    else
    {
        if ([self.view.superview.subviews containsObject:self.fontView]) {
            self.isTapCenter = YES;
        } else {
            self.isTapCenter = NO;
            [SNStoryUtility setPanGestureWithState:YES];//解决手势冲突
        }
        
        self.dealView.hidden = YES;
        [self.dealView removeFromSuperview];
        dealViewFrame.origin.y += DealViewHeight;
    }
    
    [SNStoryDealView animateWithDuration:0.4 animations:^{
        
        self.dealView.frame = dealViewFrame;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark 目录进入阅读页(从阅读页进入的目录)
-(void)storyCatelogIntoPageWithIndex:(NSUInteger)index chapterArray:(NSMutableArray *)chapterArray
{
    
    if (self.chapterArray.count != chapterArray.count) {//章节数不等，重新刷数据
        
        self.chapterArray = nil;
        [self initPageArrayWithNovelId:self.novelId chapterId:0 font:self.cur_font chapterIndex:0];
    }
    
    NSInteger conut =  self.chapterArray.count;
    if (index >= conut) {
        
        if (conut > 0) {
            index = conut - 1;
        }
    }
    
    self.dealView.maxChapterCount = self.chapterArray.count;
    SNStoryContentController *contentController=(SNStoryContentController *)[self.pageViewController.viewControllers firstObject];
    
    //同一账号登录不同设备，章节购买后，在另一设备刷新(同一本书)
    ChapterList *catelogChapter = chapterArray[index];
    BOOL isJump = (contentController.chapterType == StoryPayPageView && (catelogChapter.isfree || catelogChapter.hasPaid));
    if (index != contentController.chapterIndex || isJump) {
        self.dealView.slider.isRefreshSlider = YES;//是否刷新进度条
        [self.chapterCacheDic removeObjectForKey:[NSString stringWithFormat:@"%ld", catelogChapter.chapterId]];//同一章节购买后刷新
        
        //页面或章节跳转
        [self chapterChangeWithIndex:index pageNum:0 bookMarkLocation:0 scrollAnimation:StoryPageScrollAnimationNone];
    }
}
#pragma mark --目录书签进阅读
- (void)gotoBookMarkPageWith:(SNStoryBookMarkAndNoteModel *)bookMark chapterArray:(NSMutableArray *)chapterArray{
    
    if (bookMark.chapterId.length == 0) {
        return;
    }
    
    self.dealView.slider.isRefreshSlider = YES;
    self.dealView.maxChapterCount = self.chapterArray.count;
    [self chapterChangeWithIndex:bookMark.chapterIndex pageNum:bookMark.pageNum bookMarkLocation:bookMark.startLocation scrollAnimation:StoryPageScrollAnimationNone];
}

-(void)storyFontAdjustmentViewHidden
{
    CGRect fontViewFrame = self.fontView.frame;
    if (self.fontView.isHidden) {
        self.fontView.hidden = NO;
        fontViewFrame.origin.y -= FONTSETTINGVIEWHEIGHT;
        self.isTapCenter = YES;
        [self.view.superview addSubview:self.fontView];
        
        if (!self.dealView.hidden) {
            
            [self storyDealViewHidden];
        }
    }
    else
    {
        self.isTapCenter = NO;
        self.fontView.hidden = YES;
        [self.fontView removeFromSuperview];
        fontViewFrame.origin.y += FONTSETTINGVIEWHEIGHT;
        [SNStoryUtility setPanGestureWithState:YES];//解决手势冲突
    }
    
    [SNStoryFontAdjustmentView animateWithDuration:0.4 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.fontView.frame = fontViewFrame;
    }];
}
#pragma mark - UIPageViewControllerDataSource

#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if (self.chapterArray.count <= 0) {
        return nil;
    } else {
        SNStoryContentController *contentController = (SNStoryContentController *)[pageViewController.viewControllers firstObject];
        //以前是页码放在这里处理，现在不放这里，传当前页码
        SNStoryContentController *upContentController = [SNStoryPage viewControllerWithChapterIndex:contentController.chapterIndex pageIndex:contentController.pageNum pageViewController:self font:self.cur_font storyScrollType:StoryBforePageView];
        return upContentController;
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        
        SNStoryContentController *contentController=(SNStoryContentController *)[pageViewController.viewControllers firstObject];
        
        if (contentController.chapterType == StoryPayPageView) {
            
            //付费页面 处理自动购买逻辑
            //付费页面单独提出来，原因：1.付费章节会有限免活动，会每次刷新 2.pageviewController预加载，造成自动购买是购买下一章节的书籍
            [contentController novelContentWithIsrefresh:YES];
        }
        
        //记录页码
        [self recordHasReadChapter];
        //调整进度条
        [self updateRateProgressWithChapterIndex:contentController.chapterIndex];
    }
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (self.chapterArray.count <= 0) {
        return nil;
    } else {
        SNStoryContentController *contentController = (SNStoryContentController *)[pageViewController.viewControllers firstObject];
        //以前是页码放在这里处理，现在不放这里，传当前页码
        SNStoryContentController *nextContentController = [SNStoryPage viewControllerWithChapterIndex:contentController.chapterIndex pageIndex:contentController.pageNum pageViewController:self font:self.cur_font storyScrollType:StoryAfterPageView];
        return nextContentController;
    }
    
}

#pragma mark - 点击小说内容处理
-(void)storyContentTapWithIsTapGesture:(BOOL)isTapGesture
{
    if (isTapGesture) {
        
        self.pageViewController.delegate = nil;
        self.pageViewController.dataSource = nil;
        
    } else {
        
        if (!self.pageViewController.delegate) {
            self.pageViewController.delegate = self;
            self.pageViewController.dataSource = self;
        }
        
    }
}

#pragma mark -- pop动画返回书架

- (void)popViewControllerToBookshelf {
    [self.screenBrightnessView removeFromSuperview];
    [self.statusBar removeFromSuperview];
    [self.dealView removeFromSuperview];
    [self.fontView removeFromSuperview];
    
    BOOL isOnBookshelf = [SNBookShelf isOnBookshelf:self.novelId];
    
    if (isOnBookshelf) {//上报阅读锚点
        
        SNStoryContentController *currContentController = [self.pageViewController.viewControllers firstObject];
        ChapterList *chapter = [self.chapterArray objectAtIndex:currContentController.chapterIndex];
        SNStoryChapter *tempModel = [self.chapterCacheDic objectForKey:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
        
        NSString *anchorStr = nil;
        if (!tempModel.chapterPageArray || tempModel.chapterPageArray.count <= 0) {
            anchorStr = @"0";
        }else
        {
            anchorStr = [[tempModel.chapterPageArray[currContentController.pageNum]componentsSeparatedByString:@"_"]firstObject];
        }
        
        NSDictionary *dic = @{@"bookId":[NSNumber numberWithUnsignedInteger:[self.novelId integerValue]],@"chapter":[NSNumber numberWithUnsignedInteger:tempModel.chapterId],@"pageNO":[NSNumber numberWithUnsignedInteger:[anchorStr integerValue]],@"platform":@"5"};
        
        [SNStoryPage novelAdd_AnchorDic:dic completeBlock:nil];
    }
    
    if (self.cover && self.pageType == StoryPageFromChannel && isOnBookshelf) {
        // 如果书没有在书架上，做这个动画也就没有意义了
         //设置动画
        SNNavigationController *navigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if ([navigationController.viewControllers count] > 1) {
            if ([[navigationController.viewControllers lastObject] isKindOfClass:[SNStoryPageViewController class]]) {
                
                UIViewController *vc = [navigationController.viewControllers objectAtIndex:navigationController.viewControllers.count - 2];
                if ([vc isKindOfClass:[SNNovelShelfController class]]) {
                    self.previousConroller = (SNNovelShelfController*)vc;
                    self.previousConroller.bookAnimating = YES;
                }
            }
        }
        self.cover.hidden = NO;
        //开始动画
        [UIView animateWithDuration:3/8.f animations:^{
            self.cover.layer.transform = CATransform3DIdentity;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.cover.frame = self.rectInBookshelf;
            self.view.frame = self.rectInBookshelf;
        } completion:^(BOOL finished) {
            [self.cover removeFromSuperview];
            self.cover = nil;
            [SNStoryUtility popViewControllerAnimated:NO];
            if (_previousConroller) {
                //@qz 必须放到pop动画结束后 因为要等nav.vcs 把当前的storyvc 从array中 remove掉
                _previousConroller.bookAnimating = NO;
            }
        }];
    }else if (self.pageType == StoryPageFromH5Catelaog) {
        
        for (UIViewController *controller in self.flipboardNavigationController.viewControllers ) {
            if ([controller isKindOfClass:[SNStoryCatelogController class]]) {
                
                StoryBookList *book = [StoryBookList fecthBookByBookIdByUsingCoreData:self.novelId];
                [((SNStoryCatelogController *)controller)chapterHasReadWithNovelId:self.novelId book:book];
                break;
            }
        }
        
        [SNStoryUtility popViewControllerAnimated:YES];
    } else {
         [SNStoryUtility popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -----小说专用

#pragma mark 
-(void)initPageArrayWithNovelId:(NSString *)novelId chapterId:(NSInteger)chapterId font:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    if (!self.chapterArray || self.chapterArray.count <= 0) {
        StoryBookList *book = [StoryBookList fecthBookByBookIdByUsingCoreData:novelId];
        if (book) self.book = book; //@qz 需要每次都做吗？
        
        NSArray *chapters = [ChapterList fecthBookChapterListByBookId:novelId chapterId:0 ascending:YES];
        if (!chapters || chapters.count <= 0) return;
        
        self.chapterArray = [NSArray arrayWithArray:chapters];
    }

    if (chapterId > 0) {//修改某一章节
        NSArray *array = [ChapterList fecthBookChapterListByBookId:novelId chapterId:chapterId ascending:YES];
        if (array && [array count]) {
            ChapterList *chapter = array[0];
            if (chapter.chapterId == chapterId && chapter.chapterContent.length > 0) {
                [self cacheChapterWithFont:font chapter:chapter];
            }
        }
    } else {//初始化所有章节
        
        if (self.chapterCacheDic.count > 0 && [self.novelId isEqualToString:novelId]) {//同一个novelId，有内容，表示已缓存，不用再次缓存
            return;
        }
        
        //处理可读章节
        NSInteger count = self.chapterArray.count;
        for (int i = 0; i < count; i++) {
            
            ChapterList *chapter = self.chapterArray[i];
            
            if (chapter.isfree || chapter.hasPaid) {
                if (!chapter.isDownload) {
                    [self.availableChapterArray addObject:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
                }
                
            }else{
                [self.payArray addObject:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
            }
        }
        //首次读这本小说缓存十章处理(原因 首次下载10章,说是太多，服务器压力大)
        //用copy，防止多线程操作数据
        NSArray *availableChapterArray = [self.availableChapterArray copy];
        NSInteger availableChapterCount = availableChapterArray.count;
        NSString *firstReadThisBook = [[NSUserDefaults standardUserDefaults] objectForKey:self.novelId];
        
        if (!firstReadThisBook || firstReadThisBook.length <=0 || [firstReadThisBook isEqualToString:@"0"])
        {
            if (availableChapterCount >= 0) {
                StoryNetworkReachabilityStatus status =  [SNStoryUtility currentReachabilityStatusForStory];
                if (status == StoryNetworkReachabilityStatusReachableViaWiFi) {
                    for (int chapterIndex = 0; chapterIndex < availableChapterCount ;chapterIndex++) {
                        NSString *chapterIdStr = availableChapterArray[chapterIndex];
                        [SNStoryPage storyChapterContentRequestWithBookId:self.novelId pageViewController:self startChapterId:chapterIdStr chapterCount:@"1" completeBlock:nil];
                        
                        if ((chapterIndex+1) >= 10) {
                            break;
                        }
                    }
                }
            }
        }
    }
}

#pragma mark 缓存章节内容，存于内存
-(void)cacheChapterWithFont:(UIFont *)font chapter:(ChapterList *)chapter
{
    SNStoryChapter *model = [[SNStoryChapter alloc]init];
    model.chapterId = chapter.chapterId;
    model.oid = chapter.oid;
    model.chapterTitle = chapter.chapterTitle;
    model.isFree = chapter.isfree;
    model.hasPaid = chapter.hasPaid;
    model.isDownload = chapter.isDownload;
    model.chapterContent = [SNStoryPage decryContentWithStr:chapter.chapterContent key:chapter.chapterKey];
    model.chapterPageArray = [SNStoryPage getPageCountWithStr:model.chapterContent font:font];
    if (!chapter.isfree && !chapter.hasPaid) {//防止小屏付费章节内容大于1页
        if (model.chapterPageArray.count > 1) {
            [model.chapterPageArray removeLastObject];
        }
    }
    
    [self.chapterCacheDic setObject:model forKey:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
}

#pragma mark 改变字号，重新计算页码
-(void)updatePageArrayWithChapterId:(NSInteger)chapterId isDispatch:(BOOL)isDispatch font:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    [self updateFontWithFont:font chapterIndex:chapterIndex];
}

-(void)updateFontWithFont:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    ChapterList *chapter = self.chapterArray[chapterIndex];
    SNStoryChapter *tempModel = [self.chapterCacheDic objectForKey:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
    tempModel.chapterPageArray = [SNStoryPage getPageCountWithStr:tempModel.chapterContent font:font];
}

#pragma 同步pid章节
-(void)updatePidInfoByCid
{
    //章节列表同步
    [ChapterList pidBookByCidBookWithBookId:self.novelId];
    //已读章节同步(pid无记录，同步cid的阅读记录)
    [self recordHasReadChapter];
    
    //刷新数据
    [self.chapterCacheDic removeAllObjects];
    self.chapterArray = nil;
    [self initPageArrayWithNovelId:self.novelId chapterId:0 font:self.cur_font chapterIndex:0];
    
    //锚点刷新
    [SNStoryUtility getNovelAchor];
}

#pragma mark set status bar
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

-(BOOL)prefersStatusBarHidden
{
    if (!self.dealView.isHidden || !self.fontView.isHidden)
    {
        return NO;
    }
    else {
        return YES;
    }
}
@end
