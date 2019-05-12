//
//  SNPostCommentOperation.h
//  sohunews
//
//  Created by jialei on 14-4-25.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SNPostCommentCompletedBlock)(ASIHTTPRequest *request);
@class ASIFormDataRequest;

@interface SNPostCommentOperation : NSOperation

- (id)initWithRequest:(ASIFormDataRequest *)request
            completed:(void (^)(ASIHTTPRequest *))completedBlock;

@end
