//
//  WSMVVideoControlBar_FullScreen.h
//  WeSee
//
//  Created by handy wang on 9/9/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import "WSMVVideoControlBar.h"

@interface WSMVVideoControlBar_FullScreen : WSMVVideoControlBar
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *volumeBtn;
@property (nonatomic, strong) UIButton *previousVideoBtn;
@property (nonatomic, strong) UIButton *nextVideoBtn;

- (void)enableShare;
- (void)disableShare;
@end
