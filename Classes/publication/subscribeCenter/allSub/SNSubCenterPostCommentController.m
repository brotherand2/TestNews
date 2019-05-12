//
//  SNSubCenterPostCommentController.m
//  sohunews
//
//  Created by wang yanchen on 12-11-29.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterPostCommentController.h"
#import "UIColor+ColorUtils.h"
#import "SNTextView.h"
#import "SNStarGradeView.h"
#import "SNAlert.h"
#import "SNSubscribeCenterService.h"
#import "SNPostFollow.h"
#import "SNStatusBarMessageCenter.h"
#import "SNToast.h"

#import "SNNewAlertView.h"

#define MAXINPUT_FOR_POST		800
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



@interface SNSubCenterPostCommentController () {
    // views
    SNTextView *_contentTextView;
    UIButton *_imageViewButton;
    UILabel *_contentLengthView;
    UIView *_contentView;
    SNStarGradeView *_starGradeView;
    SNAlert *_confirmAlertView;
    
    NSString *_content;
    NSString *_subId;
}

@property(nonatomic,strong)SNAlert *confirmAlertView;
@property(nonatomic,strong)NSString *subId;

@end

@implementation SNSubCenterPostCommentController

@synthesize confirmAlertView=_confirmAlertView;
@synthesize subId=_subId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        self.subId = [query objectForKey:@"subId"];
        //_content = @"请在这里输入您的评价";
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_valuation;
}

- (void)loadView {
    [super loadView];
    
    [SNNotificationManager addObserver:self selector:@selector(dismissCurrentPostView:) name:kNotifyDidReceive object:nil];
    
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypePostSubComment];
    
    int width;
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    width = self.view.size.width;
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];

    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeightWithoutBottom, width, 179 + 16 / 2)];
    _contentView.backgroundColor = [UIColor clearColor];
    
    // textview background
    UIImageView *imageBGN = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareInput.png"]];
    imageBGN.frame = CGRectMake(kLeftRightBlank, 10 + 16 / 2, imageBGN.frame.size.width, imageBGN.frame.size.height);
    [_contentView addSubview:imageBGN];
        
    // textview
    if (!_contentTextView) {
        _contentTextView = [[SNTextView alloc] initWithFrame:CGRectMake(kLeftRightBlank + 5, kTextViewTopBlank - 6 + 16 / 2,
                                                                        self.view.frame.size.width - 2 * kLeftRightBlank - 5, kTextViewHeight - 5)];
    }
    _contentTextView.delegate = self;
    _contentTextView.font = [UIFont systemFontOfSize:14];
    _contentTextView.returnKeyType = UIReturnKeyDefault;
    _contentTextView.showsVerticalScrollIndicator = NO;
    
    _contentTextView.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShareToInfoTextColor]];
    
    _contentTextView.backgroundColor = [UIColor clearColor];

    [_contentView addSubview:_contentTextView];
    
    UIImage *submitImg = [UIImage imageNamed:@"share_submit.png"];
    
    _starGradeView = [[SNStarGradeView alloc] initWithStyle:SNStarGradeViewStyleLarge canEdit:YES];
    _starGradeView.frame = CGRectMake(16, _contentTextView.bottom + 1, 0, 0);
    [_contentView addSubview:_starGradeView];
    
    UIButton *_submitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - submitImg.size.width - 16,
                                                                         _contentTextView.bottom - 3,
                                                                         submitImg.size.width, submitImg.size.height)];
    [_submitButton setImage:submitImg forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton setAccessibilityLabel:@"发布"];
    
    UILabel *btnTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _submitButton.width, _submitButton.height)];
    btnTitle.backgroundColor = [UIColor clearColor];
    [btnTitle setTextAlignment:NSTextAlignmentCenter];
    [btnTitle setFont:[UIFont systemFontOfSize:14]];
    [btnTitle setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeatherWidgetTextColor]]];
    [btnTitle setText:@"发布"];
    [btnTitle setIsAccessibilityElement:NO];
    
    [_submitButton addSubview:btnTitle];
    
    [_contentView addSubview:_submitButton];

    
    //------------------
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObject:@"添加评价"]];
    
    UIImage *icon = [UIImage imageNamed:@"nickClose.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:icon forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(kAppScreenWidth - icon.size.width - 4/2, 8/2 + kSystemBarHeight, icon.size.width, icon.size.height);
    [self.headerView addSubview:backBtn];
    
    [self.view addSubview:_contentView];
    
    //2012 11 14 by diao for 盲人阅读
    [icon setAccessibilityLabel:@"关闭"];
    
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [[SNSubscribeCenterService defaultService] removeListener:self];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [[SNSubscribeCenterService defaultService] removeListener:self];
    
     //(_contentView);
     //(_contentTextView);
     //(_contentLengthView);
     //(_starGradeView);
     //(_confirmAlertView);
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_contentTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SNToast shareInstance] hideToast];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)post:(id)sender {
    [_contentTextView resignFirstResponder];
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }

    if (_starGradeView.grade == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"您还没有打分" toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    NSString *postText = [_contentTextView.text trim];
    if ([postText length] > MAXINPUT_FOR_POST) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"内容应不多于%d个字", MAXINPUT_FOR_POST] toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    if ([postText length] <= 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"内容不能为空" toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }

	// 发布
    if ([self.subId length] > 0) {
        [[SNSubscribeCenterService defaultService] postSubComment:postText author:[SNPostFollow currentUserName] starGrade:_starGradeView.grade subId:self.subId];
        [self showLoading:YES];
    }
}

- (void)changeInputInfo {
	NSString *shareContent	= _contentTextView.text;
	NSInteger nLength	= [shareContent length];
	NSInteger nCanInputCount	= 0;
	if (nLength <= MAXINPUT_FOR_POST) {
		nCanInputCount	= MAXINPUT_FOR_POST - nLength;
        NSString *strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Can input",@""),nCanInputCount];
		[_contentLengthView setText:strContrent];
	}
	else {
		nCanInputCount	= nLength - MAXINPUT_FOR_POST;
        NSString *strContrent = [NSString stringWithFormat:@"%@%ld字",NSLocalizedString(@"Exceeded",@""),nCanInputCount];
        [_contentLengthView setText:strContrent];
	}
}

- (void)onBack:(id)sender {
    [self hideKeyboard];
    
    if (_contentTextView.text.length == 0 || [_content isEqualToString:_contentTextView.text]) {
        // 内容没有编辑 直接推出
//        [self.flipboardNavigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
//    SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:@"取消评价?"
//                                                             delegate:self
//                                                            iconImage:[SNUtility chooseActEditIconImage]
//                                                              content:@"您已经写下的文字将丢失"
//                                                           actionType:SNActionSheetTypeDefault
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:@"退出"
//                                                    otherButtonTitles:nil];
//    
//    [[TTNavigator navigator].window addSubview:actionSheet];
//    [actionSheet showActionViewAnimation];
//    [actionSheet release];
//    SNConfirmFloatView* confirmView = [[SNConfirmFloatView alloc] init];
//    confirmView.message = @"取消评价,您已经写下的文字将丢失";
//    [confirmView setConfirmText:@"取消" andBlock:^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [confirmView show];
    
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:@"取消评价,您已经写下的文字将丢失" cancelButtonTitle:@"取消" otherButtonTitle:@"确认"];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)hideKeyboard {
    [_contentTextView resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {    
    //[self changeInputInfo];
}

#pragma mark -
#pragma mark - SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [_contentTextView becomeFirstResponder];
    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewTagCancel) {
        if (buttonIndex == 1) {
//            [self.flipboardNavigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [_contentTextView becomeFirstResponder];
        }
    }
    self.confirmAlertView = nil;
}

- (void)showLoading:(BOOL)bLoading {
    if (bLoading) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Please wait", @"") toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        //[[SNUtility getApplicationDelegate] hideLoadingAndBlock];
        [[SNToast shareInstance] hideToast];
    }
}

- (void)dismissCurrentPostView:(NSNotification *)notification {
    if (self.confirmAlertView) {
        [self.confirmAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    [self hideKeyboard];
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypePostSubComment) {
//        [self showLoading:NO];

        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"评价成功" toUrl:nil mode:SNCenterToastModeSuccess];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypePostSubComment) {
        NSString *msg = [dataSet.lastError domain];
        if ([msg startWith:@"NSURLError"] || ![[SNUtility getApplicationDelegate] isNetworkReachable]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
        }
    }
}

@end
