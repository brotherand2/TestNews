//
//  SNTodayWidgetContentCollectionGroupPhotoCell.m
//  sohunews
//
//  Created by wangyy on 15/10/29.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNTodayWidgetContentCollectionGroupPhotoCell.h"

static const int kSNTodayWidgetContentTableGroupPhotoCellMaxImgsCount = 3;

@interface SNTodayWidgetContentCollectionGroupPhotoCell ()

@property (nonatomic, strong) NSMutableArray *groupPhotoViews;
@property (nonatomic, strong) SNTodayWidgetNews *news;

@end

@implementation SNTodayWidgetContentCollectionGroupPhotoCell

@synthesize groupPhotoViews = _groupPhotoViews;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.groupPhotoViews = [NSMutableArray array];
        
        CGRect newsTitleRect = CGRectZero;
        CGFloat newsCommentX = 0;
        CGFloat y = 0;
        CGFloat countLabelHeight = 0;
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            
            newsTitleRect = CGRectMake(CELL_LEFT, CELL_TOP, self.bounds.size.width - CELL_LEFT*2, 20);
            newsCommentX = CELL_LEFT;
            y = self.bounds.size.height - kSNTodayWidgetContentTableTextCellCommentCountIconHeight - CELL_TOP;
            countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSize;
        }
        else
        {
            newsTitleRect = CGRectMake(14, 15, self.bounds.size.width - 14*2, 20);
            newsCommentX = 14;
            y = self.bounds.size.height - kSNTodayWidgetContentTableTextCellCommentCountIconHeight - 11;
            countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSizeIOS10;
        }
        self.newsTitleLabel.frame = newsTitleRect;
        
        self.newsCommentCountIcon.frame = CGRectMake(newsCommentX, y, kSNTodayWidgetContentTableTextCellCommentCountIconWidth, kSNTodayWidgetContentTableTextCellCommentCountIconHeight);
        CGFloat x = self.newsCommentCountIcon.frame.origin.x + self.newsCommentCountIcon.frame.size.width + 5.0f;
        self.newsCommentCountLabel.frame = CGRectMake(x, y, 120, countLabelHeight);
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)configureCellWithRowNews:(SNTodayWidgetNews *)newsItem{
    
    self.news = newsItem;
    
    //Update title and its height
    self.newsTitleLabel.text = [newsItem.title trim];
    
    //Update group images
    [self updateGroupPhotoViews];
    
    //Update comment count
    self.newsCommentCountLabel.text = newsItem.commentCount;
}

- (void)updateGroupPhotoViews{
    for (UIImageView *imgView in _groupPhotoViews) {
        [imgView removeFromSuperview];
    }
    [_groupPhotoViews removeAllObjects];
    
    NSInteger groupPhotoCount = MIN(self.news.imgURLArray.count, kSNTodayWidgetContentTableGroupPhotoCellMaxImgsCount);
    CGFloat x = CELL_LEFT;
    CGFloat y = CELL_TOP + self.newsTitleLabel.frame.size.height + 5;
    //适配6和plus放大模式
    int imageWidth = (self.frame.size.width - 20  - x * 2 - [SNTodayWidgetContentCollectionTitleViewCell getImageDistance] * 2) / groupPhotoCount;
    float height = [SNTodayWidgetContentCollectionTitleViewCell getImageHeight];
    
    if (!SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        
        imageWidth = (self.frame.size.width - 14 * 2 - 10 * 2) / groupPhotoCount;
        height = imageWidth / 1.55;
        x = 14;
        y = 15 + self.newsTitleLabel.frame.size.height + 5;
    }
    
    for (int i=0; i<groupPhotoCount; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,imageWidth,height)];
        NSString *imgURLString = [self.news.imgURLArray objectAtIndex:i];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgURLString];
        if (cacheImage != nil) {
            imgView.image = cacheImage;
        }
        else{
            [imgView sd_setImageWithURL:[NSURL URLWithString:imgURLString] placeholderImage:[UIImage imageNamed:@"todaywidget_news_defaultimage.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!!error) {
                    SNDebugLog(@"...Failed to get image, %d, %@", error.code, error.localizedDescription);
                } else {
                    SNDebugLog(@"...Succeed to get image");
                }
            }];
        }
        
        [self addSubview:imgView];
        [_groupPhotoViews addObject:imgView];
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            
            x += (imageWidth + [SNTodayWidgetContentCollectionTitleViewCell getImageDistance]);
        }else
        {
            x += (imageWidth + 10);
        }
    }
}

@end
