 //
//  SNCommentViewController.m
//  sohunews
//
//  Created by jialei on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorViewController.h"
#import "SNBaseEditorViewController+SNLayout.h"
#import "SNStatusBarMessageCenter.h"
#import "SNNotificationCenter.h"
#import "UIImage+Utility.h"
#import "SNThemeManager.h"
#import "SNConsts.h"
#import "AMRWBRecorder.h"
#import "NSDate-Utilities.h"
#import "AMRPlayer.h"
#import "SNSoundManager.h"
#import "SNNewsCommentSoundView.h"

#import "SNGuideRegisterManager.h"
#import "SNImagePickerController.h"
#import "SNSendCommentObject.h"
#import "SNShareManager.h"
#import "SNEmoticonObject.h"

#import "SNWaitingActivityView.h"
#import "SNCacheManager.h"

#import "SNNewsLoginManager.h"
#import "SNUserManager.h"

#define kInputPicViewWidth          (68/2)
#define kInputPicViewHeight         (68/2)

#define kCommentInputViewRect CGRectMake(0, 0, kAppScreenWidth, 216)

typedef NS_OPTIONS(NSInteger, kCommentDeleteType) {
    kDeleteTypeSound,
    kDeleteTypeImage
};

@interface SNCommentEditorViewController () {
    AMRWBRecorder     *_recorder;//录音器
    FGalleryPhotoView *_photoView;
    UIImageView       *_commentPicView;
    SNNewsCommentSoundView   *_soundView;
    UIView            *_recordOverlayView;

    NSTimer           *_updateTimer;
    kCommentDeleteType _deleteType;
    BOOL              isRecordTimeOut;
    
    float             _textHeight;
    CGFloat           _lastTextViewContentHeight;
    
    NSString*         commentText;
}

@end

@implementation SNCommentEditorViewController

@synthesize viewType;
@synthesize recordFilePath = _recordFilePath;
@synthesize sendImagePath;
@synthesize replayName = _replayName;
@synthesize deleteButton;
@synthesize newsId = _newsId;
@synthesize comtHint = _comtHint;
@synthesize comtStatus = _comtStatus;

- (id)initWithParams:(NSDictionary *)infoDict {
    self = [super initWithParams:infoDict];
    if (self) {
        [self.sendDataDictionary setValuesForKeysWithDictionary:infoDict];
        
        self.viewType = [[(NSNumber *)infoDict valueForKey:kEditorKeyViewType] integerValue];
        self.toolBarType = [[(NSNumber *)infoDict valueForKey:kCommentToolBarType]integerValue];
        self.editorType = SNEditorTypeComment;
        self.comtStatus = [infoDict valueForKey:kEditorKeyComtStatus];
        self.comtHint = [infoDict valueForKey:kEditorKeyComtHint];
        self.sendCmtObj = [infoDict objectForKey:kEditorKeySendCmtObj];
        self.shareObj = [infoDict objectForKey:kEditorKeyShareCmtObj];
        self.replayName = self.sendCmtObj.replyName;
        self.newsId = self.sendCmtObj.newsId;
        NSString* noshow = [infoDict objectForKey:@"noshow"];
        if([noshow isEqualToString:@"1"]){
            self.noshow = YES;
        }
        else{
            self.noshow = NO;
        }
        
        commentText = [infoDict objectForKey:@"textfield.text"];
        
        self.isEmoticon = [[infoDict objectForKey:@"isEmoticon"] boolValue];
        [self initAllSubviews];
        _toolBar.commentToolBarType = self.toolBarType;
        _lastTextViewContentHeight = 0;
        [self addObserver];
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL
                     query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        [self.sendDataDictionary setValuesForKeysWithDictionary:query];
        
        self.viewType = [[(NSNumber *)query valueForKey:kEditorKeyViewType] integerValue];
        self.toolBarType = [[(NSNumber *)query valueForKey:kCommentToolBarType]integerValue];
        self.editorType = SNEditorTypeComment;
        self.comtStatus = [query valueForKey:kEditorKeyComtStatus];
        self.comtHint = [query valueForKey:kEditorKeyComtHint];
        self.sendCmtObj = [query objectForKey:kEditorKeySendCmtObj];
        self.shareObj = [query objectForKey:kEditorKeyShareCmtObj];
        self.replayName = self.sendCmtObj.replyName;

        [self initAllSubviews];
        _toolBar.commentToolBarType = self.toolBarType;
        _lastTextViewContentHeight = 0;
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    [SNNotificationManager addObserver:self
                              selector:@selector(becomeActiveFunction)
                                  name:UIApplicationDidBecomeActiveNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(resignActiveFunction)
                                  name:UIApplicationDidEnterBackgroundNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(shareToolBarTrigger) name:SNCECheckIconDidPressed object:nil];
    
    [SNNotificationManager addObserver:self selector:@selector(shareToolBarTrigger) name:NotificationCommentShareLoginFinished object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(didReceiveRemote)
                                  name:kNotifyDidReceive
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(DidChangeStatusBarFrameNotification)
                                  name:UIApplicationDidChangeStatusBarFrameNotification
                                object:nil];
    [SNNotificationManager addObserver:self selector:@selector(userDidTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
}

- (void)loadView {
    [super loadView];
    
    if ([self.replayName length] > 0) {
        _tipLabel.text = [NSString stringWithFormat:@"回复%@:", self.replayName];
    } else {
        NSString *saveTips = [SNUserDefaults stringForKey:kCommentRemarkTip];
        if (self.sendCmtObj.cmtText.length > 0) {
            [_textField setText:self.sendCmtObj.cmtText];
            [self textViewDidChange:_textField];
        }
        else if (saveTips.length > 0) {
            _tipLabel.text = saveTips;
        } else {
            _tipLabel.text = @"我来说两句...";
        }
    }
    
    //图片显示
    _commentPicView = [[UIImageView alloc]initWithFrame:
                       CGRectMake(kPicViewLeft, kPicViewTop, kInputPicViewWidth, kInputPicViewHeight)];
    _commentPicView.bottom = _textFieldBackView.bottom - 9;
    _commentPicView.contentMode = UIViewContentModeScaleAspectFill;
    _commentPicView.clipsToBounds = YES;
//    _commentPicView.layer.cornerRadius = 2;
    _commentPicView.hidden = YES;
    _commentPicView.alpha =  1;
    _commentPicView.userInteractionEnabled = YES;
    [_dynamicallyView insertSubview:_commentPicView belowSubview:_toolBar];
    
    //分享工具栏
    _cmtShareBar = [[SNCommentShareToolBar alloc] initWithFrame:CGRectZero];
    _cmtShareBar.showView = _cmtShareBar.hasSelectedItem;
    _cmtShareBar.hidden = YES;
    _cmtShareBar.top = _dynamicallyView.height;
    _toolBar.showShare = _cmtShareBar.hasSelectedItem;
    
    [_dynamicallyView addSubview:_cmtShareBar];

    //声音显示控件
    _soundView = [[SNNewsCommentSoundView alloc] initWithFrame:
                  CGRectMake(kPicViewLeft, kPicViewTop + 2, kInputSoundViewWidth, kInputSoundViewHeight)];
    _soundView.hidden = YES;
    _soundView.bottom = _textFieldBackView.bottom - 9;
    [_dynamicallyView insertSubview:_soundView belowSubview:_toolBar];
    
    //删除按钮
    UIButton *_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.hidden = YES;
    _deleteButton.accessibilityLabel = @"删除当前图片";
    _deleteButton.size = CGSizeMake(kDeleteButtonWidth, kDeleteButtonHeight);
    _deleteButton.left = _soundView.right;
    [_deleteButton setImage:[UIImage imageNamed:@"icopl_close_v5.png"] forState:UIControlStateNormal];
    [_deleteButton setImage:[UIImage imageNamed:@"icopl_closepress_v5.png"] forState:UIControlStateHighlighted];
    [_deleteButton setBackgroundColor:[UIColor clearColor]];
    [_deleteButton addTarget:self action:@selector(deleteButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton = _deleteButton;
    [_dynamicallyView insertSubview:self.deleteButton belowSubview:_toolBar];

    //图片点击事件
    UITapGestureRecognizer *picRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(picHandleTap:)];
    [_commentPicView addGestureRecognizer:picRecognizer];
    
    //照片选取view
    _picInputView = [[SNPicInputView alloc] initWithFrame:kCommentInputViewRect];
    _picInputView.top = _dynamicallyView.height;
    _picInputView.hidden = YES;
    _picInputView.pickerDelegate = self;
    [_dynamicallyView addSubview:_picInputView];
    
    //录音view
    _recordView = [[SNRecordView alloc] initWithFrame:kCommentInputViewRect];
    _recordView.top = _dynamicallyView.height;
    _recordView.recordDelegate = self;
    _recordView.hidden = YES;
    [_dynamicallyView addSubview:_recordView];
    
    //overlay view
    _recordOverlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _recordOverlayView.backgroundColor = [UIColor clearColor];
    _recordOverlayView.hidden = YES;
    [_dynamicallyView insertSubview:_recordOverlayView
                aboveSubview:_recordView.recordButton];
    
    _recorder = new AMRWBRecorder();
    _recorder->SetDelegate(self);
    
    //[_textField becomeFirstResponder];

    if (self.noshow == YES) {

    }
    else{
        if (commentText.length>0) {
            _textField.text = commentText?:@"";
            _tipLabel.hidden = YES;
        }
        if (self.isEmoticon) {
            inputViewState = kSNCommentInputStateKeyboard;
        } else {
            [_textField becomeFirstResponder];
        }
        [self showCommentEditorView];
        
    }
    
    //[self showCommentEditorView];
    
    [self loadCacheAttachment];
    
    //李健 2015.01.22 解决在评论页时Push后显示新页后，无法操作的问题
    [SNNotificationManager addObserver:self selector:@selector(onReceiveNotifyToBack) name:kNotifyExpressShow object:nil];
}

//截屏完收起评论页面
- (void)userDidTakeScreenshot
{
    [self popViewController];
}

- (void)keyboardDidHide
{
    if (![self isHasImageDetailView]) {
        [self changeInputView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_soundView) {
        [_soundView stopSoundPlay];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [SNNotificationManager removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [SNNotificationManager removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [SNNotificationManager removeObserver:self];
    _picInputView.pickerDelegate = nil;
    _recordView.recordDelegate = nil;
    if (_updateTimer) {
        [_updateTimer invalidate];
    }
    if (_soundView) {
        [_soundView stopSoundPlay];
    }
    if (_recorder) {
        _recorder->SetDelegate(nil);
        delete _recorder;
        _recorder = NULL;
    }
}

#pragma mark -
#pragma mark application active
- (void)shareToolBarTrigger {
    if (![_textField isFirstResponder]) {
        [self layoutSubViews:_mediaMode animation:NO];
        [self changeInputViewStateTo:kSNCommentInputStateBottom
                      keyboardHeight:_keyBoardHeight
                   animationDuration:kCEAnimationDuration];
    }
}

- (void)resignActiveFunction {
    if (_recorder && _recorder->IsRunning()) {
        [self stopRecord];
    }
//    [self changeInputViewStateTo:kSNCommentInputStateBottom
//                  keyboardHeight:0
//               animationDuration:kCEAnimationDuration];
}

- (void)becomeActiveFunction {
    isFirstLoadView = NO;
}

- (void)didReceiveRemote {
    if (_recorder && _recorder->IsRunning()) {
        //在下一个RunLoop 停止录音界面，保证推送的Altert全部做完。
        [self performSelector:@selector(stopRecord)
                   withObject:nil afterDelay:0.2];
    }
}

#pragma mark -
#pragma mark SNCommentImageInputViewDelegate
- (void)commentImageFromCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:kCameraDenyAlertText message:@"" delegate:self cancelButtonTitle:kCameraDenyAlertConfirm otherButtonTitles: nil];
        [alert show];
        return;
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        
    }
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        [[SNStatusBarMessageCenter sharedInstance] setAlpha:0];
    }
    
    SNImagePickerController *imagePicker = [[SNImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)commentImageFromPhotoLibrary {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:^(void){}];
}

#pragma mark- emoticonScrollDelegate
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon {
    [super emoticonDidSelect:emoticon];
}

- (void)emoticonDidDelete {
    [super emoticonDidDelete];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([picker respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [picker performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
    
    [[SNStatusBarMessageCenter sharedInstance] setAlpha:1];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    _mediaMode = SNCommentMediaModePhoto;
    
    if (!self.activityIndicator) {
        self.activityIndicator = [[SNWaitingActivityView alloc] init];
    }
    
    [_dynamicallyView addSubview:self.activityIndicator];
    [self layoutSubViews:_mediaMode animation:YES];
    [self setCommentStateView];
    self.activityIndicator.center = _commentPicView.center;
    [self.activityIndicator startAnimating];
    
    //等拍照视图消失再设置图像
    [self performSelector:@selector(setInputImage:) withObject:image afterDelay:0.2];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker respondsToSelector:@selector(dismissModalViewControllerAnimated:)])
        [picker performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES]];
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
    
    [[SNStatusBarMessageCenter sharedInstance] setAlpha:1];
}

#pragma mark -
#pragma mark Set InputImage Data
- (void)loadCacheAttachment {
    if (self.sendCmtObj.cmtImgae) {
        _commentPicView.image = self.sendCmtObj.cmtImgae;
        _mediaMode = SNCommentMediaModePhoto;
    } else if (self.sendCmtObj.cmtAudioPath) {
        [_soundView loadIfNeeded];
        _soundView.url = self.sendCmtObj.cmtAudioPath;
        _soundView.duration = [self.sendCmtObj.cmtAudioDuration intValue];
        _mediaMode = SNCommentMediaModeAudio;
    }
//    [self layoutSubViews:_mediaMode animation:NO];
}

- (void)setInputImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    //内存中旋转原图
    _commentPicView.image = [UIImage rotateImage:image];
    _commentPicView.alpha = themeImageAlphaValue();
    UIImage *sendImage = nil;
    
    CGSize imgSize = _commentPicView.image.size;
    //所有上传照片最大像素1080等比例压缩
    CGFloat maxPix = 1080 / 2;
    
    if (imgSize.width > imgSize.height) {
        CGFloat scale = imgSize.height / imgSize.width;
        if (imgSize.width > maxPix) {
            imgSize.width = maxPix;
            imgSize.height = scale * maxPix;
        }
    } else {
        CGFloat scale = imgSize.width/imgSize.height;
        if (imgSize.height > maxPix) {
            imgSize.height = maxPix;
            imgSize.width = scale * maxPix;
        }
    }
    _commentPicView.image = [UIImage imageWithImage:_commentPicView.image scaledToSize:imgSize];
    self.sendImagePath = [SNUtility getImageNameByDate];
    NSData *data = UIImageJPEGRepresentation(_commentPicView.image, 1);
    if (data && self.sendImagePath) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //暂时跑不通，读取的地方可能有问题，先用TT
            [[TTURLCache sharedCache] storeData:data forURL:self.sendImagePath];
        });
        sendImage = _commentPicView.image;
    }
    
    [self.activityIndicator stopAnimating];
    //李健 2015.01.20 这里在加完动画后没有将添加的view去掉，影响到下面盖住的view的手势事件了。
    [self.activityIndicator removeFromSuperview];
    [_textField becomeFirstResponder];
    if (self.sendImagePath.length > 0) {
        self.sendCmtObj.cmtImagePath = self.sendImagePath;
    }
    if (sendImage) {
        self.sendCmtObj.cmtImgae = sendImage;
    }
    _deleteType = kDeleteTypeImage;
}

#pragma mark -
#pragma mark picTouchAction
- (void)picHandleTap:(UITapGestureRecognizer *)tapGesture {
    if (inputViewState == kSNCommentInputStateKeyboard) {
        [_textField resignFirstResponder];
    }
    if (_imageDetailView == nil) {
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        applicationFrame.size.height = kAppScreenHeight;
        _imageDetailView = [[UIView alloc] initWithFrame:applicationFrame];
        _imageDetailView.backgroundColor = [UIColor blackColor];
        _imageDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectMake(0, 0, _imageDetailView.width, _imageDetailView.height)];
        _photoView.photoDelegate = self;
        
        _photoView.imageView.centerX = CGRectGetMidX(_photoView.bounds);
        _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds) + 30;
        [_imageDetailView addSubview:_photoView];
        
        if (_commentPicView.image) {
            _photoView.imageView.frame =
            CGRectMake(0, 0, _imageDetailView.frame.size.width,
                       _imageDetailView.frame.size.width / _commentPicView.image.size.width * _commentPicView.image.size.height);
            _photoView.contentSize = _photoView.imageView.size;
            if (_photoView.imageView.height < _photoView.height) {
                _photoView.imageView.centerY = CGRectGetMidY(_photoView.bounds);
            }
        }
        
        CGFloat alphaToShow = 1;
        UIImage *backImage = [UIImage imageNamed:@"photo_slideshow_back.png"];
        UIButton *btn = [[UIButton alloc]
                         initWithFrame:CGRectMake(0, _imageDetailView.height - backImage.size.height, backImage.size.width, backImage.size.height)];
        [btn setImage:backImage forState:UIControlStateNormal];
        btn.alpha = alphaToShow;
        [btn addTarget:self action:@selector(cancelViewSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        [_imageDetailView addSubview:btn];
        
        UIImage *removeImage = [UIImage imageNamed:@"cleanUp.png"];
        btn = [[UIButton alloc] initWithFrame:CGRectMake(applicationFrame.size.width - removeImage.size.width - 5, _imageDetailView.height - removeImage.size.height, 40, 40)];
        [btn setImage:removeImage forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"unCleanUp.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(removeSharedImage:) forControlEvents:UIControlEventTouchUpInside];
        [_imageDetailView addSubview:btn];
    }
    _photoView.imageView.image = _commentPicView.image;
    [[TTNavigator navigator].topViewController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _imageDetailView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)viewTaped:(UIGestureRecognizer *)rcg {
    if (_imageDetailView.alpha == 1.0) {
        [self cancelViewSharedImage:nil];
    }
}

- (void)didTapPhotoView:(FGalleryPhotoView *)photoView {
    if (_imageDetailView.alpha == 1.0) {
        [self cancelViewSharedImage:nil];
    }
}

- (void)cancelViewSharedImage:(id)sender {
    if (_imageDetailView != nil) {
        if (_imageDetailView.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            _imageDetailView.alpha = 0;
            [UIView commitAnimations];
        } else {
            [_imageDetailView removeFromSuperview];
            _imageDetailView = nil;
        }
    }
}

- (void)removeSharedImage:(id)sender {
    if (_imageDetailView != nil) {
        if (_imageDetailView.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
            _imageDetailView.alpha = 0;
            [UIView commitAnimations];
        } else {
            [_imageDetailView removeFromSuperview];
            _imageDetailView = nil;
        }
    }
    _commentPicView.image = nil;
    _commentPicView.hidden = YES;
    self.deleteButton.hidden = YES;
 
    if (self.sendCmtObj.cmtImagePath.length > 0) {
        self.sendCmtObj.cmtImagePath = nil;
    }
    if (self.sendCmtObj.cmtImgae) {
        self.sendCmtObj.cmtImgae = nil;
    }
    _mediaMode = SNCommentMediaModeText;
    [self setSendButtonState];
}

- (void)removeAnimationDidStop:(NSString *)animationID
                      finished:(NSNumber *)finished
                       context:(void *)context {
    [_textField becomeFirstResponder];
    [_imageDetailView removeFromSuperview];
    _imageDetailView = nil;
}

#pragma mark-
#pragma mark Function from base controller
- (void)setMediaViewPosition:(BOOL)animation {
    if (_mediaMode == SNCommentMediaModeAudio) {
        _deleteType = kDeleteTypeSound;
        _soundView.hidden = NO;
        self.deleteButton.hidden = NO;
    } else if (_mediaMode == SNCommentMediaModePhoto) {
        _deleteType = kDeleteTypeImage;
        _commentPicView.hidden = NO;
        self.deleteButton.hidden = NO;
    }
    [self setAnimateBlock];
}

- (void)layoutToolbars:(CGFloat)viewHeight {
    CGFloat currentKeyBoardHeight = _keyBoardHeight;
    if (inputViewState == kSNCommentInputStateBottom) {
        currentKeyBoardHeight = 0;
    }
    _toolBar.bottom = viewHeight - currentKeyBoardHeight;
    _cmtShareBar.bottom = _toolBar.top;
    if (!_cmtShareBar.hidden) {
        _cmtShareBar.bottom = _toolBar.top;
    } else {
    }
    
    if (!_commentPicView.hidden) {
        self.deleteButton.hidden = NO;
        self.deleteButton.frame = CGRectMake(_commentPicView.right, _commentPicView.top + 1, kDeleteButtonWidth, kDeleteButtonHeight);
    } else if (!_soundView.hidden) {
        self.deleteButton.hidden = NO;
        self.deleteButton.frame = CGRectMake(_soundView.right, _soundView.top + 1, kDeleteButtonWidth, kDeleteButtonHeight);
    }

}

- (void)setAnimateBlock {
    CGFloat viewHeight = _dynamicallyView.height;
    [self layoutToolbars:viewHeight];
}

- (void)DidChangeStatusBarFrameNotification {
    [self setTextViewFrame];
}

- (void)setSendButtonState {
    NSString *inputStr = [_textField.text trim];
    
    if ([inputStr length] > 0 ||
        (_commentPicView && _commentPicView.hidden == NO) ||
        (_soundView && _soundView.hidden == NO)) {
        [_toolBar setSendButtonEnable];
    } else {
        [_toolBar setSendButtonDisable];
    }
    
    if (!_soundView.hidden || !_commentPicView.hidden) {
        _tipLabel.hidden = YES;
    }
}

- (void)showTips {
    self.alertTitle = NSLocalizedString(@"GiveUpComment", @"");
    self.alertSubMessage = NSLocalizedString(@"", @"");
    self.alertCancelTitle = NSLocalizedString(@"CancelGiveUp", @"");
    self.alertOtherTitle = NSLocalizedString(@"ConfirmGiveUp", @"");
    [super showTips];
}

- (void)layoutSubViews:(SNCommentMediaMode)modeType
             animation:(BOOL)animation {
    _mediaMode = modeType;

    [self setTextViewFrame];
    [self setMediaViewPosition:animation];
    [self setSendButtonState];
}

- (void)setTextViewFrame {
    CGFloat textHeight = 0;
    CGFloat currentKeyBoardHeight = _keyBoardHeight;
    if (inputViewState == kSNCommentInputStateBottom) {
        currentKeyBoardHeight = 0;
    }
    
    _textFieldBackView.height = _textField.height;
    _dynamicallyView.height = currentKeyBoardHeight + _textField.height + kCommentToolBarHeight + kTextfieldTop;
    if (!_cmtShareBar.hidden) {
        _dynamicallyView.height += _cmtShareBar.height;
    }
    
    if (!_commentPicView.hidden || !_soundView.hidden || [self.activityIndicator superview]) {
        _textFieldBackView.height += 100/2;
        _dynamicallyView.height += 100/2;
        _commentPicView.bottom = _textFieldBackView.bottom - 9;
        _soundView.bottom = _textFieldBackView.bottom - 9;
    }
    
    if (self.isEmoticon) {
        [UIView animateWithDuration:kCEAnimationDuration animations:^{
            _dynamicallyView.bottom = self.view.height;
        }];
    } else {
        _dynamicallyView.bottom = self.view.height;
    }
    _textField.top = kTextfieldTop;
}

- (NSDictionary *)defaultAttributes {
    return [super defaultAttributes];
}

- (void)onBack {
    self.sendCmtObj.cmtText = _textField.text;
    
    [SNNotificationManager postNotificationName:NotificationCommentCache object:self.sendCmtObj];
    [SNNotificationManager postNotificationName:NotificationCommentEditorPop object:nil];
    [super onBack];
}

- (void)onBackCallBack:(void (^)(NSDictionary* info))method{
    self.sendCmtObj.cmtText = _textField.text;
    
    [SNNotificationManager postNotificationName:NotificationCommentCache object:self.sendCmtObj];
    [SNNotificationManager postNotificationName:NotificationCommentEditorPop object:nil];
    
    [super popCallBack:^(NSDictionary *info) {
        if (method) {
            method(nil);
        }
    }];
}

- (void)onReceiveNotifyToBack {
    self.sendCmtObj.cmtText = _textField.text;
    [super onBack];
}

- (void)setCommentStateView
{
    if (inputViewState == kSNCommentInputStateCamera) {
        _picInputView.top = _toolBar.bottom;
    } else if (inputViewState == kSNCommentInputStateRecord) {
        _recordView.top = _toolBar.bottom;
    } else if (inputViewState == kSNCommentInputStateEmoticon) {
        _emoticonView.top = _toolBar.bottom;
    }
}

#pragma mark-
#pragma mark SNCommentRecordViewDelegate
- (void)snRecordChangedBegin {
    isRecordTimeOut = NO;
    [self snRecordStateChanged];
}

- (void)snRecordChangedEnd {
    if (!isRecordTimeOut) {
        [self snRecordStateChanged];
    }
}

- (void)snRecordStateChanged {
    if (_recorder && _recorder->IsRunning())
        // If we are currently recording, stop and save the file.
	{
        [self stopRecord];
	} else {
        // If we're not recording, start
		// Start the recorder
        _recordOverlayView.hidden = NO;
        
        NSString *name = [NSDate stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
        name = [name stringByAppendingString:@".amr"];
        self.recordFilePath = [[[TTURLCache sharedCache] cachePath] stringByAppendingPathComponent:name];
        
        if (_recorder) {
            _recorder->StartRecord((__bridge CFStringRef)_recordFilePath);
        }
        
        [self startLevelMeterTimer];
	}
}

- (void)startLevelMeterTimer {
    if (_updateTimer) {
        [_updateTimer invalidate];
    }
    _updateTimer = [NSTimer
                     scheduledTimerWithTimeInterval:0.2
                     target:self
                     selector:@selector(refreshLevelMeter)
                     userInfo:nil
                     repeats:YES];
}

- (void)refreshLevelMeter {
    float avgPower, peakPower;
    int durationTime = _recorder->GetFileDuration();
    if (durationTime > kMaxRecordTime) {
        isRecordTimeOut = YES;
        [self stopRecord];
        [self showMessage:NSLocalizedString(@"audioDurationTooLong", @"")];
    }
    _recorder->UpdateLevelMeter(&avgPower, &peakPower);
    _recordView.timerLabel.text = [NSString stringWithFormat:@"%d\"", durationTime];
    
    //音量显示
    [_recordView powerValueChange:avgPower];
}

- (void)stopRecord {
    
    _recordOverlayView.hidden = YES;
    [_updateTimer invalidate];
    [_recordView powerValueChange:0];
    _recorder->StopRecord();
    
    if (_recorder->GetFileDuration() >= AUDIO_REC_MIN_DUR) {
        if (_soundView && _soundView.hidden) {
            [_soundView loadIfNeeded];
            _soundView.hidden = NO;
        }
        [self layoutSubViews:SNCommentMediaModeAudio animation:NO];
        [self setCommentStateView];

        if (self.recordFilePath) {
            _soundView.url = self.recordFilePath;
            _soundView.duration = _recorder->GetFileDuration();
            self.sendCmtObj.cmtAudioPath = self.recordFilePath;
            self.sendCmtObj.cmtAudioDuration = [NSString stringWithFormat:@"%d", _soundView.duration];
        }

        _recordView.timerLabel.text = @"";
        [_recordView.recordButton setTitle:NSLocalizedString(@"recordAgain", @"") forState:UIControlStateNormal];
        
        _deleteType = kDeleteTypeSound;
    } else if (_recorder->GetFileDuration() < AUDIO_REC_MIN_DUR) {
        if (!_soundView.hidden) {
            [_recordView.recordButton setTitle:NSLocalizedString(@"recordAgain", @"") forState:UIControlStateNormal];
        } else {
            [_recordView.recordButton setTitle:NSLocalizedString(@"recordButtonDown", @"") forState:UIControlStateNormal];
            _soundView.url = nil;
            _soundView.duration = 0;
        }
        [self showMessage:NSLocalizedString(@"audioDurationTooShort", @"")];
    }
    double delayInSeconds = .4f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_textField becomeFirstResponder];
    });
}

#pragma mark-
#pragma mark deleteButtonFun
- (void)deleteButtonEvent:(id)sender {
    if (_deleteType == kDeleteTypeSound) {
        [_soundView stopSoundPlay];
        [_recordView.recordButton setTitle:NSLocalizedString(@"recordButtonDown",
                                                             @"")
                                  forState:UIControlStateNormal];
        _soundView.hidden = YES;
        _soundView.url = nil;
        _soundView.duration = 0;
        
        self.sendCmtObj.cmtAudioDuration = nil;
        self.sendCmtObj.cmtAudioPath = nil;
        self.deleteButton.hidden = YES;
    } else if(_deleteType == kDeleteTypeImage) {
        [self removeSharedImage:sender];
    }
    [self layoutSubViews:SNCommentMediaModeText animation:NO];
    [self setCommentStateView];
}

#pragma mark- fastTextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITableView *)textView {
//    [self layoutSubViews:_mediaMode animation:YES];
    [self changeInputViewStateTo:kSNCommentInputStateKeyboard
	              keyboardHeight:_keyBoardHeight
	           animationDuration:kCEAnimationDuration];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITableView *)textView {
    return YES;
}

- (void)textViewDidBeginEditing:(UITableView *)textView {
    if (textView.contentSize.height != _lastTextViewContentHeight) {
        _lastTextViewContentHeight = textView.contentSize.height;
        [self layoutSubViews:_mediaMode animation:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.markedTextRange == nil) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;// 字体的行间距
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:KTextFieldFont],
                                     NSForegroundColorAttributeName:SNUICOLOR(kThemeTextRIColor),
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        NSRange oldRange = textView.selectedRange;
        _textField.attributedText = [[NSAttributedString alloc] initWithString:_textField.text attributes:attributes];
        textView.selectedRange = oldRange;
    }
    
    static CGFloat maxHeight = 140.0f/2;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        /*
         UITextView在上下左右分别有一个8px的padding，需要将UITextView.contentSize.width减去16像素(左右的padding 2 x 8px)
         同时返回的高度中再加上16像素（上下的padding），这样得到的才是UITextView真正适应内容的高度。
         */
        size = CGSizeMake(frame.size.width, [self calculateTextHeightWithText:_textField.text andWidth:frame.size.width - 16] + 16.0);
    } else { // ios7 使用此方法存在问题
        size = [textView sizeThatFits:constraintSize];
    }
    if (size.height <= kTextfieldHeight) {
        size.height = kTextfieldHeight;
        _textField.contentInset = UIEdgeInsetsZero;
    } else {
        if (size.height >= maxHeight)
        {
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
            _textField.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
        }
        else
        {
            textView.scrollEnabled = NO;    // 不允许滚动
            _textField.contentInset = UIEdgeInsetsZero;
        }
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    _textFieldBackView.height = size.height;
    
    [self layoutSubViews:_mediaMode animation:YES];
    [self setCommentStateView];

    if (_textField.text.length > 0 && !_tipLabel.hidden) {
        _tipLabel.hidden = YES;
    } else if(_textField.text.length == 0) {
        _tipLabel.hidden = NO;
    }
    [self setSendButtonState];
}

- (CGFloat)calculateTextHeightWithText:(NSString *)text andWidth:(CGFloat)width {
    
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 2;
    CGRect textRect = [text boundingRectWithSize:maximumLabelSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:KTextFieldFont],
                                                   NSForegroundColorAttributeName:SNUICOLOR(kThemeTextRIColor),
                                                   NSParagraphStyleAttributeName:paraStyle}
                                         context:nil];
    return textRect.size.height;
    
}

- (void)fastTextView:(FastTextView *)textView
        didSelectURL:(NSURL *)URL {
}

#pragma mark -
#pragma mark toolbarFunction
- (BOOL)SNCommentToolRecordFunction {
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=cc&fun=106&newsid=%@", self.newsId]];
    loginType = SNCommentLoginTypeAudio;
    //语音评论控制
    BOOL isBottom = (inputViewState == kSNCommentInputStateBottom);
    if ([SNUtility needCommentControlTip:self.comtStatus
                           currentStatus:kCommentStsForbidAudio
                                     tip:self.comtHint
                                isBottom:isBottom]) {
        return NO;
    }
    //禁止语音评论
    if (self.toolBarType == SNCommentToolBarTypeTextAndCam) {
        [self showMessage:NSLocalizedString(@"audioCommentIsForbidden", nil)];
        return NO;
    }
    [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_ARTICLE referId:self.newsId referAct:SNReferActCommentAudio];
    
    //引导登陆
//    if ([self checkNeedToLogin]) {
//        return NO;
//    }
    
    if (_commentPicView && _commentPicView.hidden == NO) {
        [self showMessage:NSLocalizedString(@"audioCouldntSendWithPhoto", nil)];
        return NO;
    }
    
    BOOL bHaveMicPermission = [SNSoundManager isMicrophoneEnabled];
    if (!bHaveMicPermission) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"MicrophoneForbidden", nil) toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    
    return [super SNCommentToolRecordFunction];
}

- (BOOL)SNCommentToolCamraFunction {
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=cc&fun=108&newsid=%@", self.newsId]];
    loginType = SNCommentLoginTypeImage;
    [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_ARTICLE referId:self.newsId referAct:SNReferActCommentPic];
    BOOL isBottom = (inputViewState == kSNCommentInputStateBottom);
    if ([SNUtility needCommentControlTip:self.comtStatus
                           currentStatus:kCommentStsForbidImage
                                     tip:self.comtHint
                                isBottom:isBottom]) {
        return NO;
    }
    
//    if ([self checkNeedToLogin]) {
//        return NO;
//    }
    
    if (!_soundView.hidden) {
        [self showMessage:NSLocalizedString(@"audioCouldntSendWithPhoto", nil)];
        return NO;
    }

    return [super SNCommentToolCamraFunction];
}

- (void)SNCommentToolShareFunction {
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=cc&fun=109&newsid=%@", self.newsId]];
    _cmtShareBar.hidden = YES;
    _cmtShareBar.bottom = _toolBar.top;
    [self layoutSubViews:_mediaMode animation:YES];
    
    [super SNCommentToolShareFunction];
}

- (void)SNCommentToolEmoticonFunction {
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=cc&fun=107&newsid=%@", self.newsId]];
    if (!_emoticonView) {
        _emoticonView = [[SNEmoticonTabView alloc] initWithType:SNEmoticonConfigNews frame:kCommentInputViewRect];
        _emoticonView.top = _dynamicallyView.height;
        _emoticonView.hidden = YES;
        _emoticonView.delegate = self;
        [_dynamicallyView addSubview:_emoticonView];
    }
    [super SNCommentToolEmoticonFunction];
}

- (void)callbackComment{
    if (self.sendDelegateController) {
        [self.sendDelegateController textFieldDidBeginAction];
    }
}

- (void)autoPostComment:(id)sender{
    if (sender && [sender isKindOfClass:[SNSendCommentObject class]]) {
        self.sendCmtObj = sender;
    }
    
    if (self.sendCmtObj) {
        [[SNPostCommentService shareInstance] saveCommentToServer:self.sendCmtObj];
        [SNNotificationManager postNotificationName:NotificationCommentCacheClean object:nil];
        [SNNotificationManager postNotificationName:NotificationCommentEditorPop object:nil];
    }
}

- (void)contentsWillPost {//wangshun share
    
    //wangshun login
    if (![SNUserManager isLogin]) {
//        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {
//            [self callbackComment];
//        } Failed:^(NSDictionary *errorDic) {
//            return ;
//        }];
        [self changeInputViewStateTo:kSNCommentInputStateBottom keyboardHeight:0 animationDuration:kCEAnimationDuration];
        __weak SNCommentEditorViewController* weakSelf = self;
        [self onBackCallBack:^(NSDictionary *info) {
            if (weakSelf.sendDelegateController && [weakSelf.sendDelegateController respondsToSelector:@selector(commentLogin:)]) {
                
                self.sendCmtObj.cmtText = _textField.text;
                self.sendCmtObj.isNovelComment = self.isNovelComment;
                
                [weakSelf.sendDelegateController commentLogin:self.sendCmtObj];
            }
        }];
        
        return;
    }
    
    if (self.sendCmtObj) {
        self.sendCmtObj.cmtText = _textField.text;
        self.sendCmtObj.isNovelComment = self.isNovelComment;
        [[SNPostCommentService shareInstance] saveCommentToServer:self.sendCmtObj];
        
//        SNShareItem *shareItem = [[SNShareItem alloc] init];
//        shareItem.shareId = self.shareObj.contentId;
//        shareItem.shareContentType = SNShareContentTypeJson;
//        shareItem.sourceType     = self.shareObj.sourceType;
//        shareItem.shareContent   = self.shareObj.abstract;
//        shareItem.shareImageUrl  = self.shareObj.picUrl;
//        shareItem.shareLink = self.shareObj.link;
//        shareItem.ugc = self.sendCmtObj.cmtText;
//        NSArray *appIdArray = [_cmtShareBar.appIdDic allValues];
//        shareItem.appId = [appIdArray componentsJoinedByString:@","];
//        shareItem.fromComment = YES;
//        shareItem.needTip = NO;
//        if (shareItem.appId.length > 0) {
//            [[SNShareManager defaultManager] postShareItemToServer:shareItem];
//        }
        
        [SNNotificationManager postNotificationName:NotificationCommentCacheClean object:nil];
        [SNNotificationManager postNotificationName:NotificationCommentEditorPop object:nil];
    }
}

- (void)showCommentEditorView
{
    [UIView animateWithDuration:kCommentEditorViewShowTime animations:^(void) {
        _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    } completion:^(BOOL finished) {
        if (self.isEmoticon) {
            [_toolBar emoticonButtonPressed];
        }
    }];
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer
{
    [self onBack];
}

- (void)changeInputView {
    if (inputViewState == kSNCommentInputStateKeyboard) {
        [_textField becomeFirstResponder];
    }
}

- (BOOL)isHasImageDetailView {
    return _imageDetailView.alpha;
}

- (BOOL)prefersStatusBarHidden {
    return [TTNavigator navigator].topViewController.flipboardNavigationController.previousViewController.prefersStatusBarHidden;
}

@end
