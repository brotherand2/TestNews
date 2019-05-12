/*
 *  SNUtility.m
 *  sohunews
 *
 *  Created by zhu kuanxi on 4/20/11.
 *  Copyright 2011 sohu. All rights reserved.
 *
 */

#import "SNUtility.h"
#import "RegexKitLite.h"
#import <sys/time.h>
#import "SNDBManager.h"
#import "SNDatabase_SubscribeCenter.h"
#import "UIColor+ColorUtils.h"
#import "SNCommentEditorViewController.h"
#import "SNCommentManager.h"
#import "NSAttributedString+Attributes.h"
#import "SNRollingNewsTableItem.h"
#import "SNUserConsts.h"
#import "SNUserManager.h"
#import "SNCommentConfigs.h"
#import "SNClientRegister.h"
#import "SNSendCommentObject.h"
#import "SNPreference.h"
#import "UIDevice-Hardware.h"
#import "SNUserLocationManager.h"
#import "SNCorpusListRequest.h"
#import "SNThemeManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNRollingNewsViewController.h"
#import "NSJSONSerialization+String.h"
#import "SNShareConfigs.h"
#import "SNInterceptConfigManager.h"
#import "SNNewsReport.h"
#import "KeychainItemWrapper.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNAppConfigTabBar.h"
#import "SNLogManager.h"
#import "SNAppConfigTimeControl.h"
#import "SNAppConfigHttpsSwitch.h"
#import "SNCorpusNewsViewController.h"
#import "SNMySDK.h"
#import "SNSLib.h"
#import "UIFont+Theme.h"
#import "SNMyFavouriteManager.h"
//wangshun
#import <JsKitFramework/JsKitFramework.h>
#import "JSONKit.h"
#import "SNRedPacketManager.h"
#import "NSObject+YAJL.h"
#import "SNUserRedPacketView.h"
#import <SohuLiveSDK-News/SohuLiveSDK-News.h>
#import <SohuCoreFoundation/SCActionManager.h>
#import <CoreTelephony/CTCarrier.h>
#import "SNCorpusAlertObject.h"
#import <SafariServices/SafariServices.h>
#import "SNNewAlertView.h"
#import "SNAppConfigScheme.h"
#import "SNClearPushCountRequest.h"
#import "SNUgcPackRequest.h"
#import "SNIsBindAlipayRequest.h"
#import "SNWebViewManager.h"
#import "SNIsBindMobileRequest.h"
#import "SNStoryPageViewController.h"
#import "SNStoryCatelogController.h"
#import "SNStoryUtility.h"
#import "SNNetDiagReportRequest.h"
#import "SNNewsShareManager.h"
#import "SNUserPortraitPlayer.h"
#import "SNSSOSinaWrapper.h"
#import "SNOpenWayManager.h"
#import "SNStoryPage.h"
#import "SNCorpusList.h"
#import "SNH5NewsBindWeibo.h"
#include <CommonCrypto/CommonDigest.h>
#import "SNPasteBoardAlert.h"
#import "SNAlertStackManager.h"
#import "SNCloudSynRequest.h"
#import "SNSpecialActivity.h"
#import "SNNewsLoginManager.h"
#import "SNBackThirdAppView.h"
#import "COMPCompassManager.h"

#define kSNTLReadCircleVersion     (@"2.1")
#define kSystemVersion             ([[[UIDevice currentDevice] systemVersion] floatValue])
#define kIOS_9                      9.f

@interface SNUtility()<SKStoreProductViewControllerDelegate,SFSafariViewControllerDelegate>{
    SKStoreProductViewController *_sKStoreProductViewController;
}

@property (nonatomic, strong) NSArray *whiteList;
@property (nonatomic) NSTimeInterval lastChannelCallTime;
@property (nonatomic, strong) SNCorpusAlertObject *corpusAlertObjct;
@property (nonatomic, strong) SNNewsShareManager *shareManager;

@end

@implementation SNUtility

//渠道号
+ (int)marketID
{
    //真机Bundle文件无权限修改。方案调整：如果修改渠道号开关打开，读取设置里的渠道号，否则读取markd.id文件 wyy
    BOOL marketIdSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:@"Debug_marketIdSwitch"];
    if (marketIdSwitch == YES) {
        //开关打开，允许用户修改渠道号文件
        NSString *marketId = [[NSUserDefaults standardUserDefaults] objectForKey:@"Debug_marketId"];
        if (marketId == nil) {
            return [SNUtility getFileMarketID];
        }
        return [marketId intValue];
    }
    
    return [SNUtility getFileMarketID];
}

+ (int)getFileMarketID{
    NSError *marketIdFileError = nil;
    NSString *marketIdFilePath	= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"market.id"];
    NSString *marketIdStr = [NSString stringWithContentsOfFile:marketIdFilePath encoding:NSUTF8StringEncoding error:&marketIdFileError];
    
    int marketId = [marketIdStr intValue];
    
    return marketId;
}

#pragma string handle

+ (NSString *)getStr:(NSString *)srcStr fromStr:(NSString *)str {
    NSRange searchRange = [srcStr rangeOfString:str options:NSCaseInsensitiveSearch];
    NSString *resultStr = nil;
    if (NSNotFound != searchRange.location) {
        resultStr = [srcStr substringFromIndex:searchRange.location + searchRange.length];
    }
    return resultStr;
}

+ (NSString *)getStr:(NSString *)srcStr toStr:(NSString *)str {
    NSRange searchRange = [srcStr rangeOfString:str options:NSCaseInsensitiveSearch];
    NSString *resultStr = nil;
    if (NSNotFound != searchRange.location) {
        resultStr = [srcStr substringToIndex:searchRange.location];
    }
    return resultStr;
}

#pragma mark path
+ (NSString *)getDocumentPath {
    NSString *documentPath = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (0 < paths.count) {
        documentPath = [paths objectAtIndex:0];
    }
    return documentPath;
}

+ (NSString *)getImageNameByDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHMMSS"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *imageName = nil;
    if (dateStr.length > 0) {
        imageName = [NSString stringWithFormat:@"%@.png", dateStr];
    }
    
    return imageName;
}

#pragma get sharedInstance
+ (sohunewsAppDelegate *)getApplicationDelegate {
#ifndef SN_APP_EXTENSIONS
    return (sohunewsAppDelegate *)([UIApplication sharedApplication].delegate);;
#else
    return nil;
#endif
}


#pragma mark UUID
+ (NSString *)CreateUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *UUIDString = CFBridgingRelease(string);
    return UUIDString;
}

+ (CGRect)calculateFrameToFitScreenBySize:(CGSize)size defaultSize:(CGSize)defaultSize
{
    CGSize calculatSize = size;
    if (size.width <= 0 || size.height <= 0) {
        calculatSize = defaultSize;
    }
    
    CGFloat width, height;
    
    if (calculatSize.width / calculatSize.height > TTScreenBounds().size.width / TTScreenBounds().size.height) {
        width = TTScreenBounds().size.width;
        height = calculatSize.height/calculatSize.width * TTScreenBounds().size.width;
        
    } else {
        width = calculatSize.width/calculatSize.height * TTScreenBounds().size.height;
        height = TTScreenBounds().size.height;
    }
    
    
    CGFloat xd = width - TTScreenBounds().size.width;
    CGFloat yd = height - TTScreenBounds().size.height;
    
    return CGRectMake(-xd/2, -yd/2, width, height);
}

#pragma mark - Animation

+ (CATransition *)getAnimation:(NSString *)kCATransitionType kCATransitionSubType:(NSString *)kCATransitionSubType andDuration:(CFTimeInterval)duration {
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionType];
    [animation setSubtype:kCATransitionSubType];
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return animation;
}

+ (NSString *)strByAppendingParamsToUrl:(NSString *)url fromLink:(NSDictionary *)userData {
    // 添加打开article的link所带的所有字段
    NSString *ret = url;
    
    NSString *aLink = [userData stringValueForKey:kLink defaultValue:nil];
    if (aLink) {
        NSRange range = [aLink rangeOfString:@"://"];
        if (range.length > 0) {
            NSString *schema = [aLink substringToIndex:range.location + range.length];
            NSMutableDictionary *dict = [SNUtility parseProtocolUrl:aLink schema:schema];
            if ([url containsString:kNewsId]) {
                [dict removeObjectForKey:kNewsId];
            }
            if ([url containsString:kChannelId]) {
                [dict removeObjectForKey:kChannelId];
            }
            if ([url containsString:kTermId]) {
                [dict removeObjectForKey:kTermId];
            }
            
            if (dict.count > 0) {
                NSString *params = [dict toUrlString];
                ret = [url stringByAppendingString:params];
            }
        }
    }
    return ret;
}

+ (NSDictionary *)appendingParamsToUrl:(NSMutableDictionary *)params fromLink:(NSDictionary *)userData {
    NSString *aLink = [userData stringValueForKey:kLink defaultValue:nil];
    if (aLink) {
        NSRange range = [aLink rangeOfString:@"://"];
        if (range.length > 0) {
            NSString *schema = [aLink substringToIndex:range.location + range.length];
            NSMutableDictionary *dict = [SNUtility parseProtocolUrl:aLink schema:schema];
            
            if ([params.allKeys containsObject:kNewsId]) {
                [dict removeObjectForKey:kNewsId];
            }
            if ([params.allKeys containsObject:kChannelId]) {
                [dict removeObjectForKey:kChannelId];
            }
            if ([params.allKeys containsObject:kTermId]) {
                [dict removeObjectForKey:kTermId];
            }
            [params setValuesForKeysWithDictionary:dict];
        }
    }
    return params;
}

//解析push url数据
+ (NSMutableDictionary *)parseProtocolUrl:(NSString*)urlPath schema:(NSString *)schemaStr {
    if ([SNUtility isProtocolV2:urlPath]) {
        return [SNUtility parseURLParam:urlPath schema:schemaStr];
    } else {
        return [SNUtility parsePushUrlPath:urlPath schema:schemaStr];
    }
}

+ (NSDictionary *)getParemsInfoWithLink:(NSString *) link
{
    NSDictionary *paremsDic = nil;
    if ([link hasPrefix:kProtocolHTTP] || [link hasPrefix:kProtocolHTTPS]) {
        paremsDic = [SNUtility getParamsInfoWithUrl:link];
    }else {
        NSRange range = [link rangeOfString:@"://"];
        if (NSNotFound != range.location) {
            NSString *schema = [link substringToIndex:range.location + range.length];
            paremsDic = [SNUtility parseProtocolUrl:link schema:schema];
        }
    }
    return paremsDic;
}

+ (NSMutableDictionary *)parsePushUrlPath:(NSString*)pushUrlPath schema:(NSString *)schemaStr
{
    if (!pushUrlPath || [@"" isEqualToString:pushUrlPath]) {
        return nil;
    }
    
    if (!(schemaStr.length < pushUrlPath.length) || schemaStr.length == 0) {
        return nil;
    }
    
    NSString *pushUrlPathExcludeSchema = [pushUrlPath substringFromIndex:[[NSString stringWithString:schemaStr] length]];
    pushUrlPathExcludeSchema = [pushUrlPathExcludeSchema stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
    
    //v3.0.1开始是：paper://107_3191
    NSString *IDsSeparatedByUnderline = pushUrlPathExcludeSchema;
    NSMutableDictionary *dicResult = nil;
    if (IDsSeparatedByUnderline && ![@"" isEqualToString:IDsSeparatedByUnderline]) {
        if ([IDsSeparatedByUnderline rangeOfString:@"_"].location == NSNotFound) {
            dicResult = [NSMutableDictionary dictionary];
            
            // 有可能是paper://termId这种的
            if ([schemaStr isEqualToString:kProtocolPaper]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:@"termId"];
            }
            //  即时新闻频道 newsChannel://channelId
            else if ([schemaStr isEqualToString:kProtocolNewsChannel]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kChannelId];
            }
            // 微闻频道列表：weiboChannel://channelId
            else if ([schemaStr isEqualToString:kProtocolWeiboChannel]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kChannelId];
            }
            // 组图频道列表:：groupPicChannel://categoryId
            else if ([schemaStr isEqualToString:kProtocolPhotoChannel]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kCategoryId];
            }
            // 直播频道列表（可能是多个直播频道列表）:liveChannel://channelSubId
            else if ([schemaStr isEqualToString:kProtocolLiveChannel]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kChannelSubId];
            }
            // 数据流刊物：dataFlow://subId（打开数据流刊物）
            else if ([schemaStr isEqualToString:kProtocolDataFlow]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kSubId];
            }
            // 订阅：sub://subId  (打开订阅详情页)
            else if ([schemaStr isEqualToString:kProtocolSub]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kSubId];
            }
            // 直播：live://liveId   （打开具体一个直播）
            else if ([schemaStr isEqualToString:kProtocolLive]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kLiveIdKey];
            }
            // 微闻：weibo://rootId  （打开具体一个微闻）
            else if ([schemaStr isEqualToString:kProtocolWeibo]) {
                [dicResult setObject:IDsSeparatedByUnderline forKey:kWeiboId];
            }
        }
        else {
            NSArray *substrings = [IDsSeparatedByUnderline componentsSeparatedByString:@"_"];
            if (substrings.count >= 2) {
                dicResult = [NSMutableDictionary dictionary];
                if ([schemaStr isEqualToString:kProtocolNews] || [schemaStr isEqualToString:kProtocolPhoto] || [schemaStr isEqualToString:kProtocolVote] || [schemaStr isEqualToString:kProtocolJoke]) {
                    NSString *channelId = [substrings objectAtIndex:0];
                    NSString *newsId = [substrings objectAtIndex:1];
                    if (channelId && newsId) {
                        [dicResult setObject:channelId forKey:kChannelId];
                        //[dicResult setObject:channelId forKey:kTermId];
                        [dicResult setObject:newsId forKey:kNewsId];
                    }
                }
                else if ([schemaStr isEqualToString:kProtocolPaper]) {
                    NSString *subId = [substrings objectAtIndex:0];
                    NSString *termId = [substrings objectAtIndex:1];
                    if (subId && termId) {
                        [dicResult setObject:subId forKey:kSubId];
                        [dicResult setObject:termId forKey:kTermId];
                    }
                } else if ([schemaStr isEqualToString:kProtocolLive]) {
                    NSString *liveId = [substrings objectAtIndex:1];
                    NSString *liveType = [substrings objectAtIndex:0];
                    if (liveId && liveType) {
                        [dicResult setObject:liveId forKey:kLiveIdKey];
                        [dicResult setObject:liveType forKey:kLiveTypeKey];
                    }
                } else if ([schemaStr isEqualToString:kProtocolSpecial]) {
                    NSString *termId = [substrings objectAtIndex:1];
                    if (termId) {
                        [dicResult setObject:termId forKey:kSpecialNewsTermId];
                    }
                } else if ([schemaStr isEqualToString:kProtocolWeibo]) {
                    NSString *channelId = [substrings objectAtIndex:0];
                    NSString *weiboId = [substrings objectAtIndex:1];
                    if (channelId && weiboId) {
                        [dicResult setObject:channelId forKey:kChannelId];
                        [dicResult setObject:weiboId forKey:kWeiboId];
                    }
                }
                // 数据流刊物 dataFlow://subId_termId
                else if ([schemaStr isEqualToString:kProtocolDataFlow]) {
                    NSString *subId = [substrings objectAtIndex:0];
                    NSString *termId = [substrings objectAtIndex:1];
                    if (subId && termId) {
                        [dicResult setObject:subId forKey:kSubId];
                        [dicResult setObject:termId forKey:kTermId];
                    }
                }
                //  即时新闻频道 newsChannel://channelId
                else if ([schemaStr isEqualToString:kProtocolNewsChannel]) {
                    NSString *channelId = [substrings objectAtIndex:0];
                    NSString *subId = [substrings objectAtIndex:1];
                    if (channelId && subId) {
                        [dicResult setObject:channelId forKey:kChannelId];
                        [dicResult setObject:subId forKey:kSubId];
                    }
                }
                // 微闻频道列表：weiboChannel://channelId
                else if ([schemaStr isEqualToString:kProtocolWeiboChannel]) {
                    NSString *channelId = [substrings objectAtIndex:0];
                    NSString *subId = [substrings objectAtIndex:1];
                    if (channelId && subId) {
                        [dicResult setObject:channelId forKey:kChannelId];
                        [dicResult setObject:subId forKey:kSubId];
                    }
                }
                // 组图频道列表:：groupPicChannel://categoryId
                else if ([schemaStr isEqualToString:kProtocolPhotoChannel]) {
                    NSString *channelId = [substrings objectAtIndex:0];
                    NSString *subId = [substrings objectAtIndex:1];
                    if (channelId && subId) {
                        [dicResult setObject:channelId forKey:kCategoryId];
                        [dicResult setObject:subId forKey:kSubId];
                    }
                }
            }
        }
    }
    return dicResult;
}

// 解析二代协议链接
+ (NSMutableDictionary*)parseURLParam:(NSString*)link schema:(NSString *)schemaStr {
    if ([link length]==0) {
        SNDebugLog(@"parseNewsProtocol : Invalid newsUrlPath.");
        return nil;
    }
    if (!(schemaStr.length < link.length) || schemaStr.length == 0) {
        return nil;
    }
    NSString *urlPathExcludeSchema = [link substringFromIndex:[[NSString stringWithString:schemaStr] length]];
    //urlPathExcludeSchema = [urlPathExcludeSchema stringByReplacingOccurrencesOfString:@".xml" withString:@""];
    
    NSMutableDictionary *dicResult = [NSMutableDictionary dictionary];
    
    [dicResult setObject:link forKey:kOpenProtocolOriginalLink2];
    
    NSArray *substrings = [urlPathExcludeSchema componentsSeparatedByString:@"&"];
    for (int x=0; x<substrings.count; x++) {
        
        NSString *strPart = [substrings objectAtIndex:x];
        NSArray *partItem = [strPart componentsSeparatedByString:@"="];
        if (partItem.count>=2) {
            NSString *name = [partItem objectAtIndex:0];
            NSString *value = [partItem objectAtIndex:1];
            if (name&&value) {
                [dicResult setObject:value forKey:name];
            }else {
                SNDebugLog(@"warnning!not expect paramer.");
            }
        }
    }
    return dicResult;
}

+ (NSMutableDictionary *)parseLinkParams:(NSString *)link2 {
    
    if ([link2 length] > 0) {
        //link2 = [link2 stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
        
        /**
         * 如果push url格式是"news://......"
         * 3.0.1开始，还可以推送news://......这种类型的通知，用来打开及时新闻
         */
        if ((NSNotFound !=[link2 rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location)) {
            return [SNUtility parseURLParam:link2 schema:kProtocolNews];
        }
        /**
         * 如果push url格式是"paper://......"
         * 3.0版本客户端，只会推送paper://......这种类型的通知
         * 3.4 apiVersion=12添加dataFlow://
         */
        else if (NSNotFound !=[link2 rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location ||
                 NSNotFound !=[link2 rangeOfString:kProtocolDataFlow options:NSCaseInsensitiveSearch].location) {
            
            if (NSNotFound !=[link2 rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location) {
                return [SNUtility parseURLParam:link2 schema:kProtocolPaper];
            } else {
                return [SNUtility parseURLParam:link2 schema:kProtocolDataFlow];
            }
        }
        /*
         sub://subId=356
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolSub options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolSub];
        }
        /**
         * 如果push url格式是"photo://......"
         * 组图协议
         */
        else if ((NSNotFound !=[link2 rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location)) {
            return [SNUtility parseURLParam:link2 schema:kProtocolPhoto];
        }
        /**
         * 如果push url格式是"live://......"
         * 直播协议
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolLive];
        }
        /**
         * 如果push url格式是"special://0_newsId"
         * 专题协议
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolSpecial options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolSpecial];
        }
        /**
         * 如果push url格式是"feedback://0_feedbackId"
         * 意见反馈
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolFeedback options:NSCaseInsensitiveSearch].location) {
            
        }
        /**
         * 如果push url格式是"weibo://..."
         * 微闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolWeibo options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolWeibo];
        }
        
        /**
         * 如果push url格式是"vote://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolVote];
        }
        
        /**
         * 如果push url格式是"newsChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolNewsChannel options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolNewsChannel];
        }
        /**
         * 如果push url格式是"weiboChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolWeiboChannel options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolWeiboChannel];
        }
        /**
         * 如果push url格式是"groupPicChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolPhotoChannel options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolPhotoChannel];
        }
        
        /**
         * 如果push url格式是"liveChannel://..."
         * 投票新闻
         * eg. liveChannel://categoryId=1,2
         */
        // todo 目前直播频道还没有单独的接口通过id来访问
        else if (NSNotFound != [link2 rangeOfString:kProtocolLiveChannel options:NSCaseInsensitiveSearch].location) {
            // 这里服务器通过link给的参数
            return [SNUtility parseURLParam:link2 schema:kProtocolLiveChannel];
        }
        
        // 搜索：search://words=新闻&type=0
        else if (NSNotFound != [link2 rangeOfString:kProtocolSearch options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolSearch];
        }
        
        // 功能订阅：plugin://id=yiy
        else if (NSNotFound != [link2 rangeOfString:kProtocolPlugin options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolPlugin];
        }
        
        // 阅读圈 详细页 : socialShare://shareId=1358
        else if (NSNotFound != [link2 rangeOfString:kProtocolReadCircleDetail options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolReadCircleDetail];
        }
        
        // 用户个人中心profile页 : userInfo://pid=xxx
        else if (NSNotFound != [link2 rangeOfString:kProtocolUserInfoProfile options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolUserInfoProfile];
        }
        
        else if (NSNotFound != [link2 rangeOfString:kProtocolComment options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolComment];
        }
        // 视频 二代协议 "link2": "video://vid=89&mid=62&channelId="
        else if (NSNotFound != [link2 rangeOfString:kProtocolVideo options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolVideo];
        }
        //政企首页 二代协议:orgHome://subId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolOrgHome options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolOrgHome];
        }
        //政企栏目页 二代协议:orgColumn://subId=123&columnId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolOrgColumn options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolOrgColumn];
        }
        //二维码页面 二代协议：qrCode://subId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolQRCode options:NSCaseInsensitiveSearch].location) {
            return [SNUtility parseURLParam:link2 schema:kProtocolQRCode];
        }
        else if(NSNotFound != [link2 rangeOfString:kProtocolChannel options:NSCaseInsensitiveSearch].location){
            return [SNUtility parseURLParam:link2 schema:kProtocolChannel];
        }
        //如果push url格式是其它，如："http://......"  普通广告
        else {
            // do nothing
        }
    }
    
    return nil;
}

+ (SNCCPVPage)parseLinkPage:(NSString *)link2 {
    
    if ([link2 length] > 0) {
        //link2 = [link2 stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
        
        /**
         
         * 如果push url格式是"news://......"
         * 3.0.1开始，还可以推送news://......这种类型的通知，用来打开及时新闻
         */
        if ((NSNotFound !=[link2 rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location)) {
            return article_detail_txt;
        }
        /**
         * 如果push url格式是"paper://......"
         * 3.0版本客户端，只会推送paper://......这种类型的通知
         * 3.4 apiVersion=12添加dataFlow://
         */
        else if (NSNotFound !=[link2 rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location ||
                 NSNotFound !=[link2 rangeOfString:kProtocolDataFlow options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        /*
         sub://subId=356
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolSub options:NSCaseInsensitiveSearch].location) {
            return paper_detail;
        }
        /**
         * 如果push url格式是"photo://......"
         * 组图协议
         */
        else if ((NSNotFound !=[link2 rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location)) {
            return article_detail_pic;
        }
        /**
         * 如果push url格式是"live://......"
         * 直播协议
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            return live;
        }
        /**
         * 如果push url格式是"special://0_newsId"
         * 专题协议
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolSpecial options:NSCaseInsensitiveSearch].location) {
            return special;
        }
        /**
         * 如果push url格式是"feedback://0_feedbackId"
         * 意见反馈
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolFeedback options:NSCaseInsensitiveSearch].location) {
            return more_feedback;
        }
        /**
         * 如果push url格式是"weibo://..."
         * 微闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolWeibo options:NSCaseInsensitiveSearch].location) {
            return weiboDetail;
        }
        
        /**
         * 如果push url格式是"vote://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location) {
            return article_detail_txt;
        }
        
        /**
         * 如果push url格式是"newsChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolNewsChannel options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        /**
         * 如果push url格式是"weiboChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolWeiboChannel options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        /**
         * 如果push url格式是"groupPicChannel://..."
         * 投票新闻
         */
        else if (NSNotFound != [link2 rangeOfString:kProtocolPhotoChannel options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        
        /**
         * 如果push url格式是"liveChannel://..."
         * 投票新闻
         * eg. liveChannel://categoryId=1,2
         */
        // todo 目前直播频道还没有单独的接口通过id来访问
        else if (NSNotFound != [link2 rangeOfString:kProtocolLiveChannel options:NSCaseInsensitiveSearch].location) {
            // 这里服务器通过link给的参数
            return paper_main;
        }
        
        // 搜索：search://words=新闻&type=0
        else if (NSNotFound != [link2 rangeOfString:kProtocolSearch options:NSCaseInsensitiveSearch].location) {
            return search;
        }
        
        // 功能订阅：plugin://id=yiy
        else if (NSNotFound != [link2 rangeOfString:kProtocolPlugin options:NSCaseInsensitiveSearch].location) {
            return paper_yiy;
        }
        
        // 阅读圈 详细页 : socialShare://shareId=1358
        else if (NSNotFound != [link2 rangeOfString:kProtocolReadCircleDetail options:NSCaseInsensitiveSearch].location) {
            return circle_detail;
        }
        
        // 用户个人中心profile页 : userInfo://pid=xxx
        else if (NSNotFound != [link2 rangeOfString:kProtocolUserInfoProfile options:NSCaseInsensitiveSearch].location) {
            return more_user;
        }
        
        else if (NSNotFound != [link2 rangeOfString:kProtocolComment options:NSCaseInsensitiveSearch].location) {
            return comment_list;
        }
        // 视频 二代协议 "link2": "video://vid=89&mid=62&channelId="
        else if (NSNotFound != [link2 rangeOfString:kProtocolVideo options:NSCaseInsensitiveSearch].location) {
            return videoDetail;
        }
        //政企首页 二代协议:orgHome://subId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolOrgHome options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        //政企栏目页 二代协议:orgColumn://subId=123&columnId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolOrgColumn options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        //二维码页面 二代协议：qrCode://subId=123
        else if(NSNotFound != [link2 rangeOfString:kProtocolQRCode options:NSCaseInsensitiveSearch].location) {
            return paper_2dimensional;
        }
        //我的订阅 二代协议：mySubs://
        else if(NSNotFound != [link2 rangeOfString:kProtocolMySubs options:NSCaseInsensitiveSearch].location) {
            return myrsslist;
        }
        //媒体刊物 二代协议：videoMedia://
        else if(NSNotFound != [link2 rangeOfString:kProtocolVideoMidia options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        //媒体刊物 二代协议：videoPerson://
        else if(NSNotFound != [link2 rangeOfString:kProtocolVideoPerson options:NSCaseInsensitiveSearch].location) {
            return paper_main;
        }
        //如果push url格式是其它，如："http://......"  普通广告
        else {
            // do nothing
            return sohu_http_web;
        }
    }
    return -1;
}

#pragma mark -
#pragma mark SNRollingNewsTableItem

+ (NSMutableArray *)createRollingNewsListItems:(NSArray *)newsList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:newsList.count];
    for (SNRollingNews *news in newsList) {
        SNRollingNewsTableItem *tItem = [[SNRollingNewsTableItem alloc] init];
        tItem.news = news;
        tItem.isRecommend = NO;
        tItem.isSearchNews = NO;
        [tItem setItemNewsType];
        [tItem setItemCellTypeWithTemplate];
        [list addObject:tItem];
    }
    return list;
}

+ (NSMutableArray *)getNewsArrayWithChannelId:(NSString *) channelId from:(NSString *) from  newsInfoArray:(NSArray *) newsInfoArray
{
    NSMutableArray *newsArray = [NSMutableArray array];
    for (NSDictionary *resultItemDic in newsInfoArray) {
        @autoreleasepool {
            SNRollingNews *rollingNews = [self createNews:resultItemDic fromPush:NO];
            rollingNews.channelId = channelId;
            rollingNews.from = from;
            if (rollingNews && ![rollingNews shouldBeHiddenWith:NO]) {
                [newsArray addObject:rollingNews];
            }
        }
    }
    return newsArray;
}

+ (SNRollingNews *)createNews:(NSDictionary *)data fromPush:(BOOL)fromPush
{
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.newsId = [data stringValueForKey:kNewsId defaultValue:@""];
    news.newsType = [data stringValueForKey:kNewsType defaultValue:@""];
    news.time = [data stringValueForKey:kTime defaultValue:@""];
    news.title = [data stringValueForKey:kTitle defaultValue:@""];
    news.digNum = [data stringValueForKey:kDigNum defaultValue:@""];
    news.commentNum = [data stringValueForKey:kCommentNum defaultValue:@"0"];
    news.countShowText = [data stringValueForKey:kCountShowText defaultValue:@"0"];
    news.abstract = [data stringValueForKey:kDesc defaultValue:@""];
    news.link = [data objectForKey:kNewsLink2];
    news.picUrl = [data objectForKey:kListPic];
    news.listPicsNumber = [data stringValueForKey:kListPicsNumber defaultValue:@""];
    news.hasVideo = [data stringValueForKey:kIsHasTV defaultValue:@""];
    news.hasAudio = [data stringValueForKey:kIsHasAudio defaultValue:@""];
    news.hasVote = [data stringValueForKey:kIsHasVote defaultValue:@""];
    news.updateTime = [data stringValueForKey:kUpdateTime defaultValue:@""];
    news.recomDay = [data stringValueForKey:kRecomDay defaultValue:@""];
    news.recomNight = [data stringValueForKey:kRecomNight defaultValue:@""];
    news.media = [data stringValueForKey:kNewsMedia defaultValue:@""];
    news.starGrade = [data stringValueForKey:kStarGrade defaultValue:@"0"];
    news.subId = [data stringValueForKey:kNewsSubId defaultValue:@""];
    news.needLogin = [data stringValueForKey:kNeedLogin defaultValue:@""];
    news.isSubscribe = [data stringValueForKey:kIsSubscribe defaultValue:@"0"];
    news.templateType = [data stringValueForKey:kTemplateType defaultValue:@"1"];
    news.templateId = [data stringValueForKey:kTemplateId defaultValue:@""];
    news.playTime = [data stringValueForKey:kPlayTime defaultValue:@""];
    news.liveType = [data stringValueForKey:kLiveType defaultValue:@""];
    news.isFlash = [data stringValueForKey:kIsFlash defaultValue:@"0"];
    news.position = [data stringValueForKey:kPos defaultValue:@""];
    news.statsType = [data intValueForKey:kRollingNewsStatsType defaultValue:0];
    news.adType = [data stringValueForKey:kAdType defaultValue:@""];
    news.adAbPosition = [data intValueForKey:kAdAbPosition defaultValue:0];
    news.adPosition = [data intValueForKey:kAdPosition defaultValue:0];
    news.refreshCount = [data intValueForKey:kAdRefreshCount defaultValue:0];
    news.loadMoreCount = [data intValueForKey:kAdLoadMoreCount defaultValue:0];
    news.scope = [data stringValueForKey:kAdScope defaultValue:nil];
    news.appChannel = [data stringValueForKey:kAdAppChannel defaultValue:0];
    news.newsChannel = [data stringValueForKey:kAdNewsChannel defaultValue:0];
    news.isHasSponsorships = [data stringValueForKey:kIsHasSponsorships defaultValue:@""];
    news.iconText = [data objectForKey:kIconText];
    news.newsTypeText = [data objectForKey:kNewsTypeText];
    news.isPush = fromPush;
    
    if ([[data objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
        news.picUrls = [data objectForKey:kListPics];
        if ([news.picUrls count]) {
            NSString *imageUrl = [news.picUrls objectAtIndex:0];
            news.picUrl = imageUrl;
        }
    }
    
    //设置特殊模信息
    [news setDataStringWithDic:data];
    
    //设置冠名信息
    [news setSponsorshipsWithDic:[data objectForKey:kSponsorships]];
    
    return news;
}

+ (NSMutableArray *)getNewsItemsArrayWithArray:(NSArray *)newsArray
                                      fromPush:(BOOL)fromPush
{
    NSMutableArray *newsItems = [NSMutableArray array];
    for (NSDictionary *resultItemDic in newsArray) {
        @autoreleasepool {
            SNRollingNews *rollingNews = [self createNews:resultItemDic
                                                 fromPush:fromPush];
            if (rollingNews && ![rollingNews shouldBeHiddenWith:NO]) {
                [newsItems addObject:rollingNews];
            }
        }
    }
    
    NSMutableArray *allNewsItems = [self createRollingNewsListItems:newsItems];
    return allNewsItems;
}

- (void)readInfo_plist {
    if (!self.whiteList && (kSystemVersion >= kIOS_9)) {
        self.whiteList = [NSArray array];
        NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
        self.whiteList = [dic objectForKey:@"LSApplicationQueriesSchemes"];
    }
}

+ (BOOL)isWhiteListURL:(NSURL *)url{
    if (kSystemVersion < kIOS_9) {
        return [[UIApplication sharedApplication] canOpenURL:url];
    }
    NSArray * whiteList = [[SNUtility sharedUtility] whiteList];
    if (!whiteList) {
        [[SNUtility sharedUtility] readInfo_plist];
        whiteList = [[SNUtility sharedUtility] whiteList];
    }
    NSString * urlScheme = [url scheme];
    for (NSString * scheme in whiteList) {
        if ([scheme isEqualToString:urlScheme]) {
            return [[UIApplication sharedApplication] canOpenURL:url];
        }
    }
    return NO;
}

+ (BOOL)isSohuDomain:(NSString *)url {
    if ([url containsString:@"api/usercenter/redirect.go"]) {
        return NO;
    }
    BOOL containSNSDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_W options:NSCaseInsensitiveSearch].location);
    BOOL containProductMainDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_K options:NSCaseInsensitiveSearch].location);
    BOOL containSohunewsMagicIP = (NSNotFound != [url rangeOfString:SNLinks_Domain_SohunewsMagicIP options:NSCaseInsensitiveSearch].location);
    BOOL containProductDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_ProductDomain options:NSCaseInsensitiveSearch].location);
    BOOL containMPDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_Mp options:NSCaseInsensitiveSearch].location);
    BOOL containTVDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_Tv options:NSCaseInsensitiveSearch].location);
    BOOL containMDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_M options:NSCaseInsensitiveSearch].location);
    BOOL containStockDomain = (NSNotFound != [url rangeOfString:SNLinks_Domain_Stock options:NSCaseInsensitiveSearch].location);
    
    return containProductMainDomain || containSohunewsMagicIP || containProductDomain || containSNSDomain || containTVDomain || containMPDomain || containMDomain || containStockDomain;
}

#pragma mark - 统计需求

// 打开新闻统计
+ (void)checkOpenProtocolUrlShouldUploadNewsLog:(NSDictionary *)context userInfo:(NSDictionary *)userInfo {
    NSString *targetString = @"news";
    NSString *url = userInfo[@"url"] ? : userInfo[@"kOpenProtocolOriginalLink2"];
    NSString *fromString = @"";
    NSString *dataRefString = @"";
    NSString *msgid = [userInfo stringValueForKey:@"msgId" defaultValue:@""] ;
    
    if (url.length > 0) {
        if (NSNotFound != [url rangeOfString:@":"].location) {
            targetString = [[url componentsSeparatedByString:@":"] firstObject];
        }
    }
    
    if ([targetString isEqualToString:@"news"]) {
        dataRefString = [NSString stringWithFormat:@"&newsId=%@", [userInfo stringValueForKey:@"newsId" defaultValue:@""]];
    }
    
    else if ([targetString isEqualToString:@"live"]){
        dataRefString = [NSString stringWithFormat:@"&liveId=%@", [userInfo stringValueForKey:@"liveId" defaultValue:@""]];
    }
    
    else if ([targetString isEqualToString:@"subHome"]){
        targetString = @"term";
        dataRefString = [NSString stringWithFormat:@"&subId=%@&termId=%@", [userInfo stringValueForKey:@"subId" defaultValue:@""],[userInfo stringValueForKey:@"termId" defaultValue:@""]];
    }
    
    else if ([targetString isEqualToString:@"previewChannel"]){
        targetString = @"h5channel";
        dataRefString = [NSString stringWithFormat:@"&channelId=%@", [userInfo stringValueForKey:@"channelId" defaultValue:@""]];
    }
    
    // 3.7.2 增加push打开统计埋点
    if ([[context valueForKey:kNewsExpressType] intValue] == 1) {
        fromString = @"push";
    }
    // 3.7.2 增加搜索打开统计埋点
    else if ([[context valueForKey:kRefer] intValue] == REFER_SEARCH) {
        fromString = @"search";
    }
    
    NSString *paramString = [NSString stringWithFormat:kAppOpenAnalyzeUrl, targetString, fromString, msgid];
    paramString = [paramString stringByAppendingString:dataRefString];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

// 打开报纸统计
+ (void)checkOpenProtocolUrlShouldUploadTermLog:(NSDictionary *)context userInfo:(NSDictionary *)userInfo {
    NSString *targetString = @"term";
    NSString *fromString = @"";
    NSString *dataRefString = [NSString stringWithFormat:@"&termId=%@&subId=%@", [userInfo stringValueForKey:@"termId" defaultValue:@""], [userInfo stringValueForKey:@"subId" defaultValue:@""]];
    NSString *msgid = [userInfo stringValueForKey:@"msgId" defaultValue:@""] ;
    
    
    if ([[context valueForKey:kNewsExpressType] intValue] == 1) {
        fromString = @"push";
    }
    else if ([[context valueForKey:kRefer] intValue] == REFER_SEARCH) {
        fromString = @"search";
    }
    else if ([[context valueForKey:@"FromMySubList"] boolValue]) {
        fromString = @"subscribed";
    }
    
    NSString *paramString = [NSString stringWithFormat:kAppOpenAnalyzeUrl, targetString, fromString, msgid];
    paramString = [paramString stringByAppendingString:dataRefString];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

+ (BOOL)openProtocolUrlV1:(NSString *)pushURLStr context:(NSDictionary *)context {
    BOOL bRet = NO;
    if ([pushURLStr length] > 0) {
        pushURLStr = [pushURLStr stringByReplacingOccurrencesOfString:@".xml" withString:@""];//去掉.xml后缀
        
        TTURLAction *urlAction = nil;
        NSMutableDictionary *userInfo = nil;
        
        //不含参数的二代协议
        if ([pushURLStr hasPrefix:kProtocolStoryRechargeHistory] || [pushURLStr hasPrefix:kProtocolStoryRechargeCenter] || [pushURLStr hasPrefix:kProtocolFeedBackEdit] || [pushURLStr hasPrefix:kProtocolNewsTab] || [pushURLStr hasPrefix:kProtocolTelBind] || [pushURLStr hasPrefix:kProtocolOpenSysytemLocation] || [pushURLStr hasPrefix:kProtocolSohuVideo] || [pushURLStr hasPrefix:kProtocolReadHistory] || [pushURLStr hasPrefix:kProtocolLogin]) {
            //由于二代协议经过正则验证，需要添加参数
            pushURLStr = [pushURLStr stringByAppendingString:@"param="];
            [SNUtility openProtocolUrlV2:pushURLStr context:nil];
        }
        //Appstore
        else if ([SNAPI isItunes:pushURLStr]){
            [[SNUtility sharedUtility] showAppStoreInApp:[NSURL URLWithString:pushURLStr]];
        }
        // 千帆直播(qfsdk://action.cmd?action=1.0&partner=10051&roomid=520612&from=13&isHasSponsorships=1&position=14&page=1&templateType=39&newsType=65，协议中第一个参数为？，不能经过正则验证，是非二代协议)
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolSohuQFLive options:NSCaseInsensitiveSearch].location){
            pushURLStr  =  [NSString stringWithFormat:@"%@&refresh=1",pushURLStr];
            [SCActionManager handleActionWithURL:pushURLStr];
            
            //cc,pv上报
            SNUserTrack *curPage = [SNUserTrack trackWithPage:sohu_qfLive link2:pushURLStr];
            SNUserTrack *fromPage = [SNUserTrack trackWithPage:tab_news link2:nil];//用户轨迹，来自新闻Tab
            NSString *paramsString = [NSString stringWithFormat:@"_act=pv&page=%@&track=%@", [curPage toFormatString], [fromPage toFormatString]];
            [SNNewsReport reportADotGifWithTrack:paramsString];
            return YES;
        }
        // 千帆直播
        else if ([pushURLStr containsString:FixedUrl_QianFan] || [pushURLStr containsString:FixedUrl_NewQianFan]){
            NSArray *array = [pushURLStr componentsSeparatedByString:@"/"];
            if ([array count] > 0) {
                NSString *roomStr = [array lastObject];
                //千帆要求后面含有参数的，使用native打开
                NSArray *idArray = [roomStr componentsSeparatedByString:@"?"];
                NSString *roomID = nil;
                if ([idArray count] > 0) {
                    roomID = [idArray objectAtIndex:0];
                }
                if ([self isPureNum:roomID]) {
                    NSString *urlString = [NSString stringWithFormat:@"qfsdk://action.cmd?action=1.0&partner=10051&roomid=%@", roomID];
                    [SCActionManager handleActionWithURL:urlString];
                } else {
                    userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:[NSNumber numberWithInteger:NormalWebViewType] forKey:kUniversalWebViewType];
                    [userInfo setObject:pushURLStr forKey:@"link"];
                    [SNUtility openUniversalWebView:userInfo];
                    return YES;
                }
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoV2 options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldAddAnimationOnSpread:NO];
            SNTabBarController *vc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
            NSInteger showSpread = 0;
            if (vc.selectedIndex == 0) {
                showSpread = 1;
            }
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoV2];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            NSString *vid = [userInfo stringValueForKey:@"vid" defaultValue:@""];
            NSString *site = [userInfo stringValueForKey:@"site" defaultValue:@""];
            if (site.length == 0) {
                site = @"2";
            }
            NSString *url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=%@&more={\"sourcedata\":{\"channeled\":\"1300030006\",\"type\":2,\"newsNavAnimaition\":%d}}", vid, site, showSpread];
            [[ActionManager defaultManager] handleUrl:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            return YES;
        }
        //如果push url格式是其它，如："http://......"  普通广告
        else {
            userInfo = [NSMutableDictionary dictionary];
            if (![pushURLStr containsString:@"://"]) {
                pushURLStr = [pushURLStr URLDecodedString];
            }
            
            if (pushURLStr && [SNAPI isWebURL:pushURLStr]) {
                NSString *queryString = [NSURL URLWithString:pushURLStr].query;
                [userInfo setValuesForKeysWithDictionary:[NSString getURLParas:queryString]];
                NSString *startFrom = @"startfrom=";
                if ([pushURLStr containsString:startFrom]) {
                    [userInfo setValue:[NSNumber numberWithInteger:SNOpenAppOriginFromUniversalLink] forKey:kOpenAppOriginFromKey];
                    [SNUtility staticOpenAppOriginFrom:userInfo];
                }
                
                UniversalWebViewType webViewType = NormalWebViewType;
                if (context) {
                    [userInfo setValuesForKeysWithDictionary:context];
                    if (![context objectForKey:kUniversalWebViewType]) {
                        if ([[context objectForKey:@"channelType"] isEqualToString:@"stockType"]) {
                            webViewType = StockMarketWebViewType;
                        }
                        else if ([pushURLStr containsString:@"termId="]) {
                            webViewType = SpecialWebViewType;
                        }
                        else if ([pushURLStr containsString:@"ad/view.go"]) {
                            webViewType = InterlligentOfferWebViewType;
                        }
                        else if ([pushURLStr containsString:@"hotquestion/modules"]) {
                            webViewType = FeedBackWebViewType;
                        }
                        else if ([[context objectForKey:kIsRedPacketNewsKey] boolValue] || [pushURLStr containsString:@"packId="]) {
                            webViewType = RedPacketWebViewType;
                        }
                        else if ([[context objectForKey:kFromRollingChannelWebKey] boolValue]) {
                            webViewType = StockChannelLoginWebViewType;
                        }
                        [userInfo setObject:[NSNumber numberWithInteger: webViewType] forKey:kUniversalWebViewType];
                    }
                }
                
                [userInfo setObject:pushURLStr forKey:@"link"];
                [SNUtility openUniversalWebView:userInfo];
                //设置返回第三方App信息
                [self setBackThirdAppInfo:userInfo];
                return YES;
            }
            
            if (context && [context objectForKey:@"onlySohuLink"]) {
                urlAction = nil;
            }
        }
        if (urlAction) {
            [[TTNavigator navigator] openURLAction:urlAction];
            bRet = YES;
            if ([SNAPI isWebURL:pushURLStr]) {
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
            }
        }
    }
    return bRet;
    
//        /**
//         * 如果push url格式是"news://......"
//         * 3.0.1开始，还可以推送news://......这种类型的通知，用来打开及时新闻
//         */
//        if ((NSNotFound !=[pushURLStr rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location)) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolNews];
//            if (userInfo && [userInfo count] > 0) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                [userInfo setObject:kNewsOnline forKey:kNewsMode];
//                if (![userInfo objectForKey:kChannelId]) {
//                    [userInfo setObject:@"0" forKey:kChannelId];
//                }
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5NewsWebView"] applyAnimated:YES] applyQuery:userInfo];
//                
//                // 打开新闻统计
//                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
//            }
//        }
//        /**
//         * 如果push url格式是"paper://......"
//         * 3.0版本客户端，只会推送paper://......这种类型的通知
//         * 3.4 apiVersion=12 dataFlow://
//         */
//        else if (NSNotFound !=[pushURLStr rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location ||
//                 NSNotFound !=[pushURLStr rangeOfString:kProtocolDataFlow options:NSCaseInsensitiveSearch].location) {
//            if (NSNotFound !=[pushURLStr rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location) {
//                userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolPaper];
//            } else {
//                userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolDataFlow];
//            }
//            
//            if (userInfo && [userInfo count] > 0 && ([userInfo objectForKey:@"termId"] || [userInfo objectForKey:@"subId"])) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                SubscribeHomeMySubscribePO *subItem = [[SubscribeHomeMySubscribePO alloc] init];
//                
//                // 如果是报纸推送，第一个参数是pubId，不是subId，需要替换一下
//                if ([context objectForKey:@"notification"]) {
//                    if (NSNotFound !=[pushURLStr rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location) {
//                        NSString *pubId = [userInfo objectForKey:@"subId"];
//                        if (pubId) {
//                            [userInfo setObject:pubId forKey:@"pubId"];
//                            [userInfo removeObjectForKey:@"subId"];
//                        }
//                    }
//                }
//                
//                subItem.pubIds = [userInfo objectForKey:@"pubId"];
//                subItem.subId = [userInfo objectForKey:@"subId"];
//                
//                SCSubscribeObject *subObj = nil;
//                if (subItem.subId) {
//                    subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subItem.subId];
//                } else if (subItem.pubIds) {
//                    subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectByPubId:subItem.pubIds];
//                }
//                
//                if (subObj) {
//                    subItem.subId = subObj.subId;
//                    subItem.subName = subObj.subName;
//                }
//                
//                SNDebugLog(@"INFO: sub/pub id is %@", subItem.subId);
//                subItem.lastTermLink = [NSString stringWithFormat:kUrlTermPaper, [userInfo objectForKey:@"termId"]];
//                [userInfo setObject:subItem forKey:@"subitem"];
//                [userInfo setObject:@"SUBLIST" forKey:@"linkType"];
//                
//                SNDebugLog(@"%@--%@, laset term link: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), subItem.lastTermLink);
//                //(subItem);
//                
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://paperBrowser"] applyAnimated:YES] applyQuery:userInfo];
//                
//                // 打开报纸统计
//                [self checkOpenProtocolUrlShouldUploadTermLog:context userInfo:userInfo];
//            }
//        }
//        /**
//         * 如果push url格式是"photo://......"
//         * 组图协议
//         */
//        else if ((NSNotFound !=[pushURLStr rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location)) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolPhoto];
//            if (userInfo && [userInfo count] > 0) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                [userInfo setObject:kNewsOnline forKey:kNewsMode];
//                [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS] forKey:kMyFavouriteRefer];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5NewsWebView"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        /**
//         * 如果push url格式是"live://......"
//         * 直播协议
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolLive];
//            if (userInfo && [userInfo count] > 0 && [userInfo objectForKey:kLiveIdKey]/* && [userInfo objectForKey:kLiveTypeKey]*/) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyAnimated:YES] applyQuery:userInfo];
//                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
//                
//            }
//        }
//        
//        /**
//         * 如果push url格式是"scan://..."
//         * 扫描二维码
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolScanQrCode options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolScanQrCode];
//            if ([pushURLStr containsString:@"closeLastPage=1"]) {
//                SNNavigationController *topNavigation = [TTNavigator navigator].topViewController.flipboardNavigationController;
//                [topNavigation popViewControllerAnimated:NO];
//            }
//            
//            if (userInfo && [userInfo objectForKey:kNewsId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                
//                if (![userInfo objectForKey:kChannelId]) {
//                    [userInfo setObject:@"0" forKey:kChannelId];
//                }
//            }
//            urlAction = [[[TTURLAction actionWithURLPath:@"tt://scanQRCode"] applyAnimated:YES] applyQuery:userInfo];
//        }
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryRechargeHistory options:NSCaseInsensitiveSearch].location) {//小说书币充值历史记录
//            [SNUtility shouldUseSpreadAnimation:NO];
//            if (userInfo) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://transactionHistory"] applyAnimated:YES] applyQuery:userInfo];
//            }else{
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://transactionHistory"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryRechargeCenter options:NSCaseInsensitiveSearch].location) {//小说书币充值
//            [SNUtility shouldUseSpreadAnimation:NO];
//            if (userInfo) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://voucherCenter"] applyAnimated:YES] applyQuery:userInfo];
//            }else{
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://voucherCenter"] applyAnimated:YES] applyQuery:userInfo];
//            }
//
//        }
//
//        //分享浮层
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolShare options:NSCaseInsensitiveSearch].location) {
//            //打开分享浮层页面
//            
//            NSMutableDictionary* dic = [SNUtility createShareData:pushURLStr Context:context];
//            [SNUtility callShare:dic];
//        }
//        
//        /**
//         * 如果push url格式是"coupon://back2url=..."
//         *
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolCoupon options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolCoupon];
//            if (userInfo) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                
//                NSString * url = nil;
//                
//                if ([pushURLStr containsString:@"back2url"]) {
//                    url = [[pushURLStr componentsSeparatedByString:@"coupon://back2url="] lastObject];
//                    [SNUtility openProtocolUrl:url context:context];
//                }
//            }
//        }
//        
//        
//        /**
//         * 如果push url格式是"special://0_newsId"
//         * 专题协议
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSpecial options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolSpecial];
//            if (userInfo && [userInfo count] > 0 && [userInfo objectForKey:kSpecialNewsTermId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                [userInfo setObject:[NSNumber numberWithInteger:SpecialWebViewType] forKey:kUniversalWebViewType];
//                [SNUtility openUniversalWebView:userInfo];
//                return YES;
//            }
//        }
//        /**
//         * 如果push url格式是"feedback://0_feedbackId"
//         * 意见反馈
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolFeedback options:NSCaseInsensitiveSearch].location) {
//            if (context) [userInfo setValuesForKeysWithDictionary:context];
//            urlAction = [[[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:YES] applyQuery:userInfo];
//        }
//        
//        /**
//         * 如果push url格式是"weibo://..."
//         * 微闻
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolWeibo options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolWeibo];
//            if (userInfo && [userInfo count] > 0 && [userInfo objectForKey:kWeiboId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                if (![userInfo objectForKey:kChannelId]) {
//                    [userInfo setObject:@"0" forKey:kChannelId];
//                }
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://weiboDetail"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        /**
//         * 如果push url格式是"vote://..."
//         * 投票新闻
//         */
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolVote];
//            if (userInfo && [userInfo objectForKey:kNewsId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                if (![userInfo objectForKey:kChannelId]) {
//                    [userInfo setObject:@"0" forKey:kChannelId];
//                }
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5NewsWebView"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        // 订阅：sub://subId  (打开订阅详情页)
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSub options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolSub];
//            if ([userInfo count] > 0 && [userInfo objectForKey:kSubId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        // 即时新闻频道：newsChannel://channelId
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolNewsChannel options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolNewsChannel];
//            if (userInfo && [userInfo objectForKey:kChannelId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://newsChannel"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        // 微闻频道列表：weiboChannel://channelId
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolWeiboChannel options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolWeiboChannel];
//            if (userInfo && [userInfo objectForKey:kChannelId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                [userInfo setObject:@(NewsChannelTypeWeiboHot) forKey:@"channelType"];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://newsChannel"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        // 组图频道列表:：groupPicChannel://categoryId
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolPhotoChannel options:NSCaseInsensitiveSearch].location) {
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolPhotoChannel];
//            if (userInfo && [userInfo objectForKey:kCategoryId]) {
//                if (context) [userInfo setValuesForKeysWithDictionary:context];
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://photosChannel"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        // 直播频道列表：（可能是多个直播频道列表）:liveChannel://channelSubId
//        // todo 目前直播频道还没有单独的接口通过id来访问
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolLiveChannel options:NSCaseInsensitiveSearch].location) {
//            // 这里服务器通过link给的参数
//            userInfo = [SNUtility parsePushUrlPath:pushURLStr schema:kProtocolLiveChannel];
//            if (context) [userInfo setValuesForKeysWithDictionary:context];
//            if (userInfo && ([userInfo objectForKey:kChannelSubId] || [userInfo objectForKey:kSubId])) {
//                urlAction = [[[TTURLAction actionWithURLPath:@"tt://livesChannel"] applyAnimated:YES] applyQuery:userInfo];
//            }
//        }
//        
//        //Appstore
//        else if ([SNAPI isItunes:pushURLStr]){
//            [[SNUtility sharedUtility] showAppStoreInApp:[NSURL URLWithString:pushURLStr]];
//        }
//        
//        // 千帆直播
//        else if(NSNotFound != [pushURLStr rangeOfString:kSohuQFLive options:NSCaseInsensitiveSearch].location){
//            pushURLStr  =  [NSString stringWithFormat:@"%@&refresh=1",pushURLStr];
//            [SCActionManager handleActionWithURL:pushURLStr];
//            
//            //cc,pv上报
//            SNUserTrack *curPage = [SNUserTrack trackWithPage:sohu_qfLive link2:pushURLStr];
//            SNUserTrack *fromPage = [SNUserTrack trackWithPage:tab_news link2:nil];//用户轨迹，来自新闻Tab
//            NSString *paramsString = [NSString stringWithFormat:@"_act=pv&page=%@&track=%@", [curPage toFormatString], [fromPage toFormatString]];
//            [SNNewsReport reportADotGifWithTrack:paramsString];
//        }
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolReadHistory options:NSCaseInsensitiveSearch].location || NSNotFound != [pushURLStr rangeOfString:kPushHistory options:NSCaseInsensitiveSearch].location) {
//            NSString *htmlString = nil;
//            if (NSNotFound != [pushURLStr rangeOfString:kProtocolReadHistory options:NSCaseInsensitiveSearch].location) {
//                htmlString = kUrlReadHistory;
//            }
//            else {
//                htmlString = kUrlPushHistory;
//            }
//            
//            NSString *actionURLString = nil;
//            SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
//            if ([themeManager.currentTheme isEqualToString:@"night"]) {
//                actionURLString = [SNUtility addParamModeToURL:htmlString];
//                actionURLString = [actionURLString stringByAppendingString:@"&platformId=5"];
//            }
//            else {
//                actionURLString = [NSString stringWithFormat:@"%@?platformId=5", htmlString];
//            }
//            actionURLString = [NSString stringWithFormat:@"%@&p1=%@", actionURLString, [SNUserManager getP1]];
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:actionURLString, kLink, [NSNumber numberWithInteger:ReadHistoryWebViewType], kUniversalWebViewType, nil];
//            [SNUtility openUniversalWebView:dic];
//            return YES;
//        }
//        else if ([pushURLStr containsString:FixedUrl_QianFan] || [pushURLStr containsString:FixedUrl_NewQianFan]){
//            NSArray *array = [pushURLStr componentsSeparatedByString:@"/"];
//            if ([array count] > 0) {
//                NSString *roomStr = [array lastObject];
//                //千帆要求后面含有参数的，使用native打开
//                NSArray *idArray = [roomStr componentsSeparatedByString:@"?"];
//                NSString *roomID = nil;
//                if ([idArray count] > 0) {
//                    roomID = [idArray objectAtIndex:0];
//                }
//                if ([self isPureNum:roomID]) {
//                    NSString *urlString = [NSString stringWithFormat:@"qfsdk://action.cmd?action=1.0&partner=10051&roomid=%@", roomID];
//                    [SCActionManager handleActionWithURL:urlString];
//                } else {
//                    userInfo = [NSMutableDictionary dictionary];
//                    [userInfo setObject:[NSNumber numberWithInteger:NormalWebViewType] forKey:kUniversalWebViewType];
//                    [userInfo setObject:pushURLStr forKey:@"link"];
//                    [SNUtility openUniversalWebView:userInfo];
//                    return YES;
//                }
//            }
//        }
//        //一代协议搜狐视频的跳转
//        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoV2 options:NSCaseInsensitiveSearch].location) {
//            [SNUtility shouldAddAnimationOnSpread:NO];
//            SNTabBarController *vc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
//            NSInteger showSpread = 0;
//            if (vc.selectedIndex == 0) {
//                showSpread = 1;
//            }
//            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoV2];
//            if (context) {
//                [userInfo setValuesForKeysWithDictionary:context];
//            }
//            
//            NSString *vid = [userInfo stringValueForKey:@"vid" defaultValue:@""];
//            NSString *site = [userInfo stringValueForKey:@"site" defaultValue:@""];
//            if (site.length == 0) {
//                site = @"2";
//            }
//            NSString *url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=%@&more={\"sourcedata\":{\"getad\":0,\"channeled\":\"1300030006\",\"type\":2,\"newsNavAnimaition\":%d}}", vid, site, showSpread];
//            [[ActionManager defaultManager] handleUrl:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        }
//        //如果push url格式是其它，如："http://......"  普通广告
//        else {
//            userInfo = [NSMutableDictionary dictionary];
//            if (![pushURLStr containsString:@"://"]) {
//                pushURLStr = [pushURLStr URLDecodedString];
//            }
//            
//            if (pushURLStr) {
//                if (context) {
//                    [userInfo setValuesForKeysWithDictionary:context];
//                }
//                if ([[context objectForKey:@"channelType"] isEqualToString:@"stockType"]) {
//                    [userInfo setObject:[context stringValueForKey:kStockCodeKey defaultValue:@""] forKey:kStockCodeKey];
//                    [userInfo setObject:[context stringValueForKey:kStockFromKey defaultValue:@"news"] forKey:kStockFromKey];
//                    [userInfo setObject:[NSNumber numberWithInteger:StockMarketWebViewType] forKey:kUniversalWebViewType];
//                }
//                else {
//                    if ([pushURLStr containsString:@"termId="]) {
//                        [userInfo setObject:[NSNumber numberWithInteger:SpecialWebViewType] forKey:kUniversalWebViewType];
//                    }
//                    else if ([pushURLStr containsString:@"ad/view.go"]) {
//                        [userInfo setObject:[NSNumber numberWithInteger:InterlligentOfferWebViewType] forKey:kUniversalWebViewType];
//                    }
//                    else if (![context objectForKey:kUniversalWebViewType]){
//                        if ([pushURLStr containsString:@"hotquestion/modules"]) {
//                            [userInfo setObject:[NSNumber numberWithInteger:FeedBackWebViewType] forKey:kUniversalWebViewType];
//                        } else {
//                            if ([[context objectForKey:kIsRedPacketNewsKey] boolValue] || [pushURLStr containsString:@"packId="]) {
//                                [userInfo setObject:[NSNumber numberWithInteger:RedPacketWebViewType] forKey:kUniversalWebViewType];
//                            }
//                            else if ([[context objectForKey:kFromRollingChannelWebKey] boolValue]) {
//                                [userInfo setObject:[NSNumber numberWithInteger: StockChannelLoginWebViewType] forKey:kUniversalWebViewType];
//                            }
//                            else {
//                                if (![context objectForKey:kUniversalWebViewType]) {
//                                    [userInfo setObject:[NSNumber numberWithInteger: NormalWebViewType] forKey:kUniversalWebViewType];
//                                }
//                            }
//                        }
//                    }
//                }
//                [userInfo setObject:pushURLStr forKey:@"link"];
//                [SNUtility openUniversalWebView:userInfo];
//                return YES;
//            }
//            
//            if (context && [context objectForKey:@"onlySohuLink"]) {
//                urlAction = nil;
//            }
//            
//#if (0) //lijian 用于ATS，如果苹果强制使用ATS，则可以打开，所有浏览器外联均用SFSafariViewController打开
//            if (nil != pushURLStr && [SNAPI isWebURL:pushURLStr]) {
//                SFSafariViewController *safariController = [[[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:pushURLStr]] autorelease];
//                safariController.delegate = [SNUtility sharedUtility];
//                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:safariController animated:YES completion:^{}];
//                return YES;
//            }
//#endif
//        }
        
//        if (urlAction) {
//            [[TTNavigator navigator] openURLAction:urlAction];
//            bRet = YES;
//            if ([SNAPI isWebURL:pushURLStr]) {
//                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
//            }
//        }
//    }
//    return bRet;
}

+ (BOOL)openProtocolUrlV2:(NSString *)pushURLStr {
    return [self openProtocolUrlV2:pushURLStr context:nil];
}

+ (BOOL)openProtocolUrlV2:(NSString *)pushURLStr context:(NSDictionary *)context {
    BOOL bRet = NO;
    if ([pushURLStr length] > 0) {
        TTURLAction *urlAction = nil;
        NSString *urlPath = nil;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        //普通正文
        if ((NSNotFound != [pushURLStr rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location)) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolNews];
            if ([userInfo count] > 0) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                if (![userInfo objectForKey:kChannelId]) {
                    [userInfo setObject:@"0" forKey:kChannelId];
                }
                urlPath = @"tt://h5NewsWebView";
                
                // 打开新闻统计
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
                CGFloat linkBottomTop = [[userInfo stringValueForKey:kH5LinkBottom defaultValue:@""] floatValue];
                [[NSUserDefaults standardUserDefaults] setDouble:linkBottomTop forKey:kRememberCellOriginYInScreen];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        //组图
        else if ((NSNotFound !=[pushURLStr rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location)) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolPhoto];
            if ([userInfo count] > 0) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS] forKey:kMyFavouriteRefer];                
                if ([userInfo objectForKey:kGid]) {
                    if (![userInfo objectForKey:kTermId]) {
                        [userInfo setObject:kDftSingleGalleryTermId forKey:kTermId];
                    }
                    [userInfo setObject:[userInfo objectForKey:kGid] forKey:kNewsId];
                }
                
                urlPath = @"tt://h5NewsWebView";
            }
        }
        //互动直播
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolLive options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolLive];
            if ([userInfo count] > 0 && [userInfo objectForKey:kLiveIdKey]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                urlPath = @"tt://live";
            }
            [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
        }
        //专题
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSpecial options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolSpecial];
            if ([userInfo count] > 0 && [userInfo objectForKey:kSpecialNewsTermId]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                [userInfo setObject:[NSNumber numberWithInteger:SpecialWebViewType] forKey:kUniversalWebViewType];
                [SNUtility openUniversalWebView:userInfo];
                [self staticOpenAppOriginFrom:userInfo];
                
                //设置返回第三方App信息
                [self setBackThirdAppInfo:userInfo];
                
                return YES;
            }
        }
        // 打开设置用户评论
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolFeedback options:NSCaseInsensitiveSearch].location) {
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            urlPath = @"tt://feedback";
        }
        // 投票新闻
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVote];
            if (userInfo && [userInfo objectForKey:kNewsId]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                
                if (![userInfo objectForKey:kChannelId]) {
                    [userInfo setObject:@"0" forKey:kChannelId];
                }
                
                urlPath = @"tt://h5NewsWebView";
            }
        }
        //扫一扫
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolScanQrCode options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolScanQrCode];
            if ([pushURLStr containsString:@"closeLastPage=1"]) {
                SNNavigationController *topNavigation = [TTNavigator navigator].topViewController.flipboardNavigationController;
                [topNavigation popViewControllerAnimated:NO];
            }
            if (userInfo) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                urlPath = @"tt://scanQRCode";
            }
        }
        //优惠卷
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolCoupon options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolCoupon];
            if (userInfo) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                
                NSString * url = nil;
                if ([pushURLStr containsString:@"back2url"]) {
                    url = [[pushURLStr componentsSeparatedByString:@"coupon://back2url="] lastObject];
                    [SNUtility openProtocolUrl:url context:context];
                }
            }
        }
        //横屏广告
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolLandscape options:NSCaseInsensitiveSearch].location) {
            userInfo = [NSMutableDictionary dictionary];
            pushURLStr = [[pushURLStr componentsSeparatedByString:[NSString stringWithFormat:@"%@url=",kProtocolLandscape]]lastObject];
            if (pushURLStr) {
                if (context) {
                    [userInfo setValuesForKeysWithDictionary:context];
                }
                [userInfo setObject:pushURLStr forKey:@"address"];
                [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"landscape"];
                if (![context objectForKey:kUniversalWebViewType]) {
                    [userInfo setObject:[NSNumber numberWithInteger:NormalWebViewType] forKey:kUniversalWebViewType];
                }
                
                [userInfo setObject:pushURLStr forKey:@"link"];
                [SNUtility openUniversalWebView:userInfo];
                [self staticOpenAppOriginFrom:userInfo];
                //设置返回第三方App信息
                [self setBackThirdAppInfo:userInfo];
                
                return YES;
            }
        }
        // 正文蓝词搜索
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSearch options:NSCaseInsensitiveSearch].location) {
            NSString *url = [pushURLStr URLDecodedString];
            userInfo = [SNUtility parseURLParam:url schema:kProtocolSearch];
            if (userInfo[@"words"]) {
                [userInfo setObject:userInfo[@"words"] forKey:@"searchText"];
            }
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            if (userInfo && [userInfo objectForKey:kSearchWord]) {
                urlPath = @"tt://search";
            }
        }
        // 用户个人中心profile页
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolUserInfoProfile options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolUserInfoProfile];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            if (userInfo && [userInfo objectForKey:@"pid"]) {
                NSObject *push = [userInfo objectForKey:@"fromPush"];
                NSDictionary * arg = @{
                                       @"pid":[userInfo objectForKey:@"pid"],
                                       @"type":kProtocolUserInfoProfile,
                                       @"protocolLink2":pushURLStr,
                                       @"fromPush":nil == push ? @"0" : push,
                                       };
                
                [userInfo setValuesForKeysWithDictionary:arg];
                
                [SNSLib pushToProfileViewControllerWithDictionary:userInfo];
                [[SNMySDK sharedInstance] updateAppTheme];
                [self staticOpenAppOriginFrom:userInfo];
                
                //设置返回第三方App信息
                [self setBackThirdAppInfo:userInfo];
                
                return YES;
            }
        }
        // 视频详情页（非视频SDK）
        else if ([pushURLStr.lowercaseString startWith:kProtocolVideo.lowercaseString]) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideo];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if (userInfo) {
                urlPath = @"tt://videoDetail";
            }
        }
        //登录页面
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolLogin options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolLogin];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            //直接截取backUrl=后面的Url
                
            NSRange range = [pushURLStr rangeOfString:kLoginBackUrl];
            if (range.location == NSNotFound) {
                range = [pushURLStr rangeOfString:@"login://back2url="];
            }
            if (range.location == NSNotFound) {
                return YES;
            }
            
            NSString *backUrl = [pushURLStr substringFromIndex:range.length];
            [SNGuideRegisterManager protocolLogin:[backUrl URLDecodedString] dictInfo:context];
            
            [self staticOpenAppOriginFrom:userInfo];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //返回要闻频道
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolNewsTab options:NSCaseInsensitiveSearch].location) {
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            SNTabBarController* tabBarController = [[SNUtility getApplicationDelegate] appTabbarController];
            UIViewController *rootTabItemVC = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
            UIViewController *currentVC = [[TTNavigator navigator].topViewController.flipboardNavigationController topSubcontroller];
            //新闻Tab没有选中，则(如果没有处于根ViewController则先pop到根ViewController)切换到新闻Tab
            if (tabBarController.selectedIndex != 0) {
                if (currentVC != rootTabItemVC) {
                    [[TTNavigator navigator].topViewController.flipboardNavigationController popToRootViewControllerAnimated:NO];
                }
                [SNRollingNewsPublicManager sharedInstance].widgetOpen = YES;
                [tabBarController setSelectedIndex:0];
            }
            else {
                if (currentVC != rootTabItemVC) {
                    [SNRollingNewsPublicManager sharedInstance].widgetOpen = YES;
                    [[TTNavigator navigator].topViewController.flipboardNavigationController popToRootViewControllerAnimated:NO];
                }
            }
        }
        //刊首页二代协议
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSubHome options:NSCaseInsensitiveSearch].location) {
            NSObject *push = [context objectForKey:@"fromPush"];
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolSubHome];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            NSDictionary * arg = @{
                                   @"type":kProtocolSubHome,
                                   @"protocolLink2":pushURLStr,
                                   @"fromPush":nil == push ? @"0" : push
                                   };
            [userInfo setValuesForKeysWithDictionary:arg];
            
            [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
            
            if (![pushURLStr containsString:kH5LinkBottomTopDistance]) {
                BOOL shouldSpread = YES;
                if ([[context objectForKey:kFromRollingChannelWebKey] boolValue]) {
                    shouldSpread = NO;
                }
                [SNUtility shouldUseSpreadAnimation:shouldSpread];
            }
            [SNUtility shouldAddAnimationOnSpread:NO];
            
            [SNSLib pushToProfileViewControllerWithDictionary:userInfo];
            
            [[SNMySDK sharedInstance] updateAppTheme];
            [self staticOpenAppOriginFrom:userInfo];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //视频离线下载页
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolVideoDownload options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoDownload];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            
            [SNNotificationManager postNotificationName:kNotifyDidHandled object:nil];
            //这里不能采用暂停方式只能采用Stop方式，因为暂停后，等下载完后，播刚下完的视频时会播暂停的那个视频
            [SNNotificationManager postNotificationName:kSNPlayerViewStopVideoNotification object:nil];
            
            if (userInfo.count > 0) {
                urlPath = @"tt://videoDownloadViewController";
            }
        }
        // 频道预览页
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolPreview options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolPreview];
            if (userInfo) {
                if (context) {
                    [userInfo setValuesForKeysWithDictionary:context];
                }

                NSString *title = [[userInfo objectForKey:@"channelName"] URLDecodedString];
                if (title.length == 0) {
                    title = @"";
                }
                [userInfo setObject:title forKey:kTitle];
                [userInfo setObject:[NSNumber numberWithInteger:ChannelPreviewWebViewType] forKey:kUniversalWebViewType];
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
                [SNUtility openUniversalWebView:userInfo];
                [self staticOpenAppOriginFrom:userInfo];
                
                //设置返回第三方App信息
                [self setBackThirdAppInfo:userInfo];
                
                return YES;
            }
        }
        // 标签调起
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolChannel options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolChannel];
            if ([[userInfo objectForKey:@"channelName"]isEqualToString:@"小说"]) {
                NSString *typeStr = [userInfo objectForKey:@"type"];
                if (typeStr && [typeStr isEqualToString:@"push"]) {
                    //小说频道push点击，进入小说频道埋点统计
                    [SNNewsReport reportADotGif:@"act=fic_channel&tp=pv&from=2"];
                } else {
                    //频道流内导流item点击，进入小说频道
                    [SNNewsReport reportADotGif:@"act=fic_channel&tp=pv&from=3"];
                }
            }
            
            if (nil == userInfo) {
                return NO;
            }
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            NSString *channelId = userInfo[@"channelId"];
            NSString *channelName = userInfo[@"channelName"];
            BOOL channelSource = userInfo[@"channelSource"];//是否为来自频道预览的添加，避免与外链频道添加冲突
            NSString *_channelStatusDelete = userInfo[@"channelStatusDelete"];//频道删除字段
            if (channelId.length == 0 || channelName.length == 0) {
                return NO;
            }
            
            if ([channelId isEqualToString:kLocalChannelUnifyID]) {
                SNChannel *saveChannel = [[SNChannel alloc] init];
                saveChannel.channelName = channelName;
                saveChannel.channelId = channelId;
                saveChannel.gbcode = [userInfo objectForKey:@"gbcode" defalutObj:@""];
                [SNUtility saveHistoryShowWithChannel:saveChannel isHouseChannel:NO];
                SNChannel *localChannel = [SNUtility getThirdChannel];
                if (![channelName isEqualToString:localChannel.channelName]) {
                    NSString *gbCode = [userInfo objectForKey:@"gbcode" defalutObj:@""];
                    if ([gbCode length] != 0 && gbCode != nil) {
                        [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:channelId];
                        [[SNUserLocationManager sharedInstance] updateLocalChannelWithId:channelId cityName:channelName gbcode:gbCode channelId:channelId];
                    }
                }
            }
            
            if (!channelSource) {
                NSTimeInterval now = [NSDate date].timeIntervalSince1970;
                if (now - [SNUtility sharedUtility].lastChannelCallTime < 0.5) {
                    //避免打开两次
                    return YES;
                }
                
                [SNUtility sharedUtility].lastChannelCallTime = now;
            }
            
            channelName = [channelName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NewsChannelItem* item = [[NewsChannelItem alloc] init];
            item.channelName = channelName;
            item.channelId = channelId;
            item.channelType = [NSString stringWithFormat:@"%d", NewsChannelTypeNews];
            item.subId = nil;
            item.channelTop = @"0";
            item.isChannelSubed = @"1";
            item.channelStatusDelete = _channelStatusDelete;
            item.link = pushURLStr;
            
            if (!channelSource) {
                TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://rollingNews"] applyAnimated:YES];
                SNRollingNewsViewController *newsController = (SNRollingNewsViewController *)[[TTNavigator navigator] openURLAction:action];
                
                int index = [newsController addAndSelectExternalChannel:item];
                [SNUtility popToTabViewController:[TTNavigator navigator].topViewController];
                if ([SNUtility isFromChannelManagerViewOpened]) {
                    if ([newsController respondsToSelector:@selector(hideChannelManageView)]) {
                        [newsController hideChannelManageView];
                    }
                }
                [SNNotificationManager postNotificationName:kCloseSearchWebNotification object:nil];
                sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
                //跳转频道闪退modify by wangyy
                SNTabbarView *tabbarView = [app appTabbarController].tabbarView;
                if (tabbarView.currentSelectedIndex != TABBAR_INDEX_NEWS) {
                    [[app appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
                }
                
                if (-1 != index)  {
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        [newsController.tabBar reloadChannels];
                        newsController.tabBar.selectedChannelId = item.channelId;
                    });
                }
                
                bRet = YES;
                
                [[SNUtility sharedUtility] setLastOpenUrl:nil];
                if ([newsController respondsToSelector:@selector(setTabbarViewLocked:)]) {
                    [newsController setTabbarViewLocked:NO];
                }
                if ([newsController respondsToSelector:@selector(showTabbarView)]) {
                    [newsController showTabbarView];
                }
            }
            else {//修改bug，在看我tab频道预览添加时，会直接返回首页，底部tab栏丢失
                NSDictionary *dict = [NSDictionary dictionaryWithObject:item forKey:@"newsChannelItemFromChannel"];
                [SNNotificationManager postNotificationName:kChangePreviewChannelNotification object:nil userInfo:dict];
            }
        }
        //手机绑定拦截
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolTelBind options:NSCaseInsensitiveSearch].location) {
            BOOL isOpenMobileBind = [SNUtility isOpenMobileBindSwitch:kUserActionIdForArticleComment];
            if (isOpenMobileBind) {
                //打开手机绑定拦截页面
                userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle", nil];
                urlPath = @"tt://mobileNumBindLogin";
            }
        }
        //全屏视频 用户画像
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoFullScreen options:NSCaseInsensitiveSearch].location){
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoFullScreen];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            
            SNUserPortraitPlayer* player = [[SNUserPortraitPlayer alloc] initWithData:userInfo];
            [[TTNavigator navigator].topViewController.view addSubview:player];
            [player playUserPortraitVideo];
            [[SNUtility sharedUtility] setLastOpenUrl:nil];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //快速分享，直接打开指定分享平台
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolFastShare options:NSCaseInsensitiveSearch].location) {
            NSDictionary* dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolFastShare];
            
            userInfo = [SNUtility createShareData:pushURLStr Context:context];
            NSString* platform = [dic objectForKey:@"shareTo"];
            if (platform && platform.length>0) {
                [SNUtility fastShareWithPlatform:platform Data:userInfo];
            }
        }
        //分享浮层
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolShare options:NSCaseInsensitiveSearch].location) {
            //打开分享浮层页面
            userInfo = [SNUtility createShareData:pushURLStr Context:context];
            [SNUtility callShare:userInfo];
        }
        //打开收藏页面
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolOpenCorpus options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolOpenCorpus];
            if ([[userInfo objectForKey:kNoCorpusFolderName] isEqualToString:kNoCorpusCreat]) {
                [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kIsFromCorpusListCreat];
                urlPath = @"tt://creatCorpus";
            }
            else {
                urlPath = nil;
                NSString *corpusId = [userInfo objectForKey:kCorpusID];
                if ([corpusId isEqualToString:@"0"] || corpusId.length == 0) {//首页流和正文页收藏，点击toast进入收藏夹列表页
                    urlPath = @"tt://homeCorpus";
                    [SNCorpusNewsViewController clearData];
                }
                else {//收藏页面的toast，点击进入收藏详情页
                    urlPath = @"tt://corpusList";
                }
            }
        }
        //打开系统使用位置页
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolOpenSysytemLocation options:NSCaseInsensitiveSearch].location) {//iOS8以上支持
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        //弹窗设置
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolPopup options:NSCaseInsensitiveSearch].location) {
            NSDictionary *dict = [SNUtility parseURLParam:pushURLStr schema:kProtocolPopup];
            NSString *msg = [dict objectForKey:@"msg"];
            NSString *leftBtn = [dict objectForKey:@"leftbutton"];
            NSString *leftAction = [dict objectForKey:@"leftaction"];
            NSString *rightBtn = [dict objectForKey:@"rightbutton"];
            NSString *rightAction = [dict objectForKey:@"rightaction"];
            
            dispatch_async(dispatch_get_main_queue(), ^() {
                NSString *title = kBundleNameKey;
                SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:msg cancelButtonTitle:leftBtn otherButtonTitle:rightBtn];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [pushAlertView show];
                });
                [pushAlertView actionWithBlocksCancelButtonHandler:^{
                    if (![leftAction isEqualToString:@"close"]) {
                        [SNUtility openProtocolUrl:leftAction];
                    }
                } otherButtonHandler:^{
                    [SNUtility openProtocolUrl:rightAction];
                }];
            });
        }
        //天气详情页
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolWeather options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolWeather];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            NSString *gbcode = [userInfo stringValueForKey:kWeatherGbcode defaultValue:@""];
            NSString *city = [userInfo stringValueForKey:kWeatherCity defaultValue:@""];
            NSString *channelID = [userInfo stringValueForKey:kChannelId defaultValue:@""];
            [userInfo removeAllObjects];
            [userInfo setValue:gbcode forKey:kGbcode];
            [userInfo setValue:[city URLDecodedString] forKey:kCity];
            [userInfo setValue:channelID forKey:kChannelId];
            
            urlPath = @"tt://weather";
        }
        //视频SDK
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoV2 options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldAddAnimationOnSpread:NO];
            SNTabBarController *vc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
            NSInteger showSpread = 0;
            if (vc.selectedIndex == 0) {
                showSpread = 1;
            }
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoV2];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            NSString *vid = [userInfo stringValueForKey:@"vid" defaultValue:@""];
            NSString *site = [userInfo stringValueForKey:@"site" defaultValue:@""];
            if (site.length == 0) {
                site = @"2";
            }
            //lijian 20171021 去掉了sourcedata 里的 \"getad\":0 解决了pgc视频不能受配置有没有广告。
            NSString *url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=%@&more={\"sourcedata\":{\"channeled\":\"1300030006\",\"type\":2,\"newsNavAnimaition\":%d}}", vid, site, showSpread];
            [[ActionManager defaultManager] handleUrl:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //小说阅读页
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryReadChapter options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryReadChapter];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            SNStoryPageViewController *pageController = [SNStoryPageViewController new];
            NSString *novelId = [userInfo objectForKey:@"novelId"];
            pageController.novelId = novelId;
            pageController.chapterIndex = 0;
             pageController.chapterId = [[userInfo objectForKey:@"chapterIndex"]integerValue];
            pageController.pageType = StoryPageFromProtocol;
            [SNStoryUtility pushViewController:pageController animated:YES];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //小说章节列表
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryChapterList options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryChapterList];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            SNStoryCatelogController *catelogController = [SNStoryCatelogController new];
            catelogController.catelogType = StoryCateLogFromH5Detail;
            catelogController.novelId = [userInfo objectForKey:@"novelId"];
            [SNStoryUtility pushViewController:catelogController animated:YES];
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        //小说发现更多页面
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryNovel options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldAddAnimationOnSpread:NO];
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryNovel];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            [userInfo setObject:pushURLStr forKey:StoryProtocolLink];
            [userInfo setObject:@"0" forKey:@"novelH5PageType"];//表示小说发现更多页面
            [userInfo setObject:@"1" forKey:@"type"];
            [userInfo setObject:@"1" forKey:@"tagId"];//tagId默认传1
            urlPath = @"tt://storyWebView";
        }
        //小说详情
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryNovelDetail options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryNovelDetail];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            
            [userInfo setObject:pushURLStr forKey:StoryProtocolLink];
            [userInfo setObject:@"1" forKey:@"novelH5PageType"];//表示小说详情
            [SNUtility shouldAddAnimationOnSpread:NO];
            urlPath = @"tt://storyWebView";
        }
        //小说详情的全部评论
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryNovelDetailAllComments options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryNovelDetailAllComments];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            [userInfo setObject:pushURLStr forKey:StoryProtocolLink];
            [userInfo setObject:@"2" forKey:@"novelH5PageType"];//表示小说详情的全部评论
            [SNUtility shouldAddAnimationOnSpread:NO];
            urlPath = @"tt://storyWebView";
        }
        //小说书币充值历史记录
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryRechargeHistory options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldUseSpreadAnimation:NO];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            urlPath = @"tt://transactionHistory";
        }
        //小说书币充值
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryRechargeCenter options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldUseSpreadAnimation:NO];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            urlPath = @"tt://voucherCenter";
        }
        //小说运营标签
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryOperate options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldUseSpreadAnimation:NO];
            NSDictionary *dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryOperate];
            [userInfo setObject:pushURLStr forKey:StoryProtocolLink];
            [userInfo setValuesForKeysWithDictionary:dic];
            [userInfo setObject:@"3" forKey:@"novelH5PageType"];
            urlPath = @"tt://storyWebView";
        }
        //小说分类标签
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolStoryClassify options:NSCaseInsensitiveSearch].location) {
            [SNUtility shouldUseSpreadAnimation:NO];
            NSDictionary *dic = [SNUtility parseURLParam:pushURLStr schema:kProtocolStoryClassify];
            [userInfo setObject:pushURLStr forKey:StoryProtocolLink];
            [userInfo setValuesForKeysWithDictionary:dic];
            [userInfo setObject:@"2" forKey:@"type"];
            [userInfo setObject:@"0" forKey:@"novelH5PageType"];
            urlPath = @"tt://storyWebView";
        }
        //AR游戏
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolThirdParty options:NSCaseInsensitiveSearch].location) {
            if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            }
            else {
                [SNUtility shouldUseSpreadAnimation:NO];
                NSDictionary *dict = [SNUtility parseURLParam:pushURLStr schema:kProtocolThirdParty];
                NSString *actUrl = [[dict stringValueForKey:kJingDongActUrl defaultValue:@""] URLDecodedString];
                NSString *backUrl = [dict stringValueForKey:kJingDongBackUrl defaultValue:@""];
                if ([actUrl containsString:@"?"]) {
                    actUrl = [actUrl stringByAppendingFormat:@"&backUrl=%@", backUrl];
                }
                else {
                    actUrl = [actUrl stringByAppendingFormat:@"?backUrl=%@", backUrl];
                }
                
                if (context) {
                    [userInfo setValuesForKeysWithDictionary:context];
                }

                [userInfo setObject:actUrl forKey:kJingDongActUrl];
                [userInfo setObject:[dict stringValueForKey:kJingDongActivityID defaultValue:@""] forKey:kJingDongActivityID];
                [userInfo setObject:[dict stringValueForKey:kJingDongContentType defaultValue:@""] forKey:kJingDongContentType];
                urlPath = @"tt://JDGameView";
            }
        }
        //tab切换
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolTab options:NSCaseInsensitiveSearch].location) {
            [SNNotificationManager postNotificationName:kSNSShowTabBarNotification object:nil];
            [SNNotificationManager postNotificationName:kSearchWebViewCancle object:nil];
            SNTabBarController *tabBarController = [[SNUtility getApplicationDelegate] appTabbarController];
            __block UIViewController *rootViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
            UIViewController *currentViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController topSubcontroller];
            
            if (currentViewController != rootViewController) {
                [[TTNavigator navigator].topViewController.flipboardNavigationController popToRootViewControllerAnimated:NO];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1), dispatch_get_main_queue(), ^() {
                rootViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
                if ([rootViewController respondsToSelector:@selector(setTabbarViewLocked:)]) {
                    [rootViewController setTabbarViewLocked:NO];
                }
                if ([rootViewController respondsToSelector:@selector(showTabbarView)]) {
                    [rootViewController showTabbarView];
                }
            });
            
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolTab];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }

            NSString *tabName = [userInfo stringValueForKey:kTabBarNameKey defaultValue:@""];
            if ([tabName isEqualToString:kTabBarNewsTab]) {//新闻tab
                [tabBarController setSelectedIndex:0];
            }
            else if ([tabName isEqualToString:kTabBarVideoTab]) {//视频tab
                [tabBarController setSelectedIndex:1];
            }
            else if ([tabName isEqualToString:kTabBarSNSTab]) {//狐友tab
                [tabBarController setSelectedIndex:2];
            }
            else if ([tabName isEqualToString:kTabBarMyTab]) {//我tab
                [tabBarController setSelectedIndex:3];
            }
            
            //设置返回第三方App信息
            [self setBackThirdAppInfo:userInfo];
            
            return YES;
        }
        // 意见反馈输入页面
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolFeedBackEdit options:NSCaseInsensitiveSearch].location) {
            urlPath = @"tt://quickFeedBack";
        }
        //阅读历史
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolReadHistory options:NSCaseInsensitiveSearch].location || NSNotFound != [pushURLStr rangeOfString:kPushHistory options:NSCaseInsensitiveSearch].location) {
            NSString *htmlString = nil;
            if (NSNotFound != [pushURLStr rangeOfString:kProtocolReadHistory options:NSCaseInsensitiveSearch].location) {
                htmlString = kUrlReadHistory;
            }
            else {
                htmlString = kUrlPushHistory;
            }
            
            NSString *actionURLString = nil;
            SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
            if ([themeManager.currentTheme isEqualToString:@"night"]) {
                actionURLString = [SNUtility addParamModeToURL:htmlString];
                actionURLString = [actionURLString stringByAppendingString:@"&platformId=5"];
            }
            else {
                actionURLString = [NSString stringWithFormat:@"%@?platformId=5", htmlString];
            }
            actionURLString = [NSString stringWithFormat:@"%@&p1=%@", actionURLString, [SNUserManager getP1]];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:actionURLString, kLink, [NSNumber numberWithInteger:ReadHistoryWebViewType], kUniversalWebViewType, nil];
            [SNUtility openUniversalWebView:dic];
            return YES;
        }
        //打开搜狐视频APP
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSohuVideo options:NSCaseInsensitiveSearch].location) {
            if ([SNUtility isWhiteListURL:[NSURL URLWithString:pushURLStr]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pushURLStr]];
            }
        }
        //全屏广告
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolFullScreen options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolFullScreen];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            
            NSNumber *webType = context[kUniversalWebViewType];
            if (webType) {
                if ([webType integerValue] != FullScreenADWebViewType) {
                    [userInfo setObject:[NSNumber numberWithInteger:FullScreenADWebViewType] forKey:kUniversalWebViewType];
                }
            }else{
                [userInfo setObject:[NSNumber numberWithInteger:FullScreenADWebViewType] forKey:kUniversalWebViewType];
            }
            
            [SNUtility openUniversalWebView:userInfo];
        }
        //废弃协议 start
        else if ((NSNotFound !=[pushURLStr rangeOfString:kProtocolJoke options:NSCaseInsensitiveSearch].location)) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolJoke];
            if ([userInfo count] > 0) {
                if ([SNUtility sharedUtility].isEnterBackground) {
                    [SNNotificationManager postNotificationName:kAppBecomeActivityNotification object:nil];
                    [SNUtility sharedUtility].isEnterBackground = NO;
                }
                
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                if (![userInfo objectForKey:kChannelId]) {
                    [userInfo setObject:@"0" forKey:kChannelId];
                }
                NSString *urlPath = @"tt://h5NewsWebView";
                
                urlAction = [[[TTURLAction actionWithURLPath:urlPath] applyAnimated:YES] applyQuery:userInfo];
                // 打开新闻统计
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
            }
        }
        else if (NSNotFound !=[pushURLStr rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location ||
                 NSNotFound !=[pushURLStr rangeOfString:kProtocolDataFlow options:NSCaseInsensitiveSearch].location) {
            
            if (NSNotFound !=[pushURLStr rangeOfString:kProtocolPaper options:NSCaseInsensitiveSearch].location) {
                userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolPaper];
            } else {
                userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolDataFlow];
            }
            
            NSString *subId = [userInfo objectForKey:@"subId"];
            
            if ([userInfo count] > 0) {
                NSMutableDictionary *feedBackParamsDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                [feedBackParamsDict removeObjectForKey:@"subId"];
                [feedBackParamsDict removeObjectForKey:@"termId"];
                if ([context objectForKey:@"s1"] && [context objectForKey:@"s2"]) {
                    [feedBackParamsDict setObject:[context objectForKey:@"s1"] forKey:@"s1"];
                    [feedBackParamsDict setObject:[context objectForKey:@"s2"] forKey:@"s2"];
                }
                
                NSString *feedBackParamsStr = [feedBackParamsDict toUrlString];
                SNDebugLog(@"feedback param str = %@", feedBackParamsStr);
                if (feedBackParamsStr.length > 0) {
                    [userInfo setObject:feedBackParamsStr forKey:kProtocolParamsFeedback];
                }
                
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                
                SubscribeHomeMySubscribePO *subItem = nil;
                
                if ([[userInfo objectForKey:@"subitem"] isKindOfClass:[SubscribeHomeMySubscribePO class]]) {
                    subItem = (SubscribeHomeMySubscribePO *)[userInfo objectForKey:@"subitem"];
                } else {
                    subItem = [[SubscribeHomeMySubscribePO alloc] init];
                    [userInfo setObject:subItem forKey:@"subitem"];
                    
                    if (subId) {
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
                        if (subObj) {
                            subItem.subId = subObj.subId;
                            subItem.subName = subObj.subName;
                        }
                    }
                }
                
                SNDebugLog(@"INFO: sub/pub id is %@", subItem.subId);
                
                NSString *urlExcludeSchema = [SNUtility removeProtocolV2FromStr:pushURLStr];
                subItem.lastTermLink = [NSString stringWithFormat:kUrlTermGo, urlExcludeSchema];
                
                [userInfo setObject:@"SUBLIST" forKey:@"linkType"];
                
                SNDebugLog(@"%@--%@, term link: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), subItem.lastTermLink);
                //(subItem);
                
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://paperBrowser"] applyAnimated:YES] applyQuery:userInfo];
                
                // 打开报纸统计
                [self checkOpenProtocolUrlShouldUploadTermLog:context userInfo:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolSub options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolSub];
            if ([userInfo count] > 0 && [userInfo objectForKey:@"subId"]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolWeibo options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolWeibo];
            if (userInfo && [userInfo count] > 0 && [userInfo objectForKey:@"rootId"]) {
                [userInfo setObject:[userInfo objectForKey:@"rootId"] forKey:kWeiboId];
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://weiboDetail"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolNewsChannel options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolNewsChannel];
            if (userInfo && [userInfo objectForKey:kChannelId]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                NSString *title = [[userInfo objectForKey:@"channelName"] URLDecodedString];
                if (title.length == 0) {
                    title = @"";
                }
                [userInfo setObject:title forKey:kTitle];
                [userInfo setObject:[NSNumber numberWithInteger:ChannelPreviewWebViewType] forKey:kUniversalWebViewType];
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
                [SNUtility openUniversalWebView:userInfo];
                [self staticOpenAppOriginFrom:userInfo];
                return YES;
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolWeiboChannel options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolWeiboChannel];
            if (userInfo && [userInfo objectForKey:kChannelId]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                [userInfo setObject:@(NewsChannelTypeWeiboHot) forKey:@"channelType"];
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://newsChannel"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolPhotoChannel options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolPhotoChannel];
            if (userInfo && [userInfo objectForKey:kCategoryId]) {
                if (context) [userInfo setValuesForKeysWithDictionary:context];
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://photosChannel"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolLiveChannel options:NSCaseInsensitiveSearch].location) {
            // 这里服务器通过link给的参数
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolLiveChannel];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            if (userInfo && ([userInfo objectForKey:kChannelSubId] || [userInfo objectForKey:kSubId])) {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://livesChannel"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolPlugin options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolPlugin];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            if (userInfo && [userInfo objectForKey:@"id"]) {
                NSString *plugin = [userInfo objectForKey:@"id"];
                urlAction = [self actionWithPluginName:plugin userInfo:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolReadCircleDetail options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolReadCircleDetail];
            if (context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if (userInfo) {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://readCircleDetail"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolComment options:NSCaseInsensitiveSearch].location) {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolComment];
            if (context) [userInfo setValuesForKeysWithDictionary:context];
            
            if (userInfo) {
                NSNumber *toolbarType = [NSNumber numberWithInteger:SNCommentToolBarTypeTextOnly];
                NSNumber *viewType = [NSNumber numberWithInteger:SNComment];
                NSString *replyToName = [userInfo objectForKey:@"replyToName"];
                NSString *newsId = [userInfo stringValueForKey:@"newsId" defaultValue:nil];
                NSString *replyId = [userInfo stringValueForKey:@"replyId" defaultValue:nil];
                SNCommentSendType replyType = [userInfo intValueForKey:@"replyType" defaultValue:1];
                
                [userInfo setObject:toolbarType forKey:kCommentToolBarType];
                [userInfo setObject:viewType forKey:kEditorKeyViewType];
                
                SNSendCommentObject *cmtObj = [SNSendCommentObject new];
                if (replyToName.length > 0)
                {
                    cmtObj.replyName = [replyToName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                if (newsId.length > 0) {
                    cmtObj.newsId = newsId;
                    cmtObj.busiCode = commentBusicodeNews;
                }
                
                //回复评论数据结构
                SNNewsComment *replyComment = [[SNNewsComment alloc] init];
                replyComment.commentId = replyId;
                cmtObj.replyComment = [SNNewsComment createReplyComment:replyComment replyType:replyType];
                
                if (cmtObj) {
                    [userInfo setObject:cmtObj forKey:kEditorKeySendCmtObj];
                }
                
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://modalCommentEditor"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        //政企首页 二代协议:orgHome://subId=123
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolOrgHome options:NSCaseInsensitiveSearch].location)
        {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolOrgHome];
            if(context)
            {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if(userInfo)
            {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://orgHome"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        //政企栏目页 二代协议:orgColumn://subId=123&columnId=123
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolOrgColumn options:NSCaseInsensitiveSearch].location)
        {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolOrgColumn];
            if(context)
            {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if(userInfo)
            {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://orgColumn"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        //二维码页面 二代协议：qrCode://subId=123
        else if(NSNotFound != [pushURLStr rangeOfString:kProtocolQRCode options:NSCaseInsensitiveSearch].location)
        {
            userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolQRCode];
            if(context)
            {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if(userInfo)
            {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://subQRInfo"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        //视频媒体页 videoMedia://
        else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoMidia options:NSCaseInsensitiveSearch].location ||
                 NSNotFound != [pushURLStr rangeOfString:kProtocolVideoPerson options:NSCaseInsensitiveSearch].location) {
            
            if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoMidia options:NSCaseInsensitiveSearch].location) {
                userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoMidia];
            }
            else if (NSNotFound != [pushURLStr rangeOfString:kProtocolVideoPerson options:NSCaseInsensitiveSearch].location) {
                userInfo = [SNUtility parseURLParam:pushURLStr schema:kProtocolVideoPerson];
            }
            
            if(context) {
                [userInfo setValuesForKeysWithDictionary:context];
            }
            if (pushURLStr.length > 0) {
                [userInfo setObject:pushURLStr forKey:kVideoMediaLink];
            }
            if(userInfo) {
                urlAction = [[[TTURLAction actionWithURLPath:@"tt://videoMedia"] applyAnimated:YES] applyQuery:userInfo];
            }
        }
        //废弃协议 end
        //设置返回第三方App信息
        [self setBackThirdAppInfo:userInfo];
        
        if (urlPath) {
            urlAction = [[[TTURLAction actionWithURLPath:urlPath] applyAnimated:YES] applyQuery:userInfo];
        }
        
        [self staticOpenAppOriginFrom:userInfo];//统计调起app方式
        
        if (urlAction) {
            [[TTNavigator navigator] openURLAction:urlAction];
            bRet = YES;
            if ([SNAPI isWebURL:pushURLStr]) {
                [self checkOpenProtocolUrlShouldUploadNewsLog:context userInfo:userInfo];
            }
        }
    }
    
    return bRet;
}

+ (void)setBackThirdAppInfo:(NSDictionary *)dict {
    SNOpenAppOriginFromType originType = [[dict stringValueForKey:kOpenAppOriginFromKey defaultValue:nil] integerValue];
    if (originType != SNOpenAppOriginFromUniversalLink) {
        return;
    }
    
    [SNUtility sharedUtility].backThirdAppDict = dict;
    
    SNAppConfigScheme *config = [[SNAppConfigManager sharedInstance] configScheme];
    if (config.appSchemeList) {
        [SNUtility showBackThirdAppView];
    }
}

+ (void)showBackThirdAppView {
    if ([SNUtility sharedUtility].backThirdAppDict) {
        NSString *backAppUrl = [[SNUtility sharedUtility].backThirdAppDict stringValueForKey:@"backApp" defaultValue:@""];
        if (backAppUrl.length > 0) {
            if ([[UIApplication sharedApplication].keyWindow viewWithTag:kBackThirdAppViewTag]) {
                [SNUtility sharedUtility].backThirdAppDict = nil;
                return;
            }
            SNBackThirdAppView *view = [[SNBackThirdAppView alloc] init];
            view.tag = kBackThirdAppViewTag;
            [view setBackAppInfo:[backAppUrl URLDecodedString]];
        }
        [SNUtility sharedUtility].backThirdAppDict = nil;
    }
}

+ (void)staticOpenAppOriginFrom:(NSDictionary *)dict {
    NSString *type =  [dict stringValueForKey:kOpenAppOriginFromKey defaultValue:nil];
    NSString *startFrom = [dict stringValueForKey:@"startfrom" defaultValue:nil];
    if (startFrom && type) {
        [[SNOpenWayManager sharedInstance] analysisAndPostURL:nil from:nil openOrigin:startFrom];
    }
}

+ (BOOL)openQRCodeViewWith:(NSDictionary *)query {
    [SNUtility shouldUseSpreadAnimation:NO];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://scanQRCode"] applyAnimated:YES] applyQuery:query];
    [[TTNavigator navigator] openURLAction:urlAction];
    return YES;
}

+ (BOOL)openProtocolUrl:(NSString *)pushURLStr {
    return [self openProtocolUrl:pushURLStr context:nil];
}

+ (BOOL)openProtocolAesUrl:(NSString *)aesUrl AesKey:(NSString *)aesKey{
    if (aesUrl.length == 0) {
        return YES;
    }
    NSMutableData *data = [NSMutableData dataWithCapacity:aesUrl.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [aesUrl length] / 2; i++) {
        byte_chars[0] = [aesUrl characterAtIndex:i*2];
        byte_chars[1] = [aesUrl characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    NSString *pushURLStr = [AesEncryptDecrypt decryptData:data withKey:aesKey];
    return [self openProtocolUrl:pushURLStr context:nil];
}

+ (BOOL)openProtocolUrl:(NSString *)url context:(NSDictionary *)context {
    SNDebugLog(@"protocol url:%@", url);
    NSString *tempUrl = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *pushURLStr = [self removeBackFlowProtocolForUrl:tempUrl];
    if (pushURLStr.length == 0) {
        return YES;
    }
    if ([pushURLStr hasPrefix:@"js:"]) {
        pushURLStr = [pushURLStr substringFromIndex:3];
    }
    
    if ([SNUtility sharedUtility].isEnterBackground) {
        [SNNotificationManager postNotificationName:kAppBecomeActivityNotification object:nil];
        [SNUtility sharedUtility].isEnterBackground = NO;
    }
    
    if ([SNUtility pasteBoardUrlIsEqualProtocolUrl:pushURLStr]) {
        [SNUtility clearPasteBoard];
    }
        
    //用户画像
    if ([pushURLStr containsString:@"h5apps/newssdk.sohu.com/modules/readZone/readZone.html"]) {
    }
    else {
        NSString * lastUrl = [[SNUtility sharedUtility] lastOpenUrl];
        if (lastUrl && [lastUrl isEqualToString:pushURLStr]) {
            [[SNUtility sharedUtility] setLastOpenUrl:nil];
            return YES;
        }
    }
    
    [[SNUtility sharedUtility] setLastOpenUrl:pushURLStr];
    
    if (NSNotFound != [pushURLStr rangeOfString:kProtocolTab options:NSCaseInsensitiveSearch].location) {
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
    }
    
    //处理SNS二代协议
    if (NSNotFound != [pushURLStr rangeOfString:kProtocolSNS options:NSCaseInsensitiveSearch].location) {
        [SNUtility shouldAddAnimationOnSpread:NO];
        [SNSLib actionFromOpenUrl:pushURLStr];
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
        return YES;
    }
    
    BOOL bRet = NO;
    if ([self isProtocolV2:pushURLStr]) {
        // 使用的是二代协议xxx://a=xx&b=yy&...
        bRet = [self openProtocolUrlV2:pushURLStr context:context];
    } else {
        // 缺省一代协议xxx://xxx_xxx
        bRet = [self openProtocolUrlV1:pushURLStr context:context];
    }
    return bRet;
}

+ (BOOL)isProtocolV2:(NSString *)urlStr {
    BOOL bRet = NO;
    NSString *tempString = [self removeBackFlowProtocolForUrl:urlStr];
    NSString *url = [tempString URLDecodedString];
    if ([url length] > 0) {
        // 判断协议版本
        NSString *pattern = @"\\w*://\\w*=\\w*(&\\w*=\\w*)*";//这个正则不能乱改，否则会被误认为一代协议，导致很多地方出错！！
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger numberOfMatches = [regex numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])];
        
        bRet = (numberOfMatches > 0);
    }
    return bRet;
}

//移除协议前缀"sohunews://pr/",转化为端内协议
+ (NSString *)removeBackFlowProtocolForUrl:(NSString *)url {
    NSString *tempString = nil;
    if ([url containsString:kProtocolBackFlow]) {
        tempString = [url stringByReplacingOccurrencesOfString:kProtocolBackFlow withString:@""];
    }
    else {
        tempString = url;
    }
    
    return tempString;
}

+ (NSString *)removeProtocolV2FromStr:(NSString *)urlStr {
    NSString *ret = urlStr;
    
    if ([SNUtility isProtocolV2:urlStr]) {
        NSRange range = [urlStr rangeOfString:@"://"];
        if (range.length > 0) {
            ret = [urlStr substringFromIndex:range.location + 3];
        }
    }
    return ret;
}

+ (SNReferFrom)referFromWithProtocolV2:(NSString *)urlStr {
    SNReferFrom refer = -1;
    if ([urlStr hasPrefix:kProtocolNews]) {
        refer = REFER_ARTICLE;
    }
    else if ([urlStr hasPrefix:kProtocolPhoto]) {
        refer = REFER_GROUPPHOTOLIST;
    }
    else if ([urlStr hasPrefix:kProtocolPaper] || [urlStr hasPrefix:kProtocolDataFlow]) {
        refer = REFER_PAPER;
    }
    else if ([urlStr hasPrefix:kProtocolSub]) {
        refer = REFER_PUB_INFO;
    }
    else if ([urlStr hasPrefix:kProtocolLive]) {
        refer = REFER_LIVE;
    }
    else if ([urlStr hasPrefix:kProtocolSpecial]) {
        refer = REFER_SPECIALNEWSLIST;
    }
    else if ([urlStr hasPrefix:kProtocolWeibo]) {
        refer = REFER_WEIHOT;
    }
    
    // 。。。 其他的待添加
    
    return refer;
}

+ (TTURLAction *)actionWithPluginName:(NSString *)plugin userInfo:(NSDictionary *)userInfo {
    if (plugin.length <= 0) {
        return nil;
    }
    if ([plugin isEqualToString:kPluginShake]) {
        return [[[TTURLAction actionWithURLPath:@"tt://shakingView"] applyAnimated:YES] applyQuery:userInfo];
    } else if ([plugin isEqualToString:kPluginReadingCircle]) {
        // 如果用户中心已经登陆 直接进阅读圈 否则 先进登陆页面 by jojo
        if ([SNUserManager isLogin])
            return [[[TTURLAction actionWithURLPath:@"tt://timeline_main"] applyAnimated:YES] applyQuery:userInfo];
        else
            return [[[TTURLAction actionWithURLPath:@"tt://timeline_login"] applyAnimated:YES] applyQuery:userInfo];
    }
    return nil;
}

//add by sampanli
+(NSString *)getLinkFromShareContent:(NSString *)content {
    if (content.length==0) {
        return nil;
    }
    NSString *link = nil;
    NSString *linkHeader = [SNAPI rootScheme];
    NSRange rangHeader = [content rangeOfString:linkHeader options:NSCaseInsensitiveSearch|NSBackwardsSearch];
    if (rangHeader.location != NSNotFound) {
        NSString *subStr = [content substringFromIndex:rangHeader.location + [linkHeader length]];
        NSInteger subStringLen = [subStr length];
        unichar ch = 0;
        int linkEndIndex = 0;
        for (int nIndex = 0; nIndex < subStringLen; nIndex++) {
            ch = [subStr characterAtIndex:nIndex];
            if (!isascii(ch) || isblank(ch)) {
                linkEndIndex = nIndex;
                break;
            }
            if (nIndex == subStringLen - 1) {
                linkEndIndex = nIndex + 1;
                break;
            }
        }
        if (linkEndIndex) {
            link = [content substringWithRange:NSMakeRange(rangHeader.location, rangHeader.length + linkEndIndex)];
        }
    }
    return link;
}

+ (NSString *)getP1{
    NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (savedUid.length){
        NSString* encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
        NSString* p1Str = [encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return p1Str;
    }
    return nil;
}

//version	是	字符串	接口版本号 : 一期 1.0
//token     是	通信码	登陆时获取的token(由passport同一维护的token)
//pid       否	字符串	当前登陆用户的passportid(有则必须传)
//userId    否	字符串	当前登陆用户的passport账号(没有pid则传userId)
//p1        是	字符串	用户ID的Base64编码，之后再用URLEncode编码使符合URL规范
//gid       是	字符串	登陆passport时传递给passport的gid
+(NSString*)addParamsToURLForReadingCircle:(NSString *)URL
{
    NSMutableString* url = [NSMutableString stringWithString:URL];
    if(NSNotFound == [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location)
        [url appendFormat:@"?version=%@", kSNTLReadCircleVersion];
    else
        [url appendFormat:@"&version=%@", kSNTLReadCircleVersion];
    
    if([SNUserManager getToken])
        [url appendFormat:@"&token=%@", [SNUserManager getToken]];
    else
        [url appendFormat:@"&token=-1"];
    
    if([SNUserManager getPid])
        [url appendFormat:@"&pid=%@", [SNUserManager getPid]];
    else if([SNUserManager getUserId])
        [url appendFormat:@"&userId=%@", [SNUserManager getUserId]];
    
    NSString* p1Str = [SNUserManager getP1];
    if(p1Str.length>0)
        [url appendFormat:@"&p1=%@", p1Str];
    
    [url appendFormat:@"&gid=%@",[SNUserManager getGid]];
    return url;
}

+ (NSDictionary *)paramsDictionaryForReadingCircle {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:kSNTLReadCircleVersion forKey:@"version"];
    
    if ([SNUserManager getToken].length > 0)
        [dic setObject:[SNUserManager getToken] forKey:@"token"];
    
    if ([SNUserManager getPid].length > 0)
        [dic setObject:[SNUserManager getPid] forKey:@"pid"];
    
    if ([SNUserManager getUserId].length > 0)
        [dic setObject:[SNUserManager getUserId] forKey:@"userId"];
    
    NSString *gid = [SNUserManager getGid];
    if (gid.length > 0)
        [dic setObject:gid forKey:@"gid"];
    
    NSString* p1Str = [SNUserManager getP1];
    if(p1Str.length > 0)
        [dic setObject:p1Str forKey:@"p1"];
    
    return dic;
}

//p1            是
//mainPassport	否                 当前登录的passport账号,传这个参数则表明处于登录状态,不传返回所有第三方，状态为待绑定，需要用户先登录
//isCheck       否                 整型	是否需要检验token(兼容老版本)，0不需要，1需要 默认不需要
//gid           isCheck为1时必传    字符串	检验token需要的参数
//token         isCheck为1时必传    字符串	token
//version       是                 字符串	版本号(从3.5版本开始加入)，控制第三方登陆类型，无该值返回的type=wap，此值为1.0时返回type=mapp
+ (NSString *)addParamsToURLForShare:(NSString *)URL
{
    if(![SNUserManager isLogin])
    {
        NSMutableString* url = [NSMutableString stringWithString:URL];
        if(NSNotFound == [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location)
            [url appendFormat:@"?version=1.0"];
        else
            [url appendFormat:@"&version=1.0"];
        return url;
    }
    else
    {
        NSMutableString* url = [NSMutableString stringWithString:URL];
        if(NSNotFound == [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location)
            [url appendFormat:@"?version=1.0"];
        else
            [url appendFormat:@"&version=1.0"];
        
        if([SNUserManager getUserId].length > 0)
            [url appendFormat:@"&mainPassport=%@", [SNUserManager getUserId]];
        
        if([SNUserManager getToken].length > 0)
            [url appendFormat:@"&token=%@", [SNUserManager getToken]];
        
        NSString* p1Str = [SNUserManager getP1];
        if(p1Str.length>0)
            [url appendFormat:@"&p1=%@", p1Str];
        
        [url appendFormat:@"&isCheck=1"];
        [url appendFormat:@"&gid=%@",[SNUserManager getGid]];
        return url;
    }
}

+ (NSString *)addAPIVersionToURL:(NSString *)URL {
    
    if (![URL containsString:@"?"]) {
        return [URL stringByAppendingFormat:@"?apiVersion=%d", APIVersion];
    }
    else {
        return [URL stringByAppendingFormat:@"&apiVersion=%d", APIVersion];
    }
}

+ (NSString *)addProductIDIntoURL:(NSString *)url {
    if (url.length <= 0) {
        return url;
    }
    
    NSString *productIDParamName1 = @"&u=";
    NSString *productIDParamName2 = @"?u=";
    NSString *productIDParamValue = [SNAPI productId];
    //原URL中不包含产品param
    if (![url containsString:productIDParamName1] && ![url containsString:productIDParamName2]) {
        //原URL中包含了问号
        if ([url containsString:@"?"]) {
            url = [NSString stringWithFormat:@"%@%@%@", url, productIDParamName1, productIDParamValue];
        }
        //原URL中不包含问号
        else {
            url = [NSString stringWithFormat:@"%@%@%@", url, productIDParamName2, productIDParamValue];
        }
    }
    return url;
}

+ (NSString *)addBundleIDIntoURL:(NSString *)URL {
    if (URL.length <= 0) {
        return URL;
    }
    
    NSString *bundleIDParamName1 = @"&bid=";
    NSString *bundleIDParamName2 = @"?bid=";
    NSString *bundleIDParamValue = [SNAPI encodedBundleID];
    //原URL中不包含产品param
    if (![URL containsString:bundleIDParamName1] && ![URL containsString:bundleIDParamName2]) {
        //原URL中包含了问号
        if ([URL containsString:@"?"]) {
            URL = [NSString stringWithFormat:@"%@%@%@", URL, bundleIDParamName1, bundleIDParamValue];
        }
        //原URL中不包含问号
        else {
            URL = [NSString stringWithFormat:@"%@%@%@", URL, bundleIDParamName2, bundleIDParamValue];
        }
    }
    return URL;
}

+ (NSString *)addPLProductIDIntoURL:(NSString *)url {
    if (url.length <= 0) {
        return url;
    }
    
    NSString *productIDParamName1 = @"&pl=";
    NSString *productIDParamName2 = @"?pl=";
    NSString *productIDParamValue = [SNAPI productId];
    //原URL中不包含产品param
    if (![url containsString:productIDParamName1] && ![url containsString:productIDParamName2]) {
        //原URL中包含了问号
        if ([url containsString:@"?"]) {
            url = [NSString stringWithFormat:@"%@%@%@", url, productIDParamName1, productIDParamValue];
        }
        //原URL中不包含问号
        else {
            url = [NSString stringWithFormat:@"%@%@%@", url, productIDParamName2, productIDParamValue];
        }
    }
    return url;
}

+ (NSString *)addParamP1ToURL:(NSString *)URL {
    NSString *urlWithP1 = URL;
    if (NSNotFound == [URL rangeOfString:@"p1=" options:NSCaseInsensitiveSearch].location) {
        NSString *p1Str = [SNUserManager getP1];
        if (p1Str.length == 0) {
            p1Str = @"0";
        }
        if (NSNotFound == [URL rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
            urlWithP1 = [URL stringByAppendingFormat:@"?p1=%@", p1Str];
        }
        else {
            urlWithP1 = [URL stringByAppendingFormat:@"&p1=%@", p1Str];
        }
    }
    if([SNUserManager isLogin])
    {
        if(![urlWithP1 containsString:@"pid="] && [SNUserManager getPid])
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&pid=%@", [SNUserManager getPid]];
        if(![urlWithP1 containsString:@"token="] && [SNUserManager getToken])
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&token=%@", [SNUserManager getToken]];
        
        //gid参数如果被占用了，就以zgid作为参数
        NSString *gidKey = @"gid";
        if ([urlWithP1 containsString:@"gid="]) {
            gidKey = @"zgid";
        }
        urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&%@=%@", gidKey, [SNUserManager getGid]];
    }
    else
    {
        if ([urlWithP1 containsString:@"?"]) {
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&pid=%@", @"-1"];
        } else {
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"?pid=%@", @"-1"];
        }
    }
    
    //为确保服务器能通过当次接口请求就判断出来apiVersion, 从3.7开始显示添加此参数，不去查询缓存值，否则用户升级时不及时，第二次启动apiVersion才是新的。
    urlWithP1 = [SNUtility addAPIVersionToURL:urlWithP1];
    
    //sid
    NSString *sid = [SNClientRegister sharedInstance].sid;
    if (sid) {
        urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&sid=%@", sid];
    }
    
    return urlWithP1;
}

+ (NSString *)addParamP1ToURL:(NSString *)URL isV6:(BOOL)isV6 {
    NSString *urlWithP1 = URL;
    if (NSNotFound == [URL rangeOfString:@"p1=" options:NSCaseInsensitiveSearch].location) {
        NSString *p1Str = [SNUserManager getP1];
        if (p1Str.length) {
            if (NSNotFound == [URL rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                urlWithP1 = [URL stringByAppendingFormat:@"?p1=%@", p1Str];
            }
            else {
                urlWithP1 = [URL stringByAppendingFormat:@"&p1=%@", p1Str];
            }
        }
    }
    if([SNUserManager isLogin])
    {
        if(![urlWithP1 containsString:@"pid="] && [SNUserManager getPid])
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&pid=%@", [SNUserManager getPid]];
        if(![urlWithP1 containsString:@"token="] && [SNUserManager getToken])
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&token=%@", [SNUserManager getToken]];
        
        //gid参数如果被占用了，就以zgid作为参数
        NSString *gidKey = @"gid";
        if ([urlWithP1 containsString:@"gid="]) {
            gidKey = @"zgid";
        }
        urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&%@=%@", gidKey, [SNUserManager getGid]];
    }
    else
    {
        if ([urlWithP1 containsString:@"?"]) {
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&pid=%@", @"-1"];
        } else {
            urlWithP1 = [urlWithP1 stringByAppendingFormat:@"?pid=%@", @"-1"];
        }
    }
    
    //为确保服务器能通过当次接口请求就判断出来apiVersion, 从3.7开始显示添加此参数，不去查询缓存值，否则用户升级时不及时，第二次启动apiVersion才是新的。
    if (!isV6) {
        urlWithP1 = [SNUtility addAPIVersionToURL:urlWithP1];
    }
    
    //sid
    NSString *sid = [SNClientRegister sharedInstance].sid;
    if (sid) {
        urlWithP1 = [urlWithP1 stringByAppendingFormat:@"&sid=%@", sid];
    }
    
    return urlWithP1;
}

+ (NSString *)addParamModeToURL:(NSString *)URL {
    NSString *urlWithMode = URL;
    if (NSNotFound == [URL rangeOfString:@"mode=" options:NSCaseInsensitiveSearch].location) {
        if(URL.length) {
            if(NSNotFound == [URL rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                urlWithMode = [URL stringByAppendingFormat:@"?mode=1"];
            }
            else {
                urlWithMode = [URL stringByAppendingFormat:@"&mode=1"];
            }
        }
    }
    return urlWithMode;
}

+ (NSString *)addParamImgsToURL:(NSString *)URL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger nonePictureMode = [[userDefaults objectForKey:kNonePictureModeKey] intValue];
    NSString *appendType = nil;
    if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        appendType = @"imgs=1";
    }
    else {
        appendType = @"imgs=0";
    }
    NSString *urlWithMode = URL;
    if (NSNotFound == [URL rangeOfString:@"imgs=" options:NSCaseInsensitiveSearch].location) {
        if(URL.length) {
            if(NSNotFound == [URL rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                urlWithMode = [URL stringByAppendingFormat:@"?%@", appendType];
            }
            else {
                urlWithMode = [URL stringByAppendingFormat:@"&%@", appendType];
            }
        }
    }
    return urlWithMode;
}

+ (NSString *)addParamSuccessToURL:(NSString *)URL {
    if ([URL containsString:kLoginBackUrl]) {
        if ([URL containsString:SNLinks_Domain_W]) {
            NSRange range = [URL rangeOfString:kLoginBackUrl];
            URL = [URL substringFromIndex:range.length];
        }else {
            URL = [[URL componentsSeparatedByString:kLoginBackUrl] lastObject];
        }
    }
    NSString *urlWithSuccess = nil;
    if ([URL containsString:SNLinks_Domain_W]) {
        urlWithSuccess = [NSString stringWithFormat:kH5LoginUrl, [URL URLEncodedString]];//H5联合登陆数据
    }else {
        urlWithSuccess = URL;
    }
    NSString *status = nil;
    if ([SNUserManager isLogin]) {
        status = @"1";
    }
    else {
        status = @"0";
    }
    if (NSNotFound == [urlWithSuccess rangeOfString:@"success=" options:NSCaseInsensitiveSearch].location) {
        if(URL.length) {
            if(NSNotFound == [urlWithSuccess rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                urlWithSuccess = [urlWithSuccess stringByAppendingFormat:@"?success=%@", status];
            }
            else {
                urlWithSuccess = [urlWithSuccess stringByAppendingFormat:@"&success=%@", status];
            }
        }
    }
    
    //v5.2.2
    urlWithSuccess = [urlWithSuccess stringByAppendingString:[NSString stringWithFormat:@"&p1=%@&u=%@&gid=%@&pid=%@&p2=%@&sdk=%@&ver=%@&token=%@", [SNUserManager getP1], [SNAPI productId], [SNUserManager getGid], [SNUserManager getPid], [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], [[UIDevice currentDevice] systemVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [SNUserManager getToken]]];
    
    //    if ([URL containsString:@"redpacket.sohu.com"]) {
    //        urlWithSuccess = [urlWithSuccess stringByAppendingFormat:@"&isSupportRedPacket=%d", [SNRedPacketManager sharedInstance].joinActivity];
    //    }
    
    return urlWithSuccess;
}

+ (NSDictionary *)getParamsInfoWithUrl:(NSString *) url
{
    if (!url) {
        return nil;
    }
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    if ([url hasPrefix:kProtocolHTTP] || [url hasPrefix:kProtocolHTTPS]) {
        NSRange range = [url rangeOfString:@"?"];
        if(NSNotFound != range.location && range.location + 1 <= url.length) {
            NSString* subStr = [url substringFromIndex:range.location+1];
            NSArray* subArray = [subStr componentsSeparatedByString:@"&"];
            if(subArray.count > 0) {
                for(NSString* str in subArray) {
                    subArray = [str componentsSeparatedByString:@"="];
                    if(subArray.count == 2) {
                        NSString *key = [subArray objectAtIndex:0];
                        NSString *value = [subArray objectAtIndex:1];
                        if (key.length > 0 && value.length > 0) {
                            [paramsDic setObject:value forKey:key];
                        }
                    }
                }
            }
        }
    }
    
    return paramsDic;
}

+ (NSString *)addVideoCipherToURL:(NSString *)url {
    SNDebugLog(@"Add cipher: Original video url %@", url);
    SNDebugLog(@"Add cipher: forward host: %@", kForwardHost);
    
    //不是forward地址则原样返回
    if (![url startWith:kForwardHost]) {
        SNDebugLog(@"Add cipher: Not forward url, %@", url);
        return url;
    }
    //如果是forward地址则要加cipher参数
    else {
        
        //没有cipher参数则加上
        if (NSNotFound == [url rangeOfString:@"cipher=" options:NSCaseInsensitiveSearch].location) {
            NSString *cipher = [self getCipher:url];
            SNDebugLog(@"Add cipher: Cipher is %@", cipher);
            
            NSString *encryptedURL = url;
            if (cipher.length > 0) {
                if (NSNotFound == [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                    encryptedURL = [url stringByAppendingFormat:@"?cipher=%@", cipher];
                }
                else {
                    encryptedURL = [url stringByAppendingFormat:@"&cipher=%@", cipher];
                }
                SNDebugLog(@"Add cipher: Encrypted url %@", encryptedURL);
            }
            else {
                SNDebugLog(@"Add cipher: Cipher is nil, encrypted url is %@", encryptedURL);
            }
            return encryptedURL;
        }
        //有cipher参数则原样返回
        else {
            SNDebugLog(@"Add cipher: Forward url had contain cipher parameter, %@", url);
            return url;
        }
    }
}

+ (NSString *)addVideoP1ToURL:(NSString *)url {
    SNDebugLog(@"Add video p1: Original video url %@", url);
    SNDebugLog(@"Add video p1: forward host: %@", kForwardHost);
    
    //不是forward地址则原样返回
    if (![url startWith:kForwardHost]) {
        SNDebugLog(@"Add video p1: Not forward url, %@", url);
        return url;
    }
    else {
        
        //没有p1则加上
        if (NSNotFound == [url rangeOfString:@"p1=" options:NSCaseInsensitiveSearch].location) {
            NSString *p1 = [self getP1];
            SNDebugLog(@"Add video p1: p1 is %@", p1);
            
            NSString *p1URL = url;
            if (p1.length > 0) {
                if (NSNotFound == [url rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                    p1URL = [url stringByAppendingFormat:@"?p1=%@", p1];
                }
                else {
                    p1URL = [url stringByAppendingFormat:@"&p1=%@", p1];
                }
                SNDebugLog(@"Add video p1: Added p1 url %@", p1URL);
            }
            return p1URL;
        }
        //有p1则原样返回
        else {
            SNDebugLog(@"Add video p1: Forward url had contain p1 parameter, %@", url);
            return url;
        }
    }
}

+ (NSString *)getCipher:(NSString *)notEncryptedURL {
    NSString *url = notEncryptedURL.length > 0 ? notEncryptedURL : @"";
    
    NSString *p1 = [self getP1];
    p1 = p1.length > 0 ? p1 : @"";
    
    NSString *privateKey = @"MKRq0G8b0HouRuqV6cW5v";
    NSString *notEncryptedCipher = [NSString stringWithFormat:@"%@%@%@", url, p1, privateKey];
    SNDebugLog(@"Not encrypted cipher: %@", notEncryptedCipher);
    
    NSString *cipher = [notEncryptedCipher md5Hash];
    SNDebugLog(@"Encrypted cipher: %@", cipher);
    
    return cipher;
}

+ (NSString *)copyrightText
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger year = [components year];
    return [NSString stringWithFormat:@"Copyright © %ld Sohu.com,Inc.All Rights Reserved", (long)year];
}

+ (void)showNoWifiTipForPhotosWithKey:(NSString *)key {
    if (key.length <= 0) {
        return;
    }
    
    if ([[SNUtility getApplicationDelegate] currentNetworkStatus] != ReachableViaWiFi) {
        // 非wifi模式下每天提示用户一次
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:
                                   (NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                               fromDate:[NSDate date]];
        NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)comps.year, (long)comps.month, (long)comps.day];
        
        NSString *currentStr = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (currentStr == nil || ![currentStr isEqualToString:dateStr]) {
            [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SNNotificationCenter showNoWifiTitle:NSLocalizedString(@"photoNoWifiTitle",@"")
                                           detail:NSLocalizedString(@"photoNoWifiInfo",@"")
                                        hideAfter:2];
        }
    }
}

+(NSString*)getCFUUID
{
    NSUserDefaults* standardUserDefault = [NSUserDefaults standardUserDefaults];
    NSString* device = [standardUserDefault objectForKey:@"deviceId"];
    
    if(device!=nil)
        return device;
    else
    {
        CFUUIDRef deviceId = CFUUIDCreate (NULL);
        CFStringRef deviceIdStringRef = CFUUIDCreateString(NULL,deviceId);
        
        NSString* deviceIdString = CFBridgingRelease(deviceIdStringRef);
        [standardUserDefault setValue:deviceIdString forKey:@"deviceId"];
        [standardUserDefault synchronize];
        CFRelease(deviceId);
        return deviceIdString;
    }
}

//3.4去掉小号字体，改为三种字体 lijian 2015.05.13 组图的文字和行间距使用了这里。
+ (CGPoint)getNewsFontSizePoint {
    static float fontSizeArray[] = {0, 14, 18, 22, 28};
    static float fontLineHeight[] = {0, 20, 29, 31, 38};
    int fontIndex = [SNUtility getNewsFontSizeIndex];
    
    fontIndex = MAX(2, fontIndex);
    return CGPointMake(fontSizeArray[fontIndex], fontLineHeight[fontIndex]);
}

+ (CGFloat)newsContentFontSize
{
    static float fontSizeArray[] = {13, 16, 18, 22};
    NSString *savedFontClass = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    int fontIndex = savedFontClass ? [[savedFontClass stringByReplacingOccurrencesOfString:@"font" withString:@""] intValue]
    : 2;
    
    fontIndex = MAX(2, MIN(4, fontIndex)) - 1;
    return fontSizeArray[fontIndex];
    
}

+ (CGFloat)newsContentFontLineheight
{
    static float fontLineHeight[] = {22, 25, 30, 39};
    NSString *savedFontClass = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    int fontIndex = savedFontClass ? [[savedFontClass stringByReplacingOccurrencesOfString:@"font" withString:@""] intValue]
    : 2;
    
    fontIndex = MAX(2, MIN(4, fontIndex)) - 1;
    return fontLineHeight[fontIndex];
}

+ (int)getDefaultFontSizeIndex
{
    return 2;
}

+ (int)getNewsFontSizeIndex
{
    int currentfontSize = [SNUtility getDefaultFontSizeIndex];
    NSString *savedFont = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    if ([savedFont isEqualToString:kWordMoreBig])
    {
        currentfontSize = 5;
    }
    else if ([savedFont isEqualToString:kWordBig])
    {
        currentfontSize = 4;
    }
    else if ([savedFont isEqualToString:kWordMiddle])
    {
        currentfontSize = 3;
    }
    else if ([savedFont isEqualToString:kWordSmall] || [savedFont isEqualToString:kWordSmall1]){
        currentfontSize = 2;
    }
    
    return currentfontSize;
}

+ (NSString *)getNewsFontSizeClass
{
    NSString *savedFontClass = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    return savedFontClass;
}

+ (NSString *)getNewsFontSizeLabelText
{
    NSString *text = nil;
    NSString *savedFontClass = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    //文本换为大中小，对于原来的超大，大，中
    if ([savedFontClass isEqualToString:kWordMoreBig]){
        text = @"特大";
    }
    else if ([savedFontClass isEqualToString:kWordBig]){
        text = @"大";
    }
    else if ([savedFontClass isEqualToString:kWordMiddle]) {
        text = @"中";
    }
    else if ([savedFontClass isEqualToString:kWordSmall] || [savedFontClass isEqualToString:kWordSmall1]){
        text = @"小";
    }
   
    
    return text;
}

+ (void)setNewsFontSize:(NSInteger)fontSize
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"font%ld", fontSize] forKey:kNewsFontClass];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:fontSize - 2] forKey:@"settings_fontSize"];
    
    
    //特大，超大字体从3开始，大中小规则不变
    NSInteger size = fontSize >= 5 ? fontSize-2 : 4-fontSize;
    [self sendSettingModeType:SNUserSettingFontMode mode:[NSString stringWithFormat:@"%ld", size]];
    
    [SNNotificationManager postNotificationName:kFontModeChangeNotification object:nil];
}

+ (void)setFontSize:(SNSettingFontSize)fontSize
{
    [SNUtility setFontSize:fontSize showText:NO];
}

+ (void)setFontSize:(SNSettingFontSize)fontSize showText:(BOOL)show
{
    SNSettingFontSize defaultSize = [SNUtility getFontSize];
    if(fontSize == defaultSize)
        return;
    NSString* fontString = kWordBig;
    NSString* text = nil;
    switch (fontSize)
    {
        case SNSettingSmallFont:
            fontString = kWordSmall;
            text = NSLocalizedString(@"SmallFont", "Small Font");
            break;
        case SNSettingMiddleFont:
            fontString = kWordMiddle;
            text = NSLocalizedString(@"MediumFont", "Medium Font");
            break;
        case SNSettingBigFont:
            fontString = kWordBig;
            text = NSLocalizedString(@"LargeFont", "Large Font");
            break;
        case SNSettingMoreBigFont:
            fontString = kWordMoreBig;
            text = NSLocalizedString(@"MoreLargeFont", "MoreLarge Font");
            break;
        default:
            fontString = kWordBig;
            text = NSLocalizedString(@"LargeFont", "Large Font");
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:fontString forKey:kNewsFontClass];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SNNotificationManager postNotificationName:kFontModeChangeNotification object:nil];
    if(show) {
        if (SNSettingMoreBigFont == fontSize) {
           [[SNCenterToast shareInstance] showCenterToastWithTitle:text toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:text toUrl:nil mode:SNCenterToastModeSuccess];
        }
        
    }
}

+ (SNSettingFontSize)getFontSize
{
    NSString* fontString = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    if(!fontString || fontString.length==0)
        return SNSettingBigFont;
    if([fontString isEqualToString:kWordSmall])
        return SNSettingSmallFont;
    else if([fontString isEqualToString:kWordMiddle])
        return SNSettingMiddleFont;
    else if([fontString isEqualToString:kWordBig])
        return SNSettingBigFont;
    else if([fontString isEqualToString:kWordMoreBig])
        return SNSettingMoreBigFont;
    else
        return SNSettingBigFont;
}

+ (UIFont *)getNewsTitleFont{
    UIFont *titleFont = nil;
    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeE];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeH];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeM];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeN];
                break;
                
            default:
                break;
        }
        
    }
    else{
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeE];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeH];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSizeType:UIFontSizeTypeN];
                break;
                
            default:
                break;
        }
    }
    return titleFont;
}

+ (UIFont *)getFeedUserNameFont{
    UIFontSizeType fontType = UIFontSizeTypeE;
    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontsize) {
            case 2:
                fontType = UIFontSizeTypeE;
                break;
            case 3:
                fontType = UIFontSizeTypeH;
                break;
            case 4:
                fontType = UIFontSizeTypeM;
                break;
            case 5:
                fontType = UIFontSizeTypeN;
                break;
                
            default:
                break;
        }
        
    }
    else{
        switch (fontsize) {
            case 2:
                fontType = UIFontSizeTypeD;
                break;
            case 3:
                fontType = UIFontSizeTypeE;
                break;
            case 4:
                fontType = UIFontSizeTypeH;
                break;
            case 5:
                fontType = UIFontSizeTypeN;
                break;
                
            default:
                break;
        }
    }
    
    float fontSize = [UIFont fontSizeWithType:fontType];
    return [UIFont systemFontOfSize:fontSize - 1];
}

+ (UIFont *)getTopTitleFont {
    UIFont *titleFont = nil;
    int fontsize = [SNUtility getNewsFontSizeIndex];
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:50/3.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:52/3.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:54/3.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:54/3.f];
             break;
                
            default:
                break;
                
        }
    }
    else{
        switch (fontsize) {
            case 2:
                titleFont = [UIFont systemFontOfSize:28/2.f];
                break;
            case 3:
                titleFont = [UIFont systemFontOfSize:30/2.f];
                break;
            case 4:
                titleFont = [UIFont systemFontOfSize:32/2.f];
                break;
            case 5:
                titleFont = [UIFont systemFontOfSize:32/2.f];
                break;
            default:
                break;
                
        }
    }
    return titleFont;
}

+ (float)getNewsTitleFontSize{
    int fontSize = [SNUtility getNewsFontSizeIndex];
    float titleFontSize = 0.0;
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontSize) {
            case 2:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeE];
                break;
            case 3:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeH];
                break;
            case 4:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeM];
                break;
            case 5:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeN];
                break;
                
            default:
                break;
        }
        
    }
    else{
        switch (fontSize) {
            case 2:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeD];
                break;
            case 3:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeE];
                break;
            case 4:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeH];
                break;
            case 5:
                titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeN];
                break;
                
            default:
                break;
        }
    }
    return titleFontSize;
}

+ (float)getNewsTitleHeight{
    int fontSize = [SNUtility getNewsFontSizeIndex];
    float titleHeight = 0.0;
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontSize) {
            case 2:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeE] + 3;
                break;
            case 3:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeH] + 3;
                break;
            case 4:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeM] + 4;
                break;
            case 5:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeN] + 4;
                break;
                
            default:
                break;
        }
        
    }
    else{
        switch (fontSize) {
            case 2:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeD] + 2;
                break;
            case 3:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeE] + 2;
                break;
            case 4:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeH] + 3;
                break;
            case 5:
                titleHeight = [UIFont fontSizeWithType:UIFontSizeTypeN] + 3;
                break;
                
            default:
                break;
        }
    }
    return titleHeight;
}

+ (void)setBiggerFontSize
{
    SNSettingFontSize fontSize = [self getFontSize];
    NSInteger sendFontSize = 0;
    switch (fontSize)
    {
        case SNSettingSmallFont:
            [self setFontSize:SNSettingMiddleFont showText:YES];
            sendFontSize = 3;
            break;
        case SNSettingMiddleFont:
            [self setFontSize:SNSettingBigFont showText:YES];
            sendFontSize = 4;
            break;
        case SNSettingBigFont:
            [self setFontSize:SNSettingMoreBigFont showText:YES];
            sendFontSize = 5;
            break;
        case SNSettingMoreBigFont:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已是最大字号" toUrl:nil mode:SNCenterToastModeOnlyText];
            break;
        default:
            break;
    }
    
    if (sendFontSize != 0 ) {
        //特大，超大字体从3开始，大中小规则不变
        NSInteger size = sendFontSize >= 5 ? sendFontSize-2 : 4-sendFontSize;
        [self sendSettingModeType:SNUserSettingFontMode mode:[NSString stringWithFormat:@"%ld", size]];
    }
}

+ (void)setSmallerFontSize
{
    SNSettingFontSize fontSize = [self getFontSize];
    NSInteger sendFontSize = 0;
    switch (fontSize)
    {
        case SNSettingSmallFont:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已是最小字号" toUrl:nil mode:SNCenterToastModeOnlyText];
            break;
        case SNSettingMiddleFont:
            [self setFontSize:SNSettingSmallFont showText:YES];
            sendFontSize = 2;
            break;
        case SNSettingBigFont:
            [self setFontSize:SNSettingMiddleFont showText:YES];
            sendFontSize = 3;
            break;
        case SNSettingMoreBigFont:
            [self setFontSize:SNSettingBigFont showText:YES];
            sendFontSize = 4;
            break;
        default:
            break;
    }
    
    if (sendFontSize != 0 ) {
        //特大，超大字体从3开始，大中小规则不变
        NSInteger size = sendFontSize >= 5 ? sendFontSize-2 : 4-sendFontSize;
        [self sendSettingModeType:SNUserSettingFontMode mode:[NSString stringWithFormat:@"%ld", size]];
    }
}

+ (void)setH5NewsFontSize:(NSInteger)fontSize
{
    switch (fontSize) {
        case 2:
            [self setFontSize:SNSettingMiddleFont showText:NO];
            break;
        case 3:
            [self setFontSize:SNSettingBigFont showText:NO];
            break;
        case 4:
            [self setFontSize:SNSettingMoreBigFont showText:NO];
            break;
        default:
            break;
    }
    [self sendSettingModeType:SNUserSettingFontMode mode:[NSString stringWithFormat:@"%ld", fontSize]];
}

+ (BOOL)shownBigerFont{
    NSString *savedFont = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    return [savedFont isEqualToString:kWordMoreBig];
}

+ (BOOL)changePGCLayOut{
    NSString *savedFont = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsFontClass];
    if (![SNDevice sharedInstance].isMoreThan320 && ![savedFont isEqualToString:kWordSmall] && ![savedFont isEqualToString:kWordSmall1] ) {
        return YES;
    }
    return NO;
}

+ (NSString *)link2Format:(NSString *)link2
{
    NSInteger index = [link2 rangeOfString:@":"].location;
    if (index != NSNotFound) {
        NSString *protcol = [link2 substringToIndex:index];
        if (link2.length > index + 3) {
            NSArray *arr = [[link2 substringFromIndex:(index+3)] componentsSeparatedByString:@"&"];
            if (arr.count > 1) {
                arr = [arr sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
                NSString *newLink2 = [NSString stringWithFormat:@"%@://%@",protcol,[arr componentsJoinedByString:@"&"]];
                return newLink2;
            }
        }
    }
    return link2;
}

+ (BOOL)isNetworkWWANReachable {
    return [[SNUtility getApplicationDelegate] isWWANNetworkReachable];
}

+ (BOOL)isNetworkReachable {
    return [[SNUtility getApplicationDelegate] isNetworkReachable];
}

- (CTTelephonyNetworkInfo *)tNetworkInfo {
    if (_tNetworkInfo == nil) {
        _tNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return _tNetworkInfo;
}

- (NSString *)getCarrierName {
    return self.tNetworkInfo.subscriberCellularProvider.carrierName;
}

- (NSString *)getCountryCode {
    return self.tNetworkInfo.subscriberCellularProvider.mobileCountryCode;
}

- (NSString *)getNetworkCode {
    return self.tNetworkInfo.subscriberCellularProvider.mobileNetworkCode;
}

- (NSString *)getRadioAccessTechnology {
    return self.tNetworkInfo.currentRadioAccessTechnology;
}

+ (BOOL)isWebpEnabled {
    return [SNPreference sharedInstance].webpEnabled;
}

+ (BOOL)needCommentControlTip:(NSString *)cmtStatus
                currentStatus:(NSString*)curStatus
                          tip:(NSString *)cmtHint
                     isBottom:(BOOL)bottom
{
    if (cmtStatus.length <= 0 || curStatus.length <=0 || cmtHint.length <= 0) {
        return NO;
    }
    
    if ([cmtStatus isEqualToString:curStatus] &&
        ([cmtStatus isEqualToString:kCommentStsForbidAudio] ||
         [cmtStatus isEqualToString:kCommentStsForbidImage])) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:cmtHint toUrl:nil mode:SNCenterToastModeOnlyText];
            return YES;
        }
    else if (![curStatus isEqualToString:kCommentStsForbidAll] &&
             [cmtStatus isEqualToString:kCommentStsForbidMedia]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:cmtHint toUrl:nil mode:SNCenterToastModeOnlyText];
        return YES;
    }
    else if ([cmtStatus isEqualToString:kCommentStsForbidAll]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:cmtHint toUrl:nil mode:SNCenterToastModeOnlyText];
        return YES;
    }
    else if ([cmtStatus isEqualToString:kCommentStsNormal]) {
        return NO;
    }
    else {
        return NO;
    }
}

+ (void)setCmtRemarkTips:(NSString *)curTips
{
    if (curTips.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:curTips forKey:kCommentRemarkTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString*)extractionCookie:(NSString*)aUrl key:(NSString*)aKey
{
    if (aUrl.length == 0) {
        return nil;
    }
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:aUrl]];
    
    NSString *cookieHeader = nil;
    for(NSHTTPCookie* cookie in cookies)
    {
        SNDebugLog(@"COOKIE{name: %@, value: %@}", [cookie name], [cookie value]);
        if(cookieHeader.length==0)
            cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
        else if([cookie name].length>0)
            cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
    }
    return cookieHeader;
}

+ (NSString *)getAccessTokenInWebCookie:(NSString *)urlString cookieName:(NSString *)cookieName {
    if (urlString.length == 0) {
        return nil;
    }
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:urlString]];
    NSString *accessToken = nil;
    for(NSHTTPCookie* cookie in cookies) {
        if ([[cookie name] isEqualToString:cookieName]) {
            accessToken = [cookie value];
            break;
        }
    }
    return accessToken;
}

+ (void)deleteCookieForUrl:(NSString *)url {
    if (url.length == 0) {
        return;
    }
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookiesArray = [cookieStorage cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in cookiesArray) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (void)deleteAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *allCookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in allCookies) {
        [cookieStorage deleteCookie:cookie];
    }
}

+ (NSString *)getHumanReadableTime:(double)secondsOfHumanUnreadable {
    NSUInteger dHours = floor(secondsOfHumanUnreadable / 3600);
    NSUInteger dMinutes = floor((NSUInteger)secondsOfHumanUnreadable%3600/60);
    NSUInteger dSeconds = floor((NSUInteger)secondsOfHumanUnreadable%3600%60);
    
    NSString *_humanReadableTime = nil;
    if (dHours>0) {
        _humanReadableTime = [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    else {
        _humanReadableTime = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes, (unsigned long)dSeconds];
    }
    return _humanReadableTime;
}

#pragma mark -判断设备

+ (NSString *)platformStringForSohuNews
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [currentDevice platformStringForSohuNews];
}


#pragma mark - File system size

+ (SNFileSystemSize *)getCachedFileSystemSize {
    SNStopWatch *_stopWatch = [SNStopWatch watch];
    [_stopWatch begin];
    
    SNFileSystemSize *_fileSystemSize = [[SNFileSystemSize alloc] init];
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        _fileSystemSize.totalFileSystemSizeInBytes = [fileSystemSizeInBytes unsignedLongLongValue];
        _fileSystemSize.freeFileSystemSizeInBytes = [freeFileSystemSizeInBytes unsignedLongLongValue];
        SNDebugLog(@"File System Size of %llu MiB with %llu MiB File System Free Size.",
                   ((_fileSystemSize.totalFileSystemSizeInBytes/1024ll)/1024ll), ((_fileSystemSize.freeFileSystemSizeInBytes/1024ll)/1024ll));
    } else {
        SNDebugLog(@"Error Obtaining File System Size Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
    [_stopWatch stop];
    [_stopWatch print:@"Refresh file system size"];
    return _fileSystemSize;
}

+ (NSString *)formatStrForMediaSize:(unsigned long long)mediaSize {
    NSString *str = nil;
    if (mediaSize >= 1024 * 1024 * 1024) {
        str = [NSString stringWithFormat:@"%.1fGB", mediaSize/(1024.0f*1024.0f*1024.0f)];
    } else if (mediaSize >= 1024 * 1024) {
        str = [NSString stringWithFormat:@"%.1fMB", mediaSize/(1024.0f*1024.0f)];
    } else if (mediaSize >= 1024) {
        str = [NSString stringWithFormat:@"%.1fK", mediaSize/1024.0f];
    } else if (mediaSize > 0) {
        str = [NSString stringWithFormat:@"%lluB", mediaSize];
    }
    return str;
}


+ (void)popToTabViewController:(UIViewController*)topViewController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBackRootFromSohuIconKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIViewController* topController = topViewController;
    if(topController == nil)
        topController = [TTNavigator navigator].topViewController;
    SNNavigationController* flipboardController = topController.flipboardNavigationController;
    [topController.flipboardNavigationController popToRootViewControllerAnimated:YES];
    //If navigation controller was presented, it will be dismissed
    while(flipboardController.presentingViewController)
    {
        //UIViewController* presentingController = flipboardController.presentingViewController;
        [flipboardController dismissViewControllerAnimated:YES completion:nil];
        topController = [TTNavigator navigator].topViewController;
        if(topController.flipboardNavigationController)
        {
            flipboardController = topController.flipboardNavigationController;
            [flipboardController popToRootViewControllerAnimated:YES];
        }
        else
        {
            flipboardController = nil;
        }
    }
}

+ (UIView *)addCoverViewForInfoIcon:(CGRect)frame {
    float coverAlpha = [[SNThemeManager sharedThemeManager] isNightTheme]? 0.3f:0.0f;
    UIView *coverView = [[UIView alloc] initWithFrame:frame];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.userInteractionEnabled = NO;
    coverView.alpha = coverAlpha;
    coverView.layer.cornerRadius = 11.0f;
    return coverView;
}

+ (NSString *)addNetSafeParametersForURL:(NSString *)urlString {
    SNDebugLog(@"Before net-safe-monitored url: %@", urlString);
    if (urlString.length <= 0) {
        return @"";
    }
    //内网IP
    NSString *innerIPKey = @"innerIp=";
    NSString *innerIPValue = [UIDevice ipAddress];
    //端口号
    NSString *portKey = @"port=";
    NSString *portValue = [UIDevice portID];
    //经度
    NSString *longitudeKey = @"longitude=";
    NSString *longitudeValue = [[SNUserLocationManager sharedInstance] getLongitude];
    //纬度
    NSString *latitudeKey = @"latitude=";
    NSString *latitudeValue = [[SNUserLocationManager sharedInstance] getLatitude];
    
    NSString *tempURLString = [[urlString lowercaseString] copy];
    BOOL isContainedQuestionMark = [tempURLString rangeOfString:@"?"].location != NSNotFound;
    if ([tempURLString rangeOfString:[innerIPKey lowercaseString]].location == NSNotFound) {
        urlString = [urlString stringByAppendingFormat:@"%@%@%@", (isContainedQuestionMark ? @"&" :@"?"), innerIPKey, innerIPValue];
    }
    
    if ([tempURLString rangeOfString:[portKey lowercaseString]].location == NSNotFound) {
        urlString = [urlString stringByAppendingFormat:@"&%@%@", portKey, portValue];
    }
    
    if ([tempURLString rangeOfString:[longitudeKey lowercaseString]].location == NSNotFound) {
        urlString = [urlString stringByAppendingFormat:@"&%@%@", longitudeKey, longitudeValue];
    }
    
    if ([tempURLString rangeOfString:[latitudeKey lowercaseString]].location == NSNotFound) {
        urlString = [urlString stringByAppendingFormat:@"&%@%@", latitudeKey, latitudeValue];
    }
    
    tempURLString = nil;
    SNDebugLog(@"After net-safe-monitored url: %@", urlString);
    return urlString;
}

+ (UIImage *)chooseActDefaultIconImage {
    UIImage *image = nil;
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0))
        image = [UIImage imageNamed:@"act_default_icon_ios6.png"];
    else
        image = [UIImage imageNamed:@"act_default_icon.png"];
    return image;
}

+ (UIImage *)chooseActEditIconImage {
    UIImage *image = nil;
    image = [UIImage imageNamed:@"act_edit_icon.png"];
    return image;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////V5.0版本///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Debug Util
+ (void)debugViews:(NSArray *)views {
#if kDebugSubBrowser
    for (id v in views) {
        if ([v isKindOfClass:v]) {
            [self debugView:v];
        }
    }
#endif
}

+ (void)debugView:(UIView *)v {
#if kDebugSubBrowser
    v.layer.borderWidth = 0.5;
    v.layer.borderColor = [UIColor redColor].CGColor;
#endif
}

#pragma mark - 二代协议相关
+ (BOOL)isSohuNewsProtocol:(NSString *)protocol {
    if (protocol.length > 0) {
        NSArray *sohuNewsProtocols = @[kProtocolSubHome, kProtocolNews, kProtocolPaper, kProtocolDataFlow,
                                       kProtocolSub, kProtocolPhoto, kProtocolLive,
                                       kProtocolSpecial, kProtocolFeedback, kProtocolWeibo,
                                       kProtocolVote, kProtocolNewsChannel, kProtocolWeiboChannel,
                                       kProtocolPhotoChannel, kProtocolLiveChannel, kProtocolSearch,
                                       kProtocolPlugin, kProtocolReadCircleDetail, kProtocolUserInfoProfile,
                                       kProtocolComment, kProtocolVideo, kProtocolOrgHome,
                                       kProtocolOrgColumn, kProtocolQRCode, kProtocolVideoMidia,
                                       kProtocolVideoPerson, kProtocolLogin, kProtocolMySubs,
                                       kProtocolHTTP, kProtocolHTTPS,kProtocolLandscape,kProtocolJoke,kProtocolCoupon];
        return [sohuNewsProtocols containsObject:protocol];
    } else {
        return NO;
    }
}

+ (UIView *)addMaskForImageViewWithRadius:(CGFloat)radius width:(CGFloat)width height:(CGFloat)height{
    UIView *view = [[UIView alloc] init];
    if (radius != 0) {
        view.frame = CGRectMake(-0.5, -0.5, width+1, height+1);
        view.layer.cornerRadius = radius+0.5;
        view.layer.masksToBounds = YES;
    }
    else
        view.frame = CGRectMake(0, 0, width, height);
    
    view.backgroundColor = [UIColor blackColor];
    
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        view.alpha = 0.7;
    }
    else
        view.alpha = 0;
    
    return view;
}

+ (NSString *)replaceString:(NSString *)str {
    NSArray *strArray = [str componentsSeparatedByString:@"/"];
    NSRange range = [str rangeOfString:[strArray lastObject]];
    NSString *changedStr = [NSString stringWithFormat:@"night/night_%@", [strArray lastObject]];
    NSString *newStr = [str stringByReplacingCharactersInRange:range withString:changedStr];
    return newStr;
}

+ (NSString *)statisticsDataChangeType:(NSString *)data {
    double dataDouble = [data doubleValue];
    NSString *dataString = nil;
    double dataTenThousand = dataDouble/10000;
    if (dataTenThousand < 1) {
        dataString = [NSString stringWithFormat:@"%.0f", dataDouble];
    }
    else if (dataTenThousand == 1 || (dataTenThousand < 10 && dataTenThousand >1)) {
        if (dataTenThousand == 1) {
            dataString = [NSString stringWithFormat:@"%.0f万", dataTenThousand];
        }
        else {
            NSInteger dataThousand = (NSInteger)(dataDouble/1000)%10;
            if (dataThousand == 9 || dataThousand == 0) {
                dataString = [NSString stringWithFormat:@"%.0f万", dataTenThousand];
            }
            else {
                dataString = [NSString stringWithFormat:@"%.1f万", dataTenThousand];
            }
        }
    }
    else if (dataTenThousand == 10 || (dataTenThousand < 10000 && dataTenThousand >10)) {
        dataString = [NSString stringWithFormat:@"%.0f万", dataTenThousand];
    }
    else if (dataTenThousand > 10000 || dataTenThousand == 10000) {
        if (dataTenThousand == 10000) {
            dataString = [NSString stringWithFormat:@"%.0f亿", dataTenThousand/10000];
        }
        else {
            NSInteger dataTenMillion = (NSInteger)(dataDouble/10000000)%10;
            if (dataTenMillion == 9 || dataTenMillion == 0) {
                dataString = [NSString stringWithFormat:@"%.0f亿", dataTenThousand/10000];
            }
            else {
                dataString = [NSString stringWithFormat:@"%.1f亿", dataTenThousand/10000];
            }
        }
    }
    return dataString;
}

+ (instancetype)sharedUtility {
    static dispatch_once_t onec;
    static SNUtility *instance = nil;
    
    dispatch_once(&onec, ^(){
        instance = [[SNUtility alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (void)popViewToRootController {
    [SNUtility popToTabViewController:[TTNavigator navigator].topViewController];
    sohunewsAppDelegate *app = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
    [[app appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    
    SNRollingNewsViewController *newsController = (SNRollingNewsViewController *)[[TTNavigator navigator] viewControllerForURL:@"tt://rollingNews"];
    
    if (nil != newsController) {
        dispatch_async(dispatch_get_main_queue(), ^()
                       {
                           //5.2.2 PUSH返回，首页重置 wyy
                           [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
                           newsController.tabBar.selectedChannelId = @"1";
                       });
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

+ (void)popViewToPreViewController {
    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewController];
}

+ (BOOL)isFromChannelManagerViewOpened {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isOpened = [[userDefaults objectForKey:kEnterChannelManageViewTag] boolValue];
    return isOpened;
}

+ (void)sendSettingModeType:(SNUserSettingModeType)settingModeType mode:(NSString *)mode {
    [[[SNUserSettingRequest alloc] initWithUserSettingMode:settingModeType andModeString:mode] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            [self setSettingResponse:responseObject];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.userInfo);
    }];
}


+ (void)setSettingResponse:(NSDictionary *)responseObject {
    NSDictionary *infoDict = [responseObject objectForKey:@"data"];
    if (infoDict && [infoDict isKindOfClass:[NSDictionary class]]) {
        NSString *newsPush = [infoDict stringValueForKey:@"newsPush" defaultValue:@""];
        NSString *readerPush = [infoDict stringValueForKey:@"readerPush" defaultValue:@""];//小说推送总开关
        NSString *imageMode = [infoDict stringValueForKey:@"image" defaultValue:@""];
        NSString *videoMode = [infoDict stringValueForKey:@"video" defaultValue:@""];
        NSString *fontMode = [infoDict stringValueForKey:@"font" defaultValue:@""];
        NSString *miniVideo = [infoDict stringValueForKey:@"videoMiniMode" defaultValue:@""];
        NSString *dayMode = nil;
        BOOL isNight;
        if ([[infoDict objectForKey:@"dayMode"] integerValue] == 1) {
            dayMode = kThemeNight;
            isNight = YES;
        }
        else {
            dayMode = kThemeDefault;
            isNight = NO;
        }
        
        NSString *imageMode1 = @"0";
        if (imageMode.integerValue == 1) {
            imageMode1 = @"2";
        } else if (imageMode.integerValue == 2) {
            imageMode1 = @"1";
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:newsPush forKey:kNewsPushSet];
        [userDefaults setObject:readerPush forKey:kReaderPushSet];
        [userDefaults setObject:imageMode1 forKey:kNonePictureModeKey];
        if (videoMode.length > 0 ) {
            if ([userDefaults objectForKey:kNoneVideoModeKey]) {//用户不曾手动设置，则以服务端setting.go返回为准
                [userDefaults setObject:videoMode forKey:kNoneVideoModeKey];
            }
        }
        
        if (fontMode.length == 0) {
            fontMode = @"1";//默认使用中号字体
        }
        
        if (miniVideo.length == 0) {
            miniVideo = @"0";//正文视频小窗功能默认开启0,关闭1
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //异步执行，避免启动随机死锁问题
            //客户端0，1，2，3对应大、中、小、特大字体，h5 0，1，2，3对应小、中、大、特大字体
            NSInteger fontSize = fontMode.integerValue;
            if (fontSize != 3) {
                fontSize = 2 - fontMode.integerValue;
            }
            
            JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
            [jsKitStorage setItem:[NSNumber numberWithInteger:fontSize] forKey:@"settings_fontSize"];
            [jsKitStorage setItem:[NSNumber numberWithBool:isNight] forKey:@"settings_nightMode"];
            [jsKitStorage setItem:[NSNumber numberWithInteger:imageMode.integerValue] forKey:@"settings_imageMode"];
        });
        
        NSInteger fontsize = [fontMode integerValue];
        fontsize = (fontsize > 2) ? fontsize+2 : 4-fontsize;
        [userDefaults setObject:[NSString stringWithFormat:@"font%ld", fontsize] forKey:kNewsFontClass];
        [userDefaults setObject:dayMode forKey:kThemeSelectedKey];
        [userDefaults setObject:miniVideo forKey:kNewsMiniVideoModeKey];
        [userDefaults synchronize];
        
        //设置关闭 夜间模式时间， 开关默认打开
        NSString *nightSwith = [infoDict stringValueForKey:@"smartSwitchForNightMode" defaultValue:@"1"];
        [[SNThemeManager sharedThemeManager] setCurrentTheme:dayMode];
        if (isNight == YES) {
            if (nightSwith.integerValue == 1) {
                //获取自动关闭夜间模式时间戳 (业务规定早上7点)
                NSDate *date = [SNUtility getSettingValidTime:7];
                [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewsThemeNightValidTime];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:nightSwith forKey:kNewsThemeNightSwitch];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SNNotificationManager postNotificationName:kThemeDidChangeNotification object:nil];
        [SNNotificationManager postNotificationName:kFontModeChangeNotification object:[NSNumber numberWithBool:YES]];
    }
    
}


+ (BOOL)isRightP1 {
    if ([SNUserManager getP1].length > 0 && ![[SNUserManager getP1] isEqualToString:[[kDefaultProfileClientID dataUsingEncoding:NSUTF8StringEncoding] base64String]]) {
        return YES;
    }
    return NO;
}

//corpus float
+ (void)executeFloatView:(id)delegate selector:(SEL)selector {
    [SNCloudSaveService corpusDataCloudSync:^{
        
        [SNCorpusList getCorpusListWithHandler:^(NSArray *corpusList) {
            if ([corpusList count] > 0) {
                SNCorpusAlertObject *alertObjct = [[SNCorpusAlertObject alloc] init];
                alertObjct.entry = @"2";
                alertObjct.corpusListArray = corpusList;
                [SNUtility sharedUtility].corpusAlertObjct = alertObjct;
                alertObjct.delegate = delegate;
                [alertObjct showCorpusAlertMenu:NO];
            } else {
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                BOOL firstUse = [[userDefault objectForKey:kFirstUseCollectTag] boolValue];
                if (!firstUse) {
                    [userDefault setObject:@"YES" forKey:kFirstUseCollectTag];
                    [userDefault synchronize];
                    
                    [SNCorpusAlertObject showEmptyCorpusAlert];
                    [delegate performSelector:selector withObject:nil afterDelay:0];
                } else {
                    [delegate performSelector:selector withObject:nil afterDelay:0];
                }
            }
        }];
    }];
}

+ (BOOL)isOpenMobileBindSwitch:(NSString *)soureceType {
    //判断服务端开关是否打开，确定是否弹手机绑定界面
    NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:[SNInterceptConfigManager configFilePath]];
    BOOL isShowMobileBind = NO;
    NSDictionary *globalDic = [configDict objectForKey:kUserActionInterceptInfoKeyGlobal];
    NSString *swithStr = [globalDic stringValueForKey:kUserActionInterceptInfoKeySwitch defaultValue:nil];
    if ([swithStr isEqualToString:@"1"]) {//总开关
        NSArray *actionList = [configDict objectForKey:kUserActionInterceptInfoKeyActionList];
        NSString *actionID = nil;
        NSString *actionLink = nil;
        if ([actionList count] > 0) {
            for (NSDictionary *actionDict in actionList) {
                actionID = [actionDict stringValueForKey:kUserActionInterCeptInfoKeyId defaultValue:nil];//登录来源
                actionLink = [actionDict stringValueForKey:kUserActionInterCeptInfoKeyActionLink defaultValue:nil];
                if ([actionLink isEqualToString:kUserActionInterceptClientActionBindMobileNum] && [soureceType isEqualToString:actionID]) {
                    isShowMobileBind = YES;
                    break;
                }
            }
        }
    }
    
    return isShowMobileBind;
}

+ (void)checkIsBindMobileWithResult:(void(^)(BOOL isBindMobile))result {
    
    NSString* passport = [SNUserinfoEx passport];
    if (passport) {
        [[[SNIsBindMobileRequest alloc] initWithDictionary:@{@"passport":passport}] send:^(SNBaseRequest *request, id jsonDict) {
            if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                
                NSInteger statusCode = [jsonDict[@"statusCode"]integerValue];
                if (statusCode == 10000000) {
                    NSInteger bindMobileStatus = [jsonDict[@"bindMobileStatus"] integerValue];
                    if(bindMobileStatus == 1){
                        if (result) result(YES);
                        return;
                    }
                    
                }
            }
            if (result) result(NO);
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"%@",error.localizedDescription);
            if (result) result(NO);
        }];
    } else {
        if (result) result(NO);
    }
}

+ (void)checkIsBindAlipayWithResult:(void(^)(BOOL isBindAlipay))result {
    
    [[[SNIsBindAlipayRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSInteger statusCode = [responseObject[@"statusCode"]integerValue];
            if (statusCode == 10000000) {
                if (result) result(YES);
                return;
            }
        }
        if (result) result(NO);
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"Error ocurred with:%d,%@ in %@", error.code, error.localizedDescription, NSStringFromSelector(_cmd));
        if (result) result(NO);
    }];
}

+ (void)setUserDefaultSourceType:(NSString *)soureceType keyString:(NSString *)keyString{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:soureceType forKey:keyString];
    [userDefaults synchronize];
}

+ (void)showToastWithID:(NSString *)corpusId folderName:(NSString *)folderName {
    NSString *toastString = kAlreadyMoveFinished;
    [[SNCenterToast shareInstance] showCenterToastWithTitle:toastString toUrl:nil mode:SNCenterToastModeOnlyText];
}

+ (BOOL)isChannelExitWithChannelID:(NSString *)channelID {
    BOOL isExit = NO;
    NSArray *channelList = [[SNDBManager currentDataBase] getSubedNewsChannelList];
    for (NewsChannelItem *item in channelList) {
        if ([channelID isEqualToString:item.channelId]) {
            isExit = YES;
            break;
        }
    }
    return isExit;
}

//从APPDelegate OpenUrl 转给SNS处理的外部协议
+ (BOOL)openSNSSchemeUrl:(NSString *)schemeUrl {
    
    if (NSNotFound != [schemeUrl rangeOfString:kSchemeUrlSNS options:NSCaseInsensitiveSearch].location) {
        [SNUtility shouldAddAnimationOnSpread:NO];
        [SNSLib actionFromOpenUrl:schemeUrl];
        return YES;
    }
    return NO;
}

- (void)setCurrentChannelId:(NSString *)currentChannelId {
    if (![_currentChannelId isEqualToString:currentChannelId]) {
        _currentChannelId = currentChannelId;
        //如果切换频道时, 重置状态
        [SNRollingNewsPublicManager sharedInstance].isRequestChannelData = NO;
    }
}

+ (NSString *)getCurrentChannelId {
    return [[self sharedUtility] currentChannelId] ? : @"";
}

+ (NSString *)getCurrentChannelCategoryID {
    return [[self sharedUtility] currentChannelCategoryID] ? : @"";
}

+ (BOOL)isHavePushSwitchOpened {
    NSString *newsPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kNewsPushSet];
    if ([newsPushSet isEqualToString:@"1"] || [newsPushSet isEqualToString:@"-1"]) {//快讯开关
        if ([newsPushSet isEqualToString:@"-1"]) {//避免覆盖安装时，取到到默认值为－1
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNewsPushSet];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return YES;
    }
    NSString *mediaPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kPaperPushSet];
    if ([mediaPushSet isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)judgeOldSubscribePushSwitch {
    NSArray *subscribeList = [[SNDBManager currentDataBase] getSubArrayWithoutYouMayLike];
    for (SCSubscribeObject *subscribeItem in subscribeList) {//订阅刊物开关
        if ([subscribeItem.isPush isEqualToString:@"1"]) {
            return YES;
        }
    }
    return NO;
}

+ (void)showSettingPushHalfFloatView:(BOOL)isOverIOS8 isFromSetting:(BOOL)isFromSetting {
    NSString *aDotURL = [SNUtility addNetSafeParametersForURL:@"_act=cc"];
    if (isFromSetting) {
        aDotURL = [aDotURL stringByAppendingString:@"&page=1&topage="];
    }
    else {
        aDotURL = [aDotURL stringByAppendingString:@"&page=0&topage="];
    }
    
    __block NSString *blockDotURL = aDotURL;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (isOverIOS8) {
        UIUserNotificationSettings* userSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone == userSetting.types || ![SNUtility isHavePushSwitchOpened]) {//iOS>=8.0
            SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:kPushSettingContent cancelButtonTitle:kPushTemporarily otherButtonTitle:kPushOpenImmediate];
            [alert show];
            [alert actionWithBlocksCancelButtonHandler:^{
                blockDotURL = [aDotURL stringByAppendingString:@"&fun=66"];
                [SNNewsReport reportADotGif:blockDotURL];
            } otherButtonHandler:^{
                if (UIUserNotificationTypeNone == userSetting.types) {
                    //iOS8以上支持，打开应用设置页
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                    if (![SNUtility isHavePushSwitchOpened]) {
                        [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                        if (!isFromSetting) {
                            [SNUtility setPushSettingRequest];
                        }
                    }
                }
                else {//open 快讯
                    [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                    if (!isFromSetting) {
                        [SNUtility setPushSettingRequest];
                    }
                }
                blockDotURL = [aDotURL stringByAppendingString:@"&fun=67"];
                [SNNewsReport reportADotGif:blockDotURL];
            }];
            if (!isFromSetting) {
                [userDefaults setObject:[NSDate date] forKey:kRecordFirstOpenNewsKey];
            }
        }
    }
    else {
        if (UIRemoteNotificationTypeNone == [[UIApplication sharedApplication] enabledRemoteNotificationTypes] || ![SNUtility isHavePushSwitchOpened]) {
            
            SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:kPushSettingContent cancelButtonTitle:kPushTemporarily otherButtonTitle:kPushOpenImmediate];
            [alert show];
            [alert actionWithBlocksCancelButtonHandler:^{
                blockDotURL = [aDotURL stringByAppendingString:@"&fun=66"];
                [SNNewsReport reportADotGif:blockDotURL];
            } otherButtonHandler:^{
                if (UIRemoteNotificationTypeNone == [[UIApplication sharedApplication] enabledRemoteNotificationTypes]) {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 解决iOS7通知浮层未弹出问题。。
                        
                        SNNewAlertView *notiAlert = [[SNNewAlertView alloc] initWithContentView:[self createNotiView]  cancelButtonTitle:nil otherButtonTitle:kLowVersionIKnow alertStyle:SNNewAlertViewStyleAlert];
                        [notiAlert show];
                    });
                    
                    if (![SNUtility isHavePushSwitchOpened]) {
                        [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                        if (!isFromSetting) {
                            [SNUtility setPushSettingRequest];
                        }
                    }
                }
                else {//open 快讯
                    [SNNotificationManager postNotificationName:kPushOpenNewsFlashNotification object:nil];
                    if (!isFromSetting) {
                        [SNUtility setPushSettingRequest];
                    }
                }
                blockDotURL = [aDotURL stringByAppendingString:@"&fun=67"];
                [SNNewsReport reportADotGif:blockDotURL];
                
            }];
            
            if (!isFromSetting) {
                [userDefaults setObject:[NSDate date] forKey:kRecordFirstOpenNewsKey];
            }
        }
    }
    [userDefaults synchronize];
}


+ (UIView *)createNotiView {
    CGFloat imageH = 124/667.0 * kAppScreenHeight;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0), imageH+133.0)];
    bgView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.width, imageH)];
    imageV.image = [UIImage imageNamed:@"icotooltip_zdzx_v5.png"];
    [bgView addSubview:imageV];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageH+20, bgView.width, 25)];
    titleLabel.text = @"第一时间获取重大新闻";
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    UILabel *massageLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, imageH+20+25+8, bgView.width - 22*2, 40)];
    massageLabel.text = @"打开设置,在“通知管理”或“应用管理”中选择搜狐新闻,开启通知。";
    massageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    massageLabel.textColor = SNUICOLOR(kThemeText4Color);
    massageLabel.numberOfLines = 0;
    massageLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [bgView addSubview:massageLabel];
    
    
    return bgView;
}

+ (void)setPushSettingRequest {
    
    [[[SNUserSettingRequest alloc] initWithUserSettingMode:SNUserSettingNewsPushMode andModeString:@"1"] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        if (status == 200) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kPushSettingOpened toUrl:nil mode:SNCenterToastModeSuccess];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"1" forKey:kNewsPushSet];
            [userDefaults synchronize];
        }

    } failure:nil];
    
}

+ (BOOL)isCoverInstallAPP {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *preVersion = [userDefaults objectForKey:kPreVersion];
    if (preVersion) {
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey];
        if (![preVersion isEqualToString:currentVersion]) {
            [userDefaults setObject:currentVersion forKey:kPreVersion];
            [userDefaults synchronize];
            return YES;
        }
    }
    return NO;
}

+ (void)saveHistoryShowWithChannel:(SNChannel *)channel isHouseChannel:(BOOL)isHouseChannel {
    if (!channel.channelName) {
        return;
    }
    NSString *defaultKey = nil;
    if (isHouseChannel) {
        defaultKey = kSaveSearchHouseArrayKey;
    }
    else {
        defaultKey = kSaveSearchCityArrayKey;
    }
    
    NSArray *channelArray = [self getHistoryShowChannel:isHouseChannel];
    for (SNChannel *chan in channelArray) {
        if ([chan.channelName isEqualToString:channel.channelName]) {
            return;//做个判断，待优化
        }
    }
    
    SNChannel *saveChannel = [[SNChannel alloc] init];
    saveChannel.channelName = channel.channelName;
    saveChannel.channelId = channel.channelId;
    saveChannel.gbcode = channel.gbcode;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:defaultKey]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveChannel];
        NSArray *array = [NSArray arrayWithObject:data];
        [userDefaults setObject:array forKey:defaultKey];
        [userDefaults synchronize];
    }
    else {
        NSArray *array = [userDefaults objectForKey:defaultKey];
        if ([array count] > 0) {
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveChannel];
            if (![mArray containsObject:data]) {
                if ([mArray count] < kSaveSearchCityArrayCount) {
                    [mArray addObject:data];
                }
                else {
                    [mArray removeObjectAtIndex:0];
                    [mArray addObject:data];
                }
                [userDefaults setObject:[NSArray arrayWithArray:mArray] forKey:defaultKey];
                [userDefaults synchronize];
            }
        }
    }
}

+ (NSArray *)getHistoryShowChannel:(BOOL)isHouseChannel {
    NSString *defaultKey = nil;
    if (isHouseChannel) {
        defaultKey = kSaveSearchHouseArrayKey;
    }
    else {
        defaultKey = kSaveSearchCityArrayKey;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:defaultKey]) {
        NSArray *array = [userDefaults objectForKey:defaultKey];
        NSMutableArray *channelArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [array count]; i++) {
            SNChannel *channel = (SNChannel *)[NSKeyedUnarchiver unarchiveObjectWithData:[array objectAtIndex:i]];
            [channelArray addObject:channel];
        }
        return [NSArray arrayWithArray:channelArray];
    }
    return nil;
}

+ (void)saveLocalChannel:(SNChannel *)channel isHouseChannel:(BOOL)isHouseChannel {
    NSString *defaultKey = nil;
    if (isHouseChannel) {
        defaultKey = kSaveLocalHouseKey;
    }
    else {
        defaultKey = kSaveLocalCityKey;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:channel];
    [userDefaults setObject:data forKey:defaultKey];
    [userDefaults synchronize];
}

+ (SNChannel *)getLocalChannel:(BOOL)isHouseChannel {
    NSString *defaultKey = nil;
    if (isHouseChannel) {
        defaultKey = kSaveLocalHouseKey;
    }
    else {
        defaultKey = kSaveLocalCityKey;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:defaultKey];
    SNChannel *channel = (SNChannel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return channel;
}

+ (SNChannel *)getThirdChannel {
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    for (NewsChannelItem *item in channelList) {
        if ([item.channelId isEqualToString:kLocalChannelUnifyID]) {
            SNChannel *channel = [[SNChannel alloc] init];
            channel.channelName = item.channelName;
            channel.channelId = item.channelId;
            channel.gbcode = item.gbcode;
            return channel;
        }
    }
    
    return nil;
}

+ (SNChannel *)getChannelByChannelID:(NSString *)channelID {
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    for (NewsChannelItem *item in channelList) {
        if ([item.channelId isEqualToString:channelID]) {
            SNChannel *channel = [[SNChannel alloc] init];
            channel.channelId =item.channelId;
            channel.channelName = item.channelName;
            channel.serverVersion = item.serverVersion;
            channel.isMixStream = item.isMixStream;
            return channel;
        }
    }
    
    return nil;
}

+ (NSInteger)getChannelIndexByChannelID:(NSString *)channelID {
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    NSInteger index = 0;
    for (NewsChannelItem *item in channelList) {
        if ([item.channelId isEqualToString:channelID]) {
            return index;
        }
        index ++;
    }
    return 0;
}

+ (NSString *)getFirstChannelID {
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    if ([channelList count] > 0) {
        NewsChannelItem *item = [channelList objectAtIndex:0];
        return item.channelId;;
    }
    return nil;
}

+ (BOOL)isAllowUseLocation {
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    BOOL locationServiceEnabled = [CLLocationManager locationServicesEnabled];
    if (!locationServiceEnabled || locationStatus == kCLAuthorizationStatusDenied) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)resetLocationChannelWithChannelID:(NSString *)channelID {
    [SNUserLocationManager sharedInstance].isRefreshLocation = NO;
    [SNUserLocationManager sharedInstance].isRefreshChannelLocation = YES;
    if (![SNUtility isAllowUseLocation]) {
        return NO;
    }
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:kIntelligetnLocationSwitchKey] boolValue]) {//智能定位打开,暂时使用283确定是否本地频道
        NSDate *lastDate = [userDefaults objectForKey:kRequestLocalChannelTimeKey];
        if (lastDate) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.minute = kRequestChannelExpireTime;
            NSDate *expiredDate = [calendar dateByAddingComponents:components toDate:lastDate options:0];
            if ([expiredDate compare:[NSDate date]] == NSOrderedAscending) {//距离上次刷新本地频道超过30分钟，自动显示为GPS锁定为的城市频道
                [userDefaults removeObjectForKey:kRequestLocalChannelTimeKey];
                [userDefaults synchronize];
                
                [[SNUserLocationManager sharedInstance] resetLocatingChannel];
                [[SNUserLocationManager sharedInstance] updateLocationUserData:[[NSNumber alloc] initWithInteger:1]];
                [SNUserLocationManager sharedInstance].refreshChannelBlock = ^(){
                    //30分钟定位刷新，只清除本地频道数据 wangyy
                    [[SNDBManager currentDataBase] clearRollingNewsListByChannelId:kLocalChannelUnifyID];
                    //重置频道，删除旧请求参数
                    [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:kLocalChannelUnifyID];
                    
                    SNChannel *channel = [SNUserLocationManager sharedInstance].currentCityChannel;
                    [SNUtility saveHistoryShowWithChannel:channel isHouseChannel:NO];
                    [[SNUserLocationManager sharedInstance] updateLocalChannelWithId:kLocalChannelUnifyID cityName:channel.channelName gbcode:channel.gbcode channelId:kLocalChannelUnifyID];
                };
                
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)needResetHomePageChannel {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [userDefaults objectForKey:kRequestHomePageTimeKey];
    if (lastDate) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.minute = [SNUtility getRefreshRollingNewsTime];
        NSDate *expiredDate = [calendar dateByAddingComponents:components toDate:lastDate options:0];
        if ([expiredDate compare:[NSDate date]] == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)changeSohuLinkToProtocol:(NSString *)linkUrl {
    //仅处理3g.k.sohu.com和m.k.sohu.com
    if (!([linkUrl containsString:SNLinks_Domain_3gK] || [linkUrl containsString:SNLinks_Domain_MK])) {
        return nil;
    }
    
    NSString *protocolString = nil;
    NSString *idString = nil;
    NSRange range;
    if ([linkUrl containsString:@"/t/n"]) {//图文
        range = [linkUrl rangeOfString:@"/t/n"];
        protocolString = [NSString stringWithFormat:@"%@newsId=", kProtocolNews];
    }
    else if ([linkUrl containsString:@"/p/n"]) {//组图
        range = [linkUrl rangeOfString:@"/p/n"];
        protocolString = [NSString stringWithFormat:@"%@gid=", kProtocolPhoto];
    }
    else if ([linkUrl containsString:@"/l/n"]) {//直播
        range = [linkUrl rangeOfString:@"/l/n"];
        protocolString = [NSString stringWithFormat:@"%@liveId=", kProtocolLive];
    }
    else if ([linkUrl containsString:@"/t/l"]) {//直播
        range = [linkUrl rangeOfString:@"/t/l"];
        protocolString = [NSString stringWithFormat:@"%@liveId=", kProtocolLive];
    }
    else if ([linkUrl containsString:@"/t/z"]) {//专题
        range = [linkUrl rangeOfString:@"/t/z"];
        protocolString = [NSString stringWithFormat:@"%@termId=", kProtocolSpecial];
    }
    else {
        return nil;
    }
    
    NSString *resultString = [linkUrl substringFromIndex:(range.location + 4)];
    NSArray *array = [resultString componentsSeparatedByString:@"/"];
    
    if ([array count] > 0) {
        idString = [array objectAtIndex:0];
        if ([idString containsString:@"?"]) {
            NSRange sRange = [idString rangeOfString:@"?"];
            idString = [idString substringToIndex:sRange.location];
        }
        protocolString = [NSString stringWithFormat:@"%@%@",protocolString, idString];
    }
    else {
        return nil;
    }
    
    return protocolString;
}

+ (BOOL)getSinaBindStatus {//wangshun bind
    return [SNH5NewsBindWeibo isNotBindWeibo];
}
#pragma mark - SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - 端内展现appstore
- (void)showAppStoreInApp:(NSURL *)appStoreURL {
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    if (isAllow != nil) {
        if (!_sKStoreProductViewController) {
            _sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
            _sKStoreProductViewController.delegate = self;
        }

        NSDictionary *productParams = @{ SKStoreProductParameterITunesItemIdentifier : [self appIdInURL:appStoreURL] };
        
        [_sKStoreProductViewController loadProductWithParameters:productParams                                                 completionBlock:^(BOOL result, NSError *error) {
            
            if (result) {
            }
            else{
                SNDebugLog(@"%@",error);
            }
        }];
        UIViewController *newsController = [TTNavigator navigator].topViewController;
        [newsController presentViewController:_sKStoreProductViewController
                                     animated:YES
                                   completion:nil];
        
    }
    else{
        //低于iOS6没有这个类
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}

- (NSString *)appIdInURL:(NSURL *)appStoreURL {
    NSString * appId = nil;
    if ([appStoreURL.absoluteString containsString:@"/id"]) {
        appId = [[appStoreURL.absoluteString componentsSeparatedByString:@"/id"] lastObject];
        if ([appId containsString:@"?"]) appId = [[appId componentsSeparatedByString:@"?"] firstObject];
    }
    
    return appId;
}

//对视图消失的处理
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        _sKStoreProductViewController.delegate = nil;
        _sKStoreProductViewController = nil;
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
    }];
}

+ (NSString *)getDeviceUDID {
    static NSString *savedUDID = nil;
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"kSohuNewsDeviceUDID" accessGroup:nil];
    savedUDID = [wrapper objectForKey:(id)kSecAttrAccount];
    if (savedUDID.length == 0) {
        savedUDID = [UIDevice deviceUDID];
        [wrapper setObject:savedUDID forKey:(id)kSecAttrAccount];
    }
    
    return savedUDID;
}

+ (NSString *)currentWebNetworkStatusString
{
    NetworkStatus networkStatus = [[SNUtility getApplicationDelegate] currentNetworkStatus];
    if (networkStatus == ReachableViaWiFi) {
        return @"wifi";
    }
    else if (networkStatus == ReachableViaWWAN ||
             networkStatus == ReachableVia2G ||
             networkStatus == ReachableVia3G ||
             networkStatus == ReachableVia4G) {
        return @"mobile";
    }
    else {
        return @"none";
    }
}

+ (BOOL)isConnectedToNetwork {
    NSString *reachStatus = [self currentWebNetworkStatusString];
    if ([reachStatus isEqualToString:@"NotReachable"]) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)missingCheckReportWithUrl:(NSString *)url {
    static int assignedNum = 1000;//是否为指定随机数，模拟1/10000的概率
    int randomNum = (int)(1 + (arc4random()%(10000)));//随机数范围[1,10000]
    if (assignedNum == randomNum) {//进行一次a.gif和n.gif
        url = [url stringByAppendingString:@"&statType=validate"];
        [[SNNewsReport shareInstance] reportWithUrl:url];
        
        url = [url stringByReplacingOccurrencesOfString:@"a.gif" withString:@"n.gif"];
        [[SNNewsReport shareInstance] reportWithUrl:url];
    }
}

+ (NSString *)aesEncryptWithString:(NSString *)string {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cid = [userDefaults objectForKey:kProfileClientIDKey];
    NSString *nowTime = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *verifyToken = [NSString stringWithFormat:@"%@_%@", cid, nowTime];
    NSString *plainText = [NSString stringWithFormat:@"cid=%@&verifytoken=%@&v=%@&p=%@&h=%d", cid, verifyToken, [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey], @"iOS", [SNUtility marketID]];//明文
    NSString *cipherText = [[SNRedPacketManager sharedInstance] aesEncryptWithData:plainText];//密文
    
    return [NSString stringWithFormat:@"%@&verifytoken=%@&ciphertext=%@&keyv=%@", string, verifyToken, cipherText, [[SNRedPacketManager sharedInstance] getKeyVersion]];
}

+ (NSString *)getShareNewsSourceType:(NSString *)urlString type:(int)type {
    
    if ([urlString hasPrefix:kProtocolVote] || [urlString containsString:@"newstype=12"]) {
        return type == 0 ? kNewsTypeVoteNews : @"vote";
    } else if ([urlString hasPrefix:kProtocolNews]) {
        return type == 0 ? kNewsTypePhotoAndText : @"news";
    }
    else if ([urlString hasPrefix:kProtocolPhoto]) {
        return type == 0 ? kNewsTypeGroupPhoto : @"group";
    }
    else if ([urlString hasPrefix:kProtocolWeibo]) {
        return type == 0 ? kNewsTypeWeibo : @"weibo";
    }
    else if ([urlString hasPrefix:kProtocolVideo]) {
        return type == 0 ? kNewsTypeVideo : @"video";
    }
    else if ([urlString hasPrefix:kProtocolSpecial]) {
        return type == 0 ? kNewsTypeSpecialNews : @"special";
    }
    else if ([urlString hasPrefix:kProtocolLive]) {
        return type == 0 ? kNewsTypeLive : @"live";
    }
    else if ([urlString hasPrefix:kProtocolPaper]) {
        return type == 0 ? kNewsTypePaper : @"paper";
    }
    else {
        return type == 0 ? kNewsTypePhotoAndText : @"news";
    }
    return 0;
}

+ (void)requestRedPackerAndCoupon:(NSString *)protocolContent type:(NSString *)type {
    @autoreleasepool {
        NSDictionary *jsonDict= nil;
        if ([SNUserManager isLogin]) {
            jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:[SNUserManager getP1], @"p1", [SNUserManager getPid], @"pid", [SNAPI productId], @"u", protocolContent, @"content", type, @"type", nil];
        } else {
            jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:[SNUserManager getP1], @"p1", [SNAPI productId], @"u", protocolContent, @"content", type, @"type", nil];
        }
        
        NSString *aesString = [[SNRedPacketManager sharedInstance] aesEncryptWithData:[jsonDict yajl_JSONString]];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        [params setValue:aesString forKey:@"data"];
        [params setValue:[[SNRedPacketManager sharedInstance] getKeyVersion] forKey:@"v"];
        [[[SNUgcPackRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            @autoreleasepool {
                NSObject *dataObj = [responseObject objectForKey:@"data"];
                if ([dataObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = (NSDictionary *)dataObj;
                    if (dataDict.count > 0) {
                        if ([[dataDict stringValueForKey:@"actType" defaultValue:@""] isEqualToString:@"1"]) {//显示红包
                            [SNUtility showRedPacketPopView:dataDict isActivity:NO];
                        }
                        else if ([[dataDict stringValueForKey:@"actType" defaultValue:@""] isEqualToString:@"2"]) {//显示优惠劵
                            [SNUtility showCouponFloatView:dataDict];
                        }
                    }
                }
            }

        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"%@",error.localizedDescription);
        }];
    }
}

#define kRedPacketTag  3450002

+ (void)showRedPacketPopView:(NSDictionary *)dictInfo isActivity:(BOOL)isActivity{
    
    UIView *subView = [[TTNavigator navigator].topViewController.view viewWithTag:kRedPacketTag];
    if (subView) {
        return;
    }
    
    NSString *type = [dictInfo stringValueForKey:kRedPacketType defaultValue:@""];
    SNRedPacketType typeValue = 0;
    if ([type isEqualToString:@"1"]) {
        typeValue = SNRedPacketNormal;
    }
    else if ([type isEqualToString:@"2"]) {
        typeValue = SNRedPacketTask;
    }
    else {
        typeValue = SNRedPacketOther;
    }
    
    SNRedPacketItem *redPacketItem = [SNRedPacketManager sharedInstance].redPacketItem;
    redPacketItem.sponsoredIcon = [dictInfo stringValueForKey:@"adImageURL" defaultValue:@""];
    redPacketItem.sponsoredTitle = [dictInfo stringValueForKey:@"adTitle" defaultValue:@""];
    redPacketItem.moneyValue = [dictInfo stringValueForKey:kRedPacketMoney defaultValue:@""];
    redPacketItem.moneyTitle = [dictInfo stringValueForKey:kDescription defaultValue:@""];
    redPacketItem.redPacketType = [dictInfo intValueForKey:kRedPacketType defaultValue:0];
    redPacketItem.redPacketInValid = 1;
    redPacketItem.redPacketId = [dictInfo stringValueForKey:@"packId" defaultValue:@""];
    redPacketItem.showAnimated = [[dictInfo stringValueForKey:@"isShowRedPacketRain" defaultValue:@""] boolValue];
    redPacketItem.delayTime = [dictInfo longValueForKey:@"showDelayTime" defaultValue:0];
    redPacketItem.isSlideUnlockRedpacket = [dictInfo intValueForKey:kIsSlideUnlockRedpacket defaultValue:1];
    redPacketItem.slideUnlockRedPacketText = [dictInfo stringValueForKey:kSlideUnlockRedPacketText defaultValue:@"将小图拖到指定位置解锁"];
    redPacketItem.jumpUrl = [dictInfo stringValueForKey:@"jumpUrl" defaultValue:@""];
    redPacketItem.nid = [dictInfo stringValueForKey:@"nid" defaultValue:@""];
    
    SNUserRedPacketView *userRedPacket = [[SNUserRedPacketView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight) redPacketType:typeValue];
    userRedPacket.backgroundColor = [UIColor clearColor];
    userRedPacket.isFromRedPacketActivity = isActivity;
    [userRedPacket updateContentView:redPacketItem];
    [userRedPacket showUserRedPacket];
    userRedPacket.tag = kRedPacketTag;
    [[TTNavigator navigator].topViewController.view addSubview:userRedPacket];
    if ([[TTNavigator navigator].topViewController isKindOfClass:NSClassFromString(@"SNRollingNewsTableController")]) {
        if ([[TTNavigator navigator].topViewController.tabbarView isKindOfClass:[SNTabbarView class]]) {
            SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
            [tabview showCoverLayer:YES];
        }
    }
    [SNRedPacketManager sharedInstance].redPacketShowing = YES;
    
    [SNNewsReport reportADotGif:@"_act=luckmoney&_tp=pop"];
}

+ (void)showCouponFloatView:(NSDictionary *)dictInfo {
    
    NSString *pushTitle = [dictInfo stringValueForKey:kDescription defaultValue:@""];
    SNNewAlertView *pushAlert = [[SNNewAlertView alloc] initWithTitle:pushTitle message:nil cancelButtonTitle:kTohoNoNeed otherButtonTitle:kImmediatelyPickUp];
    [pushAlert show];
    [pushAlert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        [SNUtility openProtocolUrl:[dictInfo stringValueForKey:@"url" defaultValue:@""]];
    }];
}

+ (NSString *)getPushMsgID:(NSString *)pushUrlString {
    NSString *schema = nil;
    if ([pushUrlString hasPrefix:kProtocolNews]) {
        schema = kProtocolNews;
    }
    else if ([pushUrlString hasPrefix:kProtocolPhoto]) {
        schema = kProtocolPhoto;
    }
    else if ([pushUrlString hasPrefix:kProtocolLive]) {
        schema = kProtocolLive;
    }
    else if ([pushUrlString hasPrefix:kProtocolSub]) {
        schema = kProtocolSub;
    }
    else if ([pushUrlString hasPrefix:kProtocolVote]) {
        schema = kProtocolVote;
    }
    else if ([pushUrlString hasPrefix:kProtocolChannel]) {
        schema = kProtocolChannel;
    }
    
    NSMutableDictionary *userInfo = [SNUtility parseProtocolUrl:pushUrlString schema:schema];
    
    return [userInfo objectForKey:@"msgId"];
}

+ (NSString *)getNewsItemAdId:(NSString *)link{
    //if ([link hasPrefix:@"http://"]) {
    if([SNAPI isWebURL:link]){
        NSRange range = [link rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            NSString *urlStr = [link substringFromIndex:range.location + 1];
            NSArray *substrings = [urlStr componentsSeparatedByString:@"&"];
            for (int x=0; x<substrings.count; x++) {
                
                NSString *strPart = [substrings objectAtIndex:x];
                NSArray *partItem = [strPart componentsSeparatedByString:@"="];
                if (partItem.count>=2) {
                    NSString *name = [partItem objectAtIndex:0];
                    NSString *value = [partItem objectAtIndex:1];
                    if (name&&value) {
                        if ([name isEqualToString:@"adId"]) {
                            return value;
                        }
                    }
                }
            }
        }
    }
    
    return nil;
}


+ (BOOL)channelVideoSwitchStatus {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kNoneVideoModeKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kChannelVideoSwitchKey];
    }
    else {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kNoneVideoModeKey] boolValue];
    }
}


+ (NSString *)getTabBarName:(NSInteger)index {
    SNAppConfigTabBar *configTabbar = [[SNAppConfigManager sharedInstance] configTabBar];
    NSArray *array = configTabbar.tabBarTextArray;
    if (index < [array count]) {
        NSString *name = [array objectAtIndex:index];
        if (name.length > 0) {
            return name;
        }
    }
    return nil;
}


+ (void)reportSNSShareLogWithType:(NSString *)type shareonInfo:(NSString *)shareonInfo originType:(NSString *)originType  {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *dateStr = [outputFormatter stringFromDate:[NSDate date]];
    
    NSString *logString = [NSString stringWithFormat:@"Type=sns&MdShare|%@|%@|%@|%@|%@", dateStr, [SNUserManager getUserId], type, shareonInfo, originType];
    [[SNLogManager sharedInstance] addLog:logString];
}

+ (void)recordShowEditModeNewsFromBack:(BOOL)fromBack {
    /******
     1.每天自早6点起，用户第一次进入客户端，首页默认展示编辑流
     2.在客户端使用过程中，已经曝光过编辑流至少一次的前提下，每天客户端在后台单次停留30分钟以上或杀掉进程，之后（直到次日凌晨6:00）每次进入客户端，首页默认展现现有推荐流内容
     ******/
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *nowEnterDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
//
//    NSDate *lastEnterAppDate = [userDefaults objectForKey:kRecordEveryDayEnterAppDateKey];
//    NSDate *enterBackAppDate = [userDefaults objectForKey:kRecordEnterBackgroundAppDateKey];
    BOOL showEditMode = NO;
//    if (!lastEnterAppDate) {
//        showEditMode = YES;
//        [self resetADParametes];
//    }
//    else {
//        NSDateComponents *nowCompoments = [SNUtility getComponentsForDate:nowEnterDate];
//        NSDate *fromDate = lastEnterAppDate;
//        if (fromBack) {
//            fromDate = enterBackAppDate;
//        }
//        NSDateComponents *lastCompoments = [SNUtility getComponentsForDate:fromDate];
//
//        if (nowCompoments.year > lastCompoments.year) {
//            showEditMode = YES;
//            [self resetADParametes];
//        }
//        else {
//            if (nowCompoments.month > lastCompoments.month) {
//                showEditMode = YES;
//                [self resetADParametes];
//            }
//            else {
//                if (nowCompoments.day > lastCompoments.day) {
//                    if (nowCompoments.day - lastCompoments.day > 1) {
//                        showEditMode = YES;
//                        [self resetADParametes];
//                    }
//                    else {
//                        if (nowCompoments.hour >= [SNUtility getResetEditRollingNewsTime]) {
//                            showEditMode = YES;
//                            [self resetADParametes];
//                        }
//                        else {
//                            showEditMode = NO;
//                        }
//                    }
//                }
//                else {
//                    if (fromBack) {
//                        if (![userDefaults boolForKey:kShouldShowEditModeNewsKey]) {
//                            showEditMode = NO;
//                        }
//                        else {
//                            if (nowCompoments.hour == lastCompoments.hour) {
//                                if (nowCompoments.minute - lastCompoments.minute >= [SNUtility getRefreshRollingNewsTime]) {
//                                    if (nowCompoments.hour == [SNUtility getResetEditRollingNewsTime]) {
//                                        showEditMode = YES;
//                                        [self resetADParametes];
//                                    }
//                                    else {
//                                        showEditMode = NO;
//                                    }
//                                }
//                                else {
//                                    showEditMode = YES;
//                                    [self resetADParametes];
//                                }
//                            }
//                            else {
//                                if (nowCompoments.hour == [SNUtility getResetEditRollingNewsTime]) {
//                                    showEditMode = YES;
//                                    [self resetADParametes];
//                                }
//                                else {
//                                    showEditMode = NO;
//                                }
//                            }
//                        }
//                    }
//                    else {
//                        if (lastCompoments.hour >= [SNUtility getResetEditRollingNewsTime] || nowCompoments.hour < [SNUtility getResetEditRollingNewsTime]) {
//                            showEditMode = NO;
//                        }
//                        else {
//                            showEditMode = YES;
//                            [self resetADParametes];
//                        }
//                    }
//                }
//            }
//        }
//    }
//    [userDefaults setObject:nowEnterDate forKey:kRecordEveryDayEnterAppDateKey];
    if ([SNUtility isNewDayToBackHomeChannel]) {
        showEditMode = YES;
        [self resetADParametes];
    }
    
    [userDefaults setBool:showEditMode forKey:kShouldShowEditModeNewsKey];
    [userDefaults synchronize];
}

+ (void)resetADParametes {
    [SNRollingNewsPublicManager sharedInstance].homeADCount = 0;
    [SNRollingNewsPublicManager sharedInstance].recomADCount = 0;
    [SNRollingNewsPublicManager sharedInstance].localADCount = 0;
    [SNRollingNewsPublicManager sharedInstance].entertainmentADCount = 0;
}

#pragma mark -  share
//wangshun share test
+ (NSMutableDictionary*)createShareData:(NSString*)pushURLStr Context:(NSDictionary*)context{
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSDictionary *shareInfoDict = [SNUtility parseURLParam:pushURLStr schema:kProtocolShare];
    if([pushURLStr rangeOfString:kProtocolFastShare].location != NSNotFound){
        if (shareInfoDict == nil) {
            shareInfoDict = [SNUtility parseURLParam:pushURLStr schema:kProtocolFastShare];
        }
    }

    NSString *shareOnString = [[shareInfoDict stringValueForKey:@"shareOn" defaultValue:@""] URLDecodedString];
    
    if ([SNUtility isProtocolV2:shareOnString]) {
        shareInfoDict = [SNUtility parseURLParam:shareOnString schema:kProtocolShare];
    }
    
    NSString *shareOrigin = [shareInfoDict objectForKey:@"shareOrigin"];
    if ([shareOrigin isEqualToString:@"universalWebView"]) {
        NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeADSpread];
        [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    }
    else if([shareOrigin isEqualToString:@"qianfan"]){
        NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeQianfan];
        [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    }
    else{
        NSString* sourceType = [shareInfoDict objectForKey:SNNewsShare_V4Upload_sourceType];
        if (!sourceType) {
            sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeActivityNoUgc];
            [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
        }
        else{
            [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
        }
    }
    
    if (shareInfoDict[@"contentType"] && [shareInfoDict[@"contentType"] isEqualToString:@"special"]){
        NSString* sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeSpecial];
        [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    }
    
    SNTimelineOriginContentObject* shareObj = [[SNTimelineOriginContentObject alloc] init];
    shareObj.title = [[NSString stringWithFormat:@"%@", [shareInfoDict stringValueForKey:kShareInfoKeyTitle defaultValue:@""]] URLDecodedString];
    shareObj.link = [[shareInfoDict stringValueForKey:@"link" defaultValue:@""] URLDecodedString];
    shareObj.description = [shareInfoDict stringValueForKey:@"description" defaultValue:@""];
    shareObj.picUrl = [[shareInfoDict stringValueForKey:@"icon" defaultValue:@""] URLDecodedString];
    shareObj.content = [[shareInfoDict stringValueForKey:@"content" defaultValue:@""] URLDecodedString];
    shareObj.type = ShareSubTypeQuoteCard;
    shareObj.subId = nil;
    
    [mDic setObject:shareObj.title?shareObj.title:@"" forKey:SNNewsShare_title];
    [mDic setObject:shareObj.link?shareObj.link:@"" forKey:SNNewsShare_webUrl];
    [mDic setObject:shareObj.link?shareObj.link:@"" forKey:SNNewsShare_Url];
    [mDic setObject:shareObj.content?shareObj.content:@"" forKey:SNNewsShare_content];
    
    NSString * contentType = [shareInfoDict stringValueForKey:@"contentType" defaultValue:@""];
    NSString * channelId   = [shareInfoDict stringValueForKey:@"channelId" defaultValue:@""];
    NSString * imageUrl    = [[shareInfoDict stringValueForKey:@"pics" defaultValue:@""] URLDecodedString];
    
    [mDic setObject:contentType?contentType:@"" forKey:SNNewsShare_ShareOn_contentType];
    [mDic setObject:channelId?channelId:@"" forKey:@"channelId"];
    [mDic setObject:imageUrl?imageUrl:@"" forKey:SNNewsShare_ImageUrl];
    
    if ([pushURLStr rangeOfString:@"&local_webview=1"].location != NSNotFound) {
        [mDic setObject:@"1" forKey:@"local_webview"];
    }
    
    NSString* shareon = [shareInfoDict stringValueForKey:kShareOnKey defaultValue:@""];
    [mDic setObject:shareon?shareon:@"" forKey:kShareOnKey];
    
    //origin 这个不知道干啥的 shareOn用
    NSString* origin  = [shareInfoDict stringValueForKey:kShareSubActivityPageKey defaultValue:@""];
    [mDic setObject:origin?origin:@"" forKey:kShareSubActivityPageKey];
    
    
    NSString *redPacket = [shareInfoDict stringValueForKey:@"redPacket" defaultValue:@""];
    if ([[shareInfoDict stringValueForKey:@"contentType" defaultValue:@""] isEqualToString:@"pack"] && redPacket.length == 0) {
        redPacket = [NSString stringWithFormat:@"shareUrl=%@", shareObj.link];
    }
    [mDic setObject:redPacket?redPacket:@"" forKey:@"redPacket"];
    
    NSString * refer       = [shareInfoDict stringValueForKey:@"refer" defaultValue:@""];
    NSString * referId     = [shareInfoDict stringValueForKey:@"referId" defaultValue:@""];
    if (referId.length != 0 && refer.length != 0) {
        [mDic setObject:[NSString stringWithFormat:@"%@=%@",refer,referId] forKey:@"referString"];
        shareObj.referId = referId;
    }
    
    [mDic setObject:[shareInfoDict stringValueForKey:@"sourceId" defaultValue:@""] forKey:kRedPacketIDKey];//红包统计需要
    
    if ([shareOrigin isEqualToString:@"qianfan"]) {
        
        shareObj.picUrl = [[shareInfoDict stringValueForKey:@"icon" defaultValue:@""] URLDecodedString];
        shareObj.subId = @"qianfan";
        [mDic setObject:[[shareInfoDict stringValueForKey:@"icon" defaultValue:@""] URLDecodedString] forKey:kShareInfoKeyImageUrl];
        [mDic setObject:[shareInfoDict stringValueForKey:@"roomID" defaultValue:@""] forKey:@"referId"];//给sns的唯一标识 sns服务端用来判断分享feed合并用的 @降文娟
        [mDic setObject:[shareInfoDict stringValueForKey:@"roomID" defaultValue:@""] forKey:@"roomID"];//shareOn.go 必参
        
        
        [mDic setObject:@"qianfan" forKey:SNNewsShare_ShareOn_contentType];
        [mDic setObject:@"qianfan" forKey:SNNewsShare_LOG_type];
        [mDic setObject:@"1" forKey:SNNewsShare_isQianfan];
    }
    
    [mDic setObject:shareObj forKey:kShareInfoKeyShareRead];

    NSString *shareonInfo = [[shareInfoDict stringValueForKey:kSNSShareonInfo defaultValue:@""] URLDecodedString];
    if (shareonInfo.length > 0) {
        [mDic setObject:shareonInfo?shareonInfo:@"" forKey:kSNSShareonInfo];
        [mDic setObject:@"sns" forKey:@"contentType"];
        //为了统计，解析shareonInfo
        NSString *newStr = [NSString stringWithFormat:@"%@%@", kProtocolNews, [shareonInfo URLDecodedString]];
        NSDictionary *newDict = [SNUtility parseProtocolUrl:newStr schema:kProtocolNews];
        if (newDict) {
            NSString *newsId = [newDict stringValueForKey:@"feed_id" defaultValue:@""];
            if (newsId.length == 0) {
                newsId = [newDict stringValueForKey:@"profile_user_id" defaultValue:@""];
            }
            [mDic setObject:newsId forKey:kShareInfoKeyNewsId];
        }
    }
    
    NSString *shareType = [shareInfoDict objectForKey:@"logstaisType"];//红包统计需要
    if (shareType.length == 0) {
        shareType = @"protocal";
    }

    if (context[@"shareLogType"] && [context[@"shareLogType"] isEqualToString:@"coupon"]) {
        [mDic setObject:@"coupon" forKey:SNNewsShare_LOG_type];
    }
    else{
        [mDic setObject:shareType forKey:SNNewsShare_LOG_type];
    }
    
    NSString* disableIcons = [shareInfoDict stringValueForKey:@"hideShareIcons" defaultValue:@"0"];
    [mDic setObject:disableIcons forKey:SNNewsShare_disableIcons];
    
    NSString* floatTitle = [[shareInfoDict stringValueForKey:@"floatTitle" defaultValue:@""] URLDecodedString];
    [mDic setObject:floatTitle forKey:SNNewsShare_ShareViewTitle];

    return mDic;
}

+ (void)callShare:(NSDictionary*)dic{
    if ([SNUtility sharedUtility].shareManager) {
        [SNUtility sharedUtility].shareManager = nil;
    }
    SNNewsShareManager* manager = [SNNewsShareManager loadShareData:dic Delegate:[SNUtility sharedUtility]];
    [SNUtility sharedUtility].shareManager = manager;
}

//直接调平台分享
+ (void)fastShareWithPlatform:(NSString* )title Data:(NSDictionary*)dic{
    if ([SNUtility sharedUtility].shareManager) {
        [SNUtility sharedUtility].shareManager = nil;
    }
    SNNewsShareManager* manager = [[SNNewsShareManager alloc] init];
    [SNUtility sharedUtility].shareManager = manager;
    
    [manager shareIconSelected:title ShareData:dic];
}

#pragma mark - End

+ (NSDateComponents *)getComponentsForDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compoments = [calendar components:(NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    NSString *dateString = [NSString stringWithFormat:@"%@", date];
    NSArray *dateArray = [dateString componentsSeparatedByString:@":"];
    if ([dateArray count] > 0) {
        NSString *firstString = [dateArray objectAtIndex:0];
        if (firstString.length > 8) {
            compoments.month = [[firstString substringWithRange:NSMakeRange(firstString.length - 8, 2)] integerValue];
            compoments.day = [[firstString substringWithRange:NSMakeRange(firstString.length - 5, 2)] integerValue];
            compoments.hour = [[firstString substringFromIndex:firstString.length-2] integerValue];
        }
    }
    
    return compoments;
}

+ (NSDate *)getSettingValidTime:(NSInteger)timeValue{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateformat stringFromDate:[NSDate date]];
    
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = nil;
    if (timeValue < 10) {
        date = [dateformat dateFromString:[NSString stringWithFormat:@"%@ 0%d:00:00", today, timeValue]];
    }
    else{
        date = [dateformat dateFromString:[NSString stringWithFormat:@"%@ %d:00:00", today, timeValue]];
    }
    
    //时间转时间戳
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    
    NSDateFormatter *dateFrom=[[NSDateFormatter alloc] init];
    [dateFrom setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval time = [timeSp doubleValue];
    
    NSDate *getDate = nil;
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    NSDateComponents *nowCompoments = [SNUtility getComponentsForDate:nowDate];
    if (nowCompoments.hour >= timeValue) {
        getDate = [NSDate dateWithTimeIntervalSince1970:time + 24*60*60];
    }
    else{
        getDate = [NSDate dateWithTimeIntervalSince1970:time];
    }
    
    NSDate *currentData = [SNUtility changeNowDateToSysytemDate:getDate];
    return currentData;
}

+ (NSDate *)getTodayValidTime:(NSInteger)timeValue{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateformat stringFromDate:[NSDate date]];
    
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = nil;
    if (timeValue < 10) {
        date = [dateformat dateFromString:[NSString stringWithFormat:@"%@ 0%d:00:00", today, timeValue]];
    }
    else{
        date = [dateformat dateFromString:[NSString stringWithFormat:@"%@ %d:00:00", today, timeValue]];
    }
    
    //时间转时间戳
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    
    NSDateFormatter *dateFrom=[[NSDateFormatter alloc] init];
    [dateFrom setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval time = [timeSp doubleValue];
    
    NSDate *getDate = nil;
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    NSDateComponents *nowCompoments = [SNUtility getComponentsForDate:nowDate];
    getDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDate *currentData = [SNUtility changeNowDateToSysytemDate:getDate];
    return currentData;
}

+ (BOOL)shouldShowEditMode {
    if ([SNPreference sharedInstance].testModeEnabled) {
        return YES;//测试环境无推荐流
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldShowEditModeNewsKey];
}

+ (NSInteger)getResetEditRollingNewsTime {
    //单位：时
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kEditRollingNewsRefreshTime];
    return [dict intValueForKey:@"startTime" defaultValue:6];
}

+ (NSInteger)getRefreshRollingNewsTime {
    //单位：分
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kEditRollingNewsRefreshTime];
    return [dict intValueForKey:@"interval" defaultValue:1800]/60;
}

+ (BOOL)getHttpsSwitchStatus {
#if defined SNPublicLinks_Https_Mode
    return YES;
#endif
    //return NO;
    
    SNAppConfigHttpsSwitch *httpsSwitchConfig = [[SNAppConfigManager sharedInstance] configHttpsSwitch];
    //return httpsSwitch.httpsSwitchStatus;
    
    NSString *httpsSwitch = [[NSUserDefaults standardUserDefaults] valueForKey:kHttpsSwitchStatusKey];
    BOOL isSmallSwitch = NO;
    if(httpsSwitch && [httpsSwitch length] > 0){
        isSmallSwitch = [httpsSwitch boolValue];
    }else{
        isSmallSwitch = httpsSwitchConfig.httpsSwitchStatus;
    }
    
    NSString *httpsSwitchAll = [[NSUserDefaults standardUserDefaults] valueForKey:kHttpsSwitchStatusAllKey];
    BOOL isBigSwitch = NO;
    if(httpsSwitchAll && [httpsSwitchAll length] > 0){
        isBigSwitch = [httpsSwitchAll boolValue];
    }else{
        isBigSwitch = httpsSwitchConfig.httpsSwitchStatusAll;
    }
    
    return (isSmallSwitch || isBigSwitch);
}

+ (void)shouldUseSpreadAnimation:(BOOL)use {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:use forKey:kUseSpreadAnimationKey];
    
    if ([SNUtility isNetworkReachable]) {
        [userDefaults setBool:YES forKey:kRecordNetWorkStatusKey];
    }
    else {
        [userDefaults setBool:NO forKey:kRecordNetWorkStatusKey];
    }
    
    [userDefaults synchronize];
}

+ (void)shouldAddAnimationOnSpread:(BOOL)add {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:add forKey:kRecordNetWorkStatusKey];
    [userDefaults synchronize];
}

+ (NSDate *)changeNowDateToSysytemDate:(NSDate *)nowDate {
    //转化为系统的时间
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval timeInterval = [zone secondsFromGMTForDate:nowDate];
    return [nowDate dateByAddingTimeInterval:timeInterval];
}

+ (void)trigerSpecialActivity {
    NSDictionary *activityInfo = [SNSpecialActivity shareInstance].activityInfo;
    if ([[activityInfo stringValueForKey:kSpecialActivityAdSwitch defaultValue:nil] intValue]) {
        [SNNotificationManager postNotificationName:kSpecialActivityShowNotification object:nil userInfo:@{kSpecialActivityShouldShowKey:[NSNumber numberWithBool:YES]}];
    }
}

+ (BOOL)shouldShowSpecialActivity {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[SNUtility getImagePathWithName:@"activity_1.png"]];
    if (!image || image.size.width == 0 || image.size.height == 0) {
        //图片资源未下载成功
        return NO;
    }
    
    BOOL showActivity = NO;
    NSDictionary *dict = [SNSpecialActivity shareInstance].activityInfo;
    if (dict) {
        showActivity = [[dict stringValueForKey:kSpecialActivityAdSwitch defaultValue:nil] intValue];
        //判定当天是否已显示过一次（广告定义以9-9点间为一个自然天）
        if (showActivity && ![SNUtility haveAlreadyShowSpecialActivityInToday]) {
            showActivity = YES;
        }
        else {
            showActivity = NO;
        }
    }
    
    return showActivity;
}

+ (BOOL)haveAlreadyShowSpecialActivityInToday {
    BOOL haveShow = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *nowDate = [NSDate date];
    NSDate *lastDate = (NSDate *)[userDefaults objectForKey:kSpecialActivityShowTimeKey];
    if (lastDate) {
        NSDateComponents *lastComponents = [SNUtility getComponentsForDate:lastDate];
        NSDateComponents *nowComponents = [SNUtility getComponentsForDate:[SNUtility changeNowDateToSysytemDate:nowDate]];
        if (nowComponents.year > lastComponents.year) {
            haveShow = NO;
        }
        else {
            if (nowComponents.month > lastComponents.month) {
                haveShow = NO;
            }
            else {
                if (nowComponents.day > lastComponents.day) {
                    if (nowComponents.day - lastComponents.day > 1) {
                        haveShow = NO;
                    }
                    else {
                        if (nowComponents.hour >= 9) {
                            haveShow = NO;
                        }
                        else {
                            haveShow = YES;
                        }
                    }
                }
                else {
                    if (lastComponents.hour < 9 && nowComponents.hour >= 9) {
                        haveShow = NO;
                    }
                    else {
                        haveShow = YES;
                    }
                }
            }
        }
    }
    
    if (!haveShow) {
        [userDefaults setObject:[SNUtility changeNowDateToSysytemDate:nowDate] forKey:kSpecialActivityShowTimeKey];
        [userDefaults synchronize];
    }
    
    return haveShow;
}

+ (void)clearPushCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[SNClearPushCountRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"%@",error.localizedDescription);
        }];
    });
}

+ (void)forceScreenPortrait {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

+ (BOOL)isPureNum:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (void)openUniversalWebView:(NSDictionary *)dict {
    SNWebViewManager *webViewManager = [[SNWebViewManager alloc] init];
    [webViewManager processWebViewWithDict:dict];
}

#pragma mark //A/B测试 4种界面风格类型

+ (BOOL)isABTestAppStyleChangeTime:(NSDate *)date{
    NSDate *validDate = [[NSUserDefaults standardUserDefaults] objectForKey:kABTestAppStyleChangeValidTime];
    if (validDate == nil) {
        return NO;
    }
    
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:date];
    NSComparisonResult result = [validDate compare:nowDate];
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

+ (void)changeABTestAppStyle:(SNAppABTestStyle)style {
    //该选项如果为关闭状态，则默认使用服务端下发的配置。否则优先使用配置的风格。
    BOOL AppStyleSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:@"Debug_ABTestStlyeSwitch"];
    if (AppStyleSwitch == YES) {
        NSNumber *marketId = [[NSUserDefaults standardUserDefaults] objectForKey:@"Debug_ABTestAppStlye"];
        style = [marketId intValue];
    }
    
    //服务端强制切换app样式
    //如果服务端下发的style发生变化时，切换样式
    if (style == [SNUtility getCurrentAbTestStlye:YES]) {
        return;
    }
    //@qz 2017.7.27 注掉abtest
//    [SNUtility saveAbTestStlye:style isCurrent:YES];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self doChangeABTestAppStyle:style];
//    });
}

+ (void)doChangeABTestAppStyle:(SNAppABTestStyle) style{
    //h5 appstyle同步
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInt:style] forKey:@"settings_abtest_mode"];
    
    //发通知切换app页面风格
    [[NSNotificationCenter defaultCenter] postNotificationName:KABTestChangeAppStyleNotification object:nil];
}

+ (void)saveAbTestStlye:(SNAppABTestStyle)style isCurrent:(BOOL)isCurrent{
    NSString *key = isCurrent ? kABTestCurAppStyle : kABTestValidAppStyle;
    [[NSUserDefaults standardUserDefaults] setInteger:style forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (SNAppABTestStyle)getCurrentAbTestStlye:(BOOL)isCurrent{
    NSString *key = isCurrent ? kABTestCurAppStyle : kABTestValidAppStyle;
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (SNAppABTestStyle)getSettingParamMode{
    //服务端下发参数回传
    return [SNUtility getCurrentAbTestStlye:YES];
}

+ (SNAppABTestStyle)AbTestAppStyle {
    return [SNUtility getCurrentAbTestStlye:YES];
}

/*+ (BOOL)rollingNewsShowVideoChange {
    SNAppABTestStyle style = [SNUtility AbTestAppStyle];
    return (style == SNAppABTestStyVideoChanged);
}*/

//+ (BOOL)articleShowTopBar{
//    SNAppABTestStyle style = [SNUtility AbTestAppStyle];
//    return (style == SNAppABTestStyleAb) || (style ==SNAppABTestStyleab);
//}

+ (void)resultErrorReportWithType:(NSString *)type dict:(NSDictionary *)dict {
    [[[SNNetDiagReportRequest alloc] initWithUploadJson:[dict translateDictionaryToJsonString] andType:type] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    
}

+ (void)setABTestUserMode:(int)value{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"kABTestUserMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSNumber *)ABTestUserMode{
    int value =[[NSUserDefaults standardUserDefaults] integerForKey:@"kABTestUserMode"];
    return [NSNumber numberWithInt:value];
}

+ (BOOL)customSettingChange{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kCustomSettingChange"];
}

+ (void)customSettingChange:(BOOL)change{
    [[NSUserDefaults standardUserDefaults] setBool:change forKey:@"kCustomSettingChange"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isContainSchemeWithType:(NSString *)type urlString:(NSString *)urlString {
    if ([SNAPI isWebURL:urlString]) {
        return NO;
    }
    
    NSRange range = [urlString rangeOfString:@"://"];
    if (urlString.length < range.location + 3) {
        return NO;
    }
    NSString *scheme = [urlString substringToIndex:range.location+3];
    
    SNAppConfigScheme *config = [[SNAppConfigManager sharedInstance] configScheme];
    NSArray *configArray = config.appSchemeList;
    NSString *switchKey = nil;
    if ([type integerValue] == REFER_LOADING) {
        switchKey = kThirdAppSchemeLoading;
    }
    else if ([type integerValue] == REFER_BACK_THIRD_APP) {
        switchKey = kThirdAppSchemeOutCall;
    }
    else {
        switchKey = kThirdAppSchemeInstream;
    }
    
    if ([configArray count] > 0) {
        for (NSDictionary *dict in configArray) {
            NSString *link = [dict stringValueForKey:kThirdAppSchemeLink defaultValue:nil];
            if (link && [link isEqualToString:scheme]) {
                if ([[dict stringValueForKey:switchKey defaultValue:nil] boolValue]) {
                    if (![switchKey isEqualToString:kThirdAppSchemeOutCall]) {
                        [SNUtility sharedUtility].thirdPartName = [[dict stringValueForKey:kThirdAppSchemeName defaultValue:nil] URLDecodedString];
                    }
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}


+ (BOOL)isRecommandGuideShow{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kRecommendGuidShow, [SNUtility sharedUtility].currentChannelId];
    return ![[NSUserDefaults standardUserDefaults] boolForKey:keyName];
}

+ (void)hideRecommendGuide:(NSString *)channelId{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kRecommendGuidShow, channelId];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark 小说热词搜索
+(void)novelSearchHotWord:(void (^)(NSArray *hotNovelWords))hotNovelWords
{
    //小说搜索
    if ([SNRollingNewsPublicManager sharedInstance].novelSearchHotWord.count <= 0) {
        
        [SNStoryPage novelHotWordsSearchDic:@{@"top":@"4"} completeBlock:^(id result) {
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dic = result;
                
                if ([[dic objectForKey:@"isSuccess"]isEqualToString:@"1"]) {
                    
                    NSArray *hotWords = [dic objectForKey:@"hotWords"];
                    NSArray *keyArray = [[hotWords firstObject]allKeys];
                    if (hotNovelWords) {
                        hotNovelWords(keyArray);
                    }
                    if (hotWords.count > 0) {
                        [SNRollingNewsPublicManager sharedInstance].novelSearchHotWord = keyArray;
                    }
                }
            }
        }];
    }else
    {
        if (hotNovelWords) {
            hotNovelWords([SNRollingNewsPublicManager sharedInstance].novelSearchHotWord);
        }
    }
}

+ (void)openLoginViewWithDict:(NSDictionary *)dict {
    [SNUtility shouldUseSpreadAnimation:NO];
//    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:dict];
//    if ([SNUtility isRightP1]) {
//        [[TTNavigator navigator] openURLAction:urlAction];
//    }
//    else {
//        //强制注册p1
//        [[SNClientRegister sharedInstance] registerClientAnywaySuccess:^(SNBaseRequest *request) {
//            [[TTNavigator navigator] openURLAction:urlAction];
//        } fail:^(SNBaseRequest *request, NSError *error) {
//            [[TTNavigator navigator] openURLAction:urlAction];
//        }];
//    }
    
//    wangshun login
    [SNNewsLoginManager loginData:nil Successed:nil Failed:nil];//111评论抢沙发
}

+ (BOOL)unZipFile:(NSString *)file zipFileTo:(NSString *)fileTo{
    //解压文件
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:file] ){
        BOOL result = [zip UnzipFileTo:fileTo overWrite:YES];
        if(!result ){
            SNDebugLog(@"文件解压失败！");
            return NO;
        }
        [zip UnzipCloseFile];
    }
    return YES;
}

//文件流MD5加密
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[4096];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    
    SNDebugLog(@"MD5// %@",result);
    
    return result;
}

+ (void)handleClipper {
 
    if ([SNRollingNewsPublicManager sharedInstance].isOpenNewsFromPush) {
        return;
    }
    
    sohunewsAppDelegate *appDelegate = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
    SNTabbarView *tabbarView = [appDelegate appTabbarController].tabbarView;
    if (tabbarView.currentSelectedIndex != TABBAR_INDEX_NEWS){
        return;
    }
    
    NSString *channelID = [SNUtility sharedUtility].currentChannelId;
    if ([channelID isEqualToString:@"1"] || [channelID isEqualToString:@"13557"]) {
        NSDictionary *dict = [SNUtility getPasteBoardInfo];
        if (dict) {
            NSString *text = [dict stringValueForKey:@"text" defaultValue:@""];
            NSString *url = [dict stringValueForKey:@"url" defaultValue:@""];
            if (text.length > 0 && url.length > 0) {
                //弹出浮层
                SNPasteBoardAlert *pasteBoardAlert = [[SNPasteBoardAlert alloc] initWithAlertViewData:dict];
                [[SNAlertStackManager sharedAlertStackManager] addAlertViewToAlertStack:pasteBoardAlert];
            }
            [SNUtility clearPasteBoard];
        }
    }
}

//获取剪切板内容
+ (NSDictionary *)getPasteBoardInfo {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *boardString = pasteboard.string;
    if ([boardString containsString:@"<-"] && [boardString containsString:@"->"]) {
        //取'<-'与'->'之间的内容
        NSRange startRange = [boardString rangeOfString:@"<-"];
        NSRange endRange = [boardString rangeOfString:@"->"];
        NSRange dataRange = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
        NSString *dataString = [boardString substringWithRange:dataRange];
        if (dataString.length > 16) {
            //AES加密数据为，除去末尾的16位
            NSString *aesString = [dataString substringWithRange:NSMakeRange(0, dataString.length - 16)];
            NSString *md5AES = [aesString md5Hash];
            //校验,取前16位
            NSString *resultMd5 = [md5AES substringWithRange:NSMakeRange(0, 16)];
            //dataString的末尾16位为待校验的md5
            NSString *rightMd5 = [dataString substringWithRange:NSMakeRange(dataString.length - 16, 16)];
            if ([resultMd5 isEqualToString:rightMd5]) {
                NSMutableData *aesData = [NSMutableData dataWithCapacity:aesString.length / 2];
                unsigned char whole_byte;
                char byte_chars[3] = {'\0','\0','\0'};
                int i;
                for (i=0; i < [aesString length] / 2; i++) {
                    byte_chars[0] = [aesString characterAtIndex:i*2];
                    byte_chars[1] = [aesString characterAtIndex:i*2+1];
                    whole_byte = strtol(byte_chars, NULL, 16);
                    [aesData appendBytes:&whole_byte length:1];
                }
                NSString *plainText = [AesEncryptDecrypt decryptData:aesData withKey:kAESEncryptKey];
                //便于解析，前面拼接一个协议
                NSString *finalString = [NSString stringWithFormat:@"%@%@", kProtocolNews, plainText];
                NSDictionary *dict = [SNUtility parseURLParam:finalString schema:kProtocolNews];
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    return dict;
                }
            }
        }
    }
    return nil;
}

//删除剪切板内容
+ (void)clearPasteBoard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:@""];
}

//判断剪切板中的URL与二代协议是否相同
+ (BOOL)pasteBoardUrlIsEqualProtocolUrl:(NSString *)url {
    NSDictionary *dict = [SNUtility getPasteBoardInfo];
    if (dict) {
        NSString *pastBoardUrl = [[dict stringValueForKey:@"url" defaultValue:@""] URLDecodedString];
        if (pastBoardUrl.length > 0 && [pastBoardUrl isEqualToString:url]) {
            return YES;
        }
    }
    return NO;
}

//禁止universal links调起safari
+ (void)banUniversalLinkOpenInSafari {
    if ([SNUtility sharedUtility].isOpenFromUniversalLinks) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            UIView *statusView = [application valueForKey:@"statusBar"];
            if ([statusView isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
                statusView = [statusView valueForKeyPath:@"_statusBar"];
            }
            if ([statusView isKindOfClass:NSClassFromString(@"UIStatusBar")] || [statusView isKindOfClass:NSClassFromString(@"_UIStatusBar")]) {
                NSArray *subIcons = [[statusView valueForKeyPath:@"foregroundView"] subviews];
                NSArray *tempArray = [NSArray arrayWithArray:subIcons];
                for (UIView *view in tempArray) {
                    if ([view isKindOfClass:NSClassFromString(@"UIStatusBarOpenInSafariItemView")]) {
                        view.userInteractionEnabled = NO;
                        break;
                    }
                }
            }
        });
    }
}


+(void)getSyncStatusGo{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([SNPreference sharedInstance].simulateCloudSyncEnabled) {
        [params setValue:@"1" forKey:@"isDebug"];
    }
    [[[SNCloudSynRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id requestDict) {
        
        NSString *statusText = [requestDict objectForKey:@"statusText"];
        if ([statusText isEqualToString:@"Need sync"]) {
            NSArray *dataArray = [requestDict objectForKey:@"data"];
            if ([dataArray count] > 0) {
                NSDictionary *syncDict = (NSDictionary *)[dataArray objectAtIndex:0];
                NSString *cidString = [syncDict objectForKey:@"cid"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:cidString forKey:kCloudSynchronousCid];
                [userDefaults synchronize];
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

#pragma mark 娱乐频道重置刷新计算

+ (void)setTimeToResetChannel{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kChannleRefreshTime, [SNUtility sharedUtility].currentChannelId];
    
    NSDate *date = [SNUtility getSettingValidTime:6];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isTimeToResetChannel:(NSString *)keyName{
    NSDate *validDate = [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
    if (validDate == nil) {
        //为空，表示第一次启动，娱乐频道需要重置
        //计算下次重置时间
        NSDate *date = [SNUtility getSettingValidTime:6];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    NSDate *nowDate = [SNUtility changeNowDateToSysytemDate:[NSDate date]];
    NSComparisonResult result = [validDate compare:nowDate];
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        
        NSDate *date = [SNUtility getSettingValidTime:6];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return YES;
    }
    
    return NO;
}

+ (void)resetHomeChannelTime{
    NSString *keyName = [NSString stringWithFormat:@"%@_1", kChannleRefreshTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isTimeToResetChannel {
    if (![SNUtility sharedUtility].currentChannelId) {
        return NO;
    }
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kChannleRefreshTime, [SNUtility sharedUtility].currentChannelId];
    return [SNUtility isTimeToResetChannel:keyName];
}

+ (BOOL)isNewDayToBackHomeChannel {
    return [SNUtility isTimeToResetChannel:@"isNewDayToBackHomeChannel"];
}

+ (void)recordRefreshTime:(NSString *)channelId{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kChannleOnHourRefreshTime, channelId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldResetChannel{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", kChannleOnHourRefreshTime, [SNUtility sharedUtility].currentChannelId];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:keyName];
    if (date != nil) {
        NSTimeInterval refreshTime = [date timeIntervalSince1970];
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval intervalTime = nowTime - refreshTime;
        if (intervalTime > 60 * 60) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;//为空，表示第一次启动，娱乐频道需要重置
}

+ (void)deleteChannelParamsWithChannelId:(NSString *)channelId{
    [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:channelId];
    [[SNRollingNewsPublicManager sharedInstance] deleteContentTokenWithChannelId:channelId];
}

#pragma mark - 注册第三方平台
+ (void)registerSharePlatform {
    static BOOL registered = NO;
    if (registered) {
        return;
    }
    //不能放子线程初始化，避免支付宝初始化未知crash
    if (isINHOUSE) {
        [APOpenAPI registerApp:kSNAPAPPID_INHOUSE];
    } else {
        [APOpenAPI registerApp:kSNAPAPPID];
    }
    //Register for weixin,放子线程，iOS10以下系统crash
    [SNWXHelper initWXApi];
    //QQ初始化放在子线程会crash
    [SNQQHelper initQQApi];
    //5.2注册新浪
    [SNSSOSinaWrapper sinaSDKRegister];
    registered = YES;
}

+ (NSString *)fullScreenADServerFlagString{
    return @"predownload:";
}

+ (NSString *)getImagePathWithName:(NSString *)imageName {
    NSString *path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:kSpecialActivityDocumentName];
    path = [path stringByAppendingPathComponent:kSpecialActivityName];
    
    if (!imageName) {
        return path;
    }
    return [path stringByAppendingPathComponent:imageName];
}

+ (BOOL)isListGOSync {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kListGOSync];
}

+ (void)recordListGOSync:(BOOL)isSync {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isSync forKey:kListGOSync];
    [userDefaults synchronize];
}

+ (BOOL)isFirstInstallOrUpdateApp {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kFirstInstallOrUpdateApp];
}

+ (void)recordIsFirstInstallOrUpdateApp:(BOOL)isFirst {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFirst forKey:kFirstInstallOrUpdateApp];
    [userDefaults synchronize];
}

+ (NSDictionary *)getWifiSSIDInfo {
    if ([[SNUtility getApplicationDelegate] currentNetworkStatus] != ReachableViaWiFi) {
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    CFArrayRef cf_ifs = CNCopySupportedInterfaces();
    NSArray *ifs = (__bridge id)cf_ifs;
    NSString *ssid = nil;
    NSString *bssid = nil;
    for (NSString *ifnam in ifs) {
        CFDictionaryRef cf_info = CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        NSDictionary *info = (__bridge id)cf_info;
        if (info[@"SSID"]) {
            ssid = [NSString stringWithString:info[@"SSID"]];
        }
        if (info[@"BSSID"]) {
            bssid = [NSString stringWithString:info[@"BSSID"]];
        }
        if (cf_info != NULL) {
            CFRelease(cf_info);
        }
    }
    if (cf_ifs != NULL) {
        CFRelease(cf_ifs);
    }
    
    [dict setValue:ssid forKey:@"SSID"];
    [dict setValue:bssid forKey:@"BSSID"];
    return dict;
}

+ (void)registCompassSDK {
    if (![SNUserDefaults boolForKey:kCompassSDKSwitchKey]) {
        return;
    }
    
    //启动Compass
    COMPConfiguration *configuration = [[COMPConfiguration alloc] init];
    //NO表示不拦截网络请求，YES表示拦截网络请求
    configuration.allowInterveneNetwork = NO;
    [COMPCompassManager startWithCId:[SNUserManager getCid] configuration:configuration];
}

@end

@implementation UIView (SNUtiltyView)

#define XibAwakeFlag "SNUtiltyViewXibAwakeFlag"

- (NSNumber *)isXibAwaked
{
    return objc_getAssociatedObject(self, XibAwakeFlag);
}

- (void)setIsXibAwaked:(NSNumber *)isXibAwaked
{
    objc_setAssociatedObject(self, XibAwakeFlag, isXibAwaked, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)allocWithXIBUtility
{
    return [super alloc];
}

@end
