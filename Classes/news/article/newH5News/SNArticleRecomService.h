//
//  SNArticleRecomService.h
//  sohunews
//
//  Created by lhp on 12/19/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDatabase+adInfos.h" //SNAdInfoType

typedef NS_ENUM(NSInteger, SNRecommendType) {
    SNRecommendTypeNews,
    SNRecommendTypePhoto
};

@protocol SNArticleRecomServiceDelegate <NSObject>
@optional

- (void)getRecommendNewsSucceed;

@end

@interface SNArticleRecomService : NSObject {
    
    NSMutableArray *adInfoArray;
    NSString *newsId;
    NSString *termId;
    NSString *subId;
    NSString *channelId;
    id<SNArticleRecomServiceDelegate> __weak _delegate;
}
@property(nonatomic,strong)NSString *newsId;
@property(nonatomic,strong)NSString *gid;
@property(nonatomic,strong)NSString *termId;
@property(nonatomic,strong)NSString *subId;
@property(nonatomic,strong)NSString *channelId;
@property(nonatomic,assign)SNRecommendType recomType;
@property(nonatomic,strong)NSDictionary *userData;
@property(nonatomic,assign)SNAdInfoType adType;
@property(nonatomic,strong)NSMutableArray *adInfoArray;
@property(nonatomic,weak)id<SNArticleRecomServiceDelegate> delegate;

// add by Cae. 5.1需求，push定向
@property(nonatomic,strong)NSString *fromPush;

- (void)loadRecommendNews;
- (void)cancel;

@end
