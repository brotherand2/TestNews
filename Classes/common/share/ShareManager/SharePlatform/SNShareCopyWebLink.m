//
//  SNShareCopyWebLink.m
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareCopyWebLink.h"

@implementation SNShareCopyWebLink

- (void)shareTo:(NSDictionary *)dic Upload:(UploadBlock)method{
    
    if (method) {
        self.uploadMethod = method;
    }
    
    if (self.shareData && [self.shareData isKindOfClass:[NSDictionary class]]) {
        NSString* shareLink = [self.shareData objectForKey:@"webUrl"];
        if (shareLink.length > 0) {
            [self copyLink:shareLink];
        }
        else{
            shareLink = [self.shareData objectForKey:kShareInfoKeyMediaUrl];
            if(shareLink.length > 0){
                [self copyLink:shareLink];
            }
        }
    }
}

- (void)copyLink:(NSString*)link{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = link;
    [[SNCenterToast shareInstance] showCenterToastWithTitle:kCopyLinkSucceed toUrl:nil mode:SNCenterToastModeOnlyText];
}

@end
