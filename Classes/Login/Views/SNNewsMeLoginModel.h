//
//  SNNewsMeLoginModel.h
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SNNewsMeLoginIcon @"SNNewsMeLoginIcon"
#define SNNewsMeLoginTitle @"SNNewsMeLoginTitle"


@interface SNNewsMeLoginModel : NSObject

@property (nonatomic,strong) NSMutableArray* dataArr;

-(instancetype)initData:(NSDictionary*)data;

@end
