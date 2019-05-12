//
//  SNTrendCommentsView.m
//  sohunews
//
//  Created by jialei on 13-11-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendCommentsView.h"
#import "SNTimelineTrendObjects.h"
#import "SNTimelineConfigs.h"
#import "SNUserUtility.h"
#import "SNTimelinePostService.h"
#import "SNBaseEditorViewController.h"
#import <CoreText/CoreText.h>

#define kDftImageKeyFemale  @"female_default_icon.png"
#define kDftImageKeyMale    @"login_user_defaultIcon.png"

#define ImageLeftPadding            6.0
#define ImageTopPadding             3.0

@interface SNTrendCommentsView()
{
    UIImageView *_bgImageView;
    UIImage *_bgImage;
    UIImage *_dfFemaleHeadIcon;
    UIImage *_dfMaleHeadIcon;
}
@property (nonatomic, strong)UIImage *bgImage;

@end


@implementation SNTrendCommentsView
@synthesize referFrom;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [UIImage themeImageNamed:@"timeline_origin_bg_with_angle@2x.png"];
        _dfFemaleHeadIcon = [UIImage themeImageNamed:kDftImageKeyFemale];
        _dfMaleHeadIcon = [UIImage themeImageNamed:kDftImageKeyMale];
    }
    return self;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImage = [UIImage themeImageNamed:@"timeline_origin_bg_with_angle@2x.png"];
        _dfFemaleHeadIcon = [UIImage themeImageNamed:kDftImageKeyFemale];
        _dfMaleHeadIcon = [UIImage themeImageNamed:kDftImageKeyMale];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentsViewEvent:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    self.commentsRect = rect;
    
    //背景图
    if ([self.bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        self.bgImage = [self.bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 10, 10)];
    }
    else {
        self.bgImage = [self.bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    [_bgImage drawInRect:self.bounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    int index = 0;
    for (SNTimelineCommentsObject *cmtObj in self.commentsData) {
        //评论内容
        CGRect rect = CGRectMake(cmtObj.textLabelFrame.origin.x,
                                 self.timelineObj.commentsHeight - cmtObj.textLabelFrame.origin.y -
                                 cmtObj.contentHeight - kTLShareInfoCommentsTopMrigin,
                                 cmtObj.textLabelFrame.size.width,
                                 cmtObj.textLabelFrame.size.height);
        cmtObj.drawRect = rect;
        cmtObj.attContent = [cmtObj setCommentAttributedStr];
        CGContextSaveGState(context);
        CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
        CGContextConcatCTM(context, flip);
        [UIView drawTextWithString:cmtObj.attContent 
                          textRect:rect
                           context:context];
        
        //评论表情
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)cmtObj.attContent);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, &CGAffineTransformIdentity, rect);
        
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, cmtObj.attContent.length), path, nil);
        CFArrayRef lineArray = CTFrameGetLines(frameRef);

        
        if (lineArray && CFArrayGetCount(lineArray) > 0) {
            CGPoint origins[CFArrayGetCount(lineArray)];
            CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
            for (CFIndex i = 0 ; i<CFArrayGetCount(lineArray); i++) {
                CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
                CFArrayRef runArray = CTLineGetGlyphRuns(line);
                for (CFIndex j = 0; j < CFArrayGetCount(runArray); j++) {
                    CTRunRef run = CFArrayGetValueAtIndex(runArray, j);
                    CFRange cfRange = CTRunGetStringRange(run);
                    NSRange range = NSMakeRange(cfRange.location, cfRange.length);
                    
                    NSRange tmpRange;
                    CTFontRef fontRef = (__bridge CTFontRef)[cmtObj.attContent attribute:(NSString *)kCTFontAttributeName atIndex:range.location effectiveRange:&tmpRange];
                    CGFloat fontSize = CTFontGetSize(fontRef);
                    
                    CGFloat offsetX;
                    CTLineGetOffsetForStringIndex(line, range.location, &offsetX);
                    //CGContextDrawImage 绘制不需要翻转坐标，在翻转的坐标系中使用相对坐标的位置，再减去偏移量
                    CGFloat offsetY = self.timelineObj.commentsHeight - cmtObj.textLabelFrame.origin.y -
                                    cmtObj.contentHeight - kTLShareInfoCommentsTopMrigin + origins[i].y - 4;
                    
                    CGPoint emoticonPoint = CGPointMake(offsetX + ImageLeftPadding, offsetY);
                    CFDictionaryRef attributes = CTRunGetAttributes(run);
                    NSNumber *num = (NSNumber *)CFDictionaryGetValue(attributes, @"emoticonType");
                    SNEmoticonType emoticonType = [num intValue];
                    UIImage *emoticonImage = (UIImage *)CFDictionaryGetValue(attributes, @"emoticonImage");
                    if (emoticonImage) {
                        CGRect imageRect = CGRectZero;
                        imageRect.origin = emoticonPoint;
                        if (emoticonType == SNEmoticonStatic) {
                            imageRect.size = CGSizeMake(fontSize + 4, fontSize + 4);
                        }
                        
                        CGContextDrawImage(context, imageRect, emoticonImage.CGImage);
                    }
                }
            }
        }
        
        CGContextRestoreGState(context);
        
        // v5.2.0
        TT_RELEASE_CF_SAFELY(path);
        TT_RELEASE_CF_SAFELY(framesetter);
        
        TT_RELEASE_CF_SAFELY(frameRef);
        //分割线
        [UIView drawCellSeperateLine:cmtObj.commentFrame margin:0];
        index++;
        if (index >= kTimelineMaxCommentDisplayNum) {
            break;
        }
    }
    
    //展开显示更多评论
    for (SNTimelineCommentsObject *cmtObj in self.commentsData) {
        if (cmtObj.isFolder && cmtObj.needFolder) {
            CGContextSetFillColorWithColor(context, SNUICOLORREF(kAuthorNameColor));
            NSString *moreBtnStr = @"显示更多";
            [moreBtnStr textDrawInRect:cmtObj.moreCmtBtnFrame
                               withFont:[UIFont systemFontOfSize:kTLShareInfoViewNameFontSize]
                          lineBreakMode:NSLineBreakByTruncatingTail
                              alignment:NSTextAlignmentLeft
                              textColor:SNUICOLOR(kAuthorNameColor)];

        }
    }
    
    //查看全部
    if (self.timelineObj.showAllComment) {
        NSString *moreBtnStr = [NSString stringWithFormat:@"查看全部%d条评论", self.timelineObj.commentNum];
        CGContextSetFillColorWithColor(context, SNUICOLORREF(kFloorViewCommentContentColor));
        [moreBtnStr textDrawInRect:self.moreBtnFrame
                          withFont:[UIFont systemFontOfSize:kTLCommentsViewTextFontSize]
                     lineBreakMode: NSLineBreakByWordWrapping
                         alignment:NSTextAlignmentCenter
                         textColor:SNUICOLOR(kFloorViewCommentContentColor)];
    }
}

- (void)dealloc
{
     //(_bgImage);
     //(_commentsData);
}

#pragma mark - commentViewAction
- (void)commentsViewEvent:(UIGestureRecognizer *)tapGesture
{
    // hide menu  by jojo
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    
    CGPoint tapPoint = [tapGesture locationInView:self];
    
    //点击查看全部评论进阅读圈最终页
    if (CGRectContainsPoint(self.moreBtnFrame, tapPoint)) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (self.timelineObj.actId.length > 0) {
            [dic setObject:self.timelineObj.actId forKey:kCircleDetailKeyActId];
        }
        if (self.timelineObj.pid.length > 0) {
            [dic setObject:self.timelineObj.pid forKey:kCircleDetailKeyPid];
        }
        [dic setObject:@(self.indexPath) forKey:kCircleDetailKeyIndex];
        [dic setObject:@(self.timelineObj.topNum) forKey:kCircleDetailKeyAvlNum];
        TTURLAction *urlAction = nil;
        urlAction = [[[TTURLAction actionWithURLPath:@"tt://readCircleDetail"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
        
        // cc统计
        if (self.referFrom == REFER_MORE) {
            SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
            SNUserTrack *toPage = [SNUserTrack trackWithPage:circle_comment link2:nil];
            NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_get_more];
            [SNNewsReport reportADotGifWithTrack:paramString];
        }
        
        return;
    }
    
    //文本区域事件
    int index = 0;
    for (SNTimelineCommentsObject *cmtObj in self.commentsData) {
        //点击头像和用户名进入该用户中心
        BOOL isTapInUserIcon = CGRectContainsPoint(cmtObj.userIconFrame, tapPoint);
        BOOL isTapInContentFrame = CGRectContainsPoint(cmtObj.textLabelFrame, tapPoint);
        //计算当前点击位置相对于当前评论位置
        CGPoint point = CGPointMake(tapPoint.x, tapPoint.y - cmtObj.textLabelFrame.origin.y);
        NSRange targetRange = [cmtObj getTouchRangeWithPoint:point
                                                       frame:cmtObj.commentFrame
                                                      topGap:0];
        BOOL isTapInUserNameLabel = NO;
        if (targetRange.length > 0) {
            isTapInUserNameLabel = NSEqualRanges(targetRange, cmtObj.userNameRange);
        }
        BOOL isTapInFuserNameLabel = NO;
        if (targetRange.length > 0  && targetRange.location > 0) {
            isTapInFuserNameLabel = NSEqualRanges(targetRange ,cmtObj.fUserNameRange);
        }

        BOOL isTapInMoreCmtBtn = CGRectContainsPoint(cmtObj.moreCmtBtnFrame, tapPoint);
        
        //查看更多
        if (isTapInMoreCmtBtn) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(snTrendCmtBtnOpenMore:)]) {
                [self.delegate snTrendCmtBtnOpenMore:cmtObj.commentId];
            }
            break;
        }
        //查看发评论人用户中心
        if (isTapInUserIcon || isTapInUserNameLabel) {
            [SNUserUtility openUserWithPassport:nil
                                     spaceLink:nil
                                     linkStyle:nil
                                           pid:cmtObj.pid
                                           push:@"0" refer: nil];
            break;

        }
        //查看被回复用户
        if (isTapInFuserNameLabel) {
            [SNUserUtility openUserWithPassport:nil
                                     spaceLink:nil
                                     linkStyle:nil
                                           pid:cmtObj.fPid
                                           push:@"0" refer:nil];
            break;
        }
        
        //回复
        if (isTapInContentFrame) {
            
            // cc统计
            if (self.referFrom == REFER_MORE) {
                SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
                SNUserTrack *toPage = [SNUserTrack trackWithPage:comment_reply link2:nil];
                NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_reply];
                [SNNewsReport reportADotGifWithTrack:paramString];
            }

            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            if (cmtObj.actId.length) {
                [dic setObject:cmtObj.actId forKey:kCircleCommentKeyActId];
            }
            
            if (cmtObj.pid.length > 0)
                [dic setObject:cmtObj.pid forKey:kCircleCommentKeyFpid];
            
            if (cmtObj.nickName.length > 0) {
                [dic setObject:cmtObj.nickName forKey:kCircleCommentKeyFname];
            }
            if (cmtObj.commentId.length > 0) {
                [dic setObject:cmtObj.commentId forKey:kCircleCommentKeyCommentId];
            }
            
            TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES]
                                   applyQuery:dic];
            [[TTNavigator navigator] openURLAction:action];
            
            break;
        }
        index++;
    }
}

#pragma mark - updateTheme
- (void)updateTheme
{
    self.bgImage = [UIImage themeImageNamed:@"timeline_origin_bg_with_angle@2x.png"];
    for (SNTimelineCommentsObject *cmtObj in self.commentsData) {
        cmtObj.attContent = [cmtObj setCommentAttributedStr];
    }
    [self setNeedsDisplay];
}
@end
