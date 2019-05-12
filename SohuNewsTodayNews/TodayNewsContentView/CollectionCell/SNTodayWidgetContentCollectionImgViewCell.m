//
//  SNTodayWidgetContentCollectionImgViewCell.m
//  sohunews
//
//  Created by wangyy on 15/10/29.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNTodayWidgetContentCollectionImgViewCell.h"
#import "SNDevice.h"

@interface SNTodayWidgetContentCollectionImgViewCell ()

@property (nonatomic, strong) UIImageView *newsImageView;

@end

@implementation SNTodayWidgetContentCollectionImgViewCell

@synthesize newsImageView = _newsImageView;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createNewsImageView];
    }
    
    return self;
}

#pragma mark - Private
- (void)createNewsImageView {
    if (!self.newsImageView) {
        
        CGRect newsImageRect = CGRectZero;
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            newsImageRect = CGRectMake(CELL_LEFT,CELL_TOP,CELL_IMAGE_WIDTH,CELL_IMAGE_HEIGHT);
        } else {
            float cellHeight = self.bounds.size.height;
            newsImageRect = CGRectMake(14,15,(cellHeight - 15*2)*1.5,cellHeight - 15*2);
        }
        self.newsImageView = [[UIImageView alloc] initWithFrame:newsImageRect];
        self.newsImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.newsImageView];
    }
}

- (void)configureCellWithRowNews:(SNTodayWidgetNews *)newsItem{
    NSString *imgURLString = @"";
    if (newsItem.imgURLArray.count > 0) {
        imgURLString = [newsItem.imgURLArray objectAtIndex:0];
    }
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgURLString];
    if (cacheImage != nil) {
        self.newsImageView.image = cacheImage;
    }
    else{
        [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:imgURLString]
                              placeholderImage:[UIImage imageNamed:@"todaywidget_news_defaultimage.png"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         if (!!error) {
                                             SNDebugLog(@"...Failed to get image, %ld, %@", error.code, error.localizedDescription);
                                         } else {
                                             SNDebugLog(@"...Succeed to get image");
                                         }
                                     }];
    }
    
    NSString *newsTitle = [newsItem.title trim];
    CGFloat x = self.newsImageView.frame.origin.x + self.newsImageView.frame.size.width + 10;
    
    CGFloat titleWidth = 0;
    UIFont *newsTitleFont;
    CGFloat sizeHeight = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        
        titleWidth = self.bounds.size.width - CELL_LEFT - x - 20;
        newsTitleFont = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellTitleFontSize];
        sizeHeight = 40.0f;
    } else {
        titleWidth = self.bounds.size.width - x - 20;
        newsTitleFont = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellTitleFontSizeIOS10];
        sizeHeight = self.bounds.size.height - 2*15 - 18;
    }
    
    NSDictionary *attributeDic = @{NSFontAttributeName: newsTitleFont};
    CGSize constraintSize = CGSizeMake(titleWidth, sizeHeight);
    CGSize newsTitleActualCGSize = [newsTitle boundingRectWithSize:constraintSize
                                                           options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                        attributes:attributeDic
                                                           context:nil].size;
    
    
    CGRect newsTitleRect = CGRectZero;
    CGFloat y = 0;
    CGFloat countLabelHeight = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        newsTitleRect = CGRectMake(x , CELL_TOP - 30, titleWidth, newsTitleActualCGSize.height + 60);
        y = self.bounds.size.height - kSNTodayWidgetContentTableTextCellCommentCountIconHeight - CELL_TOP;
        countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSize;
    } else {
        newsTitleRect = CGRectMake(x, 15, titleWidth, newsTitleActualCGSize.height);
        y = CGRectGetMaxY(self.newsImageView.frame) - kSNTodayWidgetContentTableTextCellCommentCountIconHeight;
        countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSizeIOS10;
    }
    self.newsTitleLabel.frame = newsTitleRect;
    self.newsTitleLabel.text = newsTitle;
    
    self.newsCommentCountIcon.frame = CGRectMake(x, y, kSNTodayWidgetContentTableTextCellCommentCountIconWidth, kSNTodayWidgetContentTableTextCellCommentCountIconHeight);
    
    self.newsCommentCountLabel.text = newsItem.commentCount;
    x = self.newsCommentCountIcon.frame.origin.x + self.newsCommentCountIcon.frame.size.width + 6.0f;
    self.newsCommentCountLabel.frame = CGRectMake(x, y, 120, countLabelHeight);
}

@end
