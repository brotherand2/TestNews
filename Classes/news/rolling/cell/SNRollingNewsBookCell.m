//
//  SNRollingNewsBookCell.m
//  sohunews
//
//  Created by H on 2016/11/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsBookCell.h"
#import "SNStoryUtility.h"
#import "SNUtility.h"

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingNewsBookCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0) {
        rowCellHeight = roundf(CELL_BOOK_IMAGE_HEIGHT + 2 * IMAGE_TOP);
    }
    return rowCellHeight;
}

static int titleWidth = 0.0;
+ (CGFloat)getTitleWidth {
    if (titleWidth == 0) {
        //有图片时标题宽度不同
        titleWidth = kAppScreenWidth - 2*CONTENT_LEFT - CELL_BOOK_IMAGE_WIDTH - CELL_IMAGE_TITLE_DISTANCE;
    }
    return titleWidth;
}

static int abstractWidth = 0.0;
+ (CGFloat)getAbstractWidth {
    if (abstractWidth == 0) {
        //有图片时摘要宽度不同
        abstractWidth = kAppScreenWidth - 2 * CONTENT_LEFT - CELL_BOOK_IMAGE_WIDTH - CELL_IMAGE_TITLE_DISTANCE;
    }
    return abstractWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, CELL_BOOK_IMAGE_WIDTH, CELL_BOOK_IMAGE_HEIGHT);
        self.cellImageView.frame = imageViewRect;
        [self.cellImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholderNovel]];
    }
    return self;
}

- (void)updateTheme {
    [super updateTheme];
    [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholderNovel]];
    [self.cellImageView updateTheme];
}

- (void)updateImage {
    //如果self.item.news.picUrl为nil，图片view会隐藏，显示空白 update by wangchuanwen 5.8.7
    [self.cellImageView updateImageWithUrl:self.item.news.picUrl
                              defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholderNovel]
                                 showVideo:[self.item hasVideo]];
    
    if (self.item.cellType != SNRollingNewsCellTypeBook) {
        [super updateCellContentView];
        CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT);
        self.cellImageView.frame = imageViewRect;
        [self.cellImageView layOutVideoImageView];
    }
}

- (void)openNews {
    [SNUtility shouldUseSpreadAnimation:YES];
    [SNUtility shouldAddAnimationOnSpread:NO];
    [SNUtility openProtocolUrl:self.item.news.link];
    
    if ([self.item.news.channelId isEqualToString:@"13555"] ||
        [self.item.news.channelId isEqualToString:@"960415"]) {
        //详情页埋点统计 1.小说频道item点击
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&objType=fic_todetail&fromObjType=%@",@"1"]];
    } else {
        //推荐item点击,进入阅读页
        [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=10&bookId=%@",self.item.news.novelBookId]];
        
    }
}

@end
