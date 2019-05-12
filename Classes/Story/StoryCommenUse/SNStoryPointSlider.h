//
//  SNStoryPointSlider.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/30.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct SliderPointBoundary SliderPointBoundary;
SliderPointBoundary SliderPointBoundaryMake(CGFloat minX, CGFloat maxX);

@class SNStoryPointSliderView;

@protocol SNStoryPointSliderProtocol <NSObject>
//计算拖动进度
-(void)storyPointProgressDealwithRatio:(float)readRate;
//移动距离及是否显示进度
@end

@protocol SNStoryPointSliderViewProtocol <NSObject>

//计算拖动距离
-(void)storyPointProgressMovedGap:(CGFloat)gap isEnd:(BOOL)isEnd;
- (void)clickTouchEnded;//touchend
@end

@interface SNStoryPointSlider : UIView

@property(nonatomic, assign)int maximumValue;//最大数
@property(nonatomic, assign)SliderPointBoundary boundaryPoint;
@property(nonatomic, strong)UIImageView *progresImageView;
@property(nonatomic, strong)SNStoryPointSliderView *pointThumbView;
@property(nonatomic, weak)id<SNStoryPointSliderProtocol>delegate;
- (void)updateNovelTheme;

- (void)setInitPosition:(NSInteger)po;

@end


@interface SNStoryPointSliderView : UIButton

@property(nonatomic, weak)id<SNStoryPointSliderViewProtocol>delegate;

@end
