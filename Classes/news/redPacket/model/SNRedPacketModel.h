//
//  SNRedPacketModel.h
//  sohunews
//
//  Created by cuiliangliang on 16/3/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFNetworking.h"
/*
 http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=10192397#id-客户端红包接口-我的红包提现接口
 {
     statusCode: 30060000,   //数据状态码
     statusMsg: "success",
     data: {
         withdrawFee: "88.54",  // 提现红包金额
         alipayPassport: "haiohf*****naj" //支付宝账户
         withdrawTime: 1457533047000
     }
 }
 */
#define RedPacketCopywriterNomal  @"红包未能成功提现到支付宝"
#define RedPacketCode30060009  @"该设备未绑定支付宝"
#define RedPacketCode30060010  @"红包已过期"
#define RedPacketCode30060011  @"红包错误"
#define RedPacketCode30060012  @"根据支付宝规定，提现超过1000元时需进行支付宝实名认证"
#define RedPacketCode30060013  @"未能获取到支付宝账号"
#define RedPacketCode30060014  @"未登录"
#define RedPacketCode30060006  @"该设备已绑定过支付宝账号"
#define RedPacketCode30060003  @"你当前的支付宝账号已被绑定，请更改后重试"
#define RedPacketCode30060005  @"账号错误"
#define RedPacketCode30060002  @"该设备未绑定手机"
#define RedPacketCode30060001  @"该手机已绑定过其他设备"



@interface SNPackProfile : NSObject
@property (nonatomic, copy) NSString *statusCode;//30060000 成功
@property (nonatomic, copy) NSString *statusMsg;
@property (nonatomic, copy) NSString *withdrawFee;
@property (nonatomic, copy) NSString *alipayPassport;
@property (nonatomic, copy) NSString *withdrawTime;

@end

typedef void(^authCompletionBlock)(BOOL Success, NSString *result);
typedef void(^verifyCompletionBlock)(BOOL Success, BOOL isClickBackButton);
typedef void(^SNRedPacketRequestFinish)(SNPackProfile *packProfile);
typedef void(^SNRedPacketRequestFailure)(id request, NSError *error);

@interface SNRedPacketModel : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) authCompletionBlock authCompletion;
@property (nonatomic, assign) BOOL isH5;

+ (SNRedPacketModel *)sharedInstance;

/*
 30060009    该设备未绑定支付宝
 30060010    红包已过期
 30060011    红包错误
 30060012    根据支付宝规定，提现超过1000元时需进行支付宝实名认证
 */
- (SNPackProfile *)packProfileWithP1:(NSString *)p1 withPackId:(NSString *)packId;

/*
 //错误码：
 30060014   未登录
 30060013   未能获取到支付宝账号
 30060006   该设备已绑定过支付宝账号
 30060003   你当前的支付宝账号已被绑定，请更改后重试
 30060005   账号错误
 30060002   该设备未绑定手机
 30060001   该手机已绑定过其他设备
 */
- (NSString *)bindApalipayPassport:(NSString *)openid
                      withAuthCode:(NSString *)code;

- (void)bindApalipayPassport:(NSString*)openid
                withAuthCode:(NSString*)code
                   andResult:(void(^)(id responseObject))result;

- (void)verifySendRedPacket:(verifyCompletionBlock)completionBlock;
- (void)auth_V2:(authCompletionBlock)completionBlock;
- (void)redPacketRequestWithPacketID:(NSString *)packetID
                       requestFinish:(SNRedPacketRequestFinish)requestFinish
                      requestFailure:(SNRedPacketRequestFailure)requestFailure;
- (void)handleOpenURL:(NSURL *)url;

+ (NSString *)getPidByInfoStr:(NSString *)url;
+ (NSString *)getValueStringFromUrl:(NSString *)url forParam:(NSString *)param;

+ (NSString *)getErrorStringWithErrorCode:(NSString *)code;

@end
