//
//  SNCloudGetRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCloudGetRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

@interface SNCloudGetRequest ()

@property (nonatomic, assign)SNCloudGetType cloudGetType;

@end

@implementation SNCloudGetRequest

- (instancetype)initWithCloudGetType:(SNCloudGetType)cloudGetType
{
    self = [super init];
    if (self) {
        self.cloudGetType = cloudGetType;
        switch (cloudGetType) {
            case SNCloudGetAll:
            case SNCloudGetChannels:
                self.url = SNLinks_Path_Cloud_Get;
                break;
            case SNCloudGetFavourite:
                self.url = SNLinks_Path_Favorite_Get;
                break;
        }
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return self.url;
}

- (id)sn_parameters {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    switch (self.cloudGetType) {
        case SNCloudGetAll: {
            [params setValue:@"1,2,3" forKey:@"type"];
            [params setValue:@"1" forKey:@"page"];
            [params setValue:@"10000" forKey:@"pageSize"];
        }
            break;
        case SNCloudGetChannels: {
            [params setValue:@"2,3" forKey:@"type"];
            [params setValue:@"1" forKey:@"page"];
            [params setValue:@"10000" forKey:@"pageSize"];
        }
            break;
        case SNCloudGetFavourite: { // 收藏
            [params setValue:@"1" forKey:@"type"];
            NSInteger pageNum = [[[NSUserDefaults standardUserDefaults] objectForKey:kFavouritePageTag] integerValue];
            [params setValue:[NSString stringWithFormat:@"%zd",pageNum] forKey:@"page"];
            [params setValue:@"20" forKey:@"pageSize"];
        }
            break;
    }
    [self.parametersDict setValuesForKeysWithDictionary:params];
    return [super sn_parameters];
}

//lijian 20170925 强制切https
- (NSString *)sn_baseUrl {
    return SNLinks_Https_Domain(SNLinks_Domain_BaseApiK);
}

@end
