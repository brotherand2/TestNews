//
//  SNUnifyShareServer.h
//  sohunews
//
//  Created by H on 15/7/6.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ShareTypeNews,
    ShareTypeVote,
    ShareTypeGroup,
    ShareTypeChannel,
    ShareTypeLive,
    ShareTypeVideo,
    ShareTypeActivityPage,
    ShareTypeWeb,
    ShareTypeSpecial,
    ShareTypeVideoTab,
    ShareTypeRedPacket,
    ShareTypeJoke,
    ShareTypeQianfan,
    ShareTypeUnknown,
    ShareTypePicTextRedPacket,//正文页组图红包
} ShareType;

typedef enum : NSUInteger {
    OnTypeDefault,
    OnTypeWeibo,
    OnTypeWXSession,
    OnTypeWXTimeline,
    OnTypeQQChat,
    OnTypeQQZone,
    OnTypeTaoBao,
    OnTypeTaoBaoMoments,
    OnTypeAll,
    OnTypeUnknown,
} ShareOnType;


@protocol SNUnifyShareServerDelegate <NSObject>

/**
 *v5.2.2 请求shareOn.go接口的delegate回调
 */
- (void)requestFromUnifyServerFinished:(NSDictionary *)responseData;

@end

@interface SNUnifyShareServer : NSObject

/**
 *v5.2.2 SNUnifyShareServerDelegate
 */
@property (nonatomic, weak) id <SNUnifyShareServerDelegate> delegate;
@property (nonatomic, strong)NSString *activitySubPageShare;
@property (nonatomic, strong)NSString *shareonInfo;

/**
 * shareOn.go接口单例
 */
+ (SNUnifyShareServer *)sharedInstance;


/**
 * 传入shareType、shareOnType、referId参数向shareon.go发起请求(referString例如普通新闻的格式为：@"newsId=12345")
 */
- (void)getShareInfoWithShareType:(ShareType)shareType onType:(ShareOnType)shareOnType referString:(NSString *)referString channelId:(NSString *)channelId redPacket:(NSString *)redPacket shareOn:(NSString *)shareOn;

/**
 * 同上 加一个参数 showType
 */
- (void)getShareInfoWithShareType:(ShareType)shareType onType:(ShareOnType)shareOnType referString:(NSString *)referString channelId:(NSString *)channelId redPacket:(NSString *)redPacket shareOn:(NSString *)shareOn showType:(NSString*)showType;

- (void)getShareInfoWithQianfan:(NSString*)type onType:(ShareOnType)shareOnType roomID:(NSString *)roomID;

@end
