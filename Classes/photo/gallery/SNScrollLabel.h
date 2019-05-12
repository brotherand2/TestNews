//
//  SNScrollLabel.h
//  sohunews
//
//  Created by Dan on 6/28/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNScrollLabel : UIScrollView {

	UILabel *_textLabel;
	NSString *_text;
	
	BOOL canScroll;
}

@property (nonatomic, retain)NSString *text;
@property (nonatomic)BOOL canScroll;

@end
