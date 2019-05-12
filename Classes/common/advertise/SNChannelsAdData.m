//
//  SNChannelsAdData.m
//  sohunews
//
//  Created by HuangZhen on 11/07/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNChannelsAdData.h"
#import "TMCache.h"

static const NSString * SNChannelADKey = @"SNChannelADKey";

@implementation SNChannelsAdData

- (instancetype)initWithDic:(NSDictionary *)dic adType:(SNChannelADType)type{
    if (self = [super init]) {
        _adId = [dic stringValueForKey:@"_id" defaultValue:@""];
        _adImageUrl = [dic stringValueForKey:@"image" defaultValue:@""];
        _adClickUrl = [dic stringValueForKey:@"resourceLink" defaultValue:@""];
        _adType = type;
        [self checkEnable];
        [self preLoadImage:_adImageUrl];
    }
    return self;
}

- (void)preLoadImage:(NSString *)imageUrl {
    if (imageUrl.length > 0) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[imageUrl trim]] options:SDWebImageDownloaderContinueInBackground | SDWebImageDownloaderIgnoreCachedResponse progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl toDisk:YES];
        }];
    }
}

- (BOOL)checkEnable {
    ///用户是否手动关闭过广告
    NSDate * today = [NSDate date];
    NSString * key = [NSString stringWithFormat:@"%@%d",SNChannelADKey,_adType];
    NSDate * cacheDate = [[TMCache sharedCache] objectForKey:key];
    if (cacheDate) {
        _enable = [self isGreaterDay:today thanDate:cacheDate];
    }else {
        _enable = YES;
    }
    return _enable;
}

- (void)didManualClosedAD {
    _enable = NO;
    NSDate * todayDate = [NSDate date];
    NSString * key = [NSString stringWithFormat:@"%@%d",SNChannelADKey,_adType];
    [[TMCache sharedCache] setObject:todayDate forKey:key];
}

/**
 *  今天是否大于该日期一个自然日
 */
- (BOOL)isGreaterDay:(NSDate*)today thanDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* todayComp = [calendar components:unitFlags fromDate:today];
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    if ([todayComp year] > [comp year]) {
        return YES;
    }else if ([todayComp year] == [comp year] && [todayComp month] > [comp month]){
        return YES;
    }else if ([todayComp year] == [comp year] && [todayComp month] == [comp month] && [todayComp day] > [comp day]){
        return YES;
    }else{
        return NO;
    }
}
@end
