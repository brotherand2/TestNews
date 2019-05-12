//
//  SNStoryNetOrNoDataView.m
//  sohunews
//
//  Created by chuanwenwang on 16/11/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryNetOrNoDataView.h"
#import "UIImage+Story.h"

#define FailImageViewLeftOffset                         0.0
#define FailImageViewTopOffset                          0.0
#define FailImageViewGap                                12.0

@implementation SNStoryNetOrNoDataView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _gap = FailImageViewGap;
        _font = [UIFont systemFontOfSize:13];
        _imageName = @"icofiction_hqsb_v5.png";
        _isTap = YES;
        UIImage * image = [UIImage imageStoryNamed:@"icofiction_hqsb_v5.png"];
        self.failImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FailImageViewLeftOffset, FailImageViewTopOffset, image.size.width, image.size.height)];
        self.failImageView.image = image;
        self.failImageView.centerX = self.centerX;
        self.failImageView.centerY = self.centerY;
        [self addSubview:self.failImageView];
        
    }
    
    return self;
}

-(void)setGap:(float)gap
{
    if (self.gap != gap) {
        
        _gap = gap;
    }
}

-(void)setImageName:(NSString *)imageName
{
    if (self.imageName != imageName) {
        
        _imageName = imageName;
    }
}

-(void)setFont:(UIFont *)font
{
    if (self.font != font) {
        
        _font = font;
    }
}

-(void)setIsTap:(BOOL)isTap
{
    if (self.isTap != isTap) {
        
        _isTap = isTap;
    }
}


@end
