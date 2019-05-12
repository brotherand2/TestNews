//
//  SNCorpusList.m
//  sohunews
//
//  Created by Valar__Morghulis on 2017/4/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCorpusList.h"
#import "SNCorpusListRequest.h"
#import "SNMyFavouriteManager.h"

//#define SN_CorpusListSavePath [NSString writeToFileWithName:@"CorpusList.plist"]
#define SN_NewCorpusListSavePath [NSString writeToFileWithName:@"NewCorpusList"]
@implementation SNCorpusList

+ (void)saveCorpusListWithCorpusListArray:(NSArray *)corpusListArray {

//    [corpusListArray writeToFile:SN_CorpusListSavePath atomically:YES];
    [NSKeyedArchiver archiveRootObject:corpusListArray toFile:SN_NewCorpusListSavePath];
}

+ (void)resaveCorpusList {
    [[[SNCorpusListRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        if (status == 200) {
            NSArray *corpusArray = [responseObject objectForKey:kMsgResult];
            [SNCorpusList saveCorpusListWithCorpusListArray:corpusArray];
        } else {
            [self deleteLocalCorpusList];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self deleteLocalCorpusList];
    }];
}

+ (void)getCorpusListWithHandler:(void(^)(NSArray *corpusList))handler {
    NSArray *corpusList = [NSKeyedUnarchiver unarchiveObjectWithFile:SN_NewCorpusListSavePath];
    if (corpusList && [corpusList isKindOfClass:[NSArray class]]) {
        if (handler) {
            handler(corpusList);
        }
    } else {
        __weak typeof(self)weakself = self;
        [self loadCorpusListFromServerWithSuccessHandler:^(NSArray *corpusList) {
            if (handler) {
                handler(corpusList);
            }
            [weakself saveCorpusListWithCorpusListArray:corpusList];
        } failure:nil];
    }
}

+ (void)loadCorpusListFromServerWithSuccessHandler:(void(^)(NSArray *corpusList))success failure:(void(^)())failure {
    [[[SNCorpusListRequest alloc] initWithDictionary:@{@"entry":@1}] send:^(SNBaseRequest *request, id responseObject) {
        
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        if (status == 200) {
            NSArray *corpusArray = [responseObject objectForKey:kMsgResult];
            if (success) {
                success(corpusArray);
            }
        } else {
            [SNMyFavouriteManager shareInstance].isHandleFavorite = NO;
            NSString *msg = [responseObject objectForKey:@"msg"];
            if (msg.length > 0) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (void)deleteLocalCorpusList {
    if ([[NSFileManager defaultManager] fileExistsAtPath:SN_NewCorpusListSavePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:SN_NewCorpusListSavePath error:nil];
    }
}

@end
