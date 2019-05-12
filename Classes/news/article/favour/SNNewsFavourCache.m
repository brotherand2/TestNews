//
//  SNNewsFavourCache.m
//  sohunews
//
//  Created by weibin cheng on 14-8-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsFavourCache.h"

#define kNewsFavourFileName @"snnewsfavour.plist"

@implementation SNNewsFavourCache

+ (instancetype)shareInstance
{
    static SNNewsFavourCache* newsFavourCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newsFavourCache = [[SNNewsFavourCache alloc] init];
    });
    return newsFavourCache;
}

- (void)readFavourWithNewsId:(NSString *)newsId delegate:(id<SNNewsFavourCacheDelegate>)delegate
{
    if (!newsId) {
        return;
    }
    self.delegate = delegate;
    NSString* path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kNewsFavourFileName];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(dic)
            {
                BOOL favoured = [dic intValueForKey:newsId defaultValue:NO];
                if(_delegate && [_delegate respondsToSelector:@selector(newsFavourCacheDidFinish:)])
                {
                    [_delegate newsFavourCacheDidFinish:favoured];
                }
            }
            else
            {
                if(_delegate && [_delegate respondsToSelector:@selector(newsFavourCacheDidFinish:)])
                {
                    [_delegate newsFavourCacheDidFinish:NO];
                }
            }
        });
    });
}

- (void)saveFavourWithNewsId:(NSString*)newsId
{
    if (!newsId) {
        return;
    }
    NSString* path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kNewsFavourFileName];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
        if(!dic)
        {
            dic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [dic setValue:[NSNumber numberWithBool:YES] forKey:newsId];
        [dic writeToFile:path atomically:YES];
    });
}

//发现上面的writeToFile:只存不删？ 所以做了个清理的方法
- (void)clearFavour {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString* path = [SNUtility getDocumentPath];
        path = [path stringByAppendingPathComponent:kNewsFavourFileName];
        if ([fm fileExistsAtPath:path]) {
            [fm removeItemAtPath:path error:nil];
        }
    });

}

@end
