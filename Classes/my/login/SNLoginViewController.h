//
//  SNLoginViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-16.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//


#import "SNUserAccountService.h"
#import "SNUserinfoService.h"

#define GUIDE_LOGIN_HEIGHT 36
@protocol SNLoginViewControllerDataSource;
@class SNLoginRegisterViewController;
@interface SNLoginViewController : SNBaseViewController<SNUserAccountLoginDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate, SNUserAccountOpenLoginUrlDelegate, SNUserinfoServiceGetUserinfoDelegate>
{
    UIScrollView* _scrollView;
    NSMutableArray* _openUrlItemArray;
    SNLoginRegisterViewController* __weak _SNLoginRegisterViewController;
    BOOL _guideLogin;
    NSDictionary *_queryDictionary;
}
@property (nonatomic,weak) id <SNLoginViewControllerDataSource> dataSource;

@property (nonatomic,strong) NSString* sourceChannelID;//登录来源 wangshun

@property(nonatomic,strong) UIScrollView* _scrollView;
@property(nonatomic,strong) NSMutableArray* _openUrlItemArray;
@property(nonatomic,weak) SNLoginRegisterViewController* _SNLoginRegisterViewController;
@property(nonatomic,assign) BOOL _guideLogin;
@property(nonatomic,assign) BOOL isFromVideo;
-(void)resignResponserByTag:(NSInteger)aTag;
-(void)submitLogin:(id)sender;
-(void)submitKickBack:(id)sender;
- (id)initWithParams:(NSDictionary *)query;
- (void)showPhoneVerify;
@end

@protocol SNLoginViewControllerDataSource <NSObject>

- (NSDictionary*)getPhoneNumberData;

@end
