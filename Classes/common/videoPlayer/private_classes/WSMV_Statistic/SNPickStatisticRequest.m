//
//  SNPickStatisticRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPickStatisticRequest.h"
#import "SNClientRegister.h"
#import "SNUserLocationManager.h"
#import "SNRedPacketManager.h"
#import "SNUserManager.h"

static NSString *cipherText = nil;

@interface SNPickStatisticRequest ()

@property (nonatomic, assign) SNPickLinkDotGifType statisticType;
@property (nonatomic, assign) BOOL needAESEncrypt;

@end

@implementation SNPickStatisticRequest

/**
 初始化方法(此方法默认拼接加密参数)
 
 @param dict 外部可变参数
 @param statisticType SNPickLinkDotGifType
 @return request
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict
                  andStatisticType:(SNPickLinkDotGifType)statisticType
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.statisticType = statisticType;
        self.needAESEncrypt = YES;
    }
    return self;
}


/**
 初始化方法
 
 @param dict 外部可变参数
 @param statisticType SNPickLinkDotGifType
 @param needAESEncrypt 是否需要拼接加密参数
 @return request
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict
                  andStatisticType:(SNPickLinkDotGifType)statisticType
                    needAESEncrypt:(BOOL)needAESEncrypt
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.statisticType = statisticType;
        self.needAESEncrypt = needAESEncrypt;
    }
    return self;
}



- (NSDictionary *)starDotGifParams {
    //移动端ID
    NSString *cid = [[SNClientRegister sharedInstance].uid copy];
    cid = (cid.length > 0) ? cid : @"";
    //移动端系统平台
    NSString *platform = @"ios";
    //App版本号
    NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] copy];
    version = (version.length > 0) ? version : @"other";
    //渠道号
    NSString *marketID = [NSString stringWithFormat:@"%d", [SNUtility marketID]];
    marketID = (marketID.length > 0) ? marketID : @"";
    //网络状态
    self.needCurrentNetStatusParam = YES;

    //产品ID
    NSString *productID = [[SNAPI productId] copy];
    productID = (productID.length > 0) ? productID : @"";
    //gbcode(通过location.go获取)
    //上报时的时间戳
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:cid       forKey:@"c"];
    [params setValue:platform  forKey:@"p"];
    [params setValue:version   forKey:@"v"];
    [params setValue:marketID  forKey:@"h"];
    [params setValue:productID forKey:@"u"];
    [params setValue:[SNUserLocationManager sharedInstance].currentChannelGBCode forKey:@"gbcode"];
    [params setValue:[NSString stringWithFormat:@"%f",interval*1000] forKey:@"t"];
    
    return params;
}

- (NSDictionary *)addAESEncryptParams {
    NSString *cid = [SNUserManager getCid];
    NSString *nowTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *verifyToken = [NSString stringWithFormat:@"%@_%@", cid, nowTime];
    NSString *plainText = [[NSString alloc] initWithFormat:@"cid=%@&verifytoken=%@&v=%@&p=%@&h=%d", cid, verifyToken, [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey], @"iOS", [SNUtility marketID]];//明文
    if (!cipherText) {
        cipherText = [[SNRedPacketManager sharedInstance] aesEncryptWithData:plainText];//密文
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:verifyToken forKey:@"verifytoken"];
    [params setValue:cipherText forKey:@"ciphertext"];
    [params setValue:[[SNRedPacketManager sharedInstance] getKeyVersion] forKey:@"keyv"];
    
    return params;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_PicK];
}

- (NSString *)sn_requestUrl {
    NSString *statisticTypeMapStr = nil;
    
    switch (self.statisticType) {
        case PickLinkDotGifTypeA:
            statisticTypeMapStr = @"a";
            break;
        case PickLinkDotGifTypeC:
            statisticTypeMapStr = @"c";
            break;
        case PickLinkDotGifTypeN:
            statisticTypeMapStr = @"n";
            break;
        case PickLinkDotGifTypeS:
            statisticTypeMapStr = @"s";
            break;
        case PickLinkDotGifTypeUsr:
            statisticTypeMapStr = @"usr";
            break;
        case PickLinkDotGifTypeReqstat:
            statisticTypeMapStr = @"reqstat";
            break;
    }

    return [NSString stringWithFormat:SNLinks_Path_DotGifBaseUrl,statisticTypeMapStr];
}

- (id)sn_parameters {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [params setValuesForKeysWithDictionary:[self starDotGifParams]];
    if (self.needAESEncrypt) {
        [params setValuesForKeysWithDictionary:[self addAESEncryptParams]];
    }
    
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}

@end
