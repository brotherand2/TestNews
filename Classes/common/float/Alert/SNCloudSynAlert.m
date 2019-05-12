//
//  SNCloudSynAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCloudSynAlert.h"
#import "SNNewAlertView.h"
#import "SNSyncDataRequest.h"
#import "SNSubscribeCenterService.h"

@interface SNCloudSynAlert()
@property (nonatomic, strong) SNNewAlertView *cloudSynAlert;
@end

@implementation SNCloudSynAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        self.alertViewType = SNAlertViewCloudSynType;
        [self setAlertViewData:content];
    }
    return self;
}

- (void)showAlertView {
    if (self.cloudSynAlert) {
        [self.cloudSynAlert show];
    } else {
        [self dismissAlertView];
    }
}

- (void)setAlertViewData:(id)content {
    
    SNNewAlertView *synchronousAlert = [[SNNewAlertView alloc] initWithTitle:nil
                                                                     message:kCloudSynchronousWords
                                                           cancelButtonTitle:kCancelCloudSynchronous
                                                            otherButtonTitle:kImmediatelyCloudSynchronous];
    self.cloudSynAlert = synchronousAlert;
    self.cloudSynAlert.alertViewType = SNAlertViewCloudSynType;
    __weak typeof(self)weakself = self;
    [synchronousAlert actionWithBlocksCancelButtonHandler:^{
        NSString *cidString = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
        [weakself getSynchronousInfoWithCID:cidString isSynchronous:NO];
        [SNNewsReport reportADotGif:@"_act=cc&page=&topage=&fun=46"];
        
    } otherButtonHandler:^{
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kCloudSynchronousStatus toUrl:nil mode:SNCenterToastModeOnlyText];
        NSString *cidString = [[NSUserDefaults standardUserDefaults] objectForKey:kCloudSynchronousCid];
        [weakself getSynchronousInfoWithCID:cidString isSynchronous:YES];
        [SNNewsReport reportADotGif:@"_act=cc&page=&topage=&fun=45"];
    }];
}

- (void)getSynchronousInfoWithCID:(NSString *)cidString isSynchronous:(BOOL)isSynchronous {
    
    [[[SNSyncDataRequest alloc] initWithDictionary:@{@"sourceCid":cidString}] send:^(SNBaseRequest *request, id responseObject) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCloudSynchronousCid];
        
        NSInteger status = [[responseObject objectForKey:@"status"] integerValue];
        if (status == 200 && isSynchronous) {
            //更新频道列表、设置、订阅列表
            [SNNotificationManager postNotificationName:kRollingChannelReloadNotification object:nil];
            
            [SNUtility sendSettingModeType:SNUserSettingGetMode mode:nil];
            [[SNSubscribeCenterService defaultService] loadMySubFromServer];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kCloudSynchronousSucceed toUrl:nil mode:SNCenterToastModeSuccess];
        }
        
    } failure:nil];
}

- (void)dealloc {
    self.cloudSynAlert = nil;
}

@end
