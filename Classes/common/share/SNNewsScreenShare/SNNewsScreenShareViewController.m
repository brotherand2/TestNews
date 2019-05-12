//
//  SNNewsScreenShareViewController.m
//  sohunews
//
//  Created by wang shun on 2017/7/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareViewController.h"

#import "SNShareItemsView.h"
#import "SNShareMenuViewModel.h"
#import "SNNewsShareManager.h"
#import "SNNewsScreenShare.h"
#import "UIColor+ColorChange.h"
#import "SNNewsShareDrawBoardViewController.h"
#import "SNNewsScreenWeiXin.h"
#import "SNNewsScreenSharePic.h"
#import "SNNewsScreenSharefocalBtn.h"
#import "SNNewsScreenCheckBoxView.h"
#import "SNNewsScreenShareItemsView.h"

#define SNNews_ScreenShare_BGCOLOR SNUICOLOR(kBackgroundColor)

@interface SNNewsScreenShareViewController ()<SNNewAlertViewDelegate,SNNewsShareManagerDelegate,SNNewsScreenSharePicDelegate,SNNewsScreenSharefocalBtnDelegate,SNNewsScreenShareItemsViewDelegate,SNNewsScreenCheckBoxViewdelegate,SNNewsScreenWeiXinDelegate>
{
    BOOL isSHH5News;
    
    CGRect qr_head_show_rect;//二维码有头像 显示
    CGRect qr_show_rect;//二维码无头像 显示
    
    CGRect qr_head_rect;//二维码有头像
    CGRect qr_rect;//二维码无头像
    CGRect bg_head_rect;//bg 有头像
    CGRect bg_rect;//bg 无头像
    CGRect sohu_head_rect;//bg 有头像
    CGRect sohu_rect;//bg 无头像
    
    
    NSString* link2;
}
@property (nonatomic,strong) SNShareMenuViewModel* viewModel;//显示分享icon

//viewModel
@property (nonatomic,strong) SNNewsScreenWeiXin* weixinModel;//微信授权
@property (nonatomic,strong) SNNewsScreenSharePic* sharePic;//分享图片

@property (nonatomic,strong) SNNewsShareManager* shareManager;
@property (nonatomic,strong) NSMutableDictionary* shareOnData;

//隔板view
@property (nonatomic,strong) UIView* bgView;

//授权checkbox
@property (nonatomic,strong) SNNewsScreenCheckBoxView* checkView;
//分享icon 朋友圈 好友 狐友
@property (nonatomic,strong) SNNewsScreenShareItemsView* itemsView;
//右上角 划重点btn
@property (nonatomic,strong) SNNewsScreenSharefocalBtn* focalBtn;//划重点

//切图
@property (nonatomic,strong) UIImage* clip_img;
@property (nonatomic,strong) UIImage* base_img;
@property (nonatomic,strong) UIImage* brush_img;

//二维码
@property (nonatomic,strong) UIImageView* final_clip_imageView;
@property (nonatomic,strong) UIImageView* final_qr_code_imageView;

@property (nonatomic,strong) UIView* final_share_View;//最终分享view
@property (nonatomic,strong) UIView* sohu_share_View;//狐友分享view (产品要求狐友不要二维码) wangshun

@property (nonatomic,strong) UILabel* tips_show;//默认文案
@property (nonatomic,strong) UILabel* tips_share;//默认文案


@property (nonatomic,strong) UIImageView* clip_imageView;//截屏图
@property (nonatomic,strong) UIView* head_bg_view;//头像行分享
@property (nonatomic,strong) UIView* qr_bgView;//二维码行分享
@property (nonatomic,strong) UIView* qr_bgView_show;//二维码行显示
@property (nonatomic,strong) UIView* head_bg_view_show;//头像行显示
@property (nonatomic,strong) UIImageView* qr_code_imageView;

@property (nonatomic,strong) UIView* share_View;//分享view
@property (nonatomic,strong) UIView* share_sohu_View;//分享狐友view


@property (nonatomic,strong) UIImageView* head_imgView_share;
@property (nonatomic,strong) UILabel* nickNameLabel_share;

@property (nonatomic,strong) UIImageView* head_imgView_show;
@property (nonatomic,strong) UILabel* nickNameLabel_show;

@property (nonatomic,strong) SNNewsShareDrawBoardViewController* drawBoardViewController;

@end

@implementation SNNewsScreenShareViewController

- (instancetype)initWithClipImage:(UIImage*)image WithBrushImage:(UIImage *)brush BaseImage:(UIImage *)baseImg WithData:(NSDictionary *)data{
    if (self = [super init]) {
        self.clip_img = image;
        self.base_img = baseImg;
        self.brush_img = brush;
        
        isSHH5News = NO;
        if (data) {
            NSString* isSHH5News_s = [data objectForKey:@"isSHH5News"];
            if([isSHH5News_s isEqualToString:@"1"]){
                isSHH5News = YES;
                self.shareOnData = [data objectForKey:@"shareon"];
            }
            else{
                isSHH5News = NO;
                
                NSDictionary* shareon = [data objectForKey:@"shareon"];
                if (shareon && [shareon isKindOfClass:[NSDictionary class]]) {
                    self.shareOnData = [NSMutableDictionary dictionaryWithDictionary:shareon];
                }
                
            }
        }
        
    }
    return self;
}

- (instancetype)initWithClipImage:(UIImage*)image BaseImage:(UIImage*)baseImg WithData:(NSDictionary*)data{
    if (self = [super init]) {
        self.clip_img = image;
        self.base_img = baseImg;
        
        isSHH5News = NO;
        if (data) {
            NSString* isSHH5News_s = [data objectForKey:@"isSHH5News"];
            if([isSHH5News_s isEqualToString:@"1"]){
                isSHH5News = YES;
                self.shareOnData = [data objectForKey:@"shareon"];
            }
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewModel = [[SNShareMenuViewModel alloc] initWithData:@{SNNewsShare_disableIcons:@"lifeCircle,copyLink,Screenshot,qq,qqZone,alipay,sina"}];
    self.weixinModel = [[SNNewsScreenWeiXin alloc] init];
    self.weixinModel.delegate = self;
    
    
    self.sharePic = [[SNNewsScreenSharePic alloc] init];
    self.sharePic.delegate = self;
    
    if (isSHH5News == YES) {
        self.sharePic.isSHH5News = YES;
    }
    else{
        self.sharePic.isSHH5News = NO;
    }
    
    self.view.backgroundColor = SNNews_ScreenShare_BGCOLOR;

    //写两份UI，原因就是看到的图太小了，分享出去的要实际大小
    [self createfinalClipImageView];
    
    _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = SNNews_ScreenShare_BGCOLOR;
    [self.view addSubview:_bgView];
    
    [self createEditBtn];
    
    [self createClipImageView];

    [self showScreenShotShareView];

    //[self addNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.weixinModel didload:self.shareOnData];
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark -  编辑

- (void)createEditBtn{
    //划重点
    CGFloat w = 89;
    CGFloat x = self.view.bounds.size.width-14-w;
    
    CGFloat y = 20+8;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        y = 44+8;
    }
    CGFloat h = 31;
    
    self.focalBtn = [[SNNewsScreenSharefocalBtn alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.focalBtn.delegate = self;
    [self.view addSubview:self.focalBtn];
}

-(void)focalBtnPress:(id)sender{
    SNNavigationController* flipboardNavigationController = [TTNavigator navigator].topViewController.flipboardNavigationController;
    [flipboardNavigationController popViewControllerAnimated:YES];
    
    [SNNewsReport reportADotGif:@"_act=highlight&_tp=clk&newsId=&channelid="];
}

////////////////////////////////////////////////////////////////////////////////
//调整有头像和无头像UI位置
- (void)showHead:(BOOL)show{
    if (show == YES) {
        self.head_bg_view_show.hidden = NO;
        self.head_bg_view.hidden      = NO;
        
        [self.qr_bgView_show setFrame:qr_head_show_rect];
        [self.qr_bgView setFrame:qr_head_rect];
        [self.final_share_View setFrame:bg_head_rect];
        [self.sohu_share_View setFrame:sohu_head_rect];
    }
    else{
        self.head_bg_view_show.hidden = YES;
        self.head_bg_view.hidden      = YES;
        
        [self.qr_bgView_show setFrame:qr_show_rect];
        [self.qr_bgView setFrame:qr_rect];
        [self.final_share_View setFrame:bg_rect];
        [self.sohu_share_View setFrame:sohu_rect];
    }
}

#pragma mark - 勾选带头像

- (BOOL)selectedCheckBox:(BOOL)isSelected{
    
    self.weixinModel.isCheckBoxSelected = isSelected;
    if (self.weixinModel.isCheckBoxSelected == YES) {
        self.sharePic.selected = @"1";
    }
    else{
        self.sharePic.selected = @"";
    }
    
    if ([self.sharePic isShowHead:nil]) {//有头像有昵称才显示
        [self setHeadUrl:self.sharePic.headUrl Title:self.sharePic.nickName Completion:nil];
        [self showHead:isSelected];
    }
    else{
        [self showHead:NO];
    }
    
    //勾选
    [SNNewsReport reportADotGif:@"_act=share_view_addname&_tp=clk&newsId=&channelid="];
    return YES;//
}

#pragma mark - 创建俩UI层

- (void)createfinalClipImageView{
    CGFloat b = (720/348.0);
    
    CGFloat w1 = (405/360.0);
    CGFloat w = w1* self.clip_img.size.width;
    
    CGFloat h1 = (718/405.0);
    CGFloat h = h1*w;
    
    if ([[SNDevice sharedInstance] isPhoneX]) {
        h = h + 300;
    }
    //CGFloat h = self.clip_img.size.width*b;
    //CGFloat w = self.clip_img.size.width;
    
    UIView* bg_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [bg_view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bg_view];
    
    self.sohu_share_View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [self.sohu_share_View setBackgroundColor:[UIColor whiteColor]];
    [bg_view addSubview:self.sohu_share_View];
    
    CGFloat clip_image_x = (w-self.clip_img.size.width)/2.0;
    CGFloat clip_image_y = (22/718.0)*h;
    
    UIImageView* clip_image = [[UIImageView alloc] initWithFrame:CGRectMake(clip_image_x, clip_image_y, self.clip_img.size.width, self.clip_img.size.height)];
    clip_image.image = self.clip_img;
    [self.sohu_share_View addSubview:clip_image];
    
    clip_image.layer.shadowColor = [UIColor blackColor].CGColor;
    clip_image.layer.shadowOpacity = 0.3f;
    clip_image.layer.shadowRadius = 4.0f;
    clip_image.layer.shadowOffset = CGSizeMake(0,0);
    
    if (self.brush_img) {
        UIImageView* brush_imageView = [[UIImageView alloc] initWithImage:self.brush_img];
        [brush_imageView setFrame:clip_image.bounds];
//        brush_imageView.center = clip_image.center;
        [clip_image addSubview:brush_imageView];
    }
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(clip_image.frame)+1, w, 1)];
    [line setBackgroundColor:[UIColor clearColor]];
    [self.sohu_share_View addSubview:line];
    
    sohu_rect = CGRectMake(0, 0, w, CGRectGetMaxY(line.frame)+clip_image_y);
    
//    CGFloat o = [[SNDevice sharedInstance] isPlus]?(60/405.0):(80/405.0);
//    if ([[SNDevice sharedInstance] isPhone6]) {
//        o = (70/405.0);
//    }
    
    CGFloat t_h = h-CGRectGetMaxY(line.frame);
    CGFloat qr_w = t_h * (80/150.0);
    CGFloat qr_bg_h = (h-CGRectGetMaxY(line.frame)-qr_w)/2.0+ CGRectGetMaxY(line.frame);
    
    //二维码view
    UIView* qr_bg_View = [[UIView alloc] initWithFrame:CGRectMake(0, qr_bg_h, w, qr_w)];
    [qr_bg_View setBackgroundColor:[UIColor clearColor        ]];
    [bg_view addSubview:qr_bg_View];
    
    qr_rect = CGRectMake(0, qr_bg_h, w, qr_w);
    self.qr_bgView = qr_bg_View;
    
    CGFloat qr_code_x = w * (23/405.0);
    UIImageView* qr_code = [[UIImageView alloc] initWithFrame:CGRectMake(qr_code_x, 0, qr_w, qr_w)];
    qr_code.userInteractionEnabled = NO;
    
    NSString* webUrl = SNNews_SHARE_ScreenShare_QRCode_Default_URL;
    if (isSHH5News == NO) {
        if (self.shareOnData) {
            NSString* url = [self.shareOnData objectForKey:@"webUrl"];
            if (url && url.length>0) {
                webUrl = url;
            }
        }
    }
    
    qr_code.image = [SNNewsScreenShare createQRcodeImage:webUrl];
    
    [qr_bg_View addSubview:qr_code];
    self.qr_code_imageView = qr_code;
    
    CGFloat logo_w = (12/80.0)*qr_w;
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iOS_114_normal.png"]];
    [logo setFrame:CGRectMake((qr_w-logo_w)/2.0, (qr_w-logo_w)/2.0, logo_w, logo_w)];
    [qr_code addSubview:logo];
    
    CGFloat wenan_h = (t_h * (28/150.0));
    CGFloat wenan_h_h = (17/80.0)* qr_w;
    
    CGFloat wenan_x = CGRectGetMaxX(qr_code.frame)+ w*(15/405.0);
    CGFloat wenan_y = (qr_w - wenan_h*2 - 16)/2.0;
    
    //标题高度 超过两行 维持两行 不够两行显示一行 wangshun
    NSString* str = [self.shareOnData objectForKey:@"title"];
    NSString* title = [NSString stringWithFormat:@"转自【%@】",str?:@""];
    CGFloat t = [[SNDevice sharedInstance] isPlus]?9:4;
    
//    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
//    style.paragraphSpacing = 0;
//    style.paragraphSpacingBefore = 0;
//    style.lineSpacing = 0;
    //style.lineBreakMode = NSLineBreakByTruncatingTail;
//    NSParagraphStyleAttributeName:style
    
    
    CGRect rect = [title boundingRectWithSize:CGSizeMake(w-wenan_x-qr_code_x, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:(wenan_h*(2/3.0))]} context:nil];
    
    if(rect.size.height>wenan_h){
       wenan_y = (qr_w - (wenan_h*2+wenan_h_h))/2.0;//间距不要了
    }

    UILabel* shh5news_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(wenan_x, wenan_y, w-wenan_x-qr_code_x, wenan_h)];
    if(rect.size.height>wenan_h){
        [shh5news_titleLabel setFrame:CGRectMake(wenan_x, 0, w-wenan_x-qr_code_x, (wenan_h)*2)];
    }
    
//    NSMutableAttributedString* mstr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:(wenan_h*(2/3.0))/1],NSParagraphStyleAttributeName:style}];

//    [shh5news_titleLabel setAttributedText:mstr];
    [shh5news_titleLabel setText:title];
    shh5news_titleLabel.numberOfLines = 0;
    
    shh5news_titleLabel.font = [UIFont systemFontOfSize:wenan_h*(2/3.0)];
    [qr_bg_View addSubview:shh5news_titleLabel];
    shh5news_titleLabel.textColor = SNUICOLOR(kThemeText10Color);
    [shh5news_titleLabel setBackgroundColor:[UIColor clearColor]];
    
    CGFloat a = 16;
    if (rect.size.height>wenan_h) {
        a = 0;
    }
    UILabel* wenan = [[UILabel alloc] initWithFrame:CGRectMake(wenan_x, CGRectGetMaxY(shh5news_titleLabel.frame)+a, w-wenan_x-qr_code_x, wenan_h_h)];
    [qr_bg_View addSubview:wenan];
    wenan.font = [UIFont systemFontOfSize:wenan_h_h-t];
    wenan.text = @"长按识别二维码 凑凑热闹";
    wenan.textColor = SNUICOLOR(kThemeText3Color);
    [wenan setBackgroundColor:[UIColor clearColor]];
    self.tips_share = wenan;
    
//    [bg_view setFrame:CGRectMake(0, 0, w, CGRectGetMaxY(line.frame)+(22/718.0)*h*2+qr_w)];//+上下边距(22/718.0)*h*2
//    bg_rect = CGRectMake(0, 0, w, CGRectGetMaxY(line.frame)+(22/718.0)*h*2+qr_w);
    
    bg_rect = bg_view.bounds;

    self.final_share_View = bg_view;
    
    CGFloat y_tmp = h * (7/718.0);
//    o = [[SNDevice sharedInstance] isPlus]?(22/405.0):(28/405.0);
//    if ([[SNDevice sharedInstance] isPhone6]) {
//        o = (24/405.0);
//    }

    
    CGFloat user_w = t_h * (28/150.0);
//    CGFloat user_y = (22/718.0)*h + CGRectGetMaxY(line.frame);
    CGFloat f_h = CGRectGetMaxY(line.frame);
    CGFloat user_y = (h-f_h-y_tmp-qr_w-user_w)/2.0 + CGRectGetMaxY(line.frame);
    CGFloat user_x = qr_code_x;
    
    UIView* userView = [[UIView alloc] initWithFrame:CGRectMake(0, user_y, w, user_w)];
    [userView setBackgroundColor:[UIColor clearColor]];
    [self.sohu_share_View addSubview:userView];
    self.head_bg_view = userView;
    userView.hidden = YES;
    
    UIImageView* head = [[UIImageView alloc] initWithImage:nil];
    [head setFrame:CGRectMake(user_x, 0, user_w, user_w)];
    [head setBackgroundColor:[UIColor clearColor]];
    [userView addSubview:head];
    head.layer.cornerRadius  = user_w/2.0;
    head.layer.masksToBounds = YES;
    self.head_imgView_share = head;
    
    CGFloat tmp_space = (4/348.0)*w;
    UILabel* nickName = [[UILabel alloc] initWithFrame:CGRectMake(user_x+user_w+tmp_space, 0, w-(user_x*2)-user_w, user_w)];
    [nickName setText:@""];
    [nickName setBackgroundColor:[UIColor clearColor]];
    [userView addSubview:nickName];
    nickName.font = [UIFont systemFontOfSize:user_w*(2/3.0)];
    self.nickNameLabel_share = nickName;
    
    wenan.font = [UIFont systemFontOfSize:user_w*(2/3.0)];

    qr_head_rect = CGRectMake(0, CGRectGetMaxY(userView.frame)+y_tmp, w, qr_w);
    bg_head_rect = CGRectMake(0, 0, w, h);
    
    sohu_head_rect = CGRectMake(0, 0, w, CGRectGetMaxY(userView.frame)+y_tmp);
    if (userView.hidden == NO) {
        qr_bg_View.frame = qr_head_rect;
    }
    
    [self performSelector:@selector(screenCat) withObject:nil afterDelay:2];
}

- (void)saveClipImage:(UIImage*)img{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/clipImg.png"];
    SNDebugLog(@"path::::::%@",path);
    NSData *imageData = UIImagePNGRepresentation(img);
    [imageData writeToFile:path atomically:YES];
}

- (void)screenCat{
    UIImage* img = [SNNewsScreenShare getImageFromView:self.sohu_share_View];
    [self saveClipImage:img];
}

- (void)createClipImageView{
    
    CGFloat y = CGRectGetMaxY(self.focalBtn.frame)+kAppScreenHeight*(20/1280.0);
    CGFloat h = kAppScreenHeight*(718/1280.0);
    NSLog(@"k:%f s:%f",kAppScreenHeight,self.view.bounds.size.height);
    
    CGFloat w = (405/718.0)*h;
    CGFloat x = (kAppScreenWidth-w)/2.0;
    
    if ([[SNDevice sharedInstance] isPhoneX]) {
        h = h+50;
    }
    
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bgView];
    
    UIImageView* clip_shh5web_imageView = [[UIImageView alloc] initWithImage:self.clip_img];
    CGFloat b = (self.clip_img.size.height/self.clip_img.size.width);
    
    CGFloat clip_shh5web_imageView_y = (22/718.0)*h;
    CGFloat clip_shh5web_imageView_x = (23/405.0)*w;
    CGFloat clip_shh5web_imageView_w = w-(clip_shh5web_imageView_x*2);
    CGFloat clip_shh5web_imageView_h = clip_shh5web_imageView_w*b;
    [clip_shh5web_imageView setFrame:CGRectMake(clip_shh5web_imageView_x, clip_shh5web_imageView_y, clip_shh5web_imageView_w, clip_shh5web_imageView_h)];
    [bgView addSubview:clip_shh5web_imageView];
    
    if (self.brush_img) {
        UIImageView* brush_imageView = [[UIImageView alloc] initWithImage:self.brush_img];
        [brush_imageView setFrame:clip_shh5web_imageView.bounds];
//        brush_imageView.center = clip_shh5web_imageView.center;
        [clip_shh5web_imageView addSubview:brush_imageView];
    }
    clip_shh5web_imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    clip_shh5web_imageView.layer.shadowOpacity = 0.3f;
    clip_shh5web_imageView.layer.shadowRadius = 1.0f;
    clip_shh5web_imageView.layer.shadowOffset = CGSizeMake(0,0);
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(clip_shh5web_imageView.frame)+1, w, 0.5)];
    [line setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:line];
    
    CGFloat f_h = CGRectGetMaxY(line.frame);
    
//    CGFloat o = [[SNDevice sharedInstance] isPlus]?(60/405.0):(80/405.0);
//    
//    if ([[SNDevice sharedInstance] isPhone6]) {
//        o = (70/405.0);
//    }
//    CGFloat qr_w = w * o;
    CGFloat t_h = h-CGRectGetMaxY(line.frame);
    CGFloat qr_w = t_h * (80/150.0);

    CGFloat qr_bg_h = (h-f_h-qr_w)/2.0;
    
    UIView* qr_bg_View = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame)+qr_bg_h, w, qr_w)];
    [qr_bg_View setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:qr_bg_View];
    
    qr_show_rect = qr_bg_View.frame;
    
    CGFloat qr_code_x = w * (23/405.0);
    UIImageView* qr_code = [[UIImageView alloc] initWithFrame:CGRectMake(qr_code_x, 0, qr_w, qr_w)];
    qr_code.userInteractionEnabled = NO;
    qr_code.image = [SNNewsScreenShare createQRcodeImage:SNNews_SHARE_ScreenShare_QRCode_Default_URL];
    [qr_bg_View addSubview:qr_code];
    
    CGFloat logo_w = 8;
    UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iOS_114_normal.png"]];
    [logo setFrame:CGRectMake((qr_w-logo_w)/2.0, (qr_w-logo_w)/2.0, logo_w, logo_w)];
    [qr_code addSubview:logo];
    
    CGFloat wenan_x = CGRectGetMaxX(qr_code.frame)+ w*(14/405.0);
    
    //标题高度 超过两行 维持两行 不够两行显示一行 wangshun
    NSString* str = [self.shareOnData objectForKey:@"title"];
    NSString* title = [NSString stringWithFormat:@"转自【%@】",str?:@""];
    CGRect rect = [title boundingRectWithSize:CGSizeMake(w-wenan_x-qr_code_x, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:7]} context:nil];
    CGFloat wenan_y = (qr_w - (12+10) - 3)/2.0;
    if(rect.size.height>10){
        wenan_y = (qr_w - (10+20) - 0)/2.0;//间距不要了
    }
    
    UILabel* shh5news_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(wenan_x, wenan_y, w-wenan_x-qr_code_x, 12)];
    if(rect.size.height>12){
        [shh5news_titleLabel setFrame:CGRectMake(wenan_x, wenan_y, w-wenan_x-qr_code_x, 20)];
    }
    //self.shareOnData
    [shh5news_titleLabel setText:title];
    shh5news_titleLabel.numberOfLines = 0;
    shh5news_titleLabel.font = [UIFont systemFontOfSize:7];
    [qr_bg_View addSubview:shh5news_titleLabel];
    shh5news_titleLabel.textColor = SNUICOLOR(kThemeText10Color);
    [shh5news_titleLabel setBackgroundColor:[UIColor clearColor]];
    
    CGFloat a = 3;
    if(rect.size.height>12){
        a= 0;
    }
    UILabel* wenan = [[UILabel alloc] initWithFrame:CGRectMake(wenan_x, CGRectGetMaxY(shh5news_titleLabel.frame)+a, w-wenan_x-qr_code_x, 10)];
    [qr_bg_View addSubview:wenan];
    wenan.font = [UIFont systemFontOfSize:6];
    wenan.text =@"长按识别二维码 凑凑热闹";
    wenan.textColor = SNUICOLOR(kThemeText3Color);
    [wenan setBackgroundColor:[UIColor clearColor]];
    self.tips_show = wenan;
    
    CGFloat y_tmp = h * (7/718.0);
//    o = [[SNDevice sharedInstance] isPlus]?(22/718.0):(28/718.0);
//    if ([[SNDevice sharedInstance] isPhone6]) {
//        o = (24/718.0);
//    }
//    CGFloat user_w = o*h;
    CGFloat user_w = t_h * (28/150.0);
    CGFloat user_y = (h-f_h-y_tmp-qr_w-user_w)/2.0 + CGRectGetMaxY(line.frame);
    CGFloat user_x = qr_code_x;
    
    UIView* userView = [[UIView alloc] initWithFrame:CGRectMake(0, user_y, w, user_w)];
    [userView setBackgroundColor:[UIColor clearColor]];
    [bgView addSubview:userView];
    userView.hidden = YES;
    
    UIImageView* head = [[UIImageView alloc] initWithImage:nil];
    [head setFrame:CGRectMake(user_x, 0, user_w, user_w)];
    [head setBackgroundColor:[UIColor clearColor]];
    [userView addSubview:head];
    head.layer.cornerRadius  = user_w/2.0;
    head.layer.masksToBounds = YES;
    self.head_imgView_show = head;
    
    UILabel* nickName = [[UILabel alloc] initWithFrame:CGRectMake(user_x+user_w+4, 0, w-(user_x*2)-user_w, user_w)];
    [nickName setText:@""];
    [nickName setBackgroundColor:[UIColor clearColor]];
    [userView addSubview:nickName];
    nickName.font = [UIFont systemFontOfSize:8];
    self.nickNameLabel_show = nickName;
    
    qr_head_show_rect = CGRectMake(0, CGRectGetMaxY(userView.frame)+y_tmp, w, qr_w);
    if (userView.hidden == NO) {
        qr_bg_View.frame = qr_head_show_rect;
    }
    
    self.qr_bgView_show = qr_bg_View;
    self.head_bg_view_show = userView;
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - showAlertView

// MARK: - 截屏分享 TODO:交给王舜
- (void)showScreenShotShareView {

    CGFloat cancel_height = self.view.bounds.size.height * (90/1280.0);
    CGFloat y = kAppScreenHeight-cancel_height;
    CGFloat iphoneX_H = 0;
    if ([[SNDevice sharedInstance] isPhoneX]) {
        cancel_height = 30;
        iphoneX_H = 15;
        y =  y + iphoneX_H;
    }

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, y, self.view.bounds.size.width, cancel_height)];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    
    [btn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* bottom_line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(btn.frame)-1, self.view.frame.size.width, 0.5)];
    [bottom_line setBackgroundColor:SNUICOLOR(kThemeBg1Color)];
    [self.view addSubview:bottom_line];
    
    CGFloat middle_height = (290/1280.0)*self.view.bounds.size.height;
    
    UIView* left_line = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight-cancel_height-middle_height+iphoneX_H, (self.view.frame.size.width-72)/2, 0.5)];
    [left_line setBackgroundColor:SNUICOLOR(kThemeBg1Color)];
    [self.view addSubview:left_line];
    
    UIView* right_line = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-72)/2+72, kAppScreenHeight-cancel_height-middle_height+iphoneX_H, (self.view.frame.size.width-72)/2, 0.5)];
    [right_line setBackgroundColor:SNUICOLOR(kThemeBg1Color)];
    [self.view addSubview:right_line];
    
    CGFloat fenxiang_width = (144/720.0)*kAppScreenWidth;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-fenxiang_width)/2, CGRectGetMinY(left_line.frame)-12, fenxiang_width, 21)];
    label.text = @"分享";
    label.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = SNUICOLOR(kThemeText1Color);
    
    [self.view addSubview:label];
    
    CGFloat weixin_area_height = (180/1280.0)*self.view.bounds.size.height;
    CGFloat checkbox_area_height = (110/1280.0)*self.view.bounds.size.height;
    
    self.itemsView = [[SNNewsScreenShareItemsView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight-checkbox_area_height-cancel_height-weixin_area_height+iphoneX_H, kAppScreenWidth, weixin_area_height) WithData:self.viewModel.shareIconsArr];
    self.itemsView.delegate = self;
    [self.itemsView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.itemsView];
    
    self.checkView = [[SNNewsScreenCheckBoxView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight-cancel_height-checkbox_area_height+iphoneX_H, kAppScreenWidth, checkbox_area_height)];
    [self.checkView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.checkView];
    self.checkView.delegate = self;
    self.weixinModel.isCheckBoxSelected = YES;//第一次YES 默认勾选 wangshun
    self.sharePic.selected = [NSString stringWithFormat:@"%d",self.weixinModel.isCheckBoxSelected];//默认勾选
    
    //因为checkview 把cancel btn 盖住了 所以放后面addsubview
    [self.view addSubview:btn];
    
    NSString* s = [self.sharePic isShowHeadFirst];
    if ([s isEqualToString:@"1"]) {//有头像有昵称才显示
        [self setHeadUrl:self.sharePic.headUrl Title:self.sharePic.nickName Completion:nil];
        [self showHead:YES];
    }
    else if ([s isEqualToString:@"2"]) {
        [self showHead:NO];
    }
    else{
        [self showHead:NO];
        [self.checkView setCheckBoxSelected:NO];
        self.weixinModel.isCheckBoxSelected = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - auth delegate

- (void)getAuthUserInfo:(id)sender{
    
    if (self.weixinModel.tips) {
        self.tips_show.text = self.weixinModel.tips;
        self.tips_share.text = self.weixinModel.tips;
        
        self.sharePic.weixin_openid = self.weixinModel.openID;
        
        if ([self.weixinModel.isWeiXinAuth isEqualToString:@"2"]) {
            //显示？问号
            [self.checkView setExpired:YES];//过期
        }
        else{
            [self.checkView setExpired:NO];
            
        }
    }
}

- (void)weixinShareCallBack:(id)sender{
    
    if ([self.weixinModel isShowWeixin]) {
        self.sharePic.headUrl  = self.weixinModel.weixin_headImage_Url;
        self.sharePic.nickName = self.weixinModel.weixin_nickName;
        
        __weak SNNewsScreenShareViewController* weakSelf = self;
        [self setHeadUrl:self.weixinModel.weixin_headImage_Url Title:self.weixinModel.weixin_nickName Completion:^(NSDictionary *info) {
 
            [weakSelf performSelector:@selector(shareLater:) withObject:sender];
        }];
        

        [self showHead:YES];
    }
}

- (void)sohuShareCallBack:(id)sender{
    if ([self.weixinModel isShowSohu]) {
        self.sharePic.headUrl = self.weixinModel.huyou_headImage_Url;
        self.sharePic.nickName = self.weixinModel.huyou_nickName;
        
        __weak SNNewsScreenShareViewController* weakSelf = self;
        [self setHeadUrl:self.weixinModel.huyou_headImage_Url Title:self.weixinModel.huyou_nickName Completion:^(NSDictionary *info) {
            [weakSelf performSelector:@selector(shareLater:) withObject:kShareTitleMySohu];
        }];
        
        [self showHead:YES];
    }
}

- (void)weixinAuthFailed{
    //去掉勾选
    [self.checkView setCheckBoxSelected:NO];
    self.weixinModel.isCheckBoxSelected = NO;
    self.sharePic.selected = @"";
}

////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNNewsScreenShareItemsViewDelegate

- (void)shareTo:(NSString *)title{
    [self share:title];
}

////////////////////////////////////////////////////////////////////////////////

- (void)setHeadUrl:(NSString*)headUrl Title:(NSString*)title Completion:(void (^)(NSDictionary*info)) method{
    
    NSURL* url = [NSURL URLWithString:headUrl];
    [self.head_imgView_show sd_setImageWithURL:url placeholderImage:nil];
    NSString* name = title?:@"";
    if (name.length>10) {
        name = [[name substringToIndex:6] stringByAppendingString:@".."];
    }
    
    if (name && name.length>0) {
        name = [NSString stringWithFormat:@"%@ 的划重点",name];
    }
    
    [self.nickNameLabel_show setText:name];
    [self.head_imgView_share sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (method) {
            method(nil);
        }
    }];
    [self.nickNameLabel_share setText:name];
}

- (void)cancelClick:(UIButton*)b{
    [self.sharePic finishedShareClose:nil];
}

-(void)changeQRImage:(UIImage *)qrImg{
    if (!_weixinModel.link2) {
        self.qr_code_imageView.image = qrImg;
        self.final_qr_code_imageView.image = self.qr_code_imageView.image;
    }
}

//

-(void)updateLink2:(UIImage *)link2_img Background:(NSString *)back_imgUrl{
    if (link2_img) {
        self.qr_code_imageView.image = link2_img;
        self.final_qr_code_imageView.image = self.qr_code_imageView.image;
    }
}

-(void)removedSelf{
    if(self.delgate && [self.delgate respondsToSelector:@selector(removedSelf)]){
        [self.delgate removedSelf]; 
    }
}

#pragma mark -  share 分享图片
//能分享 去分享 不能分享授权后自动分享 (逻辑在isCanShare)
- (void)share:(NSString*)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.weixinModel isCanShare:sender];
    });
}

// 等待头像下载完 立即分享
- (void)shareLater:(NSString*)sender{
    UIView* view = self.final_share_View;
    if ([sender isEqualToString:kShareTitleMySohu] || [sender isEqualToString:SNNewsShare_Icons_Sohu]) {
        view = self.sohu_share_View;
    }
    
    [self.sharePic callShare:self.shareOnData Title:sender WithFinalView:view];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSelf{
    [self cancelClick:nil];
}

- (BOOL)panGestureEnable{
    return NO;
}

#pragma mark - 分享

//第一期需求 二期以后用不上了
//- (void)enterDrawBoardView:(UIButton*)b{
//    if (self.drawBoardViewController) {
//        [self addChildViewController:self.drawBoardViewController];
//        [self.view addSubview:self.drawBoardViewController.view];
//        [self.drawBoardViewController reEnterSelf];
//        
//        return;
//    }
//    
//    self.drawBoardViewController = [[SNNewsShareDrawBoardViewController alloc] initWithEditorImage:self.base_img];
//    [self addChildViewController:self.drawBoardViewController];
//    self.drawBoardViewController.delegate = self;
//    [self.drawBoardViewController.view setFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:self.drawBoardViewController.view];
//    
//    [SNNewsReport reportADotGif:@"_act=highlight&_tp=clk&newsId=&channelid="];
//}

//#pragma mark - 分享
//
//- (void)share:(NSString*)sender{
//    
//    //    [self writPic];
//    //
//    //    NSMutableDictionary* mDic = nil;
//    //    if (isSHH5News == YES && self.shareOnData) {
//    //        mDic = self.shareOnData;
//    //    }
//    //    else{
//    //        mDic = [self createScreenShareData:sender];
//    //    }
//    //
//    //    [self callShare:mDic Title:sender];
//}
//#pragma mark - SNNewsShareDrawBoardVCDelegate
////再次切图
//- (UIImage*)getClipImage:(UIImage *)img{
//    
//    if (img) {
//        if (self.delgate && [self.delgate respondsToSelector:@selector(getClipImage:)]) {
//            UIImage* f_img = [self.delgate getClipImage:img];
//            if (f_img) {
//                self.clip_img = f_img;
//                
//                self.final_clip_imageView.image = self.clip_img;
//                self.clip_imageView.image = self.clip_img;
//                return f_img;
//            }
//        }
//    }
//    
//    return nil;
//}


//- (void)finishedShareClose:(id)sender{
//    if (self.flipboardNavigationController.viewControllers) {
//        if (self.flipboardNavigationController.viewControllers.count>=3) {
//            NSInteger n = self.flipboardNavigationController.viewControllers.count-3;
//            if (n>=0) {
//
//                NSInteger m = n-1;
//
//                SNNewsShareDrawBoardViewController* dvc = [self.flipboardNavigationController.viewControllers objectAtIndex:m];
//                if (dvc) {
//                    [dvc clean];//清除tmp 中图片
//                }
//
//                SNBaseViewController* vc = [self.flipboardNavigationController.viewControllers objectAtIndex:n];
//                [self.flipboardNavigationController popToViewController:vc animated:YES];
//            }
//        }
//    }
//}

//- (NSMutableDictionary*)createScreenShareData:(NSString*)title{
//    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
//    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/screenshare.png"];
//    
//    [mDic setObject:@"搜狐新闻" forKey:kShareInfoKeyTitle];
//    [mDic setObject:path forKey:kShareInfoKeyImagePath];
//    [mDic setObject:@"" forKey:kShareInfoKeyContent];
//    [mDic setObject:SNNews_SHARE_ScreenShare_QRCode_Default_URL forKey:SNNewsShare_Url];
//    if (title && [title isEqualToString:kShareTitleMySohu]) {
//        [mDic setObject:@"3" forKey:@"type"];
//        [mDic setObject:@"" forKey:@"url"];
//    }
//    
//    return mDic;
//}

//- (void)callShare:(NSMutableDictionary*)dic Title:(NSString*)title{
//    if (self.shareManager != nil) {
//        self.shareManager = nil;
//    }
//    
//    self.shareManager = [[SNNewsShareManager alloc] init];
//    self.shareManager.delegate = self;
//    [self.shareManager shareIconSelected:title ShareData:dic];
//    
//    if (isSHH5News == NO) {//关闭
//        [self finishedShareClose:nil];
//    }
//}



//#pragma mark - shareOnUrl
//
//- (void)shareOnFinished:(SNSharePlatformBase *)platform{
//    //如果是正文页重新生成二维码
//    if (isSHH5News == YES) {
//        NSString* webUrl = [platform.shareData objectForKey:@"webUrl"];
//        NSString* title = nil;
//        if (platform.optionPlatform == SNActionMenuOptionMySOHU) {
//            title = kShareTitleMySohu;
//        }
//        NSMutableDictionary* mDic = [self createScreenShareData:title];
//        if (platform.optionPlatform != SNActionMenuOptionMySOHU) {
//            [mDic setObject:webUrl?:@"" forKey:SNNewsShare_Url];
//        }
//        
//        if (platform.optionPlatform == SNActionMenuOptionOAuths){
//            [platform.shareData setObject:webUrl?:@"" forKey:SNNewsShare_Url];
//            
//            NSString* path = [mDic objectForKey:kShareInfoKeyImagePath];
//            [platform.shareData setObject:path?:@"" forKey:kShareInfoKeyImagePath];
//        }
//        else{
//            platform.shareData = mDic;
//        }
//
//        if (webUrl) {
//            self.qr_code_imageView.image = [SNNewsScreenShare createQRcodeImage:webUrl];
//            self.final_qr_code_imageView.image = self.qr_code_imageView.image;
//        }
//
//        //把数据源改为图片数据 (需要用正文页数据访问shareon)
//
//        [self writPic];
//        
//        [self finishedShareClose:nil];
//    }
//}

//#pragma mark - writ to path 图片
//
//
//- (void)writPic{
//    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/screenshare.png"];
//    UIImage* share_image = [SNNewsScreenShare getImageFromView:self.final_share_View];
//    NSData* imageData = UIImagePNGRepresentation(share_image);
//    [imageData writeToFile:path atomically:YES];
//    SNDebugLog(@"%@",path);
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
