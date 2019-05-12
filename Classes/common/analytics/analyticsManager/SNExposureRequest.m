//
//  SNExposureRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNExposureRequest.h"

@interface SNExposureRequest ()

@property (nonatomic, copy) NSString *uploadString;

@end

@implementation SNExposureRequest

- (instancetype)initWithUploadString:(NSString *)uploadString
{
    self = [super init];
    if (self) {
        self.uploadString = uploadString;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeHTTP;
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_ResponseHttpManager;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/html"];
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_News_Exposure;
}

- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    [formData appendPartWithFormData:[@"exps" dataUsingEncoding:NSUTF8StringEncoding] name:@"act"];
    [formData appendPartWithFormData:[[SNAPI starDotGifParamString] dataUsingEncoding:NSUTF8StringEncoding] name:@"baseinfo"];
    [formData appendPartWithFormData:[self.uploadString dataUsingEncoding:NSUTF8StringEncoding] name:@"value"];
}

@end
