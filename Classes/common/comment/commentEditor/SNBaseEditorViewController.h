//
//  SNCommentEditorViewController.h
//  sohunews
//
//  Created by jialei on 13-6-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentToolBarView.h"
#import "SNCommentEditorShareToolBar.h"
#import "SNCommentEditorPicInputView.h"
#import "SNEmoticonTabView.h"
#import "SNPostCommentService.h"
#import "SNCommentEditorRecordView.h"
#import "SNAlert.h"
#import "SNEmoticonAttachmentView.h"

#define kCommentDataKeyText         @"kCommentDataKeyText"
#define kCommentDataKeyImage        @"kCommentDataKeyImage"
#define kCommentDataKeyImagePath    @"kCommentDataKeyImagePath"
#define kCommentDataKeyVoicePath    @"kCommentDataKeyVoicePath"
#define kCommentDataKeyVoiceDuration @"kCommentDataKeyVoiceDuration"
#define kCommentDataKeyNewsId       @"newsId"
#define kCommentDataKeyGId          @"gid"
#define kCommentDataKeyRefer        @"kCommentDataKeyRefer"
#define kCommentDataKeyReplyCommentId @"replyId"
#define kCommentDataKeyReplyPid     @"replyPid"
#define kCommentDataKeyReplyType    @"replyType"

#define kCircleCommentKeyActId     @"kCircleCommentKeyActId"
#define kCircleCommentKeySpid       @"kCircleCommentKeySpid"
#define kCircleCommentKeyCommentId  @"kCircleCommentKeyCommentId"
#define kCircleCommentKeyFpid       @"kCircleCommentKeyFpid"
#define kCircleCommentKeyFname      @"kCircleCommentKeyFname"
#define kCircleCommentKeyDelegate   @"kCircleCommentKeyDelegate"

#define kCommentInputViewHeight     216
#define KTextFieldMinLines          3
#define KTextFieldMaxLines          15
#define KTextFieldFont              16

#define kTextfieldTop               (22/2)
#define kTextfieldLeft              (28/2)
#define kTextfieldHeight            (114/2)

typedef NS_OPTIONS(NSUInteger, SNCommentInputState)
{
	kSNCommentInputStateBottom          = 0,
	kSNCommentInputStateKeyboard		= 1,
    kSNCommentInputStateCamera          = 2,
    kSNCommentInputStateRecord          = 3,
	kSNCommentInputStateEmoticon		= 4
};

typedef NS_OPTIONS(NSInteger, SNCommentMediaMode)
{
	SNCommentMediaModeText		= 0,
	SNCommentMediaModePhoto		= 1,
	SNCommentMediaModeAudio		= 2,
    
    SNCommentMediaModeModeUnknown	= 99,
};

typedef NS_OPTIONS(NSInteger, SNEditorType)
{
	SNEditorTypeComment		= 0,
	SNEditorTypeShare		= 1,
};

typedef NS_OPTIONS(NSInteger, SNCommentLoginType)
{
	SNCommentLoginTypeNone          = 0,
	SNCommentLoginTypeImage         = 1,
	SNCommentLoginTypeAudio         = 2,
};

@protocol SNCommentEditorPostDelegate <NSObject>

/*
 *发送评论方法
 *prama (NSMutableDictionary *)commentData  保存发送数据的字典，key为kCommentDataKey开始的字符串
 */
//- (void)commentWillPost:(NSMutableDictionary *)commentData sendType:(SNEditorType)sendType;

@optional
- (void)commentDidCancelPost;

- (void)textFieldDidBeginAction;

- (void)commentLogin:(id)sender;

@end

@interface SNBaseEditorViewController : SNBaseViewController<
UITextViewDelegate,
SNCommentToolBarDelegate,
SNActionSheetDelegate>
{
    UIView *_maskBackgroundView;
    UIView *_dynamicallyView;
    UIView *_textFieldBackView;
    UITextView     *_textField;
    SNCommentToolBarView  *_toolBar;
    SNCommentShareToolBar *_cmtShareBar;
    
    SNCommentInputState inputViewState;                 //输入框状态.
    SNCommentToolBarType toolBarType;                   //输入框类型.
    SNCommentMediaMode _mediaMode;                      //输入的媒体类型
    SNEditorType editorType;                            //编辑类型
    SNCommentLoginType  loginType;                      //登录提示类型
    
    SNPicInputView *_picInputView;                       //照片选取
    SNRecordView   *_recordView;                         //录音
    SNEmoticonTabView *_emoticonView;                    //表情
    
    SNAlert        *_confirmAlertView;                   //提示框
    UILabel        *_tipLabel;
    
    NSMutableDictionary  *_sendEmoticonDic;              //要发送的文本
    
    BOOL isViewVisible;
    BOOL isFirstLoadView;
    BOOL isKeyboardShown;
    
    float   touchStartPointY;
    float   _keyBoardHeight;                              //键盘高度
    BOOL    isChangeKeyboardHeight;
    BOOL    _needTextView;
    
    int     _textLines;
    int     _maxHeight;                                    //最大能显示行数
    
    NSMutableDictionary *_sendDataDictionary;             //保存发送数据
}

@property (nonatomic, assign) SNEditorType editorType;
@property (nonatomic, assign) SNCommentToolBarType toolBarType;
@property (nonatomic, assign) SNCommentMediaMode mediaMode;
@property (nonatomic, weak) id<SNCommentEditorPostDelegate> sendDelegateController;
@property (nonatomic, strong) NSMutableDictionary *sendDataDictionary;
@property (nonatomic, strong) SNAlert *confirmAlertView;
@property (nonatomic, strong) SNSendCommentObject *cacheComment;

@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSString *alertSubMessage;
@property (nonatomic, strong) NSString *alertCancelTitle;
@property (nonatomic, strong) NSString *alertOtherTitle;

@property (nonatomic, strong) NSMutableAttributedString *sendAttributedString;
@property (nonatomic, strong) UITextView *textField;

@property (nonatomic, assign) BOOL noshow;

- (id)initWithParams:(NSDictionary *)infoDict;
- (void)initAllSubviews;
- (void)showTips;
- (void)popViewController;
- (void)popCallBack:(void (^)(NSDictionary* info))method;
- (void)contentsWillPost;
- (BOOL)checkNeedToLogin;
- (NSInteger)txtContentCount:(NSString*)s;
- (void)startLogin;
- (BOOL)shouldShowLogin;
- (void)fastTextInsertText:(NSString *)text selectRange:(NSRange)sRange markedRange:(NSRange)mRange;
- (void)fastTextDeleteText;
- (void)showMessage:(NSString*)message;
- (void)setMediaViewPosition:(BOOL)animation;
- (void)layoutSubViews:(SNCommentMediaMode)modeType animation:(BOOL)animation;
- (void)onBack;
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon;
- (void)emoticonDidDelete;
- (void)setTextViewFrame;
- (NSDictionary *)defaultAttributes;
- (BOOL)hasText;
- (void)insertText:(NSString *)text;
- (void)deleteBackward;
//- (NSMutableAttributedString *)parseEmoticon:(NSMutableAttributedString *)parseStr;
//组装发送string 使用[XX]形式代替图片
//- (NSString *)makeSendText;

@end
