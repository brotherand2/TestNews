//
//  SNHighlightedTextButton.m
//  sohunews
//
//  Created by handy wang on 5/12/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNHighlightedTextButton.h"
#import "SNLabel.h"

@interface SNHighlightedTextButton() {
    SNLabel *_countdownLabel;
}
@end

@implementation SNHighlightedTextButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _countdownLabel = [[SNLabel alloc] initWithFrame:self.bounds];
        _countdownLabel.backgroundColor = [UIColor clearColor];
        _countdownLabel.linkColor = RGBCOLOR(0xc8, 0, 0);
        _countdownLabel.disableLinkDetect = YES;
        _countdownLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countdownLabel];
    }
    return self;
}

#pragma mark - Public
- (void)setText:(NSString *)text highlightedText:(NSString *)highlightedText {
    [_countdownLabel removeAllHighlightInfo];
    _countdownLabel.text = text;
    [_countdownLabel addHighlightText:highlightedText inRange:[text rangeOfString:highlightedText]];

    [self updateCountdownLabelHeightAndTop];
}

- (void)setTextFont:(UIFont *)font {
    [_countdownLabel setFont:font];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _countdownLabel.frame = self.bounds;
    
    [self updateCountdownLabelHeightAndTop];
}

- (void)setTextColor:(UIColor *)textColor {
    [_countdownLabel setTextColor:textColor];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [_countdownLabel setTextAlignment:textAlignment];
}

#pragma mark - Private
- (void)updateCountdownLabelHeightAndTop {
    CGSize textSize = [_countdownLabel.text sizeWithFont:_countdownLabel.font];
    _countdownLabel.height = textSize.height+5;
    _countdownLabel.top = (self.height-_countdownLabel.height)/2.0f;
}

@end