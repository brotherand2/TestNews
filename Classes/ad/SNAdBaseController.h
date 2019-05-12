//
//  SNAdBase.h
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAdView.h"
//#import "STADManagerForNews.h"

@class SNAdData;
@class SNAdBaseController;

@protocol SNAdDelegate <NSObject>

@required

// 广告所有数据加载完毕, 不管广告是否加载出错，此接口都会被回调
// 广告加载如果出错，必须根据ad里的数据来判断。
// 比如 ad.noAd表示广告出错，或者空广告
//     某些图片没有加载成功，那么对应的数据也会是空的
// 不做广告加载失败的接口是因为广告加载失败不好判断。 比如文本加载成功，图片加载失败，到底是成功还是失败呢。
-(void) adAllLoaded:(SNAdBaseController *)ad;

@optional

// 广告文本加载完毕
-(void) adTextLoaded:(SNAdBaseController *)ad;

// 加载了一张图片
-(void) adImageLoaded:(SNAdBaseController *)ad url:(NSString *)url error:(BOOL)error;

// 本广告是一条空广告
-(void) emptyAD:(SNAdBaseController *)ad;

// 广告被点击了
// ad:被点击的广告
// view:被点击的UI控件
-(void) adClick:(SNAdBaseController *)ad control:(UIView *)view;

// 点击了不感兴趣
-(void) uninteresting:(SNAdBaseController *)ad;

@end


@interface SNAdBaseController : UIViewController

@property (nonatomic, weak) id<SNAdDelegate> delegate;
@property (nonatomic, assign) SNAdView *adView;  // 广告UI

// 上报的数据ID
@property (nonatomic) NSInteger reportId;

@property (nonatomic, copy) NSString *spaceId;

// 广告数据
@property (nonatomic, retain) SNAdData *adData;

// 用户自定义捆绑的数据，本类不使用，也不维护对象的引用计数
@property (nonatomic, assign) NSObject *userData;

// 此属性标明的是否有广告。sdk出错，空广告，都属于没有广告。此时值为YES.
// 对外不需要区分空广告还是广告错误，外界不关心，只知道没广告即可。
@property (nonatomic) BOOL noAd;

@property (nonatomic) NSInteger downloadRetry;
@property (nonatomic) NSInteger maxDownloadRetry;

-(instancetype) initWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate filter:(NSDictionary *)filter;

// 曝光. 可以反复调用，接口内部会做率重处理
- (void)exposure;

// 空广告。可以反复调用，接口内部会做率重处理
- (void)empty;

// 此接口由子类实现，并且不能调用基类的viewSize
// 请求广告时adps采用的参数，会让广告服务器根据这个尺寸下发最合适的图片
// 这个尺寸并不是实际的View的尺寸，请不要在其他地方使用
- (CGSize)adps;

// 此接口由子类实现，并且不能调用基类的updateAdView
// 数据在adData里
- (void)updateAdView;

// ----以下所有接口和属性都仅供广告系统内部使，外部请不要使用
#pragma mark 广告系统使用的接口，外部请不要调用

-(void) reportEmpty; // 上报空广告
-(void) reportLoad;  // 上报加载
-(void) reportExposure;
-(void) reportUninteresting;
-(void) reportClick;

// updateAdView的助手函数
- (void)updateImage:(UIImageView *)image url:(NSString *)url complete:(void(^)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL))complete;

@end
