//
//  SNSearchSuggestionTool.h
//  sohunews
//
//  Created by 张承 on 15/8/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSearchSuggestionTool : NSObject

+ (SNSearchSuggestionTool *)sharedManager;
- (void)searchSuggestion:(NSString *)keyword showSuggestion:(BOOL)showSuggestion success:(void(^)(NSArray *suggesstionList))success failure:(void(^)(void))failure;
@end
