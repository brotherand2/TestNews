//
//  SNMessage.h
//  sohunews
//
//  Created by chenhong on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNMessage : NSObject

@property(nonatomic,copy)NSString *msgId;
@property(nonatomic,copy)NSString *body;
@property(nonatomic,copy)NSString *timestamp;

- (id)initWithMsgId:(NSString *)msgId
               body:(NSString *)body
          timestamp:(NSString *)ts;
@end
