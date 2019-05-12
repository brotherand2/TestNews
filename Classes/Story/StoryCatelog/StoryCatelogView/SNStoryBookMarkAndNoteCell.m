//
//  SNStoryBookMarkAndNoteCell.m
//  sohunews
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryBookMarkAndNoteCell.h"
#import "SNStoryContanst.h"
#import "SNStoryBookMarkAndNoteModel.h"

#define CellLeftOffset                      14.0//cell左边距
#define BookMarkLabelTopOffset              12.0//书签的章节上边距
#define BookMarkLabelGap                    6.0//书签内容与章节的间距
#define BookMarkTimeLeftOffset              0.0//书签时间上边距

@interface SNStoryBookMarkAndNoteCell ()
@property(nonatomic, strong)UILabel *bookMarkLabel;
@property(nonatomic, strong)UILabel *bookMarkContent;
@property(nonatomic, strong)UILabel *bookMarkTime;
@end

@implementation SNStoryBookMarkAndNoteCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
        
        //书签章节
        self.bookMarkLabel = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftOffset, BookMarkLabelTopOffset, View_Width - CellLeftOffset*2, [UIFont systemFontOfSize:13].lineHeight)];
        self.bookMarkLabel.font = [UIFont systemFontOfSize:13];
        self.bookMarkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
        [self.contentView addSubview:self.bookMarkLabel];
        
        //书签内容
        self.bookMarkContent = [[UILabel alloc]initWithFrame:CGRectMake(CellLeftOffset, CGRectGetMaxY(self.bookMarkLabel.frame)+BookMarkLabelGap, View_Width - CellLeftOffset*2, [UIFont systemFontOfSize:16].lineHeight)];
        self.bookMarkContent.font = [UIFont systemFontOfSize:16];
        self.bookMarkContent.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        [self.contentView addSubview:self.bookMarkContent];
        
        //书签添加时间
        self.bookMarkTime = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bookMarkContent.frame)+BookMarkLabelGap, 0, [UIFont systemFontOfSize:11].lineHeight)];
        self.bookMarkTime.textAlignment = NSTextAlignmentLeft;
        self.bookMarkTime.font = [UIFont systemFontOfSize:11];
        self.bookMarkTime.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
        [self.contentView addSubview:self.bookMarkTime];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kNovelThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)updateTheme {
    
    self.contentView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
    
    //书签章节
    self.bookMarkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
    
    //书签内容
    self.bookMarkContent.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
    
    //书签添加时间
    self.bookMarkTime.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
}

-(void)storyBookMarkCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath isBookMark:(BOOL)isBookMark
{
    if ([model isKindOfClass:[NSArray class]]) {
        
        NSArray *arry = (NSArray *)model;
        if (!arry || arry.count <= 0) {
            return;
        } else {
            
            SNStoryBookMarkAndNoteModel *bookMarkAndNoteModel = [arry objectAtIndex:indexPath.row];
            self.bookMarkLabel.text = bookMarkAndNoteModel.bookMark;
            self.bookMarkContent.text = [[[bookMarkAndNoteModel.bookMarkcontent componentsSeparatedByString:@"\n"] componentsJoinedByString:@""] trim];
            self.bookMarkTime.text = bookMarkAndNoteModel.bookMarkTime;
            
            UIFont *timeFont = [UIFont systemFontOfSize:11];
            NSDictionary *dic = @{NSFontAttributeName:timeFont};
            CGSize timeSize = [bookMarkAndNoteModel.bookMarkTime boundingRectWithSize:CGSizeMake(200, timeFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
            CGRect timeRect = self.bookMarkTime.frame;
            timeRect.origin.x = View_Width-CellLeftOffset-timeSize.width;
            timeRect.size.width = timeSize.width;
            self.bookMarkTime.frame = timeRect;
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subView in self.subviews){ // 此处是为了设置左滑删除夜间模式
        if([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]){
            subView.backgroundColor = [UIColor colorFromKey:@"kThemeBg3Color"];
            if ([subView.subviews[0] isKindOfClass:NSClassFromString(@"_UITableViewCellActionButton")]) {
                
                UIButton* deleteBtn = (UIButton *)subView.subviews[0];
                [deleteBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
                deleteBtn.backgroundColor = [UIColor colorFromKey:@"kThemeRed1Color"];
                break;
            }
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNovelThemeDidChangeNotification object:nil];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
