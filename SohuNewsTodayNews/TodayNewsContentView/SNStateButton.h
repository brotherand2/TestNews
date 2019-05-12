//
//  SNStateButton.h
//  sohunews
//
//  Created by TengLi on 2017/9/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SNStateButtonState) {
    SNStateButtonNormal,   // 没有可以录入的内容
    SNStateButtonAddTo,    // + 保存到搜狐新闻
    SNStateButtonAdding,   // 正在录入...
    SNStateButtonAdded     // 已录入到搜狐新闻
};

@interface SNStateButton : UIButton
@property (nonatomic, readwrite, assign) SNStateButtonState collectState;
@end
