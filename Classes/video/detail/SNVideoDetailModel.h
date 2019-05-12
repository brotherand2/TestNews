//
//  SNVideoDetailModel.h
//  sohunews
//
//  Created by jojo on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoObjects.h"

@interface SNVideoDetailModel : NSObject

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *mid; // 请求视频信息 需要用这个id来访问接口
@property (nonatomic, copy) NSString *channelId;

// data returned
@property (nonatomic, strong) SNVideoData *videoDetailItem;
@property (nonatomic, copy) NSString *shareContent;

// mid需要有值 否则请求失败返回NO
- (BOOL)refreshVideoDetail;

// 通过mid来刷分享语
- (BOOL)refreshShareContent;

@end
