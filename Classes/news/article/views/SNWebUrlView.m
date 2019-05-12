//
//  SNWebUrlView.m
//  sohunews
//
//  Created by jojo on 14-3-10.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNWebUrlView.h"
#import "NSCellLayout.h"

#define kSubscribedWidth 100.0f
#define kSohuIconLeftDistance 14.0

#define kSubscribedName @"已添加"
#define kUnSubscribedStockName @"添加到自选股"

@interface SNWebUrlView (){
    UIImageView* _lineView;
}

@property (nonatomic, strong) UIButton *subscribButton;

@end

@implementation SNWebUrlView
@synthesize link;
@synthesize delegate;
@synthesize buttonState = _buttonState;
@synthesize subscribButton = _subscribButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"channel_middle_bg.png"]];
//        CGRect rect = CGRectMake(14, 11, frame.size.height-22, frame.size.height-22);
//        UIImage* image = [UIImage themeImageNamed:@"Icon.png"];
//        iconButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
//        iconButton.backgroundColor = [UIColor clearColor];
//        iconButton.frame = rect;
//        [iconButton setImage:image forState:UIControlStateNormal];
//        [iconButton addTarget:self action:@selector(clickIconAction) forControlEvents:UIControlEventTouchUpInside];
//        iconButton.alpha = themeImageAlphaValue();
//        [self addSubview:iconButton];
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 44 + kSystemBarHeight)];
        backgroundImageView.image = [UIImage themeImageNamed:@"channel_middle_bg.png"];
        backgroundImageView.userInteractionEnabled = YES;
        [self addSubview:backgroundImageView];
        
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"bgtitlebar_maskleft_v5.png"]];
        _coverImageView.frame = CGRectMake(0,0, 96/2, backgroundImageView.height);
        [backgroundImageView addSubview:_coverImageView];

        
        CGRect rect = CGRectMake(CONTENT_LEFT + 3, kSystemBarHeight + 23/2, 21, 21);
        UIImage* image = [UIImage themeImageNamed:@"icotitlebar_sohu_v5.png"];
        iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.backgroundColor = [UIColor clearColor];
        iconButton.frame = rect;
        [iconButton setImage:image forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(clickIconAction) forControlEvents:UIControlEventTouchUpInside];
        iconButton.alpha = themeImageAlphaValue();
        [backgroundImageView addSubview:iconButton];
        
        _titleLabel = [[UILabel alloc] init];
        //    NSString *newTitle = [NSString stringWithFormat:@"     %@",self.urlTitle];
        _titleLabel.text     = @"";
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]];
        
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [backgroundImageView addSubview:_titleLabel];

        CGFloat screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        
        CGFloat width = screenWidth - CONTENT_LEFT-21-11;
        //    CGSize size = [newTitle sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(width, 300) lineBreakMode:_titleLabel.lineBreakMode];
        _titleLabel.frame = CGRectMake(CONTENT_LEFT+21+11, kSystemBarHeight + 23/2, width, 21);
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        
//        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 0, 12)];
//        logoImageView.backgroundColor = [UIColor clearColor];
//        logoImageView.alpha = themeImageAlphaValue();
//        [backgroundImageView addSubview:logoImageView];
        
//        urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 2, backgroundImageView.width-10, 20)];
//        urlTextField.backgroundColor = [UIColor clearColor];
//        urlTextField.font = [UIFont systemFontOfSize:kThemeFontSizeB];
//        urlTextField.returnKeyType =  UIReturnKeyGo;
//        urlTextField.textAlignment = NSTextAlignmentLeft;
//        urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        urlTextField.delegate = self;
//        urlTextField.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
//        [backgroundImageView addSubview:urlTextField];
        
        //lijian 2014.12.18 修改了h5页的阴影线
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.frame.origin.x, frame.size.height, frame.size.width + (self.frame.origin.x * 2), 2)];
        _lineView.image = [[UIImage themeImageNamed:@"icotitlebar_shadow_v5.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [self addSubview:_lineView];
        _lineView.clipsToBounds = NO;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
//        refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        refreshButton.frame = CGRectMake(backgroundImageView.width-30, 3, 25, 25);
//        [refreshButton setBackgroundImage:[UIImage themeImageNamed:@"news_content_refresh_normal.png"]
//                                 forState:UIControlStateNormal];
//        [refreshButton setBackgroundImage:[UIImage themeImageNamed:@"news_content_refresh_highlight.png"]
//                                 forState:UIControlStateHighlighted];
//        [refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
//        [backgroundImageView addSubview:refreshButton];
        
        //显示添加按钮
        self.subscribButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.subscribButton.backgroundColor = [UIColor clearColor];
        self.subscribButton.frame = CGRectMake(0, 0, kSubscribedWidth, kThemeFontSizeC + 2);
        self.subscribButton.centerY = iconButton.centerY;
        self.subscribButton.right = kAppScreenWidth - kSohuIconLeftDistance;
        self.subscribButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;//设置按钮文字居右显示
        self.subscribButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [self.subscribButton addTarget:self action:@selector(subscribeAction) forControlEvents:UIControlEventTouchUpInside];
        [backgroundImageView addSubview:self.subscribButton];
        
        if (self.buttonState == SNSubscribeButtonHide) {
            self.subscribButton.hidden = YES;
        }
        else{
            self.subscribButton.hidden = NO;
            
            [SNNotificationManager addObserver:self selector:@selector(refreshButtonState:) name:kRefreshStockDetailButtonNotification object:nil];
        }

    }
    return self;
}

- (void)refreshButtonState{
    if (self.buttonState == SNSubscribeButtonDel) {
        [self.subscribButton setTitle:kSubscribedName forState:UIControlStateNormal];
        [self.subscribButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    }
    else if (self.buttonState == SNSubscribeButtonAdd){
        [self.subscribButton setTitle:kUnSubscribedStockName forState:UIControlStateNormal];
        [self.subscribButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    }
}

- (void)refreshButtonState:(NSNotification *)notification{
    NSDictionary *userDic = notification.userInfo;
    BOOL status = [[userDic objectForKey:@"status"] boolValue];
    if (status == YES) {//添加成功，按钮显示del，操作失败，按钮状态不变
        self.buttonState = SNSubscribeButtonDel;
    }
    else{
        self.buttonState = SNSubscribeButtonAdd;
    }
    
    [self refreshButtonState];
}

- (void)updateUIForRotate:(BOOL)landscape {
    if (landscape) {
        backgroundImageView.frame = CGRectMake(0, 0, self.width, 44);
        CGFloat width = self.width - CONTENT_LEFT-21-11;
        _titleLabel.frame = CGRectMake(CONTENT_LEFT+21+11,23/2, width, 21);
        _lineView.frame = CGRectMake(_lineView.origin.x, self.height , self.frame.size.width + (self.frame.origin.x * 2), 2);
        iconButton.frame = CGRectMake(CONTENT_LEFT + 3, 23/2, 21, 21);
        _coverImageView.hidden = YES;
    }else {
        backgroundImageView.frame = CGRectMake(0, 0, self.width, 44 + kSystemBarHeight);
        CGFloat width = self.width - CONTENT_LEFT-21-11;
        _titleLabel.frame = CGRectMake(CONTENT_LEFT+21+11, kSystemBarHeight + 23/2, width, 21);
        _lineView.frame = CGRectMake(_lineView.origin.x, self.height + kSystemBarHeight, self.frame.size.width + (self.frame.origin.x * 2), 2);
        iconButton.frame = CGRectMake(CONTENT_LEFT + 3,kSystemBarHeight + 23/2, 21, 21);
        _coverImageView.hidden = NO;
    }

}

- (void)disableSohuIcon
{
    iconButton.frame = CGRectZero;
//    backgroundImageView.frame = CGRectMake(14, 11, self.frame.size.width-28,22);
//    urlTextField.frame = CGRectMake(5, 0, backgroundImageView.width-10, 22);
    //refreshButton.frame = CGRectMake(backgroundImageView.width-30, 3, 25, 25);
}

- (void)updateLogoUrl:(NSString *) logoUrl  withLink:(NSString *) urlString
{
//    if (logoUrl) {
//        [logoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if (image) {
//                float scale = image.size.width / image.size.height;
//                logoImageView.width =  12*scale;
//                urlTextField.left = logoImageView.right+5;
//                urlTextField.width = backgroundImageView.width - logoImageView.width - 15;
//            }
//        }];
//    }else {
//        urlTextField.width = backgroundImageView.width -10;
//    }
//    self.link = urlString;
//    urlTextField.text = urlString;
    
    _titleLabel.text = urlString;
}

- (void)updateTile:(NSString *)title {
    if (title.length > 0) {
        _titleLabel.text = title;
    }
    if (_titleLabel.text.length == 0) {
        _titleLabel.text = @"搜狐新闻客户端";
    }
}

- (void)refreshAction
{
    if (delegate && [delegate respondsToSelector:@selector(refreshWebView)]) {
        [delegate refreshWebView];
    }
}

- (void)clickIconAction
{
    if(delegate && [delegate respondsToSelector:@selector(clickIconView)]) {
        [delegate clickIconView];
    }
}

- (void)updateTheme
{
//    urlTextField.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText4Color]];
    backgroundImageView.image = [UIImage themeImageNamed:@"channel_middle_bg.png"];
    //[iconButton setBackgroundImage:[UIImage themeImageNamed:@"Icon.png"] forState:UIControlStateNormal];
//    _coverImageView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"bgtitlebar_maskleft_v5.png"]];
//    iconButton.alpha = themeImageAlphaValue();
    _coverImageView.image = [UIImage themeImageNamed:@"bgtitlebar_maskleft_v5.png"];
    [iconButton setImage:[UIImage themeImageNamed:@"icotitlebar_sohu_v5.png"] forState:UIControlStateNormal];
    logoImageView.alpha = themeImageAlphaValue();
}

- (void)dealloc
{
    if (self.buttonState != SNSubscribeButtonHide) {
        [SNNotificationManager removeObserver:self name:kRefreshStockDetailButtonNotification object:nil];
    }
    
    [SNNotificationManager removeObserver:self];

}

- (void)subscribeAction{
    if (self.buttonState == SNSubscribeButtonDel) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(unSubscribeAciton)]) {
            [self.delegate unSubscribeAciton];
        }
    }
    else if (self.buttonState == SNSubscribeButtonAdd){
        if (self.delegate && [self.delegate respondsToSelector:@selector(subscribeAction)]) {
            [self.delegate subscribeAction];
        }
    }
}

@end
