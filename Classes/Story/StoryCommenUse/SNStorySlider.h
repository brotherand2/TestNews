//
//  SNStorySlider.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/30.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct SliderBoundary SliderBoundary;
SliderBoundary SliderBoundaryMake(CGFloat minX, CGFloat maxX);

@class SNStorySliderView;

@protocol SNStorySliderProtocol <NSObject>

-(void)storyProgressDealwithSetRatio:(float)rate;
//计算拖动停止时的进度
-(void)storyProgressDealwithRatio:(float)readRate;
//移动刷新气泡
-(void)storyProgressMoveWithRate:(float)rate;
//移动距离及是否显示进度
-(void)storyProgressShow:(float)readRate isShow:(BOOL)isShow;

- (void)storyProgressShow2Min;
@end

@protocol SNStorySliderViewProtocol <NSObject>

//计算拖动距离
-(void)storyProgressMovedGap:(CGFloat)gap;
//是否开始移动或结束移动
-(void)storyProgressMovedBeganOrEnded:(float)index isBegan:(BOOL)isBegan;
@end

@interface SNStorySlider : UIView

@property(nonatomic, assign)float rate;//阅读百分比
@property(nonatomic, assign)BOOL isRefreshSlider;//是否刷新进度
@property(nonatomic, assign)int maximumValue;//最大数
@property(nonatomic, assign)SliderBoundary boundaryPoint;
@property(nonatomic, strong)UIImageView *progresSlide;
@property(nonatomic, strong)SNStorySliderView *thumbView;
@property(nonatomic, weak)id<SNStorySliderProtocol>delegate;

- (void)updateNovelTheme;

@end


@interface SNStorySliderView : UIImageView

@property(nonatomic, weak)id<SNStorySliderViewProtocol>delegate;

@end
