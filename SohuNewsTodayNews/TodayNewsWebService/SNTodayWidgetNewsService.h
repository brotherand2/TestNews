//
//  SNTodayWidgetNewsService.h
//  WidgetApp
//
//  Created by WongHandy on 8/4/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNTodayWidgetNewsServiceDelegate <NSObject>
- (void)didFinishWithNewsList:(NSArray *)newsList;
- (void)didFailedWithError:(NSError *)error;
@end

@interface SNTodayWidgetNewsService : NSObject
@property(nonatomic, weak)id delegate;
- (void)requestFromLocalAsynchrously;
- (void)requestFromServerAsynchrously;
- (void)cancel;
+ (void)uploadPasteBoardToServer:(NSString *)boardString pid:(NSString *)pid success:(void(^)())success failure:(void(^)())failure;
@end
