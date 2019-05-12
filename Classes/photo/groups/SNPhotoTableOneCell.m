//
//  SNPhotoTableOneCell.m
//  sohunews
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoTableOneCell.h"
#import "SNWebImageView.h"
#import "RegexKitLite.h"

@implementation SNPhotoTableOneCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 211;
}

// cell图片是否已加载
-(BOOL)isImagesLoaded {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    if ([imagePaths count] > 0) {
        SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100];
        return imageView.hasLoaded;
    }
    return YES;
}

-(void)addImages:(BOOL)ignoreNonePicMode {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    if ([imagePaths count] > 0) {
        UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
        SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100];
        
        if (!imageView) {
            imageView = [[SNWebImageView alloc] initWithFrame:CGRectZero];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;

            imageView.frame = CGRectMake(10, 
                                         titleLabel.origin.y+titleLabel.frame.size.height+9, 
                                         self.frame.size.width-20, 
                                         145);
            imageView.tag = 100;
            self.lastImageView = imageView;
            [self.contentView addSubview:imageView];
            [imageView release];
            
            // background 圆角效果
            UIImageView *mask = [[UIImageView alloc] init];
            mask.tag = 123;
            mask.frame = imageView.frame;
            [self.contentView addSubview:mask];
            [mask release];
 
            
            NSString *defalutImageName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_600_290.png" : @"default_bg_600_290.png";
            NSString *iconImgName = [[SNThemeManager sharedThemeManager] themeFileName:defalutImageName];
            imageView.defaultImage = [[UIImage imageNamed:iconImgName] scaledImage];
            _currentPicMode = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"1" : @"0";
        }
        NSString *imagePath = [imagePaths objectAtIndex:0];

        if (imageView.hasLoaded && [imageView.urlPath isEqualToString:imagePath]) {
            return;
        }

        if (ignoreNonePicMode) {
            [imageView loadUrlPath:imagePath];
        } else {
            imageView.urlPath = imagePath;
        }
    }
}

- (void)changeImageAlpha {
     SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100];
    
    if (imageView) {
        NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
        imageView.alpha = [alpha floatValue];
    }
}

- (void)changeDefaultImage {
    SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100];
    if (imageView) {
        // 来回切换无图模式，需要修改对应的defaultImage
        NSString *defalutImageName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_600_290.png" : @"default_bg_600_290.png";
        [imageView setDefaultImage:[UIImage imageNamed:defalutImageName]];
    }
}

- (void)changeMask
{
    UIImageView *mask = (UIImageView *)[self.contentView viewWithTag:123];
    if (mask) {
        NSString *iconImgName = [[SNThemeManager sharedThemeManager] themeFileName:@"zutu_mask.png"];
        mask.image = [[UIImage imageNamed:iconImgName] scaledImage];
    }
}

- (void)openNews
{
    [super openNews];
}

@end
