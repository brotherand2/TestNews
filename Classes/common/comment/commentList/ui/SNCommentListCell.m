//
//  SNCommentListCell.m
//  sohunews
//
//  Created by 贾 磊 on 13-8-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentListCell.h"
#import "UIColor+ColorUtils.h"
#import "SNFloorCommentItem.h"
#import "SNHeadIconView.h"
#import "SNNameButton.h"
#import "SNLiveRoomConsts.h"
#import "SNUserUtility.h"
#import "SNDingView.h"
#import "SNDingManager.h"
#import "SNDBManager.h"
#import "SNLiveSoundView.h"
#import "SNWebImageView.h"
#import "UIImage+MultiFormat.h"
#import "SNBadgeView.h"
#import "SNCommentListManager.h"
#import "SNEmoticonManager.h"
#import "UIMenuController+Observe.h"

#import "SNThemeDefines.h"

#define CELL_DATE_LABEL_WIDTH               (80.0f)
#define CELL_DING_LABEL_WIDTH               (300/3.0f)
#define CELL_CONTENT_FONT                   ([SNUtility newsContentFontSize])
#define CEll_CONTENT_LINE_HEIGHT            ([SNUtility newsContentFontLineheight])

#define CONTENT_TOP_MARGIN                  (29/2)

#define kCityLabelTag                       (15)
#define kSeparatorLineTag                   (16)
#define kWeiboTypeIconSize                  (34 / 2)

#define kWeiboIconWidth                     14
#define kWeiboIconHeight                    14

#define kHeadIconAndNameGap                 (28 / 2)

#define kHeadIconOffset                     ((kAppScreenWidth == 320.0) ? 5: ((kAppScreenWidth == 375.0) ? 5 : 4))

@interface SNCommentListCell()<SNBadgeViewDelegate>
{
    BOOL   _isMenuShow;
    BOOL   _hadDing;
    
    float  _cellWidth;
    SNDingService     *_approveService;
    //NSMutableArray    *_soundViewArray;
    
    SNHeadIconView *_userHeadIcon;
    UIImageView        *_vipIcon;
    SNNameButton       *_userInfoButton;
    UIImageView        *_userWeiboIcon;
    UILabel            *_dateLabel;
    UILabel            *_cityLabel;
    UILabel            *_approveLabel;
    SNDingView         *_approveView;
    SNLabel            *_contentLabel;
    SNNameButton       *_expandBtn;
    SNLiveSoundView    *_soundView;
    SNWebImageView     *_picView;
    
    SNBadgeView *_badgeView;
}

@end

@implementation SNCommentListCell

@synthesize item = _item;
@synthesize delegate;
@synthesize tableTag;
@synthesize cellHeight;
@synthesize cellOffsetY;

+ (CGFloat)heightForCommentListCell:(SNFloorCommentItem *)commentItem
{
    return commentItem.cellHeight;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    //[[SNSoundManager sharedInstance] stopAll];
    
    self.delegate = nil;
    _badgeView.delegate = nil;
    _badgeView = nil;
    
    _approveService.delegate = nil;
}



#pragma mark- initSubViews
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.width = kAppScreenWidth;
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.identifier = reuseIdentifier;
        
        //监听夜间模式和字体改变
        [SNNotificationManager addObserver:self selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateFontTheme)
                                                     name:kUpdateCellFontChangeNotification object:nil];
//        [SNNotificationManager addObserver:self
//                                                 selector:@selector(removeDelegate)
//                                                     name:kNotificationSetCommentDelegate
//                                                   object:nil];
        
        [self initUserHeadIcon];
        [self initUserNameLabel];
        [self initDateLabel];
        [self initCityLabel];
        [self initApproveView];
        [self initContentView];
        //需要时再加载语音和图片评论
//        [self initSoundView];
//        [self initImageView];
        [self initFloorView];
        
        _badgeView = [[SNBadgeView alloc] init];
        _badgeView.delegate = self;
        [self.contentView addSubview:_badgeView];
    }
    return self;
}


- (void)initUserHeadIcon
{
    _userHeadIcon = [[SNHeadIconView alloc] initWithFrame:CGRectMake(CELL_RIGHT_MARGIN, CELL_TOP_MARGIN, HEAD_W, HEAD_W)];
    _userHeadIcon.alpha = themeImageAlphaValue();
    _userHeadIcon.layer.masksToBounds = YES;
    
    UIImage *image = [UIImage imageNamed:@"comment_headIcon_circle_mask_v5.png"];
    CALayer *layer = [CALayer layer];
//    layer.frame = CGRectMake(2.5, 2.5, 35, 35);
    layer.frame = _userHeadIcon.bounds;
    layer.contents = (id)[image CGImage];
    
    _userHeadIcon.layer.mask = layer;
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterUserCenter:)];
    [_userHeadIcon addGestureRecognizer:tapGes];
    
    [self.contentView addSubview:_userHeadIcon];
}

- (void)initUserNameLabel
{
    _userInfoButton = [[SNNameButton alloc]initWithFrame:CGRectZero];
    _userInfoButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_userInfoButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];

    _userInfoButton.backgroundColor = [UIColor clearColor];
    [_userInfoButton addTarget:self action:@selector(enterUserCenter:) forControlEvents:UIControlEventTouchUpInside];
    [_userInfoButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    
    [self.contentView addSubview:_userInfoButton];

}

- (void)initDateLabel
{
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.frame = CGRectZero;
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    _dateLabel.textColor = SNUICOLOR(kThemeText3Color);
    [_dateLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    
    [self.contentView addSubview:_dateLabel];
}

- (void)initCityLabel
{
    _cityLabel = [[UILabel alloc] init];
    
    _cityLabel.frame = CGRectZero;
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textAlignment = NSTextAlignmentLeft;
    _cityLabel.textColor = SNUICOLOR(kThemeText3Color);
    [_cityLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    [_cityLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [_cityLabel setNumberOfLines:1];
    
    [self.contentView addSubview:_cityLabel];
}

- (void)initApproveView
{
    _approveLabel = [[UILabel alloc] init];
    [_approveLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    _approveLabel.backgroundColor = [UIColor clearColor];
    _approveLabel.textAlignment = NSTextAlignmentRight;
    _approveLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    [self.contentView addSubview:_approveLabel];
}

- (void)initContentView
{
    UIFont *font = [UIFont systemFontOfSize:CELL_CONTENT_FONT];
    UIFont *expandFont = [UIFont systemFontOfSize:kThemeFontSizeC];
    
    _contentLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.font = font;
    _contentLabel.delegate = self;
    _contentLabel.lineHeight = CEll_CONTENT_LINE_HEIGHT;
    _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    
    [self.contentView addSubview:_contentLabel];
    
    //查看更多按钮
    _expandBtn = [[SNNameButton alloc]initWithFrame:CGRectZero];
    _expandBtn.backgroundColor = [UIColor clearColor];
    _expandBtn.exclusiveTouch = YES;
    [_expandBtn.titleLabel setFont:expandFont];
    [_expandBtn setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
    [_expandBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    [_expandBtn addTarget:self action:@selector(expandComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView  addSubview:_expandBtn];
}

- (void)initSoundView
{
    if (!_soundView)
    {
        _soundView = [[SNLiveSoundView alloc] initWithFrame:CGRectZero];
        [_soundView loadIfNeeded];
        [self.contentView addSubview:_soundView];
    }
}

- (void)initImageView
{
    if (!_picView)
    {
        NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
        UIImage *defaultImage = [UIImage imageNamed:defautlImgName];
        
        _picView = [[SNWebImageView alloc] initWithFrame:CGRectZero];
        _picView.showFade = NO;
        _picView.defaultImage = defaultImage;
        _picView.contentMode = UIViewContentModeScaleAspectFill;
        _picView.clipsToBounds = YES;
        _picView.layer.cornerRadius = 3;
        _picView.userInteractionEnabled = YES;
        BOOL bNightMode = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight];
        _picView.alpha = bNightMode ? 0.7 : 1;
        //图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView)];
        [_picView addGestureRecognizer:tap];
        
        [self.contentView addSubview:_picView];
    }
}

- (void)initFloorView
{
    _floorContainerView = [[UIImageView alloc] init];
    _floorContainerView.backgroundColor = [UIColor clearColor];
    _floorContainerView.userInteractionEnabled = YES;
//    NSString *bgName = @"comment_floor_bg.png";
    UIImage *bgImage = [UIImage imageNamed:@"bgtext_v5.png"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];

    _floorContainerView.image = bgImage;
    [self.contentView addSubview:_floorContainerView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawAuthor:context];
//    [self drawDate:context];
//    [self drawCity:context];
    //分隔符
//    [UIView drawCellSeperateLine:rect];
}

- (void)drawAuthor:(CGContextRef)context {
    //角色
	NSString *roleStr = nil;
    if (self.item.comment.roleType == SNNewsCommentRoleAuthor) {
        roleStr = @"作者";
    }
    if (roleStr) {
        CGFloat startX = _userHeadIcon.left + 10;
        CGFloat startY = kCommentRoleTypeTopMargin;
        UIFont *font = [UIFont systemFontOfSize:10];
        CGSize titleSize = [roleStr sizeWithFont:font
                               constrainedToSize:CGSizeMake(320.0f, 480.0f)
                                   lineBreakMode:NSLineBreakByCharWrapping];
        CGColorRef textColor = SNUICOLORREF(kThemeBlue1Color);
        CGContextSetFillColorWithColor(context, textColor);
        
        [roleStr textDrawAtPoint:CGPointMake(startX, startY)
                        forWidth:titleSize.width
                        withFont:font
                   lineBreakMode:NSLineBreakByTruncatingTail
                       textColor:SNUICOLOR(kThemeBlue1Color)];
    }
}

- (void)drawDate:(CGContextRef)context {
    NSString *dateStr = [NSDate relativelyDate:self.item.comment.ctime];
    if (dateStr.length > 0) {
        CGSize limitSize = [dateStr sizeWithFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]
                               constrainedToSize:CGSizeMake(320, 1000)];
        
        CGFloat startX = _userHeadIcon.right + CELL_RIGHT_MARGIN - 2;
        CGFloat startY = _userInfoButton.bottom + MarginTopBetweenUserLabelAndTimeDingLabel;
        
        CGColorRef textColor = SNUICOLORREF(kFloorCommentDateColor);
        CGContextSetFillColorWithColor(context, textColor);
        
        [dateStr drawAtPoint:CGPointMake(startX, startY)
                    forWidth:limitSize.width
                    withFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]
               lineBreakMode:NSLineBreakByTruncatingTail];
    }
}

- (void)drawCity:(CGContextRef)context {
    if (self.item.comment.city.length > 0) {
        NSString *dateStr = [NSDate relativelyDate:self.item.comment.ctime];
        CGSize timeSize = [dateStr sizeWithFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]
                              constrainedToSize:CGSizeMake(320, 1000)];
        CGSize citySize = [self.item.comment.city sizeWithFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]];
        
        CGFloat startX = _userHeadIcon.right + CELL_RIGHT_MARGIN - 2 + timeSize.width + 12;
        CGFloat startY = _userInfoButton.bottom + MarginTopBetweenUserLabelAndTimeDingLabel;
        
        CGColorRef textColor = SNUICOLORREF(kFloorCommentDateColor);
        CGContextSetFillColorWithColor(context, textColor);
        
        [self.item.comment.city drawAtPoint:CGPointMake(startX, startY)
                                   forWidth:citySize.width
                                   withFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]
                              lineBreakMode:NSLineBreakByTruncatingTail];
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

#pragma mark - setSubViews
- (void)setObject:(SNFloorCommentItem *)commentItem
{
    _isMenuShow = NO;
    _cellWidth = [UIScreen mainScreen].bounds.size.width;
    _originY = 0;
    
    self.item = commentItem;
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openMenu:)];
    menuTap.delegate = self;
    [self addGestureRecognizer:menuTap];
    
    //按subView顺序布局
    [self setUserNameIcon];
    [self setVipIcon];
    [self setUserInfoLabel];
    [self setDateLabel];
    [self setCityLabel];
    [self setApproveView];
    [self setContentView];
    [self setSoundView];
    [self setImageView];
    [self setFloorView];
    
    if (self.item.comment.badgeListArray && [self.item.comment.badgeListArray count])
    {
        [_badgeView reloadBadges:self.item.comment.badgeListArray];
        _badgeView.hidden = NO;
    }
    else
    {
        _badgeView.hidden = YES;
    }
    [self setNeedsDisplay];
}

- (void)setUserNameIcon
{
    //是否拥有通行证
    if (_userHeadIcon)
    {
//        _userHeadIcon.frame = CGRectMake(CELL_RIGHT_MARGIN, CELL_TOP_MARGIN, HEAD_W, HEAD_W);
        _originY = _userHeadIcon.bottom;
        [_userHeadIcon setIconUrl:self.item.comment.authorimg passport:self.item.comment.passport gender:0];
    }
}

- (void)setVipIcon {
    if (!_vipIcon) {
        UIImage *vipImage = [UIImage themeImageNamed:@"icotext_v_v5.png"];
        _vipIcon = [[UIImageView alloc] initWithImage:vipImage];
        _vipIcon.bottom = _userHeadIcon.bottom;
        _vipIcon.right = _userHeadIcon.right;
        
        [self addSubview:_vipIcon];
    }
    if (self.item.comment.mediaType == SNCommentMediaTypeVip) {
        _vipIcon.hidden = NO;
    }
    else {
        _vipIcon.hidden = YES;
    }
    
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        _vipIcon.alpha = 0.5;
    }
    else {
        _vipIcon.alpha = 1.0;
    }
}

- (void)setUserInfoLabel
{
    //根据实际长度计算实际区域
    if (_userInfoButton && [self.item.comment.author length] > 0)
    {
        [_userInfoButton setTitle:self.item.comment.author forState:UIControlStateNormal];
        CGSize limitSize = [_userInfoButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
        _userInfoButton.frame = CGRectMake(_userHeadIcon.right + kHeadIconAndNameGap, CELL_TOP_MARGIN + 1,
                                           limitSize.width, kThemeFontSizeC + 2);
        _userInfoButton.top = _userHeadIcon.top + kCommentUserInfoTopBottomMargin - kHeadIconOffset;
//        _userInfoButton.backgroundColor = [UIColor redColor];
    }
}

//时间
- (void)setDateLabel
{
    if (self.item.comment.ctime && [self.item.comment.ctime length] > 0)
    {
        _dateLabel.text = [NSDate relativelyDate:self.item.comment.ctime];
        _dateLabel.accessibilityLabel = [NSDate accessoryRelativelyDate:self.item.comment.ctime];
        _dateLabel.hidden = NO;
        
        CGSize limitSize = [_dateLabel.text sizeWithFont:_dateLabel.font constrainedToSize:CGSizeMake(320, 1000)];
        _dateLabel.frame = CGRectMake(_userHeadIcon.right + kHeadIconAndNameGap,
                                      _userInfoButton.bottom + MarginTopBetweenUserLabelAndTimeDingLabel,
                                     limitSize.width, kThemeFontSizeB + 2);
        _dateLabel.bottom = _userHeadIcon.bottom - kCommentUserInfoTopBottomMargin + kHeadIconOffset;
//        _dateLabel.backgroundColor = [UIColor redColor];
    }
    else
    {
        _dateLabel.hidden = YES;
    }
}

//城市
- (void)setCityLabel
{
    if (self.item.comment.city && [self.item.comment.city length] > 0)
    {
        _cityLabel.text = self.item.comment.city;
        _cityLabel.frame = CGRectMake(_dateLabel.right + 12,
                                      _userInfoButton.bottom + MarginTopBetweenUserLabelAndTimeDingLabel,
                                      CELL_CITY_LABEL_WIDTH, kThemeFontSizeB + 2);
        _cityLabel.bottom = _userHeadIcon.bottom - kCommentUserInfoTopBottomMargin + kHeadIconOffset;
        _cityLabel.hidden = NO;
    }
    else
    {
        _cityLabel.hidden = YES;
    }
}

//顶图标
- (void)setApproveView
{
    if (self.item.comment.digNum && [self.item.comment.digNum length] > 0)
    {
        _approveLabel.text = [NSString stringWithFormat:@"%@",self.item.comment.digNum];
        if ([self.item.comment.digNum integerValue] == 0) {
            _approveLabel.hidden = YES;
        }
        else {
            _approveLabel.hidden = NO;
        }
        
        if (!self.item.comment.hadDing)
        {
            if ([[SNDingManager sharedInstance] isDingForCommentId:self.item.comment.commentId])
            {
                //lijian 2015.01.16 这里的+1重复了，导致有些评论一次加了2.不知道有没有什么特殊的需求，先去掉了。
                //NSString *dingNumString = [NSString stringWithFormat:@"%d",[self.item.comment.digNum intValue] + 1];
                NSString *dingNumString = [NSString stringWithFormat:@"%d",[self.item.comment.digNum intValue]];
                _approveLabel.text = [NSString stringWithFormat:@"%@",dingNumString];
                _approveLabel.textColor = SNUICOLOR(kThemeBlue1Color);
            }
            else {
                _approveLabel.textColor = SNUICOLOR(kThemeText3Color);
            }
        }
        CGSize dingStringSize = [_approveLabel.text sizeWithFont:[UIFont systemFontOfSize:CELL_DATE_CITY_DING_LABEL_HEIGHT-2]];
        if (dingStringSize.width >= CELL_DING_LABEL_WIDTH)
        {
            _approveLabel.frame = CGRectMake(_cellWidth - CELL_RIGHT_MARGIN - dingStringSize.width - 25,
                                             _userInfoButton.top,
                                             dingStringSize.width,
                                             CELL_DATE_CITY_DING_LABEL_HEIGHT);
        }
        else
        {
            _approveLabel.frame = CGRectMake(_cellWidth - CELL_RIGHT_MARGIN - CELL_DING_LABEL_WIDTH - 25,
                                             _userInfoButton.top,
                                             CELL_DING_LABEL_WIDTH,
                                             CELL_DATE_CITY_DING_LABEL_HEIGHT);
        }
        _approveLabel.bottom = _userInfoButton.bottom + kHeadIconOffset;
    }
    else
    {
        _approveLabel.hidden = YES;
    }
    
    if (!_approveView)
    {
        UIImage *normalImage = [UIImage themeImageNamed:@"ding_normal.png"];
        _approveView = [[SNDingView alloc] initWithFrame:CGRectMake(_cellWidth - CELL_RIGHT_MARGIN - 60,
                                                                    _userInfoButton.top - 5 + kHeadIconOffset,
                                                                    normalImage.size.width, normalImage.size.height)];
        _approveView.right = self.width - CELL_RIGHT_MARGIN + 6;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginApproveAction)];
        [_approveView addGestureRecognizer:tap];
//        _approveView.backgroundColor = [UIColor redColor];
        
        [self.contentView addSubview:_approveView];
    }
    //每次重新设置顶图标
    self.item.hasDing = [[SNDingManager sharedInstance] isDingForCommentId:self.item.comment.commentId];
    _approveView.dingImageView.highlighted = self.item.hasDing;
    _hadDing = self.item.hasDing;
}

//正文
- (void)setContentView
{
    if ([self.item.comment.content length] > 0)
    {
        _originY += MarginTopBetweenUserLabelAndTimeDingLabel;
        _contentLabel.text = [self.item.comment.content trim];

        UIFont *expandFont = [UIFont systemFontOfSize:CELL_USER_INFO_HEIGHT];
        _contentLabel.frame = CGRectMake(_userInfoButton.left, _originY + kHeadIconOffset,
                                         _cellWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 5, self.item.cellContentHeight);
        _contentLabel.hidden = NO;
        _contentLabel.alpha = themeImageAlphaValue();
//        NSArray *emoticonRanges = [self.item.comment.content itemRangesWithPattern:commentEmoticonPattern];
//        NSDictionary *imageRangeDic = [[SNEmoticonManager sharedManager] parseEmoticonImageFromText:self.item.comment.content];
//        
//        if ([imageRangeDic count] > 0 ) {
//            [_contentLabel addEmoticons:imageRangeDic];
//        }
//        else {
//            [_contentLabel removeAllEmoticonInfo];
//        }
        
        if (self.item.isMoreDesignLine && !self.item.comment.isCommentOpen)
        {
            _originY = _contentLabel.bottom;
            CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:expandFont];
            _expandBtn.frame = CGRectMake(_contentLabel.left, _originY + FLOOR_TOP_MARGIN,
                                         stringSize.width, 14);
            _expandBtn.hidden = NO;
            _originY = _expandBtn.bottom;
        }
        else
        {
            _originY = _contentLabel.bottom;
            _expandBtn.hidden = YES;
        }
    }
    else
    {
        _contentLabel.hidden = YES;
        _expandBtn.hidden = YES;
    }
}

- (void)setSoundView
{
    if ([self.item.comment hasAudio])
    {
        [self initSoundView];
        _soundView.frame = CGRectMake(_userInfoButton.left, _originY + SOUNDVIEW_SPACE, SOUNDVIEW_WIDTH, SOUNDVIEW_HEIGHT);
        _soundView.duration = self.item.comment.commentAudLen;
        _soundView.commentID = self.item.comment.commentId;
        _soundView.url = self.item.comment.commentAudUrl;
        _originY = _soundView.bottom;
        _soundView.hidden = NO; 
    }
    else
    {
        _soundView.hidden = YES;
    }
}

- (void)setImageView
{
    //如果服务器返回缩略图，显示，否则不显示
    if(self.item.comment.commentImageSmall && [self.item.comment.commentImageSmall length] > 0)
    {
        [self initImageView];
        //是本地url加载本地图片
        SNDebugLog(@"%@", self.item.comment.commentImageSmall);
        NSData* imageData = [[TTURLCache sharedCache] dataForURL:self.item.comment.commentImageSmall];
        if (_picView.urlPath)
        {
            [_picView unsetImage];
        }
        if(imageData)
        {
            _picView.urlPath = self.item.comment.commentImageSmall;
            
            UIImage *sdImage = [UIImage sd_imageWithData:imageData];
            if (!sdImage)
            {
                _picView.image = [UIImage imageWithData:imageData];
            }
            else
            {
                _picView.image = sdImage;
            }
        }
        else
        {
            if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
            {
                _picView.urlPath = self.item.comment.commentImageSmall;
            }
            else
            {
                _picView.urlPath = nil;
                NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
                UIImage *defaultImage = [UIImage imageNamed:defautlImgName];
                _picView.defaultImage = defaultImage;
            }
        }
        _picView.hidden = NO;
        _picView.frame = CGRectMake(_userInfoButton.left, _originY + CELL_BOTTOM_MARGIN, kPicViewWidth, kPicViewHeight);
        _originY = _picView.bottom;
    }
    else
    {
        _picView.hidden = YES;
        _picView.urlPath = nil;
    }
}

- (void)setFloorView
{
    if (_floorContainerView)
    {
        [_floorContainerView removeAllSubviews];
    }
    
    CGFloat h = 0;
    if (!self.item.expand
        && self.item.comment.commentId
        && self.item.comment.floors.count > kExpandLimit)
    {
        //一楼
        SNNewsComment *c1 = [self.item.comment.floors objectAtIndex:0];
        c1.floorNum = 1;
        SNFloorView *floor = [[SNFloorView alloc] init];
        floor.subFloorIndex = 0;
        floor.commentId = self.item.comment.commentId;
        floor.comment = c1;
        floor.newsId    = self.item.newsId;
        floor.gid       = self.item.gid;
        floor.showSeparator = NO;
        floor.cell = self;
        floor.origin = CGPointMake(0, h);
        h += floor.size.height;
        [_floorContainerView addSubview:floor];
        
        //展开按钮
        UIButton* expandBtn = [self addExpandButton:@"点击展开全部评论"];
        expandBtn.frame = CGRectMake(1, h,
                                     _cellWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN - 2, EXPAND_BTN_HEIGHT);
        expandBtn.tag = commentViewType_expandFloor;
        
        [_floorContainerView addSubview:expandBtn];
        h += EXPAND_BTN_HEIGHT;
        
        //最后两楼
        SNNewsComment *c2 = [self.item.comment.floors objectAtIndex:self.item.comment.floors.count-2];
        c2.floorNum = (int)self.item.comment.floors.count-1;
        SNFloorView *floor2 = [[SNFloorView alloc] init];
        floor2.subFloorIndex = (int)self.item.comment.floors.count - 2;
        floor2.commentId = self.item.comment.commentId;
        floor2.comment = c2;
        floor2.newsId    = self.item.newsId;
        floor2.gid       = self.item.gid;
        floor2.showSeparator = YES;
        floor2.cell = self;
        floor2.origin = CGPointMake(0, h);
        h += floor2.size.height;
        [_floorContainerView addSubview:floor2];
        [floor2 setNeedsDisplay];
        
        SNNewsComment *c3 = [self.item.comment.floors objectAtIndex:self.item.comment.floors.count-1];
        c3.floorNum = (int)self.item.comment.floors.count;
        SNFloorView *floor3 = [[SNFloorView alloc] init];
        floor3.subFloorIndex = (int)self.item.comment.floors.count-1;
        floor3.commentId = self.item.comment.commentId;
        floor3.comment = c3;
        floor3.newsId  = self.item.newsId;
        floor3.gid     = self.item.gid;
        floor3.cell = self;
        floor3.showSeparator = NO;
        floor3.origin = CGPointMake(0, h);
        h += floor3.size.height;
        [_floorContainerView addSubview:floor3];
        [floor3 setNeedsDisplay];
    }
    else
    {
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
    }
    
    _floorContainerView.frame = CGRectMake(CELL_CONTENT_LEFT_MARGIN + CELL_RIGHT_MARGIN - 10,
                                           _originY + CELL_BOTTOM_MARGIN,
                                           _cellWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10,
                                           h);
    _originY = _floorContainerView.bottom + 2;
}

#pragma mark- SNBadgeView
- (void)badgeViewWidth:(float)width height:(float)height
{
    _badgeView.frame = CGRectMake(_userInfoButton.right + 5.f, _userInfoButton.top, width, height);
    _badgeView.center = CGPointMake(_badgeView.centerX, _userInfoButton.centerY);
}

#pragma mark- subViewsAction
- (void)enterUserCenter:(id)sender
{
    [[SNSoundManager sharedInstance] stopAmr];
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    _isMenuShow = NO;
    
    if ([contextMenu isMenuVisible])
        [contextMenu setMenuVisible:NO];
    
    if (self.item.comment.orgHomePage.length > 0) {
        [SNUtility openProtocolUrl:self.item.comment.orgHomePage];
    } else {
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        if (self.item.newsId.length > 0) {
            [referInfo setObject:self.item.newsId forKey:kReferValue];
            [referInfo setObject:@"Newsid" forKey:kReferType];
        }
        if (self.item.gid.length > 0) {
            [referInfo setObject:self.item.gid forKey:kReferValue];
            [referInfo setObject:@"gid" forKey:kReferType];
        }
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Article_CommentUser] forKey:kRefer];
        
        BOOL gotoSpace = [SNUserUtility openUserWithPassport:self.item.comment.passport
                                                  spaceLink:self.item.comment.spaceLink
                                                    linkStyle:self.item.comment.linkStyle pid:self.item.comment.pid
                                                         push:@"0" refer:referInfo];
        if(!gotoSpace)
        {
            SNDebugLog(@"%@", @"gotoSpace");
        }
    }
}

- (void)beginApproveAction
{
    if (!_hadDing)
    {
        if (!_approveService)
        {
            _approveService = [[SNDingService alloc] init];
            _approveService.delegate = self;
        }
        if (self.item.comment.isCache)
        {
            [_approveService asyncDingComment:nil topicId:self.item.comment.topicId];
        }
        else
        {
            [_approveService asyncDingComment:self.item.comment.commentId topicId:self.item.comment.topicId];
        }
    }
}

- (void)clickImageView
{
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible])
        [contextMenu setMenuVisible:NO];
    
    if (_picView.urlPath == nil)
    {
        // 加载失败后，点击加载小图
        if (self.item.comment.commentImageSmall &&
            self.item.comment.commentImageSmall.length > 0)
        {
            //是本地url加载本地图片
            if([[TTURLCache sharedCache] hasDataForURL:self.item.comment.commentImageSmall] &&
               _picView.urlPath)
            {
                
                NSString *sourceUrl = self.item.comment.commentImageBig;
                if (sourceUrl && sourceUrl.length > 0)
                {
//                    [self.item.floorsCommentController performSelector:@selector(showImageWithUrl:) withObject:sourceUrl];
                }
            }
            else
            {
                _picView.urlPath = self.item.comment.commentImageSmall;
                [_picView loadUrlPath:self.item.comment.commentImageSmall];
            }
        }
    }
    else
    {
        // 没有正常加载，点击重新加载
        if (!_picView.isLoading && !_picView.isLoaded)
        {
            [_picView loadUrlPath:self.item.comment.commentImageSmall];
        }
        else if (_picView.isLoaded)
        {
            // 显示大图
            if ([self.delegate respondsToSelector:@selector(showImageWithUrl:)])
            {
                NSString *sourceUrl = self.item.comment.commentImageBig;
                if (sourceUrl && sourceUrl.length > 0)
                {
                    [self.delegate performSelector:@selector(showImageWithUrl:) withObject:sourceUrl];
                }
            }
        }
    }
}

- (void)expandComment:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(expandComment:)])
    {
        if (!self.item.comment.commentId)
        {
            self.item.comment.isCommentOpen = YES;
        }
        [self.delegate expandComment:self.item.comment.commentId];
    }
}

- (void)expandFloor
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openFloor:)])
    { 
        [self.delegate openFloor:self.item.comment.commentId];
    }
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible])
        [contextMenu setMenuVisible:NO];
    
    if ([link length] > 0)
    {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        
        [query setObject:link forKey:@"address"];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

#pragma mark - openMenuAction
-(void)deleteComment
{
    _isMenuShow = NO;
    if([self.delegate respondsToSelector:@selector(deleteComment:)])
    {
        [self.delegate deleteComment:self.item.comment];
    }
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Finish clear up",@"") toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)copyComment
{
    _isMenuShow = NO;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.item.comment.content trim];
}

- (void)shareComment {
    _isMenuShow = NO;
//    NSString *shareComment = [self.item.comment.content trim];
//    SNDebugLog(@"shareComment = %@", shareComment);
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(shareComment:)])
    {
        [self.delegate shareComment:self.item.comment];
    }
}

- (void)replyComment {
    
    _isMenuShow = NO;
    [self resetMenuItems];
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyComment:)]) {
        
        [self.delegate replyComment:self.item.comment];
    }
    else if (self.replyBlock) {
        self.replyBlock(self.item.comment);
    }
}
- (void)resetMenuItems
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO];
    [menuController setMenuItems:nil];
    [menuController update];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == NSSelectorFromString(@"dingComment")  ||
		action == NSSelectorFromString(@"replyComment") ||
		action == NSSelectorFromString(@"copyComment")  ||
        action == NSSelectorFromString(@"shareComment") ||
        action == NSSelectorFromString(@"deleteComment")) {
		return YES;
	}
	return NO;
}

- (void)openMenu:(UITapGestureRecognizer *)tapGesture
{
    if (_item.comment.status == SNCommentStatusDelete)
        return;
    
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    [contextMenu setMenuControllerKeyWithString:@"commentCell"];
    
    if (_isMenuShow)
    {
        _isMenuShow = NO;
        [contextMenu setMenuVisible:NO];
        [SNNotificationManager postNotificationName:NotificationCommentListMenu
                                                            object:nil
                                                          userInfo:nil];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(setCommentMenu:)])
//        {
//            [self.delegate setCommentMenu:NO];
//        }
    }
    else
    {
        [SNNotificationManager postNotificationName:NotificationCommentListMenu
                                                            object:@(YES)
                                                          userInfo:nil];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(setCommentMenu:)])
//        {
//            [self.delegate setCommentMenu:YES];
//        }
        _isMenuShow = YES;
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        float meunPointX = CELL_CONTENT_LEFT_MARGIN / 2;

        UIMenuItem *markMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyComment)];
        [menuItemsArray addObject:markMenuItem];
        
        if (_item.isAuthor) {
            UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteComment)];
            [menuItemsArray addObject:deleteMenuItem];
        }        
        
        if (_item.comment.content.length > 0) {
            UIMenuItem *recordMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyComment)];
            [menuItemsArray addObject:recordMenuItem];
        }
        
        UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareComment)];
        [menuItemsArray addObject:shareMenuItem];
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        
        CGPoint point = [tapGesture locationInView:self];
        [contextMenu setTargetRect:CGRectMake(meunPointX, point.y, self.frame.size.width, self.frame.size.height) inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
        
    }
}

#pragma mark- privateMethod
-(UIButton*)addExpandButton:(NSString*)buttonTitle
{
    //展开按钮
//    NSString *imageName = @"comment_expand_btn.png";
//    UIImage *expandImage = [UIImage imageNamed:imageName];
    UIButton *expandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expandBtn.exclusiveTouch = YES;
    [expandBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [expandBtn.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [expandBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [expandBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];

    CGSize dingStringSize = [buttonTitle sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    
    [expandBtn addTarget:self action:@selector(expandFloor) forControlEvents:UIControlEventTouchUpInside];
    [expandBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 7,
                                                   5,
                                                   _cellWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN - dingStringSize.width - 13)];
    
    UIView *sepView = [[UIView alloc] init];
    sepView.frame = CGRectMake(0, 0, _cellWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN - 2, .5);
    sepView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    sepView.tag = commentViewType_expandComment;
    
    [expandBtn addSubview:sepView];
    
    return expandBtn;
}


-(void)changeCommentDigNumTo:(NSString *)digNum commentId:(NSString *)cid
{
    if ([digNum length] <= 0)
    {
        return;
    }
    
    if (!cid)
    {
        [self changeCellDingNum:digNum];
    }
    else //if (self.delegate && [self.delegate respondsToSelector:@selector(changeAllSameCommentDingNum:commentId:tag:)])
    {
        [self changeAllVisibleDingNum:digNum cid:cid];
    }
}

- (void)changeCellDingNum:(NSString *)digNum
{
    self.item.comment.digNum  = digNum;
    self.item.comment.hadDing = YES;
    _approveLabel.hidden = NO;
    if (_approveLabel) {
        _approveLabel.text = [NSString stringWithFormat:@"%@", digNum];
        _approveLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    }
    
    if (_approveView)
        [_approveView beginAnimation];
}

-(void)changeAllVisibleDingNum:(NSString *)digNum cid:(NSString *)cid
{
    if ([self.item.comment.commentId isEqualToString:cid])
    {
        [self changeCellDingNum:digNum];
    }
    
    for (SNNewsComment *comment in self.item.comment.floors)
    {
        if ([comment.commentId isEqualToString:cid])
        {
            comment.digNum = digNum;
            comment.hadDing = YES;
            break;
        }
    }
}

#pragma mark - SNDingServiceDelegate
-(void)didFinishDingComment {
    _hadDing = YES;
    self.item.hasDing = YES;
    
    int digNum = [self.item.comment.digNum intValue];
    self.dingNum = [NSString stringWithFormat:@"%d",digNum+1];
    self.item.comment.digNum = self.dingNum;
    [self changeCommentDigNumTo:self.dingNum commentId:self.item.comment.commentId];
    
    //记录顶过的评论ID
    [[SNDingManager sharedInstance] addCommentId:self.item.comment.commentId];
    
    if (self.item.comment.commentId)
    {
        NSString *newsType = self.item.newsId ? kNewsId : kGid;
        [[SNDBManager currentDataBase] updateCommentDigNumByNewsId:self.item.newsId andCommentId:self.item.comment.commentId andNewsType:newsType];
    }
    else
    {
        [[SNDBManager currentDataBase] updateMyCommentDigNumById:self.item.comment.cid];
    }
}

#pragma mark - SNFloorViewDelegate
- (void)floorViewExpandFloorComment:(int)floorIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(expandFloorComment:indexPathRow:)]) {
        [self.delegate expandFloorComment:floorIndex indexPathRow:self.item.index];
    }
}
- (void)floorViewReplyFloorComment:(SNNewsComment *)comment
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyFloorComment:)]) {
        [self.delegate replyFloorComment:comment];
    }
}

- (void)floorViewShareFloorComment:(SNNewsComment *)comment
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(shareComment:)]) {
        [self.delegate shareComment:comment];
    }
}
- (void)floorViewDeleteFloorCommentId:(NSString *)commentId floorIndex:(int)floorIndex
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(deleteFloorCommentId:tag:row:floorIndex:)]) {
        [self.delegate deleteFloorCommentId:commentId row:self.item.index floorIndex:floorIndex];
    }
}
- (void)floorViewShowImageWithUrl:(NSString *)url
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(showImageWithUrl:)]) {
        [self.delegate showImageWithUrl:url];
    }
}

- (void)setCommentMenu:(BOOL)isCommentMenu
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(setCommentMenu:)]) {
        [self.delegate setCommentMenu:isCommentMenu];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark updateTheme
- (void)updateTheme
{
    _dateLabel.textColor = SNUICOLOR(kThemeText3Color);
    _cityLabel.textColor = SNUICOLOR(kThemeText3Color);
    _approveLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    
    _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    _contentLabel.alpha = themeImageAlphaValue();
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        _vipIcon.alpha = 0.5;
    }
    else {
        _vipIcon.alpha = 1.0;
    }
    [_expandBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    [_userInfoButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    
    [_approveView updateTheme];
    [_badgeView updateTheme];
    
    _userHeadIcon.alpha = themeImageAlphaValue();
    _picView.alpha = themeImageAlphaValue();

    [_userHeadIcon updateTheme];
    [_soundView updateTheme];
    
    UIImage *bgImage = [UIImage imageNamed:@"bgtext_v5.png"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];

    _floorContainerView.image = bgImage;
    
    UIButton *expandBtn = (UIButton *)[_floorContainerView viewWithTag:commentViewType_expandFloor];
//    UIImage *expandImage = [UIImage imageNamed:@"comment_expand_btn.png"];
    [expandBtn setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
//    [expandBtn setBackgroundImage:expandImage forState:UIControlStateNormal];
//    [expandBtn setBackgroundImage:expandImage forState:UIControlStateHighlighted];
//    [expandBtn setBackgroundImage:expandImage forState:UIControlStateSelected];
    
    UIView *expandBtaSepView = [expandBtn viewWithTag:commentViewType_expandComment];
    expandBtaSepView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    
    _approveView.dingImageView.highlightedImage = [UIImage imageNamed:@"icotext_like_press_v5.png"];
    _approveView.dingImageView.image = [UIImage imageNamed:@"icotext_like_v5.png"];
    
    [self setNeedsDisplay];
}

- (void)updateFontTheme
{
    UIFont *font = [UIFont systemFontOfSize:CELL_CONTENT_FONT];
    _contentLabel.font = font;
    _contentLabel.lineHeight = CEll_CONTENT_LINE_HEIGHT;
}

- (void)removeDelegate
{
    self.delegate = nil;
}

@end
