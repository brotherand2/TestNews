//
//  SohuNetworking.h
//  SohuAR
//
//  Created by sun on 2016/11/29.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ZipDownloadProgress)(float progress);
typedef void(^ZipDownloadSuccess)(NSInteger state);


@interface SohuNetworking : NSObject

+ (void)downloadArZipWithActivityID:(NSString *)activityID
                           progress:(ZipDownloadProgress)progress
                            success:(ZipDownloadSuccess) state;

+ (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(id json))success
            failure:(void (^)(NSError *error))failure;

+ (void)getWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(id json))success
            failure:(void (^)(NSError *error))failure;


+ (void)sohuARstatistics;

+ (void)downloadArZipInfoWithActivityID:(NSString *)activityID
                              progress:(ZipDownloadProgress)progress
                               success:(ZipDownloadSuccess) state;


+(void)uploadImageWithURL:(NSString *)url
                    image:(UIImage *)image
                  success:(void (^)(id json))success
                  failure:(void (^)(NSError *error))failure;



@end
