//
//  SNPickStatisticRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

typedef NS_ENUM(NSUInteger, SNPickLinkDotGifType) {
    PickLinkDotGifTypeA,          // img8/wb/tj/a.gif
    PickLinkDotGifTypeC,          // img8/wb/tj/c.gif
    PickLinkDotGifTypeN,          // img8/wb/tj/n.gif
    PickLinkDotGifTypeS,          // img8/wb/tj/s.gif
    PickLinkDotGifTypeUsr,        // img8/wb/tj/usr.gif
    PickLinkDotGifTypeReqstat     // img8/wb/tj/reqstat.gif
};

@interface SNPickStatisticRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict
                  andStatisticType:(SNPickLinkDotGifType)statisticType;

- (instancetype)initWithDictionary:(NSDictionary *)dict
                  andStatisticType:(SNPickLinkDotGifType)statisticType
                    needAESEncrypt:(BOOL)needAESEncrypt;

@end
