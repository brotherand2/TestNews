//
//  COMPApi.m
//  Compass
//
//  Created by 李耀忠 on 25/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPApi.h"
#import "Recorditem.pb.h"
#import "NSObject+COMPExtension.h"
#import "NSData+COMPAES.h"
#import "COMPConstant.h"

static NSString *COMPErrorDomain = @"COMPErrorDomain";


@interface COMPApi () <NSURLSessionDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSOperationQueue *operationQueue;

@end

@implementation COMPApi

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static COMPApi *instance;
    dispatch_once(&onceToken, ^{
        instance = [[COMPApi alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 30;
        configuration.allowsCellularAccess = YES;

        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_operationQueue];
    }

    return self;
}

#pragma mark - Task

+ (NSURLSessionDataTask *)post:(NSString *)url jsonData:(NSData *)data completionHandler:(void (^)(NSError *error))completionHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:@"AES,AES/ECB/PKCS7Padding" forHTTPHeaderField:@"Encrypt-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";

    NSData *encryptData = [data comp_AES256EncryptWithKey:AES_KEY];
    if (!encryptData) {
        NSError *error = [NSError errorWithDomain:COMPErrorDomain code:COMPApiErrorCodeEncrypt userInfo:nil];
        completionHandler(error);
        return nil;
    }

    NSString *base64 = [encryptData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    request.HTTPBody = [base64 dataUsingEncoding:NSUTF8StringEncoding];

#ifdef DEBUG
    COMPRecordItemListReq *listReq = [COMPRecordItemListReq parseFromData:data error:nil];
    NSDictionary *properties = [listReq comp_getProperties];
    NSLog(@"Upload data %@", properties);
#endif

    NSURLSessionDataTask *task = [[COMPApi sharedInstance].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            NSInteger errorCode;
            if (error) {
                errorCode = COMPApiErrorCodeLocal;
            } else {
                NSError *error;
                COMPRecordItemListResp *itemListResp = [COMPRecordItemListResp parseFromData:data error:&error];
                if (error) {
                    errorCode = COMPApiErrorCodePBParse;
                } else {
                    COMPCommonResp *commonResp = itemListResp.commonResp;
                    if (commonResp.errorCode == COMPOK) {
                        completionHandler(nil);
                        return;
                    } else {
                        errorCode = commonResp.errorCode;
                    }
                }
            }

            NSError *compError = [[NSError alloc] initWithDomain:COMPErrorDomain code:errorCode userInfo:nil];
            completionHandler(compError);
        }
    }];

    [task resume];

    return task;
}

@end
