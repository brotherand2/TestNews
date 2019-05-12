//
//  SNRedPacketManager.m
//  sohunews
//
//  Created by wangyy on 16/3/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedPacketManager.h"
#import "SNUserManager.h"
#import "SNUserRedPacketView.h"
#import "AesEncryptDecrypt.h"
#import "SNRedPacketConfigRequest.h"
#import "SNAppConfigFloatingLayer.h"
#import "SNAppConfigManager.h"
#import "NSDictionaryExtend.h"
#import "SNRedPacketModel.h"
#import "SNNewAlertView.h"
#import "SNAppConfigH5RedPacket.h"
#import "SNCheckOutRequest.h"
#import "SNTicketGroupRequest.h"

#define kLoginAlertTag      100011
#define kBindAlipayTag      100012

#define kCheckSuccess           10000000
#define kLoginSohuCode          30070008    //未登录搜狐账户
#define kBindPhoneCode          30070018    //绑定手机号和支付宝
#define kBindAlipayCode         30070028    //绑定支付宝

#define kFailureCode 30070005
#define kStatusCode  @"statusCode"
#define kStatusData  @"data"
#define kStatuMsg    @"statusMsg"

@interface SNRedPacketManager ()
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *realKey;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *keyTime;
@property (nonatomic, copy) NSString *encryptData;
@property (nonatomic, strong) NSDictionary *redPacketData;
@end

@interface SNRedPacketManager ()<UIAlertViewDelegate>
{
    NSString * _validTicketId;
}
@end

@implementation SNRedPacketManager
@synthesize keyTime = _keyTime;
@synthesize key = _key;
@synthesize realKey = _realKey;
@synthesize version = _version;
@synthesize encryptData = _encryptData;
@synthesize redPacketItem = _redPacketItem;
@synthesize showRedPacketTheme = _showRedPacketTheme;
@synthesize pullRedPacket = _pullRedPacket;
@synthesize redPacketShowing = _redPacketShowing;
@synthesize isRedPacketPassWd = _isRedPacketPassWd;
@synthesize redPacketData = _redPacketData;

+ (SNRedPacketManager *)sharedInstance {
    static SNRedPacketManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNRedPacketManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.redPacketItem = [[SNRedPacketItem alloc] init];
        self.redPacketData = [NSDictionary dictionary];
        NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kJoinRedPacketsValue];
        if (number != nil) {
            self.joinActivity = [number boolValue];
        }
        else{
            self.joinActivity = YES;
        }
        
        self.showRedPacketTheme = [[NSUserDefaults standardUserDefaults] boolForKey:kShowRedPacketTheme];
        
        //初始化密钥
        NSString *storeKey = [[NSUserDefaults standardUserDefaults] objectForKey:kRedPacketStoreKey];
        if (storeKey) {
            self.key = storeKey;
            NSArray *keyArray = [self.key componentsSeparatedByString:@"|"];
            if (keyArray.count == 3) {
                self.version = keyArray[1];
            }
            [self p_EnCryptData];
        }
    }
    
    return self;
}

#pragma mark 口令

- (void)dealPasteboard{
    UIPasteboard *pasteboard=[UIPasteboard generalPasteboard];
    NSString *myString=pasteboard.string;
    
    myString =[myString stringByReplacingOccurrencesOfString:@" " withString:@""];
    myString =[myString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (![myString isEqualToString:@""] && [myString length] != 0){
        if ([self isValidWord:myString]) {
            
            _validTicketId = [[myString substringFromIndex:4] copy];
            
            self.isRedPacketPassWd = YES;
            
            if ([myString hasPrefix:@"SH"])
            {
                //传送有效的红包到服务端校验
                [self chackOutAndUseWord: _validTicketId];
            }
            else if ([myString hasPrefix:@"SY"]){
                [self checkTicketWithKeyWord:_validTicketId];
                
            }
            
            //是红包口令，处理完后置空处理，避免下次再验证
            [pasteboard setString:@""];
        }
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isValidWord:(NSString *)word{
    //    SH[2位数字表示红包ID长度][红包ID]
    //    SY[2位优惠券ID长度][优惠券ID]
    BOOL isValid = NO;
    if ([word hasPrefix:@"SH"] || [word hasPrefix:@"SY"]) {
        if (word.length < 4) {
            return NO;
        }
        NSString *lenStr = [word substringWithRange:NSMakeRange(2, 2)];
        if ([self isPureInt:lenStr]) {
            int len = [lenStr intValue];
            NSString *keyWord = [word substringFromIndex:4];
            if ([keyWord length] == len) {
                isValid = YES;
            }
        }
    }
    
    return isValid;
}
- (void)chackOutAndUseWord:(NSString *)keyWord {
    
    [[[SNCheckOutRequest alloc] initWithDictionary:@{@"code":keyWord}] send:^(SNBaseRequest *request, id requestDict) {
        
        int statusCode = [[requestDict objectForKey:@"statusCode"] intValue] ;
        NSString *statusMsg = [requestDict objectForKey:@"statusMsg" defalutObj:nil];
        self.isRedPacketPassWd = NO;
        
        switch (statusCode) {
            case kCheckSuccess:
            {
                //口令开启成功
                self.redPacketData = [requestDict objectForKey:@"data"];
                [self showUserRedPacket:self.redPacketData];
            }
                break;
                
            case kLoginSohuCode:
            case kBindPhoneCode:
            {
                //未登录、绑定手机号
                [self showWaringActionAlertwithTitle:@"" withMsg:statusMsg withTag:kLoginAlertTag];
            }
                break;
                
            case kBindAlipayCode:
            {
                //绑定支付宝
                [self showWaringActionAlertwithTitle:@"" withMsg:statusMsg withTag:kBindAlipayTag];
            }
                break;
                
            default:
            {
                if(statusMsg == nil){
                    statusMsg = @"红包口令校验失败";
                }
                
                [self showWaringAlertwithTitle:nil withMsg:statusMsg];
            }
                break;
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        [self showWaringAlertwithTitle:@"抱歉" withMsg:@"红包口令校验失败"];
    }];
}

- (void)loginAndBindAlipay{
    //判断是否登陆绑定搜狐账户
    [[SNRedPacketModel sharedInstance] verifySendRedPacket:^(BOOL Success, BOOL isClickBackButton) {
        if (Success) {
            //是否绑定支付宝
            [SNUtility checkIsBindAlipayWithResult:^(BOOL isBindAlipay) {
                if (!isBindAlipay) {
                    [self onlyBindAlipay];
                } else {
                    //重新传送有效的红包口令到服务端校验
                    [self chackOutAndUseWord: _validTicketId];
                }
            }];
        } else {
            [self showWaringAlertwithTitle:nil withMsg:@"登陆失败"];
        }
    }];
}

- (void)onlyBindAlipay{
    //支付宝授权
    [[SNRedPacketModel sharedInstance] auth_V2:^(BOOL Success, NSString *result) {
        if (Success) {
            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
                if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                    NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
                    NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                    if ([statusCode isEqualToString:@"10000000"]) {
                        //重新传送有效的红包口令到服务端校验
                        [self chackOutAndUseWord: _validTicketId];
                    }else{
                        [self showWaringAlertwithTitle:nil withMsg:statusMsg];
                    }
                }else{
                    [self showWaringAlertwithTitle:nil withMsg:@"支付宝账户绑定失败"];
                }
            }];
        }
        else{
            [self showWaringAlertwithTitle:nil withMsg:@"支付宝账户授权失败"];
        }
    }];
    
    [SNRedPacketModel sharedInstance].authCompletion = ^(BOOL Success, NSString *result){
        if (Success) {
            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
                if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                    NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
                    NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                    if ([statusCode isEqualToString:@"10000000"]) {
                        //重新传送有效的红包口令到服务端校验
                        [self chackOutAndUseWord: _validTicketId];
                    }else{
                        [self showWaringAlertwithTitle:nil withMsg:statusMsg];
                    }
                }
            }];
        }else{
            [self showWaringAlertwithTitle:nil withMsg:@"支付宝账户授权失败"];
        }
    };
}

- (void)checkTicketWithKeyWord:(NSString *)keyWord {
    [[[SNTicketGroupRequest alloc] initWithDictionary:@{@"tgId":keyWord}] send:^(SNBaseRequest *request, id responseObject) {
        int statusCode = [[responseObject objectForKey:@"statusCode"] intValue];
        if (statusCode == 30050000) {
            //优惠券口令开启成功
            [self showTicket:[responseObject objectForKey:@"data"]];
        }
    } failure:nil];
}

- (void)dealRedPacketItem:(NSDictionary *)dataDic{
    int packType = [dataDic intValueForKey:@"packType" defaultValue:1];
    if (packType == 2) {//链式传播
        NSDictionary *packDic = [dataDic objectForKey:@"pack" defalutObj:nil];
        if (packDic != nil && [packDic isKindOfClass:[NSDictionary class]]) {
            self.redPacketItem.sponsoredIcon = [packDic objectForKey:@"sponsoredIcon" defalutObj:@""];
            self.redPacketItem.sponsoredTitle = [packDic objectForKey:@"sponsoredTitle" defalutObj:@""];
            self.redPacketItem.moneyValue = [NSString stringWithFormat:@"%@", [packDic objectForKey:@"money" defalutObj:@"0"]];
            self.redPacketItem.moneyTitle = [packDic objectForKey:@"msg" defalutObj:@""];
            int type = [[packDic objectForKey:kRedPacketType defalutObj:[NSNumber numberWithInt:1]] intValue];
            if (type == 1) {
                self.redPacketItem.redPacketType = SNRedPacketNormal;
            }
            else if (type == 2) {
                self.redPacketItem.redPacketType = SNRedPacketTask;
                self.redPacketItem.jumpUrl = [packDic objectForKey:@"jumpUrl" defalutObj:@""];
            }
            else {
                self.redPacketItem.redPacketType = SNRedPacketOther;
            }
        }
    }
    else{
        self.redPacketItem.moneyValue = [NSString stringWithFormat:@"%@", [dataDic objectForKey:@"packNum" defalutObj:@"0"]];
        self.redPacketItem.moneyTitle = @"你已帮拆成功";
        self.redPacketItem.redPacketType = SNRedPacketNormal;
    }
    
    self.redPacketItem.redPacketId = [dataDic objectForKey:@"redPacketId" defalutObj:nil];
    self.redPacketItem.redPacketInValid = 1;
}

- (void)showUserRedPacket:(NSDictionary *)dataDic{
    if (dataDic == nil || [dataDic count] == 0) {
        return;
    }
    
    //解析红包数据
    [self dealRedPacketItem:dataDic];
    
    SNUserRedPacketView *userRedPacket = [[SNUserRedPacketView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight) redPacketType:self.redPacketItem.redPacketType];
    userRedPacket.backgroundColor = [UIColor clearColor];
    
    [userRedPacket updateContentView:self.redPacketItem];
    
    [userRedPacket showUserRedPacket];
    [[TTNavigator navigator].window addSubview:userRedPacket];
    
    [SNRedPacketManager sharedInstance].redPacketShowing = NO;
}

- (void)showTicket:(NSDictionary *)dataDic{
    if (dataDic == nil || [dataDic count] == 0) {
        return;
    }
    
    SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:[dataDic stringValueForKey:@"title" defaultValue:nil] cancelButtonTitle:@"稍后再说" otherButtonTitle:@"立即领取"];
    [alertView show];
    [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        if (_validTicketId) {
            [SNUtility openProtocolUrl:[NSString stringWithFormat:SNLinks_Path_RedPacketH5_GetTicket,_validTicketId]];
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=coupon&_tp=see&channelId=%@", [SNUtility getCurrentChannelId]]];
        }
    }];
   
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=coupon&_tp=pop&channelId=%@", [SNUtility getCurrentChannelId]]];

}


- (void)showWaringAlertwithTitle:(NSString *)title withMsg:(NSString *)message{
    if (0 == title.length) {
        title = kBundleNameKey;
    }
    SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:message cancelButtonTitle:nil otherButtonTitle:@"我知道了"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushAlertView show];
    });

}

- (void)showWaringActionAlertwithTitle:(NSString *)title withMsg:(NSString *)message withTag:(int)tag{
    if (0 == title.length) {
        title = kBundleNameKey;
    }
    NSString *confirmStr = nil;
    NSString *cancelStr = nil;
    if (tag == kLoginAlertTag || tag == kBindAlipayTag) {
        confirmStr = @"前往绑定";
        cancelStr = @"朕，不要!";
    } else {
        confirmStr = @"我知道了";
        cancelStr = nil;
    }
    SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelStr otherButtonTitle:confirmStr];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushAlertView show];
    });
    [pushAlertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        if (tag == kLoginAlertTag) {
            [self loginAndBindAlipay];
        }
        else if (tag == kBindAlipayTag){
            [self onlyBindAlipay];
        }
    }];
}

- (BOOL)isValidRedPacket{
    return self.redPacketItem.redPacketInValid;
}

+ (void)showRedPacketActivityInfo{
    NSString *urlString = nil;
    if ([SNRedPacketManager sharedInstance].isInArticleShowRedPacket) {
        SNAppConfigH5RedPacket *h5RedPacket = [SNAppConfigManager sharedInstance].configH5RedPacket;
        urlString = h5RedPacket.redPacketDetailUrl;
    }
    else {
        SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
        urlString = floatingLayer.H5Url;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInteger:RedPacketWebViewType] forKey:kUniversalWebViewType];
    if (urlString) {
        [SNUtility openProtocolUrl:urlString context:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kIsRedPacketNewsKey]];
    }
}

+ (void)showRedPacketActivityInfo:(NSString *)packId isRedPacket:(BOOL)isRedPacket {
    SNAppConfigH5RedPacket *h5RedPacket = [SNAppConfigManager sharedInstance].configH5RedPacket;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInteger:RedPacketWebViewType] forKey:kUniversalWebViewType];
    if (h5RedPacket.redPacketUrl) {
        //5.8.4版本SNS红包
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:packId, @"packId", [NSNumber numberWithBool:isRedPacket],kIsRedPacketNewsKey, nil];
        [SNUtility openProtocolUrl:h5RedPacket.redPacketUrl context:dic];
    }
}


#pragma mark - 加密
- (NSString *)aesEncryptWithKey:(NSString *)key {
    if (key == nil || key.length == 0) {
        return nil;
    }
    
    //对Key添加|SMC签名
    NSString *enKey = [key stringByAppendingString:@"|smc"];
    
    //加密方式Key与Cid的前16位进行ASE加密
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    //对CID进行MD5加密, 取16位小写
    cid = [[cid md5Hash] lowercaseString];
    cid = [cid substringWithRange:NSMakeRange(8, 16)];
    
    return [AesEncryptDecrypt encrypt:enKey withKey:cid];
}

- (NSString *)aesEncryptWithData:(NSString *)data {
    @synchronized (self) {
        if (data == nil || data.length == 0) {
            return nil;
        }
        
        if (self.realKey && [self.realKey respondsToSelector:@selector(md5Hash)]) {
            NSString *md5RealKey = [[self.realKey md5Hash] lowercaseString];
            //取16位小写
            if (md5RealKey.length > 16) {
                md5RealKey = [md5RealKey substringWithRange:NSMakeRange(8, 16)];
                
                NSString *resultData = [AesEncryptDecrypt encrypt:data withKey:md5RealKey];
                return resultData;
            }
        }
        
        return nil;
    }
}

- (NSString *)getKey {
    return self.key;
}

- (NSString *)getRealKey {
    return self.realKey;
}

- (NSString *)getEncryptData {
    //每次都重置数据加密
    [self p_EnCryptData];
    
    return self.encryptData;
}

- (NSString *)getKeyVersion {
    return self.version;
}

- (NSString *)getKeyTime {
    return self.keyTime;
}

- (void)p_EnCryptData {
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    self.keyTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *data = [NSString stringWithFormat:@"{\"methodName\":\"News.go\",\"c\":\"%@\",\"t\":\"%@\"}", cid, self.keyTime];
    
    self.realKey = [self aesEncryptWithKey:self.key];
    self.encryptData = [self aesEncryptWithData:data];
}

- (void)requestRedPacketKey {
    [[[SNRedPacketConfigRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary *dic = [NSDictionary dictionary];
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            dic = responseObject;
        } else { // 返回数据出现异常 NSData
            if (responseObject) {
                dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            }
        }
        NSInteger code = [dic[kStatusCode] integerValue];
        NSString *key = @"";
        NSString *version = @"";
        if (code == kCheckSuccess) {
            key = dic[kStatusData];
            NSArray *keyArray = [dic[kStatusData] componentsSeparatedByString:@"|"];
            if (keyArray.count == 3) {
                version = keyArray[1];
            }
        }
        self.key = key;
        self.version = version;
        if (_key.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:self.key
                                                      forKey:kRedPacketStoreKey];
            [self p_EnCryptData];
        } else {
            NSString *storeKey = [[NSUserDefaults standardUserDefaults] objectForKey:kRedPacketStoreKey];
            self.key = storeKey;
            [self p_EnCryptData];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        NSString *storeKey = [[NSUserDefaults standardUserDefaults] objectForKey:kRedPacketStoreKey];
        self.key = storeKey;
        [self p_EnCryptData];
    }];
}

- (BOOL)showRedPacketActivityTheme {
    if (self.showRedPacketTheme == NO) {
        return NO;
    } else {
        return self.joinActivity;
    }
}

+ (BOOL)isRedPacketViewShow {
    NSArray* subViews = [[TTNavigator navigator].window subviews];
    for(UIView* view in subViews) {
        if([view isKindOfClass:[SNUserRedPacketView class]])
            return YES;
    }
    return NO;
}

+ (void)postRedPacketNotificationName:(BOOL)show{
    [SNRedPacketManager sharedInstance].showRedPacketTheme = show;
    NSNumber *value = [NSNumber numberWithBool:[SNRedPacketManager sharedInstance].showRedPacketTheme];
    [SNNotificationManager postNotificationName:kShowRedPacketThemeNotification object:value];
    
    [[NSUserDefaults standardUserDefaults] setBool:[SNRedPacketManager sharedInstance].showRedPacketTheme forKey:kShowRedPacketTheme];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setRedPacketTips:(NSString *)title{
    if (title == nil || [title length] == 0) {
        title = @"一大波红包正在来袭";
    }
    [[NSUserDefaults standardUserDefaults] setObject:title forKey:kRedPacketTips];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getRedPacketTips{
    //如果为空，返回默认，断网，返回上次得到数据
    NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:kRedPacketTips];
    if (obj != nil && [obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    }
    
    return @"一大波红包正在来袭";
}

- (BOOL)showRedPacketanimated{
    return [SNRedPacketManager sharedInstance].redPacketItem.showAnimated && self.isValidRedPacket && !self.redPacketShowing;
}

@end
