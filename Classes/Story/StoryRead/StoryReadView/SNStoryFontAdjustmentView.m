//
//  SNStoryFontAdjustmentView.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/8.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryFontAdjustmentView.h"
#import "SNStoryContanst.h"
#import "SNStorySlider.h"
#import "SNStoryPointSlider.h"
#import "UIImage+Story.h"
#import "SNNovelThemeManager.h"
#import "SNStoryPage.h"
#import "StoryConfig.h"
#import "SNStoryUtility.h"

#define FontAndRightOrginX                    19.0
#define FontAndRightOrginY                    21.0
#define FontAndRightWidth                     35.0
#define PointSliderGap                        10.0
#define StorySliderGap                        11.5
#define StorySliderHeightGap                  27.0
#define StorySliderHeight                     18.0
#define ImageViewEdgeInsets                   (UIEdgeInsetsMake(0, 0, 0, 0))

@interface SNStoryFontAdjustmentView ()<SNStorySliderProtocol, SNStoryPointSliderProtocol>

@property(nonatomic, strong)SNStoryPointSlider *pointSlider;

@end
@implementation SNStoryFontAdjustmentView

-(instancetype)initWithFrame:(CGRect)frame novelId:(NSString*)novelId
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
        NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
        
        self.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"bgColor"]];
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        viewLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
        viewLine.tag = 3111;
        [self addSubview:viewLine];
        
        float width = frame.size.width - (FontAndRightOrginX + FontAndRightWidth)*2 - 3*FontAndRightWidth;
        float gap = width / 4;
        
        //字体及亮度调节
        for (int i = 0; i < 4; i++) {
            
            UIButton *buttonImage = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonImage.adjustsImageWhenHighlighted = NO;
            buttonImage.tag = 5000 + i;
            [self addSubview:buttonImage];
            
            switch (i) {
                case 0:
                {
                    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"fontSmallImg"]];
                    [buttonImage setImage:image forState:UIControlStateNormal];
                    buttonImage.frame = CGRectMake(FontAndRightOrginX - 17, FontAndRightOrginY - 10, image.size.width + 10, image.size.height + 15);
                    [buttonImage addTarget:self action:@selector(fontadjust:) forControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                    
                case 1:
                {
                    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"fontBigImg"]];
                    [buttonImage setImage:image forState:UIControlStateNormal];
                    buttonImage.frame = CGRectMake(frame.size.width - FontAndRightOrginX - image.size.width + 6, FontAndRightOrginY - 4 - 7, image.size.width + 15, image.size.height + 15);
                    [buttonImage addTarget:self action:@selector(fontadjust:) forControlEvents:UIControlEventTouchUpInside];
                }
                break;
                    
                case 2:
                {
                    UIImage *image1 = [UIImage imageStoryNamed:[dic objectForKey:@"fontBigImg"]];
                    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"brightnessSmallImg"]];
                    [buttonImage setImage:image forState:UIControlStateNormal];
                    buttonImage.frame = CGRectMake(FontAndRightOrginX - 5, FontAndRightOrginY * 2 + image1.size.height+2, image.size.width, image.size.height);
                }
                    break;
                    
                case 3:
                {
                    UIImage *image1 = [UIImage imageStoryNamed:[dic objectForKey:@"fontBigImg"]];
                    UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"brightnessBigImg"]];
                    [buttonImage setImage:image forState:UIControlStateNormal];
                    buttonImage.frame = CGRectMake(frame.size.width - FontAndRightOrginX - FontAndRightOrginX + 6, FontAndRightOrginY * 2 + image1.size.height, image.size.width, image.size.height);
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        float fontSize = 18;
        NSArray *array = [StoryConfig fecthStoryConfig];
        if (array.count > 0) {
            
            StoryConfig *config = [array firstObject];
            
            if (config.chapterFont > 0) {
                fontSize = config.chapterFont;
            }
        }
        
        NSInteger po = [SNStoryFontAdjustmentView getStoryPoint:fontSize];
        
        //字号调节
        UIImage *imageFont = [UIImage imageStoryNamed:[dic objectForKey:@"fontSmallImg"]];
        UIImage *imageRFont = [UIImage imageStoryNamed:[dic objectForKey:@"fontBigImg"]];
        SNStoryPointSlider *pointSlider = [[SNStoryPointSlider alloc]initWithFrame:CGRectMake(FontAndRightOrginX +imageFont.size.width + PointSliderGap, FontAndRightOrginY, (frame.size.width - (FontAndRightOrginX+PointSliderGap)*2 - imageRFont.size.width - imageFont.size.width), StorySliderHeight)];
//        pointSlider.rate = po;
        pointSlider.maximumValue = 100;
        pointSlider.delegate = self;
        self.pointSlider = pointSlider;
        [self addSubview:pointSlider];
        [pointSlider setInitPosition:po];
        
        //亮度调节
        UIImage *image = [UIImage imageStoryNamed:[dic objectForKey:@"brightnessSmallImg"]];
        UIImage *imageR = [UIImage imageStoryNamed:[dic objectForKey:@"brightnessBigImg"]];
        SNStorySlider *slider = [[SNStorySlider alloc]initWithFrame:CGRectMake(FontAndRightOrginX +image.size.width + StorySliderGap, FontAndRightOrginY * 2 + StorySliderHeightGap, (frame.size.width - (FontAndRightOrginX+StorySliderGap)*2 - imageR.size.width - image.size.width), StorySliderHeight)];
        self.slider = slider;
        
        //wangshun
        NSNumber* alphaNum = [SNUserDefaults objectForKey:kSNStory_Screen_Brightness];
        //1-readRate-0.2 = alpha
        CGFloat f = 0 ;
        if (alphaNum) {
            CGFloat a = alphaNum.floatValue;
            if (a>0.8) {
                a = 0.8;
            }
            
            CGFloat b = (a/0.8);
        
            f = 1-(b*1);
        }
        
        self.slider.rate = alphaNum?f:1;
        self.slider.maximumValue = 100;
        slider.delegate = self;
        [self addSubview:slider];
        
        //背景色
        for (int i = 0; i < 5; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i > 0 && i < 4) {
                
                button.frame = CGRectMake(FontAndRightOrginX + (gap+FontAndRightWidth)*i, frame.size.height - 21 - FontAndRightWidth, FontAndRightWidth, FontAndRightWidth);
            }
            
            button.layer.cornerRadius = FontAndRightWidth / 2.0;
            button.tag = 2000 + i;
            [button addTarget:self action:@selector(storyBackgroundSet:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            switch (i) {
                case 0:
                    button.backgroundColor = [UIColor storyColorFromString:StoryReadBackgroundColor1];
                    button.frame = CGRectMake(FontAndRightOrginX, frame.size.height - FontAndRightOrginY - FontAndRightWidth, FontAndRightWidth, FontAndRightWidth);
                    break;
                    
                case 1:
                    button.backgroundColor = [UIColor storyColorFromString:StoryReadBackgroundColor2];
                    break;
                    
                case 2:
                    button.backgroundColor = [UIColor storyColorFromString:StoryReadBackgroundColor3];
                    break;
                    
                case 3:
                    button.backgroundColor = [UIColor storyColorFromString:StoryReadBackgroundColor4];
                    break;
                    
                case 4:
                    button.backgroundColor = [UIColor storyColorFromString:StoryReadBackgroundColor5];
                    button.frame = CGRectMake(View_Width - FontAndRightOrginX - FontAndRightWidth, frame.size.height - FontAndRightOrginY - FontAndRightWidth, FontAndRightWidth, FontAndRightWidth);
                    break;
                    
                default:
                    break;
            }
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
            
            NSInteger selectIndex = [[userDefault objectForKey:@"storyColorTheme"]integerValue];
            if (selectIndex == 4 && i != 4) {
                button.layer.borderWidth = 0;
            }
            else
            {
                button.layer.borderWidth = 1;
            }
            
            if (i == selectIndex) {
                
                button.layer.borderColor = [UIColor colorFromKey:[dic objectForKey:@"readSelectedRadiuColor"]].CGColor;
               
            } else {
                button.layer.borderColor = [UIColor colorFromKey:@"ReadNormalColor"].CGColor;
            }
        }
    }
    
    return self;
}


-(void)storyBackgroundSet:(UIButton *)button
{
    //设置选中色
    SNNovelThemeManager *novelThemeManager = [SNNovelThemeManager manager];
    
    switch (button.tag - 2000) {
            
        case 0:
        {
            [novelThemeManager setNovelDefaultTheme];
        }
            break;
            
        case 1:
        {
            [SNStoryPage setReadBackgroundColorWithColorStr:StoryReadBackgroundColor2];
            [novelThemeManager setNovelPictureTheme];
        }
            break;
            
        case 2:
        {
            [SNStoryPage setReadBackgroundColorWithColorStr:StoryReadBackgroundColor3];
            [novelThemeManager setNovelWaterRedTheme];
        }
            break;
            
        case 3:
        {
            [SNStoryPage setReadBackgroundColorWithColorStr:StoryReadBackgroundColor4];
            [novelThemeManager setNovelCyanTheme];
        }
            break;
            
        case 4:
        {
            [novelThemeManager setNovelNightTheme];
        }
            break;
            
        default:
            break;
            
    }
}

#pragma mark - 计算亮度
#pragma mark - 点击计算亮度
-(void)storyProgressDealwithRatio:(float)readRate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeScreenBrightness:)]) {
        [self.delegate changeScreenBrightness:readRate];
    }
}

#pragma mark - 移动计算亮度
-(void)storyProgressMoveWithRate:(float)rate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeScreenBrightness:)]) {
        [self.delegate changeScreenBrightness:rate];
    }
}

//计算字号
-(void)storyPointProgressDealwithRatio:(float)readRate
{
    CGFloat fontSize = [SNStoryFontAdjustmentView getStoryFontSize:readRate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeFont:)]) {
        [self.delegate changeFont:fontSize];
    }
}

-(void)fontadjust:(UIButton *)button
{
    CGFloat fontSize = 18;
    NSArray *array = [StoryConfig fecthStoryConfig];
    if (array.count > 0) {
        
        StoryConfig *config = [array firstObject];
        fontSize = config.chapterFont;
    }
    
    NSInteger point = [SNStoryFontAdjustmentView getStoryPoint:fontSize];
    if (button.tag == 5000) {
        
        if (point > 0) {
            point --;
        }
    }else{
    
        if (point < 5) {
            point++;
        }
    }
    
    [self.pointSlider setInitPosition:point];
    [self storyPointProgressDealwithRatio:point];
}

-(void)updateNovelTheme
{
    [self.pointSlider updateNovelTheme];
    [self.slider updateNovelTheme];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
    NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
    
    self.backgroundColor = [UIColor colorFromKey:[dic objectForKey:@"bgColor"]];
    UIView *viewLine = [self viewWithTag:3111];
    viewLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    
    //字体及亮度调节
    for (int i = 0; i < 4; i++) {
        
        UIButton *button = [self viewWithTag:(5000 + i)];
        
        switch (i) {
            case 0:
                [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"fontSmallImg"]] forState:UIControlStateNormal];
                break;
                
            case 1:
                [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"fontBigImg"]] forState:UIControlStateNormal];
                break;
                
            case 2:
                [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"brightnessSmallImg"]] forState:UIControlStateNormal];
                break;
                
            case 3:
                [button setImage:[UIImage imageStoryNamed:[dic objectForKey:@"brightnessBigImg"]] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
    
    //选中色
    for (int i =0; i<5; i++) {
        UIButton *buttonReset = [self viewWithTag:(2000+i)];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *storyColorTheme = [userDefault objectForKey:@"storyColorTheme"];
        
        NSInteger selectIndex = [storyColorTheme integerValue];
        if (selectIndex == 4 && i != 4) {
            buttonReset.layer.borderWidth = 0;
        }
        else
        {
            buttonReset.layer.borderWidth = 1;
        }
        
        if (i == selectIndex) {
            
            NSDictionary *dic = [SNStoryUtility getReadPropertyWithStr:storyColorTheme];
            buttonReset.layer.borderColor = [UIColor colorFromKey:[dic objectForKey:@"readSelectedRadiuColor"]].CGColor;
        }
        else
        {
            buttonReset.layer.borderColor = [UIColor colorFromKey:@"ReadNormalColor"].CGColor;
        }
        
    }
}

+ (CGFloat)getStoryFontSize:(float)readRate{
    CGFloat fontSize = 18;
    
    if (readRate == 0.0) {
        fontSize = 16;
    }
    else if (readRate == 1.0){
        fontSize = 18;
    }
    else if (readRate == 2.0){
        fontSize = 20;
    }
    else if (readRate == 3.0){
        fontSize = 22;
    }
    else if (readRate == 4.0){
        fontSize = 24;
    }
    else if (readRate == 5.0){
        fontSize = 26;
    }
    return fontSize;
}

+ (NSInteger)getStoryPoint:(float)readrate{
    NSInteger f = readrate/1;
    NSInteger po = 18;
    
    if (f == 16) {
        po = 0;
    }
    else if (f == 18){
        po = 1;
    }
    else if (f == 20){
        po = 2;
    }
    else if (f == 22){
        po = 3;
    }
    else if (f == 24){
        po = 4;
    }
    else if (f == 26){
        po = 5;
    }
    return po;
}

@end
