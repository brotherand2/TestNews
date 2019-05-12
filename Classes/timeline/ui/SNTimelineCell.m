//
//  SNTimelineCell.m
//  sohunews
//
//  Created by jojo on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineCell.h"
#import "SNDBManager.h"
#import "SNBaseEditorViewController.h"
#import "SNCircleCommentEditorController.h"
#import "SNGuideRegisterManager.h"

@implementation SNTimelineCell
@synthesize timelineObj = _timelineObj;
@synthesize commonViewBuilder = _commonViewBuilder;
@synthesize hideComment = _hideComment;
@synthesize showDetele = _showDetele;
@synthesize ignoreUserInfoTap = _ignoreUserInfoTap;
@synthesize delegate;
@synthesize indexPath = _indexPath;

+ (CGFloat)heightForTimelineObj:(SNTimelineTrendItem *)obj hideComment:(BOOL)hideComment {
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _commentViewsArray = [[NSMutableArray alloc] init];
        _commentMoreButtonArray = [[NSMutableArray alloc] init];
        _commentViewsFrameArray = [[NSMutableArray alloc] init];
        
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
        UIColor *authorColor = [UIColor colorFromString:strColor];
        
        for (int i = 0; i < kTimelineMaxCommentDisplayNum; ++i) {
            SNLabel *lb = [[[SNLabel alloc] initWithFrame:CGRectZero] autorelease];
            lb.font = [UIFont systemFontOfSize:kTLCommentsViewTextFontSize];
            lb.lineHeight = kTLCommentsViewTextLineHeight;
            lb.delegate = self;
            lb.linkColor = authorColor;
            lb.tag = i;
            lb.tapEnable = YES;
            [_commentViewsArray addObject:lb];
            [self addSubview:lb];
            
            NSString *contentColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor];
            UIColor *contentColor = [UIColor colorFromString:contentColorStr];
            lb.textColor = contentColor;
            
            UIButton* button = [self makeMoreButton];
            [_commentMoreButtonArray addObject:button];
            [self addSubview:button];
        }
        
        // Initialization code
        // 由于 timeline 订阅按钮 隐藏掉了  所以不需要监听刊物订阅状态变化了
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(handleMySubDidChangedNotification:)
//                                                     name:kSubscribeCenterMySubDidChangedNotify
//                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    TT_RELEASE_SAFELY(_timelineObj);
    TT_RELEASE_SAFELY(_commonViewBuilder);
    
    TT_RELEASE_SAFELY(_headIconView);
    TT_RELEASE_SAFELY(_nameLabel);
    TT_RELEASE_SAFELY(_timeLabel);
    TT_RELEASE_SAFELY(_contentLabel);
    TT_RELEASE_SAFELY(_abstractLabel);
    TT_RELEASE_SAFELY(_commentButton);
    
    TT_RELEASE_SAFELY(_moreCommentsButton);
    TT_RELEASE_SAFELY(_commentViewsArray);
    TT_RELEASE_SAFELY(_commentMoreButtonArray);
    TT_RELEASE_SAFELY(_commentViewsFrameArray);
    
    TT_RELEASE_SAFELY(_originalTapview);
    TT_RELEASE_SAFELY(_videoIconView);
    TT_RELEASE_SAFELY(_subButton);
    TT_RELEASE_SAFELY(_moreButton);
    
    [super dealloc];
}

- (UIButton*)makeMoreButton {
    UIFont *font = [UIFont systemFontOfSize:kTLShareInfoViewNameFontSize];
    
    UIButton* moreButton = [[[UIButton alloc]initWithFrame:CGRectZero] autorelease];
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
    moreButton.exclusiveTouch = YES;
    [moreButton setTitleColor:[UIColor colorFromString:strColor] forState:UIControlStateNormal];
    [moreButton setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
    [moreButton.titleLabel setFont:font];
    moreButton.width = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:moreButton.titleLabel.font].width;
    return moreButton;
}

- (void)setTimelineObj:(SNTimelineTrendItem *)timelineObj {
    // more cell

    //删除动态
//    if (!_moreCommentsButton) {
//        NSString *contentColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
//        UIColor *contentColor = [UIColor colorFromString:contentColorStr];
//        
//        _moreCommentsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, kTLCommentsViewOneCellHeight)];
//        _moreCommentsButton.titleLabel.font = [UIFont systemFontOfSize:kTLCommentsViewTextFontSize];
//        [_moreCommentsButton setTitleColor:contentColor forState:UIControlStateNormal];
//        [_moreCommentsButton addTarget:self action:@selector(moreCommentAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_moreCommentsButton];
//    }
//    
//    NSString *morebtnTitle = [NSString stringWithFormat:@"查看全部%d条评论", self.timelineObj.commentsArray.count];
//    [_moreCommentsButton setTitle:morebtnTitle forState:UIControlStateNormal];
//    _moreCommentsButton.hidden = !(self.timelineObj.commentsArray.count > kTimelineMaxCommentDisplayNum);
//    
//    if (self.hideComment) {
//        _commentButton.hidden = YES;
//        _moreCommentsButton.hidden = YES;
//    }
//    else if (self.timelineObj.commentsArray.count > 0) {
//        // draw comment bg
//        UIImage *commentBgImage = [UIImage imageNamed:@"timeline_comment_bg.png"];
//        CGRect bgImageRect = CGRectMake(self.width - 10 - commentBgImage.size.width,
//                                        _commentButton.bottom,
//                                        commentBgImage.size.width,
//                                        self.height - kTLCellBottomMargin - _commentButton.bottom);
    
        // draw comments content
//        int index = 0;
//        UIImage *commentSepImage = [UIImage imageNamed:@"timeline_comment_sep.png"];
//        CGFloat startY = bgImageRect.origin.y + kTLCommentsViewIconBottomMargin + kTLCommentsViewTextTopMargin;
        
//        CGFloat textWidth = kTLCommentsViewTextWidth;
//        CGFloat startX = CGRectGetMidX(bgImageRect) - textWidth / 2;
        
//        while (index < self.timelineObj.commentsArray.count && index < kTimelineMaxCommentDisplayNum) {
//            SNTimelineCommentsObject *cmtObj = [self.timelineObj.commentsArray objectAtIndex:index];
        
//            NSInteger height = cmtObj.textHeight;
//            SNLabel *label = [self commentAttriLabelForIndex:index];
//            label.backgroundColor = [UIColor clearColor];
//            label.hidden = NO;
            //label.attributedString = cmtObj.attriString;
//            label.frame = CGRectMake(startX, startY, textWidth, height);
//            label.text = cmtObj.stringToCaculate;
            
//            [label removeAllCustomLinks];
//            [label addCustomLink:[NSString stringWithFormat:@"link://%@",cmtObj.pid] inRange:NSRangeFromString(cmtObj.authorRangeString)];
            // 回复人的 link
//            if (cmtObj.fpid.length > 0 && cmtObj.replyRangeString.length > 0) {
//                [label addCustomLink:[NSString stringWithFormat:@"link://%@", cmtObj.fpid] inRange:NSRangeFromString(cmtObj.replyRangeString)];
//            }
            
//            if(cmtObj.isFolder && cmtObj.needFolder) {
//                UIButton* button = [self commentMoreForIndex:index];
//                button.hidden = NO;
//                button.frame = CGRectMake(startX, CGRectGetMaxY(label.frame), button.width, SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT);
//                startY = CGRectGetMaxY(label.frame) + SNTIMELINE_SHAREINFO_COMMENT_MORE_HEIGHT;
//                
//                [button setAction:kUIButtonBlockTouchUpInside withBlock:^{
//                    cmtObj.isFolder = NO;
////                    [timelineObj resetAllCommentHeight];
//                    [timelineObj sizeToFit];
//                    
//                    UITableView *parentTable = (UITableView *)self.superview;
//                    [parentTable reloadData];
//                }];
//                
//            }
//            else{
//                startY = CGRectGetMaxY(label.frame);
//            }
//            
//            if ((self.timelineObj.commentsArray.count > kTimelineMaxCommentDisplayNum) ||
//                (self.timelineObj.commentsArray.count <= kTimelineMaxCommentDisplayNum && index != self.timelineObj.commentsArray.count - 1)) {
//                
//                startY += kTLCommentsViewTextBottomMargin;
//                
//                CGRect sepRect = CGRectMake(CGRectGetMidX(bgImageRect) - commentSepImage.size.width / 2,
//                                            startY - 1,
//                                            commentSepImage.size.width,
//                                            commentSepImage.size.height);
//                [_commentViewsFrameArray addObject:NSStringFromCGRect(sepRect)];
//                
//                startY += kTLCommentsViewTextTopMargin;
//            }
//            index++;
//        }
//    }
//    
//    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

#pragma mark - draw methods

- (void)drawTimelineOriginContent {
    
    if (self.timelineObj.content.length > 0) {
        UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg.png"];
        if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        else
            bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        
        [bgImage drawInRect:_originalContentRect];
    }
    else {
        UIImage *bgImage = [UIImage imageNamed:@"timeline_origin_bg_with_angle.png"];
        if ([bgImage respondsToSelector:@selector(resizableImageWithCapInsets:)])
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        else
            bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        
        [bgImage drawInRect:CGRectMake(_originalContentRect.origin.x, _originalContentRect.origin.y - 5,
                                       _originalContentRect.size.width, _originalContentRect.size.height + 5)];
    }
}

- (SNLabel *)commentAttriLabelForIndex:(int)index {
    SNLabel *lb = nil;
    
    if (!_commentViewsArray) {
        _commentViewsArray = [[NSMutableArray alloc] init];
    }
    
    if (index < _commentViewsArray.count) {
        lb = [_commentViewsArray objectAtIndex:index];
    }
    else {
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor];
        UIColor *authorColor = [UIColor colorFromString:strColor];
        
        lb = [[[SNLabel alloc] initWithFrame:CGRectZero] autorelease];
        lb.font = [UIFont systemFontOfSize:kTLCommentsViewTextFontSize];
        lb.lineHeight = kTLCommentsViewTextLineHeight;
        lb.delegate = self;
        lb.linkColor = authorColor;
        lb.tag = index;
        lb.tapEnable = YES;
        [_commentViewsArray addObject:lb];
        [self addSubview:lb];
        
        NSString *contentColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor];
        UIColor *contentColor = [UIColor colorFromString:contentColorStr];
        lb.textColor = contentColor;
    }
    
    lb.tag = index;
    
    return lb;
}

- (UIButton *)commentMoreForIndex:(int)index {
    UIButton *button = nil;
    
    if (!_commentMoreButtonArray) {
        _commentMoreButtonArray = [[NSMutableArray alloc] init];
    }
    
    if (index < _commentMoreButtonArray.count) {
        button = [_commentMoreButtonArray objectAtIndex:index];
    }
    else {
        UIButton* button = [self makeMoreButton];
        
        [_commentMoreButtonArray addObject:button];
        [self addSubview:button];
    }
    
    button.tag = index;
    
    return button;
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    if ([link length] > 0) {
        if ([link hasPrefix:@"link://"]) {
            NSString *pid = [link substringFromIndex:7];
            
            TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : pid}] applyAnimated:YES];
            [[TTNavigator navigator] openURLAction:urlAction];
        } else {
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            
            [query setObject:link forKey:@"address"];
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
            [[TTNavigator navigator] openURLAction:urlAction];
            
        }
   }
    
}

- (void)tapOnNotLink:(SNLabel *)label
{
}

#pragma mark - actions

- (void)openOriginalContentAction:(id)sender {
    if (self.timelineObj.originContentObj.link.length > 0) {
        [SNUtility openProtocolUrl:self.timelineObj.originContentObj.link context:nil];
    }
}

- (void)commentAction:(id)sender {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
    
    [dic release];
    dic = nil;
}

- (void)deleteAction:(id)sender {
}

- (void)moreCommentAction:(id)sender {
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:self.timelineObj forKey:@"timelineObj"];
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://readCommentList"] applyAnimated:YES] applyQuery:dicInfo];
    [[TTNavigator navigator] openURLAction:action];
}

- (void)userIconOrNameTapped:(id)sender {
    // 如果是点击了自己  不进入我自己的用户中心
    if (self.ignoreUserInfoTap)
        return;
    
//    if (self.hideComment)
//        return;
    
    TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : self.timelineObj.pid}] applyAnimated:YES];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)subAction:(id)sender {
    if (self.timelineObj.originContentObj.subId.length == 0) {
        SNDebugLog(@"%@-%@: error empty subId !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    _subButton.hidden = YES;
    
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.timelineObj.originContentObj.subId];
    if (!subObj) {
        subObj = [[SCSubscribeObject new] autorelease];
        subObj.subId = self.timelineObj.originContentObj.subId;
    }
    
    NSString *succMsg = [subObj succSubMsg];
    NSString *failMsg = [subObj failSubMsg];
    
    // 统计refer
    subObj.from = REFER_READ_CIRCLE;
    
    SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer
                                                                            request:nil
                                                                              refId:subObj.subId];
    [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
    [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:subObj];
}

- (void)handleMySubDidChangedNotification:(NSNotification *)notification {
    _subButton.hidden = YES;
}

@end