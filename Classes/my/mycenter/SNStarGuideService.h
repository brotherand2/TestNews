//
//  SNStarGuideService.h
//  sohunews
//
//  Created by weibin cheng on 13-12-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNURLRequest.h"


@protocol SNStarGuideServiceDelegate <NSObject>
@optional

-(void)requestStarDidFinished;

-(void)followStarDidFinished:(NSInteger)count;

@end

@interface SNStarGuideService : NSObject<TTURLRequestDelegate>

@property(nonatomic, weak)    id<SNStarGuideServiceDelegate> delegate;
@property(nonatomic, readonly)  NSMutableArray* starArray;

+(SNStarGuideService*)shareInstance;

-(void)startReqeustStar;

-(void)followAllStar;

-(SNUserinfoEx*)getStarByIndex:(NSInteger)index;
@end
