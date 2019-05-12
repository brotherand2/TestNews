//
//  SNPullAdRequest.m
//  
//
//  Created by 李腾 on 2017/2/9.
//
//  这是什么鬼.....

#import "SNPullAdRequest.h"
#import "SNUserLocationManager.h"
#import "SNAdManager.h"

#define kPlatformId                     (@"5")

@implementation SNPullAdRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Channel_PullAd;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}

- (id)sn_parameters {
    
    NSString * cdma_lat = [[SNUserLocationManager sharedInstance] getLatitude];
    NSString * cdma_lng = [[SNUserLocationManager sharedInstance] getLongitude];
    NSString * net = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) currentNetworkStatusString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"json" forKey:@"rt"];
    [params setValue:net forKey:@"net"];
    [params setValue:cdma_lat forKey:@"cdma_lat"];
    [params setValue:cdma_lng forKey:@"cdma_lng"];
    [params setValue:net forKey:@"net"];
    [params setValue:net forKey:@"net"];
    [params setValuesForKeysWithDictionary:[SNAdManager addAdParameters]];
    [params setValue:kPlatformId forKey:@"platformId"];
    [self.parametersDict setValuesForKeysWithDictionary:params];
    return [super sn_parameters];
}
@end
