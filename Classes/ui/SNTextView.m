//
//  SNTextView.m
//  sohunews
//
//  Created by guoyalun on 10/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTextView.h"

@implementation SNTextView


- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [UIMenuController sharedMenuController].menuItems = nil;
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.selectedRange.length > 0) {
        if (action == @selector(copy:) || action == @selector(cut:)) {
            return YES ;
        }
    } else {
        if (action == @selector(select:) || action == @selector(selectAll:)) {
            return YES ;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (action == @selector(paste:)) {
        return [super canPerformAction:action withSender:sender];
    } else if (action == @selector(share:)){
        return NO;
    }
#pragma clang diagnostic pop
    return NO;

}


@end
