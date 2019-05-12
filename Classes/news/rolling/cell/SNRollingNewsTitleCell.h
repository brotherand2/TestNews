//
//  SNRollingNewsTitleCell.h
//  sohunews
//
//  Created by lhp on 5/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingBaseCell.h"
#import "SNRollingNewsTableItem.h"
#import "SNCellContentView.h"
#import "NSAttributedString+Attributes.h"
#import "UITableViewCell+ConfigureCell.h"
#import "NSMutableAttributedString+Size.h"

/*****************************显示标题的Cell***********************************
 
        1、最多显示两行
        2、多于两行结尾显示"..."

****************************************************************************/

@interface SNRollingNewsTitleCell : SNRollingBaseCell {
    CELL_READ_STYLE_TYPE currentReadStatus;
    NSTimeInterval _lastClickTime;
}
@property (nonatomic, strong) SNCellContentView *cellContentView;

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item;
+ (CGFloat)getTitleWidth;
+ (int)getTitleHeightWithItem:(SNRollingNewsTableItem *)item
                   isMultLine:(BOOL)isMultLine;
- (void)setReadStyleByMemory;
- (void)updateNewsContent;
- (void)setAlreadyReadStyle;
- (void)setUnReadStyle;
- (void)openNews;
- (void)updateCellContentView;

+ (CGFloat)getTitleWidth:(SNRollingNewsTableItem *)item;
+ (CGFloat)titleMaxLineCount:(SNRollingNewsTableItem *)item;
+ (BOOL)isSohuFeedItem:(SNRollingNewsTableItem *)item;

+ (void)setNewsTitleWithItem:(SNRollingNewsTableItem *)newsItem;
- (void)setNewsReadStyleByMemory;

@end
