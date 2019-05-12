//
//  SNStoryPointSlider.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/30.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryPointSlider.h"
#import "SNStoryContanst.h"
#import "UIViewAdditions+Story.h"
#import "UIImage+Story.h"
#import "SNStoryUtility.h"

#define pointImageViewWidth                        9.0//节点宽度
#define pointImageViewHeight                       9.0//节点高度
#define ProgresImageViewLeftOffset                 0.0//进度条左边距
#define ProgresImageViewHeight                     2.0//进度条高度
#define ProgresSlideImageViewLeftOffset            0.0//进度滑动条左边距
#define ProgresSlideImageViewHeight                2.0//进度滑动条高度
#define StoryPointSlider_PoinCount                 5//节点个数

struct SliderPointBoundary {
    CGFloat minX;
    CGFloat maxX;
};

SliderPointBoundary SliderPointBoundaryMake(CGFloat minX, CGFloat maxX)
{
    SliderPointBoundary p; p.minX = minX; p.maxX = maxX;
    return p;
}

@interface SNStoryPointSlider ()<SNStoryPointSliderViewProtocol>

@property(nonatomic, strong)UIImageView *progresSlideImageView;
@end

@implementation SNStoryPointSlider

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
        NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
        
        self.progresImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ProgresImageViewLeftOffset, (frame.size.height - 2) / 2.0, frame.size.width, ProgresImageViewHeight)];
        self.progresImageView.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"normalProgressBgColor"]];
        
        self.progresSlideImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ProgresSlideImageViewLeftOffset, (frame.size.height - 2) / 2.0, 0, ProgresSlideImageViewHeight)];
        self.progresSlideImageView.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"progressBgColor"]];
        
        UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"thumbImg"]];
        self.pointThumbView = [[SNStoryPointSliderView alloc]initWithFrame:CGRectMake(-image.size.width/2.0, (frame.size.height - image.size.height) / 2.0, image.size.width, image.size.height)];
        [self.pointThumbView setBackgroundImage:image forState:UIControlStateNormal];
        self.boundaryPoint = SliderPointBoundaryMake(0, frame.size.width);
        self.pointThumbView.userInteractionEnabled = YES;
        self.pointThumbView.delegate = self;
        [self addSubview:self.progresImageView];
        [self addSubview:self.progresSlideImageView];
        
        //添加6个节点
        float pointGap = frame.size.width/StoryPointSlider_PoinCount;
        
        for (int i = 0; i<6; i++) {
            
            UIImageView *pointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(pointGap*i - pointImageViewWidth/2.0, (self.height - pointImageViewHeight)/2.0, pointImageViewWidth, pointImageViewHeight)];
            pointImageView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
            pointImageView.tag = 2650+i;
            pointImageView.layer.cornerRadius = pointImageViewHeight/2.0;
            [self addSubview:pointImageView];
        }
    }
    [self addSubview:self.pointThumbView];
    
    return self;
}

- (void)setInitPosition:(NSInteger)po{
    float pointGap = self.frame.size.width/StoryPointSlider_PoinCount;
    if (po>=StoryPointSlider_PoinCount) {
        po = StoryPointSlider_PoinCount;
    }
    if (po<=0) {
        po = 0;
    }

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
    
    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"thumbImg"]];
    self.pointThumbView.frame = CGRectMake( pointGap*po-self.pointThumbView.width/2.0, (self.frame.size.height - image.size.height) / 2.0, image.size.width, image.size.height);
    self.progresSlideImageView.frame = CGRectMake(ProgresSlideImageViewLeftOffset, (self.frame.size.height - 2) / 2.0, (pointGap*po-self.pointThumbView.width/2.0) + 2, ProgresSlideImageViewHeight);
}

- (void)clickTouchEnded{
    CGFloat length = self.pointThumbView.origin.x;
    [self stroyProgressDealwithLength:length isEnd:YES];
}

#pragma mark 计算拖动进度

-(void)stroyProgressDealwithLength:(float)length isEnd:(BOOL)isEnd
{
    CGRect rect = self.progresSlideImageView.frame;
    if (length <= 0) {
        length=0;
    }
    
    if (isEnd) {
        float pointGap = self.frame.size.width/StoryPointSlider_PoinCount;
        __block CGRect thumbRect = self.pointThumbView.frame;
        NSInteger num = 0;
        
        if (length < pointGap/2) {
            thumbRect.origin.x = -self.pointThumbView.width/2.0;
            num = 0;
        } else if (length < pointGap){
            thumbRect.origin.x = pointGap-self.pointThumbView.width/2.0;
            num = 1;
        }else if (length < pointGap*3/2.0){
            thumbRect.origin.x = pointGap-self.pointThumbView.width/2.0;
            num = 1;
        }else if (length < pointGap*2.0){
            
            thumbRect.origin.x = pointGap*2.0-self.pointThumbView.width/2.0;
            num = 2;
        }else if (length < pointGap*5/2.0){
            
            thumbRect.origin.x = pointGap*2.0-self.pointThumbView.width/2.0;
            num = 2;
            
        }else if (length < pointGap*3.0){
            
            thumbRect.origin.x = pointGap*3.0-self.pointThumbView.width/2.0;
            num = 3;
        }
        else if (length < pointGap*7/2.0){
            thumbRect.origin.x = pointGap*3.0-self.pointThumbView.width/2.0;
            num = 3;
        }
        else if (length < pointGap*4.0){
            thumbRect.origin.x = pointGap*4.0-self.pointThumbView.width/2.0;
            num = 4;
        }
        else if (length < pointGap*9/2.0){
            thumbRect.origin.x = pointGap*4.0-self.pointThumbView.width/2.0;
            num = 4;
        }
        else
        {
            thumbRect.origin.x = pointGap*5-self.pointThumbView.width/2.0;
            num = 5;
        }
        
        if (thumbRect.origin.x <= 0) {
            rect.size.width =0;
        }else
        {
            rect.size.width = thumbRect.origin.x + 2;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.pointThumbView.frame = thumbRect;
            self.progresSlideImageView.frame = rect;
            
        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(storyPointProgressDealwithRatio:)]) {
            [self.delegate storyPointProgressDealwithRatio:num];
        }

    }
}

#pragma mark StorySliderViewProtocol方法
#pragma mark 计算拖动进度的代理方法
-(void)storyPointProgressMovedGap:(CGFloat)gap isEnd:(BOOL)isEnd
{
    CGRect rect = self.pointThumbView.frame;
    
    if (self.maximumValue > 100) {
        rect.origin.x += (gap/self.maximumValue*100);
    }else
    {
        rect.origin.x += gap;
    }
    
    if (rect.origin.x <= -self.pointThumbView.width/2) {
        
        rect.origin.x = -self.pointThumbView.width/2;
    }
    else if (rect.origin.x >= self.boundaryPoint.maxX - self.pointThumbView.width/2)
    {
        rect.origin.x = self.boundaryPoint.maxX - self.pointThumbView.width/2;
    }

    self.pointThumbView.frame = rect;
    CGRect p_rect = self.progresSlideImageView.frame;
    p_rect.size.width = self.pointThumbView.origin.x;
    
    if (self.pointThumbView.origin.x < 0) {
        p_rect.size.width = 0;
    }
    
    self.progresSlideImageView.frame = CGRectMake(ProgresSlideImageViewLeftOffset, (self.frame.size.height - 2) / 2.0, p_rect.size.width, ProgresSlideImageViewHeight);
    
}

-(void)updateNovelTheme
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
    
    self.progresImageView.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"normalProgressBgColor"]];
    self.progresSlideImageView.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"progressBgColor"]];
    //添加6个节点
    for (int i = 0; i<6; i++) {
        
        UIImageView *pointImageView = [self viewWithTag:(2650+i)];
        pointImageView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    }
    
    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"thumbImg"]];
    [self.pointThumbView setBackgroundImage:image forState:UIControlStateNormal];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self];
    
    CGRect rect = self.progresSlideImageView.frame;
    
    float pointGap = self.frame.size.width/StoryPointSlider_PoinCount;
    CGRect thumbRect = self.pointThumbView.frame;
    NSInteger num = 0;
    CGFloat length = point.x;
    if (length < pointGap/2) {
        thumbRect.origin.x = -self.pointThumbView.width/2.0;
        num = 0;
    } else if (length < pointGap){
        thumbRect.origin.x = pointGap-self.pointThumbView.width/2.0;
        num = 1;
    }else if (length < pointGap*3/2.0){
        thumbRect.origin.x = pointGap-self.pointThumbView.width/2.0;
        num = 1;
    }else if (length < pointGap*2.0){
        
        thumbRect.origin.x = pointGap*2.0-self.pointThumbView.width/2.0;
        num = 2;
    }else if (length < pointGap*5/2.0){
        
        thumbRect.origin.x = pointGap*2.0-self.pointThumbView.width/2.0;
        num = 2;
        
    }else if (length < pointGap*3.0){
        
        thumbRect.origin.x = pointGap*3.0-self.pointThumbView.width/2.0;
        num = 3;
    }
    else if (length < pointGap*7/2.0){
        thumbRect.origin.x = pointGap*3.0-self.pointThumbView.width/2.0;
        num = 3;
    }
    else if (length < pointGap*4.0){
        thumbRect.origin.x = pointGap*4.0-self.pointThumbView.width/2.0;
        num = 4;
    }
    else if (length < pointGap*9/2.0){
        thumbRect.origin.x = pointGap*4.0-self.pointThumbView.width/2.0;
        num = 4;
    }
    else
    {
        thumbRect.origin.x = pointGap*5-self.pointThumbView.width/2.0;
        num = 5;
    }
    
    if (thumbRect.origin.x <= 0) {
        rect.size.width =0;
    }else
    {
        rect.size.width = thumbRect.origin.x + 2;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.pointThumbView.frame = thumbRect;
        self.progresSlideImageView.frame = rect;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(storyPointProgressDealwithRatio:)]) {
        [self.delegate storyPointProgressDealwithRatio:num];
    }

}

@end

@interface SNStoryPointSliderView ()

@property(nonatomic, strong)UIImageView *progresSlideImageView;

@end

@implementation SNStoryPointSliderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}

#pragma mark UIResponder触摸方法重写
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    if (point.x != previousPoint.x) {
        
        CGFloat gap = point.x - previousPoint.x;
        
        if ([self.delegate respondsToSelector:@selector(storyPointProgressMovedGap:isEnd:)]) {
            
            [self.delegate storyPointProgressMovedGap:gap isEnd:NO];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(clickTouchEnded)]) {
        
        [self.delegate clickTouchEnded];
    }
}

@end

