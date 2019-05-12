//
//  SNBackThirdAppView.m
//  sohunews
//
//  Created by yangln on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBackThirdAppView.h"

#define kBackButtonLeftDistance 10.0/2
#define kBackButtonBetweenDistance 10.0/2
#define kCloseButtonRightDistance 24.0/2
#define kCloseButtonbetweenDistance 28.0/2
#define kBackViewBottomDistance 310/2.0
#define kBackViewHeight 60.0/2

@interface SNBackThirdAppView()
@property (nonatomic, strong) NSString *backAppScheme;
@property (nonatomic, strong) NSString *backAppTitle;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation SNBackThirdAppView

- (id)init {
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setBackAppInfo:(NSString *)urlString {
    if (urlString.length > 0) {
        NSString *newString = [NSString stringWithFormat:@"%@%@", kProtocolNews, urlString];
        NSDictionary *dict = [SNUtility parseProtocolUrl:newString schema:kProtocolNews];
        self.backAppScheme = [dict stringValueForKey:kUrl defaultValue:@""];
        self.backAppTitle = [dict stringValueForKey:kTitle defaultValue:@""];
        if (self.backAppScheme.length > 0 && self.backAppTitle.length > 0) {
            if ([SNUtility isContainSchemeWithType:[NSString stringWithFormat:@"%d", REFER_BACK_THIRD_APP] urlString:self.backAppScheme]) {
                [self addBackView];
            }
        }
    }
}

- (void)addBackView {
    UIImage *backImage = [UIImage imageNamed:@"ico_back_thirdApp_v5.png"];
    UIImage *closeImage = [UIImage imageNamed:@"ico_close_thirdApp_v5.png"];
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.text = self.backAppTitle;
    self.textLabel.textColor = SNUICOLOR(kThemeText13Color);
    self.textLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [self.textLabel sizeToFit];
    UIImage *backGroundImage = [UIImage imageNamed:@"ico_thirdApp_background.png"];
    self.frame = CGRectMake(-15.0, kAppScreenHeight - kBackViewBottomDistance - kBackViewHeight, kBackButtonLeftDistance + backImage.size.width + kBackButtonBetweenDistance + self.textLabel.width + closeImage.size.width + kCloseButtonRightDistance + kCloseButtonbetweenDistance + 20.0, backGroundImage.size.height);
    
    self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.backgroundButton setBackgroundImage:backGroundImage forState:UIControlStateNormal];
    [self.backgroundButton setBackgroundImage:backGroundImage forState:UIControlStateHighlighted];
    [self.backgroundButton addTarget:self action:@selector(dragMoving:withEvent:)forControlEvents: UIControlEventTouchDragInside];
    self.backgroundButton.userInteractionEnabled = YES;
    [self addSubview:self.backgroundButton];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    self.backImageView.image = backImage;
    self.backImageView.center = self.backgroundButton.center;
    self.backImageView.left = kBackButtonLeftDistance + 12.0;
    self.backImageView.userInteractionEnabled = YES;
    [self.backgroundButton addSubview:self.backImageView];
    
    self.textLabel.center = self.backImageView.center;
    self.textLabel.left = self.backImageView.right + kBackButtonBetweenDistance;
    [self.backgroundButton addSubview:self.textLabel];
    
    self.closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    self.closeImageView.image = closeImage;
    self.closeImageView.center = self.backImageView.center;
    self.closeImageView.left = self.textLabel.right + kCloseButtonRightDistance - 2.0;
    self.closeImageView.userInteractionEnabled = YES;
    [self.backgroundButton addSubview:self.closeImageView];
    
    UITapGestureRecognizer *tapBackGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backThirdApp:)];
    [self.backgroundButton addGestureRecognizer:tapBackGesture];
}

- (void)dragMoving: (UIControl *) control withEvent:event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:[UIApplication sharedApplication].keyWindow];
    if ([SNToolbar toolbarHeight] < point.y && point.y < kAppScreenHeight - [SNToolbar toolbarHeight]) {
       self.center = CGPointMake(self.center.x, point.y);
    }
}

- (void)backThirdApp:(id)sender {
    CGPoint point = [sender locationInView:self];
    if (point.x < (self.frame.size.width * 2) / 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.backAppScheme]];
    }
    [self removeFromSuperview];
}

- (void)updateTheme {
    UIImage *backImage = [UIImage imageNamed:@"ico_back_thirdApp_v5.png"];
    UIImage *closeImage = [UIImage imageNamed:@"ico_close_thirdApp_v5.png"];
    UIImage *backGroundImage = [UIImage imageNamed:@"ico_thirdApp_background.png"];
    [self.backgroundButton setBackgroundImage:backGroundImage forState:UIControlStateNormal];
    [self.backgroundButton setBackgroundImage:backGroundImage forState:UIControlStateHighlighted];
    self.closeImageView.image = closeImage;
    self.backImageView.image = backImage;
    
    self.textLabel.textColor = SNUICOLOR(kThemeText13Color);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
