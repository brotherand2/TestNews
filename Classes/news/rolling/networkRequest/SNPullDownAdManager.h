//
//  SNPullDownAdManager.h
//  sohunews
//
//  Created by H on 15/4/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SNURLRequest.h"

@protocol  SNPullDownAdManagerDelegate <NSObject>

- (void)requestFnishedWithAdInfo:(NSDictionary *)info;

@end

@interface SNPullDownAdManager : NSObject

//@property (nonatomic, strong) SNURLRequest * pullAdRequest;

@property (nonatomic, weak) id <SNPullDownAdManagerDelegate> delegate;

- (void)startRequsetPullAdWithInfo:(NSString *)channelId;

@end
