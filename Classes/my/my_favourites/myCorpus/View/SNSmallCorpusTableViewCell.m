//
//  SNSmallCorpusTableViewCell.m
//  sohunews
//
//  Created by Scarlett on 15/9/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNSmallCorpusTableViewCell.h"

#define kSmallCorpusLabelFont ((kAppScreenWidth == 320.0) ? kThemeFontSizeD : kThemeFontSizeE)

@interface SNSmallCorpusTableViewCell () {
    UIImageView *_corpusImageView;
    UILabel *_corpusLabel;
}

@end

@implementation SNSmallCorpusTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSmallCorpusTabelCellHeight)];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        
        _corpusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSmallCorpusTabelLeftDistance, (kSmallCorpusTabelCellHeight-kSmallImageViewWidth)/2, kSmallImageViewWidth, kSmallImageViewWidth)];
        [self.contentView addSubview:_corpusImageView];
        
        _corpusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kSmallCorpusTabelTopDistance, kAppScreenWidth-_corpusImageView.right-kSmallCorpusTabelLeftDistance, self.height)];
        _corpusLabel.backgroundColor = [UIColor clearColor];
        _corpusLabel.center = _corpusImageView.center;
        _corpusLabel.left = _corpusImageView.right + kSmallCorpusTabelLeftDistance;
        _corpusLabel.font = [UIFont systemFontOfSize:kSmallCorpusLabelFont];
        [self.contentView addSubview:_corpusLabel];
    }
    return self;
}

- (void)setCellWithText:(NSString *)text imageName:(NSString *)imageName{
    if ([text isEqualToString:kCorpusNewFavourite]) {
        _corpusLabel.textColor = SNUICOLOR(kThemeRed1Color);
    }
    else {
        _corpusLabel.textColor = SNUICOLOR(kThemeText1Color);
    }
    _corpusLabel.text = text;
    _corpusImageView.image = [UIImage imageNamed:imageName];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [self setHighlighted:selected animated:animated];
//    // Configure the view for the selected state
//}
//
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    if (highlighted) {
//        _bgImageView.alpha = 1;
//        _bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
//    }
//    else {
//        _bgImageView.alpha = 0;
//        _bgImageView.backgroundColor = [UIColor clearColor];
//    }
//}


@end
