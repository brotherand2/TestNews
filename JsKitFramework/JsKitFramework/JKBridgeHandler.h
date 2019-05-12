//
//  JKBridgeHandler.h
//  sohunews
//
//  Created by sevenshal on 16/6/3.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BRIDGE_PATH_PREFIX @"/jskitbridge/"

@class JKBridgeHandler;

typedef void(^HANDLER)(JKBridgeHandler* handler, NSData *data, NSString* mimeType);

@interface JKBridgeHandler : NSObject

-(void)handleUrl:(NSURLRequest*) request callback:(HANDLER)callback;

-(void)stopHandle;

@end
