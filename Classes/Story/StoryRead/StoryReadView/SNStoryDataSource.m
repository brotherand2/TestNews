//
//  SNStoryDataSource.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryDataSource.h"
#import "ChapterList.h"
#import "StoryBookList.h"
#import "SNStoryPage.h"
#import "SNStoryChapter.h"
#import "SNStoryAesEncryptDecrypt.h"
#import "SHCoreDataHelper.h"

@interface SNStoryDataSource ()

@end

@implementation SNStoryDataSource

+(SNStoryDataSource *)sharedInstance
{
    static SNStoryDataSource *storyChapter= nil;
    static dispatch_once_t once_t;
    if (!storyChapter) {
        
        dispatch_once(&once_t, ^{
            
            storyChapter = [SNStoryDataSource new];
            storyChapter.availableChapterArray = [NSMutableArray array];
            storyChapter.chapterCacheDic = [NSMutableDictionary dictionary];
            storyChapter.payArray = [NSMutableArray array];
            storyChapter.bookCacheDic = [NSMutableDictionary dictionary];
            storyChapter.isAscending = YES;
        });
    }
    
    return storyChapter;
}

-(void)initPageArrayWithNovelId:(NSString *)novelId chapterId:(NSInteger)chapterId font:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    
    if (![self.novelId isEqualToString:novelId] ||
        self.chapterCacheDic.count <= 0 ||
        self.chapterArray.count <= 0) {
        
        self.novelId = novelId;
        //第一次启动需要从数据库读取
        StoryBookList *book = [StoryBookList fecthBookByBookIdByUsingCoreData:novelId];
        if (book) {
            //TODO:需要保存？
            self.bookTitle = book.bookTitle;
        }
        
        NSArray *chapters = [ChapterList fecthBookChapterListByBookId:novelId chapterId:0 ascending:self.isAscending];
        
        if (self.chapterArray && self.chapterArray.count > 0) {
            [self.chapterArray removeAllObjects];
            if (chapters) {
                [self.chapterArray addObjectsFromArray:chapters];
            }
            
        } else {
            self.chapterArray = [chapters mutableCopy];
        }
    }
    
    NSInteger chapterCount = self.chapterArray.count;
    
    if (chapterCount <= 0) {
        return;
    }
    
    if (chapterId > 0) {//修改某一章节
        
        NSArray *array = [[ChapterList fecthBookChapterListByBookId:novelId chapterId:chapterId ascending:self.isAscending]copy];
        NSInteger chpterUpdateCount = array.count;
        
        for (int i = 0; i < chpterUpdateCount; i++) {
            
            ChapterList *chapter = array[i];
            if (chapter.chapterId == chapterId) {
                
                [self cacheChapterWithFont:font chapter:chapter];
                break;
            }
            
        }
        
    } else {//初始化所有章节
        
        if (self.chapterCacheDic.count > 0 && [self.novelId isEqualToString:novelId]) {//同一个novelId，有内容，表示已缓存，不用再次缓存
            return;
        }
        
        if (chapterCount > 5) {//大于10章异步处理
            
            for (int i = 0; i < 5; i++) {//先算10章，其余章节异步处理
                
                ChapterList *chapter  = self.chapterArray[i];
                [self cacheChapterWithFont:font chapter:chapter];
            }
            
            dispatch_queue_t queue = dispatch_queue_create("storyCacheChapter", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue, ^{
                
                NSInteger count = self.chapterArray.count;
                for (int i = 5; i < count; i++) {
                    
                    ChapterList *chapter  = self.chapterArray[i];
                    [self cacheChapterWithFont:font chapter:chapter];
                }
                
            });
            
        } else {
            
            for (int i = 0; i < chapterCount; i++) {
                ChapterList *chapter  = self.chapterArray[i];
                [self cacheChapterWithFont:font chapter:chapter];
            }
        }
        
        //处理可读章节
        dispatch_queue_t queue = dispatch_queue_create("storyAvailableChapter", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            
            NSInteger count = self.chapterArray.count;
            for (int i = 0; i < count; i++) {
                
                ChapterList *chapter = self.chapterArray[i];
                if (chapter.isfree && !chapter.isDownload) {
                    
                    [self.availableChapterArray addObject:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
                }
                else if(!chapter.isfree){
                    
                    [self.payArray addObject:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
                }
            }
            
        });
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
    model.isDownload = chapter.isDownload;
    model.chapterContent =[SNStoryPage decryContentWithStr:chapter.chapterContent key:chapter.chapterKey];
    model.chapterPageArray = [SNStoryPage getPageCountWithStr:model.chapterContent font:font];
    
    [self.chapterCacheDic setObject:model forKey:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
}

-(void)updatePageArrayWithChapterId:(NSInteger)chapterId isDispatch:(BOOL)isDispatch font:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    if (isDispatch) {
        
        [self updateFontWithFont:font chapterIndex:chapterIndex];
        
        dispatch_queue_t queue = dispatch_queue_create("storyChapter", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            
            for (int i = 0; i <= (chapterIndex - 1); i++) {
                
               [self updateFontWithFont:font chapterIndex:chapterIndex];
            }
            
        });
    } else {
        
        [self updateFontWithFont:font chapterIndex:chapterIndex];
    }
}

-(void)updateFontWithFont:(UIFont *)font chapterIndex:(NSInteger)chapterIndex
{
    ChapterList *chapter = self.chapterArray[chapterIndex];
    SNStoryChapter *tempModel = [self.chapterCacheDic objectForKey:[NSString stringWithFormat:@"%ld",chapter.chapterId]];
    tempModel.chapterPageArray = [SNStoryPage getPageCountWithStr:tempModel.chapterContent font:font];
}

-(NSString *)getContentWithModel:(SNStoryChapter *)model currentIndex:(NSInteger)currentIndex
{
    NSString *pstr = [model.chapterPageArray objectAtIndex:currentIndex];
    NSArray *array = [pstr componentsSeparatedByString:@"_"];
    NSRange range = NSMakeRange([[array firstObject]integerValue], [[array lastObject]integerValue]);
    if ((range.location + range.length) > model.chapterContent.length) {
        return @"";
    }
    else
    {
        NSString *contentStr = [model.chapterContent substringWithRange:range];
        return contentStr;
    }
}

-(void)removeCacheChapterWithNovelId:(NSString *)novelId
{
    if ([self.novelId isEqualToString:novelId]) {
        SNStoryDataSource *storyDataSource = [SNStoryDataSource sharedInstance];
        [storyDataSource.availableChapterArray removeAllObjects];
        [storyDataSource.availableChapterArray removeAllObjects];
        [storyDataSource.chapterCacheDic removeObjectForKey:novelId];
        [storyDataSource.payArray removeAllObjects];
        self.novelId =nil;
    }
}

-(NSMutableArray *)payChapters
{
    return self.payArray;
}

- (StoryBookList *)getBookInfo:(NSString *)bookID {
    if (self.book && [self.book.bookId isEqualToString:bookID]) {
        return self.book;
    }
    return nil;
}

@end
