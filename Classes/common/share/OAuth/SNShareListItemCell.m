//
//  SNShareListItemCell.m
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShareListItemCell.h"
#import "SNModeSwitch.h"
#import "UIColor+ColorUtils.h"
#import "SNShareManager.h"
#import "CacheObjects.h"
#import "SNUserinfo.h"
#import "SNMoreSwitcher.h"
#import "SNUserManager.h"

@implementation SNShareListItemCell

@synthesize appIcon = _appIcon;
@synthesize appName = _appName;
//@synthesize appEnable = _appEnable;
@synthesize bindingButton = _bindingButton;
@synthesize shareItem = _shareItem;
@synthesize delegate = _delegate;
@synthesize needTopSepLine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        _appIcon = [[SNWebImageView alloc] initWithFrame:CGRectMake(10, 7, 95, 30)];
        _appIcon.backgroundColor = [UIColor clearColor];
        _appIcon.centerY = kSNShareListItemCellHeight / 2;
        [self addSubview:_appIcon];
        
        _appName = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 30)];
        _appName.backgroundColor = [UIColor clearColor];
        _appName.lineBreakMode = NSLineBreakByTruncatingTail;
        _appName.font = [UIFont systemFontOfSize:12];
        _appName.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        _appName.centerY = kSNShareListItemCellHeight / 2;
        [self addSubview:_appName];
        
//        _appEnable = [[SNModeSwitch alloc] init];
//        [_appEnable addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventTouchUpInside];
//        _appEnable.centerY = kSNShareListItemCellHeight / 2;
//        _appEnable.centerX = self.width - 35;
//        [self addSubview:_appEnable];
        
        self.width = kAppScreenWidth;
        
        _appSwitcher = [[SNMoreSwitcher alloc] initWithFrame:CGRectMake(self.width - kPushSettingSwitcherWidth - 8,
                                                                     kSNShareListItemCellHeight / 2 - kPushSettingSwitcherHeight / 2,
                                                                     kPushSettingSwitcherWidth,
                                                                     kPushSettingSwitcherHeight)];
//        _appSwitcher.centerY = kSNShareListItemCellHeight / 2;
//        _appSwitcher.centerX = self.width - 35;
        _appSwitcher.delegate = self;
        _appSwitcher.currentIndex = 1;
        [self addSubview:_appSwitcher];
        
        UIImage *btnImage = [UIImage imageNamed:@"share_list_bindBtn.png"];
        _bindingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 10 - btnImage.size.width,
                                                                    7,
                                                                    btnImage.size.width,
                                                                    btnImage.size.height)];
        [_bindingButton addTarget:self action:@selector(binding) forControlEvents:UIControlEventTouchUpInside];
        _bindingButton.centerY = kSNShareListItemCellHeight / 2;
        [_bindingButton setImage:btnImage forState:UIControlStateNormal];
        [self addSubview:_bindingButton];
        
        _overdueLabel = [[UILabel alloc] init];
        _overdueLabel.backgroundColor = [UIColor clearColor];
        _overdueLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _overdueLabel.textColor = SNUICOLOR(kThemeText4Color);
        _overdueLabel.text = @"已过期";
        [_overdueLabel sizeToFit];
        _overdueLabel.centerY = _bindingButton.centerY;
        _overdueLabel.right = _bindingButton.left - kOverdueRightDistance;
        [self addSubview:_overdueLabel];
    }
    return self;
}

- (void)dealloc {
    
     //(_overdueLabel);
    
    _delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _appName.frame = CGRectMake(110, (self.height - 30) / 2, 100, 30);
    _appName.centerY = kSNShareListItemCellHeight / 2;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.needTopSepLine)
        [UIView drawCellSeperateLine:CGRectMake(0, 0, rect.size.width, 1)];
    
    [UIView drawCellSeperateLine:rect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

- (void)setShareItem:(ShareListItem *)shareItem {
    _shareItem = shareItem;
    
    NSInteger statusNum = [_shareItem.status intValue];// 0：已绑定，1：未(或已取消)绑定(需再绑定)，2：已失效(需再绑定)
    isBinded = NO;
    if (statusNum == 0) {
        isBinded = YES;
//        _bindingButton.hidden = YES;
        [_bindingButton setImage:[UIImage imageNamed:@"share_list_unbindBtn.png"] forState:UIControlStateNormal];
        _overdueLabel.hidden = YES;
        _appSwitcher.hidden = YES;
    }
    else if (statusNum == 1) {
        isBinded = NO;
//        _bindingButton.hidden = NO;
        [_bindingButton setImage:[UIImage imageNamed:@"share_list_bindBtn.png"] forState:UIControlStateNormal];
        _overdueLabel.hidden = YES;
        _appSwitcher.hidden = YES;
    }
    else if (statusNum == 2) {
        isBinded = NO;
//        _bindingButton.hidden = NO;
        [_bindingButton setImage:[UIImage imageNamed:@"share_list_bindBtn.png"] forState:UIControlStateNormal];
        _overdueLabel.hidden = NO;
        _appSwitcher.hidden = YES;
    }
    
//    _bindingButton.hidden = isBinded;
//    _overdueLabel.hidden = isBinded;
    if (!isBinded) {
        NSString *bindingLabel = [NSString stringWithFormat:@"绑定%@", _shareItem.appName];
        _bindingButton.accessibilityLabel = bindingLabel;
    }
    if (isBinded) {
        //原来的开关按钮，现在不显示了，只要新浪微博绑定了就写死了是开着的
        int currentIndex = 1;//[SNShareList isItemEnable:_shareItem] ? 1 : 0;
        [_appSwitcher setCurrentIndex:currentIndex animated:NO];
        _appName.text = _shareItem.userName;
        _appName.accessibilityLabel = _shareItem.userName;
    }
    else {
        int currentIndex = 0;
        [_appSwitcher setCurrentIndex:currentIndex animated:NO];
        _appName.text = @"";
    }
    
    NSString *iconName = [SNShareList iconNameByItem:_shareItem];
    _appIcon.image = [UIImage imageNamed:iconName];
    _appIcon.accessibilityLabel = _shareItem.appName;
    if (!iconName) {
        [_appIcon loadUrlPath:([_shareItem.status intValue] == 0) ? _shareItem.appIconUrl : _shareItem.appGrayIconUrl];
    }
}

- (void)binding {
//    [[SNShareManager defaultManager] authrizeByAppId:_shareItem.appID delegate:_delegate];
    
    // main passport
    BOOL isLogin = [SNUserManager isLogin];
    
    // 增加登陆来源统计 by jojo
    if (!isLogin) {
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_SHARE referId:@"" referAct:SNReferActShare];
    }
    
    [SNNotificationManager postNotificationName:kShareUnbundlingSelectNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isBinded] forKey:kSinaBindStatus]];
    
    if (!isBinded) {
        [[SNShareManager defaultManager] authrizeByAppId:_shareItem.appID loginType:isLogin ? SNShareManagerAuthLoginTypeBind : SNShareManagerAuthLoginTypeLoginWithBind delegate:_delegate];
    }
}

//- (void)switchChanged {
//    _appSwitcher.on = !_appSwitcher.on;
//    [SNShareList saveItemStatusToUserDefaults:_shareItem enable:_appSwitcher.on];
//    [[SNShareManager defaultManager] updateShareList];
//}

#pragma -SNPushSwitcherDelegate
- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex {
//    [_appSwitcher setCurrentIndex:newIndex];
    BOOL isEnable = (newIndex == 0) ? NO :YES;
    [SNShareList saveItemStatusToUserDefaults:_shareItem enable:isEnable];
    [[SNShareManager defaultManager] updateShareList];
}


@end

