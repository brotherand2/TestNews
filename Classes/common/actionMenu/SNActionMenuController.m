//
//  SNActionMenuController.m
//  sohunews
//
//  Created by wangxiang on 3/19/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNActionMenuController.h"
#import "SNActionMenuContentFactory.h"
#import "SNActionMenuItemBuilder.h"
#import "RegexKitLite.h"
#import <objc/runtime.h>
#import "SNUserManager.h"
#import "SNAPOpenApiHelper.h"
#import "SMPageControl.h"
#import "SNNewAlertView.h"

#import "SNShareCollectionViewCell.h"
#import "SNShareCollectionViewLayout.h"

#define kIconImgWidth 45.0///2*[UIScreen mainScreen].scale

#define kShareMoments @"moments" //微信朋友圈
#define kShareWeChat @"weChat" //微信好友
#define kShareSohu @"sohu" //狐友
#define kShareSina @"sina" //新浪微博
#define kShareQQ @"qq" //QQ
#define kShareQQZone @"qqZone" //QQ空间
#define kShareAlipay @"alipay" //支付宝好友
#define kShareLifeCircle @"lifeCircle" //生活圈
#define kShareScreenshot @"Screenshot" //屏幕快照
#define kShareCopyLink @"copyLink" //复制链接

#define kIconImage  @"iconImage"
#define kIconTitle  @"title"

@interface SNActionMenuController()<SNUnifyShareServerDelegate,UICollectionViewDelegate, UICollectionViewDataSource, SNNewAlertViewDelegate>

@property (nonatomic) NSTimeInterval lastShareTime;

@property (nonatomic, strong) NSMutableArray *shareArray;
@property (nonatomic, weak  ) SMPageControl *pageControl;
@property (nonatomic, weak  ) SNNewAlertView *alertView;



@end

@implementation SNActionMenuController

- (id)init {
    self = [super init];
    if (self) {
        self.isVideoShare = NO;
        self.isQianfanShare = NO;
        [SNNotificationManager addObserver:self selector:@selector(dismissActionSheet) name:kNotifyDidReceive object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(dismissActionSheet)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dismissActionSheet
{
    [self dismissActionMenu];
}


-(void)dealloc{
    
    [SNNotificationManager removeObserver:self];
    [SNUnifyShareServer sharedInstance].delegate = nil;
    _actionMenu.delegate = nil;
    _content.delegate = nil;

}

#pragma mark -
#pragma mark Prublic Methods

- (NSArray *)createActionMenuItems
{
    NSArray *items = nil;
    
    if (_lastButtonType == SNActionMenuButtonTypeH5Share) {
        
        items = [SNActionMenuItemBuilder buildActionMenuItemsWithOptions:SNActionMenuOptionWXSession |
                                                                         SNActionMenuOptionQQ |
                                                                        SNActionMenuOptionSMS |
                                                                        SNActionMenuOptionMail|
                                                                        SNActionMenuOptionMySOHU];
    } else {
        
        SNActionMenuOptions options = SNActionMenuOptionOAuths
                                      | SNActionMenuOptionWXTimeline
                                      | SNActionMenuOptionWXSession
                                      | SNActionMenuOptionQQ
                                      | SNActionMenuOptionMySOHU
                                      | SNActionMenuOptionAliPaySession
                                      | SNActionMenuOptionAliPayLifeCircle;
    
        if (_lastButtonType == SNActionMenuButtonTypeLike) {
            if (_disableLikeBtn) {
                options |= SNActionMenuOptionLikeDisabled;
            } else if (_isLiked) {
                options |= SNActionMenuOptionLiked;
            } else {
                options |= SNActionMenuOptionUnliked;
            }
        } else if (_lastButtonType == SNActionMenuButtonTypeLoadingPage) {
            options |= SNActionMenuOptionMySOHU;
        }
        
        if (!self.disableQZoneBtn)
        {
            options |= SNActionMenuOptionQZone;
        }
        if (self.disableCopyLinkBtn) {
            options |= SNActionMenuOptionWebLink;
        }
        
        items = [SNActionMenuItemBuilder buildActionMenuItemsWithOptions:options];
        
    }
    return items;
}


- (void)dismissActionMenu {
    // objc_setAssociatedObject(_actionMenu, SNActionMenuKey, nil, OBJC_ASSOCIATION_COPY);
//    [_actionMenu dismiss];
    [self.alertView dismiss];
}

- (void)showActionMenu {

    SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithContentView:[self createShareView] cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    actionSheet.delegate = self;
    self.alertView = actionSheet;
    [actionSheet show];
}

- (void)showActionMenuFromView:(UIView *)fromView {
    self.isLoadingShare = YES;

    SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithContentView:[self createShareView] cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    actionSheet.delegate = self;
    self.alertView = actionSheet;
    [actionSheet showInView:fromView];
    [actionSheet actionWithBlocksCancelButtonHandler:^{
        [[SNUtility sharedUtility] setLastOpenUrl:nil];
    } otherButtonHandler:nil];
}

- (void)showActionMenuFromLandscapeView:(UIView *)fromView
{
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    
    if (now - _lastShareTime < 1) {
        return ;
    }
    
    _lastShareTime = now;
    
    self.actionMenu = [[SNActionMenu alloc] initWithFrame:CGRectMake(0, 0,
                                                                [UIScreen mainScreen].bounds.size.height,
                                                                [UIScreen mainScreen].bounds.size.width)
                                                items:[self createActionMenuItems]];
    _actionMenu.delegate = self;
    _actionMenu.presentFromView = fromView;
//    [self setActionMenuBlock];
    [_actionMenu show];
}
- (void)showActionNewMenuFromLandscapeView:(UIView *)fromView{
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    
    if (now - _lastShareTime < 1) {
        return ;
    }
    
    _lastShareTime = now;
    
    self.actionMenu = [[SNActionMenu alloc] initWithFrame:CGRectMake(0, 0,
                                                                      [UIScreen mainScreen].bounds.size.width,
                                                                      [UIScreen mainScreen].bounds.size.height)
                                                     items:[self createActionMenuItems]];
    _actionMenu.delegate = self;
    _actionMenu.presentFromView = fromView;
//    [self setActionMenuBlock];
    [_actionMenu show];
}

#pragma mark - SNNewAlertViewDelegate
- (void)willDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex {
    [[SNUtility sharedUtility] setLastOpenUrl:nil];//避免二代协议打开浮层，再次点击不能打开
}

#pragma mark - SNActionMenuDelegate

- (void)actionMenu:(SNActionMenu *)actionMenu didSelectAtIndex:(int)buttonIndex
{
    /*
    SNActionMenuBlock block = objc_getAssociatedObject(actionMenu, SNActionMenuKey);
    block(actionMenu, buttonIndex);
     */
    
    if (buttonIndex >= actionMenu.items.count || buttonIndex < 0) {
        return;
    }
    
    SNActionMenuItem *item = actionMenu.items[buttonIndex];
    
    if (item.type == SNActionMenuOptionLiked ||
        item.type == SNActionMenuOptionUnliked) {
        
        if ([_delegate respondsToSelector:@selector(actionmenuDidSelectLikeBtn)]) {
            [_delegate actionmenuDidSelectLikeBtn];
        }
        return;
    }
    else if (item.type == SNActionMenuOptionDownload) {
        if ([_delegate respondsToSelector:@selector(actionmenuDidSelectDownloadBtn)]) {
            [_delegate actionmenuDidSelectDownloadBtn];
        }
        return;
    }
    else if (item.type == SNActionMenuOptionWebLink) {
        NSString *shareLink = nil;
        SNTimelineOriginContentObject *shareInfoObj = [_contextDic objectForKey:@"shareRead"];
        if (shareInfoObj.isFromChannelPreview) {
            shareLink = [_contextDic objectForKey:kShareInfoKeyWebUrl];
        }
        else {
            shareLink = [_contextDic objectForKey:kShareInfoKeyShareLink];
        }
        
        if (shareLink.length == 0) {
            NSString *shareContent = [_contextDic objectForKey:kShareContent];
            if (!shareContent) {
                shareContent = [_contextDic objectForKey:kContent];
            }
            NSArray	*linkArray = [shareContent componentsMatchedByRegex: @"(http[\\.:?=/A-Za-z0-9%_-]*)"];
            if (linkArray && linkArray.count > 0) {
                shareLink = [linkArray objectAtIndex:0];
            }
        }
        
        if (shareLink.length > 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = shareLink;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kCopyLinkSucceed toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        return;
    }
    else if (item.type == SNActionMenuOptionWXSession) {
        [[SNWXHelper sharedInstance] setScene:WXSceneSession];
    }
    else if (item.type == SNActionMenuOptionWXTimeline) {
        [[SNWXHelper sharedInstance] setScene:WXSceneTimeline];
    }
    
    else if (item.type == SNActionMenuOptionMySOHU ) {
//        SNDebugLog(@"分享到我的搜狐");
    }
    
    
    NSDictionary *userInfo = @{kActionMenuViewDidTapLikeBtn:@(NO)};
    [SNNotificationManager postNotificationName:kNotifyDidHandled object:userInfo];
    
    self.content = [SNActionMenuContentFactory getContentOfType:item.type];
    
    if (_content) {
        
        if ([_delegate respondsToSelector:@selector(actionmenuWillSelectItemType:)]) {
            // 根据type修改_contextDic，所以要放在interpretContext之前
            [_delegate actionmenuWillSelectItemType:item.type];
        }
        _content.type = item.type;
        //
        SNTimelineOriginContentObject *shareObj = [_contextDic objectForKey:kShareInfoKeyShareRead];
        if (shareObj.isFromChannelPreview) {
            if (_content.type == SNActionMenuOptionWXSession || _content.type == SNActionMenuOptionQQ || _content.type == SNActionMenuOptionQZone) {//微信好友,QQ,QQ好友
                [_contextDic setValue:[NSString stringWithFormat:@"%@", shareObj.description] forKey:@"content"];
            }
            else if (_content.type == SNActionMenuOptionWXTimeline) {//微信朋友圈
                [_contextDic setValue:[NSString stringWithFormat:@"%@%@", shareObj.title, shareObj.description] forKey:@"content"];
            }
        }
        
        //shareOn.go?
        [SNUnifyShareServer sharedInstance].delegate = nil;
        [SNUnifyShareServer sharedInstance].delegate = self;
        [SNUnifyShareServer sharedInstance].activitySubPageShare = _contextDic[kShareSubActivityPageKey];
        [SNUnifyShareServer sharedInstance].shareonInfo = _contextDic[kSNSShareonInfo];
        
        NSString* showType = [_contextDic objectForKey:@"showType"];
        
        [[SNUnifyShareServer sharedInstance] getShareInfoWithShareType:[self shareTypeWith:_contextDic[@"contentType"]?:@""] onType:[self onTypeWith:_content.type] referString:_contextDic[@"referString"]?:@"" channelId:_contextDic[@"channelId"]?:@"" redPacket:_contextDic[@"redPacket"]?:@"" shareOn:_contextDic[kShareOnKey] showType:showType];
        
        if (_content.type != SNActionMenuOptionWebLink && _content.type != SNActionMenuOptionOAuths) {
            SNShareItem *shareItem = [[SNShareItem alloc] init];
            shareItem.shareId = [_contextDic objectForKey:@"newsId"];
            shareItem.shareContentType = SNShareContentTypeJson;
            shareItem.shareContent   = [_contextDic objectForKey:@"content"];
            shareItem.shareImageUrl  = [_contextDic objectForKey:@"imageUrl"];
            shareItem.sourceType = self.sourceType;
            shareItem.shareLink = [_contextDic objectForKey:@"url"];
            shareItem.isNotRealShare = YES;
            if (_content.type == SNActionMenuOptionWXTimeline) {//微信朋友圈
                shareItem.appId = SNShareToThirdPartTypeWeiXinTimeline;
            }
            else if (_content.type == SNActionMenuOptionWXSession) {//微信好友
                shareItem.appId = SNShareToThirdPartTypeWeiXinFriend;
            }
            else if (_content.type == SNActionMenuOptionQQ) {//QQ好友
                shareItem.appId = SNShareToThirdPartTypeQQ;
            }
            else if (_content.type == SNActionMenuOptionQZone) {//QQ空间
                shareItem.appId = SNShareToThirdPartTypeWeiXinTimeline;
            }
            else if (_content.type == SNActionMenuOptionMySOHU) {//搜狐我的
                shareItem.appId = SNShareToThirdPartTypeMySohu;
            }
            else if (_content.type == SNActionMenuOptionAliPaySession) {//支付宝
                shareItem.appId = SNShareToThirdPartTypeAlipay;
            }
            else if (_content.type == SNActionMenuOptionAliPayLifeCircle) {//生活圈
                shareItem.appId = SNShareToThirdPartTypeLifeCircle;
            }
            [[SNShareManager defaultManager] postShareItemToServer:shareItem];
        }
    }
}

- (void)prepareToShare {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.content interpretContext:self.contextDic];
        
        _content.contentType = [self shareTypeWith:_contextDic[@"contentType"]?:@""];
        _content.delegate = _delegate;
        _content.shareSubType = self.shareSubType;
        _content.timelineContentType = self.timelineContentType;
        _content.timelineContentId = self.timelineContentId;
        _content.newsLink = self.newsLink;
        _content.shareLogType = self.shareLogType;
        _content.sourceType = self.sourceType;
        _content.isVideoShare = self.isVideoShare;
        _content.isQianfanShare = self.isQianfanShare;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isVideoShare) {
                if (![SNUserManager isLogin]&& [_content isKindOfClass:[SNMySohuActionMenuContent class]]) {
                    self.shareToLogin(self);
                }else{
                    [_content share];
                }
            }else{
                [_content share];
            }
            
            //刷新分享列表
            [SNShareManager startWork];
        });
    });
}

- (void)requestFromUnifyServerFinished:(NSDictionary *)responseData {
    [self updateContextDic:responseData];
    if (_content.type == SNActionMenuOptionWebLink) {
        NSString *shareLink = _contextDic[@"webUrl"];
        if (shareLink.length > 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = shareLink;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kCopyLinkSucceed toUrl:nil mode:SNCenterToastModeOnlyText];
            return;
        }
    }
    [self prepareToShare];
}

- (void)updateContextDic:(NSDictionary *)dictionary{
    
    if (dictionary && [dictionary isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if (dictionary[@"content"] && [dictionary[@"content"] isKindOfClass:[NSString class]]) {
        NSString *content = dictionary[@"content"];
        if (content.length > 0) {
            _contextDic[@"content"] = content;
        }
    }
    if (dictionary[kIconTitle] && [dictionary[kIconTitle] isKindOfClass:[NSString class]]) {
        NSString *title = dictionary[kIconTitle];
        if (title.length > 0) {
            _contextDic[kIconTitle] = title;
        }
    }
    
    if (dictionary[@"pics"] && [dictionary[@"pics"] isKindOfClass:[NSArray class]]) {
        if ([dictionary[@"pics"] count] > 0) {
            NSString *imageUrl = _contextDic[@"imageUrl"];
            if (!imageUrl || imageUrl.length == 0 || [_contextDic[@"contentType"] isEqualToString:@"video"]) {
                _contextDic[@"imageUrl"] = [dictionary[@"pics"] firstObject];
            }
        }
    }
   
    if (dictionary[@"link"] && [dictionary[@"link"] isKindOfClass:[NSString class]]) {
        NSString * link = dictionary[@"link"];
        if (link &&![link isKindOfClass:[NSNull class]]&&link.length > 0) {
            _contextDic[@"webUrl"] = link;
        }
    }
}

- (ShareOnType)onTypeWith:(SNActionMenuOption)onType{
    switch (onType) {
        case SNActionMenuOptionUnknown:
            return OnTypeUnknown;
            break;
        case SNActionMenuOptionOAuths:
            return OnTypeWeibo;
            break;
        case SNActionMenuOptionWXSession:
            return OnTypeWXSession;
            break;
        case SNActionMenuOptionWXTimeline:
            return OnTypeWXTimeline;
            break;
        case SNActionMenuOptionMail:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionSMS:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionQQ:
            return OnTypeQQChat;
            break;
        case SNActionMenuOptionQZone:
            return OnTypeQQZone;
            break;
        case SNActionMenuOptionEvernote:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionWebLink:
            return OnTypeWeibo;
            break;
        case SNActionMenuOptionDownload:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionMySOHU:
            return OnTypeDefault;
            break;
        case SNActionMenuOptionAliPayLifeCircle:
            return OnTypeTaoBaoMoments;
        case SNActionMenuOptionAliPaySession:
            return OnTypeTaoBao;
        default:
            return OnTypeAll;
            break;
    }
}

- (ShareType)shareTypeWith:(NSString *)typeString{
    if ([typeString isEqualToString:@"news"]) {
        return ShareTypeNews;
    }
    else if ([typeString isEqualToString:@"vote"]) {
        return ShareTypeVote;
    }
    else if ([typeString isEqualToString:@"video"]) {
        return ShareTypeVideo;
    }
    else if ([typeString isEqualToString:@"videotab"]) {
        return ShareTypeVideoTab;
    }
    else if ([typeString isEqualToString:@"qianfan"]) {
        return ShareTypeQianfan;
    }
    else if ([typeString isEqualToString:@"live"]) {
        return ShareTypeLive;
    }
    else if ([typeString isEqualToString:@"group"]) {
        return ShareTypeGroup;
    }
    else if ([typeString isEqualToString:@"channel"]) {
        return ShareTypeChannel;
    }
    else if ([typeString isEqualToString:@"activityPage"]) {
        return ShareTypeActivityPage;
    }else if ([typeString isEqualToString:@"web"]) {
        return ShareTypeWeb;
    }else if ([typeString isEqualToString:@"special"]) {
        return ShareTypeSpecial;
    }
    else if ([typeString isEqualToString:@"pack"]) {
        return ShareTypeRedPacket;
    }
    else if ([typeString isEqualToString:@"joke"]) {
        return ShareTypeJoke;
    }
    else{
        return ShareTypeUnknown;
    }
}

//分享button点击 wangshun
- (void)halfFloatViewActionMenu:(SNActionMenuOption)menuOption {
    //处理正文页的回调
    if ([_delegate respondsToSelector:@selector(actionmenuDidSelectItemTypeCallback:)]) {
        [_delegate actionmenuDidSelectItemTypeCallback:menuOption];
    }
    
    if (menuOption == SNActionMenuOptionLiked ||
        menuOption == SNActionMenuOptionUnliked) {
        
        if ([_delegate respondsToSelector:@selector(actionmenuDidSelectLikeBtn)]) {
            [_delegate actionmenuDidSelectLikeBtn];
        }
        return;
    }
    else if (menuOption == SNActionMenuOptionDownload) {
        if ([_delegate respondsToSelector:@selector(actionmenuDidSelectDownloadBtn)]) {
            [_delegate actionmenuDidSelectDownloadBtn];
        }
        return;
    }
    else if (menuOption == SNActionMenuOptionWebLink) {
    }
    else if (menuOption == SNActionMenuOptionWXSession) {
        [[SNWXHelper sharedInstance] setScene:WXSceneSession];
    }
    else if (menuOption == SNActionMenuOptionWXTimeline) {
        [[SNWXHelper sharedInstance] setScene:WXSceneTimeline];
    }
    else if (menuOption == SNActionMenuOptionMySOHU) {
        //        SNDebugLog(@"分享到我的搜狐");
    }
    else if (menuOption == SNActionMenuOptionOAuths) {
        [_contextDic setObject:@"sinaweibo" forKey:kShareTargetNameKey];
    }
    else if (menuOption == SNActionMenuOptionAliPaySession) {
        //分享到支付宝会话
        if (![[SNAPOpenApiHelper sharedInstance] isAPAppInstalled]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AP not installed", @"") toUrl:nil mode:SNCenterToastModeWarning];
            return;
        }
        [_contextDic setObject:@"alipayFriend" forKey:kShareTargetNameKey];
    }
    else if (menuOption == SNActionMenuOptionAliPayLifeCircle) {
        //分享支付宝生活圈
        if (![[SNAPOpenApiHelper sharedInstance] isAPAppInstalled]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"AP not installed", @"") toUrl:nil mode:SNCenterToastModeWarning];
            
            return;
        }
        [_contextDic setObject:@"alipayCircle" forKey:kShareTargetNameKey];
    }
    
    
    NSDictionary *userInfo = @{kActionMenuViewDidTapLikeBtn:@(NO)};
    [SNNotificationManager postNotificationName:kNotifyDidHandled object:userInfo];
    
    self.content = [SNActionMenuContentFactory getContentOfType:menuOption];
    
    if (self.isOnlyImage) {
        NSString* url = [_contextDic objectForKey:@"url"];
        NSString* imageUrl = [_contextDic objectForKey:@"imageUrl"];
        if ([url isEqualToString:imageUrl]) {
            if ([url hasSuffix:@".gif"]||[url hasSuffix:@".GIF"]) {
               [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂不支持分享动图操作" toUrl:nil mode:SNCenterToastModeOnlyText];
                return;
            }
            
        }
    }
    
    if (_content) {
        
        if ([_delegate respondsToSelector:@selector(actionmenuWillSelectItemType:)]) {
            // 根据type修改_contextDic，所以要放在interpretContext之前
            [_delegate actionmenuWillSelectItemType:menuOption];
        }
        
        _content.type = menuOption;
        //
        SNTimelineOriginContentObject *shareObj = [_contextDic objectForKey:kShareInfoKeyShareRead];
        if (shareObj.isFromChannelPreview) {
            if (_content.type == SNActionMenuOptionWXSession || _content.type == SNActionMenuOptionQQ || _content.type == SNActionMenuOptionQZone) {//微信好友,QQ,QQ好友
                [_contextDic setValue:[NSString stringWithFormat:@"%@", shareObj.description] forKey:@"content"];
            }
            else if (_content.type == SNActionMenuOptionWXTimeline) {//微信朋友圈
                [_contextDic setValue:[NSString stringWithFormat:@"%@%@", shareObj.title, shareObj.description] forKey:@"content"];
            }
        }
        
//------------------------------------------------
        
        //
        [SNUnifyShareServer sharedInstance].delegate = nil;
        [SNUnifyShareServer sharedInstance].delegate = self;
        [SNUnifyShareServer sharedInstance].activitySubPageShare = _contextDic[kShareSubActivityPageKey];
        [SNUnifyShareServer sharedInstance].shareonInfo = _contextDic[kSNSShareonInfo];
        NSString* showType = [_contextDic objectForKey:@"showType"];
        if (self.isVideoShare) {
            [[SNUnifyShareServer sharedInstance] getShareInfoWithShareType:[self shareTypeWith:@"videotab"] onType:[self onTypeWith:_content.type] referString:[NSString stringWithFormat:@"vid=%@",_contextDic[@"vid"]] channelId:_contextDic[@"channelId"]?:@"" redPacket:_contextDic[@"redPacket"]?:@"" shareOn:_contextDic[kShareOnKey]];
        }else if (self.isQianfanShare){
            [[SNUnifyShareServer sharedInstance] getShareInfoWithQianfan:@"qianfan" onType:[self onTypeWith:_content.type] roomID:_contextDic[@"vid"]];
        }else{
            [[SNUnifyShareServer sharedInstance] getShareInfoWithShareType:[self shareTypeWith:_contextDic[@"contentType"]?:@""] onType:[self onTypeWith:_content.type] referString:_contextDic[@"referString"]?:@"" channelId:_contextDic[@"channelId"]?:@"" redPacket:_contextDic[@"redPacket"]?:@"" shareOn:_contextDic[kShareOnKey] showType:showType];
        }
        

        NSString *shareToThirdTag = nil;
        if (_content.type != SNActionMenuOptionWebLink && _content.type != SNActionMenuOptionOAuths) {
            
            SNShareItem *shareItem = [[SNShareItem alloc] init];
            
            shareItem.shareId = [_contextDic objectForKey:@"newsId"];
            if (shareItem.shareId.length == 0 && _contextDic[@"referString"]) {
                NSString * referStr = _contextDic[@"referString"];
                shareItem.shareId = [[referStr componentsSeparatedByString:@"="] lastObject];
            }
            shareItem.shareContentType = SNShareContentTypeJson;
            shareItem.shareContent   = [_contextDic objectForKey:@"content"];
            shareItem.shareTitle     = [_contextDic objectForKey:kIconTitle];
            shareItem.shareImageUrl  = [_contextDic objectForKey:@"imageUrl"];
            shareItem.sourceType = self.sourceType;
            shareItem.shareLink = [_contextDic objectForKey:@"url"];
            shareItem.isNotRealShare = YES;
            if (_content.type == SNActionMenuOptionWXTimeline) {//微信朋友圈
                shareItem.appId = SNShareToThirdPartTypeWeiXinTimeline;
            }
            else if (_content.type == SNActionMenuOptionWXSession) {//微信好友
                shareItem.appId = SNShareToThirdPartTypeWeiXinFriend;
            }
            else if (_content.type == SNActionMenuOptionQQ) {//QQ好友
                shareItem.appId = SNShareToThirdPartTypeQQ;
            }
            else if (_content.type == SNActionMenuOptionQZone) {//QQ空间
                shareItem.appId = SNShareToThirdPartTypeQZone;
            }
            else if (_content.type == SNActionMenuOptionMySOHU) {//搜狐我的
                shareItem.appId = SNShareToThirdPartTypeMySohu;
            }
            else if (_content.type == SNActionMenuOptionAliPaySession) {//支付宝
                shareItem.appId = SNShareToThirdPartTypeAlipay;
            }
            else if (_content.type == SNActionMenuOptionAliPayLifeCircle) {//生活圈
                shareItem.appId = SNShareToThirdPartTypeLifeCircle;
            }
            [[SNShareManager defaultManager] postShareItemToServer:shareItem];
            shareToThirdTag = shareItem.appId;
        }
        if (_content.type == SNActionMenuOptionOAuths) {
            shareToThirdTag = SNShareToThirdPartTypeSina;
        }
        
        NSString *snsShareonInfo = _contextDic[kSNSShareonInfo];
        if (snsShareonInfo.length>0) {
            [SNUtility reportSNSShareLogWithType:shareToThirdTag shareonInfo:snsShareonInfo originType:self.shareLogType];
        }
    }

}

#pragma mark alipay

- (void)showAlipyActionMenu:(NSString *)title alipayName:(NSString *)alipayName{
//    SNAlipayAlertView *alertView = [[SNAlipayAlertView alloc] initWithSize:CGSizeMake(312, 225)];
//    [alertView setTitle:title setAlipayName:alipayName];
//    [alertView showAlipayAlert];
//    alertView.shareClickBlock = ^(SNActionMenuOption menuOption) {
//        [self halfFloatViewActionMenu:menuOption];
//    };
}

- (UIView *)createShareView {
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 155+2*kIconImgWidth)];
    shareView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 16, 100, 20)];
    titleLabel.text = @"分享到";
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [shareView addSubview:titleLabel];
    CGFloat margin = (kAppScreenWidth - kIconImgWidth * 4) / 5 / 2;
    SNShareCollectionViewLayout *flowLayout = [[SNShareCollectionViewLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kIconImgWidth + 2 * margin, 25+kIconImgWidth);
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 0;
    //    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat offset = (kAppScreenWidth == 667) ? (margin - 5) : margin; // 暂时还不知道原因
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, offset, 0, offset)];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 46, kAppScreenWidth, (25+kIconImgWidth)*2+25) collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.scrollsToTop = NO;
    collectionView.pagingEnabled = YES;
    [collectionView registerClass:[SNShareCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SNShareCollectionViewCell class])];
    [shareView addSubview:collectionView];
    
    SMPageControl *pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 14, 160+2*kIconImgWidth - 25, 28, 15)];
    pageControl.currentPage = 0;
    pageControl.numberOfPages = self.shareArray.count % 8 ? (self.shareArray.count / 8 + 1):self.shareArray.count / 8;
    pageControl.indicatorMargin = 5.0f;
    pageControl.indicatorDiameter = 5.5f;
    pageControl.hidesForSinglePage = YES;
    [shareView addSubview:pageControl];
    
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.pageIndicatorTintColor = [UIColor colorFromString:[SNThemeManager sharedThemeManager].isNightTheme ? @"#343434":@"#dadada"];;
    pageControl.currentPageIndicatorTintColor = [UIColor colorFromString:[SNThemeManager sharedThemeManager].isNightTheme ? @"#4e4e4e":@"#b1b1b1"];;
    self.pageControl = pageControl;
    return shareView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shareArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SNShareCollectionViewCell class]) forIndexPath:indexPath];
    
    [cell setDataWithDict:self.shareArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.shareArray[indexPath.item][kIconTitle];
    [self.alertView dismiss];
    [SNUtility forceScreenPortrait];
    SNActionMenuOption option;

    if ([title isEqualToString:kShareTitleWechat]) {
        option = SNActionMenuOptionWXTimeline;
    } else if ([title isEqualToString:kShareTitleWechatSession]) {
        option = SNActionMenuOptionWXSession;
    } else if ([title isEqualToString:kShareTitleMySohu]) {
        option = SNActionMenuOptionMySOHU;
    } else if ([title isEqualToString:kShareTitleSina]) {
        option = SNActionMenuOptionOAuths;
    } else if ([title isEqualToString:kShareTitleQQZone]) {
        option = SNActionMenuOptionQZone;
    } else if ([title isEqualToString:kShareTitleQQ]){
        option = SNActionMenuOptionQQ;
    } else if ([title isEqualToString:kShareTitleAliPaySession]) {
        option = SNActionMenuOptionAliPaySession;
    } else if ([title isEqualToString:kShareTitleAliPayLifeCircle]){
        option = SNActionMenuOptionAliPayLifeCircle;
    } else {
        option = SNActionMenuOptionWebLink;
    }
    [self halfFloatViewActionMenu:option];
}


//-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = (SNShareCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setImageViewStateWithHightlighted:YES andDict:self.shareArray[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = (SNShareCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setImageViewStateWithHightlighted:NO andDict:self.shareArray[indexPath.item]];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    self.pageControl.currentPage = index;
}

- (NSMutableArray *)shareArray {
    if (_shareArray == nil) {
        _shareArray = [NSMutableArray array];

        [_shareArray addObject:@{kIconImage:@"icofloat_pyq_v5.png",kIconTitle:kShareTitleWechat}];
        [_shareArray addObject:@{kIconImage:@"icofloat_wxhy_v5.png",kIconTitle:kShareTitleWechatSession}];
        [_shareArray addObject:@{kIconImage:@"icofloat_hy_v5.png",kIconTitle:kShareTitleMySohu}];
        [_shareArray addObject:@{kIconImage:@"icofloat_xlwb_v5.png",kIconTitle:kShareTitleSina}];
        [_shareArray addObject:@{kIconImage:@"icofloat_qqkj_v5.png",kIconTitle:kShareTitleQQZone}];
        [_shareArray addObject:@{kIconImage:@"icofloat_qq_v5.png",kIconTitle:kShareTitleQQ}];
        [_shareArray addObject:@{kIconImage:@"icofloat_zfb_v5.png",kIconTitle:kShareTitleAliPaySession}];
        [_shareArray addObject:@{kIconImage:@"icofloat_shq_v5.png",kIconTitle:kShareTitleAliPayLifeCircle}];
        [_shareArray addObject:@{kIconImage:@"icofloat_lj_v5.png",kIconTitle:kShareTitleWebLink}];
        if (!self.disableCopyLinkBtn) {
            self.hideShareIcons = [NSString stringWithFormat:@"%@", kShareCopyLink];
            if (self.isLoadingShare) {
                self.hideShareIcons = [self.hideShareIcons stringByAppendingFormat:@",%@,%@", kShareQQZone, kShareLifeCircle];
               
            }
            else if (self.disableMySNSBtn) {
                self.hideShareIcons = [self.hideShareIcons stringByAppendingFormat:@",%@", kShareSohu];
            }
        }
        if (![SNAppConfigManager sharedInstance].isShowAliPayShareSession) {
            if (!self.hideShareIcons) {
                self.hideShareIcons = [NSString stringWithFormat:@"%@", kShareAlipay];
            }
            else {
                self.hideShareIcons = [self.hideShareIcons stringByAppendingFormat:@",%@", kShareAlipay];
            }
        }
        if (![SNAppConfigManager sharedInstance].isShowAliPayShareTimeline && !self.isLoadingShare) {
            if (!self.hideShareIcons) {
                self.hideShareIcons = [NSString stringWithFormat:@"%@", kShareLifeCircle];
            }
            else {
                self.hideShareIcons = [self.hideShareIcons stringByAppendingFormat:@",%@", kShareLifeCircle];
            }
        }
        _shareArray = [self resetShareMutabelArray:_shareArray string:self.hideShareIcons];

    }
    return _shareArray;
}

- (NSMutableArray *)resetShareMutabelArray:(NSMutableArray *)muArray
                                    string:(NSString *)string {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:muArray];
    if (string.length > 0) {
        NSInteger index = 0;
        NSDictionary *arrayObject = nil;
        NSArray *array = [string componentsSeparatedByString:@","];
        if ([array containsObject:kShareMoments]) {
            if ([muArray count] > 0) {
                arrayObject = [muArray objectAtIndex:0];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareWeChat]) {
            if ([muArray count] > 1) {
                arrayObject = [muArray objectAtIndex:1];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareSohu]) {
            if ([muArray count] > 2) {
                arrayObject = [muArray objectAtIndex:2];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareSina]) {
            if ([muArray count] > 3) {
                arrayObject = [muArray objectAtIndex:3];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareQQZone]) {
            if ([muArray count] > 4) {
                arrayObject = [muArray objectAtIndex:4];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareQQ]) {
            if ([muArray count] > 5) {
                arrayObject = [muArray objectAtIndex:5];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareAlipay]) {
            if ([muArray count] > 6) {
                arrayObject = [muArray objectAtIndex:6];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareLifeCircle]) {
            if ([muArray count] > 7) {
                arrayObject = [muArray objectAtIndex:7];
                [tempArray removeObject:arrayObject];
            }
        }
        if ([array containsObject:kShareCopyLink]) {
            if ([muArray count] > 8) {
                arrayObject = [muArray objectAtIndex:8];
                [tempArray removeObject:arrayObject];
            }
        }
    }
    
    return tempArray;
}

@end

/*****************************SNShareCollectionViewCell*******************************/

//@interface SNShareCollectionViewCell ()
//
//@property (nonatomic, weak) UIImageView *iconImageView;
//@property (nonatomic, weak) UILabel *label;
//
//@end
//
//@implementation SNShareCollectionViewCell
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        UIImageView *iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - kIconImgWidth) / 2, 0, kIconImgWidth, kIconImgWidth)];
//        _iconImageView = iconImgV;
//        iconImgV.layer.cornerRadius = kIconImgWidth / 2;
//        iconImgV.backgroundColor = SNUICOLOR(kThemeBg4Color);
//        [self.contentView addSubview:iconImgV];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kIconImgWidth + 5, frame.size.width, 20)];
//        label.textColor = SNUICOLOR(kThemeText1Color);
//        label.font = [UIFont systemFontOfSize:kThemeFontSizeC];
//
//        label.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:label];
//        _label = label;
//        
////        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
////        self.selectedBackgroundView.backgroundColor = SNUICOLOR(kThemeBg1Color);
//        
//    }
//    return self;
//}
//
//- (void)setImageViewStateWithHightlighted:(BOOL)hightlight andDict:(NSDictionary *)dict {
//    if (hightlight) {
//        NSString *imgName = [NSString stringWithFormat:@"%@press_v5.png",[[dict objectForKey:kIconImage] substringToIndex:[[dict objectForKey:kIconImage] length] - 7]];
//        self.iconImageView.image = [UIImage imageNamed:imgName];
//        self.label.textColor = SNUICOLOR(kThemeBg1Color);
//    } else {
//        self.iconImageView.image = [UIImage imageNamed:[dict objectForKey:kIconImage]];
//        self.label.textColor = SNUICOLOR(kThemeText1Color);
//    }
//}
//
//- (void)setDataWithDict:(NSDictionary *)dict {
//    NSString *imageName = [dict objectForKey:kIconImage];
//    _iconImageView.image = [UIImage imageNamed:imageName];
//    _label.text = [dict objectForKey:kIconTitle];
//}
//
//@end

/*****************************SNShareCollectionViewLayout*******************************/

//static CGFloat itemSpacing = 0.0f;
//static CGFloat lineSpacing = 0.0f;
//static long    pageNumber  = 1;
//@interface SNShareCollectionViewLayout()
//
//@property (nonatomic, strong) NSMutableArray * attributes;
//
//@end


//@implementation SNShareCollectionViewLayout
//{
//    int _row;
//    int _col;
//}
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.attributes = [NSMutableArray new];
//    }
//    return self;
//}
//
//
//- (void)prepareLayout {
//    [super prepareLayout];
//    
//    CGFloat itemWidth  = self.itemSize.width;
//    CGFloat itemHeight = self.itemSize.height;
//    
//    CGFloat width  = self.collectionView.frame.size.width;
//    CGFloat height = self.collectionView.frame.size.height;
//    
//    CGFloat contentWidth = (width - self.sectionInset.left - self.sectionInset.right);
//    
//    // 如果列数大于 2 行
//    if (contentWidth >= (2 * itemWidth + self.minimumInteritemSpacing)) {
//        NSInteger m = (contentWidth - itemWidth) / (itemWidth + self.minimumInteritemSpacing);
//        _col = m + 1;
//        NSInteger n = (NSInteger)(contentWidth - itemWidth) % (NSInteger)(itemWidth + self.minimumInteritemSpacing);
//        if (n > 0) {
//            double offset = ((contentWidth - itemWidth) - m * (itemWidth + self.minimumInteritemSpacing)) / m;
//            itemSpacing = self.minimumInteritemSpacing + offset;
//        } else if (n == 0) {
//            itemSpacing = self.minimumInteritemSpacing;
//        }
//        // 如果列数为 1 行
//    } else {
//        _col = 1;  // 注意不为0 10.0后模拟器会崩，真机没问题
//        itemSpacing = 0;
//    }
//    CGFloat contentHeight = (height - self.sectionInset.top - self.sectionInset.bottom);
//    // 如果行数大于 2 行
//    if (contentHeight >= (2 * itemHeight + self.minimumLineSpacing)) {
//        NSInteger m = (contentHeight - itemHeight) / (itemHeight + self.minimumLineSpacing);
//        _row = m + 1;
//        NSInteger n = (NSInteger)(contentHeight - itemHeight) % (NSInteger)(itemHeight + self.minimumLineSpacing);
//        if (n > 0) {
//            double offset = ((contentHeight - itemHeight) - m * (itemHeight + self.minimumLineSpacing)) / m;
//            lineSpacing = self.minimumLineSpacing + offset;
//        } else if (n == 0) {
//            lineSpacing = self.minimumInteritemSpacing;
//        }
//        // 如果行数数为 1 行
//    } else {
//        _row = 1; // 注意不为0 10.0后模拟器会崩，真机没问题
//        lineSpacing = 0;
//    }
//    NSInteger itemNumber = 0;
//    itemNumber = itemNumber + (NSInteger)[self.collectionView numberOfItemsInSection:0];
//    // 注意不为0 10.0后模拟器会崩，真机没问题
//    pageNumber = itemNumber == 1 ? 1 : (itemNumber - 1) / (_row * _col) + 1;
//}
//
//
//#pragma mark - collectionView 的整体滚动区域
//- (CGSize)collectionViewContentSize {
//    return CGSizeMake(self.collectionView.bounds.size.width * pageNumber, self.collectionView.bounds.size.height);
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    
//    CGRect frame;
//    frame.size = self.itemSize;
//    long number = _row * _col;
//    long m = 0;
//    long p = 0;
//    if (indexPath.item >= number) {
//        p = indexPath.item / number;
//        m = (indexPath.item % number) / _col;
//    } else {
//        m = indexPath.item / _col;
//    }
//    
//    long n = indexPath.item % _col;
//    frame.origin = CGPointMake(n * self.itemSize.width + n * itemSpacing + self.sectionInset.left + (indexPath.section + p) * self.collectionView.frame.size.width, m * self.itemSize.height + m * lineSpacing + self.sectionInset.top);
//    
//    attribute.frame = frame;
//    return attribute;
//}
//
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray * tmpAttributes = [NSMutableArray new];
//    for (int j = 0; j < self.collectionView.numberOfSections; j ++) {
//        NSInteger count = [self.collectionView numberOfItemsInSection:j];
//        for (NSInteger i = 0; i < count; i++) {
//            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:j];
//            [tmpAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//        }
//    }
//    self.attributes = tmpAttributes;
//    return self.attributes;
//}

//#pragma mark - 是否需要重新布局
//- (BOOL)ShouldinvalidateLayoutForBoundsChange:(CGRect)newBound {
//    return NO;
//}
//
//
//@end
