//
//  SNNetDiagnoRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNetDiagnoRequest.h"
#import "SNUserManager.h"

@interface SNNetDiagnoRequest ()

@property (nonatomic, assign) SNRequestMethod method;
@property (nonatomic, copy) NSString *netDiagoseUrl;

@end

@implementation SNNetDiagnoRequest

- (instancetype)initWithStep:(SNNetDiagnoseStep)step andRandomDate:(NSString *)randomDate
{
    self = [super init];
    if (self) {
        switch (step) {
            case SNNetDiagnoseStepOne:
                self.method = SNRequestMethodGet;
                self.netDiagoseUrl = SNLinks_Path_NetDiag_Element;
                break;
            case SNNetDiagnoseStepTwo: {
                self.method = SNRequestMethodGet;
                NSMutableString *url = [[NSMutableString alloc] initWithString:SNLinks_Path_NetDiag_Random];
                if ([SNLinks_Path_NetDiag_Random hasPrefix:@"http://"]) {
                    [url insertString:[NSString stringWithFormat:@"%@.",randomDate] atIndex:7];
                }
                if ([SNLinks_Path_NetDiag_Random hasPrefix:@"https://"]) {
                    [url insertString:[NSString stringWithFormat:@"%@.",randomDate] atIndex:8];
                }
                self.netDiagoseUrl = url;
                break;
            }
            case SNNetDiagnoseStepThree:
                self.method = SNRequestMethodPost;
                self.netDiagoseUrl = SNLinks_Path_NetDiag_Remote;
                [self.parametersDict setObject:@"c" forKey:@"c"];
                [self.parametersDict setObject:randomDate forKey:@"r"];
                break;
        }
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return self.method;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_Ldd];
}

- (NSString *)sn_requestUrl {
    return self.netDiagoseUrl;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/html",@"application/json"];
}

@end

/**
 *  -----------------------SNNetDiagnoElementRequest-----------------------
 */
@interface SNNetDiagnoElementRequest ()

@property (nonatomic, copy) NSString *netDiagoseElementUrl;

@end

@implementation SNNetDiagnoElementRequest

- (instancetype)initWithElementUrl:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.netDiagoseElementUrl = urlString;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_customUrl {
    return self.netDiagoseElementUrl;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/html",@"application/json",@"image/png",@"image/gif",@"image/jpeg"];
}

@end
