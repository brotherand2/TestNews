//
//  SNCommentEditorViewController+Layout.m
//  sohunews
//
//  Created by jialei on 13-6-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController+SNLayout.h"
#import "SNCommentConfigs.h"

@implementation SNBaseEditorViewController (SNLayout)

#pragma mark - Keyboard Notifications
#pragma mark - Notification

- (void)notifyPushDidReceive {
    if (_textField) {
        [self popViewController];
    }
    
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (!isViewVisible)
	{
		return;
	}
	
	//获取键盘的rect
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
	if (duration == 0)
	{
		duration = .25;
	}
	
	// Need to translate the bounds to account for rotation.
	keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //ios5中英文切换键盘高度改变后不会触发keyboardHeight通知，再次修改keyboard高度
    _keyBoardHeight = keyboardBounds.size.height;
    
    [self layoutSubViews:_mediaMode animation:YES];
    [self changeInputViewStateTo:kSNCommentInputStateKeyboard
	              keyboardHeight:keyboardBounds.size.height
	           animationDuration:duration];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	if (!isViewVisible)
	{
		return;
	}
	if (inputViewState != kSNCommentInputStateKeyboard)
	{
		return;
	}
	
	// Get keyboard size and loctaion.
//	NSDictionary *userInfo = [notification userInfo];
//	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Need to translate the bounds to account for rotation.
//	keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
//    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!isViewVisible)
	{
		return;
	}
	
	// Get keyboard size and loctaion.
	NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self layoutSubViews:_mediaMode animation:YES];
    _keyBoardHeight = keyboardBounds.size.height;
    
	if (inputViewState == kSNCommentInputStateBottom)
	{
		[self downInputViewWithAnimationDuration:duration];
	}
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    
}

- (void)keyboardHeight:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float height = keyboardBounds.size.height;
//    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    if (_keyBoardHeight != height)
    {
        _keyBoardHeight = height;
        if (inputViewState == kSNCommentInputStateCamera ||
            inputViewState == kSNCommentInputStateRecord ||
            inputViewState == kSNCommentInputStateEmoticon) {
            _keyBoardHeight = kCommentInputViewHeight;
        }
        isChangeKeyboardHeight = YES;
        [self layoutSubViews:_mediaMode animation:YES];
//        if (_keyBoardHeight > 0) {
//            inputViewState = kSNCommentInputStateKeyboard;
//        }
    }
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (_toolBar.commentToolBarType == SNCommentToolBarTypeShowNone) {
//        return;
//    }
//    
//    UITouch *touchPint = [touches anyObject];
//    CGPoint clickedPoint = [touchPint locationInView:self.view];
//    
//    touchStartPointY = clickedPoint.y;
//    
//    [[self nextResponder] touchesBegan:touches withEvent:event];
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_toolBar.commentToolBarType == SNCommentToolBarTypeShowNone) {
//        return;
//    }
//    
//    UITouch *touchPint = [touches anyObject];
//    CGPoint clickedPoint = [touchPint locationInView:self.view];
//    float touchEndPointY = clickedPoint.y;
//    float movedDistance = touchEndPointY - touchStartPointY;
//    
//    if (abs(movedDistance) > 5.0)
//    {
//        [self changeInputViewStateTo:kSNCommentInputStateBottom
//                      keyboardHeight:0
//                   animationDuration:kCEAnimationDuration];
////        int num = _textField.numberOfLines;
////        [self setTextLineNum:MIN(MAX(_textField.numberOfLines, _textLines), _maxLines)];
//    }
//    else
//    {
//        [_textView becomeFirstResponder];
//        [[self nextResponder] touchesEnded:touches withEvent:event];
//        [super touchesEnded:touches withEvent:event];
//    }
//    [self layoutSubViews:_mediaMode animation:YES];
//}

- (void)growingTextViewDidChangeSelection:(FastTextView *)growingTextView
{
}

- (void)growingTextViewDidScroll
{
//    if (inputViewState == kSNCommentInputStateBottom)
//    {
//        return;
//    }
//    [self changeInputViewStateTo:kSNCommentInputStateBottom
//                  keyboardHeight:0
//               animationDuration:kCEAnimationDuration];
//    int n = _textField.numberOfLines;
//    [self setTextLineNum:MIN(MAX(_textField.numberOfLines, _textLines), _maxLines)];
}

//隐藏输入区
- (void)downInputViewWithAnimationDuration:(NSTimeInterval)duration
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:duration];
	
	_toolBar.bottom = _dynamicallyView.height;
    _cmtShareBar.bottom = _toolBar.top;
	_textField.top = _dynamicallyView.height;
	
	[UIView commitAnimations];
}

- (void)changeInputViewStateTo:(SNCommentInputState)newState
                keyboardHeight:(CGFloat)keyboardHeight
             animationDuration:(NSTimeInterval)duration
{
	if (inputViewState == newState)
	{
        if (newState == kSNCommentInputStateKeyboard) {
            _emoticonView.top = _dynamicallyView.height;
            _recordView.top = _dynamicallyView.height;
            _picInputView.top = _dynamicallyView.height;
        }
		return;
	}
	SNCommentInputState currentState = inputViewState;
	inputViewState = newState;
    
	switch (newState)
	{
        case kSNCommentInputStateBottom:
        {
            if (currentState == kSNCommentInputStateKeyboard)
            {
//                [_textField resignFirstResponder];
            }
            if (currentState == kSNCommentInputStateCamera)
            {
                [_toolBar changedCameraButtonState];
                [UIView beginAnimations:nil context:NULL];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[UIView setAnimationDuration:duration];
				
				_picInputView.top= _dynamicallyView.height;
				
				[UIView commitAnimations];
            }
            if (currentState == kSNCommentInputStateRecord)
            {
                [_toolBar changedRecordButtonState];
                [UIView beginAnimations:nil context:NULL];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[UIView setAnimationDuration:duration];
				
				_recordView.top = _dynamicallyView.height;
				
				[UIView commitAnimations];
            }
            if (currentState == kSNCommentInputStateEmoticon) {
                [_toolBar changedEmoticonButtonState];
                [UIView beginAnimations:nil context:NULL];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[UIView setAnimationDuration:duration];
				
				_emoticonView.top = _dynamicallyView.height;
				
				[UIView commitAnimations];
            }
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:duration];
            
            _toolBar.bottom = _dynamicallyView.height;
            _cmtShareBar.bottom = _toolBar.top;
            inputViewState = kSNCommentInputStateBottom;
            [UIView commitAnimations];
        }
            break;
		case kSNCommentInputStateKeyboard:
        {
            [self changeCurrentInputState:nil currentState:currentState];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:duration];
            
            _toolBar.bottom = _dynamicallyView.height - keyboardHeight;
            _cmtShareBar.bottom = _toolBar.top;
            
            [UIView commitAnimations];
            break;
        }
        case kSNCommentInputStateCamera:
        {
            //改变工具栏按钮状态
            [_toolBar changedCameraButtonState];
            _picInputView.hidden = NO;
            [self changeCurrentInputState:_picInputView currentState:currentState];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:kCEAnimationDuration];
            _toolBar.bottom = _picInputView.top;
            _cmtShareBar.bottom = _toolBar.top;
            [UIView commitAnimations];
//            [self setTextLineNum:_textLines];
            break;
        }
        case kSNCommentInputStateRecord:
        {
            //改变工具栏按钮状态
            [_toolBar changedRecordButtonState];
            _recordView.hidden = NO;
            [self changeCurrentInputState:_recordView currentState:currentState];

            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:kCEAnimationDuration];
            _toolBar.bottom = _recordView.top;
            _cmtShareBar.bottom = _toolBar.top;
            [UIView commitAnimations];
            break;
        }
        case kSNCommentInputStateEmoticon:
        {
            //改变工具栏按钮状态
            [_toolBar changedEmoticonButtonState];
            _emoticonView.hidden = NO;
            [self changeCurrentInputState:_emoticonView currentState:currentState];

            _toolBar.bottom = _emoticonView.top;
            _cmtShareBar.bottom = _toolBar.top;

            break;
        }
		default:
			break;
	}
//    [self setMediaViewPosition:YES];
}

- (void)changeCurrentInputState:(UIView *)currentView currentState:(SNCommentInputState)state
{
    CGFloat viewHeight = _dynamicallyView.height;
    
    if (state == kSNCommentInputStateBottom)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        currentView.bottom = viewHeight;
        [UIView commitAnimations];
    }
    
    if (state == kSNCommentInputStateKeyboard)
    {
        [_textField resignFirstResponder];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        currentView.bottom = viewHeight;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        
        [UIView commitAnimations];
    }
    else if (state == kSNCommentInputStateCamera)
    {
        [_toolBar changedCameraButtonState];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        _picInputView.top = viewHeight;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        currentView.bottom = viewHeight;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelay:0.2];
        [UIView setAnimationDuration:kCEAnimationDuration];
        
        [UIView commitAnimations];
    }
    if (state == kSNCommentInputStateRecord) {
        [_toolBar changedRecordButtonState];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        _recordView.top = viewHeight;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        currentView.bottom = viewHeight;
        [UIView commitAnimations];
    }
    else if (state == kSNCommentInputStateEmoticon)
    {
        [_toolBar changedEmoticonButtonState];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        _emoticonView.top = viewHeight;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:kCEAnimationDuration];
        currentView.bottom = viewHeight;
        [UIView commitAnimations];
    }
}

@end
