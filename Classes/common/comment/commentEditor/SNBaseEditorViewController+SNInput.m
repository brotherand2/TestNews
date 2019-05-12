//
//  SNCommentEditorViewController+SNInput.m
//  sohunews
//
//  Created by jialei on 13-6-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController+SNInput.h"
#import "SNBaseEditorViewController+SNLayout.h"
#import "SNUserManager.h"
#import "SNSoundManager.h"

NSTimeInterval keyboardAnimationDuration;

@implementation SNBaseEditorViewController (SNInput)

#pragma mark -
#pragma mark toolbarFunction
- (BOOL)SNCommentToolRecordFunction
{
    if (inputViewState == kSNCommentInputStateRecord)
    {
        [_textField becomeFirstResponder];
    }
    else
    {
        _keyBoardHeight = kCommentInputViewHeight;
        if(inputViewState == kSNCommentInputStateBottom)
        {
//            _textLines = [self countTextLineNum];
//            [self setTextLineNum:_textLines];
            [self setTextViewFrame];
        }
        [self layoutSubViews:_mediaMode animation:YES];
        [self changeInputViewStateTo:kSNCommentInputStateRecord
                      keyboardHeight:_keyBoardHeight
                   animationDuration:keyboardAnimationDuration];
    }
    return YES;
}

- (BOOL)SNCommentToolCamraFunction
{
    if (inputViewState == kSNCommentInputStateCamera)
    {
        [_textField becomeFirstResponder];
    }
    else
    {
        _keyBoardHeight = kCommentInputViewHeight;
        if(inputViewState == kSNCommentInputStateBottom)
        {
            [self setTextViewFrame];
        }
        [self layoutSubViews:_mediaMode animation:YES];
        [self changeInputViewStateTo:kSNCommentInputStateCamera
                      keyboardHeight:_keyBoardHeight
                   animationDuration:keyboardAnimationDuration];
    }
    return YES;
}

- (void)SNCommentToolShareFunction
{
    if (inputViewState == kSNCommentInputStateCamera) {
        _picInputView.bottom = _dynamicallyView.height;
        _recordView.top = _dynamicallyView.height;
        _emoticonView.top = _dynamicallyView.height;
    } else if (inputViewState == kSNCommentInputStateRecord) {
        _recordView.bottom = _dynamicallyView.height;
        _emoticonView.top = _dynamicallyView.height;
        _picInputView.top = _dynamicallyView.height;
    } else if (inputViewState == kSNCommentInputStateEmoticon) {
        _emoticonView.bottom = _dynamicallyView.height;
        _recordView.top = _dynamicallyView.height;
        _picInputView.top = _dynamicallyView.height;
    } else if (inputViewState == kSNCommentInputStateKeyboard) {
        _emoticonView.top = _dynamicallyView.height;
        _recordView.top = _dynamicallyView.height;
        _picInputView.top = _dynamicallyView.height;
    }
}

- (BOOL)SNCommentToolEmoticonFunction
{
    if (inputViewState == kSNCommentInputStateEmoticon)
    {
        [_textField becomeFirstResponder];
    }
    else
    {
        _keyBoardHeight = kCommentInputViewHeight;
        if(inputViewState == kSNCommentInputStateBottom)
        {
//            _textLines = [self countTextLineNum];
//            [self setTextLineNum:_textLines];
            [self setTextViewFrame];
        }
        [self layoutSubViews:_mediaMode animation:YES];
        [self changeInputViewStateTo:kSNCommentInputStateEmoticon
                      keyboardHeight:_keyBoardHeight
                   animationDuration:keyboardAnimationDuration];
    }
    return YES;
}

- (void)SNCommentToolSendFunction
{//wangshun share
    if (![[SNUtility getApplicationDelegate] isNetworkReachable])
    {
//        [self showMessage:NSLocalizedString(@"network error", @"")];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }

//    if (![SNUserManager isLogin])
//    {
//        loginType = SNCommentLoginTypeNone;
//
//        if ([self shouldShowLogin])
//        {
//            [SNUserDefaults setObject:[NSDate date] forKey:kCommontLoginTip];
//            [_textField resignFirstResponder];
//            [self startLogin];
//            return;
//        }
//    }
    
    NSInteger count = [self txtContentCount:[_textField.text trim]];
    if (count > 1000)
    {
        [self showMessage:@"评论内容应不多于1000个字"];
        return;
    }
    [[SNSoundManager sharedInstance] stopAmr];
    if ([self respondsToSelector:@selector(contentsWillPost)]) {
        [self performSelector:@selector(contentsWillPost)];
    }
    if ([SNUserManager isLogin]) {
        [self popViewController];
    }
}


@end
