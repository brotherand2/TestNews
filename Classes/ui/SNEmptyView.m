//
//  SNEmptyView.m
//  sohunews
//
//  Created by kuanxi zhu on 7/22/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#define ICONIMAEVIEW_OFFSET_X				(260.0 / 2)
#define ICONIMAEVIEW_OFFSET_Y				(260.0 / 2)

#define ERRORTITLE_FONT_SIZE				(30.0 / 2)
#define ERRORTITLE_OFFSET_Y					(36.0 / 2)
#import "SNEmptyView.h"
#import "UIColor+ColorUtils.h"

@interface SNEmptyView ()
-(void)handleGesture:(UIGestureRecognizer*)gestureRecognizer;
@end

@implementation SNEmptyView
@synthesize errorTitle = _errorTitle;
@synthesize bgImagePath = _bgImagePath;
@synthesize iconImagePath = _iconImagePath;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:tapGes];
        
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kViewBackgroundColor]];
    }
    return self;
}

-(void)handleGesture:(UIGestureRecognizer*)gestureRecognizer {
    
}

- (void)setBgImagePath:(NSString *)path {
	if (![_bgImagePath isEqualToString:path]) {
		 //(_bgImagePath);
		_bgImagePath = [path copy];
		
		_bgView = [[SNWebImageView alloc] initWithFrame:self.frame];
		_bgView.userInteractionEnabled = NO;
        _bgView.showFade = NO;
		[_bgView loadUrlPath:_bgImagePath];
		[self addSubview:_bgView];
		
		[self setNeedsLayout];
	}
}

- (void)setIconImagePath:(NSString *)path {
	if (![_iconImagePath isEqualToString:path]) {
		 //(_iconImagePath);
		_iconImagePath = [path copy];
		
		_iconView = [[SNWebImageView alloc] init];
        _iconView.showFade = NO;
		[_iconView loadUrlPath:_iconImagePath];
		[self addSubview:_iconView];
		
		[self setNeedsLayout];
	}
}

- (void)setErrorTitle:(NSString *)title {
	if (![_errorTitle isEqualToString:title]) {
		 //(_errorTitle);
		_errorTitle = [title copy];
		
		if (!_errorLabel) {
			_errorLabel = [[UILabel alloc] init];
			_errorLabel.font = [UIFont systemFontOfSize:ERRORTITLE_FONT_SIZE];
			_errorLabel.backgroundColor = [UIColor clearColor];
//			_errorLabel.textColor = TTSTYLEVAR(tableErrorTextColor);
            _errorLabel.font = [UIFont boldSystemFontOfSize:18];
			[self addSubview:_errorLabel];
		}
		_errorLabel.text = _errorTitle;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	if (_iconView) {
		CGRect newFrame = _iconView.frame;
		newFrame.origin = CGPointMake((self.frame.size.width - _iconView.frame.size.width) / 2,
                                      ICONIMAEVIEW_OFFSET_Y);
		_iconView.frame = newFrame;
	}
	
	if (_errorLabel) {
		CGFloat height = ICONIMAEVIEW_OFFSET_Y;
		CGSize maximumSize = CGSizeMake(320, 100);
		CGSize changeSize = [_errorLabel.text sizeWithFont:_errorLabel.font 
										constrainedToSize:maximumSize 
											lineBreakMode:_errorLabel.lineBreakMode];
		
		if (_iconView) {
			height =  _iconView.frame.origin.y + _iconView.frame.size.height + ERRORTITLE_OFFSET_Y;
		}
		_errorLabel.frame = CGRectMake(self.frame.size.width / 2 - changeSize.width / 2,  
									   height, 
									   changeSize.width, 
									   changeSize.height);
	}
}

- (void)dealloc {
	 //(_bgView);
	 //(_iconView);
	 //(_errorLabel);
	 //(_errorTitle);
	 //(_bgImagePath);
	 //(_iconImagePath);
}


@end
