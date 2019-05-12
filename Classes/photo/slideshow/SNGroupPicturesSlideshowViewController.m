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
#import "SNPhotoSlideshowAdWrapView.h"
#import "SNMyFavouriteManager.h"
#import "UIImage+MultiFormat.h"
#import "SNConst+PicturesSlideshowViewController.h"
#import "SNSendCommentObject.h"

#import "SNGuideRegisterManager.h"
#import "SNPostCommentController.h"
#import "SNTimelinePostService.h"
#import "SNCommentListManager.h"
#import "SNActionMenuController.h"
#import "SNCommentEditorViewController.h"

@interface SNGroupPicturesSlideshowViewController ()<UIScrollViewDelegate, SNActionMenuControllerDelegate, SNSlideshowViewDelegate>
{
    UIScrollView *_scrollView;
    NSMutableArray *_slideshowViews;
    int _pageCount;
}
@property (nonatomic, retain)NSString *commentNumber;
@property (nonatomic, retain)SNActionMenuController *actionMenuController;
@property (nonatomic, retain)SNCommentListManager *commentListManager; //获取即时评论数
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.frame = CGRectMake(0.f, 0.f, kAppScreenWidth, kAppScreenHeight);
    self.view.backgroundColor = [UIColor blackColor];

    _commentNumber = @"0";
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
    [_scrollView release];
    
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
            [slideshowView release];
            _scrollView.contentSize = CGSizeMake(kAppScreenWidth + kMultiPicturePadding, kAppScreenHeight);
            [_scrollView setContentOffset:CGPointMake(0.f, _scrollView.contentOffset.y) animated:NO];
            if (![[SNUtility getApplicationDelegate] checkNetworkStatus])
            {
               [self showEmbededActivityIndicator];
            }
            return;
        }
    }
}

- (void)reloadViewsWithPictures:(SNPhotoSlideshow *)slideshow index:(int)index isRecommendView:(BOOL)isRecommendView
{
    if (!slideshow || [slideshow isEqual:@"0"] || !slideshow.photos)
    {
        [self loadPlaceholderView:slideshow];
        return;
    }
    [self prepareForReuse];
    self.slideshows = slideshow;
    _slideshowIndex = index;
    
    _pageCount = [_slideshows.photos count];
    SNPhotoSlideshowRecommendView *recommendView = nil;
    if ([_slideshows hasMoreRecommend])
    {
        _pageCount ++;
        BOOL hasNextGroup = [_delegate hasNextGroupWithCurrentNewsID:_slideshows.newsId];
        recommendView = [[SNPhotoSlideshowRecommendView alloc] initWithRecommends:_slideshows.moreRecommends delegate:(id)_delegate hasNextGroup:hasNextGroup adDataCarrier:_slideshows.sdkAdLastRecommend];
    }
    _scrollView.contentSize = CGSizeMake(_pageCount * (kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    
    __block typeof(&*self) blockSelf = self;
    [_slideshows.photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNSlideshowView *slideshowView = [[SNSlideshowView alloc] initWithFrame:CGRectMake(idx * (kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2, 0.f, kAppScreenWidth, kAppScreenHeight)];
        if ([obj isKindOfClass:[SNPhoto class]])
        {
            slideshowView.picture = obj;
        }
        slideshowView.delegate = blockSelf;
        [_scrollView addSubview:slideshowView];
        [_slideshowViews addObject:slideshowView];
        [slideshowView release];
    }];
    if ([_slideshows hasMoreRecommend])
    {
        recommendView.left = [_slideshows.photos count]*(kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2;
        [_scrollView addSubview:recommendView];
        [_slideshowViews addObject:recommendView];
        [recommendView release];
    }
    
    [self updateCommentNum:_slideshows.newsId];
    if (isRecommendView)
    {
        _slideshowIndex = _pageCount - 1;
        _slideshowIndex = (_slideshowIndex < 0) ? 0 : _slideshowIndex;
    }
    
    //[self displaySlideshowViewAtIndex:_slideshowIndex];
    [_scrollView setContentOffset:CGPointMake(_slideshowIndex*(_scrollView.frame.size.width), _scrollView.contentOffset.y) animated:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(photoDidMoveToIndex:slideshow:)])
    {
        [_delegate photoDidMoveToIndex:_slideshowIndex slideshow:_slideshows];
    }
}

- (void)displayCurrentSlideshowView
{
    if (_slideshows.photos)
    {
        [self displaySlideshowViewAtIndex:_slideshowIndex];
    }
}

//通过评论接口获取评论数和禁止评论项,等接口修复好，就去掉这个再取数据的方法
- (void)updateCommentNum:(NSString *)newsId
{
    SNCommentRequestType commentRequestType = [_slideshows.termId isEqualToString:@"0"] ? SNCommentRequestTypeGid : SNCommentRequestTypeNewsId;
    self.commentListManager = [[[SNCommentListManager alloc] initWithId:newsId requestType:commentRequestType] autorelease];
    
    [self setCommentListBlocks];
    [self.commentListManager loadData:NO];
}

- (void)setCommentListBlocks
{
    __block typeof(&*self) blockSelf = self;
    self.commentListManager.requestFinishedBlock = ^() {
        blockSelf.commentNumber = blockSelf->_commentListManager.commentCount;
        if (blockSelf->_delegate && [blockSelf->_delegate respondsToSelector:@selector(updateCommentCount:slideshow:)])
        {
            blockSelf->_slideshows.commentNum = blockSelf->_commentListManager.commentCount;
            [blockSelf->_delegate updateCommentCount:blockSelf->_commentListManager.commentCount slideshow:blockSelf->_slideshows];
        }
    };
    
    self.commentListManager.requestFailedBlock = ^() {
        blockSelf.commentNumber = blockSelf->_commentListManager.commentCount;
        if (blockSelf->_delegate && [blockSelf->_delegate respondsToSelector:@selector(updateCommentCount:slideshow:)])
        {
            blockSelf->_slideshows.commentNum = blockSelf->_commentListManager.commentCount;
            [blockSelf->_delegate updateCommentCount:blockSelf->_commentListManager.commentCount slideshow:blockSelf->_slideshows];
        }
    };
}

- (void)showCommentListAction
{
    if (!_slideshows || [_slideshows isEqual:@"0"] || !_slideshows.photos)
    {
        return;
    }
    NSMutableDictionary *newsInfo = [NSMutableDictionary dictionary];
    if (_slideshows.title.length > 0)
    {
        newsInfo[kCommentListKeyNewsTitle] = _slideshows.title;
    }
    if (_slideshows.shareContent.length > 0)
    {
        newsInfo[kCommentListKeyShareContent] = _slideshows.shareContent;
    }
    if(_slideshows.newsId .length > 0)
    {
        if([kDftSingleGalleryTermId isEqualToString:_slideshows.termId])
        {
            newsInfo[kCommentListKeyGid] = _slideshows.newsId;
        }
        else
        {
            newsInfo[kCommentListKeyNewsId] = _slideshows.newsId;
        }
    }
    [SNCommentListManager pushAllCommentListWithQuery:newsInfo];
}

- (void)shareAction
{
    if (!_slideshows || [_slideshows isEqual:@"0"] || !_slideshows.photos)
    {
        return;
    }
    // 特殊处理一下广告的数据
    BOOL isSdkAdData = [[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]];
    self.actionMenuController = [[[SNActionMenuController alloc] init] autorelease];
    _actionMenuController.shareSubType = isSdkAdData ? ShareSubTypeQuoteText : ShareSubTypeQuoteCard;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    
    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    _actionMenuController.timelineContentId = _slideshows.newsId;
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePhoto contentId:_slideshows.newsId];
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

- (void)downloadAction
{
    UIImage *saveImage = [self currentImage];
    if (saveImage)
    {
        UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (NSMutableDictionary *)createActionMenuContentContext
{
    NSMutableDictionary *shareInfoDict = [NSMutableDictionary dictionary];
    NSString *content = _slideshows.shareContent;
    if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
    {
        content = [_slideshows.sdkAdLastPic adShareText];
    }
    NSString *shareContent = content.length > 0 ? content : NSLocalizedString(@"SMS share to friends", @"");
    shareInfoDict[kShareInfoKeyContent] = shareContent;
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
    SNGroupPicturesFavourite *groupPicturesFavourite = [[[SNGroupPicturesFavourite alloc] init] autorelease];
    groupPicturesFavourite.type = _myFavouriteRefer;
    groupPicturesFavourite.contentLevelSecondID = _slideshows.newsId;
    if (![_slideshows.channelId isEqualToString:@"0"])
    {
        //滚动新闻组图PhotoList下的SlideShow里收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS
        groupPicturesFavourite.contentLevelFirstID = _slideshows.channelId ? _slideshows.channelId : @"0";
    }
    else if (![_slideshows.termId isEqualToString:kDftChannelGalleryTermId])
    {
        //刊物组图PhotoList下的SlideShow里收藏或画报下的SlideShow收藏  MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL
        groupPicturesFavourite.contentLevelFirstID = _slideshows.termId ? _slideshows.termId : @"0";
    }
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:groupPicturesFavourite];
}

- (void)commentAction
{
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
        SNSendCommentObject *sendComemntObject = [[[SNSendCommentObject alloc] init] autorelease];
        if ([_slideshows.termId isEqualToString:kDftSingleGalleryTermId])
        {
            sendComemntObject.gid = _slideshows.newsId;
        }
        else
        {
            sendComemntObject.newsId = _slideshows.newsId;
        }
        dic[kEditorKeySendCmtObj] = sendComemntObject;

        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCommentEditor"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
        
        [dic release], dic = nil;
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

- (void)generateAdWrapView
{
    _pageCount ++;
    _scrollView.contentSize = CGSizeMake(_pageCount * (kAppScreenWidth + kMultiPicturePadding), kAppScreenHeight);
    SNPhotoSlideshowAdWrapView *adWrapView = [[SNPhotoSlideshowAdWrapView alloc] initWithAdView:_slideshows.sdkAdLastPic.adWrapperView];
    adWrapView.left = [_slideshows.photos count]*(kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2;
    [_scrollView addSubview:adWrapView];
    if ([_slideshows hasMoreRecommend] && [[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowRecommendView class]])
    {
        SNPhotoSlideshowRecommendView *recommendView = (SNPhotoSlideshowRecommendView *)[self slideshowViewAtIndex:[_slideshows.photos count]];
        recommendView.left = (_pageCount - 1)*(kAppScreenWidth + kMultiPicturePadding) + kMultiPicturePadding/2;
    }
    [_slideshowViews insertObject:adWrapView atIndex:[_slideshows.photos count]];
    [adWrapView release];
}

//加载当前index的图片
- (void)displaySlideshowViewAtIndex:(int)index
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
        [recommendView loadImageWithAdDataCarrier:_slideshows.sdkAdLastRecommend];
    }
    
    [self prepareNeighborSlideshowViewAtIndex:index];
}

//准备加载当前index的前一张和后一张图片
- (void)prepareNeighborSlideshowViewAtIndex:(int)index
{
    if(index == 0)
    {
        [self willDisplaySlideshowViewAtIndex:index + 1];
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
        if (index == [_slideshows.photos count] - 3 && [_slideshows hasSdkAdData] && ![[self slideshowViewAtIndex:[_slideshows.photos count]] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            //看广告页是否已创建
            [self generateAdWrapView];
        }
    }
}

//加载即将展现的图片，并重新设置image的scale
- (void)willDisplaySlideshowViewAtIndex:(int)index
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
        [recommendView loadImageWithAdDataCarrier:_slideshows.sdkAdLastRecommend];
    }
}

//释放不用的image
- (void)willDismissSlideshowViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = [self pictureViewAtIndex:index];
    if(slideshowView)
    {
        [slideshowView prepareForReuse];
    }
}

- (UIView *)slideshowViewAtIndex:(int)index
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

- (SNSlideshowView *)pictureViewAtIndex:(int)index
{
    SNSlideshowView *slideshowView = nil;
    if(index >= 0 && index < [_slideshows.photos count] && [_slideshowViews count])
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
    [_commentNumber release], _commentNumber = nil;
    [_slideshows release], _slideshows = nil;
    [_slideshowViews release], _slideshowViews = nil;
    [_commentListManager release], _commentListManager = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [_commentNumber release], _commentNumber = nil;
    [_slideshows release], _slideshows = nil;
    [_slideshowViews release], _slideshowViews = nil;
    [_commentListManager release], _commentListManager = nil;
    
    _actionMenuController.delegate = nil;
    TT_RELEASE_SAFELY(_actionMenuController);
    
    [super dealloc];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect bounds = scrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    if(index < 0)
    {
        index = 0;
    }
	if(index > _pageCount - 1)
    {
        index = _pageCount - 1;
    }
    [self prepareNeighborSlideshowViewAtIndex:index];
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
            [_slideshows.sdkAdLastRecommend reportForDisplayTrack];
        }
        else if ([[self slideshowViewAtIndex:_slideshowIndex] isKindOfClass:[SNPhotoSlideshowAdWrapView class]])
        {
            [_slideshows.sdkAdLastPic reportForDisplayTrack];
        }
    }
}

#pragma mark - SNActionMenuControllerDelegate
- (void)actionmenuDidSelectLikeBtn
{
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
    [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:groupPicturesFavourite];
    [groupPicturesFavourite release];
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
