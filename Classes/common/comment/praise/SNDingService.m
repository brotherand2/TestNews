//
//  SNDingService.m
//  sohunews
//
//  Created by qi pei on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDingService.h"



@implementation SNDingService

-(void)asyncDingComment:(NSString *)commentId topicId:(NSString *)topicId {
    if (!commentId) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDingComment)]) {
            [self.delegate didFinishDingComment];
        }
    } else {
        
        [self.parametersDict setValue:commentId forKey:@"commentId"];
        [self.parametersDict setValue:topicId forKey:@"topicId"];
        [self send:^(SNBaseRequest *request, id responseObject) {
            NSInteger status = 0;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                status = [[responseObject objectForKey:kStatus] integerValue];
            }
            if (status != 403 || status != 405) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDingComment)]) {
                    [self.delegate didFinishDingComment];
                }
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        }];
    }
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Comment_Ding;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}


@end
