//
//  SNStoryPage.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryPage.h"
#import "SNStoryPageViewController.h"
#import "StoryBookList.h"
#import "StoryBookShelfList.h"
#import "SNStoryChapter.h"
#import "ChapterList.h"
#import "SNStoryUtility.h"
#import <CoreText/CoreText.h>
#import "SNStoryContanst.h"
#import "SNStoryAesEncryptDecrypt.h"
#import "SNStoryRSA.h"
#import "StoryBookAnchor.h"

//网络请求
#import "SNStoryRequest.h"

#define MAX_CHAPTER_COUNT 2000

@implementation SNStoryPage

+ (SNStoryContentController *)viewControllerWithChapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex pageViewController:(SNStoryPageViewController *)pageViewController font:(UIFont *)font storyScrollType:(StoryScrollType)storyScrollType{
    
    //创建一个新的控制器类，并且分配给相应的数据
    SNStoryContentController *contentController = [[SNStoryContentController alloc] init];
    contentController.cur_font = font;
    contentController.novelId = pageViewController.novelId;
    contentController.pageViewController = pageViewController;
    NSInteger chpterCount = pageViewController.chapterArray.count;
    if (chapterIndex >= chpterCount) {
        //以前是contentController赋值为nil，但是，章节列表为空，就是空白页，因此改成这样
        contentController.chapterType = StoryGetPageFailedView;
        contentController.content = @"";
        //contentController = nil;
    }
    else
    {
        SNStoryChapter *tempModel = [SNStoryPage initChapterWithPageViewController:pageViewController chapterIndex:chapterIndex font:font];
        
        NSInteger tempChapterIndex = chapterIndex;
        NSInteger count = tempModel.chapterPageArray.count;
        if (storyScrollType == StoryAfterPageView) {
            
            pageIndex = pageIndex + 1;
            contentController.storyScrollType = StoryAfterPageView;
            
            if (pageIndex >= count && chapterIndex < (chpterCount - 1)) {
                
                pageIndex = 0;
                tempChapterIndex = tempChapterIndex + 1;
            }else if(pageIndex >= count && chapterIndex >= (chpterCount-1)){
                
                return nil;
            }else{
                
                //不作任何处理
            }
            
        } else if(storyScrollType == StoryBforePageView){
            
            pageIndex = pageIndex - 1;
            contentController.storyScrollType = StoryBforePageView;
            
            if (pageIndex < 0 && chapterIndex > 0) {
                
                pageIndex = 0;
                tempChapterIndex = tempChapterIndex - 1;
                chapterIndex = tempChapterIndex;
                tempModel = [SNStoryPage initChapterWithPageViewController:pageViewController chapterIndex:chapterIndex font:font];
                NSUInteger count = tempModel.chapterPageArray.count;
                if (count > 0) {
                    pageIndex = count - 1;
                }
                
            }else if(pageIndex < 0 && chapterIndex <= 0){
                
                return nil;
            }else{
                
                //不作任何处理
            }
        }
        else
        {
            contentController.storyScrollType = StoryOriginPageView;
        }
        
        if (tempChapterIndex != chapterIndex) {
            chapterIndex = tempChapterIndex;
            tempModel = [SNStoryPage initChapterWithPageViewController:pageViewController chapterIndex:chapterIndex font:font];
        }
        
        contentController.chapterIndex = chapterIndex;
        contentController.pageNum = pageIndex;
        
        if (tempModel) {
            if (tempModel.isFree || tempModel.hasPaid) {
                
                if (tempModel.chapterContent && tempModel.chapterContent.length > 0) {
                    
                    if (!tempModel.isDownload) {
                        contentController.chapterType = StoryPuschaseDownloadView;
                        NSString *chapterIdStr = [NSString stringWithFormat:@"%ld",tempModel.chapterId];
                        [pageViewController.chapterCacheDic removeObjectForKey:chapterIdStr];
                    } else {
                        contentController.chapterType = StoryNormalPageView;
                    }
                } else {
                    
                    if ([SNStoryUtility currentReachabilityStatusForStory] ==StoryNetworkReachabilityStatusNotReachable) {
                        contentController.chapterType = StoryGetPageNONet;
                    } else {
                        contentController.chapterType = StoryGetPageFailedView;
                    }
                }
            } else {
                
                contentController.chapterType = StoryPayPageView;
            }
        } else {
            if ([SNStoryUtility currentReachabilityStatusForStory] ==StoryNetworkReachabilityStatusNotReachable) {
                contentController.chapterType = StoryGetPageNONet;
            } else {
                contentController.chapterType = StoryGetPageFailedView;
            }
        }
        
        if (tempModel.chapterPageArray && tempModel.chapterPageArray.count > 0 && pageIndex < tempModel.chapterPageArray.count) {
            NSString *pstr = [tempModel.chapterPageArray objectAtIndex:pageIndex];
            NSArray *array = [pstr componentsSeparatedByString:@"_"];
            NSRange range = NSMakeRange([[array firstObject]integerValue], [[array lastObject]integerValue]);
            if ((range.location + range.length) > tempModel.chapterContent.length) {
                contentController = nil;
            }
            else {
                NSString *contentStr = [tempModel.chapterContent substringWithRange:range];
                contentController.content = contentStr;
            }
            
        } else {
            contentController.content = @"";
        }
    }
    
    return contentController;
}

+(SNStoryChapter *)initChapterWithPageViewController:(SNStoryPageViewController *)pageViewController chapterIndex:(NSInteger)chapterIndex font:(UIFont *)font
{
    NSInteger chapterId = 1;
    if (pageViewController.chapterArray.count > 0) {
        ChapterList *chapter = pageViewController.chapterArray[chapterIndex];
        chapterId = chapter.chapterId;
    }
    
    NSString *chapterIdStr = [NSString stringWithFormat:@"%ld",chapterId];
    SNStoryChapter *tempModel = [pageViewController.chapterCacheDic objectForKey:chapterIdStr];
    
    if (!tempModel || tempModel.chapterContent.length <= 0) {
        
        [pageViewController initPageArrayWithNovelId:pageViewController.novelId chapterId:chapterId font:font chapterIndex:chapterIndex];
         tempModel = [pageViewController.chapterCacheDic objectForKey:chapterIdStr];
    }
    
    return tempModel;
}

+(NSInteger)getPageNumFromPageOffsetWithPageOffset:(NSInteger)pageOffset storyChapter:(SNStoryChapter *)storyChapter
{
    NSInteger storyChapterPageCount = storyChapter.chapterPageArray.count;
    
    if (storyChapter.chapterPageArray && storyChapterPageCount > 0) {
        
        NSInteger tempChapterPageNum = -1;
        for (NSString *pageNumOffsetStr in storyChapter.chapterPageArray) {
            
            tempChapterPageNum++;
            NSArray *pageNumOffsetArray = [pageNumOffsetStr componentsSeparatedByString:@"_"];
            
            if (pageNumOffsetArray.count > 1) {
                
                NSInteger startOffset = [[pageNumOffsetArray firstObject]integerValue];
                NSInteger endOffset = [[pageNumOffsetArray lastObject]integerValue];
                
                if (pageOffset > startOffset && pageOffset <= (startOffset + endOffset)) {
                    return tempChapterPageNum;
                }
            }
        }
    }
    
    return 0;
}

+(float)getLineHeightWithFont:(UIFont *)font
{
    return font.lineHeight;
}

+(float)getLineSpace
{
    return 8;
}

+(float)getparagraphSpace
{
    return 20;
}

#pragma marl 获取阅读背景色
+(UIColor *)getReadBackgroundColor
{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *colorStr = [userDefault objectForKey:@"readBackgroundColor"];
    if (!colorStr || colorStr.length <= 0) {
        colorStr = StoryReadBackgroundColor1;
    }
    return [UIColor storyColorFromString:colorStr];
}

#pragma marl 设置阅读背景色
+(void)setReadBackgroundColorWithColorStr:(NSString*)colorStr
{
    if (!colorStr || colorStr.length <= 0) {
        colorStr = StoryReadBackgroundColor1;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:colorStr forKey:@"readBackgroundColor"];
    [userDefault synchronize];
}

+ (void)storyDetailRequestWithBookId:(NSString *)bookId pageTye:(StoryPageClearCacheType)pageTye completeBlock:(void (^)(id))completeBlock
{
    if (!bookId) {
        return;
    }
    
    NSDictionary * dic= @{@"oid" : bookId};
    SNStoryDetailRequest *detailRequest = [[SNStoryDetailRequest alloc]initWithDictionary:dic];
    [detailRequest send:^(SNBaseRequest *request, id responseObject) {
        NSMutableDictionary *novelDetailDic = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                novelDetailDic = [[[dic objectForKey:@"data"] objectForKey:@"content"] mutableCopy];
                if (!novelDetailDic) {
                    NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"0", @"isBookDetail":@"1"};
                    if (completeBlock) {
                        completeBlock(postDic);
                    }
                } else {
                    if ([[dic objectForKey:@"data"] objectForKey:@"isAddBookShelf"]) {
                        [novelDetailDic setObject:[NSString stringWithFormat:@"%ld", [[[dic objectForKey:@"data"]objectForKey:@"isAddBookShelf"] integerValue]] forKey:@"addBookSelf"];
                    }
                    
                    //已下载存章节数
                    NSArray *chapterArray = [ChapterList fecthBookChapterListByBookId:bookId chapterId:0 ascending:YES];
                    NSInteger chapterCount = chapterArray.count;
                    
                    //书籍信息
                    NSInteger maxChapterCount = [[novelDetailDic objectForKey:@"maxChapters"]integerValue];
                    StoryBookList *book = [StoryBookList fecthBookByBookIdByUsingCoreData:bookId];
                    
                    if (!book || (!chapterArray || chapterCount <= 0 || chapterCount != maxChapterCount) || pageTye == StoryNeedRefresh) {
                        //接口有时候忘记清缓存，造成tail.go接口返回的maxChapterCount为0，坑用户，因此加一个补丁
                        if (maxChapterCount <= 0) {
                            
                            if (book.maxChapters <= 0) {
                                maxChapterCount = MAX_CHAPTER_COUNT;

                            } else {
                                maxChapterCount = book.maxChapters;
                            }
                        }
                        else
                        {
                            //第一次或连载小说有更新时，刷新
                            [StoryBookList insertBookInfoWithDic:novelDetailDic bookId:bookId];
                        }
                        
                        NSString *maxChapters = [NSString stringWithFormat:@"%ld",maxChapterCount];
                        [SNStoryPage storyChapterListRequestWithBookId:bookId startChapterId:@"1" chapterCount:maxChapters completeBlock:^(id result) {
                            
                            if ([result isKindOfClass:[NSDictionary class]]) {//接口有时候忘记清缓存，造成tail.go接口返回的maxChapterCount为0，坑用户，因此加一个补丁
                                NSDictionary *resultDic = result;
                                NSString *maxChapters = [resultDic objectForKey:@"maxChapters"];
                                if (maxChapters && (maxChapterCount != [maxChapters integerValue])) {
                                    //第一次或连载小说有更新时，刷新
                                    [novelDetailDic setObject:maxChapters forKey:@"maxChapters"];
                                    [StoryBookList insertBookInfoWithDic:novelDetailDic bookId:bookId];
                                }
                            }
                            
                            if (completeBlock) {
                                completeBlock(result);
                            }
                        }];
                    }else
                    {
                        NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"1", @"isBookDetail":@"1"};
                        if (completeBlock) {
                            completeBlock(postDic);
                        }
                    }
                    
                }
            } else {
                NSDictionary *postDic = @{@"statusMsg" : [dic objectForKey:@"statusMsg"], @"isSuccess":@"0", @"isBookDetail" : @"1"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            }
        } else {
            NSDictionary *postDic = @{@"statusMsg":@"返回数据格式不对",@"isSuccess":@"0", @"isBookDetail":@"1"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        NSDictionary *postDic = @{@"statusMsg":@"网络请求失败",@"isSuccess":@"0", @"isBookDetail":@"1"};
        if (completeBlock) {
            completeBlock(postDic);
        }
    }];
}

+ (void)storyChapterListRequestWithBookId:(NSString *)bookId
                           startChapterId:(NSString *)startChapterId
                             chapterCount:(NSString *)chapterCount
                            completeBlock:(void(^)(id result))completeBlock {
    if (!bookId || !startChapterId || !chapterCount) {
        return;
    }
    
    NSInteger maxChapterCount = [chapterCount integerValue];
    if (maxChapterCount > MAX_CHAPTER_COUNT) {//服务端只能承受2000章的请求，大于2000章节，循环请求处理
        
        int count = maxChapterCount % MAX_CHAPTER_COUNT;
        int repeateCount = maxChapterCount / MAX_CHAPTER_COUNT;
        
        if (count != 0) {
            repeateCount += 1;
        }
        
        //这样处理将来是一个坑：1.章节要以200为准循环请求，说不定会某个2000章节因网络而失败
        //                  2.所有章节请求完毕，合并数据入库
        //建议章节列表做成分页请求，重新构建小说架构
        NSMutableArray *chapterArray = [NSMutableArray array];
        dispatch_queue_t queue = dispatch_queue_create("StroryChapterListRequest", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t chapterListGroup = dispatch_group_create();
        dispatch_async(queue, ^{
            for (int i = 0; i < repeateCount; i++) {
                NSString *startChapterId = [NSString stringWithFormat:@"%ld", i*MAX_CHAPTER_COUNT+1];
                int requestCount = (maxChapterCount - i*MAX_CHAPTER_COUNT);
                NSString *requestChapterCount = nil;
                if (requestCount >= MAX_CHAPTER_COUNT) {
                    requestChapterCount = [NSString stringWithFormat:@"%d",MAX_CHAPTER_COUNT];
                } else {
                    requestChapterCount = [NSString stringWithFormat:@"%ld",requestCount];
                }
                
                NSDictionary *chapterListRequestDic = @{@"bookId" : bookId,
                                                        @"startChapterId" : startChapterId
                                                        , @"chapterCount" : requestChapterCount};
                SNStoryChapterListRequest *chapterListRequest = [[SNStoryChapterListRequest alloc] initWithDictionary:chapterListRequestDic];
                
                dispatch_group_enter(chapterListGroup);
                [chapterListRequest send:^(SNBaseRequest *request, id responseObject) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dic = (NSDictionary *)responseObject;
                        if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                            NSArray *chapterList = [[dic objectForKey:@"data"]objectForKey:@"chapters"];
                            [chapterArray addObjectsFromArray:chapterList];
                            dispatch_group_leave(chapterListGroup);
                        } else {
                            dispatch_group_leave(chapterListGroup);
                        }
                    } else{
                        dispatch_group_leave(chapterListGroup);
                    }
                } failure:^(SNBaseRequest *request, NSError *error) {
                    dispatch_group_leave(chapterListGroup);
                }];
            }
            
            dispatch_group_notify(chapterListGroup, queue, ^{
                //数据库插入主线程操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (chapterArray.count > 0) {
                        NSDictionary *postDic = @{@"isSuccess":@"1", @"isBookDetail":@"0"};
                        [ChapterList insertBookChapterListWithArray:chapterArray bookId:bookId];
                        if (completeBlock) {
                            completeBlock(postDic);
                        }
                    } else {
                        NSDictionary *postDic = @{@"isSuccess":@"0", @"isBookDetail":@"0"};
                        if (completeBlock) {
                            completeBlock(postDic);
                        }
                    }
                });
            });
        });
    }else{
        //小于2000的章节请求处理
        NSDictionary * dic= @{@"bookId":bookId, @"startChapterId":startChapterId,@"chapterCount":chapterCount};
        SNStoryChapterListRequest *chapterListRequest = [[SNStoryChapterListRequest alloc]initWithDictionary:dic];
        
        [chapterListRequest send:^(SNBaseRequest *request, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dic = (NSDictionary *)responseObject;
                if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                    
                    NSArray *chapterList = [[dic objectForKey:@"data"]objectForKey:@"chapters"];
                    [ChapterList insertBookChapterListWithArray:chapterList bookId:bookId];
                    NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"maxChapters":[[dic objectForKey:@"data"]objectForKey:@"maxChapters"],@"isSuccess":@"1", @"isBookDetail":@"0"};
                    if (completeBlock) {
                        completeBlock(postDic);
                    }
                    
                } else {
                    NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"0", @"isBookDetail":@"0"};
                    if (completeBlock) {
                        completeBlock(postDic);
                    }
                }
            }
            else{
                
                NSDictionary *postDic = @{@"statusMsg":@"返回数据格式不对",@"isSuccess":@"0", @"isBookDetail":@"0"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            NSDictionary *postDic = @{@"statusMsg":@"网络请求失败",@"isSuccess":@"0", @"isBookDetail":@"0"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }];
    }
}

+(void)storyChapterContentRequestWithBookId:(NSString *)bookId pageViewController:(SNStoryPageViewController *)pageViewController startChapterId:(NSString *)startChapterId chapterCount:(NSString *)chapterCount completeBlock:(void(^)(id result))completeBlock
{
    if (!bookId || !startChapterId || !chapterCount) {
        return;
    }
    
    NSDictionary *dic=@{@"bookId":bookId, @"startChapterId":startChapterId,@"chapterCount":chapterCount};
    SNStoryChapterContentRequest *chapterContentRequest = [[SNStoryChapterContentRequest alloc]initWithDictionary:dic];
    [chapterContentRequest send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                
                NSString *novelKey = [[dic objectForKey:@"data"]objectForKey:@"k"];
                NSString *novelContent = [[dic objectForKey:@"data"]objectForKey:@"chapters"];
                
                NSString *novelKeyStr = [SNStoryRSA decryptString:novelKey publicKeyWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"public_key" ofType:@"der"]];
                
                NSData *data = [[NSData alloc] initWithBase64EncodedString:novelContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
                novelContent = [SNStoryAesEncryptDecrypt decryptData:data withKey:novelKeyStr];
                NSData *jsonData = [novelContent dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                
                if ([json isKindOfClass:[NSArray class]]) {
                    
                    NSArray *array = (NSArray*)json;
                    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
                    [contentDic setObject:novelKey?novelKey:@"" forKey:@"k"];
                    [contentDic setObject:novelKeyStr?novelKeyStr:@"" forKey:@"decryKey"];
                    [contentDic setObject:array forKey:@"chapters"];
                    
                    //更新章节内容
                    [ChapterList updateBookChapterListContentByBookId:bookId chapterDic:contentDic];
                    NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"1"};
                    if (completeBlock) {
                        completeBlock(postDic);
                    }
                    
                    //处理付费章节或可读章节
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSInteger count = array.count;
                        NSMutableArray *availableArray = pageViewController.availableChapterArray;
                        NSMutableArray *payArray = pageViewController.payArray;
                        for (int i = 0; i < count; i++) {
                            
                            id content = [array objectAtIndex:i];
                            
                            if ([content isKindOfClass:[NSDictionary class]]) {
                                NSMutableDictionary *contentDic = [((NSDictionary*)content)mutableCopy];
                                id chapterId = [contentDic objectForKey:@"chapterId"];
                                if (chapterId) {
                                    
                                    NSString *chapterIdStr = [NSString stringWithFormat:@"%ld",[chapterId integerValue]];
                                    
                                    if (availableArray.count > 0) {
                                        [availableArray removeObject:chapterIdStr];
                                    }
                                    
                                    if (payArray.count > 0) {//wcw error
                                        [payArray removeObject:chapterIdStr];
                                    }
                                    
                                }
                            }
                        }
                    });
                }
            } else {
                
                NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"0"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            }
            
        }else{
            
            NSDictionary *postDic = @{@"statusMsg":@"返回数据格式不对",@"isSuccess":@"0"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        NSDictionary *postDic = @{@"statusMsg":@"网络请求失败",@"isSuccess":@"0"};
        if (completeBlock) {
            completeBlock(postDic);
        }
    }];
}

+(void)purchaseChapterContentRequestWithBookId:(NSString *)bookId startChapterId:(NSString *)startChapterId chapterCount:(NSString *)chapterCount payType:(NSString *)payType completeBlock:(void(^)(id result))completeBlock
{
    NSDictionary * dic= @{@"bookId":bookId, @"startChapterId":startChapterId,@"chapterCount":chapterCount ,@"type":payType};
    SNStoryPurchaseChapterContentRequest *purchaseChapterRequest = [[SNStoryPurchaseChapterContentRequest alloc]initWithDictionary:dic];
    [purchaseChapterRequest send:^(SNBaseRequest *request, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *postDic = responseObject;
            if (completeBlock) {
                completeBlock(postDic);
            }
        } else {
            NSDictionary *postDic = @{@"statusMsgEn":@"failure"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        NSDictionary *postDic = @{@"statusMsgEn":@"failure"};
        if (completeBlock) {
            completeBlock(postDic);
        }
    }];
    
}

#pragma mark 可读章节下载
+(void)downloadAvailableChapterContentRequestWithBookId:(NSString *)bookId pageViewController:(SNStoryPageViewController *)pageViewController chapterIds:(NSString *)chapterIds completeBlock:(void(^)(id result))completeBlock
{
    NSDictionary * requestDic= @{@"bookId":bookId, @"chapterIds":chapterIds};
    SNStoryDownloadAvailableChapterContentRequest *downloadChapterContentRequest = [[SNStoryDownloadAvailableChapterContentRequest alloc]initWithDictionary:requestDic];
    [downloadChapterContentRequest send:^(SNBaseRequest *request, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                
                NSString *novelKey = [[dic objectForKey:@"data"]objectForKey:@"k"];
                NSString *novelContent = [[dic objectForKey:@"data"]objectForKey:@"chapters"];
                
                NSString *novelKeyStr = [SNStoryRSA decryptString:novelKey publicKeyWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"public_key" ofType:@"der"]];
                
                NSData *data = [[NSData alloc] initWithBase64EncodedString:novelContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
                novelContent = [SNStoryAesEncryptDecrypt decryptData:data withKey:novelKeyStr];
                
                NSData *jsonData = [novelContent dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
                
                if ( json && [json isKindOfClass:[NSArray class]]) {
                    
                    NSArray *array = (NSArray*)json;
                    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
                    [contentDic setObject:novelKey?novelKey:@"" forKey:@"k"];
                    [contentDic setObject:novelKeyStr?novelKeyStr:@"" forKey:@"decryKey"];
                    [contentDic setObject:array forKey:@"chapters"];
                    //更新章节内容
                    [ChapterList updateBookChapterListContentByBookId:bookId chapterDic:contentDic];
                    
                    //处理付费章节或可读章节
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSInteger count = array.count;
                        NSMutableArray *availableArray = pageViewController.availableChapterArray;
                        NSMutableArray *payArray = pageViewController.payArray;
                        for (int i = 0; i < count; i++) {
                            
                            id content = [array objectAtIndex:i];
                            
                            if ([content isKindOfClass:[NSDictionary class]]) {
                                NSMutableDictionary *contentDic = [((NSDictionary*)content)mutableCopy];
                                id chapterId = [contentDic objectForKey:@"chapterId"];
                                if (chapterId) {
                                    
                                    NSString *chapterIdStr = [NSString stringWithFormat:@"%ld",[chapterId integerValue]];
                                    
                                    if (availableArray.count > 0) {
                                        [availableArray removeObject:chapterIdStr];
                                    }
                                    
                                    if (payArray.count > 0) {//wcw error
                                        [payArray removeObject:chapterIdStr];
                                    }
                                    
                                }
                            }
                        }
                    });
                }
                
                NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"1"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            } else {
                
                NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"0"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            }
            
        }else{
        
            NSDictionary *postDic = @{@"statusMsg":@"返回数据格式不对",@"isSuccess":@"0"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        NSDictionary *postDic = @{@"statusMsg":@"failure",@"isSuccess":@"0"};
        if (completeBlock) {
            completeBlock(postDic);
        }
    }];
}

+(void)novelHotWordsSearchDic:(NSDictionary *)searchDic completeBlock:(void(^)(id result))completeBlock
{
    SNStoryHotWordsSearchRequest *hotWordsSearchRequest = [[SNStoryHotWordsSearchRequest alloc]initWithDictionary:searchDic];
    [hotWordsSearchRequest send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                
                NSArray *hotWords = [[dic objectForKey:@"data"]objectForKey:@"hotWords"];
                NSDictionary *postDic = @{@"statusMsg":[dic objectForKey:@"statusMsg"],@"isSuccess":@"1"};
                
                NSMutableDictionary *muDic  = [NSMutableDictionary dictionary];
                [muDic setValuesForKeysWithDictionary:postDic];
                [muDic setObject:hotWords?hotWords:@"" forKey:@"hotWords"];
                if (completeBlock) {
                    completeBlock(muDic);
                }
            } else {
                
                NSDictionary *postDic = @{@"statusMsg":@"failure",@"isSuccess":@"0"};
                if (completeBlock) {
                    completeBlock(postDic);
                }
            }
            
        }else{
            
            NSDictionary *postDic = @{@"statusMsg":@"返回数据格式不对",@"isSuccess":@"0"};
            if (completeBlock) {
                completeBlock(postDic);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        NSDictionary *postDic = @{@"statusMsg":@"failure",@"isSuccess":@"0"};
        if (completeBlock) {
            completeBlock(postDic);
        }
    }];
}

#pragma mark - 添加锚点
+(void)novelAdd_AnchorDic:(NSDictionary *)requestDic completeBlock:(void (^)(id))completeBlock
{
    SNStoryBookAdd_AnchorRequest * add_AnchorRequest = [[SNStoryBookAdd_AnchorRequest alloc]initWithDictionary:requestDic];
    [add_AnchorRequest send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                if (completeBlock) {
                    completeBlock(@"success");
                }
            } else {
                if (completeBlock) {
                    completeBlock(@"failure");
                }
            }
        } else {
            if (completeBlock) {
                completeBlock(@"failure");
            }
            SNDebugLog(@"Add_AnchorDic接口数据格式错误");
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completeBlock) {
            completeBlock(@"failure");
        }
        SNDebugLog(@"Add_AnchorDic err reason:%@",error.userInfo);
    }];
}

#pragma mark - 获取锚点
+(void)novelGet_AnchorDic:(NSDictionary *)requestDic completeBlock:(void(^)(id result))completeBlock
{
    SNStoryBookGet_AnchorRequest * get_AnchorRequest = [[SNStoryBookGet_AnchorRequest alloc]initWithDictionary:requestDic];
    [get_AnchorRequest send:^(SNBaseRequest *request, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = responseObject;
            if ([[dic objectForKey:@"statusMsgEn"] isEqualToString:@"success"]) {
                
                NSArray *array = dic[@"data"];
                if (array && array.count > 0) {
                    
                    [StoryBookAnchor insertBookAnchorWithBookAnchorArry:array];
                    if (completeBlock) {
                        completeBlock(@"success");
                    }
                } else {
                    if (completeBlock) {
                        completeBlock(@"failure");
                    }
                }
                
            } else {
                if (completeBlock) {
                    completeBlock(@"failure");
                }
                SNDebugLog(@"Add_Anchor:%@",[dic objectForKey:@"statusMsg"]);
            }
        } else {
            if (completeBlock) {
                completeBlock(@"failure");
            }
            SNDebugLog(@"Add_Anchor接口数据格式错误");
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completeBlock) {
            completeBlock(@"failure");
        }
        SNDebugLog(@"get_Anchor err reason:%@",error.userInfo);
    }];
}

#pragma mark - 解密章节内容
+(NSString *)decryContentWithStr:(NSString *)str key:(NSString *)key
{
    if (!str || !key) {
        return @"";
    }
    
    NSString *novelKeyStr = [SNStoryRSA decryptString:key publicKeyWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"public_key" ofType:@"der"]];
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString * decryDataContent = [SNStoryAesEncryptDecrypt decryptData:data withKey:novelKeyStr];
    if (decryDataContent.length <= 0) {
        return @"";
    }
    
    NSString *contentStr = [[decryDataContent stringByReplacingOccurrencesOfString:@"\n" withString:@"\n　　"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    contentStr = [NSString stringWithFormat:@"　　%@",contentStr];
    return contentStr;
}

#pragma mark - 计算章节分页
+(NSMutableArray *)getPageCountWithStr:(NSString *)str font:(UIFont *)font
{
    NSMutableArray *pageCountArry = [[NSMutableArray alloc]initWithCapacity:20];
    
    UIFont *font_ = font;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [SNStoryPage getLineSpace];
    paragraphStyle.paragraphSpacing = [SNStoryPage getparagraphSpace];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *dic = @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName:font_};
    
    NSMutableAttributedString *totalString = [[NSMutableAttributedString  alloc] initWithString:str];
    
    [totalString setAttributes:dic range:NSMakeRange(0, totalString.length)];
    //首页
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) totalString);
    CGPathRef firstPagePath = CGPathCreateWithRect(CGRectMake(PageOriginX, 0 ,PageWidth, PageHeight/2.f), NULL);
    CTFrameRef firstPageCTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), firstPagePath, NULL);
    CFRange firstPageCFRange = CTFrameGetVisibleStringRange(firstPageCTFrame);
    
    if ((firstPageCFRange.length + firstPageCFRange.location) >= totalString.length) {//只有1页
        [pageCountArry addObject:[NSString stringWithFormat:@"%ld_%ld", firstPageCFRange.location,firstPageCFRange.length]];
        
        CFRelease(firstPagePath);
        CFRelease(firstPageCTFrame);
        CFRelease(frameSetter);
        return pageCountArry;
    }
    
    //章节首页
    [pageCountArry addObject:[NSString stringWithFormat:@"%ld_%ld", firstPageCFRange.location,firstPageCFRange.length]];
    
    //其他页
    NSString * normalStr = [str substringFromIndex:(firstPageCFRange.length + firstPageCFRange.location)];
    NSMutableAttributedString *normalTotalString = [[NSMutableAttributedString  alloc] initWithString:normalStr];
    [normalTotalString setAttributes:dic range:NSMakeRange(0, normalTotalString.length)];
    CTFramesetterRef naomalFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) normalTotalString);
    CGPathRef normalPath = CGPathCreateWithRect(CGRectMake(PageOriginX, 0 ,PageWidth, PageHeight), NULL);
    CTFrameRef normalCTFrame = CTFramesetterCreateFrame(naomalFrameSetter, CFRangeMake(0, 0), normalPath, NULL);
    CFRange normalCFRange = CTFrameGetVisibleStringRange(normalCTFrame);
    
    
    CFRelease(normalPath);
    CFRelease(normalCTFrame);
    CFRelease(firstPagePath);
    CFRelease(firstPageCTFrame);
    CFRelease(frameSetter);
    CFRelease(naomalFrameSetter);
    
    //location需要加上首页的length
    [pageCountArry addObject:[NSString stringWithFormat:@"%ld_%ld", (firstPageCFRange.location + firstPageCFRange.length),normalCFRange.length]];
    
    NSUInteger length = normalStr.length;
    while (normalCFRange.length + normalCFRange.location < length) {
        
        NSString *subStr = [normalStr substringFromIndex:(normalCFRange.length + normalCFRange.location)];
        NSMutableAttributedString *totalString = [[NSMutableAttributedString  alloc] initWithString:subStr];
        [totalString setAttributes:dic range:NSMakeRange(0, totalString.length)];
        
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) totalString);
        CGPathRef path = CGPathCreateWithRect(CGRectMake(PageOriginX, 0 ,PageWidth, PageHeight), NULL);
        CTFrameRef ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
        CFRange cfrange1 = CTFrameGetVisibleStringRange(ctFrame);
        
        normalCFRange.location = (normalCFRange.length + normalCFRange.location);
        normalCFRange.length = cfrange1.length;
        
        CFRelease(path);
        CFRelease(ctFrame);
        CFRelease(frameSetter);
        //location需要加上首页的length
        NSRange rangeCount = NSMakeRange(normalCFRange.location + (firstPageCFRange.location + firstPageCFRange.length), normalCFRange.length);
        
        if ((rangeCount.location + rangeCount.length) >= length) {//最后一行是空行
            NSString *contentStr = [str substringWithRange:rangeCount];
            contentStr = [contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
            contentStr = [contentStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            contentStr = [contentStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            if (contentStr.length > 0) {
                [pageCountArry addObject:[NSString stringWithFormat:@"%ld_%ld", normalCFRange.location + (firstPageCFRange.location + firstPageCFRange.length),normalCFRange.length]];
            }
        }
        else
        {
           [pageCountArry addObject:[NSString stringWithFormat:@"%ld_%ld", normalCFRange.location + (firstPageCFRange.location + firstPageCFRange.length),normalCFRange.length]];
        }
    }
    
    return pageCountArry;
}

+(void)removeBookInfoAndChaptersByBookId:(NSString *)bookId
{
    //删除某本书
    [StoryBookList removeBookInfoByBookId:bookId];
    //删除某本书的所有章节
    [ChapterList removeBookChapterListByBookId:bookId chapterId:0];
    //删除某本书的正逆序记录
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:bookId];
}

+(void)insertBookShelfListWithArray:(NSArray *)array
{
    [StoryBookShelfList insertBookShelfListWithArray:array];
}

+(StoryBookShelfList *)fecthBookShelfListByBookId:(NSString *)bookId
{
    return [StoryBookShelfList fecthBookShelfListByBookId:bookId];
}

+(NSString *)getContentWithModel:(SNStoryChapter *)model currentIndex:(NSInteger)currentIndex
{
    NSInteger pageCount = model.chapterPageArray.count;
    if (pageCount <= 0) {
        return @"";
    } else {
        if (currentIndex >= pageCount) {
            currentIndex = pageCount - 1;
        }
    }
    
    NSString *pstr = [model.chapterPageArray objectAtIndex:currentIndex];
    NSArray *array = [pstr componentsSeparatedByString:@"_"];
    NSRange range = NSMakeRange([[array firstObject]integerValue], [[array lastObject]integerValue]);
    if ((range.location + range.length) > model.chapterContent.length) {
        return @"";
    }
    else
    {
        NSString *contentStr = [model.chapterContent substringWithRange:range];
        if (!contentStr) {
            contentStr = @"";
        }
        return contentStr;
    }
}

@end
