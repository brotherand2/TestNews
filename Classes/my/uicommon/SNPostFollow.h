//
//  SNWrittingPost.h
//  Test2
//
//  Created by wangxiang on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SNDevice.h"

#define FRONT   15.0
#define BEISHU  6
#define kShadowHeight 7
#define kBtnSpaceWidth 38
#define kBtnWidth 43

#define TEXTVIEW_X 41
#define TEXTVIEW_Y 4.5
#define TEXTVIEW_W kAppScreenWidth-107
#define TEXTVIEW_H 33.5

#define kPostFollowHeight        ([[SNDevice sharedInstance] isPlus]?(146.0 / 3.0):(44.0 + kPostFollowBottomHeight))
#define kPostFollowBottomHeight  ([[SNDevice sharedInstance] isPhoneX] ? 20 : 0)
@class SNWaitingActivityView;

typedef enum {
    SNPostFollowTypeBackAndCommentAndCollectionAndShare, //普通新闻正文
    SNPostFollowTypeBackAndCommentAndShare,              //小说页
    SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh,//h5正文页底部
} SNPostFollowType;

typedef enum {
    EClosed = 0,
    EExpanding = 1,
    EExpanded = 2,
    EShrinking = 3
}SNToolBarState;

@class SNCommentActivityBtn;
@interface SNPostFollow : NSObject<UITextViewDelegate,UITextFieldDelegate>
{
    SNPostFollowType  _type;
    UIView *userSettingView;
    SNCommentActivityBtn *_commentBtn;
    BOOL isChangeUserName;
    BOOL isPostFeedback;
    CGFloat btnX;
    
    NSMutableArray *_aryImgNomal;
    NSMutableArray *_aryImgPress;
    NSMutableArray *_aryActionButton;
    //3.4 上传图片
    UIImage* _image;
    BOOL _imageUploadSupport;
    UIImageView*    _shadowImageView;
    CGFloat _textViewBgViewHeight;
    NSString *_backWhere; //记录有更新数时，正文页强制返回要闻或者推荐频道
    
    BOOL isCreateOthersButtons;//是否创建过了
}

@property (nonatomic, weak) id _delegate;
@property (nonatomic, strong)UIImageView *textFieldBgView;
@property (nonatomic, weak)UIViewController *_viewController;
@property (nonatomic, strong)NSString* _strPostOrComment;
@property (nonatomic, strong)NSString *_strContent;
@property (nonatomic, strong)UITextField *_textField;
@property (nonatomic, strong)UITextView  *textView;
@property (nonatomic, strong)UIView *userSettingView;
@property (nonatomic, assign) CGRect  _rect;
@property (nonatomic, assign)BOOL keyboardShown;
@property (nonatomic, assign) SNPostFollowType  type;
@property (nonatomic, assign)BOOL   _isTouchTxtField;
@property (nonatomic, strong)SNWaitingActivityView *_activityIndicator;
@property (nonatomic, assign)BOOL   isPostFeedback;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign)BOOL isFromPushNews;
@property (nonatomic, assign) int collectionNum;
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong)UIImageView *updateNubImageView;
@property (nonatomic, strong)UILabel *updateNubLabel;
@property (nonatomic, copy)NSString *recomInfo;//推荐流上报参数

//3.4 上传图片
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIView *textViewBgView;

@property (nonatomic, assign) BOOL isNOCreateCommentBtn;//未创建评论数btn
@property (nonatomic, strong) NSString* saveCommentNum;//存评论数
@property (nonatomic, assign) BOOL isNOCreateCollectBtn;//未创建收藏btn
@property (nonatomic, assign) NSInteger saveCollectNum;//存收藏数

@property (nonatomic, strong) UIButton* collectBtn;//存收藏数
@property (nonatomic, strong) UIButton* closeBtn;//关闭btn x

- (void)createWithType:(SNPostFollowType)type;
- (void)show:(BOOL)isShow;
- (void)returnKeyboard;
- (void)showKeyboard;
- (void)stateSelected:(int)index;
- (void)stateUnSelected:(int)index;
- (void)showLoadingAt:(int)index;
- (void)hideLoadingAt:(int)index;
- (void)setLiked;
- (void)setButton:(int)index enabled:(BOOL)enabled;
- (void)enableInput:(BOOL)enabled;
- (void)focusInput;
- (void)changeUserName;
- (void)refreshUserBtn;
- (void)updateTheme;
+ (NSString *)currentUserName;
- (void)refreshCollectionImage;
- (void)showCollectionAnimation;

- (void)setCommentNum:(NSString *)commentNum;
- (void)setCommentRead:(BOOL)hasRead;
- (void)setCommentBtnLoading:(BOOL)bLoading;
- (void)setCommentBtnEnable:(BOOL)enable;
- (void)setShareBtnEnabel:(BOOL)enable;
- (void)setUploadImageSuported:(BOOL)aSupport;
- (float)heightForTextView: (UITextView*)textView WithText:(NSString*)strText;
- (int)txtContentCount:(NSString*)p;
- (void)creatUpdateNumberView;
- (void)setUpdateNumber:(NSInteger)number backWhere:(NSString *)backWhere;
- (void)backViewController;
- (void)hideCollectionView:(BOOL)isHidden;

- (void)setH5WebType:(SNPostFollowType)type;
- (void)createInitStatus;
- (void)showCloseBtn;


@end

@protocol PostFollowDelegate <NSObject>
- (void)postFollow:(SNPostFollow*)postFollow andButtonTag:(int)iTag;
- (void)h5PostFollow:(SNPostFollow*)postFollow WithButton:(UIButton*)btn;
- (void)h5PostFollow:(SNPostFollow*)postFollow emojiBtnClick:(UIButton *)emojiBtn;
@optional
- (void)postFollowDidShowKeyboard:(SNPostFollow *)postFollow;
- (void)postFollowDidHideKeyboard:(SNPostFollow *)postFollow;
@end
