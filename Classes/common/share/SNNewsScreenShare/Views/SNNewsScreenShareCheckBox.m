//
//  SNNewsScreenShareCheckBox.m
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareCheckBox.h"

@interface SNNewsScreenShareCheckBox ()

@property (nonatomic,strong) UIImageView* bgImgView;

@property (nonatomic,strong) UIImage* uncheckImg;//未选中
@property (nonatomic,strong) UIImage* electImg;//选中


@end

@implementation SNNewsScreenShareCheckBox

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.uncheckImg = [UIImage themeImageNamed:@"ico_uncheck_v5.png"];
    self.electImg = [UIImage themeImageNamed:@"ico_elect_v5.png"];
    
    _bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_bgImgView];
}

-(void)setElect:(BOOL)b{
    self.isSelected = b;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected == YES) {
        self.bgImgView.image = self.electImg;
    }
    else if (_isSelected == NO){
        self.bgImgView.image = self.uncheckImg;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
