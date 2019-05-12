//
//  SNNewsFaourService.h
//  sohunews
//
//  Created by weibin cheng on 14-8-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNewsFavourServiceDelegate <NSObject>

@optional
//- (void)newsFavourServiceDidFinished:(NSInteger)favourCount;
- (void)newsFavourServiceDidFinished:(NSInteger)favourCount readingCount:(NSInteger)readingCount;
- (void)newsFavourServiceDisdFailed:(NSError*)error;
@end

@interface SNNewsFavourService : NSObject
@property (nonatomic, weak) id<SNNewsFavourServiceDelegate> delegate;
@property (nonatomic, assign) int favourCount;
@property (nonatomic, assign) int readingCount;

//- (void)startRequestNewsFavourWithNewsId:(NSString*)newsId;

//- (void)startRequestNewsFavourWithGid:(NSString*)gid;

@end
