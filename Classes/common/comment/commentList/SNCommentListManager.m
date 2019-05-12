//
//  SNCommentListManager.m
//  sohunews
//
//  Created by jialei on 13-8-20.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentListManager.h"
#import "SNFloorCommentItem.h"
#import "SNMyMessage.h"
#import "SNConsts.h"
#import "SNCommentManager.h"
#import "SNCommentListModel.h"
#import "SNTimelineConfigs.h"
#import "UIImage+MultiFormat.h"
#import "SNGalleryPhotoView.h"


@implementation SNCommentListManager
{
    BOOL _isCommentLoading;
    
    SNGalleryPhotoView *_imageDetailView;
}

+ (void)expandCommentById:(NSArray *)comments cid:(NSString *)commentId
{
    if (!commentId)
        return;
    
    for (id commentItem in comments) {
        if ([commentItem isKindOfClass:[SNFloorCommentItem class]]) {
            SNFloorCommentItem *item = (SNFloorCommentItem*)commentItem;
            if ([item.comment.commentId isEqualToString:commentId]) {
                item.comment.isCommentOpen = YES;
                item.cellHeight = 0;
            }
        }
    }
}

+ (void)deleteFloorCommentFromComments:(NSArray *)comments row:(int)row floorIndex:(int)floorIndex theId:(NSString *)theId subId:(NSString *)subId
{
    if (row >= comments.count || row < 0)
        return;
    
    SNFloorCommentItem *item = [comments objectAtIndex:row];
    
    if (floorIndex >= 0 && floorIndex < item.comment.floors.count) {
        SNNewsComment *comment = [item.comment.floors objectAtIndex:floorIndex];
        comment.content = @"该评论已删除";
        comment.commentImage = nil;
        comment.commentImageBig = nil;
        comment.commentImageSmall = nil;
        item.cellHeight = 0;
        
        [[SNCommentManager defaultManager] sendDeleteCommentRequestByCommentId:comment.commentId theId:theId subId:subId busiCode:kCommentBusiCodeNews];
    }

}

+ (void)deleteCommentFromComments:(NSMutableArray *)comments commentId:(NSString *)commentId theId:(NSString *)theId subId:(NSString *)subId
{
    if (!commentId)
        return;
    
    int i = -1;
    for (SNFloorCommentItem *item in comments) {
        i++;
        if ([item.comment.commentId isEqualToString:commentId]) {
            break;
        }
    }
    
    if (i != -1) {
        [comments removeObjectAtIndex:i];
        
        [[SNCommentManager defaultManager] sendDeleteCommentRequestByCommentId:commentId theId:theId subId:subId busiCode:kCommentBusiCodeNews];
    }

}

+ (void)openFloorById:(NSArray *)comments id:(NSString *)commentId
{
    if (!commentId) {
        return;
    }
    for (SNFloorCommentItem *item in comments) {
        if ([item.comment.commentId isEqualToString:commentId]) {
            item.expand = YES;
            item.cellHeight = 0;
        }
    }
}

+ (void)expandSubComment:(NSArray*)comments subFloorIndex:(int)floorIndex indexPathRow:(NSInteger)rowIndex
{
    for (SNFloorCommentItem *item in comments)
    {
        if ([item isKindOfClass:[SNFloorCommentItem class]]) {
            int fItemRow = (int)item.index;
            if (fItemRow == rowIndex && floorIndex < item.comment.floors.count)
            {
                SNNewsComment *comment = [item.comment.floors objectAtIndex:floorIndex];
                comment.isCommentOpen = YES;
                item.cellHeight = 0;
                break;
            }
        }
    }
}

+ (void)expandSocialByMsgId:(NSArray *)comments messageId:(NSString *)messageId {
    if (!messageId) {
        return;
    }
    for (id item in comments) {
        if ([item isKindOfClass:[SNMyMessageItem class]]) {
            SNMyMessageItem *fItem = (SNMyMessageItem *)item;
            if ([fItem.socialMsg.actComment.commentId isEqualToString:messageId]) {
                fItem.socialMsg.actComment.isFolder = NO;
                break;
            }
        }
    }
}

+ (void)expandSocialFloorByMsgId:(NSArray *)comments messageId:(NSString *)messageId {
    if (!messageId) {
        return;
    }
    for (id item in comments) {
        if ([item isKindOfClass:[SNMyMessageItem class]]) {
            SNMyMessageItem *fItem = (SNMyMessageItem *)item;
            if ([fItem.socialMsg.replyComment.commentId isEqualToString:messageId]) {
                fItem.socialMsg.replyComment.isFolder = NO;
                break;
            }
        }
    }
}

+ (void)changeAllSameCommentDingNum:(NSArray *)comments dingNumber:(NSString *)dingNum commentId:(NSString *)commentId
{
    for (SNFloorCommentItem *item in comments)
    {
        if ([item.comment.commentId isEqualToString:commentId])
        {
            item.comment.digNum = dingNum;
            item.comment.hadDing = YES;
            continue;
        }
        for (SNNewsComment *com in item.comment.floors)
        {
            if ([com.commentId isEqualToString:commentId])
            {
                com.digNum = dingNum;
                com.hadDing = YES;
                break;
            }
        }
    }
}

- (void)resetAllCommentCellHeight {
    for (SNFloorCommentItem *item in self.commentItems) {
        if (item.commentItemType == SNCommentItemTypeComment) {
            item.cellHeight = 0;
        }
        item.isUsed = NO;
    }
}

- (id)initWithId:(NSString *)cmtReqId requestType:(SNCommentRequestType)type
{
    self = [super init];
    if (self) {
        if(type == SNCommentRequestTypeNewsId) {
            self.theNewCommentListModel = [[SNNewCommentListModel alloc] initWithCommentModelWithNewsId:cmtReqId gid:nil];
            self.theHotCommentListModel = [[SNHotCommentListModel alloc] initWithCommentModelWithNewsId:cmtReqId gid:nil];
         }
        else {
            self.theNewCommentListModel = [[SNNewCommentListModel alloc] initWithCommentModelWithNewsId:nil gid:cmtReqId];
            self.theHotCommentListModel = [[SNHotCommentListModel alloc] initWithCommentModelWithNewsId:nil gid:cmtReqId];
        }
        self.theNewCommentListModel.delegate = self;
        self.theNewCommentListModel.isFirst = NO;
        self.theHotCommentListModel.delegate = self;
        self.theHotCommentListModel.isFirst = NO;
    }
    return self;
}

- (void)dealloc
{
    _theHotCommentListModel.delegate = nil;
    _theNewCommentListModel.delegate = nil;    
}

#pragma mark - commentData
//组装评论cell需要的item
- (NSArray *)createCommentItems:(BOOL)isHotModel
{
    int capacity = (int)self.theHotCommentListModel.comments.count + (int)self.theNewCommentListModel.comments.count;
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:capacity];
    __block NSMutableArray *blockComments = comments;
    if (self.theHotCommentListModel.comments && self.theHotCommentListModel.comments.count > 0) {
        //热门评论sectionTitle
        SNFloorCommentItem *newCommentScetionTitleItem = [[SNFloorCommentItem alloc] init];
        newCommentScetionTitleItem.commentItemType = SNCommentItemTypeCommentSection;
        newCommentScetionTitleItem.cellHeight = kNewCommentTitleSectionHeight;
        newCommentScetionTitleItem.sectionTitle = @"热门评论";
        newCommentScetionTitleItem.isEmptyComment = NO;
        [blockComments addObject:newCommentScetionTitleItem];
        
//        [comments addObjectsFromArray:self.theHotCommentListModel.comments];
        [self.theHotCommentListModel.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SNFloorCommentItem class]]) {
                SNFloorCommentItem *item = (SNFloorCommentItem *)obj;
                if (item) {
                    [blockComments addObject:item];
                }
            }
        }];
        
        if (self.theHotCommentListModel.comments.count >= kSHowOpenHotCommentCellLimitNum) {
            SNFloorCommentItem *openHotCommentItem = [[SNFloorCommentItem alloc] init];
            openHotCommentItem.commentItemType = SNCommentItemTypeOpenHotComment;
            openHotCommentItem.cellHeight = kOpenHotCommentCellHeight;
            [blockComments addObject:openHotCommentItem];
        }
    }
    
    //最新评论sectionTitle
    SNFloorCommentItem *newCommentScetionTitleItem = [[SNFloorCommentItem alloc] init];
    newCommentScetionTitleItem.commentItemType = SNCommentItemTypeCommentSection;
    [blockComments addObject:newCommentScetionTitleItem];
    
    if (self.theNewCommentListModel.comments && self.theNewCommentListModel.comments.count > 0) {
        newCommentScetionTitleItem.cellHeight = kNewCommentTitleSectionHeight;
        newCommentScetionTitleItem.sectionTitle = @"最新评论";

        newCommentScetionTitleItem.isEmptyComment = NO;
//        [comments addObjectsFromArray:self.theNewCommentListModel.comments];
        [self.theNewCommentListModel.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SNFloorCommentItem class]]) {
                SNFloorCommentItem *item = (SNFloorCommentItem *)obj;
                if (item) {
                    [blockComments addObject:item];
                }
            }
        }];
        SNDebugLog(@"SNCommentListManager createCommentItems isemptyComment = NO");
    }
//    else {
//        //如果是最新评论请求返回，并且数据为空才创建评论空视图
//        if (isHotModel) {
//            newCommentScetionTitleItem.isEmptyComment = (self.theHotCommentListModel.comments.count > 0 ? NO : YES);
//            SNDebugLog(@"SNCommentListManager createCommentItems isemptyComment = NO, isHotModel");
//        }
//        else {
//            newCommentScetionTitleItem.isEmptyComment = YES;
//            SNDebugLog(@"SNCommentListManager createCommentItems isemptyComment = Yes");
//        }
//    }
    
    if (capacity > 0) {
        newCommentScetionTitleItem.isEmptyComment = NO;
    } else {
        newCommentScetionTitleItem.isEmptyComment = YES;
    }

    if (newCommentScetionTitleItem.isEmptyComment) {
        newCommentScetionTitleItem.cellHeight += kCommentEmptyClickedViewHeight;
    }
    
//    self.comtItemsCount = [comments count];
    
    return comments;
}

- (int)comtItemsCount
{
    return (int)self.commentItems.count + (int)(self.theNewCommentListModel.comments.count > 0 ? 1 : 0);
}

- (int)hotComtItemsCount
{
    int count = (int)self.theHotCommentListModel.comments.count;
    if (self.theHotCommentListModel.comments.count >= 3) {
        count += 1;
    }
    return count;
}

- (int)newComtItemsCount
{
    return (int)self.theNewCommentListModel.comments.count + (int)(self.theNewCommentListModel.hasMore ? 1 : 0);
}

- (NSString *)commentNum
{
    int numHot = [self.theHotCommentListModel.commentCount intValue];
    
    //lijian 2015.05.07 这里做权宜之计，因为hot和new的网络model不一定谁先回来，如果虽然hot先请求，但是如果new先回来，去hot得num就错了。所以这里做了个判断，如果hot没有值就去取new，反正俩字段的num时一个样的。这个逻辑尼玛真乱！
    int numNew = [self.theNewCommentListModel.commentCount intValue];
    int num = (numHot > 0)?(numHot):(numNew);
    if(numHot <= 0){
//        SNDebugLog(@"Warmming!!--commentNum getNewNum<---------------------->-%d",numNew);
    }
    return [NSString stringWithFormat:@"%d", num];
}

- (NSString *)readCount
{
    return self.theHotCommentListModel.readCount;
}

- (NSString *)comtStatus
{
    return self.theHotCommentListModel.comtStatus;
}

- (NSString *)comtHint
{
    return self.theHotCommentListModel.comtHint;
}

- (NSString *)stpAudCmtRsn
{
    return self.theHotCommentListModel.stpAudCmtRsn;
}

- (void)setUserInfo:(NSMutableDictionary *)userInfo
{
    self.theHotCommentListModel.userInfo = userInfo;
    self.theNewCommentListModel.userInfo = userInfo;
}

- (void)setIsAuthor:(BOOL)isAuthor
{
    self.theHotCommentListModel.isAuthor = isAuthor;
}

- (void)loadHotData:(BOOL)moreData
{
    [self.theHotCommentListModel loadData:moreData];
}

- (void)loadNewData:(BOOL)moreData
{
    [self.theNewCommentListModel loadData:moreData];
}

- (void)resetData
{
    [self.theHotCommentListModel resetData];
    [self.theNewCommentListModel resetData];
}

- (BOOL)loadMoreNewComment:(UIScrollView *)scrollView
{
    //上拉加载更多
    if (!_isCommentLoading) {
        if ((scrollView.contentOffset.y + scrollView.height + kToolbarViewHeight >
             scrollView.contentSize.height - SNCLLoadMoreBuf * 2 &&
             self.theNewCommentListModel.hasMore)) {
            if ([self checkNetworkIsEnableAndTell]) {
                if (self.theNewCommentListModel.comments.count > 0) {
                    [self.theNewCommentListModel loadData:YES];
//                    [SNNotificationManager postNotificationName:SNCLMoreCellStateChanged
//                                                                        object:[NSNumber numberWithInt:kRCMoreCellStateLoadingMore]];
                } else {
                    [self.theNewCommentListModel loadData:NO];
                }
                return YES;
            }
        }
        else {
//            [SNNotificationManager postNotificationName:SNCLMoreCellStateChanged
//                                                                object:[NSNumber numberWithInt:kRCMoreCellStateEnd]];
        }
    }
    return NO;
}

- (BOOL)loadMoreHotComment
{
    if ([self checkNetworkIsEnableAndTell]) {
        if (self.theHotCommentListModel.comments.count > 0) {
            [self.theHotCommentListModel loadData:YES];
        } else {
            [self.theHotCommentListModel loadData:NO];
        }
        return YES;
    }
    return NO;
}

- (BOOL)checkNetworkIsEnableAndTell {
    BOOL bRet = YES;
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        bRet = NO;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
    return bRet;
}

- (void)insertCacheComment:(NewsCommentItem *)cacheComment
{
    SNNewsComment *comment = nil;
    if ([cacheComment.type isEqualToString:@"reply"]) {
        comment = [self.theNewCommentListModel jsonStringToComment:cacheComment.content topicId:nil];
        comment.userComtId = cacheComment.userComtId;
        
        //发布新评论缓存增加评论ID
        if (!comment.commentId) {
            comment.commentId = [NSString stringWithUUID];
            comment.isCache   = YES;
        }
    } else {
        comment = [[SNNewsComment alloc] init];
        comment.commentId = cacheComment.commentId;
        comment.ctime   = cacheComment.ctime;
        comment.author  = cacheComment.author;
        comment.passport    = cacheComment.passport;
        comment.linkStyle   = cacheComment.linkStyle;
        comment.spaceLink   = cacheComment.spaceLink;
        comment.pid         = cacheComment.pid;
        comment.content     = cacheComment.content;
        comment.digNum  = cacheComment.digNum;
        comment.hadDing = cacheComment.hadDing;
        comment.cid     = cacheComment.ID;
        comment.authorimg     = cacheComment.authorImage;
        comment.commentAudUrl = cacheComment.audioPath;
        comment.commentAudLen = [cacheComment.audioDuration intValue];
        comment.userComtId    = cacheComment.userComtId;
        comment.passport      = [[SNUserinfo userinfo] getUsername];
        comment.commentImageSmall   = cacheComment.imagePath;
        comment.commentImage        = cacheComment.imagePath;
        comment.commentImageBig     = cacheComment.imagePath;
    }
    
    SNFloorCommentItem *commentItem = [[SNFloorCommentItem alloc]initWithComment:comment]; //lijian 2015.01.29 修改内存泄露
    commentItem.newsId = cacheComment.newsId;
    commentItem.isAuthor = self.isAuthor;
    commentItem.commentItemType = SNCommentItemTypeComment;
    
    if (!self.theNewCommentListModel.comments) {
        self.theNewCommentListModel.comments = [NSMutableArray array];
    }
    
    //lijian 2015.05.08 上面对theNewCommentListModel.comments做了初始化为啥不对theHotCommentListModel初始化，评论沙发时还用这个呢，为空时就添加不上了。
    if (!self.theHotCommentListModel.comments) {
        self.theHotCommentListModel.comments = [NSMutableArray array];
    }
    
    [self.theNewCommentListModel.comments insertObject:commentItem atIndex:0];

//    if ([SNUserinfoEx isLogin])
//    {
//        [self.theHotCommentListModel.comments insertObject:commentItem atIndex:0];
//    }
//    else
//    {
//        [self.theNewCommentListModel.comments insertObject:commentItem atIndex:0];
//    }
    
    self.commentItems = [self createCommentItems:NO];
}

#pragma mark - commentImage
- (void)showImageWithUrl:(NSString *)urlPath {
    if (_imageDetailView == nil) {
        CGRect applicationFrame     = [[UIScreen mainScreen] bounds];
        applicationFrame.size.height = kAppScreenHeight;
        _imageDetailView   = [[SNGalleryPhotoView alloc] initWithFrame:applicationFrame];
    }
    [_imageDetailView loadImageWithUrlPath:urlPath];
    [[TTNavigator navigator].topViewController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _imageDetailView.alpha = 1.0;
    [UIView commitAnimations];
}

#pragma mark - SNCommentListModelDelegate
- (void)commentListModelDidStartLoad:(SNCommentListModel *)commentModel
{
    _isCommentLoading = YES;
}

- (void)commentListModelDidFinishLoad:(SNCommentListModel *)commentModel
{
    _isCommentLoading = NO;
    self.commentItems = [self createCommentItems:commentModel.isHotTab];
    if (self.requestFinishedBlock) {
        self.requestFinishedBlock();
    }
    
//    if (commentModel.isHotTab && commentModel.loadPageNum >= 2)  //热门评论只显示30条
    if (commentModel.isHotTab)
    {
        if (!self.theHotCommentListModel.hasMore || commentModel.comments.count >= 20) {
            [SNNotificationManager postNotificationName:NotificationCommentListHotCommentFinishend object:@(NO)];
        } else {
            [SNNotificationManager postNotificationName:NotificationCommentListHotCommentFinishend object:@(YES)];
        }
    } else {
        [SNNotificationManager postNotificationName:SNCLMoreCellStateChanged object:@(NO)];

        if (self.theNewCommentListModel.comments.count == 0) {
            [SNNotificationManager postNotificationName:SNCLMoreCellHiddin object:nil];
        }
    }
}

- (void)commentListModelDidFailToLoadWithError:(SNCommentListModel *)commentModel
{
    _isCommentLoading = NO;
    self.commentItems = [self createCommentItems:commentModel.isHotTab];
    switch (commentModel.lastErrorCode) {
        case kCommentErrorCodeNoData: {
            if (commentModel.isHotTab) {
                if (self.theHotCommentListModel.hasMore || commentModel.comments.count >= 20) {
                    [self.theHotCommentListModel loadData:YES];
                } else {
                    [SNNotificationManager postNotificationName:NotificationCommentListHotCommentFinishend
                                                                        object:@(NO)];
                }
            }
            else {
                if (self.theNewCommentListModel.hasMore) {
                    [self.theNewCommentListModel loadData:YES];
                }
                else {
                    [SNNotificationManager postNotificationName:SNCLMoreCellStateChanged
                                                                        object:@(NO)];
                    if (self.theNewCommentListModel.comments.count == 0) {
                        [SNNotificationManager postNotificationName:SNCLMoreCellHiddin object:nil];
                    }
                    
                }
            }
            break;
        }
        case kCommentErrorCodeDisconnect: {
            break;
        }
        default:
            break;
    }
    
    if (self.requestFailedBlock) {
        self.requestFailedBlock();
    }
}

@end
