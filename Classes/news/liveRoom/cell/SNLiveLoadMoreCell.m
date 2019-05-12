//
//  SNWeiboDetailMoreCell.m
//  sohunews
//
//  Created by Chen Hong on 12-12-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveLoadMoreCell.h"
#import "SNCommentConfigs.h"

@implementation SNLiveLoadMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        _actView.left = 84;

        _promtLabel.font = [UIFont systemFontOfSize:14];
//        _promtLabel.text = @"正在加载更多...";
        _promtLabel.textAlignment = NSTextAlignmentCenter;
        _promtLabel.left = (kAppScreenWidth - 98)/2;
        
        [SNNotificationManager addObserver:self
                                                selector:@selector(stateChanged:)
                                                    name:SNCLMoreCellStateChanged
                                                  object:nil];
        [SNNotificationManager addObserver: self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

+ (CGFloat)height {
    return 40;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)showLoading:(BOOL)bShow {
    [super showLoading:bShow];
    [self setNeedsLayout];
}

- (void)setHasNoMore:(BOOL)noMore {
    _promtLabel.hidden = NO;
    if (noMore) {
        //_promtLabel.left = _actView.right + 20;
        _promtLabel.text = @"已全部加载";
    } else {
        //_promtLabel.left = _actView.right + 20 - 5;
        _promtLabel.text = @"上拉加载更多";
    }
    [self setNeedsLayout];
}

- (void)setPromtLabelText:(NSString *) text{
    _promtLabel.hidden = NO;
    _promtLabel.text = text;
}

- (void)setPromtLabelTextHide:(BOOL) hide{
    _promtLabel.hidden = hide;
}

- (void)stateChanged:(NSNotification *)notification {
    NSNumber *state = (NSNumber *)[notification object];
    
    self.state = [state intValue];
}

- (void)setState:(SNMoreCellState)state {
    switch (state) {
        case kRCMoreCellStateLoadingMore:
            [self showLoading:YES];
            break;
        case kRCMoreCellStateDragRefresh:
            [self showLoading:NO];
            [self setHasNoMore:NO];
            break;
        case kRCMoreCellStateEnd:
            [self showLoading:NO];
            [self setHasNoMore:YES];
            break;
        default:
            break;
    }
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
}

@end
