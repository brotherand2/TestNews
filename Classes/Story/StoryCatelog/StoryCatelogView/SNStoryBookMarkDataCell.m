//
//  SNStoryBookMarkDataCell.m
//  sohunews
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryBookMarkDataCell.h"
#import "SNStoryContanst.h"
#import "UIImage+Story.h"

#define CellLeftOffset                      14.0//cell左边距
#define BookMarkImageViewLeftOffset         0.0//书签图片左边距
#define BookMarkImageViewTopOffset          150.0//书签图片上边距
#define BookMarkLabelLeftOffset             0.0//书签内容右边距
#define BookMarkGap                         12.0//书签时间上边距

@interface SNStoryBookMarkDataCell ()
@property(nonatomic, strong)UILabel *bookMarkLabel;
@property(nonatomic, strong)UIImageView *bookMarkImageView;
@property(nonatomic, assign)NSInteger tab;
@end


@implementation SNStoryBookMarkDataCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bookTab:(StoryBookNoDataTab)tab
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
        self.tab = tab;
        //无书签/批注
        UIFont *font = [UIFont systemFontOfSize:13];
        
        NSString *bookMarkStr = @"";
         UIImage *image = nil;
        switch (tab) {
            case StoryBookNoDataTabChapter:
            {
                bookMarkStr = @"点击重试哦";
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshChapterList)];
                [self addGestureRecognizer:tapGesture];
                image = [UIImage imageStoryNamed:@"icofiction_hqsb_v5.png"];
                break;
            }
            case StoryBookNoDataTabMark:
            {
                bookMarkStr = @"还没有添加过标签哦";
                image = [UIImage imageStoryNamed:@"icofiction_sqkb_v5.png"];
                break;
            }
            case StoryBookNoDataTabTip:
            {
                bookMarkStr = @"还没有添加过批注哦";
                image = [UIImage imageStoryNamed:@"icofiction_pzkb_v5.png"];
                break;
            }
            default:
                break;
        }
        
        float centerHeight = (kAppScreenHeight - StoryHeaderTotalHeight - BottomBarHeight - (image.size.height + BookMarkGap + font.lineHeight))/2.0;
        self.bookMarkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(BookMarkImageViewLeftOffset, centerHeight, image.size.width, image.size.height)];
        self.bookMarkImageView.image = image;
        
        CGRect bookMarkImageViewRect = self.bookMarkImageView.frame;
        bookMarkImageViewRect.origin.x = (View_Width - image.size.width) / 2;
        self.bookMarkImageView.frame = bookMarkImageViewRect;
        [self.contentView addSubview:self.bookMarkImageView];
        
        self.bookMarkLabel = [[UILabel alloc]initWithFrame:CGRectMake(BookMarkLabelLeftOffset, CGRectGetMaxY(self.bookMarkImageView.frame)+BookMarkGap, View_Width, font.lineHeight)];
        self.bookMarkLabel.font = font;
        self.bookMarkLabel.text = bookMarkStr;
        self.bookMarkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
        [self.contentView addSubview:self.bookMarkLabel];
        
        NSDictionary *dic = @{NSFontAttributeName:font};
        CGSize bookMarkSize = [bookMarkStr boundingRectWithSize:CGSizeMake((View_Width - CellLeftOffset*2)/2.0, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
        CGRect bookMarkRect = self.bookMarkLabel.frame;
        bookMarkRect.origin.x = (View_Width - bookMarkSize.width) / 2;
        bookMarkRect.size.width = bookMarkSize.width;
        self.bookMarkLabel.frame = bookMarkRect;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kNovelThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)updateTheme {
    
    self.contentView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    
    //无书签/批注
    self.bookMarkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
     UIImage *image = [UIImage imageStoryNamed:@"icofiction_sqkb_v5.png"];
    switch (self.tab) {
        case StoryBookNoDataTabChapter:
        {
            image = [UIImage imageStoryNamed:@"icofiction_hqsb_v5.png"];
            break;
        }
        case StoryBookNoDataTabMark:
        {
            image = [UIImage imageStoryNamed:@"icofiction_sqkb_v5.png"];
            break;
        }
        case StoryBookNoDataTabTip:
        {
            image = [UIImage imageStoryNamed:@"icofiction_sqkb_v5.png"];
            break;
        }
        default:
            break;
    }
    
    self.bookMarkImageView.image = image;
}

-(void)refreshChapterList
{
    if (self.refreshChapter) {
        self.refreshChapter();
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNovelThemeDidChangeNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
