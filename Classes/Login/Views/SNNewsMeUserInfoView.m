//
//  SNNewsMeUserInfoView.m
//  sohunews
//
//  Created by wang shun on 2017/9/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsMeUserInfoView.h"

#import "SNUserManager.h"
#import "SNUserinfo.h"

@interface SNNewsMeUserInfoView ()

@property (nonatomic,strong) UIImageView* headImageView;
@property (nonatomic,strong) UIView* coverheadView;//夜间模式
@property (nonatomic,strong) UILabel* nickNameLabel;
@property (nonatomic,strong) UIImageView* arrowImageView;

@property (nonatomic,strong) UIView* line;

@end

@implementation SNNewsMeUserInfoView

- (void)dealloc{
    [SNNotificationManager removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
        
        //切换夜间模式 wangshun
        [SNNotificationManager addObserver:self selector:@selector(update:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)createUI{
    
    CGFloat x = 19;
    CGFloat y = (self.bounds.size.height-46)/2.0;
    
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 46, 46)];
    [self addSubview:_headImageView];
    _headImageView.backgroundColor = [UIColor clearColor];
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 23;
    _headImageView.image = [UIImage imageNamed:@"默认头像.png"];
    
    _coverheadView = [[UIView alloc] initWithFrame:_headImageView.bounds];
    [_headImageView addSubview:_coverheadView];
    _coverheadView.backgroundColor = [UIColor blackColor];
    _coverheadView.alpha = 0.5;//跟sns 保持一致
    if (![[SNThemeManager sharedThemeManager] isNightTheme]) {
        _coverheadView.hidden = YES;
    }
    
    _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+13, y, self.bounds.size.width-(CGRectGetMaxX(_headImageView.frame)+13)-50, 46)];
    [self addSubview:_nickNameLabel];
    
    [_nickNameLabel setFont:[UIFont systemFontOfSize:17]];
    [_nickNameLabel setTextColor:SNUICOLOR(kThemeText10Color)];
    
    [_nickNameLabel setText:@""];
    
    CGFloat aw = 27/2.0;
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-14-aw,(self.bounds.size.height-aw)/2.0 , aw, aw)];
    [_arrowImageView setBackgroundColor:[UIColor clearColor]];
    _arrowImageView.image = [UIImage themeImageNamed:@"icome_arrows_v5.png"];
    [self addSubview:_arrowImageView];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(19, 99, self.bounds.size.width-19, 1)];
    [_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
    [self addSubview:_line];
    
}

- (void)update:(NSNotification*)noti{
    _nickNameLabel.text =  [[SNUserinfoEx userinfoEx] getNickname];
    NSString* headImageUrl = [[SNUserinfoEx userinfoEx] headImageUrl];
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:[UIImage imageNamed:@"默认头像.png"]];
    [_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
    _arrowImageView.image = [UIImage themeImageNamed:@"icome_arrows_v5.png"];
    [_nickNameLabel setTextColor:SNUICOLOR(kThemeText10Color)];
    
    if (![[SNThemeManager sharedThemeManager] isNightTheme]) {
        _coverheadView.hidden = YES;
    }
    else{
        _coverheadView.hidden = NO;
    }
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //sohusns://profile/open/{"id":"18611019389@sohu.com","callFlagId":"sns_h5_demo_123456789","snsTab":"1"}
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    
    NSString* passport = [userinfo getUsername];//
    NSString* protocol = [NSString stringWithFormat:@"sohusns://profile/open/{\"id\":\"%@\"}",passport];
    [SNUtility openProtocolUrl:protocol];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
