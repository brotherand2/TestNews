//
//  SNLiveRoomViewController.h
//  sohunews
//
//  Created by Chen Hong on 4/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//


#import "CacheObjects.h"
#import "SNLiveBannerView.h"
#import "SNEmbededActivityIndicator.h"
#import "SNLiveToolbar.h"
#import "SNLiveInputBar.h"
#import "SNCommentEditorPicInputView.h"
#import "SNEmoticonTabView.h"
#import "SNLiveRoomTableViewController.h"
#import "SNLiveRoomContentCell.h"
#import "SNLiveContentObjects.h"
#import "SNLiveRoomTopInfoView.h"

@class SNVideoData;

@interface SNLiveRoomViewController : SNBaseViewController<TTURLRequestDelegate, UIScrollViewDelegate, SNHeadSelectViewDelegate, SNLiveToolbarDelegate, SNLiveInputBarDelegate, SNCommentImageInputViewDelegate, UIGestureRecognizerDelegate, SNEmbededActivityIndicatorDelegate, SNLiveRoomTopInfoViewDelegate, SNActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    NSString *_replyId;//回复的父评论的ID，如果回复直播员，则是直播员的contentId，反之是用户评论的rid
    NSString *_replyType;//网友回复网友：1；网友回复直播员：2
    NSString *_replyName;
    NSString *_replyPid;//被回复人的pid
    NSString *_audioFilePath;
}

@property (nonatomic, strong) LivingGameItem *livingGameItem;
@property (nonatomic, strong) NSString *replyId;
@property (nonatomic, strong) NSString *replyType;
@property (nonatomic, strong) NSString *replyName;
@property (nonatomic, strong) NSString *replyPid;
@property (nonatomic, strong) NSString *audioFilePath;
@property (nonatomic, strong) SNLiveBannerView *liveBannerView;
@property (nonatomic, strong) NSString *liveId;

- (void)hideKeyboard;
- (void)shareAction:(NSString *)comment;
- (void)shareCommentAction:(NSDictionary *)commentDic;

- (void)showPopNewMarkAtLive:(BOOL)bShow;
- (void)showPopNewMarkAtChat:(BOOL)bShow;

- (void)showContentVideo:(SNVideoData *)videoModel
                fromCell:(SNLiveRoomContentCell *)cell
   videoPlaceHolderFrame:(CGRect)videoPlaceHolderFrame;

- (void)stopPlayingVideoInCellWhenReloadData:(SNLiveRoomTableViewController *)tableViewController;
- (void)tableViewController:(SNLiveRoomTableViewController *)tableViewController whetherShowVideoPlayerByCell:(SNLiveRoomContentCell *)cell;
- (void)tableViewController:(SNLiveRoomTableViewController *)tableViewController didEndDisplayingCell:(SNLiveRoomContentCell *)cell;

- (void)focusInput;

- (void)scrolltoVertical:(BOOL)hideFlag;

- (int)currentTabIndex;
- (LiveTableEnum)currentTabType;

@end
