//
//  SNSpecialADTools.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialADTools.h"
#import "SNSpecialADResourceRequest.h"

@implementation SNSpecialADTools

/**
 *  今天是否大于该日期一个自然日 每天9点为一个自然日
 */
+ (BOOL)isNaturalDaythanDate:(NSDate*)date
{
    return  [self isNaturalDaythanDate:date withTimePoint:@"0900"];
}

/**
 判断现在距离date是否超过一个自然日

 @param date 之前的一个时间戳
 @param timePoint 自然日的时间分割点 例如:0830为8点半
 @return YES 超过一个自然日
 */
+ (BOOL)isNaturalDaythanDate:(NSDate*)date withTimePoint:(NSString *)timePoint {
    if (!date || timePoint.length == 0) {
        return YES;//这里由于都是用于判断广告显示，广告默认不展示，所以默认return YES
    }
    NSString * hourStr, * minuteStr;
    [self analyseTimePoint:timePoint withHour:&hourStr minute:&minuteStr];
    NSInteger pointHour = hourStr.integerValue;
    NSInteger pointMinute = minuteStr.integerValue;
    
    NSDate *today = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* todayComp = [calendar components:unitFlags fromDate:today];
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    if (todayComp.year > comp.year) {
        return YES;
    }else if (todayComp.year == comp.year && todayComp.month > comp.month){
        return YES;
    }else if (todayComp.year == comp.year && todayComp.month == comp.month && todayComp.day > comp.day){
        if (todayComp.day - comp.day == 1) {
            //超过了一天
            if (todayComp.hour == pointHour) {
                return todayComp.minute >= pointMinute;
            }else{
                return today.hour > pointHour;
            }
        }else {
            return YES;
        }
    }else if (todayComp.year == comp.year && todayComp.month == comp.month && todayComp.day == comp.day){
        //同一天
        BOOL nowIsMoreThanTimePoint = NO;
        BOOL dateIsLessThanTimePoint = NO;
        if (todayComp.hour == pointHour) {
            nowIsMoreThanTimePoint = todayComp.minute >= pointMinute;
        }else {
            nowIsMoreThanTimePoint = todayComp.hour > pointHour;
        }
        if (comp.hour == pointHour) {
            dateIsLessThanTimePoint = comp.minute < pointMinute;
        }else {
            dateIsLessThanTimePoint = comp.hour < pointHour;
        }
        
        return nowIsMoreThanTimePoint && dateIsLessThanTimePoint;
        
    }else{
        return NO;
    }
}

+ (void)analyseTimePoint:(NSString *)timePoint withHour:(NSString **)hour minute:(NSString **)minute {
    if (timePoint.length > 3) {
        *hour = [timePoint substringToIndex:2];
        *minute = [timePoint substringFromIndex:2];
    }
}

+ (void)fetchAdConfigArticleAd:(SNSpecialADToolsFetchArticleAdCompleted)articleAdsBlock channelAd:(SNSpecialADToolsFetchChannelAdCompleted)channelAdsBlock {
    //request on server
    SNSpecialADResourceRequest * req = [[SNSpecialADResourceRequest alloc] init];
    [req send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * responseDic = (NSDictionary *)responseObject;
            NSString * reqSuccessed = [responseDic stringValueForKey:@"isSuccess" defaultValue:nil];
            if ([reqSuccessed isEqualToString:@"S"]) {
                NSDictionary * response = [responseDic dictionaryValueForKey:@"response" defalutValue:nil];
                NSArray * articleAds = [response arrayValueForKey:@"articleMaterials" defaultValue:nil];
                NSArray * channelAds = [response arrayValueForKey:@"channelMaterials" defaultValue:nil];
                articleAdsBlock(articleAds);
                channelAdsBlock(channelAds);
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        
    }];
}

+ (void)preDownloadAdResourceWithUrl:(NSString *)url md5Key:(NSString *)md5Key majorKey:(NSString *)mkey {
    
    //WIFI下预先缓存广告物料
    //检查网络环境，WIFI则开始下载物料
    Reachability *reachability = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
    NetworkStatus currentNetStatus = [reachability currentReachabilityStatus];
    if (currentNetStatus != ReachableViaWiFi) {
        return;
    }
    
    if (url.length <= 0 || mkey.length <= 0 || md5Key.length <= 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *reqUrl = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:reqUrl];
        request.timeoutInterval = 500;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        NSString *path = [SNUtility getDocumentPath];
        path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
        path = [path stringByAppendingPathComponent:mkey];
        BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//        NSString *filePath = [path stringByAppendingPathComponent:kSpecialActivityDocumentZipName];
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"activity%@.zip",mkey]];

        /* 下载的数据 */
        if (data != nil){
            if ([data writeToFile:filePath atomically:YES]) {
                CFStringRef cfRef = FileMD5HashCreateWithPath((__bridge CFStringRef)(filePath));
                NSString *fileMD5 = (__bridge NSString *)cfRef;
                //MD5校验过之后，解压
                if ([fileMD5 isEqualToString:md5Key]) {
                    [SNUtility unZipFile:filePath zipFileTo:path];
                    [SNNewsReport reportADotGif:@"_act=ad_download&_tp=success"];
                }
                CFRelease(cfRef);
            }
            else {
                SNDebugLog(@"保存失败.");
            }
        } else {
            SNDebugLog(@"%@", error);
            [SNNewsReport reportADotGif:@"_act=ad_download&_tp=fail"];
        }
    });
    
}

+ (BOOL)didDownloadResourceWithMajorkey:(NSString *)mkey {
    NSFileManager * fileM = [NSFileManager defaultManager];
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
    path = [path stringByAppendingPathComponent:mkey];
    NSArray *filesArray = [fileM contentsOfDirectoryAtPath:[self rootPathWithMajorkey:mkey] error:nil];
    return [fileM fileExistsAtPath:path] && filesArray.count > 0;
}

+ (BOOL)removeAdResourceWithMajorkey:(NSString *)mkey {
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
    path = [path stringByAppendingPathComponent:mkey];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (BOOL)removeAllAdResource {
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


///////////////////////////////////////////////////////////////////////////////////////


+ (NSString *)rootPathWithMajorkey:(NSString *)mkey {
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
    path = [path stringByAppendingPathComponent:mkey];
    path = [path stringByAppendingPathComponent:kSpecialActivityName];
    return path;
}

+ (NSString *)imagePathWithMajorkey:(NSString *)mkey imageName:(NSString *)imageName {
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialAdResourceDocumentName];
    path = [path stringByAppendingPathComponent:mkey];
    path = [path stringByAppendingPathComponent:kSpecialActivityName];
    path = [path stringByAppendingPathComponent:imageName];
    return path;
}

@end
