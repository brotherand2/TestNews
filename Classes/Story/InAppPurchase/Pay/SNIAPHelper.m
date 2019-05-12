//
//  SNIAPHelper.m
//  sohunews
//
//  Created by H on 2016/11/21.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNIAPHelper.h"
#import "SNWaitingActivityView.h"
#import "SNKeyChainHelper.h"
#import "SNIAPVerifyRequest.h"
#import "SNNewAlertView.h"
#import "NSDictionaryExtend.h"
#import <JsKitFramework/JKNotificationCenter.h>

@interface SNIAPHelper ()<SNNewAlertViewDelegate>
{
    NSData * _currentReceipt;
    NSString * _cerReceiptId;
}

/**
 appserver 生成的本次交易订单号
 */
@property (nonatomic, copy, readonly) NSString * transactionId;

/**
 当前将要购买的商品id
 */
@property (nonatomic, copy) NSString * buyProductId;

/**
 购买商品的数量
 */
@property (nonatomic, assign) NSInteger quantity;

/**
 用于请求商品信息
 */
@property (nonatomic, strong) SKProductsRequest *request;

/**
 loading动画遮罩
 */
@property (nonatomic, strong) UIView * loadingMask;

@end

@implementation SNIAPHelper


- (void)showLoading {
    [[SNCenterToast shareInstance] showCenterLoadingToastWithTitle:nil cancelButtonEvent:nil];
}

- (void)hideLoading {
    [[SNCenterToast shareInstance] hideCenterLoadingToast];
}

- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (instancetype)initWithTransactionId:(NSString *)transactionId {
    if (self = [super init]) {
        _transactionId = transactionId;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

/**
	购买入口，外部调用
 */
- (void)buyProduct:(NSString *)productId quantity:(NSInteger)quantity
{
    if ([self jailbrokenDevice]) {
        [self hideLoading];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请不要越狱设备上使用充值功能" toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    
    if ([SKPaymentQueue canMakePayments]) {
        self.buyProductId = productId;
        self.quantity = quantity;
        [self requestProductData];
    }
    else
    {
        [self hideLoading];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您的手机没有打开程序内付费购买" toUrl:nil mode:SNCenterToastModeWarning];
    }
}

/**
 判断设备是否越狱
 
 @return YES 已越狱
 */
- (BOOL)jailbrokenDevice{
    BOOL jailbroken = NO;
    NSString * cydiaPath = @"/Applications/Cydia.app";
    NSString * aptPath = @"/private/var/lib/apt";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

/**
 请求商品对应信息
 */
- (void)requestProductData {
    NSArray *product = [NSArray arrayWithObject:self.buyProductId];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate = self;
    self.request = request;
    [self.request start];
//    [self showLoading];
}

/**
 收到的产品信息 SKProductsRequestDelegate
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
//    SKPayment *payment = [SKPayment paymentWithProductIdentifier:self.buyProductId];
    if (response.products.count > 0) {
        SKProduct * product = response.products.firstObject;
        SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = self.quantity;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
        [self hideLoading];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"购买信息请求失败" toUrl:nil mode:SNCenterToastModeError];
    }
}

/**
 弹出错误信息
 */
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [self hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:[error localizedDescription] toUrl:nil mode:SNCenterToastModeError];
}

-(void) requestDidFinish:(SKRequest *)request
{
}

-(void)purchasedTransaction:(SKPaymentTransaction *)transaction{
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

/**
 监听购买结果<SKPaymentTransactionObserver>
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
//    [self showLoading];
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:{//交易完成
                [self completeTransaction:transaction];
                SNDebugLog(@"-----交易完成 --------");
            } break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                [self hideLoading];
                SNDebugLog(@"-----交易失败 --------");
            }break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                [self hideLoading];
                SNDebugLog(@"-----已经购买过该商品 --------");
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                SNDebugLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction: (SKPaymentTransaction *)transaction
{
    [self verifyReceiptWithTransaction:transaction];
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)failedTransaction: (SKPaymentTransaction *)transaction{
    SNDebugLog(@"失败");
    [self hideLoading];
    
    [self showAlertWithTitle:[NSString stringWithFormat:@"充值失败 ErrorCode-%d",transaction.error.code + 1000] message:transaction.error.localizedDescription];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(iapFailedWithErrorCode:)]) {
        [self.delegate iapFailedWithErrorCode:transaction.error.code + 1000];
    }
}
-(void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    SNDebugLog(@" 交易恢复处理");
}

-(void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    SNDebugLog(@"-------paymentQueue----");
}

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

/**
 {
 "statusCode": 30140000,
 "statusMsg": "成功",
 "data": 5000    //金币金额
 }
 */
- (void)verifyReceiptWithTransaction:(SKPaymentTransaction *)transaction {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
//    NSString *bodyString = [NSString stringWithFormat:@"%@", receiptString];
    _currentReceipt = [receiptString dataUsingEncoding:NSUTF8StringEncoding];
    [self verifyReceipt:_currentReceipt completed:^(BOOL successed, NSNumber *amount, NSData * receipt, NSString * errMsg) {
        [self hideLoading];
        if (successed) {
            //验证成功
            [SNKeyChainHelper removeReceiptForTransactionID:self.transactionId];

            //通知代理
            if (self.delegate && [self.delegate respondsToSelector:@selector(iapSuccessed)]) {
                [self.delegate iapSuccessed];
            }
            //提示用户充值成功
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"充值成功" toUrl:nil mode:SNCenterToastModeSuccess];

        }else{
            //验证失败,存储收据
            [self saveReceipt:receipt];
        }
    }];
}

/**
 服务端验证收据，外部暴露

 @param receipt 收据
 @param verifyCompleted 完成回调
 */
- (void)verifyReceipt:(NSData *)receipt completed:(VerifyCompletedBlock)verifyCompleted {
    if (!receipt) {
        return;
    }
    [self showLoading];
    _currentReceipt = receipt;
    SNIAPVerifyRequest * request = [[SNIAPVerifyRequest alloc] init];
    request.transactionId = self.transactionId;
    request.receipt = receipt;
    [request send:^(SNBaseRequest *request, id responseObject) {
        [self hideLoading];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            int statusCode = [resData intValueForKey:@"statusCode" defaultValue:-1];
            NSNumber * amount = [resData objectForKey:@"data"];
            NSString * statusMsg = [resData stringValueForKey:@"statusMsg" defaultValue:@""];
            if (statusCode == 30140000) {
                //刷新余额
                [SNNotificationManager postNotificationName:kSNNovelCoinBalanceRefreshSuccessedNotification object:nil userInfo:@{@"amount":amount}];
                ///通知jskit
                [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.iap.verifysuccessed" withObject:nil];
                verifyCompleted(YES,amount,receipt,statusMsg);
            }else{
                verifyCompleted(NO,amount,receipt,statusMsg);
            }
        }else{
            //验证失败
            verifyCompleted(NO,@0,receipt,@"连接失败，请稍后再试");
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self hideLoading];
        //验证失败
        verifyCompleted(NO,@0,receipt,@"请检查网络设置");
    }];
}

/**
 将失败的订单存储，以便后续重新验证
 */
- (void)saveReceipt:(NSData *)receiptString {
    
    SNDebugLog(@"-----验证失败--------");
    if (self.transactionId.length <= 0) {
        //如果走到这里就出问题了，订单号丢失，只有支付凭证
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"充值失败" toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    _currentReceipt = receiptString;
    [SNKeyChainHelper saveReceipt:receiptString forTransactionID:self.transactionId];
    NSString * title = [NSString stringWithFormat:@"充值失败 ErrorCode-%d",IAPErrorVerifyServiceFailed];
    SNNewAlertView *alerView =  [[SNNewAlertView alloc] initWithTitle:title
                                                              message:@"请稍后到「交易记录」中重试，重试时不会再次扣费"
                                                             delegate:self
                                                    cancelButtonTitle:@"稍后再试"
                                                     otherButtonTitle:@"立即重试"];
    [alerView show];

}

#pragma mark - SNNewAlertViewDelegate
- (void)otherButtonClickedOnAlertView:(SNNewAlertView *)alertView {
    
    [self verifyReceipt:_currentReceipt completed:^(BOOL successed, NSNumber *amount, NSData *receipt, NSString * errMsg) {
        if (successed) {
            //验证成功
            [SNKeyChainHelper removeReceiptForTransactionID:self.transactionId];
            //刷新余额
            //通知代理
            if (self.delegate && [self.delegate respondsToSelector:@selector(iapSuccessed)]) {
                [self.delegate iapSuccessed];
            }
            //提示用户充值成功
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"充值成功" toUrl:nil mode:SNCenterToastModeSuccess];
        }else{
            //验证失败,存储收据
            [self saveReceipt:receipt];
        }
    }];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    switch (buttonIndex) {
//        case 0:
//        {
//            break;
//        }
//        case 1:
//        {
//            [self verifyReceipt:_currentReceipt completed:^(BOOL successed, NSNumber *amount, NSData *receipt) {
//                if (successed) {
//                    //验证成功
//                    [SNKeyChainHelper removeReceiptForTransactionID:self.transactionId];
//                    //刷新余额
//                    //通知代理
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(iapSuccessed)]) {
//                        [self.delegate iapSuccessed];
//                    }
//                    //提示用户充值成功
//                    [self showAlertWithTitle:@"充值成功" message:[NSString stringWithFormat:@"账户余额 %d 书币",amount.integerValue]];
//                }else{
//                    //验证失败,存储收据
//                    [self saveReceipt:receipt];
//                }
//            }];
//            break;
//        }
//        default:
//            break;
//    }
//}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg {
    [self hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];

//    SNNewAlertView *alerView =  [[SNNewAlertView alloc] initWithTitle:title
//                                                              message:msg
//                                                    cancelButtonTitle:@"确定"
//                                                     otherButtonTitle:nil];
//    [alerView show];
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}
/**
 *  本地验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
//-(void)verifyPurchaseWithPaymentTransaction{
//    //从沙盒中获取交易凭证并且拼接成请求体数据
//    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
//    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
//
//    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
//    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
//    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//
//
//    //创建请求到苹果官方进行购买验证//上线时需改为appstore的链接
//    NSURL *url=[NSURL URLWithString:SANDBOX];
//    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
//    requestM.HTTPBody=bodyData;
//    requestM.HTTPMethod=@"POST";
//    //创建连接并发送同步请求
//    NSError *error=nil;
//    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
//    if (error) {
//        SNDebugLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
//        return;
//    }
//    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
//    SNDebugLog(@"%@",dic);
//    if([dic[@"status"] intValue]==0){
//        SNDebugLog(@"购买成功！");
//        NSDictionary *dicReceipt= dic[@"receipt"];
//        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
//        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
//        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
//        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//        if ([productIdentifier isEqualToString:@"123"]) {
//            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
//            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
//        }else{
//            [defaults setBool:YES forKey:productIdentifier];
//        }
//        //在此处对购买记录进行存储，可以存储到开发商的服务器端
//    }else{
//        SNDebugLog(@"购买失败，未通过验证！");
//    }
//}
@end
