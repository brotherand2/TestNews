//
//  SNSendVcodeViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSendVcodeViewModel : NSObject

- (void)sendVcode:(NSDictionary*)params Completion:(void (^)(NSDictionary*resultDic))method;

@end
