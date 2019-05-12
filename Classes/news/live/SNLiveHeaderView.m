//
//  SNLiveHeaderView.m
//  sohunews
//
//  Created by yanchen wang on 12-6-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveHeaderView.h"
#import "UIColor+ColorUtils.h"
#import "SNSkinManager.h"

#define TEXT_OFFSET_X					(26.0 / 2)
#define TEXT_OFFSET_Y					(20.0 / 2)
#define TEXT_FONT_SIZE					(32.0 / 2)
#define HEADER_HEIGHT                   (72.0 / 2)

const CGFloat kMoreButtonWidth = 80.0;


@interface SNLiveHeaderView () {
    UIButton *_moreButton;
    UIImageView *_moreImageView;
}

@property (copy, nonatomic) MoreButtonPressBlock moreButtonPressBlock;

@end


@implementation SNLiveHeaderView
@synthesize titleLabel = _titleLabel;

#pragma mark 生命周期
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _bar.left = 0;
        _bar.bottom = self.height;
        [self addSubview:_bar];
        
        CGRect titleLabelFrame = _bar.bounds;
        titleLabelFrame.origin.x += TEXT_OFFSET_X;
        titleLabelFrame.size.width -= (TEXT_OFFSET_X + kMoreButtonWidth);
        _titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        _titleLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_bar addSubview:_titleLabel];
        
        // 按钮 v5.2.2
        _moreButton = [[UIButton alloc] init];
        _moreButton.size = CGSizeMake(kMoreButtonWidth, _bar.height);
        _moreButton.backgroundColor = [UIColor clearColor];
        _moreButton.left = _titleLabel.right;
        _moreButton.top = 0;
        _moreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _moreButton.titleLabel.font = [SNSkinManager font:(kAppScreenWidth > kIPHONE_6_WIDTH ? SkinFontC : SkinFontD)];
        [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonPressedAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bar addSubview:_moreButton];
        
        // 更多箭头 v5.2.2
        _moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icobooking_next_v5.png"]];
        [_bar addSubview:_moreImageView];
        _moreImageView.right = (kAppScreenWidth > kIPHONE_6_WIDTH ? (_bar.width - 22.0 / 3) : (_bar.width - 16.0 / 2));
        _moreImageView.centerY = _bar.centerY;
        
        [self updateTheme];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        
        // 默认不显示 其他模块在复用这个...
        _moreButton.hidden = YES;
        _moreImageView.hidden = YES;
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(_titleLabel);
     //(_bar);
}

- (void)updateTheme {
    NSString *barColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveSectionBarColor];
    _bar.backgroundColor = [UIColor colorFromString:barColor];
    
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveSectionTitleColor];
    _titleLabel.textColor = [UIColor colorFromString:strColor];
    
    [_moreButton setTitleColor:([[SNThemeManager sharedThemeManager] isNightTheme] ? _titleLabel.textColor : [SNSkinManager color:SkinText3]) forState:UIControlStateNormal];
    _moreImageView.image = [UIImage imageNamed:@"icobooking_next_v5.png"];
}

#pragma mark set
- (void)setDataDict:(NSDictionary *)dataDict {
    if (_dataDict != dataDict) {
        _dataDict = dataDict;
    }
    
    // 往期不显示更多
    if (_dataDict) {
        _moreButton.hidden = NO;
        _moreImageView.hidden = NO;
    } else {
        _moreButton.hidden = YES;
        _moreImageView.hidden = YES;
    }
}

#pragma mark touch event
- (void)moreButtonPressedAction:(id)sender {
    if (_moreButtonPressBlock) {
        _moreButtonPressBlock(_dataDict);
    }
}

#pragma mark 外部
- (void)setMoreActionBlock:(MoreButtonPressBlock)block {
    self.moreButtonPressBlock = block;
}

@end
