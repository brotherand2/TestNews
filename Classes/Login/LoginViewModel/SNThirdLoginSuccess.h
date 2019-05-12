//
//  SNThirdLoginSuccess.h
//  sohunews
//
//  Created by wang shun on 2017/3/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNThirdLoginSuccess : NSObject

@property (nonatomic,strong) NSString *appId;

//老版本方法
- (void)loginSuccessed:(NSDictionary*)respDic WithThirdData:(NSDictionary*)thirdDic;

- (void)loginSuccessed:(NSDictionary*)respDic WithThirdData:(NSDictionary*)thirdDic WithSuccessed:(void (^)(NSDictionary *))method;

@end

@protocol SNThirdLoginSuccessDelegate <NSObject>

@end
