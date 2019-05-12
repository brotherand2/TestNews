//
//  SNStoryPage.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PageOriginX      19.0
#define PageOriginY      75.0
#define PageWidth        (View_Width - PageOriginX*2)
#define PageHeight       (View_Height - PageOriginY)

typedef enum
{
    StoryOriginPageView = 0,//初始页
    StoryBforePageView,//向前翻页
    StoryAfterPageView//向后翻页
}StoryScrollType;

typedef enum
{
    StoryNeedRefresh = 0,//刷新
    StoryNormalPage//正常请求，不刷新
}StoryPageClearCacheType;

typedef enum
{
    StoryNormalPageView = 0,//正常阅读页面
    StoryPayPageView,//付费页面
    StoryGetPageNONet,//无网络
    StoryGetPageFailedView,//章节获取失败页面
    StoryPuschaseDownloadView//刚购买过,需要下载的章节页
}StoryPageType;


@class SNStoryContentController;
@class SNStoryChapter;
@class SNStoryPageViewController;
@class StoryBookShelfList;

//小说专用数据
@class ChapterList;


@interface SNStoryPage : NSObject

+(float)getLineHeightWithFont:(UIFont *)font;//行高
+(float)getLineSpace;//行间距
+(float)getparagraphSpace;//段间距

+(UIColor *)getReadBackgroundColor;//获取阅读背景色
+(void)setReadBackgroundColorWithColorStr:(NSString*)colorStr;//设置阅读背景色

/**
 *   书籍信息请求
 *   addBookSelf 0:未加入书架  1:加入书架
 */
+(void)storyDetailRequestWithBookId:(NSString *)bookId pageTye:(StoryPageClearCacheType)pageTye completeBlock:(void(^)(id result))completeBlock;

/**
 *   章节列表请求
 *   可以控制请求的章节数
 *   startChapterId:章节起始位置
 *   chapterCount:需要查的章节数，一般传最大值，一次全部请求
 */
+(void)storyChapterListRequestWithBookId:(NSString *)bookId startChapterId:(NSString *)startChapterId chapterCount:(NSString *)chapterCount completeBlock:(void(^)(id result))completeBlock;//小说请求ur

/**
 *    章节内容请求
 *    @function 可以控制请求的章节数
 *    startChapterId:章节起始位置
 *    chapterCount:需要查的章节数
 */
+(void)storyChapterContentRequestWithBookId:(NSString *)bookId pageViewController:(SNStoryPageViewController *)pageViewController startChapterId:(NSString *)startChapterId chapterCount:(NSString *)chapterCount completeBlock:(void(^)(id result))completeBlock;//小说请求ur

/**
 *    购买章节请求
 *    @function 可以控制请求的章节数
 *    startChapterId:章节起始位置
 *    chapterCount:购买的章节数
 *    payType 1:支付宝  2:微信
 */
+(void)purchaseChapterContentRequestWithBookId:(NSString *)bookId startChapterId:(NSString *)startChapterId chapterCount:(NSString *)chapterCount payType:(NSString *)payType completeBlock:(void(^)(id result))completeBlock;//小说请求ur

/**
 *    可读章节下载
 *    @function 可以控制请求的章节数
 *    chapterIds:章节起始位置
 *    chapterCount:需要查的章节数
 */
+(void)downloadAvailableChapterContentRequestWithBookId:(NSString *)bookId pageViewController:(SNStoryPageViewController *)pageViewController chapterIds:(NSString *)chapterIds completeBlock:(void(^)(id result))completeBlock;

/**
 *    小说热词搜索
 *    @function 可以控制请求的章节数
 *    searchDic:扩张使用，目前传nil
 *
 */
+(void)novelHotWordsSearchDic:(NSDictionary *)searchDic completeBlock:(void(^)(id result))completeBlock;

/**
 *    小说阅读锚点上报
 *    @function 可以控制请求的章节数
 *    searchDic:扩张使用，目前传nil
 *
 */
+(void)novelAdd_AnchorDic:(NSDictionary *)requestDic completeBlock:(void(^)(id result))completeBlock;

/**
 *    小说阅读锚点获取
 *    @function 可以控制请求的章节数
 *    searchDic:扩张使用，目前传nil
 *
 */
+(void)novelGet_AnchorDic:(NSDictionary *)requestDic completeBlock:(void(^)(id result))completeBlock;

/**
 *    解密章节内容
 */
+(NSString *)decryContentWithStr:(NSString *)str key:(NSString *)key;

/**
 *    计算章节分页
 */
+(NSMutableArray *)getPageCountWithStr:(NSString *)str font:(UIFont *)font;

/**
 *    初始化章节
 */
+(SNStoryChapter *)initChapterWithPageViewController:(SNStoryPageViewController *)pageViewController chapterIndex:(NSInteger)chapterIndex font:(UIFont *)font;

/**
 *    获取每一页
 */
+ (SNStoryContentController *)viewControllerWithChapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex pageViewController:(SNStoryPageViewController *)pageViewController font:(UIFont *)font storyScrollType:(StoryScrollType)storyScrollType;

/**
 *    根据偏移量获取页码
 */
+(NSInteger)getPageNumFromPageOffsetWithPageOffset:(NSInteger)pageOffset storyChapter:(SNStoryChapter *)storyChapter;
/*
 *   删除某本书
 */
+(void)removeBookInfoAndChaptersByBookId:(NSString*)bookId;

/*
 *   插入书架书籍
 */
+(void)insertBookShelfListWithArray:(NSArray *)array;

/*
 *   查询书架某本书籍
 */
+(StoryBookShelfList *)fecthBookShelfListByBookId:(NSString *)bookId;

//小说专用数据
+(NSString *)getContentWithModel:(SNStoryChapter *)model
                     currentIndex:(NSInteger)currentIndex;//获取某一页的内容
@end
