//
//  SNPopupActivity.m
//  sohunews
//
//  Created by handy wang on 6/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNPopupActivity.h"
#import "SNAppConfigConst.h"
#import "NSJSONSerialization+String.h"

static NSString *const keyIdentifier                                = @"activityId";
static NSString *const keyTitle                                     = @"title";
static NSString *const keyMessage                                   = @"copyWritingDesc";
static NSString *const keyCancelBtnTitle                            = @"cancleButtonName";
static NSString *const keyConfirmBtnTitle                           = @"buttonName";
static NSString *const keyConfirmLink2                              = @"buttonLink";
static NSString *const keyPopupActivityTimeDelayAfterShowLoading    = @"loadingAfterTime";
static NSString *const keyMaxDurationOfPopupActivity                = @"frameTimeOut";
static NSString *const keyActivityType                              = @"activityType";
static NSString *const ketDescDetail                                = @"descDetail";

@implementation SNPopupActivity

- (void)updateWithDic:(NSDictionary *)appSettingDic {
    NSString *activityObjString = [appSettingDic stringValueForKey:kPopupActivity defaultValue:@"{}"];
    id activityObj = [NSJSONSerialization JSONObjectWithString:activityObjString
                                                       options:NSJSONReadingMutableLeaves
                                                         error:NULL];
    if ([activityObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *activityDic = (NSDictionary *)activityObj;
        self.identifier = [activityDic stringValueForKey:keyIdentifier defaultValue:@"0"];
        self.title = [activityDic stringValueForKey:keyTitle defaultValue:@""];
        self.message = [activityDic stringValueForKey:keyMessage defaultValue:@""];
        self.cancelBtnTitle = [activityDic stringValueForKey:keyCancelBtnTitle defaultValue:@"取消"];
        self.confirmBtnTitle = [activityDic stringValueForKey:keyConfirmBtnTitle defaultValue:@"查看"];
        self.confirmLink2 = [activityDic stringValueForKey:keyConfirmLink2 defaultValue:@""];
        self.popupActivityTimeDelayAfterShowLoading = [activityDic intValueForKey:keyPopupActivityTimeDelayAfterShowLoading defaultValue:5];
        self.maxDurationOfPopupActivity = [activityDic intValueForKey:keyMaxDurationOfPopupActivity defaultValue:10];
        
        self.activityType = [[activityDic stringValueForKey:keyActivityType defaultValue:@"1"] intValue];
        self.descDetail = [activityDic stringValueForKey:ketDescDetail defaultValue:@""];
    }
}

- (NSString *)description {
    NSString *popupActivityTimeDelayAfterShowLoadingStr = [NSString stringWithFormat:@"%ld", (long)_popupActivityTimeDelayAfterShowLoading];
    NSString *maxDurationOfPopupActivity = [NSString stringWithFormat:@"%ld", (long)_maxDurationOfPopupActivity];
    
    NSDictionary *desc = @{keyIdentifier:(_identifier.length > 0 ? _identifier : @""),
                           keyTitle:(_title.length > 0 ? _title : @""),
                           keyMessage:(_message.length > 0 ? _message : @""),
                           keyCancelBtnTitle:(_cancelBtnTitle.length > 0 ? _cancelBtnTitle : @""),
                           keyConfirmBtnTitle:(_confirmBtnTitle.length > 0 ? _confirmBtnTitle : @""),
                           keyConfirmLink2:(_confirmLink2.length > 0 ? _confirmLink2 : @""),
                           keyPopupActivityTimeDelayAfterShowLoading:(popupActivityTimeDelayAfterShowLoadingStr.length > 0 ? popupActivityTimeDelayAfterShowLoadingStr : @""),
                           keyMaxDurationOfPopupActivity:(maxDurationOfPopupActivity.length > 0 ? maxDurationOfPopupActivity : @"")
                           };
    return [desc description];
}

@end
