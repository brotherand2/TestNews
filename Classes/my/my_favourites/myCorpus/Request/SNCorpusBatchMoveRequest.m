//
//  SNCorpusBatchMoveRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCorpusBatchMoveRequest.h"

@implementation SNCorpusBatchMoveRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Corpus_BatchMove;
}

//- (NSString *)sn_customUrl {
//    return @"http://10.10.26.140:8070/api/corpusBind/batchMove.go";
//}

- (id)sn_parameters {
    return [super sn_parameters];
}


@end
