//
//  SNPromotionTableItem.h
//  sohunews
//
//  Created by yanchen wang on 12-7-6.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsModel.h"
#import "SNPromotion.h"

@interface SNPromotionTableItem : TTTableSubtitleItem {
    SNPromotion *_promotion;
    SNRollingNewsModel *_newsModel;
}

@property(nonatomic, strong)SNPromotion *promotion;
@property(nonatomic, strong)SNRollingNewsModel *newsModel;

@end
