//
//  SNAPOpenApiHelper.h
//  sohunews
//
//  Created by cuiliangliang on 16/3/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//


typedef enum {
    ShareTypeText = 0, // 发送文本消息到支付宝
    ShareTypeImageUrl, //发送图片消息到支付宝(图片链接形式)
    ShareTypeImageData, // 发送图片消息到支付宝(图片数据形式)
    ShareTypeWebByUrl, // 发送网页消息到支付宝(缩略图链接形式)
}SNAPShareType;

#import <Foundation/Foundation.h>
#import "APOpenAPI.h"
#import "APOpenAPIObject.h"

@interface SNAPOpenApiHelper : NSObject<APOpenAPIDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) int scene;
@property (nonatomic, assign) SNAPShareType shareType;
@property (nonatomic, copy) NSString *text;//ShareTypeText 类型时不能为nil
@property (nonatomic, copy) NSString *imageUrl;//ShareTypeImageUrl 类型时不能为nil

// 此处填充图片data数据,例如 UIImagePNGRepresentation(UIImage对象)
// 此处必须填充有效的image NSData类型数据，否则无法正常分享
@property (nonatomic, copy) NSData *imageData;//ShareTypeImageData 类型时不能为nil
@property (nonatomic, copy) NSString *title;//ShareTypeWebByUrl 可以为nil
@property (nonatomic, copy) NSString *desc;//ShareTypeWebByUrl 可以为nil
@property (nonatomic, copy) NSString *thumbUrl;//ShareTypeWebByUrl 可以为nil
@property (nonatomic, copy) NSData *thumbData;//ShareTypeWebByUrl 可以为nil
@property (nonatomic, copy) NSString *wepageUrl;//ShareTypeWebByUrl 类型时不能为nil
@property (nonatomic, retain) NSString *shareUrl;

+ (SNAPOpenApiHelper *)sharedInstance;

/*! @brief 检查支付宝是否已被用户安装
 *
 * @return 支付宝已安装返回YES，未安装返回NO。
 */
- (BOOL)isAPAppInstalled;

/*! @brief 分享到支付宝
 *
 * @return 发送成功返回YES，未发送返回NO。
 */
- (BOOL)shareToAPScene;

- (void)shareTextToAP:(NSString *)text;
- (void)shareImageToAP:(NSData *)imageData imageTitle:(NSString *)title; //image最大10M
- (void)shareNewsToAP:(NSString *)content title:(NSString *)title
           thumbImage:(NSData *)imageData webUrl:(NSString *)url;
@end
