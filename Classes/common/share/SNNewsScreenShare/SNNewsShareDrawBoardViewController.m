//
//  SNNewsShareDrawBoardViewController.m
//  sohunews
//
//  Created by wang shun on 2017/7/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsShareDrawBoardViewController.h"

#import "SNNewsDrawBoard.h"

#import "SNNewsScreenShare.h"

#import "SNNewsShareDrawBoardSlider.h"
#import "SNNewsScreenShareTouchView.h"//仅用于挡住touch事件
#import "SNDrawOvalAnimation.h"

@interface SNNewsShareDrawBoardViewController ()<SNNewsShareDrawBoardSliderDelegate,SNNewsDrawBoardDelegate>
{
    BOOL isShowMenu;
    BOOL isShowMenuLater;
    BOOL isTouchSlider;
    
    NSDate* isTouchEdnSliderDate;
    
    CGFloat topMenuTopHeight;
    CGFloat bottomMenuTopHeight;
}

@property (nonatomic,strong) SNNewsDrawBoard* drawView;

@property (nonatomic,strong) UIView* topMenu;
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,strong) UIView* bottomMenu;
@property (nonatomic,strong) SNNewsShareDrawBoardSlider* slider;
@property (nonatomic,strong) UIImageView* undoImageView;
@property (nonatomic,strong) UIImageView* img;
@property (nonatomic,strong) UIImageView* pencil;

@property (nonatomic,strong) SNNewsScreenShareTouchView* touchView;//用来挡住画板touch事件
@property (nonatomic,strong) SNNewsScreenShareTouchView* top_touchView;//用来挡住画板touch事件

@property (nonatomic,strong) UIImage* editor_Image;

@property (nonatomic,strong) UIImageView* final_drawView;

@end

@implementation SNNewsShareDrawBoardViewController

- (instancetype)initWithEditorImage:(UIImage*)image{
    if (self = [super init]) {
        self.editor_Image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorFromString:@"#e0e0e0"];
    
    //用于定位
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 47+10, self.view.bounds.size.width, self.view.bounds.size.height-47-61-10-10)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bgView];
    
    CGFloat h = self.view.bounds.size.height-47-61-10-10;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        h = self.view.bounds.size.height - (47+24)-(61+20)-10-10;
    }
    
    CGFloat w = (self.editor_Image.size.width/self.editor_Image.size.height)*h;
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    imageView.image = self.editor_Image;
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    imageView.center = bgView.center;
    
    self.final_drawView = imageView;
    
    
    self.drawView = [[SNNewsDrawBoard alloc] initWithFrame:imageView.bounds];
    self.drawView.brushWidth = 3;
    self.drawView.shapeType = SNNewsDrawShapeCurve;
    self.drawView.delegate = self;
    
//    self.drawView.backgroundImage = self.editor_Image;
    
    [imageView addSubview:self.drawView];
    
    imageView.clipsToBounds = YES;
    
    self.touchView = [[SNNewsScreenShareTouchView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-61, self.view.bounds.size.width, 61)];
    self.touchView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    [self.view addSubview:self.touchView];
    
    self.top_touchView = [[SNNewsScreenShareTouchView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 47)];
    self.top_touchView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    [self.view addSubview:self.top_touchView];
    
    [self createTopMenuView];
    [self createBottomMenuView];
    
    [self performSelector:@selector(showFirstMenu:) withObject:nil afterDelay:0.25];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self performSelector:@selector(showFirstMenu:) withObject:nil afterDelay:0.25];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSNDrawOvalAnimationDidShow]) {
        [SNDrawOvalAnimation start];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSNDrawOvalAnimationDidShow];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)drawBoardClick:(id)sender{

//    self.drawView.isShowMenu = !isShowMenu;
//    [self showMenu:!isShowMenu completion:^(BOOL finished) {
//    }];
//    self.drawView.isShowMenu = !isShowMenu;
//    [self showMenu:!isShowMenu completion:^(BOOL finished) {
//    }];
}

-(void)drawBoardCanUnDo:(BOOL)can{
    if (can == YES) {//能撤销
        self.undoImageView.image = [UIImage themeImageNamed:@"ico_undo1_v5.png"];
    }
    else{//不能撤销
        self.undoImageView.image = [UIImage themeImageNamed:@"ico_undo_v5.png"];
    }
   
//    if (can == YES) {//如果画完了一笔 显示menu 
//        isShowMenuLater = NO;
//        [self performSelector:@selector(showMenuLater) withObject:nil afterDelay:0.5];
//    }
}

//- (void)showMenuLater{
//    
//    if (isShowMenuLater == NO) {
//        self.drawView.isShowMenu = !isShowMenu;
//        [self showMenu:!isShowMenu completion:^(BOOL finished) {
//            
//        }];
//    }
//}

- (void)drawBoardStartDraw:(id)sender{
    isShowMenuLater = YES;
    if (isShowMenu == YES) {
//        self.drawView.isShowMenu = NO;
//        [self showMenu:NO completion:^(BOOL finished) {
//            
//        }];
    }
}

- (void)drawBroardStartTouch:(id)sender{
    isTouchSlider = YES;
    //NSLog(@"drawBroardStartTouch isTouchSlider :%d",isTouchSlider);
}

- (void)drawBroardEndTouch:(id)sender{
    isTouchSlider = NO;
    isTouchEdnSliderDate = [NSDate date];
    //NSLog(@"drawBroardStartTouch drawBroardEndTouch :%d",isTouchSlider);
    [self performSelector:@selector(hideImg) withObject:nil afterDelay:1.0];
}


- (void)showFirstMenu:(id)sender{
    self.drawView.isShowMenu = YES;
    __weak SNNewsShareDrawBoardViewController* weakSelf = self;
    [self showMenu:YES completion:^(BOOL finished) {
        self.img.hidden = NO;
        [weakSelf performSelector:@selector(hideImg) withObject:nil afterDelay:2.0];
    }];
}

- (void)hideImg{
    //NSLog(@"drawBroardStartTouch isTouchSlider :%d",isTouchSlider);
    if (isTouchSlider == NO) {
        double f = [SNNewsScreenShare getDateInterval:isTouchEdnSliderDate Date2:[NSDate date]];
        if (f>0.9) {
            self.img.hidden = YES;
        }
    }
}

//- (void)tapClick:(UIGestureRecognizer*)gesture{
//    if (isShowMenu == YES) {
//        CGPoint point = [gesture locationInView:self.view];
//        if (point.y<(47) || point.y>(self.view.bounds.size.height-61)) {
//            return;
//        }
//    }
//    
//    self.drawView.isShowMenu = !isShowMenu;
//    [self showMenu:!isShowMenu completion:^(BOOL finished) {
//        
//    }];
//}

#pragma mark - bottomMenu Click

- (void)unDoBtnClick:(UIButton*)btn{
    [self.drawView unDo];
}

#pragma mark - topMenu Click

- (void)finishBtnClick:(UIButton*)b{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getClipImage:)]) {
        UIImage* image =[self.drawView getLastBrush];
        [self.delegate getClipImage:image];
        [self enterPreviewPage];
    }
    
    //http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=10191408
    [SNNewsReport reportADotGif:@"_act=share_to_button&_tp=clk&newsId=&channelid="];
    
        
//    if (isShowMenu) {
//        __weak SNNewsShareDrawBoardViewController* weakSelf = self;
//        self.img.hidden = YES;
//        b.enabled = NO;
//        [self showMenuHideCompletion:^(BOOL finished) {
        
//            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(getClipImage:)]) {
//                UIImage *image = [UIImage imageWithScreenshot];
//                UIImage* p_image = [weakSelf.delegate getClipImage:image];
//            }
//            [weakSelf performSelector:@selector(enterPreviewPage) withObject:nil afterDelay:0.5];
//            b.enabled = YES;
//        }];
//    }
//    else{
//        if (self.delegate && [self.delegate respondsToSelector:@selector(getClipImage:)]) {
//            UIImage* image = [SNNewsScreenShare getImageFromView:self.view];//再次生成图片
//            [self.delegate getClipImage:image];
//        }
//        [self performSelector:@selector(closeSelf) withObject:nil afterDelay:0.5];
//    }
}

- (void)cancelBtnClick:(UIButton*)b{
    [self.drawView canelClick];
    [self closeSelf];
}

- (void)reEnterSelf{
    [self.drawView reEnterSelf];
    [self showFirstMenu:nil];
}

- (void)enterPreviewPage{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushPreViewController:)]) {
        [self.delegate pushPreViewController:nil];
    }
}

#pragma mark - closeSelf

- (void)closeSelf{
    if (self.delegate && [self.delegate respondsToSelector:@selector(removedSelf)]) {
        [self.delegate removedSelf];
    }
    [self.drawView clean];
    [self.flipboardNavigationController popViewControllerAnimated:YES];
    
//    [self.view removeFromSuperview];
//    [self removeFromParentViewController];
}

#pragma mark -  showMenu Animation

- (void)showMenu:(BOOL)b completion:(void (^)(BOOL finished))completion{
    SNDebugLog(@"showMenu");
    if (b) {
        topMenuTopHeight = [[SNDevice sharedInstance] isPhoneX]?24:0;
        CGFloat hhh = [[SNDevice sharedInstance] isPhoneX]?81:61;
        bottomMenuTopHeight = self.view.bounds.size.height-hhh;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.topMenu setFrame:CGRectMake(0, topMenuTopHeight, self.view.bounds.size.width, 47)];
            [self.bottomMenu setFrame:CGRectMake(0, bottomMenuTopHeight, self.view.bounds.size.width, hhh)];
        } completion:^(BOOL finished) {
            isShowMenu = YES;
            self.touchView.hidden = NO;
            self.top_touchView.hidden = NO;
            self.titleLabel.hidden = NO;
            
            if (completion) {
                completion(YES);
            }
            //self.img.hidden = NO;
//            [self performSelector:@selector(hideImg) withObject:nil afterDelay:1.5];
        }];
    }
    else{
        topMenuTopHeight = -47 - ([[SNDevice sharedInstance] isPhoneX]?24:0);
        CGFloat hhh = 61;
        bottomMenuTopHeight = self.view.bounds.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            [self.topMenu setFrame:CGRectMake(0, topMenuTopHeight, self.view.bounds.size.width, 47)];
            [self.bottomMenu setFrame:CGRectMake(0, bottomMenuTopHeight, self.view.bounds.size.width, hhh)];
        } completion:^(BOOL finished) {
            isShowMenu = NO;
            self.touchView.hidden = YES;
            self.top_touchView.hidden = YES;
            self.titleLabel.hidden = YES;
            if (completion) {
                completion(YES);
            }
            self.img.hidden = YES;
        }];
    }
}

- (void)showMenuHideCompletion:(void (^)(BOOL finished))completion{
    SNDebugLog(@"showMenuHidecompletion");

    topMenuTopHeight = -47;
    CGFloat hhh = 61;
    bottomMenuTopHeight = self.view.bounds.size.height;
//    [UIView animateWithDuration:0.25 animations:^{
        [self.topMenu setFrame:CGRectMake(0, topMenuTopHeight, self.view.bounds.size.width, 47)];
        [self.bottomMenu setFrame:CGRectMake(0, bottomMenuTopHeight, self.view.bounds.size.width, hhh)];
//    } completion:^(BOOL finished) {
        isShowMenu = NO;
        self.touchView.hidden = YES;
        self.top_touchView.hidden = YES;
        self.titleLabel.hidden = YES;
        if (completion) {
            completion(YES);
        }
        self.img.hidden = YES;
//    }];
}

#pragma mark -  create UI

- (void)createTopMenuView{
    topMenuTopHeight = -47;
    CGFloat h = [[SNDevice sharedInstance] isPhoneX]?(44+30):(20+30);
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, topMenuTopHeight, self.view.bounds.size.width, 50)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view];
    self.topMenu = view;

    UIView* black_view = [[UIView alloc] initWithFrame:view.bounds];
    black_view.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    black_view.alpha = 0.9;
    [view addSubview:black_view];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    label.font = [UIFont boldSystemFontOfSize:kThemeFontSizeE];
    label.text = @"划重点";
    label.textColor = SNUICOLOR(kThemeText2Color);
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    label.hidden = YES;
    self.titleLabel = label;
    
    UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setImage:[UIImage imageNamed:@"ico_arrow_v5.png"] forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(10, 20, 68, 30)];
    cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    //titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [cancelBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    
    [view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"ico_share_v5.png"]];
    imageView.frame = CGRectMake(self.view.bounds.size.width-14-42-7-18, 25, 18, 20);
    [view addSubview:imageView];
    
    UIButton* finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishBtn setTitle:@"分享" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [finishBtn setFrame:CGRectMake(self.view.bounds.size.width-14-42, 20, 42, 30)];
    [finishBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    [view addSubview:finishBtn];
    [finishBtn addTarget:self action:@selector(finishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createBottomMenuView{
    
    CGFloat hhh = 61;
    bottomMenuTopHeight = self.view.bounds.size.height;

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, bottomMenuTopHeight, self.view.bounds.size.width, hhh)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view];
    self.bottomMenu = view;
    
    UIView* black_view = [[UIView alloc] initWithFrame:view.bounds];
    black_view.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    black_view.alpha = 1;
    [view addSubview:black_view];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, (61-44)/2, 0.5, 44)];
    line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [view addSubview:line];
    
    self.pencil = [[UIImageView alloc] initWithFrame:CGRectMake(16, (61-17)/2, 17, 17)];
    self.pencil.image = [UIImage themeImageNamed:@"ico_write1_v5.png"];
    [view addSubview:self.pencil];
    
    self.undoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-(35+10), (61-(17+5+21))/2, 21, 17)];
    self.undoImageView.image = [UIImage themeImageNamed:@"ico_undo_v5.png"];
    [view addSubview:self.undoImageView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.undoImageView.frame)-5, CGRectGetMaxY(self.undoImageView.frame)+5, CGRectGetWidth(self.undoImageView.frame)+10, 21)];
    [label setText:@"撤销"];
    
    label.textColor = SNUICOLOR(kThemeText9Color);
    label.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    UIButton* unDoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [unDoBtn setFrame:CGRectMake(self.view.bounds.size.width-70, 0, 70, view.frame.size.height)];
    [view addSubview:unDoBtn];
    [unDoBtn addTarget:self action:@selector(unDoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat w = (CGRectGetMinX(line.frame)-8)-(CGRectGetMaxX(self.pencil.frame)+8);
    
    self.slider = [[SNNewsShareDrawBoardSlider alloc] initWithFrame:CGRectMake((CGRectGetMaxX(self.pencil.frame)+8), 0, w, hhh) WithBgColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor]];
    self.slider.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kBackgroundColor];
    [view addSubview:self.slider];
    self.slider.delegate = self;
    
    self.img = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetMaxX(self.pencil.frame)+8)+6-14, (self.view.bounds.size.height-hhh)-34, 27, 34)];
    [self.view addSubview:self.img];
    self.img.image = [UIImage themeImageNamed:@"ico_color1_v5.png"];
    self.img.hidden = YES;
}

- (void)selectedColor:(UIColor *)color WithPoint:(CGPoint)point WithNumber:(NSInteger)n{
    self.img.frame = CGRectMake(CGRectGetMinX(self.slider.frame)-14+point.x, (self.view.bounds.size.height-61)-34, 27, 34);
    if (color) {
        NSString* str = [NSString stringWithFormat:@"ico_color%d_v5.png",(n+1)];
        self.img.image = [UIImage themeImageNamed:str];
        self.drawView.brushColor = color;
        
        NSString* write = [NSString stringWithFormat:@"ico_write%d_v5.png",(n+1)];
        self.pencil.image = [UIImage themeImageNamed:write];
        if (self.img.hidden == YES) {
            self.img.hidden = NO;
        }
    }
}

- (void)clean{
    [self.drawView clean];
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)panGestureEnable{
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
