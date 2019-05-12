//
//  SNArticleDownView.m
//  sohunews
//
//  Created by qz on 09/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//
#define GRAY(c) [UIColor colorWithRed:(c&0xFF)/255.0 green:(c&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

#import <JsKitFramework/JsKitFramework.h>
#import "SNArticleDownView.h"
#import <JsKitFramework/JsKitStorage.h>
#import <JsKitFramework/JsKitStorageManager.h>
#import <SVVideoForNews/SVVideoForNews.h>
#import "SHH5NewsWebViewController.h"

@interface SNArticleDownView(){
    CGFloat _viewHeight;
}
@property (nonatomic,strong) UIView  *bgView;
@property (nonatomic,strong) UILabel *nightShiftLbl; //夜间模式
@property (nonatomic,strong) UILabel *fontSizeLbl;   //字号设置
@property (nonatomic,strong) UILabel *tipOffLbl;     //举报
@property (nonatomic,strong) UIButton *tipOffBtn;     //举报按钮
@property (nonatomic,strong) UISwitch *nightSwitch;

@property (nonatomic,strong) UIButton *bigFontBtn;
@property (nonatomic,strong) UIButton *smallFontBtn;
@property (nonatomic,strong) UIButton *middleFontBtn;

@property (nonatomic,strong) UIImageView *arrowsImageView;

@end


@implementation SNArticleDownView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _viewHeight = frame.size.height;
        [self initViews];
    }
    
    return self;
}

-(void)initViews
{
    self.nightShiftLbl = [self labelModelWithFrame:CGRectMake(52/2, 26, 62, 40) text:@"夜间模式"];
    [self addSubview:_nightShiftLbl];
    
    self.fontSizeLbl = [self labelModelWithFrame:CGRectMake(52/2, 90, 62, 40) text:@"字号设置"];
    [self addSubview:_fontSizeLbl];
    
    self.tipOffLbl = [self labelModelWithFrame:CGRectMake(52/2, 154, 62, 40) text:@"举报"];
    [self addSubview:_tipOffLbl];
    
    self.bigFontBtn = [self buttonModelWithFrame:CGRectMake(self.frame.size.width-33, 90, 20, 20) text:@"大"];
    [self addSubview:_bigFontBtn];
    
    self.smallFontBtn = [self buttonModelWithFrame:CGRectMake(self.frame.size.width-140, 90, 20, 20) text:@"小"];
    [self addSubview:_smallFontBtn];
    self.middleFontBtn = [self buttonModelWithFrame:CGRectMake(self.frame.size.width-85, 90, 20, 20) text:@"中"];
    [self addSubview:_middleFontBtn];
    
    self.arrowsImageView =[[UIImageView alloc]init];
    _arrowsImageView.frame = CGRectMake(self.frame.size.width-27, 160, 13.5, 13.5);
    _arrowsImageView.image = [UIImage imageNamed:@"icome_arrows_v5.png"];
    [self addSubview:_arrowsImageView];
    
    self.nightSwitch = [[UISwitch alloc] init];
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault]) {
        _nightSwitch.on = NO;
        _nightSwitch.alpha = 1;
    }else{
        _nightSwitch.on = YES;
        _nightSwitch.alpha = 0.6;
    }
    _nightSwitch.frame = CGRectMake(self.frame.size.width-14-50, 22, 50, 22);
    [_nightSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_nightSwitch];
    
    self.tipOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _tipOffBtn.backgroundColor = [UIColor clearColor];
    _tipOffBtn.frame = CGRectMake(0, CGRectGetMinY(_tipOffLbl.frame) - 20, self.frame.size.width, 60);
    [_tipOffBtn addTarget:self action:@selector(tipOff:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tipOffBtn];
}

-(void)tipOff:(UIButton *)sender
{
    if (_delegate) {
        //举报操作
        [_delegate tipOffOperation];
    }
}

//切换字体
-(void)fontButtonClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    if (sender.tag == 1) {
        _middleFontBtn.selected =
        _smallFontBtn.selected = NO;
        if (_delegate) {
            [_delegate updateFontSize:4];
        }
    }else if (sender.tag == 2) {
        _bigFontBtn.selected =
        _smallFontBtn.selected = NO;
        if (_delegate) {
            [_delegate updateFontSize:3];
        }
    }else{
        _bigFontBtn.selected =
        _middleFontBtn.selected = NO;
        if (_delegate) {
            [_delegate updateFontSize:2];
        }
    }
    
}

//切换夜间模式
-(void)switchAction:(id)sender
{
    [SNNewsReport reportADotGif:@"act=cc&fun=85"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UISwitch *switchBtin = (UISwitch*)sender;
        if (switchBtin.isOn) {
            if (_delegate) {
                [_delegate nightShiftOperation:YES];
                _nightSwitch.alpha = 0.6;
            }
        }else{
            if (_delegate) {
                [_delegate nightShiftOperation:NO];
                _nightSwitch.alpha = 1;
            }
        }
        [self updateTheme];
    });
}

- (void)updateTheme{
    if (_delegate && [_delegate isKindOfClass:SHH5NewsWebViewController.class]) {
        SHH5NewsWebViewController *tmpController = (SHH5NewsWebViewController*)_delegate;
        [tmpController updateTheme:nil];
    }
    _bgView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
    _fontSizeLbl.textColor = SNUICOLOR(kActionsheetTextColor);
    _tipOffLbl.textColor = SNUICOLOR(kActionsheetTextColor);
    _nightShiftLbl.textColor = SNUICOLOR(kActionsheetTextColor);
    
    [_smallFontBtn setTitleColor:SNUICOLOR(kActionsheetTextColor) forState:UIControlStateNormal];
    [_smallFontBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
    
    [_middleFontBtn setTitleColor:SNUICOLOR(kActionsheetTextColor) forState:UIControlStateNormal];
    [_middleFontBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
    
    [_bigFontBtn setTitleColor:SNUICOLOR(kActionsheetTextColor) forState:UIControlStateNormal];
    [_bigFontBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
}

-(UILabel *)labelModelWithFrame:(CGRect)lblFrame text:(NSString *)text;
{
    UILabel *lbl = [[UILabel alloc]initWithFrame:lblFrame];
    lbl.textColor = SNUICOLOR(kActionsheetTextColor);
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:16];
    lbl.backgroundColor = [UIColor clearColor];
    [lbl sizeToFit];//忽略传入的size
    return lbl;
}

-(UIButton *)buttonModelWithFrame:(CGRect)btnFrame text:(NSString *)text;
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    btn.frame = btnFrame;
    NSString *currText = [SNUtility getNewsFontSizeLabelText];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:SNUICOLOR(kActionsheetTextColor) forState:0];
    [btn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
    if ([currText isEqualToString:text]) {
        btn.selected = YES;
    }
    [btn addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    if([text isEqualToString:@"大"]){
        btn.tag = 1;
    }else if([text isEqualToString:@"中"]){
        btn.tag = 2;
    }else{
        btn.tag = 3;
    }
    btn.backgroundColor = [UIColor clearColor];
    return btn;
}

@end
