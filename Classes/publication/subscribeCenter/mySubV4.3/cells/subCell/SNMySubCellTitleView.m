//
//  SNMySubCellTitleView.m
//  sohunews
//
//  Created by jojo on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMySubCellTitleView.h"
#include "SNMySubsUIDefines.h"
#import "SNDBManager.h"

@interface SNMySubCellTitleView () {
    UIImageView *_indicatorView;
    UIImageView *_mySubIconBgImageView;
}

@property (nonatomic, strong) SNWebImageView *subIconView;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *subTimeLabel;
@property (nonatomic, strong) UIImageView *newMark;
@property (nonatomic, strong) UIImageView *bgSelectedView;
@property (nonatomic, assign) BOOL isTouched;

@end

@implementation SNMySubCellTitleView
@synthesize subObj = _subObj;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *indicatorImage = [UIImage imageNamed:@"arrow.png"];
        _indicatorView = [[UIImageView alloc] initWithImage:indicatorImage];
        _indicatorView.centerY = CGRectGetMidY(self.bounds);
        _indicatorView.right = self.width - kSNMySubTitleViewIndicatorRightMargin;
        [self addSubview:_indicatorView];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
//        [self addGestureRecognizer:tap];
//         //(tap);
    }
    return self;
}

- (void)dealloc {
     //(_subObj);
     //(_subIconView);
     //(_subTimeLabel);
     //(_newMark);
     //(_subTitleLabel);
     //(_bgSelectedView);
     //(_indicatorView);
     //(_mySubIconBgImageView);
}

- (void)drawRect:(CGRect)rect {
    [UIView drawCellSeperateLine:rect margin:0.5];
}

- (void)setSubObj:(SCSubscribeObject *)subObj {
    if (_subObj != subObj) {
         //(_subObj);
        _subObj = subObj;
    }
    
    self.subIconView.urlPath = _subObj.subIcon;
    self.subTitleLabel.text = _subObj.subName;
    self.subTitleLabel.centerY = CGRectGetMidY(self.bounds);
    
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = self.subTitleLabel.text;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_subObj.publishTime longLongValue]/1000];
    self.subTimeLabel.text = [date formatTimeWithType:1];
    [self.subTimeLabel sizeToFit];
    
    // new mark
    
    int status = [_subObj statusValueWithFlag:SCSubObjStatusFlagSubStatus];
    
    //“新一期”样式
    if (status == [kHAVE_NEW_TERM intValue]) {
        _newMark.hidden = NO;
        _newMark.top = 1;
        _newMark.left = 0;
    }
    else {
        _newMark.hidden = YES;
    }
}

- (SNWebImageView *)subIconView {
    if (!_subIconView) {
        _subIconView = [[SNWebImageView alloc] initWithFrame:CGRectMake(kSNMySubTitleViewIconLeftMargin,
                                                                        kSNMySubTitleViewIconTopMargin,
                                                                        kSNMySubTitleViewIconSize,
                                                                        kSNMySubTitleViewIconSize)];
        _subIconView.clipsToBounds = YES;
        _subIconView.layer.cornerRadius = 3;
    
        _subIconView.defaultImage = [UIImage imageNamed:@"defaulticon.png"];
        [self addSubview:_subIconView];
        
        UIImage *bgImage = [[UIImage imageNamed:@"my_sub_icon_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        
        _mySubIconBgImageView = [[UIImageView alloc] initWithFrame:CGRectInset(_subIconView.frame, -0.5, -0.5)];
        _mySubIconBgImageView.image = bgImage;
        [self insertSubview:_mySubIconBgImageView belowSubview:_subIconView];
    }
    return _subIconView;
}

- (UILabel *)subTitleLabel { 
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subIconView.right + kSNMySubTitleViewTitleLeftMargin,
                                                                   kSNMySubTitleViewTitleTopMargin,
                                                                   self.width - self.subIconView.right - 2 * kSNMySubTitleViewTitleLeftMargin - 10,
                                                                   kSNMySubTitleViewTitleFont + 1)];
        _subTitleLabel.font = [UIFont systemFontOfSize:kSNMySubTitleViewTitleFont];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_subTitleLabel];
    }
    _subTitleLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
    return _subTitleLabel;
}

- (UILabel *)subTimeLabel {
    if (!_subTimeLabel) {
        _subTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subTitleLabel.left,
                                                                  self.subTitleLabel.bottom + kSNMySubTitleViewTimeTopMargin,
                                                                  0,
                                                                  0)];
        _subTimeLabel.backgroundColor = [UIColor clearColor];
        _subTimeLabel.font = [UIFont systemFontOfSize:kSNMySubTitleViewTimeFont];
        _subTimeLabel.alpha = 0;
        [self addSubview:_subTimeLabel];
    }
    _subTimeLabel.textColor = SNUICOLOR(kSNMySubTitleViewTimeTextColor);
    return _subTimeLabel;
}

- (UIImageView *)newMark {
    if (!_newMark) {
        UIImage *newMarkImage = [UIImage imageNamed:@"news_subscribe_new.png"];
        _newMark = [[UIImageView alloc] initWithImage:newMarkImage];
        _newMark.frame = CGRectMake(0, 0, 16, 16);
        [self addSubview:_newMark];
    }
    return _newMark;
}

- (UIImageView *)bgSelectedView {
    if (!_bgSelectedView) {
        UIImage *bgImage = [[UIImage imageNamed:@"cell-press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _bgSelectedView = [[UIImageView alloc] initWithImage:bgImage];
        _bgSelectedView.alpha = 0;
        [self insertSubview:_bgSelectedView atIndex:0];
    }
    _bgSelectedView.frame = self.bounds;
    return _bgSelectedView;
}

- (void)onTapped:(id)sender {
    // 去除‘新’标记
    [self.subObj setStatusValue:[kNO_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.subObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:self.subObj.subId withValuePairs:dict];
    _newMark.hidden = YES;
    
    // 打开 // 如果是可以通过link打开的 优先考虑通过link打开
    //提交参数中s1=term&s2=subscribed，表示为来自“我的订阅”。服务器端准备以此判断，这个时候忽略termId,均提供最新的内容
    SubscribeHomeMySubscribePO *_tempSubHomeMySubPO = [self.subObj toSubscribeHomeMySubscribePO];
    
    if (self.subObj.subShowType.length > 0 && self.subObj.link.length > 0) {
        self.subObj.openContext = @{@"subitem" : _tempSubHomeMySubPO,
                            @"linkType" : @"SUBLIST",
                            @"FromMySubList" : @"Yes",
                            @"s1" : @"term",
                            @"s2" : @"subscribed",};
        
        if ([self.subObj open]) return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_tempSubHomeMySubPO forKey:@"subitem"];
    [userInfo setObject:@"SUBLIST" forKey:@"linkType"];
    [userInfo setObject:@"Yes" forKey:@"FromMySubList"];
    [userInfo setObject:@"term" forKey:@"s1"];
    [userInfo setObject:@"subscribed" forKey:@"s2"];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://paperBrowser"] applyAnimated:YES] applyQuery:userInfo];
    
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouched = YES;
    [self showSelectedBgView:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouched = NO;
    [self showSelectedBgView:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *oneTouch = [touches anyObject];
    CGPoint pt = [oneTouch locationInView:self];
    
    if (self.isTouched && CGRectContainsPoint(self.bounds, pt)) {
        [self onTapped:nil];
    }
    
    [self showSelectedBgView:NO];
    self.isTouched = NO;
}

- (void)showSelectedBgView:(BOOL)show {
    if (show) {
        self.bgSelectedView.alpha = 1;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        self.bgSelectedView.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)updateTheme {
    _mySubIconBgImageView.image = [[UIImage imageNamed:@"my_sub_icon_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    _newMark.image = [UIImage imageNamed:@"news_subscribe_new.png"];
    _indicatorView.image = [UIImage imageNamed:@"arrow.png"];
    _subIconView.defaultImage = [UIImage imageNamed:@"defaulticon.png"];
    _bgSelectedView.image = [[UIImage imageNamed:@"cell-press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _subTitleLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
}
@end
