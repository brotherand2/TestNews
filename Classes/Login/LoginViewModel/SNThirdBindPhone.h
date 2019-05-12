//
//  SNThirdBindPhone.h
//  sohunews
//
//  Created by wang shun on 2017/4/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNThirdBindPhoneDelegate;

@interface SNThirdBindPhone : NSObject

@property (nonatomic,weak) id <SNThirdBindPhoneDelegate> delegate;

@property (nonatomic,strong) NSDictionary* userInfo;

- (instancetype)initWithDelegate:(id <SNThirdBindPhoneDelegate>)del;

- (void)bindThirdPartyLogin:(NSDictionary*)params;

@end

@protocol SNThirdBindPhoneDelegate <NSObject>

- (void)openBindPhoneViewControllerData:(NSDictionary*)dic WithUserInfo:(NSDictionary*)userinfo;

- (void)loginSuccessed:(NSDictionary *)data WithUserInfo:(NSDictionary*)userInfo;

- (void)ThirdBindApiFailed:(NSDictionary*)data;

- (void)ppLoginSuccessed:(NSDictionary*)dic;

@end
