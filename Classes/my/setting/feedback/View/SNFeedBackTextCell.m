//
//  SNFeedBackTextCell.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackTextCell.h"
#import "SNFeedBackTextModel.h"
#import "SNUserManager.h"
#import "SNSerQuestionListRequest.h"


#define kTextMaxWidth (kAppScreenWidth - kFBIconLeftMargin * 2 - kFBIconWidth - kFBNameLeftMargin - kFBTextLeftMargin * 2)

@interface SNFeedBackTextCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *firstRecordView;
@property (nonatomic, strong) SNFeedBackTextModel *textModel;

@end

@implementation SNFeedBackTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    _recordLabel = [[UILabel alloc] init];
    _recordLabel.userInteractionEnabled = YES;
    _recordLabel.backgroundColor = [UIColor clearColor];
    _recordLabel.textColor = SNUICOLOR(kThemeText2Color);
    _recordLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _recordLabel.numberOfLines = 0;
    [self.chatBubble addSubview:_recordLabel];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
    longPressGesture.delegate = self;
    [self.recordLabel addGestureRecognizer:longPressGesture];

}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    if (action == @selector(resendFeedback) ||
        action == @selector(copyFeedback)) {
        return YES;
    }
    return NO;
}

-(void)openMenu:(UILongPressGestureRecognizer *)longPressGesture {
    if (_textModel.fbType == FeedBackTypeReply) {
        return;
    }
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        
        UIMenuController *contextMenu = [UIMenuController sharedMenuController];
        if ([contextMenu isMenuVisible]) {
            [contextMenu setMenuVisible:NO];
        } else {
            contextMenu.arrowDirection = UIMenuControllerArrowDefault;
            //        [contextMenu setMenuVisible:NO];
            [self becomeFirstResponder];
            
            NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
            //            if (sendStatus == FBSendStatusFailed) {
            UIMenuItem *sendMenuItem = [[UIMenuItem alloc] initWithTitle:@"重新发送" action:@selector(resendFeedback)];
            [menuItemsArray addObject:sendMenuItem];
            
            UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyFeedback)];
            [menuItemsArray addObject:copyMenuItem];
            
            contextMenu.menuItems = menuItemsArray;
            
            [contextMenu update];
            [contextMenu setTargetRect:CGRectMake(0, 15, self.recordLabel.width, self.recordLabel.height) inView:self.recordLabel];
            [contextMenu setMenuVisible:YES animated:YES];
        }
    }
}

- (void)setDataWithModel:(SNFeedBackTextModel *)fbModel {
    _firstRecordView = nil;
    [_firstRecordView removeFromSuperview];
    _textModel = fbModel;
    if (fbModel.date.length > 0) {
        self.dateLabel.text = [fbModel.date getDateFormate];
    }
    UIImage *leftImage = [UIImage imageNamed:@"icofeedback_leftbackground_v5.png"];
    UIImage *rightImage = [UIImage imageNamed:@"icofeedback_rightbackground_v5.png"];
    UIImage *replyBgImage = [leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 20, 10, 20)];
    UIImage *meBgImage = [rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 20, 10, 20)];
    if (fbModel.fbType == FeedBackTypeMe){
        UIImage *iconImage = [UIImage imageNamed:@"feedBack_defaultIcon_v5.png"];
        if ([SNUserManager isLogin]) {
            self.nameLabel.text = [SNUserManager getNickName];
            [self.iconView sd_setImageWithURL:[NSURL URLWithString:[SNUserManager getHeadImageUrl]]
                             placeholderImage:iconImage];
            if ([SNThemeManager sharedThemeManager].isNightTheme) {
                self.iconView.alpha = 0.5;
            } else {
                self.iconView.alpha = 1;
            }

        } else {
            self.iconView.image = iconImage;
            self.nameLabel.text = @"搜狐网友";
        }
        self.chatBubble.image = meBgImage;
    } else {
        self.iconView.image = [UIImage imageNamed:@"cs_icon.png"];
        self.nameLabel.text = @"客服小秘书";
        self.chatBubble.image = replyBgImage;
    }
    self.recordLabel.text =fbModel.fbText;
    
    [self setFrameWithModel:fbModel];
}

- (void)setFrameWithModel:(SNFeedBackTextModel *)fbModel {
    if (fbModel.fbType == FeedBackTypeMe) {
        self.nameLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    CGFloat iconX = fbModel.fbType == FeedBackTypeReply ? kFBIconLeftMargin : (kAppScreenWidth - kFBIconLeftMargin - kFBIconWidth);
    CGSize nameSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeB]} context:nil].size;
    CGFloat nameX = fbModel.fbType == FeedBackTypeReply ? (iconX + kFBIconWidth + kFBNameLeftMargin) : (iconX - kFBNameLeftMargin - nameSize.width);
    if (!fbModel.isHideDate) {
        self.dateLabel.hidden = NO;
        self.dateLabel.frame = CGRectMake(0, kFBDateTopMargin, kAppScreenWidth, 11);
        self.iconView.frame = CGRectMake(iconX, kFBNameTopMargin + CGRectGetMaxY(self.dateLabel.frame), kFBIconWidth, kFBIconWidth);
    } else {
        self.dateLabel.hidden = YES;
        self.iconView.frame = CGRectMake(iconX, kFBDateTopMargin, kFBIconWidth, kFBIconWidth);
    }
    self.nameLabel.frame = CGRectMake(nameX, self.iconView.top, nameSize.width, 11);

    CGSize titleSize = [fbModel.fbText boundingRectWithSize:CGSizeMake(kTextMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeD]} context:nil].size;
    CGFloat bubbleX = fbModel.fbType == FeedBackTypeReply ? self.nameLabel.left - 10 : (self.nameLabel.right + 10 - titleSize.width - kFBTextLeftMargin * 2);
    self.chatBubble.frame = CGRectMake(bubbleX, self.nameLabel.bottom + kFBIconLeftMargin, titleSize.width + kFBTextLeftMargin * 2 , titleSize.height + kFBBubblrBottomMargin * 2);
    if (fbModel.isSendFaild) {
        self.warningView.hidden = NO;
        self.warningView.frame = CGRectMake(self.chatBubble.left - kFBWarningWidth, self.chatBubble.top, kFBWarningWidth, kFBWarningWidth);
    } else {
        self.warningView.hidden = YES;
    }
    CGFloat recordX = fbModel.fbType == FeedBackTypeReply ? (kFBTextLeftMargin + 5):(kFBTextLeftMargin - 5);
    self.recordLabel.frame = CGRectMake(recordX, kFBBubblrBottomMargin, titleSize.width, titleSize.height);
    if (fbModel.row == 0) {
        
        CGFloat width = [self calcuMaxQuestionWidthWithQuestionArray:self.questionArray];
        [self setFirstRowFeedBackWithMaxWidth:MAX(width, titleSize.width) andQuestionCount:self.questionArray.count];
        [self setFirstRowTextWithArray:self.questionArray];
    }
    
}

- (void)gotoQueation:(UITapGestureRecognizer *)recognizer {
    NSString *url = SNLinks_Path_FeedBackH5_HotQuestion;
    for (UIView *view in recognizer.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            NSInteger questionId = label.tag;
            NSString *title = [label.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            NSString *detailUrl = [NSString stringWithFormat:@"%@?id=%zd&title=%@",url,questionId,title];
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            if (detailUrl.length > 0) {
                [query setObject:detailUrl forKey:@"allQuestionUrl"];
            }
            [query setObject:[NSNumber numberWithInteger:FeedBackWebViewType] forKey:kUniversalWebViewType];
            [SNUtility openUniversalWebView:query];
        }
    }
}



/**
 *  根据要显示的问题最大宽度展示UI
 *
 *  @param maxWidth 问题显示最大宽度
 *  @param count    问题个数
 */
- (void)setFirstRowFeedBackWithMaxWidth:(CGFloat)maxWidth  andQuestionCount:(NSInteger)count{
    [_firstRecordView removeFromSuperview];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kFBTextLeftMargin + 5, self.recordLabel.bottom, maxWidth + 10, kDefaultEachQuestionHeight*count)];
    _firstRecordView = view;
    self.chatBubble.height += kDefaultEachQuestionHeight*count;
    self.chatBubble.width = maxWidth + kFBTextLeftMargin * 2 + 10;
    [self.chatBubble addSubview:view];
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0, kDefaultEachQuestionHeight*i, view.width, kDefaultEachQuestionHeight)];
        [tipView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoQueation:)]];
        [view addSubview:tipView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, maxWidth, 18)];
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = SNUICOLOR(kThemeText2Color);
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [tipView addSubview:label];
        UIImageView *tipImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_hl.png"]];
        tipImgV.userInteractionEnabled = NO;
        tipImgV.frame = CGRectMake(tipView.width - 10, tipView.height - 12, 7.5, 12);
        [tipView addSubview:tipImgV];
    }
}

/**
 *  设置三个问题的显示内容
 *
 *  @param array 问题数组,包括文字和对应ID
 */
- (void)setFirstRowTextWithArray:(NSArray *)array {
    for (NSInteger i = 0; i < self.firstRecordView.subviews.count; i++) {
        UIView *tipView = [self.firstRecordView.subviews objectAtIndex:i];
        NSDictionary *dict = [array objectAtIndex:i];
        [tipView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)obj;
                label.text = [dict objectForKey:kQuestionTitle];;
                label.tag = [[dict objectForKey:kQuestionId] integerValue];
            }
        }];
    }
}

- (CGFloat)calcuMaxQuestionWidthWithQuestionArray:(NSArray *)array {
    CGFloat maxWidth = 0;
    for (NSDictionary *obj in array) {
        NSString *title = [obj objectForKey:kQuestionTitle];
        CGFloat width = [title boundingRectWithSize:CGSizeMake(kTextMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeD]} context:nil].size.width;
        if (width > maxWidth) {
            maxWidth = width;
        }
    }
    if (maxWidth > kTextMaxWidth - kFBTextLeftMargin - 15) {
        maxWidth = kTextMaxWidth - kFBTextLeftMargin - 15;
    }
    return maxWidth;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)resendFeedback {
    if ([self.delegate respondsToSelector:@selector(resendFeedBackWithFbModel:)]) {
        [self.delegate resendFeedBackWithFbModel:self.textModel];
    }
}

- (void)copyFeedback {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.textModel.fbText;
}



@end
