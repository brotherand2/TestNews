//
//  SNTransactionHistoryCell.m
//  sohunews
//
//  Created by H on 2016/12/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTransactionHistoryCell.h"
#import "SNTransactionHistoryItem.h"

@interface SNTransactionHistoryCell ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timestampLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UILabel * retryTipLabel;
@property (nonatomic, strong) UIView * separatorLine;

@end

@implementation SNTransactionHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initContent];
    }
    return self;
}

- (void)initContent{
    self.backgroundColor = SNUICOLOR(kThemeBg3Color);
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect screenRect = TTScreenBounds();
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, screenRect.size.width - 100, 30)];
    self.titleLabel.text = @"充值100书币";
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    self.titleLabel.textColor = SNUICOLOR(kThemeText2Color);
    [self.contentView addSubview:self.titleLabel];
    
    self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 150, 30)];
    self.timestampLabel.text = @"12月23日 19：20";
    self.timestampLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.timestampLabel.textColor = SNUICOLOR(kThemeText3Color);
    self.timestampLabel.top = self.titleLabel.bottom + 5;
    [self.contentView addSubview:self.timestampLabel];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 30)];
    self.statusLabel.text = @"充值成功";
    self.statusLabel.textAlignment = NSTextAlignmentRight;
    self.statusLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    self.statusLabel.textColor = SNUICOLOR(kThemeText2Color);
    self.statusLabel.right = screenRect.size.width - 14;
    [self.contentView addSubview:self.statusLabel];

    self.retryTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    self.retryTipLabel.text = @"点此重试(重试时不会再次扣费)";
    self.retryTipLabel.textAlignment = NSTextAlignmentRight;
    self.retryTipLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.retryTipLabel.textColor = SNUICOLOR(kThemeText3Color);
    self.retryTipLabel.right = screenRect.size.width - 14;
    self.retryTipLabel.top = self.statusLabel.bottom + 5;
    [self.contentView addSubview:self.retryTipLabel];
    
    self.separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 79, kAppScreenWidth, 0.5)];
    self.separatorLine.backgroundColor = SNUICOLOR(kThemeText3Color);
    [self.contentView addSubview:self.separatorLine];
}

- (void)layoutWithItem:(SNTransactionHistoryItem *)item {
    switch (item.transactionType) {
        case SNTransactionTypeSuccessed:
        {
            self.retryTipLabel.hidden = YES;
            self.statusLabel.text = @"充值成功";
            self.statusLabel.textColor = SNUICOLOR(kThemeText2Color);
            self.timestampLabel.text = item.ctime;
            self.titleLabel.text = [NSString stringWithFormat:@"充值书币 %@",item.amount];
            break;
        }
        case SNTransactionTypeFailed:
        {
            self.retryTipLabel.hidden = NO;
            self.statusLabel.text = @"充值失败";
            self.statusLabel.textColor = SNUICOLOR(kThemeRed1Color);
            self.timestampLabel.text = item.ctime;
            self.titleLabel.text = [NSString stringWithFormat:@"充值书币 %@",item.amount];
            break;
        }
        default:
            break;
    }
}
@end
