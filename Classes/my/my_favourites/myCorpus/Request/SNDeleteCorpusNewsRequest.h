//
//  SNDeleteCorpusNewsRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  删除收藏夹新闻请求类

#import "SNDefaultParamsRequest.h"

@interface SNDeleteCorpusNewsRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andCorpusName:(NSString *)corpusName;

@end
