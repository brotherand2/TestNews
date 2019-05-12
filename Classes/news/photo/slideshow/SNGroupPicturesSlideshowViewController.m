//
//  SNGroupPicturesSlideshowViewController.m
//  sohunews
//
//  Created by Gao Yongyue on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNGroupPicturesSlideshowViewController.h"
#import "SNSlideshowView.h"
#import "SNPhotoSlideshow.h"
#import "SNDBManager.h"
#import "SNPhotoSlideshowRecommendView.h"
#import "SNMyFavouriteManager.h"
#import "UIImage+MultiFormat.h"
#import "SNConst+PicturesSlideshowViewController.h"
#import "SNSendCommentObject.h"

#import "SNGuideRegisterManager.h"
#import "SNPostCommentService.h"
#import "SNTimelinePostService.h"
#import "SNCommentListManager.h"
#import "SNActionMenuController.h"
#import "SNCommentEditorViewController.h"
#import "SNCommentCacheManager.h"
#import "SNNewsExposureManager.h"
#import "SNSubscribeCenterService.h"
#import "SNNewsShareManager.h"

@interface SNGroupPicturesSlideshowViewController ()<UIScrollViewDelegate, SNActionMenuControllerDelegate, SNSlideshowViewDelegate/*, SNClickItemOnHalfViewDelegate*/>
{
    UIScrollView *_scrollView;
    NSMutableArray *_slideshowViews;
    NSInteger _pageCount;
    NSInteger _lastIndex;
}
@property (nonatomic, strong)NSString *commentNumber;
@property (nonatomic, strong)SNActionMenuController *actionMenuController;
@property (nonatomic, strong)SNNewsShareManager *shareManager;
@property (nonatomic, strong)SNCommentListManager *commentListManager; //获取即时评论数
@property (nonatomic, strong)SNCommentCacheManager *commentCacheManager;

@end

@implementation SNGroupPicturesSlideshowViewController

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow
{
    return [self initWithSlideshows:slideshow index:0];
}

- (id)initWithSlideshows:(SNPhotoSlideshow *)slideshow index:(int)index
{
    self = [self init];
    if (self)
    {
        _slideshowIndex = index;
        self.slideshows = slideshow;
        self.slideshows.groupPicturesSlideshowViewController = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshStatusbar];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.frame = CGRectMake(0.f, 0.f, kAppScreenWidth, kAppScreenHeight);
    self.view.backgroundColor = [UIColor blackColor];

    _commentNumber = @"0";
    _lastIndex = -1;
    _slideshowViews = [[NSMutableArray alloc] init];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-kMultiPicturePadding/2, 0.f, kAppScreenWidth + kMultiPicturePadding, kAppScreenHeight)];
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.pagingEnabled = YES;
	_scrollView.clipsToBounds = YES;
	_scrollView.scrollsToTop = NO;
    _scrollView.bounces = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.delegate = self;
    _scrollView.alwaysBounceHorizontal = YES;
    
    [self.view addSubview:_scrollView];
    
    [self reloadViewsWithPictures:_slideshows index:_slideshowIndex isRecommendView:NO];
}

- (void)showEmbededActivityIndicator
{
    [_slideshowViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNSlideshowView *slideshow = (SNSlideshowView *)obj;
        if ([slideshow isKindOfClass:[SNSlideshowView class]])
        {
            [slideshow showEmbededActivityIndicator];
        }
    }];
}

- (void)hideEmbededActivityIndicator
{
    [_slideshowViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNSlideshowView *slideshow = (SNSlideshowView *)obj;
        if ([slideshow isKindOfClass:[SNSlideshowView class]])
        {
            [slideshow hideEmbededActivityIndicator];
        }
    }];
}

- (void)prepareForReuse
{
    [_scrollView removeAllSubviews];
    [_slideshowViews removeAllObjects];
    _pageCount = 0;
    _slideshowIndex = 0;
}

- (UIImage *)currentImage
{
    UIImage *image = nil;
    UIView *currentView = [self slideshowViewAtIndex:_slideshowIndex];
    if ([currentView isKindOfClass:[SNSlideshowView class]])
    {
        image = [[self pictureViewAtIndex:_slideshowIndex] image];
    }
    return image;
}

- (void)setSlideshowViewZoom
{
    SNSlideshowView *slideshowView = [self pictureViewAtIndex:_slideshowIndex];
    [slideshowView setScrollViewZoom];
}

- (void)loadPlaceholderView:(SNPhotoSlideshow *)slideshow
{
    self.slideshows = slideshow;
    if (!slideshow || [slideshow isEqual:@"0"] || !slideshow.photos)
    {
        if ([_slideshowViews count] != 1)
        {
            [self prepareForReuse];
            SNSlideshowView *slideshowView = [[SNSlideshowView alloc] initWithFrame:CGRectMake(kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight)];
            slideshowView.delegate = self;
            [_scrollView addSubview:slideshowView];
            [_slideshowViews addObject:slideshowView];
            _scrollView.contentSize = CGSizeMake(kAppScreenWidth + kMultiPicturePadding, kAppScreenHeight);
            [_scrollView setContentOffset:CGPointMake(0.f, _scrollView.contentOffset.y) animated:NO];
            if (![SNUtility getApplicationDelegate].isNetworkReachable)
            {
               [self showEmbededActivityIndicator];
            }
            return;
        }
    }
}

- (void)reloadViewsWithPictures:(SNPhotoSlideshow *)slideshow
                          index:(NSInteger)index
                isRecommendView:(BOOL)isRecommendView {
    if (!slideshow || [slideshow isEqual:@"0"] || !slideshow.photos) {
        [self loadPlaceholderView:slideshow];
        return;
    }
    [self prepareForReuse];
    self.slideshows = slideshow;
    _slideshowIndex = index;
    self.slideshows.groupPicturesSlideshowViewController = self;
    
    _pageCount = [_slideshows.photos count];
    SNPhotoSlideshowRecommendView *recommendView = nil;
    if ([_slideshows hasMoreRecommend]) {
        _pageCount ++;
        BOOL hasNextGroup = [_delegate hasNextGroupWithCurrentSlideshow:_slideshows];
        recommendView = [[SNPhotoSlideshowRecommendView alloc] initWithRecommends:_slideshows.moreRecommends delegate:(id)_delegate hasNextGroup:hasNextGroup adDataCarrier:_slideshows.sdkAdLastRecommend ad13371:_slideshows.sdkAd13371];
        recommendView.newsId = slideshow.newsId;
    }
    _scrollView.contentSize = CGSizeMake(_pageCount * (kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    
    __weak typeof(&*self) blockSelf = self;
    [_slideshows.photos enumerateObjectsUsingBlock:^(id obj,
                                                     NSUInteger idx,
                                                     BOOL *stop) {
        SNSlideshowView *slideshowView = [[SNSlideshowView alloc] initWithFrame:CGRectMake(idx * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding / 2, 0.f, kAppScreenWidth, kAppScreenHeight)];
        if ([obj isKindOfClass:[SNPhoto class]]) {
            slideshowView.picture = obj;
        }
        slideshowView.delegate = blockSelf;
        [_scrollView addSubview:slideshowView];
        [_slideshowViews addObject:slideshowView];
    }];
    if ([_slideshows hasMoreRecommend] && recommendView != nil) {
        recommendView.left = [_slideshows.photos count] * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding / 2;
        [_scrollView addSubview:recommendView];
        [_slideshowViews addObject:recommendView];
    }
    
    [self updateCommentNum:_slideshows.newsId];
    if (isRecommendView) {
        _slideshowIndex = _pageCount - 1;
        _slideshowIndex = (_slideshowIndex < 0) ? 0 : _slideshowIndex;
    }
    if ([_slideshows isKindOfClass:[SNPhotoSlideshow class]]) {
        [self displaySlideshowViewAtIndex:_slideshowIndex];
    }
    
    [_scrollView setContentOffset:CGPointMake(_slideshowIndex * (_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(photoDidMoveToIndex:slideshow:)]) {
        [_delegate photoDidMoveToIndex:_slideshowIndex slideshow:_slideshows];
    }
}

- (void)displayCurrentSlideshowView
{
    if ([_slideshows isKindOfClass:[SNPhotoSlideshow class]] && _slideshows.photos)
    {
        [self displaySlideshowViewAtIndex:_slideshowIndex];
    }
}

- (void)refreshStatusbar
{
    [SNNotificationManager postNotificationName:kUpdateStatusBarStyleChangeNotification object:@{@"style": @"blackStyle"}];
    [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
}

//通过评论接口获取评论数和禁止评论项,等接口修复好，就去掉这个再取数据的方法
- (void)updateCommentNum:(NSString *)newsId
{
// 没有评论功能了， 代码注了。用的时候再打开吧。
//    SNCommentRequestType commentRequestType = [_slideshows.termId isEqualToString:@"0"] ? SNCommentRequestTypeGid : SNCommentRequestTypeNewsId;
//    self.commentListManager = [[[SNCommentListManager alloc] initWithId:newsId requestType:commentRequestType] autorelease];
    
//    [self setCommentListBlocks];
//    [self.commentListManager loadHotData:NO];
}

//slide图片分享
- (void)shareAction
{
    if (!_slideshows || [_slideshows isEqual:@"0"] || !_slideshows.photos)
    {
        return;
    }
    // 特殊处理一下广告的数据
    BOOL isSdkAdData = [[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]];
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    
    NSString *referStrUrl = nil;
    NSString *linkUrl = nil;
    if ([self.slideshows.channelId isEqualToString:@"47"] || [self.slideshows.channelId isEqualToString:@"54"]) {
        referStrUrl = @"gid=%@";
        linkUrl = [NSString stringWithFormat:@"photo://channelId=%@&gid=%@", self.slideshows.channelId, self.slideshows.newsId];
    }
    else {
        referStrUrl = @"newsId=%@";
    }
    
    [mDic setObject:[NSString stringWithFormat:referStrUrl,self.slideshows.newsId] forKey:SNNewsShare_ShareOn_referString];
    if (linkUrl) {
        [mDic setObject:linkUrl forKey:SNNewsShare_Url];
        [mDic setObject:@"group" forKey:SNNewsShare_ShareOn_contentType];
    }
    [mDic setObject:isSdkAdData ? @"" : @"group" forKey:SNNewsShare_ShareOn_contentType];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto contentId:_slideshows.newsId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj?oobj.sourceType:SNShareSourceTypePhoto];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [mDic setObject:@"pics" forKey:SNNewsShare_LOG_type];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.shareSubType = isSdkAdData ? ShareSubTypeQuoteText : ShareSubTypeQuoteCard;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    
    NSString *referStr = nil;
    NSString *link = nil;
    if ([self.slideshows.channelId isEqualToString:@"47"] || [self.slideshows.channelId isEqualToString:@"54"]) {
        referStr = @"gid=%@";
        link = [NSString stringWithFormat:@"photo://channelId=%@&gid=%@", self.slideshows.channelId, self.slideshows.newsId];
    }
    else {
        referStr = @"newsId=%@";
    }
    
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:referStr,self.slideshows.newsId] forKey:@"referString"];
    if (link) {
        [_actionMenuController.contextDic setObject:link forKey:@"url"];
        [_actionMenuController.contextDic setObject:@"group" forKey:@"contentType"];
    }
    [_actionMenuController.contextDic setObject:isSdkAdData ? @"" : @"group" forKey:@"contentType"];

    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    _actionMenuController.timelineContentId = _slideshows.newsId;
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                         contentId:_slideshows.newsId];
    _actionMenuController.sourceType = obj ? obj.sourceType : 4;
    if (obj.link)
    {
        _actionMenuController.newsLink = obj.link;
    }
    _actionMenuController.shareLogType = @"pics";
    _actionMenuController.delegate = self;
    if (isSdkAdData)
    {
        _actionMenuController.disableLikeBtn = YES;
    }
    else
    {
        _actionMenuController.disableLikeBtn = NO;
        _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    }
    [_actionMenuController showActionMenu];
}


- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)downloadAction
{
    UIImage *saveImage = [self currentImage];
    if (saveImage)
    {
        UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [SNNewsReport reportADotGif:@"_act=download&_tp=pho&from=article_pics"];
    }
}

- (NSMutableDictionary *)createActionMenuContentContext
{
    NSString *referStr = nil;
    if ([self.slideshows.channelId isEqualToString:@"47"]) {//美图频道
        referStr = @"gid=";
    }
    else {
        referStr = @"newsId=";
    }
    NSMutableDictionary *shareInfoDict = [NSMutableDictionary dictionary];
    NSString *content = _slideshows.shareContent;
    if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
    {
        content = [_slideshows.sdkAdLastPic adShareText];
    }
    NSString *shareContent = content.length > 0 ? content : NSLocalizedString(@"SMS share to friends for splash", @"");
    shareInfoDict[kShareInfoKeyContent] = shareContent;
    NSString * protocoUrl = [NSString stringWithFormat:@"%@%@%@&subId=%@&from=channel&channelId=%@",kProtocolPhoto,referStr,self.slideshows.newsId,@"",self.slideshows.channelId?:@""];
    [shareInfoDict setObject:protocoUrl forKey:@"url"];
    //log
    if (content.length > 0)
    {
        shareInfoDict[kShareInfoKeyShareContent] = content;
    }
    NSString *newsID = _slideshows.newsId;
    if (newsID.length > 0)
    {
        shareInfoDict[kShareInfoKeyNewsId] = newsID;
    }
    
    //weixin
    NSString *imageUrl = nil;
    UIImage *saveImage = nil;
    if (![[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowRecommendView class]] && ![[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
    {
        SNSlideshowView *slideshowView = [self pictureViewAtIndex:_slideshowIndex];
        imageUrl = ((SNPhoto *)_slideshows.photos[_slideshowIndex]).url;
        saveImage = [slideshowView image];
        if (_slideshowIndex + 1 > 0)
        {
            shareInfoDict[@"imageIndex"] = @(_slideshowIndex + 1);
        }
        if (!_slideshows.isOnlineMode)
        {
            if (imageUrl.length > 0)
            {
                shareInfoDict[kShareInfoKeyImagePath] = imageUrl;
            }
        }
    }
    else if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
    {
        NSString *imagePath = [_slideshows.sdkAdLastPic adImageFilePath];
        if ([imagePath length] > 0)
        {
            saveImage = [UIImage imageWithContentsOfFile:imagePath];
            shareInfoDict[kShareInfoKeyImagePath] = imagePath;
        }
    }
    else
    {
        if (_slideshowViews)
        {
            if ([_slideshows.photos count])
            {
                imageUrl = [_slideshows.photos[0] URLForVersion:TTPhotoVersionLarge];
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                saveImage = [UIImage sd_imageWithData:data];
            }
        }
    }
    
    if (saveImage)
    {
        shareInfoDict[@"saveImage"] = saveImage;
    }
    if ([imageUrl length] > 0)
    {
        shareInfoDict[kShareInfoKeyImageUrl] = imageUrl;
    }
    if ([_slideshows.subId length] > 0)
    {
        shareInfoDict[kShareInfoKeySubId] = _slideshows.subId;
    }
    if ([_slideshows.title length] > 0)
    {
        shareInfoDict[kShareInfoKeyTitle] = _slideshows.title;
    }
    return shareInfoDict;
}

- (BOOL)checkIfHadBeenMyFavourite
{
    SNGroupPicturesFavourite *groupPicturesFavourite = [[SNGroupPicturesFavourite alloc] init];
    groupPicturesFavourite.type = _myFavouriteRefer;
    groupPicturesFavourite.contentLevelSecondID = _slideshows.newsId;
    if (_slideshows.termId)
    {
        groupPicturesFavourite.contentLevelFirstID = _slideshows.termId;
    }
//    if (![_slideshows.channelId isEqualToString:@"0"])
//    {
//        //滚动新闻组图PhotoList下的SlideShow里收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
//        groupPicturesFavourite.contentLevelFirstID = _slideshows.channelId ? _slideshows.channelId : @"0";
//    }
    else if (![_slideshows.termId isEqualToString:kDftChannelGalleryTermId])
    {
        //刊物组图PhotoList下的SlideShow里收藏或画报下的SlideShow收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL
        groupPicturesFavourite.contentLevelFirstID = _slideshows.termId ? _slideshows.termId : @"0";
    }
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:groupPicturesFavourite];
}

- (void)commentAction
{
    [self refreshStatusbar];
    if (!_slideshows || [_slideshows isEqual:@"0"] || !_slideshows.photos)
    {
        return;
    }
    BOOL needLogin = [SNSubscribeCenterService shouldLoginForSubscribeWithSubId:_slideshows.subId];
    if (needLogin)
    {
        [SNGuideRegisterManager showGuideWithMediaComment:_slideshows.subId];
    }
    else
    {
        [self presentCommentEidtorController];
    }
}

- (void)presentCommentEidtorController
{
    if (!_commentCacheManager) {
        self.commentCacheManager = [[SNCommentCacheManager alloc] init];
    }
    
    if (![SNUtility needCommentControlTip:_slideshows.photoList.cmtStatus
                            currentStatus:kCommentStsForbidAll
                                      tip:_slideshows.photoList.cmtHint
                                 isBottom:YES])
    {
        NSNumber *toolbarType = @(SNCommentToolBarTypeShowAll);
        if ([_slideshows.stpAudCmtRsn length] > 0)
        {
            toolbarType = @(SNCommentToolBarTypeTextAndCam);
        }
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        dic[kCommentToolBarType] = toolbarType;
        dic[kEditorKeyViewType] = @(SNComment);
        if (_slideshows.photoList.cmtHint.length > 0)
        {
            dic[kEditorKeyComtHint] = _slideshows.photoList.cmtHint;
        }
        if (_slideshows.photoList.cmtStatus.length > 0)
        {
            dic[kEditorKeyComtStatus] = _slideshows.photoList.cmtStatus;
        }
        SNSendCommentObject *sendComemntObject = [[SNSendCommentObject alloc] init];
        //缓存评论
        [self.commentCacheManager setCacheValue:sendComemntObject];
        
        if ([_slideshows.termId isEqualToString:kDftSingleGalleryTermId])
        {
            sendComemntObject.gid = _slideshows.newsId;
            sendComemntObject.busiCode = commentBusicodePhoto;
        }
        else
        {
            sendComemntObject.newsId = _slideshows.newsId;
            sendComemntObject.busiCode = commentBusicodeNews;
        }
        dic[kEditorKeySendCmtObj] = sendComemntObject;
        SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto
                                                                                             contentId:_slideshows.newsId];
        if (obj) {
            obj.contentId = _slideshows.newsId;
            dic[kEditorKeyShareCmtObj] = obj;
        }

//        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCommentEditor"] applyAnimated:YES] applyQuery:dic];
//        [[TTNavigator navigator] openURLAction:action];
        
        _commentEditorViewController = [[SNCommentEditorViewController alloc] initWithParams:dic];
        CGRect viewRect = _commentEditorViewController.view.frame;
        _commentEditorViewController.view.frame = CGRectMake(0, kAppScreenHeight, kAppScreenWidth, kAppScreenHeight);
        [self.view addSubview:_commentEditorViewController.view];
        [UIView animateWithDuration:kCommentEditorViewShowTime animations:^(void) {
            _commentEditorViewController.view.frame = viewRect;
        } completion:^(BOOL finished) {}];
        
        dic = nil;
    }
}

- (BOOL)isRecommendView
{
    return [[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowRecommendView class]];
}

- (BOOL)isAdView
{
    return [[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]];
}

- (NSString *)commentNumber
{
    return _commentNumber;
}

// SNPhotoSlideshowAdWrapView 的statDelegate
- (void)adDidClicked:(SNPhotoSlideshowAdWrapView *)adWrapView
{
    [SNUtility openProtocolUrl:_slideshows.sdkAdLastPic.adClickUrl];
    
    if (0 == _slideshows.sdkAdLastPic.adClickUrl) {
        _slideshows.sdkAdLastPic.newsID = _slideshows.newsId;
//        [_slideshows.sdkAdLastPic reportForEmptyTrack];
    }
    else {
        _slideshows.sdkAdLastPic.newsID = _slideshows.newsId;
        [_slideshows.sdkAdLastPic reportForClickTrack];
    }
}

- (void)generateAdWrapView
{
    _pageCount ++;
    _scrollView.contentSize = CGSizeMake(_pageCount * (kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    SNPhotoSlideshowAdWrapView *adWrapView = [[SNPhotoSlideshowAdWrapView alloc] initWithAdView:_slideshows.sdkAdLastPic.adWrapperView];

    adWrapView.viewDelegate = self;
    adWrapView.size = CGSizeMake(kAppScreenWidth, kAppScreenHeight);
    SNDebugLog(@"SNGroupPicturesSlideshowViewController generateAdWrapView %@", NSStringFromCGRect(adWrapView.frame));
    
    adWrapView.left = [_slideshows.photos count]*(kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2;
    [_scrollView addSubview:adWrapView];
    if ([_slideshows hasMoreRecommend] && [[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowRecommendView class]])
    {
        SNPhotoSlideshowRecommendView *recommendView = (SNPhotoSlideshowRecommendView *)[self slideshowViewAtIndex:[_slideshows.photos count]];
        recommendView.left = (_pageCount - 1)*(kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2;
    }
    [_slideshowViews insertObject:adWrapView atIndex:[_slideshows.photos count]];
    
    //广告曝光统计
    NSString *link = [_slideshows.sdkAdLastPic adClickUrl];
    if (link.length > 0) {
        link = [link stringByAppendingString:@"&exposureFrom=6"];
        [[SNNewsExposureManager sharedInstance] exposureNewsInfoWithLink:link];
    }
}

//加载当前index的图片
- (void)displaySlideshowViewAtIndex:(NSInteger)index
{
    SNSlideshowView *slideshowView = [self pictureViewAtIndex:index];
    if(slideshowView)
    {
        [slideshowView prepareForReuse];
        [slideshowView loadImage];
    }
    else if ([[self slideshowViewAtIndex:index] isKindOfClass:[SNPhotoSlideshowRecommendView class]])
    {
        SNPhotoSlideshowRecommendView *recommendView = (SNPhotoSlideshowRecommendView *)[self slideshowViewAtIndex:index];
        [recommendView loadImageWithAdDataCarrier:_slideshows.sdkAdLastRecommend ad13371:_slideshows.sdkAd13371];
    }
    
    [self prepareNeighborSlideshowViewAtIndex:index];
}

//准备加载当前index的前一张和后一张图片
- (void)prepareNeighborSlideshowViewAtIndex:(NSInteger)index
{
    if(index == 0)
    {
        [self willDisplaySlideshowViewAtIndex:index + 1];
        if (_slideshows.photos.count < 3 && [_slideshows hasSdkAdData] && ![[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            [self generateAdWrapView];
        }
    }
    else if(index == _pageCount - 1)
    {
        [self willDisplaySlideshowViewAtIndex:index - 1];
        if ([_slideshows hasSdkAdData] && ![[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            [self generateAdWrapView];
            [_scrollView setContentOffset:CGPointMake((_pageCount - 1)*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
        }
    }
    else
    {
        [self willDisplaySlideshowViewAtIndex:index - 1];
        [self willDisplaySlideshowViewAtIndex:index + 1];
        if ((index + 3) >= [_slideshows.photos count] && [_slideshows hasSdkAdData] && ![[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            //看广告页是否已创建
            [self generateAdWrapView];
        }
    }
    
}

//加载即将展现的图片，并重新设置image的scale
- (void)willDisplaySlideshowViewAtIndex:(NSInteger)index
{
    if (index < [_slideshows.photos count])
    {
        //普通图片页面
        SNSlideshowView *slideshowView = [self pictureViewAtIndex:index];
        if(slideshowView)
        {
            [slideshowView prepareForReuse];
            [slideshowView loadImage];
        }
        
        [slideshowView resetImageScale];
    }
    
    else if (index == _pageCount - 1 && [_slideshows hasMoreRecommend] && [[self slideshowViewAtIndex:index] isKindOfClass:[SNPhotoSlideshowRecommendView class]])
    {
        SNPhotoSlideshowRecommendView *recommendView = (SNPhotoSlideshowRecommendView *)[self slideshowViewAtIndex:index];
        [recommendView loadImageWithAdDataCarrier:_slideshows.sdkAdLastRecommend ad13371:_slideshows.sdkAd13371];
    }
}

//释放不用的image
- (void)willDismissSlideshowViewAtIndex:(NSInteger)index
{
    SNSlideshowView *slideshowView = [self pictureViewAtIndex:index];
    if(slideshowView)
    {
        [slideshowView prepareForReuse];
    }
}

- (UIView *)slideshowViewAtIndex:(NSInteger)index
{
    SNSlideshowView *slideshowView = [self pictureViewAtIndex:index];
    if (slideshowView)
    {
        return slideshowView;
    }
    else if (index < [_slideshowViews count])
    {
        return _slideshowViews[index];
    }
    else
        return nil;
}

- (SNSlideshowView *)pictureViewAtIndex:(NSInteger)index
{
    if (![_slideshows isKindOfClass:[SNPhotoSlideshow class]]) {
        return nil;
    }
    SNSlideshowView *slideshowView = nil;
    if(index >= 0 && index < [_slideshows.photos count] && index < [_slideshowViews count])
    {
        slideshowView = _slideshowViews[index];
    }
    return slideshowView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    _commentNumber = nil;
    _slideshows = nil;
    _slideshowViews = nil;
    _commentListManager.requestFinishedBlock = nil;
    _commentListManager.requestFailedBlock = nil;
    _commentListManager = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    _commentNumber = nil;
    _slideshows = nil;
    _slideshowViews = nil;
    _commentListManager.requestFinishedBlock = nil;
    _commentListManager.requestFailedBlock = nil;
    _commentListManager = nil;
    
    _actionMenuController.delegate = nil;
        
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	NSInteger index = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    
    if(index < 0)
    {
        index = 0;
    }
	if(index > _pageCount - 1)
    {
        index = _pageCount - 1;
    }
    if (!(_slideshowIndex == _pageCount - 1 && _slideshows.galleryLoadType == GalleryLoadTypePrev) && _lastIndex != index)
    {
        [self prepareNeighborSlideshowViewAtIndex:index];
        _lastIndex = index;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoDidMoveToIndex:slideshow:)])
    {
        [_delegate photoDidMoveToIndex:index slideshow:_slideshows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	_slideshowIndex = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if (_delegate && [_delegate respondsToSelector:@selector(photoDidMoveToIndex:slideshow:)])
    {
        [_delegate photoDidMoveToIndex:_slideshowIndex slideshow:_slideshows];
    }
    if (_slideshowIndex < [_slideshows.photos count])
    {
        if(_slideshowIndex > 1)
        {
            [self willDismissSlideshowViewAtIndex:_slideshowIndex - 2];
        }
        if(_slideshowIndex < [_slideshows.photos count] - 2)
        {
            [self willDismissSlideshowViewAtIndex:_slideshowIndex + 2];
        }
    }
    else
    {
        // sdk广告曝光统计
        if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowRecommendView class]])
        {
            _slideshows.sdkAdLastRecommend.newsID = _slideshows.newsId;
            if (_slideshows.sdkAdLastRecommend.errorType != kStadErrorForNewsTypeNodata) {//空广告不报av
                [_slideshows.sdkAdLastRecommend reportForDisplayTrack];
            }
            
            _slideshows.sdkAd13371.newsID = _slideshows.newsId;
            if (_slideshows.sdkAd13371.errorType != kStadErrorForNewsTypeNodata) {//空广告不报av
                [_slideshows.sdkAd13371 reportForDisplayTrack];
            }
            SNPhotoSlideshowRecommendView *recommendView = (SNPhotoSlideshowRecommendView *)[self slideshowViewAtIndex:_slideshowIndex];
            [recommendView reportBusinessStatisticsInfo];
        }
        else if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            _slideshows.sdkAdLastPic.newsID = _slideshows.newsId;
            [_slideshows.sdkAdLastPic reportForDisplayTrack];
        }
    }
}

#pragma mark - SNActionMenuControllerDelegate
- (void)actionmenuDidSelectLikeBtn {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if ([self checkIfHadBeenMyFavourite]) {
        [self executeFavouriteNews:nil];
    }
    else {
        [SNUtility executeFloatView:self selector:@selector(executeFavouriteNews:)];
    }
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavouriteNews:dict];
}

- (void)executeFavouriteNews:(NSDictionary *)dict {
    SNGroupPicturesFavourite *groupPicturesFavourite = [[SNGroupPicturesFavourite alloc] init];
    groupPicturesFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
    groupPicturesFavourite.title = _slideshows.title;
    groupPicturesFavourite.type = _myFavouriteRefer;
    groupPicturesFavourite.contentLevelSecondID = _slideshows.newsId;
    if ([_slideshows.photoList.gallerySubItems count] > 0)
    {
        PhotoItem *photo = _slideshows.photoList.gallerySubItems[0];
        if (![@"" isEqualToString:photo.url])
        {
            groupPicturesFavourite.imageUrl = photo.url;
        }
    }
    if (![_slideshows.channelId isEqualToString:@"0"])
    {
        //滚动新闻组图PhotoList下的SlideShow里收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
        groupPicturesFavourite.contentLevelFirstID = _slideshows.channelId ? _slideshows.channelId : @"0";
    }
    else if (![_slideshows.termId isEqualToString:kDftChannelGalleryTermId])
    {
        //刊物组图PhotoList下的SlideShow里收藏或画报下的SlideShow收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL
        groupPicturesFavourite.contentLevelFirstID = _slideshows.termId;
    }
    [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:groupPicturesFavourite corpusDict:dict];
}

#pragma mark - UIdownloadimagebutton
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	SNDebugLog(@"照片失败%@", [error localizedDescription]);
	[[SNUtility getApplicationDelegate] image:image didFinishSavingWithError:error contextInfo:contextInfo];
}

#pragma mark - SNSlideshowViewDelegate
- (void)didTapRetry
{
    if (_delegate && [_delegate respondsToSelector:@selector(reloadSlideshowInfo:)])
    {
        [_delegate reloadSlideshowInfo:_slideshows];
    }
}

@end
