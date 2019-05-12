//
//  SHHomePageArticleViewJSModel.m
//  LiteSohuNews
//
//  Created by iEvil on 11/5/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "SHHomePageArticleViewJSModel.h"
#import <JsKitFramework/JsKitClient.h>
#import "SNUserManager.h"
#import "SNRedPacketModel.h"
#import "SNRedPacketManager.h"
#import "SNBaseWebViewController.h"
#import "SNRedPacketShareAlert.h"

@interface SHHomePageArticleViewJSModel ()
@property (nonatomic, strong) SNRedPacketShareAlert *alipayAlert;
@end

@implementation SHHomePageArticleViewJSModel

- (void)jsInterface_jsSendSubInfo:(JsKitClient *)client info:(NSDictionary *)jsonData {
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController addSubscribeWithInfo:jsonData];
        });
    }
}

- (void)jsInterface_jsCallH5Type:(JsKitClient *)client h5Type:(NSString *)type h5Link:(NSString *)h5Link {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type && [type isEqualToString:@"0"]) {
            [self.newsH5WebViewController setH5Type:type h5Link:nil];
        } else if (type && [type isEqualToString:@"1"] && h5Link) {
            [self.newsH5WebViewController setH5Type:type h5Link:h5Link];
        }
    });
}

- (void)jsInterface_setCmtCount:(JsKitClient *)client
                        comment:(NSNumber *)cmt
                  collectionNum:(NSNumber *)collectionNum
{
    if(nil != cmt){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController setCommentNum:[NSString stringWithFormat:@"%ld",[cmt integerValue]]];
            if (![collectionNum isEqual:[NSNull null]]) {
                [self.newsH5WebViewController setCollectionCount:[collectionNum intValue]];
            }
        });
    }
}

- (void)jsInterface_showLoadingView:(JsKitClient *)client isLoading:(id)isLoading {
    NSNumber *number = (NSNumber *)isLoading;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.newsH5WebViewController stopProgress:number.integerValue];
    });
}

- (void)jsInterface_backHeadChannel:(JsKitClient *)client
{
    if ([NSThread isMainThread]) {
        //不管在那个tab，点击都回到新闻tab头条流，并刷新
        UIViewController* topController = [TTNavigator navigator].topViewController;
        [SNUtility popToTabViewController:topController];
        //tab切换到新闻
        [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
        //栏目切换到焦点
        [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
        [SNNotificationManager postNotificationName:kCloseSearchWebNotification object:nil];
        if ([SNUtility isFromChannelManagerViewOpened]) {
            [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //不管在那个tab，点击都回到新闻tab头条流，并刷新
            UIViewController* topController = [TTNavigator navigator].topViewController;
            [SNUtility popToTabViewController:topController];
            //tab切换到新闻
            [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
            //栏目切换到焦点
            [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
            [SNNotificationManager postNotificationName:kSearchWebViewCancle object:nil];
            if ([SNUtility isFromChannelManagerViewOpened]) {
                [SNNotificationManager postNotificationName:kHideChannelManageViewNotification object:nil];
            }
        });
    }
}

- (void)jsInterface_fullScreen:(JsKitClient *)client
                       comment:(NSNumber *)isFull
{
    
}

- (void)jsInterface_report:(JsKitClient *)client
{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController onClickReport];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController onClickReport];
        });
    }
}

- (void)jsInterface_zoomImage:(JsKitClient *)client date:(id)json
{
    if (json && [json isKindOfClass:[NSDictionary class]]) {
        NSString *imageUrl = [json objectForKey:@"url"];
        NSString *title = [json objectForKey:@"title"];
        NSNumber *x = [json objectForKey:@"x"];
        NSNumber *y = [json objectForKey:@"y"];
        NSNumber *w = [json objectForKey:@"w"];
        NSNumber *h = [json objectForKey:@"h"];
        [self.newsH5WebViewController clickImage:imageUrl title:title rect:CGRectMake(x.floatValue, y.floatValue, w.floatValue, h.floatValue)];
    }
}

- (void)jsInterface_scrollViewDidEndScrolling:(JsKitClient *)client
{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController scrollViewDidEndScrolling];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController scrollViewDidEndScrolling];
        });
    }
}

- (void)jsInterface_setNightMode:(JsKitClient *)client isNight:(id)isNight
{
    NSNumber *number = (NSNumber *)isNight;
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController setWebviewNightModeView:[number boolValue]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController setWebviewNightModeView:[number boolValue]];
        });
    }
}

/**
 *  通用浏览器 长按图片保存分享
 */
- (void)jsInterface_jsCallLongTouchImageData:(JsKitClient *)client url:(NSString *)url{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController longTouchImage:url];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController longTouchImage:url];
        });
    }
}

- (void)jsInterface_gotoCommentSofa:(JsKitClient *)client
{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController emptyCommentListClicked];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController emptyCommentListClicked];
        });
    }
}

- (void)jsInterface_jsCallReplayComment:(JsKitClient *)client jsonObject:(id)jsonObject
{
    if ([NSThread isMainThread]) {
        if (jsonObject) {
            [self.newsH5WebViewController replyComment:(NSDictionary *)jsonObject];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonObject) {
                [self.newsH5WebViewController replyComment:(NSDictionary *)jsonObject];
            }
        });
    }
}

- (void)jsInterface_jsCallCopy:(JsKitClient *)client jsonObject:(NSString *)content
{
    if (![content isKindOfClass:[NSNull class]]) {
        [self.newsH5WebViewController copyComment:content];
    }
}

- (void)jsInterface_jsCallShare:(JsKitClient *)client jsonObject:(NSString *)content
{
    if (![content isKindOfClass:[NSNull class]]) {
        if ([NSThread isMainThread]) {
            [self.newsH5WebViewController shareContent:content];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.newsH5WebViewController shareContent:content];
            });
        }
    }
}

- (void)jsInterface_jsCallGotoSubHome:(JsKitClient *)client jsonObject:(id)jsonObject
{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController enterUserCenter:jsonObject];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController enterUserCenter:jsonObject];
        });
    }
}

- (void)jsInterface_viewImageFullScreen:(JsKitClient *)client jsonObject:(NSString *)imageUrl
{
    __block NSString *imgURL = imageUrl;
    if ([NSThread isMainThread]) {
        if ([[imageUrl lowercaseString] hasPrefix:@"jskitfile"]) {
            imageUrl = [imageUrl componentsSeparatedByString:@"/"].lastObject;
        }
        [self.newsH5WebViewController showImageWithUrl:imageUrl];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[imageUrl lowercaseString] hasPrefix:@"jskitfile"]) {
                imgURL = [imageUrl componentsSeparatedByString:@"/"].lastObject;
            }
            [self.newsH5WebViewController showImageWithUrl:imgURL];
        });
    }
}

- (void)jsInterface_shareFastTo:(JsKitClient *)client shareName:(NSString *)shareName
{
    if ([NSThread isMainThread]) {
        SNActionMenuOption menuOption = SNActionMenuOptionUnknown;
        if ([shareName isEqualToString:@"weChat"]) {
            menuOption = SNActionMenuOptionWXSession;
        } else if ([shareName isEqualToString:@"pengyou"]) {
            menuOption = SNActionMenuOptionWXTimeline;
        } else if ([shareName isEqualToString:@"sina"]) {
            menuOption = SNActionMenuOptionOAuths;
        } else if ([shareName isEqualToString:@"sohu"]) {
            menuOption = SNActionMenuOptionMySOHU;
        }
        
        [self.newsH5WebViewController shareFastTo:menuOption];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SNActionMenuOption menuOption = SNActionMenuOptionUnknown;
            if ([shareName isEqualToString:@"weChat"]) {
                menuOption = SNActionMenuOptionWXSession;
            } else if ([shareName isEqualToString:@"pengyou"]) {
                menuOption = SNActionMenuOptionWXTimeline;
            } else if ([shareName isEqualToString:@"sina"]) {
                menuOption = SNActionMenuOptionOAuths;
            } else if ([shareName isEqualToString:@"sohu"]) {
                menuOption = SNActionMenuOptionMySOHU;
            }
            
            [self.newsH5WebViewController shareFastTo:menuOption];
        });
    }
}

/**
 *  优惠券红包 通用浏览器 js控制显示标题栏 newsApi.showTitle(boolean show, String title);//控制是否显示标题栏和标题。
 */
- (void)jsInterface_showTitle:(JsKitClient *)client show:(NSNumber *)show title:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL bool_show = [show boolValue];
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(showTitleBar:animated:)]) {
                [self.delegate showTitleBar:bool_show animated:NO];
            }
            if (title.length > 0 && [self.delegate respondsToSelector:@selector(updateTitle:)]) {
                [self.delegate updateTitle:title];
            }
        }
    });
}

/**
 *  优惠券红包 通用浏览器 js控制显示分享按钮 newsApi.showShareBtn(boolean show);//控制是否显示分享按钮。
 */
- (void)jsInterface_showShareBtn:(JsKitClient *)client show:(NSNumber *)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL bool_show = [show integerValue];
        if (self.delegate && [self.delegate respondsToSelector:@selector(showShareBtn:)]) {
            [self.delegate showShareBtn:bool_show];
        }
    });
}

/**
 *  红包提现接口
 *
 *  @param luckyMoneyId id
 */
- (void)jsInterface_cashOut:(JsKitClient *)client redPacketId:(NSString *)redPacketId moneyValue:(NSString *)moneyValue redPacketType:(NSString *)redPacketType {
    self._redPacketId = redPacketId;
    self._moneyValue =moneyValue;
    [SNRedPacketManager sharedInstance].redPacketItem.redPacketType = [redPacketType intValue];
    [self performSelectorOnMainThread:@selector(saveToAlipay) withObject:nil waitUntilDone:NO];
}

//V5.5.1红包提现先显示红包雨
- (void)jsInterface_showRedPacketPopView:(JsKitClient *)client jsonObject:(id)jsonObject {
    NSDictionary *dictPacket = (NSDictionary *)jsonObject;
    [SNUtility showRedPacketPopView:dictPacket isActivity:YES];
    self._redPacketId = [dictPacket stringValueForKey:@"packId" defaultValue:@""];
}

- (void)updateActivityStatus:(NSNotification *)notification {
    NSString *drawTime = [notification.userInfo objectForKey:kRedPacketDrawTimeKey];
    BOOL needCallBack = NO;
    if (drawTime.length != 0) {
        needCallBack = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cashOutCallback:withRedPacketId:withDrawTime:)]) {
        [self.delegate cashOutCallback:needCallBack withRedPacketId:self._redPacketId withDrawTime:drawTime];
    }
}

-(NSString*)getCurrentDate{
    
    NSString *timeSp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
    return timeSp;
}

-(void)saveToAlipay{
    
    SNRedPacketModel *redPacketModel = [[SNRedPacketModel alloc] init];
    
    __block SNRedPacketModel *weakRedPacketModel = redPacketModel;
    redPacketModel.isH5 = YES;
    [redPacketModel verifySendRedPacket:^(BOOL Success,BOOL isClickBackButton) {
        
        if (Success) {
            
            [SNUtility checkIsBindAlipayWithResult:^(BOOL isBindAlipay) {
                if (!isBindAlipay) {
                    [weakRedPacketModel auth_V2:^(BOOL Success, NSString *result) {
                        BOOL isCallBack = NO;
                        if (Success) {
                            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
                            
                            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
                                
                                [self verifyWithJsonDict:jsonDict isCallBack:isCallBack];
                            }];
                            return;
                        }else{
                            [self showFailAlertView:@"授权失败" withTitle:@" "];
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                            [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
                        }
                    }];
                    
                    [SNRedPacketModel sharedInstance].authCompletion = ^(BOOL Success, NSString *result){
                        __block BOOL isCallBack = NO;
                        if (Success) {
                            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
                            
                            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
                                
                                if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                                    NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
                                    NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                                    if ([statusCode isEqualToString:@"10000000"]) {
                                        isCallBack = YES;
                                    }else{
                                        [self showFailAlertView:statusMsg withTitle:@" "];
                                    }
                                }
                                if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                                    [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
                                }
                            }];
                            return;
                        }else{
                            [self showFailAlertView:@"授权失败" withTitle:@" "];
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                            [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
                        }
                    };
                }
                
            }];
        }else{
            if (!isClickBackButton) {
                [self showFailAlertView:RedPacketCopywriterNomal withTitle:@" "];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                [self.delegate checkLoginAndBindCallback:NO url:self._checkLoginUrl];
            }
        }
    }];
    
}


#pragma mark 正文或其他页红包
-(void)verifyWithJsonDict:(id)jsonDict isCallBack:(BOOL)isCallBack
{
    if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
        NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
        NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
        if ([statusCode isEqualToString:@"10000000"]) {
            
            if ([SNAppConfigManager sharedInstance].configH5RedPacket.redPacketFloatBtnIsShow) {//正文页红包
                
                isCallBack = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                    [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
                }
                
            } else {//原有老红包逻辑
                
                //提现能已经废掉，原因：1.H5自己提现  2.该接口已经不在使用
                isCallBack = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                    [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
                }
                
                /*__block BOOL callBack = isCallBack;
                [[SNRedPacketModel sharedInstance] redPacketRequestWithPacketID:self._redPacketId requestFinish:^(SNPackProfile * profile) {
                    if (profile && [profile.statusCode isEqualToString:@"10000000"]) {
                        [self showAlipayAlertView:profile.alipayPassport];
                        callBack = YES;
                    }else{
                        [self showFailAlertView:profile.statusMsg withTitle:@" "];
                    }
                    if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                        [self.delegate checkLoginAndBindCallback:callBack url:self._checkLoginUrl];
                    }
                } requestFailure:^(id request, NSError *error) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                        [self.delegate checkLoginAndBindCallback:callBack url:self._checkLoginUrl];
                    }
                }];
                return;*/
            }
            
        }else{
            [self showFailAlertView:statusMsg withTitle:@" "];
            if (self.delegate && [self.delegate respondsToSelector:@selector(checkLoginAndBindCallback:url:)]) {
                [self.delegate checkLoginAndBindCallback:isCallBack url:self._checkLoginUrl];
            }
        }
    }
}

-(void)withdrawError:(NSString*)statusCode{
    NSString *message = nil;
    NSString *title = [SNRedPacketModel getErrorStringWithErrorCode:statusCode];
    [self showFailAlertView:message withTitle:title];
}

- (void)showFailAlertView:(NSString*)message withTitle:(NSString*)title{

    if (0 == title.length) {
        title = kBundleNameKey;
    }
    SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:message cancelButtonTitle:@"关闭" otherButtonTitle:@"重试"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushAlertView show];
    });
    [pushAlertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        [self saveToAlipay];
    }];

}


- (void)showAlipayAlertView:(NSString *)alipayName{
    
    NSString *title = [NSString stringWithFormat:@"%@元已提现到你的支付宝", self._moneyValue];
    self.alipayAlert = [[SNRedPacketShareAlert alloc] init];
    [self.alipayAlert showRedPacketShareAlertWithTitle:title alipayName:alipayName withRedPacketId:self._redPacketId];
}


/**
 *  通用浏览器 新窗口打开页面  newsApi.newWindow(url)
 */
- (void)jsInterface_newWindow:(JsKitClient *)client url:(NSString *)url {
    __block NSString *protocolUrl = url;//外链分享contentType
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([protocolUrl containsString:@"?"]) {
            protocolUrl = [protocolUrl stringByAppendingString:@"&contentType=pack"];
        }
        else {
            protocolUrl = [protocolUrl stringByAppendingString:@"?contentType=pack"];
        }
        
        [SNUtility openProtocolUrl:protocolUrl context:@{@"shareLogType":@"coupon", kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType]}];
    });
}

/**
 *  通用浏览器 关闭当前窗口 newsApi.backBtnOut(true) 参数为true时关闭当前窗口 false保持原退出逻辑
 */
- (void)jsInterface_backBtnOut:(JsKitClient *)client close:(NSNumber *)close {
    BOOL bool_close = [close integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(forceCloseBrowser:)]) {
        [self.delegate forceCloseBrowser:bool_close];
    }
}

- (void)jsInterface_showMaskView:(JsKitClient *)client close:(NSNumber *)close{
    BOOL bool_close = [close integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(showMaskView:)]) {
        [self.delegate showMaskView:bool_close];
    }
}

- (void)jsInterface_closeBrowser:(JsKitClient *)client {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeBrowserImmediately)]) {
        [self.delegate closeBrowserImmediately];
    }
}

- (void)jsInterface_openAdsInfo:(JsKitClient *)client packageName:(NSString *)packageName videoVersion:(NSString *)videoVersion downLoadUrl:(NSString *)downLoadUrl {
    __block NSString *_packageName = packageName;
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        if ([_packageName isEqual:[NSNull null]] || _packageName.length == 0) {
            if (![downLoadUrl isEqual:[NSNull null]] && downLoadUrl.length != 0) {
                [SNUtility openProtocolUrl:downLoadUrl];
            }
        }
        else {
            if ([_packageName isEqualToString:kSohuVideoBundleID]) {
                _packageName = kProtocolSohuVideo;
                if ([SNUtility isWhiteListURL:[NSURL URLWithString:_packageName]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_packageName]];
                }
                else {
                    if (![downLoadUrl isEqual:[NSNull null]] && downLoadUrl.length != 0) {
                        [SNUtility openProtocolUrl:downLoadUrl];
                    }
                }
            }
        }
    });
}

- (void)jsInterface_checkLoginAndBind:(JsKitClient *)client url:(NSString *)url{
    self._checkLoginUrl = url;
    [self performSelectorOnMainThread:@selector(saveToAlipay) withObject:nil waitUntilDone:NO];
}

- (void)jsInterface_closeWindow:(JsKitClient *)client{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(webViewGoBack)]) {
            [self.delegate webViewGoBack];
        }
    });
}
- (void)jsInterface_showReportBtn:(JsKitClient *)client close:(NSNumber *)show{
    BOOL bool_show = [show integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(showReportBtn:)]) {
        [self.delegate showReportBtn:bool_show];
    }
}

- (void)jsInterface_openFacePreferenceSetting:(JsKitClient *)client gender:(NSString *)gender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openFacePreferenceSetting:)]) {
        [self.delegate openFacePreferenceSetting:gender];
    }
}

- (void)jsInterface_clickFaceInfoLayout:(JsKitClient *)client FaceType:(NSNumber *)faceType GenderStatus:(NSNumber *)genderStatus Gender:(NSString *)gender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFaceInfoLayoutFaceType:GenderStatus:Gender:)]) {
        [self.delegate clickFaceInfoLayoutFaceType:faceType GenderStatus:genderStatus Gender:gender];
    }
}

- (void)jsInterface_hideOrShowCollection:(JsKitClient *)client showType:(NSNumber*)showType
{
    if ([NSThread isMainThread]) {
        [self.newsH5WebViewController hideOrShowCollection:showType];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsH5WebViewController hideOrShowCollection:showType];
        });
    }
}

- (void)dealloc {
    self.delegate = nil;
}

@end
