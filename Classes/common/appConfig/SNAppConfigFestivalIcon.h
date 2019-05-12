//
//  SNAppConfigFestivalIcon.h
//  sohunews
//
//  Created by H on 15/4/7.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigFestivalIcon : NSObject

@property (nonatomic, assign) BOOL hasFestivalIcon;

@property (nonatomic, copy) NSString * festivalIconUrl;

- (void)updateWithDic:(NSDictionary *)dic;

@end

