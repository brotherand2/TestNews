//
//  SNQRItem.h
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QRItemType) {
    QRItemType_QRCode = 0,      //扫普通二维码
    QRItemType_Album,           //相册
    QRItemType_Lamp,            //照明灯（闪光灯）
    QRItemType_Other,           //其他
};

@interface SNQRItem : UIButton

/**
 *  <扫一扫> 菜单按钮类型
 */
@property (nonatomic, assign) QRItemType type;

/**
 *  <扫一扫> 选中状态
 */
@property (nonatomic, assign) BOOL didSelected;


/**
 *  <扫一扫> 初始化一个菜单按钮 标题
 */
- (instancetype)initWithFrame:(CGRect)frame
                       titile:(NSString *)titile;

/**
 *  <扫一扫> 初始化一个菜单按钮 图片
 */
- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)imageName;
@end
