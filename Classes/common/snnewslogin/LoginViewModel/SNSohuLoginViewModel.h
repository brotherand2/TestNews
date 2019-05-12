//
//  SNSohuLoginViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSohuLoginViewModel : NSObject

- (void)sohuLogin:(NSDictionary*)params WithSuccessed:(void (^)(NSDictionary*resultDic))method;

@end
