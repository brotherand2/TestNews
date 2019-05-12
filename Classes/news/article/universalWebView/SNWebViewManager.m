//
//  SNWebViewManager.m
//  sohunews
//
//  Created by yangln on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWebViewManager.h"
#import "SNBaseWebViewController.h"

@interface SNWebViewManager ()

@property (nonatomic, strong) NSMutableDictionary *dictInfo;

@end

@implementation SNWebViewManager

- (void)processWebViewWithDict:(NSDictionary *)dict {
    self.dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    UniversalWebViewType webViewType = [[self.dictInfo stringValueForKey:kUniversalWebViewType defaultValue:@""] integerValue];
    switch (webViewType) {
        case AdvertisementWebViewType://广告、推广
            [self openADWebView];
            break;
        case FullScreenADWebViewType://广告、推广
            [self openFullScreenADWebView];
            break;
        case NormalWebViewType://普通类型
        case ApplicationSohuWebViewType://申请公众号页面
            [self openNormalWebView];
            break;
        case ReportWebViewType://举报
            [self creatEncrypted:self.dictInfo];
        case ActivityWebViewType://普通活动页面
        case ChannelPreviewWebViewType://频道预览
        case StockMarketWebViewType://股票详情页
        case StockChannelLoginWebViewType://股票登录页
        case InterlligentOfferWebViewType://智能报盘
        case SpecialWebViewType://专题
        case RedPacketTaskWebViewType://任务红包活动页面
        case RedPacketWebViewType://普通红包页面
        case ReadHistoryWebViewType://阅读历史
        case UserPortraitWebViewType://用户画像
        case MyTicketsListWebViewType://优惠卷
        case FeedBackWebViewType://意见反馈子页面
        case FictionWebViewType:
        case TimeFreeWebViewType://限时免费小说
            [self openJSKitWebView];
        default:
            break;
    }
}

- (void)creatEncrypted:(NSMutableDictionary *)dict {
    NSString *link = [dict objectForKey:@"link"];
    NSString *encryptionStr = @"";
    if ([link rangeOfString:@"channelId"].location != NSNotFound) {
        NSString *channelId = [[link componentsSeparatedByString:@"channelId="] lastObject];
        channelId = [[channelId componentsSeparatedByString:@"&"] firstObject];
        if (channelId.length > 0) {
            encryptionStr = [NSString stringWithFormat:@"channelId=%@", channelId];
        } else {
            encryptionStr = [NSString stringWithFormat:@"channelId=%@", @"-1"];
        }
    } else {
        encryptionStr = [NSString stringWithFormat:@"channelId=%@", @"-1"];
    }
    if ([link rangeOfString:@"newsId"].location != NSNotFound) {
        NSString *newsId = [[link componentsSeparatedByString:@"newsId="] lastObject];
        newsId = [[newsId componentsSeparatedByString:@"&"] firstObject];
        encryptionStr = [NSString stringWithFormat:@"%@&newsId=%@", encryptionStr, newsId];
    }
    
    //直接取pid，不在用link判断
    /*if ([link rangeOfString:@"pid"].location != NSNotFound) {
        NSString *pid = [[link componentsSeparatedByString:@"pid="] lastObject];
        pid = [[pid componentsSeparatedByString:@"&"] firstObject];
        encryptionStr = [NSString stringWithFormat:@"%@&pid=%@", encryptionStr, pid];
    }*/
    encryptionStr = [NSString stringWithFormat:@"%@&pid=%@", encryptionStr, [SNUserManager getPid]];
    
    NSString *encryption = [[SNRedPacketManager sharedInstance] aesEncryptWithData:encryptionStr];
    NSString *vKey = [[SNRedPacketManager sharedInstance] getKeyVersion];
    link = [NSString stringWithFormat:@"%@&skd=%@&v=%@", link, encryption, vKey];
    [self.dictInfo setObject:link forKey:@"link"];
}

- (void)openNormalWebView {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://normalWebView"] applyAnimated:YES] applyQuery:self.dictInfo];
    NSString *urlString = [self.dictInfo stringValueForKey:kLink defaultValue:@""];
    if ([urlString containsString:FixedUrl_Subscribe]) {
        urlAction = [[[TTURLAction actionWithURLPath:@"tt://subscribeWebBrowser"] applyAnimated:YES] applyQuery:self.dictInfo];
    }
    
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)openJSKitWebView {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://jsKitWebView"] applyAnimated:YES] applyQuery:self.dictInfo];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)openADWebView {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://adWebView"] applyAnimated:YES] applyQuery:self.dictInfo];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)openFullScreenADWebView {
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://adFullScreenWebView"] applyAnimated:YES] applyQuery:self.dictInfo];
    [[TTNavigator navigator] openURLAction:urlAction];
}
@end
