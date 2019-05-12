//
//  SNCollectModeButton.h
//  sohunews
//
//  Created by TengLi on 2017/9/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SNCollectModeType) {
    SNCollectModeNormal = 0,
    SNCollectModeAuto = 1,      // 自动
    SNCollectModeManually = 2,  // 手动
};

@interface SNCollectModeButton : UIButton
@property (nonatomic, assign) SNCollectModeType collectMode;
@end
