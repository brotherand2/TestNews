//
//  SNNewsShareOnService.m
//  sohunews
//
//  Created by wang shun on 2017/2/28.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsShareOnService.h"
#import "SNShareOnRequest.h"

#import "SNUnifyShareServer.h"



//分享 shareOn 接口参数 转换
#define SNNewsShare_ShareOn_OnTypeParamType_Default                      @""
#define SNNewsShare_ShareOn_OnTypeParamType_Weibo                        @"Weibo"
#define SNNewsShare_ShareOn_OnTypeParamType_WXSession                    @"WeiXinChat"
#define SNNewsShare_ShareOn_OnTypeParamType_WXTimeline                   @"WeiXinMoments"
#define SNNewsShare_ShareOn_OnTypeParamType_QQChat                       @"QQChat"
#define SNNewsShare_ShareOn_OnTypeParamType_QQZone                       @"QQZone"
#define SNNewsShare_ShareOn_OnTypeParamType_All                          @"All"
#define SNNewsShare_ShareOn_OnTypeParamType_TaoBaoMoments                @"TaoBaoMoments"
#define SNNewsShare_ShareOn_OnTypeParamType_TaoBao                       @"TaoBao"

//shareType 参数转换
#define SNNewsShare_ShareOn_ShareTypeParam_News                      @"news"
#define SNNewsShare_ShareOn_ShareTypeParam_Joke                      @"joke"
#define SNNewsShare_ShareOn_ShareTypeParam_Vote                      @"vote"
#define SNNewsShare_ShareOn_ShareTypeParam_Group                     @"group"
#define SNNewsShare_ShareOn_ShareTypeParam_Channel                   @"channel"
#define SNNewsShare_ShareOn_ShareTypeParam_Live                      @"live"
#define SNNewsShare_ShareOn_ShareTypeParam_Video                     @"video"
#define SNNewsShare_ShareOn_ShareTypeParam_ActivityPage              @"activityPage"
#define SNNewsShare_ShareOn_ShareTypeParam_VideoTab                  @"videotab"
#define SNNewsShare_ShareOn_ShareTypeParam_Special                   @"special"
#define SNNewsShare_ShareOn_ShareTypeParam_RedPacket                 @"pack"
#define SNNewsShare_ShareOn_ShareTypeParam_PicTexRedPacket           @"redPackPage"//正文页组图红包
#define SNNewsShare_ShareOn_ShareTypeParam_FeedSNS                   @"sns"



@implementation SNNewsShareOnService

- (instancetype)initWithDelegate:(id<SNNewsShareOnServiceDelegate>)delegate{
    if (self = [super init]) {
        self.del = delegate;
    }
    return self;
}

-(void)getShareType:(ShareType)shareType onType:(ShareOnType)shareOnType Params:(NSDictionary *)dic{
    
    if (shareType == ShareTypeQianfan) {//千帆特殊
        NSString* roomID = [dic objectForKey:@"roomID"];
        _currentOnType = @"qianfan";
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:[self onType:shareOnType] forKey:@"on"];
        [params setValue:roomID?:@"" forKey:@"roomId"];
        [params setValue:_currentOnType forKey:@"type"];
        [self requestWithUrl:nil andParams:params];
        return;
    }
    else{
        
        NSString* shareOn = [dic objectForKey:@"shareon"];
        if (shareOn.length > 0) {
            _currentOnType = [self onType:shareOnType];
            NSDictionary* dic = nil;
            if ([_currentOnType isEqualToString:@"Weibo"]) {
                dic = @{@"isWeibo":@"Weibo"};
            }
            
            [self requestWithUrl:[shareOn URLDecodedString] andParams:dic];
            return;
        }
        
        NSString* channelId = [dic objectForKey:@"channelId"]?:@"";
        NSString* referString = [dic objectForKey:@"referString"]?:@"";
        NSString* shareonInfo = [dic objectForKey:@"shareonInfo"]?:@"";
        NSString* redPacket = [dic objectForKey:@"redPacket"]?:@"";
        NSString* activitySubPageShare = [dic objectForKey:@"activitySubPageShare"]?:@"";
        NSString* showType = [dic objectForKey:@"showType"]?:@"";
        NSString* nid = [dic objectForKey:@"nid"]?:@"";
        NSString* redAmount = [dic objectForKey:@"redAmount"]?:@"";
        NSString* site = [dic objectForKey:@"site"];

        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:[self onType:shareOnType] forKey:@"on"];
        [params setValue:channelId forKey:@"channelId"];
        [params setValue:nid forKey:@"nid"];//红包nid
        [params setValue:redAmount forKey:@"redAmount"];//红包金额
        
        if (site && [site isKindOfClass:[NSString class]] && site.length>0 ) {
            [params setObject:site forKey:@"site"];
        }
        
        if (referString.length > 0) {//newsId=
            [params setValuesForKeysWithDictionary:[NSString getURLParas:referString]];
        }
        NSString *type = [self shareType:shareType];
        
        if (shareonInfo.length > 0) {
            type = SNNewsShare_ShareOn_ShareTypeParam_FeedSNS;
            [params setValuesForKeysWithDictionary:[NSString getURLParas:shareonInfo]];
        }
        
        if ([type isEqualToString:SNNewsShare_ShareOn_ShareTypeParam_ActivityPage]) {
            
            if (redPacket.length > 0) {
                [params setValuesForKeysWithDictionary:[NSString getURLParas:[redPacket URLDecodedString]]];
                type = SNNewsShare_ShareOn_ShareTypeParam_RedPacket;
            }
        }
        else if ([type isEqualToString:SNNewsShare_ShareOn_ShareTypeParam_RedPacket]) {
            [params setValuesForKeysWithDictionary:[NSString getURLParas:[redPacket URLDecodedString]]];
        }
        [params setValue:type forKey:@"type"];
        [params setValue:shareOn forKey:@"shareon"];
        
        _currentOnType = [self onType:shareOnType];
        
        if (activitySubPageShare) {
            [params setValue:activitySubPageShare forKey:@"origin"];
        }
        if (showType && showType.length>0) {
            [params setValue:showType forKey:@"showType"];
        }
        
        NSString* newsId = [params objectForKey:@"newsId"];
        if (newsId) {
            NSString* gid = [params objectForKey:@"gid"];
            if (!gid) {
                [params setObject:newsId?:@"" forKey:@"gid"];
            }
        }
        
        [self requestWithUrl:nil andParams:params];
    }
}

- (void)requestWithUrl:(NSString *)url andParams:(NSDictionary *)params {
    
    //小说活动 改短链 2017.10.20 wangshun
    NSString* weibo = [params objectForKey:@"isWeibo"];
    if (weibo && [weibo isEqualToString:@"Weibo"]) {
        url = [url stringByReplacingOccurrencesOfString:@"on=All" withString:@"on=Weibo"];
    }
    
    [[[SNShareOnRequest alloc] initWithDictionary:params andShareOnUrl:url] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (self.del && [self.del respondsToSelector:@selector(requestFromShareOnServerFinished:)]) {
                [self.del requestFromShareOnServerFinished:[self parseDictionary:responseObject]];

            }
        } else {
            if (self.del && [self.del respondsToSelector:@selector(requestFromShareOnServerFinished:)]) {
                [self.del requestFromShareOnServerFinished:nil];
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        //[[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (self.del && [self.del respondsToSelector:@selector(requestFromShareOnServerFinished:)]) {
            [self.del requestFromShareOnServerFinished:nil];
        }
    }];
}

///************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************///


- (NSDictionary *)parseDictionary:(NSDictionary *)originDic{
    _currentOnType = _currentOnType.length > 0 ? _currentOnType : @"Default" ;
    NSDictionary * dic = originDic[_currentOnType];
    return dic;
}

- (NSString *)onType:(ShareOnType)shareOnType{
    NSString * shareOnTypeString = @"";
    switch (shareOnType) {
        case OnTypeDefault:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_Default;
            break;
        case OnTypeWeibo:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_Weibo;
            break;
        case OnTypeWXSession:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_WXSession;
            break;
        case OnTypeWXTimeline:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_WXTimeline;
            break;
        case OnTypeQQChat:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_QQChat;
            break;
        case OnTypeQQZone:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_QQZone;
            break;
        case OnTypeTaoBao:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_TaoBao;
            break;
        case OnTypeTaoBaoMoments:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_TaoBaoMoments;
            break;
        case OnTypeAll:
            shareOnTypeString = SNNewsShare_ShareOn_OnTypeParamType_All;
            break;
            
        default:
            break;
    }
    return shareOnTypeString;
}

- (NSString *)shareType:(ShareType)shareType{
    NSString * shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_News;
    switch (shareType) {
        case ShareTypeNews:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_News;
            break;
        case ShareTypeVote:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Vote;
            break;
        case ShareTypeVideo:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Video;
            break;
        case ShareTypeLive:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Live;
            break;
        case ShareTypeGroup:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Group;
            break;
        case ShareTypeChannel:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Channel;
            break;
        case ShareTypeActivityPage:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_ActivityPage;
            break;
        case ShareTypeVideoTab:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_VideoTab;
            break;
        case ShareTypeSpecial:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Special;
            break;
        case ShareTypeRedPacket:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_RedPacket;
            break;
        case ShareTypeJoke:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_Joke;
            break;
        case ShareTypePicTextRedPacket:
            shareTypeString = SNNewsShare_ShareOn_ShareTypeParam_PicTexRedPacket;
            break;
        default:
            break;
    }
    return shareTypeString;
}


@end


