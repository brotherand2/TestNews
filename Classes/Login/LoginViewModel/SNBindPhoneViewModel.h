//
//  SNBindPhoneViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SNBindPhoneViewModelDelegate;
@interface SNBindPhoneViewModel : NSObject

@property (nonatomic,weak) id <SNBindPhoneViewModelDelegate> delegate;

/** 绑定手机号 (直接绑定(老用户)/第三方绑定/搜狐passport绑定) (新用户注册/老用户绑定) params[@"type"]
 */
- (void)bindPhone:(NSDictionary *)params ThirdData:(NSDictionary*)thirdData Successed:(void (^)(NSDictionary *))method;

//自动注册 //微信、评论 
- (void)autoThirdSignup:(NSDictionary*)thirdParams Successed:(void (^)(NSDictionary *))method;

- (BOOL)isBinding;

@end

@protocol SNBindPhoneViewModelDelegate <NSObject>

- (void)resetPhoneViewText:(NSDictionary*)dic;

@end