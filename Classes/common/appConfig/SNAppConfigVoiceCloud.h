//
//  SNAppConfigVoiceCloud.h
//  sohunews
//
//  Created by jialei on 14-6-25.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigVoiceCloud : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *theCopyWriting;
@property (nonatomic, assign) int isOpen;
@property (nonatomic, strong) NSDictionary *dictInfo;

- (void)updateWithDic:(NSDictionary *)dic;

@end
