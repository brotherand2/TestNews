//
//  SNCorpusNewsRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCorpusNewsRequest.h"
#import "SNNetworkConfiguration.h"

@interface SNCorpusNewsRequest()
@property (nonatomic, strong) NSString *corpusName;
@end

@implementation SNCorpusNewsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andCorpusName:(NSString *)corpusName {
    self = [super initWithDictionary:dict];
    if (self) {
        self.corpusName = corpusName;
        if ([corpusName isEqualToString:kCorpusMyFavourite]) { //我的收藏
            self.url = SNLinks_Path_Favorite_List;
        } else if ([corpusName isEqualToString:kCorpusMyShare]) { //我的分享
            self.url = SNLinks_Path_Favorite_ShareList;
        } else if ([corpusName isEqualToString:kCorpusMyInclude]) { //我的录入
            self.url = SNLinks_Path_NewsGrab_List;
        } else { //其他收藏
            self.url = SNLinks_Path_Corpus_BindList;
        }
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

//- (NSString *)sn_customUrl {
//    if ([self.corpusName isEqualToString:kCorpusMyInclude]) {
//        return [NSString stringWithFormat:@"http://onlinetestapi.k.sohu.com/%@",self.url]; // 先写死准线上
//    } else {
//        return [NSString stringWithFormat:@"%@%@",[SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK],self.url];
//    }
//}

- (NSString *)sn_requestUrl {
    return self.url;
}

- (id)sn_parameters {
    if (![self.corpusName isEqualToString:kCorpusMyInclude]) {
        [self.parametersDict setValue:@"20" forKey:@"pageSize"];
    }
    return [super sn_parameters];
}


@end
