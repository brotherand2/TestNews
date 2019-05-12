//
//  NotificationService.m
//  sohunewsNotificationExtention
//
//  Created by yangln on 2017/8/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo =  self.bestAttemptContent.userInfo;
    NSDictionary *apsDict = userInfo[@"aps"];
    NSString *sourceUrl = [self URLDecodedString:apsDict[@"sourceUrl"]];
    NSString *type = apsDict[@"type"];
    if (sourceUrl.length > 0) {
        [self loadAttachmentForUrlString:sourceUrl withType:type completionHandle:^(UNNotificationAttachment *attach) {
            if (attach) {
                self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }
    else {
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

- (void)loadAttachmentForUrlString:(NSString *)urlStr
                          withType:(NSString *)type
                  completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler {
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                        [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
                        
                        NSError *attachmentError = nil;
                        attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                        if (attachmentError) {
                            NSLog(@"UNNotificationAttachment error:%@", attachmentError.localizedDescription);
                        }
                    }
                    else {
                        NSLog(@"load push image error:%@", error.localizedDescription);
                    }
                    completionHandler(attachment);
                }] resume];
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    else if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    else {
        ext = @"png";
    }
    return [@"." stringByAppendingString:ext];
}

- (NSString*)URLDecodedString:(NSString*)str {
    return [str stringByRemovingPercentEncoding];
}

@end
