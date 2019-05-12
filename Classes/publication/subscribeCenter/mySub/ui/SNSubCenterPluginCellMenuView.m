//
//  SNSubCenterPluginCellMenuView.m
//  sohunews
//
//  Created by chenhong on 13-6-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubCenterPluginCellMenuView.h"

#define SEPLINE1_X (212.0/2)
#define SEPLINE2_X (424.0/2)
#define BTN_W 106
#define BTN_TITLE_EDGE_INSET UIEdgeInsetsMake(0, 10, 0, 0)

#define KEEP_TOP_BTN_TAG 100
#define PUSH_BTN_TAG 101
#define SUB_BTN_TAG 102

@implementation SNSubCenterPluginCellMenuView

- (void)loadView {
    _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subcenter_mylist_menu_bg.png"]];
    [self addSubview:_bgView];
    
    UIImage *sepline = [UIImage imageNamed:@"subcenter_vertical_line.png"];
    
    _sepLine1 = [[UIImageView alloc] initWithImage:sepline];
    _sepLine1.frame = CGRectMake(self.frame.size.width/2, (self.frame.size.height - _sepLine1.height)/2, _sepLine1.width, _sepLine1.height);
    [self addSubview:_sepLine1];
    
    UIButton *keepTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2.png"] forState:UIControlStateNormal];
    [keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2_pressed.png"] forState:UIControlStateHighlighted];
    [keepTopBtn setTitle:NSLocalizedString(@"menuKeepTop", @"") forState:UIControlStateNormal];
    [keepTopBtn setTitleEdgeInsets:BTN_TITLE_EDGE_INSET];
    [keepTopBtn setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:0 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [keepTopBtn setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    keepTopBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [keepTopBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop

    keepTopBtn.tag = KEEP_TOP_BTN_TAG;
    keepTopBtn.frame = CGRectMake((self.frame.size.width/2 - BTN_W)/2, (self.frame.size.height-32)/2, BTN_W, 32);
    [self addSubview:keepTopBtn];
    _keepTopBtn = keepTopBtn;
    
    UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn.png"] forState:UIControlStateNormal];
    [subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn_p.png"] forState:UIControlStateHighlighted];
    [subBtn setTitle:NSLocalizedString(@"menuUnsubscribe", @"") forState:UIControlStateNormal];
    [subBtn setTitleEdgeInsets:BTN_TITLE_EDGE_INSET];
    [subBtn setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:0 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [subBtn setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop

    subBtn.tag = SUB_BTN_TAG;
    subBtn.frame = CGRectMake(self.frame.size.width/2 + (self.frame.size.width/2 - BTN_W)/2, (self.frame.size.height-32)/2, BTN_W, 32);
    [self addSubview:subBtn];
    _subBtn = subBtn;
    
    self.exclusiveTouch = YES;
}

- (void)updateBtnTitles {
    SCSubscribeObject *obj = (SCSubscribeObject *)self.object;
    if (obj) {
        NSString *keepTopTitle = ([obj.isTop intValue] == 0 ? NSLocalizedString(@"menuKeepTop", @"") : NSLocalizedString(@"menuNotKeepTop", @""));
        NSString *subTitle = ([obj.isSubscribed intValue] == 0 ? NSLocalizedString(@"menuUse", @"") : NSLocalizedString(@"menuStopUse", @""));
        
        [_keepTopBtn setTitle:keepTopTitle forState:UIControlStateNormal];
        [_subBtn setTitle:subTitle forState:UIControlStateNormal];
    }
}

@end
