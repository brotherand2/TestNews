//
//  SNRefreshMessageView.h
//  sohunews
//
//  Created by lhp on 7/30/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNRefreshMessageView : UIView{
    UILabel *_messageLabel;
    UIImageView *_backGroundImageView;
    UIImageView *_tipsImageView;
    NSString *tipsLink;
    NSTimer *_hideTimer;
    BOOL showTips;
}

@property(nonatomic,strong) NSString *tipsLink;
@property(nonatomic,strong) NSTimer *hideTimer;
@property(nonatomic,assign) BOOL showTips;
@property(nonatomic,assign) BOOL statusbarHidden;

+ (SNRefreshMessageView *)sharedInstance;
- (void)setMessageInfo:(NSString *) messageText showTipsImage:(BOOL) show;
- (void)showMessageAnimation;
- (void)showMessageAnimationDuration:(NSTimeInterval)dur;
- (void)showTipsMessageAnimation;

@end
