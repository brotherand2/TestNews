//
//  SNFloorCommentItem.m
//  sohunews
//
//  Created by qi pei on 6/18/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNFloorCommentItem.h"
#import "SNNewsComment.h"
#import "SNLabel.h"

@implementation SNFloorCommentItem

@synthesize comment, index, expand, newsId, gid ,hasDing;
@synthesize cellHeight = _cellHeight;
@synthesize cellContentHeight = _cellContentHeight;
@synthesize cellOffsetY =_cellOffsetY;
@synthesize isMoreDesignLine;
@synthesize isUsed;

+(BOOL)IsEqualObject:(SNFloorCommentItem*)aObj1 obj2:(SNFloorCommentItem*)aObj2
{
    SNNewsComment *comment1 = aObj1.comment;
    SNNewsComment *comment2 = aObj2.comment;
    
    return [SNNewsComment IsEqualObject:comment1 obj2:comment2];
}

- (void)setCellHeight:(float)height {
    if (height == 0) {
        _cellHeight = [self heightForCommentItem];
    } else {
        _cellHeight = height;
    }
}

- (float)heightForCommentItem
{
    if (!self.comment) {
        return 0;
    }
        
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGSize maximumSize = CGSizeMake(CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN * 2 -
                                    kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10, CGFLOAT_MAX_CORE_TEXT);
    CGFloat h = CELL_TOP_MARGIN + CELL_USER_ICON_HEIGHT;
    UIFont* font = [UIFont systemFontOfSize:kFLOOR_COMMENT_CONTENT_FONT];
    
    
    //楼层高度
    if (self.comment.floors.count > 0) {
        h += CELL_BOTTOM_MARGIN;
        if (!self.expand
            && self.comment.commentId
            && self.comment.floors.count > kExpandLimit) {
            
            h += kFLOOR_COMMENT_TOP_MARGIN * 3;
            h += kFLOOR_COMMENT_USER_INFO_HEIGHT * 3;
            h += kFLOOR_COMMENT_CONTENT_TOP_MARGIN * 3;
            h += kFLOOR_COMMENT_CONTENT_TOP_MARGIN * 3;
            h += EXPAND_BTN_HEIGHT;
            
            SNNewsComment *c = [self.comment.floors objectAtIndex:0];
            NSString *content = [c.content trim];
            if ([content length] > 0) {
                CGSize changeSize = [SNLabel sizeForContent:content maxSize:maximumSize font:font.pointSize lineHeight:CEll_CONTENT_LINE_HEIGHT];
                int lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT: changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
                if(lines > KCOMMENT_THUMBNAIL_LINENUM && !c.isCommentOpen) {
                    int contentHeight = [SNLabel heightForContent:content maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
                    h += contentHeight+ kFLOOR_COMMENT_CONTENT_TOP_MARGIN + OPEN_COMMENT_BTN_HEIGHT;
                } else {
                    h += changeSize.height;
                }
            }
            
            if ([c hasAudio]) {
                h += SOUNDVIEW_HEIGHT+SOUNDVIEW_SPACE;
            }
            
            if([c hasImage]) {
                h += kPicViewHeight + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;;
            }
            
            SNNewsComment *c1 = [self.comment.floors objectAtIndex:comment.floors.count-2];
            NSString *content1 = [c1.content trim];
            if ([content1 length] > 0) {
                CGSize changeSize = [SNLabel sizeForContent:content1
                                                    maxSize:maximumSize
                                                       font:font.pointSize
                                                 lineHeight:CEll_CONTENT_LINE_HEIGHT];
                
                int lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT : changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
                if(lines > KCOMMENT_THUMBNAIL_LINENUM && !c1.isCommentOpen) {
                    int contentHeight = [SNLabel heightForContent:content1
                                                         maxWidth:changeSize.width
                                                             font:kFLOOR_COMMENT_CONTENT_FONT
                                                       lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
                    
                    h += contentHeight+ kFLOOR_COMMENT_CONTENT_TOP_MARGIN + OPEN_COMMENT_BTN_HEIGHT;
                } else {
                    h += changeSize.height;
                }
            }
            if([c1 hasImage]) {
                h += kPicViewHeight + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;;
            }
            
            if ([c1 hasAudio]) {
                h += SOUNDVIEW_HEIGHT + SOUNDVIEW_SPACE;
            }
            
            SNNewsComment *c2 = [self.comment.floors objectAtIndex:comment.floors.count-1];
            NSString *content2 = [c2.content trim];
            if ([content2 length] > 0) {
                CGSize changeSize = [SNLabel sizeForContent:content2 maxSize:maximumSize font:font.pointSize lineHeight:CEll_CONTENT_LINE_HEIGHT];
                int lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT : changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
                if(lines > KCOMMENT_THUMBNAIL_LINENUM && !c2.isCommentOpen){
                    int contentHeight = [SNLabel heightForContent:content2 maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
                    h += contentHeight+ kFLOOR_COMMENT_CONTENT_TOP_MARGIN + OPEN_COMMENT_BTN_HEIGHT;
                } else {
                    h += changeSize.height + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
                }
            }
            if([c2 hasImage]) {
                h += kPicViewHeight + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
            }
            
            if ([c2 hasAudio]) {
                h += SOUNDVIEW_HEIGHT + SOUNDVIEW_SPACE;
            }
            
        } else {
            for (int i = 0; i < self.comment.floors.count; i++) {
                SNNewsComment *c = [self.comment.floors objectAtIndex:i];
                NSString *content = [c.content trim];
                
                if ([content length] > 0) {
                    CGSize changeSize = [SNLabel sizeForContent:content maxSize:maximumSize font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT];
                    int lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT: changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
                    if(lines > KCOMMENT_THUMBNAIL_LINENUM && !c.isCommentOpen){
                        int contentHeight = [SNLabel heightForContent:content maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
                        h += contentHeight +FLOOR_TOP_MARGIN+ kFLOOR_COMMENT_CONTENT_TOP_MARGIN + OPEN_COMMENT_BTN_HEIGHT;
                    } else {
                        h += changeSize.height + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
                    }
                }
                
                if([c hasImage]) {
                    h += kPicViewHeight + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
                }
                
                if ([c hasAudio]) {
                    h += SOUNDVIEW_HEIGHT +SOUNDVIEW_SPACE;
                }
                
                h += kFLOOR_COMMENT_USER_INFO_HEIGHT;
                h += (kFLOOR_COMMENT_CONTENT_TOP_MARGIN) * 2;
            }
        }
        h += MarginTopBetweenUserLabelAndTimeDingLabel + 1;
    } else {
        h += MarginTopBetweenUserLabelAndTimeDingLabel;
    }
    
    NSString *content = [self.comment.content trim];
//    NSString *emoticonContent = [content replaceSubStringWithSpace:commentEmoticonPattern];
    
    CGSize originalSize = CGSizeMake(CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 5, CGFLOAT_MAX_CORE_TEXT);
    
    CGSize changeSize = [SNLabel sizeForContent:content maxSize:originalSize font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT];
    int lines = 0;
    if(font.lineHeight != 0 && changeSize.height != 0) {
        lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height / CEll_CONTENT_LINE_HEIGHT : changeSize.height/CEll_CONTENT_LINE_HEIGHT + 1;
    }
    if(lines > KCOMMENT_THUMBNAIL_LINENUM && !self.comment.isCommentOpen){
        int contentHeight = [SNLabel heightForContent:content maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
        h += contentHeight +FLOOR_TOP_MARGIN+ OPEN_COMMENT_BTN_HEIGHT + FLOOR_TOP_MARGIN;
        self.cellContentHeight= contentHeight;
        self.isMoreDesignLine = YES;
    } else if(lines > 0){
        h += changeSize.height + FLOOR_TOP_MARGIN;
        self.cellContentHeight = changeSize.height;
        self.isMoreDesignLine = NO;
    }
    
    if(self.comment.commentImageSmall && [self.comment.commentImageSmall length] > 0) {
        h += kPicViewHeight + CELL_BOTTOM_MARGIN;
    }
    
    if ([self.comment hasAudio]) {
        h += SOUNDVIEW_HEIGHT + SOUNDVIEW_SPACE;
    }
    
    h += FLOOR_TOP_MARGIN;
    
	return h;
}

-(id)initWithComment:(SNNewsComment *)newsComment {
    if (self = [super init]) {
        self.comment = newsComment;
        self.cellHeight = 0;
        self.isUsed = NO;
    }
    return self;
}

-(void)dealloc {
     //(indexPath);
     //(comment);
     //(newsId);
     //(gid);
     //(_sectionTitle);
}

@end
