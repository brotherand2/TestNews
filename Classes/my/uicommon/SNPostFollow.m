//
//  SNWrittingPost.m
//  Test2
//
//  Created by wangxiang on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNPostFollow.h"
#import "SNNotificationCenter.h"
#import "UIColor+ColorUtils.h"
#import "SNPhotoGalleryPlainSlideshowController.h"
#import "SNCommentActivityBtn.h"
#import "SNPhotoGallerySlideshowController.h"
#import "SNRollingNewsViewController.h"
#import "SNNewsPaperWebController.h"
#import "SNLoginRegisterViewController.h"
#import "SNSkinManager.h"
#import "SNUserManager.h"
#import "SNStoryUtility.h"
#import "SNPicturesSlideshowViewController.h"
#import "UIButton+Badge.h"
#import "SNNewsLogin.h"

#define kCommentBtnPosX         212
#define kPlaceHolderLabelTag    999
#define kTextFieldViewHeight    ((kAppScreenWidth > 375.0 ? 146.0/3 : 44))
#define CommentActivityWidth    (70)

#define kBackBtnLeft             ((kAppScreenWidth == 320.0) ? 6 : ((kAppScreenWidth == 375.0) ? 10 : 32.0/3))
#define kShareBtnLeft            ((kAppScreenWidth == 320.0) ? (kAppScreenWidth - 89) : ((kAppScreenWidth == 375.0) ? (kAppScreenWidth - 97) : (kAppScreenWidth - 316.0/3)))
#define kMoreBtnLeft             ((kAppScreenWidth == 320.0) ? (kAppScreenWidth - 38) : ((kAppScreenWidth == 375.0) ? (kAppScreenWidth - 42) : (kAppScreenWidth - 134.0/3)))
#define kMoreBtnRight            ((kAppScreenWidth == 320.0) ? 14 : ((kAppScreenWidth == 375.0) ? 18 : 62.0/3))
#define kShareBtnLeftSpace       ((kAppScreenWidth == 320.0) ? 24 : ((kAppScreenWidth == 375.0) ? 17 : 22))
#define KTextFieldRightSpace     ((kAppScreenWidth == 320.0) ? 7 : ((kAppScreenWidth == 375.0) ? 16 : 56.0/3))

#define kTextFieldLeft           ((kAppScreenWidth == 320.0) ? 44 : ((kAppScreenWidth == 375.0) ? 54 : 54))
#define kTextFieldWidth      ((kAppScreenWidth == 320.0) ? (kAppScreenWidth - 228 + 15) : ((kAppScreenWidth == 375.0) ? (kAppScreenWidth - 245 + 12) : (kAppScreenWidth - 288 + 39)))

#define kStoryTextFieldWidth      ((kAppScreenWidth == 320.0) ? (kAppScreenWidth - 228 + 15 + 40) : ((kAppScreenWidth == 375.0) ? (kAppScreenWidth - 245 + 12 + 50) : (kAppScreenWidth - 288 + 39 + 60)))

#define KTextFieldHeight    ((kAppScreenWidth == 320.0) ? 24 : ((kAppScreenWidth == 375.0) ? 24 : 76.0/3))
#define KTextFieldBorderWidth    ((kAppScreenWidth == 320.0) ? 0.5 : ((kAppScreenWidth == 375.0) ? 0.5 : 1.0/3))

#define kUpdateNubImageViewLeft         ((kAppScreenWidth == 320.0) ? 11 : 15)
#define kUpdateNubImageViewTop          ((kAppScreenWidth > 375.0 ? -3 : -5))
#define kUpdateNubImageViewHeight       (17)
#define kUpdateNubLabelHeight           (15)

@interface SNPostFollow()
@property (nonatomic, strong) UIButton *emojiBtn;
- (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText;
- (void)setButtonImages;
- (void)drawContainerView;
- (void)addAccessibilytyLabelForButtons;
- (void)startUserInfoView;
- (void)startActionSheetView;

@end

@implementation SNPostFollow

@synthesize _strPostOrComment;
@synthesize _isTouchTxtField;
@synthesize _viewController;
@synthesize _strContent;
@synthesize _textField;
@synthesize textView = _textView;
@synthesize _delegate;
@synthesize _rect;
@synthesize _activityIndicator;
@synthesize type = _type;
@synthesize keyboardShown;
@synthesize userSettingView;
@synthesize isPostFeedback;
@synthesize image = _image;
@synthesize textViewBgView = _textViewBgView;
@synthesize collectionNum = _collectionNum;
@synthesize recomInfo = _recomInfo;

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    self._delegate = nil;
    self.textView.delegate = nil;
    [self.textView removeFromSuperview];
    self.textView = nil;
    
    self._textField.delegate = nil;
    [self._textField removeFromSuperview];
    self._textField = nil;
    
    [self.textViewBgView removeFromSuperview];
    self.textViewBgView = nil;
    self._viewController = nil;
}

-(id)init
{
    if (self=[super init]) {
        //监听登出事件
        _imageUploadSupport = YES;
        self.isNOCreateCommentBtn = NO;//wangshun
        self.isNOCreateCollectBtn = NO;//wangshun
        isCreateOthersButtons = NO;
        _aryActionButton = [[NSMutableArray alloc]init];
        [SNNotificationManager addObserver:self selector:@selector(mobileNumLoginSuccess) name:kMobileNumLoginSucceedNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(mobileNumLoginSuccess) name:kBackFromBindViewControllerNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(commentLoginSucceed) name:kLoginFromArticleCommentNotification object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods
- (void)createWithType:(SNPostFollowType)type
{
    _type = type;
    
    @autoreleasepool {
        if (isPostFeedback) {
            [SNNotificationManager addObserver:self
                                      selector:@selector(keyboardWillShow:)
                                          name:UIKeyboardWillShowNotification
                                        object:nil];
            [SNNotificationManager addObserver:self
                                      selector:@selector(keyboardWillHide:)
                                          name:UIKeyboardWillHideNotification
                                        object:nil];
        }
        
        [self setButtonImages];
        
        self._isTouchTxtField = NO;

        [self drawContainerView];

        [self addTextField];
    
        [self layoutButtons];

        [self addAccessibilytyLabelForButtons];
        [self addKeyboardAccessoryInputView];
    }
}

- (void)creatUpdateNumberView {
    self.updateNubImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kUpdateNubImageViewLeft, kUpdateNubImageViewTop, 0, kUpdateNubImageViewHeight)];
    self.updateNubImageView.image = [[UIImage imageNamed:@"icozw_background_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 6) resizingMode:UIImageResizingModeStretch];
    self.updateNubImageView.hidden = YES;
    [_textFieldBgView addSubview:self.updateNubImageView];
    
    self.updateNubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, kUpdateNubLabelHeight)];
    self.updateNubLabel.textColor = SNUICOLOR(kThemeText5Color);
    self.updateNubLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
    self.updateNubLabel.textAlignment = NSTextAlignmentCenter;
    [self.updateNubImageView addSubview:self.updateNubLabel];
}

- (void)setUpdateNumber:(NSInteger)number backWhere:(NSString *)backWhere
{
    if (number == 0) {
        return;
    } else if (number == -1) {
        self.updateNubLabel.text = @"有新内容";
    }else if (number > 0) {
        if (number > 99) {
            self.updateNubLabel.text = [NSString stringWithFormat:@"99+新内容",number];
        } else {
            self.updateNubLabel.text = [NSString stringWithFormat:@"%d新内容",number];
        }
    }
    _backWhere = backWhere;
    self.updateNubImageView.hidden = NO;
    CGSize durationSize = [self.updateNubLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
    self.updateNubLabel.width = durationSize.width + 10;
    self.updateNubImageView.width = durationSize.width + 10;
}

- (void)setButtonImages
{
    _aryImgNomal = [NSMutableArray array];
    _aryImgPress = [NSMutableArray array];
    
    switch (_type) {
        case SNPostFollowTypeBackAndCommentAndCollectionAndShare: {
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_back_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_backpress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_collection_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_collectionpress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_share_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"]];
            
            break;
        }
        case SNPostFollowTypeBackAndCommentAndShare: {
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_back_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_backpress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_share_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"]];
            
            break;
        }
        case SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh: {
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_back_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_backpress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotab_close_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotab_closepress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_collection_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_collectionpress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_share_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"]];
            
            [_aryImgNomal addObject:[UIImage themeImageNamed:@"icotext_more_v5.png"]];
            [_aryImgPress addObject:[UIImage themeImageNamed:@"icotext_morepress_v5.png"]];
            
            break;
        }
        default:
            break;
    }
}

- (void)drawContainerView
{
    UIImageView *containerView = nil;
    UIImage  *bgImg = nil;
    CGRect parentViewRect = _viewController.view.frame;
    parentViewRect.size.height = kAppScreenHeight;
    
    switch (_type) {
        case SNPostFollowTypeBackAndCommentAndCollectionAndShare:
        case SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh:
        case SNPostFollowTypeBackAndCommentAndShare: {
            bgImg = [UIImage themeImageNamed:@"postTab.png"];
            containerView = [[UIImageView alloc] initWithImage:nil];
            containerView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
            containerView.alpha = 0.95;
            containerView.frame = CGRectMake(0, parentViewRect.size.height - bgImg.size.height, TTScreenBounds().size.width, bgImg.size.height);
            break;
        }
        default:
            break;
    }

    containerView.frame = CGRectMake(0,parentViewRect.size.height - kPostFollowHeight,kAppScreenWidth,kPostFollowHeight);
    containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//既然所有type都走 那就不用if
    if(_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare || _type == SNPostFollowTypeBackAndCommentAndShare)
    {
        if(!_shadowImageView)
        {
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
            UIImage *shadowImg = [[UIImage themeImageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
            _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -shadowImg.size.height, TTScreenBounds().size.width, shadowImg.size.height)];
            _shadowImageView.image = shadowImg;
            [containerView addSubview:_shadowImageView];
        }
    }
    
    // for : 拍照等情况会隐藏statusbar postfollow位置会算错 by jojo
    if (parentViewRect.origin.y == -20 || parentViewRect.size.height == [UIScreen mainScreen].bounds.size.height)
        containerView.top += parentViewRect.origin.y;

    self._rect = containerView.frame;
    
    containerView.userInteractionEnabled = YES;
    self.textFieldBgView = containerView;
    
//    if (self.textFieldBgView) {
//        [self.textFieldBgView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    }

    [_viewController.view addSubview:_textFieldBgView];
     containerView = nil;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    NSLog(@"============== %@",change);
//    NSLog(@"%@",change);
//}

- (void)updateContainerView
{
    if(_shadowImageView)
        _shadowImageView.image = [UIImage themeImageNamed:@"icotabbar_shadow_v5.png"];
}

- (void)addTextField
{
    if (_type != SNPostFollowTypeBackAndCommentAndShare) {
        return;
    }
    float width = 0.0;
    float left  = 10;
    
    UIImage *imgField = [UIImage themeImageNamed:@"post.png"];
    
    switch (_type) {
        case SNPostFollowTypeBackAndCommentAndCollectionAndShare:
            left = kTextFieldLeft;
            width = kTextFieldWidth;
            break;
        case SNPostFollowTypeBackAndCommentAndShare:
            left = kTextFieldLeft;
            width = kStoryTextFieldWidth;
        default:
            break;
    }
    
    CGFloat tempTop = (_textFieldBgView.height - KTextFieldHeight - kPostFollowBottomHeight)/2.0f;
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(left,tempTop,width,KTextFieldHeight)];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    if(_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare || _type == SNPostFollowTypeBackAndCommentAndShare)
    {
        textField.layer.borderColor = [SNSkinManager color:SkinIconCanTouch].CGColor;
        textField.layer.borderWidth = KTextFieldBorderWidth;
    }
    else
    {
        textField.frame = CGRectMake(left, tempTop + 2.5, width, KTextFieldHeight);
        textField.background = imgField;
    }
    textField.exclusiveTouch = YES;
    self._textField = textField;
     textField = nil;
    //_textField.alpha = 0;
    [_textFieldBgView  addSubview:_textField];
    
    //placeholder
    UIView *phContainer = [[UIView alloc] initWithFrame:self._textField.bounds/*CGRectMake(5,1,0,30)*/];
    phContainer.userInteractionEnabled = NO;
    phContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *placeholder = [[UILabel alloc] init];
    placeholder.tag = kPlaceHolderLabelTag;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    placeholder.frame = CGRectMake(0,0,width,phContainer.height);
    //placeholder.top += 7;
    placeholder.userInteractionEnabled = NO;
    placeholder.font = [UIFont systemFontOfSize:13.0f];
    placeholder.backgroundColor = [UIColor clearColor];
    placeholder.textAlignment = NSTextAlignmentLeft;
    placeholder.textColor = [UIColor grayColor];
    placeholder.text = _strPostOrComment;
    if(_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare || _type == SNPostFollowTypeBackAndCommentAndShare)
    {
        placeholder.frame = phContainer.bounds;
        placeholder.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        placeholder.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    }
    placeholder.left = 8;
    [phContainer addSubview:placeholder];
    [_textField  addSubview:phContainer];
    [self addEmojiButton];
     placeholder = nil;
     phContainer = nil;
}

- (void)layoutButtons
{
    if(_type != SNPostFollowTypeBackAndCommentAndShare){
           return;
    }
    if (_aryImgNomal != nil) {
        int iTag = 0;
        
        for (int i = 0; i < [_aryImgNomal count]; i++) {
            
            if (i == 1 && (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type || _type == SNPostFollowTypeBackAndCommentAndShare)) {
                iTag++;
                
                CGFloat commentBtnHeight = _textFieldBgView.height - kPostFollowBottomHeight;
                
                CGRect rect = CGRectMake(_textField.right + KTextFieldRightSpace, 1, CommentActivityWidth, commentBtnHeight);
                
                
                _commentBtn = [[SNCommentActivityBtn alloc] initWithFrame:rect];
                _commentBtn.clipsToBounds = YES;
                [_commentBtn addTarget:self selecor:@selector(doShare:)];
                _commentBtn.tag = iTag;
                [_textFieldBgView addSubview:_commentBtn];
//                _commentBtn.alpha = 0;
                //_commentBtn = nil;
            }
            
            iTag++;
            UIImage *imgNomal = [_aryImgNomal  objectAtIndex:i];
            UIImage *imgPress = [_aryImgPress objectAtIndex:i];
            UIButton *btn = [UIButton  buttonWithType :UIButtonTypeCustom];
            btn.exclusiveTouch = YES;
            
            CGFloat tempHeight = imgNomal.size.height;
            CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f+2;
            if (i == 0) {
                btn.frame = CGRectMake(btnX, tempTop, imgNomal.size.width + 10, tempHeight);
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
            } else {
                btn.frame = CGRectMake(btnX, tempTop, imgNomal.size.width, tempHeight);
            }
        
            //按5.0设计调整正文页postfollow布局, add by chengweibin
            if (_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare) {
                CGFloat tempHeight = imgNomal.size.height;
                CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f;
                switch (i) {
                    case 0://返回
                        btn.frame = CGRectMake(kBackBtnLeft, tempTop, imgNomal.size.width+10, tempHeight);
                        break;
                    case 1://收藏
                        btn.frame = CGRectMake(kShareBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        break;
                    case 2://分享
                        btn.frame = CGRectMake(kMoreBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        btn.right = kAppScreenWidth - kMoreBtnRight;
                        break;
                    default:
                        break;
                }
            } else if (_type == SNPostFollowTypeBackAndCommentAndShare) {
                CGFloat tempHeight = imgNomal.size.height;
                CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f;
                switch (i) {
                    case 0://返回
                        btn.frame = CGRectMake(kBackBtnLeft, tempTop, imgNomal.size.width+10, tempHeight);
                        break;
                    case 1://分享
                        btn.frame = CGRectMake(kMoreBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        btn.right = kAppScreenWidth - kMoreBtnRight;
                        break;
                    default:
                        break;
                }
            }
            
            [btn setImage:imgNomal forState:UIControlStateNormal];
            [btn setImage:imgPress forState:UIControlStateHighlighted];
            [btn setImage:imgPress forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
//            if (i !=0) {
//                btn.alpha = 0;
//            }
            
            [_textFieldBgView addSubview:btn];
            [_aryActionButton addObject:btn];
            btn.tag = iTag;
        }
    }
}

- (void)addAccessibilytyLabelForButtons
{
    //back btn
    //@Dan: tell what to read for blind people
    UIButton *backBtn = (UIButton *)[_textFieldBgView viewWithTag:1];
    backBtn.accessibilityLabel = @"返回";
    
    switch (_type) {
        
        case SNPostFollowTypeBackAndCommentAndCollectionAndShare:
            ((UIButton *)[_textFieldBgView viewWithTag:3]).accessibilityLabel = @"收藏";
            ((UIButton *)[_textFieldBgView viewWithTag:4]).accessibilityLabel = @"分享";
            break;
        case SNPostFollowTypeBackAndCommentAndShare:
            ((UIButton *)[_textFieldBgView viewWithTag:3]).accessibilityLabel = @"分享";
            break;
        case SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh:
            ((UIButton *)[_textFieldBgView viewWithTag:2]).accessibilityLabel = @"关闭";
            ((UIButton *)[_textFieldBgView viewWithTag:3]).accessibilityLabel = @"收藏";
            ((UIButton *)[_textFieldBgView viewWithTag:4]).accessibilityLabel = @"分享";
            ((UIButton *)[_textFieldBgView viewWithTag:5]).accessibilityLabel = @"更多";
            break;
        default:
            break;
    }
}

- (void)startActionSheetView
{
    if(_delegate!=nil && [_delegate isKindOfClass:[UIViewController class]])
    {
        UIViewController* contronler= (UIViewController*)_delegate;
        if ([contronler respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            UIActionSheet *sheetView = [[UIActionSheet alloc] initWithTitle:nil delegate:_delegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     destructiveButtonTitle:nil otherButtonTitles: @"拍照", @"用户相册", (_image!=nil ? @"移除图片" : nil),nil];
            [sheetView showInView:contronler.view];
        }
    }
}

- (void)startUserInfoView
{
    SNLoginRegisterViewController* controller = [[SNLoginRegisterViewController alloc] initWithNavigatorURL:nil query:nil];
    controller._guideLogin = YES;
    controller._delegate = self;
    controller._method = [NSValue valueWithPointer:@selector(focusInput)];
    controller._needPop = YES;
    
    if([self._viewController isKindOfClass:[SNGroupPicturesSlideshowContainerViewController class]])
    {
        SNGroupPicturesSlideshowContainerViewController *_photoSlideshowController = (SNGroupPicturesSlideshowContainerViewController *)(self._viewController);
        if ([_photoSlideshowController.delegate isKindOfClass:[SNPhotoGalleryPlainSlideshowController class]])
        {
            SNPhotoGalleryPlainSlideshowController *_photoGalleryPlainSlideshowController = (SNPhotoGalleryPlainSlideshowController *)(_photoSlideshowController.delegate);
            [_photoGalleryPlainSlideshowController.flipboardNavigationController pushViewController:controller animated:YES];
        }
        else if ([_photoSlideshowController.delegate isKindOfClass:[SNPhotoGallerySlideshowController class]])
        {
            NSNumber* needPop = [NSNumber numberWithBool:YES];
            NSNumber* guideLogin = [NSNumber numberWithBool:YES];
            NSValue* method = [NSValue valueWithPointer:@selector(focusInput)];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self,@"delegate", method,@"method" , needPop, @"needpop", guideLogin, @"guidelogin", nil];            
            [SNUtility openLoginViewWithDict:dic];
        }
    }
    else
    {
        if([self._viewController isKindOfClass:[SNPicturesSlideshowViewController class]])
        {
            NSNumber* needPop = [NSNumber numberWithBool:YES];
            NSNumber* guideLogin = [NSNumber numberWithBool:YES];
            NSValue* method = [NSValue valueWithPointer:@selector(focusInput)];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self,@"delegate", method,@"method" , needPop, @"needpop", guideLogin, @"guidelogin", nil];
            [SNUtility openLoginViewWithDict:dic];
        }
        else
            [self._viewController.flipboardNavigationController pushViewController:controller animated:YES];
    }
    
    controller = nil;
}

- (void)doPost:(id)sender{
    SNUserinfoEx* obj = (SNUserinfoEx*)[SNUserinfoEx userinfoEx];
    if (!obj || ![obj getUsername]) {
        if ([self shouldShowUserInfo]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kCommontLoginTip];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self startUserInfoView];
            return;
        }
    }
    
    int count = [self txtContentCount:[_textView.text trim]];
    if (isPostFeedback) {
        if (count > 800) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"反馈内容应不多于800个字" toUrl:nil mode:SNCenterToastModeOnlyText];
        } else if (count > 0 && count <= 800){
            if(_imageUploadSupport)
                _textView.frame = CGRectMake(TEXTVIEW_X,TEXTVIEW_Y,TEXTVIEW_W,TEXTVIEW_H);
            else
                _textView.frame = CGRectMake(5,TEXTVIEW_Y,TEXTVIEW_W+36,TEXTVIEW_H);
            self._strContent =  _textView.text;
            _textView.text = nil;
            [self returnKeyboard];
            _textViewBgViewHeight = TEXTVIEW_H+10;
            [self setTextViewFrameByContentSize];
            if (_delegate) {
                [_delegate postFollow:self andButtonTag:0];
            }
        } else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入反馈内容" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    } else {
        if (count > 1000) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"评论内容应不多于1000个字" toUrl:nil mode:SNCenterToastModeOnlyText];
        } else if ((count > 0 && count <=1000) || self.image!=nil){
            _textViewBgView.frame = CGRectMake(0,0,kAppScreenWidth, 40);
            if(_imageUploadSupport)
                _textView.frame = CGRectMake(TEXTVIEW_X,TEXTVIEW_Y,TEXTVIEW_W,TEXTVIEW_H);
            else
                _textView.frame = CGRectMake(5,TEXTVIEW_Y,TEXTVIEW_W+36,TEXTVIEW_H);
            self._strContent =  _textView.text;
            
            [self returnKeyboard];
            [self setTextViewFrameByContentSize];
            if (_delegate) {
                [_delegate postFollow:self andButtonTag:0];
            }
        } else{
            _textView.text = nil;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入评论内容" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

- (void)doShare:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    if (_type == SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh) {
        if (btn.tag == 5) {
            if (_delegate)
            {
                [_delegate h5PostFollow:self WithButton:btn];
            }
            return;
        }
    }
    
    if (_delegate)
    {
        [_delegate postFollow:self andButtonTag:(int)btn.tag];
    }
}

- (void)setLiked {
    
}

- (void)stateSelected:(int)index {
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:index];
    btn.userInteractionEnabled = NO;
    btn.selected = YES;
}

- (void)stateUnSelected:(int)index {
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:index];
    btn.userInteractionEnabled = YES;
    btn.selected = NO;
}

- (void)setButton:(int)index enabled:(BOOL)enabled {
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:index];
    btn.enabled = enabled;
}

- (void)enableInput:(BOOL)enabled {
    self._textField.enabled = enabled;
}

- (void)showLoadingAt:(int)index {
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:index];
    _activityIndicator.center = btn.center;
    btn.hidden = YES;
    [self._activityIndicator startAnimating];
}

- (void)hideLoadingAt:(int)index {
    [self._activityIndicator stopAnimating];
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:index];
    btn.hidden = NO;
}

- (void)show:(BOOL)isShow{
    if (!isShow) {
        _textFieldBgView.frame = CGRectMake(0, TTScreenBounds().size.height, kAppScreenWidth, kPostFollowHeight);

    } else {
        _textFieldBgView.frame = _rect;
    }
}

- (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText{
    float fPadding = 16.0; 
    CGSize constraint = CGSizeMake(textView.contentSize.width - fPadding, CGFLOAT_MAX);
    CGSize size = [strText sizeWithFont: textView.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    float fHeight = size.height + 16.0;
    return fHeight;
}

- (int)txtContentCount:(NSString*)s
{
	int i,n =(int)[s length],l = 0,a = 0,b = 0;
	unichar c;
	for(i = 0;i < n;i++){
		c = [s characterAtIndex:i];
		if(isblank(c)){
			b ++;
		} else if(isascii(c)){
			a ++;
		} else {
			l ++;
		}
	}
	if(a == 0 && l == 0) return 0;
	return l + (int)ceilf((float)(a + b)/2.0);
}

- (void)setCommentNum:(NSString *)commentNum {
    
    if(_type != SNPostFollowTypeBackAndCommentAndShare){
        if (self.isNOCreateCommentBtn == NO) {
            if (commentNum) {
                self.saveCommentNum = commentNum;
            }
            return;
        }
    }
    
    if (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type) {
        SNCommentActivityBtn *btn = (SNCommentActivityBtn *)[_textFieldBgView viewWithTag:2];
        NSString *title = commentNum;
        [btn setTitle:title];
        
        NSInteger offset = (kShareBtnLeft - kShareBtnLeftSpace - (btn.width)) - btn.left;
        _textField.width += offset;
        btn.right = kShareBtnLeft - kShareBtnLeftSpace;
        if(!_imageUploadSupport)
            _textField.width -= 36;
    } else if (_type == SNPostFollowTypeBackAndCommentAndShare) {
        SNCommentActivityBtn *btn = (SNCommentActivityBtn *)[_textFieldBgView viewWithTag:2];
        NSString *title = commentNum;
        [btn setTitle:title];
        
        NSInteger offset = (kMoreBtnLeft - kShareBtnLeftSpace - (btn.width)) - btn.left;
        _textField.width += offset;
        btn.right = kMoreBtnLeft - kShareBtnLeftSpace;
    }
    self.emojiBtn.left = _textField.width - KTextFieldHeight - 3;
    
}

- (void)setCommentRead:(BOOL)hasRead
{
    SNCommentActivityBtn *btn = (SNCommentActivityBtn *)[_textFieldBgView viewWithTag:2];
    [btn setCommentRead:hasRead];
}

- (void)setCommentBtnLoading:(BOOL)bLoading
{
    if (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type || _type == SNPostFollowTypeBackAndCommentAndShare) {
        SNCommentActivityBtn *btn = (SNCommentActivityBtn *)[_textFieldBgView viewWithTag:2];
        [btn showLoading:bLoading];
    }
}

- (void)setCommentBtnEnable:(BOOL)enable
{
    if (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type || _type == SNPostFollowTypeBackAndCommentAndShare) {
        SNCommentActivityBtn *btn = (SNCommentActivityBtn *)[_textFieldBgView viewWithTag:2];
        [btn setEnable:enable];
    }

}

- (void)setShareBtnEnabel:(BOOL)enable
{
    UIButton *btn = nil;
    if (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type) {
        btn = (UIButton *)[_textFieldBgView viewWithTag:4];
    } else if (_type == SNPostFollowTypeBackAndCommentAndShare) {
        btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    }

    
    if (btn) {
        btn.enabled = enable;
    }
}

- (void)setUploadImageSuported:(BOOL)aSupport{
    _imageUploadSupport = aSupport;
}

#pragma mark -
#pragma mark Private Methods

- (void)addKeyboardAccessoryInputView {
    
    if (isPostFeedback) {
        _textViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight, 0, 0)];
        _textViewBgView.clipsToBounds = NO;
        _textViewBgView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPostTextViewBgColor]];
        [_viewController.view addSubview:_textViewBgView];
    }
    else {
        UIView *viewSend = [[UIView alloc] initWithFrame:CGRectMake(0,0,kAppScreenWidth,TEXTVIEW_H+10)];
        viewSend.clipsToBounds = NO;
        viewSend.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPostTextViewBgColor]];
        [_textField setInputAccessoryView:viewSend];
        self.textViewBgView = viewSend;
    }
    
    //shadow
    UIImage* shadowImg = [UIImage imageNamed:@"postFollow_shadow.png"];
    UIImageView* shadowImgView = [[UIImageView alloc] initWithImage:shadowImg];
    shadowImgView.frame = CGRectMake(0, -9, kAppScreenWidth, 9);
    shadowImgView.tag = 102;
    [self.textViewBgView addSubview:shadowImgView];
    
    UIImage *imgNomal = [UIImage imageNamed:@"postNomal.png"];
    UITextView *postTextView = [[UITextView  alloc] initWithFrame:CGRectMake(TEXTVIEW_X,TEXTVIEW_Y,TEXTVIEW_W,TEXTVIEW_H)];
    postTextView.returnKeyType = UIReturnKeyDefault;
    postTextView.font = [UIFont  systemFontOfSize:15];
    postTextView.layer.masksToBounds = YES;
    postTextView.scrollEnabled = NO;
    postTextView.layer.cornerRadius = 3;
    postTextView.layer.borderColor = [[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.0] CGColor];
    postTextView.layer.borderWidth = 0.7;
    postTextView.delegate = self;
    postTextView.exclusiveTouch = YES;
    postTextView.textColor = [UIColor blackColor];
    postTextView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentPostBgColor]];
    
    if (nil != self.textView) {
        [self.textView removeFromSuperview];
    }

    self.textView = postTextView;
    [_textViewBgView addSubview:_textView];
    
    UIButton *btnPost= [UIButton buttonWithType:UIButtonTypeCustom];
    btnPost.frame = CGRectMake(kAppScreenWidth-65,2.5,imgNomal.size.width,imgNomal.size.height);
    [btnPost setBackgroundImage:imgNomal  forState:UIControlStateNormal];
    //[btnPost setBackgroundImage:imgPress forState:UIControlStateHighlighted];
    btnPost.exclusiveTouch = YES;
    //[btnPost setTitle:@"发表" forState:UIControlStateNormal];
    
    //@Dan: tell what to read for blind people
    btnPost.accessibilityLabel = @"发表评论";
    
    [btnPost setTitleColor:kThemeColor forState:UIControlStateNormal];
    [btnPost.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btnPost addTarget:self action:@selector(doPost:) forControlEvents:UIControlEventTouchUpInside];
    btnPost.tag = 101;
    [_textViewBgView addSubview:btnPost];
    
    //反馈置灰
    if(_imageUploadSupport)
    {
        UIButton *userSetting = [UIButton buttonWithType:UIButtonTypeCustom];
        userSetting.contentMode= UIViewContentModeScaleAspectFit;
        userSetting.exclusiveTouch = YES;
        userSetting.frame = CGRectMake(5, 5, 31, 31);
        [userSetting setImage:[UIImage themeImageNamed:@"post_comment_img_add.png"] forState:UIControlStateNormal];
        [userSetting setImage:nil forState:UIControlStateHighlighted];
        [userSetting addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        userSetting.tag = 1;
        userSetting.accessibilityLabel = @"选择图片"; //@Dan: tell what to read for blind people
        [_textViewBgView addSubview:userSetting];
        
        //照片背景

        UIButton* bgView = [UIButton buttonWithType:UIButtonTypeCustom];
        bgView.contentMode= UIViewContentModeScaleAspectFit;
        bgView.frame = CGRectMake(5, 5, 31, 31);
        [bgView setImage:[UIImage imageNamed:@"post_follow_del_bg.png"] forState:UIControlStateNormal];
        [bgView addTarget:self action:@selector(changeUserName) forControlEvents:UIControlEventTouchUpInside];
        bgView.tag = 2;
        bgView.hidden = YES;
        [_textViewBgView addSubview:bgView];
    }
    else
    {
        _textView.frame = CGRectMake(5,TEXTVIEW_Y,TEXTVIEW_W+36,TEXTVIEW_H);
    }
}

- (void)resetMenuItems
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:NO];
    [menuController setMenuItems:nil];
    [menuController update];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self._delegate && [self._delegate respondsToSelector:@selector(postFollowEditor)])
    {
        if (self.bookID) {
            [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&tp=comment&bookId=%@", self.bookID]];
        }
        else{//埋点
            [SNNewsReport reportADotGif:@"_act=comment_box&_tp=clk"];
        }
        
        [self resetMenuItems];
        [self._textField resignFirstResponder];
        
        [self._delegate performSelector:@selector(postFollowEditor)];
        
        return NO;
    }
#pragma clang diagnostic pop
    
    SNDebugLog(@"textFieldShouldBeginEditing %d", !keyboardShown);
    return !keyboardShown;
}

- (void)mobileNumLoginSuccess {
//    [self._delegate performSelector:@selector(postFollowEditor)];
}

- (void)commentLoginSucceed {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self._delegate performSelector:@selector(postFollowEditor)];
#pragma clang diagnostic pop
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (self._delegate && [self._delegate respondsToSelector:@selector(textFieldDidBeginAction)])
    {
        [self._textField resignFirstResponder];
        [self._delegate performSelector:@selector(textFieldDidBeginAction)];
    }
    else
    {
        if (!isPostFeedback) {
            [_textField setInputAccessoryView:self.textViewBgView];
        }
        [NSObject  cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeFirstResponder) object:nil];
        [self performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    }
#pragma clang diagnostic pop
}

- (void)becomeFirstResponder {
    isChangeUserName = NO;
    self._isTouchTxtField = YES;
    [_textView  becomeFirstResponder];
    keyboardShown = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(postFollowDidShowKeyboard:)]) {
        [_delegate postFollowDidShowKeyboard:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location == 0 && range.length == 0 && [text isEqualToString:@"\n"]) {
        return NO;
    }
    return YES;
}

- (void)setTextViewFrameByContentSize {
    CGFloat maxHeight = 103.5f;

    CGFloat fixedWidth = _textView.frame.size.width;
    //_textView.scrollEnabled = NO;
    CGSize newSize = [_textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fminf(newSize.height, maxHeight));

    if (!CGRectEqualToRect(_textView.frame, newFrame)) {
        _textView.frame = newFrame;
        if (!isPostFeedback) {
            _textViewBgView.height = ceil(10/*9 + 5.5 * 2*/ + newFrame.size.height);
        }
        else {
            CGFloat bgViewHeight = _textViewBgView.height;
            _textViewBgView.height = ceil(10 + newFrame.size.height);
            _textViewBgView.origin = CGPointMake(_textViewBgView.origin.x, _textViewBgView.origin.y - _textViewBgView.height + bgViewHeight);
            
            _textViewBgViewHeight = _textViewBgView.height;
        }
    }

    if (_textView.frame.size.height >= maxHeight) {
        if (_textView.scrollEnabled == NO) {
            _textView.scrollEnabled = YES;
            _textView.contentOffset = CGPointMake(0, 2);
            [_textView flashScrollIndicators];
        }
    } else {
        if (_textView.scrollEnabled == YES) {
            _textView.contentOffset = CGPointMake(0, 0);
            _textView.scrollEnabled = NO;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setTextViewFrameByContentSize];
}

- (void)returnKeyboard {
    if (!isPostFeedback) {
        [_textField setInputAccessoryView:self.textViewBgView];
    }
    else {
        [self resetTextView];
    }
    self._isTouchTxtField = NO;
    [_textField resignFirstResponder];
    [_textView resignFirstResponder]; 
    _textField.text = nil;
    
    [self.userSettingView resignFirstResponder];
    //userNameTextField.text = nil;
    
    keyboardShown = NO;
    [NSObject  cancelPreviousPerformRequestsWithTarget:self selector:@selector(focusInput) object:nil];
}

- (void)onKeyboardHide
{
    if (keyboardShown) {
        keyboardShown = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(postFollowDidHideKeyboard:)]) {
            [_delegate postFollowDidHideKeyboard:self];
        }
        SNDebugLog(@"onKeyboardHide %d", keyboardShown);
    }
}

- (void)didReceiveRemoteNotify {
    if (keyboardShown) {
        [self returnKeyboard];
    }
}

- (void)focusInput {
    self._isTouchTxtField = YES;
    [_textField becomeFirstResponder];
}

- (void)changeUserName {
    if(keyboardShown) {
        if(self.image!=nil)
        {
            self.image = nil;
            UIButton* button = (UIButton*)[self.textViewBgView viewWithTag:1];
            
            [button setImage:[UIImage themeImageNamed:@"post_comment_img_add.png"] forState:UIControlStateNormal];
            [button setImage:nil forState:UIControlStateHighlighted];
            
            UIImageView* bgView = (UIImageView*)[self.textViewBgView viewWithTag:2];
            bgView.hidden = YES;
        }
        else
        {
            [self returnKeyboard];
            if(![SNUserManager isLogin])
                [self performSelector:@selector(startUserInfoView) withObject:nil afterDelay:0.3];
            else
                [self performSelector:@selector(startActionSheetView) withObject:nil afterDelay:0.3];
        }
        
    } else {
        SNDebugLog(@"self._viewController.class :%@",self._viewController.class);
        SNDebugLog(@"self._viewController.delegate.class :%@",self._viewController.class);
        if ([self._viewController isKindOfClass:[SNGroupPicturesSlideshowContainerViewController class]]) {
            
            SNGroupPicturesSlideshowContainerViewController *_photoSlideshowController = (SNGroupPicturesSlideshowContainerViewController *)(self._viewController);
            SNDebugLog(@"self._viewController.delegate.class :%@",_photoSlideshowController.delegate.class);
            
            if ([_photoSlideshowController.delegate isKindOfClass:[SNPhotoGalleryPlainSlideshowController class]]) {
                
                SNPhotoGalleryPlainSlideshowController *_photoGalleryPlainSlideshowController = (SNPhotoGalleryPlainSlideshowController *)(_photoSlideshowController.delegate);
                
                [_photoGalleryPlainSlideshowController.flipboardNavigationController popViewControllerAnimated:YES];
                
            } else if ([_photoSlideshowController.delegate isKindOfClass:[SNPhotoGallerySlideshowController class]]) {
                SNPhotoGallerySlideshowController *_photoGallerySlideshowController = (SNPhotoGallerySlideshowController *)(_photoSlideshowController.delegate);
                [_photoGallerySlideshowController photoViewDidClose];
            }
            
        } else {
            //@qz 正文页 老的返回按钮 埋点
            NSString *paramString = @"act=cc&fun=102";
            if (self.recomInfo && [self.recomInfo length] > 0) {
               paramString = [paramString stringByAppendingFormat:@"&recomInfo=%@", self.recomInfo];
            }
            [SNNewsReport reportADotGif:paramString];
            
            [self backViewController];
        }
    }
}

- (void)backViewController {
    if (_commentBtn) {
        [_commentBtn removeFromSuperview];
        _commentBtn = nil;
    }
    
    UIViewController* topController = nil;
    if(self._viewController.flipboardNavigationController!=nil)
        topController = self._viewController;
    else
        topController = [TTNavigator navigator].topViewController;
    
    if (topController.flipboardNavigationController) {
        if ([_backWhere isEqualToString:SNNews_Push_Back_FocusNews]) {
            [SNNewsReport reportADotGif:@"_act=cc&fun=121"];
            //不管在那个tab，点击都回到新闻tab头条流，并刷新
            UIViewController* topController = [TTNavigator navigator].topViewController;
            [SNUtility popToTabViewController:topController];
            //tab切换到新闻
            [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
            //栏目切换到焦点
            [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
        } else if ([_backWhere isEqualToString:SNNews_Push_Back_RecomNews]) {
            [SNNewsReport reportADotGif:@"_act=cc&fun=120"];
            UIViewController* topController = [TTNavigator navigator].topViewController;
            [SNUtility popToTabViewController:topController];
            //tab切换到新闻
            [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
            [SNNotificationManager postNotificationName:SHROLLINGNEWS_PUSHTORECOMCHANNEL object:nil];
        } else {
            [topController.flipboardNavigationController popViewController];
        }
    }
}

- (int)getNavigationStackIndexOfTargetViewController:(Class)viewControllerClass {
    NSArray *_viewControllers = self._viewController.flipboardNavigationController.viewControllers;
    NSInteger _index = NSNotFound;
    for (NSInteger i = ((NSInteger)_viewControllers.count - 1); i >= 0; i--) {
        UIViewController *_vc = [_viewControllers objectAtIndex:i];
        if ([_vc isKindOfClass:viewControllerClass]) {
            _index = i;
            break;
        }
    }
    return _index;
}

- (int)getNavigationStackIndexOfTargetViewControllerEx:(Class)viewControllerClass controller:(UIViewController*)aController {
    NSArray *_viewControllers = aController.flipboardNavigationController.viewControllers;
    NSInteger _index = NSNotFound;
    for (NSInteger i = ((NSInteger)_viewControllers.count - 1); i >= 0; i--) {
        UIViewController *_vc = [_viewControllers objectAtIndex:i];
        if ([_vc isKindOfClass:viewControllerClass]) {
            _index = i;
            break;
        }
    }
    return _index;
}

- (void)refreshCollectionImage
{
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    if (_isLiked == YES) {
        [btn setImage:[UIImage themeImageNamed:@"icotext_collection-done_v5.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage themeImageNamed:@"icotext_collection-donepress_v5.png"] forState:UIControlStateHighlighted];
    }
    else{
        [btn setImage:[UIImage themeImageNamed:@"icotext_collection_v5.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage themeImageNamed:@"icotext_collectionpress_v5.png"] forState:UIControlStateHighlighted];
    }
}

- (void)hideCollectionView:(BOOL)isHidden{
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    
    btn.hidden = isHidden;
}

- (void)showCollectionAnimation{
    
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    
    UIImage *image = nil;
    if (_isLiked == YES) {
        image = [UIImage themeImageNamed:@"icofloat_number-plus_v5.png"];
        _collectionNum++;
    }
    else{
        image = [UIImage themeImageNamed:@"icofloat_number-reduce.png"];
        if (_collectionNum <= 0) {
            _collectionNum = 0;
        }
        else{
            _collectionNum--;
        }
    }
    [self refreshButton:btn badgeValue:_collectionNum];
    
    UIView *view = [btn viewWithTag:500001];
    if (view != nil) {
        [view removeFromSuperview];
    }
    
    
    UIImageView *badgeImage = [[UIImageView alloc] initWithImage:image];
    badgeImage.frame = CGRectMake(btn.badge.origin.x, 0, image.size.width, image.size.height);
    badgeImage.centerX = btn.badge.centerX;
    badgeImage.tag = 500001;
    badgeImage.alpha = 0;
    [btn addSubview:badgeImage];
   
    [UIView beginAnimations:nil context:nil];//标记动画块开始
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];//定义动画加速和减速方式
    [UIView setAnimationDuration:0.35];//动画时长
    [UIView setAnimationDelegate:self];
    badgeImage.top = -20;
    badgeImage.alpha = 1;
    //动画结束后回调方法
    [UIView setAnimationDidStopSelector:@selector(showArrowDidStop:finished:context:)];
    [UIView commitAnimations];//标志动滑块结束
   
    [self shakeAnimationForView:btn.imageView];
}

- (void)showArrowDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hiddenAnimation) userInfo:Nil repeats:NO];
}

-(void)hiddenAnimation
{
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    
    UIImageView *badgeImage = (UIImageView *)[btn viewWithTag:500001];
    [UIView animateWithDuration:0.35 animations:^{
        badgeImage.top = -40;
        badgeImage.alpha = 0;
    } completion:^(BOOL finished) {
        [badgeImage removeFromSuperview];
    }];
}

- (void)refreshButton:(UIButton *)button badgeValue:(int)badgeValue{
    //SNDebugLog(@"wangshun ::::%d",badgeValue);
    if (badgeValue <= 0) {
        button.badgeValue = @" ";
    }
    else if (badgeValue < 10000) {
        button.badgeValue = [NSString stringWithFormat:@"%d", badgeValue];
    }
    else if (badgeValue < 100000){
        if (badgeValue % 10000 >= 500) {
            button.badgeValue = [NSString stringWithFormat:@"%.1f万", badgeValue / 10000.0];
        }
        else{
            button.badgeValue = [NSString stringWithFormat:@"%d万", badgeValue / 10000];
        }
    }
    else {
        button.badgeValue = @" ...";
    }
    button.badgeBGColor = [UIColor clearColor];
    button.badgeTextColor = SNUICOLOR(kThemeText3Color);
}

- (void)shakeAnimationForView:(UIView *) view
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 1.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.08, 1.08, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.02, 1.02, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.0)]];
    
    animation.values = values;
    [view.layer addAnimation:animation forKey:nil];
}

- (void)setCollectionNum:(int)collectionNum{
    
    if(_type != SNPostFollowTypeBackAndCommentAndShare){
        if (self.isNOCreateCollectBtn == NO) {
            if (collectionNum) {
                self.saveCollectNum = collectionNum;
            }
            return;
        }
    }
    
    _collectionNum = collectionNum;
    UIButton *btn = (UIButton *)[_textFieldBgView viewWithTag:3];
    
    [self refreshButton:btn badgeValue:collectionNum];
}

-(void)refreshUserBtn
{
    UIButton *userBtn =  (UIButton *)[_textFieldBgView viewWithTag:1];

    UIImage *imgNomal = [UIImage themeImageNamed:@"tb_new_back.png"];
    UIImage *imgPress = [UIImage themeImageNamed:@"tb_new_back_hl.png"];
    
    [userBtn setImage:imgNomal forState:UIControlStateNormal];
    [userBtn setImage:imgPress forState:UIControlStateHighlighted];
    [userBtn setImage:imgPress forState:UIControlStateSelected];
}

- (void)changeUserNameInternal
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHaveChangedUserName"]; 
    [[NSUserDefaults standardUserDefaults] synchronize];
    isChangeUserName = YES;
    [self changeUserName];
}

+ (NSString *)currentUserName
{
    if([SNUserManager getNickName])
        return [SNUserManager getNickName];
    else
        return kDefaultUserName;
}

- (void)showKeyboard
{
    [NSObject  cancelPreviousPerformRequestsWithTarget:self selector:@selector(focusInput) object:nil];
    keyboardShown = YES;
    // 评论数为0时进入评论列表，未调出输入框
    [self performSelector:@selector(focusInput) withObject:nil afterDelay:0.4];
}

- (void)updateTheme
{
    [self refreshUserBtn];
    [self setButtonImages];
    [self updateContainerView];
    if(_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare || _type == SNPostFollowTypeBackAndCommentAndShare)
    {
        _textFieldBgView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
        UILabel* placeHolderLabel = (UILabel*)[_textField viewWithTag:kPlaceHolderLabelTag];
        if(placeHolderLabel)
            placeHolderLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];

        _textField.layer.borderColor = [SNSkinManager color:SkinIconCanTouch].CGColor;
    }
    else
    {
        UIImage *imgField = [UIImage themeImageNamed:@"post.png"];
        _textField.background = imgField;
    }

    int num = (int)[_aryImgNomal count];
    for (int i = 0; i < num; i++) {

        if(_aryActionButton.count<=i){//当数组里没有那么多btn
            break;
        }
        UIButton *btn = [_aryActionButton objectAtIndex:i];
        UIImage *imgNomal = [_aryImgNomal  objectAtIndex:i];
        UIImage *imgPress = [_aryImgPress objectAtIndex:i];
        
        [btn setImage:imgNomal forState:UIControlStateNormal];
        [btn setImage:imgPress forState:UIControlStateHighlighted];
        [btn setImage:imgPress forState:UIControlStateSelected];
    }
    
    //accecoryView
    self.textViewBgView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPostTextViewBgColor]];
    
    UIImageView *shadowImgView = (UIImageView *)[self.textViewBgView viewWithTag:102];
    shadowImgView.image = [UIImage imageNamed:@"postFollow_shadow.png"];
    _textView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentPostBgColor]];
    
    UIButton *btnPost = (UIButton *)[_textViewBgView viewWithTag:101];
    [btnPost setBackgroundImage:[UIImage imageNamed:@"postNomal.png"] forState:UIControlStateNormal];

    if(_imageUploadSupport) {
        UIButton *userSetting = (UIButton *)[_textViewBgView viewWithTag:1];
        [userSetting setImage:[UIImage themeImageNamed:@"post_comment_img_add.png"] forState:UIControlStateNormal];
        
        UIButton *bgView = (UIButton *)[_textViewBgView viewWithTag:2];
        [bgView setImage:[UIImage imageNamed:@"post_follow_del_bg.png"] forState:UIControlStateNormal];
    }
    [self refreshCollectionImage];
}

-(void)postCommentSucccess
{
    _textView.text = nil;
    
    self.image = nil;
    UIButton* button = (UIButton*)[self.textViewBgView viewWithTag:1];
    [button setImage:[UIImage themeImageNamed:@"post_comment_img_add.png"] forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    
    UIImageView* bgView = (UIImageView*)[self.textViewBgView viewWithTag:2];
    bgView.hidden = YES;
}

-(void)postCommentFailure
{
}

- (BOOL)shouldShowUserInfo
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:kCommontLoginTip];
    if (data && [data isKindOfClass:[NSDate class]])
    {
        return [(NSDate *)[data dateByAddingTimeInterval:kCommontLoginTipInterval] compare:[NSDate date]] < 0;
    }
    else
    {
        return YES;
    }
}

- (void)resetTextView {
    _textViewBgView.hidden = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;

    CGFloat bgHeight = 0;
    CGFloat bgOriginY = 0;
    if (_textViewBgViewHeight == 0 || _textView.text.length == 0) {
        bgHeight = TEXTVIEW_H+10;
        bgOriginY = kAppScreenHeight - kSystemBarHeight - keyboardSize.height - TEXTVIEW_H+10;
    }
    else {
        bgHeight = _textViewBgViewHeight;
        bgOriginY = kAppScreenHeight - kSystemBarHeight - keyboardSize.height - _textViewBgViewHeight + 20;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        bgOriginY = bgOriginY - 20;
    }
    _textViewBgView.frame = CGRectMake(0, bgOriginY, kAppScreenWidth, bgHeight);
    _textViewBgView.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [SNNotificationManager postNotificationName:kHideKeyBoardFromChatBackNotification object:nil];
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

#pragma mark - H5NewsSwitch Methods

- (void)createInitStatus{
    
    if (isPostFeedback) {
        [SNNotificationManager addObserver:self
                                  selector:@selector(keyboardWillShow:)
                                      name:UIKeyboardWillShowNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(keyboardWillHide:)
                                      name:UIKeyboardWillHideNotification
                                    object:nil];
    }
    
    self._isTouchTxtField = NO;
    
    [self drawContainerView];

    [self createFirstBackBtn];
    
    [self addAccessibilytyLabelForButtons];
    [self addKeyboardAccessoryInputView];
}

- (void)createFirstBackBtn{
    //创建第一个back
    int iTag = 1;
    UIImage *imgNomal = [UIImage themeImageNamed:@"icotext_back_v5.png"];
    UIImage *imgPress = [UIImage themeImageNamed:@"icotext_backpress_v5.png"];
    
    UIButton *btn = [UIButton  buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    
    CGFloat tempHeight = imgNomal.size.height;
    CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f+2;

    btn.frame = CGRectMake(btnX, tempTop, imgNomal.size.width + 10, tempHeight);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    btn.frame = CGRectMake(kBackBtnLeft, tempTop, imgNomal.size.width+10, tempHeight);
    [btn setImage:imgNomal forState:UIControlStateNormal];
    [btn setImage:imgPress forState:UIControlStateHighlighted];
    [btn setImage:imgPress forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
    
    [_textFieldBgView addSubview:btn];
    [_aryActionButton addObject:btn];
    btn.tag = iTag;
}

- (void)setH5WebType:(SNPostFollowType)type{
    self.type = type;
    
    [self setButtonImages];
    
    switch (self.type) {
        case SNPostFollowTypeBackAndCommentAndCollectionAndShare:
        {
            [self createTextField];
        }
            break;
        case SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh:
        {
            
        }
            break;
            
        default:
            break;
    }

    [self createOthersButtons];

    [self performSelector:@selector(layoutButtonsAgain) withObject:nil afterDelay:0.1];
}

//再次create button
- (void)layoutButtonsAgain{
    [UIView animateWithDuration:0.25 animations:^{
        
        for (UIButton* b in _aryActionButton) {
            b.alpha = 1.0;
        }
        _commentBtn.alpha = 1;
        self._textField.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.saveCommentNum) {
            [self setCommentNum:self.saveCommentNum];
        }
    }];
}

- (void)createTextField{
    if (self._textField) {
        return;
    }
    
    float width = 0.0;
    float left  = 10;
    
    left = kTextFieldLeft;
    width = kTextFieldWidth;
    
    CGFloat tempTop = (_textFieldBgView.height - KTextFieldHeight - kPostFollowBottomHeight)/2.0f;
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(left,tempTop,width,KTextFieldHeight)];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    textField.layer.borderColor = [SNSkinManager color:SkinIconCanTouch].CGColor;
    textField.layer.borderWidth = KTextFieldBorderWidth;
    
    textField.exclusiveTouch = YES;
    self._textField = textField;
    [_textFieldBgView addSubview:_textField];
    textField = nil;
    _textField.alpha = 0;

    //placeholder
    UIView *phContainer = [[UIView alloc] initWithFrame:self._textField.bounds/*CGRectMake(5,1,0,30)*/];
    phContainer.userInteractionEnabled = NO;
    phContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *placeholder = [[UILabel alloc] init];
    placeholder.tag = kPlaceHolderLabelTag;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    placeholder.frame = CGRectMake(0,0,width,phContainer.height);
    //placeholder.top += 7;
    placeholder.userInteractionEnabled = NO;
    placeholder.font = [UIFont systemFontOfSize:13.0f];
    placeholder.backgroundColor = [UIColor clearColor];
    placeholder.textAlignment = NSTextAlignmentLeft;
    placeholder.textColor = [UIColor grayColor];
    placeholder.text = _strPostOrComment;
    
    placeholder.frame = phContainer.bounds;
    placeholder.left = 8;
    placeholder.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    placeholder.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    [phContainer addSubview:placeholder];
    [_textField  addSubview:phContainer];
    [self addEmojiButton];
    placeholder = nil;
    phContainer = nil;
}

- (void)addEmojiButton {
    
    // 添加表情图标
    UIButton *emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiBtn.adjustsImageWhenHighlighted = NO;
    self.emojiBtn = emojiBtn;
    emojiBtn.frame = CGRectMake(0, 0, KTextFieldHeight, KTextFieldHeight);
    emojiBtn.left = _textField.width - KTextFieldHeight -3;
    emojiBtn.accessibilityLabel = @"添加表情";
    [emojiBtn addTarget:self action:@selector(emoticonButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    emojiBtn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    [emojiBtn setImage:[UIImage imageNamed:@"ico_emoticon_v5.png"] forState:UIControlStateNormal];
    [_textField addSubview:emojiBtn];
}

- (void)emoticonButtonPressed:(UIButton *)sender {
    if ([self._delegate respondsToSelector:@selector(h5PostFollow:emojiBtnClick:)]) {
        [self._delegate h5PostFollow:self emojiBtnClick:sender];
    }
}

- (void)createOthersButtons{
    if (isCreateOthersButtons == YES) {
        return;
    }
    isCreateOthersButtons = YES;
    
    if (_aryImgNomal != nil) {
        int iTag = 1;
        
        for (int i = 1; i < [_aryImgNomal count]; i++) {
            
            if (i == 1 && (SNPostFollowTypeBackAndCommentAndCollectionAndShare == _type)) {
                iTag++;
                
                CGFloat commentBtnHeight = _textFieldBgView.height - kPostFollowBottomHeight;
                
                CGRect rect = CGRectMake(_textField.right + KTextFieldRightSpace, 1, CommentActivityWidth, commentBtnHeight);

                _commentBtn = [[SNCommentActivityBtn alloc] initWithFrame:rect];
                _commentBtn.clipsToBounds = YES;
                [_commentBtn addTarget:self selecor:@selector(doShare:)];
                _commentBtn.tag = iTag;
                [_textFieldBgView addSubview:_commentBtn];
                self.isNOCreateCommentBtn = YES;
                if (self.saveCommentNum) {
                    [self setCommentNum:self.saveCommentNum];
                }
                _commentBtn.alpha = 0;
            }
            
            iTag++;
            UIImage *imgNomal = [_aryImgNomal  objectAtIndex:i];
            UIImage *imgPress = [_aryImgPress objectAtIndex:i];
            UIButton *btn = [UIButton  buttonWithType :UIButtonTypeCustom];
            btn.exclusiveTouch = YES;
            
            CGFloat tempHeight = imgNomal.size.height;
            CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f+2;
            if (i == 0) {
                btn.frame = CGRectMake(btnX, tempTop, imgNomal.size.width + 10, tempHeight);
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
            } else {
                btn.frame = CGRectMake(btnX, tempTop, imgNomal.size.width, tempHeight);
            }
            
            //按5.0设计调整正文页postfollow布局, add by chengweibin
            if (_type == SNPostFollowTypeBackAndCommentAndCollectionAndShare) {
                CGFloat tempHeight = imgNomal.size.height;
                CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f;
                switch (i) {
                    case 0://返回
                        btn.frame = CGRectMake(kBackBtnLeft, tempTop, imgNomal.size.width+10, tempHeight);
                        break;
                    case 1://收藏
                        btn.frame = CGRectMake(kShareBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        self.collectBtn = btn;
                        break;
                    case 2://分享
                        btn.frame = CGRectMake(kMoreBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        btn.right = kAppScreenWidth - kMoreBtnRight;
                        break;
                    default:
                        break;
                }
            }
            else if (_type == SNPostFollowTypeBackAndCloseAndCollectionAndShareAndRefresh){
                CGFloat tempHeight = imgNomal.size.height;
                CGFloat tempTop = (_textFieldBgView.height - tempHeight - kPostFollowBottomHeight)/2.0f;
                switch (i) {
                    case 0://返回
                        btn.frame = CGRectMake(kBackBtnLeft, tempTop, imgNomal.size.width+10, tempHeight);
                        break;
                    case 1://关闭
                    {
                        CGFloat xx = kBackBtnLeft + (kMoreBtnLeft-kShareBtnLeft);
                        btn.frame = CGRectMake(xx, tempTop, imgNomal.size.width, tempHeight);
                        self.closeBtn = btn;
                    }
                        break;
                    case 2://收藏
                    {
                        CGFloat xx = kShareBtnLeft - (kMoreBtnLeft-kShareBtnLeft);
                        btn.frame = CGRectMake(xx, tempTop, imgNomal.size.width, tempHeight);
                        self.collectBtn = btn;
                    }
                        break;
                        
                    case 3://share
                        btn.frame = CGRectMake(kShareBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        break;
                    case 4://more
                        btn.frame = CGRectMake(kMoreBtnLeft, tempTop, imgNomal.size.width, tempHeight);
                        btn.right = kAppScreenWidth - kMoreBtnRight;
                        break;
                    default:
                        break;
                }
            }
            
            [btn setImage:imgNomal forState:UIControlStateNormal];
            [btn setImage:imgPress forState:UIControlStateHighlighted];
            [btn setImage:imgPress forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
            
            
            if (i !=0) {
                if (self.closeBtn && btn == self.closeBtn) {
                    self.closeBtn.hidden = YES;
                }
                else{
                    btn.alpha = 0;
                }
            }
            
            [_textFieldBgView addSubview:btn];
            [_aryActionButton addObject:btn];
            btn.tag = iTag;
            
            if (self.collectBtn) {
                self.isNOCreateCollectBtn = YES;
                if (self.saveCollectNum) {
                    [self setCollectionNum:self.saveCollectNum];
                }
            }

        }
    }
}

- (void)showCloseBtn{
    if (self.closeBtn) {
        self.closeBtn.hidden = NO;
    }
}

@end
