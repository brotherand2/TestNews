//
//  SNUninterestedView.m
//  sohunews
//
//  Created by 赵青 on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNUninterestedView.h"

#define kTitleLabelFontSize            ((kAppScreenWidth > 375.0) ? kThemeFontSizeC : kThemeFontSizeC)
#define kTitleLabelLeftDistance        ((kAppScreenWidth > 375.0) ? 42.0/3 : 28.0/2)
#define kTitleLabelTopDistance         ((kAppScreenWidth > 375.0) ? 54.0/3 : 36.0/2)
#define kConfirmBtnBottomDistance       ((kAppScreenWidth > 375.0) ? 84.0/3 : 56.0/2)
#define kReasonsBtnHeight              ((kAppScreenWidth > 375.0) ? 114.0/3 : 76.0/2)
#define kReasonsBtnHeightSpace         ((kAppScreenWidth > 375.0) ? 21.0/3 : 14.0/2)

@implementation SNUninterestedView

- (id)initWithUninterestedItem:(SNUninterestedItem *)item
{
    self = [super init];
    if (self) {
        _uninterestedItem = item;
        _selectedReasons = [NSMutableArray array];
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        [self loadView];
    }
    return self;
}

- (CGFloat)getHeight
{
    CGFloat height = kTitleLabelTopDistance*2 + kTitleLabelFontSize + kThemeFontSizeE + kConfirmBtnBottomDistance*2;
    if (_uninterestedItem.count > 0) {
        NSInteger rows = 0;
        if (_uninterestedItem.count % 2 == 0) {
            rows = _uninterestedItem.count/2;
        } else {
            rows = _uninterestedItem.count/2 + 1;
        }
        height += kReasonsBtnHeight*rows + kReasonsBtnHeightSpace*(rows-1);
    }
    return height;
}

- (void)loadView
{
    CGFloat height = [self getHeight];
    self.frame = CGRectMake(0, kAppScreenHeight-height, kAppScreenWidth, height);
    [self createTitleLabel:@"可选理由 即可精准屏蔽"];
    [self createReasonsBtn];
    [self createConfirmBtn];
}

- (void)createTitleLabel:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.left = kTitleLabelLeftDistance;
    titleLabel.top = kTitleLabelTopDistance;
    titleLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self addSubview:titleLabel];
}

- (void)createReasonsBtn
{
    for (SNReasonItem *reasonItem in _uninterestedItem.reasonData) {
        
        NSString *title = reasonItem.rname;
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeD];
        NSInteger index = [_uninterestedItem.reasonData indexOfObject:reasonItem];

        CGFloat btnTopHeight = kTitleLabelTopDistance*2 + kTitleLabelFontSize;
        CGFloat btnWidth = (kAppScreenWidth-kTitleLabelLeftDistance*2-kReasonsBtnHeightSpace)/2;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kTitleLabelLeftDistance + (index%2)*(btnWidth+kReasonsBtnHeightSpace), btnTopHeight+(index/2)*(kReasonsBtnHeight+kReasonsBtnHeightSpace), btnWidth, kReasonsBtnHeight);
        button.tag = index;
        button.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        [button setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateSelected];
        [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateHighlighted];
        button.titleLabel.font = font;
        [button addTarget:self action:@selector(onReasonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)createConfirmBtn
{
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake((kAppScreenWidth-100)/2, 0, 100, kThemeFontSizeE+2);
    confirmBtn.bottom = self.height - (kConfirmBtnBottomDistance-2/2);
    [confirmBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
}

- (void)onReasonClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_selectedReasons addObject:[_uninterestedItem.reasonData objectAtIndex:btn.tag]];
    } else {
        [_selectedReasons removeObject:[_uninterestedItem.reasonData objectAtIndex:btn.tag]];
    }
    if (_selectedReasons.count > 0) {
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    } else {
        [confirmBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
    }
}

- (void)confirmBtnClick:(UIButton *)btn
{
    if (self.confirmBtnClickBlock) {
        self.confirmBtnClickBlock(_selectedReasons);
    }
}

@end
