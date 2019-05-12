//
//  SNStoryCatelogCell.m
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/19.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryCatelogCell.h"
#import "SNStoryContanst.h"
#import "UIImage+Story.h"
#import "ChapterList.h"
#import "StoryBookList.h"

#define CellLeftOffset                      14.0//cell左边距
#define ChapterLabelTopOffset               21.0//章节上边距
#define ChapterLockImageViewTopOffset       21.0//章节图片上边距
#define ChapterLockImageViewLeftGap         10.0//章节图片与章节的间距

@interface SNStoryCatelogCell ()

@property(nonatomic, assign)NSUInteger selectedChapterId;
@property(nonatomic, strong)UILabel *chapterLabel;
@property(nonatomic, strong)UILabel *downLabel;
@property(nonatomic, strong)UIImageView *chapterLockImageView;
@property(nonatomic, strong)NSString *novelId;
@end

@implementation SNStoryCatelogCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageStoryNamed:@"icofiction_lock_v5.png"];
        //
        self.chapterLabel = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftOffset, ChapterLabelTopOffset, View_Width - CellLeftOffset*2 - image.size.width - ChapterLockImageViewLeftGap, [UIFont systemFontOfSize:16].lineHeight)];
        self.chapterLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.chapterLabel];
        
        self.downLabel = [[UILabel alloc]initWithFrame:CGRectMake(View_Width - CellLeftOffset, ChapterLabelTopOffset, image.size.width, [UIFont systemFontOfSize:16].lineHeight)];
        self.downLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.downLabel];
        //
        self.chapterLockImageView = [[UIImageView alloc]initWithFrame:CGRectMake(View_Width - CellLeftOffset - image.size.width, ChapterLockImageViewTopOffset, image.size.width, image.size.height)];
        [self.contentView addSubview:self.chapterLockImageView];
        
    }
    
    return self;
}

-(void)storyCatelogCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath
{
    if ([model isKindOfClass:[NSArray class]]) {
        
        for (UIView *cellView in self.contentView.subviews) {
            [cellView removeFromSuperview];
        };
        NSArray *arry = (NSArray *)model;
        self.chapterLockImageView.image = nil;
        ChapterList *chapter = [arry objectAtIndex:indexPath.row];
        
        self.novelId = chapter.bookId;
        StoryBookList *book = [StoryBookList fecthBookByBookId:self.novelId];
        
        
        self.chapterLabel.text = chapter.chapterTitle;
        
        if (!chapter.isfree && !chapter.hasPaid) {
            
            UIImage *image = [UIImage imageStoryNamed:@"icofiction_lock_v5.png"];
            self.chapterLockImageView.image = image;
        }
        
        if ((chapter.isfree || chapter.hasPaid) && chapter.isDownload) {
            CGSize downLabelSize = [@"已下载" boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:0].size;
            CGRect downLabelRect = self.downLabel.frame;
            downLabelRect.origin.x = View_Width - downLabelSize.width - CellLeftOffset;
            downLabelRect.size.width = downLabelSize.width;
            self.downLabel.frame = downLabelRect;
            self.downLabel.text = @"已下载";
        }
        else
        {
            self.downLabel.text = @"";
        }
        
        if (book) {
            NSUInteger chapterId = book.hasReadChapterId;
            if (chapterId == chapter.chapterId) {
                self.chapterLabel.textColor = [UIColor colorFromKey:@"kThemeRed1Color"];
                self.selectedChapterId = chapter.chapterId;
            } else {
                self.chapterLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
            }
            
        } else {
            self.chapterLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        }
        self.downLabel.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
        [self.contentView addSubview:self.chapterLabel];
        [self.contentView addSubview:self.chapterLockImageView];
        [self.contentView addSubview:self.downLabel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
