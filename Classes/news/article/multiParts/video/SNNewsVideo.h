//
//  SNNewsVideo.h
//  sohunews
//
//  Created by Cong Dan on 6/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoObjects.h"

typedef enum {
    SNNewsVideoSrcType_M3U8         = 0,
    SNNewsVideoSrcType_MP4Fraction  = 1,
    SNNewsVideoSrcType_TvUrl        = 2
} SNNewsVideoSrcType;

@interface SNNewsVideo : NSObject
{
    NSString *vId;
    NSString *name;
    NSString *poster;
    NSString *layout;
    NSString *playTime;
}

@property(nonatomic, copy)NSString *vId;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *poster;
@property(nonatomic, copy)NSString *layout;
@property(nonatomic, copy)NSString *playTime;
@property(nonatomic, copy)NSString *vvId; // 如果没有该节点不需要进行vv统计

@property(nonatomic, assign)SNNewsVideoSrcType newsVideoSrcType;
@property(nonatomic, strong)NSArray *srcArray;

@property(nonatomic, assign)WSMVVideoPlayType playType;
@property(nonatomic, assign)WSMVVideoDownloadType downloadType;
@property(nonatomic, copy)NSString *wapUrl;
@property(nonatomic, strong)SNVideoShare *share;

@property(nonatomic, copy) NSString *site;
@property(nonatomic, copy) NSString *site2;
@property(nonatomic, copy) NSString *siteName;
@property(nonatomic, copy) NSString *siteId;
@property(nonatomic, copy) NSString *playById;
@property(nonatomic, copy) NSString *playAd;
@property(nonatomic, copy) NSString *adServer;
@end
