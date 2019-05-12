//
//  SNNewsMeLoginModel.m
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsMeLoginModel.h"

#import "WXApi.h"

@implementation SNNewsMeLoginModel

-(instancetype)initData:(NSDictionary*)data{
    if (self = [super init]) {
        self.dataArr = [[NSMutableArray alloc] init];
        
        [self addData:data];
    }
    return self;
}

- (void)addData:(NSDictionary*)data{
   
    [_dataArr addObject:@{SNNewsMeLoginIcon:@"icoland_melogin_sj_v5.png",SNNewsMeLoginTitle:@"mobile"}];
    if ([WXApi isWXAppInstalled]) {
        [_dataArr addObject:@{SNNewsMeLoginIcon:@"icoland_melogin_wx_v5.png",SNNewsMeLoginTitle:@"weixin"}];
    }
    [_dataArr addObject:@{SNNewsMeLoginIcon:@"icoland_melogin_qq_v5.png",SNNewsMeLoginTitle:@"qq"}];

    [_dataArr addObject:@{SNNewsMeLoginIcon:@"icoland_melogin_sohu_v5.png",SNNewsMeLoginTitle:@"sohu"}];
    [_dataArr addObject:@{SNNewsMeLoginIcon:@"icoland_melogin_xl_v5.png",SNNewsMeLoginTitle:@"weibo"}];
}


@end
