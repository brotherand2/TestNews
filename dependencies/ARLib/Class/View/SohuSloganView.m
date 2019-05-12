//
//  SohuSloganView.m
//  SohuAR
//
//  Created by sun on 2016/12/5.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuSloganView.h"
#import "SohuARMacro.h"

@interface SohuSloganView ()

@property(nonatomic,strong) NSDictionary *information;

@end

@implementation SohuSloganView

+(void)showToView:(UIView *)view sloganImage:(UIImage *)image size:(CGSize)size sloganinformation:(NSDictionary *)information{
    __block  SohuSloganView *sohuSloganView=[[SohuSloganView alloc]initWithFrame:CGRectMake(kscreenWidth/2-size.width/2, view.frame.size.height-70-size.height, size.width,size.height)];
    sohuSloganView.information=information;
    [view addSubview:sohuSloganView];
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.frame=CGRectMake(0, 0, sohuSloganView.frame.size.width, sohuSloganView.frame.size.height);
    imageView.image=image;
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled=YES;
    [sohuSloganView addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            sohuSloganView.alpha=0;
        } completion:^(BOOL finished) {
            [sohuSloganView removeFromSuperview];
            sohuSloganView=nil;
        }];
    });
}



+(void)showToView1:(UIView *)view
      sloganImage:(UIImage *)image
             size:(CGSize)size
 sloganinformation:(NSDictionary *)information{
    __block  SohuSloganView *sohuSloganView=[[SohuSloganView alloc]initWithFrame:CGRectMake(kscreenWidth/2-size.width/2, view.frame.size.height-70-size.height, size.width,size.height)];
    sohuSloganView.information=information;
    [view addSubview:sohuSloganView];
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.frame=CGRectMake(0, 0, sohuSloganView.frame.size.width, sohuSloganView.frame.size.height);
    imageView.image=image;
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled=YES;
    [sohuSloganView addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([information[@"duration"] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.8 animations:^{
            sohuSloganView.alpha=0;
        } completion:^(BOOL finished) {
            [sohuSloganView removeFromSuperview];
            sohuSloganView=nil;
        }];
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        if ([self.information[@"enableHide"] boolValue]) {
        [self removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sohuSloganView" object:self.information];
}

@end
