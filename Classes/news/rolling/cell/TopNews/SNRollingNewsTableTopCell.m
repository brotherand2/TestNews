//
//  SNRollingNewsTableTopCell.m
//  sohunews
//
//  Created by wangyy on 2017/11/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTableTopCell.h"

@implementation SNRollingNewsTableTopCell

@synthesize cellImageView = _cellImageView;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return newsItem.cellHeight;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    item.cellHeight = roundf(TOP_CELL_IMAGE_HEIGHT + 26);
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
            if (titleSize.width > titleWidth) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (CGFloat)getTitleWidth {
    //有图片时标题宽度不同
    CGFloat titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT - TOP_CELL_IMAGE_WIDTH - CELL_IMAGE_TITLE_DISTANCE;
    return titleWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        [self initPhotoImage];
    }
    return self;
}

- (void)initPhotoImage {
    CGRect imageViewRect = CGRectMake(CONTENT_LEFT, 13, TOP_CELL_IMAGE_WIDTH, TOP_CELL_IMAGE_HEIGHT);
    self.cellImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
    [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
    [self addSubview:self.cellImageView];
}

- (void)updateContentView {
    [super updateContentView];
    
    [self.cellImageView updateImageWithUrl:self.item.news.picUrl
                              defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]
                                 showVideo:[self.item hasVideo]];
    
    [self layOutTopCell];
}

- (void)layOutTopCell {
    CGRect frame = self.newsTitle.frame;
    BOOL isMultLineTitle = [SNRollingNewsTableTopCell isMultiLineTitleWithItem:self.item];
    float height = [SNUtility getNewsTitleHeight];
    if (isMultLineTitle) {
        height = height * 2 + 7;
    }
    self.newsTitle.frame = CGRectMake(self.cellImageView.right + CELL_IMAGE_TITLE_DISTANCE, 0, [[self class] getTitleWidth], height);
    
    self.topFlag.frame = CGRectMake(self.newsTitle.right + 10, 0, 30, kThemeFontSizeB + 2);
    self.topFlag.right = kAppScreenWidth - CONTENT_LEFT;
    if (isMultLineTitle) {
        self.newsTitle.centerY = self.cellImageView.centerY;
        self.topFlag.bottom = self.newsTitle.bottom - 3;
    } else {
        self.newsTitle.top = self.cellImageView.top;
        self.topFlag.bottom = self.newsTitle.bottom + [SNUtility getNewsTitleHeight];
    }
}

- (void)updateTheme {
    [super updateTheme];
    [self.cellImageView updateTheme];
    [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
}

@end
