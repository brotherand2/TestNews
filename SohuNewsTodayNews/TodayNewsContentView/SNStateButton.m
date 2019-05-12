//
//  SNStateButton.m
//  sohunews
//
//  Created by TengLi on 2017/9/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNStateButton.h"

#define kOriginalTitle   @"没有可以保存的内容"
#define kAddToTitle      @" 保存到搜狐新闻"
#define kAddingTitle     @"正在保存..."
#define kAddSuccessTitle @"已保存到搜狐新闻\n         点击查看"

#define kDefaultColor [UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:1]
#define kAlphaColor   [UIColor colorWithRed:(46.0/255.0) green:(46.0/255.0) blue:(46.0/255.0) alpha:0.6]

@implementation SNStateButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectState = SNStateButtonNormal;
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.numberOfLines = 2;
        [self setTitleColor:kDefaultColor forState:UIControlStateNormal];
    }
    return self;
}

- (void)setCollectState:(SNStateButtonState)collectState {
    _collectState = collectState;
    [self setImage:nil forState:UIControlStateNormal];
    switch (collectState) {
        case SNStateButtonNormal:
//            [self setTitle:kOriginalTitle forState:UIControlStateNormal];
            [self setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:kOriginalTitle attributes:@{NSForegroundColorAttributeName:kDefaultColor}] forState:UIControlStateNormal];
            break;
        case SNStateButtonAddTo:
        {
            [self setImage:[UIImage imageNamed:@"ico_add_v5.png"] forState:UIControlStateNormal];
//            [self setTitle:kAddToTitle forState:UIControlStateNormal];
            [self setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:kAddToTitle attributes:@{NSForegroundColorAttributeName:kDefaultColor}] forState:UIControlStateNormal];
        }
            break;
        case SNStateButtonAdding:
//            [self setTitle:kAddingTitle forState:UIControlStateNormal];
            [self setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:kAddingTitle attributes:@{NSForegroundColorAttributeName:kDefaultColor}] forState:UIControlStateNormal];
            break;
        case SNStateButtonAdded:
        {
//            [self setTitle:kAddSuccessTitle forState:UIControlStateNormal];
                NSRange range = [kAddSuccessTitle rangeOfString:@"点击查看"];
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:kAddSuccessTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:kDefaultColor}];
                [attributeString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],NSForegroundColorAttributeName:kAlphaColor } range:range];
                [self setAttributedTitle:attributeString forState:UIControlStateNormal];

        }
            break;
        default:
            break;
    }
}

@end
