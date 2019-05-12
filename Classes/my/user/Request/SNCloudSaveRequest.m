//
//  SNCloudSaveRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCloudSaveRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

@implementation SNCloudSaveRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andIsCollectNews:(BOOL)isCollectNews
{
    self = [super initWithDictionary:dict];
    if (self) {
        if (isCollectNews) {
            // ========================这都啥逻辑,直接改get请求不就得了....额
            self.url = SNLinks_Path_Favorite_Save;
            self.url = [SNUtility addParamP1ToURL:self.url];
            NSString *entry = [dict stringValueForKey:@"entry" defaultValue:@""];
            NSString *h5wt = [dict stringValueForKey:kH5WebType defaultValue:@""];
            if (entry.length > 0) {
                self.url  = [self.url stringByAppendingString:[NSString stringWithFormat:@"&entry=%@",entry]];
            }
            if (h5wt.length > 0) {
                self.url  = [self.url stringByAppendingString:@"&newstype=8"];
            }
            NSString *content = [dict stringValueForKey:@"contents" defaultValue:@""];
            if (content.length > 0 && [content containsString:@"://"]) {
                NSRange range = [content rangeOfString:@"://"];
                content = [content substringFromIndex:(range.location + range.length)];
                self.url = [[content toParametersDictionary] appendParamToUrlString:self.url];
            }
            // ========================================================
        } else {
            self.url = SNLinks_Path_Favorite_Delete;
        }

    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}


- (NSString *)sn_requestUrl {
    return self.url;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"1" forKey:@"type"];
    return [super sn_parameters];
}

@end
