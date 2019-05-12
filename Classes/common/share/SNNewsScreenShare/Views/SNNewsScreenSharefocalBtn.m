//
//  SNNewsScreenSharefocalBtn.m
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenSharefocalBtn.h"

@interface SNNewsScreenSharefocalBtn ()

@property (nonatomic,strong) UIImageView* icon;
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,strong) UIButton* btn;

@end

@implementation SNNewsScreenSharefocalBtn

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = SNUICOLOR(kThemeBg3Color);
        
        self.layer.cornerRadius = frame.size.height/2.0;
        self.layer.borderWidth  = 1;
        self.layer.borderColor  = SNUICOLOR(kThemeBg6Color).CGColor;
        
        [self createUI];
    }
    return self;
}

- (void)createUI{
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(6, (self.bounds.size.height-14)/2.0, 22, 14)];
    [self.icon setImage:[UIImage themeImageNamed:@"ico_write_v5.png"]];
    [self addSubview:self.icon];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.icon.frame)+3, (self.bounds.size.height-18)/2.0, 60, 18)];
    [self.titleLabel setText:@"划重点"];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
    [self.titleLabel setTextColor:SNUICOLOR(kThemeText10Color)];
    [self addSubview:self.titleLabel];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setFrame:self.bounds];
    [self addSubview:self.btn];
    [self.btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn setImage:[UIImage themeImageNamed:@"icoshare_bgpress_v5.png"] forState:UIControlStateHighlighted];

}

- (void)click:(UIButton*)b{
    if (self.delegate && [self.delegate respondsToSelector:@selector(focalBtnPress:)]) {
        [self.delegate focalBtnPress:self];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
