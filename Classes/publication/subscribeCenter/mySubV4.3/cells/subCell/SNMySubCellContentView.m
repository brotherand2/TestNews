//
//  SNMySubCellContentView.m
//  sohunews
//
//  Created by jojo on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMySubCellContentView.h"
#include "SNMySubsUIDefines.h"
#import "SNDBManager.h"
#import "SNNewsPaperWebController.h"

@interface SNMySubCellContentView ()

@property (nonatomic, strong) SNWebImageView *newsImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTimeLabel;
@property (nonatomic, strong) UILabel *absLabel;
@property (nonatomic, strong) UIImageView *bgSelectedView;
@property (nonatomic, assign) BOOL isTouched;

@end

@implementation SNMySubCellContentView
@synthesize subObj = _subObj;
@synthesize newsImageView = _newsImageView;
@synthesize titleLabel = _titleLabel;
@synthesize absLabel = _absLabel;
@synthesize subTimeLabel = _subTimeLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewTapped:)];
//        [self addGestureRecognizer:tap];
//         //(tap);
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
     //(_subObj);
     //(_newsImageView);
     //(_titleLabel);
     //(_subTimeLabel);
     //(_absLabel);
     //(_bgSelectedView);
}

- (void)setSubObj:(SCSubscribeObject *)subObj {
    if (_subObj != subObj) {
         //(_subObj);
        _subObj = subObj;
        // update pics array
        _subObj.topNewsPicsString = subObj.topNewsPicsString;
    }
    
    CGFloat titleMaxWidth = 0;
    
    if (_subObj.topNewsPics.count > 0) {
        self.newsImageView.hidden = NO;
        self.newsImageView.urlPath = _subObj.topNewsPics[0];
        self.newsImageView.centerY = CGRectGetMidY(self.bounds) - 1;
        
        titleMaxWidth = self.width - kSNMySubContentTitleLeftMargin - self.newsImageView.width - kSNMySubContentViewImageRightMargin - kSNMySubContentTitleLeftMargin;
    }
    else {
        self.newsImageView.hidden = YES;
        titleMaxWidth = self.width - 2 * kSNMySubContentTitleLeftMargin;
    }
    
    NSString *timeText = [NSDate relativelyDate:[NSString stringWithFormat:@"%lld", [_subObj.publishTime longLongValue]]];
    self.subTimeLabel.text = timeText;
    [self.subTimeLabel sizeToFit];
    self.subTimeLabel.bottom = self.newsImageView.bottom;
    
    self.titleLabel.width = titleMaxWidth;
    self.titleLabel.text = _subObj.topNews;
    
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = self.titleLabel.text;
    
    CGSize textSize = [_subObj.topNews sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(titleMaxWidth, 1000) lineBreakMode:self.titleLabel.lineBreakMode];
    // 超过两行 不显示摘要
    // 最新修改 都不显示摘要了
    if (textSize.height > kSNMySubContentTitleFont * 2) {
        self.titleLabel.height = [self.titleLabel.font lineHeight] * 2;
        self.absLabel.hidden = YES;
    }
    // 显示摘要
    else {
        self.titleLabel.height = [self.titleLabel.font lineHeight];
        self.absLabel.hidden = YES;
        
//        self.absLabel.text = _subObj.topNewsAbstracts;
//        
//        self.absLabel.width = self.titleLabel.width;
//        self.absLabel.top = self.titleLabel.bottom + 5;
//        
//        textSize = [_subObj.topNewsAbstracts sizeWithFont:self.absLabel.font constrainedToSize:CGSizeMake(titleMaxWidth, 1000) lineBreakMode:self.absLabel.lineBreakMode];
//        self.absLabel.height = MIN(textSize.height, self.absLabel.font.lineHeight * 2);
    }
    
    if (!self.newsImageView.isHidden) {
        self.newsImageView.left = kSNMySubTitleViewIconLeftMargin;
        self.titleLabel.left = self.newsImageView.right + 10;
    }
    else {
        self.titleLabel.left = kSNMySubTitleViewIconLeftMargin;
        // 暂时没有内容
        if (self.titleLabel.text.length == 0) {
            self.titleLabel.text = @"暂时没有内容";
        }
    }
    
    self.subTimeLabel.left = self.titleLabel.left;
    self.titleLabel.top = self.newsImageView.top;
}

- (SNWebImageView *)newsImageView {
    if (!_newsImageView) {
        _newsImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, kSNMySubContentViewImageWidth, kSNMySubContentViewImageHeight)];
        _newsImageView.right = self.width - kSNMySubContentViewImageRightMargin;
        _newsImageView.centerY = CGRectGetMidY(self.bounds);
        _newsImageView.defaultImage = [UIImage imageNamed:@"defaulticon.png"];

        [self addSubview:_newsImageView];
    }
    _newsImageView.alpha = themeImageAlphaValue();
    return _newsImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSNMySubContentTitleLeftMargin,
                                                                kSNMySubContentTitleTopMargin,
                                                                0,
                                                                0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kSNMySubContentTitleFont];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
    }
    _titleLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
    return _titleLabel;
}

- (UILabel *)subTimeLabel {
    if (!_subTimeLabel) {
        _subTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  0,
                                                                  0)];
        _subTimeLabel.backgroundColor = [UIColor clearColor];
        _subTimeLabel.font = [UIFont systemFontOfSize:kSNMySubTitleViewTimeFont];
        [self addSubview:_subTimeLabel];
    }
    _subTimeLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
    return _subTimeLabel;
}

- (UILabel *)absLabel {
    if (!_absLabel) {
        _absLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.left,
                                                              0, 0, 0)];
        _absLabel.backgroundColor = [UIColor clearColor];
        _absLabel.font = [UIFont systemFontOfSize:24 / 2];
        _absLabel.textColor = [UIColor colorFromString:@"#6e6e6e"];
        _absLabel.numberOfLines = 2;
        [self addSubview:_absLabel];
    }
    return _absLabel;
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

- (void)onViewTapped:(id)sender {
    // 去除‘新’标记
    [self.subObj setStatusValue:[kNO_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.subObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:self.subObj.subId withValuePairs:dict];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.delegate respondsToSelector:NSSelectorFromString(@"updateViews")]) {
        [self.delegate performSelector:NSSelectorFromString(@"updateViews")];
    }
#pragma clang diagnostic pop
    
    // 在新闻页面之前 再插入一个刊物页面  返回直接到所属的刊物页面
    if (self.subObj.topNewsLink.length) {
        // “进入文章最终页后，点击返回应先返回订阅List页，再返回我的订阅”去掉此逻辑，直接返回我的订阅
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:kReferFromPublication forKey:kReferFrom];
        [SNUtility openProtocolUrl:self.subObj.topNewsLink context:dic];
        
        /*
        if (![self.subObj.topNewsLink isEqualToString:self.subObj.link]) {
            
            NSMutableDictionary *linkDic = [[SNUtility parseLinkParams:self.subObj.link] retain];
            SubscribeHomeMySubscribePO *_tempSubHomeMySubPO = [self.subObj toSubscribeHomeMySubscribePO];
            SNNewsPaperWebController *paperController = nil;
            
            if (linkDic &&_tempSubHomeMySubPO) {
                SNNavigationController *nv = [[TTNavigator navigator] topViewController].flipboardNavigationController;
                
                [linkDic setObject:_tempSubHomeMySubPO forKey:@"subitem"];
                [linkDic setObject:@"SUBLIST" forKey:@"linkType"];
                [linkDic setObject:@"Yes" forKey:@"FromMySubList"];
                [linkDic setObject:@"term" forKey:@"s1"];
                [linkDic setObject:@"subscribed" forKey:@"s2"];
                
                paperController = [[SNNewsPaperWebController alloc] initWithNavigatorURL:nil query:linkDic];
                paperController.view.alpha = 0;
                [nv pushViewController:paperController animated:NO];
            }
            
            [SNUtility openProtocolUrl:self.subObj.topNewsLink];
            
            if (paperController) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    paperController.view.alpha = 1;
                    [paperController release];
                });
            }
        }
        else {
            [SNUtility openProtocolUrl:self.subObj.topNewsLink];
        }
         */
    }
    else {
        
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
        [self onViewTapped:nil];
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
    _newsImageView.defaultImage = [UIImage imageNamed:@"defaulticon.png"];
    _bgSelectedView.image = [[UIImage imageNamed:@"cell-press.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _newsImageView.alpha = themeImageAlphaValue();
    _subTimeLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
    _titleLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
}

@end
