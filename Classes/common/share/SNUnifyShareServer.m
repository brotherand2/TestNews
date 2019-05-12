//
//  SNUnifyShareServer.m
//  sohunews
//
//  Created by H on 15/7/6.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//


#define kShareTypeNews                      @"news"
#define kShareTypeJoke                      @"joke"
#define kShareTypeVote                      @"vote"
#define kShareTypeGroup                     @"group"
#define kShareTypeChannel                   @"channel"
#define kShareTypeLive                      @"live"
#define kShareTypeVideo                     @"video"
#define kShareTypeActivityPage              @"activityPage"
#define kShareTypeVideoTab                  @"videotab"
#define kShareTypeSpecial                   @"special"
#define kShareTypeRedPacket                 @"pack"
#define kShareTypeFeedSNS                   @"sns"

#define kOnTypeDefault                      @""
#define kOnTypeWeibo                        @"Weibo"
#define kOnTypeWXSession                    @"WeiXinChat"
#define kOnTypeWXTimeline                   @"WeiXinMoments"
#define kOnTypeQQChat                       @"QQChat"
#define kOnTypeQQZone                       @"QQZone"
#define kOnTypeAll                          @"All"
#define kOnTypeTaoBaoMoments                @"TaoBaoMoments"
#define kOnTypeTaoBao                       @"TaoBao"


#import "SNUnifyShareServer.h"
#import "AFHTTPRequestOperation.h"
//#import "AFNetworking.h"
#import "ASIFormDataRequest.h"
#import "SNUserManager.h"
#import "SNShareOnRequest.h"

@interface SNUnifyShareServer (){
    NSString * _currentOnType;
}

@end

@implementation SNUnifyShareServer

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (SNUnifyShareServer *)sharedInstance {
    static SNUnifyShareServer * server = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [[SNUnifyShareServer alloc] init];
    });
    return server;
}

- (void)requestWithUrl:(NSString *)url andParams:(NSDictionary *)params {
   
    [[[SNShareOnRequest alloc] initWithDictionary:params andShareOnUrl:url] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
                [self.delegate requestFromUnifyServerFinished:[self parseDictionary:responseObject]];
                self.shareonInfo = nil;
                self.activitySubPageShare = nil;
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
                [self.delegate requestFromUnifyServerFinished:nil];
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
            [self.delegate requestFromUnifyServerFinished:nil];
        }
    }];
}

//- (void)requestWithUrl:(NSString *)url {
//
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 10.f;
//    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
//    
//    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
//                [self.delegate requestFromUnifyServerFinished:[self parseDictionary:responseObject]];
//                self.shareonInfo = nil;
//                self.activitySubPageShare = nil;
//            }
//        }else{
//            if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
//                [self.delegate requestFromUnifyServerFinished:nil];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
//            [self.delegate requestFromUnifyServerFinished:nil];
//        }
//    }];
//    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//    AFHTTPRequestOperation * opration = [[AFHTTPRequestOperation alloc] initWithRequest:req];
//    [opration setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary * responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        if ([responseDic isKindOfClass:[NSDictionary class]]) {
//            if ([self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
//                [self.delegate requestFromUnifyServerFinished:[self parseDictionary:responseDic]];
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if ([self.delegate respondsToSelector:@selector(requestFromUnifyServerFinished:)]) {
//            [self.delegate requestFromUnifyServerFinished:nil];
//        }
//    }];
//    [opration start];
//    [req release];
//    [opration release];
//}
- (void)getShareInfoWithQianfan:(NSString*)type onType:(ShareOnType)shareOnType roomID:(NSString *)roomID;{
//    NSString *url = [NSString stringWithFormat:@"%@on=%@&roomId=%@", SNLinks_Path_Share_ShareOn, [self onType:shareOnType], roomID];
//    url = [url stringByAppendingFormat:@"&type=%@", type];
//    _currentOnType = [self onType:shareOnType];
//    if (![url containsString:@"p1="]) {
//        url = [url stringByAppendingFormat:@"&p1=%@", [SNUserManager getP1]];
//    }
//    [self requestWithUrl:url];
    
    _currentOnType = [self onType:shareOnType];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:[self onType:shareOnType] forKey:@"on"];
    [params setValue:roomID forKey:@"roomId"];
    [params setValue:type forKey:@"type"];
    
    [self requestWithUrl:nil andParams:params];
}

- (void)getShareInfoWithShareType:(ShareType)shareType onType:(ShareOnType)shareOnType referString:(NSString *)referString channelId:(NSString *)channelId redPacket:(NSString *)redPacket shareOn:(NSString *)shareOn showType:(NSString*)showType{
    if (shareOn.length > 0) {
        _currentOnType = [self onType:shareOnType];
        [self requestWithUrl:[shareOn URLDecodedString] andParams:nil];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:[self onType:shareOnType] forKey:@"on"];
    [params setValue:channelId forKey:@"channelId"];
    
    if (referString.length > 0) {
        [params setValuesForKeysWithDictionary:[NSString getURLParas:referString]];
    }
    NSString *type = [self shareType:shareType];
    
    if (self.shareonInfo.length > 0) {
        type = kShareTypeFeedSNS;
        [params setValuesForKeysWithDictionary:[NSString getURLParas:self.shareonInfo]];
    }
    
    if ([type isEqualToString:kShareTypeActivityPage]) {
        
        if (redPacket.length > 0) {
            [params setValuesForKeysWithDictionary:[NSString getURLParas:[redPacket URLDecodedString]]];
            type = kShareTypeRedPacket;
        }
    }
    else if ([type isEqualToString:kShareTypeRedPacket]) {
        [params setValuesForKeysWithDictionary:[NSString getURLParas:[redPacket URLDecodedString]]];
    }
    [params setValue:type forKey:@"type"];
    [params setValue:shareOn forKey:@"shareon"];
    
    _currentOnType = [self onType:shareOnType];

    if (self.activitySubPageShare) {
        [params setValue:self.activitySubPageShare forKey:@"origin"];
    }
    if (showType && showType.length>0) {
        [params setValue:showType forKey:@"showType"];
    }
    
    [self requestWithUrl:nil andParams:params];
}


//- (void)getShareInfoWithShareType:(ShareType)shareType onType:(ShareOnType)shareOnType referString:(NSString *)referString channelId:(NSString *)channelId redPacket:(NSString *)redPacket shareOn:(NSString *)shareOn showType:(NSString*)showType{
//    if (shareOn.length > 0) {
//        _currentOnType = [self onType:shareOnType];
//        [self requestWithUrl:[shareOn URLDecodedString]];
//        return;
//    }
//    NSString *url = [NSString stringWithFormat:@"%@on=%@&channelId=%@", SNLinks_Path_Share_ShareOn, [self onType:shareOnType], channelId];
//    if (referString.length > 0) {
//        url = [NSString stringWithFormat:@"%@&%@", url, referString];
//    }
//    NSString *type = [self shareType:shareType];
//    
//    if (self.shareonInfo.length > 0) {
//        type = kShareTypeFeedSNS;
//        url = [url stringByAppendingFormat:@"&%@", self.shareonInfo];
//    }
//    
//    if ([type isEqualToString:kShareTypeActivityPage]) {
//        url = [NSString stringWithFormat:@"%@&p1=%@", url, [SNUserManager getP1]];
//        if (redPacket.length > 0) {
//            url = [NSString stringWithFormat:@"%@&%@", url, [redPacket URLDecodedString]];
//            type = kShareTypeRedPacket;
//        }
//    }
//    else if ([type isEqualToString:kShareTypeRedPacket]) {
//        url = [NSString stringWithFormat:@"%@&%@", url, [redPacket URLDecodedString]];
//        url = [NSString stringWithFormat:@"%@&p1=%@", url, [SNUserManager getP1]];
//    }
//    
//    url = [url stringByAppendingFormat:@"&type=%@&shareon=%@", type, shareOn];
//    _currentOnType = [self onType:shareOnType];
//    
//    if (![url containsString:@"p1="]) {
//        url = [url stringByAppendingFormat:@"&p1=%@", [SNUserManager getP1]];
//    }
//    if (self.activitySubPageShare) {
//        url = [url stringByAppendingFormat:@"&origin=%@", self.activitySubPageShare];
//    }
//    if (showType && showType.length>0) {
//        url = [url stringByAppendingFormat:@"&showType=%@", showType];
//    }
//    
//    [self requestWithUrl:url];
//}

- (void)getShareInfoWithShareType:(ShareType)shareType onType:(ShareOnType)shareOnType referString:(NSString *)referString channelId:(NSString *)channelId redPacket:(NSString *)redPacket shareOn:(NSString *)shareOn {
    [self getShareInfoWithShareType:shareType onType:shareOnType referString:referString channelId:channelId redPacket:redPacket shareOn:shareOn showType:nil];
}

- (NSString *)onType:(ShareOnType)shareOnType{
    NSString * shareOnTypeString = @"";
    switch (shareOnType) {
        case OnTypeDefault:
            shareOnTypeString = kOnTypeDefault;
            break;
        case OnTypeWeibo:
            shareOnTypeString = kOnTypeWeibo;
            break;
        case OnTypeWXSession:
            shareOnTypeString = kOnTypeWXSession;
            break;
        case OnTypeWXTimeline:
            shareOnTypeString = kOnTypeWXTimeline;
            break;
        case OnTypeQQChat:
            shareOnTypeString = kOnTypeQQChat;
            break;
        case OnTypeQQZone:
            shareOnTypeString = kOnTypeQQZone;
            break;
        case OnTypeTaoBao:
            shareOnTypeString = kOnTypeTaoBao;
            break;
        case OnTypeTaoBaoMoments:
            shareOnTypeString = kOnTypeTaoBaoMoments;
            break;
        case OnTypeAll:
            shareOnTypeString = kOnTypeAll;
            break;
            
        default:
            break;
    }
    return shareOnTypeString;
}

- (NSString *)shareType:(ShareType)shareType{
    NSString * shareTypeString = @"";
    switch (shareType) {
        case ShareTypeNews:
            shareTypeString = kShareTypeNews;
            break;
        case ShareTypeVote:
            shareTypeString = kShareTypeVote;
            break;
        case ShareTypeVideo:
            shareTypeString = kShareTypeVideo;
            break;
        case ShareTypeLive:
            shareTypeString = kShareTypeLive;
            break;
        case ShareTypeGroup:
            shareTypeString = kShareTypeGroup;
            break;
        case ShareTypeChannel:
            shareTypeString = kShareTypeChannel;
            break;
        case ShareTypeActivityPage:
            shareTypeString = kShareTypeActivityPage;
            break;
        case ShareTypeVideoTab:
            shareTypeString = kShareTypeVideoTab;
            break;
        case ShareTypeSpecial:
            shareTypeString = kShareTypeSpecial;
            break;
        case ShareTypeRedPacket:
            shareTypeString = kShareTypeRedPacket;
            break;
        case ShareTypeJoke:
            shareTypeString = kShareTypeJoke;
            break;
        default:
            break;
    }
    return shareTypeString;
}

- (NSDictionary *)parseDictionary:(NSDictionary *)originDic{
    _currentOnType = _currentOnType.length > 0 ? _currentOnType : @"Default" ;
    NSDictionary * dic = originDic[_currentOnType];
    return dic;
}

- (void)dealloc {
    self.delegate = nil;
    _currentOnType = nil;
}

@end
