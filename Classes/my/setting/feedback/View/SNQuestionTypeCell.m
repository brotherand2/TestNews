//
//  SNQuestionTypeCell.m
//  sohunews
//
//  Created by 李腾 on 2016/10/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNQuestionTypeCell.h"
#import "SNFBTypeModel.h"

@interface SNQuestionTypeCell ()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *typeLabel;

@end
#define kIconW  39.0f

@implementation SNQuestionTypeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        UIImageView *iconView = [[UIImageView alloc] init];
//        iconView.image = [UIImage imageNamed:@"键盘"];
        iconView.size = CGSizeMake(kIconW, kIconW);
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.left = self.contentView.width / 2 - iconView.width / 2;
        _iconView = iconView;
        [self.contentView addSubview:iconView];
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.text = @"新闻阅读";
        typeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        typeLabel.textColor = SNUICOLOR(kThemeText2Color);
        [typeLabel sizeToFit];
        iconView.top = self.height/2 - (iconView.height + 14 + typeLabel.height)/2 + 5;
        _typeLabel = typeLabel;
        typeLabel.top = iconView.bottom + 14;
        typeLabel.width = self.contentView.width;
        typeLabel.left = self.contentView.width / 2 - typeLabel.width / 2;
        typeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:typeLabel];
        
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = SNUICOLOR(kThemeBg1Color).CGColor;

        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    }
    return self;
}

- (void)setTypeModel:(SNFBTypeModel *)typeModel {
    _typeModel = typeModel;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:typeModel.icon]];
    _typeLabel.text = typeModel.name;
}


@end
