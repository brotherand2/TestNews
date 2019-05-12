//
//  SNActionUserLoginManager.h
//  sohunews
//
//  Created by lhp on 9/30/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNUserAccountService.h"
#import "SNGuideRegisterManager.h"
#import "SNBaseFavouriteObject.h"

@interface SNActionSheetLoginManager : NSObject <SNUserAccountOpenLoginUrlDelegate, SNUserAccountLoginDelegate>
{
    
    SNUserAccountService *_userinfoModel;
//    SNGuideRegisterType _guideType;
    SNBaseFavouriteObject *_favouriteObject;
    NSDictionary *guideDic;
    
    BOOL logining;
    BOOL isSSO;
}

@property(nonatomic,strong) NSDictionary *guideDic;
@property(nonatomic,strong) SNBaseFavouriteObject *favouriteObject;
@property(nonatomic,assign) BOOL logining;
@property (nonatomic, strong)NSString *newsId;
@property (nonatomic, assign)SNGuideRegisterType guideType;
@property(nonatomic,strong) NSString *backUrl;
@property(nonatomic,assign) BOOL forceBackWebView;

+ (SNActionSheetLoginManager *)sharedInstance;
- (void)setNewGuideDic:(NSDictionary *) dictionary;
- (void)resetNewGuideDic;
- (void)loginWithIndex:(NSInteger) index;

// 在某些情况下，比如登陆拦截功能拦截后 需要把登陆成功之后的操作 清掉
- (void)cleanGuideType;
- (SNGuideRegisterType)getGuideRegisterType;

//wangshun login Success 2017.5.8
-(void)mobileLoginSuccess:(NSDictionary *)params SuccessBlock:(void (^)(NSDictionary *info))method;

@end
