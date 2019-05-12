//
//  SNNewsThirdLoginEnable.h
//  sohunews
//
//  Created by wang shun on 2017/5/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsThirdLoginEnable : NSObject

@property (nonatomic,assign) BOOL isLanding;

//第三方是否正在登陆 loading的时候不能再次点击 孟刘洋
+ (SNNewsThirdLoginEnable *)sharedInstance;

@end
