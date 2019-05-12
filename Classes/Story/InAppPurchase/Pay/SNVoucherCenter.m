//
//  SNVoucherCenter.m
//  sohunews
//
//  Created by H on 2016/11/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define kDidSetAutoPurchaseNextChapter @"kDidSetAutoPurchaseNextChapter"
#define kIAPProductsListCacheKey        @"kIAPProductsListCacheKey"
#define kIAPProductsListCacheDateKey        @"kIAPProductsListCacheDateKey"

//订单状态 0:待支付 1:支付处理中2:支付成功 3:支付失败 4:支付调用超时 5:超时未支付
typedef enum : NSUInteger {
    SNNovelPaymentUnknown = 0,
    SNNovelPaymentUnpaid,
    SNNovelPaymentPaying,
    SNNovelPaymentSuccess,
    SNNovelPaymentFail,
    SNNovelPaymentCallTimeout,
    SNNovelPaymentOvertime,
} SNNovelPaymentStatus;

#import "SNVoucherCenter.h"
#import "SNIAPHelper.h"
#import "ChapterList.h"
#import "SNStoryUtility.h"
#import "NSStringAdditions.h"
#import "SNGeneratePaymentIdRequest.h"
#import "SNCoinBalanceRequest.h"
#import "SNIAPProductsRequest.h"
#import "SNCoinPayRequest.h"
#import "SNPaymentStatusRequest.h"
#import "SNNewAlertView.h"
#import "TMCache.h"
#import "NSDictionaryExtend.h"
#import "SNSpecialADTools.h"

@interface SNVoucherCenter () <SNIAPHelperDelegate>
{
    NSTimer * _checkPaymentTimer;   //check订单状态的timer
    NSString * _curOrderId;         //当前的支付订单号
    SNNovelPaymentStatus _curPaymentStatus;//当前订单状态
    BOOL _beingPaid;//正在支付，一次只处理一个支付订单，防止二次支付
    NSUInteger _checkCount;//监测订单状态的次数，也就是timer执行的次数
    BOOL _successedFlag;//小说购买标识
    BOOL _iapCompleted;//书币充值完成标识
}

@property (nonatomic, strong) SNIAPHelper * payHelper;

/**
 待支付的bookId
 */
@property (nonatomic, copy) NSString * bookId;

/**
 待支付的章节id 多章节id用逗号分隔
 */
@property (nonatomic, copy) NSString * chapterIds;

@property (nonatomic, copy) PurchaseCompletedBlock purchaseCompleted;

@end
static SNVoucherCenter * __vc;
@implementation SNVoucherCenter

- (id)init {
    if (__vc != nil) {
        [NSException raise:@"singletonClassError" format:@"不要直接初始化单例类 SNVoucherCenter."];
    } else if (self = [super init]) {
        __vc = self;
    }
    _iapCompleted = YES;
    return __vc;
}

#pragma mark - 静态方法

+ (SNVoucherCenter *)voucherCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __vc = [[SNVoucherCenter alloc] init];
    });
    return __vc;
}
#pragma mark - 商品信息
/*
 {
 "statusCode": 30140000,
 "statusMsg": "成功",
 "data": [
 {
 id: 100,  //购买产品 id
 price: "1.00",     //价格
 desc: "100书币"    //描述
 }
 ]
 }
 */
+ (void)getProductsCompleted:(CompletedBlock)completedBlock
{
    SNIAPProductsRequest * request = [[SNIAPProductsRequest alloc] init];
    [request send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            int statusCode = [resData intValueForKey:@"statusCode" defaultValue:-1];
            NSArray * dataArray = [resData objectForKey:@"data"];
            if (statusCode == 30140000 && [dataArray isKindOfClass:[NSArray class]]) {
                [self storeProductsList:dataArray];
                completedBlock(YES,dataArray);
            }else{
                completedBlock(NO,[self productsListCache]);
            }
        }else{
            completedBlock(NO,[self productsListCache]);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        completedBlock(NO,[self productsListCache]);
    }];
}

+ (void)storeProductsList:(NSArray *)productsList {
    if (productsList.count > 0) {
        [[TMCache sharedCache] setObject:productsList forKey:kIAPProductsListCacheKey];
        [[TMCache sharedCache] setObject:[NSDate date] forKey:kIAPProductsListCacheDateKey];
    }
}

+ (NSArray *)productsListCache {
    NSDate * cacheDate = [[TMCache sharedCache]objectForKey:kIAPProductsListCacheDateKey];
    if (cacheDate && ![SNSpecialADTools isNaturalDaythanDate:cacheDate]) {
        return [[TMCache sharedCache] objectForKey:kIAPProductsListCacheKey];
    }else{
        [[TMCache sharedCache] removeObjectForKey:kIAPProductsListCacheKey];
        [[TMCache sharedCache] removeObjectForKey:kIAPProductsListCacheDateKey];
    }
    return nil;
}

#pragma mark - 书币余额
/*
 {
 "statusCode": 30140000,
 "statusMsg": "成功",
 "data": {
 "nickName": "用户昵称",
 "amount": 5000
 }
 }
 */
//刷新余额
+ (void)refreshBalance {
    //每次消费与充值后都要调用此方法来刷新余额
    //刷新余额接口
    SNCoinBalanceRequest * request = [[SNCoinBalanceRequest alloc] init];
    [request send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary * data = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            int statusCode = [resData intValueForKey:@"statusCode" defaultValue:-1];
            data = [resData objectForKey:@"data"];
            if (statusCode == 30140000 && [data isKindOfClass:[NSDictionary class]]) {
                NSNumber * amountNum = data[@"amount"];
                //更新余额
                [[self voucherCenter] updateBalance:amountNum.integerValue];
            }
        }
        //刷新UI通知
        [SNNotificationManager postNotificationName:kSNNovelCoinBalanceRefreshSuccessedNotification object:nil userInfo:data];
    } failure:^(SNBaseRequest *request, NSError *error) {
        //刷新UI通知
        [SNNotificationManager postNotificationName:kSNNovelCoinBalanceRefreshSuccessedNotification object:nil userInfo:nil];
    }];
}

+ (CGFloat)balance {
    CGFloat bal = 0;
    if ([SNStoryUtility isLogin]) {
        NSNumber * amountNum = [[TMCache sharedCache] objectForKey:[SNStoryUtility getPid]];
        if (amountNum && [amountNum isKindOfClass:[NSNumber class]]) {
            bal = amountNum.integerValue;
        }
        return bal;
    }
    return 0;
}

+ (BOOL)sufficientBalance:(CGFloat)price {
    CGFloat balance = [self balance];
    if (balance >= price) {
        return YES;
    }
    return NO;
}

#pragma mark - 书币充值
/*
 {
 "statusCode": 30140000,
 "statusMsg": "成功",
 "data": "1001487315534999000"     //交易 id
 }
 */
+ (void)rechargeWithProductId:(NSString *)productId quantity:(NSInteger)quantity completed:(ChargeCompletedBlock)completedBlock {

    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }
    [[self voucherCenter] showLoading];
    //app server 生成订单
    SNGeneratePaymentIdRequest * request = [[SNGeneratePaymentIdRequest alloc] init];
    request.productId = productId;
    [request send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            /*
             {
             statusCode: "30140003",
             statusMsg: "需登录后操作"
             }
             */
            int statusCode = [resData intValueForKey:@"statusCode" defaultValue:-1];
            NSString * transactionId = [resData stringValueForKey:@"data" defaultValue:@""];
            if (statusCode == -1) {
                
                [[self voucherCenter]hideLoading];
                [[self voucherCenter] showAlertWithTitle:nil msg:@"数据错误。"];
                completedBlock(NO);
                return ;
            }
            if (statusCode == 30140000 && transactionId.length > 0) {
                //订单创建成功
                //apple server 开始购买
                [self voucherCenter].payHelper = [[SNIAPHelper alloc] initWithTransactionId:transactionId];
                [self voucherCenter].chargeCompleted = completedBlock;
                [[self voucherCenter].payHelper buyProduct:productId quantity:quantity];
            }else{
                [[self voucherCenter]hideLoading];
                NSString * errMsg = [resData objectForKey:@"statusMsg"];
                if (errMsg && [errMsg isKindOfClass:[NSString class]]) {
                    [[self voucherCenter] showAlertWithTitle:nil msg:errMsg];
                }else{
                    [[self voucherCenter] showAlertWithTitle:nil msg:@"订单创建失败，请稍后再试。"];
                }
                completedBlock(NO);
            }
        }else{
            [[self voucherCenter]hideLoading];
            [[self voucherCenter] showAlertWithTitle:nil msg:@"订单创建失败，请稍后再试。"];
            completedBlock(NO);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[self voucherCenter]hideLoading];
        //订单创建失败
        [[self voucherCenter] showAlertWithTitle:nil msg:@"网络错误，请稍候再试"];
        completedBlock(NO);
    }];
  
}

+ (void)rechargeWithWealthBalanceWithProductId:(NSString *)productId {
    //财富余额支付
    // to do ...
}


#pragma mark - 购买小说

+ (void)setAutoPurchase:(BOOL)autoPurchase {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:autoPurchase] forKey:kDidSetAutoPurchaseNextChapter];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (autoPurchase) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已开启自动购买下一章功能" toUrl:nil mode:SNCenterToastModeOnlyText];
    }else{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已关闭自动购买下一章功能" toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    [SNNotificationManager postNotificationName:NovelAutoPurchaseStatusDidChangedNotification object:nil];
}

+ (BOOL)autoPurchase {
    NSNumber * obj = [[NSUserDefaults standardUserDefaults] objectForKey:kDidSetAutoPurchaseNextChapter];
    return obj.boolValue;
}

+ (void)purchaseWithBookId:(NSString *)bookId
                  chapters:(NSArray *)chapters
                 completed:(PurchaseCompletedBlock)completedBlock
{
    [[self voucherCenter] purchaseWithBookId:bookId chapters:chapters completed:completedBlock];
}

#pragma mark - 动态方法
- (void)setPayHelper:(SNIAPHelper *)payHelper {
    if (_iapCompleted) {
        _iapCompleted = NO;
        _payHelper = payHelper;
        _payHelper.delegate = self;
    }
}

- (void)updateBalance:(NSUInteger)newbalance {
    if ([SNStoryUtility isLogin]) {
        NSNumber * amountNum = [NSNumber numberWithInteger:newbalance];
        [[TMCache sharedCache] setObject:amountNum forKey:[SNStoryUtility getPid]];
    }
}

//开始使用金币支付
- (void)purchaseWithBookId:(NSString *)bookId
                  chapters:(NSArray *)chapters
                 completed:(PurchaseCompletedBlock)completedBlock
{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }

    if (chapters.count <= 0 || bookId.length == 0) {
        //数据错误
        return;
    }
    if (_beingPaid) {
        return;
    }
    [self showLoading];
    self.purchaseCompleted = completedBlock;
    float totalPrice = 0.0;
    NSUInteger chaptersCount = 0;
    self.chapterIds = @"";
    NSMutableArray * chapterIds = [NSMutableArray array];
    //结算
    for (ChapterList * chapter in chapters) {
        if (!chapter.hasPaid && !chapter.isfree) {
            totalPrice += chapter.price;
            chaptersCount++;
            [chapterIds addObject:[NSString stringWithFormat:@"%d",chapter.chapterId]];
        }
    }
    self.bookId = bookId;
    if (chapterIds.count > 1) {
        self.chapterIds = [chapterIds componentsJoinedByString:@","];
        NSString * msg = [NSString stringWithFormat:@"确认支付后%d章吗？", chaptersCount];
        [self hideLoading];
        SNNewAlertView * confirmAlert = [[SNNewAlertView alloc] initWithTitle:@"请确认" message:msg cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
        [confirmAlert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
            [self showLoading];
            [self goPurchase];
        }];
        [confirmAlert show];
    }else{
        self.chapterIds = [chapterIds firstObject];
        if ([[self class] sufficientBalance:totalPrice]) {
            [self goPurchase];
        }else{
            [self hideLoading];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您的余额不足，请充值后购买" toUrl:nil mode:SNCenterToastModeError];
        }
    }
}

#pragma mark - UI
- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
}

- (void)showLoading {
    [[SNCenterToast shareInstance] showCenterLoadingToastWithTitle:nil cancelButtonEvent:nil];
}

- (void)hideLoading {
    [[SNCenterToast shareInstance] hideCenterLoadingToast];
}

- (void)showSuccessToast {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支付成功" toUrl:nil mode:SNCenterToastModeSuccess];
}
- (void)showFailedToast {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"支付失败" toUrl:nil mode:SNCenterToastModeError];
}

/*
 {
  "isSuccess": "S",
  "response": {
  "productid": 3601,
  "errorDesc": "成功",
  "orderid": "2530004902108203",
  "transid": "CP20161216000000000000266657",
  "sign": "d669aa0b8993234b31ca6e52b454e706",
 "amt": "0.12",
 "status": "1",
 }
 }
 */
#pragma mark - 小说购买支付
- (void)goPurchase {
    if (!self.bookId || !self.chapterIds) {
        [self hideLoading];
        return;
    }
    if (_beingPaid) {
        return;
    }
    
    _curPaymentStatus = SNNovelPaymentUnpaid;
    _beingPaid = YES;
    _successedFlag = NO;//发起支付，标志位置false
    
    SNCoinPayRequest * request = [[SNCoinPayRequest alloc] init];
    request.bookId = self.bookId;
    request.chapterIds = self.chapterIds;
    //支付过程可能会非常漫长，于是有一个check订单状态的接口
    [request send:^(SNBaseRequest *request, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * r = (NSDictionary *)responseObject;
            NSString * s = r[@"isSuccess"];
            NSDictionary * err = r[@"error"];
            if ([s isKindOfClass:[NSString class]] && [err isKindOfClass:[NSDictionary class]]) {
                NSString * errMsg = [err stringValueForKey:@"message" defaultValue:@""];
                int errCode = [err intValueForKey:@"code" defaultValue:-1];
                if ([s isEqualToString:@"F"]) {
                    [self resetPayment];
                    if (errCode == 1) {
                        /*
                         code:1   已经购买过
                         code:2   参数违法
                         code:3	  请求频繁，请稍后再试
                         code:4	  交易异常
                         code:5	  尚未登录
                         */
                        /// 已经购买过了，直接返回购买成功，刷新页面，服务端会控制重复购买的问题
                        [self setPaymentStatus:SNNovelPaymentSuccess];
                    }else{
                        
                        [self hideLoading];
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:errMsg toUrl:nil mode:SNCenterToastModeError];
                        [self setPaymentStatus:SNNovelPaymentFail];
                    }
                    return;
                }
            }
            //支付接口只看订单是否提交成功，支付是否成功由Paystatus.go统一返回
            // "status": "1" 提交成功
            // "status": "0" 提交失败
            /*
             {
             amount = 12;
             busiType = 10;
             channelType = 5;
             completeTime = 1488258822680;
             ctime = 0;
             id = 406428883;
             orderId = 101488258822997852;
             passport = 6044410714889039978;
             paygate = 0;
             status = 1;
             terminalType = 3;
             transType = 0;
             uptime = 0;
             }
             */
            NSDictionary * info = r[@"response"];
            if ([info isKindOfClass:[NSDictionary class]]) {
                int submit = [info intValueForKey:@"status" defaultValue:-1];
                if (submit == 1) {
                    //支付订单提交成功，service开始支付流程
                    //确定当前订单号、交易流水号
                    _curOrderId = info[@"orderId"];
                    if (_curOrderId.length > 0) {
                        //开始check订单状态
                        [self startCheckPaymentStatusTimer];
                    }else{
                        [self setPaymentStatus:SNNovelPaymentFail];
                    }
                }else{
                    [self setPaymentStatus:SNNovelPaymentFail];
                }
            }else{
                [self setPaymentStatus:SNNovelPaymentFail];
            }
        }else{
            [self setPaymentStatus:SNNovelPaymentFail];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self hideLoading];
        [self setPaymentStatus:SNNovelPaymentFail];
    }];
}

/**
 支付状态唯一输出口

 @param paymentStatus  支付状态
 */
- (void)setPaymentStatus:(SNNovelPaymentStatus)paymentStatus {
    if (_successedFlag) {
        return;
    }
    _curPaymentStatus = paymentStatus;
    switch (_curPaymentStatus) {
        case SNNovelPaymentUnpaid:
        {
            //待支付
            [self showLoading];
            [self timeoutProtect];
            break;
        }
        case SNNovelPaymentPaying:
        {
            //支付中
            [self showLoading];
            [self timeoutProtect];
            break;
        }
        case SNNovelPaymentSuccess:
        {
            //支付成功
            _successedFlag = YES;//支付成功，标志位置true，之后的多次回调
            [self resetPayment];
            [self showSuccessToast];
            if (self.purchaseCompleted) {
                self.purchaseCompleted(YES,NO);
            }
            break;
        }
        case SNNovelPaymentFail:
        {
            //支付失败
            [self paymentFailedToast];
            [self resetPayment];
            if (self.purchaseCompleted) {
                self.purchaseCompleted(NO,NO);
            }
            break;
        }
        case SNNovelPaymentCallTimeout:
        {
            //支付调用超时
            [self paymentFailedToast];
            [self resetPayment];
            if (self.purchaseCompleted) {
                self.purchaseCompleted(NO,NO);
            }
            break;
        }
        case SNNovelPaymentOvertime:
        {
            //超时未支付
            [self paymentFailedToast];
            [self resetPayment];
            if (self.purchaseCompleted) {
                self.purchaseCompleted(NO,NO);
            }
            break;
        }
        default:
        {
            //缺省
            [self paymentFailedToast];
            [self resetPayment];
            if (self.purchaseCompleted) {
                self.purchaseCompleted(NO,NO);
            }
            break;
        }
    }
}

- (void)timeoutProtect {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [self cancelPayment];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }

    if (_checkCount >= 20) {
        //超过一定次数就取消check接口，避免一直卡住界面
        [self resetPayment];
        if (self.purchaseCompleted) {
            self.purchaseCompleted(NO,YES);
        }
        SNNewAlertView * alert = [[SNNewAlertView alloc] initWithTitle:@"网络超时" message:@"网络超时，请稍候再试，如已支付成功请忽略。" cancelButtonTitle:@"确定" otherButtonTitle:nil];
        [alert show];
    }
}

- (void)cancelPayment {
    //由于服务器始终返回正在支付状态，用户手动中断了交易，此时是否扣款，是否交易成功都未知
    [self resetPayment];
}

//查询订单支付状态的接口
- (void)checkPaymentStatus:(NSString *)orderId {
    /*
     {
     "isSuccess": "S",
     "response": {
     "amount": 0.12,//附件金额,
     "busiType": 10,//业务类型,
     "channelType": 0,//渠道类型 0 Android ，1 IOS,
     "completeTime": 0,//交易完成时间,
     "ctime": 1481882966000,//交易创建时间,
     "id": 1701784073,
     "orderId": "9480594902101131",//订单号,
     "passport": "6087162300211834902",//pid,
     "paygate": 1841,
     "status": 2,//订单状态 0:待支付 1:支付处理中2:支付成功 3:支付失败 4:支付调用超时 5:超时未支付
     "terminalType": 3,
     "transType": 0,
     "uptime": 1481882966000
     }
     }
     */
    if (!orderId) {
        [self resetPayment];
        return;
    }
    _checkCount ++;
    SNPaymentStatusRequest * request = [[SNPaymentStatusRequest alloc] init];
    request.orderId = orderId;
    [request send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * r = (NSDictionary *)responseObject;
            if ([r[@"isSuccess"] isEqualToString:@"F"]) {
                [self resetPayment];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:r[@"error"] toUrl:nil mode:SNCenterToastModeError];
                return;
            }
            NSDictionary * info = [r dictionaryValueForKey:@"response" defalutValue:nil];
            if (info) {
                int status = [info intValueForKey:@"status" defaultValue:-999];
                SNDebugLog(@" novel paying status : %d",status);
                //服务端设定的status从0开始，客户端从1开始，所以+1
                [self setPaymentStatus:status + 1];
            }else{
                [self setPaymentStatus:SNNovelPaymentFail];
            }
        }else{
            [self setPaymentStatus:SNNovelPaymentFail];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self setPaymentStatus:SNNovelPaymentFail];
    }];
}

- (void)paymentFailedToast{
    //支付订单提交失败，提示用户
    [self showFailedToast];
    //支付状态归零
    //[self resetPayment];//调用paymentFailedToast方法之前，已经对支付状态归零
}

- (void)resetPayment {
    _curPaymentStatus = SNNovelPaymentUnpaid;
    _beingPaid = NO;
    _curOrderId = nil;
    _checkCount = 0;
    [self stopCheckPaymentStatusTimer];
    [self hideLoading];
}

#pragma mark - timer
- (void)startCheckPaymentStatusTimer {
    [self stopCheckPaymentStatusTimer];
    _checkPaymentTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(performCheckSelectorInBackgroundThread) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_checkPaymentTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCheckPaymentStatusTimer {
    _checkCount = 0;
    if (_checkPaymentTimer && [_checkPaymentTimer isValid]) {
        [_checkPaymentTimer invalidate];
        _checkPaymentTimer = nil;
    }
}

- (void)performCheckSelectorInBackgroundThread {
    [self performSelectorInBackground:@selector(doCheckPaymentStatusService) withObject:nil];
}

- (void)doCheckPaymentStatusService {
    if (!_curOrderId) {
        [self resetPayment];
        return;
    }
    @autoreleasepool {
        [self checkPaymentStatus:_curOrderId];
    }
}

#pragma mark - SNIAPHelperDelegate 书币充值回调
- (void)iapSuccessed {
    //充值成功，刷新书币余额
    [SNVoucherCenter refreshBalance];
    if (self.chargeCompleted) {
        self.chargeCompleted(YES);
    }
    _iapCompleted = YES;
}

- (void)iapFailedWithErrorCode:(IAPErrorCode)errorCode {
    if (self.chargeCompleted) {
        self.chargeCompleted(NO);
    }
    _iapCompleted = YES;
}

@end
