//
//  SNStoryDealView.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/29.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNStorySlider;
@class SNRateProgressView;

@protocol SNStoryDealViewProtocol <NSObject>
-(void)storySettingWithIndex:(NSUInteger)index;//阅读设置按钮代理
-(void)storySettingWithWithButton:(UIButton *)button; // by liteng
-(void)chapterChangeWithRatio:(float)ratio;//章节切换
-(void)chapterChangeMovedWithRate:(float)rate;//移动
-(void)chapterChangeDealwithSetRatio:(float)ratio;
@end

@interface SNStoryDealView : UIView
{
    int _maxChapterCount;
}

@property(nonatomic, assign)float rate;//阅读百分比
@property(nonatomic, strong)SNStorySlider *slider;
@property(nonatomic, strong)SNRateProgressView *rateProgressView;
@property(nonatomic, weak)id<SNStoryDealViewProtocol>delegate;
@property(nonatomic, assign)int maxChapterCount;//最大章节数
- (void)updateNovelTheme;
-(void)enableChangeChapter:(BOOL)enableChange;
@end

@interface SNRateProgressView : UIView

@property(nonatomic, strong)UILabel *chapterLabel;
@property(nonatomic, strong)UILabel *progressLabel;
- (void)updateNovelTheme;
@end
