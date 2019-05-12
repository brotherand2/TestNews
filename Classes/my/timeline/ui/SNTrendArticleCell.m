//
//  SNTrendCommentCell.m
//  sohunews
//
//  Created by jialei on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendArticleCell.h"
#import "UIImage+MultiFormat.h"
#import "SNHeadIconView.h"
#import "SNNewsShareManager.h"

@interface SNTrendArticleCell() {
}

@property (nonatomic, strong)SNActionMenuController *actionMenuController;
@property (nonatomic, strong)SNNewsShareManager *shareManager;
@property (nonatomic, strong)NSString *shareContent;

@end

@implementation SNTrendArticleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
     //(tap);
    
    [SNNotificationManager addObserver:self
                                             selector:@selector(handleHideNotification:)
                                                 name:kUIMenuControllerHideMenuNotification
                                               object:nil];
    
    return self;
}

- (void)dealloc
{
     //(_actionMenuController);
     //(_shareContent);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawTimelineOriginContent
{
}

//用户ugc显示
- (void)setContent
{
    [super setContent];
    [self setContentImage];
    [self setContentSound];
}

//动态原文
- (void)setOriginTitleAndFrom
{
    [super setOriginTitleAndFrom];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    
    //title
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    _originTitleLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                         kTLOriginalContentTitleTopMargin + startY,
                                         textWidth,
                                         self.timelineTrendObj.originContentObj.titleHeight);
    _originTitleLabel.text = self.timelineTrendObj.originContentObj.title;
    _originTitleLabel.font = titleFont;
    if (_originTitleLabel.frame.size.height == 0) {
        _originTitleLabel.text = nil;
    }
    
    //from
    startY = _originTitleLabel.bottom + kTLOriginalContentVerticalMargin;
    UIFont *fromFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    _originFromLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                        startY,
                                        textWidth,
                                        self.timelineTrendObj.originContentObj.fromHeight);
    _originFromLabel.text = self.timelineTrendObj.originContentObj.fromDisplayString;
    if (_originFromLabel.frame.size.height == 0) {
        _originFromLabel.text = nil;
    }
    _originFromLabel.font = fromFont;
}

- (void)setOriginView
{
    [super setOriginView];
    
    if (!_abstractLabel) {
        _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectZero];
        _abstractLabel.delegate = self;
        _abstractLabel.font = [UIFont systemFontOfSize:kTLOriginalContentAbstractFontSize];
        _abstractLabel.lineHeight = kTLOriginalContentAbstractLineHeight;
        _abstractLabel.textColor = SNUICOLOR(kRollingNewsCellDetailTextUnreadColor);
        _abstractLabel.tapEnable = YES;
        [self addSubview:_abstractLabel];
    }
    
    if (self.timelineTrendObj.originContentObj.abstract.length > 0) {
        _abstractLabel.hidden = NO;
        CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
        _abstractLabel.top = _originFromLabel.bottom + kTLOriginalContentTextSideMargin;
        _abstractLabel.left = CGRectGetMinX(_originalContentRect) + kTLOriginalContentTextSideMargin;
        _abstractLabel.width = textWidth;
        _abstractLabel.height = self.timelineTrendObj.originContentObj.abstractHeight;
        _abstractLabel.text = self.timelineTrendObj.originContentObj.abstract;
    }
    else {
        _abstractLabel.hidden = YES;
    }
}

- (void)setOriginalImageView
{
    CGRect imageRect = CGRectMake(CGRectGetMinX(_originalContentRect) + kTLOriginalContentImageSideMargin,
                                  CGRectGetMaxY(_originalContentRect) - kTLOriginalContentImageBottomMargin - self.timelineTrendObj.originContentObj.picDisplaySize.height,
                                  self.timelineTrendObj.originContentObj.picDisplaySize.width,
                                  self.timelineTrendObj.originContentObj.picDisplaySize.height);
    if (!_originalImageView) {
        _originalImageView = [[SNWebImageView alloc] init];
        _originalImageView.clipsToBounds = YES;
        [self addSubview:_originalImageView];
        _originalImageView.userInteractionEnabled = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        tap.delegate = self;
        [_originalImageView addGestureRecognizer:tap];
         //(tap);
#pragma clang diagnostic pop

    }
    
    if ([_originalImageView.urlPath length] > 0) {
        _originalImageView.urlPath = nil;
    }
    [_originalImageView setFrame:imageRect];
    _originalImageView.defaultImage = _originDefaultImage;
    _originalImageView.hidden = (CGRectIsEmpty(imageRect) || !self.timelineTrendObj.originContentObj.picUrl);
    _originalImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.7 : 1;
    [self setOriginalImageUrl:self.timelineTrendObj.originContentObj.picUrl isRelyNetwork:YES];
    
    if (!_videoIconView) {
        UIImage *videoImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        _videoIconView = [[UIImageView alloc] initWithImage:videoImage];
        _videoIconView.size = CGSizeMake(videoImage.size.width, videoImage.size.height);
        [self addSubview:_videoIconView];
    }
    
    _videoIconView.alpha = _originalImageView.alpha;
    
    if (!_originalImageView.isHidden) {
        _videoIconView.right = CGRectGetMaxX(_originalImageView.frame) - 2;
        _videoIconView.bottom = CGRectGetMaxY(_originalImageView.frame) - 2;
        _videoIconView.hidden = !self.timelineTrendObj.originContentObj.hasTv;
    }
    else {
        _videoIconView.hidden = YES;
    }
}


//用户评论图
- (void)setContentImage
{
    NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
    UIImage *defaultImage = [UIImage imageNamed:defautlImgName];
    
    if (!_picView) {
        _picView = [[SNWebImageView alloc] initWithFrame:CGRectMake(_contentLabel.left,
                                                                    _viewOffsetY + kTLShareInfoViewNameContentMargin,
                                                                    kPicViewWidth,
                                                                    kPicViewHeight)];
        _picView.showFade = NO;
        _picView.clipsToBounds = YES;
        _picView.layer.cornerRadius = 3;
        _picView.userInteractionEnabled = YES;
        [self addSubview:_picView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        //图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView)];
#pragma clang diagnostic pop

        tap.delegate = self;
        [_picView addGestureRecognizer:tap];
    }
    
    // set image data
    if (self.timelineTrendObj.ugcSmallImageUrl.length > 0) {
        _picView.defaultImage = defaultImage;
        _picView.top = _viewOffsetY + kTLShareInfoViewNameContentMargin;
        _picView.hidden = NO;
        _viewOffsetY = _picView.bottom;
        _picView.urlPath = self.timelineTrendObj.ugcSmallImageUrl;
        BOOL bNightMode = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight];
        _picView.alpha = bNightMode ? 0.7 : 1;
    }
    else {
        _picView.hidden = YES;
    }
}

//用户评论语音
- (void)setContentSound
{
    if (!_soundView) {
        _soundView = [[SNLiveSoundView alloc] initWithFrame:CGRectMake(_contentLabel.left,
                                                                       _viewOffsetY + kTLShareInfoViewNameContentMargin,
                                                                       SOUNDVIEW_WIDTH,
                                                                       SOUNDVIEW_HEIGHT)];
        
        [self addSubview:_soundView];
    }
    
    if (self.timelineTrendObj.ugcAudUrl.length > 0) {
        [_soundView loadIfNeeded];
        _soundView.top = _viewOffsetY + kTLShareInfoViewNameContentMargin;
        _soundView.duration = self.timelineTrendObj.ugcAudLen;
        _soundView.commentID = self.timelineTrendObj.actId;
        _soundView.url = self.timelineTrendObj.ugcAudUrl;
        
        _soundView.hidden = NO;
        _viewOffsetY = _soundView.bottom;
    }
    else {
        _soundView.hidden = YES;
    }
}

- (void)updateTheme {
    [_soundView updateTheme];
    [super updateTheme];
}

#pragma mark - action
- (void)setOriginalImageUrl:(NSString *)urlPath isRelyNetwork:(BOOL)isDownload
{
    [super setOriginalImageUrl:urlPath isRelyNetwork:isDownload];
}

#pragma mark- UIGestureRecognizerDelegate
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

#pragma mark - UIMenuController
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(shareTrend)) {
		return YES;
	}
	return NO;
}

- (void)handleHideNotification:(id)sender {
    _isMenuShow = NO;
}

- (void)enterUserCenter:(NSMutableDictionary *)dic
{
    _isMenuShow = NO;
    // hide menu  by jojo
    [SNNotificationManager postNotificationName:kUIMenuControllerHideMenuNotification
                                                        object:nil
                                                      userInfo:nil];
    [super enterUserCenter:dic];
}

- (void)enterUserCenter
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:self.timelineTrendObj.pid forKey:kHeadIconKeyPid];
    [self enterUserCenter:dic];
}

#pragma mark - handleTapGesture
- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (self.timelineTrendObj.actType == SNTimelineActTypeUGCPublic) {
        [self openMenu:tapGesture];
    }
    CGPoint tapPoint = [tapGesture locationInView:self];
    BOOL isInTapView = CGRectContainsPoint(_originalTapview.frame, tapPoint);
    if (isInTapView) {
        [super openOriginalContentAction:nil];
    }
}

- (void)openMenu:(UITapGestureRecognizer *)tapGesture
{
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if (_isMenuShow)
    {
        _isMenuShow = NO;
        [contextMenu setMenuVisible:NO];
    }
    else {
        _isMenuShow = YES;
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareTrend)];
        [menuItemsArray addObject:shareMenuItem];
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        
        CGRect rect = CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, self.frame.size.height);
        [contextMenu setTargetRect:rect inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}

- (void)shareTrend
{
    _isMenuShow = NO;
    
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    NSString* sourceType = [NSString stringWithFormat:@"%d",self.timelineTrendObj.originContentObj.sourceType];
    [mDic setObject:sourceType forKey:@"sourceType"];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    self.actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    self.actionMenuController.contextDic = [self createActionMenuContentContext];
    self.actionMenuController.sourceType = self.timelineTrendObj.originContentObj.sourceType;
    self.actionMenuController.timelineContentId = self.timelineTrendObj.originContentObj.referId;
    self.actionMenuController.disableLikeBtn = YES;
    
    [self.actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
    self.timelineTrendObj.originContentObj.type = SNTimelineOriginContentTypeTextAndPics;
    self.timelineTrendObj.originContentObj.picUrl = @"timeline_share_default.png";
    
    if (self.timelineTrendObj.originContentObj.referId.length > 0) {
        dicShareInfo[kShareInfoKeyNewsId] = self.timelineTrendObj.actId;
    }
    if (self.timelineTrendObj.originContentObj.description.length > 0) {
        self.shareContent = self.timelineTrendObj.originContentObj.description;
    }
    if (self.shareContent.length > 0) {
        dicShareInfo[kShareInfoKeyShareComment] = self.timelineTrendObj.content;
        dicShareInfo[kShareInfoKeyContent] = self.shareContent;
        //NSRange range = [self.shareContent rangeOfString:@"http://"];
        NSRange range = [SNAPI rangeOfUrl:self.shareContent];
        if (range.location > 0 && range.length > 0) {
            NSString *shareTitle = [NSString stringWithFormat:@"%@,快来收听吧!",
                                    [self.shareContent substringToIndex:range.location]];
            self.timelineTrendObj.originContentObj.title = shareTitle;
            self.timelineTrendObj.originContentObj.description = nil;
        }
    }
    
    dicShareInfo[kShareInfoKeyShareRead] = self.timelineTrendObj.originContentObj;
    
    return dicShareInfo;
}

@end
