//
//  SNSohuHaoModel.h
//  sohunews
//
//  Created by HuangZhen on 13/06/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSohuHaoChannel : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * channelId;

@end

@interface SNSohuHao : NSObject

@property (nonatomic, copy) NSString * subId;//（公众号id）
@property (nonatomic, copy) NSString * nickname;//（公众号名称）
@property (nonatomic, assign) NSInteger pv;//（公众号累计关注数量）
@property (nonatomic, copy) NSString * passport;//（公众号passprot）
@property (nonatomic, copy) NSString * avatar;//（公众号头像）
@property (nonatomic, copy) NSString * mpId;
@property (nonatomic, assign) BOOL following;//（是否关注）
@property (nonatomic, copy) NSString * channelid;//分类id

@end

typedef void(^SNSohuHaoChannelListDataBlock)(NSArray * data);
typedef void(^SNSohuHaoListDataBlock)(NSArray * data);

@interface SNSohuHaoModel : NSObject

+ (void)getSohuHaoChannelList:(SNSohuHaoChannelListDataBlock)sohuHaoChannelListDataBlock;

+ (void)getSohuHaoListWithChannelId:(NSString *)channelId page:(NSInteger)page completed:(SNSohuHaoListDataBlock)sohuHaoListDataBlock;

@end
