//
//  SNStoryGetContentFailedView.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryGetContentFailedView.h"
#import "UIImage+Story.h"
#import "SNStoryContanst.h"
#import "SNStoryUtility.h"
#import "StoryBookList.h"
#import "ChapterList.h"

#define CheckLabelHeight          18.0//CheckLabel的高
#define CheckLabelGap             10.0//CheckLabel与图片间距
#define CheckLabelOriginX         0.0
#define LoadBtnWidth              80.0//重新加载按钮的宽
#define LoadBtnHeight             30.0//重新加载按钮的高
#define LoadBtnlGap               20.0//重新加载按钮与label间距

@implementation SNStoryGetContentFailedView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        UIImage *failedImage = [UIImage imageStoryNamed:@"icofiction_hqsb_v5.png"];
        float centerHeight = (frame.size.height-(failedImage.size.height+CheckLabelGap+CheckLabelHeight+LoadBtnlGap+LoadBtnHeight))/2;
        
        UIImageView *failedImageView= [[UIImageView alloc]initWithFrame:CGRectMake((View_Width - failedImage.size.width)/2, centerHeight, failedImage.size.width, failedImage.size.height)];
        failedImageView.image = failedImage;
        failedImageView.tag = 7800;
        [self addSubview:failedImageView];
        
        UILabel *checkLabel = [[UILabel alloc]initWithFrame:CGRectMake(CheckLabelOriginX, CGRectGetMaxY(failedImageView.frame)+CheckLabelGap, frame.size.width, CheckLabelHeight)];
        checkLabel.font = [UIFont systemFontOfSize:13];
        checkLabel.backgroundColor = [UIColor clearColor];
        checkLabel.textAlignment = NSTextAlignmentCenter;
        checkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
        checkLabel.tag = 7801;
        [self addSubview:checkLabel];
        
        //重新加载按钮
        UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loadBtn.frame = CGRectMake((frame.size.width - LoadBtnWidth)/2, CGRectGetMaxY(checkLabel.frame)+LoadBtnlGap, LoadBtnWidth, LoadBtnHeight);
        [loadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [loadBtn setTitleColor:[UIColor colorFromKey:@"kThemeBlue1Color"] forState:UIControlStateNormal];
        loadBtn.backgroundColor = [UIColor clearColor];
        loadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        loadBtn.tag = 7802;
        [loadBtn addTarget:self action:@selector(loadChapter:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loadBtn];
        
    }
    
    return self;
}

-(void)setStoryGetContentFailedType:(SNStoryGetContentFailedType)storyGetContentFailedType
{
    UILabel *tipLabel = [self viewWithTag:7801];
    if (storyGetContentFailedType == SNStoryGetContentNoNet) {
        tipLabel.text = @"请检查网络重试";
    } else {
        tipLabel.text = @"章节内容获取失败，请重试";
    }
}

-(void)loadChapter:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(refreshRequestWithDic:)]) {
        
        [self.delegate refreshRequestWithDic:nil];
    }
}

-(void)updateNovelTheme
{
    
    UIImageView *failedImageView = [self viewWithTag:7800];
    UIImage *failedImage = [UIImage imageStoryNamed:@"icofiction_hqsb_v5.png"];
    failedImageView.image = failedImage;
    
    UILabel *checkLabel = [self viewWithTag:7801];
    checkLabel.textColor = [UIColor colorFromKey:@"kThemeText7Color"];
    
    UIButton *loadBtn = [self viewWithTag:7802];
    [loadBtn setTitleColor:[UIColor colorFromKey:@"kThemeBlue1Color"] forState:UIControlStateNormal];
}
@end
