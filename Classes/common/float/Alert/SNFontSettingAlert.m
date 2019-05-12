//
//  SNFontSettingAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNFontSettingAlert.h"
#import "UIFont+Theme.h"
#import "SNNotificationManager.h"
#import "SNFontSlider.h"

#define kFontSetNewGuideHeight  324/2
#define kFontSlideWidth         654/2
#define kFontSetterViewTag      300001
#define kTipLabelTag            300002
#define kSmallTipTag            300003
#define kBigerTipTag            300006
#define kCloseBtnTipTag         400000
#define kLineViewTag            400001
#define kFontSlideTag           400002

#define kLeftLineTag        300009
#define kSliderLineTag      300013

#define kFontSetterGuideShow        @"kFontSetterGuideShow"

@interface SNFontSettingAlert () <SNFontSliderDelegate>

@property (nonatomic, strong) UIView *fontSetterView;
@property (nonatomic, strong) NSArray *setterArray;

@end

@implementation SNFontSettingAlert

- (instancetype)initWithAlertViewData:(id)content {
    self = [super init];
    if (self) {
        self.width = kAppScreenWidth;
        self.height = kAppScreenHeight;
        self.alertViewType = SNAlertViewFontSettingType;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.0;
        [self addSubview:bgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlertView)];
        [bgView addGestureRecognizer:tap];
        
        self.fontSetterView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight, self.width, 0)];
        self.fontSetterView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.fontSetterView.tag = kFontSetterViewTag;
        [self addSubview:self.fontSetterView];
        
        [UIView animateWithDuration:0.3 animations:^{
            bgView.alpha = 0.5;
            self.fontSetterView.frame = CGRectMake(0, kAppScreenHeight - kFontSetNewGuideHeight, self.width, kFontSetNewGuideHeight);
        } ];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, 230, 20)];
        tipLabel.text = @"拖动红点，可调整字号大小";
        tipLabel.textColor = SNUICOLOR(kThemeText3Color);
        tipLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeE];
        tipLabel.tag = kTipLabelTag;
        [self.fontSetterView addSubview:tipLabel];
        
        self.setterArray = [NSArray arrayWithObjects:@"小", @"中", @"大", @"特大", nil];
        [self initFontSliderView:CGPointMake(tipLabel.left - 15, tipLabel.bottom + 2)];
        
        SNFontSlider *fontSlider = [[SNFontSlider alloc] initWithFrame:CGRectMake(tipLabel.left - 3, tipLabel.bottom + 34, self.width - tipLabel.left * 2 - 4, 36) setterCnt:self.setterArray.count];
        fontSlider.sliderDelegate = self;
        [fontSlider setSliderWithIndex];
        fontSlider.tag = kFontSlideTag;
        fontSlider.backgroundColor = [UIColor clearColor];
        [self.fontSetterView addSubview:fontSlider];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kFontSetNewGuideHeight -50, self.width, 1)];
        lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
        lineView.tag = kLineViewTag;
        [self.fontSetterView addSubview:lineView];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, lineView.bottom, self.width, 49)];
        [closeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [closeBtn setTitle:@"完成" forState:UIControlStateHighlighted];
        [closeBtn setTitleColor:SNUICOLOR(kThemeText10Color) forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeE];
        [closeBtn addTarget:self action:@selector(dismissAlertView) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.tag = kCloseBtnTipTag;
        [self.fontSetterView addSubview:closeBtn];
        
        [SNNotificationManager addObserver:self
                                  selector:@selector(updateTheme)
                                      name:kThemeDidChangeNotification
                                    object:nil];
    }
    return self;
}

- (void)initFontSliderView:(CGPoint)point{
    int count = self.setterArray.count;
    
    CGFloat x = point.x, width = 48, height = 44;
    CGFloat offsetW = (kAppScreenWidth-16 - width*count)/(count - 1) + width;
    CGFloat x1 = 0, x2 = 0;
    for (int i = 0 ; i < count; i++) {
        NSString *string = [self.setterArray objectAtIndex:i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, point.y, width, height)];
        [btn setTitle:string forState:UIControlStateNormal];
        [btn setTitleColor:SNUICOLOR(kThemeText10Color) forState:UIControlStateNormal];
        [btn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeE];
        btn.tag = kSmallTipTag+i;
        [btn addTarget:self action:@selector(doChangeFont:) forControlEvents:UIControlEventTouchUpInside];
        [self.fontSetterView addSubview:btn];
        
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, point.y + 47, 1, 6)];
        line.backgroundColor = SNUICOLOR(kThemeBg1Color);
        line.userInteractionEnabled = NO;
        line.tag = kLeftLineTag+i;
        line.centerX = btn.centerX;
        [self.fontSetterView addSubview:line];
        
        if (i == 0) {
            x1 = line.centerX;
        }
        else if (i == count - 1) {
            x2 = line.centerX;
        }
        else if(i == 2){
            x -= 2;
        }

        x += offsetW;
    }
    
    UIView *sliderLine = [[UIView alloc] initWithFrame:CGRectMake(x1, point.y + 49, x2 - x1, 1)];
    sliderLine.backgroundColor = SNUICOLOR(kThemeBg1Color);
    sliderLine.userInteractionEnabled = NO;
    sliderLine.tag = kSliderLineTag;
    [self.fontSetterView addSubview:sliderLine];
}


- (void)showAlertView {
    [super showAlertView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self setFontSetterGuideShowKey:YES];
}

- (void)dismissAlertView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.fontSetterView.frame = CGRectMake(0, kAppScreenHeight, self.width, 0);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [super dismissAlertView];
    }];
}

- (void)setFontSetterGuideShowKey:(BOOL)show {
    int isFirst = [[NSUserDefaults standardUserDefaults] integerForKey:kFontSetterGuideShow];
    
    if (isFirst != 2) {
        isFirst = show ? 2 : 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:isFirst forKey:kFontSetterGuideShow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doChangeFont:(id)sender {
    UIButton *btn = (UIButton *)sender;
    int selectTag = btn.tag;
    btn.selected = YES;
    
    for (int i = 0; i < self.setterArray.count; i++) {
        int tag = i + kSmallTipTag;
        if (tag != selectTag) {
            UIButton *btn = (UIButton *)[self viewWithTag:tag];
            btn.selected = NO;
        }
    }
    
    SNFontSlider *fontSlide = (SNFontSlider *)[self.fontSetterView viewWithTag:kFontSlideTag];
    [fontSlide changeSliderWithIndex:selectTag - kSmallTipTag];
}

- (void)changeFontSliderIndex:(int)index {
    int tag = index + kSmallTipTag;
    for (int i = 0; i < self.setterArray.count; i++) {
        int tmpTag = i + kSmallTipTag;
        UIView *subView = [self viewWithTag:tmpTag];
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (tag == tmpTag) {
                btn.selected = YES;
            }
            else{
                btn.selected = NO;
            }
        }
    }
}

- (void)updateTheme {
    if (self.fontSetterView) {
        self.fontSetterView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        
        UILabel *tipView = (UILabel *)[self.fontSetterView viewWithTag:kTipLabelTag];
        tipView.textColor = SNUICOLOR(kThemeText3Color);
        
        for (int i = kSmallTipTag; i <= kBigerTipTag; i++) {
            UIButton *btn = (UIButton *)[self.fontSetterView viewWithTag:i];
            [btn setTitleColor:SNUICOLOR(kThemeText10Color) forState:UIControlStateNormal];
            [btn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
        }
        
        for (int i = kLeftLineTag; i <= kSliderLineTag; i++) {
            UIView *view = [self.fontSetterView viewWithTag:i];
            view.backgroundColor = SNUICOLOR(kThemeBg1Color);
        }
        
        SNFontSlider *fontSlide = (SNFontSlider *)[self.fontSetterView viewWithTag:kFontSlideTag];
        [fontSlide updateTheme];
        
        UIView *lineView = [self.fontSetterView viewWithTag:kLineViewTag];
        lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
        UIButton *btnView = (UIButton *)[self.fontSetterView viewWithTag:kCloseBtnTipTag];
        [btnView setTitleColor:SNUICOLOR(kThemeText10Color) forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kThemeDidChangeNotification object:nil];
}


@end
