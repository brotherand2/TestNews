//
//  SNFollowUserService.h
//  sohunews
//
//  Created by lhp on 6/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SNURLRequest.h"

typedef enum {
    SNRequestTypeAddFollow,
    SNRequestTypeCancelFollow,
}SNRequestType;

@protocol SNFollowUserServiceDelegate <NSObject>
@optional

- (void)followedUserSucceedWithType:(SNRequestType) type;
- (void)followedUserFailWithError:(NSError*)error requestType:(SNRequestType) type;

@end

@interface SNFollowUserService : NSObject/*<TTURLRequestDelegate>*/{
    
//    SNURLRequest *_request;
    SNRequestType _requestType;
    id<SNFollowUserServiceDelegate> __weak _delegate;
}

@property(nonatomic,weak) id<SNFollowUserServiceDelegate> delegate;

- (void)followUserWithFpid:(NSString *) idString;
- (void)cancelFollowUserWithFpid:(NSString *) idString;
- (void)cancelFollowRequest;

@end
