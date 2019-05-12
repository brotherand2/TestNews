//
//  SNWeiboSettingTableCell.m
//  sohunews
//
//  Created by 李 雪 on 11-7-19.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingTableItem.h"
#import "SNWeiboSettingTableCell.h"
#import "SNWeiboSettingItem.h"
#import "UIColor+ColorUtils.h"
#import "SNShareManager.h"
#import "SNDBManager.h"

#define BUTTON_SIZE_WIDTH				(70.0)
#define BUTTON_SIZE_HEIGHT				(32.0)


@implementation SNWeiboSettingTableCell

- (void)setObject:(id)object {
	if (_item == object) {
		return;
	}
	
	[super setObject:object];

	SNWeiboSettingTableItem *item = (SNWeiboSettingTableItem*)object;
    self.imageView.image =  item.weiboSettingItem.imgIcon;
    
    if (!_userName) {
        _userName = [[UILabel alloc] initWithFrame:CGRectMake(130, (106/2 - 30) / 2, 100, 30)];
        _userName.font = [UIFont systemFontOfSize:13];
        _userName.lineBreakMode = NSLineBreakByTruncatingTail;
        _userName.backgroundColor = [UIColor clearColor];
        _userName.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        [self addSubview:_userName];
    }
    
    NSString *strBtnNomal = nil;
    NSString *strBtnPress = nil;
    NSString *strTitleColorNormal = nil;
    NSString *strTitleColorPress = nil;
    
    if ([item.weiboSettingItem.shareListItem.status intValue] == 0) {
        [(UIButton*)item.control setTitle:@"解绑" forState:UIControlStateNormal];
        _userName.text = item.weiboSettingItem.shareListItem.userName;
        strBtnNomal = @"weibo_unbind.png";
        strBtnPress = @"weibo_unbind_p.png";
        strTitleColorNormal = [NSString stringWithFormat:@"%@",kWeiboSettingUnbindTitleColor];
        strTitleColorPress = [NSString stringWithFormat:@"%@",kWeiboSettingUnbindTitlePressColor];
	}
	else {
        [(UIButton*)item.control setTitle:@"绑定" forState:UIControlStateNormal];
        _userName.text = @"";
        strBtnNomal = @"weibo_bind.png";
        strBtnPress = @"weibo_bind_p.png";
        strTitleColorNormal = [NSString stringWithFormat:@"%@",kWeiboSettingBindTitleColor];
        strTitleColorPress = [NSString stringWithFormat:@"%@",kWeiboSettingBindTitlePressColor];
    }
    
    
    [(UIButton*)item.control setBackgroundImage:[UIImage imageNamed:strBtnNomal] forState:UIControlStateNormal];
    [(UIButton*)item.control setBackgroundImage:[UIImage imageNamed:strBtnPress] forState:UIControlStateHighlighted];
    
    ((UIButton*)item.control).titleLabel.font = [UIFont systemFontOfSize:14];
    [(UIButton*)item.control setTitleColor:[UIColor colorFromString:strTitleColorNormal] forState:UIControlStateNormal];
    [(UIButton*)item.control setTitleColor:[UIColor  colorFromString:strTitleColorPress] forState:UIControlStateHighlighted];
    
    [(UIButton*)item.control addTarget:self 
								action:@selector(changeWeiBindSetting:) 
					  forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
	[super layoutSubviews];
    self.control.frame = CGRectMake(482/2,(106/2 - BUTTON_SIZE_HEIGHT)/2,BUTTON_SIZE_WIDTH,BUTTON_SIZE_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    self.imageView.left = 30/2;
}

-(void)changeWeiBindSetting:(id)sender
{
	SNWeiboSettingTableItem *item	= (SNWeiboSettingTableItem*)_item;
    if ([item.weiboSettingItem.shareListItem.status intValue] == 0) {
        [[SNShareManager defaultManager] cancelAuthrizeByAppId:item.weiboSettingItem.shareListItem.appID delegate:item.controller];
    }
    else {
//        [[SNShareManager defaultManager] authrizeByAppId:item.weiboSettingItem.shareListItem.appID delegate:item.controller];
        [[SNShareManager defaultManager] authrizeByAppId:item.weiboSettingItem.shareListItem.appID loginType:SNShareManagerAuthLoginTypeBind delegate:item.controller];
    }
//	if(!(item.weiboSettingItem.bBinded))
//	{
//		[[Weibo sharedWeiboInstance] bindToWeibo:item.weiboSettingItem.weiboPlatform delegate:(UIViewController<WeiboDelegate>*)item.controller];
//	}
//	else {
//		[[Weibo sharedWeiboInstance] unbindToWeibo:item.weiboSettingItem.weiboPlatform];
//		 item.weiboSettingItem.bBinded = NO;
//         [(UIButton*)item.control setTitle:@"绑定" forState:UIControlStateNormal];
//	}
}


@end
