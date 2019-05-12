//
//  WSMVPlayerCopyrightMsgView.h
//  sohunews
//
//  Created by handy wang on 10/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMVPlayerCopyrightMsgView : UIControl
@property (nonatomic, weak)id delegate;

- (void)updateContentToFullscreen;
- (void)updateContentToNonFullscreen;
@end

@protocol WSMVPlayerCopyrightMsgView <NSObject>
- (void)toWapPage;
@end
