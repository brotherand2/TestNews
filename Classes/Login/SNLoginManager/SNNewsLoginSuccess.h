//
//  SNNewsLoginSuccess.h
//  sohunews
//
//  Created by wang shun on 2017/4/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLoginSuccess : NSObject

@property (nonatomic,strong) NSDictionary* open_params;
@property (nonatomic,copy) void (^loginSuccess)(NSDictionary* resultDic);
@property (nonatomic,copy) void (^loginCancel)(NSDictionary* resultDic);

@property (nonatomic,strong) NSString* sourceChannelID;
@property (nonatomic,strong) NSString* entrance;//埋点
@property (nonatomic,strong) NSString* screen;

@property (nonatomic,weak) UIViewController* current_topViewController;

- (instancetype)initWithParams:(NSDictionary*)params;
+ (instancetype)sharedInstanceParams:(NSDictionary*)dic;

//登录成功失败
- (void)loginSucessed:(NSDictionary*)dic;
- (void)loginCancel:(NSDictionary*)dic;

- (void)halfLoginSucessed:(NSDictionary*)dic WithAnimation:(id)sender;
- (void)halfLoginCancel:(NSDictionary*)dic WithAnimation:(id)sender;

/** 登录成功通知
 */
- (void)postLoginSuccessNotification;

@end
