//
//  SNApplicationSohuRequest.h
//  sohunews
//
//  Created by TengLi on 2017/6/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHeaderScookieRequest.h"

@interface SNApplicationSohuRequest : SNHeaderScookieRequest


/**
 每次进入我的tab都去check公众号的状态,是申请还是管理

 @param handler 用于判断是否需要更新状态,以及最新的服务端下发的数据
 */
+ (void)checkReloadApplicationSohuWithHandler:(void(^)(BOOL needReload,NSDictionary *data))handler;
@end
