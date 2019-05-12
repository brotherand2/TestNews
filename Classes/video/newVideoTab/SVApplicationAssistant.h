//
//  SVApplicationAssistant.h
//  Utility
//
//  Created by FengHongen on 15/6/10.
//
//

@class VideoAlbum;
@class ShareController;

typedef void (^ShareBlock) (NSUInteger shareType, NSString *providerID, long long aid, long long vid);
typedef void (^ShareCompletionBlock) (NSUInteger shareType, NSString *providerID, BOOL success, long long aid, long long vid);
typedef void (^WebViewCloseBlock)();
typedef void (^LoginCallback)();

@protocol SVApplicationAssistantProtocol <NSObject>

@optional

/**
 * @abstract App presenting view controller
 *
 */
- (UIViewController *)alertPresentingViewController;

/**
 * @abstract 播放版权受限视频
 *
 * @param load url
 *
 */
- (void)openWebViewWithURL:(NSURL *)url;

/**
 * @abstract 打开一个 WebView
 *
 * @param load url
 * @param parent view controller
 * @param 是否展示分享
 * @param 关闭 WebView blcok
 */
- (void)openWebViewWithURL:(NSURL *)url
      parentViewController:(UIViewController *)parentViewCtrl
             shouldBeShare:(BOOL)shouldBeShare
                closeBlock:(WebViewCloseBlock)closeBlock;

/**
 * @abstract 打开分享
 *
 * @param load url
 * @param video album
 * @param 点击分享Type，block
 * @param 分享完成，block
 */
- (void)showShareViewRootViewController:(UIViewController *)rootViewController
                             videoAlbum:(VideoAlbum *)videoAlbum
                             shareBlock:(ShareBlock)shareBlock
                   shareCompletionBlock:(ShareCompletionBlock)shareCompletionBlock;

/**
 *  点击分享执行方法2
 *
 *  @param rootViewController   根controller
 *  @param shareTitle           分享标题
 *  @param shareText            分享的文字
 *  @param imageUrl             分享的图片Url
 *  @param pageUrl              链接
 *  @param shareBlock           分享
 *  @param contentType          类型（QQ，新浪等）
 *  @param shareCompletionBlock 分享完成回调
 */
- (void)showShareViewRootViewController:(UIViewController *)rootViewController
                             shareTitle:(NSString *)shareTitle
                              shareText:(NSString *)shareText
                          shareImageUrl:(NSString *)imageUrl
                           sharePageUrl:(NSString *)pageUrl
                             shareBlock:(ShareBlock)shareBlock
                   shareCompletionBlock:(ShareCompletionBlock)shareCompletionBlock;

/**
 * @abstract VIPPurchaseViewController
 */
- (UIViewController *)VIPPurchaseViewController;

/**
 *  监查当前用户是否为有效用户
 *
 *  @return YES or NO
 */
- (BOOL)currentUserIsValid;

/**
 *  获取用户登录信息gid,token,passport
 *
 *  @return 字典
 */
- (NSDictionary *)getLoginUserInfo;

/**
 * @abstract 打开登录
 *
 * @param parent view controller
 * @param 入口类型，typedef NS_ENUM(NSInteger, LoginEntrance)
 * @param 登录完成，block
 */
- (void)presentLoginViewControllerInViewController:(UIViewController *)parentViewController
                                     loginEntrance:(NSInteger)entrance
                                     loginCallback:(void (^)())loginCallback;

@end