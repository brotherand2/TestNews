//
//  SNCollectStateView.h
//  sohunews
//
//  Created by TengLi on 2017/9/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SNCollectState) {
    SNCollectStateUnaudited, // 审核未通过
    SNCollectStatePublished  // 发布成功
};

@interface SNCollectStateView : UIView
@property (nonatomic, assign) SNCollectState collectState; // 审核状态
@property (nonatomic, copy) NSString *stateMessage; // 审核信息
@end
