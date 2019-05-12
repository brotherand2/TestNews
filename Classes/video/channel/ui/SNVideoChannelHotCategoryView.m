//
//  SNVideoHotView.m
//  sohunews
//
//  Created by jojo on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelHotCategoryView.h"
#import "UIColor+ColorUtils.h"
#import "SNVideoChannelManager.h"
#import "WSMVVideoStatisticManager.h"

#import "SNWaitingActivityView.h"

#define kTitleTopMargin                 (34 / 2)
#define kTitleLeftMargin                (20 / 2)
#define kTitleFont                      (28 / 2)
#define kTitleLabelMaxWidth             (190 / 2)

#define kDesTopMargin                   (10 / 2)
#define kDesFont                        (20 / 2)

@implementation SNVideoChannelHotCategoryView
@synthesize delegate = _delegate;
@synthesize categoryObj = _categoryObj;
@synthesize seplineType = _seplineType;
@synthesize isSubed, isLoading;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _categoryTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLeftMargin,
                                                                        kTitleTopMargin,
                                                                        kTitleLabelMaxWidth,
                                                                        kTitleFont + 1)];
        _categoryTitleLabel.backgroundColor = [UIColor clearColor];
        _categoryTitleLabel.numberOfLines = 2;
        _categoryTitleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoHotCategoryTitleColor]];
        _categoryTitleLabel.font = [UIFont systemFontOfSize:kTitleFont];
        [self addSubview:_categoryTitleLabel];

        _categoryDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLeftMargin,
                                                                      _categoryTitleLabel.bottom + kDesTopMargin,
                                                                      kTitleLabelMaxWidth,
                                                                      kDesFont + 1)];
        _categoryDesLabel.backgroundColor = [UIColor clearColor];
        _categoryDesLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoHotCategoryTitleDesciptionColor]];
        _categoryDesLabel.font = [UIFont systemFontOfSize:kDesFont];
        [self addSubview:_categoryDesLabel];
        
        UIImage *subedImage = [UIImage imageNamed:@"hot_channel_select.png"];
        _subStatusIcon = [[UIImageView alloc] initWithImage:subedImage];
        _subStatusIcon.centerY = CGRectGetMidY(self.bounds);
        _subStatusIcon.right = self.width - 20;
        [self addSubview:_subStatusIcon];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTappedAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
         //(tap);
        
        // add listener
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleHotCategorySubDidChangeNotification:)
                                                     name:kVideoChannelHotCategorySubDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    self.delegate = nil;
     //(_categoryObj);
    
     //(_categoryTitleLabel);
     //(_categoryDesLabel);
     //(_subStatusIcon);
     //(_loadingView);
    
}

- (void)setCategoryObj:(SNVideoChannelCategoryObject *)categoryObj {
     //(_categoryObj);
    _categoryObj = categoryObj;
    
    _categoryTitleLabel.text = _categoryObj.title;
    _categoryDesLabel.text = _categoryObj.author.name;
    
    if ([_categoryObj.sub integerValue] == 1) {
        UIImage *subedImage = [UIImage imageNamed:@"hot_channel_select.png"];
        _subStatusIcon.image = subedImage;
        self.isSubed = YES;
    }
    else {
        UIImage *subedImage = [UIImage imageNamed:@"hot_channel_unselect.png"];
        _subStatusIcon.image = subedImage;
        self.isSubed = NO;
    }
    
    [self setNeedsLayout];
}

- (void)setSeplineType:(SNVideoChannelHotCategoryViewSepline)seplineType {
    _seplineType = seplineType;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _categoryTitleLabel.frame = CGRectMake(kTitleLeftMargin,
                                           kTitleTopMargin,
                                           kTitleLabelMaxWidth,
                                           kTitleFont + 1);
    
    CGSize titleSize = [_categoryTitleLabel.text sizeWithFont:_categoryTitleLabel.font
                                            constrainedToSize:CGSizeMake(_categoryTitleLabel.width, CGFLOAT_MAX)
                                                lineBreakMode:_categoryTitleLabel.lineBreakMode];
    // 超过一行
    if (titleSize.height > _categoryTitleLabel.font.lineHeight) {
        _categoryTitleLabel.height = _categoryTitleLabel.font.lineHeight * 2;
        _categoryTitleLabel.top = 6;
    }
    
    _categoryDesLabel.top = _categoryTitleLabel.bottom + kDesTopMargin;
    
    _subStatusIcon.centerY = CGRectGetMidY(self.bounds);
    _subStatusIcon.right = self.width - 20;
}

- (void)showLoading:(BOOL)bShow {
    if (bShow) {
        if (!_loadingView) {
            _loadingView = [[SNWaitingActivityView alloc] init];
            [self addSubview:_loadingView];
        }

        _loadingView.centerY = CGRectGetMidY(self.bounds);
        _loadingView.right = self.width - 20;
        _loadingView.hidden = NO;
        [_loadingView startAnimating];
        
        _subStatusIcon.hidden = YES;
        self.isLoading = YES;
    }
    else {
        _loadingView.hidden = YES;
        [_loadingView stopAnimating];
        
        _subStatusIcon.hidden = NO;
        self.isLoading = NO;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat lineWidth = [UIScreen mainScreen].scale == 2.0f ? 0.5f : 1.0f;
    CGFloat lineMargin = 0;
    
    // draw seperator line
    if (_seplineType & SNVideoChannelHotCategoryViewSeplineBottomRight) {
        [self drawSeplineWithRect:CGRectMake(lineMargin,
                                             self.height - lineWidth,
                                             self.width - lineMargin - 5,
                                             lineWidth)];
    }
    
    if (_seplineType & SNVideoChannelHotCategoryViewSeplineBottomLeft) {
        [self drawSeplineWithRect:CGRectMake(5,
                                             self.height - lineWidth,
                                             self.width - lineMargin - 5,
                                             lineWidth)];
    }
    
    if (_seplineType & SNVideoChannelHotCategoryViewSeplineRight) {
        [self drawSeplineWithRect:CGRectMake(self.width - lineWidth, 0, lineWidth, self.height)];
    }
    
    if (_seplineType & SNVideoChannelHotCategoryViewSeplineLeft) {
        [self drawSeplineWithRect:CGRectMake(0, 0, lineWidth, self.height)];
    }
}

- (void)drawSeplineWithRect:(CGRect)lineRect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
	CGContextSetFillColorWithColor(context, grayColor.CGColor);
    CGContextFillRect(context, lineRect);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Actions & Slots

- (void)viewTappedAction:(id)sender {
    if (self.isLoading) {
        SNDebugLog(@"%@- category id %@ is loading", NSStringFromClass([self class]), self.categoryObj.categoryId);
        return;
    }
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
    BOOL ret = NO;
    
    NSMutableDictionary *actionDic = [NSMutableDictionary dictionary];
    if (self.categoryObj.categoryId) {
        [actionDic setObject:self.categoryObj.categoryId forKey:@"columnId"];
    }
    
    if (self.isSubed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldUnsubCategory:)] && ![self.delegate shouldUnsubCategory:self]) {
            SNDebugLog(@"last video hot category can`t be unsubscribed !");
            return;
        }
        self.categoryObj.isUnsubLoading = YES;
        ret = [[SNVideoChannelManager sharedManager] unsubscribeACategoryWithColumnId:self.categoryObj.categoryId];
        [actionDic setObject:@"1" forKey:@"action"];
    }
    else {
        ret = [[SNVideoChannelManager sharedManager] subscribeACategoryWithColumnId:self.categoryObj.categoryId];
        [actionDic setObject:@"0" forKey:@"action"];
    }
    
    if (ret) {
        [self showLoading:YES];
    }
    
    // video 统计 by jojo
    [[WSMVVideoStatisticManager sharedIntance] videoFireHotColumnsSubActionStatisticWithActionData:actionDic];
}

- (void)handleHotCategorySubDidChangeNotification:(NSNotification *)notification {
    NSString *categoryId = [notification.userInfo stringValueForKey:kVideoChannelHotCategoryIdKey defaultValue:nil];
    if ([categoryId isEqualToString:self.categoryObj.categoryId]) {
        
        if ([notification.userInfo intValueForKey:kVideoChannelHotCategorySubResultKey defaultValue:-1] == 0) {
            if (self.isSubed) {
                self.categoryObj.sub = @"0";
                UIImage *subedImage = [UIImage imageNamed:@"hot_channel_unselect.png"];
                _subStatusIcon.image = subedImage;
            }
            else {
                self.categoryObj.sub = @"1";
                UIImage *subedImage = [UIImage imageNamed:@"hot_channel_select.png"];
                _subStatusIcon.image = subedImage;
                
                // todo@jojo 第一次选中某个栏目 弹出提示5s
                if (![self.categoryObj.author.type isEqualToString:@"-1"] && ![self.categoryObj.binding isEqualToString:@"1"]) {
                    NSString *infoString = @"成功添加到热播频道";
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:infoString toUrl:nil mode:SNCenterToastModeSuccess];
                }
            }
            // todo@jojo 是否需要更新缓存 ？？？
            
            self.isSubed = !self.isSubed;
        }
        
        [self showLoading:NO];
    }
    self.categoryObj.isUnsubLoading = NO;
}

@end
