//
//  SNPaperLogoView.m
//  sohunews
//
//  Created by guoyalun on 9/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#define LOGO_HEIGHT     (35)
#define STATE_CODE_KEY              (@"returnStatus")
#define HTTP_OK                     (@"200")

#import "SNPaperLogoView.h"
#import "SNThemeManager.h"
#import "SNURLRequest.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "UIColor+ColorUtils.h"

@implementation SNPaperLogoView
@synthesize termNameLabel   = _termNameLabel;
@synthesize state;
@synthesize subId           = _subId;
@synthesize pubName         = _pubName;
@synthesize normalLogoUrl   = _normalLogoUrl;
@synthesize nightLogoUrl    = _nightLogoUrl;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (id)initWithFrame:(CGRect)frame Delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoBackgroundColor]];
        
        _termNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 230, LOGO_HEIGHT)];
        _termNameLabel.backgroundColor = [UIColor clearColor];
        _termNameLabel.textColor       = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTermNameColor]];
        _termNameLabel.font            = [UIFont boldSystemFontOfSize:25];
        _termNameLabel.textAlignment   = NSTextAlignmentLeft;
        
        _termNameLabel.hidden = NO;
        [self addSubview:_termNameLabel];
        
        UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(pubInfoClicked:)];
        _termNameLabel.userInteractionEnabled = YES;
        [_termNameLabel addGestureRecognizer:labelTap];
         //(labelTap);
        
        _logoImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(12, 12, 88, LOGO_HEIGHT)];
        _logoImageView.contentMode = UIViewContentModeScaleToFill;
        //_logoImageView.delegate = self;
        _logoImageView.hidden = YES;
        _logoImageView.showFade = NO;
        _logoImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_logoImageView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(pubInfoClicked:)];
        _logoImageView.userInteractionEnabled = YES;
        [_logoImageView addGestureRecognizer:imageTap];
         //(imageTap);
        
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 90, 60)];
        //        _addBtn.imageEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, -57);
        // 按钮资源 改为一个大的“加关注” by jojo

        UIImage *btnImage = [UIImage imageNamed:@"add_subFollow.png"];
        _addBtn.size = btnImage.size;
        _addBtn.right = self.width - 10;
        _addBtn.centerY = CGRectGetMidY(self.bounds);
        [_addBtn setImage:btnImage forState:UIControlStateNormal];
        [_addBtn addTarget:delegate action:@selector(addASubscribe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addBtn];
        
        _seperatorView = [[UIView alloc] initWithFrame:CGRectMake(10, 60, 300, 2)];
        _seperatorView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoSeperatorColor]];
        [self addSubview:_seperatorView];
    }
    return self;
}

- (void)resetAllViews {
    _termNameLabel.hidden = NO;
    
    _logoImageView.hidden = YES;
    _logoImageView.showFade = NO;
}

- (void)dealloc
{
    
    _logoImageView = nil;
    _addBtn        = nil;
    
    self.pubName       = nil;
}

- (void)setState:(SubcribeState)_state
{
    //  add_subFollow.png
    state = _state ;
    UIImage *btnImage = nil;
    if (state == Subscribe) {
        btnImage = [UIImage imageNamed:@"remove_subFollow.png"];
    } else {
        btnImage = [UIImage imageNamed:@"add_subFollow.png"];
    }
    [_addBtn setImage:btnImage forState:UIControlStateNormal];
}
- (void)setPubName:(NSString *)pubName
{
    if (_pubName != pubName) {
        _pubName = pubName;
    }
    self.termNameLabel.text = _pubName;
}

- (void)setLogoUrl:(NSString *)logoUrl;
{
    if (logoUrl && logoUrl.length > 0) {
        UIImage* image = [[TTURLCache sharedCache] imageForURL:logoUrl];
        
        if (nil != image) {
            _logoImageView.image = image;
        } else {
            _termNameLabel.hidden = NO;
            
            //_logoImageView.urlPath = logoUrl;
            [_logoImageView loadUrlPath:logoUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 if (image) {
                     NSInteger width = image.size.width / image.size.height * LOGO_HEIGHT;
                     if (width > 235) {
                         width = 235;
                     }
                     _termNameLabel.hidden  = YES;
                     _logoImageView.frame = CGRectMake(12, 12 , width, LOGO_HEIGHT);
                     _logoImageView.hidden  = NO;
                 }
                 if (error) {
                     _logoImageView.image = _logoImageView.defaultImage;
                     _logoImageView.hidden  = YES;
                     _termNameLabel.hidden  = NO;
                 }
             }];
        }
    } else {
        _termNameLabel.hidden = NO;
        _logoImageView.hidden = YES;
    }
}


- (void)setDateString:(NSString *)publishDate;
{
    // nothing
}

- (void)logoTapped:(id)sender {
    if (self.subId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self.subId forKey:@"subId"];
        [dic setObject:@"1" forKey:@"fromNewsPaper"];
        
        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
    }
}

- (void)updateTheme {
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoBackgroundColor]];
    
    _termNameLabel.textColor       = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTermNameColor]];

    _seperatorView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoSeperatorColor]];
    [self setState:state];
}
#pragma clang diagnostic pop
@end
