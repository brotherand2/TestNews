//
//  SNSubCenterMyListCellMenuView.m
//  sohunews
//
//  Created by Chen Hong on 12-11-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterMyListCellMenuView.h"

#define SEPLINE1_X (212.0/2)
#define SEPLINE2_X (424.0/2)
#define BTN_W 106
#define BTN_TITLE_EDGE_INSET UIEdgeInsetsMake(0, 10, 0, 0)

#define KEEP_TOP_BTN_TAG 100
#define PUSH_BTN_TAG 101
#define SUB_BTN_TAG 102

@interface SNSubCenterMyListCellMenuView () {
}

@end

@implementation SNSubCenterMyListCellMenuView

@synthesize delegate;
@synthesize object=_object;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

- (void)loadView {
    _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subcenter_mylist_menu_bg.png"]];
    [self addSubview:_bgView];
    
    UIImage *sepline = [UIImage imageNamed:@"subcenter_vertical_line.png"];
    
    _sepLine1 = [[UIImageView alloc] initWithImage:sepline];
    _sepLine1.frame = CGRectMake(SEPLINE1_X, (self.frame.size.height - _sepLine1.height)/2, _sepLine1.width, _sepLine1.height);
    [self addSubview:_sepLine1];
    
    _sepLine2 = [[UIImageView alloc] initWithImage:sepline];
    _sepLine2.frame = CGRectMake(SEPLINE2_X, (self.frame.size.height - _sepLine2.height)/2, _sepLine2.width, _sepLine2.height);
    [self addSubview:_sepLine2];
    
    UIButton *keepTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2.png"] forState:UIControlStateNormal];
    [keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2_pressed.png"] forState:UIControlStateHighlighted];
    [keepTopBtn setTitle:NSLocalizedString(@"menuKeepTop", @"") forState:UIControlStateNormal];
    [keepTopBtn setTitleEdgeInsets:BTN_TITLE_EDGE_INSET];
    [keepTopBtn setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:0 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [keepTopBtn setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    keepTopBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [keepTopBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    keepTopBtn.tag = KEEP_TOP_BTN_TAG;
    keepTopBtn.frame = CGRectMake(1, (self.frame.size.height-32)/2, BTN_W, 32);
    [self addSubview:keepTopBtn];
    _keepTopBtn = keepTopBtn;
    
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushBtn setImage:[UIImage imageNamed:@"subcenter_lock.png"] forState:UIControlStateNormal];
    [pushBtn setImage:[UIImage imageNamed:@"subcenter_lock_pressed.png"] forState:UIControlStateHighlighted];
    [pushBtn setTitle:NSLocalizedString(@"menuClosePush", @"") forState:UIControlStateNormal];
    [pushBtn setTitleEdgeInsets:BTN_TITLE_EDGE_INSET];
    [pushBtn setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:0 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [pushBtn setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    pushBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [pushBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    pushBtn.tag = PUSH_BTN_TAG;
    pushBtn.frame = CGRectMake(1+BTN_W, (self.frame.size.height-32)/2, BTN_W, 32);
    [self addSubview:pushBtn];
    _pushBtn = pushBtn;
    
    UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn.png"] forState:UIControlStateNormal];
    [subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn_p.png"] forState:UIControlStateHighlighted];
    [subBtn setTitle:NSLocalizedString(@"menuUnsubscribe", @"") forState:UIControlStateNormal];
    [subBtn setTitleEdgeInsets:BTN_TITLE_EDGE_INSET];
    [subBtn setTitleColor:[UIColor colorWithRed:187.0f/255.0f green:0 blue:0 alpha:1.0f] forState:UIControlStateHighlighted];
    [subBtn setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    subBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    subBtn.tag = SUB_BTN_TAG;
    subBtn.frame = CGRectMake(1+BTN_W*2, (self.frame.size.height-32)/2, BTN_W, 32);
    [self addSubview:subBtn];
    _subBtn = subBtn;
    
    self.exclusiveTouch = YES;
}

- (void)updateBtnTitles {
    SCSubscribeObject *obj = (SCSubscribeObject *)self.object;
    if (obj) {
        NSString *keepTopTitle = ([obj.isTop intValue] == 0 ? NSLocalizedString(@"menuKeepTop", @"") : NSLocalizedString(@"menuNotKeepTop", @""));
        NSString *pushTitle = ([obj.isPush intValue] == 0 ? NSLocalizedString(@"menuOpenPush", @"") : NSLocalizedString(@"menuClosePush", @""));
        NSString *subTitle = ([obj.isSubscribed intValue] == 0 ? NSLocalizedString(@"menuSubscribe", @"") : NSLocalizedString(@"menuUnsubscribe", @""));
        
        [_keepTopBtn setTitle:keepTopTitle forState:UIControlStateNormal];
        [_pushBtn setTitle:pushTitle forState:UIControlStateNormal];
        [_subBtn setTitle:subTitle forState:UIControlStateNormal];
    }
}

- (void)setObject:(id)object {
    if (_object != object) {
        _object = object;
    }

    [self updateBtnTitles];
}

- (void)clickBtn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    SCSubscribeObject *obj = (SCSubscribeObject *)self.object;
    
    if (btn == _keepTopBtn) {
        if ([delegate respondsToSelector:@selector(subCenterMyListCellMenuViewKeepOnTop:)]) {
            [delegate subCenterMyListCellMenuViewKeepOnTop:([obj.isTop intValue] == 0)];
        }
        [self updateBtnTitles];

    } else if (btn == _pushBtn) {
        if ([delegate respondsToSelector:@selector(subCenterMyListCellMenuViewPushOn:)]) {
            [delegate subCenterMyListCellMenuViewPushOn:([obj.isPush intValue] == 0)];
        }
        
    } else if (btn == _subBtn) {
        if ([delegate respondsToSelector:@selector(subCenterMyListCellMenuViewSubscribeOn:)]) {
            [delegate subCenterMyListCellMenuViewSubscribeOn:([obj.isSubscribed intValue] == 0)];
        }
    }
}

- (void)dealloc {
     //(_bgView);
     //(_sepLine1);
     //(_sepLine2);
    
}

- (void)updateTheme {
    _bgView.image = [UIImage imageNamed:@"subcenter_mylist_menu_bg.png"];

    UIImage *sepline = [UIImage imageNamed:@"subcenter_vertical_line.png"];
    _sepLine1.image = sepline;
    _sepLine2.image = sepline;
    
    [_keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2.png"] forState:UIControlStateNormal];
    [_keepTopBtn setImage:[UIImage imageNamed:@"subcenter_pin2_pressed.png"] forState:UIControlStateHighlighted];
    
    [_pushBtn setImage:[UIImage imageNamed:@"subcenter_lock.png"] forState:UIControlStateNormal];
    [_pushBtn setImage:[UIImage imageNamed:@"subcenter_lock_pressed.png"] forState:UIControlStateHighlighted];
    
    [_subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn.png"] forState:UIControlStateNormal];
    [_subBtn setImage:[UIImage imageNamed:@"subcenter_unsubscribe_btn_p.png"] forState:UIControlStateHighlighted];
}

@end


