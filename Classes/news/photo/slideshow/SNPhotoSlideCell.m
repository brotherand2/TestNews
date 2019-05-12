
//
//  SNPhotoSlideCell.m
//  sohunews
//
//  Created by wangyy on 15/5/9.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNPhotoSlideCell.h"

#define kRecommendIconBorderWidth   1
#define kRecommendTitleHeight       56/2
#define kRecommendTitleTopMargin    14/2
#define kRecommendTitleBottomMargin    40/2

@implementation SNPhotoSlideCell

@synthesize adTitle = _adTitle;
@synthesize adView = _adView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = frame.size.height - [self recommendTitleTopMargin] - kRecommendTitleHeight - 2;
        self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        self.adView.layer.borderWidth = kRecommendIconBorderWidth;
        self.adView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.adView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.adView];
        
        self.adTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, height + [self recommendTitleTopMargin], frame.size.width, kRecommendTitleHeight+4)];
        self.adTitle.textAlignment = NSTextAlignmentLeft;
        self.adTitle.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.adTitle.textColor = [UIColor whiteColor];
        self.adTitle.backgroundColor = [UIColor clearColor];
        self.adTitle.numberOfLines = 2;
        [self addSubview:self.adTitle];
        
        _adLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-30, height-16, 30, 15)];
//        _adLabel.centerY = self.adTitle.centerY;
//        _adLabel.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3].CGColor;
//        _adLabel.layer.borderWidth = [[SNDevice sharedInstance] isPlus] ? 1.0/3 : 1.0/2;
//        _adLabel.layer.cornerRadius =[[SNDevice sharedInstance] isPlus] ? 2.0/3 : 2.0/2;
        _adLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.font = [UIFont systemFontOfSize:kThemeFontSizeH];
        _adLabel.textColor = SNUICOLOR(kThemeText5Color);
        _adLabel.hidden = YES;
        [self addSubview:_adLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tap
{
    if (nil != _clickBLock) {
        _clickBLock(self);
    }
}

- (int)recommendTitleTopMargin
{
    switch ((int)TTApplicationFrame().size.height) {
        case 548:
            return 8;
        case 568:
            return 8;
        case 460:
            return kRecommendTitleTopMargin;
    }
    
    return kRecommendTitleTopMargin;
}

@end
