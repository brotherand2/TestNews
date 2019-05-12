//
//  SNStoryFirstReadTipView.m
//  sohunews
//
//  Created by chuanwenwang on 2016/12/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryFirstReadTipView.h"
#import "UIColor+StoryColor.h"
#import "SNStoryUtility.h"
#import "SNStoryContanst.h"
#import "UIViewAdditions+Story.h"

#define StoryReadGuidePageViewBackGroundColor                       @"#000000"
#define StoryReadGuidePageViewBackGround                            [[UIColor storyColorFromString:StoryReadGuidePageViewBackGroundColor]colorWithAlphaComponent:0.3]
#define StoryReadGuideCenterViewBackGround                          [[UIColor storyColorFromString:StoryReadGuidePageViewBackGroundColor]colorWithAlphaComponent:0.4]
#define StoryReadGuideCenterView_LineColor                          @"#5a5a5a"

#define StoryReadGuidePageView_ImageMargin                          14.0
#define StoryReadGuidePageView_ImageGap                             6.0
#define StoryReadGuidePageView_LabelWidth                           80.0
#define StoryReadGuideCenterView_Lineheight                         137.0
#define StoryReadGuideCenterViewHeight                              ((View_Height - 2*StoryReadGuideCenterView_Lineheight))
#define StoryReadGuideCenterView_LineWidth                          1.5
#define StoryReadGuideCenterView_LineOriginY                        0.0
#define StoryReadGuideCenterView_imageGap                           13.0
#define StoryReadGuideCenterView_LabelGap                           3.0
#define StoryReadGuideCenterViewGap                                 ((View_Width)/3.0)

@implementation SNStoryFirstReadTipView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = StoryReadGuidePageViewBackGround;
        [self createView];
    }
    
    return self;
}

-(void)createView
{
    //上下篇
    UIImage *image = [UIImage imageNamed:@"icofiction_guideleft_v5.png"];
    UIFont *font = [UIFont systemFontOfSize:18];
    float screenHeight = (View_Height - image.size.height - StoryReadGuidePageView_ImageGap - font.lineHeight) / 2.0;
    
    for (int i = 0; i < 2; i++) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(StoryReadGuidePageView_ImageMargin, screenHeight, image.size.width, image.size.height)];
        UILabel *label = [[UILabel alloc]init];
        label.font = font;
        label.textColor = [UIColor colorFromKey:kThemeText5Color];
        
        [self addSubview:imageView];
        [self addSubview:label];
        
        if (i == 0) {
            imageView.image = image;
            
            label.frame = CGRectMake(StoryReadGuidePageView_ImageMargin, CGRectGetMaxY(imageView.frame) + StoryReadGuidePageView_ImageGap, StoryReadGuidePageView_LabelWidth, font.lineHeight);
            label.text = @"上一篇";
        } else {
            
            imageView.frame = CGRectMake(View_Width - StoryReadGuidePageView_ImageMargin - image.size.width, screenHeight, image.size.width, image.size.height);
            imageView.image = [UIImage imageNamed:@"icofiction_guideright_v5.png"];
            label.frame = CGRectMake(View_Width - StoryReadGuidePageView_ImageMargin - StoryReadGuidePageView_LabelWidth, CGRectGetMaxY(imageView.frame) + StoryReadGuidePageView_ImageGap, StoryReadGuidePageView_LabelWidth, font.lineHeight);
            label.textAlignment = NSTextAlignmentRight;
            label.text = @"下一篇";
        }
    }
    
    //中间view
    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(StoryReadGuideCenterViewGap, StoryReadGuideCenterView_Lineheight, StoryReadGuideCenterViewGap, StoryReadGuideCenterViewHeight)];
    centerView.backgroundColor = StoryReadGuideCenterViewBackGround;
    [self addSubview:centerView];
    
    
    //中间view左边线
    UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(StoryReadGuideCenterViewGap*2 - StoryReadGuideCenterView_LineWidth, StoryReadGuideCenterView_LineOriginY, StoryReadGuideCenterView_LineWidth, StoryReadGuideCenterView_Lineheight)];
    leftLineView.backgroundColor = [UIColor storyColorFromString:StoryReadGuideCenterView_LineColor];
    [self addSubview:leftLineView];
    
    //中间view右边线
    UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(StoryReadGuideCenterViewGap, CGRectGetMaxY(centerView.frame), StoryReadGuideCenterView_LineWidth, StoryReadGuideCenterView_Lineheight)];
    rightLineView.backgroundColor = [UIColor storyColorFromString:StoryReadGuideCenterView_LineColor];
    [self addSubview:rightLineView];
    
    //点击中间
    UIImage *centerImage = [UIImage imageNamed:@"icofiction_guideclick_v5.png"];
    float centerHeigt = (StoryReadGuideCenterViewHeight - centerImage.size.height - StoryReadGuideCenterView_imageGap - font.lineHeight*2 - StoryReadGuideCenterView_LabelGap)/2.0;
    
    UIImageView *centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake((centerView.width - centerImage.size.width)/2, centerHeigt, centerImage.size.width, centerImage.size.height)];
    centerImageView.image = centerImage;
    [centerView addSubview:centerImageView];
    
    //@"点击中间"
    CGRect rect = [@"点击中间" boundingRectWithSize:CGSizeMake(StoryReadGuideCenterViewGap, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake((centerView.width - rect.size.width)/2.0, CGRectGetMaxY(centerImageView.frame)+StoryReadGuideCenterView_imageGap, rect.size.width, font.lineHeight)];
    centerLabel.font = font;
    centerLabel.text = @"点击中间";
    centerLabel.textColor = [UIColor colorFromKey:kThemeText5Color];
    [centerView addSubview:centerLabel];
    
    //@"呼出工具栏"
    rect = [@"呼出工具栏" boundingRectWithSize:CGSizeMake(StoryReadGuideCenterViewGap, font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    UILabel *labelTool = [[UILabel alloc]initWithFrame:CGRectMake((centerView.width - rect.size.width)/2.0, CGRectGetMaxY(centerLabel.frame)+StoryReadGuideCenterView_LabelGap, rect.size.width, font.lineHeight)];
    labelTool.font = font;
    labelTool.text = @"呼出工具栏";
    labelTool.textColor = [UIColor colorFromKey:kThemeText5Color];
    [centerView addSubview:labelTool];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeThisView)];
    [self addGestureRecognizer:tapGesture];
}

-(void)removeThisView
{
    [self removeFromSuperview];
}

@end
