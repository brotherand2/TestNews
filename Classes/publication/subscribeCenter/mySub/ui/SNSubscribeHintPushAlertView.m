//
//  SNSubscribeHintPushAlertView.m
//  sohunews
//
//  Created by wang yanchen on 12-12-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubscribeHintPushAlertView.h"
#import "UIColor+ColorUtils.h"

#define kAlertBGWidth (586/2) //not 450/2
#define kAlertBGHeight (444/2)//not 491/2

#define kAlertBtnWidth (178/2)
#define kAlertBtnHeight (72/2)

#define kBtnLeftPadding (90/2)
#define kBtnBottomPadding (50/2)

#define kTitleTop (46/4)
#define kTitleHeight (70)
#define kTitlePading (54/2)

#define kMsgTop (155/2 + 5)
#define kMsgLeft (54/2)
#define kMsgHeight (70/2)

#define kTitleColor (@"#0xA80013")

@implementation SNSubscribeHintPushAlertView

- (void)drawline {
    const CGFloat *gray;
    CGFloat lineWidth;
    CGFloat lineY = kAlertBGHeight - kAlertBtnHeight - kBtnBottomPadding - 10;
    CGFloat lineW = 536/2;
    
    lineWidth = 0.5f;
    
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    gray = CGColorGetComponents(grayColor.CGColor);
    
	//用2像素的白色描边遮挡1像素的灰色描边,达到画1像素灰线下面2像素白线的目的
    CGContextRef c = UIGraphicsGetCurrentContext();
    
	//add 1px gray stroke
	CGContextSetLineWidth(c, lineWidth);
    CGContextSetStrokeColor(c, gray);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 25.0f, lineY-0.5f);
    CGContextAddLineToPoint(c, lineW, lineY-0.5f);
    CGContextStrokePath(c);

    UIColor *whiteColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor2]];
    const CGFloat *white = CGColorGetComponents(whiteColor.CGColor);
	//add 2px white stroke
	//CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
	CGContextSetLineWidth(c, 0.5f);
    CGContextSetStrokeColor(c, white);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 25.0f, lineY);
    CGContextAddLineToPoint(c, lineW, lineY);
    CGContextStrokePath(c);
}

- (void)drawRect:(CGRect)rect {
    UIImage *bg = [UIImage imageNamed:@"alert_subscribe.png"];
    [bg drawInRect:CGRectMake(0, 0, kAlertBGWidth, kAlertBGHeight)];
    
    if (_title != nil) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitlePading,
                                                                        kTitleTop+15,
                                                                        kAlertBGWidth - kTitlePading * 2,
                                                                        kTitleHeight-20)];
        [titleLabel setText:_title];
        [titleLabel setNumberOfLines:0];
        [titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [titleLabel setFont:[UIFont systemFontOfSize:20]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setContentMode:UIViewContentModeCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTitleColor]];
        [self addSubview:titleLabel];
    }
    
    
    if (_message != nil) {
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMsgLeft,
                                                                      kMsgTop,
                                                                      kAlertBGWidth - kMsgLeft * 2,
                                                                      kMsgHeight)];
        [msgLabel setText:_message];
        [msgLabel setNumberOfLines:0];
        [msgLabel setShadowOffset:CGSizeMake(0, -1)];
        [msgLabel setFont:[UIFont systemFontOfSize:13]];
        [msgLabel setTextAlignment:NSTextAlignmentLeft];
        [msgLabel setBackgroundColor:[UIColor clearColor]];
        msgLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSwitchTextColor]];
        [self addSubview:msgLabel];
    }
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBtn setImage:[UIImage imageNamed:@"alert_subscribe_check_on.png"] forState:UIControlStateNormal];
    [checkBtn setImage:[UIImage imageNamed:@"alert_subscribe_check_off.png"] forState:UIControlStateSelected];
    [checkBtn setTitle:@"接收推送消息" forState:UIControlStateNormal];
    checkBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [checkBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSwitchTextColor]] forState:UIControlStateNormal];
    [checkBtn setFrame:CGRectMake(kMsgLeft-15, kMsgTop + kMsgHeight, 240/2, 28)];
    [checkBtn addTarget:self action:@selector(checkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    checkBtn.selected = YES;
    checkBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:checkBtn];
    _isChecked = YES;
    
    [self drawline];
    
    CGFloat btnTop =  kAlertBGHeight - kAlertBtnHeight - kBtnBottomPadding;

	if (_cancelButtonTitle) {
		CGFloat w = _otherButtonTitle ? kAlertBtnWidth : (kAlertBGWidth - 2 * kBtnLeftPadding);
		UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kBtnLeftPadding, btnTop, w, kAlertBtnHeight)];
		[cancelBtn setTitle:_cancelButtonTitle forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        [cancelBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSwitchTextColor]] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"alert_unsub_btn.png"]
									   stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2]
							 forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"alert_unsub_btn_hl.png"]
                                       stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2]
                             forState:UIControlStateHighlighted];
        [cancelBtn setTag:0];
		[cancelBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:cancelBtn];
	}
	
	if (_otherButtonTitle) {
        CGFloat w = _cancelButtonTitle ? kAlertBtnWidth : (kAlertBGWidth - 2 * kBtnLeftPadding);
		CGFloat x = _cancelButtonTitle ? (kAlertBGWidth - kAlertBtnWidth - kBtnLeftPadding) : kBtnLeftPadding;
		UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, btnTop, w, kAlertBtnHeight)];
		[otherBtn setTitle:_otherButtonTitle forState:UIControlStateNormal];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [otherBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTitleColor]] forState:UIControlStateNormal];
        [otherBtn setBackgroundImage:[[UIImage imageNamed:@"alert_unsub_btn.png"]
									  stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2]
							forState:UIControlStateNormal];
        [otherBtn setBackgroundImage:[[UIImage imageNamed:@"alert_unsub_btn_hl.png"]
                                      stretchableImageWithLeftCapWidth:kAlertBtnHeight/2 topCapHeight:kAlertBtnHeight/2]
                            forState:UIControlStateHighlighted];
        [otherBtn setTag:1];
		[otherBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:otherBtn];
	}
}
- (void)dismiss:(UIButton *)button {
    
}
- (void)checkBtnClicked:(UIButton *)button {

}

@end
