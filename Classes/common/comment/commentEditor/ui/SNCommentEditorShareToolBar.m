//
//  SNCommentShareToolBar.m
//  sohunews
//
//  Created by jialei on 14-3-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorShareToolBar.h"
#import "SNCommentConfigs.h"
#import "SNCommentEditorRecordView.h"
#import "SNCommentEditorCheckIcon.h"
#import "SNShareList.h"
#import "SNUserManager.h"
#import "SNShareConfigs.h"

#import "SNH5NewsBindWeibo.h"


static NSString *const shareWeibo     = @"review_weibo";
//static NSString *const shareTencentWeibo = @"review_txweibo";
//static NSString *const shareRenRen       = @"review_renren";
//static NSString *const shareKaixin       = @"review_kaixin";


static NSString *const shareAppIdWeibo = @"1";
//static NSString *const shareAppIdTencentWeibo = @"2";
//static NSString *const shareAppIdRenRen = @"4";
//static NSString *const shareAppIdKaixin = @"5";

typedef NS_ENUM(NSInteger, SNCommentShareIconTag)
{
    SNCommentShareIconTagBase = 10
};


@interface SNCommentShareToolBar()<SNH5NewsBindWeiboDelegate>
{
    CGFloat _soruceIconStartX;
    
    __block NSString *_currentAppid;
}

@end

@implementation SNCommentShareToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, kAppScreenWidth, KSNCS_TOOLBAR_HEIGHT);
    
        //title
        NSString *title = @"同时分享到";
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:KSNCS_TOOLBAR_TITLE_FONT]];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.left = KSNCS_TOOLBAR_STARTPOSITION;
        titleLabel.top = KSNCS_TOOLBAR_TITLE_TOP;
        titleLabel.size = size;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = SNUICOLOR(kRollingNewsChannelNormalTextColor);
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:KSNCS_TOOLBAR_TITLE_FONT];

        [self addSubview:titleLabel];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.right + 66/2, KSNCS_TOOLBAR_TITLE_TOP, 34/2, 30.0/2)];
        iconView.centerY = KSNCS_TOOLBAR_HEIGHT / 2 + 1;
        [iconView setImage:[UIImage imageNamed:@"icopl_wb_v5.png"]];
        [self addSubview:iconView];
        
        _soruceIconStartX = titleLabel.right + 7;
        self.appIdDic = [NSMutableDictionary dictionary];
        
        //shareIcons
        [self createShareIcons];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(loginFinished:)
                                                     name:kSharelistDidChangedNotification
                                                   object:nil];
        
        self.showView = YES;
    }
    return self;
}
- (void)createShareIcons
{
//  self.itemKeys.count 写死的 就一个微博 wangshun
    for (int i = 0; i < self.itemKeys.count; i++) {
        ShareListItem *item = [self item:i];
        SNCommentEditorCheckIcon *checkIcon = [[SNCommentEditorCheckIcon alloc] initWithItem:item iconKey:self.itemKeys[i]];

        checkIcon.left = _soruceIconStartX;
        checkIcon.centerY = KSNCS_TOOLBAR_HEIGHT / 2;
        checkIcon.tag = SNCommentShareIconTagBase + [[self item:i].appID intValue];
        
        if ([SNUtility getSinaBindStatus] && [SNShareList isItemEnable:item]) {
            self.hasSelectedItem = YES;
        }
        
        __block typeof(self)wself = self;
        checkIcon.touchedChooseBlock = ^(NSString *key, BOOL selected) {
            NSInteger index = [self.itemKeys indexOfObject:key];
//            _currentAppid = [self item:index].appID;
            if (selected) {
                [wself.appIdDic setObject:[self item:index].appID forKey:key];
            }
            else {
                [wself.appIdDic removeObjectForKey:key];
            }
        };
        
        checkIcon.touchedLoginBlock = ^(NSString *key) {
            [SNNotificationManager postNotificationName:SNCECheckIconDidPressed object:nil];
            
            SNH5NewsBindWeibo* bindWeibo = [[SNH5NewsBindWeibo alloc] init];
            [bindWeibo bindWeiBo:self];
        };
        [self addSubview:checkIcon];
    }
}

#pragma mark - keyValue
- (NSArray *)itemKeys
{
    return @[shareWeibo/*, shareTencentWeibo, shareRenRen, shareKaixin*/];
}

- (NSArray *)appId
{
    return @[shareAppIdWeibo/*, shareAppIdTencentWeibo, shareAppIdRenRen, shareAppIdKaixin*/];
}

- (ShareListItem *)item:(NSInteger)index
{
    ShareListItem * item = [[SNShareList shareInstance] itemByAppId:self.appId[index]];
    if ([SNUtility getSinaBindStatus] && [SNShareList isItemEnable:item]) {
        [self.appIdDic setObject:self.appId[index] forKey:self.itemKeys[index]];
    }
    
    return item;
}

#pragma mark- privateMthod
- (NSString *)shareAppIdString
{
    NSString *appIdStr = nil;
    if (_appIdDic.count > 0) {
        NSArray *appIdArray = [_appIdDic allValues];
        appIdStr = [appIdArray componentsJoinedByString:@","];
    }
    return appIdStr;
}

- (void)loginFinished:(NSNotification *)notifacation
{
    NSString *restoreData = (NSString *)[notifacation object];
    if (!restoreData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SNShareList shareInstance] updateShareList];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SNNotificationManager postNotificationName:NotificationCommentShareLoginFinished object:nil];
                //wangshun share
                //通知相应的图标更新状态
                int tag = 1 + SNCommentShareIconTagBase;
                SNCommentEditorCheckIcon *checkIcon = (SNCommentEditorCheckIcon*)[self viewWithTag:tag];
                [checkIcon loginFinished];
            });
        });
    }
}

- (void)dealloc
{
    
}

#pragma mark - SNH5NewsBindWeiboDelegate

-(void)bindWeiboSuccess:(NSDictionary *)info{
    [self loginFinished:nil];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

#pragma mark - SNShareManagerDelegate
- (void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController {
}

- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager {
    [self loginFinished:nil];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidAuthSuccess:(SNShareManager *)manager {
    [self loginFinished:nil];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"绑定成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManager:(SNShareManager *)manager didAuthFailedWithError:(NSError *) error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法绑定" toUrl:nil mode:SNCenterToastModeWarning];
}

- (void)shareManagerDidCancelAuth:(SNShareManager *)manager {
}

- (void)shareManagerDidCancelBindingSuccess:(SNShareManager *)manager {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:kRelieveSinaSucceed toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)shareManagerDidCancelBindingFail:(SNShareManager *)manager {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂无法解除绑定" toUrl:nil mode:SNCenterToastModeWarning];
}

@end
