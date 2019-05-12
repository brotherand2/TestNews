//
//  SNLiveRoomTapView.m
//  sohunews
//
//  Created by chenhong on 13-5-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomTapView.h"
#import "SNLiveRoomContentCell.h"

@implementation SNLiveRoomTapView
@synthesize cell, canReply, canCopy, canShare;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];//[[UIColor redColor] colorWithAlphaComponent:0.2];//
        self.exclusiveTouch = YES;
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}


- (void)setMenuInvalid
{
    [self removeGestureRecognizer:_tapGesture];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
        && [cell keyboardShow]) {
        return NO;
    }
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(replyComment) /*&& canReply*/) {
        return YES;
    }
    if (action == @selector(copyContent) && canCopy) {
		return YES;
	}
    if (action == @selector(shareContent) /*&& canShare*/) {
        return YES;
    }
	return NO;
}

-(void)openMenu:(UITapGestureRecognizer *)tapGesture {
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible]) {
        [contextMenu setMenuVisible:NO];
    } else {
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [contextMenu setMenuVisible:NO];
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        
        UIMenuItem *replyMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyComment)];
        [menuItemsArray addObject:replyMenuItem];
        
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyContent)];
        [menuItemsArray addObject:copyMenuItem];
        
        UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareContent)];
        [menuItemsArray addObject:shareMenuItem];
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        [contextMenu setTargetRect:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height-10) inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}

- (void)copyContent {
    if (cell && [cell respondsToSelector:@selector(copyContent:)]) {
        [cell performSelector:@selector(copyContent:) withObject:self];
    }
}

- (void)replyComment {
    if (cell && [cell respondsToSelector:@selector(replyComment:)]) {
        [cell performSelector:@selector(replyComment:) withObject:self];
    }
}

- (void)shareContent {
    if (cell && [cell respondsToSelector:@selector(shareContent:)]) {
        [cell performSelector:@selector(shareContent:) withObject:self];
    }
}

@end
