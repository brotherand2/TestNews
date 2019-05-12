//
//  SNSelectImageCollectionViewCell.m
//  sohunews
//
//  Created by 李腾 on 2016/10/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSelectImageCollectionViewCell.h"


@implementation SNSelectImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.bounds];
        imageV.backgroundColor = SNUICOLOR(kThemeBg2Color);
        imageV.contentMode = UIViewContentModeCenter;
        imageV.clipsToBounds = YES;
        [self addSubview:imageV];
        self.imageView = imageV;
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setImage:[UIImage imageNamed:@"imageDeleteButton.png"] forState:UIControlStateNormal];
        [delBtn setImage:[UIImage imageNamed:@"imageDeleteButton-click.png"] forState:UIControlStateHighlighted];
        delBtn.hidden = YES;
        self.delBtn = delBtn;
        [delBtn addTarget:self action:@selector(delImage) forControlEvents:UIControlEventTouchUpInside];
        delBtn.frame = CGRectMake(self.width - 20, 0, 20, 20);
        [self addSubview:delBtn];
    }
    return self;
}

- (void)delImage {
    if ([self.delegate respondsToSelector:@selector(removeImageWithCell:)]) {
        [self.delegate removeImageWithCell:self];
    }
}


@end
