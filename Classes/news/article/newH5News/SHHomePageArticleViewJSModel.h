//
//  SHHomePageArticleViewJSModel.h
//  LiteSohuNews
//
//  Created by iEvil on 11/5/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>
#import "SHH5NewsWebViewController.h"
#import "SNNewsShareManager.h"

@interface SHHomePageArticleViewJSModel : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) SHH5NewsWebViewController *newsH5WebViewController;
@property(nonatomic, strong) NSMutableDictionary *queryDict;
@property(nonatomic, strong) NSString *subId;
@property(nonatomic,copy)NSString *_redPacketId;
@property(nonatomic,copy)NSString *_moneyValue;
@property(nonatomic,copy)NSString *_checkLoginUrl;
@property (nonatomic,strong) SNNewsShareManager* shareManager;
//处理JS的回调事件

/**
 js 向 native 传递公众号信息

 @param client JsKitClient
 @param jsonData 公众号信息的 json
 */
- (void)jsInterface_jsSendSubInfo:(JsKitClient *)client info:(NSDictionary *)jsonData;


/**
 js 向 native 传递新闻类型是否为非合作方H5

 @param client JsKitClient
 @param type 是否是非合作方 type="1"非合作H5页 type="0"普通新闻
 @param h5Link 非合作方展示link
 */
- (void)jsInterface_jsCallH5Type:(JsKitClient *)client h5Type:(NSString *)type h5Link:(NSString *)h5Link;

/**
 *  获取评论数字
 *
 *  @param client JsKitClient
 *  @param cmt    评论数字
 *  @param collectionNum 收藏数
 */
- (void)jsInterface_setCmtCount:(JsKitClient *)client
                        comment:(NSNumber *)cmt
                  collectionNum:(NSNumber *)collectionNum;

- (void)jsInterface_showLoadingView:(JsKitClient *)client isLoading:(NSNumber *)isLoading;

- (void)jsInterface_backHeadChannel:(JsKitClient *)client;
- (void)jsInterface_fullScreen:(JsKitClient *)client
                        comment:(NSNumber *)isFull;

- (void)jsInterface_report:(JsKitClient *)client;

- (void)jsInterface_zoomImage:(JsKitClient *)client date:(id)json;

- (void)jsInterface_jsCallLongTouchImageData:(JsKitClient *)client url:(NSString *)url;

- (void)jsInterface_gotoCommentSofa:(JsKitClient *)client;

- (void)jsInterface_jsCallReplayComment:(JsKitClient *)client;

- (void)jsInterface_jsCallCopy:(JsKitClient *)client jsonObject:(NSString *)content;

- (void)jsInterface_jsCallShare:(JsKitClient *)client jsonObject:(NSString *)content;

- (void)jsInterface_jsCallGotoSubHome:(JsKitClient *)client jsonObject:(id)jsonObject;

- (void)jsInterface_viewImageFullScreen:(JsKitClient *)client jsonObject:(NSString *)imageUrl;

- (void)jsInterface_shareFastTo:(JsKitClient *)client shareName:(NSString *)shareName;

//点击评论数页面滚动结束时会调
- (void)jsInterface_scrollViewDidEndScrolling:(JsKitClient *)client;

//非合作方正文夜间模式
- (void)jsInterface_setNightMode:(JsKitClient *)client isNight:(id)isNight;

/**
 *  优惠券红包 通用浏览器 js控制显示标题栏 newsApi.showTitle(boolean show, String title);//控制是否显示标题栏和标题。
 */
- (void)jsInterface_showTitle:(JsKitClient *)client show:(NSNumber *)show title:(NSString *)title;

/**
 *  优惠券红包 通用浏览器 js控制显示分享按钮 newsApi.showShareBtn(boolean show);//控制是否显示分享按钮。
 */
- (void)jsInterface_showShareBtn:(JsKitClient *)client show:(NSNumber *)show;

/**
 *  红包提现 提现 newsApi.cashOut(String id)//提现，调起提现逻辑
 */
- (void)jsInterface_cashOut:(JsKitClient *)client luckyMoneyId:(NSString *)luckyMoneyId;

/**
 *  通用浏览器 新窗口打开页面  newsApi.newWindow(url)
 */
- (void)jsInterface_newWindow:(JsKitClient *)client url:(NSString *)url;

/**
 *  通用浏览器 关闭当前窗口 newsApi.backBtnOut(true) 参数为true时关闭当前窗口 false保持原退出逻辑
 */
- (void)jsInterface_backBtnOut:(JsKitClient *)client close:(NSNumber *)close;

/**
 *  通用浏览器 newsApi.showMaskView(false) 控制蒙层
 */
- (void)jsInterface_showMaskView:(JsKitClient *)client close:(NSNumber *)close;

/**
 *  通用浏览器 直接关闭当前窗口 newsApi.closeBrowser
 */
- (void)jsInterface_closeBrowser:(JsKitClient *)client;

//活动页红包提现显示红包雨（需要超过一定金额）
- (void)jsInterface_showRedPacketPopView:(JsKitClient *)client jsonObject:(id)jsonObject;

//正文页视频立即打开，立即下载
- (void)jsInterface_openAdsInfo:(JsKitClient *)client packageName:(NSString *)packageName videoVersion:(NSString *)videoVersion downLoadUrl:(NSString *)downLoadUrl;

//点击红包时，判断是否登陆
- (void)jsInterface_checkLoginAndBind:(JsKitClient *)client url:(NSString *)url;

//举报页面，发送举报成功后调用关闭举报页面
- (void)jsInterface_closeWindow:(JsKitClient *)client;
/**
 *  通用浏览器 隐藏举报按钮newsApi.showReportBtn(false) 参数为true时显示 false隐藏
 */
- (void)jsInterface_showReportBtn:(JsKitClient *)client close:(NSNumber *)show;

/**
 *
 *  用户画像 js唤起 偏好设置 newsApi.openFacePreferenceSetting(String gender);
 */
- (void)jsInterface_openFacePreferenceSetting:(JsKitClient *)client gender:(NSString*)gender;

/**
 *
 *  用户画像 js唤起 偏好设置 newsApi
 *  public void clickFaceInfoLayout(int faceType, int genderStatus, String gender)
 */
- (void)jsInterface_clickFaceInfoLayout:(JsKitClient *)client FaceType:(NSNumber*)faceType GenderStatus:(NSNumber*)genderStatus Gender:(NSString*)gender;

- (void)jsInterface_hideOrShowCollection:(JsKitClient *)client showType:(NSNumber*)showType;

@end
