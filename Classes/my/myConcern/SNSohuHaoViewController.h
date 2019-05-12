//
//  SNSohuHaoViewController.h
//  sohunews
//
//  Created by HuangZhen on 2017/6/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNSubscribeNewsModel.h"

@interface SNSohuHaoViewController : SNThemeViewController<SNFollowEventDelegate>

- (void)switchTab:(NSInteger)index;


/**
 刷新关注列表
 */
- (void)refreshFollowingList;

/**
 刷新推荐列表
 */
- (void)refreshUnFollowingList;

@end
