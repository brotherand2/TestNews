//
//  SNVideosTableMoreCell.m
//  sohunews
//
//  Created by chenhong on 13-11-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableMoreCell.h"
#import "SNTwinsMoreView.h"

@interface SNVideosTableMoreCell() {
    SNTwinsMoreView *_moreView;
}
@end

@implementation SNVideosTableMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    /*self.width = kAppScreenWidth;
    if (self) {
        _promtLabel.hidden = YES;
        _moreView = [[SNTwinsMoreView alloc] initWithFrame:self.bounds];
        _moreView.height = [[self class] height];
        [self addSubview:_moreView];
    }*/
    return self;
}

/*+ (CGFloat)height {
    return 44;
}

- (void)showLoading:(BOOL)bShow {
    [super showLoading:NO];
    _promtLabel.hidden = YES;
    _moreView.hidden = NO;
    if (bShow) {
        _moreView.status = SNTwinsMoreStatusLoading;
    }
    else {
        _moreView.status = SNTwinsMoreStatusStop;
    }
}

- (void)setHasNoMore:(BOOL)noMore {
    _promtLabel.hidden = NO;
    _moreView.hidden = YES;
    if (noMore) {
        //_promtLabel.left = _actView.right + 20;
        _promtLabel.text = @"已全部加载";
    } else {
        //_promtLabel.left = _actView.right + 20 - 5;
        _promtLabel.text = @"";
    }
    [self setNeedsLayout];
}

- (void)dealloc {
    _moreView = nil;
}*/

@end
