//
//  SNRollingTrainImageTextCell.h
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainCollectionBaseCell.h"
#import "SNCellImageView.h"

typedef enum : NSUInteger {
    SNTrainCellTypeFocus,
    SNTrainCellTypeCards,
} SNTrainCellType;

@interface SNRollingTrainImageTextCell : SNRollingTrainCollectionBaseCell

@property (nonatomic, assign) SNTrainCellType type;
@property (nonatomic, strong) SNCellImageView * cellImageView;
@property (nonatomic, strong) UIImageView * maskShadow;
@property (nonatomic, strong) UIImageView * videoLabel;
@property (nonatomic, strong) UILabel * cellTitleLabel;
@property (nonatomic, strong) UIImageView * editorLogo;
@property (nonatomic, strong) UILabel * editorLabel;
@property (nonatomic, strong) UIView * editorLabelBgView;
@property (nonatomic, strong) UILabel * adLabel;
@property (nonatomic, strong) UILabel * commentLabel;
@property (nonatomic, strong) UILabel * mediaLabel;
@property (nonatomic, strong) UILabel * picCountLabel;
@property (nonatomic, strong) UIImageView * bottomShadow;

- (void)transitionWithRatio:(CGFloat)ratio;

- (void)zoomWithRatio:(CGFloat)ratio;

- (void)layoutWithType:(SNTrainCellType)cellType;

@end
