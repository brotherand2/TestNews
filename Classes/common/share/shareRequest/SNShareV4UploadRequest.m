//
//  SNShareV4UploadRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareV4UploadRequest.h"
#import "SNUserManager.h"

@interface SNShareV4UploadRequest ()
@property (nonatomic, copy) NSString *shareImagePath;
@property (nonatomic, assign) BOOL isNotRealShare;
@end

@implementation SNShareV4UploadRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict  isNotRealShare:(BOOL)isNotRealShare andShareImagePath:(NSString *)shareImagePath
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.isNotRealShare = isNotRealShare;
        if (shareImagePath && shareImagePath.length > 0) {
            self.shareImagePath = shareImagePath;
        }
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK];
}

- (NSString *)sn_requestUrl {
    NSString* pid = @"-1";
    if ([SNUserManager isLogin]) {
        pid = [SNUserManager getPid];
    }
    return [NSString stringWithFormat:@"%@?mainPassport=%@&p1=%@&share=%@&pid=%@",SNLinks_Path_Share_WebImageV4,[SNUserManager getUserId],[SNUserManager getP1],@(self.isNotRealShare),pid];
}

- (id)sn_parameters {
    
    return self.parametersDict;
}

- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    if (self.shareImagePath.length > 0) {
        NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:self.shareImagePath], 0.5);
        if (imageData) {
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"commentFile" mimeType:@"image/jpeg"];
            SNDebugLog(@"shareImagePath = %@", self.shareImagePath);
        }

    }
}

@end
