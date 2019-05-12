//
//  SNCommentEditorViewController+Layout.h
//  sohunews
//
//  Created by jialei on 13-6-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController.h"

@interface SNBaseEditorViewController (SNLayout)

- (void)changeInputViewStateTo:(SNCommentInputState)newState
                keyboardHeight:(CGFloat)keyboardHeight
             animationDuration:(NSTimeInterval)duration;

@end
