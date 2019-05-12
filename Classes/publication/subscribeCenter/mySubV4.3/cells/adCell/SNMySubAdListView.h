//
//  SNMySubAdListView.h
//  sohunews
//
//  Created by jojo on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNMySubAdListView : UIView

@property (nonatomic, strong) SCSubscribeAdObject *adObj;

//推广位展示统计
- (void)reportPopularizeDisplay;

@end
