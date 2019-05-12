//
//  SNUserUtility.m
//  sohunews
//
//  Created by weibin cheng on 14-2-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNUserUtility.h"
#import "SNUserManager.h"
#import "SNSubscribeCenterService.h"
#import "NSDictionaryExtend.h"
#import "SNWeatherCenter.h"
#import "SNVideosModel.h"
#import "SNVideoChannelManager.h"
#import "SNShareManager.h"
#import "SNH5NewsBindWeibo.h"
#import "SNCloudSaveService.h"
#import "SNSLib.h"
#import "SNMySDK.h"
#import "SNUserDataSynReuqest.h"
#import "SNNewsGrabAuthority.h"
#import "SNNewsPPLoginCookie.h"
#import "SNNewsPPLogin.h"

@implementation SNUserUtility
+(void)parseUserinfo:(SNUserinfoEx *)userInfo fromDictionary:(NSDictionary *)dic
{
    if(userInfo.pid.length == 0){
        userInfo.pid = [dic stringValueForKey:@"pid" defaultValue:nil];
        [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setObject:(userInfo.pid ?:@"-1") forKey:kTodaynewswidgetPid];
    }
    if(userInfo.token.length == 0)
        userInfo.token = [dic stringValueForKey:@"token" defaultValue:nil];
    if(userInfo.userName.length == 0)
        userInfo.userName = [dic stringValueForKey:@"userId" defaultValue:nil];
    
    // 昵称
    if ([dic stringValueForKey:@"nick" defaultValue:nil]) {
        userInfo.nickName = [dic stringValueForKey:@"nick" defaultValue:nil];
    } else if ([dic stringValueForKey:@"uniqueNick" defaultValue:nil]) {
        userInfo.nickName = [dic stringValueForKey:@"uniqueNick" defaultValue:nil];
    } else {
        userInfo.nickName = [dic stringValueForKey:@"nickName" defaultValue:nil];
    }
    // 头像
    if ([dic stringValueForKey:@"avator" defaultValue:nil]) {
        userInfo.headImageUrl = [dic stringValueForKey:@"avator" defaultValue:nil];
    } else if ([dic stringValueForKey:@"headUrl" defaultValue:nil]) {
        userInfo.headImageUrl = [dic stringValueForKey:@"headUrl" defaultValue:nil];
    }
    //3.3新增字段
    userInfo.gender = [dic stringValueForKey:@"gender" defaultValue:nil];
    userInfo.city = [dic stringValueForKey:@"city" defaultValue:nil];
    userInfo.province = [dic stringValueForKey:@"province" defaultValue:nil];
    userInfo.education = [dic stringValueForKey:@"education" defaultValue:nil];
    userInfo.tempHeader = nil;
    
    if(userInfo.province.length==0 && userInfo.city.length>0)
        userInfo.province = [[[SNWeatherCenter defaultCenter] cityDicInfoByCityName:userInfo.city] objectForKey:kCityObjKeyProvince];
    
    //3.5扩展字段
    userInfo.description = [dic stringValueForKey:@"description" defaultValue:nil];
    userInfo.actionCount = [dic stringValueForKey:@"actionCount" defaultValue:nil];
    userInfo.followingCount = [dic stringValueForKey:@"followingCount" defaultValue:nil];
    userInfo.followedCount = [dic stringValueForKey:@"followedCount" defaultValue:nil];
    userInfo.relation = [dic stringValueForKey:@"relation" defaultValue:nil];
    userInfo.userBindList = [dic stringValueForKey:@"userBindList" defaultValue:nil];
    userInfo.thirdPartyId = [dic stringValueForKey:@"thirdPartyId" defaultValue:nil];
    userInfo.thirdPartyName = [dic stringValueForKey:@"thirdPartyName" defaultValue:nil];
    userInfo.thirdPartyUrl = [dic stringValueForKey:@"thirdPartyUrl" defaultValue:nil];
    userInfo.icon = [dic stringValueForKey:@"icon" defaultValue:nil];
    
    if (userInfo.icon) {
        NSLog(@"userInfo.headImageUrl:::%@",userInfo.headImageUrl);
        if (!userInfo.headImageUrl || [userInfo.headImageUrl isEqualToString:@""]) {
            userInfo.headImageUrl = userInfo.icon;
        }
    }
    userInfo.backImg = [dic stringValueForKey:@"backImg" defaultValue:nil];
    
    userInfo.from = [dic stringValueForKey:@"from" defaultValue:nil];
    userInfo.isRegcms = [dic intValueForKey:@"isRegcms" defaultValue:0];
    userInfo.cmsRegUrl = [dic stringValueForKey:@"cmsRegUrl" defaultValue:nil];
    userInfo.signList = [dic objectForKey:@"signList"];
    userInfo.personMediaArray = [dic objectForKey:@"subInfoList"];
    userInfo.isShowManage = [dic intValueForKey:@"isShowManage" defaultValue:0];
    userInfo.audugcAuth = [dic intValueForKey:@"audugcAuth" defaultValue:0];
    
    //如果绑定手机没有 还有安全手机，如果都没有，那没招了 wangshun
    NSString *m = [dic stringValueForKey:@"bindMobile" defaultValue:nil];
    if (m.length == 0) {
        m = [dic stringValueForKey:@"secureMobile" defaultValue:nil];
    }
    userInfo.mobile = m;

    
    //这块跟外部调用写法有关，重构干掉 wangshun
    NSString* passport = [dic objectForKey:@"passport"];//如果外层有
    NSDictionary* userInfo_dic = [dic objectForKey:@"userInfo"];
    
    if ([userInfo_dic objectForKey:@"passport"] && ((NSString*)[userInfo_dic objectForKey:@"passport"]).length>0) {//如果内层有
        passport = [userInfo_dic objectForKey:@"passport"];
    }
    
    if (passport && passport.length>0) {//如果数据没有则不管
        SNDebugLog(@"wangshun passport:::::%@",passport);
        userInfo.passport = passport;
        
        if (userInfo.isRealName == NO) {
            if (userInfo.passport && userInfo.passport.length>0) {//如果当前有passport 实名认证
                userInfo.isRealName = YES;
            }
            else {
                userInfo.isRealName = NO;
            }
        }
    }
    
    userInfo.ppLoginFlag = @"0";

//    //NSString *isRealNameString = [dic stringValueForKey:@"isRealName" defaultValue:nil];
//    
////    if (isRealNameString.length == 0) {
////        userInfo.isRealName = YES;//容错处理，服务端未设置，默认为yes
////    }
//    else {
//        userInfo.isRealName = [isRealNameString boolValue];
//    }
    /*
    id infoLinks = [dic objectForKey:@"productList"];
    if([infoLinks isKindOfClass:[NSArray class]])
    {
        [userInfo._itemArray removeAllObjects];
        
        for(NSDictionary* dic in infoLinks)
        {
            SNUserItem* item = [[SNUserItem alloc] init];
            [userInfo._itemArray addObject:item];
            
            item._imageUrl = [dic objectForKey:@"imgUrl"];
            item._imageUrlhl = [dic objectForKey:@"clickImgUrl"];
            item._imageUrlNight = [dic objectForKey:@"blackImgUrl"];
            item._imageUrlNighthl = [dic objectForKey:@"clickBlackImgUrl"];
            item._name = [dic objectForKey:@"name"];
            item._link = [dic objectForKey:@"link"];
            [item release];
        }
    }*/
}

//用户名校验
+(BOOL)isValidateUsername:(NSString*)aUsername
{
    if(aUsername!=nil && [aUsername length]>0)
    {
        NSString* str = @"^[a-z][a-zA-Z0-9_]{3,15}$"; //字母开头,字母数字下划线 4-16位
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:0 error:nil];
        NSInteger numberOfMatches = [regex numberOfMatchesInString:aUsername options:0 range:NSMakeRange(0, [aUsername length])];
        
        str = @"^((?!(admin|master|abuse|contact|help|info|jobs|owner|sales|staff|sales|support|www)).)*$"; //不包含关键词
        regex = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger numberOfMatches2 = [regex numberOfMatchesInString:aUsername options:0 range:NSMakeRange(0, [aUsername length])];
        
        if(numberOfMatches>0 && numberOfMatches2>0)
            return YES;
    }
    
    //fail
    return NO;
}

+(BOOL)isMobileValidateTelNumber:(NSString*)aNumber
{
    if(aNumber!=nil && [aNumber length]>0)
    {
        /**
         * 手机号码
         * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         * 联通：130,131,132,152,155,156,185,186
         * 电信：133,1349,153,180,189
         */
        NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
        /**
         10         * 中国移动：China Mobile
         11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
         12         */
        NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
        /**
         15         * 中国联通：China Unicom
         16         * 130,131,132,152,155,156,185,186
         17         */
        NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
        /**
         20         * 中国电信：China Telecom
         21         * 133,1349,153,180,189
         22         */
        NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
        /**
         25         * 大陆地区固话及小灵通
         26         * 区号：010,020,021,022,023,024,025,027,028,029
         27         * 号码：七位或八位
         28         */
        // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
        
        NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
        NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
        NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
        NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
        
        if (([regextestmobile evaluateWithObject:aNumber] == YES) || ([regextestcm evaluateWithObject:aNumber] == YES)
            || ([regextestct evaluateWithObject:aNumber] == YES) || ([regextestcu evaluateWithObject:aNumber] == YES))
            return YES;
    }
    
    //fail
    return NO;
}

//密码校验
+(BOOL)isValidatePassword:(NSString*)aPassword
{
    /*
     if(aPassword!=nil && [aPassword length]>0)
     {
     NSString* str = @"[a-zA-Z0-9_]{6,16}$"; //字母数字下划线 6-16位
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:nil];
     NSInteger numberOfMatches = [regex numberOfMatchesInString:aPassword options:0 range:NSMakeRange(0, [aPassword length])];
     
     if(numberOfMatches>0)
     return YES;
     }*/
    
//    if(aPassword!=nil && [aPassword length]>=6 && [aPassword length]<=16)
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
    return YES;
}

//邮箱
+(BOOL)isValidateEmail:(NSString*)aEmail
{
    if(aEmail!=nil && [aEmail length]>0)
    {
        NSString *str = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger numberOfMatches = [regex numberOfMatchesInString:aEmail options:0 range:NSMakeRange(0, [aEmail length])];
        
        if(numberOfMatches>0)
            return YES;
    }
    
    //fail
    return NO;
}

+(void)handleUserLogin
{
    //[[SNSubscribeCenterService defaultService] loadMySubFromServer];
    [[SNSubscribeCenterService defaultService] performSelector:@selector(loadMySubFromServer) withObject:nil afterDelay:2.0];
    
    // 设置视频热播频道刷新标志位
    [SNVideosModel setNeedRefresh:YES
                        channelId:kVideoTimelineMainChannelId];
    
    // 刷新视频频道
//    [[SNVideoChannelManager sharedManager] loadVideoChannelsFromServer];
    
    // 清空分享平台的启用状态
    [SNShareList clearAppEnableMark];
    // 刷新一下分享列表 保证列表都是未绑定
    [[SNShareList shareInstance] refreshShareListForce];
    
    [SNNotificationManager postNotificationName:kUserDidLoginNotification object:nil userInfo:nil];
    
    // 触发服务端同步
    [SNCloudSaveService triggerCorpusSynCompletion:^(BOOL success) {
        SNDebugLog(@"%d",success);
        // 登录成功后重新同步收藏(pid下的收藏)
        [SNCloudSaveService synCloudFavoriteData];
    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 判断pid是否在白名单下
        [SNNewsGrabAuthority newsGrabAuthority];
    });
}

+(void)handleUserLogout
{
    [SNUtility deleteAllCookies]; // 退出登录后清掉所有cookie
    
    [SNNewsPPLoginCookie deleteCookie];
    
    // 退出后重新同步收藏(cid下的收藏)
    [SNCloudSaveService synCloudFavoriteData];
    
    [SNUserinfoEx clearUserinfoFromUserDefaults];
    [[SNUserinfoEx userinfoEx] resetUserinfo];
    [[SNSubscribeCenterService defaultService] loadMySubFromServer];
    
    // 设置视频热播频道刷新标志位
    [SNVideosModel setNeedRefresh:YES
                        channelId:kVideoTimelineMainChannelId];
    
//    // 刷新视频频道
//    [[SNVideoChannelManager sharedManager] loadVideoChannelsFromServer];
    // 注销之后
    // 清空分享平台的启用状态
    [SNShareList clearAppEnableMark];
    // 刷新一下分享列表 保证列表都是未绑定
    [[SNShareList shareInstance] refreshShareListForce];
    
    [SNNotificationManager postNotificationName:kUserDidLogoutNotification object:nil userInfo:nil];
    
    [SNH5NewsBindWeibo removeBindWeibo];//清除正文评论绑定微博状态
    

    // 退出登录后重新同步收藏(cid下的收藏)
    [SNCloudSaveService synCloudFavoriteData];
    
    // 清掉widget下的pid存储
    [[[NSUserDefaults alloc] initWithSuiteName:kTodaynewswidgetGroup] setObject:@"-1" forKey:kTodaynewswidgetPid];
}


+ (BOOL)openUserWithPassport:(NSString *)passport
                   spaceLink:(NSString *)spaceLink
                   linkStyle:(NSString *)linkStyle
                         pid:(NSString *)pid
                        push:(NSString *)push
                       refer:(NSDictionary *)referInfo {
#pragma mark - huangjing  - 新闻评论列表用户点击 跳转到我的SDK的profile页
    NSMutableDictionary *arg = [NSMutableDictionary dictionary];
    [arg setObject:pid?pid:@"" forKey:@"pid"];
    [arg setObject:passport ? passport : @"" forKey:@"profileUserId"];
    [arg setObject:kProtocolUserInfoProfile forKey:@"type"];
    [arg setObject:push forKey:@"fromPush"];
    if (referInfo) {
        [arg setValuesForKeysWithDictionary:referInfo];
    }

    [SNSLib pushToProfileViewControllerWithDictionary:arg];
    [[SNMySDK sharedInstance] updateAppTheme];

    return YES;
    
    
#pragma mark - end
}

@end
