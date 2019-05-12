//
//  SNRollingRedPacketCell.m
//  sohunews
//
//  Created by wangyy on 16/3/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingRedPacketCell.h"
#import "UIFont+Theme.h"
#import "SNRedPacketManager.h"

@interface SNRollingRedPacketCell ()

@property (nonatomic, strong) SNCellImageView *bgPic;
@property (nonatomic, strong) SNCellImageView *sponsoredIcon;
@property (nonatomic, strong) UILabel *redPacketTitle;
@property (nonatomic, strong) UILabel *redPacketDes;
@property (nonatomic, strong) UIButton *redPacketDetail;
@property (nonatomic, strong) UIImageView * littleRedPacketImg;

@end

@implementation SNRollingRedPacketCell

@synthesize bgPic = _bgPic;
@synthesize sponsoredIcon = _sponsoredIcon;
@synthesize redPacketTitle = _redPacketTitle;
@synthesize redPacketDes = _redPacketDes;
@synthesize redPacketDetail = _redPacketDetail;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return newsItem.cellHeight;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    [super calculateCellHeight:item];
    UIImage *image = [UIImage themeImageNamed:@"icohome_quanpic_v5.png"];
    CGFloat cellHeight = HEIGHT_VALUE;
    cellHeight += image.size.height;
    item.cellHeight = cellHeight;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    //红包频道默认传NO
    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style
                reuseIdentifier:identifier];
    if (self) {
        [self initBgPic];
        [self initSponsoredIcon];
        [self initRedPacketTitle];
        [self initRedPacketDes];
        [self initRedPacketDetail];
    }
    return self;
}

- (void)initBgPic {
    UIImage *img = [UIImage themeImageNamed:@"icohome_quanpic_v5.png"];
    self.bgPic = [[SNCellImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP, kAppScreenWidth - 2 * CONTENT_LEFT, img.size.height)];
    [self.bgPic setDefaultImage:img];
    [self addSubview:self.bgPic];
}

- (void)initSponsoredIcon {
    UIImage *img = [UIImage themeImageNamed:@"icohongbao_placeholder_v5.png"];
    CGFloat yValue = (self.bgPic.height - img.size.height)/2;
    self.sponsoredIcon = [[SNCellImageView alloc] initWithFrame:CGRectMake(25, yValue, img.size.width, img.size.height)];
    [self.sponsoredIcon setDefaultImage:img];
    [self.bgPic addSubview:self.sponsoredIcon];
    
    img = [UIImage themeImageNamed:@"icohome_smallhb_v5.png"];
    self.littleRedPacketImg = [[UIImageView alloc] initWithFrame:CGRectMake(19, 47, img.size.width, img.size.height)];
    [self.littleRedPacketImg setImage:img];
    [self.bgPic addSubview:self.littleRedPacketImg];
}

- (void)initRedPacketTitle {
    CGFloat yValue = (self.bgPic.height - 20 - 6 - 15) / 2;
    CGFloat xValue = self.sponsoredIcon.right + 12;
    self.redPacketTitle = [[UILabel alloc] initWithFrame:CGRectMake(xValue, yValue - 2, self.bgPic.width - xValue - CONTENT_LEFT, 25)];
    self.redPacketTitle.backgroundColor = [UIColor clearColor];
    self.redPacketTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
    self.redPacketTitle.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
    [self.bgPic addSubview:self.redPacketTitle];
}

- (void)initRedPacketDes {
    self.redPacketDes = [[UILabel alloc] initWithFrame:CGRectMake(self.redPacketTitle.left, self.redPacketTitle.bottom + 4, self.redPacketTitle.width - 60, 15)];
    self.redPacketDes.backgroundColor = [UIColor clearColor];
    self.redPacketDes.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
    self.redPacketDes.font = [UIFont systemFontOfSizeType:UIFontSizeTypeC];
    [self.bgPic addSubview:self.redPacketDes];
}

- (void)initRedPacketDetail{
    self.redPacketDetail = [[UIButton alloc] initWithFrame:CGRectMake(self.bgPic.right - 90, self.redPacketDes.top, 65, 15)];
    self.redPacketDetail.backgroundColor = [UIColor clearColor];
    [self.redPacketDetail setTitle:@"了解详情" forState:UIControlStateNormal];
    [self.redPacketDetail setTitle:@"了解详情" forState:UIControlStateHighlighted];
    [self.redPacketDetail setImage:[UIImage themeImageNamed:@"icohome_arrow_v5.png"] forState:UIControlStateNormal];
    [self.redPacketDetail setImage:[UIImage themeImageNamed:@"icohome_arrow_v5.png"] forState:UIControlStateHighlighted];
    [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateNormal];
    [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateHighlighted];
    self.redPacketDetail.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    if ([UIScreen mainScreen].bounds.size.width > 750/2.f) {
        [self.redPacketDetail setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        [self.redPacketDetail setImageEdgeInsets:UIEdgeInsetsMake(0, self.redPacketDetail.titleLabel.right + 22, 0, 0)];
    } else {
        [self.redPacketDetail setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        [self.redPacketDetail setImageEdgeInsets:UIEdgeInsetsMake(0, self.redPacketDetail.titleLabel.right + 18, 0, 0)];
    }
    
    [self.bgPic addSubview:self.redPacketDetail];
}

- (void)gotoRedPacketDetail {
    [SNRedPacketManager sharedInstance].isInArticleShowRedPacket = NO;
    [SNRedPacketManager showRedPacketActivityInfo:self.item.news.redPacketId  isRedPacket:[self.item.news isRedPacketNews]];
}

- (void)openNews{
    if (self.item.cellType == SNRollingNewsCellTypeCoupons) {
        if (self.item.news.link.length > 0) {
            [SNUtility openProtocolUrl:self.item.news.link context:@{kUniversalWebViewType:[NSNumber numberWithInteger:MyTicketsListWebViewType]}];
        }
    } else {
        [self gotoRedPacketDetail];
    }
}

- (void)updateTheme{
    [super updateTheme];
    if (self.item.cellType == SNRollingNewsCellTypeCoupons) {
        [self.bgPic updateTheme];
        [self.bgPic updateDefaultImage:[UIImage themeImageNamed:@"icohome_quanpic_v5.png"]];
        [self.sponsoredIcon updateTheme];
        self.redPacketTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
        self.redPacketDes.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
        [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateNormal];
        [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateHighlighted];
    } else {
        [self.bgPic updateTheme];
        [self.bgPic updateDefaultImage:[UIImage themeImageNamed:@"icohome_quanpic_v5.png"]];
        [self.sponsoredIcon updateTheme];
        [self.sponsoredIcon updateDefaultImage:[UIImage themeImageNamed:@"icohongbao_placeholder_v5.png"]];
        self.redPacketTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
        [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateNormal];
        [self.redPacketDetail setTitleColor:SNUICOLOR(kThemeText6Color) forState:UIControlStateHighlighted];
        
        self.redPacketDes.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
    }
}

- (void)updateNewsContent {
    [super updateNewsContent];
    
    if (self.item.cellType == SNRollingNewsCellTypeCoupons) {
        //优惠券
        self.littleRedPacketImg.hidden = YES;
        [self.bgPic setDefaultImage:[UIImage themeImageNamed:@"icohome_quanpic_v5.png"]];
        [self.sponsoredIcon setFrame:CGRectMake(34/2.f,(self.bgPic.height - 44 ) / 2, 44, 44)];
        self.redPacketTitle.left = self.sponsoredIcon.right + 10;
        self.redPacketDes.left = self.sponsoredIcon.right + 10;
        self.redPacketDes.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
        self.redPacketDes.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        
        if ([UIScreen mainScreen].bounds.size.width > 750 / 2.f) {
            self.redPacketDetail.frame = CGRectMake(self.bgPic.right - 90, self.redPacketDes.top, 65, 15);
        } else {
            self.redPacketDetail.frame = CGRectMake(self.bgPic.right - 85, self.redPacketDes.top, 65, 15);
        }
        
        self.redPacketDetail.centerY = self.bgPic.height / 2.f;
        [self.redPacketDetail setTitle:@"立即领取" forState:UIControlStateNormal];
        [self.redPacketDetail setTitle:@"立即领取" forState:UIControlStateHighlighted];
        self.redPacketDetail.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeC];
        [self.redPacketDetail addTarget:self action:@selector(openNews) forControlEvents:UIControlEventTouchUpInside];
        
        self.redPacketTitle.text = self.item.news.redPacketTitle;
        self.redPacketDes.text = self.item.news.abstract;
        [self.sponsoredIcon updateImageWithUrl:self.item.news.sponsoredIcon defaultImage:[UIImage themeImageNamed:@"icohome_quan_v5.png"] showVideo:NO];
        [self.bgPic updateImageWithUrl:self.item.news.bgPic defaultImage:[UIImage themeImageNamed:@"icohome_quanpic_v5.png"] showVideo:NO];
    } else {
        //红包
        self.littleRedPacketImg.hidden = NO;
        self.redPacketDes.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText6Color];
        self.redPacketDes.font = [UIFont systemFontOfSizeType:UIFontSizeTypeC];
        self.redPacketTitle.left = self.sponsoredIcon.right + 12;
        self.redPacketDes.left = self.sponsoredIcon.right + 12;
        self.redPacketDetail.frame = CGRectMake(self.bgPic.right - 90, self.redPacketDes.top, 65, 15);
        [self.redPacketDetail setTitle:@"了解详情" forState:UIControlStateNormal];
        [self.redPacketDetail setTitle:@"了解详情" forState:UIControlStateHighlighted];
        self.redPacketDetail.titleLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        [self.redPacketDetail addTarget:self action:@selector(openNews) forControlEvents:UIControlEventTouchUpInside];

        self.redPacketTitle.text = self.item.news.redPacketTitle;
        self.redPacketDes.text = self.item.news.abstract;
        [self.sponsoredIcon updateImageWithUrl:self.item.news.sponsoredIcon defaultImage:[UIImage themeImageNamed:@"icohongbao_placeholder_v5.png"] showVideo:NO];
        [self.bgPic updateImageWithUrl:self.item.news.bgPic defaultImage:[UIImage themeImageNamed:@"icohome_quanpic_v5.png"] showVideo:NO];
    }
}

@end
