//
//  SNLoadingImageAnimationView.m
//  sohunews
//
//  Created by Scarlett on 16/9/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNLoadingImageAnimationView.h"

#define kImageViewAnimationDuration 2.0
#define kAnimationImageCount 38

@interface SNLoadingImageAnimationView ()

@property (nonatomic, strong) UIImageView *animationImageView;

@end

@implementation SNLoadingImageAnimationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, self.animationImageView.width, self.animationImageView.height);
        [self addSubview:self.animationImageView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (UIImageView *)animationImageView {
    if (!_animationImageView) {
        UIImage *animationImage = [UIImage imageNamed:@"sohu_loading_1.png"];
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, animationImage.size.width, animationImage.size.height)];
        NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 1; i < kAnimationImageCount + 1; i ++) {//共38帧
            [muArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"sohu_loading_%d.png", i]]];
        }
        _animationImageView.animationImages = [NSArray arrayWithArray:muArray];
        _animationImageView.animationDuration = kImageViewAnimationDuration;
        _animationImageView.animationRepeatCount = 0;
    }
    
    return _animationImageView;
}

- (void)setStatus:(SNImageLoadingStatus)status {
    _status = status;
    switch (status) {
        case SNImageLoadingStatusLoading:
            [self startAnimation];
            break;
        case SNImageLoadingStatusStopped:
            [self stopAnimation];
            break;
        default:
            break;
    }
}

- (void)startAnimation {
    self.origin = self.targetView.origin;
    self.center = CGPointMake(kAppScreenWidth/2, kAppScreenHeight/2);
    [self.targetView addSubview:self];
    [self.animationImageView startAnimating];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kImageAnimationStatus];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)stopAnimation {
    [self.animationImageView stopAnimating];
    [self removeFromSuperview];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kImageAnimationStatus];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateTheme {
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 1; i < kAnimationImageCount + 1; i ++) {//共38帧
        [muArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"sohu_loading_%d.png", i]]];
    }
    _animationImageView.animationImages = [NSArray arrayWithArray:muArray];
    if (_status == SNImageLoadingStatusLoading) {
        [_animationImageView startAnimating];
    }
}

- (void)dealloc {
     //(_animationImageView);
     //(_targetView);
    [SNNotificationManager removeObserver:self];
}

@end
