//
//  SNWeiboHelper.h
//  sohunews
//
//  Created by wang shun on 2017/2/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

#import "SNShareWeibo.h"
#import "SNH5NewsBindWeibo.h"

@interface SNWeiboHelper : NSObject<WeiboSDKDelegate>

@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbRefreshToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

@property (nonatomic, strong) SNShareWeibo *shareWeibo;

@property (nonatomic, strong) SNH5NewsBindWeibo *bindWeibo;//正文页评论绑定微博

+ (SNWeiboHelper *)sharedInstance;

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end
