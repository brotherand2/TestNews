//
//  SNStoryUtility.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/10.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sohunewsAppDelegate.h"

typedef NS_ENUM(NSInteger, StoryNetworkReachabilityStatus) {
    StoryNetworkReachabilityStatusUnknown          = -1,
    StoryNetworkReachabilityStatusNotReachable     = 0,
    StoryNetworkReachabilityStatusReachableViaWWAN = 1,
    StoryNetworkReachabilityStatusReachableViaWiFi = 2,
};

@interface SNStoryUtility : NSObject

+(sohunewsAppDelegate *)getAppDelegate;//获取主线delegate
+(StoryNetworkReachabilityStatus)currentReachabilityStatusForStory;//获取当前网络状态
+(NSString *)getStoryRequestUrlWithStr:(NSString *)url;//获取完整的URL
//正文分享
+(void)shareActionWith:(NSMutableDictionary *)shareDic;
+(NSMutableDictionary *)getDefaultParam;
+(BOOL)loginTipCloseState;//登录浮层关闭状态
+(void)loginTipCloseStateWithState:(BOOL)state;//登录浮层关闭状态

+(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;//pushViewController

+(void)popViewControllerAnimated:(BOOL)animated;//popViewController
+(void)openProtocolUrl:(NSString *)pushURLStr context:(NSDictionary *)context;//二代协议
+(void)setPanGestureWithState:(BOOL)state;//设置手势
+(BOOL)isLogin;//登录状态
+(NSString *)getCookie;//获取cookie
+(NSString *)getUserId;//获取userid
+(NSString *)getP1;//获取cid
+(NSString *)getPid;//获取pid
+(NSString *)getToken;//获取token
+(NSString *)getGid;//获取gid
+(NSString *)getU;//获取u

+(void)openUrlPath:(NSString *)urlPath applyQuery:(NSDictionary *)query applyAnimated:(BOOL)animated;//为兼容three20页面跳转处理

+(void)storyReportADotGif:(NSString *)string;//小说埋点
+(NSDictionary *)getReadPropertyWithStr:(NSString *)string;//小说操作栏属性

#pragma mark 小说操作栏颜色
+(UIColor *)getReadColor;
+(void)getNovelAchor;//获取小说锚点
@end
