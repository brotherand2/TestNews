//
//  SNGalleryErrorView.m
//  sohunews
//
//  Created by qi pei on 4/23/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNGalleryErrorView.h"
#define ICONIMAEVIEW_OFFSET_Y           (200)
#define ERRORTITLE_OFFSET_Y             (36.0/2)

@implementation SNGalleryErrorView

@synthesize errorDelegate = _errorDelegate;

- (void)layoutSubviews {
    
	if (_iconView) {
		CGRect newFrame = _iconView.frame;
		newFrame.origin = CGPointMake((self.frame.size.width - _iconView.frame.size.width) / 2,
                                      ICONIMAEVIEW_OFFSET_Y);
		_iconView.frame = newFrame;
	}
	
	if (_errorLabel) {
        _errorLabel.textColor = RGBCOLOR(127, 127, 127);
		CGFloat height = ICONIMAEVIEW_OFFSET_Y;
		CGSize maximumSize = CGSizeMake(320, 100);
		CGSize changeSize = [_errorLabel.text sizeWithFont:_errorLabel.font 
                                         constrainedToSize:maximumSize 
                                             lineBreakMode:_errorLabel.lineBreakMode];
		
		if (_iconView) {
			height =  _iconView.frame.origin.y + _iconView.frame.size.height + ERRORTITLE_OFFSET_Y;
		} else {
            height += 80;
        }
		_errorLabel.frame = CGRectMake(self.frame.size.width / 2 - changeSize.width / 2,  
									   height, 
									   changeSize.width, 
									   changeSize.height);
	}
}

-(void)handleGesture:(UIGestureRecognizer*)gestureRecognizer {
    if (_errorDelegate && [_errorDelegate respondsToSelector:@selector(reloadForError)]) {
        [_errorDelegate reloadForError];
    }
}

@end
