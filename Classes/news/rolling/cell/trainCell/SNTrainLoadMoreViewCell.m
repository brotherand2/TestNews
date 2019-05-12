//
//  SNTrainLoadMoreViewCell.m
//  sohunews
//
//  Created by Huang Zhen on 2017/11/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNTrainLoadMoreViewCell.h"
#import "SNTwinsMoreView.h"
#import "SNRollingTrainCellConst.h"

@interface SNTrainLoadMoreViewCell(){
    BOOL _lastNewsIsPGC;
}

@property (nonatomic, strong) SNTwinsMoreView * loadMoreView;
@property (nonatomic, strong) UILabel * allFinishedLoadView;

@end

@implementation SNTrainLoadMoreViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    CGRect rect = CGRectMake(0, 0, self.width, self.height);
    if (!self.allFinishedLoadView) {
        self.allFinishedLoadView = [[UILabel alloc] initWithFrame:rect];
        self.allFinishedLoadView.text = @"看完啦\n下拉看看别的";
        self.allFinishedLoadView.numberOfLines = 0;
        self.allFinishedLoadView.textColor = SNUICOLOR(kThemeTextRI1Color);
        self.allFinishedLoadView.font = [UIFont systemFontOfSize:11];
        self.allFinishedLoadView.textAlignment = NSTextAlignmentCenter;
        self.allFinishedLoadView.center = CGPointMake(self.width/2.f - kLeftSpace/2.f, self.height/2.f);
        [self addSubview:self.allFinishedLoadView];
        self.allFinishedLoadView.hidden = YES;
    }
    if (!self.loadMoreView) {
        CGRect animateFrame = CGRectMake(0, 0, self.width, kStatusLabelHeight + kAnimationViewHeight + 6);
        self.loadMoreView = [[SNTwinsMoreView alloc] initWithFrame:animateFrame];
        self.loadMoreView.statusLabel.font = [UIFont systemFontOfSize:11];
        self.loadMoreView.statusLabel.text = @"左滑加载更多";
        self.loadMoreView.animationView.top = 3;
        self.loadMoreView.statusLabel.top = self.loadMoreView.animationView.bottom + 3;
        self.loadMoreView.center = CGPointMake(self.width/2.f - kLeftSpace/2.f, self.height/2.f);
        [self addSubview:self.loadMoreView];
    }
}

- (void)updateTheme {
    [super updateTheme];
    [self resetFrame];
}

#pragma mark -
#pragma mark - public
- (void)startLoading {
    _isAnimating = YES;
    self.loadMoreView.hidden = NO;
    self.allFinishedLoadView.hidden = YES;
    [self.loadMoreView setStatus:SNTwinsMoreStatusLoading];
    self.loadMoreView.statusLabel.text = @"正在加载";
}

- (void)stopLoading {
    _isAnimating = NO;
    self.loadMoreView.hidden = NO;
    self.allFinishedLoadView.hidden = YES;
    [self.loadMoreView setStatus:SNTwinsMoreStatusStop];
    self.loadMoreView.statusLabel.text = @"左滑加载更多";
}

- (void)allFinishedLoad {
    _isAnimating = NO;
    [self.loadMoreView setStatus:SNTwinsMoreStatusStop];
    self.loadMoreView.hidden = YES;
    self.allFinishedLoadView.hidden = NO;
}

- (void)resetSizeWithPgc:(BOOL)isPGC {
    _lastNewsIsPGC = isPGC;
    [self resetFrame];
}

- (void)resetFrame {
    if (_lastNewsIsPGC) {
        self.allFinishedLoadView.textColor = SNUICOLOR(kThemeTextRI1Color);
        self.loadMoreView.center = CGPointMake(self.width/2.f - 2*kLeftSpace, self.height/2.f);
        self.allFinishedLoadView.center = CGPointMake(self.width/2.f - 2*kLeftSpace, self.height/2.f);
    }else{
        self.allFinishedLoadView.textColor = SNUICOLOR(kThemeTextRI1Color);
        self.loadMoreView.center = CGPointMake(self.width/2.f - kLeftSpace/2.f, self.height/2.f);
        self.allFinishedLoadView.center = CGPointMake(self.width/2.f - kLeftSpace/2.f, self.height/2.f);
    }
}

@end
