//
//  SNViewBorder.m
//  sohunews
//
//  Created by chenhong on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNViewBorder.h"

@implementation SNViewBorder

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.layer.borderWidth = 2.0f;
		self.layer.borderColor = [UIColor redColor].CGColor;
	}
	return self;
}

- (void)didMoveToSuperview
{
	self.layer.cornerRadius = self.superview.layer.cornerRadius;
}

- (void)startAnimation
{
	self.alpha = 1.0f;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didAppearingAnimationStopped)];
	
	self.alpha = 0.0f;
    
	[UIView commitAnimations];
}

- (void)didAppearingAnimationStopped
{
	[self removeFromSuperview];
}


@end
