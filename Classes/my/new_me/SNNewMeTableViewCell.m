//
//  SNNewMeTableViewCell.m
//  sohunews
//
//  Created by cuiliangliang on 16/8/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNewMeTableViewCell.h"
#import "SNNewsReport.h"
#import <JsKitFramework/JsKitStorage.h>
#import <JsKitFramework/JsKitStorageManager.h>
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNUserManager.h"
#import "SNImageView.h"

#define kUnReadImageViewWidth       (12/2)
#define kActiveTipsImageViewWidth   (46/2)

@interface SNNewMeTableViewCell ()
@property(nonatomic,strong)UIImageView  *iconImageView;
@property(nonatomic,strong)UIImageView  *arrowsImageView;
@property(nonatomic,strong)UILabel      *titleLable;
@property(nonatomic,strong)UIView       *line;
@property(nonatomic,strong)UISwitch     *nightSwitch;
@property(nonatomic,strong)NSDictionary *tmpData;
@property(nonatomic,strong)UIImageView  *unReadImageView;
@property(nonatomic,strong)UILabel      *activityTitleLable;
@property(nonatomic,strong)SNImageView  *activeTipsImageView;

@end

@implementation SNNewMeTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.showSlectedBg = YES;
        [self initUI];
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

-(void)initUI{
    [SNNotificationManager addObserver:self selector:@selector(unReadCountIsShow:) name:kUnReadCountIsShowNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(unReadFbReply:) name:kUnReadFbReplyNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(unActiveTipsClear) name:kUnActiveTipsClearNotification object:nil];

    _iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconImageView];
    _arrowsImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_arrowsImageView];
    _line= [[UIView alloc] init];
    _line.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
    [self.contentView addSubview:_line];
    _titleLable = [[UILabel alloc] init];
    _titleLable.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    //5.9.3 wangchuanwen update
    //_titleLable.textColor  = SNUICOLOR(kThemeText2Color);
    //换成abTest字体色 5.9.3 by wangchuanwen
    _titleLable.textColor  = SNUICOLOR(kThemeTextRIColor);
    _titleLable.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLable];
    _nightSwitch = [[UISwitch alloc] init];
    _nightSwitch.hidden = YES;
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault]) {
        _nightSwitch.on = NO;
    }else{
        _nightSwitch.on = YES;
    }
    [_nightSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_nightSwitch];
    
    _activeTipsImageView = [[SNImageView alloc] init];
    _activeTipsImageView.layer.masksToBounds = YES;
    _activeTipsImageView.layer.cornerRadius = kActiveTipsImageViewWidth/2;
    [self.contentView addSubview:_activeTipsImageView];
    
    _activityTitleLable = [[UILabel alloc] init];
    _activityTitleLable.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    _activityTitleLable.textColor = SNUICOLOR(kThemeText3Color);
    _activityTitleLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_activityTitleLable];
    
    if (!_unReadImageView) {
        _unReadImageView = [[UIImageView alloc] init];
    }
    _unReadImageView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    _unReadImageView.hidden = YES;
    [self.contentView addSubview:_unReadImageView];
}

-(void)switchAction:(id)sender
{
    [SNNewsReport reportADotGif:@"act=cc&fun=85"];
    UISwitch *switchBtin = (UISwitch*)sender;
    if (switchBtin.isOn) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeNight];
            JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
            [jsKitStorage setItem:[NSNumber numberWithBool:YES] forKey:@"settings_nightMode"];
            
            [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"1"];
            [DKNightVersionManager nightFalling];
            
            //TODO动态换皮肤更新频道列表？
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:@(switchBtin.isOn)];
        });
        
        NSNumber *switche = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsThemeNightSwitch];
        BOOL switchValue = NO;
        if (switche == nil) {
            switchValue = YES;//默认开关打开
        }
        else{
            switchValue = [switche boolValue];
        }
        if (switchValue) {
            //获取自动关闭夜间模式时间戳 (业务规定早上7点)
            NSDate *date = [SNUtility getSettingValidTime:7];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewsThemeNightValidTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[SNThemeManager sharedThemeManager] launchCurrentTheme:kThemeDefault];
            
            JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
            [jsKitStorage setItem:[NSNumber numberWithBool:NO] forKey:@"settings_nightMode"];
            
            [SNUtility sendSettingModeType:SNUserSettingDayMode mode:@"0"];
            [DKNightVersionManager dawnComing];
            
            //TODO动态换皮肤更新频道列表？PENG
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:@(switchBtin.isOn)];
        });
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    NSInteger iconHigh = 22;
    NSInteger iconX = 14;
    NSInteger arrowsHigh = 27/2;
    _iconImageView.frame = CGRectMake(iconX, (self.frame.size.height-iconHigh)/2, iconHigh, iconHigh);
    _arrowsImageView.frame = CGRectMake(self.frame.size.width-iconX-arrowsHigh, (self.frame.size.height-arrowsHigh)/2, arrowsHigh, arrowsHigh);
    _nightSwitch.frame = CGRectMake(self.frame.size.width-iconX-50, (self.frame.size.height-iconHigh)/2, 50, iconHigh);

    _line.frame = CGRectMake(14, (self.frame.size.height-1)/2, self.frame.size.width-14, 0.5);
    _titleLable.frame = CGRectMake(2*iconX+iconHigh, (self.frame.size.height-iconHigh)/2, 148, iconHigh);
    
    if ([_titleLable.text isEqualToString:@"活动"]) {
        _activeTipsImageView.frame = CGRectMake(_arrowsImageView.left-8-kUnReadImageViewWidth-kActiveTipsImageViewWidth, 0, kActiveTipsImageViewWidth, kActiveTipsImageViewWidth);
        _activeTipsImageView.centerY = _arrowsImageView.centerY;
        _unReadImageView.frame = CGRectMake(_arrowsImageView.left-8-kUnReadImageViewWidth, _activeTipsImageView.top-kUnReadImageViewWidth, kUnReadImageViewWidth, kUnReadImageViewWidth);

        if (_activeTipsImageView.hidden == NO) {
            CGSize activeTitleSize = [_activityTitleLable.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
            _activityTitleLable.frame = CGRectMake(_activeTipsImageView.left-activeTitleSize.width-30/2, 0, activeTitleSize.width, iconHigh);
            _activityTitleLable.centerY = _arrowsImageView.centerY;
        } else {
            CGSize activeTitleSize = [_activityTitleLable.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
            _activityTitleLable.frame = CGRectMake(_unReadImageView.left-activeTitleSize.width-30/2, 0, activeTitleSize.width, iconHigh);
            _activityTitleLable.centerY = _arrowsImageView.centerY;
        }
    } else {
        CGSize titleSize = [_titleLable.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
        _unReadImageView.frame = CGRectMake(2*14+24 + titleSize.width, 0, kUnReadImageViewWidth, kUnReadImageViewWidth);
        _unReadImageView.centerY = _titleLable.centerY;
    }
}

- (void)updateTheme{
    [super updateTheme];
    _unReadImageView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    _arrowsImageView.image = [UIImage imageNamed:@"icome_arrows_v5.png"];
    _activityTitleLable.textColor = SNUICOLOR(kThemeText3Color);
    _activeTipsImageView.alpha = themeImageAlphaValue();
}

-(void)loadDataToUpDateUI:(NSDictionary*)data{
    [self updateTheme];
    _line.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg1Color];
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault]) {
        _nightSwitch.on = NO;
        _nightSwitch.alpha = 1;
    }else{
        _nightSwitch.on = YES;
        _nightSwitch.alpha = 0.6;
    }
    _unReadImageView.hidden = YES;
    _activeTipsImageView.hidden = YES;
    _activityTitleLable.hidden = YES;
    if (data) {
        self.tmpData = data;
        if ([data[@"title"] isEqualToString:@"space"]) {
            _iconImageView.hidden = YES;
            _arrowsImageView.hidden = YES;
            _nightSwitch.hidden = YES;
            _titleLable.hidden = YES;
            _line.hidden = NO;
            _titleLable.text = data[@"title"];
        }
        else {
            _line.hidden = YES;
            _iconImageView.hidden = NO;
            _arrowsImageView.hidden = NO;
            _titleLable.hidden = NO;
            //5.9.3 wangchuanwen update
            //_titleLable.textColor  = SNUICOLOR(kThemeText2Color);
            //换成abTest字体色 5.9.3 by wangchuanwen
            _titleLable.textColor  = SNUICOLOR(kThemeTextRIColor);
            NSString *title = data[@"title"];
            NSString *icon = data[@"icon"];
            NSString *selector = data[@"selector"];
            NSString *openUrl = [data stringValueForKey:@"openUrl" defaultValue:@""];
            _titleLable.text = title;
            _iconImageView.image = [UIImage imageNamed:icon];
            _arrowsImageView.image = [UIImage imageNamed:@"icome_arrows_v5.png"];
            if (selector && [selector isEqualToString:@"openNight"]) {
                _nightSwitch.hidden = NO;
                _arrowsImageView.hidden = YES;
            }else{
                _arrowsImageView.hidden = NO;
                _nightSwitch.hidden = YES;
            }
            
            if ([title isEqualToString:NSLocalizedString(@"Sohu Hao",@"")]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsRedDot]) {
                    _unReadImageView.hidden = NO;
                }
            }
            if ([title isEqualToString:@"退出登录"]) {
                _arrowsImageView.hidden = YES;
            }
            /// ================================
            if ([openUrl isEqualToString:@"application"]) { //  申请/管理公众号
                if (![SNUserManager isLogin]) { // 未登录状态显示申请搜狐号
                    _titleLable.text = SN_ApplicationSohu;
                    _iconImageView.image = [UIImage imageNamed:@"icome_sq_v5.png"];
                } else {
                    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:SN_ApplicationSohuPath];
                    if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *sohuDict = [dataDict dictionaryValueForKey:@"sohuHaoTab" defalutValue:nil];
                        NSInteger showType = [sohuDict intValueForKey:@"showType" defaultValue:3];
                        if (1 == showType) { // 显示管理
                            _titleLable.text = SN_ManageSohu;
                            _iconImageView.image = [UIImage imageNamed:@"icome_manage_v5.png"];
                        } else if (0 == showType) { // 显示申请
                            _titleLable.text = SN_ApplicationSohu;
                            _iconImageView.image = [UIImage imageNamed:@"icome_sq_v5.png"];
                        }
                    }
                }
            }
            /// =================================
            // 反馈有回复红点显示
            if ([title isEqualToString:@"意见反馈"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:kFbHaveReply]) {
                    
                    _unReadImageView.hidden = NO;
                }
            }
            if ([title isEqualToString:@"活动"]) {
                NSDictionary *activeTipsInfo = [[SNAppConfigManager sharedInstance] getActiveTipsInfo];
                if (activeTipsInfo) {
                    NSString *text = [activeTipsInfo objectForKey:@"text"];
                    NSString *imageUrl = [activeTipsInfo objectForKey:@"imageUrl"];
                    BOOL status = [activeTipsInfo objectForKey:@"showRedPoint"];
                    if (imageUrl && imageUrl.length > 0) {
                        _activeTipsImageView.hidden = NO;
                        [_activeTipsImageView loadImageWithUrl:imageUrl defaultImage:nil];
                    }
                    if (text && text.length > 0) {
                        _activityTitleLable.hidden = NO;
                        _activityTitleLable.text = text;
                    }
                    if (status) {
                        _unReadImageView.hidden = NO;
                    }
                }
            }
        }
    }
}

- (void)unReadCountIsShow:(NSNotification *)notification
{
    NSNumber *numState = (NSNumber *)[notification object];
    if ([_titleLable.text isEqualToString:NSLocalizedString(@"Sohu Hao",@"")]) {
        if ([numState boolValue]) {
            _unReadImageView.hidden = NO;
        } else {
            _unReadImageView.hidden = YES;
        }
    }
}

- (void)unReadFbReply:(NSNotification *)noti {
    NSNumber *numState = (NSNumber *)[noti object];
    if ([_titleLable.text isEqualToString:@"意见反馈"]) {
        if ([numState boolValue]) {
            _unReadImageView.hidden = NO;
        } else {
            _unReadImageView.hidden = YES;
        }
    }
}

- (void)unActiveTipsClear
{
    if ([_titleLable.text isEqualToString:@"活动"]) {
        _unReadImageView.hidden = YES;
        _activityTitleLable.hidden = YES;
        _activeTipsImageView.hidden = YES;
        [[SNAppConfigManager sharedInstance] setActiveTipsInfo:nil];
    }
}

-(void)dealloc
{
    [SNNotificationManager removeObserver:self name:kUnReadCountIsShowNotification object:nil];
     [SNNotificationManager removeObserver:self name:kUnReadFbReplyNotification object:nil];
    [SNNotificationManager removeObserver:self name:kUnActiveTipsClearNotification object:nil];
}

@end
 
