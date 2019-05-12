//
//  SNMoreCellForTextFont.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellForTextFont.h"
#import "SNConsts.h"

@implementation SNSettingCellForTextFont

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    
//    NSString *text = [SNUtility getNewsFontSizeLabelText];
    
    _indicateLabel.textColor = _titleLabel.textColor;
    _indicateLabel.font = _titleLabel.font;
//    _indicateLabel.text = text;
    _indicateLabel.userInteractionEnabled = YES;
    if (_indicateLabel.subviews.count == 0) {
        [self creatFontButton];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _indicateLabel.right = self.contentView.width - 12;
}

- (void)creatFontButton {
    NSArray *fontTextArray = [NSArray arrayWithObjects:@"特大", @"大", @"中", @"小", nil];
    NSInteger fontTextCount = [fontTextArray count];
    NSString *text = [SNUtility getNewsFontSizeLabelText];
    for (int i=0; i<fontTextCount; i++) {
        NSString *buttonTitle = [fontTextArray objectAtIndex:i];
        UIButton *fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fontButton.backgroundColor = [UIColor clearColor];
        fontButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        if ([text isEqualToString:buttonTitle]) {
            [fontButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
        }
        else {
            [fontButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        }
        [fontButton setTitle:buttonTitle forState:UIControlStateNormal];
        fontButton.tag = i-1;
        [fontButton sizeToFit];
        CGFloat pointX = (_indicateLabel.width - fontButton.width*fontTextCount)/fontTextArray.count;
        CGFloat pointY = (_indicateLabel.height - fontButton.height)/2;
        pointX += (pointX + fontButton.width)*i;
        fontButton.origin = CGPointMake(pointX, pointY);
        [fontButton addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_indicateLabel addSubview:fontButton];
    }
}

- (void)fontButtonClick:(id)sender {
    UIButton *fontButton = (UIButton *)sender;
    for (UIView *view in _indicateLabel.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if (fontButton.tag == view.tag) {
                [fontButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
                [SNUtility setNewsFontSize:4-fontButton.tag];
            }
            else {
                [button setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
            }
        }
    }
    
    [SNNotificationManager postNotificationName:kArticleFontSizeSetNotification object:nil];
}

@end
