//
//  SNShareCollectionViewCell.m
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareCollectionViewCell.h"
#import "SNNewsShareParamsHeader.h"

@interface SNShareCollectionViewCell ()

@property (nonatomic,strong) UIImageView* newsImageView;

@end

@implementation SNShareCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - kShareIconImgWidth) / 2, 0, kShareIconImgWidth, kShareIconImgWidth)];
        _iconImageView = iconImgV;
        iconImgV.layer.cornerRadius = kShareIconImgWidth / 2;
        iconImgV.backgroundColor = SNUICOLOR(kThemeBg4Color);
        [self.contentView addSubview:iconImgV];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kShareIconImgWidth + 5, frame.size.width, 20)];
        label.textColor = SNUICOLOR(kThemeText1Color);
        label.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        _label = label;
        
        //        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        //        self.selectedBackgroundView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        
        self.newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(36,-8, 30, 12.5)];
        [self addSubview:self.newsImageView];
        [self.newsImageView setBackgroundColor:[UIColor clearColor]];
        self.newsImageView.hidden = YES;
        self.contentView.clipsToBounds = NO;
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)setImageViewStateWithHightlighted:(BOOL)hightlight andDict:(NSDictionary *)dict {
    if (hightlight) {
        NSString *imgName = [NSString stringWithFormat:@"%@press_v5.png",[[dict objectForKey:kShareIconImage] substringToIndex:[[dict objectForKey:kShareIconImage] length] - 7]];
        self.iconImageView.image = [UIImage imageNamed:imgName];
        self.label.textColor = SNUICOLOR(kThemeBg1Color);
    } else {
        self.iconImageView.image = [UIImage imageNamed:[dict objectForKey:kShareIconImage]];
        self.label.textColor = SNUICOLOR(kThemeText1Color);
    }
}

- (void)setDataWithDict:(NSDictionary *)dict {
    NSString *imageName = [dict objectForKey:kShareIconImage];
    _iconImageView.image = [UIImage imageNamed:imageName];
    _label.text = [dict objectForKey:kShareIconTitle];
    if ([_label.text isEqualToString:kShareTitleScreenshot]) {
        [self showNewsImg];
    }
}

- (void)showNewsImg{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kFirstShowScreenShareKey1]) {
        self.newsImageView.image = [UIImage themeImageNamed:@"icofloat_new_v5.png"];
        self.newsImageView.hidden = NO;
    }
}

@end
