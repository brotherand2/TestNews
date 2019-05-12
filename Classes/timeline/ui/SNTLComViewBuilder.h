//
//  SNTLComViewBuilder.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTimelineConfigs.h"

@class SNTLCommonView;

typedef void (^BtnAction)();

typedef NS_ENUM(NSInteger, SNTLComViewUseType) {
    kSNTLComViewUseForShareCircle = 0,
    kSNTLComViewUseForShareOuter = 1
};

@interface SNTLComViewBuilder : NSObject {
    CGFloat _suggestViewWidth;
    CGSize _suggestSize;
}

// data source
@property(nonatomic, assign) BOOL isForShare; // 是否是阅读圈分享页面使用的空间 default value is NO；
@property(nonatomic, copy) NSString *link; // 一代、二代协议 用来打开原文
@property(nonatomic, copy) BtnAction btnClickAction;
@property(nonatomic, assign) SNTLComViewUseType useType;

// size cache
+ (CGFloat)heightForObject:(id)object;
+ (SNTLCommonView *)viewForObject:(id)object;

- (UIView *)buildView;
- (CGSize)suggestViewSize;

// subViews
- (UIButton *)actionButton;
- (UIView *)imageView;
- (UIView *)videoIconView;

- (CGRect)imageViewFrameForRect:(CGRect)rect;
- (NSString *)imageUrlPath;

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context;

@end
