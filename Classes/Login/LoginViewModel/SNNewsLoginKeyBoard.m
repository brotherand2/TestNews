//
//  SNNewsLoginKeyBoard.m
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginKeyBoard.h"

@implementation SNNewsLoginKeyBoard

- (instancetype)initWithHalfLoginView:(UIView*)view{
    if (self = [super init]) {
        self.half_view = view;
    }
    return self;
}

- (instancetype)initWithToolbar:(SNToolbar*)toolbar{
    if (self = [super init]) {
        self.toolbarView = toolbar;
    }
    return self;
}

#pragma mark - keyboardWillShow

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    if (self.toolbarView == nil) {
        if (self.half_view) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyBoardHeight:)]) {
                [self.delegate keyBoardHeight:keyboardSize];
            }
        }
        return;
    }
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height - keyboardSize.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
    
}

#pragma mark - keyboardWillHide

- (void)keyboardWillHide:(NSNotification *)notification{
    if (self.toolbarView == nil) {
        if (self.half_view) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyBoardHeight:)]) {
                [self.delegate keyBoardHeight:CGSizeZero];
            }
        }
        return;
    }
    
    self.toolbarView.frame = CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight);
}

#pragma mark - createkeyboardNotification

- (void)createkeyboardNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - removeKeyBoardNotification

- (void)removeKeyBoardNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



@end
