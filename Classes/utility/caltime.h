//
//  caltime.h
//  qiyi
//
//  Created by luther.cui@gmail.com on 12-5-30.
//  Copyright (c) 2012年 崔道长. All rights reserved.
//


@interface caltime : NSObject
{
    NSMutableDictionary * timer_cap;
}
@property (atomic, retain)  NSMutableDictionary * timer_cap;

- (NSString *)set_cal_time:(NSString *)key;
- (int)end_cal_time:(NSString *)key;


@end




@interface  caltime(Singleton)

+ (caltime*)sharedInstance;

@end
