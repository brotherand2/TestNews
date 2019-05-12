//
//  SNAlert.m
//  sohunews
//
//  Created by wangxiang on 4/17/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNAlert.h"

//NOTE：
//A UIAlertView is actually an image. Trying to set the frame to the same size as bg image will cause
//the alert view image enlarged and obscure. 
//so make the kAlertBGWidth and kAlertBGHeight smaller than actual bg image size.
#define kAlertBGWidth (638/2) //not 450/2
#define kAlertBGHeight (368/2)//not 491/2

#define kAlertBtnWidth (178/2)
#define kAlertBtnHeight (72/2)

#define kBtnLeftPadding (124/2)
#define kBtnBottomPadding (80/2)

#define kTitleTop (82/2)
#define kTitleHeight (42/2)
#define kMsgHeight (90/2)
#define kContentPadding (100/2)

@implementation SNAlert

- (void)setFrame:(CGRect)rect {
	[super setFrame:CGRectMake(0, 0, kAlertBGWidth, kAlertBGHeight)];
	self.center = CGPointMake(TTScreenBounds().size.width / 2, TTScreenBounds().size.height / 2);
}

- (void)drawRect:(CGRect)rect {
    UIImage *bg = [UIImage themeImageNamed:@"alert_unsub_bg.png"];
    [bg drawInRect:CGRectMake(0, 0, kAlertBGWidth, kAlertBGHeight)];
    
    float title_top = kTitleTop;
    float message_top = kTitleTop + kTitleHeight + 2;
    
    if ([_title length] == 0) {
        message_top = kTitleTop + 15;
    }
    if ([_message length] == 0) {
        title_top = kTitleTop + 15;
    }
    
    if (_title != nil) {
        NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAlertTitleTextColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentPadding,
                                                                      title_top, 
                                                                      kAlertBGWidth - kContentPadding * 2, 
                                                                      kTitleHeight)];
        [titleLabel setText:_title];
        [titleLabel setNumberOfLines:0];
        [titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [titleLabel setFont:[UIFont systemFontOfSize:20]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.textColor = [UIColor colorFromString:titleColor];
        [self addSubview:titleLabel];
    }
    
    if (_message != nil) {
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAlertMsgTextColor];

        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentPadding,
                                                                      message_top,
                                                                      kAlertBGWidth - kContentPadding * 2,
                                                                      kMsgHeight)];
        [msgLabel setText:_message];
        [msgLabel setNumberOfLines:0];
        [msgLabel setShadowOffset:CGSizeMake(0, -1)];
        [msgLabel setFont:[UIFont systemFontOfSize:13]];
        [msgLabel setTextAlignment:NSTextAlignmentCenter];
        [msgLabel setBackgroundColor:[UIColor clearColor]];
        msgLabel.textColor = [UIColor colorFromString:strColor];
        [self addSubview:msgLabel];
    }
    
    NSString *btnColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAlertMsgBtnTextColor];

    CGFloat btnTop =  kAlertBGHeight - kAlertBtnHeight - kBtnBottomPadding;
	NSString *strBtnNomal = @"alert_unsub_btn.png";
    NSString *strBtnPress = @"alert_unsub_btn_hl.png";
	if (_cancelButtonTitle) {
		CGFloat w = _otherButtonTitle ? kAlertBtnWidth : (kAlertBGWidth - 2 * kBtnLeftPadding);
		UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kBtnLeftPadding, btnTop, w, kAlertBtnHeight)];
		[cancelBtn setTitle:_cancelButtonTitle forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        [cancelBtn setTitleColor:[UIColor colorFromString:btnColor] forState:UIControlStateNormal]; 
        [cancelBtn setBackgroundImage:[[UIImage imageNamed:strBtnNomal]
									   stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2] 
							 forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[[UIImage imageNamed:strBtnPress]
                                       stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2] 
                             forState:UIControlStateHighlighted];
        [cancelBtn setTag:0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
		[cancelBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
		[self addSubview:cancelBtn];
	}
	
	if (_otherButtonTitle) {
        CGFloat w = _cancelButtonTitle ? kAlertBtnWidth : (kAlertBGWidth - 2 * kBtnLeftPadding);
		CGFloat x = _cancelButtonTitle ? (kAlertBGWidth - kAlertBtnWidth - kBtnLeftPadding) : kBtnLeftPadding;
		UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, btnTop, w, kAlertBtnHeight)];
		[otherBtn setTitle:_otherButtonTitle forState:UIControlStateNormal];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [otherBtn setTitleColor:[UIColor colorFromString:btnColor] forState:UIControlStateNormal]; 
        [otherBtn setBackgroundImage:[[UIImage imageNamed:strBtnNomal]
									  stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2] 
							forState:UIControlStateNormal];
        [otherBtn setBackgroundImage:[[UIImage imageNamed:strBtnPress]
                                      stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2] 
                            forState:UIControlStateHighlighted];
        [otherBtn setTag:1];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
		[otherBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:otherBtn];
#pragma clang diagnostic pop

	}
}


@end
