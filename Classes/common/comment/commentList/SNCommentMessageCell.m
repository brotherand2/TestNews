//
//  SNCommentMessageCell.m
//  sohunews
//
//  Created by 贾 磊 on 14-2-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentMessageCell.h"
#import "SNFloorCommentItem.h"
#import "SNFloorView.h"

@implementation SNCommentMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (float)rowHeightForObject:(SNFloorCommentItem *)item
{
    SNNewsComment *comment = item.comment;
    if (comment.content.length <= 0) {
        return 0;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGSize maximumSize = CGSizeMake(CGRectGetWidth(screenRect) - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 3 - CELL_CONTENT_LEFT_MARGIN, CGFLOAT_MAX_CORE_TEXT);
    CGFloat h = CELL_TOP_MARGIN + CELL_USER_ICON_HEIGHT;
    UIFont* font = [UIFont systemFontOfSize:kFLOOR_COMMENT_CONTENT_FONT];
    
    if (comment.floors.count > 0) {
        h += CELL_BOTTOM_MARGIN;
        for (int i = 0; i < comment.floors.count; i++) {
            SNNewsComment *floorComment = [comment.floors objectAtIndex:i];
            NSString *content = [floorComment.content trim];
            
            if ([content length] > 0) {
                CGSize changeSize = [SNLabel sizeForContent:content maxSize:maximumSize font:font.pointSize lineHeight:CEll_CONTENT_LINE_HEIGHT];
                int lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT: changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
                if(lines > KCOMMENT_THUMBNAIL_LINENUM && !floorComment.isCommentOpen){
                    int contentHeight = [SNLabel heightForContent:content maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
                    h += contentHeight +FLOOR_TOP_MARGIN+ kFLOOR_COMMENT_CONTENT_TOP_MARGIN + OPEN_COMMENT_BTN_HEIGHT;
                    item.isMoreDesignLine = YES;
                } else {
                    h += changeSize.height + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
                    item.isMoreDesignLine = NO;
                }
            }
            
            if([floorComment hasImage]) {
                h += kPicViewHeight + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
            }
            
            if ([floorComment hasAudio]) {
                h += SOUNDVIEW_HEIGHT +SOUNDVIEW_SPACE;
            }
            
            h += kFLOOR_COMMENT_USER_INFO_HEIGHT;
            h += (kFLOOR_COMMENT_CONTENT_TOP_MARGIN) * 2;
        }
        h += MarginTopBetweenUserLabelAndTimeDingLabel + 1;
    } else {
        h += MarginTopBetweenUserLabelAndTimeDingLabel;
    }
    
    NSString *content = [comment.content trim];
    CGSize originalSize = CGSizeMake(CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN, CGFLOAT_MAX_CORE_TEXT);
    
    CGSize changeSize = [SNLabel sizeForContent:content maxSize:originalSize font:font.pointSize lineHeight:CEll_CONTENT_LINE_HEIGHT];
    int lines = 0;
    if(font.lineHeight != 0 && changeSize.height != 0) {
        lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT : changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
    }
    if(lines > KCOMMENT_THUMBNAIL_LINENUM && !comment.isCommentOpen){
        int contentHeight = [SNLabel heightForContent:content maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
        item.cellContentHeight = contentHeight;
        item.isMoreDesignLine = YES;
        h += contentHeight +FLOOR_TOP_MARGIN+ OPEN_COMMENT_BTN_HEIGHT + FLOOR_TOP_MARGIN;
    } else if(lines > 0){
        h += changeSize.height + FLOOR_TOP_MARGIN;
        item.cellContentHeight = changeSize.height;
        item.isMoreDesignLine = NO;
    }
    
    if(comment.commentImageSmall && [comment.commentImageSmall length] > 0) {
        h += kPicViewHeight + CELL_BOTTOM_MARGIN;
    }
    
    if(comment.newsTitle && [comment.newsTitle length] > 0) {
        h += KFLOOR_COMMENT_NEWSTITLE_HEIGHT + CELL_BOTTOM_MARGIN;
    }
    
    if ([comment hasAudio]) {
        h += SOUNDVIEW_HEIGHT + SOUNDVIEW_SPACE;
    }
    
    h += FLOOR_TOP_MARGIN;
    
	return h;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
    }
    return self;
}


- (void)setObject:(SNFloorCommentItem *)commentItem
{
    [super setObject:commentItem];
    [self addNewsTitle];
}

- (void)initApproveView
{
}

- (void)setApproveView
{
}

- (void)setFloorView
{
    if (_floorContainerView)
    {
        [_floorContainerView removeAllSubviews];
    }
    
    CGFloat h = 0;
    for (int i = 0; i < self.item.comment.floors.count; i++)
    {
        SNNewsComment *c = [self.item.comment.floors objectAtIndex:i];
        c.floorNum = i+1;
        SNFloorView *floor = [[SNFloorView alloc] init];
        floor.subFloorIndex = i;
        floor.commentId = self.item.comment.commentId;
        floor.comment = c;
        floor.newsId    = self.item.newsId;
        floor.gid       = self.item.gid;
        floor.cell = self;
        floor.colseShare = YES;
        if (i == (self.item.comment.floors.count - 1))
        {
            floor.showSeparator = NO;
        } else
        {
            floor.showSeparator = YES;
        }
        floor.origin = CGPointMake(0, h);
        h += floor.size.height;
        [_floorContainerView addSubview:floor];
        [floor setNeedsDisplay];
    }
    
    if (h > 0) {
        _floorContainerView.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN,
                                               _originY + CELL_BOTTOM_MARGIN,
                                               [UIScreen mainScreen].bounds.size.width - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN,
                                               h);
        _originY = _floorContainerView.bottom + 2;
        _floorContainerView.hidden = NO;
    }
    else {
        _floorContainerView.hidden = YES;
    }
}

//原文标题链接
- (void)addNewsTitle
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    UIFont *font = [UIFont systemFontOfSize:15];
    //newsTitle
    UIImageView *newsTitleButton = (UIImageView*)[self.contentView viewWithTag:commentViewType_newsTitleButton];
    UILabel *titleLabel = (UILabel*)[self.contentView viewWithTag:commentViewType_newsTitleLabel];
    if(!newsTitleButton) {
        newsTitleButton = [[UIImageView alloc] init];
        newsTitleButton.tag = commentViewType_newsTitleButton;
        newsTitleButton.exclusiveTouch = YES;
        UIImage* imageBg = [UIImage themeImageNamed:@"mycomment_newstitle_bg.png"];
        [newsTitleButton setImage:imageBg];
        [newsTitleButton setHighlightedImage:[UIImage themeImageNamed:@"singleCell.png"]];
        [self.contentView addSubview:newsTitleButton];
        
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
        [newsTitleButton addGestureRecognizer:tapGes];
        tapGes.delegate = self;
        
        UIImage *imgArrow = [UIImage themeImageNamed:@"arrow.png"];
        UIImageView *ndicatorView = [[UIImageView alloc] initWithImage:imgArrow];
        ndicatorView.frame = CGRectMake(CGRectGetWidth(screenRect) - CELL_CONTENT_LEFT_MARGIN - CELL_RIGHT_MARGIN - NEWSTITLE_LEFT_MARGIN - imgArrow.size.width,
                                        (KFLOOR_COMMENT_NEWSTITLE_HEIGHT - imgArrow.size.height) / 2,
                                        imgArrow.size.width, imgArrow.size.height);
        [newsTitleButton addSubview:ndicatorView];
        
        titleLabel = [[UILabel alloc]init];
        titleLabel.tag = commentViewType_newsTitleLabel;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentNewsTitleColor]]];
        [titleLabel setFont:font];
        [newsTitleButton addSubview:titleLabel];
    }
    
    if(self.item.comment.newsTitle && [self.item.comment.newsTitle length] > 0) {
        NSString* newsTitleStr = [NSString stringWithFormat:@"原文: %@" ,self.item.comment.newsTitle];
        
        newsTitleButton.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN,
                                           _originY + CELL_BOTTOM_MARGIN,
                                           CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN,
                                           KFLOOR_COMMENT_NEWSTITLE_HEIGHT);
        
        CGSize titleSize = [newsTitleStr sizeWithFont:font];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [titleLabel setText:newsTitleStr];
        titleLabel.frame = CGRectMake(NEWSTITLE_LEFT_MARGIN,
                                      (newsTitleButton.height - titleSize.height) / 2,
                                      newsTitleButton.width - NEWSTITLE_LEFT_MARGIN * 4,
                                      titleSize.height + 2);
        
        newsTitleButton.hidden = NO;
    }
    else {
        newsTitleButton.hidden = YES;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == NSSelectorFromString(@"replyComment") /*&& canReply*/) {
        return YES;
    }
    if (action == NSSelectorFromString(@"copyComment")) {
		return YES;
	}

	return NO;
}

-(void)openMenu:(UITapGestureRecognizer *)tapGesture {
    UIImageView *newsTitleButton = (UIImageView*)[self.contentView viewWithTag:commentViewType_newsTitleButton];
    CGPoint tapPoint = [tapGesture locationInView:self];
    BOOL isTapInTitleButton = CGRectContainsPoint(newsTitleButton.frame, tapPoint);
    if (isTapInTitleButton && self.item.comment.newsLink.length > 0) {
        [[SNSoundManager sharedInstance] stopAll];
        [SNUtility openProtocolUrl:self.item.comment.newsLink];
        return;
    }
    
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible]) {
        [contextMenu setMenuVisible:NO];
    } else {
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [contextMenu setMenuVisible:NO];
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        
        UIMenuItem *replyMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyComment)];
        [menuItemsArray addObject:replyMenuItem];
        
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyComment)];
        [menuItemsArray addObject:copyMenuItem];
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        CGPoint point = [tapGesture locationInView:self];
        float meunPointX = CELL_CONTENT_LEFT_MARGIN / 2;
        [contextMenu setTargetRect:CGRectMake(meunPointX, point.y, self.frame.size.width, self.frame.size.height) inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}
- (void)replyComment {
    
}
- (void)copyComment {

}
- (void)updateTheme
{
    UIImageView *newsTitleButton = (UIImageView*)[self.contentView viewWithTag:commentViewType_newsTitleButton];
    UIImage* imageBg = [UIImage themeImageNamed:@"mycomment_newstitle_bg.png"];
    [newsTitleButton setImage:imageBg];
    [newsTitleButton setHighlightedImage:[UIImage themeImageNamed:@"singleCell.png"]];
    
    UILabel *titleLabel = (UILabel*)[self.contentView viewWithTag:commentViewType_newsTitleLabel];
    [titleLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentNewsTitleColor]]];
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
    [super updateTheme];
}

- (void)floorViewShowImageWithUrl:(NSString *)url
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showImageWithUrl:)]) {
        [self.delegate showImageWithUrl:url];
    }
}

@end
