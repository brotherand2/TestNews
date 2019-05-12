//
//  SNScrollLabel.m
//  sohunews
//
//  Created by Dan on 6/28/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNScrollLabel.h"

#define kEdgeInset 10
#define kMaxHeight 80

@implementation SNScrollLabel

@synthesize text = _text, canScroll;

- (id)init {
    
    self = [super init];
    if (self) {
		[self setBackgroundColor:[UIColor colorWithWhite:0 alpha:kTransparentBGAlpha]];
        _textLabel = [[UILabel alloc] init];
		[_textLabel setFont:[UIFont systemFontOfSize:14]];
		[_textLabel setNumberOfLines:0];
		[_textLabel setBackgroundColor:[UIColor clearColor]];
		[_textLabel setTextColor:[UIColor whiteColor]];
		[_textLabel setLineBreakMode:NSLineBreakByCharWrapping];
		[self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
		[self setAlwaysBounceVertical:YES]; 
		[self addSubview:_textLabel];
		[self setContentInset:UIEdgeInsetsMake(0, kEdgeInset, 0, kEdgeInset)];
    }
    return self;
}

- (void)setText:(NSString *)text {
	_text = text;
	_textLabel.text = text;

	CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(TTScreenBounds().size.width - kEdgeInset * 2, 0)];
	_textLabel.frame = CGRectMake(0, 0, textSize.width, textSize.height);

	self.contentSize = textSize;
	canScroll = self.contentSize.height > kMaxHeight;
	[self setScrollEnabled:canScroll];
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize maximumLabelSize = CGSizeMake(TTScreenBounds().size.width - kEdgeInset * 2, kMaxHeight);
	
	CGSize expectedLabelSize = [_text sizeWithFont:_textLabel.font
									  constrainedToSize:maximumLabelSize 
										  lineBreakMode:_textLabel.lineBreakMode]; 
	
	return expectedLabelSize;
}



@end
