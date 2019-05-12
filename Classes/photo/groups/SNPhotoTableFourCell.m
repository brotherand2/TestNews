//
//  SNPhotoTableFourCell.m
//  sohunews
//
//  Created by ivan.qi  on 12-3-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoTableFourCell.h"
#import "SNWebImageView.h"
#import "RegexKitLite.h"

@implementation SNPhotoTableFourCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 223;
}

// cell图片是否已加载
-(BOOL)isImagesLoaded {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    int cnt = MIN(4, [imagePaths count]);
    for (int i = 0; i < cnt; i++) {
        SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100+i];
        if (imageView.hasLoaded) {
            return YES;
        }
    }
    return NO;
}

-(void)addImages:(BOOL)ignoreNonePicMode {
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    if ([imagePaths count] >= 4) {
        UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
        for (int i = 0; i < 4; i++) {
            SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100+i];
            if (!imageView) {
                imageView = [[SNWebImageView alloc] initWithFrame:CGRectZero];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;

                if (i%2 == 0) {
                    if (self.lastImageView) {
                        imageView.frame = CGRectMake(10, 
                                                     self.lastImageView.origin.y+self.lastImageView.frame.size.height+7, 
                                                     146, 75);
                    } else {
                        imageView.frame = CGRectMake(10, 
                                                     titleLabel.origin.y+titleLabel.frame.size.height+9, 
                                                     146, 75);
                    }
                    self.lastImageView = imageView;
                } else {
                    imageView.frame = CGRectMake(self.lastImageView.origin.x+self.lastImageView.frame.size.width+7, 
                                                 self.lastImageView.origin.y, 
                                                 146,75);
                }
                imageView.tag = 100+i;
                [self.contentView addSubview:imageView];
                [imageView release];
                
                // 圆角效果 
                UIImageView *mask = [[UIImageView alloc] init];
                mask.frame = imageView.frame;
                mask.tag = 200+i;
                [self.contentView addSubview:mask];
                [mask release];
                
                NSString *defalutImageName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_292_150.png" : @"default_bg_292_150.png";
                NSString *iconImgName = [[SNThemeManager sharedThemeManager] themeFileName:defalutImageName];
                imageView.defaultImage = [[UIImage imageNamed:iconImgName] scaledImage];
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
    NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
    CGFloat aVal = [alpha floatValue];
    for (int i = 0; i < 4; i++) {
        SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100+i];
        if (imageView) {
            imageView.alpha = aVal;
        }
    }
}

- (void)changeDefaultImage {
    
    NSMutableArray *imagePaths = self.item.hotPhotoNews.images;
    
    for (int i = 0; i < 4; i++) {
        SNWebImageView *imageView = (SNWebImageView *)[self.contentView viewWithTag:100+i];
        if (imageView) {
            // 来回切换无图模式，需要修改对应的defaultImage
            NSString *defalutImageName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_bg_click_292_150.png" : @"default_bg_292_150.png";
            [imageView setDefaultImage:[UIImage imageNamed:defalutImageName]];
            
            SNDebugLog(@"imagePath %@ : %@", imagePaths[i], defalutImageName);
        }
    }
}

- (void)changeMask
{
    for (int i = 0; i < 4; i++) {
        UIImageView *mask = (UIImageView *)[self.contentView viewWithTag:200+i];
        if (mask) {
            NSString *iconImgName = [[SNThemeManager sharedThemeManager] themeFileName:@"zutu_mask_1_4.png"];
            mask.image = [[UIImage imageNamed:iconImgName] scaledImage];
        }
    }
}

- (void)openNews
{
    [super openNews];
}

@end
