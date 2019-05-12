//
//  SNLiveRoomTableHeaderDragRefreshView.m
//  sohunews
//
//  Created by chenhong on 13-8-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomTableHeaderDragRefreshView.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
const CGFloat kLiveRefreshDeltaY = -55.0f;

// The height of the refresh header when it is in its "loading" state.
const CGFloat kLiveHeaderVisibleHeight = 60.0f;

@implementation SNLiveRoomTableHeaderDragRefreshView

- (CGFloat)refreshStartPosY {
    return -kLiveRefreshDeltaY;
}

@end
