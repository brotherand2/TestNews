//
//  SohuARSingleton.h
//  SohuAR
//
//  Created by sun on 2016/12/7.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SohuARSingleton : NSObject

@property(nonatomic,strong) NSDictionary * arConfigurations;
@property(nonatomic,assign) BOOL timeOut;
@property(nonatomic,assign) BOOL enableMotion;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *activityID;
@property(nonatomic,strong) NSDictionary *parameter;
@property(nonatomic,strong) NSString *suggestedFilename;

+(id)sharedInstance;

- (NSDictionary *)activityInformation;

+(void)clean;
@end
