//
//  SNAdView.h
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNAdView : UIView

// 用户使用的click事件回调
// 这个click要子模板实现了才能使用，否则是不会触发回调的。
// 这个click的设计初衷是：某些地方可能不需要AdBaseController，而是简单的使用UI，那么无法通过controller的delegate来获得点击事件
// 建议：只使用view，而不使用controller时才用这个block（就是不走广告流程，仅复用UI时），才这么干
@property (nonatomic, copy) void(^userClick)(SNAdView *, UIView *view);

// 给使用者绑定自定义数据的变量，本类和广告系统永不使用，也不维持对象的引用计数
@property (nonatomic, assign) NSObject *userData;

// 曝光的时候调用.
// 调用此接口时，会直接调用SNAdBaseController中的曝光，这里做这个接口只是为了外部方便使用而已。
// 此接口内部会做率重逻辑，可以反复调用。
- (void)exposure;



// ----以下所有接口和属性都仅供广告系统内部使，外部请不要使用
#pragma mark 广告系统使用的接口，外部请不要调用

@property (nonatomic, copy) void (^uninterestingBlock)(SNAdView *);
@property (nonatomic, copy) void (^clickBlock)(SNAdView *, UIView *clickdView);
@property (nonatomic, copy) void (^exposureBlock)(SNAdView *);

@end
