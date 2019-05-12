//
//  SNSendFeedBackRequest.m
//  sohunews
//
//  Created by 李腾 on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSendFeedBackRequest.h"
#import "SNUserManager.h"
#import "SNUtility.h"

@interface SNSendFeedBackRequest ()
/**
 *  发送反馈的图片数组
 */
@property (nonatomic, strong) NSArray <UIImage *>*filesArray;

@end

@implementation SNSendFeedBackRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andImageArray:(NSArray <UIImage *>*)imgArray
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.filesArray = imgArray;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_FeedBack_Send;
}

- (id)sn_parameters {
    // 不变的参数写在请求类里
    NSMutableDictionary *paramM = [NSMutableDictionary dictionary];
    [paramM setObject:[SNAPI productId] forKey:@"productId"];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *phoneBrand = [currentDevice platformStringForSohuNews];
    
    if (phoneBrand && phoneBrand.length > 0) {
        //get carrior
        NSString *carrierName = [[SNUtility sharedUtility] getCarrierName];
        if (carrierName) {
            phoneBrand = [phoneBrand stringByAppendingFormat:@" 运营商-%@", carrierName];
        }
        
        NSString *systemVersion = [currentDevice systemVersion];
        if (systemVersion) {
            phoneBrand = [phoneBrand stringByAppendingFormat:@" 系统版本-%@", systemVersion];
        }
        
        NSString *network = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
        if (network) {
            phoneBrand = [phoneBrand stringByAppendingFormat:@" 网络-%@", network];
        }
    }
    if (phoneBrand.length > 0) {
        [paramM setObject:phoneBrand forKey:@"phoneBrand"];
    }
    
    [self.parametersDict setValuesForKeysWithDictionary:paramM]; // 存入外界可变参数
    return [super sn_parameters];
}

/*发送反馈的图片数据拼到表单里*/
- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    
    if (self.filesArray && self.filesArray.count > 1) {
        NSInteger i = 0;
        for (UIImage *image in self.filesArray) {
            if (i < self.filesArray.count -1) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0f)
                                            name:@"uploadFiles"
                                        fileName:[NSString stringWithFormat:@"feedBack _%zd",i]
                                        mimeType:@"image/jpeg"];
                i++;
            }
        }
    }

}

@end
