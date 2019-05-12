//
//  SNRechargeHelpTableViewCell.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRechargeHelpTableViewCell.h"

@implementation SNRechargeHelpTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initContent];
    }
    return self;
}

- (void)initContent{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect screenRect = TTScreenBounds();
    UILabel * contentLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, screenRect.size.width, 30)];
    contentLabel1.text = @"购买书币前，您需要确认以下几点：";
    contentLabel1.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    contentLabel1.textColor = SNUICOLOR(kThemeText1Color);
    [self.contentView addSubview:contentLabel1];
    
    UILabel * contentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, screenRect.size.width, 100)];
    contentLabel2.text = @"1.您的手机没有越狱；\n2.搜狐新闻是从AppStore下载的；\n3.当前苹果账户和下载搜狐新闻时的账户为同一账户；\n4.苹果账户里余额充足；\n5.App购买项目的访问限制是打开状态（设置-通用-访问限制）";
    contentLabel2.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    contentLabel2.textColor = SNUICOLOR(kThemeText3Color);
    contentLabel2.top = contentLabel1.bottom;
    contentLabel2.numberOfLines = 0;
    [self.contentView addSubview:contentLabel2];
    
    UILabel * contentLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, screenRect.size.width, 30)];
    contentLabel3.text = @"若充值没有到账，请尝试以下操作";
    contentLabel3.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    contentLabel3.textColor = SNUICOLOR(kThemeText1Color);
    contentLabel3.top = contentLabel2.bottom;
    [self.contentView addSubview:contentLabel3];
    
    UILabel * contentLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, screenRect.size.width, 60)];
    contentLabel4.text = @"到【我-活动-我的书币-充值记录】查看有无充值失败的记录，若有，可以点击该条记录重试（重试时不会再次扣费），如下图所示：";
    contentLabel4.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    contentLabel4.textColor = SNUICOLOR(kThemeText3Color);
    contentLabel4.top = contentLabel3.bottom;
    contentLabel4.numberOfLines = 0;
    [self.contentView addSubview:contentLabel4];
    
    UIImage * example = [UIImage themeImageNamed:@""];
    UIImageView * exampleImage = [[UIImageView alloc] initWithImage:example];
    exampleImage.frame = CGRectMake(0, 0, example.size.width, example.size.height);
    exampleImage.centerX = self.contentView.centerX;
    exampleImage.top = contentLabel4.bottom + 5;
    [self.contentView addSubview:exampleImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
