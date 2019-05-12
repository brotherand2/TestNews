//
//  SNFollowUserModel.h
//  sohunews
//
//  Created by weibin cheng on 13-12-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SNURLRequest.h"

@protocol SNFollowUserModelDelegate <NSObject>

-(void)requestUserModelDidFinish:(BOOL)hasMore;
-(void)requestUserModelDidNetworkError:(NSError*)error;
-(void)requestUserModelDidServerError:(NSString*)msg;

@end

@interface SNFollowUserModel : NSObject/*<TTURLRequestDelegate>*/
@property(nonatomic, assign) BOOL isFollowing;// 关注or粉丝
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, readonly) NSMutableArray* userArray;
@property(nonatomic, weak) id<SNFollowUserModelDelegate> delegate;
@property(nonatomic, strong) NSDate* lastRequestDate;

-(id)initWithPid:(NSString*)pid;
-(void)refresh;
-(void)loadMore;
@end
