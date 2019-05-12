//
//  SNStorySlider.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/30.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStorySlider.h"
#import "UIImage+Story.h"
#import "UIColor+StoryColor.h"
#import "SNStoryUtility.h"

#define ProgresImageViewLeftOffset               0.0//进度条左边距
#define ProgresImageViewHeight                   2.0//进度条高度
#define ProgresSlideImageViewLeftOffset          0.0//进度滑动条左边距
#define ProgresSlideImageViewHeight              2.0//进度滑动条高度
#define ThumbViewLeftOffset                      0.0//移动按钮左边距
#define SliderBoundaryLeftOffset                 0.0//移动边界的最小距离

struct SliderBoundary {
    CGFloat minX;
    CGFloat maxX;
};

SliderBoundary SliderBoundaryMake(CGFloat minX, CGFloat maxX)
{
    SliderBoundary p; p.minX = minX; p.maxX = maxX; return p;
}

@interface SNStorySlider ()<SNStorySliderViewProtocol>

@property(nonatomic, strong)UIImageView *progres;
@property(nonatomic, assign)int movedCount;//最大／最小只移动一次
@end

@implementation SNStorySlider

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
        NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
        
        self.backgroundColor = [UIColor clearColor];
        self.progres = [[UIImageView alloc]initWithFrame:CGRectMake(ProgresImageViewLeftOffset, (frame.size.height - ProgresImageViewHeight) / 2.0, frame.size.width, ProgresImageViewHeight)];
        self.progres.userInteractionEnabled = YES;
        self.progres.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"normalProgressBgColor"]];
        
        self.progresSlide = [[UIImageView alloc]initWithFrame:CGRectMake(ProgresSlideImageViewLeftOffset, (frame.size.height - ProgresSlideImageViewHeight) / 2.0, 0, ProgresSlideImageViewHeight)];
        self.progresSlide.userInteractionEnabled = YES;
        self.progresSlide.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"progressBgColor"]];
        
        UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"thumbImg"]];
        self.thumbView = [[SNStorySliderView alloc]initWithFrame:CGRectMake(ThumbViewLeftOffset, (frame.size.height - image.size.height - 4) / 2, image.size.width+4, image.size.height+4)];
        //[self.thumbView setBackgroundImage:image forState:UIControlStateNormal];
        self.thumbView.image = image;
        self.boundaryPoint = SliderBoundaryMake(SliderBoundaryLeftOffset, frame.size.width);
        self.thumbView.userInteractionEnabled = YES;
        self.thumbView.delegate = self;
        
        [self addSubview:self.progres];
        [self addSubview:self.progresSlide];
        [self addSubview:self.thumbView];
    }
    
    return self;
}

#pragma mark 调整进度
-(void)setRate:(float)rate
{
    float width = self.frame.size.width - self.thumbView.frame.size.width + 3;
    float length = width * rate;
    
    CGRect thumbRect = self.thumbView.frame;
    CGRect progresRect = self.progresSlide.frame;
    
    if (length < 0 || ((int)length) <= 1) {
        length = 0;
        thumbRect.origin.x = -2.5;
        progresRect.size.width = length;
    } else {
        thumbRect.origin.x = length;
        progresRect.size.width = length + 3;
    }
    
    self.thumbView.frame = thumbRect;
    self.progresSlide.frame = progresRect;
    
    if ([self.delegate respondsToSelector:@selector(storyProgressDealwithSetRatio:)]) {
        
        [self.delegate storyProgressDealwithSetRatio:rate];
    }
}

#pragma mark 计算拖动进度
-(void)stroyProgressDealwithLength:(float)length isMoved:(BOOL)isMoved
{
    float width = self.frame.size.width - self.thumbView.frame.size.width + 3;
    CGRect rect = self.progresSlide.frame;
    rect.size.width = length;
    
    if (length <= 0) {
        length = 0;
        rect.size.width = length;
    } else {
        rect.size.width = length + 3;
    }
    
    self.progresSlide.frame = rect;
    
    if (isMoved) {
        if ([self.delegate respondsToSelector:@selector(storyProgressMoveWithRate:)]) {
            self.isRefreshSlider = YES;
            [self.delegate storyProgressMoveWithRate:length / width];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(storyProgressDealwithRatio:)]) {
            [self.delegate storyProgressDealwithRatio:length / width];
        }
    }
}

#pragma mark StorySliderViewProtocol方法
#pragma mark 计算拖动进度的代理方法
-(void)storyProgressMovedGap:(CGFloat)gap
{
    CGRect rect = self.thumbView.frame;
    rect.origin.x += gap;
    
    if (rect.origin.x <= (-self.thumbView.frame.size.width/4)) {
        
        rect.origin.x = -self.thumbView.frame.size.width/4;
        self.movedCount++;
    }
    else if (rect.origin.x >= self.boundaryPoint.maxX - self.thumbView.frame.size.width + 3)
    {
        rect.origin.x = self.boundaryPoint.maxX - self.thumbView.frame.size.width + 3;
        self.movedCount++;
    }
    else
    {
        self.movedCount = 0;
    }
    
    self.thumbView.frame = rect;
    
    [UIView animateWithDuration:0 animations:^{
        

        if (_movedCount < 2) {
            self.isRefreshSlider = YES;
            [self stroyProgressDealwithLength:self.thumbView.frame.origin.x isMoved:YES];
        }
    }];
}

-(void)storyProgressMovedToPoint:(CGFloat)point{
    CGRect rect = self.thumbView.frame;
    rect.origin.x = point;
    if (rect.origin.x >self.boundaryPoint.maxX - self.thumbView.frame.size.width) {
        rect.origin.x = self.boundaryPoint.maxX - self.thumbView.frame.size.width + 3;
    }
    
    self.thumbView.frame = rect;
    [self stroyProgressDealwithLength:self.thumbView.frame.origin.x isMoved:NO];
}

#pragma mark 是否开始移动或结束移动
-(void)storyProgressMovedBeganOrEnded:(float)index isBegan:(BOOL)isBegan
{
    
    float width = self.frame.size.width - self.thumbView.frame.size.width + 3;
    
    if (index < 0) {
        index = 0;
    }
    if (!isBegan) {
        if ([self.delegate respondsToSelector:@selector(storyProgressDealwithRatio:)]) {
            self.isRefreshSlider = NO;
            [self.delegate storyProgressDealwithRatio:index / width];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(storyProgressShow:isShow:)]) {
        
        [self.delegate storyProgressShow:index isShow:isBegan];
    }
}

- (void)updateNovelTheme {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
    self.progres.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"normalProgressBgColor"]];
    self.progresSlide.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"progressBgColor"]];
    
    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"thumbImg"]];
    //[self.thumbView setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbView.image = image;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    if (point.x <= 0) {
        SNDebugLog(@"小雨");
        point.x = -2;
    }
    self.isRefreshSlider = YES;
    [self storyProgressMovedToPoint:point.x];
}

@end


@interface SNStorySliderView ()

@end

@implementation SNStorySliderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

#pragma mark UIResponder触摸方法重写
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(storyProgressMovedBeganOrEnded:isBegan:)]) {
        
        [self.delegate storyProgressMovedBeganOrEnded:self.frame.origin.x isBegan:YES];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    if (point.x != previousPoint.x) {
        
        CGFloat gap = point.x - previousPoint.x;
        
        if ([self.delegate respondsToSelector:@selector(storyProgressMovedGap:)]) {
            
            [self.delegate storyProgressMovedGap:gap];
        }
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(storyProgressMovedBeganOrEnded:isBegan:)]) {
        [self.delegate storyProgressMovedBeganOrEnded:self.frame.origin.x isBegan:NO];
        SNDebugLog(@"小雨:%f",self.frame.origin.x);
    }
}

@end

