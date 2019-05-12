//
//  SNSearchSuggestionTool.m
//  sohunews
//
//  Created by 张承 on 15/8/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSearchSuggestionTool.h"
#import "SNUserManager.h"
#import "NSJSONSerialization+String.h"
#import "SNSearchSuggestV2Request.h"

@interface SNSearchSuggestionTool()
@end

@implementation SNSearchSuggestionTool
+ (SNSearchSuggestionTool *)sharedManager {
    static SNSearchSuggestionTool *__sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sInstance = [[self alloc] init];
    });
    return __sInstance;
}

- (void)searchSuggestion:(NSString *)keyword showSuggestion:(BOOL)showSuggestion success:(void(^)(NSArray *suggesstionList))success failure:(void(^)(void))failure;
{
    if (!showSuggestion) {
        return;
    }
    
    [[[SNSearchSuggestV2Request alloc] initWithDictionary:@{@"words":keyword}]
     send:^(SNBaseRequest *request, id responseObject) {
        NSArray *array = [responseObject objectForKey:@"suggestList"];
        if ([array count] > 0) {
            if (success) {
                success(array);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (failure) {
            failure();
        }
    }];
    
    
}

@end
