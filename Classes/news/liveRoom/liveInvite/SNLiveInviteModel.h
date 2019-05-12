//
//  SNLiveInviteModel.h
//  sohunews
//
//  Created by chenhong on 13-12-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! @brief 邀请状态枚举
 */
typedef enum {
    /*** 0-unknow */
    
    LIVE_INVITE_UNKNOWN = 0,
    /*** 1-邀请中 */
    
    LIVE_INVITING = 1,
    
    /** 2-邀请成功 */
    
    LIVE_INVITE_SUC,
    
    /** 3-邀请被拒 */
    
    LIVE_INVITE_DENIED,
    
    /** 4-邀请过期 */
    
    LIVE_INVITE_OVERDUE,
    
    /** 5-权限过期 */
    
    LIVE_AUTHORITY_OVERDUE,
    
    /** 6-收回主持权限 */
    
    LIVE_AUTHORITY_CANCELED,
    
    /** 7-未被邀请 */
    
    LIVE_NOT_BE_INVITED
    
}SNLiveInviteStatusEnum;

/*! @brief 邀请响应枚举
 */
typedef enum {
    /** 1-接受 */
    LIVE_INVITE_FEEDBACK_ACCEPT = 1,
    
    /** 2-拒绝 */
    LIVE_INVITE_FEEDBACK_DENY = 2,
    
}SNLiveInviteFeedbackEnum;

/*! @brief 邀请二代协议busi值
 */
typedef NS_ENUM(NSInteger, SNLiveInviteBusiEnum) {
    /** 0-unknown */
    LIVE_INVITE_BUSI_UNKNOWN = 0,
    
    /** 1-邀请 */
    LIVE_INVITE_BUSI_INVITING = 1,
    
    /** 2-后台绑定为嘉宾 */
    LIVE_INVITE_BUSI_SUCCESS = 2,
};

/*! @brief 邀请状态查询返回对象
 */
@interface SNLiveInviteStatusObj : NSObject

@property(nonatomic,copy)NSString *liveId;
@property(nonatomic,copy)NSString *passport;
@property(nonatomic,copy)NSString *showmsg;
@property(nonatomic,strong)NSNumber *inviteStatus;

- (id)initWithDict:(NSDictionary *)dict;

@end

/*! @brief 邀请查询代理
 */
@protocol SNLiveInviteModelDelegate <NSObject>

- (void)requestInviteStatusFinished:(SNLiveInviteStatusObj *)statusObj;
- (void)requestInviteStatusFailedWithError:(NSError *)error;

- (void)sendInviteFeedbackFinished:(SNLiveInviteStatusObj *)statusObj;
- (void)sendInviteFeedbackFailedWithError:(NSError *)error;

@end


/*! @brief 直播间邀请相关接口
 */
@interface SNLiveInviteModel : NSObject<TTURLRequestDelegate>

@property(nonatomic,assign)SNLiveInviteStatusEnum inviteStatus;
@property(nonatomic,weak)id<SNLiveInviteModelDelegate> delegate;
@property(nonatomic,strong)NSDictionary *userInfo;

//直播邀请状态查询
- (void)requestInviteStatusByLiveId:(NSString *)liveId passport:(NSString *)passport;

//直播邀请应答
- (void)sendInviteFeedback:(SNLiveInviteFeedbackEnum)feedback
                withLiveId:(NSString *)liveId
                  passport:(NSString *)passport;

@end
