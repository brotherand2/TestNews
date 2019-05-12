//
//  SNNewsShareOnService.h
//  sohunews
//
//  Created by wang shun on 2017/2/28.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SNNewsShareOnServiceDelegate;

@interface SNNewsShareOnService : NSObject

@property (nonatomic,strong) NSString * currentOnType;
@property (nonatomic,weak) id <SNNewsShareOnServiceDelegate> del;

- (instancetype)initWithDelegate:(id<SNNewsShareOnServiceDelegate>)delegate;

- (void)getShareType:(ShareType)shareType onType:(ShareOnType)shareOnType Params:(NSDictionary *)dic;

@end

@protocol SNNewsShareOnServiceDelegate <NSObject>
/**
 * 请求shareOn.go接口的delegate回调
 */
- (void)requestFromShareOnServerFinished:(NSDictionary *)responseData;

@end
