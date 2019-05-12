//
//  SNPhotolistDataSource.m
//  sohunews
//
//  Created by jialei on 14-3-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNPhotolistDataSource.h"
#import "SNPhotoListTableItem.h"
#import "SNPhotoListTableCell.h"
#import "SNPhotoListSubscribeCell.h"
#import "SNRollingNewsTableItem.h"
#import "SNPhotoListSectionTitleCell.h"
#import "SNRollingPhotoNewsTableCell.h"
#import "SNRollingNewsTableCell.h"
#import "SNPhotoListRecommendCell.h"
#import "SNSeparateLabel.h"
#import "SNFloorCommentItem.h"
#import "SNCommentListCell.h"
#import "SNWeiboDetailMoreCell.h"
#import "SNTableViewCell.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNCommonNewsDatasource.h"
#import "SNSendCommentObject.h"

#define kPhotoTextListSectionNumber 6
#define kTableRecommendSectionCount    1
#define kTableTitleSectionCount        1
#define kTableSubSectionCount          1

@interface SNPhotolistDataSource ()
{
    BOOL    _isSendCount;
    SNCommentSendType   commentType;
}

//@property (nonatomic, copy)TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, retain)NSIndexPath *moreCellIndexPath;
@property (nonatomic, retain)NSString *newsId;
@property (nonatomic, assign)SNCommentRequestType cmtReqType;

@end

@implementation SNPhotolistDataSource

- (id)initWithCommentId:(NSString *)cmtReqId requestType:(SNCommentRequestType)type
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_photoItems);
    TT_RELEASE_SAFELY(_subscribe);
    TT_RELEASE_SAFELY(_recommendItems);
    TT_RELEASE_SAFELY(_commentItems);
    TT_RELEASE_SAFELY(_scrollBlock);
    TT_RELEASE_SAFELY(_cellDisplayBlock);
    TT_RELEASE_SAFELY(_imageClickBlock);
    TT_RELEASE_SAFELY(_tableReload);
    TT_RELEASE_SAFELY(_replyComment);
    
    TT_RELEASE_SAFELY(_subId);
    TT_RELEASE_SAFELY(_newsId);

    [super dealloc];
}

- (id)itemForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SNPLTableSectionPhoto: {
            SNPhotoListTableItem *item = [self.photoItems objectAtIndex:indexPath.row];
            if (item) {
                return item;
            }
            break;
        }
        case SNPLTableSectionSub: {
            return self.subscribe;
        }
        case SNPLTableSectionRecommendTitle: {
            if (self.recmdCount > 0 || self.sdkAdState == SNAdDataStateReady) {
                return [NSString stringWithFormat:@"相关推荐"];
            }
            break;
        }
        case SNPLTableSectionRecommend: {
            if (self.recmdCount > 0 && indexPath.row < self.recmdCount) {
                SNRollingNewsTableItem *newsItem = [self.recommendItems objectAtIndex:indexPath.row];
                return newsItem;
            }
            break;
        }
        case SNPLTableSectionCommentTitle: {
            if (self.cmtCount > 0) {
                return [NSString stringWithFormat:@"热门评论"];
            }
            break;
        }
        case SNPLTableSectionComment: {
            if (indexPath.row < self.commentItems.count && indexPath.row >= 0) {
                SNFloorCommentItem *item = [self.commentItems objectAtIndex:[indexPath row]];
                if (item) {
                    item.index = indexPath.row;
                    return item;
                }
            }
            break;
        }
    }
    return nil;
}

- (Class)classForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SNPLTableSectionPhoto: {
            return [SNPhotoListTableCell class];
        }
        case SNPLTableSectionSub: {
            return [SNPhotoListSubscribeCell class];
        }
        case SNPLTableSectionRecommendTitle: {
            return [SNPhotoListSectionTitleCell class];
        }
        case SNPLTableSectionRecommend: {
            if (self.recmdCount >0 && indexPath.row < self.recmdCount) {
                SNRollingNewsTableItem *newsItem = [self.recommendItems objectAtIndex:indexPath.row];
                if ([kNewsTypeGroupPhoto isEqualToString:newsItem.news.newsType]) {
                    return [SNRollingPhotoNewsTableCell class];
                }
                else {
                    return [SNRollingNewsTableCell class];
                }
            }
            else {
                return [SNPhotoListRecommendCell class];
            }
        }
        case SNPLTableSectionCommentTitle: {
            return [SNPhotoListSectionTitleCell class];
        }
        case SNPLTableSectionComment: {
            if (indexPath.row < self.commentItems.count) {
                SNFloorCommentItem *item = [self.commentItems objectAtIndex:indexPath.row];
                if (item) {
                    return [SNCommentListCell class];
                }
            }
            else {
                self.moreCellIndexPath = indexPath;
                return [SNWeiboDetailMoreCell class];
            }
        }
    }
    return [UITableViewCell class];
}

#pragma tableViewDataSource && tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kPhotoTextListSectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SNPLTableSectionPhoto: {
            return self.photoCount;
        }
        case SNPLTableSectionSub: {
            return self.subscribe ? kTableSubSectionCount : 0;
        }
        case SNPLTableSectionRecommendTitle: {
            return (self.recmdCount > 0) ? kTableTitleSectionCount : 0;
        }
        case SNPLTableSectionRecommend: {
            return self.recmdCount;
        }
        case SNPLTableSectionCommentTitle: {
            return (self.cmtCount > 0) ? kTableTitleSectionCount : 0;
        }
        case SNPLTableSectionComment: {
            return self.cmtCount;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SNPLTableSectionPhoto: {
            if (self.photoCount > 0 && [indexPath row] < self.photoCount) {
                SNPhotoListTableItem *item = [self.photoItems objectAtIndex:[indexPath row]];
                return item.cellHeight;
            }
            break;
        }
        case SNPLTableSectionSub: {
            if (self.subscribe) {
                return [SNPhotoListSubscribeCell heightForSubscribeCell];
            }
            break;
        }
        case SNPLTableSectionRecommendTitle: {
            if (self.recmdCount > 0) {
                return kSeparateLabelHeight + 4;
            }
        }
        case SNPLTableSectionRecommend: {
            if (self.recmdCount >0 && indexPath.row < self.recmdCount) {
                SNRollingNewsTableItem *newsItem = [self.recommendItems objectAtIndex:indexPath.row];
                if ([kNewsTypeGroupPhoto isEqualToString:newsItem.news.newsType]) {
                    return [SNRollingPhotoNewsTableCell tableView:tableView rowHeightForObject:newsItem];
                }else {
                    return [SNRollingNewsTableCell tableView:tableView rowHeightForObject:newsItem];
                }
            }
            else {
                CGFloat cellHeight = 0;
                // 增加相应广告位的高度
                if (self.sdkAdState == SNAdDataStateReady) {
                    cellHeight += ((106 / 2) + (24 / 2) * 2);
                }
                if (self.sdkAdState == SNAdDataStateReady) {
                    cellHeight += (88 / 2) + (20 / 2) * 2 + (16 / 2) + (33 / 2);
                }
                return cellHeight;
            }
            break;
        }
        case SNPLTableSectionCommentTitle: {
            if (self.cmtCount > 0) {
                return kSeparateLabelHeight + 4;
            }
            break;
        }
        case SNPLTableSectionComment: {
            if ([indexPath row] < self.commentItems.count) {
                SNFloorCommentItem *item = [self.commentItems objectAtIndex:[indexPath row]];
                if (item) {
                    return [SNCommentListCell heightForCommentListCell:item];
                }
            }
            else {
                return [SNWeiboDetailMoreCell height];
            }
            break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemForIndexPath:indexPath];
    Class cellClass = [self classForIndexPath:indexPath];
    NSString *identifierStr = NSStringFromClass(cellClass);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        cell = [[[cellClass alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:identifierStr] autorelease];
    }
    
    [cell setDelegate:self];
    [cell setObject:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SNWeiboDetailMoreCell class]]) {
        SNWeiboDetailMoreCell *moreCell = (SNWeiboDetailMoreCell *)cell;
        moreCell.state = self.moreCellState;
    }
    if (self.cellDisplayBlock) {
        self.cellDisplayBlock(cell);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == SNPLTableSectionRecommend) {
        if (self.recmdCount >0 && indexPath.row < self.recmdCount) {
            SNRollingNewsTableItem *newsItem = [self.recommendItems objectAtIndex:indexPath.row];
            if (newsItem.type == NEWS_ITEM_TYPE_GROUP_PHOTOS) {
                SNRollingPhotoNewsTableCell *photoCell = (SNRollingPhotoNewsTableCell *)[tableView cellForRowAtIndexPath:indexPath];
                photoCell.item.news.isRead = YES;
                [photoCell setReadStyleByMemory];
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:kNewsOnline forKey:kNewsMode];
                [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kisFromRelatedNewsList];
                if (newsItem.news.newsId) {
                    [userInfo setObject:newsItem.news.newsId forKey:kNewsId];
                    [userInfo setObject:newsItem.news.newsId forKey:kRecommendFromNewsId];
                }
                if (newsItem && newsItem.news.link) {
                    [userInfo setObject:newsItem.news.link forKey:kNewsLink2];
                }
                [userInfo setObject:[NSNumber numberWithBool:NO] forKey:kNewsSupportNext];
                
                NSMutableDictionary* dic = [[[SNCommonNewsDatasource getPhotoListRecommandDictionary:userInfo] retain] autorelease];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:urlAction];
                return;
            }else {
                SNRollingNewsTableCell *newsCell = (SNRollingNewsTableCell *)[tableView cellForRowAtIndexPath:indexPath];
                newsCell.item.news.isRead = YES;
                [newsCell setReadStyleByMemory];
            }
            
            if (newsItem && newsItem.news.link) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:newsItem.news.link forKey:kNewsLink2];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:kNewsSupportNext];
                if (newsItem.news.updateTime) {
                    [dic setObject:newsItem.news.updateTime forKey:kUpdateTime];
                }
                [SNUtility openProtocolUrl:newsItem.news.link context:dic];
            }
        }
    }
}

#pragma photoCellDelegate
- (void)clickImage:(id)sender {
    if (self.imageClickBlock) {
        self.imageClickBlock(sender);
    }
}

#pragma mark - commentListCellDelegate
- (void)showImageWithUrl:(NSString *)urlPath
{
    if (self.showComtImage) {
        self.showComtImage(urlPath);
    }
}

- (void)shareComment:(SNNewsComment *)comment
{
    if (self.shareComment) {
        self.shareComment(comment);
    }
}

- (void)replyComment:(SNNewsComment *)comment
{
    if (self.replyComment) {
        self.replyComment(comment, kCommentSendTypeReply);
    }
}


- (void)replyFloorComment:(SNNewsComment *)comment
{
    if (self.replyComment) {
        self.replyComment(comment, kCommentSendTypeReplyFloor);
    }
}

- (void)expandComment:(NSString *)commentId tag:(int)tag
{
    [SNCommentListManager expandCommentById:self.commentItems id:commentId];
    if (self.tableReload) {
        self.tableReload();
    }
}

- (void)openFloor:(NSString *)commentId tag:(int)tag
{
    [SNCommentListManager openFloorById:self.commentItems id:commentId];
    if (self.tableReload) {
        self.tableReload();
    }
}

-(void)expandFloorComment:(int)subFloorIndex indexPathRow:(int)rowIndex tag:(int)tag
{
    [SNCommentListManager expandSubComment:self.commentItems subFloorIndex:subFloorIndex indexPathRow:rowIndex];
    if (self.tableReload) {
        self.tableReload();
    }
}

#pragma mark - privateMethod
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollBlock) {
        self.scrollBlock(scrollView);
    }
}

- (void)setMoreCellState:(SNMoreCellState)moreCellState tableView:(UITableView *)tableView {
    id cell = [tableView cellForRowAtIndexPath:self.moreCellIndexPath];
    if ([cell isKindOfClass:[SNWeiboDetailMoreCell class]]) {
        SNWeiboDetailMoreCell *moreCell = (SNWeiboDetailMoreCell *)cell;
        moreCell.state = moreCellState;
    }
}

@end
