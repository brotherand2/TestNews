//
//  SNTableAutoLoadMoreCell.m
//  sohunews
//
//  Created by Cong Dan on 4/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableAutoLoadMoreCell.h"
#import "SNTableMoreButton.h"
#import "SNRollingNewsPublicManager.h"

//static const CGFloat kMoreButtonMargin = 40.0f;

@implementation SNTableAutoLoadMoreCell

@synthesize animating = _animating, activityIndicatorView = _activityIndicatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        //5.9.3 wangchuanwen update
        //self.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        self.contentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        _moreAnimationView = [[SNTwinsMoreView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, TT_ROW_HEIGHT * 1.5)];
        [self addSubview:_moreAnimationView];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:KABTestChangeAppStyleNotification object:nil];
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    CGFloat height = [super tableView:tableView rowHeightForObject:object];
    CGFloat minHeight = TT_ROW_HEIGHT * 1.5;
    
    if (height < minHeight) {
        return minHeight;
        
    } else {
        return height;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:15];
    
    CGSize textSize = [self.textLabel.text sizeWithFont:self.textLabel.font];
    
    self.textLabel.frame = CGRectMake((self.contentView.width - textSize.width)/2, self.textLabel.top,
                                      textSize.width,
                                      self.textLabel.height);    
    
    _activityIndicatorView.left = (self.contentView.width - textSize.width)/2 - _activityIndicatorView.width - kTableCellSmallMargin;
    _activityIndicatorView.top = floor(self.contentView.height/2 - _activityIndicatorView.height/2);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [_activityIndicatorView updateTheme];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        
        SNTableMoreButton* item = object;
        self.accessoryType = UITableViewCellAccessoryNone;
        if ([SNRollingNewsPublicManager sharedInstance].moreCellStatus == SNMoreCellAllLoad) {
            self.textLabel.text = @"已全部加载";
        }
        if ([SNRollingNewsPublicManager sharedInstance].moreCellStatus == SNMoreCellRefreshAndBack) {
            self.textLabel.text = @"看完啦，点击回到顶部刷新";
        }else {
            self.textLabel.text = NSLocalizedString(@"DragToLoadMore", nil);
        }
        self.textLabel.accessibilityLabel = @"点击加载更多";
        self.animating = item.animating;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (SNWaitingActivityView*)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[SNWaitingActivityView alloc] init];
        [self.contentView addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}

- (void)updateTheme {
    //5.9.3 wangchuanwen update
    //self.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
    self.contentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    self.textLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    
    if (_animating) {
        _moreAnimationView.status = SNTwinsMoreStatusLoading;
    } else {
        _moreAnimationView.status = SNTwinsMoreStatusStop;
    }
    
    _moreAnimationView.hidden = !animating;
    
    if ([SNRollingNewsPublicManager sharedInstance].moreCellStatus == SNMoreCellAllLoad) {
        _moreAnimationView.status = SNTwinsMoreStatusStop;
        _moreAnimationView.hidden = YES;
        self.textLabel.text = @"已全部加载";
        return;
    }
    else if ([SNRollingNewsPublicManager sharedInstance].moreCellStatus == SNMoreCellRefreshAndBack){
        _moreAnimationView.status = SNTwinsMoreStatusStop;
        _moreAnimationView.hidden = YES;
        self.textLabel.text = @"看完啦，点击回到顶部刷新";
        return;
    }
    
    self.textLabel.text = animating ? @"" : NSLocalizedString(@"DragToLoadMore", nil);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    _moreAnimationView.status = SNTwinsMoreStatusStop;
    [_moreAnimationView removeFromSuperview];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    if ([SNRollingNewsPublicManager sharedInstance].moreCellStatus == SNMoreCellRefreshAndBack) {
        [SNRollingNewsPublicManager sharedInstance].refreshChannelId = @"1";
        [SNNotificationManager postNotificationName:kToastRefreshNotification object:nil];
    }
}

@end
