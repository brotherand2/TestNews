 //
//  SNSharePostController.m
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShareWithCommentController.h"

#import "UIColor+ColorUtils.h"
#import "SNShareListItemCell.h"
#import "SNShareClipImageButton.h"
#import "UIImage+Utility.h"

#import "SNThemeManager.h"
#import "NSDictionaryExtend.h"
#import "SNTextView.h"
#import "CacheObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNTLComViewTextAndPicsBuilder.h"
#import "SNTLComViewSubscribeBuilder.h"
#import "SNTLComViewOnlyTextBuilder.h"
#import "SNTimelineTrendObjects.h"
#import "SNBaseEditorViewController.h"
#import "SNShareConfigs.h"

#import "SNNewAlertView.h"


//static NSString *const shareDefaultSuff = @"@搜狐新闻客户端";

#define MAXINPUT_FOR_SINA           140
#define NEWS_MAXINPUT_FOR_SINA		110
#define LIVE_MAXINPUT_FOR_SINA       130
#define MIN_MAXINPUT_FOR_SINA       50
#define MIN_DEFAULTINPUT_FOR_SINA       20
#define kAlertViewTagCancel     0
#define kAlertViewTagUnbingding 1

#define kLeftRightBlank         10
#define kImageViewRightBlank    8
#define kImageViewTopBlank      8
#define kImageViewWidth         37
#define kImageViewHeight        37
#define kTextLenLabelLeftBlank  9
#define kTextViewTopBlank       20
#define kTextViewHeight         110
#define kTextViewFont           16
#define kTipLabelGapX           10
#define kBindingActionSheetTag  777
#define kCancelBindActionSheetTag   778

@interface SNShareWithCommentController () {
    UIView *_newsView;
    BOOL    canShare;
    
}

@property(nonatomic, copy)NSString *imagePath;
@property(nonatomic, strong)SNTimelineOriginContentObject *shareInfoObj;

@end

@implementation SNShareWithCommentController

+ (SNShareWithCommentController *)sharePostControllerWithShareInfo:(NSDictionary *)shareInfo {
    SNShareWithCommentController *controller = nil;
    return controller;
}

- (void)updateShareInfoObj:(NSDictionary *)shareInfo{
    if (self.shareInfoObj) {
        self.shareInfoObj.content = shareInfo[@"content"];
        self.shareInfoObj.title = shareInfo[@"content"];
    }
}

- (id)initWithShareInfo:(NSDictionary *)shareInfo {
    self = [super initWithShareInfo:shareInfo];
    if (self) {
//        self.shareInfoObj = shareInfo[kShareInfoKeyInfoDic];
        self.shareInfoObj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareInfo];
        if (shareInfo[@"contentType"] && ([shareInfo[@"contentType"] isEqualToString:@"web"] || [shareInfo[@"contentType"] isEqualToString:@"special"] || [shareInfo[@"contentType"] isEqualToString:@"activityPage"] || [shareInfo[@"contentType"] isEqualToString:@"pack"] || [shareInfo[@"contentType"] isEqualToString:@"channel"] || [shareInfo[@"contentType"] isEqualToString:@"sns"] || [shareInfo[@"contentType"] isEqualToString:@"qianfan"])) {
            self.shareType = SNShareContentTypeString;
            if ([self.content containsString:@"@搜狐新闻客户端"]) {
                
            }else{
                if ([shareInfo[@"contentType"] isEqualToString:@"web"]) {
                    self.content = shareInfo[@"title"];
                    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:shareInfo];
                    [muDict setObject:self.content forKey:kShareInfoKeyContent];
                    shareInfo = [NSDictionary dictionaryWithDictionary:muDict];
                }
                if (![SNAPI isWebURL:self.content]) {
                    if ([shareInfo[@"contentType"] isEqualToString:@"qianfan"]) {
                        self.content = shareInfo[@"title"];
                    }
                    self.content = [NSString stringWithFormat:@"%@ %@ (分享自 @搜狐新闻客户端)",self.content, shareInfo[@"webUrl"]];
                }
                
            }
        }else {
            self.shareType  = SNShareContentTypeJson;
        }

        [self updateShareInfoObj:shareInfo];
//        _canInputCount	= self.shareInfoObj.ugcWordLimit;
//        NSString *urlString = [shareInfo objectForKey:@"url"];
//        if(NSNotFound != [urlString rangeOfString:kProtocolPreview options:NSCaseInsensitiveSearch].location) {
//            NSString *contentString = [shareInfo objectForKey:@"content"];
//            _canInputCount = MAXINPUT_FOR_SINA - contentString.length;
//        }
//        else  if(NSNotFound != [urlString rangeOfString:kProtocolSpecial options:NSCaseInsensitiveSearch].location) {
//            NSString *contentString = [shareInfo objectForKey:@"content"];
//            _canInputCount = MAXINPUT_FOR_SINA - contentString.length;
//        }
        NSString *contentString = [shareInfo objectForKey:@"content"];
        _canInputCount = MAXINPUT_FOR_SINA - contentString.length;

    }
    return self;
}

- (SNShareWithCommentController *)initWithContent:(NSString *)content
                                  imageUrl:(NSString *)imageUrl
                                    newsId:(NSString *)newsId
                                   groupId:(NSString *)gid
                                 longitude:(long)longitude
                                  latitude:(long)latitude
                                  delegate:(id)delegate {
    self = [super init];
    return self;
}


- (void)loadView {
    [super loadView];
    [SNNotificationManager addObserver:self
                                             selector:@selector(actionSheetOnBack)
                                                 name:KGuideRegisterBackNotification
                                               object:nil];
    [SNNotificationManager addObserver:self
                                             selector:@selector(audioShareNotification)
                                                 name:kAudioShareSNotification
                                               object:nil];
    
    

}

- (void)creatView {
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    int width, height;
    self.view.frame = appFrame;
    width = kAppScreenWidth;
    height = kAppScreenHeight;
    
    CGFloat offsetHeight = 0;
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
    if (t == UIDevice6iPhone || t == UIDevice6PlusiPhone || t == UIDevice7iPhone || t == UIDevice7PlusiPhone || t == UIDevice8iPhone || t == UIDevice8PlusiPhone) {
        offsetHeight = 50;
    }
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom + 44, width, 0)];
    _contentHeaderView.backgroundColor = [UIColor clearColor];
    
    // textview
    UIFont *font = [UIFont systemFontOfSize:KTextFieldFont];
    if (!_contentTextView) {
        _contentTextView = [[SNTextView alloc] initWithFrame:CGRectMake(0, kTextViewTopBlank - 20 + 16 / 2,
                                                                        self.view.frame.size.width, font.lineHeight * 3 + 4 + offsetHeight)];
    }
    _contentTextView.delegate = self;
    _contentTextView.font = font;
    _contentTextView.returnKeyType = UIReturnKeyDone;
    _contentTextView.showsVerticalScrollIndicator = YES;
    _contentTextView.backgroundColor = [UIColor clearColor];
    [_contentTextView becomeFirstResponder];
    _contentTextView.tag = 10001;
    _contentTextView.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShareToInfoTextColor]];
    [_contentHeaderView addSubview:_contentTextView];
    
    //提示
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(kTipLabelGapX, _contentTextView.top + 10,
                                                         _contentTextView.width, KTextFieldFont)];
    _tipLabel.font = [UIFont systemFontOfSize:KTextFieldFont];
    _tipLabel.textColor = SNUICOLOR(kCommentTextTipColor);
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = @"分享我的心得...";
    _tipLabel.hidden = NO;
    [_contentHeaderView addSubview:_tipLabel];
    
    //分享控件，2013-9-9改版
    
    if (![self.shareInfoObj.title containsString:@"@搜狐新闻客户端"]) {
        if (![SNAPI isWebURL:self.shareInfoObj.title]) {
            self.shareInfoObj.title = self.content;
        }
        else {
            self.shareInfoObj.title = [NSString stringWithFormat:@"%@ (分享自 @搜狐新闻客户端)",self.shareInfoObj.title];
        }
    }
    if (self.shareInfoObj.isFromChannelPreview) {//频道预览页分享
        self.shareInfoObj.sourceType = SNShareSourceTypeChannel;
        SNTLComViewTextAndPicsBuilder *picNewsBuilder = [SNTLComViewTextAndPicsBuilder new];
        picNewsBuilder.imagePath = self.shareInfoObj.picUrl;
        picNewsBuilder.imageUrl = self.shareInfoObj.picUrl;
        picNewsBuilder.fromString = self.shareInfoObj.fromString;
        picNewsBuilder.typeString = self.shareInfoObj.typeString;
        picNewsBuilder.isForShare = YES;
        picNewsBuilder.useType = kSNTLComViewUseForShareOuter;
        picNewsBuilder.isChannelPreview = self.shareInfoObj.isFromChannelPreview;
        picNewsBuilder.title = [NSString stringWithFormat:@"%@", self.shareInfoObj.content];
        _newsView = [picNewsBuilder buildView];
    }
    else if ((self.shareInfoObj &&
        (SNTimelineOriginContentTypeTextAndPics == self.shareInfoObj.type))) {                           //图文显示
        SNTLComViewTextAndPicsBuilder *picNewsBuilder = [SNTLComViewTextAndPicsBuilder new];
        if (self.isQianfanShare) {
            picNewsBuilder.imagePath = self.imageUrl;
            picNewsBuilder.imageUrl = self.imageUrl;
        }else{
            picNewsBuilder.imagePath = self.shareInfoObj.picUrl;
            picNewsBuilder.imageUrl = self.shareInfoObj.picUrl;
        }
        picNewsBuilder.title = self.shareInfoObj.title;
//        picNewsBuilder.abstract = self.shareInfoObj.description;
        picNewsBuilder.fromString = self.shareInfoObj.fromString;
        picNewsBuilder.typeString = self.shareInfoObj.typeString;
        picNewsBuilder.isForShare = YES;
        picNewsBuilder.useType = kSNTLComViewUseForShareOuter;
        picNewsBuilder.isChannelPreview = self.shareInfoObj.isFromChannelPreview;
        
        _newsView = [picNewsBuilder buildView];
    } else if (self.shareInfoObj &&
               (SNTimelineOriginContentTypeSub == self.shareInfoObj.type))  {                            //刊物
        SNTLComViewSubscribeBuilder *subBuilder = [SNTLComViewSubscribeBuilder new];
        subBuilder.subId = self.shareInfoObj.subId;
        subBuilder.subName = self.shareInfoObj.subName;
        subBuilder.subIcon = self.shareInfoObj.picUrl;
        subBuilder.subCountNum = self.shareInfoObj.subCount;
        subBuilder.isForShare = YES;
        subBuilder.useType = kSNTLComViewUseForShareOuter;
        
        _newsView = [subBuilder buildView];
    } else if (self.shareInfoObj &&
               (SNTimelineOriginContentTypeText == self.shareInfoObj.type))                              //纯文本
    {
//        if (self.imagePath.length > 0)
//        {
        if (self.imagePath.length == 0) {
            self.imagePath = [[NSBundle mainBundle] pathForResource:@"iOS_114_normal" ofType:@"png"];
        }
        
            SNTLComViewTextAndPicsBuilder *picNewsBuilder = [SNTLComViewTextAndPicsBuilder new];
            picNewsBuilder.imageUrl = self.shareInfoObj.picUrl;
            picNewsBuilder.imagePath = self.imagePath;
            picNewsBuilder.title = self.shareInfoObj.title;
//            picNewsBuilder.abstract = self.shareInfoObj.abstract;
            picNewsBuilder.fromString = self.shareInfoObj.fromString;
            picNewsBuilder.typeString = self.shareInfoObj.typeString;
            picNewsBuilder.isForShare = YES;
            picNewsBuilder.useType = kSNTLComViewUseForShareOuter;
            
            _newsView = [picNewsBuilder buildView];
    }
    
    if (_newsView)
    {
        CGRect newsViewRect = CGRectMake(_contentTextView.width / 2 - _newsView.width / 2, _contentTextView.bottom,
                                         _newsView.width, _newsView.height);
        _newsView.frame = newsViewRect;
        [_contentHeaderView addSubview:_newsView];
    }
    
    // textview background
    UIImage *bgImgae = [UIImage imageNamed:@"share_post_sepLine.png"];
    UIImageView *imageBGN = [[UIImageView alloc] initWithImage:bgImgae];
    imageBGN.frame = CGRectMake(0, _newsView.bottom - bgImgae.size.height, kAppScreenWidth, bgImgae.size.height);
    [_contentHeaderView addSubview:imageBGN];
    int newsViewHeight = _newsView ? _newsView.bottom : 153;
    
    // content length
    _contentLengthView = [[UILabel alloc] initWithFrame:CGRectMake(kLeftRightBlank + kTextLenLabelLeftBlank,
                                                                   newsViewHeight + 15, 180, 20)];
	[_contentLengthView setNumberOfLines:1];
	[_contentLengthView setTextAlignment:NSTextAlignmentLeft];
    [_contentLengthView setFont:[UIFont systemFontOfSize:11]];
	[_contentLengthView setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubHomeTableCellDetailLabelColor]]];
    [_contentLengthView setBackgroundColor:[UIColor clearColor]];
    [_contentHeaderView addSubview:_contentLengthView];
    
    CGRect screenFrame = TTApplicationFrame();
    UIImage *submitImg = [UIImage imageNamed:@"comment_send_button_enable.png"];
    UIButton *_submitButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width - submitImg.size.width - 6,
                                                                         _contentLengthView.top - 8,
                                                                         submitImg.size.width, submitImg.size.height)];
    [_submitButton setImage:submitImg forState:UIControlStateNormal];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_submitButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop

    [_submitButton setAccessibilityLabel:@"发表"];
    _submitButton.centerY = _contentLengthView.centerY;
    _contentHeaderView.frame = CGRectMake(0, kHeaderHeightWithoutBottom + 44, width, _submitButton.bottom + 8);
    
    [_contentHeaderView addSubview:_submitButton];
    
    //点击收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [_newsView addGestureRecognizer:tap];
    
    // tableview
    _sharelistTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom, width, height - kHeaderHeightWithoutBottom) style:UITableViewStylePlain];
    _sharelistTableView.backgroundColor = [UIColor clearColor];
    _sharelistTableView.showsVerticalScrollIndicator = NO;
    [_sharelistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _sharelistTableView.tableHeaderView = _contentHeaderView;
    
    // table bg
    _sharelistTableView.backgroundView = nil;
    _sharelistTableView.backgroundColor = SNUICOLOR(kBackgroundColor);
    _sharelistTableView.delegate = self;
    _sharelistTableView.dataSource = self;
    [self.view addSubview:_sharelistTableView];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_logo_dark.png"]];
    [logo setFrame:CGRectMake((kAppScreenWidth - kAppLogoWidth/2)/2,-100, kAppLogoWidth/2, kAppLogoHeight/2)];
    [_sharelistTableView addSubview:logo];
    logo = nil;
    
    _refreshShareListMaskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44 + _contentHeaderView.height, width, height - 44 - _contentHeaderView.height)];
    [_refreshShareListMaskButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_refreshShareListMaskButton.titleLabel setTextColor:[UIColor lightGrayColor]];
    [_refreshShareListMaskButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    _refreshShareListMaskButton.backgroundColor = [UIColor clearColor];
    [_refreshShareListMaskButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_refreshShareListMaskButton setTitle:@"点击刷新分享列表" forState:UIControlStateNormal];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_refreshShareListMaskButton addTarget:self action:@selector(refreshShareList) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop

    _refreshShareListMaskButton.hidden = ([_shareListItems count] > 0);
    [self.view addSubview:_refreshShareListMaskButton];
    
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObject:@"分享"]];
    
    UIImage *icon = [UIImage imageNamed:@"nickClose.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:icon forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(kAppScreenWidth - icon.size.width - 4/2, kSystemBarHeight+8/2, icon.size.width, icon.size.height);
    [self.headerView addSubview:backBtn];
    
    self.view.backgroundColor = _sharelistTableView.backgroundColor;
    //2012 11 14 by diao for 盲人阅读
    [icon setAccessibilityLabel:@"关闭"];
}

-(void)audioShareNotification{
    if (self.isVideoShare) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    if (self.isQianfanShare) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}

- (void)actionSheetOnBack {
    [_contentTextView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)startPost {
    NSString *shareComment = [_contentTextView.text trim];
    NSString *shareContent = [self.content trim];
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return NO;
    }
    
    if ([[[SNShareManager defaultManager] itemsCouldShare] count] == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kBindSinaFirst toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }

    if (!canShare) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"分享内容应不多于140个字" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    
    SNShareItem *shareItem = [[SNShareItem alloc] init];

    shareItem.shareId = self.newsId;
    shareItem.shareContent   = shareContent;
    
    shareItem.shareContentType = self.shareType;
    shareItem.shareTitle = self.shareInfoObj.title;
    if (self.shareInfoObj.isFromChannelPreview) {
        shareItem.shareId = self.shareInfoObj.subId;
        shareItem.shareContent = self.shareInfoObj.description;
    }
    if (self.isVideoShare) {
        shareItem.shareLink      = self.shareInfoObj.link;
        shareItem.shareId = self.shareInfoObj.referId;
    }else {
        shareItem.shareId = self.newsId;
        shareItem.shareLink      = self.shareInfoObj.link;
    }
    shareItem.shareLink      = self.shareInfoObj.link;
    shareItem.shareImagePath = self.imagePath;
    shareItem.shareImageUrl  = self.imageUrl;
    if (self.sourceType == 141) {
        shareItem.sourceType = self.sourceType;
    }else if (self.sourceType == 65) {
        shareItem.sourceType = self.sourceType;
    }else{
        shareItem.sourceType     = self.shareInfoObj.sourceType;
    }
    shareItem.ugc = shareComment;
    if (shareItem.shareId.length == 0) {
        shareItem.shareId = self.shareInfoObj.referId;
    }
    [[SNShareManager defaultManager] postShareItemToServer:shareItem];
     //(shareItem);
    
    return YES;
}

- (void)onBack:(id)sender {
    [SNNotificationManager postNotificationName:kShareWithCommentControllerDidDismissNotification object:nil];
    [SNNotificationCenter hideMessage];
    [self hideKeyboard];
    if ([_contentTextView.text length] <= 0) {
        self.isDismissing = YES;
        // 内容没有编辑 直接推出
        if (self.bPresentFromWindowDelegate) {
            [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        }
        else if (self.delegate && [self.delegate isKindOfClass:[SNSplashViewController class]]) {
            [self.delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        } else {
            //present-style push
            if (self.isVideoShare || self.isQianfanShare) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }else{
                [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
            }
        }
        return;
    }
    
    SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:@"退出分享，您已经写下的文字将丢失" cancelButtonTitle:@"取消" otherButtonTitle:@"退出"];
    [alertView show];
    [alertView actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        if (self.bPresentFromWindowDelegate) {
            [[SNUtility getApplicationDelegate].splashViewController performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        }
        else if (self.delegate && self.delegate == [SNUtility getApplicationDelegate].splashViewController) {
            [self.delegate performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
        } else {
            if (self.isVideoShare||self.isQianfanShare) {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            } else {
                [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
            }
            
        }
        self.isDismissing = YES;

    }];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    if (_contentTextView.text.length > 0 && !_tipLabel.hidden) {
        _tipLabel.hidden = YES;
    } else if(_contentTextView.text.length == 0){
        _tipLabel.hidden = NO;
    }
    [self changeInputInfo];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height
           - textView.contentInset.bottom - textView.contentInset.top);
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
            [UIView animateWithDuration:.2 animations:^{
                [textView setContentOffset:offset];
            }];
        }
    }
}

#pragma mark - private methods
- (void)handleTap:(UIPanGestureRecognizer*)tap
{
    [_contentTextView resignFirstResponder];
}

- (void)setImageClipButton {
    
}

- (void)changeInputInfo {
    //要分享的内容和用户输入的评论分开计算
	NSString *shareComment = _contentTextView.text;
//    NSInteger inputCount = MAXINPUT_FOR_SINA - shareComment.length;
    NSInteger inputCount = _canInputCount - shareComment.length;
    //剩余  文章 ：X=110-标题-链接34456 组图：X=110- 标题-链接
    canShare = YES;
    NSString *strContrent = nil;
    if (inputCount >= 0) {
        strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Can input",@""),inputCount];
    }
    else {
        strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Exceeded",@""), labs(inputCount)];
        canShare = NO;
    }
    if (strContrent.length > 0) {
        [_contentLengthView setText:strContrent];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 10001) {
        return;
    }
    [_contentTextView resignFirstResponder];
}

@end
