//
//  SNCommentViewController.h
//  sohunews
//
//  Created by jialei on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController.h"
#import "FGalleryPhotoView.h"
#import "SNCommentConfigs.h"

@class SNRecordInputViewController;
@class SNSendCommentObject;
@class SNCommentShareToolBar;
@class SNWaitingActivityView;

@interface SNCommentEditorViewController : SNBaseEditorViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, SNCommentImageInputViewDelegate, SNCommentRecordViewDelegate, FGalleryPhotoViewDelegate, SNEmoticonScrollViewDelegate> {
    NSString                *_imagePath;
    UIView                  *_imageDetailView;
    NSString                *_recordFilePath;
    NSString                *_replayName;
    SNCommentEditorViewType viewType;
}

@property (nonatomic, assign) SNCommentEditorViewType viewType;
@property (nonatomic, strong) NSString *replayName;
@property (nonatomic, strong) NSString *recordFilePath;
@property (nonatomic, strong) NSString *sendImagePath;
@property (nonatomic, copy)   NSString *newsId;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) NSString *comtStatus;
@property (nonatomic, strong) NSString *comtHint;
@property (nonatomic, strong) SNSendCommentObject *sendCmtObj;//发送评论数据结构
@property (nonatomic, strong) SNTimelineOriginContentObject *shareObj;//分享数据结构
@property (nonatomic, strong) SNWaitingActivityView* activityIndicator;
@property (nonatomic, assign) BOOL isNovelComment;//小说评论
@property (nonatomic, assign) BOOL isEmoticon;


- (id)initWithParams:(NSDictionary *)infoDict;
- (void)changeInputView;
- (BOOL)isHasImageDetailView;

- (void)contentsWillPost;
- (void)autoPostComment:(id)sender;

@end
