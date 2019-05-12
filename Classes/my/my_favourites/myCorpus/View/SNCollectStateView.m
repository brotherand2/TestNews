//
//  SNCollectStateView.m
//  sohunews
//
//  Created by TengLi on 2017/9/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCollectStateView.h"

#define kCollectStateUnaudited @"审核未通过"
#define kCollectStatePublished @"发布成功"

@interface SNCollectStateView ()

@property (nonatomic, weak) UILabel *stateLabel;
@property (nonatomic, weak) UIButton *stateImageView;
@end

@implementation SNCollectStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = [kCollectStatePublished textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]].height + 10;
        self.width = [kCollectStatePublished textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]].width + 50;
        self.userInteractionEnabled = YES;
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        stateLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        stateLabel.textColor = SNUICOLOR(kThemeRed1Color);
        stateLabel.text = kCollectStateUnaudited;
        [stateLabel sizeToFit];
        stateLabel.centerY = self.height/2;
        self.stateLabel = stateLabel;
        [self addSubview:stateLabel];
        
        UIImage *stateImage = [UIImage imageNamed:@"icocollection_sh_v5.png"];
        UIButton *stateImageView = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stateLabel.frame)+4, 0, stateImage.size.width + 10, self.height)];
//        stateImageView.centerY = self.height/2;
        [stateImageView setImage:stateImage forState:UIControlStateNormal];
        [stateImageView addTarget:self action:@selector(stateToast:) forControlEvents:UIControlEventTouchUpInside];
        self.stateImageView = stateImageView;
        [self addSubview:stateImageView];
    }
    return self;
}

- (void)setCollectState:(SNCollectState)collectState {
    _collectState = collectState;
    switch (collectState) {
        case SNCollectStateUnaudited:
        {
            self.stateLabel.text = kCollectStateUnaudited;
            self.stateLabel.textColor = SNUICOLOR(kThemeRed1Color);
            [self.stateLabel sizeToFit];
            [self.stateImageView setImage:[UIImage imageNamed:@"icocollection_sh_v5.png"] forState:UIControlStateNormal];
            self.stateImageView.left = self.stateLabel.right;
        }
            break;
        case SNCollectStatePublished:
        {
            self.stateLabel.text = kCollectStatePublished;
            self.stateLabel.textColor = SNUICOLOR(kThemeText3Color);
            [self.stateLabel sizeToFit];
            [self.stateImageView setImage:[UIImage imageNamed:@"icocollection_shtg_v5.png"] forState:UIControlStateNormal];
            self.stateImageView.left = self.stateLabel.right;
        }
            break;
            
        default:
            break;
    }
}

- (void)stateToast:(UIButton *)sender {

    if (self.collectState == SNCollectStateUnaudited && self.stateMessage.length > 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:self.stateMessage toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

@end
