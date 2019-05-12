//
//  SNVoucherCenter.h
//  sohunews
//
//  Created by H on 2016/11/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ChargeCompletedBlock)(BOOL successed);
typedef void(^PurchaseCompletedBlock)(BOOL successed,BOOL checkStatusTimeout);
typedef void(^CompletedBlock)(BOOL successed, NSArray * responseArray);

@interface SNVoucherCenter : NSObject

@property (nonatomic, copy) ChargeCompletedBlock chargeCompleted;
//@property (nonatomic, copy) PurchaseCompletedBlock purchaseCompleted;
@property (nonatomic, copy) CompletedBlock completed;

/**
 用户充值中心
 用于书币兑换，可使用红包余额，也可直接Apple充值

 @return 用户充值中心
 */
+ (SNVoucherCenter *)voucherCenter;

#pragma mark
#pragma mark - 书币商品列表获取
/**
 获取商品列表

 @return 商品列表
 */
+ (void)getProductsCompleted:(CompletedBlock)completedBlock;

#pragma mark
#pragma mark - 书币余额信息查询

/**
 刷新余额
 */
+ (void)refreshBalance;

/**
 书币余额，不会调刷新接口
 
 @return 书币余额
 */
+ (CGFloat)balance;

/**
 用于判断余额是否充足
 是否足够购买当前价格
 不会调刷新接口
 
 @return YES 余额充足
 */
+ (BOOL)sufficientBalance:(CGFloat)price;

#pragma mark
#pragma mark - 书币充值
/**
 苹果充值书币
 
 @param productId 书币礼包的id
 */
+ (void)rechargeWithProductId:(NSString *)productId quantity:(NSInteger)quantity completed:(ChargeCompletedBlock)completedBlock;

/**
 财富余额充值书币

 @param productId 书币礼包的id
 */
//+ (void)rechargeWithWealthBalanceWithProductId:(NSString *)productId;


#pragma mark
#pragma mark - 使用书币购买小说

/**
 设置自动购买小说（默认自动购买下一章）

 @param autoPurchase YES 自动购买
 */
+ (void)setAutoPurchase:(BOOL)autoPurchase;

/**
 是否设置了自动购买

 @return YES 设置了自动购买下一章功能
 */
+ (BOOL)autoPurchase;


/**
 购买小说

 @param bookId 小说id
 @param chapters NSArray<ChapterList> 章节id 传几章购买几章,会自动过滤已购买章节
 @param completedBlock 完成的回调block
 */
+ (void)purchaseWithBookId:(NSString *)bookId
             chapters:(NSArray *)chapters
            completed:(PurchaseCompletedBlock)completedBlock;

@end
