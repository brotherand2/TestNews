//
//  SNRollingSubscribeRecomCell.m
//  sohunews
//
//  Created by 赵青 on 15/12/2.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingSubscribeRecomCell.h"
#import "SNImageView.h"
#import "SNSubscribeCenterOperation.h"
#import "SNSubscribeCenterService.h"
#import "SNWaitingActivityView.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#import "SNSohuHaoModel.h"
#import "NSString+Utilities.h"
#import "UIFont+Theme.h"
#import "SNNewsLoginManager.h"

@interface SNRollingSubscribeRecomCell () {
    SNImageView *iconImageView;
    UILabel *titleLabel;
    UILabel *subPersonCountLabel;
    UIImageView *iconCoverImageView;
    UIButton *addFollowButton;
    SNWaitingActivityView *loadingView;
    SNSohuHao * _sohuHao;
}

@end

#define kSubscribeRecomCellHeight ((kAppScreenWidth > 375) ? 280 / 3 : 171 / 2)

#define kIconImageViewLeft ((kAppScreenWidth > 375) ? 54 / 3 : 28 / 2)
#define kIconImageViewTop ((kAppScreenWidth > 375) ? 48 / 3 : 28 / 2)
#define kIconImageViewWidth ((kAppScreenWidth > 375) ? 145 / 3 : 90 / 2)
#define kTitleLeft ((kAppScreenWidth > 375) ? 31 / 3 : 17 / 2)
#define kTitleTop ((kAppScreenWidth > 375) ? 67 / 3 : 39 / 2)
#define kTitleBottom ((kAppScreenWidth > 375) ? 42 / 3 : 20 / 2)

@implementation SNRollingSubscribeRecomCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kSubscribeRecomCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = YES;
        [self initContentView];
        [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
    }
    return self;
}

- (void)initContentView {
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
    UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    iconCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kIconImageViewLeft, kTitleTop, kIconImageViewWidth, kIconImageViewWidth)];
    iconCoverImageView.image = subIconBgImg;
    iconCoverImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.layer.masksToBounds = YES;
    iconCoverImageView.layer.cornerRadius = 3.0f;
    [self.contentView addSubview:iconCoverImageView];
    
    iconImageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 0, kIconImageViewWidth, kIconImageViewWidth)];
    iconImageView.ignorePictureMode = YES;
    iconImageView.alpha = themeImageAlphaValue();
    iconImageView.center = iconCoverImageView.center;
    iconImageView.layer.masksToBounds = YES;
    iconImageView.layer.cornerRadius = 3.0f;
    [self.contentView addSubview:iconImageView];
    
    addFollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFollowButton.backgroundColor = [UIColor clearColor];
    [addFollowButton setTitle:@" 关注" forState:UIControlStateNormal];
    [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_add_v5.png"] forState:UIControlStateNormal];
    [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_addpress_v5.png"] forState:UIControlStateHighlighted];
    [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
    addFollowButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    addFollowButton.frame = CGRectMake(kAppScreenWidth - kIconImageViewTop - 60 - kRecomFollowCatalogListViewWidth, 0, 60, kSubscribeRecomCellHeight);
    addFollowButton.right = kAppScreenWidth - kRecomFollowCatalogListViewWidth - 34/2.f;
    addFollowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [addFollowButton addTarget:self action:@selector(addFollowAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:addFollowButton];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right + kTitleLeft, kTitleTop, kAppScreenWidth - kIconImageViewLeft - iconImageView.width - kTitleLeft - kRecomFollowCatalogListViewWidth - 60 - 17, [UIFont fontSizeWithType:UIFontSizeTypeD] + 2)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText10Color];
    [self.contentView addSubview:titleLabel];

    subPersonCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right + kTitleLeft, titleLabel.bottom - 2 + kTitleBottom, kAppScreenWidth - kIconImageViewLeft - iconImageView.width - kTitleLeft - kRecomFollowCatalogListViewWidth - 60 - 17, kThemeFontSizeC + 1)];
    subPersonCountLabel.backgroundColor = [UIColor clearColor];
    subPersonCountLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    subPersonCountLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self.contentView addSubview:subPersonCountLabel];
    titleLabel.font = [self getRecomAccountsNameFont];
    CGSize size = [titleLabel.text textSizeWithFont:titleLabel.font];
    titleLabel.height = size.height + 2;
    subPersonCountLabel.font = [self getRecomAccountsSubNameFont];
    CGSize subSize = [subPersonCountLabel.text textSizeWithFont:subPersonCountLabel.font];
    subPersonCountLabel.height = subSize.height + 2;
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    if ([object isKindOfClass:[SNSohuHao class]]) {
        [self updateContentWithSohuHao:object];
    } else if([object isKindOfClass:[SNRollingSubscribeRecomItem class]]) {
        if (self.subscribeRecomItem != object) {
            self.subscribeRecomItem = object;
            self.subscribeRecomItem.delegate = self;
            self.subscribeRecomItem.selector = @selector(openSubscribe);
        }
        [self updateContentView];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) {
        return nil;
    }
    
    if ([self pointInside:point withEvent:event] == NO) {
        return nil;
    }
    
    int count = (int)self.contentView.subviews.count - 1;
    for (int i = count; i >= 0 ; i--) {
        UIView *view = self.contentView.subviews[i];
        if ([view isKindOfClass:[UIButton class]] && point.x > addFollowButton.frame.origin.x) {
            CGPoint p = [view convertPoint:point fromView:self.contentView];
            return [view hitTest:p withEvent:event];
        };
    }
    return self;
}

- (void)updateFontTheme {
    titleLabel.font = [self getRecomAccountsNameFont];
    CGSize size = [titleLabel.text textSizeWithFont:titleLabel.font];
    titleLabel.height = size.height + 2;
    subPersonCountLabel.font = [self getRecomAccountsSubNameFont];
    CGSize subSize = [subPersonCountLabel.text textSizeWithFont:subPersonCountLabel.font];
    subPersonCountLabel.height = subSize.height + 2;
}

- (void)updateContentWithSohuHao:(SNSohuHao *)sohuHao {
    _sohuHao = sohuHao;
    titleLabel.text = sohuHao.nickname;
    titleLabel.font = [self getRecomAccountsNameFont];
    CGSize size = [titleLabel.text textSizeWithFont:titleLabel.font];
    titleLabel.height = size.height + 2;
    iconImageView.ignorePictureMode = YES;
    [iconImageView loadImageWithUrl:sohuHao.avatar
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
    NSString * pvStr = [NSString chineseStringWithInt:sohuHao.pv];
    subPersonCountLabel.text = [NSString stringWithFormat:@"累计阅读%@", pvStr];
    subPersonCountLabel.font = [self getRecomAccountsSubNameFont];
    CGSize subSize = [subPersonCountLabel.text textSizeWithFont:subPersonCountLabel.font];
    subPersonCountLabel.height = subSize.height + 2;

    if (sohuHao.following) {
        [addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateHighlighted];
    } else {
        [addFollowButton setTitle:@" 关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_add_v5.png"] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_addpress_v5.png"] forState:UIControlStateHighlighted];
    }
}

- (void)updateContentView {
    titleLabel.text = self.subscribeRecomItem.subscribeObject.subName;
    titleLabel.font = [self getRecomAccountsNameFont];
    CGSize size = [titleLabel.text textSizeWithFont:titleLabel.font];
    titleLabel.height = size.height + 2;
    
    iconImageView.ignorePictureMode = YES;
    [iconImageView loadImageWithUrl:self.subscribeRecomItem.subscribeObject.subIcon
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
    subPersonCountLabel.text = [NSString stringWithFormat:@"%@人关注", [SNUtility statisticsDataChangeType:self.subscribeRecomItem.subscribeObject.subPersonCount]];
    subPersonCountLabel.font = [self getRecomAccountsSubNameFont];
    CGSize subSize = [subPersonCountLabel.text textSizeWithFont:subPersonCountLabel.font];
    subPersonCountLabel.height = subSize.height + 2;

    if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"1"]) {
        [addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateHighlighted];
    } else if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"2"]) {
        [addFollowButton setTitle:@" 关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_add_v5.png"] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_addpress_v5.png"] forState:UIControlStateHighlighted];
    }
}

- (void)updateTheme {
    [super updateTheme];
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
    UIImage *subIconBgImg = [[UIImage themeImageNamed:@"bgsquare_journal_v5.png"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    iconCoverImageView.image = subIconBgImg;
    iconImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.alpha = themeImageAlphaValue();
    iconCoverImageView.image = [UIImage imageNamed:@"icobooking_publication_v5.png"];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
    [iconImageView loadImageWithUrl:self.subscribeRecomItem.subscribeObject.subIcon
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
    subPersonCountLabel.textColor = SNUICOLOR(kThemeText4Color);
    if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"1"]) {
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
    } else if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"2"]) {
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_add_v5.png"] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_addpress_v5.png"] forState:UIControlStateHighlighted];
    }
}

- (void)openSubscribe {
    if (self.subscribeRecomItem.subscribeObject.link.length > 0) {
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subrecomm&_tp=pv&subid=%@",self.subscribeRecomItem.subscribeObject.subId]];
        NSMutableDictionary *referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
        
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Subscribe_MeMedia] forKey:kRefer];
        [SNUtility openProtocolUrl:self.subscribeRecomItem.subscribeObject.link context:referInfo];
    }
}

- (void)addFollowAction:(id)sender {
    if (![SNUserManager isLogin]) {//login
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSValue *method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method",[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111看看搜狐号里关注
            
        } Failed:nil];
        return ;
    } else {
        if (!loadingView) {
            loadingView = [[SNWaitingActivityView alloc] init];
            loadingView.center = CGPointMake(addFollowButton.center.x + 5.0, addFollowButton.center.y);
            [self insertSubview:loadingView aboveSubview:addFollowButton];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRecomSubClick];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *succMsg = [self.subscribeRecomItem.subscribeObject succSubMsg];
        NSString *failMsg = [self.subscribeRecomItem.subscribeObject failSubMsg];
        if (_sohuHao.subId.length > 0) {
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subbutton&_tp=pv&subid=%@&channelid=%@",_sohuHao.subId,_sohuHao.channelid]];
            [loadingView startAnimating];
            addFollowButton.hidden = YES;
            if (_sohuHao.following) {
                ///取消关注
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
                [[SNSubscribeCenterService defaultService] removeMySubToServerBySubId:_sohuHao.subId from:0];
            } else {
                ///添加关注
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
                [[SNSubscribeCenterService defaultService] addMySubToServerBySubId:_sohuHao.subId from:0];
            }
        } else if (self.subscribeRecomItem.subscribeObject) {
            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=subbutton&_tp=pv&subid=%@",self.subscribeRecomItem.subscribeObject.subId]];
            [loadingView startAnimating];
            addFollowButton.hidden = YES;
            if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"1"]) {
                SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRemoveMySubToServer request:nil refId:self.subscribeRecomItem.subscribeObject.subId];
                [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
                
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRemoveMySubToServer];
                
                [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:self.subscribeRecomItem.subscribeObject];
            } else if ([self.subscribeRecomItem.subscribeObject.isSubscribed isEqualToString:@"2"]) {
                SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:self.subscribeRecomItem.subscribeObject.subId];
                [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
                
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
                [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:self.subscribeRecomItem.subscribeObject];
            }
        }
    }
}

#pragma mark - SNSubscribeCenterServiceDelegate
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer) {
        [loadingView stopAnimating];
        // 订阅成功
        addFollowButton.hidden = NO;
        [addFollowButton setTitle:@"已关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color] forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateNormal];
        [addFollowButton setImage:nil forState:UIControlStateHighlighted];
        self.subscribeRecomItem.subscribeObject.isSubscribed = @"1";
        _sohuHao.following = YES;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kRecomSubClick];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        [loadingView stopAnimating];
        addFollowButton.hidden = NO;
        [addFollowButton setTitle:@" 关注" forState:UIControlStateNormal];
        [addFollowButton setTitleColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeGreen1Color] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_add_v5.png"] forState:UIControlStateNormal];
        [addFollowButton setImage:[UIImage themeImageNamed:@"icosubscription_addpress_v5.png"] forState:UIControlStateHighlighted];
        self.subscribeRecomItem.subscribeObject.isSubscribed = @"2";
        _sohuHao.following = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kRecomSubClick];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(subscribeFinished:)]) {
        [_subscribeDelegate subscribeFinished:YES];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        [loadingView stopAnimating];
        addFollowButton.hidden = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kRecomSubClick];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(subscribeFinished:)]) {
        [_subscribeDelegate subscribeFinished:NO];
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    if (dataSet.operation == SCServiceOperationTypeAddMySubToServer || dataSet.operation == SCServiceOperationTypeRemoveMySubToServer) {
        [loadingView stopAnimating];
        loadingView.hidden = YES;
        addFollowButton.hidden = NO;
    }
    if (_subscribeDelegate && [_subscribeDelegate respondsToSelector:@selector(subscribeFinished:)]) {
        [_subscribeDelegate subscribeFinished:NO];
    }
}

- (UIFont *)getRecomAccountsNameFont {
    UIFont *titleFont = nil;
    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:28 / 2.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:32 / 2.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:36 / 2.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:40 / 2.f];
                break;
            default:
                break;
        }
    } else {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:28 / 2.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:32 / 2.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:36 / 2.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:40 / 2.f];
                break;
            default:
                break;
        }
    }
    return titleFont;
}

- (UIFont *)getRecomAccountsSubNameFont {
    UIFont *titleFont = nil;
    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:22 / 2.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:26 / 2.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:30 / 2.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:34 / 2.f];
                break;
            default:
                break;
        }
    } else {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:22 / 2.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:26 / 2.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:30 / 2.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:34 / 2.f];
                break;
            default:
                break;
        }
    }
    return titleFont;
}

@end
