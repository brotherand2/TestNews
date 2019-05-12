//
//  SNNovelUtilities.h
//  sohunews
//
//  Created by qz on 17/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNovelUtilities : NSObject

+ (NSInteger)bookNumbersOfSingleShelfRow;//2017.4 书架页每行有几本书

+ (CGFloat)shelfImageHeightWidthRatio;//2017.4 书架页图书缩略图高宽比

+ (CGFloat)shelfImageWidth;//2017.4 书架页图书缩略图宽度

+ (CGFloat)shelfCellHeight;//2017.4 书架页cell高度

+ (NSInteger)downloadChapterNumsWhenReadBooks;//2017.5 开始阅读的时候应该下载的章节数 下载章节过多服务器有压力

+ (NSString *)shelfDataTitle;//2017.5 书架入口复用了templateType = 19 的cell  人工造的rollingnews数据里面 title字段的写死的名字
@end
