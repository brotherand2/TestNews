//
//  SNSpecialTextNewsTableCell.m
//  sohunews
//
//  Created by Chen Hong on 11/15/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialAbstractNewsTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNSpecialNewsTableItem.h"

#define kRowHeight (106/2)

#define horizontalPadding                           (10)
#define textWidth                                   (300)
#define fontSize                                    (13)
#define kAbstractLineHeight                         (40/2)
#define kCellContentColor                           RGBCOLOR(75, 75, 70)

@interface SNSpecialAbstractNewsTableCell()

@property(nonatomic, strong, readwrite)SNLabel *abstractLabel;

@end

@implementation SNSpecialAbstractNewsTableCell

@synthesize abstractLabel=_abstractLabel;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)object;
    CGFloat textHeight = [SNLabel heightForContent:snItem.news.abstract
                                          maxWidth:TTScreenBounds().size.width - kTableCellMargin * 2
                                              font:fontSize
                                        lineHeight:kAbstractLineHeight];

    snItem.cellHeight = textHeight + 2 * kTableCellMargin;
	return snItem.cellHeight;
}

- (void)setObject:(id)object {
    isNewItem = _item != object;
    
	if (isNewItem) {
        
		_item = object;
        
        if (_item) {
            SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
            SNDebugLog(SN_String("INFO: %@--%@, item is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [snItem description]);
            
            snItem.delegate = self;
            snItem.selector = nil;
            
            if (snItem.news.abstract && ![@"" isEqualToString:snItem.news.abstract]) {
                self.abstractLabel.text = snItem.news.abstract;
            }
            
            [self setNeedsDisplay];
        }
	}
}

- (SNLabel *)abstractLabel {
    if (!_abstractLabel) {
        _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectMake(horizontalPadding, horizontalPadding, textWidth, 0)];
        _abstractLabel.font = [UIFont systemFontOfSize:fontSize];
        _abstractLabel.backgroundColor = [UIColor clearColor];
        _abstractLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        [_abstractLabel setLineHeight:kAbstractLineHeight];
        [self addSubview:_abstractLabel];
    }
    return _abstractLabel;
}

- (void)layoutSubviews {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    
    // 动态算text长度
    NSString *title = self.abstractLabel.text;
    if (title && [title length] > 0) {
        CGFloat H = snItem.cellHeight;
        self.abstractLabel.height = H;
        snItem.cellHeight = H + 2*kTableCellMargin;
    }
    
    self.abstractLabel.frame = CGRectMake(kTableCellHPadding, kTableCellHPadding, TTScreenBounds().size.width - kTableCellMargin * 2, snItem.cellHeight);
    [self updateTheme];
}

- (void)showSelectedBg:(BOOL)show
{
//    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
//    if ([snItem.news.newsType isEqualToString:kSNTextNewsType]) return;
//    
}

- (void)setAlreadyReadStyle {
    
}

- (void)setUnReadStyle {
    
}

-(void)updateTheme {
    self.abstractLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
    [self setNeedsDisplay];
}

- (void)dealloc {
     //(_abstractLabel);
    
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIView drawCellSeperateLine:rect];
}

@end
