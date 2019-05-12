//
//  SNActiveTipsService.m
//  sohunews
//
//  Created by 赵青 on 2016/11/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNActiveTipsService.h"
#import "SNUserManager.h"
#import "SNGetPromptRequest.h"

@interface SNActiveTipsService () {
//    ASIHTTPRequest *_request;
}
@end

@implementation SNActiveTipsService

- (void)requestActivityInfo
{
//    [_request clearDelegatesAndCancel];
//    _request = nil;
//    
//    NSString *url = [NSString stringWithFormat:SNLinks_Path_Activity_Info, [SNUserManager getP1], [SNAPI productId], [SNUtility marketID], [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey]];
//    _request = [self requestWithURLString:url];
//    [_request setDelegate:self];
//    [_request startAsynchronous];
    
    [[[SNGetPromptRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSString *statusCode = [responseObject objectForKey:@"statusCode"];
                    if ([statusCode isEqualToString:@"000"]) {
                        NSDictionary *dict = [responseObject objectForKey:@"data"];
                        if (dict) {
                            [self dispatchToDelegateWithActivityInfo:dict];
                        }
                    } else {
                        //服务器返回999失败时，测试数据
                        //                NSDictionary *activeTipsInfo = @{@"text": @"京东送红包活动",@"imageUrl": @"http://00f3c1b4.sohunewsclientpic.imgcdn.sohucs.com/img7/adapt/wb/focal/2016/02/23/145622156825498514_720_356.JPEG", @"showRedPoint": @YES};
                        //                [self dispatchToDelegateWithActivityInfo:activeTipsInfo];
                    }
                } else {
                    [self dispatchToDelegateWithError:nil];
                }
            } @catch (NSException *exception) {
                SNDebugLog(@"SNGetPromptRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });

    } failure:^(SNBaseRequest *request, NSError *error) {
        [self dispatchToDelegateWithError:nil];
    }];
    
}


- (void)dispatchToDelegateWithError:(NSError *)error {
    if (!([NSThread currentThread].isMainThread)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchToDelegateWithError:error];
        });
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didFailedToRequestActiveTips)]) {
        [_delegate didFailedToRequestActiveTips];
    }
}

- (void)dispatchToDelegateWithActivityInfo:(NSDictionary *)activityInfo {
    if (!([NSThread currentThread].isMainThread)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchToDelegateWithActivityInfo:activityInfo];
        });
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(didSucceedToRequestActiveTips:)]) {
        [_delegate didSucceedToRequestActiveTips:activityInfo];
    }
}

@end
