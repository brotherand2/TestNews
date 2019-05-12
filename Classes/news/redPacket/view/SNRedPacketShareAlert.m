//
//  SNRedPacketShareAlert.m
//  sohunews
//
//  Created by Valar__Morghulis on 2017/4/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRedPacketShareAlert.h"
#import "SNNewAlertView.h"
#import "SNRedPacketManager.h"
#import "SNNewsShareManager.h"
#import "SNUserManager.h"

#define kDefaultAlertW 300.0f
#define kDefaultAlertH 180.0f

@interface SNRedPacketShareAlert ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) SNNewAlertView *alertView;
@property (nonatomic, strong) UIColor *alipayBtnColor;             // 副标题颜色
@property (nonatomic, assign) BOOL alipayBtnEnabled;               // 副标题是否可点击
@property (nonatomic, copy  ) NSString *shareTitle;                // 分享到各平台的标题
@property (nonatomic, strong) NSMutableArray *shareBtns;           // 可分享到的平台数组
@property (nonatomic, assign) CGFloat alertW;                      // 弹窗的宽
@property (nonatomic, assign) CGFloat alertH;                      // 弹窗的高
@property (nonatomic, strong) SNNewsShareManager *newsShareManager;
@property (nonatomic, strong) NSMutableDictionary *shareParams;    // 分享需要传入的参数
@end

@implementation SNRedPacketShareAlert

- (instancetype)init
{
    self = [super init];
    if (self) { // 初始化部分默认数据
        self.shareParams = [NSMutableDictionary dictionary];
        self.alertW = kDefaultAlertW;
        self.alertH = kDefaultAlertH;
        self.alertView = [[SNNewAlertView alloc] initWithContentView:self.bgView cancelButtonTitle:@"关闭" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleAlert];
    }
    return self;
}

- (void)showArticleRedPacketShareAlert {
    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
    [self.shareParams setObject:@"redPackPage" forKey:@"contentType"];
    [self.shareParams setObject:item.nid?item.nid:@"" forKey:@"nid"];
    [self.shareParams setObject:item.moneyValue?item.moneyValue:@"" forKey:@"redAmount"];
    NSString *title = [NSString stringWithFormat:@"%@元已存入您的零钱", item.moneyValue];
    self.alipayBtnColor = SNUICOLOR(kThemeBlue2Color);
    self.alipayBtnEnabled = YES;
    self.shareTitle = @"邀请好友一起抢红包";
    [self setTitle:title setAlipayName:@"前往查看零钱"];
    [self.alertView show];
}

- (void)showRedPacketShareAlertWithTitle:(NSString *)title
                              alipayName:(NSString *)alipayName
                         withRedPacketId:(NSString *)redPacketId {
    
    [self.shareParams setObject:@"pack" forKey:@"contentType"];
    NSString *redPacket = [NSString stringWithFormat:@"packId=%@&step=3&p1=%@", redPacketId, [SNUserManager getP1]];
    [self.shareParams setObject:[redPacket URLEncodedString] forKey:@"redPacket"];
    
    SNAppConfigFloatingLayer *floatingLayer = [SNAppConfigManager sharedInstance].floatingLayer;
    if (floatingLayer.H5Url.length > 0) {
        [self.shareParams setObject:floatingLayer.H5Url?:@"" forKey:SNNewsShare_webUrl];
    }
    
    if (redPacketId) {
        [self.shareParams setObject:redPacketId forKey:kRedPacketIDKey];
    }
    
    SNRedPacketItem *item = [SNRedPacketManager sharedInstance].redPacketItem;
    NSString *shareType = nil;
    if (item.redPacketType == 1) {//1普通红包，2任务红包
        shareType = @"pthongbao";
    }
    else if (item.redPacketType == 2) {
        shareType = @"rwhongbao";
    }
    else {
        shareType = @"protocal";
    }
    [self.shareParams setObject:shareType forKey:SNNewsShare_LOG_type];
    [self.shareParams setObject:@"copyLink" forKey:SNNewsShare_disableIcons];

    self.alipayBtnColor = SNUICOLOR(kThemeText4Color);
    self.alipayBtnEnabled = NO;
    [self setTitle:title setAlipayName:alipayName];
    [self.alertView show];
}


- (void)setTitle:(NSString *)title setAlipayName:(NSString *)alipayName {
    CGFloat offsetY = 0.0f;
    
    // titleLable
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(14, 21, _alertW - 28, 20)];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = title;
    titleLable.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    titleLable.textColor = SNUICOLOR(kThemeText1Color);
    [self.bgView addSubview:titleLable];
    offsetY += titleLable.origin.y + titleLable.height + 5;
    
    // alipayButton
    UIButton *alipayButton = [[UIButton alloc] initWithFrame:CGRectMake(14, offsetY, _alertW - 28, 15)];
    alipayButton.adjustsImageWhenHighlighted = NO;
    alipayButton.enabled = self.alipayBtnEnabled;
    [alipayButton setTitle:alipayName forState:UIControlStateNormal];
    [alipayButton addTarget:self action:@selector(fetchBalance) forControlEvents:UIControlEventTouchUpInside];//查看余额
    [alipayButton setTitleColor:self.alipayBtnColor forState:UIControlStateNormal];
    alipayButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    [self.bgView addSubview:alipayButton];
    
    offsetY = alipayButton.bottom + 19;
    
    // shareLable
    UILabel *shareLable = [[UILabel alloc] init];
    shareLable.backgroundColor = [UIColor clearColor];
    shareLable.textAlignment = NSTextAlignmentCenter;
    shareLable.text = self.shareTitle.length > 0 ? self.shareTitle : @"好运要跟大家一起分享";
    shareLable.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    shareLable.textColor = SNUICOLOR(kThemeText1Color);
    CGSize shareLableSize = [shareLable.text boundingRectWithSize:CGSizeMake(_alertW - 40, 16)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{
                                                                    NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeB]
                                                                    }
                                                          context:nil].size;
    shareLable.frame = CGRectMake((_alertW - shareLableSize.width)/2, offsetY, shareLableSize.width, 16);
    [self.bgView addSubview:shareLable];
    
    // leftLine
    CGFloat lineHeight = [SNDevice sharedInstance].isPlus ? (3.0/3) : (1.0/2);
    UIImage *image = [UIImage imageNamed:@"icofloat_xian_v5.png"];
    UIImageView *leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, offsetY + 8, (_alertW - shareLableSize.width - 20)/2 , lineHeight)];
    leftLine.image = image;
    [self.bgView addSubview:leftLine];
    
    // rightLine
    UIImageView *rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(_alertW - leftLine.width, offsetY + 8, leftLine.width , lineHeight)];
    rightLine.image = image;
    [self.bgView addSubview:rightLine];
    
    // shareBtn
    [self createShareButton:leftLine.bottom];
}

- (void)createShareButton:(CGFloat)yValue {
    NSInteger count = self.shareBtns.count;
    for (int i = 0; i < count; i++) {
        NSDictionary *dict = self.shareBtns[i];
        NSString *title = dict.allKeys[0];
        NSString *iconImageName = dict.allValues[0];
        UIImage *icon = [UIImage imageNamed:iconImageName];
        int width = (_alertW - 25*2)/count;
        int xValue = i*width + 25;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(xValue, yValue, width, 83)];
        button.adjustsImageWhenHighlighted = NO;
        button.backgroundColor = [UIColor clearColor];
        [button setImage:icon forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        CGSize size = button.frame.size;
        CGFloat imgViewEdgeInsetLeft = (size.width - icon.size.width)/2;
        CGFloat imgViewEdgeInsetTop = button.imageView.top - 30;
        CGFloat titleLabelEdgeInsetLeft = size.width/2.0f-button.titleLabel.center.x - icon.size.width / 2 + 10;
        CGFloat titleLabelEdgeInsetTop  = imgViewEdgeInsetTop + icon.size.height + 12;
        UIEdgeInsets imgViewEdgeInsets = UIEdgeInsetsMake(-5, imgViewEdgeInsetLeft, 0, 0);
        UIEdgeInsets titleLabelEdgeInsets = UIEdgeInsetsMake(titleLabelEdgeInsetTop+5, titleLabelEdgeInsetLeft, 0, 0);
        [button setImageEdgeInsets:imgViewEdgeInsets];
        [button setTitleEdgeInsets:titleLabelEdgeInsets];
        [button addTarget: self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        
        [self.bgView addSubview:button];
    }
}

- (void)doShare:(UIButton *)sender {
    [self.alertView dismiss];
    NSString *shareString = nil;
    switch (sender.tag) {
        case 0:
            //微信好友
            shareString = kShareTitleWechatSession;
            break;
        case 1:
            //朋友圈
            shareString = kShareTitleWechat;
            break;
        case 2:
            //微博
            shareString = kShareTitleSina;
            break;
        case 3:
            //QQ
            shareString = kShareTitleQQ;
            break;
        default:
            break;
    }

    self.newsShareManager = [[SNNewsShareManager alloc] init];
    [self.newsShareManager shareIconSelected:shareString ShareData:self.shareParams];
}

- (void)fetchBalance {
    [self.alertView dismiss];
    [SNRedPacketManager showRedPacketActivityInfo];
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _alertW, _alertH)];
        _bgView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    }
    return _bgView;
}

- (NSMutableArray *)shareBtns {
    if (_shareBtns == nil) {
        _shareBtns = [NSMutableArray arrayWithCapacity:4];
        [_shareBtns addObject:@{@"微信好友":@"icotcshare_wx_v5.png"}];
        [_shareBtns addObject:@{@"朋友圈":@"icotcshare_pyq_v5.png"}];
        [_shareBtns addObject:@{@"微博":@"icotcshare_wb_v5.png"}];
        [_shareBtns addObject:@{@"QQ":@"icotcshare_qq_v5.png"}];
    }
    return _shareBtns;
}


@end
