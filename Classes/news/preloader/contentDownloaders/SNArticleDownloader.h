//
//  SNArticleDownloader.h
//  sohunews
//
//  Created by jojo on 13-11-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNContentDownloader.h"

@interface SNArticleDownloader : SNContentDownloader

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSMutableDictionary *linkParams;

@end
