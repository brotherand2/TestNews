//
//  SNNewsLoginPhoneVoiceVerifyBtn.h
//  sohunews
//
//  Created by wang shun on 2017/7/28.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsLoginPhoneVoiceVerifyBtnDelegate;
@interface SNNewsLoginPhoneVoiceVerifyBtn : UIView

@property (nonatomic,weak) id <SNNewsLoginPhoneVoiceVerifyBtnDelegate> delegate;

- (void)countDownTime;

- (void)sendVoiceCodeSuccess:(NSDictionary*)resp;

@end

@protocol SNNewsLoginPhoneVoiceVerifyBtnDelegate  <NSObject>

- (void)sendVoiceCodeRequest;

@end
