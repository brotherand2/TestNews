//
//  SNSSOQQWrapper.h
//  sohunews
//
//  Created by jojo on 13-11-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSSOWrapper.h"
#import "SNQQHelper.h"

#import "SNThirdLoginSuccess.h"

@interface SNSSOQQWrapper : SNSSOWrapper <SNQQHelperLoginDelegate>

@property (nonatomic,strong) SNThirdLoginSuccess* thirdLoginSuccess;
@property (nonatomic,strong) NSDictionary* userInfoDic;//绑定之前已经拿到的userinfo

@end
