//
//  SNActiveTipsService.h
//  sohunews
//
//  Created by 赵青 on 2016/11/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNActiveTipsServiceDelegate <NSObject>

- (void)didSucceedToRequestActiveTips:(NSDictionary *)activityInfo;
- (void)didFailedToRequestActiveTips;

@end

@interface SNActiveTipsService : NSObject
@property (nonatomic, weak) id<SNActiveTipsServiceDelegate> delegate;

- (void)requestActivityInfo;

@end
