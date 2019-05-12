//
//  SNValidateMobileNumModel.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNValidateMobileNumModel.h"

@implementation SNValidateMobileNumModel

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

/** 验证手机号有效
 */
- (void)isValidateMobileNum:(NSString *)phone Successed:(void (^)(NSDictionary* resultDic))method {
    
    /*
     //手机号正确：30020001
     //手机号错误：30020002
     //手机号为空：30020003
     */
    
    [[[SNMobileValidateRequest alloc] initWithDictionary:@{@"mobileNo":phone}] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSDictionary* re_dic = nil;
        
        NSString *status = [responseObject stringValueForKey:@"statusCode" defaultValue:nil];
        if ([status isEqualToString:@"30020001"]) {
            if (method) {
                re_dic = @{@"success":@"1"};
                method(re_dic);
                return;
            }
        }
        else if ([status isEqualToString:@"30020002"] || [status isEqualToString:@"30020003"]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入正确的手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
            
        }
        
        if (method) {
            re_dic = @{@"success":@"0"};
            method(re_dic);
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"MobileValidate: %@",error.localizedDescription);
        NSDictionary* re_dic = @{@"success":@"0"};
        if (method) {
            method(re_dic);
        }
    }];
}

@end
