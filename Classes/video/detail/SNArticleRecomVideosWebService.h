//
//  SNArticleRecomVideosWebService.h
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNArticleRecomVideosWebService : NSObject
@property (nonatomic, weak)id delegate;
@property (nonatomic, copy)NSString *newsId;
@property (nonatomic, copy)NSString *channelId;
@property (nonatomic, copy)NSString *subId;

- (void)startAsynchrously;
- (void)cancel;
@end

@protocol SNArticleRecomVideosWebServiceDelegate <NSObject>
- (void)didFinishLoadRecommendVideos:(NSArray *)recommendVideos;
- (void)didFailLoadWithError:(NSError *)error;
@end
