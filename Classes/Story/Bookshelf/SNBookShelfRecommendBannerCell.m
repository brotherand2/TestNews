//
//  SNBookShelfRecommendBannerCell.m
//  sohunews
//
//  书籍推荐bannner位
//
//  Created by chuanwenwang on 2017/4/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBookShelfRecommendBannerCell.h"

#define BookBannerCellHeight                            99
#define BookBannerImageOriginX                          14//左边距
#define BookBannerImageYGap                             14//垂直间距

@implementation SNBookShelfRecommendBannerCell

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    return BookBannerCellHeight + BookBannerImageYGap*2;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        cellImageView = [[SNImageView alloc] initWithFrame:CGRectMake(BookBannerImageOriginX, BookBannerImageYGap, kAppScreenWidth - 2*BookBannerImageOriginX, BookBannerCellHeight)];
        [self addSubview:cellImageView];
    }
    return self;
}

-(void)updateNewsContent
{
    [super updateNewsContent];
    [self updateImage];
}

- (void)updateImage
{
    [cellImageView loadImageWithUrl:self.item.news.picUrl defaultImage:[UIImage imageNamed:@"zwt@2x.png"]];
    cellImageView.alpha = themeImageAlphaValue();
}

- (void)updateTheme
{
    [super updateTheme];
    cellImageView.alpha = themeImageAlphaValue();
    [cellImageView updateDefaultImage:[UIImage themeImageNamed:@"zwt@2x.png"]];
}

@end
