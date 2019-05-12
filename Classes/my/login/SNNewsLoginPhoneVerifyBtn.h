//
//  SNNewsLoginPhoneVerifyBtn.h
//  sohunews
//
//  Created by wang shun on 2017/7/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNewsLoginPhoneVerifyBtnDataSource;
@interface SNNewsLoginPhoneVerifyBtn : UIView

@property (nonatomic,weak) id <SNNewsLoginPhoneVerifyBtnDataSource> dataSource;

@end

@protocol SNNewsLoginPhoneVerifyBtnDataSource <NSObject>

- (NSDictionary*)getCurrentPhoneNumberData;

@end
