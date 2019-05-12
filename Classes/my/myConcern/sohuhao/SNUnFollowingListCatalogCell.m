//
//  SNUnFollowingListCatalogCell.m
//  sohunews
//
//  Created by HuangZhen on 2017/6/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUnFollowingListCatalogCell.h"
#import "SNSohuHaoModel.h"

@interface SNUnFollowingListCatalogCell ()

@property (nonatomic, strong) UILabel * catalogLabel;

@end

@implementation SNUnFollowingListCatalogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    self.catalogLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kRecomFollowCatalogListViewWidth, 45)];
    self.catalogLabel.textColor = SNUICOLOR(kThemeText10Color);
    self.catalogLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    self.catalogLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.catalogLabel];
}

- (void)setContentWithChannel:(SNSohuHaoChannel *)channel {
    NSString * channelName = channel.name;
    self.catalogLabel.text = channelName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.catalogLabel.textColor = SNUICOLOR(kThemeRed1Color);
    }else{
        self.catalogLabel.textColor = SNUICOLOR(kThemeText10Color);
    }
}

@end
