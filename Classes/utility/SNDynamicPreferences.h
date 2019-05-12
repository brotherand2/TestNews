//
//  SNDynamicPreferences.h
//  sohunews
//
//  Created by wangyy on 15/4/16.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNDynamicColorType) {
    SNBottomFontColorDefaultType,//底部tab字体未选中颜色
    SNBottomFontColorSelectedType,//底部tab字体选中颜色
    SNTopFontColorDefaultType,//顶部频道栏字体未选中颜色
    SNTopFontColorSelectedType,//顶部频道栏字体选中颜色
    SNTopChannelEditButtonColorType//顶部频道编辑按钮颜色
};

@interface SNDynamicPreferences : NSObject{

    NSString *_imageSize;

}

@property (nonatomic, copy) NSString *imageSize;
@property (nonatomic, strong) NSMutableDictionary *resultDic;
@property (nonatomic, assign) BOOL haveAlreadyClearData;

- (void)requestDynamicPreferences;

+ (SNDynamicPreferences *)sharedInstance;
- (NSString *)getDynmicColor:(NSString *)defautlColor type:(SNDynamicColorType)colorType;
- (UIImage *)getDynamicSkinImage:(NSString *)imageName ImageSize:(CGSize)imageSize;
- (NSString *)getDynmicTabBarTitle:(NSString *)defaultTitle;
+ (void)refreshView;
- (BOOL)statusTextColorShouldChange;//状态栏字体颜色是否跟随皮肤变化
- (void)clearData;//皮肤开关关闭后，清空数据
- (BOOL)needRefresh;//是否需要刷新

@end
