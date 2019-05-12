//
//  SNNewsAdInfo.m
//  sohunews
//
//  Created by jojo on 13-11-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNewsAdInfo.h"
#import "NSObject+YAJL.h"

@implementation SNNewsAdInfo

- (void)dealloc {
     //(_adId);
     //(_adUrl);
     //(_adAppId);
     //(_downloadUrl);
     //(_iconOpenUrl);
     //(_iconDownloadUrl);
     //(_iconWidth);
     //(_iconHeight);
}

- (NSString *)toJsonString {
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    
    if (self.adId) {
        [jsonDic setObject:self.adId forKey:@"adId"];
    }
    if (self.adUrl) {
        [jsonDic setObject:self.adUrl forKey:@"adUrl"];
    }
    if (self.adAppId) {
        [jsonDic setObject:self.adAppId forKey:@"adAppId"];
    }
    if (self.downloadUrl) {
        [jsonDic setObject:self.downloadUrl forKey:@"downloadUrl"];
    }
    if (self.iconOpenUrl) {
        [jsonDic setObject:self.iconOpenUrl forKey:@"iconOpenUrl"];
    }
    if (self.iconDownloadUrl) {
        [jsonDic setObject:self.iconDownloadUrl forKey:@"iconDownloadUrl"];
    }
    if (self.iconWidth) {
        [jsonDic setObject:self.iconWidth forKey:@"iconWidth"];
    }
    if (self.iconHeight) {
        [jsonDic setObject:self.iconHeight forKey:@"iconHeight"];
    }
    
    return [jsonDic yajl_JSONString];
}

- (id)initWithJsonDic:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.adId = [json stringValueForKey:@"adId" defaultValue:nil];
        self.adUrl = [json stringValueForKey:@"adUrl" defaultValue:nil];
        self.adAppId = [json stringValueForKey:@"adAppId" defaultValue:nil];
        self.downloadUrl = [json stringValueForKey:@"downloadUrl" defaultValue:nil];
        self.iconOpenUrl = [json stringValueForKey:@"iconOpenUrl" defaultValue:nil];
        self.iconDownloadUrl = [json stringValueForKey:@"iconDownloadUrl" defaultValue:nil];
        self.iconWidth = [json stringValueForKey:@"iconWidth" defaultValue:nil];
        self.iconHeight = [json stringValueForKey:@"iconHeight" defaultValue:nil];
    }
    return self;
}

- (NSString *)iconUrlString {
    return (self.adUrl && [SNUtility isWhiteListURL:[NSURL URLWithString:self.adUrl]]) ? self.iconOpenUrl : self.iconDownloadUrl;
}

- (BOOL)isValid {
    return (self.adId.length > 0);
}

@end
