//
//  SNUploadLogRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUploadLogRequest.h"

@interface SNUploadLogRequest ()
@property (nonatomic, strong) NSData *postData;
@end

@implementation SNUploadLogRequest

- (instancetype)initWithPostData:(NSData *)postData
{
    self = [super init];
    if (self) {
        self.postData = postData;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (NSString *)sn_requestUrl {
    return [NSString stringWithFormat:SNLinks_Path_DotGifBaseUrl,@"s"];
}

- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    [formData appendPartWithHeaders:nil body:self.postData];
}

- (id)sn_parameters {
    return nil;
}
@end
