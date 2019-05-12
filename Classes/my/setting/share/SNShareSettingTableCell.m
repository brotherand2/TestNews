//
//  SNShareSettingTableCell.m
//  sohunews
//
//  Created by 李 雪 on 11-7-19.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNShareSettingTableItem.h"
#import "SNShareSettingTableCell.h"
#import "SNShareSettingItem.h"
#import "UIColor+ColorUtils.h"
#import "SNShareManager.h"
#import "SNDBManager.h"

#define BUTTON_SIZE_WIDTH				(70.0)
#define BUTTON_SIZE_HEIGHT				(32.0)

@implementation SNShareSettingTableCell

- (void)setObject:(id)object {
	if (_item == object) {
		return;
	}
	
	[super setObject:object];

	SNShareSettingTableItem *item = (SNShareSettingTableItem*)object;
    NSString *iconUrl = ([item.shareSettingItem.shareListItem.status intValue] == 0) ? item.shareSettingItem.shareListItem.appIconUrl : item.shareSettingItem.shareListItem.appGrayIconUrl;
    SNWebImageView *webImageView = (SNWebImageView *)[self viewWithTag:222];
    if (!webImageView) {
        webImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(10, 0, 180 / 2, 60 / 2)];
        webImageView.centerY = CGRectGetMidY(self.imageView.superview.bounds) + 3;
        webImageView.tag = 222;
        [self addSubview:webImageView];//原先不知为何加在self.imageView.superview上，导致社区图片解绑、绑定不能及时更新
    }
    [webImageView loadUrlPath:iconUrl];
    
    if (!_userName) {
        _userName = [[UILabel alloc] initWithFrame:CGRectMake(130, (106 / 2 - 30) / 2, 100, 30)];
        _userName.font = [UIFont systemFontOfSize:13];
        _userName.lineBreakMode = NSLineBreakByTruncatingTail;
        _userName.backgroundColor = [UIColor clearColor];
        _userName.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        [self addSubview:_userName];
    }

    ((UIButton *)item.control).titleLabel.font = [UIFont systemFontOfSize:14];
    
    [(UIButton *)item.control addTarget:self
                                 action:@selector(changeBindSetting:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self updateBindState];
}

- (void)updateBindState {
    SNShareSettingTableItem *item = (SNShareSettingTableItem *)_item;
    
    NSString *strBtnNomal = nil;
    NSString *strBtnPress = nil;
    NSString *strTitleColorNormal = nil;
    NSString *strTitleColorPress = nil;
    if ([item.shareSettingItem.shareListItem.status intValue] == 0) {
        [(UIButton *)item.control setTitle:@"解绑" forState:UIControlStateNormal];
        _userName.text = item.shareSettingItem.shareListItem.userName;
        strBtnNomal = @"weibo_unbind.png";
        strBtnPress = @"weibo_unbind_p.png";
        strTitleColorNormal = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeiboSettingUnbindTitleColor];
        strTitleColorPress = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeiboSettingUnbindTitlePressColor];
	} else {
        [(UIButton *)item.control setTitle:@"绑定" forState:UIControlStateNormal];
        _userName.text = @"";
        strBtnNomal = @"weibo_bind.png";
        strBtnPress = @"weibo_bind_p.png";
        strTitleColorNormal = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeiboSettingBindTitleColor];
        strTitleColorPress = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kWeiboSettingBindTitlePressColor];
    }
    
    [(UIButton *)item.control setBackgroundImage:[UIImage imageNamed:strBtnNomal] forState:UIControlStateNormal];
    [(UIButton *)item.control setBackgroundImage:[UIImage imageNamed:strBtnPress] forState:UIControlStateHighlighted];
    [(UIButton *)item.control setTitleColor:[UIColor colorFromString:strTitleColorNormal] forState:UIControlStateNormal];
    [(UIButton *)item.control setTitleColor:[UIColor  colorFromString:strTitleColorPress] forState:UIControlStateHighlighted];
}

- (void)layoutSubviews {
	[super layoutSubviews];
    self.control.frame = CGRectMake(kAppScreenWidth - 79,
                                    (106 / 2 - BUTTON_SIZE_HEIGHT) / 2,
                                    BUTTON_SIZE_WIDTH,
                                    BUTTON_SIZE_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    self.imageView.left = 15;
}

-(void)changeBindSetting:(id)sender {
	SNShareSettingTableItem *item = (SNShareSettingTableItem *)_item;
    if ([item.shareSettingItem.shareListItem.status intValue] == 0) {
        [[SNShareManager defaultManager] cancelAuthrizeByAppId:item.shareSettingItem.shareListItem.appID delegate:item.controller];
    } else {
        [[SNShareManager defaultManager] authrizeByAppId:item.shareSettingItem.shareListItem.appID loginType:SNShareManagerAuthLoginTypeBind delegate:item.controller];
    }
}

@end
