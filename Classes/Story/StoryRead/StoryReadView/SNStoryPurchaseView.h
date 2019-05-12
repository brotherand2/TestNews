//
//  SNStoryPurchaseView.h
//  sohunews
//
//  购买书籍
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    StoryWiXinPay = 0,      //微信支付
    StoryZhiFuBaoPay,       //支付宝支付
    StoryBalancePay        //余额支付
}StoryPayType;

typedef enum{
    StoryThisChapter = 0,      //本章
    StoryAfterTenChapter,      //后10章
    StoryAfterfiftyChapter,    //后50章
    StoryOtherChapter          //剩余章节
}StoryPurchaseType;

@class SNStoryPageViewController;

@protocol SNStoryPurchaseViewDelegate <NSObject>

- (void)purchaseButtonClicked;

- (void)purchaseTypeDidChanged:(StoryPurchaseType)type;

@end

@interface SNStoryPurchaseView : UIButton

@property(nonatomic, assign)StoryPayType payType;
@property(nonatomic, assign)StoryPurchaseType purchaseType;
@property (nonatomic, weak) id <SNStoryPurchaseViewDelegate>delegate;
@property(nonatomic, weak)SNStoryPageViewController *pageViewController;
@property(nonatomic, assign)NSInteger currentIndex;

- (instancetype)initWithFrame:(CGRect)frame pageViewController:(SNStoryPageViewController *)pageViewController chapterIndex:(NSInteger)currentIndex;
- (void)updateNovelTheme;
- (void)setPrice:(CGFloat)price;
- (void)setPaymentTitle:(NSString *)title index:(NSInteger)index;
- (CGFloat)getPrice;

@end



