//
//  SNCommentListCell.h
//  sohunews
//
//  Created by 贾 磊 on 13-8-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLabel.h"
#import "SNDingService.h"
#import "SNFloorView.h"
#import "SNBaseCommentCell.h"

#define kPicViewWidth                       (54)
#define kPicViewHeight                      (54)

#define SOUNDVIEW_WIDTH 232
#define SOUNDVIEW_HEIGHT  38
#define SOUNDVIEW_SPACE 8

typedef void(^commentListReplyBlock)(SNNewsComment *comment);

@protocol SNCommentListCellDelegate <NSObject>

@optional
- (void)deleteComment:(SNNewsComment *)comment;
- (void)deleteFloorCommentId:(NSString *)commentId row:(NSInteger)row floorIndex:(int)floorIndex;
- (void)shareComment:(SNNewsComment *)comment;
- (void)replyComment:(SNNewsComment *)comment;
- (void)replyFloorComment:(SNNewsComment *)comment;
- (void)openFloor:(NSString *)commentId;
- (void)expandComment:(NSString *)commentId;
- (void)expandFloorComment:(int)subFloorIndex indexPathRow:(NSInteger)rowIndex;
- (void)changeAllSameCommentDingNum:(NSString *)dingNum commentId:(NSString *)commentId;
- (void)showImageWithUrl:(NSString *)urlPath;
- (void)setCommentMenu:(BOOL)isCommentMenu;

@end

@interface SNCommentListCell : SNBaseCommentCell<SNLabelDelegate,SNDingServiceDelegate,UIGestureRecognizerDelegate,SNFloorViewDelegate>
{
    SNFloorCommentItem *_item;
    UIImageView        *_floorContainerView;
    float  _originY;
}

@property (nonatomic, copy)NSString *dingNum;
@property (nonatomic, weak)id<SNCommentListCellDelegate> delegate;
@property (nonatomic, assign)int tableTag;
//@property (nonatomic, retain)NSString *identifier;
@property (nonatomic, assign)float cellHeight;
@property (nonatomic, assign)float cellOffsetY;
@property (nonatomic, copy)commentListReplyBlock replyBlock;

+ (CGFloat)heightForCommentListCell:(SNFloorCommentItem *)commentItem;
- (void)setObject:(SNFloorCommentItem *)commentItem;
- (void)changeAllVisibleDingNum:(NSString *)digNum cid:(NSString *)cid;
- (void)updateTheme;

@end

