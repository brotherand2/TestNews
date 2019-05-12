//
//  SNCloseAdImageView.m
//  sohunews
//
//  Created by HuangZhen on 11/07/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNCloseAdImageView.h"
#import "UIViewAdditions.h"
#import "SNWebImageView.h"

@interface SNCloseAdImageView (){
    UILabel * _adLabel;
    UIButton * _closeBtn;
    UIView * _themeMask;
    UIView * _background;
    UIView * _line;
    SNWebImageView * _adImageView;
}
@property (nonatomic, copy) SNCloseAdAction closeActionBlock;
@property (nonatomic, copy) SNClickAdAction clickActionBlock;
@end

@implementation SNCloseAdImageView

- (instancetype)initWithFrame:(CGRect)frame closeAction:(SNCloseAdAction)closeAction clikcAction:(SNClickAdAction)clikcAction {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _closeEnable = YES;
        self.closeActionBlock = closeAction;
        self.clickActionBlock = clikcAction;
        [self createContent];
    }
    return self;
}

- (void)createContent {
    [self setBackground];
    [self setADImageView];
    [self setCloseBtn];
    [self addTapGesture];
}

- (void)setBackground {
    BOOL isNightTheme = [SNThemeManager sharedThemeManager].isNightTheme;
    if (isNightTheme) {
        _background = [[SNNavigationBar alloc] initWithFrame:CGRectMake(0,24/2.f,self.width,self.height-24/2.f)];
        UIView *whiteView = [[UIView alloc] initWithFrame:_background.bounds];
        whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:isNightTheme ? 0:0.6];
        [_background addSubview:whiteView];
    }else{
        _background = [[UIView alloc] initWithFrame:CGRectMake(0,24/2.f,self.width,self.height-24/2.f)];
        _background.backgroundColor = [UIColor colorFromString:@"#f3f3f3"];
    }
    [self addSubview:_background];
    _background.hidden = YES;
}

- (void)setADImageView {
    _adImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _adImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_adImageView];

    _adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 12)];
    _adLabel.text = @"广告";
    _adLabel.backgroundColor = [UIColor clearColor];
    _adLabel.textColor = SNUICOLOR(kThemeText3Color);
    _adLabel.font = [UIFont systemFontOfSize:20/2.f];
    _adLabel.right = self.width - 15;
    _adLabel.top = 91/2.f;
    [self addSubview:_adLabel];
    _adLabel.hidden = YES;
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    _line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    _line.bottom = self.height;
    [self addSubview:_line];
    _line.hidden = YES;
}

- (void)setCloseBtn {
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = CGRectMake(0, 0, 40, 40);
    _closeBtn.right = self.width;
    [_closeBtn setImage:[UIImage imageNamed:@"advertising_close.png"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.hidden = YES;
    [self addSubview:_closeBtn];
}

- (void)addTapGesture {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    self.clickActionBlock();
}

- (void)closeAction:(id)sender {
    self.closeActionBlock(sender);
}

- (void)setCloseEnable:(BOOL)closeEnable {
    _closeBtn.hidden = !closeEnable;
    _closeEnable = closeEnable;
}

- (void)loadImageWithUrl:(NSString *)url completed:(SNWebImageCompleteBlock)completedBlock {
    UIImage * cache = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
    if (cache) {
        [_adImageView setImage:cache];
        _closeBtn.hidden = !self.closeEnable;
        _adLabel.hidden = NO;
        _adImageView.contentMode = UIViewContentModeScaleAspectFit;
        completedBlock(cache, nil, SDImageCacheTypeDisk);
    }else{
        [_adImageView loadUrlPath:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            _closeBtn.hidden = !self.closeEnable;
            _adLabel.hidden = NO;
            _adImageView.contentMode = UIViewContentModeScaleAspectFit;
            completedBlock(image, error, cacheType);
        }];
    }
}
- (void)loadImageWithUrl:(NSString *)url size:(CGSize)size completed:(SNWebImageCompleteBlock)completedBlock {
    [self loadImageWithUrl:[self imageUrlWithImageSize:size originalUrl:url] completed:completedBlock];
}

- (void)setCloseButtonOrigin:(CGPoint)origin {
    _closeBtn.frame = CGRectMake(origin.x, origin.y, _closeBtn.width, _closeBtn.height);
}

- (void)setBackgroundViewHidden:(BOOL)hidden {
    _background.hidden = hidden;
}
- (void)setBottomLineHidden:(BOOL)hidden {
    _line.hidden = hidden;
}
- (NSString *)imageUrlWithImageSize:(CGSize)size originalUrl:(NSString *)url {
    if (size.width > 0 && size.height > 0) {
        NSString * extensionString = [[url componentsSeparatedByString:@"."] lastObject];
        if (extensionString) {
            NSString * fragmentaryString = [[url componentsSeparatedByString:[NSString stringWithFormat:@".%@",extensionString]] firstObject];
            if (fragmentaryString) {
                return [NSString stringWithFormat:@"%@_%.0f_%.0f.%@",fragmentaryString,size.width,size.height,extensionString];
            }
        }
    }
    return url;
}

@end
