//
//  SNListenNewsGuideView.m
//  sohunews
//
//  Created by jialei on 14-6-27.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNListenNewsGuideView.h"

#define SN_GIDEVIEW_BTN_HEIGHT  40
#define SN_GIDEVIEW_FONT        16

@interface SNListenNewsGuideView()
{
    BOOL _showMoreCell;
}

@property (nonatomic, strong)UIImage *iconImage;
@property (nonatomic, strong)UIButton *actionBtn;
@property (nonatomic, strong)UIImage *bgImage;

@end

@implementation SNListenNewsGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.iconImage = [UIImage themeImageNamed:@"linten_news_guide_icon.png"];
//        self.layer.borderColor = [UIColor blackColor].CGColor;
//        self.layer.borderWidth = 0.5;
        
        self.bgImage = [UIImage themeImageNamed:@"linten_news_guide_bg.png"];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTouched:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [self createView];
    }
    return self;
}

- (void)dealloc
{
     //(_actionBtn);
     //(_iconImage);
     //(_bgImage);
    
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.bgImage drawInRect:rect];
    
    CGRect imgRect = CGRectMake(15, 15, self.iconImage.size.width, self.iconImage.size.height);
    [self.iconImage drawInRect:imgRect];
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    NSString *tip = @"听新闻更带感，解放你的双手!";
    CGRect tipRect = CGRectMake(15 + self.iconImage.size.width + 9, 15,
                                120, self.iconImage.size.height + 10);
    [tip textDrawInRect:tipRect
               withFont:[UIFont systemFontOfSize:SN_GIDEVIEW_FONT]
          lineBreakMode:NSLineBreakByCharWrapping
              alignment:NSTextAlignmentLeft
              textColor:[UIColor whiteColor]];
}

- (void)createView
{
//    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.actionBtn.backgroundColor = [UIColor blackColor];
//    self.actionBtn.size = CGSizeMake(self.width / 2, SN_GIDEVIEW_BTN_HEIGHT);
//    self.actionBtn.centerX = self.width / 2;
//    self.actionBtn.bottom = self.height - 20;
//    self.actionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    self.actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.actionBtn setTitle:@"立即尝试" forState:UIControlStateNormal];
//    [self.actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.actionBtn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:self.actionBtn];
    
    UIImage *closeImage = [UIImage themeImageNamed:@"linten_news_guide_close.png"];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.size = CGSizeMake(closeImage.size.width + 15, SN_GIDEVIEW_HEIGHT);
    closeBtn.top = 0;
    closeBtn.right = self.width;
//    closeBtn.backgroundColor = [UIColor redColor];
    closeBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 10);
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:closeBtn];
}

#pragma mark - action
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)viewTouched:(UIGestureRecognizer *)recognizer
{
    _showMoreCell = YES;
    [self removeView];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    self.alpha = 0.0f;
    [self removeFromSuperview];
    if (self.guideBlock && _showMoreCell) {
        self.guideBlock();
    }
}

- (void)removeView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDelegate:self];
    // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
    
    self.alpha = 0.0;
    [UIView commitAnimations];
}

@end
