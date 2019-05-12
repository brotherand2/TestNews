//
//  SNUninterestedItem.h
//  sohunews
//
//  Created by 赵青 on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUninterestedItem : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray   *reasonData;
@property (nonatomic, copy)   NSString  *token;

@end

@interface SNReasonItem : NSObject

@property (nonatomic, copy) NSString *pos;
@property (nonatomic, copy) NSString *rid;
@property (nonatomic, copy) NSString *rname;

@end
