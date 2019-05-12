//
//  SNLiveCell.h
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNLiveTableItem.h"
#import "SNTableSelectStyleCell.h"
#import "SNLabel.h"
#import "NSAttributedString+Attributes.h"

@class GameTypeView;
@class GameInfoView;
@class GameDateTimeView;

@interface SNLiveCellContentView : UIView {
    GameInfoView *_gameInfoView;
    GameDateTimeView *_gameDateTimeView;
}

@property(nonatomic, strong) LivingGameItem *gameItem;

- (void)addTarget:(id)target selector:(SEL)selector;

@end

@protocol SNLiveCellDelegate <NSObject>

- (void)subscribeWithLiveItem:(LivingGameItem *)liveItem;
- (void)unsubscribeWithLiveItem:(LivingGameItem *)liveItem;

@end

@interface SNLiveCell : SNTableSelectStyleCell {
    SNLiveTableItem *_livingGameItem;
    SNLiveCellContentView *_liveContentView;
}

@property(nonatomic, strong)SNLiveTableItem *livingGameItem;

// get height
+ (CGFloat)cellHeight;

@end

