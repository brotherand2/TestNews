//
//  SNCorpusListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCorpusListRequest.h"

@implementation SNCorpusListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Corpus_List;
}

- (id)sn_parameters {
    [self.parametersDict setValue:@"" forKey:@"fid"];
    return [super sn_parameters];
}


@end
