//
//  SNTodayWidgetContentCollectionTitleViewCell.m
//  sohunews
//
//  Created by wangyy on 15/10/29.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNTodayWidgetContentCollectionTitleViewCell.h"
#import "UIColor+ColorUtils.h"

@interface SNTodayWidgetContentCollectionTitleViewCell ()

@end

@implementation SNTodayWidgetContentCollectionTitleViewCell

@synthesize newsTitleLabel = _newsTitleLabel;
@synthesize newsCommentCountIcon = _newsCommentCountIcon;
@synthesize newsCommentCountLabel = _newsCommentCountLabel;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createNewsTitleLabel];
        [self createNewsCommentCountIcon];
        [self createNewsCommentCountLabel];
        [self createLine];
    }
    
    return self;
}

#pragma mark - Private
- (void)createNewsTitleLabel {
    if (!self.newsTitleLabel) {
        self.newsTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        //ios10适配 5.7.2 upadte wangchuanwen begin
        UIColor *color = [UIColor colorFromString:@"#000000"];
        UIFont *font = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellTitleFontSizeIOS10];
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            color = [UIColor whiteColor];
            font = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellTitleFontSize];
        }
        self.newsTitleLabel.textColor = color;
        //ios10适配 5.7.2 upadte wangchuanwen end
        
        self.newsTitleLabel.font = font;
        self.newsTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.newsTitleLabel.numberOfLines = 0;
        self.newsTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.newsTitleLabel];
    }
}

- (void)createNewsCommentCountIcon {
    if (!self.newsCommentCountIcon) {
        self.newsCommentCountIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.newsCommentCountIcon.image = [UIImage imageNamed:@"icohome_commentsmall_v5.png"];
        [self.contentView addSubview:self.newsCommentCountIcon];
    }
}

- (void)createNewsCommentCountLabel {
    if (!self.newsCommentCountLabel) {
        self.newsCommentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        //ios10适配 5.7.2 upadte wangchuanwen begin
        UIColor *color = [UIColor colorFromString:@"#595959"];
        UIFont *font = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellCommentCountLabelFontSizeIOS10];
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            color = kSNTodayWidgetContentTableCellIconLabelTextColor;
            font = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellCommentCountLabelFontSize];
        }
        self.newsCommentCountLabel.textColor = color;
        //ios10适配 5.7.2 upadte wangchuanwen end
        
        self.newsCommentCountLabel.textAlignment = NSTextAlignmentLeft;
        self.newsCommentCountLabel.font = font;
        self.newsCommentCountLabel.text = @"0";
        [self.contentView addSubview:self.newsCommentCountLabel];
    }
}

- (void)createLine{
    
    UIImageView *imageLine = [[UIImageView alloc] init];
    CGRect imagerect = CGRectZero;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        imageLine.image = [UIImage imageNamed:@"vbg.png"];
        imagerect = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 0.5);
    } else {
        imageLine.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        imagerect = CGRectMake(14, self.bounds.size.height, self.bounds.size.width - 14*2, 0.5);
    }
    
    imageLine.frame = imagerect;
    [self addSubview:imageLine];
}

- (void)configureCellWithRowNews:(SNTodayWidgetNews *)newsItem{
    
    NSString *newsTitle = [newsItem.title trim];
    
    CGFloat titleWidth = self.bounds.size.width - CELL_LEFT*2 - 20;
    UIFont *newsTitleFont;
    CGFloat sizeHeight = 0;
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        
        newsTitleFont = [UIFont systemFontOfSize:kSNTodayWidgetContentTableCellTitleFontSize];
        sizeHeight = 40.0f;
    } else {
        
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
    CGRect commentRect = CGRectZero;
    CGFloat countLabelHeight = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        CGRectMake(CELL_LEFT, CELL_TOP - 30, titleWidth, newsTitleActualCGSize.height + 60);
        y = self.bounds.size.height - kSNTodayWidgetContentTableTextCellCommentCountIconHeight - CELL_TOP;
        commentRect = CGRectMake(CELL_LEFT, y, kSNTodayWidgetContentTableTextCellCommentCountIconWidth, kSNTodayWidgetContentTableTextCellCommentCountIconHeight);
        countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSize;
    }
    else
    {
        newsTitleRect = CGRectMake(14, 15, titleWidth, newsTitleActualCGSize.height);
        y = self.frame.size.height - 15 - kSNTodayWidgetContentTableTextCellCommentCountIconHeight;
        commentRect = CGRectMake(14, y, kSNTodayWidgetContentTableTextCellCommentCountIconWidth, kSNTodayWidgetContentTableTextCellCommentCountIconHeight);
        countLabelHeight = kSNTodayWidgetContentTableCellCommentCountLabelFontSizeIOS10;
    }
    
    self.newsTitleLabel.frame = newsTitleRect;
    self.newsTitleLabel.text = newsTitle;
    self.newsCommentCountIcon.frame = commentRect;
    
    self.newsCommentCountLabel.text = newsItem.commentCount;
    CGFloat x = self.newsCommentCountIcon.frame.origin.x + self.newsCommentCountIcon.frame.size.width + 6.0f;
    self.newsCommentCountLabel.frame = CGRectMake(x, y + 2, 120, countLabelHeight);
}

+ (CGFloat)cellHeightForNews:(SNTodayWidgetNews *)news width:(float)width{
    if (news.imgURLArray.count >= 3) {//组图时Cell的高度比图文、纯文的Cell要高
        
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            return [SNTodayWidgetContentCollectionTitleViewCell getImageHeight] + 70;
        } else {
            
            NSInteger groupPhotoCount = MIN(news.imgURLArray.count, 3);
            float imageWidth = (width - 14 * 2 - 10 * 2) / groupPhotoCount;
            return imageWidth / 1.55 + 65;
        }
    }
    else {
        
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            return CELL_IMAGE_HEIGHT + 20;
        } else {
            if ([[SNDevice sharedInstance] isPlus]) {
                
                return 238.0/3 + 15 * 2;
                
            }
            else
            {
                return 210.0/2/1.5 + 15 * 2;
            }
        }
    }
}

+ (CGFloat)getImageHeight {
    int imageHeight = 120/2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
            imageHeight = 240/3;
            break;
        case UIDevice6iPhone:
            imageHeight = 144/2;
            break;
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            imageHeight = 240/3;
            break;
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            imageHeight = 144/2;
            break;
        default:
            break;
    }
    return imageHeight;
}

+ (CGFloat)getImageDistance {
    int distance = 16/2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
            distance = 24/3;//(kAppScreenWidth-2*CONTENT_LEFT-3*[self getImageWidth])/2+1;
            break;
        case UIDevice6iPhone:
            distance = 14/2;
            break;
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            distance = 24/3;//(kAppScreenWidth-2*CONTENT_LEFT-3*[self getImageWidth])/2+1;
            break;
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            distance = 14/2;
            break;
        default:
            break;
    }
    return distance;
}

@end
