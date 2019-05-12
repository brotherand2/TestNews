//
//  SHH5ChannelApi.m
//  sohunews
//
//  Created by Scarlett on 16/3/3.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5ChannelApi.h"
//#import "JsKitClient.h"
#import <JsKitFramework/JsKitClient.h>

@implementation SHH5ChannelApi

- (void)jsInterface_showLoadingView:(JsKitClient *)client
                          channelID:(NSString *)channelID
                          isLoading:(NSNumber *)isLoading {
    //BOOL visible = [isLoading boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)jsInterface_onRefreshing:(JsKitClient *)client {
    
}

- (void)jsInterface_onRefreshComplete:(JsKitClient *)client
                            isSuccess:(NSNumber *)isSuccess {
    
}

@end
