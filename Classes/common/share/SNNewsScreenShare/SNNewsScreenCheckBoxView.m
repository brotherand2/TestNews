//
//  SNNewsScreenCheckBoxView.m
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenCheckBoxView.h"
#import "SNNewsScreenShareCheckBox.h"

#import "SNNewAlertView.h"
@interface SNNewsScreenCheckBoxView ()<UIAlertViewDelegate>

@property (nonatomic,strong) SNNewsScreenShareCheckBox* checkBox;
@property (nonatomic,strong) UIButton* btn;

@property (nonatomic,strong) UILabel* textLabel;//添加身份署名（头像，昵称）

@property (nonatomic,strong) UIButton* qbtn;//? 问号
@property (nonatomic,strong) UIImageView* q_img;//? 问号


@end

@implementation SNNewsScreenCheckBoxView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)setCheckBoxSelected:(BOOL)isSelected{
    [self.checkBox setElect:isSelected];
}

- (void)setExpired:(BOOL)expired{
    if (expired == YES) {
        self.qbtn.hidden = NO;
        self.q_img.hidden = NO;
    }
    else{
        self.qbtn.hidden = YES;
        self.q_img.hidden = YES;
    }
}


- (void)createUI{
    
    CGFloat x = (66/720.0)*kAppScreenWidth;
    CGFloat y = self.bounds.size.height-(80/1280.0)*kAppScreenHeight;
    
    self.checkBox = [[SNNewsScreenShareCheckBox alloc] initWithFrame:CGRectMake(x, y, 13, 13)];
    [self.checkBox setElect:YES];//默认不选中
    [self addSubview:self.checkBox];
    
    x = CGRectGetMaxX(self.checkBox.frame)+(18/720.0)*kAppScreenWidth;
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, kAppScreenWidth-x, 13)];
    [self.textLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [self.textLabel setTextColor:SNUICOLOR(kThemeText3Color)];
    [self addSubview:self.textLabel];
    [self.textLabel setText:@"添加头像、昵称，秀出你的姿态"];
    [self.textLabel sizeToFit];
    [self.textLabel setFrame:CGRectMake(x, y, self.textLabel.frame.size.width, 13)];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    
    self.q_img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
    
    [self.q_img setImage:[UIImage themeImageNamed:@"ico_question_v5.png"]];
    [self addSubview:self.q_img];
    self.q_img.hidden = YES;
    
    self.qbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat qb_w = 17;
    CGFloat t = (qb_w - self.textLabel.frame.size.height)/2.0;
    [self.qbtn setFrame:CGRectMake(CGRectGetMaxX(self.textLabel.frame), self.textLabel.frame.origin.y-t, qb_w, qb_w)];
    [self.qbtn setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.qbtn];
    [self.qbtn addTarget:self action:@selector(qbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.qbtn.hidden = YES;
    self.q_img.center = self.qbtn.center;
    
    //扩大点击区域
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btn setFrame:CGRectMake(self.checkBox.frame.origin.x-10, self.checkBox.frame.origin.y-10, self.checkBox.frame.size.width+20, self.checkBox.frame.size.width+20)];
    [self addSubview:self.btn];
    
    [self.btn addTarget:self action:@selector(checkClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkClick:(UIButton*)b{
    self.checkBox.isSelected = !self.checkBox.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedCheckBox:)]) {
        [self.delegate selectedCheckBox:self.checkBox.isSelected];
    }
}

- (void)qbtnClick:(UIButton*)sender{
    SNNewAlertView* alert = [[SNNewAlertView alloc] initWithTitle:@"头像、昵称未更新？" message:@"分享过程中即可自动更新" cancelButtonTitle:@"我知道了" otherButtonTitle:nil];
    [alert show];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
