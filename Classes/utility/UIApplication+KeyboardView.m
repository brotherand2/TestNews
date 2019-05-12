//
//  UIApplication+KeyboardView.m
//  sohunews
//
//  Created by jojo on 14-2-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "UIApplication+KeyboardView.h"

@implementation UIApplication (KeyboardView)

//  keyboardView
//
//  Copyright Matt Gallagher 2009. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.

- (UIView *)keyboardView;
{
	NSArray *windows = [self windows];
    NSString *clazzName1 = [NSString stringWithFormat:@"UI%@HostView", @"Peripheral"];
    NSString *clazzName2 = [NSString stringWithFormat:@"UI%@board", @"key"];
	for (UIWindow *window in [windows reverseObjectEnumerator])
	{
		for (UIView *view in [window subviews])
		{
            // UIPeripheralHostView is used from iOS 4.0, UIKeyboard was used in previous versions:
			if (!strcmp(object_getClassName(view), [clazzName1 UTF8String]) || !strcmp(object_getClassName(view), [clazzName2 UTF8String]))
			{
				return view;
			}
		}
	}
	
	return nil;
}

@end
