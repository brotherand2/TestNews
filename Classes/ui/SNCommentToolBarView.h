//
//  SNCommentToolBarView.h
//  sohunews
//
//  Created by jialei on 13-6-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kToolbarButtonWidth         47
#define kToolbarButtonHeight        50
#define kToolbarButtonOriginY       0
#define kToolbarSepOriginY          22

#define kSendButtonTop              (24/2)
#define kSendButtonWidth            (96/2)
#define kSendButtonHeight           (52/2)
#define kSendButtonRight            (28/2)

@protocol SNCommentToolBarDelegate <NSObject>

@optional

- (BOOL)SNCommentToolRecordFunction;
- (BOOL)SNCommentToolCamraFunction;
- (void)SNCommentToolShareFunction;
- (void)SNCommentToolSendFunction;
- (void)SNCommentToolEmoticonFunction;

@end

typedef NS_OPTIONS(NSUInteger, SNCommentToolBarType)
{
    SNCommentToolBarTypeShowNone,
    SNCommentToolBarTypeShowAll,
	SNCommentToolBarTypeTextOnly,
	SNCommentToolBarTypeTextAndCamAndRec,
    SNCommentToolBarTypeTextAndRec,
    SNCommentToolBarTypeTextAndCam,
    SNCommentToolBarTypeTextAndEmoticon,
    SNCommentToolBarTypeTextAndEmoticonAndShare,
    SNCommentToolBarTypeTextAndRecAndEmoticonAndCam
};

@interface SNCommentToolBarView : UIView
{
    NSArray  *_funcButtons;
    
    SNCommentToolBarType commentToolBarType;
    id<SNCommentToolBarDelegate> __weak _delegate;
}

@property (nonatomic, weak) id<SNCommentToolBarDelegate> delegate;
@property (nonatomic, assign) SNCommentToolBarType commentToolBarType;
@property (nonatomic, strong) NSArray *funcButtons;
@property (nonatomic, assign) BOOL showShare;

- (void)setSendButtonEnable;
- (void)setSendButtonDisable;
- (void)changedCameraButtonState;
- (void)changedRecordButtonState;
- (void)changedEmoticonButtonState;
- (void)setArrowView:(BOOL)show;
- (void)emoticonButtonPressed;

@end
