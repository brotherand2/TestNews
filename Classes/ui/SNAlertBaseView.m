//
//  SNAlertBaseView.m
//  sohunews
//
//  Created by Dan on 7/29/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNAlertBaseView.h"

//NOTE：
//A UIAlertView is actually an image. Trying to set the frame to the same size as bg image will cause
//the alert view image enlarged and obscure.
//so make the kAlertBGWidth and kAlertBGHeight smaller than actual bg image size.
#define kAlertBGWidth (448/2) //not 450/2
#define kAlertBGHeight (288/2)//not 491/2

#define kAlertBtnWidth (166/2)
#define kAlertBtnHeight (66/2)

#define kBtnLeftPadding (46/2)
#define kBtnBottomPadding (60/2)

#define kTitleTop (46/4)
#define kTitleHeight (70)

@implementation SNAlertBaseView

@synthesize snAlertUserData = _snAlertUserData;

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
		   delegate:(id /*<UIAlertViewDelegate>*/)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle {
	
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self = [super init];
    } else {
        self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    }
	if (self) {
		_title = [title copy];
		_message = [message copy];
		_cancelButtonTitle = [cancelButtonTitle copy];
		_otherButtonTitle = [otherButtonTitle copy];
		_alertDelegate = delegate;
		
	}
	
	return self;
}

- (NSString *)title {
	return _title;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismiss:(UIButton *)sender {
    
	[super dismissWithClickedButtonIndex:sender.tag animated:YES];
	[_alertDelegate alertView:self clickedButtonAtIndex:sender.tag];
}


- (void)didAddSubview:(UIView *)subview {
	//remove default bg
	if ([subview isMemberOfClass:[UIImageView class]]) {
		[subview removeFromSuperview];
	}
}

- (void)dealloc {
	_alertDelegate = nil;
	
    
}

@end
