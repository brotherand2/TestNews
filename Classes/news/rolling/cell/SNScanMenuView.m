//
//  SNScanMenuView.m
//  sohunews
//
//  Created by H on 16/2/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//
#define kMoreItemCount 2
#define kMoreItemButtonTag 10000
#define kWebMoreItemHeight ((kAppScreenWidth > 375.0) ? (312.0/3) : 90.0)
#define kWebMoreItemWidth ((kAppScreenWidth > 375.0) ? (355.0/3) : 100.0)
#define kWebMoreItemBottom ((kAppScreenWidth > 375.0)? 480.0 : 480.0)
#define kWebButtonLeftDistance ((kAppScreenWidth > 375.0) ? 28.0 : 45.0/2)
#define kWebBetweenImageAndText ((kAppScreenWidth > 375.0) ? (1.5*(15.0/2)) : 15.0/2)
#define kWebButtonFontSize ((kAppScreenWidth > 375.0) ? (1.3*kThemeFontSizeG) : kThemeFontSizeG)

#import "SNScanMenuView.h"

@interface SNScanMenuView (){
    UITapGestureRecognizer *_tapGesture;
    UIPanGestureRecognizer * _panGesture;
    UIImageView *_moreImageView;
    NSArray *_imageNameArray;
    NSArray *_titleArray;
    UIImageView *_bgImageView;
}

@end

@implementation SNScanMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor clearColor];
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
//    _swipeGesture.direction = UISwipeGestureRecognizerDirectionDown |
//                                UISwipeGestureRecognizerDirectionUp |
//                                UISwipeGestureRecognizerDirectionLeft |
//                                UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:_tapGesture];
    [self addGestureRecognizer:_panGesture];
    
    [SNNotificationManager addObserver:self selector:@selector(tapAction:) name:kNotifyExpressShow object:nil];
    [SNNotificationManager addObserver:self selector:@selector(tapAction:) name:kOpenClientFrom3DTouchNotification object:nil];

    [self createItem];
}

- (void)createItem{
    
    _moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWebMoreItemWidth, kWebMoreItemHeight)];
    _moreImageView.right = self.width - 5.0;
    _moreImageView.top = 100;
    _moreImageView.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"bgnormalsetting_layer_v5.png"];
    _moreImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)];
    _moreImageView.userInteractionEnabled = YES;
    [self addSubview:_moreImageView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(1.5, kWebMoreItemHeight/2, _moreImageView.width - 3, 0.5)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [_moreImageView addSubview:lineView];
    
    [self creatButtonItem];
}

- (void)creatButtonItem {
    _titleArray = [[NSArray alloc] initWithObjects:kScanMenuQrCode, kScanMenuPoster, nil];
    _imageNameArray = [[NSArray alloc] initWithObjects:@"icowebview_refresh.png", @"icowebview_report.png", nil];
    for (NSInteger i = 0; i < kMoreItemCount; i++) {
        UIButton *button = [self setItemButtonWithIndex:i title:[_titleArray objectAtIndex:i] imageName:[_imageNameArray objectAtIndex:i] pointY:((kWebMoreItemHeight/2)*i)];
        [_moreImageView addSubview:button];
    }
}

- (UIButton *)setItemButtonWithIndex:(NSInteger)index title:(NSString *)title imageName:(NSString *)imageNage pointY:(CGFloat)pointY {
    CGFloat buttonWidth = kWebMoreItemWidth;
    CGFloat buttonHeight = kWebMoreItemHeight/2;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, pointY, buttonWidth/1.2, buttonHeight/1.2);
    button.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^(void){
        button.frame = CGRectMake(0, pointY, buttonWidth, buttonHeight);
        button.alpha = 1.0;
    } completion:^(BOOL finishsed) {
    }];
    button.tag = kMoreItemButtonTag + index;
    [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(hightedAction:) forControlEvents:UIControlEventTouchDown];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNage]];
    imageView.top = (buttonHeight - imageView.frame.size.width)/2 - index*2 + 1;
    imageView.left = kWebButtonLeftDistance;
    [button addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [UIFont systemFontOfSize:kWebButtonFontSize];
    [label sizeToFit];
    label.textColor = SNUICOLOR(kThemeText4Color);
    label.center = imageView.center;
    label.left = imageView.right + kWebBetweenImageAndText;
    [button addSubview:label];
    
    return button;
}

- (void)clickAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor clearColor];
    if (button.tag == kMoreItemButtonTag) {//扫二维码、条形码
        [SNUtility openQRCodeViewWith:nil];
    }
    else {//扫海报
        [SNUtility openQRCodeViewWith:nil];
    }
    [self removeFromSuperview];
}

- (void)hightedAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = SNUICOLOR(kThemeBg2Color);
}

- (void)tapAction:(UIGestureRecognizer *)gesture {
    [self removeFromSuperview];
}

- (void)panAction:(UIGestureRecognizer *)gesture {
    [self removeFromSuperview];
}

- (void)dealloc {
     //(_tapGesture);
     //(_panGesture);
     //(_moreImageView);
     //(_titleArray);
     //(_imageNameArray);
    
}

+ (void)showMenu {
    SNScanMenuView * menu = [[SNScanMenuView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    [[UIApplication sharedApplication].keyWindow addSubview:menu];

}

@end
