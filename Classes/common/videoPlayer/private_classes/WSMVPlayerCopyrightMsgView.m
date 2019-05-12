//
//  WSMVPlayerCopyrightMsgView.m
//  sohunews
//
//  Created by handy wang on 10/15/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "WSMVPlayerCopyrightMsgView.h"

#define kTextLabelWidth                         (520.0f/2.0f)
#define kTextLabelHeight                        (64.0f/2.0f)
#define kTextLabelMarginLeftAndRight            (60.0f/2.0f)
#define kTextLabelFontSize                      (14.f)

#define kImageViewWidth                         (292.0f/2.0f)
#define kImageViewHeight                        (64.0f/2.0f)

@interface WSMVPlayerCopyrightMsgView()
@property (nonatomic, strong)UILabel        *textLabel;
@property (nonatomic, strong)UIImageView    *imageView;
@end

@implementation WSMVPlayerCopyrightMsgView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [self addTarget:self action:@selector(toWapPage) forControlEvents:UIControlEventTouchUpInside];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.frame = CGRectMake(0.f, (self.height-kTextLabelHeight)/2.f - 16.f, self.width, kTextLabelHeight);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:kTextLabelFontSize];
        self.textLabel.text = NSLocalizedString(@"switch_to_html5_play_video_msg", nil);
        [self addSubview:self.textLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - kImageViewWidth)/2.f, 0.f, kImageViewWidth, kImageViewHeight)];
        _imageView.image = [UIImage imageNamed:@"wsmv_browser_jump.png"];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        _imageView.top = _textLabel.bottom + 12.f;
    }
    return self;
}

- (void)dealloc {
    _imageView = nil;
}

#pragma mark - Public
- (void)updateContentToFullscreen {
    self.textLabel.top = (self.height-kTextLabelHeight)/2.f - 16.f;
    _imageView.top = _textLabel.bottom + 12.f;
    _imageView.left = (self.width - kImageViewWidth)/2.f;
}

- (void)updateContentToNonFullscreen {
    self.textLabel.top = (self.height-kTextLabelHeight)/2.f - 16.f;
    _imageView.top = _textLabel.bottom + 12.f;
    _imageView.left = (self.width - kImageViewWidth)/2.f;
}

#pragma mark - Private
- (void)toWapPage {
    if ([_delegate respondsToSelector:@selector(toWapPage)]) {
        [_delegate  toWapPage];
    }
}

@end
