//
//  SNNameButton.m
//  sohunews
//
//  Created by chenhong on 13-5-22.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNNameButton.h"

@implementation SNNameButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleEdgeInsets = UIEdgeInsetsMake(3.f, 0, 0, 0);
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.highlighted == YES) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *selectColor = [UIColor colorWithRed:198 / 255.0
                                               green:215 / 255.0
                                                blue:231 / 255.0
                                               alpha:1];
        CGContextSetFillColorWithColor(context, selectColor.CGColor);
        CGContextFillRect(context, self.bounds);
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"highlighted"];
}

@end
