 //
//  SNStatementViewController.m
//  sohunews
//
//  Created by guoyalun on 1/29/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNStatementViewController.h"
#import "UIColor+ColorUtils.h"
#import "NSMutableAttributedString+Size.h"
#import "SNStatementButton.h"

static NSString *const telTo = @"010-62728508";
static NSString *const mailTo = @"jieding@sohu-inc.com";

@implementation SNStatementViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+kSystemBarHeight, self.view.width, self.view.height - 44 - 40)];
    mainView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [self.view addSubview:mainView];

//    NSString *content = @"搜狐新闻客户端提供的文字、图片、视频、音频等信息内容，均来自第三方媒体，不代表搜狐公司观点。搜狐公司对于任何人经由搜狐新闻客户端所获得的任何信息，不声明或保证其正确性或可靠性。\n搜狐公司尊重国家法律法规和权利人的合法权益。任何单位或个人如认为搜狐新闻客户端中相关信息内容可能侵犯了其合法权益，可以通过书面方式向搜狐公司反馈，请提供身份证明、权属证明、涉嫌侵权内容的位置及详细侵权情况证明，并将前述材料寄至搜狐公司，地址：北京市海淀区王庄路1号院清华同方科技广场D座8层（100084），电话：18811145747、010-61134554。搜狐公司在收到前述通知书后，可依其合理判断，决定是否删除该等内容。";
    NSString *content = @"搜狐公司尊重国家法律法规和权利人的合法权益。任何单位或个人如认为搜狐新闻客户端中相关信息内容可能侵犯了其合法权益，可以通过书面方式向搜狐公司反馈，请提供身份证明、权属证明、涉嫌侵权内容的位置及详细侵权情况证明，并将前述材料寄至搜狐公司，地址：北京市海淀区王庄路1号院清华同方科技广场D座8层 （100084）,电话:18811145747、010-62728508 。搜狐公司在收到前述通知书后，可依其合理判断，决定是否删除该等内容。\n欢迎各类媒体入驻合作";
    UIFont *textFont = [UIFont systemFontOfSize:17];
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:content];
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)textFont.fontName,textFont.pointSize,NULL);
    [string addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0,[string length])];

    [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)([UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kStatementContentTextColor]].CGColor) range:NSMakeRange(0,[string length])];
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    //设置文本行间距
    CGFloat lineSpace = 6.0f;
    //设置文本段间距
    CGFloat paragraphSpacing = 8.0;
//    CGFloat  _firstLineHeadIndent = 17*2;//首段两个字体的空白
    CGFloat lineHeight = textFont.lineHeight;
    CFIndex theNumberOfSettings = 8;
    
    CTParagraphStyleSetting theSettings[8] =
    {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpace },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpace },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpace },
//        { kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&_firstLineHeadIndent},
        { kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paragraphSpacing},
        { kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(CGFloat),&lineHeight},
        { kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(CGFloat),&lineHeight}
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
    [string addAttribute:(NSString *)kCTParagraphStyleAttributeName
                              value:(id)paragraphStyle
                              range:NSMakeRange(0, string.length)];
    
    CFRelease(font);
    CFRelease(paragraphStyle);
    
    
    CGFloat content_width = mainView.bounds.size.width-20;
    
    CGFloat height = [string getHeightWithWidth:content_width maxHeight:2000];
    
    contentLabel = [[SNStatementView alloc] initWithFrame:CGRectMake(10, 20, content_width,height)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.statment = string;
    [mainView addSubview:contentLabel];

    
    UIImageView *sepView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sep_line.png"]];
    sepView.frame = CGRectMake(10, CGRectGetMaxY(contentLabel.frame) +20, content_width, 1);
    [mainView addSubview:sepView];
    
    CGFloat split = content_width-300;
    
    SNStatementButton *btn1 = [[SNStatementButton alloc] init];
    btn1.top = CGRectGetMaxY(contentLabel.frame) + 31;
    [btn1 setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
    [btn1 setTitle:telTo forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    btn1.imageEdgeInsets = UIEdgeInsetsMake(0, -146-split, 0, 0);
    btn1.titleEdgeInsets = UIEdgeInsetsMake(0, -124-split,0, 0);
    [mainView addSubview:btn1];
    
    split = split+10;//为什么要加10
    
    SNStatementButton *btn2 = [[SNStatementButton alloc] init];
    btn2.top = CGRectGetMaxY(btn1.frame) + 10;
    [btn2 setImage:[UIImage imageNamed:@"mail.png"] forState:UIControlStateNormal];
    [btn2 setTitle:mailTo forState:UIControlStateNormal];
    btn2.imageEdgeInsets = UIEdgeInsetsMake(0, -85-split, 0, 0);
    btn2.titleEdgeInsets = UIEdgeInsetsMake(0, -60-split, 0, 0);
    [btn2 addTarget:self action:@selector(mailAction:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btn2];
    
    
    [self addHeaderView];
    [self addToolbar];
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Statement",@"")]];
    
                                                              
    mainView.contentSize = CGSizeMake(self.view.width, contentLabel.height + 150);
    
}

- (void)callAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", telTo]]];
}

- (void)mailAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", mailTo]]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
     //(mainView);
     //(contentLabel);
}

- (void)dealloc
{
     //(mainView);
     //(contentLabel);
}

@end
