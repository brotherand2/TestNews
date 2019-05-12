//
//  SNBrandView.m
//  sohunews
//
//  Created by H on 15/3/30.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNBrandView.h"

@interface SNBrandView ()

@end

@implementation SNBrandView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
        [self createContent];
    }
    
    return  self;
}

- (void)createContent {///

    self.localBrand = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.festivalIdentity = [[SNWebImageView alloc] initWithFrame:CGRectZero];
    if (kAppScreenWidth == kIPHONE_4_WIDTH) {
        self.localBrand.frame = CGRectMake(0, 0, self.frame.size.width, 195/2.0f);
        self.localBrand.image = [UIImage imageNamed:@"icoloading_sohu_320w.png"];
        self.festivalIdentity.frame = CGRectMake(408/2.0f, 195/2.0f - 110/2.0f - 42/2.0f, 153/2.0f, 110/2.0f);
    }else if([UIScreen mainScreen].bounds.size.height == kIPHONE_X_HEIGHT) {
        //@qz 适配广告加的图
        self.localBrand.frame = CGRectMake(0, 0, self.frame.size.width, 447/3.0f);
        self.localBrand.image = [UIImage imageNamed:@"icoloading_sohu_x@3x.png"];
        self.festivalIdentity.frame = CGRectMake(790/3.0f, 381/3.0f - 224/3.0f - 78/3.0f, 310/3.0f, 224/3.0f);
    }else if (kAppScreenWidth == kIPHONE_6_WIDTH) {
        self.localBrand.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.localBrand.image = [UIImage imageNamed:@"icoloading_sohu_375w.png"];
        self.festivalIdentity.frame = CGRectMake(477/2.0f, self.frame.size.height - 134/2.0f - 46/2.0f, 188/2.0f, 134/2.0f);
    }else if(kAppScreenWidth == kIPHONE_6P_WIDTH) {
        self.localBrand.frame = CGRectMake(0, 0, self.frame.size.width, 381/3.0f);
        self.localBrand.image = [UIImage imageNamed:@"icoloading_sohu@3x.png"];
        self.festivalIdentity.frame = CGRectMake(790/3.0f, 381/3.0f - 224/3.0f - 78/3.0f, 310/3.0f, 224/3.0f);
    }else {
        self.localBrand.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.localBrand.image = [UIImage imageNamed:@"icoloading_sohu_375w.png"];
        self.festivalIdentity.frame = CGRectMake(477/2.0f, self.frame.size.height - 134/2.0f - 46/2.0f, 188/2.0f, 134/2.0f);
    }
  
    self.localBrand.backgroundColor = [UIColor clearColor];
    [self.localBrand setUserInteractionEnabled:NO];
    [self addSubview:self.localBrand];
    
    self.festivalIdentity.backgroundColor = [UIColor clearColor];
    [self.localBrand addSubview:self.festivalIdentity];
    
}

@end
