//
//  SNDeleteCorpusRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDeleteCorpusRequest.h"

@implementation SNDeleteCorpusRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Corpus_Delete;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
