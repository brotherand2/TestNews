//
//  SNRedPacketShareAlert.h
//  sohunews
//
//  Created by Valar__Morghulis on 2017/4/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRedPacketShareAlert : NSObject

/**
 正文页红包领取后弹出
 */
- (void)showArticleRedPacketShareAlert;


/**
 频道流红包活动领取后弹出

 @param title 标题
 @param alipayName 副标题
 @param redPacketId redPacketId
 */
- (void)showRedPacketShareAlertWithTitle:(NSString *)title
                              alipayName:(NSString *)alipayName
                         withRedPacketId:(NSString *)redPacketId;
@end
