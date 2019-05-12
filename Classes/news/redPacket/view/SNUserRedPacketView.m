//
//  SNUserRedPacketView.m
//  sohunews
//
//  Created by wangyy on 16/2/24.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNUserRedPacketView.h"
#import "SNRedPacketConfirmRequest.h"
#import "SNRedPacketFallView.h"
#import "SNRedPacketManager.h"
#import "SNRedPacketModel.h"
#import "SNUserManager.h"
#import "JSONKit.h"
#import "SNNewsReport.h"
#import "SNAppConfigFloatingLayer.h"
#import "UIButton+WebCache.h"
#import "SNUserManager.h"
#import "NSObject+YAJL.h"
#import "UIFont+Theme.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNNewAlertView.h"
#import "SNRedPacketSlideRequest.h"
#import "SNNewsShareManager.h"
#import "SNRedPacketShareAlert.h"

#define IMAGE_X                arc4random()%(int)kAppScreenWidth
#define IMAGE_WIDTH            arc4random()%20 + 10
#define PLUS_HEIGHT            Main_Screen_Height/25

#define VerifyImgLeft           20
#define SliderBtnTag            20000
#define loginAndBindTag         30000

#define kDefaultAlertWidth   (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0)
#define kDefaultLeftMargin   20.0f
#define kDefaultBottomMargin 18.0f

@interface SNUserRedPacketView () <CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *bottomImage;
@property (nonatomic, strong) UIImageView *redPacket;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *alipayButton;
@property (nonatomic, strong) SNRedPacketInfoCell *redPacketInfo;

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) NSMutableArray *imagesArray;

@property(nonatomic, strong) SNRedPacketFallView *rootLayer;

//@property (nonatomic, retain) UIButton *fullScreenBtn;

@property (nonatomic, strong) UIImageView *verifyImgView;
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, assign) BOOL showAlipayButton;
@property (nonatomic, assign) int redPacketSlideNum;
@property (nonatomic, strong) UIButton *sliderBgView;
@property (nonatomic, strong) UIImageView *sliderBtn;
@property (nonatomic, strong) SNNewsShareManager *newsShareManager;
@property (nonatomic, strong) SNRedPacketShareAlert *shareAlert;
@end

@implementation SNUserRedPacketView

@synthesize topImage = _topImage;
@synthesize bottomImage = _bottomImage;
@synthesize redPacket = _redPacket;
@synthesize closeButton = _closeButton;
@synthesize alipayButton = _alipayButton;
@synthesize redPacketInfo = _redPacketInfo;
@synthesize path = _path;
@synthesize imagesArray = _imagesArray;
@synthesize redPacketType = _redPacketType;
//@synthesize fullScreenBtn = _fullScreenBtn;
@synthesize rootLayer = _rootLayer;
@synthesize verifyImgView = _verifyImgView;
@synthesize maskImageView = _maskImageView;
@synthesize showAlipayButton = _showAlipayButton;
@synthesize redPacketSlideNum = _redPacketSlideNum;
@synthesize sliderBgView = _sliderBgView;
@synthesize sliderBtn = _sliderBtn;

- (void)dealloc{
    [SNNotificationManager removeObserver:self];
    
}

- (id)initWithFrame:(CGRect)frame redPacketType:(SNRedPacketType)packetType{
    self = [super initWithFrame:frame];
    if (self) {
        self.redPacketType = packetType;

        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor =[UIColor blackColor];
        view.alpha = 0.5;
        [self addSubview:view];
        
        //        [self initSnowImageArray];
        self.rootLayer = [[SNRedPacketFallView alloc] init];
        [self.layer addSublayer:self.rootLayer];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stopRedPacketFall) userInfo:nil repeats:NO];
        
        UIImage *image = [UIImage themeImageNamed:@"icohongbao_dakai_v5.png"];
        self.redPacket = [[UIImageView alloc] initWithFrame: CGRectMake((kAppScreenWidth - image.size.width)/2, frame.size.height*0.3, image.size.width, image.size.height)];
        [self.redPacket setImage:image];
        [self addSubview:self.redPacket];
        [self.redPacket setUserInteractionEnabled:YES];
        
        [self initRedPacket];
        [self initNoopenRedPacket];
        [self initRedPacketButton];
        
        SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
        NSURL *imageUrl = [NSURL URLWithString:floatingLayer.picUrl];
        int offsetY = [SNDevice sharedInstance].isPlus ? 3 : -4;
        UIButton *redPacketBtn = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - 56, kAppScreenHeight - 50 - 57 - offsetY, 56, 57)];
        [redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateNormal placeholderImage:[UIImage themeImageNamed:@"icohongbao_hbyu_v5.png"]];
        [redPacketBtn sd_setImageWithURL:imageUrl forState:UIControlStateHighlighted placeholderImage:[UIImage themeImageNamed:@"icohongbao_hbyu_v5.png"]];
        [self addSubview:redPacketBtn];

        self.path = [UIBezierPath bezierPath];
        [_path moveToPoint:CGPointMake(self.redPacket.centerX, self.redPacket.centerY)];
        [_path addQuadCurveToPoint:CGPointMake(kAppScreenWidth-28, kAppScreenHeight-75) controlPoint:CGPointMake(kAppScreenWidth-40, self.redPacket.centerY )];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(resetverifyImageViewLayout)
                                                     name:kGetUserRedPacketNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(loginAndBindDisappear)
                                                     name:kLoginAndBindViewDisappearNotification
                                                   object:nil];
    }
    
    return self;
}


- (void)initNoopenRedPacket{
    NSString *topImageName = @"icohongbao_noopen_v5.png";
    NSString *bottomImageName = @"icohongbao_close_v5.png";
    if (self.redPacketType == SNRedPacketTask) {
        topImageName = @"icohongbao_task_noopen_v5.png";
        bottomImageName = @"icohongbao_task_close_v5.png";
    }
   
    UIImage *t_image = [UIImage themeImageNamed:topImageName];
    self.topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, t_image.size.width, t_image.size.height)];
    [self.topImage setImage:t_image];
    [self.redPacket addSubview:self.topImage];
    
    UIImage *b_image = [UIImage themeImageNamed:bottomImageName];
    self.bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.redPacket.size.height - b_image.size.height, b_image.size.width, b_image.size.height)];
    [self.bottomImage setImage:b_image];
    [self.redPacket insertSubview:self.bottomImage belowSubview:self.topImage];
}

- (void)initRedPacket{
    NSString *imageName = @"icohongbao_dakiahou_v5.png";
    if (self.redPacketType == SNRedPacketTask) {
        imageName = @"icohongbao_task_dakiahou_v5.png";
    }
    
    UIImage *image = [UIImage themeImageNamed:imageName];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.redPacket.size.height - image.size.height, self.redPacket.size.width, image.size.height)];
    [imageview setImage:image];
    [self.redPacket addSubview:imageview];
    
    [self initRedPacketInfo];
}

- (void)initRedPacketInfo{
    self.redPacketInfo = [[SNRedPacketInfoCell alloc] initWithFrame:CGRectMake(0, 18, self.redPacket.size.width, 120) redPacketType:self.redPacketType];
    self.redPacketInfo.backgroundColor = [UIColor clearColor];
    [self.redPacket addSubview:self.redPacketInfo];
    self.redPacketInfo.alpha = 0.0;
}

- (void)initRedPacketButton{
    NSString *imageName = @"icohongbao_huanbi_v5.png";
    NSString *bgColorStr = kAlipayButtonBgColor;
    NSString *title = @"领取红包";
    NSString *textColorStr = kAlipayTextBgColor;
    if (self.redPacketType == SNRedPacketTask) {
        imageName = @"icohongbao_task_huanbi_v5.png";
        bgColorStr = kTaskAlipayButtonBgColor;
        title =  @"领取红包";
        textColorStr =  kTaskAlipayTextBgColor;
    }
    
    UIImage *image = [UIImage themeImageNamed:imageName];
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.redPacket.right+2, self.redPacket.top - image.size.height, image.size.width, image.size.height)];
    [self.closeButton setImage:[UIImage themeImageNamed:imageName] forState:UIControlStateNormal];
    [self.closeButton setImage:[UIImage themeImageNamed:imageName] forState:UIControlStateHighlighted];
    [self.closeButton addTarget:self action:@selector(closeUserRedPacket) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    self.closeButton.hidden = YES;
 
    self.alipayButton = [[UIButton alloc] initWithFrame:CGRectMake((kAppScreenWidth - 98)/2, self.redPacket.bottom + 20, 98, 34)];
    self.alipayButton.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:bgColorStr];
    [self.alipayButton setTitle:title forState:UIControlStateNormal];
    [self.alipayButton setTitle:title forState:UIControlStateHighlighted];
//    if (self.redPacketType != SNRedPacketTask) {
//        UIImage *image = [UIImage imageNamed:@"icofloat_zfb1_v5.png"];
//        [self.alipayButton setImage:image forState:UIControlStateNormal];
//        [self.alipayButton setImage:image forState:UIControlStateHighlighted];
//        self.alipayButton.titleLabel.font = [UIFont systemFontOfSize:13];
//        self.alipayButton.frame = CGRectMake((kAppScreenWidth - 110)/2, self.redPacket.bottom + 20, 110, 34);
//    }
//    else{
//        self.alipayButton.titleLabel.font = [UIFont systemFontOfSize:17];
//    }
    self.alipayButton.titleLabel.font = [UIFont systemFontOfSize:17];
    UIColor *textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:textColorStr];
    [self.alipayButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.alipayButton setTitleColor:textColor forState:UIControlStateHighlighted];
//    if (self.redPacketType == SNRedPacketTask) {
//        [self.alipayButton addTarget:self action:@selector(getTaskRedPacket) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else{
//        [self.alipayButton addTarget:self action:@selector(saveToAlipay) forControlEvents:UIControlEventTouchUpInside];
//    }
    [self.alipayButton addTarget:self action:@selector(confirmUserRedPacket) forControlEvents:UIControlEventTouchUpInside];
    self.alipayButton.layer.cornerRadius = 1;
    [self addSubview:self.alipayButton];
    self.alipayButton.hidden = YES;
    
    NSString *titleStr = [SNRedPacketManager sharedInstance].redPacketItem.slideUnlockRedPacketText;
    if (titleStr == nil || [titleStr length] == 0) {
        titleStr = @"将小图拖到指定位置解锁";
    }
  
    UIImage *bgImage = [UIImage themeImageNamed:@"icohb_bj_v5.png"];
    self.sliderBgView = [[UIButton alloc] initWithFrame:CGRectMake((kAppScreenWidth - bgImage.size.width)/2, self.redPacket.bottom + 20, bgImage.size.width, bgImage.size.height)];
    [self.sliderBgView setTitle:titleStr forState:UIControlStateNormal];
    [self.sliderBgView setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.sliderBgView setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    self.sliderBgView.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    [self addSubview:self.sliderBgView];
    self.sliderBgView.enabled = NO;
    self.sliderBgView.hidden = YES;
    

    UIImage *btnImage = [UIImage themeImageNamed:@"icohb_hk_v5.png"];
    self.sliderBtn = [[UIImageView alloc] initWithFrame:CGRectMake(self.sliderBgView.left, 0, btnImage.size.width, btnImage.size.height)];
    self.sliderBtn.backgroundColor = [UIColor clearColor];
    [self.sliderBtn setImage:btnImage];
    [self addSubview:self.sliderBtn];
    self.sliderBtn.hidden = YES;
    self.sliderBtn.tag = SliderBtnTag;
    self.sliderBtn.centerY = self.sliderBgView.centerY;
    [self.sliderBtn setUserInteractionEnabled:YES];
    
    [self.sliderBgView setTitleEdgeInsets:UIEdgeInsetsMake(0, self.sliderBtn.width, 0, 0)];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.sliderBtn addGestureRecognizer:panGestureRecognizer];
}

//- (void)initSnowImageArray{
//    self.imagesArray = [[[NSMutableArray alloc] init] autorelease];
//    for (int i = 0; i < 30; ++ i) {
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"icohongbao_hbyu_v5.png"]];
//        float x = IMAGE_WIDTH;
//        imageView.frame = CGRectMake(IMAGE_X, -x * 1.3, x, x * 1.3);
//        [self addSubview:imageView];
//        [self.imagesArray addObject:imageView];
//    }
//    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(makeSnow) userInfo:nil repeats:YES];
//}

//static int i = 0;
//- (void)makeSnow
//{
//    i = i + 1;
//    if ([_imagesArray count] > 0) {
//        UIImageView *imageView = [_imagesArray objectAtIndex:0];
//        imageView.tag = i;
//        [_imagesArray removeObjectAtIndex:0];
//        [self snowFall:imageView];
//    }
//}
//
//- (void)snowFall:(UIImageView *)aImageView
//{
//    [UIView beginAnimations:[NSString stringWithFormat:@"%i",aImageView.tag] context:nil];
//    [UIView setAnimationDuration:6];
//    [UIView setAnimationDelegate:self];
//    aImageView.frame = CGRectMake(aImageView.frame.origin.x, kAppScreenHeight, aImageView.frame.size.width, aImageView.frame.size.height);
//    [UIView commitAnimations];
//}


-(void)groupAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = _path.CGPath;
   
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.35;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    narrowAnimation.duration = 0.6f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.01f];
    
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,narrowAnimation];
    groups.duration = 0.8f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [self.redPacket.layer addAnimation:groups forKey:@"groupAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CAAnimation *groupAnimation = [self.redPacket.layer animationForKey:@"groupAnimation"];
    if (groupAnimation == anim) {
        [self dismissRedPacket];
    }
    
    //2017-04-10 wangchuanwen 正文阅读到90%触发 add 5.8.9 begin
    if ([SNAppConfigManager sharedInstance].configH5RedPacket.redPacketFloatBtnIsShow) {
        
        //弹出分享覆层
        self.shareAlert = [[SNRedPacketShareAlert alloc] init];
        [self.shareAlert showArticleRedPacketShareAlert];
//        [self showAlipayAlertView:@"前往查看您的零钱余额"];
    }
    //2017-04-10 wangchuanwen 正文阅读到90%触发 add 5.8.9 end
}

- (void)getUserRedPacket{
    self.alipayButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.verifyImgView.hidden = YES;
    self.maskImageView.hidden = YES;
    self.sliderBgView.hidden = YES;
    self.sliderBtn.hidden = YES;
    
    [self groupAnimation];
}

- (void)closeUserRedPacket{
    if ([self canShowCloseAlert]) {
        [self showCloseAlertView:@"你当真不要这个红包了吗？这可是真钱呀！～" withTitle:@""];
    }
    else{
        [self dismissRedPacket];
    }
}

- (void)showUserRedPacket{
    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
    self.showAlipayButton = !item.isSlideUnlockRedpacket;
    self.redPacket.transform = CGAffineTransformMakeScale(0.2,0.2);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.redPacket.transform = CGAffineTransformMakeScale(1,1);
    }completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(openRedPacket) userInfo:nil repeats:NO];
    }];
}

- (void)dismissRedPacket{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
        if ([[TTNavigator navigator].topViewController.tabbarView isKindOfClass:[SNTabbarView class]]) {
            SNTabbarView *tabview = (SNTabbarView *)[TTNavigator navigator].topViewController.tabbarView;
            [tabview showCoverLayer:NO];
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [SNRedPacketManager sharedInstance].redPacketShowing = NO;
    
    if ([self isOlympicRedPacket]) {
        [self reportADotGif:@"close"];
    }
}

- (void)openRedPacket{
    [UIView animateWithDuration:0.3 animations:^{
        self.topImage.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.5), CGAffineTransformMakeTranslation(1.0, -self.topImage.height / 2 +30));
        self.topImage.alpha = 0;
        
        CGRect frame = self.bottomImage.frame;
        frame.origin.y += 60;
        frame.size.height -= 60;
        self.bottomImage.frame = frame;
     
        self.closeButton.hidden = NO;
        self.alipayButton.hidden = !self.showAlipayButton;
        self.sliderBgView.hidden = self.showAlipayButton;
        self.sliderBtn.hidden = self.showAlipayButton;
        
        self.redPacketInfo.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        self.bottomImage.alpha = 0;
        
        if (self.showAlipayButton == NO) {
            [self showVerifyImageView];
        }
    }];
    
//    self.fullScreenBtn.enabled = YES;
}
/*
- (void)saveToAlipay{
    [self dismissRedPacket];
    
    [SNNewsReport reportADotGif:@"_act=luckmoney&_tp=clickwithdraw"];

    [SNRedPacketModel sharedInstance].isH5 = NO;
    [[SNRedPacketModel sharedInstance] verifySendRedPacket:^(BOOL Success ,BOOL isClickBackButton) {
        if (Success) {
            SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
            [[SNRedPacketModel sharedInstance] redPacketRequestWithPacketID:item.redPacketId requestFinish:^(SNPackProfile *profile) {
                if (profile && [profile.statusCode isEqualToString:@"10000000"]) {
                    self.drawTime = profile.withdrawTime;
                    [self showAlipayAlertView:profile.alipayPassport];
                    //30060009该设备未绑定支付宝
                }else if (profile && [profile.statusCode isEqualToString:@"30060009"]){
                    [[SNRedPacketModel sharedInstance] auth_V2:^(BOOL Success, NSString *result) {
                        if (Success) {
                            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
                            NSString *bingAP = [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode];
                            
                            NSDictionary *jsonDict = [bingAP objectFromJSONString];
                            SNDebugLog(@"bindApalipayPassport ----------- %@",jsonDict);
                            if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                                NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
                                NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                                if ([statusCode isEqualToString:@"10000000"]) {
                                    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
                                    [[SNRedPacketModel sharedInstance] redPacketRequestWithPacketID:item.redPacketId requestFinish:^(SNPackProfile * profile){
                                        if (profile && [profile.statusCode isEqualToString:@"10000000"]) {
                                            self.drawTime = profile.withdrawTime;
                                            [self showAlipayAlertView:profile.alipayPassport];
                                        }else{
                                            [self showFailAlertView:profile.statusMsg withTitle:@" "];
                                        }
                                    } requestFailure:^(id request, NSError *error) {
                                    }];
                                }else{
                                    [self showFailAlertView:statusMsg withTitle:@" "];
                                }
                            }else{
                                [self showFailAlertView:RedPacketCopywriterNomal withTitle:@" "];
                            }
                        }else{
                            [self showFailAlertView:@"授权失败" withTitle:@" "];
                        }
                        
                    }];
                    
                }else{
                    [self showFailAlertView:profile.statusMsg withTitle:@" "];
                }
                
                
                
                [SNRedPacketModel sharedInstance].authCompletion = ^(BOOL Success, NSString *result){
                    if (Success) {
                        NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                        NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
                        NSString *bingAP = [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode];
                        
                        NSDictionary *jsonDict = [bingAP objectFromJSONString];
                        SNDebugLog(@"bindApalipayPassport ----------- %@",jsonDict);
                        if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                            NSString *statusCode = [NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]];
                            NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                            if ([statusCode isEqualToString:@"10000000"]) {
                                SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
                                [[SNRedPacketModel sharedInstance] redPacketRequestWithPacketID:item.redPacketId requestFinish:^(SNPackProfile * profile){
                                    if (profile && [profile.statusCode isEqualToString:@"10000000"]) {
                                        self.drawTime = profile.withdrawTime;
                                        [self showAlipayAlertView:profile.alipayPassport];
                                    }else{
                                        [self showFailAlertView:profile.statusMsg withTitle:@" "];
                                    }
                                } requestFailure:^(id request, NSError *error) {
                                }];
                            }else{
                                [self showFailAlertView:statusMsg withTitle:@" "];
                            }
                        }else{
                            [self showFailAlertView:RedPacketCopywriterNomal withTitle:@" "];
                        }
                    }else{
                        [self showFailAlertView:@"授权失败" withTitle:@" "];
                    }
                    
                };
            } requestFailure:^(id request, NSError *error) {
                  [self showFailAlertView:RedPacketCopywriterNomal withTitle:@" "];
            }];
        }else{
           [self showFailAlertView:RedPacketCopywriterNomal withTitle:@" "];
        }
    }];
}
*/
-(void)withdrawError:(NSString*)statusCode{
    NSString *message = nil;
    NSString *title = [SNRedPacketModel getErrorStringWithErrorCode:statusCode];
    [self showFailAlertView:message withTitle:title];
}

- (void)showFailAlertView:(NSString*)message withTitle:(NSString*)title{

    if (0 == title.length) {
        title = kBundleNameKey;
    }
    SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:message cancelButtonTitle:@"关闭" otherButtonTitle:@"重试"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushAlertView show];
    });
    [pushAlertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        [self verifySuccessConfirm];//滑动成功，领取红包。支付宝流程取消
    }];

}

- (void)showFailAlertView:(NSString*)message withTitle:(NSString*)title withTag:(int)tag{

    NSString *confirmName = nil;
    if (tag == loginAndBindTag) {
        confirmName = @"我知道了";
    }
    else{
        confirmName = @"重试";
    }

    if (0 == title.length) {
        title = kBundleNameKey;
    }
    SNNewAlertView *pushAlertView = [[SNNewAlertView alloc] initWithTitle:title message:message cancelButtonTitle:@"关闭" otherButtonTitle:confirmName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushAlertView show];
    });
    [pushAlertView actionWithBlocksCancelButtonHandler:^{
        [UIView animateWithDuration:0.2 animations:^{
            self.verifyImgView.left = VerifyImgLeft;
            self.sliderBtn.left = self.sliderBgView.left;
        }completion:^(BOOL finished) {
            [self showSliderBgTitle:YES];
        }];

    }otherButtonHandler:^{
        if (tag == 10000) {
            [self verifySuccessConfirm];//滑动成功，领取红包。支付宝流程取消
        }
        else if (tag ==loginAndBindTag){
            [UIView animateWithDuration:0.2 animations:^{
                self.verifyImgView.left = VerifyImgLeft;
                self.sliderBtn.left = self.sliderBgView.left;
            }completion:^(BOOL finished) {
                [self showSliderBgTitle:YES];
            }];
        }
    }];

}

//- (void)showAlipayAlertView:(NSString *)alipayName{
//    
////    //2017-04-11 wangchuanwen 5.8.9 update 
//    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
////    SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
//    NSString *title = [NSString stringWithFormat:@"%@元已提现到你的支付宝", item.moneyValue];
//    if ([SNRedPacketManager sharedInstance].isInArticleShowRedPacket) {
//        title = [NSString stringWithFormat:@"%@元已存入您的余额", item.moneyValue];
//    }
////
////    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
////    if ([SNRedPacketManager sharedInstance].isInArticleShowRedPacket) {
////        [dic setObject:@"redPackPage" forKey:@"contentType"];
////        [dic setObject:item.nid?item.nid:@"" forKey:@"nid"];
////        [dic setObject:item.moneyValue?item.moneyValue:@"" forKey:@"redAmount"];
////    } else {
////        [dic setObject:@"pack" forKey:@"contentType"];
////        NSString *redPacket = [NSString stringWithFormat:@"packId=%@&shareUrl=%@&step=3", item.redPacketId, floatingLayer.H5Url];
////        [dic setObject:[redPacket URLEncodedString] forKey:@"redPacket"];
////        
////        NSString *shareType = nil;
////        if (item.redPacketType == 1) {//1普通红包，2任务红包
////            shareType = @"pthongbao";
////        }
////        else if (item.redPacketType == 2) {
////            shareType = @"rwhongbao";
////        }
////        else {
////            shareType = @"protocal";
////        }
////        
////        [dic setObject:shareType?:@"" forKey:SNNewsShare_LOG_type];
////        [dic setObject:@"copyLink" forKey:SNNewsShare_disableIcons];
////        
////        
////        SNTimelineOriginContentObject *shareObj = [[SNTimelineOriginContentObject alloc] init];
////        shareObj.link = floatingLayer.H5Url;
////        shareObj.type = ShareSubTypeQuoteCard;
////        [dic setObject:shareObj forKey:kShareInfoKeyShareRead];
////        if (item.redPacketId) {
////            [dic setObject:item.redPacketId forKey:kRedPacketIDKey];
////        }
////    }
////    
////    SNAlipayAlertView *alertView = [[SNAlipayAlertView alloc] initWithSize:CGSizeMake(312, 225)];
////    alertView.shareTitle = @"分享活动到";
////    [alertView setTitle:title setAlipayName:alipayName];
//////    [alertView showAlipayAlert];
////    
////
////    
////    __weak typeof(self)weakSelf = self;
////    alertView.shareClickBlock = ^(SNActionMenuOption menuOption) {
////        NSString *str = nil;
////        switch (menuOption) {
////            case SNActionMenuOptionWXSession:
////                str = kShareTitleWechatSession;
////                break;
////                
////            case SNActionMenuOptionWXTimeline:
////                str = kShareTitleWechat;
////                break;
////                
////            case SNActionMenuOptionQQ:
////                str = kShareTitleQQ;
////                break;
////                
////            case SNActionMenuOptionOAuths:
////                str = kShareTitleSina;
////                break;
////            default:
////                break;
////        }
////        
////        if (str && str.length > 0) {
////            
////            weakSelf.newsShareManager = [[SNNewsShareManager alloc] init];
////            
////            [weakSelf.newsShareManager shareIconSelected:str ShareData:dic];
////        }
////    };
//    
//    /*
//     //老分享逻辑，现在不要
//     SNActionMenuController *actionMenuController = [[SNActionMenuController alloc] init];
//    actionMenuController.delegate = nil;
//    
//    actionMenuController.disableLikeBtn = YES;
//    
//    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
//    SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:@"pack" forKey:@"contentType"];
//    NSString *redPacket = [NSString stringWithFormat:@"packId=%@&shareUrl=%@&step=3", item.redPacketId, floatingLayer.H5Url];
//    [dic setObject:[redPacket URLEncodedString] forKey:@"redPacket"];
//    NSString *shareType = nil;
//    if (item.redPacketType == 1) {//1普通红包，2任务红包
//        shareType = @"pthongbao";
//    }
//    else if (item.redPacketType == 2) {
//        shareType = @"rwhongbao";
//    }
//    else {
//        shareType = @"protocal";
//    }
//    
//    SNTimelineOriginContentObject *shareObj = [[SNTimelineOriginContentObject alloc] init];
//    shareObj.link = floatingLayer.H5Url;
//    shareObj.type = ShareSubTypeQuoteCard;
//    [dic setObject:shareObj forKey:kShareInfoKeyShareRead];
//    if (item.redPacketId) {
//        [dic setObject:item.redPacketId forKey:kRedPacketIDKey];
//    }
//    actionMenuController.contextDic = dic;
//    actionMenuController.shareLogType = shareType;
//    actionMenuController.shareSubType = ShareSubTypeQuoteCard;
//    actionMenuController.disableCopyLinkBtn = YES;
//    NSString *title = [NSString stringWithFormat:@"%@元已提现到你的支付宝", item.moneyValue];
//    [actionMenuController showAlipyActionMenu:title alipayName:alipayName];*/
//    
//    
//}

- (void)updateContentView:(SNRedPacketItem *)redPacketItem{
    [self.redPacketInfo updateContentView:redPacketItem];
}

- (void)stopRedPacketFall{
    [self.rootLayer stopRedPacketFall];
}

- (void)getTaskRedPacket{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInteger:RedPacketTaskWebViewType] forKey:kUniversalWebViewType];
    if ([SNRedPacketManager sharedInstance].redPacketItem.jumpUrl != nil) {
         [userInfo setObject:[SNRedPacketManager sharedInstance].redPacketItem.jumpUrl forKey:kLink];
    }
    [SNUtility openUniversalWebView:userInfo];
    
    [self removeFromSuperview];
    
}


- (UIImage *)imageFromView: (UIView *) theView   atFrame:(CGRect)r
{
//    IOS 6截图方法
//    UIGraphicsBeginImageContextWithOptions(theView.frame.size, YES, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    UIRectClip(r);
//    [theView.layer renderInContext:context];
//    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return  theImage;
    
//    IOS7 以上截图方法，比IOS 6效率高
    UIGraphicsBeginImageContextWithOptions(theView.frame.size, YES, 0);
    
    [theView drawViewHierarchyInRect:theView.bounds afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage *)cropImage:(UIImage *)image rect:(CGRect)cropRect
{
    cropRect = CGRectMake(cropRect.origin.x * image.scale,
                          cropRect.origin.y * image.scale,
                          cropRect.size.width * image.scale,
                          cropRect.size.height * image.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

- (void)showVerifyImageView{
    if (self.redPacketSlideNum != 0) {
        return;
    }
    
    int i = arc4random()%3;
    i = i+1;
    NSString *maskImageName = [NSString stringWithFormat:@"icohb_slider1_v%d.png", i];
    UIImage *maskImage = [UIImage imageNamed:maskImageName];
    
    int x = arc4random() % (int)self.redPacket.width;
    int y = arc4random() % (int)self.redPacket.height;

    int maxX = (int)(self.redPacket.width - maskImage.size.width);
    int maxY = (int)(self.redPacket.height - maskImage.size.height);

    x = (x >= maxX) ? self.redPacket.width - maskImage.size.width : x;
    y = (y >= maxY) ? self.redPacket.height - maskImage.size.height : y;
    
    if (self.maskImageView == nil) {
        self.maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, maskImage.size.width, maskImage.size.height)];
        self.maskImageView.backgroundColor = [UIColor clearColor];
        [self.redPacket addSubview:self.maskImageView];
    }
    
    NSString *imageName = [NSString stringWithFormat:@"icohb_slider_v%d.png", i];
    [self.maskImageView setImage:[UIImage imageNamed:imageName]];
    
    UIImage *verifyImage = [self imageFromView:self.redPacket atFrame:self.maskImageView.frame];
    verifyImage = [self cropImage:verifyImage rect:self.maskImageView.frame];
    if (self.verifyImgView == nil) {
        self.verifyImgView = [[UIImageView alloc] initWithFrame:CGRectMake(VerifyImgLeft, self.redPacket.top + self.maskImageView.top, maskImage.size.width, maskImage.size.height)];
        self.verifyImgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.verifyImgView];
    }
    [self.verifyImgView setImage:verifyImage];
    [self.verifyImgView setUserInteractionEnabled:YES];
    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.contents = (id)[maskImage CGImage];
    maskLayer.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
    [self.verifyImgView.layer setMask:maskLayer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.verifyImgView addGestureRecognizer:panGestureRecognizer];
}

- (void) handlePanGestures:(UIPanGestureRecognizer*)paramSender{
    CGPoint translatedPoint = [paramSender translationInView:paramSender.view.superview];
    if (translatedPoint.x < 0 && self.verifyImgView.left < VerifyImgLeft + 0.0001) {
        self.verifyImgView.left = VerifyImgLeft;
        self.sliderBtn.left = self.sliderBgView.left;
        [self showSliderBgTitle:YES];
        return;
    }
    
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        //通过使用 locationInView 这个方法,来获取到手势的坐标
        CGPoint location = [paramSender locationInView:paramSender.view.superview];
        CGFloat rightX = self.redPacket.right;
        if (paramSender.view.tag == SliderBtnTag) {
            rightX = self.sliderBgView.right;
            [self showSliderBgTitle:NO];
        }
        
        if ( location.x + paramSender.view.size.width/2 <= rightX ) {
            paramSender.view.centerX = location.x;
            if (paramSender.view.tag == SliderBtnTag) {
                CGFloat xOffset = ((self.redPacket.right - VerifyImgLeft) / self.sliderBgView.width ) * (location.x - self.sliderBgView.left) + VerifyImgLeft;
                if (xOffset > (self.redPacket.right - self.verifyImgView.width /2)) {
                    xOffset = (self.redPacket.right - self.verifyImgView.width /2);
                }
                self.verifyImgView.centerX = xOffset;
            }
        }
        else{
            if (paramSender.view.right < rightX) {
                paramSender.view.centerX = location.x;
                if (paramSender.view.tag == SliderBtnTag) {
                    CGFloat xOffset = ((self.redPacket.right - VerifyImgLeft) / self.sliderBgView.width ) * (location.x - self.sliderBgView.left) + VerifyImgLeft;
                    if (xOffset > (self.redPacket.right - self.verifyImgView.width /2)) {
                        xOffset = (self.redPacket.right - self.verifyImgView.width /2);
                    }
                    self.verifyImgView.centerX = xOffset;
                }
            }
        }
    }
    else if(paramSender.state == UIGestureRecognizerStateEnded){
        if (fabs(self.verifyImgView.left - (self.redPacket.left + self.maskImageView.left)) < 6) {
            [self confirmUserRedPacket];
        }
        else{
            [self sliderVerifyFailAciton];
        }
    }
    else if (paramSender.state == UIGestureRecognizerStateFailed)
    {
        [self sliderVerifyFailAciton];
    }
}

- (void)sliderVerifyFailAciton{
    [UIView animateWithDuration:0.2 animations:^{
        self.verifyImgView.left = VerifyImgLeft;
        self.sliderBtn.left = self.sliderBgView.left;
    }completion:^(BOOL finished) {
        [self showSliderBgTitle:YES];
    }];
    
    //toast提示
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"解锁失败！" toUrl:nil mode:SNCenterToastModeWarning];
    
    //红包解锁失败上报
    [self verifyFailConfirm];
    
    self.redPacketSlideNum++;
    if (self.redPacketSlideNum >= [[SNAppConfigManager sharedInstance] redPacketSlideNum]) {
        [self dismissRedPacket];
    }
    
    [self reportADotGif];
}

- (void)showCloseAlertView:(NSString*)message withTitle:(NSString*)title{

    SNNewAlertView *redPacketAlert = [[SNNewAlertView alloc] initWithContentView:[self createRedPacketViewWithMessage:message] cancelButtonTitle:@"我再想想" otherButtonTitle:@"任性不要" alertStyle:SNNewAlertViewStyleAlert];
    [redPacketAlert show];
    [redPacketAlert actionWithBlocksCancelButtonHandler:^{
        [self cancelAction];
    } otherButtonHandler:^{
        [self dismissRedPacket];
    }];
}

- (UIView *)createRedPacketViewWithMessage:(NSString *)msg {
    UIView *bgView = [[UIView alloc] init];
    
    // 弹窗的显示内容
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultLeftMargin, kDefaultLeftMargin, kDefaultAlertWidth - kDefaultLeftMargin * 2, 0)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:msg];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [msg length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kThemeFontSizeD] range:NSMakeRange(0, [msg length])];
    msgLabel.attributedText = attributedString;
    msgLabel.numberOfLines = 0;
    [msgLabel sizeToFit];
    msgLabel.textColor = SNUICOLOR(kThemeText1Color);
    [bgView addSubview:msgLabel];
    
    // 不再提示的按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kDefaultLeftMargin, msgLabel.bottom + 18, 100, kDefaultLeftMargin)];
    [button setTitle:@" 不再提示" forState:UIControlStateNormal];
    [button setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [button setTitle:@" 不再提示" forState:UIControlStateHighlighted];
    [button setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"icohb_tc_v5.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icohb_tc_v5.png"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"icohb_tcq_v5.png"] forState:UIControlStateSelected];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, -kDefaultLeftMargin, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    button.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:button];
    
    bgView.frame = CGRectMake(0, 0, kDefaultAlertWidth, kDefaultLeftMargin + msgLabel.height + button.height + 18 + 15);
    
    return bgView;
}

#pragma mark checkBoxAction

- (void)checkBoxAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self showCloseAlertOnceTime];
}


- (void)showCloseAlertOnceTime{
    BOOL showOnceTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"showCloseAlertOnceTime"];
    
    [[NSUserDefaults standardUserDefaults] setBool:!showOnceTime forKey:@"showCloseAlertOnceTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)canShowCloseAlert{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"showCloseAlertOnceTime"];
}

- (void)cancelAction{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showCloseAlertOnceTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sliderValueChanged:(id)sender{
//    if ([sender isEqual:self.redPacketSlider]) {
//        self.verifyImgView.left = self.redPacketSlider.value;
//        self.sliderTitle.hidden = YES;
//        SNDebugLog(@"%f", self.redPacketSlider.value);
//    }
}

- (IBAction)sliderDragUp:(id)sender{
//    if ([sender isEqual:self.redPacketSlider]) {
//        CGFloat sliderValue = self.redPacketSlider.value;
//        if (fabs(self.verifyImgView.left - (self.redPacket.left + self.maskImageView.left)) < 6) {
////            [self saveToAlipay];  新需求变更，不需要存入支付宝流程
//            
//            //红包解锁成功上报
//            [self verifySuccessConfirm];
//        }
//        else{
//            [UIView animateWithDuration:0.2 animations:^{
//                self.verifyImgView.left = VerifyImgLeft;
//                self.redPacketSlider.value = VerifyImgLeft;
//            }];
//            
//            //toast提示
//            [[SNToast shareInstance] showToastWithTitle:@"解锁失败！" toUrl:nil mode:SNToastUIModeWarning];
//            
//            //红包解锁失败上报
//            [self verifyFailConfirm];
//
//            self.redPacketSlideNum++;
//            if (self.redPacketSlideNum >= [[SNAppConfigManager sharedInstance] redPacketSlideNum]) {
//                [self dismissRedPacket];
//            }
//            
//            self.sliderTitle.hidden = NO;
//        }
//    }
}

- (void)confirmUserRedPacket{
    [SNUtility shouldUseSpreadAnimation:NO];
    self.alipayButton.userInteractionEnabled = NO;
    [SNUtility checkIsBindAlipayWithResult:^(BOOL isBindAlipay) {
        
        if ([SNUserManager isLogin] && isBindAlipay) {
            [self verifySuccessConfirm];
        } else {
            [self loginAndBindAlipay];
            self.alipayButton.userInteractionEnabled = YES;
        }
        
        if ([self isOlympicRedPacket]) {
            [self reportADotGif:@"get"];
            self.alipayButton.userInteractionEnabled = YES;
        }
    }];
}

//- (void)verifySuccessConfirm{
//    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
//    NSString *p1 = [[SNUserManager getP1] URLEncodedString];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:p1, @"p1", item.redPacketId, @"packId", nil];
//    
//    NSString *dataStr = [[SNRedPacketManager sharedInstance] aesEncryptWithData:[dic yajl_JSONString]];
//     
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters setValue:p1 forKey:@"p1"];
//    [parameters setValue:dataStr forKey:@"data"];
//    [parameters setValue:[[SNRedPacketManager sharedInstance] getKeyVersion] forKey:@"v"];
//    [parameters setValue:[NSNumber numberWithBool:item.isSlideUnlockRedpacket] forKey:@"isSlide"];
//    [parameters setValue:[SNUserManager getPid] forKey:@"pid"];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = 3.f;
//    NSString *urlString = [SNLinks_Path_RedPacket_Confirm stringByAppendingFormat:@"?token=%@&gid=%@", [SNUserManager getToken], [SNUserManager getGid]];
//    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *requestDict = (NSDictionary *)responseObject;
//            int statusCode = [[requestDict objectForKey:@"statusCode"] intValue] ;
//            if (statusCode == 10000000) {
//                [self getUserRedPacket];
//                if (self.redPacketType == SNRedPacketTask) {
////                    [self.alipayButton addTarget:self action:@selector(getTaskRedPacket) forControlEvents:UIControlEventTouchUpInside];
//                    [self getTaskRedPacket];
//                }
//                
//                [self.verifyImgView removeFromSuperview];
//                [self.maskImageView removeFromSuperview];
//                
//                //刷新h5
////                [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
//                [SNNotificationManager postNotificationName:kReceiveRedPacketSucceedNotification object:nil];
//            }
//            else{
//                [self showFailAlertView:@"领取失败～要不要再试试" withTitle:@"" withTag:10000];
//            }
//
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showFailAlertView:@"领取失败～要不要再试试" withTitle:@"" withTag:10000];
//    }];
//}

- (void)verifySuccessConfirm {
    
    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
    NSString *p1 = [[SNUserManager getP1] URLEncodedString];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:p1, @"p1", item.redPacketId, @"packId", nil];
    NSString *dataStr = [[SNRedPacketManager sharedInstance] aesEncryptWithData:[dic yajl_JSONString]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    [parameters setValue:dataStr forKey:@"data"];
    [parameters setValue:[[SNRedPacketManager sharedInstance] getKeyVersion] forKey:@"v"];
    [parameters setValue:[NSNumber numberWithBool:item.isSlideUnlockRedpacket] forKey:@"isSlide"];
    
    [[[SNRedPacketConfirmRequest alloc] initWithDictionary:parameters] send:^(SNBaseRequest *request, id responseObject) {
        self.alipayButton.userInteractionEnabled = YES;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *requestDict = (NSDictionary *)responseObject;
            int statusCode = [[requestDict objectForKey:@"statusCode"] intValue] ;
            if (statusCode == 10000000) {
                [self getUserRedPacket];
                if (self.redPacketType == SNRedPacketTask) {
                    [self getTaskRedPacket];
                }
                [self.verifyImgView removeFromSuperview];
                [self.maskImageView removeFromSuperview];

                [SNNotificationManager postNotificationName:kReceiveRedPacketSucceedNotification object:nil];
            } else {
                [self showFailAlertView:@"领取失败～要不要再试试" withTitle:@"" withTag:10000];
            }
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        self.alipayButton.userInteractionEnabled = YES;
        [self showFailAlertView:@"领取失败～要不要再试试" withTitle:@"" withTag:10000];
    }];
}

- (void)verifyFailConfirm{
    
    [[[SNRedPacketSlideRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}

- (void)showSliderBgTitle:(BOOL)shown{
    NSString *titleStr = [SNRedPacketManager sharedInstance].redPacketItem.slideUnlockRedPacketText;
    if (titleStr == nil || [titleStr length] == 0) {
        titleStr = @"将小图拖到指定位置解锁";
    }
    NSString *title = shown ? titleStr : @"";
    [self.sliderBgView setTitle:title forState:UIControlStateNormal];
}

- (void)reportADotGif{
    [SNNewsReport reportADotGif:@"_act=slideverify&_tp=fail"];
}

- (void)loginAndBindAlipay{
    //判断是否登陆绑定搜狐账户
    [[SNRedPacketModel sharedInstance] verifySendRedPacket:^(BOOL Success, BOOL isClickBackButton) {
        if (Success) {
            //是否绑定支付宝
//            BOOL isBindAlipay = [SNUtility isBindAlipay];
            [SNUtility checkIsBindAlipayWithResult:^(BOOL isBindAlipay) {
                
                if (!isBindAlipay) {
                    //支付宝授权
                    [[SNRedPacketModel sharedInstance] auth_V2:^(BOOL Success, NSString *result) {
                        if (Success) {
                            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
//                            NSString *bingAP = [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode];
                            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
//                                NSDictionary *jsonDict = [bingAP objectFromJSONString];
                                SNDebugLog(@"bindApalipayPassport ----------- %@",jsonDict);
                                if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                                    NSInteger statusCode = [[NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]]integerValue];
                                    NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                                    if (statusCode == 10000000) {
                                        [self verifySuccessConfirm];
                                    }else{
                                        [self showFailAlertView:statusMsg withTitle:nil withTag:loginAndBindTag];
                                    }
                                }else{
                                    [self showFailAlertView:@"支付宝账户绑定失败" withTitle:nil withTag:loginAndBindTag];
                                }
                            }];
                        }
                        else{
                            [self showFailAlertView:@"支付宝账户绑定失败" withTitle:nil withTag:loginAndBindTag];
                        }
                    }];
                    
                    [SNRedPacketModel sharedInstance].authCompletion = ^(BOOL Success, NSString *result){
                        if (Success) {
                            NSString *openid = [SNRedPacketModel getPidByInfoStr:result];
                            NSString *authcode = [SNRedPacketModel getValueStringFromUrl:result forParam:@"auth_code"];
//                            NSString *bingAP = [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode];
                            [[SNRedPacketModel sharedInstance] bindApalipayPassport:openid withAuthCode:authcode andResult:^(id jsonDict) {
//                                NSDictionary *jsonDict = [bingAP objectFromJSONString];
                                SNDebugLog(@"bindApalipayPassport ----------- %@",jsonDict);
                                if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
                                    NSInteger statusCode = [[NSString stringWithFormat:@"%@",jsonDict[@"statusCode"]]integerValue];
                                    NSString *statusMsg = [NSString stringWithFormat:@"%@",jsonDict[@"statusMsg"]];
                                    if (statusCode == 10000000) {
                                        [self verifySuccessConfirm];
                                    }else{
                                        [self showFailAlertView:statusMsg withTitle:nil  withTag:loginAndBindTag];
                                    }
                                }
                            }];
                        }else{
                            [self showFailAlertView:@"支付宝账户授权失败" withTitle:nil  withTag:loginAndBindTag];
                        }
                    };
                } else {
                    [self verifySuccessConfirm];
                }
            }];
        }
        else{
            [self showFailAlertView:@"登陆失败" withTitle:nil  withTag:loginAndBindTag];
        }
    }];
}

- (void)loginAndBindDisappear{
    /*
    if ([SNUserManager isLogin] && [SNUtility isBindMobile]) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.verifyImgView.left = VerifyImgLeft;
        self.sliderBtn.left = self.sliderBgView.left;
    }completion:^(BOOL finished) {
        [self showSliderBgTitle:YES];
    }];
    */
    [SNUtility checkIsBindMobileWithResult:^(BOOL isBindMobile) {
        if ([SNUserManager isLogin] && isBindMobile) {
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.verifyImgView.left = VerifyImgLeft;
            self.sliderBtn.left = self.sliderBgView.left;
        }completion:^(BOOL finished) {
            [self showSliderBgTitle:YES];
        }];
    }];
}

- (void)resetverifyImageViewLayout{
    if (self.showAlipayButton == YES) {
        return;
    }
    
    if ([[TTNavigator navigator].topViewController isKindOfClass:NSClassFromString(@"SNBindMobileNumViewController")]) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.verifyImgView.left = VerifyImgLeft;
        self.sliderBtn.left = self.sliderBgView.left;
    }completion:^(BOOL finished) {
        [self showSliderBgTitle:YES];
    }];
}


- (BOOL)isOlympicRedPacket{
    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
    if ((item.jumpUrl != nil && [item.jumpUrl length] != 0) && [item.jumpUrl containsString:@"olympicredpacket"]) {
        return YES;
    }
    
    return NO;
}

- (void)reportADotGif:(NSString *)action{
    [SNNewsReport reportADotGif:@"_act=ayhongbao&_tp=%@"];
}

@end
