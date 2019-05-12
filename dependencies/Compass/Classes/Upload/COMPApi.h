//
//  COMPApi.h
//  Compass
//
//  Created by 李耀忠 on 25/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *COMPErrorDomain;

typedef NS_ENUM(NSInteger, COMPApiErrorCode) {
    COMPApiErrorCodeLocal = -1,

    COMPApiErrorCodeUndefined = 0,
    COMPApiErrorCodeParamInvalid = 400,
    COMPApiErrorCodeEncrypt = 480,
    COMPApiErrorCodePBParse = 481,
    COMPApiErrorCodeServerInternalException = 500,
};

@interface COMPApi : NSObject

+ (NSURLSessionDataTask *)post:(NSString *)url jsonData:(NSData *)data completionHandler:(void (^)(NSError *error))completionHandler;

@end
