//
//  SNStoryJSModel.m
//  sohunews
//
//  Created by iOS_D on 2016/11/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryJSModel.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "JSONKit.h"


@implementation SNStoryJSModel

- (void)jsInterface_setCmtCount:(JsKitClient *)client
                        comment:(NSNumber *)cmt {
    if(nil != cmt){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storyVC setCommentNum:[NSString stringWithFormat:@"%ld",[cmt integerValue]]];
        });
    }
}

/**
 *  通用浏览器 新窗口打开页面  newsApi.newWindow(url)
 */
- (void)jsInterface_newWindow:(JsKitClient *)client url:(NSString *)url {
    __block NSString *protocolUrl = url;//外链分享contentType
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([protocolUrl containsString:@"?"]) {
            protocolUrl = [protocolUrl stringByAppendingString:@"&contentType=pack"];
        }
        else {
            protocolUrl = [protocolUrl stringByAppendingString:@"?contentType=pack"];
        }
        
        [SNUtility openProtocolUrl:protocolUrl context:@{@"shareLogType":@"coupon"}];
    });
}


//
- (void)jsInterface_jsCallGotoSubHome:(JsKitClient *)client jsonObject:(id)jsonObject
{
    if ([NSThread isMainThread]) {
        [self.storyVC enterUserCenter:jsonObject];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storyVC enterUserCenter:jsonObject];
        });
    }
}

//回复评论
- (void)jsInterface_jsCallReplayComment:(JsKitClient *)client jsonObject:(id)jsonObject
{
    if ([NSThread isMainThread]) {
        if (jsonObject) {
            [self.storyVC replyComment:(NSDictionary *)jsonObject];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonObject) {
                [self.storyVC replyComment:(NSDictionary *)jsonObject];
            }
        });
    }
}

//copy
- (void)jsInterface_jsCallCopy:(JsKitClient *)client jsonObject:(NSString *)content
{
    if (![content isKindOfClass:[NSNull class]]) {
        [self.storyVC copyComment:content];
    }
}

//share
- (void)jsInterface_jsCallShare:(JsKitClient *)client jsonObject:(NSString *)content
{
    if (![content isKindOfClass:[NSNull class]]) {
        if ([NSThread isMainThread]) {
            [self.storyVC shareContent:content];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.storyVC shareContent:content];
            });
        }
    }
}

- (void)jsInterface_gotoCommentSofa:(JsKitClient *)client
{
    if ([NSThread isMainThread]) {
        [self.storyVC emptyCommentListClicked];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storyVC emptyCommentListClicked];
        });
    }
}

- (void)jsInterface_showLoadingView:(JsKitClient *)client isLoading:(BOOL)isLoading
{
    if ([NSThread isMainThread]) {
        [SNUtility shouldAddAnimationOnSpread:isLoading];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SNUtility shouldAddAnimationOnSpread:isLoading];
        });
    }
}

- (void)jsInterface_showTitle:(JsKitClient *)client show:(NSNumber *)show title:(NSString *)title
{
    [super jsInterface_showTitle:client show:show title:title];
}

- (void)jsInterface_showShareBtn:(JsKitClient *)client show:(NSNumber *)show
{
    [super jsInterface_showShareBtn:client show:show];
}

- (void)jsInterface_showMaskView:(JsKitClient *)client close:(NSNumber *)close
{
    [super jsInterface_showMaskView:client close:close];
}
@end
