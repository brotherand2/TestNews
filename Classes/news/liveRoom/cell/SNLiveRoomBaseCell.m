//
//  SNLiveRoomBaseCell.m
//  sohunews
//
//  Created by Chen Hong on 4/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNLiveRoomBaseCell.h"

@implementation SNLiveRoomBaseCell
@synthesize object=_object;
@synthesize tableViewController = _tableViewController;

- (void)dealloc {
     //(_object);
    _tableViewController = nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.object = nil;
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    [SNUtility openProtocolUrl:link];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        if ([_tableViewController respondsToSelector:@selector(didEndDisplayingCell:)]) {
            [_tableViewController didEndDisplayingCell:self];
        }
    }
}

@end
