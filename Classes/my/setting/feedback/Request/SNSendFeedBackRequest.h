//
//  SNSendFeedBackRequest.h
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//  发送反馈网络请求类

#import "SNDefaultParamsRequest.h"

@interface SNSendFeedBackRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andImageArray:(NSArray <UIImage *>*)imgArray;

@end
