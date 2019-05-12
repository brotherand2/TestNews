//
//  SNStoryDataSource.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNStoryChapter;
@class ChapterList;
@class StoryBookList;

@interface SNStoryDataSource : NSObject
@property (nonatomic, strong) NSString *bookTitle;
@property (nonatomic, strong) NSMutableArray *chapterArray;//章节总数
@property (nonatomic, strong) NSString *novelId;
@property (nonatomic, strong) NSMutableArray *availableChapterArray;//可读章节
@property (nonatomic, strong) NSMutableDictionary *chapterCacheDic;//缓存欲读章节
@property (nonatomic, strong) NSMutableDictionary *bookCacheDic;//书籍存入内存
@property (nonatomic, strong) NSMutableArray *payArray;//付费章节
@property (nonatomic, assign) BOOL isAscending;//是否升序

@property (nonatomic, strong) StoryBookList *book;

+ (SNStoryDataSource *)sharedInstance;
- (void)initPageArrayWithNovelId:(NSString *)novelId
                       chapterId:(NSInteger)chapterId
                            font:(UIFont *)font
                    chapterIndex:(NSInteger)chapterIndex;//初始化章节信息

- (void)updatePageArrayWithChapterId:(NSInteger)chapterId
                          isDispatch:(BOOL)isDispatch
                                font:(UIFont *)font
                        chapterIndex:(NSInteger)chapterIndex;//改变字号，重新计算页码

- (void)cacheChapterWithFont:(UIFont *)font
                     chapter:(ChapterList *)chapter;//缓存章节内容，存于内存

- (NSString *)getContentWithModel:(SNStoryChapter *)model
                     currentIndex:(NSInteger)currentIndex;//获取某一页的内容
- (void)removeCacheChapterWithNovelId:(NSString *)novelId;//删除书籍，同时，删除缓存
- (NSMutableArray *)payChapters;//获取付费章节

- (StoryBookList *)getBookInfo:(NSString *)bookID;

@end

