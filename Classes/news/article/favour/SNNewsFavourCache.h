//
//  SNNewsFavourCache.h
//  sohunews
//
//  Created by weibin cheng on 14-8-30.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNNewsFavourCacheDelegate <NSObject>

-(void)newsFavourCacheDidFinish:(BOOL)favour;

@end

@interface SNNewsFavourCache : NSObject
@property(nonatomic, weak) id<SNNewsFavourCacheDelegate> delegate;

+ (instancetype)shareInstance;

- (void)readFavourWithNewsId:(NSString*)newsId delegate:(id<SNNewsFavourCacheDelegate>)delegate;

- (void)saveFavourWithNewsId:(NSString*)newsId;

- (void)clearFavour;

@end
