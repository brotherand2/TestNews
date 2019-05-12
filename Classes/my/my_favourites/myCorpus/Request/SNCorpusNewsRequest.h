//
//  SNCorpusNewsRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  获取收藏夹新闻请求类

#import "SNDefaultParamsRequest.h"

@interface SNCorpusNewsRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andCorpusName:(NSString *)corpusName;

@end
