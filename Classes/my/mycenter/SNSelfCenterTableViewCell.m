//
//  SNSelfCenterTableViewCell.m
//  sohunews
//
//  Created by yangln on 14-9-24.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterTableViewCell.h"

#import "SNSelfCenterViewController.h"
#import "SNBubbleBadgeService.h"
#import "SNBubbleBadgeObject.h"
#import "SNCheckManager.h"
#import "SNVideoDownloadManager.h"
#import "SNUserManager.h"

#define kShowMessageGuideKey @"snShowMessageGuideKey"
#define kShowActivityHighlightKey @"kShowActivityHighlightKey"
#define kSNSelfCenterActionHighLight     -1
#define kSNSelfCenterActionRmHighLight   0
#define kSNSelfOffLineMediaTag 1003
#define kSNSelfActivityTag 1007

@implementation SNSelfCenterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewCellHeight)];
        _bgImageView.alpha = 0;
        [self.contentView addSubview:_bgImageView];
        
        [SNNotificationManager addObserver:self selector:@selector(onBubbleMessageNotification:) name:kSNBubbleBadgeChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onBubbleMessageNotification:) name:kHasNewFeedBackOrVersin object:nil];
        [SNNotificationManager addObserver:self selector:@selector(onActionReceived:) name:kSNJoinActionNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        
        _customButton = [[SNMyCustomButton alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNSelfCenterTableViewCellHeight)];
        [self.contentView addSubview:_customButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setHighlighted:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        _bgImageView.alpha = 1;
        _bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    }
    else {
        _bgImageView.alpha = 0;
        _bgImageView.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark set tabel cell
- (void)setCellItem:(NSString *)imageName text:(NSString *)text tag:(NSInteger)tag {
    _customButton.text = text;
    _customButton.iconName = imageName;
    _typeTag = tag;
    if(_typeTag == kSelfCenterMessageTag) {
        BOOL showGuide = [[self getDefaultObject:kShowMessageGuideKey] boolValue];
        if (![SNUserinfoEx isLogin] && !showGuide) {
            [_customButton setTipCount:1];
        }
    }
    
    if (_typeTag == kSNSelfActivityTag || _typeTag == kSNSelfOffLineMediaTag) {
        _customButton.size = CGSizeMake(kAppScreenWidth, kSNSelfCenterTableViewCellHeight + 11);
        _bgImageView.origin = CGPointMake(0, 11);
        [_customButton resetImageViewAndLabelOrigin];
    }
    [self updateBubble];
    [self updateActivityView];
}

- (void)setCellItemSeperateLine:(NSInteger)row {
    if (!_cellItemSeperateImageView) {
        _cellItemSeperateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSNSelfCenterTableViewCellHeight-0.5, kAppScreenWidth, 0.5)];
        [self.contentView addSubview:_cellItemSeperateImageView];
    }
    if (row == 3) {
        _cellItemSeperateImageView.origin = CGPointMake(0, kSNSelfCenterTableViewCellHeight+10.5);
    }
    _cellItemSeperateImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
}

- (void)reSetBubble:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section == 1 && row == 3) {
        [self setDefaultObject:[NSNumber numberWithBool:YES] valueKey:kShowMessageGuideKey];
        [[SNBubbleNumberManager shareInstance] resetReply];
    }
    else if (section == 2) {
        if(row == 0) {//活动
            [self setDefaultObject:[NSNumber numberWithBool:NO] valueKey:kShowActivityHighlightKey];
            [self updateActivityView];
            [self updateBubble];
        }
        else if (row == 2) {//设置
            [self updateBubble];
        }
    }
}

#pragma mark Notification
- (void)onBubbleMessageNotification:(NSNotification*)notification
{
    [self performSelectorOnMainThread:@selector(updateBubble) withObject:nil waitUntilDone:NO];
}

- (void)onActionReceived:(NSNotification*)notification
{
    [self setDefaultObject:[NSNumber numberWithBool:YES] valueKey:kShowActivityHighlightKey];
    [self updateActivityView];
    [self updateBubble];
}

#pragma mark update
- (void)updateTheme {
    [self setNeedsDisplay];
    [self updateBubble];
    [self updateActivityView];
}

- (void)updateBubble {
    if (_typeTag == kSelfCenterMessageTag) {
        BOOL showGuide = [[self getDefaultObject:kShowMessageGuideKey] boolValue];
        int count = fabs([SNBubbleNumberManager shareInstance].ppnotify) + fabs([SNBubbleNumberManager shareInstance].ppreply);
        if (count > 0 || (![SNUserinfoEx isLogin] && !showGuide))
            [_customButton setTipCount:kSNSelfCenterActionHighLight];
        else
            [_customButton setTipCount:kSNSelfCenterActionRmHighLight];
    }
    else if (_typeTag == kSelfCenterSettingTag) {
        int count = [SNBubbleNumberManager shareInstance].feedback;
        if  ([SNCheckManager checkNewVersion]) {
            count += 1;
        }
        if (count > 0)
            [_customButton setTipCount:kSNSelfCenterActionHighLight];
        else
            [_customButton setTipCount:kSNSelfCenterActionRmHighLight];
    }
}

-(void)updateActivityView
{
    if (_typeTag == kSelfCenterActivityTag) {
        NSNumber* showActionHighlight = [[NSUserDefaults standardUserDefaults] objectForKey:kShowActivityHighlightKey];
        //14-1-22UI修改，活动灯泡使用红点代替原来的图片切换。
        if ([showActionHighlight boolValue]) {
            [_customButton setTipCount:kSNSelfCenterActionHighLight];
        }
        else {
            [_customButton setTipCount:kSNSelfCenterActionRmHighLight];
        }
    }
}

- (void)setDefaultObject:(id)value valueKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

- (NSString *)getDefaultObject:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [userDefaults objectForKey:key];
    return str;
}

- (void)dealloc {
     //(_cellItemSeperateImageView);
     //(_bgImageView);
     //(_customButton);
    [SNNotificationManager removeObserver:self];
    
}

@end
