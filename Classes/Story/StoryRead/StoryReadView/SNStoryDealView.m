//
//  SNStoryDealView.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/29.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryDealView.h"
#import "SNStorySlider.h"
#import "SNStoryContanst.h"
#import "UIImage+Story.h"
#import "SNStoryUtility.h"

#define LineHeight                            1.0
#define LeftGap                               14.0
#define UpChapterWidth                        60.0
#define UpChapterHeight                       30.0
#define UpChapterOriginY                      10.5
#define SliderGap                             10.0
#define SliderOriginY                         18.0
#define BackBtnSliderGap                      15.0
#define OtherBtnSliderGap                     22.0

#define ProgressViewWidth                     220.0
#define ProgressViewHeight                    40.0
#define ProgressViewOriginY                   -55.0
#define ProgressView_chapterLabelOriginX      15.0
#define ProgressView_chapterLabelOriginY      5.0
#define ProgressView_progressLabelOriginX     20.0
#define ProgressView_labelHeight              13.0
#define ProgressView_labelGap                 4.0
#define ImageViewEdgeInsets                   (UIEdgeInsetsMake(0, 0, 0, 0))
#define ButtonBaseTag                         1000

@interface SNStoryDealView ()<SNStorySliderProtocol>

@end

@implementation SNStoryDealView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
        if (!storyColorTheme || storyColorTheme.length <= 0) {
            [userDefault setObject:@"0" forKey:@"storyColorTheme"];
            [userDefault setObject:@"0" forKey:@"selectedColorTheme"];
        }
        
        NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
        self.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"bgColor"]];
        
        CGFloat width = self.width;
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, LineHeight)];
        viewLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
        viewLine.tag = 3112;
        [self addSubview:viewLine];
        //进度条
        SNStorySlider *slider = [[SNStorySlider alloc]initWithFrame:CGRectMake(LeftGap + 70, 18, width - (LeftGap*2 + (SliderGap+UpChapterWidth)*2), SliderOriginY)];
        self.slider = slider;
        slider.delegate = self;
        [self addSubview:slider];
        
        //进度及章节显示view
        [self createrateProgressView];
        
        //下排5个按钮间隔
        UIImage *imageBack = [UIImage imageStoryNamed:[dic objectForKey:@"backImg"]];
        CGFloat btnGap = (width - (LeftGap + imageBack.size.width)*2)/3.0;
        
        for (int i = 0; i < 7; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(changeChapter:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor colorFromKey:[dic objectForKey:@"fontColor"]] forState:UIControlStateNormal];
            button.tag = ButtonBaseTag + i;
            [self addSubview:button];
            
            if (i == 0) {
                
                button.frame = CGRectMake(LeftGap, UpChapterOriginY, UpChapterWidth, UpChapterHeight);
                [button setTitle:@"上一章" forState:UIControlStateNormal];
            }
            else if(i >= 2)
            {
                UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"backImg"]];
                switch (i) {
                    case 2:
                    {
                        button.frame = CGRectMake(LeftGap, SliderOriginY*2+OtherBtnSliderGap, image.size.width, image.size.height);
                        [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"backImg"]] forState:UIControlStateHighlighted];
                    }
                        break;
                        
                    case 3:
                    {
                        image = [UIImage imageStoryNamed:[dic objectForKey:@"catelogImg"]];
                        button.frame = CGRectMake(LeftGap +imageBack.size.width + (btnGap - image.size.width)/2, SliderOriginY*2+OtherBtnSliderGap, image.size.width, image.size.height);
                    }
                        break;
                        
                    case 4:
                        image = [UIImage imageStoryNamed:[dic objectForKey:@"fontImg"]];
                        button.frame = CGRectMake(LeftGap +imageBack.size.width + btnGap + (btnGap - image.size.width)/2, SliderOriginY*2+OtherBtnSliderGap, image.size.width, image.size.height);
                        break;
                        
                    case 5:
                        image = [UIImage imageStoryNamed:[dic objectForKey:@"nightImg"]];
                        button.frame = CGRectMake(LeftGap +imageBack.size.width +2*btnGap+ (btnGap - image.size.width)/2, SliderOriginY*2+OtherBtnSliderGap, image.size.width, image.size.height);
                        break;
                        
                    case 6:
                        image = [UIImage imageStoryNamed:[dic objectForKey:@"moreImg"]];
                        button.frame = CGRectMake(frame.size.width-LeftGap-image.size.width, SliderOriginY*2+OtherBtnSliderGap, image.size.width, image.size.height);
                        break;
                        
                    default:
                        break;
                }
                [button setBackgroundImage:image forState:UIControlStateNormal];
            }
            else
            {
                button.frame = CGRectMake(width - LeftGap - UpChapterWidth, UpChapterOriginY, UpChapterWidth, UpChapterHeight);
                [button setTitle:@"下一章" forState:UIControlStateNormal];
            }
        }
    }
    return self;
}

-(void)setMaxChapterCount:(int)maxChapterCount
{
    if (maxChapterCount <= 0) {//这样做的目的，防止分子为0
        maxChapterCount = 100;
    }
    _maxChapterCount = maxChapterCount;
    self.slider.maximumValue = maxChapterCount;
}

-(int)maxChapterCount
{
    return _maxChapterCount;
}

#pragma mark 进度及章节显示view
-(void)createrateProgressView
{
    self.rateProgressView = [[SNRateProgressView alloc]initWithFrame:CGRectMake(20, ProgressViewOriginY, ProgressViewWidth, ProgressViewHeight)];
    self.rateProgressView.layer.masksToBounds = YES;
    self.rateProgressView.layer.cornerRadius = 20;
    self.rateProgressView.hidden = YES;
    [self addSubview:self.rateProgressView];
}

#pragma mark StorySliderProtocol方法
-(void)storyProgressDealwithRatio:(float)ratio
{
    if ([self.delegate respondsToSelector:@selector(chapterChangeWithRatio:)]) {
        
        [self.delegate chapterChangeWithRatio:ratio];
        
    }
}

-(void)storyProgressMoveWithRate:(float)rate
{
    if ([self.delegate respondsToSelector:@selector(chapterChangeMovedWithRate:)]) {
        
        [self.delegate chapterChangeMovedWithRate:rate];
        
    }
}

-(void)storyProgressDealwithSetRatio:(float)rate
{
    if ([self.delegate respondsToSelector:@selector(chapterChangeDealwithSetRatio:)]) {
        
        [self.delegate chapterChangeDealwithSetRatio:rate];
        
    }
}

-(void)storyProgressShow:(float)readRate isShow:(BOOL)isShow
{
    self.rateProgressView.hidden = !isShow;
}

- (void)storyProgressShow2Min{
    self.rateProgressView.hidden = NO;
    [self performSelector:@selector(hiddenRateView) withObject:nil afterDelay:0.8f];
}

- (void)hiddenRateView{
    self.rateProgressView.hidden = YES;
}

#pragma mark 调整进度
-(void)setRate:(float)rate
{
    self.slider.rate = rate;
}

#pragma mark 阅读设置
-(void)changeChapter:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(storySettingWithWithButton:)]) {
        [self.delegate storySettingWithWithButton:button];
    }
}

-(void)enableChangeChapter:(BOOL)enableChange
{
    UIButton *upButton = [self viewWithTag:ButtonBaseTag];
    UIButton *nextButton = [self viewWithTag:(ButtonBaseTag+1)];
    upButton.userInteractionEnabled = enableChange;
    nextButton.userInteractionEnabled = enableChange;
}

- (void)updateNovelTheme {
    [self.slider updateNovelTheme];
    [self.rateProgressView updateNovelTheme];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
    
    self.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"bgColor"]];
    UIView *viewLine = [self viewWithTag:3112];
    viewLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    
    //刷新图片
    for (int i = 0; i < 7; i++) {
        
        UIButton *button = [self viewWithTag:(ButtonBaseTag + i)];
        
        if (i == 0 || i == 1) {
            [button setTitleColor:[UIColor colorFromKey:[dic objectForKey:@"fontColor"]] forState:UIControlStateNormal];
        }
        else
        {
            UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"backImg"]];
            switch (i) {
                case 2:
                {
                    [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"backImg"]] forState:UIControlStateHighlighted];
                }
                    break;
                    
                case 3:
                {
                    image = [UIImage imageStoryNamed:[dic objectForKey:@"catelogImg"]];
                }
                    break;
                    
                case 4:
                    image = [UIImage imageStoryNamed:[dic objectForKey:@"fontImg"]];
                    break;
                    
                case 5:
                    image = [UIImage imageStoryNamed:[dic objectForKey:@"nightImg"]];
                    break;
                    
                case 6:
                    image = [UIImage imageStoryNamed:[dic objectForKey:@"moreImg"]];
                    break;
                    
                default:
                    break;
            }
            [button setBackgroundImage:image forState:UIControlStateNormal];
        }
    }

}

@end


#pragma mark 阅读进度及章节显示 RateProgressView
@interface SNRateProgressView ()

@end

@implementation SNRateProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorFromKey:@"StoryProgressViewBgColor"];
        
        UILabel *chapterLabel = [[UILabel alloc]initWithFrame:CGRectMake(ProgressView_chapterLabelOriginX, ProgressView_chapterLabelOriginY, frame.size.width - ProgressView_chapterLabelOriginX*2, ProgressView_labelHeight)];
        chapterLabel.font = [UIFont systemFontOfSize:11];
        chapterLabel.textAlignment = NSTextAlignmentCenter;
        chapterLabel.textColor = [UIColor colorFromKey:@"kLiveGameDateTimeColor"];
        self.chapterLabel = chapterLabel;
        
        UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(ProgressView_progressLabelOriginX,CGRectGetMaxY(chapterLabel.frame) + ProgressView_labelGap,frame.size.width - ProgressView_progressLabelOriginX*2, ProgressView_labelHeight)];
        progressLabel.font = [UIFont systemFontOfSize:11];
        progressLabel.textColor = [UIColor colorFromKey:@"kLiveGameDateTimeColor"];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel = progressLabel;
        
        [self addSubview:chapterLabel];
        [self addSubview:progressLabel];
    }
    return self;
}
- (void)updateNovelTheme {
    
    self.backgroundColor = [UIColor colorFromKey:@"StoryProgressViewBgColor"];
    self.progressLabel.textColor = [UIColor colorFromKey:@"kLiveGameDateTimeColor"];
    self.chapterLabel.textColor = [UIColor colorFromKey:@"kLiveGameDateTimeColor"];
}
@end
