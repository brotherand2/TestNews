//
//  SNSubChannelHeadView.m
//  sohunews
//
//  Created by wang yanchen on 13-4-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubChannelHeadView.h"
#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "SNSubscribeCenterService.h"

#define kHeadViewHeight                 (116 / 2)
#define kHeadViewSideMargin             (10)
#define kHeadViewBottomLineHeight       (2)

#define kSubTitleFont                   (60 / 2)
#define kSubTitleTopMargin              (30 / 2)
#define kSubBtnTopMargin                (26 / 2)

@implementation SNSubChannelHeadView
@synthesize subTitle = _subTitle;
@synthesize isSubed = _isSubed;
@synthesize action = _action;
@synthesize subId = _subId;

- (id)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width, kHeadViewHeight);
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoBackgroundColor]];
        
        UIImage *image = [UIImage imageNamed:@"add_subFollow.png"];
        _subBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _subBtn.size = image.size;
        [_subBtn setBackgroundImage:image forState:UIControlStateNormal];
        _subBtn.top = kSubBtnTopMargin;
        _subBtn.right = self.width - kHeadViewSideMargin;
        [_subBtn addTarget:self action:@selector(subAction:) forControlEvents:UIControlEventTouchUpInside];
        [_subBtn setAccessibilityLabel:@"关注"];
        [self addSubview:_subBtn];
        
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHeadViewSideMargin,
                                                                   (self.height - kSubTitleFont) / 2,
                                                                   self.width - kHeadViewSideMargin - _subBtn.width - kHeadViewSideMargin,
                                                                   kSubTitleFont + 1)];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:kSubTitleFont];
        _subTitleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTermNameColor]];
        [self addSubview:_subTitleLabel];
        
//        _complexLabel = [[SNDateLabel alloc] initWithFrame:CGRectMake(220, 0, 90, 60)];
//        
//        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 43, 100, 15)];
//        _timeLabel.font = [UIFont systemFontOfSize:10];
//        _timeLabel.backgroundColor = [UIColor clearColor];
//        _timeLabel.textColor = [UIColor grayColor];
//        _timeLabel.textAlignment = UITextAlignmentRight;
//        [self addSubview:_timeLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        _subTitleLabel.userInteractionEnabled = YES;
        [_subTitleLabel addGestureRecognizer:tap];
         //(tap);
        
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
    }
    return self;
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
     //(_subTitle);
     //(_action);
     //(_subId);
     //(_complexLabel);
     //(_timeLabel);
}

- (void)updateTheme {
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoBackgroundColor]];
    
    UIImage *image = [UIImage imageNamed:@"add_subFollow.png"];
    [_subBtn setBackgroundImage:image forState:UIControlStateNormal];

    _subTitleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTermNameColor]];
    
//    [_complexLabel setNeedsDisplay];
}

- (void)setSubTitle:(NSString *)subTitle {
    if (_subTitle != subTitle) {
         //(_subTitle);
        _subTitle = [subTitle copy];
//        [self setNeedsDisplay];
        _subTitleLabel.text = _subTitle;
    }
}

- (void)setIsSubed:(BOOL)isSubed {
    _isSubed = isSubed;
    if (isSubed) {
//        _subBtn.hidden = YES;
//        _timeLabel.hidden = YES;
//        if ([_complexLabel superview] == nil) {
//            [self addSubview:_complexLabel];
//        }
//        _complexLabel.hidden = NO;
        
        UIImage *image = [UIImage imageNamed:@"remove_subFollow.png"];
        [_subBtn setBackgroundImage:image forState:UIControlStateNormal];
    } else {
//        _subBtn.hidden = NO;
//        _timeLabel.hidden = YES; // 新的ui样式  把timeLabel隐藏掉  显示一个大的“加关注”按钮 by jojo
//        _complexLabel.hidden = YES;
        
        UIImage *image = [UIImage imageNamed:@"add_subFollow.png"];
        [_subBtn setBackgroundImage:image forState:UIControlStateNormal];
    }
//    [self setNeedsDisplay];
}

- (void)setDateString:(NSString *)publishDate;
{
    if (publishDate && publishDate.length > 0) {
        _timeLabel.text = publishDate;
        _complexLabel.dateString = publishDate;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    // bottom line
    UIColor *bottomColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoSeperatorColor]];
    CGRect bottomLineRect = CGRectMake(kHeadViewSideMargin,
                                       self.height - kHeadViewBottomLineHeight,
                                       self.width - 2 * kHeadViewSideMargin,
                                       kHeadViewBottomLineHeight);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, bottomColor.CGColor);
    CGContextFillRect(context, bottomLineRect);
}

#pragma mark - actions
- (void)subAction:(id)sender {
    _subBtn.userInteractionEnabled = NO;
    if (self.action) self.action();
}

- (void)viewTapped:(id)sender {
    if (self.subId.length > 0) {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
        if (!subObj) {
            subObj = [[SCSubscribeObject alloc] init];
            subObj.subId = self.subId;
        }
        subObj.openContext = @{@"fromNewsPaper" : @"YES"};
        [subObj openDetail];
    }
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = YES;
            }
        }
    }
    else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = NO;
            }
        }
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = NO;
            }
        }
    }
    else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = YES;
            }
        }
    }

}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = NO;
            }
        }
    }
    else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        if ([dataSet.strongDataRef isKindOfClass:[NSString class]]) {
            if ([dataSet.strongDataRef isEqualToString:self.subId]) {
                _subBtn.userInteractionEnabled = YES;
                self.isSubed = YES;
            }
        }
    }
}

@end
