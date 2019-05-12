//
//  SNRefreshMessageView.m
//  sohunews
//
//  Created by lhp on 7/30/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRefreshMessageView.h"
#import "UIColor+ColorUtils.h"

#import "SNGuideRegisterManager.h"

@interface SNRefreshMessageView ()

@end

#define kRefreshMessageViewHeight 105
@implementation SNRefreshMessageView
@synthesize tipsLink;
@synthesize hideTimer = _hideTimer;
@synthesize showTips;

+ (SNRefreshMessageView *)sharedInstance {
    static SNRefreshMessageView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SNRefreshMessageView alloc] init];
    });
    return instance;
}

- (id)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, -5, kAppScreenWidth, kRefreshMessageViewHeight);
        self.backgroundColor = [UIColor clearColor];
        self.bottom = 0.f;
        
        _backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenHeight, kRefreshMessageViewHeight)];
        [self addSubview:_backGroundImageView];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kRefreshMessageViewHeight - 29.f, kAppScreenWidth, 16)];
        _messageLabel.font = [UIFont systemFontOfSize:15.5];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.accessibilityLabel = @"";
        [self addSubview:_messageLabel];
        
        _tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _tipsImageView.image = [UIImage themeImageNamed:@"refresh_arrow.png"];
        [self addSubview:_tipsImageView];
        
        UIButton *tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tipsButton.frame = CGRectMake(0, 0, kAppScreenWidth, kRefreshMessageViewHeight);
        [tipsButton addTarget:self action:@selector(openTips) forControlEvents:UIControlEventTouchUpInside];
        tipsButton.isAccessibilityElement = NO;
        [self addSubview:tipsButton];
        
        [self updateTheme];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)setMessageInfo:(NSString *) messageText showTipsImage:(BOOL) show{
        
    if (messageText) {
        int tipsWidth = show?20:0;
        float topadding = SYSTEM_VERSION_LESS_THAN(@"7.0") ? -4.f : 0.f;
        CGSize messageSize = [messageText sizeWithFont:[UIFont systemFontOfSize:15.5]];
        messageSize.width = MIN(messageSize.width, kAppScreenWidth-20-tipsWidth);
        int message_x = (kAppScreenWidth - messageSize.width -tipsWidth) /2;
        _messageLabel.frame = CGRectMake(message_x, kRefreshMessageViewHeight - 29.f +topadding, messageSize.width, 16);
        _tipsImageView.frame = CGRectMake(message_x + messageSize.width + 9.5, _messageLabel.top + 2.f, 10, 10);
        _messageLabel.text = messageText;
        _tipsImageView.hidden = !show;
    }
}

- (void)updateTheme{
    NSString *selectedStrColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRefreshMessageColor];
    _messageLabel.textColor = [UIColor colorFromString:selectedStrColor];
    _backGroundImageView.image = [UIImage themeImageNamed:@"refreshmessage.png"];
    _tipsImageView.image = [UIImage themeImageNamed:@"refresh_arrow.png"];
}

- (void)openTips {
    if (tipsLink) {
        
        if ([tipsLink hasPrefix:@" login://"] || [tipsLink hasPrefix:@"login://"])
        {
            [SNGuideRegisterManager showLoginActionSheetWithDict:@{kContent:_messageLabel.text}];
            [SNNotificationManager postNotificationName:kSNRefreshMessageViewDidTapTipsToLoginNotification object:[NSString stringWithString:tipsLink]];
            return;
        }
        
        if ([tipsLink hasPrefix:@"tt://"]) {
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:tipsLink] applyAnimated:YES] applyQuery:nil];
            [[TTNavigator navigator] openURLAction:urlAction];
        }else {
            [SNUtility openProtocolUrl:tipsLink];
        }
        [self hideTipsMessageAnimation];
        
        // 发个通知 需要的统计的地方处理一下 
        [SNNotificationManager postNotificationName:kSNRefreshMessageViewDidTapTipsNotification object:[NSString stringWithString:tipsLink]];
    }
}

- (void)hideTipsMessageAnimation {
    
    showTips = NO;
    if (_hideTimer) {
        [_hideTimer invalidate];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bottom = 0.f;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)showTipsMessageAnimation {
    
    if (!showTips) {
        showTips = YES;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             float topadding = SYSTEM_VERSION_LESS_THAN(@"7.0") ? 6.f : 0.f;
                             self.bottom = 38.f + kHeaderTotalHeight + topadding;
                         } completion:^(BOOL finished) {
                         }];
        
        if (_hideTimer) {
            [_hideTimer invalidate];
        }
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f
                                                          target:self
                                                        selector:@selector(hideTipsMessageAnimation)
                                                        userInfo:nil
                                                         repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.hideTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)showMessageAnimation{
    [self showMessageAnimationDuration:1.0];
}

- (void)showMessageAnimationDuration:(NSTimeInterval)dur {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         float topadding = 0.0f;
                         if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
                             topadding = 6.0f;
                         }
                         self.bottom = 38.f + kHeaderTotalHeight + topadding;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:dur
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.bottom = 0.f;
                                          } completion:^(BOOL finished) {
                                          }];
                     }];
    
}

- (void)dealloc{
     //(_messageLabel);
     //(_backGroundImageView);
     //(tipsLink);
    [_hideTimer invalidate];
     //(_hideTimer);
     //(_tipsImageView);
    [SNNotificationManager removeObserver:self];
}

@end
