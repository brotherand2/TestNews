//
//  SNNextSubRequestManager.h
//  sohunews
//
//  Created by H on 15/4/20.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@protocol  SNNextSubRequestManagerDelegate <NSObject>

- (void)nextSubDidFinishedRequest:(NSDictionary *)responseDictionary;

@end

@interface SNNextSubRequestManager : NSObject
{
    AFHTTPRequestOperation *_afOperation;
}

@property (nonatomic, copy) NSString * nextAbstract;
@property (nonatomic, copy) NSString * nextLink2;
@property (nonatomic, copy) NSString * nextNewsId;
@property (nonatomic, copy) NSString * nextTitle;
@property (nonatomic, copy) NSString * updateTime;
@property (nonatomic, copy) NSString * termId;
@property (nonatomic, strong) NSMutableArray * subNewsList;

@property (nonatomic, weak) id <SNNextSubRequestManagerDelegate> delegate;

+ (SNNextSubRequestManager *)sharedInstance;

- (void)startRequestWithQuery:(NSDictionary *)query delegate:(id <SNNextSubRequestManagerDelegate>) delegate ;

@end
