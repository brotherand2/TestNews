//
//  SNPhotoTableFourCell.m
//  sohunews
//
//  Created by ivan.qi  on 12-3-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoTableFourCell.h"
#import "SNSTFWebImageView.h"
#import "RegexKitLite.h"
#import "NSCellLayout.h"

@interface SNPhotoTableFourCell()
@property (nonatomic, strong) UIView *contentBgView;
@end

@implementation SNPhotoTableFourCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    int imageWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    int imageHeight = imageWidth * (1.f / 2.f);
    int cellHeight = imageHeight + (126 / 2);
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    _contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SNPhotoTableFourCell tableView:nil rowHeightForObject:nil])];
    _contentBgView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    
    [self.contentView insertSubview:_contentBgView atIndex:0];
    
    return self;
}

// cell图片是否已加载
- (BOOL)isImagesLoaded {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    long cnt = MIN(4, [imagePaths count]);
    for (int i = 0; i < cnt; i++) {
        SNSTFWebImageView *imageView = (SNSTFWebImageView *)[self.contentView viewWithTag:100 + i];
        if (imageView.hasLoaded) {
            return YES;
        }
    }
    return NO;
}

- (void)addImages:(BOOL)ignoreNonePicMode {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    if ([imagePaths count] >= 4) {
        UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
        CGRect frame = titleLabel.frame;
        frame.size.width = kAppScreenWidth - CONTENT_LEFT * 2;
        titleLabel.frame = frame;
        for (int i = 0; i < 4; i++) {
            SNSTFWebImageView *imageView = (SNSTFWebImageView *)[self.contentView viewWithTag:100 + i];
            if (!imageView) {
                imageView = [[SNSTFWebImageView alloc] initWithFrame:CGRectZero];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;

                int imageWidth = (kAppScreenWidth - 2 * CONTENT_LEFT - 7) / 2;

                if (i % 2 == 0) {
                    if (self.lastImageView) {
                        imageView.frame =
                        CGRectMake(CONTENT_LEFT, self.lastImageView.origin.y + self.lastImageView.frame.size.height + 7, imageWidth, imageWidth * 0.5);
                    } else {
                        imageView.frame = CGRectMake(CONTENT_LEFT, titleLabel.origin.y + titleLabel.frame.size.height + 9, imageWidth, imageWidth * 0.5);
                    }
                    self.lastImageView = imageView;
                } else {
                    imageView.frame = CGRectMake(self.lastImageView.origin.x + self.lastImageView.frame.size.width + 7, self.lastImageView.origin.y,
                                                 imageWidth, imageWidth * 0.5);
                }
                imageView.tag = 100 + i;
                [self.contentView addSubview:imageView];
                
                NSString *iconImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_292_150.png" : @"default_bg_292_150.png";
                imageView.defaultImage = [UIImage imageNamed:iconImgName];
                _currentPicMode = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"1" : @"0";
            }
            
            NSString *imagePath = [imagePaths objectAtIndex:i];
            if (imageView.hasLoaded && [imageView.urlPath isEqualToString:imagePath]) {
                continue;
            }

            if (ignoreNonePicMode) {
                [imageView loadUrlPath:imagePath];
            } else {
                imageView.urlPath = imagePath;
            }
        }
    }
}

- (void)changeImageAlpha {
    CGFloat aVal = themeImageAlphaValue();
    for (int i = 0; i < 4; i++) {
        SNSTFWebImageView *imageView = (SNSTFWebImageView *)[self.contentView viewWithTag:100 + i];
        if (imageView) {
            imageView.alpha = aVal;
        }
    }
}

- (void)changeTheme {
    [super changeTheme];
    _contentBgView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
}

- (void)changeDefaultImage {
    for (int i = 0; i < 4; i++) {
        SNSTFWebImageView *imageView = (SNSTFWebImageView *)[self.contentView viewWithTag:100 + i];
        if (imageView) {
            // 来回切换无图模式，需要修改对应的defaultImage
            NSString *defalutImageName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_292_150.png" : @"default_bg_292_150.png";
            [imageView setDefaultImage:[UIImage imageNamed:defalutImageName]];
        }
    }
}

- (void)changeMask {
    for (int i = 0; i < 4; i++) {
        UIImageView *mask = (UIImageView *)[self.contentView viewWithTag:200 + i];
        if (mask) {
            mask.image = [UIImage imageNamed:@"zutu_mask_1_4.png"];
        }
    }
}

- (void)openNews {
    [super openNews];
}

@end
