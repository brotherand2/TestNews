//
//  SNFloorView.h
//  sohunews
//
//  Created by qi pei on 6/19/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNewsComment.h"
#import "SNDingService.h"
#import "SNLiveSoundView.h"
#import "SNLabel.h"
#import "SNNameButton.h"

enum commentViewType {
    commentViewType_newsTitleButton = 218,
    commentViewType_picView         = 219,
    commentViewType_userHeadIcon    = 220,
    commentViewType_floorPicView    = 221,
    commentViewType_expandFloor     = 230,
    commentViewType_expandComment   = 231,
    commentViewType_newsTitleLabel  = 232,
    commentViewType_floorContainer  = 233,
    commentViewType_nameButton      = 234,
    commentViewType_contentLabel    = 235,
    commentViewType_dingLabel       = 236,
    commentViewType_dingImageView   = 237,
    commentViewType_audioView       = 238
};


@protocol SNFloorViewDelegate <NSObject>

@optional
- (void)floorViewExpandFloorComment:(int)floorIndex;
- (void)floorViewReplyFloorComment:(SNNewsComment*)comment;
- (void)floorViewShareFloorComment:(SNNewsComment*)comment;
- (void)floorViewDeleteFloorCommentId:(NSString *)commentId floorIndex:(int)floorIndex;
- (void)floorViewShowImageWithUrl:(NSString*)url;
- (void)setCommentMenu:(BOOL)isCommentMenu;
- (void)deleteFloorCommentId:(NSString *)commentId tag:(int)tag row:(int)row floorIndex:(int)floorIndex;

@end

@class SNWebImageView;

@interface SNFloorView : UIView <UIGestureRecognizerDelegate,SNLabelDelegate>
{//JSMenuControllerDelegate
    BOOL isLast;
    BOOL showSeparator;
    SNNewsComment *comment;
    
    UILabel *userInfoLabel;
    UILabel *floorNumLabel;
    SNLabel *contentLabel;
    SNWebImageView *picView;
    id<SNFloorViewDelegate> __weak _cell;
    SNDingService *dingService;
    NSString *newsId;
    NSString *gid;
    NSString *commentId;
    int subFloorIndex;
    BOOL showMenu;
    BOOL colseShare;
    SNNameButton *expandBtn;
}

@property(nonatomic,readwrite)BOOL isLast;
@property(nonatomic,readwrite)BOOL showSeparator;
@property(nonatomic,strong)SNNewsComment *comment;
@property(nonatomic,weak)id<SNFloorViewDelegate> cell;
@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *gid;
@property(nonatomic,strong)NSString *commentId;
@property(nonatomic,assign)int subFloorIndex;
@property(nonatomic,assign)BOOL colseShare;
@property(nonatomic,assign)BOOL showFloorNum;

@end
