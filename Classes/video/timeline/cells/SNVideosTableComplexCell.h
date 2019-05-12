//
//  SNVideosTableComplexCell.h
//  sohunews
//
//  Created by weibin cheng on 14-8-7.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNVideosTableBaseCell.h"

@class SNVideoData;

typedef void(^SNVideosTableComplexCellUninterestBlock)(SNVideoData* data);

@interface SNVideosTableComplexCell : SNVideosTableBaseCell
@property (nonatomic, copy)SNVideosTableComplexCellUninterestBlock uninterestBlock;
@property (nonatomic, copy)NSString* channelId;

+ (CGFloat)heightForVideoData:(SNVideoData*)data;
@end
