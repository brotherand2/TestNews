//
//  SNRollingNewsTitleTopCell.m
//  sohunews
//
//  Created by wangyy on 2017/11/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTitleTopCell.h"
#import "SNRollingNewsTitleCell.h"
#import "UIFont+Theme.h"

@implementation SNRollingNewsTitleTopCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return newsItem.cellHeight;
}

+ (CGFloat)getTitleWidth {
    return kAppScreenWidth - CONTENT_LEFT*2;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    CGFloat titleWidth = [[self class] getTitleWidth:item];
    UIFont *titleFont = [SNUtility getTopTitleFont];
    if (item.news.title && ![item.news.title isEqualToString:@""]) {
        CGSize titleSize = [item.news.title sizeWithFont:titleFont];
        if (titleSize.width > titleWidth) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isSingleLongLineTitleWithItem:(SNRollingNewsTableItem *)item {
    BOOL isMultLineTitle = [SNRollingNewsTitleTopCell isMultiLineTitleWithItem:item];
    if (!isMultLineTitle) {
        CGFloat titleWidth = [[self class] getTitleWidth:item] - 40;
        if (item.news.title && ![item.news.title isEqualToString:@""]) {
            UIFont *font = [SNUtility getTopTitleFont];
            CGSize titleSize = [item.news.title sizeWithFont:font];
            if (titleSize.width > titleWidth+2) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    [super calculateCellHeight:item];
    float height = [SNUtility getNewsTitleHeight];
    BOOL isMultLineTitle = [SNRollingNewsTitleTopCell isMultiLineTitleWithItem:item];
    BOOL isSingleLongLine = [SNRollingNewsTitleTopCell isSingleLongLineTitleWithItem:item];
    if (isMultLineTitle || isSingleLongLine) {
        height = height * 2;
    }
    
    item.cellHeight = height + IMAGE_TOP*2;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        [self initNewsTitletView];
        [self initTopFlag];
    }
    return self;
}

- (void)initNewsTitletView {
    UIFont *font = [SNUtility getTopTitleFont];
    self.newsTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.newsTitle.numberOfLines = 2;
    self.newsTitle.textColor = SNUICOLOR(kThemeTextRIColor);
    self.newsTitle.font = font;
    self.newsTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.newsTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:self.newsTitle];
}

- (void)initTopFlag {
    self.topFlag = [[UILabel alloc] initWithFrame:CGRectMake(kAppScreenWidth - CONTENT_LEFT-30, 0, 30, kThemeFontSizeB + 2)];
    self.topFlag.textColor = SNUICOLOR(kThemeTextRI1Color);
    self.topFlag.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];;
    self.topFlag.text = @"置顶";
    self.topFlag.textAlignment = NSTextAlignmentRight;
    self.topFlag.backgroundColor = [UIColor clearColor];
    self.topFlag.right = kAppScreenWidth - CONTENT_LEFT;
    [self addSubview:self.topFlag];
}

- (void)layOutTopCell{
    float height = [SNUtility getNewsTitleHeight];
    BOOL isMultLineTitle = [SNRollingNewsTitleTopCell isMultiLineTitleWithItem:self.item];
    CGFloat offsetTop = IMAGE_TOP;
    if (isMultLineTitle) {
        height = height * 2 + 5 ;
        offsetTop -= 3;
    }

    self.newsTitle.frame = CGRectMake(CONTENT_LEFT,offsetTop,[[self class] getTitleWidth],height);
    
    BOOL isSingelLoneLine = [SNRollingNewsTitleTopCell isSingleLongLineTitleWithItem:self.item];
    if (isSingelLoneLine) {
         self.topFlag.bottom = self.newsTitle.bottom + height + 2;
    }
    else{
        self.topFlag.bottom = self.newsTitle.bottom -3;
    }
}

- (void)updateContentView {
    [super updateContentView];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 3; //设置行间距
    
    UIFont *font = [SNUtility getTopTitleFont];
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle};
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:self.item.news.title attributes:dic];
    self.newsTitle.attributedText = attributeStr;
    self.newsTitle.font = font;
    [self layOutTopCell];
}

- (void)updateNewsContent {
}

- (void)updateTheme{
    [super updateTheme];
    
    self.newsTitle.textColor = SNUICOLOR(kThemeTextRIColor);
    self.topFlag.textColor = SNUICOLOR(kThemeTextRI1Color);
}

- (void)setAlreadyReadStyle {
    //TODO:设置已读样式
    currentReadStatus = CELL_READ_STYLE_READ;
    self.newsTitle.textColor = SNUICOLOR(kThemeText3Color);
}

- (void)setUnReadStyle {
    //TODO:设置未读样式
    currentReadStatus = CELL_READ_STYLE_UNREAD;
    self.newsTitle.textColor = SNUICOLOR(kThemeTextRIColor);
}

@end
