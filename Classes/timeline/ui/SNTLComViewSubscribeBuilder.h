//
//  SNTLComViewSubscribeBuilder.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewBuilder.h"

@interface SNTLComViewSubscribeBuilder : SNTLComViewBuilder

@property(nonatomic, copy) NSString *subId;
@property(nonatomic, copy) NSString *subName;
@property(nonatomic, copy) NSString *subIcon;
@property(nonatomic, copy) NSString *subCountNum;
@property(nonatomic, assign) BOOL isSubed;

@end
