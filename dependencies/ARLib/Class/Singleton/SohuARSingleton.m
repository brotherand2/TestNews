//
//  SohuARSingleton.m
//  SohuAR
//
//  Created by sun on 2016/12/7.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuARSingleton.h"
#import "SohuFileManager.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static dispatch_once_t onceToken;

@implementation SohuARSingleton

+(void)clean{
    onceToken=0;
}

+(id)sharedInstance{
    static  SohuARSingleton *arSingleton=nil;
    dispatch_once(&onceToken, ^{
        arSingleton=[[SohuARSingleton alloc]init];
        arSingleton.suggestedFilename=@"Resources";
    });
    return arSingleton;
}

#pragma mark - setter
-(void)setArConfigurations:(NSDictionary *)arConfigurations{
    _arConfigurations=arConfigurations;
}

- (NSDictionary *)activityInformation{
    NSDictionary *dic=@{@"activityID":self.activityID,
                        @"userID":self.userID,
                        @"deviceType":@"ios",
                        @"parameter":self.parameter};
    return dic;
}

#pragma mark - getter
-(NSString *)userID{
    if (_userID==nil) {
        _userID=@"";
    }
    return _userID;
}

-(NSString *)activityID{
    if (_activityID==nil) {
        _activityID=@"";
    }
    return _activityID;
}

-(NSDictionary *)parameter{

    if (_parameter==nil) {
        _parameter=@{};
    }
    return _parameter;

}

#pragma mark - setter

#pragma mark - other
-(id)init{
    if (self = [super init]) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return self;
}
@end
