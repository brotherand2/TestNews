//
//  WSMVVideoVolumnBarMask.m
//  WeSee
//
//  Created by handy on 9/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoVolumnBarMask.h"

@implementation WSMVVideoVolumnBarMask

- (id)initWithFrame:(CGRect)frame volumnBarFrame:(CGRect)volumnBarFrame volumnBtnFrame:(CGRect)volumnBtnFrame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        if (!_volumnBar) {
            self.volumnBar = [[WSMVVideoVolumnBar alloc] initWithFrame:volumnBarFrame];
            self.volumnBar.userInteractionEnabled = YES;
            [self addSubview:self.volumnBar];
            
            self.volumnBtnFrame = volumnBtnFrame;
        }
    }
    return self;
}


#pragma mark - Public
- (void)dismissSelf {
    if ([_delegate respondsToSelector:@selector(hideVolumnBarMask)]) {
        [_delegate hideVolumnBarMask];
    }
}

#pragma mark - Override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.alpha == 1 && CGRectContainsPoint(self.volumnBar.frame, point)) {
        self.userInteractionEnabled = YES;//这样做是为了不让事件传递到mask区域下面的视图，而是让volumnBar来接收事件
        return [super hitTest:point withEvent:event];
    }
    
    //当事件坐标是在音量钮的区域时把事件传给音量钮来响应事件，而不是在这里来隐藏mask自己
    if (self.alpha == 1 && CGRectContainsPoint(self.volumnBtnFrame, point)) {
        self.userInteractionEnabled = NO;//这样做后，才能使在mask上的事件传递给mask区域下面的视图
        return [super hitTest:point withEvent:event];
    }

    if (self.alpha == 1 && CGRectContainsPoint(self.frame, point)) {
        self.userInteractionEnabled = NO;//这样做后，才能使在mask上的事件传递给mask区域下面的视图
        if ([_delegate respondsToSelector:@selector(hideVolumnBarMask)]) {
            [_delegate hideVolumnBarMask];
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
