//
//  SNBookShelfRecommendClassificationLabelCell.m
//  sohunews
//
//  书籍推荐分类标签
//
//  Created by chuanwenwang on 2017/4/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBookShelfRecommendClassificationLabelCell.h"
#import "SNStoryUtility.h"
#import "UIFont+Theme.h"

#define labelButtonOriginX                          10//左边距
#define labelButtonGap                              10//水平间距
#define labelButtonYGap                             15//垂直间距
#define labelButtonHeight                           30//水平间距
#define labelButtonBaseTag                          3111//tag基值
#define labelCellSmall3Height                       78//tags小于3的cell高
#define labelCellBig3Height                         118//tags大于3的cell高


@implementation SNBookShelfRecommendClassificationLabelCell

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
    SNRollingNewsTableItem *newsItem = object;
    NSInteger count = newsItem.news.bookLabelArray.count;
    
    if (count <= 0) {
        return 0;
    }else if (count <= 3){
        
        return labelCellSmall3Height;
    }else {
        return labelCellBig3Height;
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        for (int i = 0; i < 6; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = SNUICOLOR(kThemeBg2Color);
            button.tag = labelButtonBaseTag + i;
            button.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
            [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(labelTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    return self;
}

-(void)updateNewsContent
{
    [super updateNewsContent];
    
    float width = (kAppScreenWidth - labelButtonOriginX * 2 - labelButtonGap*2)/3.0;
    NSInteger bookLabelCount = self.item.news.bookLabelArray.count;
    
    float orginY = 0;
    if (bookLabelCount <= 3) {
        orginY = (labelCellSmall3Height - labelButtonHeight) / 2.0;
    } else {
        orginY = (labelCellBig3Height - labelButtonHeight * 2 - labelButtonYGap) / 2.0;
    }
    
    for (int i = 0; i < bookLabelCount; i++) {
        SNBookLabel *bookLabel = self.item.news.bookLabelArray[i];
        UIButton *button = [self viewWithTag:(labelButtonBaseTag + i)];
        button.frame = CGRectMake(labelButtonOriginX + (width + labelButtonGap)*(i%3), orginY + (labelButtonHeight + labelButtonYGap) * (i/3), width, labelButtonHeight);
        [button setTitle:bookLabel.name forState:UIControlStateNormal];
    }
}

- (void)updateTheme
{
    [super updateTheme];
    
    NSInteger bookLabelCount = self.item.news.bookLabelArray.count;
    
    for (int i = 0; i < bookLabelCount; i++) {
        UIButton *button = [self viewWithTag:(labelButtonBaseTag + i)];
        button.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    }
}


-(void)labelTap:(UIButton *)button
{
    SNBookLabel *bookLable = self.item.news.bookLabelArray[button.tag - labelButtonBaseTag];
    if ([bookLable.type isEqualToString:@"1"]) {//type为1:分类标签 type为2:运营标签
        
        [SNStoryUtility openProtocolUrl:bookLable.readUrl context:nil];
        [SNStoryUtility storyReportADotGif:@"objType=fic_category_tag&fromObjType=channel&statType=clk"];
    } else {
        
        NSString *strUrl = [bookLable.readUrl stringByAppendingFormat:@"&channelId=%@",self.item.news.channelId];
        [SNStoryUtility openProtocolUrl:strUrl context:nil];
        [SNStoryUtility storyReportADotGif:@"objType=fic_operate_tag&fromObjType=channel&statType=clk"];
    }
}

@end
