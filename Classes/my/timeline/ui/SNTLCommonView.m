//
//  SNTLCommonView.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLCommonView.h"

@interface SNTLCommonView () {
    UIButton *_actionButton;
    UIView *_imageView;
}

@end

@implementation SNTLCommonView
@synthesize builder = _builder;

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(viewTapped:)];
        [self addGestureRecognizer:tap];
         //(tap);
    }
    return self;
}

- (void)dealloc {
     //(_builder);
     //(_actionButton);
     //(_imageView);
}

- (void)setBuilder:(SNTLComViewBuilder *)builder {
    if (_builder != builder) {
         //(_builder);
        _builder = builder;
        
        NSArray *subViews = self.subviews;
        for (UIView *subView in subViews) {
            [subView removeFromSuperview];
        }
         //(_imageView);
         //(_actionButton);
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.builder renderInRect:rect withContext:ctx];
    
    if (!_imageView) {
        _imageView = self.builder.imageView;
        if (_imageView) {
            [self addSubview:_imageView];
            
            UIView *videoIconView = self.builder.videoIconView;
            if (videoIconView) [self addSubview:videoIconView];
        }
    }
    
    if (!_actionButton && self.builder.btnClickAction) {
        _actionButton = self.builder.actionButton;
        _actionButton.right = self.width - kTLViewSideMargin;
        _actionButton.centerY = CGRectGetMidY(self.bounds);
        if (_actionButton) {
            [_actionButton addTarget:self
                              action:@selector(btnClicked:)
                    forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_actionButton];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.builder suggestViewSize];
}

#pragma mark - actions

- (void)viewTapped:(id)sender {
    if (self.builder.link.length > 0) {
        [SNUtility openProtocolUrl:self.builder.link context:nil];
    }
}

- (void)btnClicked:(id)sender {
    if (self.builder.btnClickAction) self.builder.btnClickAction();
}

@end
