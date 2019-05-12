//
//  SNShareList.h
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppKey             @"5yEVuWht0G4Ux3Q6qR9P" // from server
#define kQQSSOLoginAppId                    (@"80")

typedef enum {
    ShareListNoCache = 0,
    ShareListReady,
    ShareListFail,
}ShareListState;

typedef enum {
    ShareAppLevelSina = 1,
    ShareAppLevelQQ,
    ShareAppLevelQzone,
    ShareAppLevelSohu,
    ShareAppLevelRenren,
    ShareAppLevelKaixin,
    ShareAppLevelNetease,
    ShareAppLevelEnd = 100
}ShareAppLevel;

@protocol SNShareListDelegate;
//@protocol ASIHTTPRequestDelegate;

@class ShareListItem;

@interface SNShareList : NSObject/*<ASIHTTPRequestDelegate>*/ {
    int _shareListState;
    NSArray *_shareList;
    id<SNShareListDelegate> __weak _delegate;
}

@property(nonatomic, readonly)int shareListState;
@property(nonatomic, readonly)NSArray *shareList;
@property(nonatomic, weak)id<SNShareListDelegate>delegate;

+ (SNShareList *)shareInstance;
+ (BOOL)shouldRefreshShareList;
+ (BOOL)couldItemShare:(ShareListItem *)item;
+ (BOOL)isItemEnable:(ShareListItem *)item;
+ (void)saveItemStatusToUserDefaults:(ShareListItem *)item enable:(BOOL)enable;

// 清空每个分享平台的开关状态 注销的时候应该清空一下 ，保证下次登录或者绑定之后 默认状态为打开的
+ (void)clearAppEnableMark;

+ (NSString *)iconNameByItem:(ShareListItem *)item;
+ (NSString *)appIdByAppName:(NSString *)appName;

- (void)refreshShareListForce;
- (void)refreshShareList:(BOOL)bCheckExpire;

- (void)restoreShareListData:(NSArray *)itemList;

- (ShareListItem *)itemByAppId:(NSString *)appId;
- (NSArray *)itemsCouldShare; // 返回可以分享的items数组
- (NSArray *)itemsBinded; // 返回所有已经绑定的items数组
- (void)updateShareList;

@end

@protocol SNShareListDelegate <NSObject>

@optional
- (void)refreshShareListSucc;
- (void)refreshShareListFail;
- (void)refreshShareListGetNoData;

@end
