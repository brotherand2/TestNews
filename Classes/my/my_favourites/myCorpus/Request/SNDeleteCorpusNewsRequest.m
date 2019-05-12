//
//  SNDeleteCorpusNewsRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDeleteCorpusNewsRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

@implementation SNDeleteCorpusNewsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andCorpusName:(NSString *)corpusName {
    self = [super initWithDictionary:dict];
    if (self) {
        if ([corpusName isEqualToString:kCorpusMyFavourite]) { //我的收藏
            self.url = SNLinks_Path_Favorite_DeleteV2;
        } else if ([corpusName isEqualToString:kCorpusMyShare]) { //我的分享
            self.url = SNLinks_Path_Favorite_DelShare;
        } else { //其他收藏
            self.url = SNLinks_Path_Corpus_BindDelete;
        }
        
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    return self.url;
}

- (id)sn_parameters {
    return [super sn_parameters];
}

@end
