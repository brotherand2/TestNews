//
//  SNBookShelf.m
//  sohunews
//
//  Created by H on 2016/11/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNBookShelf.h"
#import "SNUserManager.h"
#import "SNStoryToast.h"
#import "SNStoryPage.h"
#import "SNStoryRequest.h"
#import "StoryBookShelfList.h"

@interface SNBookShelf ()
@end

@implementation SNBookShelf
/*
 {
 "data": true,
 "statusCode": 30120000,
 "statusMsg": "成功",
 "statusMsgEn": "success"
 }
 */
+ (void)addBookShelf:(NSString *)bookId hasRead:(BOOL)hasRead completed:(addBookShelfDidFinished)completedBlock
{
    if (!bookId) {
        if (completedBlock) {
            completedBlock(NO);
        }
        return;
    }
    
    [[[SNBookAddShelfRequest alloc] initWithDictionary:@{@"bookId":bookId}] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = (NSDictionary *)responseObject;
            NSNumber * statusCode = [data objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30120000) {
                //添加书架完成，刷新频道流书架
                if (hasRead) {
                    [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil userInfo:@{@"scrollTop":@"1",@"bookId":bookId}];
                } else {
                    [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil];
                }
                
                //插入数据库
                [SNStoryPage insertBookShelfListWithArray:@[@{@"bookId":bookId,@"remind":[NSNumber numberWithBool:NO]}]];
                //查询完整书籍信息
                //回调
                if (completedBlock) {
                    completedBlock(YES);
                }
                
            }else{
                if (completedBlock) {
                    completedBlock(NO);
                }
                
            }
        }else{
            if (completedBlock) {
                completedBlock(NO);
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completedBlock) {
            completedBlock(NO);
        }
    }];
}

+ (void)removeBookShelf:(NSString *)bookId completed:(removeBookShelfDidFinished)completedBlock
{
    if (!bookId) {
        if (completedBlock) {
            completedBlock(NO);
        }
        return;
    }
    
    [[[SNDelBookFromShelfRequest alloc] initWithDictionary:@{@"bookId":bookId}] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = (NSDictionary *)responseObject;
            NSString * statusCode = [data objectForKey:@"statusMsgEn"];
            if ([statusCode isEqualToString:@"success"]) {
                //书架删除书籍，刷新频道流书架
                [[NSNotificationCenter defaultCenter] postNotificationName:kNovelDidAddBookShelfNotification object:nil];
                //库中删除(2017-03-16 删除书籍，数据保留)
                //[SNStoryPage removeBookInfoAndChaptersByBookId:bookId];
                NSArray *bookIdArray = [bookId componentsSeparatedByString:@","];
                for (NSString *deletedBookId in bookIdArray) {
                    [StoryBookShelfList removeBookShelfListByBookId:deletedBookId];
                }
                
                //回调
                if (completedBlock) {
                    completedBlock(YES);
                }
            }else{
                if (completedBlock) {
                    completedBlock(NO);
                }
            }
        }else{
            if (completedBlock) {
                completedBlock(NO);
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completedBlock) {
            completedBlock(NO);
        }
    }];
}

+ (void)setBookHasRead:(NSString *)bookId complete:(setHasReadDidFinished)completedBlock{
    if (!bookId) {
        if (completedBlock) {
            completedBlock(NO);
        }
        return;
    }

    [[[SNBookHadReadRequest alloc] initWithDictionary:@{@"bookId":bookId}] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = (NSDictionary *)responseObject;
            NSNumber * statusCode = [data objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30120000) {
                if (completedBlock) {
                    completedBlock(YES);
                }
            }else{
                if (completedBlock) {
                    completedBlock(NO);
                }
            }
        }else{
            if (completedBlock) {
                completedBlock(NO);
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completedBlock) {
            completedBlock(NO);
        }
    }];
}

/*
 {
 "data": {
 "books": [
 {
 "detailUrl": "readchapter://novelId=159723354",
 "author": "权小壕",
 "category": "架空小说",
 "title": "奸妃当道，APP养成记",
 "imageUrl": "http://bimg.xiang5.com/upload/images/20150805/thumb_20150805173954_769.jpg",
 "showDot": 0,
 "bookId": 159723354,
 "readUrl": "noveldetail://novelId=159723354"
 }
 ],
 "templateType": 139,
 "newsType": 121
 },
 "statusCode": 30120000,
 "statusMsg": "成功",
 "statusMsgEn": "success"
 }
 */
+ (void)getBooks:(NSString *)page count:(NSString *)count complete:(getBooksDidFinished)completedBlock {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setObject:page ? : @"" forKey:@"page"];
    [parameters setObject:count ? : @"" forKey:@"count"];
    
    [[[SNGetShelfBooksRequest alloc] initWithDictionary:parameters] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = [(NSDictionary *)responseObject objectForKey:@"data"];
            if (data) {
                NSArray * books = [data objectForKey:@"books"];
                //插入数据库
                [SNStoryPage insertBookShelfListWithArray:books];
                if (completedBlock) {
                    completedBlock(YES,books);
                }
            }else{
                if (completedBlock) {
                    completedBlock(YES,nil);
                }
            }
        }else{
            if (completedBlock) {
                completedBlock(NO,nil);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completedBlock) {
            completedBlock(NO,nil);
        }
    }];
}

/// 判断一本书是否已经在书架上
/// 需要在getbooks之后调用，否则会由于接口延迟问题而返回值不准确
+ (BOOL)isOnBookshelf:(NSString *)bookId {
    BOOL ret = NO;
    StoryBookShelfList *book = [StoryBookShelfList fecthBookShelfListByBookId:bookId];
    if (book) {
        ret = YES;
    }
    return ret;
}

+ (void)bookPushEnable:(BOOL)enable bookId:(NSString *)bookId complete:(setPushEnableDidFinished)completedBlock {
    if (!bookId) {
        if (completedBlock) {
            completedBlock(NO);
        }
        return;
    }

    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setObject:bookId forKey:@"bookId"];
    [parameters setObject:enable?@"1":@"0" forKey:@"remind"];
    [[[SNShelfBookRemindRequest alloc] initWithDictionary:parameters] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = (NSDictionary *)responseObject;
            NSNumber * statusCode = [data objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30120000) {
                if (completedBlock) {
                    completedBlock(YES);
                }
            }else{
                if (completedBlock) {
                    completedBlock(NO);
                }
            }
        }else{
            if (completedBlock) {
                completedBlock(NO);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completedBlock) {
            completedBlock(NO);
        }
    }];

}

+ (void)bookAllPushEnable:(BOOL)enable complete:(setPushEnableDidFinished)completedBlock {
    completedBlock(NO);
    return;
    
    [[[SNShelfBookRemindRequest alloc] initWithDictionary:@{@"remind":enable?@"1":@"0"}] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = (NSDictionary *)responseObject;
            NSNumber * statusCode = [data objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30120000) {
                completedBlock(YES);
            }else{
                completedBlock(NO);
            }
        }else{
            completedBlock(NO);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        completedBlock(NO);
    }];
}

@end
