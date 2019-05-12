//
//  SNTagTableCell.m
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagPhotoTableCell.h"
#import "SNCategoryButton.h"
#import "SNTagButton.h"
#import "UIColor+ColorUtils.h"

#define CELL_LEFT_RIGHT_MARGIN          (10)
#undef CELL_TOP_MARGIN
#define CELL_TOP_MARGIN                 (30)
#undef CELL_BOTTOM_MARGIN
#define CELL_BOTTOM_MARGIN              (10)

#define CELL_WIDTH                      (320)

#define CELL1_BG_TOP_MARGIN             (14)
#define CELL2_BG_TOP_MARGIN             (9)

#define TITLE_LABEL_HEIGHT              (15)
#define TITLE_LABEL_WIDTH               (60)
#define TITLE_TOP_MARGIN                (10.5)
#define TITLE_LEFT_MARGIN               (13-4.5)
#define TITLE_LINE_MARGIN               (8)

#define CATEGORY_BUTTON_MARGIN          (40-9)
#define CATEGORY_ICON_WIDTH             (44)
#define CATEGORY_ICON_HEIGHT            (44)
#define CATEGORY_BUTTON_WIDTH           (50)
#define CATEGORY_BUTTON_HEIGHT          (60)
#define CATEGORY_BUTTON_ROW_MARGIN      (20)

#define TAG_BUTTON_MARGIN               (9)
#define TAG_BUTTON_ROW_MARGIN           (7)
#define TAG_BUTTON_LEFT_RIGHT_PADING    (10)
#define TAG_BUTTON_HEIGHT               (23.5)
#define TAG_LINE_MARGIN                 (10)

#define CAGETORY_FONT_SIZE              (12)
#define TAG_FONT_SIZE                   (12.5)

#define LINE_LEFT_RIGHT_MARGIN          (8)
#define CIRCLE_BG_LEFT_RIGHT_MARGIN     (4)

@implementation SNTagPhotoTableCell

@synthesize item, cellBgView, allBtns, selectedType, selectedId;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNTagPhotoTableItem *dataItem  = (SNTagPhotoTableItem*)object;
    CGFloat h = TITLE_TOP_MARGIN;
    h += TITLE_LABEL_HEIGHT;
    h += TITLE_LINE_MARGIN;
    
    if (dataItem.row == 0) {
        h += CELL1_BG_TOP_MARGIN;
        h += 1;
        NSMutableArray *allCategories = dataItem.allCategories;
        int rows = [allCategories count]%4 == 0 ? [allCategories count]/4 : [allCategories count]/4 + 1;
        h += CATEGORY_BUTTON_HEIGHT*rows + CATEGORY_BUTTON_ROW_MARGIN*rows;
        h += CATEGORY_BUTTON_ROW_MARGIN;
    } else if (dataItem.row == 1) {
        h += CELL2_BG_TOP_MARGIN;
        h += 1;
        int maxTagWidth = (CGRectGetWidth(tableView.frame) - CIRCLE_BG_LEFT_RIGHT_MARGIN*2 - LINE_LEFT_RIGHT_MARGIN*2 - TAG_BUTTON_MARGIN)/2.0;
        int totalWidth  = CGRectGetWidth(tableView.frame)- CIRCLE_BG_LEFT_RIGHT_MARGIN*2 - LINE_LEFT_RIGHT_MARGIN*2;
        
        CGRect lastRect = CGRectNull;
        NSMutableArray *tags = dataItem.allTags;
        for (int i = 0; i < [tags count]; i++) {
            TagItem *tag = [tags objectAtIndex:i];
            CGSize tagSize = [tag.tagName sizeWithFont:[UIFont systemFontOfSize:TAG_FONT_SIZE]];
            tagSize = CGSizeMake(5.5 + tagSize.width + 5.5, TAG_BUTTON_HEIGHT);
            if (tagSize.width > maxTagWidth) {
                tagSize = CGSizeMake(maxTagWidth, TAG_BUTTON_HEIGHT);
            }
            
            if (CGRectIsNull(lastRect)) {
                lastRect = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                      h + TAG_LINE_MARGIN, 
                                      tagSize.width, 
                                      TAG_BUTTON_HEIGHT);
            } else {
                CGFloat restLength = totalWidth - lastRect.origin.x - CGRectGetWidth(lastRect) - TAG_BUTTON_MARGIN;
                if (restLength >= tagSize.width) { //剩余长度能够容纳下当前tag
                    lastRect = CGRectMake(lastRect.origin.x + CGRectGetWidth(lastRect) + TAG_BUTTON_MARGIN, 
                                          lastRect.origin.y, 
                                          tagSize.width, 
                                          TAG_BUTTON_HEIGHT);
                } else {//剩余长度不能够容纳下当前tag，将当前tag放入下一行
                    lastRect = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                            lastRect.origin.y + CGRectGetHeight(lastRect) + TAG_BUTTON_ROW_MARGIN, 
                                            tagSize.width, 
                                            TAG_BUTTON_HEIGHT);
                }
            }
        }
        if (!CGRectIsNull(lastRect)) {
            h = (lastRect.origin.y + CGRectGetHeight(lastRect));
        }
        h += CELL_BOTTOM_MARGIN+40;
    }
    
    return h;
}

-(void)selectedButton:(NSString *)aType strId:(NSString *)aId {
    self.selectedType = aType;
    self.selectedId   = aId;
    for (id btn in self.allBtns) {
        if ([aType isEqualToString:kGroupPhotoCategory]) {
            if ([btn isKindOfClass:[SNCategoryButton class]]) {
                SNCategoryButton *cBtn = (SNCategoryButton *)btn;
                if ([aId isEqualToString:cBtn.category.categoryID]) {
                    cBtn.selected = YES;
                } else {
                    cBtn.selected = NO;
                }
            } else {
                SNTagButton *tBtn = (SNTagButton *)btn;
                tBtn.selected = NO;
            }
        } else if ([aType isEqualToString:kGroupPhotoTag]) {
            if ([btn isKindOfClass:[SNTagButton class]]) {
                SNTagButton *tBtn = (SNTagButton *)btn;
                if ([aId isEqualToString:tBtn.tagItem.tagId]) {
                    tBtn.selected = YES;
                } else {
                    tBtn.selected = NO;
                }
            } else {
                SNCategoryButton *cBtn = (SNCategoryButton *)btn;
                cBtn.selected = NO;
            }
        }
    }
}

-(void)categoryBtnClicked:(id)sender {
    SNCategoryButton *cBtn = (SNCategoryButton *)sender;
    if ([item.controller respondsToSelector:@selector(clickOnCategoryBtn:)]) {
        [item.controller clickOnCategoryBtn:cBtn.category];
    }
}

-(void)tagBtnClicked:(id)sender {
    SNTagButton *tBtn = (SNTagButton *)sender;
    if ([item.controller respondsToSelector:@selector(clickOnTagBtn:)]) {
        [item.controller clickOnTagBtn:tBtn.tagItem];
    }
}

-(NSString *)categoryBgByName:(NSString *)cName {
    if ([cName isEqualToString:@"category_yl"]) {
        return @"category_yl.png";
    } else if ([cName isEqualToString:@"category_mn"]) {
        return @"category_mn.png";
    } else if ([cName isEqualToString:@"category_js"]) {
        return @"category_js.png";
    } else if ([cName isEqualToString:@"category_sy"]) {
        return @"category_sy.png";
    } else if ([cName isEqualToString:@"category_gx"]) {
        return @"category_gx.png";
    } else if ([cName isEqualToString:@"category_ss"]) {
        return @"category_ss.png";
    } else if ([cName isEqualToString:@"category_rm"]) {
        return @"category_rm.png";
    } else {
        return @"category_xw.png";
    }
}

-(NSString *)categoryHlBgByName:(NSString *)cName {
    if ([cName isEqualToString:@"category_yl"]) {
        return @"category_yl_h.png";
    } else if ([cName isEqualToString:@"category_mn"]) {
        return @"category_mn_h.png";
    } else if ([cName isEqualToString:@"category_js"]) {
        return @"category_js_h.png";
    } else if ([cName isEqualToString:@"category_sy"]) {
        return @"category_sy_h.png";
    } else if ([cName isEqualToString:@"category_gx"]) {
        return @"category_gx_h.png";
    } else if ([cName isEqualToString:@"category_ss"]) {
        return @"category_ss_h.png";
    } else if ([cName isEqualToString:@"category_rm"]) {
        return @"category_rm_h.png";
    } else {
        return @"category_xw_h.png";
    }
}

-(void)addCategoriesToCell {
    SNCategoryButton *lastCategoryBtn   = nil;
    NSMutableArray *categories  = self.item.allCategories;
    if (categories) {
        NSString *strColor1 = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor];
        NSString *strColor2 = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagSelectedTextColor];
        UIColor *normalColor =  [UIColor colorFromString:strColor1];
        UIColor *selectedColor =  [UIColor colorFromString:strColor2];
         for (int i = 0; i < [categories count]; i++) {
             CategoryItem *category = [categories objectAtIndex:i];
             SNCategoryButton *cBtn = [SNCategoryButton buttonWithType:UIButtonTypeCustom];
             [allBtns addObject:cBtn];
             cBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
             cBtn.category = category;
             [cBtn.titleLabel setFont:[UIFont systemFontOfSize:CAGETORY_FONT_SIZE]];
             [cBtn setTitle:category.name forState:UIControlStateNormal];
             cBtn.exclusiveTouch = YES;
             [cBtn setTitleColor:normalColor forState:UIControlStateNormal];
             [cBtn setTitleColor:selectedColor forState:UIControlStateHighlighted];
             [cBtn setTitleColor:selectedColor forState:UIControlStateSelected];
             NSString *normalIconFileName = [[SNThemeManager sharedThemeManager] themeFileName:[self categoryBgByName:category.icon]];
             [cBtn setImage:[[UIImage imageNamed:normalIconFileName] scaledImage] forState:UIControlStateNormal];
             NSString *selectedIconFileName = [[SNThemeManager sharedThemeManager] themeFileName:[self categoryHlBgByName:category.icon]];
             [cBtn setImage:[[UIImage imageNamed:selectedIconFileName] scaledImage] forState:UIControlStateHighlighted];
             [cBtn setImage:[[UIImage imageNamed:selectedIconFileName] scaledImage] forState:UIControlStateSelected];
             [cBtn addTarget:self action:@selector(categoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
             [self.cellBgView addSubview:cBtn];
             
             [cBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
             [cBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -39.5, -49, 0)];
             
             if ([self.selectedType isEqualToString:kGroupPhotoCategory] && [self.selectedId isEqualToString:category.categoryID]) {
                 cBtn.selected = YES;
             }
             
             if (i%4 == 0) {
                 if (!lastCategoryBtn) {
                     cBtn.frame = CGRectMake(TITLE_LEFT_MARGIN, 
                                             lineView.frame.origin.y + lineView.frame.size.height + CATEGORY_BUTTON_ROW_MARGIN, 
                                             CATEGORY_BUTTON_WIDTH, 
                                             CATEGORY_BUTTON_HEIGHT);
                 } else {
                     cBtn.frame = CGRectMake(TITLE_LEFT_MARGIN, 
                                             lastCategoryBtn.frame.origin.y + lastCategoryBtn.frame.size.height + CATEGORY_BUTTON_ROW_MARGIN, 
                                             CATEGORY_BUTTON_WIDTH, 
                                             CATEGORY_BUTTON_HEIGHT);
                 }
             } else {
                 cBtn.frame = CGRectMake(lastCategoryBtn.frame.origin.x + lastCategoryBtn.frame.size.width +            CATEGORY_BUTTON_MARGIN, 
                                         lastCategoryBtn.frame.origin.y, 
                                         CATEGORY_BUTTON_WIDTH, 
                                         CATEGORY_BUTTON_HEIGHT);
             }
             //iconImageView.frame = CGRectMake(0, 0, CATEGORY_ICON_WIDTH, CGRectGetHeight(cBtn.frame));
             //cBtn.titleEdgeInsets = UIEdgeInsetsMake(0,CATEGORY_ICON_WIDTH,0,0);
             lastCategoryBtn = cBtn;
         }
    }
    
    CGFloat h = TITLE_TOP_MARGIN;
    h += TITLE_LABEL_HEIGHT;
    h += TITLE_LINE_MARGIN; 
    if (lastCategoryBtn) {
        h = (lastCategoryBtn.frame.origin.y + CGRectGetHeight(lastCategoryBtn.frame));
    }
    h += CATEGORY_BUTTON_ROW_MARGIN;
    self.cellBgView.frame = CGRectMake(CIRCLE_BG_LEFT_RIGHT_MARGIN, 
                                       CELL1_BG_TOP_MARGIN, 
                                       CELL_WIDTH-CIRCLE_BG_LEFT_RIGHT_MARGIN*2, 
                                       h);
}

-(void)addTagsToCell {
    SNTagButton *lastTagBtn   = nil;
    NSMutableArray *tags      = self.item.allTags;
    //tag最大长度
    int maxTagWidth = (CELL_WIDTH - CIRCLE_BG_LEFT_RIGHT_MARGIN*2 - LINE_LEFT_RIGHT_MARGIN*2 - TAG_BUTTON_MARGIN)/2.0;
    int totalWidth  = CELL_WIDTH - CIRCLE_BG_LEFT_RIGHT_MARGIN*2 - LINE_LEFT_RIGHT_MARGIN*2;
    if (tags) {
        NSString *tagBgFileName = [[SNThemeManager sharedThemeManager] themeFileName:@"tag_bg.png"];
        UIImage *bgImage = [UIImage imageNamed:tagBgFileName];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            bgImage = [[bgImage scaledImage] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else {
            bgImage = [[bgImage scaledImage] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        
        NSString *strColor1 = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor];
        NSString *strColor2 = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagSelectedTextColor];
        UIColor *normalColor =  [UIColor colorFromString:strColor1];
        UIColor *selectedColor =  [UIColor colorFromString:strColor2];
        for (int i = 0; i < [tags count]; i++) {
            TagItem *tag = [tags objectAtIndex:i];
            SNTagButton *tBtn = [SNTagButton buttonWithType:UIButtonTypeCustom];
            [allBtns addObject:tBtn];
            tBtn.tagItem = tag;
            tBtn.exclusiveTouch = YES;
            [tBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
            [tBtn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
            //[tBtn set]
            [tBtn.titleLabel setFont:[UIFont systemFontOfSize:TAG_FONT_SIZE]];
            [tBtn setTitle:tag.tagName forState:UIControlStateNormal];
            [tBtn.titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
            [tBtn setTitleColor:normalColor forState:UIControlStateNormal];
            [tBtn setTitleColor:selectedColor forState:UIControlStateHighlighted];
            [tBtn setTitleColor:selectedColor forState:UIControlStateSelected];
            tBtn.titleEdgeInsets = UIEdgeInsetsMake(5.5,10,5.5,10);
            [self.cellBgView addSubview:tBtn];  
            [tBtn addTarget:self action:@selector(tagBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([self.selectedType isEqualToString:kGroupPhotoTag] && [self.selectedId isEqualToString:tag.tagId]) {
                tBtn.selected = YES;
            }
            
            CGSize tagSize = [tag.tagName sizeWithFont:[UIFont systemFontOfSize:TAG_FONT_SIZE]];
            tagSize = CGSizeMake(tBtn.titleEdgeInsets.left + tagSize.width + tBtn.titleEdgeInsets.right, TAG_BUTTON_HEIGHT);
            if (tagSize.width > maxTagWidth) {
                tagSize = CGSizeMake(maxTagWidth, TAG_BUTTON_HEIGHT);
            }
            if (!lastTagBtn) {
                tBtn.frame = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                        lineView.frame.origin.y + lineView.frame.size.height + TAG_LINE_MARGIN, 
                                        tagSize.width, 
                                        TAG_BUTTON_HEIGHT);
            } else {
                CGFloat restLength = totalWidth - lastTagBtn.origin.x - CGRectGetWidth(lastTagBtn.frame) - TAG_BUTTON_MARGIN;
                if (restLength >= tagSize.width) { //剩余长度能够容纳下当前tag
                    tBtn.frame = CGRectMake(lastTagBtn.origin.x + CGRectGetWidth(lastTagBtn.frame) + TAG_BUTTON_MARGIN, 
                                            lastTagBtn.origin.y, 
                                            tagSize.width, 
                                            TAG_BUTTON_HEIGHT);
                } else {//剩余长度不能够容纳下当前tag，将当前tag放入下一行
                    tBtn.frame = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                            lastTagBtn.origin.y + CGRectGetHeight(lastTagBtn.frame) + TAG_BUTTON_ROW_MARGIN, 
                                            tagSize.width, 
                                            TAG_BUTTON_HEIGHT);
                }
            }
            lastTagBtn = tBtn;
        }
    }
    CGFloat h = TITLE_TOP_MARGIN;
    h += TITLE_LABEL_HEIGHT;
    h += TITLE_LINE_MARGIN; 
    if (lastTagBtn) {
        h = (lastTagBtn.frame.origin.y + CGRectGetHeight(lastTagBtn.frame));
    }
    h += CELL_BOTTOM_MARGIN;

    self.cellBgView.frame = CGRectMake(CIRCLE_BG_LEFT_RIGHT_MARGIN, 
                                       CELL2_BG_TOP_MARGIN, 
                                       CELL_WIDTH-CIRCLE_BG_LEFT_RIGHT_MARGIN*2, 
                                       h);
}

- (void)setObject:(id)object {
     if (object != self.item) {
        self.selectionStyle     = UITableViewCellSelectionStyleNone;
        self.item               = object;
        
        if (!self.allBtns) {
            self.allBtns = [NSMutableArray array];
        }
        
        [self.contentView removeAllSubviews];
        
        NSString *bgFileName = [[SNThemeManager sharedThemeManager] themeFileName:@"category_bg.png"];
        //NSString *bgFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bgFileName];
        //UIImage * bgImage = [UIImage imageWithContentsOfFile:bgFilePath];
        UIImage * bgImage = [UIImage imageNamed:bgFileName];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            bgImage = [[bgImage scaledImage] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else {
            bgImage = [[bgImage scaledImage] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        
        UIImageView *newCellBgView = [[UIImageView alloc] init];
        newCellBgView.userInteractionEnabled = YES;
        newCellBgView.image = bgImage;
        [self.contentView addSubview:newCellBgView];
        [newCellBgView release];
        self.cellBgView = newCellBgView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:TITLE_LABEL_HEIGHT-2]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhtotCellTitleColor];
        titleLabel.textColor = [UIColor colorFromString:strColor];
         
        [self.cellBgView addSubview:titleLabel];
        [titleLabel release];
        
        if (lineView) {
            TT_RELEASE_SAFELY(lineView);
        }
        lineView = [[UIImageView alloc] init];
        NSString *lineFileName = [[SNThemeManager sharedThemeManager] themeFileName:@"sep_line.png"];
        //NSString *lineFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:lineFileName];
        //lineView.image = [UIImage imageWithContentsOfFile:lineFilePath];
         lineView.image = [UIImage imageNamed:lineFileName];
        [self.cellBgView addSubview:lineView];
        
        if ([self.item.indexPath row] == 0) {
            titleLabel.frame = CGRectMake(TITLE_LEFT_MARGIN, TITLE_TOP_MARGIN, TITLE_LABEL_WIDTH, TITLE_LABEL_HEIGHT);
            lineView.frame = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                        titleLabel.frame.origin.y + titleLabel.frame.size.height + TITLE_LINE_MARGIN, 
                                        CELL_WIDTH- CIRCLE_BG_LEFT_RIGHT_MARGIN*2- LINE_LEFT_RIGHT_MARGIN*2, 1);
            titleLabel.text = NSLocalizedString(@"photoCategoryName", nil);
            [self addCategoriesToCell];
        } else if ([self.item.indexPath row] == 1) {
            titleLabel.frame = CGRectMake(TITLE_LEFT_MARGIN, TITLE_TOP_MARGIN, TITLE_LABEL_WIDTH, TITLE_LABEL_HEIGHT);
            lineView.frame = CGRectMake(LINE_LEFT_RIGHT_MARGIN, 
                                        titleLabel.frame.origin.y + titleLabel.frame.size.height + TITLE_LINE_MARGIN, 
                                        CELL_WIDTH-CIRCLE_BG_LEFT_RIGHT_MARGIN*2-LINE_LEFT_RIGHT_MARGIN*2, 1);
            titleLabel.text = NSLocalizedString(@"photoHotTagName", nil);
            [self addTagsToCell];
        }
        
    }
}

-(void)dealloc {
    if (lineView) {
        TT_RELEASE_SAFELY(lineView);
    }
    TT_RELEASE_SAFELY(item);
    TT_RELEASE_SAFELY(cellBgView);
    TT_RELEASE_SAFELY(allBtns);
    TT_RELEASE_SAFELY(selectedType);
    TT_RELEASE_SAFELY(selectedId);
    [super dealloc];
}

@end
