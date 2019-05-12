//
//  SNPopupActivity.h
//  sohunews
//
//  Created by handy wang on 6/24/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  通过活动中心打开的活动
 */
@interface SNPopupActivity : NSObject

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *cancelBtnTitle;
@property(nonatomic, copy) NSString *confirmBtnTitle;
@property(nonatomic, copy) NSString *confirmLink2;
@property(nonatomic, assign) NSInteger popupActivityTimeDelayAfterShowLoading;
@property(nonatomic, assign) NSInteger maxDurationOfPopupActivity;
@property(nonatomic, assign) int activityType;//1普通弹窗 2红包弹窗
@property(nonatomic, copy) NSString *descDetail;

- (void)updateWithDic:(NSDictionary *)appSettingDic;

@end
