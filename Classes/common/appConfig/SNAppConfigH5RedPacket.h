//
//  SNAppConfigH5RedPacket.h
//  sohunews
//
//  Created by yangln on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigH5RedPacket : NSObject

@property (nonatomic, copy) NSString *redPacketUrl;
@property (nonatomic, strong) NSString *redPacketType;
@property (nonatomic, strong) NSString *redPacketPicUrl;
@property (nonatomic, strong) NSString *redPacketDetailUrl;
@property (nonatomic, strong) NSString *redPacketPosition;
@property (nonatomic, assign) BOOL redPacketIsShow;
@property (nonatomic, strong) NSString *redPacketStartTime;
@property (nonatomic, strong) NSString *redPacketEndTime;
@property (nonatomic, assign) BOOL redPacketFloatBtnIsShow;
@property (nonatomic, strong) NSDictionary *redPacketDict;

- (void)updateWithDict:(NSDictionary *)dict;

@end
