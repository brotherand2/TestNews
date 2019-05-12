//
//  SNRollingSohuFeedPhotoCell.m
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#define kPhotoViewCount 3

#import "SNRollingSohuFeedPhotoCell.h"
#import "SNCellImageView.h"

@interface SNRollingSohuFeedPhotoCell ()
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@end

@implementation SNRollingSohuFeedPhotoCell
@synthesize imageViewArray = _imageViewArray;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    CGFloat cellHeight = [super tableView:tableView rowHeightForObject:object];
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellHeight
    return cellHeight + [[self class] getImageWidth] + SOHUFEEDCELL_ITEM_HEIGHT;
    //modify end
}

+ (CGFloat)getImageWidth {
    return (kAppScreenWidth - CONTENT_LEFT * 2 - 6) / 3;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.imageViewArray = [[NSMutableArray alloc] init];
        [self initPhotoView];
    }
    return self;
}

- (void)initPhotoView {
    CGFloat x = CONTENT_LEFT;
    CGFloat distance = 4;
    CGFloat imageWidth = [[self class] getImageWidth];
    for (int i = 0; i < kPhotoViewCount; i++) {
        CGRect imageViewRect = CGRectMake(x, FEED_CONTENT_IMAGE_TOP, imageWidth, imageWidth);
        SNCellImageView *photoImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
        [photoImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder4]];
        [self.imageViewArray addObject:photoImageView];
        photoImageView.backgroundColor = [UIColor grayColor];
        [self addSubview:photoImageView];
        x += imageWidth + distance;
    }
}

- (void)updateContentView {
    [super updateContentView];
    [self updateGroupImages];
}

- (void)updateGroupImages {
    CGFloat imageTop = FEED_CONTENT_IMAGE_TOP;
    CGFloat spaceValue = (self.item.titleHeight == 0) ? 3 : FEED_SPACEVALUE - [SNRollingSohuFeedCell feedLineSpace:self.item];
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [self.imageViewArray objectAtIndex:i];
        photoImageView.top = imageTop + self.item.titleHeight + spaceValue;
        if (i < [self.item getGroupImagesCount]) {
            photoImageView.hidden = NO;
            NSString *imageUrl = [self.item.news.picUrls objectAtIndex:i];;
            [photoImageView updateImageWithUrl:imageUrl
                                  defaultImage:[UIImage imageNamed:kThemeImgPlaceholder4]
                                     showVideo:NO];
            [photoImageView updateTheme];
            
        } else {
            [photoImageView updateImageWithUrl:nil
                                  defaultImage:[UIImage imageNamed:kThemeImgPlaceholder4]
                                     showVideo:NO];
        }
    }
}

- (void)updateImage {
    [self updateGroupImages];
}

- (void)updateTheme {
    [super updateTheme];
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [self.imageViewArray objectAtIndex:i];
        [photoImageView updateTheme];
        [photoImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder4]];
    }
}

@end
