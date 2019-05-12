//
//  SNCommentManager.h
//  sohunews
//
//  Created by Dan Cong on 8/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCommentManager : NSObject

+ (SNCommentManager *)defaultManager;
//- (id)assignDelegate;
- (void)sendDeleteCommentRequestByCommentId:(NSString *)commentId theId:(NSString *)theId subId:(NSString *)subId busiCode:(NSString *)busiCode;

@end
