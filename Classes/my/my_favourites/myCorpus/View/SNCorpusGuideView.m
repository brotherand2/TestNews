//
//  SNCorpusGuideView.m
//  sohunews
//
//  Created by Scarlett on 15/9/14.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusGuideView.h"

#define kGuideHeight ((kAppScreenWidth > 375.0) ? 182.0/3 : 109.0/2)
#define kGuideLogoLeftDistance ((kAppScreenWidth > 375.0) ? 66.0/3 : 39.0/2)
#define kGuideLogoTopDistance ((kAppScreenWidth > 375.0) ? 33.0/3 : 19.0/2)
#define kGuideLogoRightDistance ((kAppScreenWidth > 375.0) ? 39.0/3 : 14.0/2)
#define kGuideLogoImageWidth ((kAppScreenWidth > 375.0) ? 94.0/3 : 56.0/2)
#define kGuideCloseWidth ((kAppScreenWidth > 375.0) ? 48.0/3 : 32.0/2)
#define kGuideTitleRightDistance ((kAppScreenWidth > 375.0) ? 46.0/3 : 22.0/2)

@interface SNCorpusGuideView () {
    UIImageView *_backgroundImageView;
    UIImageView *_logoImageView;
    UILabel *_titleLabel;
    UIButton *_closeButton;
}
@property(nonatomic, strong)NSString *imageName;
@property(nonatomic, strong)NSString *backImageName;

@end

@implementation SNCorpusGuideView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.height = kGuideHeight;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, kGuideHeight)];
        _backgroundImageView.userInteractionEnabled = YES;
        [self addSubview:_backgroundImageView];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGuideLogoImageWidth, kGuideLogoImageWidth)];
        [_backgroundImageView addSubview:_logoImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        if (kAppScreenWidth == 320) {
            _titleLabel.font = [UIFont systemFontOfSize:14.0];
        }
        else {
            _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        }
        _titleLabel.textColor = SNUICOLOR(kThemeText4Color);
        [_backgroundImageView addSubview:_titleLabel];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.frame = CGRectMake(0, 0, kGuideCloseWidth, kGuideCloseWidth);
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"ico_close_v5.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeGuideView:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundImageView addSubview:_closeButton];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)setGuideWithImageName:(NSString *)imageName backImageName:(NSString *)backImageName title:(NSString *)title {
    self.imageName = imageName;
    self.backImageName = backImageName;
    
    _backgroundImageView.image = [UIImage imageNamed:_backImageName];
    
    _logoImageView.image = [UIImage imageNamed:imageName];
    _logoImageView.left = kGuideLogoLeftDistance;
    _logoImageView.top = kGuideLogoTopDistance;
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    _titleLabel.left = _logoImageView.right + kGuideLogoRightDistance;
    _titleLabel.centerY = _logoImageView.centerY;
    
    CGFloat guideViewWidth = _titleLabel.left + _titleLabel.width + kGuideTitleRightDistance + kGuideCloseWidth + kGuideLogoLeftDistance;
    _backgroundImageView.width = guideViewWidth;
    
    _closeButton.right = guideViewWidth - kGuideLogoLeftDistance;
    _closeButton.centerY = _logoImageView.centerY;
    
    self.width = guideViewWidth;
}

- (void)closeGuideView:(id)sender {
    [self removeFromSuperview];
}

- (void)updateTheme {
    _backgroundImageView.image = [UIImage imageNamed:_backImageName];
    _logoImageView.image = [UIImage imageNamed:_imageName];
    _titleLabel.textColor = SNUICOLOR(kThemeText4Color);
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"ico_close_v5.png"] forState:UIControlStateNormal];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}


@end
