//
//  SNStoryContentController.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/29.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryContentController.h"
#import "SNStoryPageViewController.h"
#import "SNStoryContanst.h"
#import "SNStoryContentLabel.h"
#import "SNChapterBag.h"

#import "UIImage+Story.h"
#import "SNStoryUtility.h"
#import "UIViewAdditions+Story.h"
#import "StoryBookList.h"
#import "ChapterList.h"
#import "SNStoryChapter.h"
#import "SNVoucherCenter.h"

#import "SNStoryPurchaseView.h"
#import "SNStoryLoginButton.h"
#import "SNStoryGetContentFailedView.h"
#import "SNStoryWaitingActivityView.h"
#import "SNBookShelf.h"
#import "StoryBookAnchor.h"
#import "SNNewsLoginManager.h"

#define WaitingActivityViewLeftOffset                     0.0//等待加载view的左边距
#define WaitingActivityViewTopOffset                      0.0//等待加载view的上边距
#define ChapterNameLabelHeight                            20.0//章节标题高
#define ChapterProgressOrNameLabelLabelTopOffset                     25.0//章节进度/标题上边距
#define ChapterProgressLabelRightOffset                   20.0//章节进度右边距
#define ChapterProgressLabelHeight                        20.0//章节进度高
#define StoryContentLabelTopOffset                        65.0//章节内容上边距
#define BookMarkLeftOffset                                0.0//书签左边距
#define PurchaseViewLeftOffset                            0.0//购买view左边距
#define PurchaseViewTopOffset                             64.0//购买view上边距
#define FirstPageTitleLabelHeight                         40.0//第一页标题高度
#define FirstPageTitleLabelTopOffset                      200.0//第一页标题上边距
#define FirstPageSubTitleLabelHeight                      40.0//第一页副标题高度
#define FirstPageSubTitleLabelTopOffset                   18.0//第一页副标题上边距
#define FailedViewLeftOffset                              0.0//网络失败view左边距
#define FailedViewTopOffset                               20.0//网络失败view上边距
#define WaitRefreshAfterBuySuccessViewTag                 100000

typedef enum
{
    normalContent,//正常
    payContent,//付费
    failedContent//章节获取失败
    
}ContentShowPageType;

@interface SNStoryContentController ()<SNBookMarkViewDelegate, SNStoryGetContentFailedViewDelegate,SNStoryPurchaseViewDelegate>
{
    UISlider *slider;
    NSArray *numbers;
    NSArray * cart;
    SNChapterBag * oneChptBag;
    SNChapterBag * tenChptsBag;
    SNChapterBag * fiftyChptsBag;
    SNChapterBag * restChptsBag;
    BOOL isPaying;
}

@property(nonatomic, strong)UILabel *chapterNameLabel;//章节名称
@property(nonatomic, strong)UILabel *chapterProgressLabel;//章节进度
@property (nonatomic, strong) SNStoryPurchaseView *purchaseView;//购买view
@property (nonatomic, strong) SNStoryLoginButton *loginView;//登录提示view
@property (nonatomic, strong) SNStoryGetContentFailedView *failedView;//网络失败view
@property(nonatomic, strong)SNStoryWaitingActivityView *waitingActivityView;//加载view
@property (nonatomic, assign)ContentShowPageType contentPageType;//0:付费 1:章节获取失败 2:正常
@property (nonatomic, strong) UILabel * firstPageTitleLabel;//章首大标题
@property (nonatomic, strong) UILabel * firstPageSubTitleLabel;//章首副标题
@property(nonatomic, assign)BOOL isLoginSuccessDeal;//登录成功是否处理过，yes处理过，保证处理一次即可
@property(nonatomic, assign)BOOL isNotNetWorkRefreshHasRead;//没有网络刷新已在书架的书籍，置为已读
@property(nonatomic, strong)UIView *waitRefreshAfterBuySuccessView;//购买成功，等待刷新内容View
@property(nonatomic, assign)BOOL isPurchasedChapter;//是否是刚刚购买的章节
@end

@implementation SNStoryContentController

-(void)dealloc
{
    if (self.chapterContentLabel) {
        [self.chapterContentLabel removeFromSuperview];
        self.chapterContentLabel = nil;
    }
    
    if (self.bookMark) {
        [self.bookMark removeFromSuperview];
        self.bookMark = nil;
    }
    
    if (self.failedView) {
        [self.failedView removeFromSuperview];
        self.failedView = nil;
        self.failedView.delegate = nil;
    }
    
    if (self.purchaseView) {
        [self.purchaseView removeFromSuperview];
        self.purchaseView = nil;
    }
    
    if (self.waitingActivityView) {
        [self.waitingActivityView removeFromSuperview];
        self.waitingActivityView = nil;
    }
    
    if (self.waitRefreshAfterBuySuccessView) {
        [self.waitRefreshAfterBuySuccessView removeFromSuperview];
        self.waitRefreshAfterBuySuccessView = nil;
    }
    
    if (self.loginView) {
        [self.loginView removeFromSuperview];
        self.loginView = nil;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)waitRefreshAfterBuySuccessViewRemove
{
    UIView *waitRefreshAfterBuySuccessView = [[SNStoryUtility getAppDelegate].window viewWithTag:WaitRefreshAfterBuySuccessViewTag];
    if (waitRefreshAfterBuySuccessView) {
        [waitRefreshAfterBuySuccessView removeFromSuperview];
        waitRefreshAfterBuySuccessView = nil;
    }
    
    if (self.waitRefreshAfterBuySuccessView) {
        [self.waitRefreshAfterBuySuccessView removeFromSuperview];
        self.waitRefreshAfterBuySuccessView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.contentPageType == normalContent) {
        
        if (self.bookMark) {
            [self.bookMark checkBookMark];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //放在这里处理，因为预加载，防止未切换章节，开始进行请求
    if (self.chapterType == StoryGetPageNONet || self.chapterType == StoryGetPageFailedView) {
        //处理原因：一次请求不能太多，后十章在后台处理，所以，在此时需要再次判断
        
        if (self.pageViewController.chapterArray.count <= 0) {//章节列表失败
            
            self.pageNum = 0;
            [self.waitingActivityView startAnimating];
            [self performSelector:@selector(waitForViewDeal:) withObject:@"1" afterDelay:1.0];
        } else {//章节列表成功，处理章节内容
            
            [self novelContentWithIsrefresh:NO];
        }
        
    }else if(self.chapterType == StoryPuschaseDownloadView){
        
        [self novelContentWithIsrefresh:YES];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isLoginSuccessDeal = NO;
    self.isNotNetWorkRefreshHasRead = NO;
    self.isPurchasedChapter = NO;
    [self initBg];
    
    //章节标题及阅读进度
    float chapterProgressOrNameLabelOriginY = ChapterProgressOrNameLabelLabelTopOffset;
    if ([SNDevice sharedInstance].isPhoneX) {
        chapterProgressOrNameLabelOriginY = ChapterProgressOrNameLabelLabelTopOffset + 8;
    }
    
    for (int i = 0; i<2; i++) {
        
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
        label.font = [UIFont systemFontOfSize:13];
        switch (i) {
            case 0:
                
                label.textAlignment = NSTextAlignmentLeft;
                label.frame = CGRectMake(PageOriginX, chapterProgressOrNameLabelOriginY, View_Width - PageOriginX*2, ChapterNameLabelHeight);
                self.chapterNameLabel = label;
                
                break;
            case 1:
                
                label.textAlignment = NSTextAlignmentRight;
                label.frame = CGRectMake(View_Width- PageOriginX -(View_Width - PageOriginX*2 - ChapterProgressLabelRightOffset)/2, chapterProgressOrNameLabelOriginY, (View_Width - PageOriginX*2 - ChapterProgressLabelRightOffset)/2, ChapterProgressLabelHeight);
                self.chapterProgressLabel = label;
                break;
                
            default:
                break;
        }
        [self.bookMark.bookMarkView addSubview:label];
    }
    
    self.waitingActivityView = [[SNStoryWaitingActivityView alloc]initWithFrame:CGRectMake(WaitingActivityViewLeftOffset, WaitingActivityViewTopOffset, View_Width, View_Height)];
    self.waitingActivityView.backgroundColor = [UIColor clearColor];
    self.waitingActivityView.center = self.view.center;
    [self.bookMark.bookMarkView addSubview:self.waitingActivityView];
    //到底是显示夜间模式还是选择的背景色
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"0"] && ![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
        if ([[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"1"]) {
            self.view.backgroundColor = [UIColor clearColor];
            [self.bookMark bookMarkBackGroundColor:nil imageName:@"icofiction_background_v5.png"];
        } else {
            UIColor *color = [SNStoryPage getReadBackgroundColor];
            self.view.backgroundColor = color;
            [self.bookMark bookMarkBackGroundColor:color imageName:nil];
            self.bookMark.backgroundColor = color;
        }
    }
    else
    {
        UIColor *color = [UIColor colorFromKey:@"kThemeBg4Color"];
        [self.bookMark bookMarkBackGroundColor:color imageName:nil];
        self.view.backgroundColor = color;
        self.bookMark.backgroundColor = color;
    }
    
    if (self.pageViewController.chapterArray.count > 0) {
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        self.chapterNameLabel.text = chapter.chapterTitle;
    }
    
    if(self.chapterType == StoryNormalPageView){
        
        [self showChapterContent];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNovelTheme) name:kNovelThemeDidChangeNotification object:nil];
}

-(void)showChapterContent
{
    if (self.isPurchasedChapter || self.chapterType == StoryPayPageView ||(self.chapterType == StoryGetPageFailedView ||self.chapterType == StoryGetPageNONet)) {//因为预加载，购买后需要重新刷新
        if (self.isPurchasedChapter) {
            self.isPurchasedChapter = NO;
        }
        
        self.chapterType = StoryNormalPageView;
        if (self.chapterContentLabel) {
            //预加载，有时候会造成上一个label无法释放，显示内容重叠，复现率(1/10)
            [self.chapterContentLabel removeFromSuperview];
            self.chapterContentLabel = nil;
        }
        
        if (self.waitRefreshAfterBuySuccessView) {
            [self.waitRefreshAfterBuySuccessView removeFromSuperview];
            self.waitRefreshAfterBuySuccessView = nil;
        }
        [self.pageViewController setPageViewControllerWithChapterIndex:self.chapterIndex pageIndex:self.pageNum scrollType:StoryOriginPageView scrollAnimation:StoryPageScrollAnimationNone];
    }else
    {
        
        self.chapterType = StoryNormalPageView;
        if (self.chapterContentLabel) {
            //预加载，有时候会造成上一个label无法释放，显示内容重叠，复现率(1/10)
            [self.chapterContentLabel removeFromSuperview];
            self.chapterContentLabel = nil;
        }
        
        SNStoryContentLabel *contentLabel = [[SNStoryContentLabel alloc]init];
        contentLabel.cur_font = self.cur_font;
        contentLabel.frame = CGRectMake(PageOriginX, StoryContentLabelTopOffset, PageWidth, PageHeight);
        contentLabel.textAlignment = NSTextAlignmentLeft;
        self.chapterContentLabel = contentLabel;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.content = self.content;
        
        //这样处理，只是做一个延迟加载内容的假象，产品需要
        if (self.pageNum == 0 && (self.storyScrollType == StoryAfterPageView)) {
            
            [self.waitingActivityView startAnimating];
            [self performSelector:@selector(waitForViewDeal:) withObject:@"2" afterDelay:0.3];
        }
        else
        {
            [self waitForViewDeal:@"2"];
        }
    }
}

- (void)initBg{
    if (!self.bookMark) {
        self.bookMark = [[SNBookMarkView alloc] initWithFrame:self.view.bounds];
    }
    self.bookMark.contentSize = CGSizeMake(BookMarkLeftOffset, self.view.frame.size.height + 1.f);
    self.bookMark.showsVerticalScrollIndicator = NO;
    self.bookMark.showsHorizontalScrollIndicator = NO;
    self.bookMark.bookMarkDelegate = self;
    [self.view addSubview:self.bookMark];
    
    if (!self.bookMark.model) {
        self.bookMark.model = [[SNStoryBookMarkAndNoteModel alloc] init];
    }
    self.bookMark.model.bookId = self.novelId;
}

- (BOOL)canPurchase {
    if (![SNVoucherCenter sufficientBalance:[self.purchaseView getPrice]]) {
        return NO;
    }
    return YES;
}

- (void)autoPurchase {
    //如果开启了自动购买，则自动购买当前章，并刷新页面
    if ([SNVoucherCenter autoPurchase] && !isPaying && [SNStoryUtility isLogin]) {
        isPaying = YES;
        
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        [SNVoucherCenter purchaseWithBookId:chapter.bookId chapters:@[chapter] completed:^(BOOL successed,BOOL checkStatusTimeout) {
            
            self.storyScrollType = StoryOriginPageView;
            if (successed) {
                
                [self.pageViewController.chapterCacheDic removeObjectForKey:[NSString stringWithFormat:@"%d",chapter.chapterId]];
                
                self.isPurchasedChapter = YES;
                [SNVoucherCenter refreshBalance];
                [self.chapterContentLabel removeFromSuperview];
                self.chapterContentLabel = nil;
                
                //刷新内容
                [self novelContentWithIsrefresh:YES];
                
                //加入书架
                [self cidShelfToPidShelfByBookWithPurchase:@"purchase"];
            }
            else{
                //刷新内容等待解除
                [self waitRefreshAfterBuySuccessViewRemove];
            }
            isPaying = NO;
        }];
    }
}

-(void)waitForViewDeal:(id)sender
{
    [self.waitingActivityView stopAnimating];
    
    [self.bookMark setBookMarkEnable:YES];

    NSString *pageTye = sender;
    
    if ([pageTye isEqualToString:@"0"]) {
        
        if (!self.chapterContentLabel) {
            UIView *failedView = [self.view viewWithTag:7010];
            if (failedView) {
                [failedView removeFromSuperview];
                self.failedView = nil;
            }
            
            [self.bookMark setBookMarkEnable:NO];
            
            self.contentPageType = payContent;
            SNStoryContentLabel *halfContentLabel = [[SNStoryContentLabel alloc]init];
            halfContentLabel.cur_font = self.cur_font;
            halfContentLabel.frame = CGRectMake(PageOriginX, StoryContentLabelTopOffset, PageWidth, PageHeight/3.0);
            halfContentLabel.textAlignment = NSTextAlignmentLeft;
            self.chapterContentLabel = halfContentLabel;
            halfContentLabel.backgroundColor = [UIColor clearColor];
            halfContentLabel.content = self.content;
            [self.bookMark.bookMarkView addSubview:self.chapterContentLabel];
            [self initPurchaseView];
        }
        
        if ([SNVoucherCenter autoPurchase]) {
            
            if (self.isPurchasedChapter) {
                //刷新内容等待解除
                [self waitRefreshAfterBuySuccessViewRemove];
            } else {
                //付费页面 处理自动购买逻辑
                if ([self canPurchase]) {
                    isPaying = NO;
                    [self autoPurchase];
                } else{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您的余额不足，请充值后购买" toUrl:nil mode:SNCenterToastModeError];
                    //刷新内容等待解除
                    [self waitRefreshAfterBuySuccessViewRemove];
                }
            }
            
        } else {
            //刷新内容等待解除
            [self waitRefreshAfterBuySuccessViewRemove];
        }

    } else if ([pageTye isEqualToString:@"2"]){
        
        self.contentPageType = normalContent;
        UIView *purView = [self.view viewWithTag:7000];
        if (purView) {
            [purView removeFromSuperview];
            self.purchaseView = nil;
        }
        
        if (self.loginView) {
            [self.loginView removeFromSuperview];
            self.loginView = nil;
        }

        UIView *failedView = [self.view viewWithTag:7010];
        if (failedView) {
            [failedView removeFromSuperview];
            self.failedView = nil;
            self.failedView.delegate = nil;
        }
        
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        SNStoryChapter *tempModel = [SNStoryPage initChapterWithPageViewController:self.pageViewController chapterIndex:self.chapterIndex font:self.cur_font];
        
        self.bookMark.model.chapterId = [NSString stringWithFormat:@"%d",chapter.chapterId];
        
        self.bookMark.model.bookName = self.pageViewController.book.bookTitle;
        self.bookMark.model.bookMark = chapter.chapterTitle;
        self.bookMark.model.pageNum = self.pageNum;
        self.bookMark.model.chapterIndex = self.chapterIndex;
        
        if (self.pageNum < tempModel.chapterPageArray.count) {
            NSString * locationString = [tempModel.chapterPageArray objectAtIndex:self.pageNum];
            if (locationString.length > 0) {
                NSInteger startLocation = [[locationString componentsSeparatedByString:@"_"] firstObject].integerValue;
                NSInteger length = [[locationString componentsSeparatedByString:@"_"] lastObject].integerValue;
                
                if ((startLocation+length) <= tempModel.chapterContent.length) {//加边界保护
                    
                    self.bookMark.model.startLocation = startLocation;
                    self.bookMark.model.length = length;
                    self.bookMark.model.bookMarkcontent = [tempModel.chapterContent substringWithRange:NSMakeRange(startLocation, length)];
                }
                
            }
        }
        [self.bookMark checkBookMark];
        
        NSString * chapterProgressStr= [NSString stringWithFormat:@"%ld/%ld",self.pageNum + 1,tempModel.chapterPageArray.count];
        CGSize chapterProgressSize = [chapterProgressStr boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:0].size;
        
        CGRect chapterProgressRect = self.chapterProgressLabel.frame;
        chapterProgressRect.origin.x = View_Width - chapterProgressSize.width - PageOriginX;
        chapterProgressRect.size.width = chapterProgressSize.width;
        self.chapterProgressLabel.frame = chapterProgressRect;
        self.chapterProgressLabel.text = chapterProgressStr;
        
        CGRect chapterNameLabelRect = self.chapterNameLabel.frame;
        chapterNameLabelRect.size.width = View_Width - chapterProgressSize.width - 3*PageOriginX;
        self.chapterNameLabel.frame = chapterNameLabelRect;
        
        if (self.pageNum == 0) {//首页
            CGFloat halfHeight = PageHeight/2.f;
            CGFloat pageOriginY = [[SNDevice sharedInstance]isPhoneX]?(halfHeight - 15):halfHeight;
            
            //处理下章节标题
            NSArray *titleArray = [chapter.chapterTitle componentsSeparatedByString:@" "];
            NSString * title = [[chapter.chapterTitle componentsSeparatedByString:@" "] firstObject];
            self.firstPageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PageWidth, FirstPageTitleLabelHeight)];
            self.firstPageTitleLabel.top = self.chapterNameLabel.bottom + FirstPageTitleLabelTopOffset/2.f;
            self.firstPageTitleLabel.left = self.chapterNameLabel.left;
            self.firstPageTitleLabel.textAlignment = NSTextAlignmentLeft;
            self.firstPageTitleLabel.font = [UIFont systemFontOfSize:60/2.f];
            self.firstPageTitleLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
            self.firstPageTitleLabel.text = title;
            [self.bookMark.bookMarkView addSubview:self.firstPageTitleLabel];
            
            if (titleArray.count > 1) {//有副标题，添加
                self.chapterContentLabel.frame = CGRectMake(PageOriginX, StoryContentLabelTopOffset + pageOriginY, PageWidth, halfHeight);
                
                NSString * subTitle = [[chapter.chapterTitle componentsSeparatedByString:[NSString stringWithFormat:@"%@ ",title]] lastObject];
                self.firstPageSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PageWidth, FirstPageSubTitleLabelHeight)];
                self.firstPageSubTitleLabel.top = self.firstPageTitleLabel.bottom + FirstPageSubTitleLabelTopOffset/2.f;
                self.firstPageSubTitleLabel.left = self.chapterNameLabel.left;
                self.firstPageSubTitleLabel.textAlignment = NSTextAlignmentLeft;
                self.firstPageSubTitleLabel.font = [UIFont systemFontOfSize:48/2.f];
                self.firstPageSubTitleLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
                self.firstPageSubTitleLabel.text = subTitle;
                [self.bookMark.bookMarkView addSubview:self.firstPageSubTitleLabel];
            }
            else
            {
                self.firstPageTitleLabel.font = [UIFont systemFontOfSize:60/2.f];
                self.chapterContentLabel.frame = CGRectMake(PageOriginX, StoryContentLabelTopOffset + pageOriginY - FirstPageSubTitleLabelHeight, PageWidth, halfHeight);
            }
        }
        
        [self.bookMark.bookMarkView addSubview:self.chapterContentLabel];
        
        //刷新内容等待解除
        [self waitRefreshAfterBuySuccessViewRemove];
    }
    else
    {
        UIView *purView = [self.view viewWithTag:7000];
        if (purView) {
            [purView removeFromSuperview];
            self.purchaseView = nil;
        }
        if (self.loginView) {
            [self.loginView removeFromSuperview];
            self.loginView = nil;
        }

        if (self.chapterContentLabel) {
            [self.chapterContentLabel removeFromSuperview];
            self.chapterContentLabel = nil;
        }
        
        self.contentPageType = failedContent;
        if (!self.failedView) {
            
            self.failedView = [[SNStoryGetContentFailedView alloc]initWithFrame:CGRectMake(FailedViewLeftOffset, FailedViewTopOffset, View_Width, View_Height - FailedViewTopOffset)];
            self.failedView.delegate = self;
            self.failedView.tag = 7010;
            
            if (self.chapterType == StoryGetPageNONet) {
                self.failedView.storyGetContentFailedType = SNStoryGetContentNoNet;
            } else {
                self.failedView.storyGetContentFailedType = SNStoryGetContentFailed;
            }
            [self.view addSubview:self.failedView];
        }
        else
        {
            [self.view addSubview:self.failedView];
        }
        
        //刷新内容等待解除
        [self waitRefreshAfterBuySuccessViewRemove];
    }
}

#pragma mark 查询书籍信息
-(void)novelDetail
{
    [SNStoryPage storyDetailRequestWithBookId:self.novelId pageTye:StoryNormalPage completeBlock:^(id result) {
        
        [self.waitingActivityView stopAnimating];
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary*)result;
            if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"1"]) {//isSuccess:1表示成功
                [self.pageViewController initPageArrayWithNovelId:self.novelId chapterId:0 font:self.cur_font chapterIndex:0];
                if (self.pageViewController.chapterArray.count > 0) {
                    ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
                    self.chapterNameLabel.text = chapter.chapterTitle;
                }
                
                [self novelContentWithIsrefresh:NO];
            }
            else{
            
                //章节内容失败
                [self.waitingActivityView startAnimating];
                [self performSelector:@selector(waitForViewDeal:) withObject:@"1" afterDelay:1.0];
            }
        }
        else{
        
            //章节内容失败
            [self.waitingActivityView startAnimating];
            [self performSelector:@selector(waitForViewDeal:) withObject:@"1" afterDelay:1.0];
        }
    }];
}

#pragma mark 查询书籍章节内容
-(void)novelContentWithIsrefresh:(BOOL)isRefresh
{
    //刷新内容等待(其实就是一个遮罩，用户无法进行其他操作)
    if (!self.waitRefreshAfterBuySuccessView) {
        self.waitRefreshAfterBuySuccessView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, View_Width, View_Height)];
        self.waitRefreshAfterBuySuccessView.backgroundColor = [UIColor clearColor];
        self.waitRefreshAfterBuySuccessView.tag = WaitRefreshAfterBuySuccessViewTag;
        [[SNStoryUtility getAppDelegate].window addSubview:self.waitRefreshAfterBuySuccessView];
    }
    
    //首次Wi-Fi下载10章，非Wi-Fi下载一章
    [self.waitingActivityView startAnimating];
    NSUInteger chapterId = 1;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (self.pageViewController.chapterArray.count > 0) {
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        
        chapterId = chapter.chapterId;
        if (chapterId <= 0) {//chapterId从0开始现在改为1了
            chapterId = 1;
        }
    }
    
    
    NSString *startChapterId = [NSString stringWithFormat:@"%ld",chapterId];
    NSString *chapterCount = @"1";//第一次或非Wi-Fi下下载1章
    NSString *firstReadThisBook = [userDefault objectForKey:self.novelId];
    
    if (!isRefresh) {
        StoryNetworkReachabilityStatus status =  [SNStoryUtility currentReachabilityStatusForStory];
        if (status == StoryNetworkReachabilityStatusReachableViaWiFi) {
            
            if (firstReadThisBook && [firstReadThisBook isEqualToString:@"1"]) {
                //阅读时，阅读到最后一章，Wi-Fi下，下载6章
                chapterCount = @"6";
                
            }
        }
    }
    
    [SNStoryPage storyChapterContentRequestWithBookId:self.novelId pageViewController:self.pageViewController startChapterId:startChapterId chapterCount:chapterCount completeBlock:^(id result) {
        
        //关闭加载
        [self.waitingActivityView stopAnimating];
        
        //章节内容处理
        if ([result isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary*)result;
            if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"1"]) {//isSuccess:1表示成功
                if (!firstReadThisBook || [firstReadThisBook isEqualToString:@"0"]) {
                     [userDefault setObject:@"1" forKey:self.novelId];
                }
                
                //章节内容处理
                [self requestChaterContentDeal];
                //书架进入，无网络，已读接口调用失败，开启后刷新，再次刷新已读接口
                [self notNetWorkRefreshHasRead];
            } else {//章节内容失败
                
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                
                //章节内容失败
                [self waitForViewDeal:@"1"];
            }
        }else{//章节内容失败
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            //章节内容失败
            [self waitForViewDeal:@"1"];
        }
    }];
}

-(void)requestChaterContentDeal
{
    if (self.pageViewController.chapterArray.count <= 0) {
        //章节内容失败
        [self waitForViewDeal:@"1"];
    }else{
        
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        //章节信息处理
        SNStoryChapter *tempModel = [SNStoryPage initChapterWithPageViewController:self.pageViewController chapterIndex:self.chapterIndex font:self.cur_font];
        
        if (!tempModel.chapterContent || tempModel.chapterContent.length <= 0) {
            
            //章节内容失败
            [self waitForViewDeal:@"1"];
        } else {
            
            //清除章节内容缓存
            if (self.content && self.content.length > 0) {
                [self.pageViewController.chapterCacheDic removeObjectForKey:[NSString stringWithFormat:@"%ld", chapter.chapterId]];
            }
            
            //5.9.1新老版本兼容，即页码与偏移量兼容(5.9.1以前是页码，之后是偏移量)
            if (self.pageViewController.isAnchor) {//进行锚点计算，只需要一次
                StoryBookAnchor *anchor = [StoryBookAnchor fetchBookAnchorWithBookId:self.novelId];
                self.pageNum = [SNStoryPage getPageNumFromPageOffsetWithPageOffset:anchor.pageNO storyChapter:tempModel];
                self.pageViewController.isAnchor = NO;
            }
            
            if (self.storyScrollType == StoryBforePageView) {//从一开始，从最后一章往前翻页，前一章没有内容，需要请求，此时，必须修改页数，否则是第一页
                
                if (tempModel.chapterPageArray.count > 0) {
                    self.pageNum = tempModel.chapterPageArray.count - 1;
                } else {
                    self.pageNum = 0;
                }
            }
            
            self.content = [SNStoryPage getContentWithModel:tempModel currentIndex:self.pageNum];
            
            //付费处理
            if (tempModel.isFree || tempModel.hasPaid) {
                [self showChapterContent];
            } else {
                
                if (!self.content || self.content.length <= 0) {
                    //章节内容失败
                    [self waitForViewDeal:@"1"];
                } else {
                    self.pageNum = 0;
                    [self waitForViewDeal:@"0"];
                    self.chapterType = StoryPayPageView;
                }
            }
        }
    }
}

#pragma mark StoryGetContentFailedViewDelegate
-(void)refreshRequestWithDic:(NSDictionary *)dic
{
    [self.failedView removeFromSuperview];
    StoryBookAnchor *anchor = [StoryBookAnchor fetchBookAnchorWithBookId:self.novelId];
    if (!anchor) {//本地没有锚点，需要刷新锚点
        [SNStoryPage novelGet_AnchorDic:@{@"platform":@"5"} completeBlock:nil];
    }
    
    if (self.pageViewController.chapterArray.count <= 0) {
        [self.waitingActivityView startAnimating];
        [self novelDetail];
    } else {
        [self novelContentWithIsrefresh:YES];
    }
}

#pragma mark 书架进入，无网络，已读接口调用失败，开启后刷新
-(void)notNetWorkRefreshHasRead
{
    //书架进入，无网络，已读接口调用失败，开启后刷新，再次刷新已读接口
    if ([SNBookShelf isOnBookshelf:self.novelId] && (self.pageViewController.pageType == StoryPageFromChannel)) {
        
        if (!self.isNotNetWorkRefreshHasRead) {
            
            [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil userInfo:@{@"scrollTop":@"1",@"bookId":self.novelId}];
            self.isNotNetWorkRefreshHasRead = YES;
        }
    }
}

/**
 当书签拖拽的时候通知一下controller，可以来处理一些事情。

 @param offsetY Y偏移量
 */
- (void)bookMarkViewDidScroll:(CGFloat)offsetY {

}

- (void)updateNovelTheme {
    
    [self.bookMark updateTheme];
    self.chapterNameLabel.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
    self.chapterProgressLabel.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"0"] && ![[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"4"]) {
        
        if ([[userDefault objectForKey:@"storyColorTheme"] isEqualToString:@"1"]) {
            self.view.backgroundColor = [UIColor clearColor];
            [self.bookMark bookMarkBackGroundColor:nil imageName:@"icofiction_background_v5.png"];
        } else {
            
            UIColor *color = [SNStoryPage getReadBackgroundColor];
            [self.bookMark bookMarkBackGroundColor:color imageName:nil];
            self.view.backgroundColor = color;
            self.bookMark.backgroundColor = color;
        }
    }
    else
    {
        UIColor *color = [UIColor colorFromKey:@"kThemeBg4Color"];
        [self.bookMark bookMarkBackGroundColor:color imageName:nil];
        self.view.backgroundColor = color;
        self.bookMark.backgroundColor = color;
    }
    
    if (self.contentPageType == payContent) {
        
        [self.purchaseView updateNovelTheme];
        [self.loginView updateNovelTheme];
        [self.chapterContentLabel updateNovelTheme];
        
    }
    else if (self.contentPageType == failedContent)
    {
        [self.failedView updateNovelTheme];
        
    }
    else {
        
        [self.chapterContentLabel updateNovelTheme];
        self.firstPageTitleLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        self.firstPageSubTitleLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
    }
    
    [self.waitingActivityView updateTheme];
}

#pragma mark - login
- (void)initPurchaseView{
    if ([SNStoryUtility isLogin]) {//登录状态
        [self groupingChaptersForPayment];
        if (self.loginView) {
            [self.loginView removeFromSuperview];
            self.loginView = nil;
        }
        if (!self.purchaseView) {
            
            self.purchaseView = [[SNStoryPurchaseView alloc]initWithFrame:CGRectMake(PurchaseViewLeftOffset, self.chapterContentLabel.bottom + 20, View_Width, PageHeight * 2/3.0) pageViewController:self.pageViewController chapterIndex:self.chapterIndex];
            self.purchaseView.tag = 7000;
            [self.view addSubview:self.purchaseView];
        }
        self.purchaseView.delegate = self;
        self.purchaseView.pageViewController = self.pageViewController;
        self.purchaseView.currentIndex = self.chapterIndex;
        ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
        if (!chapter || chapter == NULL) {
            SNDebugLog(@"initPurchaseView:章节是空");
        }
        self.purchaseView.purchaseType = StoryThisChapter;
        [self.purchaseView setPaymentTitle:chapter.chapterTitle index:_chapterIndex];
        [self.purchaseView setPrice:chapter.price];
    }
    //未登录状态
    else {
        if (self.purchaseView) {
            [self.purchaseView removeFromSuperview];
            self.purchaseView = nil;
        }
        if (!self.loginView) {
            __weak typeof(self)weakself = self;
            self.loginView = [[SNStoryLoginButton alloc]initWithFrame:CGRectMake(PurchaseViewLeftOffset, (kAppScreenHeight - PurchaseViewTopOffset)/2.f, View_Width, (kAppScreenHeight - PurchaseViewTopOffset)/2.f) loginBlock:^{
                [weakself goLogin];
            }];
            [self.view addSubview:self.loginView];
        }
    }
}

- (void)purchaseButtonClicked {
    ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
    if (!chapter || chapter == NULL) {
        SNDebugLog(@"purchaseButtonClicked:章节是空");
    }
    //go purchase
    //购买所选章节小说
    [SNVoucherCenter purchaseWithBookId:chapter.bookId chapters:cart completed:^(BOOL successed, BOOL checkStatusTimeout) {
        //checkStatusTimeout 超时了，有可能支付成功了，有可能没支付成功【服务端有坑啊】
        self.storyScrollType = StoryOriginPageView;
        if (successed || checkStatusTimeout) {
            
            for (ChapterList *chapter in cart) {
                [self.pageViewController.chapterCacheDic removeObjectForKey:[NSString stringWithFormat:@"%d",chapter.chapterId]];
            }
            
            self.isPurchasedChapter = YES;
            [SNVoucherCenter refreshBalance];
            [self.chapterContentLabel removeFromSuperview];
            self.chapterContentLabel = nil;
            [self novelContentWithIsrefresh:YES];
            //加入书架
            [self cidShelfToPidShelfByBookWithPurchase:@"purchase"];
        }
        else{
            //刷新内容等待解除
            [self waitRefreshAfterBuySuccessViewRemove];
        }
    }];

}

#pragma mark - 购物车

/**
 进行章节分组，将未付费的章节按1、10、50、余下所有分组,并记录价格
 */
- (void)groupingChaptersForPayment {
    oneChptBag      = [[SNChapterBag alloc] init];
    tenChptsBag     = [[SNChapterBag alloc] init];
    fiftyChptsBag   = [[SNChapterBag alloc] init];
    restChptsBag    = [[SNChapterBag alloc] init];
    NSInteger i     = self.chapterIndex;
    NSInteger count = 0;
    NSArray * allChapters = self.pageViewController.chapterArray;

    while (i < allChapters.count) {
        ChapterList *chapter = allChapters[i];
        ///过滤掉已经购买的 和 免费的章节
        if (!chapter.hasPaid && !chapter.isfree) {
            if (count == 0) {
                [oneChptBag.bag addObject:chapter];
                oneChptBag.price += chapter.price;
            }
            if (count < 10){
                [tenChptsBag.bag addObject:chapter];
                tenChptsBag.price += chapter.price;
            }
            if (count < 50){
                [fiftyChptsBag.bag addObject:chapter];
                fiftyChptsBag.price += chapter.price;
            }
            [restChptsBag.bag addObject:chapter];
            restChptsBag.price += chapter.price;
            
            count ++;
        }
        i++;
    }
}

- (void)purchaseTypeDidChanged:(StoryPurchaseType)type {
    //根据选择的章节添加购物车
    CGFloat totalPrice = 0;
    /*
     StoryThisChapter = 0,      //购买本章
     StoryAfterTenChapter,      //购买后10章
     StoryAfterfiftyChapter,    //购买后50章
     StoryOtherChapter          //购买剩余章节
     */
    NSInteger step = 0;
    switch (type) {
        case StoryThisChapter:
        {
            totalPrice = oneChptBag.price;
            cart = [NSArray arrayWithArray:oneChptBag.bag];
            break;
        }
        case StoryAfterTenChapter:
        {
            totalPrice = tenChptsBag.price;
            cart = [NSArray arrayWithArray:tenChptsBag.bag];
            break;
        }
        case StoryAfterfiftyChapter:
        {
            totalPrice = fiftyChptsBag.price;
            cart = [NSArray arrayWithArray:fiftyChptsBag.bag];
            break;
        }
        case StoryOtherChapter:
        {
            totalPrice = restChptsBag.price;
            cart = [NSArray arrayWithArray:restChptsBag.bag];
            break;
        }
        default:
            break;
    }
    
    [self.purchaseView setPrice:totalPrice];

}

- (void)goLogin{
    //wangshunlogin
    //wangshun login open
    [SNUtility shouldUseSpreadAnimation:NO];
    [SNUtility shouldAddAnimationOnSpread:NO];
    
    //wangshun login open
    [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111小说内登录购买
        [self loginSuccess];
    } Failed:^(NSDictionary *errorDic) {
        [self loginOnBack];
    }];
    
    //未登录用户需引导登录后方可充值

    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
    NSValue* onbackMethod = [NSValue valueWithPointer:@selector(loginOnBack)];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method",onbackMethod,@"onBackMethod", self,@"delegate", [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
}

- (void)loginOnBack {
    //2017-03-24 wangchuanwen update begin
    //避免loginSuccess方法会走两次
    if ([SNStoryUtility isLogin] && !self.isLoginSuccessDeal) {
        [self loginSuccess];
    }
    //2017-03-24 wangchuanwen update end
}


- (void)loginSuccess {
    //刷新小说数据
    [self cidShelfToPidShelfByBookWithPurchase:@"login"];
    
    self.isLoginSuccessDeal = YES;
    //同步pid章节
    [self.pageViewController updatePidInfoByCid];
    
    //获取当前章节信息,并判断该pid的该章节是否已购买过
    ChapterList *chapter = [self.pageViewController.chapterArray objectAtIndex:self.chapterIndex];
    
    //更新UI
    if (self.loginView) {
        [self.loginView removeFromSuperview];
        self.loginView = nil;
    }
    
    //halfContentLabel是否有必要重新定义，可否直接使用self.chapterContentLabel @huang zhen
    if (self.chapterContentLabel) {
        [self.chapterContentLabel removeFromSuperview];
        self.chapterContentLabel = nil;
    }
    
    if (chapter.isfree || chapter.hasPaid) {//已购买，显示该章节内容
        
        //内容展示
        SNStoryChapter *tempModel = [SNStoryPage initChapterWithPageViewController:self.pageViewController chapterIndex:self.chapterIndex font:self.cur_font];
        
        if (tempModel.chapterContent && tempModel.chapterContent.length > 0) {
            
            self.content = [SNStoryPage getContentWithModel:tempModel currentIndex:self.pageNum];
            [self showChapterContent];
        } else {//没有内容，去请求该章节内容
            
            [self novelContentWithIsrefresh:YES];
        }
        
    }
    
    else
    {
        //同步时，防止卸载app后安装，cid同步到pid，需要重新刷新内容
        [self novelContentWithIsrefresh:YES];
    }
}

#pragma mark cid书架进入，由未登录变为登录，且登录书架没有该本书，加入书架
-(void)cidShelfToPidShelfByBookWithPurchase:(NSString *)string
{
    if ([string isEqualToString:@"login"]) {
        if (self.pageViewController.pageType == StoryPageFromChannel) {
            [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil userInfo:@{@"scrollTop":@"1",@"bookId":self.novelId}];
        }
    } else {
        
        if (![SNBookShelf isOnBookshelf:self.novelId]) {//不在pid书架，买书后，加入书架
            [SNBookShelf addBookShelf:self.novelId hasRead:YES completed:nil];
        }
        else
        {
            if (self.pageViewController.pageType == StoryPageFromChannel) {//从书架进入阅读页，购买后刷新书架
                [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil userInfo:@{@"scrollTop":@"1",@"bookId":self.novelId}];
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
