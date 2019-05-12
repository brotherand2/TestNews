//
//  SNDatabase+adInfos.h
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNAdvertiseObjects.h"

#define kAdInfoDefaultCategoryId                    (@"1")

typedef enum {
    SNAdInfoTypeStart = -1,
    SNAdInfoTypeLoading,
    SNAdInfoTypeArticle,
    SNAdInfoTypeSubCenterTopBanner,
    SNAdInfoTypeChannelBanner,
    SNAdInfoTypePhotoListNews,
    SNAdInfoTypeMySubBanner,
    SNAdInfoTypeEnd
}SNAdInfoType;

@interface SNDatabase (adInfos)

- (BOOL)adInfoAddOrUpdateAdInfos:(NSArray *)adInfos
                        withType:(SNAdInfoType)type
                          dataId:(NSString *)dataId
                      categoryId:(NSString *)categoryId;


- (BOOL)adInfoClearAdInfosByType:(SNAdInfoType)type;

- (BOOL)adInfoClearAdInfosByType:(SNAdInfoType)type
                          dataId:(NSString *)dataId
                      categoryId:(NSString *)categoryId;


- (NSArray *)adInfoGetAdInfosByType:(SNAdInfoType)type
                             dataId:(NSString *)dataId
                         categoryId:(NSString *)categoryId;


@end
