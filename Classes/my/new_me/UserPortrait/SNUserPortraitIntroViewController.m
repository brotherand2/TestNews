//
//  SNUserPortraitIntroViewController.m
//  sohunews
//
//  Created by iOS_D on 2016/12/21.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNUserPortraitIntroViewController.h"

@interface SNUserPortraitIntroViewController ()

@property (nonatomic,strong) UILabel* mainTitleLabel;
@property (nonatomic,strong) UILabel* subTitleLabel;

@property (nonatomic,strong) UILabel* bottomLabel;

@property (nonatomic,strong) UIButton* enterBtn;

@property (nonatomic,assign) NSInteger maxNum;

@end

@implementation SNUserPortraitIntroViewController

-(id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query{
    if (self = [super initWithNavigatorURL:URL query:query]) {
        NSNumber* num = [query objectForKey:@"maxNum"];
        if (num.integerValue>0) {
            self.maxNum = num.integerValue;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configViews];
    
    _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_enterBtn setTitle:@"立即进入" forState:UIControlStateNormal];
    [_enterBtn setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    _enterBtn.layer.cornerRadius = 3;
    _enterBtn.layer.borderWidth = 1;
    _enterBtn.layer.borderColor = SNUICOLOR(kThemeRed1Color).CGColor;
    
    CGFloat a = 277/750.0;
    CGFloat w = a*(self.view.bounds.size.width);
    CGFloat b = 76/277.0;
    CGFloat h = w*b;
    CGFloat y = 60*b;
    
    _enterBtn.frame = CGRectMake((self.view.bounds.size.width-w)/2, CGRectGetMaxY(_bottomLabel.frame)+y, w, h);
    [_enterBtn addTarget:self action:@selector(enterClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_enterBtn];
    
    [self addToolbar];
}

- (void)enterClick:(UIButton*)b{
//    SNDebugLog(@"立即进入");
//    NSString* urlString = KUserPortraitH5Url;
//    [SNUtility openProtocolUrl:urlString];
    
    NSString* urlString = SNLinks_Path_FaceH5;
    [SNUtility openProtocolUrl:urlString context:@{kUniversalWebViewType:[NSNumber numberWithInteger:UserPortraitWebViewType]}];
}

- (void)addToolbar
{
    _toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - kToolbarHeight, kAppScreenWidth, kToolbarHeight)];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [_toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:_toolbarView];
}

- (void)configViews{
    
    CGFloat b = (self.view.bounds.size.height/1280.0);
    
    _mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, 33)];
    _mainTitleLabel.textAlignment = NSTextAlignmentCenter;
    _mainTitleLabel.font = [UIFont boldSystemFontOfSize:30];
    _mainTitleLabel.text = @"读资讯 献爱心";
    _mainTitleLabel.textColor = SNUICOLOR(kThemeText1Color);
    [self.view addSubview:_mainTitleLabel];
    
//    NSString* str = @"阅读100篇资讯，可给山里的孩子送出一本书";
    NSInteger n = 100;
    if (self.maxNum>0) {
        n = self.maxNum;
    }
    NSString* str = [NSString stringWithFormat:@"阅读%d篇资讯，可给山里的孩子送出一本书",(int)n];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeD]} context:nil];
    CGFloat height = 21;
    if (rect.size.height>21) {
        height = 42;
    }
    
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(_mainTitleLabel.frame)+13, self.view.bounds.size.width-60, height)];
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.textAlignment = NSTextAlignmentLeft;
    _subTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _subTitleLabel.text = str;
    _subTitleLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self.view addSubview:_subTitleLabel];

    CGFloat h = b * 120;
    
    CGFloat b_width = self.view.bounds.size.width*((180+24+28)/720.0);
    
    CGFloat x = (self.view.bounds.size.width-(52+b_width+52))/2.0;
    
    UIImageView* imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_subTitleLabel.frame)+h, 52, 56)];
    [imageView1 setImage:[UIImage themeImageNamed:@"icofiction_zx_v5.png"]];
    [self.view addSubview:imageView1];
    
    NSString* number_str = [NSString stringWithFormat:@"%d篇资讯",n];
    
    CGRect number_str_rect = [number_str boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeC]} context:nil];
    CGFloat w = 52+10;
    if (number_str_rect.size.width>w) {
        w = number_str_rect.size.width;
    }
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView1.frame)-5-((w-52-10)/2), CGRectGetMaxY(imageView1.frame)+13, w, 21)];
    label.text = number_str;//@"100篇资讯";
    label.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    label.textColor = SNUICOLOR(kThemeText3Color);
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    CGFloat b_x = (28)*(self.view.bounds.size.width/720.0);
    CGFloat b_w =  180*(self.view.bounds.size.width/720.0);
    CGFloat b_y = (CGRectGetHeight(imageView1.frame)-6)/2;
    UIImageView* middle_line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView1.frame)+b_x, CGRectGetMinY(imageView1.frame)+b_y, b_w, 6)];
    middle_line.image = [UIImage themeImageNamed:@"icofiction_jt_v5.png"];
    [self.view addSubview:middle_line];
    
    UIImageView* imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView1.frame)+b_width, CGRectGetMinY(imageView1.frame), 52, 56)];
    [imageView2 setImage:[UIImage themeImageNamed:@"icofiction_1book_v5.png"]];
    [self.view addSubview:imageView2];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView2.frame)-5, CGRectGetMaxY(imageView1.frame)+13, 52+10, 21)];
    label.text = @"1本书";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    label.textColor = SNUICOLOR(kThemeText3Color);
    [self.view addSubview:label];
    
    NSString* bStr = @"我们会根据您的阅读偏好，为您捐赠不同种类的书籍哦!";
    rect = [bStr boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeD]} context:nil];
    height = 21;
    if (rect.size.height>21) {
        height = 42;
    }
    
    CGFloat y = b * 100;
    _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_subTitleLabel.frame), CGRectGetMaxY(label.frame)+y, CGRectGetWidth(_subTitleLabel.frame), height)];
    _bottomLabel.textAlignment = NSTextAlignmentLeft;
    _bottomLabel.numberOfLines = 0;
    _bottomLabel.textColor = SNUICOLOR(kThemeText3Color);
    _bottomLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _bottomLabel.text = bStr;
    [self.view addSubview:_bottomLabel];
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
