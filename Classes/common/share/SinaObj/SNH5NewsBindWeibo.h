//
//  SNH5NewsBindWeibo.h
//  sohunews
//
//  Created by wang shun on 2017/6/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

@protocol SNH5NewsBindWeiboDelegate;
@interface SNH5NewsBindWeibo : NSObject

@property (nonatomic,weak) id <SNH5NewsBindWeiboDelegate> delegate;

/**绑定微博 正文评论*/
- (void)bindWeiBo:(id <SNH5NewsBindWeiboDelegate>)delegate_;

/** 解绑
 */
+ (void)removeBindWeibo;

/** YES:已绑定 NO:未绑定 */
+ (BOOL)isNotBindWeibo;

/** 微博回调*/
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end

@protocol SNH5NewsBindWeiboDelegate <NSObject>

- (void)bindWeiboSuccess:(NSDictionary*)info;

@end
