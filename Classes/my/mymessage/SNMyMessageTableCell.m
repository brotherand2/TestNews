//
//  SNMyMessageTableCell.m
//  sohunews
//
//  Created by jialei on 13-7-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyMessageTableCell.h"
#import "SNMyMessage.h"

#import "SNHeadIconView.h"
#import "SNNameButton.h"
#import "SNMyMessageTableController.h"
#import "SNBaseEditorViewController.h"

#define HEAD_X 8
#define HEAD_Y 12
#define HEAD_W 36
#define CELL_TOP_MARGIN                               (22.0f/2)
#define CELL_BOTTOM_MARGIN                            (22.0f/2)

#define kDefaultPassport    @"kDefaultPassport"
#define CELL_CONTENT_FONT                   ([SNUtility newsContentFontSize])
#define CEll_CONTENT_LINE_HEIGHT            ([SNUtility newsContentFontLineheight])

enum messageViewType {
    messageViewType_userNameLabel   = 10,
    messageViewType_dataLabel       = 12,
    messageViewType_cityLabel       = 13,
    messageViewType_contentLabel    = 14,
    messageViewType_floorContainer  = 15,
    messageViewType_floorLabel      = 16,
    messageViewType_newsTitleButton = 18,
    messageViewType_picView         = 19,
    messageViewType_userHeadIcon    = 20,
    messageViewType_floorPicView    = 21,
    messageViewType_expandFloor     = 30,
    messageViewType_expandComment   = 31,
    messageViewType_newsTitleLabel  = 32,
    messageViewType_expandFloorComment = 33,
    messageViewType_dicatorView = 34,
    messageViewType_floorNameLabel = 35
};
@implementation SNMyMessageTableCell

@synthesize item;

+ (CGFloat)rowHeightForObject:(id)object {
    SNMyMessageItem* fitem = object;
	SNMyMessage *comment = fitem.socialMsg;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat h = CELL_TOP_MARGIN + HEAD_W + CELL_BOTTOM_MARGIN;
    UIFont* font = [UIFont systemFontOfSize:kFLOOR_COMMENT_CONTENT_FONT];
    NSString *content = [comment.replyComment.content trim];
    CGFloat contentWidth = CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN;
    CGFloat maxHeight = CEll_CONTENT_LINE_HEIGHT * KCOMMENT_THUMBNAIL_LINENUM;
    CGSize maximumSize = CGSizeMake(contentWidth, maxHeight);
    CGFloat maxHeightWithMore = CEll_CONTENT_LINE_HEIGHT * (KCOMMENT_THUMBNAIL_LINENUM - 2);
    CGSize maxSizeWithMore = CGSizeMake(contentWidth, maxHeightWithMore);
    
    if ([content length] > 0)
    {
        h += kFLOOR_COMMENT_USER_INFO_HEIGHT + CELL_BOTTOM_MARGIN * 2 + 2;
        {
            CGSize maxLabelSize = [SNLabel sizeForContent:content
                                                  maxSize:maximumSize
                                                     font:font.pointSize
                                               lineHeight:CEll_CONTENT_LINE_HEIGHT];
            CGSize maxLabelSizeWithMore = [SNLabel sizeForContent:content
                                                     maxSize:maxSizeWithMore
                                                        font:font.pointSize
                                                  lineHeight:CEll_CONTENT_LINE_HEIGHT];
            CGFloat height = [SNLabel heightForContent:content
                                              maxWidth:contentWidth
                                                  font:CELL_CONTENT_FONT
                                            lineHeight:CEll_CONTENT_LINE_HEIGHT];
            if(height > maxLabelSize.height && comment.replyComment.isFolder)
            {
                comment.replyComment.needFolder = YES;
                h += maxLabelSizeWithMore.height + OPEN_COMMENT_BTN_HEIGHT + CELL_BOTTOM_MARGIN * 2;
                fitem.replayCommentHeight = maxLabelSizeWithMore.height;
            }
            else
            {
                comment.replyComment.needFolder = NO;
                h += height + CELL_BOTTOM_MARGIN;
                fitem.replayCommentHeight = height;
            }
        }
        
        h += (CELL_BOTTOM_MARGIN);
    }
    
    content = [comment.actComment.content trim];
    CGSize maxLabelSize = [SNLabel sizeForContent:content
                                          maxSize:maximumSize
                                             font:font.pointSize
                                       lineHeight:CEll_CONTENT_LINE_HEIGHT];
    CGSize maxLabelSizeWithMore = [SNLabel sizeForContent:content
                                                  maxSize:maxSizeWithMore
                                                     font:font.pointSize
                                               lineHeight:CEll_CONTENT_LINE_HEIGHT];
    CGFloat height = [SNLabel heightForContent:content
                                      maxWidth:contentWidth
                                          font:CELL_CONTENT_FONT
                                    lineHeight:CEll_CONTENT_LINE_HEIGHT];
    if(height > maxLabelSize.height && comment.actComment.isFolder)
    {
        comment.actComment.needFolder = YES;
        h += maxLabelSizeWithMore.height + CELL_BOTTOM_MARGIN * 2 + OPEN_COMMENT_BTN_HEIGHT;
        fitem.actCommentHeight = maxLabelSizeWithMore.height;
    }
    else
    {
        comment.actComment.needFolder = NO;
        h += height + CELL_BOTTOM_MARGIN;
        fitem.actCommentHeight = height;
    }
    
    if(comment.shareObj && [comment.shareObj.title length] > 0)
    {
        h += KFLOOR_COMMENT_NEWSTITLE_HEIGHT + CELL_BOTTOM_MARGIN;
    }
    
	return h;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    [UIView drawCellSeperateLine:rect];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark -  UI
- (void)setObject:(id)object {
	if (self.item != object) {
		[super setObject:object];
        self.item               = object;
        _originY                = 0;

       UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
       tapGes.delegate = self;
       [self addGestureRecognizer:tapGes];
        
       [self addUserInfo];
       [self addPostDate];
       [self addCityLabel];
       [self addContent];
       [self addOriginalFloor];
       [self addNewsTitle];
	}
}

//头像名字
- (void)addUserInfo
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    SNHeadIconView *userHeadIcon = (SNHeadIconView*)[self.contentView viewWithTag:messageViewType_userHeadIcon];
    if (!userHeadIcon) {
        userHeadIcon = [[SNHeadIconView alloc] initWithFrame:CGRectMake(CELL_RIGHT_MARGIN, CELL_TOP_MARGIN, HEAD_W, HEAD_W)];
        [userHeadIcon setTarget:self tapSelector:@selector(clickNameBtn)];
        
        userHeadIcon.tag = messageViewType_userHeadIcon;
        [self.contentView addSubview:userHeadIcon];
    }
    
    SNNameButton *userInfoLabel = (SNNameButton *)[self.contentView viewWithTag:messageViewType_userNameLabel];
    if (!userInfoLabel)
    {
        userInfoLabel = [[SNNameButton alloc]initWithFrame:CGRectZero];
        [userInfoLabel.titleLabel setFont:[UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT]];
        userInfoLabel.tag = messageViewType_userNameLabel;
        //userInfoLabel.cell = self;
        userInfoLabel.backgroundColor = [UIColor clearColor];
        [userInfoLabel addTarget:self action:@selector(clickNameBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:userInfoLabel];
    }
    
    [userInfoLabel setTitleColor:SNUICOLOR(kAuthorNameColor) forState:UIControlStateNormal];
    [userInfoLabel setTitle:self.item.socialMsg.actComment.nickName forState:UIControlStateNormal];
    
    //根据实际长度计算实际区域
    CGSize limitSize = [userInfoLabel.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT]
                                                 constrainedToSize:CGSizeMake(CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN - 25, 1000)];
    userInfoLabel.frame = CGRectMake(CGRectGetMaxX(userHeadIcon.frame) + CELL_RIGHT_MARGIN - 2, CELL_TOP_MARGIN + 1, limitSize.width, limitSize.height);
    
    //是否拥有通行证
    [userHeadIcon setIconUrl:self.item.socialMsg.actComment.headUrl passport:kDefaultPassport gender:[self.item.socialMsg.gender intValue]];
    userHeadIcon.alpha = themeImageAlphaValue();
    
    _originY += CGRectGetMaxY(userHeadIcon.frame) + CELL_BOTTOM_MARGIN;
}

//时间
-(void)addPostDate {
    UILabel *userInfoLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_userNameLabel];
    UILabel *dateLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_dataLabel];
    if (!dateLabel) {
        dateLabel = [[UILabel alloc] init];
        dateLabel.frame = CGRectZero;
        [dateLabel setFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]];
        dateLabel.tag = messageViewType_dataLabel;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:dateLabel];
    }
    
    dateLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    
    if ([self.item.socialMsg.replyComment.time length] > 0) {
        dateLabel.text = self.item.socialMsg.replyComment.time;
        dateLabel.accessibilityLabel = [NSDate accessoryRelativelyDate:self.item.socialMsg.ctime];
    }
    else if([self.item.socialMsg.actComment.time length] > 0) {
        dateLabel.text = self.item.socialMsg.actComment.time;
        dateLabel.accessibilityLabel = [NSDate accessoryRelativelyDate:self.item.socialMsg.actComment.time];
    }
    else {
        dateLabel.text = @"";
    }
    
    CGSize limitSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:CGSizeMake(320, 1000)];
    dateLabel.frame = CGRectMake((userInfoLabel.origin.x), CGRectGetMaxY(userInfoLabel.frame) + MarginTopBetweenUserLabelAndTimeDingLabel,
                                 limitSize.width, CELL_DATE_CITY_DING_LABEL_HEIGHT);
}

//城市
- (void)addCityLabel
{
    UILabel *userInfoLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_userNameLabel];
    UILabel *dateLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_dataLabel];
    UILabel *_cityLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_cityLabel];
    
    if (!_cityLabel)
    {
        _cityLabel = [[UILabel alloc] init];
        
        _cityLabel.frame = CGRectMake(dateLabel.frame.origin.x+dateLabel.frame.size.width+12, CGRectGetMaxY(userInfoLabel.frame) + MarginTopBetweenUserLabelAndTimeDingLabel,
                                      CELL_CITY_LABEL_WIDTH, CELL_DATE_CITY_DING_LABEL_HEIGHT);
        
        [_cityLabel setFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]];
        
        _cityLabel.tag = messageViewType_cityLabel;
        
        _cityLabel.backgroundColor = [UIColor clearColor];
        
        _cityLabel.textAlignment = NSTextAlignmentLeft;
        
        [_cityLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        
        [_cityLabel setNumberOfLines:1];
        
        [self.contentView addSubview:_cityLabel];
        
        
    }
    
    _cityLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    
    if (self.item.socialMsg.city && [self.item.socialMsg.city length] > 0)
    {
        _cityLabel.text = self.item.socialMsg.city;
    }
    else
    {
        _cityLabel.text = @"";
    }
    _cityLabel.frame = CGRectMake(dateLabel.frame.origin.x+dateLabel.frame.size.width + 12,
                                  CGRectGetMaxY(userInfoLabel.frame) + MarginTopBetweenUserLabelAndTimeDingLabel,
                                  CELL_CITY_LABEL_WIDTH,
                                  CELL_DATE_CITY_DING_LABEL_HEIGHT);
}

//回复内容
- (void)addContent
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    SNLabel *contentLabel = (SNLabel *)[self.contentView viewWithTag:messageViewType_contentLabel];
    SNNameButton *expandBtn = (SNNameButton*)[self.contentView viewWithTag:messageViewType_expandComment];
    UIFont *font = [UIFont systemFontOfSize:CELL_CONTENT_FONT];
    UIFont *expandFont = [UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT];

    if (!contentLabel)
    {
        contentLabel = [[SNLabel alloc] init];
        contentLabel.font = font;
        contentLabel.lineHeight = CEll_CONTENT_LINE_HEIGHT;
        contentLabel.delegate = self;
        contentLabel.tag = messageViewType_contentLabel;
        [self.contentView addSubview:contentLabel];
    }
    contentLabel.alpha = themeImageAlphaValue();
    contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    contentLabel.text = [self.item.socialMsg.actComment.content trim];
    
    //正文
    if ([contentLabel.text length] > 0)
    {
        CGFloat contentWidth = CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN;
        contentLabel.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN, _originY, contentWidth, self.item.actCommentHeight);
        _originY = contentLabel.bottom + CELL_BOTTOM_MARGIN;
        
        //显示更多
        if(!expandBtn)
        {
            expandBtn = [[SNNameButton alloc]initWithFrame:CGRectZero];
            expandBtn.tag = messageViewType_expandComment;
            expandBtn.backgroundColor = [UIColor clearColor];
            expandBtn.exclusiveTouch = YES;
            [expandBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]] forState:UIControlStateNormal];
            [expandBtn setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
            [expandBtn.titleLabel setFont:expandFont];
            [expandBtn addTarget:self action:@selector(expandComment:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView  addSubview:expandBtn];
        }
        if (self.item.socialMsg.actComment.isFolder && self.item.socialMsg.actComment.needFolder)
        {
            CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:expandFont];
            expandBtn.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN, _originY,
                                         stringSize.width, OPEN_COMMENT_BTN_HEIGHT);
            expandBtn.hidden = NO;
            _originY = expandBtn.bottom + CELL_BOTTOM_MARGIN;
        }
        else
        {
            expandBtn.hidden = YES;
        }
    }
    else
    {
        contentLabel.frame = CGRectZero;
        expandBtn.hidden = YES;
    }
}

//原评论
- (void)addOriginalFloor
{
    UIImageView *floorContainer = (UIImageView *)[self.contentView viewWithTag:messageViewType_floorContainer];
    if (floorContainer) {
        [floorContainer removeFromSuperview];
    }
    
    if ([self.item.socialMsg.replyComment.content length] > 0)
    {
        floorContainer = [[UIImageView alloc] init];
        floorContainer.tag = messageViewType_floorContainer;
        floorContainer.backgroundColor = [UIColor clearColor];
        floorContainer.userInteractionEnabled = YES;
        UIImage *bgImage = [UIImage imageNamed:@"comment_floor_bg.png"];
        UIFont *font = [UIFont systemFontOfSize:CELL_CONTENT_FONT];
        UIFont *expandFont = [UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT];
        float containerHeight = 0;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        } else {
            bgImage = [bgImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        }
        floorContainer.image = bgImage;
        floorContainer.alpha = themeImageAlphaValue();
        [self.contentView addSubview:floorContainer];
        CGRect screenRect = [UIScreen mainScreen].bounds;
        
        //我的名字
        CGRect rect = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, CELL_BOTTOM_MARGIN,
                                 CGRectGetWidth(screenRect) - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 3 - CELL_CONTENT_LEFT_MARGIN - kFLOOR_COMMENT_FLOOR_NUM_WIDTH,
                                 kFLOOR_COMMENT_USER_INFO_HEIGHT + 2);
        UILabel *myNameLabel = [[UILabel alloc]initWithFrame:rect];
        [myNameLabel setFont:[UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT]];
        
        if (self.item.socialMsg.replyComment.nickName.length > 0) {
            [myNameLabel setText:self.item.socialMsg.replyComment.nickName];
        }
        
        myNameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]];
        myNameLabel.backgroundColor = [UIColor clearColor];
        myNameLabel.userInteractionEnabled = YES;
        myNameLabel.tag = messageViewType_floorNameLabel;
        [floorContainer addSubview:myNameLabel];
        containerHeight += CGRectGetMaxY(myNameLabel.frame) + CELL_BOTTOM_MARGIN;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(clikcFloorNickName)];
        [myNameLabel addGestureRecognizer:tap];
        
        //原文
        SNLabel *contentLabel = (SNLabel *)[self.contentView viewWithTag:messageViewType_floorLabel];
        if (!contentLabel)
        {
            contentLabel = [[SNLabel alloc] init];
            contentLabel.font = font;
            contentLabel.lineHeight = CEll_CONTENT_LINE_HEIGHT;
            contentLabel.delegate = self;
            contentLabel.tag = messageViewType_floorLabel;
            [floorContainer addSubview:contentLabel];
        }
        contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
        NSString *orignalText = [self.item.socialMsg.replyComment.content trim];
        contentLabel.text = orignalText;
        contentLabel.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, containerHeight,
                                        CGRectGetWidth(screenRect) - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 3 - CELL_CONTENT_LEFT_MARGIN,
                                        self.item.replayCommentHeight);

        containerHeight += contentLabel.size.height + CELL_BOTTOM_MARGIN;
        //显示更多
        SNNameButton *expandBtn = (SNNameButton*)[self.contentView viewWithTag:messageViewType_expandFloorComment];
        if(!expandBtn)
        {
            expandBtn = [[SNNameButton alloc]initWithFrame:CGRectZero];
            expandBtn.tag = messageViewType_expandFloorComment;
            expandBtn.backgroundColor = [UIColor clearColor];
            expandBtn.exclusiveTouch = YES;
            [expandBtn setTitleColor:SNUICOLOR(kAuthorNameColor) forState:UIControlStateNormal];
            [expandBtn setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
            [expandBtn.titleLabel setFont:expandFont];
            [expandBtn addTarget:self action:@selector(expandFloorComment:indexPathRow:) forControlEvents:UIControlEventTouchUpInside];
            [floorContainer addSubview:expandBtn];
        }
        if (self.item.socialMsg.replyComment.needFolder && self.item.socialMsg.replyComment.isFolder)
        {
            CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:expandFont];
            expandBtn.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, containerHeight,
                                         stringSize.width, OPEN_COMMENT_BTN_HEIGHT);
            containerHeight += expandBtn.height + CELL_BOTTOM_MARGIN;
            expandBtn.hidden = NO;
        }
        else
        {
            expandBtn.hidden = YES;
        }
        
        floorContainer.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN,
                                          _originY,
                                          CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN,
                                          containerHeight);
        _originY += floorContainer.height + CELL_BOTTOM_MARGIN;
    }
}

//原文标题链接
- (void)addNewsTitle
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    UIFont *font = [UIFont systemFontOfSize:15];
    //newsTitle
    UIImageView *newsTitleButton = (UIImageView*)[self.contentView viewWithTag:messageViewType_newsTitleButton];
    UILabel *titleLabel = (UILabel*)[self.contentView viewWithTag:messageViewType_newsTitleLabel];
    if(!newsTitleButton)
    {
        newsTitleButton = [[UIImageView alloc]init];
        newsTitleButton.tag = messageViewType_newsTitleButton;
        newsTitleButton.exclusiveTouch = YES;
        UIImage* imageBg = [UIImage themeImageNamed:@"mycomment_newstitle_bg.png"];
        [newsTitleButton setImage:imageBg];
        [newsTitleButton setHighlightedImage:[UIImage themeImageNamed:@"singleCell.png"]];
        [self.contentView addSubview:newsTitleButton];
        
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [newsTitleButton addGestureRecognizer:tapGes];
        
        UIImage *imgArrow = [UIImage themeImageNamed:@"arrow.png"];
        UIImageView *ndicatorView = [[UIImageView alloc] initWithImage:imgArrow];
        ndicatorView.tag = messageViewType_dicatorView;
        ndicatorView.frame = CGRectMake(CGRectGetWidth(screenRect) - CELL_CONTENT_LEFT_MARGIN - CELL_RIGHT_MARGIN - NEWSTITLE_LEFT_MARGIN - imgArrow.size.width,
                                        (KFLOOR_COMMENT_NEWSTITLE_HEIGHT - imgArrow.size.height) / 2,
                                        imgArrow.size.width, imgArrow.size.height);
        [newsTitleButton addSubview:ndicatorView];
        
        titleLabel = [[UILabel alloc]init];
        titleLabel.tag = messageViewType_newsTitleLabel;
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel setTextColor:SNUICOLOR(kCommentNewsTitleColor)];
        [titleLabel setFont:font];
        [newsTitleButton addSubview:titleLabel];
    }
    
    if(self.item.socialMsg.shareObj.title && [self.item.socialMsg.shareObj.title length] > 0)
    {
        NSString* newsTitleStr = [NSString stringWithFormat:@"阅读圈: %@" ,self.item.socialMsg.shareObj.title];
        
        newsTitleButton.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN,
                                           _originY,
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
    else
    {
        newsTitleButton.hidden = YES;
    }
}

#pragma mark -
#pragma mark private action
- (void)clickNameBtn
{
    isMenuShow = NO;
    // hide menu  by jojo
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    if ([self.item.socialMsg.actComment.pid length] > 0)
    {
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : self.item.socialMsg.actComment.pid}] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)clikcFloorNickName
{
    isMenuShow = NO;
    // hide menu  by jojo
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    isMenuShow = NO;
    if ([self.item.socialMsg.replyComment.pid length] > 0) {
        TTURLAction* urlAction = [[[TTURLAction actionWithURLPath:@"tt://userCenter"] applyQuery:@{@"pid" : self.item.socialMsg.replyComment.pid}] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer*)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self];
    
    UIImageView *titleView = (UIImageView*)[self.contentView viewWithTag:messageViewType_newsTitleButton];
    BOOL isTapInTitleButton = CGRectContainsPoint(titleView.frame, tapPoint);
    
    if(isTapInTitleButton)
    {
        [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                            object:nil
                                                          userInfo:nil];
        isMenuShow = NO;
        if (!self.item.socialMsg.enableEnterProtocal) {
            [SNNotificationCenter showExclamation:@"该动态已被作者删除"];
        } else {
            [SNUtility openProtocolUrl:self.item.socialMsg.userActUrl];
        }
        return;
    }
    
    //菜单
    [self openMenu:tapGesture];
}

#pragma mark -
#pragma mark openComment
-(void)expandComment:(id)sender {
    if (self.delegateController && [self.delegateController respondsToSelector:@selector(expandSocialComment:)])
    {
        [self.delegateController expandSocialComment:self.item.socialMsg.actComment.commentId];
    }
}

-(void)expandFloorComment:(NSInteger)floorIndex indexPathRow:(int)rowIndex
{
    if (self.delegateController &&
        [self.delegateController respondsToSelector:@selector(expandSocialFloorComment:)])
    {
        [self.delegateController expandSocialFloorComment:self.item.socialMsg.replyComment.commentId];
    }
}

#pragma mark -
#pragma mark menu action
- (void)replyComment
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (self.item.socialMsg.actComment.actId.length) {
        [dic setObject:self.item.socialMsg.actComment.actId forKey:kCircleCommentKeyActId];
    }
    
    if (self.item.socialMsg.actComment.pid.length > 0)
        [dic setObject:self.item.socialMsg.actComment.pid forKey:kCircleCommentKeyFpid];
    
    if (self.item.socialMsg.actComment.nickName.length > 0) {
        [dic setObject:self.item.socialMsg.actComment.nickName forKey:kCircleCommentKeyFname];
    }
    if (self.item.socialMsg.actComment.commentId.length > 0) {
        [dic setObject:self.item.socialMsg.actComment.commentId forKey:kCircleCommentKeyCommentId];
    }
    
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES]
                           applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

-(void)copyComment
{
    isMenuShow = NO;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.item.socialMsg.actComment.content trim];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(replyComment) ||
		action == @selector(copyComment)) {
		return YES;
	}
	return NO;
}


-(void)openMenu:(UITapGestureRecognizer *)tapGesture {
    
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if (isMenuShow) {
        isMenuShow = NO;
        [contextMenu setMenuVisible:NO];
    } else {
        isMenuShow = YES;
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        float meunPointX = CELL_CONTENT_LEFT_MARGIN / 2;

        UIMenuItem *markMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyComment)];
        [menuItemsArray addObject:markMenuItem];
        
        UIMenuItem *recordMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyComment)];
        [menuItemsArray addObject:recordMenuItem];
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        CGPoint point = [tapGesture locationInView:self];
        [contextMenu setTargetRect:CGRectMake(meunPointX, point.y, self.frame.size.width, self.frame.size.height) inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    if ([link length] > 0) {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        
        [query setObject:link forKey:@"address"];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)updateTheme {
    SNHeadIconView *userHeadIcon = (SNHeadIconView*)[self.contentView viewWithTag:messageViewType_userHeadIcon];
    userHeadIcon.alpha = themeImageAlphaValue();
    
    SNNameButton *userInfoLabel = (SNNameButton *)[self.contentView viewWithTag:messageViewType_userNameLabel];
    [userInfoLabel setTitleColor:SNUICOLOR(kAuthorNameColor) forState:UIControlStateNormal];
    
    UILabel *dateLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_dataLabel];
    dateLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    
    UILabel *_cityLabel = (UILabel *)[self.contentView viewWithTag:messageViewType_cityLabel];
    _cityLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    
    SNLabel *contentLabel = (SNLabel *)[self.contentView viewWithTag:messageViewType_contentLabel];
    contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    contentLabel.alpha = themeImageAlphaValue();
    
    UIImageView *newsTitleButton = (UIImageView*)[self.contentView viewWithTag:messageViewType_newsTitleButton];
    UILabel *titleLabel = (UILabel*)[self.contentView viewWithTag:messageViewType_newsTitleLabel];
    [titleLabel setTextColor:SNUICOLOR(kCommentNewsTitleColor)];
    UIImage* imageBg = [UIImage themeImageNamed:@"mycomment_newstitle_bg.png"];
    [newsTitleButton setImage:imageBg];
    [newsTitleButton setHighlightedImage:[UIImage themeImageNamed:@"singleCell.png"]];
    UIImageView *ndicatorView = (UIImageView *)[newsTitleButton viewWithTag:messageViewType_dicatorView];
    ndicatorView.image = [UIImage themeImageNamed:@"arrow.png"];
    
    UIImageView *floorContainer = (UIImageView *)[self.contentView viewWithTag:messageViewType_floorContainer];
    floorContainer.alpha = themeImageAlphaValue();
    floorContainer.image = [UIImage imageNamed:@"comment_floor_bg.png"];
    
    SNLabel *contentFloorLabel = (SNLabel *)[self.contentView viewWithTag:messageViewType_floorLabel];
    contentFloorLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    
    UILabel *nameLabel = (UILabel *)[floorContainer viewWithTag:messageViewType_floorNameLabel];
    nameLabel.textColor = SNUICOLOR(kAuthorNameColor);
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self setNeedsDisplay];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
