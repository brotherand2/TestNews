//
//  SNPhotoGalleryToolbar.m
//  sohunews
//
//  Created by Dan on 6/30/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNToolbar.h"
#define kSideMargin         (2.0)
#define kBtnSpaceWidth 46
#define kBtnWidth 43

@interface SNToolbar() <CAAnimationDelegate> {
    NSMutableArray *buttons;
    UIImageView *_backgroundView;
    UIImageView *_topEdgeShadow;
    SNToolbarAlignType _alignType;
    BOOL _isFullAD;
}
@end

@implementation SNToolbar
@synthesize leftButton, rightButton;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
		//校正动画时底部露出1px空隙.
		CGRect f = self.frame;
		f.origin.y += 1;
		self.frame = f;
        self.backgroundView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
        self.backgroundView.alpha = 0.95;
        _alignType = SNToolbarAlignCenter;
        
        //Top edge shadow
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
        UIImage *shadowImg = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        _topEdgeShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, -shadowImg.size.height, self.width, shadowImg.size.height)];
        _topEdgeShadow.image = shadowImg;
        [self addSubview:_topEdgeShadow];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    if(_alignType == SNToolbarAlignCenter)
    {
        int space=self.width/ buttons.count;
        float centerX =space/2;
        int i = 0;
        float originY = (self.height-kToolbarButtonSize);
        if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
            originY = 0;
        }
        for (UIButton *btn in buttons) {
            if (i == 0) {//第一个是返回按钮
                [btn setFrame:CGRectMake(0, originY/2.0f, kToolbarButtonSize, kToolbarButtonSize)];
            }
            else if (i == 1) {//第二个是关闭按钮
                [btn setFrame:CGRectMake(kToolBarBackBtnLeft + kToolBarBtnImgWidth + kToolBarBtnSpace , originY/2.0f, kToolbarButtonSize, kToolbarButtonSize)];
                if (_isFullAD) {
                    btn.hidden = YES;
                }
            }
            else if (i == 2) {//第三个是刷新按钮
                [btn setFrame:CGRectMake(self.width - kToolBarBtnSpace - kToolBarShareBtnRight - kToolBarBtnImgWidth - kToolbarButtonSize + 10, originY/2.0f, kToolbarButtonSize, kToolbarButtonSize)];
            }
            else if (i == 3) {//第四个是分享按钮
                [btn setFrame:CGRectMake(self.width - kToolbarButtonSize - 10, originY/2.0f, kToolbarButtonSize, kToolbarButtonSize)];
            }
            
            if (_isFullAD) {
                [btn setFrame:CGRectMake(btn.frame.origin.x, 0, kToolbarButtonSize, self.height)];
                if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
                    [btn setFrame:CGRectMake(btn.frame.origin.x, 0, kToolbarButtonSize, 44)];
                }
            }
            centerX += space;
            [self addSubview:btn];
            [btn setExclusiveTouch:YES];
            i++;
        }

    }
    else
    {
        for(int i = 0; i < buttons.count; ++i)
        {
            UIButton* button = [buttons objectAtIndex:i];
            int btnx = 0;
            if(i == 0)
            {
                btnx = 0;
            }
            else
            {
                btnx = self.width - kBtnSpaceWidth*(buttons.count - i);
            }
            [button setFrame:CGRectMake(btnx, (self.height-kToolbarButtonSize)/2.0f, kBtnSpaceWidth, kToolbarButtonSize)];
            [button setExclusiveTouch:YES];
            [self addSubview:button];
        }
    }
    
    if (self.leftButton) {
        self.leftButton.frame = CGRectMake(kSideMargin, (self.height - self.leftButton.height) / 2,
                                           self.leftButton.width, self.leftButton.height);
        if (self.height == 64) {
            //@qz 适配iPhone X
            self.leftButton.frame = CGRectMake(kSideMargin, (self.height-20 - self.leftButton.height) / 2,
                                               self.leftButton.width, self.leftButton.height);
        }
    }
    if (self.rightButton) {
        self.rightButton.frame = CGRectMake(self.width - kSideMargin - self.rightButton.width, (self.height - self.rightButton.height) / 2,self.rightButton.width, self.rightButton.height);
        if (self.height == 64) {
            //@qz 适配iPhone X
            self.rightButton.frame = CGRectMake(self.width - kSideMargin - self.rightButton.width, (self.height-20 - self.rightButton.height) / 2,self.rightButton.width, self.rightButton.height);
        }
    }
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_backgroundView atIndex:0];
    }
    
    return _backgroundView;
}

- (void)setBackgroundImage:(UIImage *)image {
    if (!image) {
        _backgroundView.backgroundColor = [UIColor clearColor];
        if (_backgroundView && [_backgroundView superview]) {
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
    }
    
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_backgroundView atIndex:0];
    }
    _backgroundView.image = image;
}

- (void)setButtons:(NSArray *)btns {
    for (UIButton *btn in buttons) {
        [btn removeFromSuperview];
    }
    buttons = (NSMutableArray *)btns;
	[self setNeedsLayout];
}

- (void)setButtons:(NSArray *)btns withType:(SNToolbarAlignType)type
{
    _alignType = type;
    [self setButtons:btns];
}

- (void)setLeftButton:(UIButton *)btn {
    if (leftButton != btn) {
        [leftButton removeFromSuperview];
        leftButton = btn;
        if (btn != nil) {
            [self addSubview:btn];
        }
    }
    [self setNeedsLayout];
}

- (void)setRightButton:(UIButton *)btn {
    if (rightButton != btn) {
        [rightButton removeFromSuperview];
        rightButton = btn;
        if (btn != nil) {
            [self addSubview:btn];
        }
    }
    [self setNeedsLayout];
}

- (void)replaceButtonAtIndex:(int)index withItem:(UIButton *)newItem {
	if (!buttons) {
		return;
	}
	UIButton *delBtn = [buttons objectAtIndex:index];
	[delBtn removeFromSuperview];
	[buttons replaceObjectAtIndex:index withObject:newItem];
	[self setNeedsLayout];
}

- (CATransition *)getAnimation:(NSString *)kCATransitionType kCATransitionSubType:(NSString *)kCATransitionSubType andDuration:(CFTimeInterval)duration {
	CATransition *animation = [CATransition animation];	
	[animation setDelegate:self];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionSubType];	
	[animation setDuration:duration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	return animation;
}

- (void)show:(BOOL)show animated:(BOOL)animated {
	
	CATransition *animation = nil;
	
	if (animated) {
		
		if (show) {
			animation = [self getAnimation:kCATransitionPush kCATransitionSubType:kCATransitionFromTop andDuration:TT_FAST_TRANSITION_DURATION];
		} else {
			animation = [self getAnimation:kCATransitionPush kCATransitionSubType:kCATransitionFromBottom andDuration:TT_FAST_TRANSITION_DURATION];
		}
		
	}
	
	self.hidden = !show;
	
	if (animated) {
		[[self layer] addAnimation:animation forKey:kCATransition];
	}
	
}

- (void)updateTheme:(NSNotification *)notification {
    self.backgroundView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
    UIImage *shadowImg = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    _topEdgeShadow.image = shadowImg;
}

- (void)updateUIForRotate {
    _topEdgeShadow.frame = CGRectMake(0, _topEdgeShadow.origin.y, self.width, _topEdgeShadow.size.height);
    _backgroundView.frame = CGRectMake(0, 0, self.width, self.height);
    [self setNeedsLayout];
}

- (void)hideShadowLine{
    if (_topEdgeShadow) {
        _topEdgeShadow.hidden = YES;
    }
}

- (void)updateFullADStyle{
    if (CGRectGetHeight(_backgroundView.frame) < _backgroundView.image.size.height) {
        _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, self.height-_backgroundView.image.size.height, CGRectGetWidth(_backgroundView.frame), _backgroundView.image.size.height);
    }
    //_backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, self.height-49, CGRectGetWidth(_backgroundView.frame), 49);
    _backgroundView.alpha = 0.8;
    _backgroundView.backgroundColor = [UIColor clearColor];
    _isFullAD = YES;
    
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

+ (CGFloat)toolbarHeight{
    if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
        return 64;
    }else if ([UIScreen mainScreen].bounds.size.width == 414) {
        return 146.0 / 3.0;
    }
    return 45.0;
}
@end
