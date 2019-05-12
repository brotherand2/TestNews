//
//  SNSpecialTextNewsTableCell.m
//  sohunews
//
//  Created by handy wang on 7/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNConsts.h"
#import "SNSpecialTextNewsTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNSpecialNewsTableItem.h"
#import "SNThemeManager.h"
#import "UIImage+Utility.h"

#define kRowHeight (106/2)

@implementation SNSpecialTextNewsTableCell

#pragma mark - Public methods implementation

#pragma mark - Override

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return kRowHeight;
}

- (void)setObject:(id)object {
    isNewItem = _item != object;
    
	if (isNewItem) {
        
		_item = object;
        
        if (_item) {
            SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
            SNDebugLog(SN_String("INFO: %@--%@, item is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [snItem description]);
            
            snItem.delegate = self;
            snItem.selector = NSSelectorFromString(@"openNews");
            
            if (snItem.text && ![@"" isEqualToString:snItem.text]) {
                self.textLabel.text = snItem.text;
            }
            self.detailTextLabel.text = nil;
            self.backView.hidden = YES;
            
            [self setNeedsDisplay];
        }
	}
}

- (void)layoutSubviews {
    
    CGFloat width = self.contentView.width - kTableCellHPadding * 4;
    CGFloat left = kTableCellHPadding;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(left, 0, width, kRowHeight);
    self.textLabel.font = [UIFont systemFontOfSize:17];
    self.textLabel.adjustsFontSizeToFitWidth = NO;
    if	(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        self.textLabel.left = 0;
    }
    self.detailTextLabel.text = nil;
    
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
//        _arrowView.frame = CGRectMake(602/2, 42/2, 15/2.0, 24/2);
        CGFloat xValue = self.contentView.width - kTableCellHPadding - 15/2;
        _arrowView.frame = CGRectMake(xValue, 42/2, 15/2.0, 24/2);
        [self addSubview:_arrowView];
    }
    
    if (!_videoView) {
        _videoView = [[UIImageView alloc] init];
        _videoView.frame = CGRectMake(self.textLabel.right, (self.height - 11) / 2, 11, 11);
        _videoView.image = [UIImage themeImageNamed:@"news_video_dark.png"];
        [self addSubview:_videoView];
    }
    
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    if (snItem) {
        _videoView.hidden = ![[snItem.news hasVideo] isEqualToString:@"1"];
    }
    else {
        _videoView.hidden = YES;
    }
    
    if ([snItem.news.newsType isEqualToString:kSNVoteNewsType]) {
        _videoView.hidden = NO;
        _videoView.frame = CGRectMake(_videoView.left, _videoView.top, 15, 11);
        _videoView.image = [UIImage imageNamed:@"news_vote_icon.png"];
    } else {
        _videoView.frame = CGRectMake(_videoView.left, _videoView.top, 11, 11);
        _videoView.image = [UIImage imageNamed:@"news_video_dark.png"];
    }
    
    if ([snItem.news.newsType isEqualToString:kSNTextNewsType]) {
        _arrowView.hidden = YES;
    }
    else {
        _arrowView.hidden = NO;
    }
  
    // 动态算text长度
    NSString *title = self.textLabel.text;
    if (title && [title length] > 0) {
        CGSize size = [title sizeWithFont:self.textLabel.font];
//        CGFloat maxWidth = 566/2 - self.textLabel.left;
        CGFloat maxWidth = self.contentView.width - kTableCellHPadding * 2 - 10 - 56/2;
        if (_videoView.hidden == NO) {
            maxWidth -= (_videoView.size.width + 8);
        }
        
        if (!_videoView.isHidden)
            maxWidth -= _videoView.width + 8;
        size.width = MIN(size.width, maxWidth);
        self.textLabel.width = size.width;
        _videoView.left = self.textLabel.right + 8;
    }
    
    if (!_typeIcon) {
        _typeIcon = [[UILabel alloc] init];
//        _typeIcon.frame = CGRectMake(566/2, CGRectGetMidY(self.textLabel.frame) - 28/2/2, 56/2.0, 28/2);
        CGFloat xValue = self.contentView.size.width - kTableCellHPadding - 56/2;
        _typeIcon.frame = CGRectMake(xValue, CGRectGetMidY(self.textLabel.frame) - 28/2/2, 56/2.0, 28/2);
        _typeIcon.textAlignment = NSTextAlignmentCenter;
        _typeIcon.layer.cornerRadius = 2;
        _typeIcon.font = [UIFont systemFontOfSize:10];
        
        _typeIcon.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeLiveColor]];
        _typeIcon.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeTextColor]];
        
        [self addSubview:_typeIcon];
    }
    
    if ([snItem.news.newsType isEqualToString:kSNGroupPhotoNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = NSLocalizedString(@"GroupPhotoNews", nil);
        [self setBgBlue];
    } else if ([snItem.news.newsType isEqualToString:kSNSpecialNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"专题";
        [self setBgRed];
    }
    else if ([snItem.news.newsType isEqualToString:kSNNewsPaperNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"期刊";
        [self setBgRed];
    }
    else if ([snItem.news.newsType isEqualToString:kSNLiveNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"直播";
        [self setBgBlue];
    }
    else if ([snItem.news.newsType isEqualToString:kSNSpecialNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"专题";
        [self setBgRed];
    }
    else if ([snItem.news.newsType isEqualToString:kSNVoteWeiwenType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"微闻";
        [self setBgBlue];
    }
    else {
        _typeIcon.hidden = YES;
        _typeIcon.text = @"";
    }
   
    [self updateTheme];
}

-(void)setBgRed
{
    _typeIcon.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeSpecialColor]];
    _typeIcon.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeTextColor]];
}

-(void)setBgBlue
{
    _typeIcon.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeLiveColor]];
    _typeIcon.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsTypeTextColor]];
}

- (void)showSelectedBg:(BOOL)show
{
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    if ([snItem.news.newsType isEqualToString:kSNTextNewsType]) return;
    
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _cellSelectedBg.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)setAlreadyReadStyle {
    [super setAlreadyReadStyle];

    _arrowView.image = [UIImage imageNamed:@"arrow_hl.png"];
    
}

- (void)setUnReadStyle {
    [super setUnReadStyle];

    _arrowView.image = [UIImage imageNamed:@"arrow.png"];
    
}

#pragma mark - Normal

-(void)updateTypeIcon {
    
    SNSpecialNewsTableItem *cellItem = (SNSpecialNewsTableItem *)_item;
    if (cellItem && [cellItem.news.newsType isEqualToString:kSNGroupPhotoNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = NSLocalizedString(@"GroupPhotoNews", nil);
        [self setBgBlue];
    }
    else if (cellItem && [cellItem.news.newsType isEqualToString:kSNSpecialNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"专题";
        [self setBgRed];
    }
    else if (cellItem && [cellItem.news.newsType isEqualToString:kSNNewsPaperNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"媒体";
        [self setBgRed];
    }
    else if (cellItem && [cellItem.news.newsType isEqualToString:kSNLiveNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"直播";
        [self setBgBlue];
    }
    else if (cellItem && [cellItem.news.newsType isEqualToString:kSNSpecialNewsType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"专题";
        [self setBgRed];
    }
    else if (cellItem && [cellItem.news.newsType isEqualToString:kSNVoteWeiwenType]) {
        _typeIcon.hidden = NO;
        _typeIcon.text = @"微闻";
        [self setBgBlue];
    }
    else {
        _typeIcon.hidden = YES;
        _typeIcon.text = @"";
    }
}

-(void)updateTheme {
    [super updateTheme];
    [super setReadStyleByMemory];
    [self updateTypeIcon];
    
    if (![self needsUpdateTheme]) {
        return;
    }
}

- (void)dealloc {
     //(_arrowView);
     //(_videoView);
     //(_typeIcon);
    
}


@end
