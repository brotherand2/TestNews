//
//  SNStoryCatelogController.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryCatelogController.h"
#import "SNStoryContanst.h"
#import "SNStoryPageViewController.h"
#import "UIViewAdditions+Story.h"
#import "SNStoryBottomToolbar.h"
#import "SNStoryCatelogCell.h"
#import "UIImage+Story.h"
#import "SNStoryPage.h"

#import "SNStoryBookMarkAndNoteCell.h"
#import "SNStoryBookMarkDataCell.h"
#import "SNBookMarkViewModel.h"

#import "StoryBookList.h"
#import "ChapterList.h"
#import "SNStoryUtility.h"
#import "SNStoryWaitingActivityView.h"

#define WaitingActivityViewLeftOffset                     0.0//等待加载view的左边距
#define WaitingActivityViewTopOffset                      0.0//等待加载view的上边距

#define CATELOGHeight                                 40//目录、书签、批注view的高度
#define CATELOGWidth                                  (View_Width / 2.0)//目录、书签、批注view的款
#define CATELOGBtnLeftOffset                          15.0//目录按钮左偏移量
#define CATELOGBtnHeight                              30.0//目录按钮高度
#define CATELOGBtnImageEdgeInsetsRight                20.0//目录按钮图片右编辑
#define CATELOGBtnImageEdgeInsetsLeft                 0.0//目录按钮图片左编辑
#define CATELOGLineViewLeftOffset                     0.0//目录按钮分割线左边距
#define CATELOGLineViewHeight                         0.5//目录按钮分割线高度
#define CATELOGBtnLineWidth                           1.0//目录按钮分割线宽度
#define CATELOGBtnLineTopOffset                       5.0//目录按钮分割线上边距
#define CATELOGTableViewLeftOffset                    0.0//tableview左边距

#define NaviBarImageViewleftOffset                    0.0//导航条左边距
#define NaviBarImageViewTopOffset                     0.0//导航条上边距
#define ViewLeftOffset                                14.0//view做编辑
#define TitleLabelGap                                 30.0//目录与章节间距
#define TitleLabelBottomOffset                        10.0//目录下边距
#define LineViewHeight                                1.0//分割线高度
#define RankButtonLeftOffset                          10.0//排名按钮左边距
#define RankButtonTopOffset                           2.0//排名按钮上边距
#define StoryBottomToolbarLeftOffset                  0.0//底部导航栏左边距
#define StoryBottomToolbar_LeftBtnLeftOffset          0.0//底部导航栏左按钮左边距
#define  StoryBottomToolbar_LeftBtnTopOffset          0.0//底部导航栏左按钮上边距
#define StoryBottomToolbar_LeftBtnWidth               43.0//底部导航栏左按钮宽度
#define StoryBottomToolbar_LeftBtnHeight              43.0//底部导航栏左按钮高度

//iPhoneX适配
#define CatelogHeaderTotalHeight                      ([[UIDevice currentDevice]platformTypeForSohuNews] == UIDeviceiPhoneX?(StoryHeaderTotalHeight+20):StoryHeaderTotalHeight)
#define CatelogBottomBarHeight                        ([[UIDevice currentDevice]platformTypeForSohuNews] == UIDeviceiPhoneX?(BottomBarHeight+20):BottomBarHeight)

typedef enum {
    CATELOG = 1,//1:目录
    CATELOG_BOOKMARK,//2:书签
    CATELOG_BOOKNOTE//3:批注
    
}CATELOGBTNTYPE;

@interface SNStoryCatelogController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIImageView *naviBarImageView;//顶部导航条
@property(nonatomic,strong)UIView *catelogLineView;//分割线
@property(nonatomic,strong)UILabel *titleLabel;//书名Label
@property(nonatomic,strong)UILabel *chapterCountLabel;//章节数Label
@property(nonatomic,strong)UITableView *catelogTableView;//tableview
@property(nonatomic, strong)SNStoryWaitingActivityView *waitingActivityView;
@property(nonatomic,strong)NSMutableArray *chapterArry;//章节列表数组
@property(nonatomic,strong)NSMutableArray *bookMarkArry;//书签数组
@property(nonatomic,strong)NSMutableArray *bookNoteArry;//批注数组(目前不适用)
@property(nonatomic,strong)SNStoryBottomToolbar *bottomBar;//底部导航条
@property(nonatomic,assign)CATELOGBTNTYPE catelogBtnType;//1:目录  2:书签  3:批注
@property(nonatomic,strong)StoryBookList *book;//小说
@property(nonatomic,assign)BOOL isReload;//是否加载
@property(nonatomic,strong)NSString *recordPid;//记录登录状态
@end

@implementation SNStoryCatelogController

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //第一次安装初始化背景色
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    if (!storyColorTheme || storyColorTheme.length <= 0) {
        [userDefault setObject:@"0" forKey:@"storyColorTheme"];
        [userDefault setObject:@"0" forKey:@"selectedColorTheme"];
        [userDefault synchronize];
    }
    
    self.recordPid = [SNStoryUtility getPid];
    self.isReload = NO;
    //初始化导航栏上的元素
    [self initNavigationBar];
    
    self.bookMarkArry = [NSMutableArray arrayWithArray:[SNBookMarkViewModel bookMarksWithBookId:self.novelId chapterId:nil]];
    self.view.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    
    self.catelogTableView = [[UITableView alloc]initWithFrame:CGRectMake(CATELOGTableViewLeftOffset, CatelogHeaderTotalHeight, View_Width, View_Height - CatelogHeaderTotalHeight - CatelogBottomBarHeight) style:UITableViewStylePlain];
    
    self.catelogTableView.delegate = self;
    self.catelogTableView.dataSource =self;
    self.catelogTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:self.catelogTableView.frame];
    backgroundView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    self.catelogTableView.backgroundView = backgroundView;
    [self.view addSubview:self.catelogTableView];
    
    self.waitingActivityView = [[SNStoryWaitingActivityView alloc]initWithFrame:CGRectMake(WaitingActivityViewLeftOffset, WaitingActivityViewTopOffset, View_Width, View_Height)];
    self.waitingActivityView.backgroundColor = [UIColor clearColor];
    self.waitingActivityView.center = self.view.center;
    [self.view addSubview:self.waitingActivityView];
    [self.waitingActivityView startAnimating];
    //逻辑实在怪异：小说频道-进入一本小说详情页-倒序排列，再次进入该本小说详情页-进入目录查看
    //实际结果:ios端记录上次倒序，按照倒序显示 安卓端默认正序排列
    //产品确认:再次进入按照默认正序排列
    [userDefault setObject:@"0" forKey:@"storyCatelogSort"];
    [userDefault synchronize];
    
    //书籍详情、列表详情请求
    [self novelDetail];
    
    [SNNotificationManager addObserver : self selector : @selector (statusBarFrameWillChange:) name : UIApplicationWillChangeStatusBarFrameNotification object : nil ];
    
}

-(void)statusBarChange
{
    if (StoryBarStatusHeight > kSystemBarHeight) {
        
        self.bottomBar.frame = CGRectMake(StoryBottomToolbarLeftOffset, View_Height - CatelogBottomBarHeight - kSystemBarHeight, View_Width, CatelogBottomBarHeight);
        self.catelogTableView.frame = CGRectMake(CATELOGTableViewLeftOffset, CatelogHeaderTotalHeight, View_Width, View_Height - CatelogHeaderTotalHeight - CatelogBottomBarHeight - kSystemBarHeight);
    }
    else
    {
        self.bottomBar.frame = CGRectMake(StoryBottomToolbarLeftOffset, View_Height - CatelogBottomBarHeight, View_Width, CatelogBottomBarHeight);
        self.catelogTableView.frame = CGRectMake(CATELOGTableViewLeftOffset, CatelogHeaderTotalHeight, View_Width, View_Height - CatelogHeaderTotalHeight - CatelogBottomBarHeight);
    }
}

-(void)statusBarFrameWillChange:(NSNotification *)notification
{
    [self statusBarChange];
}

- (BOOL)needPanGesture {
    return NO;//禁止右滑返回
}
#pragma mark 查询书籍详情
-(void)novelDetail
{
    if ([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable) {//无网络用DB中的数据
        
        StoryBookList *book = [StoryBookList fecthBookByBookId:self.novelId];
        [self chapterListDealWithBook:book];
        
    }else
    {
        [SNStoryPage storyDetailRequestWithBookId:self.novelId pageTye:StoryNeedRefresh completeBlock:^(id result) {//有网络，刷新数据
            
            StoryBookList *book = [StoryBookList fecthBookByBookId:self.novelId];
            [self chapterListDealWithBook:book];
        }];
    }
}

#pragma mark 数据刷新
-(void)chapterListDealWithBook:(StoryBookList *)book
{
    [self bookDetailWithArray:book];
    self.isReload = YES;
    [self.waitingActivityView stopAnimating];
    [self.waitingActivityView removeFromSuperview];
    self.waitingActivityView = nil;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *isAsc = [userDefault objectForKey:@"storyCatelogSort"];
    BOOL isSort = YES;
    if ([isAsc isEqualToString:@"1"]) {
        isSort = NO;
    }
    
    NSArray *chapterList = [ChapterList fecthBookChapterListByBookId:self.novelId chapterId:0 ascending:isSort];
    if (chapterList.count > 0 ) {
        self.chapterArry = [chapterList mutableCopy];
    }
    
    [self chapterHasReadWithNovelId:self.novelId book:book];
}

#pragma mark 书籍信息处理
- (void)bookDetailWithArray:(StoryBookList *)book {
    if (self.catelogType == StoryCateLogFromH5Detail) {
        self.titleLabel.text = @"目录";
        UIFont *countFont = [UIFont systemFontOfSize:14];
        NSDictionary *countAttributeDict = [NSDictionary dictionaryWithObjectsAndKeys:countFont,NSFontAttributeName,nil];
        
        NSString *Chapters = [[NSNumber numberWithInteger:book.maxChapters]stringValue];
        NSString *countStr = [NSString stringWithFormat:@"共%@章",Chapters];
        CGSize chapterSize = [countStr boundingRectWithSize:CGSizeMake(300, countFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:countAttributeDict context: nil].size;
        
        CGRect chapterRect = self.chapterCountLabel.frame;
        chapterRect.origin.x = View_Width - ViewLeftOffset - chapterSize.width;
        chapterRect.size.width =chapterSize.width;
        self.chapterCountLabel.frame = chapterRect;
        self.chapterCountLabel.text = countStr;
    }
}

-(void)chapterHasReadWithNovelId:(NSString *)novelId  book:(StoryBookList *)book
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *isAsc = [userDefault objectForKey:@"storyCatelogSort"];
    BOOL isSort = YES;
    if ([isAsc isEqualToString:@"1"]) {
        isSort = NO;
    }
    
    NSString *pid = [SNStoryUtility getPid];
    if (self.recordPid != pid) {//登录状态改变，刷新数据
        self.recordPid = pid;
        
        NSArray *array = [ChapterList fecthBookChapterListByBookId:novelId chapterId:0 ascending:isSort];
        if (array && array.count > 0) {
            [self.chapterArry removeAllObjects];
            [self.chapterArry addObjectsFromArray:array];
        }
    }
    
    //跳转到已读章节，没有读过，也会跳，但没有标识出你所读章节
    [self.catelogTableView reloadData];
    if (book) {
        self.book = book;
        if (book.hasReadChapterIndex < self.chapterArry.count) {
            NSInteger chapterIndex = book.hasReadChapterIndex;
            if ([isAsc isEqualToString:@"1"]) {
                chapterIndex = self.chapterArry.count - book.hasReadChapterIndex - 1;
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:chapterIndex inSection:0];
            [self.catelogTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self statusBarChange];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)addHeaderView
{
    return;
}

- (void)updateTheme {
    [super updateTheme];
    
    self.view.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    UIView *backgroundView = [[UIView alloc]initWithFrame:self.catelogTableView.frame];
    backgroundView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    self.catelogTableView.backgroundView = backgroundView;
    
    //导航栏
    self.naviBarImageView.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
    
    if (self.catelogType == StoryCateLogFromH5Detail) {
        [self.bottomBar updateTheme];
        self.titleLabel.textColor = [UIColor colorFromKey:@"kThemeRed1Color"];
        self.catelogLineView.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"];
        self.chapterCountLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        
        //toolbar
        UIImage *image = [UIImage imageStoryNamed:@"icofiction_rank_v5.png"];
        UIImageView *shadowImageView = [self.bottomBar viewWithTag:3251];
        shadowImageView.image = image;
        
        //UIButton *button = [self.bottomBar viewWithTag:3003];
        //button.frame = CGRectMake(shadowImageView.left - 10, 2, image.size.width + 10, BottomBarHeight - 4);
        
        UIButton *leftButton = [self.bottomBar viewWithTag:3256];
        [leftButton setImage:[UIImage imageStoryNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
        [leftButton setImage:[UIImage imageStoryNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
        
    } else {
        
        for (int i = 0; i<2; i++) {
            
            UIButton *button = [self.naviBarImageView viewWithTag:(3000+i)];
            if (i != 1) {
                UIView *btnLine = [self.naviBarImageView viewWithTag:(4000+i)];
                btnLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
            }
            
            if (i == 0) {
                
                if (button.isSelected) {
                    [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_catalogpress_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                } else {
                    [button setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_catalog_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                }
                
            }else if(i == 1) {
                
                if (button.isSelected) {
                    [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_bookmarkpress_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                } else {
                   [button setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_bookmark_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                }
                
            }
            else {//批注现在不要，将来会要，先不删除
                
                if (button.isSelected) {
                    [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_postilpress_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                } else {
                    [button setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
                    UIImage *image = [UIImage imageStoryNamed:@"icofiction_postil_v5.png"];
                    [button setImage:image forState:UIControlStateNormal];
                }
                
            }

        }
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self.bottomBar updateTheme];
    [self.catelogTableView reloadData];
}

#pragma mark 初始化导航栏上的元素
-(void)initNavigationBar
{
    //导航栏
    self.naviBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(NaviBarImageViewleftOffset, NaviBarImageViewTopOffset, View_Width, CatelogHeaderTotalHeight)];
    self.naviBarImageView.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
    self.naviBarImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.naviBarImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.naviBarImageView addSubview:self.titleLabel];
    
    if (self.catelogType == StoryCateLogFromH5Detail) {
        
        self.titleLabel.textColor = [UIColor colorFromKey:@"kThemeRed1Color"];
        UIFont *font = [UIFont systemFontOfSize:16];
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
        CGSize cateLogSize = [@"目录" boundingRectWithSize:CGSizeMake(100, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDict context: nil].size;
        
        UIFont *countFont = [UIFont systemFontOfSize:14];
        NSDictionary *countAttributeDict = [NSDictionary dictionaryWithObjectsAndKeys:countFont,NSFontAttributeName,nil];
        CGSize chapterSize = [@"共0章" boundingRectWithSize:CGSizeMake(View_Width -ViewLeftOffset*2 - cateLogSize.width - TitleLabelGap, countFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:countAttributeDict context: nil].size;
        
        self.titleLabel.text = @"目录";
        self.titleLabel.frame = CGRectMake(ViewLeftOffset, CatelogHeaderTotalHeight - TitleLabelBottomOffset - font.lineHeight, cateLogSize.width, font.lineHeight);
        self.titleLabel.font = font;
        
        self.catelogLineView = [[UIView alloc]initWithFrame:CGRectMake(ViewLeftOffset, CatelogHeaderTotalHeight - LineViewHeight, cateLogSize.width, LineViewHeight)];
        self.catelogLineView.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"];
        [self.naviBarImageView addSubview:self.catelogLineView];
        
        self.chapterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(View_Width - ViewLeftOffset - chapterSize.width, self.titleLabel.originY + (self.titleLabel.height - countFont.lineHeight)/2, chapterSize.width, countFont.lineHeight)];
        self.chapterCountLabel.backgroundColor = [UIColor clearColor];
        self.chapterCountLabel.font = countFont;
        self.chapterCountLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        self.chapterCountLabel.textAlignment = NSTextAlignmentLeft;
        [self.naviBarImageView addSubview:self.chapterCountLabel];
        
        //toolbar
        UIImage *image = [UIImage imageStoryNamed:@"icofiction_rank_v5.png"];
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(View_Width - ViewLeftOffset - image.size.width, (BottomBarHeight - image.size.height)/2, image.size.width, image.size.height)];
        shadowImageView.image = image;
        shadowImageView.tag = 3251;
        
        UIButton *rankButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rankButton.tag = 3003;
        rankButton.frame = CGRectMake(shadowImageView.left - RankButtonLeftOffset, RankButtonTopOffset, image.size.width + RankButtonLeftOffset, BottomBarHeight - RankButtonTopOffset*2);
        [rankButton addTarget:self action:@selector(btnCatalog:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomBar addSubview:shadowImageView];
        [self.bottomBar addSubview:rankButton];
        
    } else {
        
        self.catelogBtnType = CATELOG;
        
        for (int i = 0; i<2; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 3000+i;
            [button addTarget:self action:@selector(btnCatalog:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            button.frame = CGRectMake(CATELOGWidth*i+CATELOGBtnLeftOffset/2, (CatelogHeaderTotalHeight - CATELOGBtnHeight - TitleLabelBottomOffset), CATELOGWidth - CATELOGBtnLeftOffset, CATELOGBtnHeight);
            
            if (i != 1) {//划线
                UIView *btnLine = [[UIView alloc]initWithFrame:CGRectMake(CATELOGWidth*(i+1)-CATELOGBtnLineWidth, CatelogHeaderTotalHeight - CATELOGBtnHeight - CATELOGBtnLineTopOffset, CATELOGBtnLineWidth, CATELOGBtnHeight)];
                btnLine.tag = 4000+i;
                btnLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
                [self.naviBarImageView addSubview:btnLine];
            }
            
            if (i == 0) {
                
                [button setTitle:@"目录" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
                UIImage *image = [UIImage imageStoryNamed:@"icofiction_catalogpress_v5.png"];
                [button setImage:image forState:UIControlStateNormal];
                button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            }else if(i == 1) {
                
                [button setTitle:@"书签" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
                UIImage *image = [UIImage imageStoryNamed:@"icofiction_bookmark_v5.png"];
                [button setImage:image forState:UIControlStateNormal];
                button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            }
            else {//批注现在不要，将来会要，先不删除
                
                [button setTitle:@"批注" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
                UIImage *image = [UIImage imageStoryNamed:@"icofiction_postil_v5.png"];
                [button setImage:image forState:UIControlStateNormal];
                button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            }
            
            [self.naviBarImageView addSubview:button];
        }
    }
}

#pragma mark 底部导航栏
-(void)addBottomBar
{
    SNStoryBottomToolbar *bottomBar = [[SNStoryBottomToolbar alloc] initWithFrame:CGRectMake(StoryBottomToolbarLeftOffset, View_Height - CatelogBottomBarHeight, View_Width, CatelogBottomBarHeight)];
    [self.view addSubview:bottomBar];
    self.bottomBar = bottomBar;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(StoryBottomToolbar_LeftBtnLeftOffset, StoryBottomToolbar_LeftBtnTopOffset, StoryBottomToolbar_LeftBtnWidth, StoryBottomToolbar_LeftBtnHeight)];
    [leftButton setImage:[UIImage imageStoryNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    leftButton.tag = 3256;
    [leftButton setImage:[UIImage imageStoryNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(storyPopViewController:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [bottomBar addSubview:leftButton];
    
}

#pragma mark 目录 标签 批注 排序事件处理
-(void)btnCatalog:(UIButton *)button
{
    for (int i=0; i<2; i++) {
        UIButton *btn = [self.naviBarImageView viewWithTag:(3000+i)];
        
        [btn setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
        if (i == 0) {
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_catalog_v5.png"];
            [btn setImage:image forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
        }else if(i == 1) {
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_bookmark_v5.png"];
            [btn setImage:image forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
        }
        else {//批注现在不要，将来会要，先不删除
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_postil_v5.png"];
            [btn setImage:image forState:UIControlStateNormal];
            btn.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
        }
        btn.selected = NO;
    }
    
    switch (button.tag - 3000) {
        case 0:
        {
            [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
            button.selected = YES;
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_catalogpress_v5.png"];
            [button setImage:image forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            self.catelogBtnType = CATELOG;
            [self chapterHasReadWithNovelId:self.novelId book:self.book];
        }
            break;
            
        case 1:
        {
            [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
            button.selected = YES;
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_bookmarkpress_v5.png"];
            [button setImage:image forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            self.catelogBtnType = CATELOG_BOOKMARK;
            [self.catelogTableView reloadData];
        }
            break;
            
        case 2://批注现在不要，将来会要，先不删除
        {
            [button setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
            button.selected = YES;
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_postilpress_v5.png"];
            [button setImage:image forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake((CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsLeft, (CATELOGBtnHeight - image.size.height)/2, CATELOGBtnImageEdgeInsetsRight);
            self.catelogBtnType = CATELOG_BOOKNOTE;
            [self.catelogTableView reloadData];
        }
            break;
            
        case 3://排序
        {
            [self.chapterArry removeAllObjects];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            if (!button.isSelected) {
                
                button.selected = !button.isSelected;
                [userDefault setObject:@"1" forKey:@"storyCatelogSort"];
            }
            else
            {
                button.selected = !button.isSelected;
                [userDefault setObject:@"0" forKey:@"storyCatelogSort"];
            }
            
            NSString *isAsc = [userDefault objectForKey:@"storyCatelogSort"];
            BOOL isSort = YES;
            if ([isAsc isEqualToString:@"1"]) {
                isSort = NO;
            }
            self.chapterArry = [[ChapterList fecthBookChapterListByBookId:self.novelId chapterId:0 ascending:isSort]mutableCopy];
            [self.catelogTableView reloadData];
            [self.catelogTableView scrollToTop:NO];
            break;
        }
        default:
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.catelogType == StoryCateLogFromH5Detail) {//详情页进入
        if (!self.chapterArry || self.chapterArry.count <= 0) {
            if (!self.isReload) {
                return 0;
            }
            return 1;
        } else {
            return self.chapterArry.count;
        }
    } else {
        
        if (self.catelogBtnType == CATELOG) {//目录
            if (!self.chapterArry || self.chapterArry.count <= 0) {
                if (!self.isReload) {
                    return 0;
                }
                return 1;
            } else {
                return self.chapterArry.count;
            }
        } else if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
            
            if (!self.bookMarkArry || self.bookMarkArry.count <= 0) {
                
                return 1;
            } else {
                return self.bookMarkArry.count;
            }
            
        }
        else//批注
        {
            if (!self.bookNoteArry || self.bookNoteArry.count <= 0) {
                return 1;
            } else {
                 return self.bookNoteArry.count;
            }
           
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.catelogType == StoryCateLogFromH5Detail) {//详情页进入
        if (!self.chapterArry || self.chapterArry.count <= 0) {
            return self.catelogTableView.height;
        } else {
            return [UIFont systemFontOfSize:16].lineHeight + 21;
        }
    } else {
        
        if (self.catelogBtnType == CATELOG) {//目录
            if (!self.chapterArry || self.chapterArry.count <= 0) {
                return self.catelogTableView.height;
            } else {
                return [UIFont systemFontOfSize:16].lineHeight + 21;
            }

        } else if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
            
            if (!self.bookMarkArry || self.bookMarkArry.count <= 0) {
                return self.catelogTableView.height;
            } else {
                return [SNStoryBookMarkAndNoteModel getBookMarkCellHeight];
            }
        }
        else//批注
        {
            if (!self.bookNoteArry || self.bookNoteArry.count <= 0) {
                
                return self.catelogTableView.height;
            } else {
                return [SNStoryBookMarkAndNoteModel getBookNoteCellHeight];
            }
        }
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *storyCatelogCellIdentifier = @"storyCatelogCell";
    static NSString *bookMarkCellIdentifier = @"bookMarkCell";
    static NSString *bookNoteCellIdentifier = @"bookNoteCell";
    
    if (self.catelogType == StoryCateLogFromH5Detail) {//详情页进入
        if (!self.chapterArry || self.chapterArry.count <= 0) {
            static NSString *bookNoMarkCellIdentifier = @"bookNoChapterCell";
            SNStoryBookMarkDataCell *cell = [tableView dequeueReusableCellWithIdentifier:bookNoMarkCellIdentifier];
            if (!cell) {
                cell = [[SNStoryBookMarkDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookNoMarkCellIdentifier bookTab:StoryBookNoDataTabChapter];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.refreshChapter = ^{
                //书籍详情、列表详情请求
                [self novelDetail];
            };
            return cell;
        }else{
            SNStoryCatelogCell *cell = [tableView dequeueReusableCellWithIdentifier:storyCatelogCellIdentifier];
            if (!cell) {
                cell = [[SNStoryCatelogCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:storyCatelogCellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell storyCatelogCellWithModel:self.chapterArry indexPath:indexPath];
            return cell;
        }
    } else {
        
        if (self.catelogBtnType == CATELOG) {//目录
            
            if (!self.chapterArry || self.chapterArry.count <= 0) {
                static NSString *bookNoMarkCellIdentifier = @"bookNoChapterCell";
                SNStoryBookMarkDataCell *cell = [tableView dequeueReusableCellWithIdentifier:bookNoMarkCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryBookMarkDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookNoMarkCellIdentifier bookTab:StoryBookNoDataTabChapter];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.refreshChapter = ^{
                    //书籍详情、列表详情请求
                    [self novelDetail];
                };
                return cell;
            }else{
                SNStoryCatelogCell *cell = [tableView dequeueReusableCellWithIdentifier:storyCatelogCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryCatelogCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:storyCatelogCellIdentifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell storyCatelogCellWithModel:self.chapterArry indexPath:indexPath];
                return cell;
            }
            
        } else if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
            
            if (!self.bookMarkArry || self.bookMarkArry.count <= 0) {//无书签
                static NSString *bookNoMarkCellIdentifier = @"bookNoMarkCell";
                SNStoryBookMarkDataCell *cell = [tableView dequeueReusableCellWithIdentifier:bookNoMarkCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryBookMarkDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookNoMarkCellIdentifier bookTab:StoryBookNoDataTabMark];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                SNStoryBookMarkAndNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:bookMarkCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryBookMarkAndNoteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookMarkCellIdentifier];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell storyBookMarkCellWithModel:self.bookMarkArry indexPath:indexPath isBookMark:YES];
                return cell;
            }
            
        }
        else//批注
        {
            if (!self.bookNoteArry || self.bookNoteArry.count <= 0) {//无批注
                static NSString *bookNoNoteCellIdentifier = @"bookNoNoteCell";
                SNStoryBookMarkDataCell *cell = [tableView dequeueReusableCellWithIdentifier:bookNoNoteCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryBookMarkDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookNoNoteCellIdentifier bookTab:StoryBookNoDataTabTip];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                
            } else {
                SNStoryBookMarkAndNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:bookNoteCellIdentifier];
                if (!cell) {
                    cell = [[SNStoryBookMarkAndNoteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bookNoteCellIdentifier];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell storyBookMarkCellWithModel:self.bookNoteArry indexPath:indexPath isBookMark:NO];
                return cell;
            }
            
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.catelogType == StoryCateLogFromH5Detail) {
        if (!self.chapterArry || self.chapterArry.count <= 0) {
            [self novelDetail];
            return;
        }
        
        NSInteger chapterIndex = indexPath.row;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *isAsc = [userDefault objectForKey:@"storyCatelogSort"];
        if ([isAsc isEqualToString:@"1"]) {
            chapterIndex = self.chapterArry.count - indexPath.row - 1;
        }
        
        SNStoryPageViewController *pageController = [[SNStoryPageViewController alloc]init];
        pageController.chapterIndex = chapterIndex;
        pageController.novelId = self.novelId;
        pageController.pageType = StoryPageFromH5Catelaog;//详情页目录进入
        [SNStoryUtility pushViewController:pageController animated:YES];
        
        //埋点统计
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=4&bookId=%@", self.novelId]];
    } else {
        
        if (self.catelogBtnType == CATELOG) {//目录
            if (!self.chapterArry || self.chapterArry.count <= 0) {
                [self novelDetail];
                return;
            }
            
            [SNStoryUtility popViewControllerAnimated:YES];
            
            if ([self.delegate respondsToSelector:@selector(storyCatelogIntoPageWithIndex:chapterArray:)]) {
                
                NSInteger chapterIndex = indexPath.row;
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSString *isAsc = [userDefault objectForKey:@"storyCatelogSort"];
                if ([isAsc isEqualToString:@"1"]) {
                    chapterIndex = self.chapterArry.count - indexPath.row - 1;
                }
                
                [self.delegate storyCatelogIntoPageWithIndex:chapterIndex chapterArray:self.chapterArry];
            }
            
            //5  阅读页-目录点击
            [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=5&bookId=%@",self.novelId]];
        } else if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
            if (self.bookMarkArry.count > indexPath.row) {
                
                [SNStoryUtility popViewControllerAnimated:YES];
                SNStoryBookMarkAndNoteModel * bookMark = [self.bookMarkArry objectAtIndex:indexPath.row];
                if ([self.delegate respondsToSelector:@selector(gotoBookMarkPageWith:chapterArray:)]) {
                    [self.delegate gotoBookMarkPageWith:bookMark chapterArray:self.chapterArry];
                }
                
                //书签进入埋点
                [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=6&bookId=%@",self.novelId]];//6 阅读页-点击“书签”tab内某书签
            }
            return;
        }
        else//批注
        {
            //7  阅读页-点击“批注”tab内某批注的；
            //[StoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=7&bookId=%@",self.novelId]];
            return;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
        if (self.bookMarkArry.count > 0) {
            return YES;
        } else {
            return NO;
        }
    }else{
        return NO;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
        
        if (self.bookMarkArry.count > 0) {
             return @"删除书签";
        } else {
             return @"";
        }
    }else {
        return @"";
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.catelogBtnType == CATELOG_BOOKMARK) {//书签
        if (self.bookMarkArry.count == 0) {
            return;
        }
        SNStoryBookMarkAndNoteModel * bookMarkModel = [self.bookMarkArry objectAtIndex:indexPath.row];
        
        [SNBookMarkViewModel cancelBookMark:bookMarkModel completed:^(BOOL success, id completedInfo) {
            if (success) {
                // 从数据源中删除
                [self.bookMarkArry removeObjectAtIndex:indexPath.row];
                if (self.bookMarkArry.count == 0) {
                    [tableView reloadData];
                }else{
                    // 从列表中删除
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
