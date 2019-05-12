//
//  SNFeedBackApi.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackApi.h"
#import <JsKitFramework/JsKitClient.h>
#import "SNNetDiagnoService.h"
#import "SNChatFeedbackController.h"

@implementation SNFeedBackApi
/*
 gotoFeedBackTab(int pos)            gotoSearchPage(int from)
 */
- (void)jsInterface_gotoSearchPage:(JsKitClient *)client pos:(NSString *)pos {
    
    BOOL hideHotWords = pos.integerValue;
    
    [self gotoMainQueueWithHandle:^{
        
        TTURLAction *urlAction = [TTURLAction actionWithURLPath:@"tt://search"];
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        [query setObject:[NSNumber numberWithBool:hideHotWords] forKey:@"hideHotWords"];
        [urlAction applyQuery:query.copy];
        [[TTNavigator navigator] openURLAction:urlAction] ;
    }];
    
}

/**
 * 去反馈界面
 */
- (void)jsInterface_gotoFeedBackTab:(JsKitClient *)client index:(NSString *)index{
    if (index.integerValue > 2) return;
    [self gotoMainQueueWithHandle:^{
        if ([[TTNavigator navigator].topViewController isKindOfClass:[SNChatFeedbackController class]]) {
            SNChatFeedbackController *chatVc = (SNChatFeedbackController *)[TTNavigator navigator].topViewController;
            [chatVc gotoFeedBackTabWithIndex:index.integerValue andAnimated:YES];
        } else {
            TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:YES];
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            [query setObject:index forKey:@"jsFeedBack"];
            [urlAction applyQuery:query.copy];
            [[TTNavigator navigator] openURLAction:urlAction];
        }
    }];
    
}

- (void)jsInterface_newWindow:(JsKitClient *)client url:(NSString *)url {
    
    [self gotoMainQueueWithHandle:^{
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        if (url.length > 0) {
            [query setObject:url forKey:@"allQuestionUrl"];
        }
        [query setObject:[NSNumber numberWithInteger:FeedBackWebViewType] forKey:kUniversalWebViewType];
        [SNUtility openUniversalWebView:query];
    }];
}


/**
 * 网络诊断
 */
- (void)jsInterface_gotoNetDiagnosis:(JsKitClient *)client {
    
    [[SNNetDiagnoService sharedInstance] startNetDiagnosisWithTipToast];
}

- (void)jsInterface_stopLoadingAnimation:(JsKitClient *)client {
    
    [self gotoMainQueueWithHandle:^{
        [self.usualQuestionViewController stopLoadingAnimation];
    }];
    
}

- (void)jsInterface_showErrorAnimationView:(JsKitClient *)client {
    
    [self gotoMainQueueWithHandle:^{
        [self.usualQuestionViewController showErrorAnimationView];
    }];
}


- (void)gotoMainQueueWithHandle:(void(^)())handle {
    if ([NSThread isMainThread]) {
        if (handle) handle();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handle) handle();
        });
    }
}


@end
