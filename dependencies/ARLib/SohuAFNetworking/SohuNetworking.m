//
//  SohuNetworking.m
//  SohuAR
//
//  Created by sun on 2016/11/29.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuNetworking.h"
#import "AFNetworking.h"
#import "SohuARMacro.h"
#import "SohuARSingleton.h"
#import "SohuConfigurations.h"
#import "ZipArchive.h"

@interface SohuNetworking ()<ZipArchiveDelegate>

@property(nonatomic,assign) ZipDownloadSuccess success;

@end

@implementation SohuNetworking


+ (void)downloadArZipWithFileUrlString:(NSString *)fileUrlString
                           progress:(ZipDownloadProgress)progress
                            success:(ZipDownloadSuccess) state{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:fileUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
      NSURLSessionDownloadTask *task=[manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
          NSURL *pathURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
          return [pathURL URLByAppendingPathComponent:[response suggestedFilename]];
      } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
          if (!error){
              NSString *path2 =[NSString stringWithFormat:@"%@%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument];
              NSFileManager* fm = [NSFileManager defaultManager];
              [fm removeItemAtPath:path2 error:nil];
              [fm createDirectoryAtPath:path2 withIntermediateDirectories:YES attributes:nil error:nil];
              NSString *zipPath=[filePath absoluteString];
              zipPath=[zipPath substringFromIndex:7];
              ZipArchive *zip	= [[ZipArchive alloc] init];
              zip.delegate=[SohuARSingleton sharedInstance];
              zip.needUnzipProcessNotify	= YES;
              if ([zip UnzipOpenFile:zipPath]) {
                  if ([zip UnzipFileTo:path2 overWrite:YES]) {
                      if (state) {
                          state(1);
                      }else{
                          state(0);
                      }
                      [self removeZip:zipPath];
                  }else{
                      state(0);
                  }
                [zip UnzipCloseFile];
              }
            
          }else{
              state(0);
          }

      }];
    [task resume];
}

+(void)removeZip:(NSString*)activityPath{
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:activityPath error:nil];
}

+ (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(id json))success
            failure:(void (^)(NSError *error))failure{
    url=[NSString stringWithFormat:@"%@/%@",khost,url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
    }];
}

+ (void)getWithURL:(NSString *)url
            params:(NSDictionary *)params
           success:(void (^)(id json))success
           failure:(void (^)(NSError *error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    url=[NSString stringWithFormat:@"%@\%@",khost,url];
    [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
         success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
    }];
}

+ (void)sohuARstatistics{
    [self postWithURL:@"/user/statistic" params:[SohuConfigurations sohuConfigurations] success:^(id json) {
    } failure:^(NSError *error) {
    }];
}


+ (void)downloadArZipInfoWithActivityID:(NSString *)activityID
                           progress:(ZipDownloadProgress)progress1
                            success:(ZipDownloadSuccess) state1{
    [self getWithURL:@"activity/info"
              params:[[SohuARSingleton sharedInstance] activityInformation]
             success:^(id json) {
                 NSDictionary *dic=json;
                 if (([dic[@"result_code"] boolValue]==0) &&[dic[@"data"] isKindOfClass:[NSDictionary class]]) {
                     if (![dic[@"data"] isKindOfClass:[NSDictionary class]]) {
                         state1(0);
                         return ;
                     }
                     NSString *filerPath=dic[@"data"][@"filePath"];
                     if ([filerPath length]>0) {
                         [self downloadArZipWithFileUrlString:filerPath progress:^(float progress) {
                             progress1(progress);
                         } success:^(NSInteger state) {
                             state1(state);
                         }];
                     }else{
                         state1(0);
                     }
                 }else{
                     state1(0);
                 }
    } failure:^(NSError *error) {
        state1(0);
    }];
}

+(void)uploadImageWithURL:(NSString *)url
                   image:(UIImage *)image
                    success:(void (^)(id json))success
                    failure:(void (^)(NSError *error))failure{
    
    url=[NSString stringWithFormat:@"%@\%@",khost,url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.png",[formatter stringFromDate:[NSDate date]]];
        [formData appendPartWithFileData:imageData name:@"vr" fileName:fileName mimeType:@"image/png"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error) {
            failure(error);
        }
    }];
}

-(void)FileUnzipped:(NSString *)filePath fromZipArchive:(ZipArchive *)zip{
    NSLog(@"*************************!!!!!!!!!!!!!!!!!!!!!!%@",filePath);
}

@end
