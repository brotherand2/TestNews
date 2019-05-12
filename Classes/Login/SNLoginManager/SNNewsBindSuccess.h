//
//  SNNewsBindSuccess.h
//  sohunews
//
//  Created by wang shun on 2017/4/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsBindSuccess : NSObject

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^bindSuccess)(NSDictionary* resultDic);
@property (nonatomic,copy) void (^bindCancel)(NSDictionary* resultDic);

- (instancetype)initWithParams:(NSDictionary*)params;

- (void)bindSucessed:(NSDictionary*)dic;
- (void)bindCanceled:(NSDictionary*)dic;

/** 绑定成功通知
 */
- (void)postBindSuccessNotification;

@end
