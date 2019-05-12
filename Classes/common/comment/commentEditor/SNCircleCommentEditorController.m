//
//  SNCircleCommentEditorController.m
//  sohunews
//
//  Created by jialei on 13-7-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCircleCommentEditorController.h"
#import "SNBaseEditorViewController+SNLayout.h"
#import "SNTimelinePostService.h"
#import "SNCommentConfigs.h"
#import "SNUserManager.h"

@interface SNCircleCommentEditorController ()
{
    CGFloat           _lastTextViewContentHeight;
}

@end

@implementation SNCircleCommentEditorController

@synthesize actId;
@synthesize spid = _spid;
@synthesize commentId = _commentId;
@synthesize fpid = _fpid;
@synthesize fname = _fname;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithData:(NSDictionary*)query
{
    if (self = [super initWithNavigatorURL:nil query:query])
    {
        self.editorType = SNEditorTypeComment;
        self.actId = [query objectForKey:kCircleCommentKeyActId];
        self.spid = [SNUserManager getPid];
        self.commentId = [query objectForKey:kCircleCommentKeyCommentId];
        self.fpid = [query objectForKey:kCircleCommentKeyFpid];
        self.fname = [query objectForKey:kCircleCommentKeyFname];
        self.sendDelegateController = [query objectForKey:kCircleCommentKeyDelegate];
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    if (self = [super initWithNavigatorURL:URL query:query])
    {
        self.editorType = SNEditorTypeComment;
        self.actId = [query objectForKey:kCircleCommentKeyActId];
        self.spid = [query objectForKey:kCircleCommentKeySpid];
        self.commentId = [query objectForKey:kCircleCommentKeyCommentId];
        self.fpid = [query objectForKey:kCircleCommentKeyFpid];
        self.fname = [query objectForKey:kCircleCommentKeyFname];
        self.sendDelegateController = [query objectForKey:kCircleCommentKeyDelegate];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Comment", @"")]];
    
    if (self.fname && self.fpid) {
        _tipLabel.text = [NSString stringWithFormat:@"回复%@：", self.fname];
    }
    else {
        NSString *saveTips = [[NSUserDefaults standardUserDefaults]stringForKey:kCommentRemarkTip];
        if (saveTips.length > 0) {
            _tipLabel.text = saveTips;
        } else {
            _tipLabel.text = @"我来说两句...";
        }
    }
    
    if (_toolBar)
    {
        _toolBar.commentToolBarType = SNCommentToolBarTypeTextAndEmoticon;
        [_toolBar setArrowView:NO];
    }
    [_textField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

#pragma mark -
#pragma mark postComment
- (void)contentsWillPost
{
    if ([_textField.text length] > 0 && [self.actId length] > 0)
    {
//        NSString *text = [self makeSendText];
        // 如果 commentId fpid 这两个字段 都有值  则是回复别人的评论
        if (self.commentId.length > 0 && self.fpid.length > 0) {
            [[SNTimelinePostService sharedService] timelineReplyComment:_textField.text
                                                                  actId:self.actId
                                                                   spid:self.spid
                                                              commentId:self.commentId
                                                                   fpid:self.fpid
                                                              fnickName:self.fname];
        }
        // 否则是添加新的评论
        else {
            [[SNTimelinePostService sharedService]timelinePostComment:_textField.text
                                                                actId:self.actId
                                                                 spid:self.spid];
        }
    }
}

#pragma mark-
#pragma mark Function from base controller
- (void)setSendButtonState
{
    NSString *inputStr = [_textField.text trim];
    if (inputStr.length > 0)
    {
        [_toolBar setSendButtonEnable];
    }
    else
    {
        [_toolBar setSendButtonDisable];
    }
}

- (void)SNCommentToolEmoticonFunction
{
    if (!_emoticonView) {
        _emoticonView = [[SNEmoticonTabView alloc] initWithType:SNEmoticonConfigNews frame:kCommentInputViewRect];
        _emoticonView.top = self.view.height;
        _emoticonView.hidden = YES;
        _emoticonView.delegate = self;
        //        _emoticonView.emoticonDelegate = self;
        [self.view addSubview:_emoticonView];
    }
    [super SNCommentToolEmoticonFunction];
}

#pragma mark- fastTextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITableView *)textView {
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

- (void)textViewDidEndEditing:(UITableView *)textView {
}

- (void)textViewDidChange:(UITableView *)textView {
    if (_textField.text.length > 0 && !_tipLabel.hidden) {
        _tipLabel.hidden = YES;
    }
    else if(_textField.text.length == 0)
    {
        _tipLabel.hidden = NO;
    }
    [self setSendButtonState];
}


- (void)showTips
{
    self.alertTitle = NSLocalizedString(@"GiveUpComment", @"");
    self.alertSubMessage = NSLocalizedString(@"", @"");
    self.alertCancelTitle = NSLocalizedString(@"CancelGiveUp", @"");
    self.alertOtherTitle = NSLocalizedString(@"ConfirmGiveUp", @"");
    [super showTips];
}

- (void)startLogin
{
    [SNGuideRegisterManager showGuideWithContentComment:nil];
}

- (BOOL)shouldShowLogin
{
    return YES;
}

- (void)layoutSubViews:(SNCommentMediaMode)modeType animation:(BOOL)animation
{
    _toolBar.bottom = self.view.bounds.size.height - _keyBoardHeight;
    [self setSendButtonState];
    [self setTextViewFrame];
}

- (void)setTextViewFrame
{
    float initH = self.view.size.height - kHeaderTotalHeight - kCommentToolBarHeight;
    
    _maxHeight = initH;
    
    initH = self.view.size.height - _keyBoardHeight - kHeaderTotalHeight - kCommentToolBarHeight;
    
    _textField.size = CGSizeMake(self.view.width, initH);
    _textField.top = kHeaderHeightWithoutBottom + 8;
}

#pragma mark -emoticonScrollDelegate
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon
{
    [super emoticonDidSelect:emoticon];
}

- (void)emoticonDidDelete
{
    [super emoticonDidDelete];
}

@end
