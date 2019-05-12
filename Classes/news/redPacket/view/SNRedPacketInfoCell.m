//
//  SNRedPacketInfoCell.m
//  sohunews
//
//  Created by wangyy on 16/3/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRedPacketInfoCell.h"
#import "UIFont+Theme.h"
#import "SNCellImageView.h"
#import "SNDevice.h"

@interface SNRedPacketInfoCell ()

@property (nonatomic, strong) SNCellImageView *headImage;
@property (nonatomic, strong) UILabel *headTitle;
@property (nonatomic, strong) UILabel *moneyNumber;
@property (nonatomic, strong) UILabel *moneyTitle;
@property (nonatomic, strong) UILabel *otherTitle;

@end


@implementation SNRedPacketInfoCell

@synthesize headImage = _headImage;
@synthesize headTitle = _headTitle;
@synthesize moneyNumber = _moneyNumber;
@synthesize moneyTitle = _moneyTitle;
@synthesize otherTitle = _otherTitle;
@synthesize redPacketType = _redPacketType;

- (void)dealloc{
     //(_headImage);
     //(_headTitle);
     //(_moneyNumber);
     //(_moneyTitle);
     //(_otherTitle);
    
}

- (id)initWithFrame:(CGRect)frame redPacketType:(SNRedPacketType)packetType {
    self = [super initWithFrame:frame];
    if (self) {
        self.redPacketType = packetType;
        [self initHeadImage];
        [self initHeadTitle];
        [self initMoneyNumber];
        [self initMoneyTitle];
        [self initOtherTitle];
    }
    
    return self;
}

- (void)initHeadImage{
    CGFloat width = 33;
    if ([SNDevice sharedInstance].isPlus) {
        width = 40;
    }
    self.headImage = [[SNCellImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - width)/2, 0, width, width) alpha:1.0];
    [self.headImage setDefaultImage:[UIImage themeImageNamed:@"icohongbao_placeholder_v5.png"] ];
    [self addSubview:self.headImage];
}

- (void)initHeadTitle{
    self.headTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, self.headImage.bottom + 5, self.frame.size.width - 32, 13)];
    self.headTitle.backgroundColor = [UIColor clearColor];
    self.headTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText2Color];
    self.headTitle.font = [UIFont systemFontOfSizeType:UIFontSizeTypeA];
    self.headTitle.textAlignment = NSTextAlignmentCenter;
//    self.headTitle.text = @"headTitle";
    [self addSubview:self.headTitle];
}

- (void)initMoneyNumber{
    NSString *colorStr = kRedPacketMoneyColor ;
    if (self.redPacketType == SNRedPacketTask) {
        colorStr = kTaskRedPacketMoneyColor;
    }
    self.moneyNumber = [[UILabel alloc] initWithFrame:CGRectMake(16, self.headTitle.bottom + 3, self.frame.size.width - 32, 27)];
    self.moneyNumber.backgroundColor = [UIColor clearColor];
    self.moneyNumber.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:colorStr];
    self.moneyNumber.textAlignment = NSTextAlignmentCenter;
//    self.moneyNumber.text = @"moneyNumber";
    [self addSubview:self.moneyNumber];
}

- (void)initMoneyTitle{
    NSString *colorStr = kThemeText2Color ;
    self.moneyTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, self.moneyNumber.bottom + 4, self.frame.size.width - 32, 30)];
    self.moneyTitle.backgroundColor = [UIColor clearColor];
    self.moneyTitle.textAlignment = NSTextAlignmentCenter;
    self.moneyTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:colorStr];
    self.moneyTitle.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    self.moneyTitle.numberOfLines = 0;
    self.moneyTitle.lineBreakMode = NSLineBreakByTruncatingTail;
//     self.moneyTitle.text = @"moneyTitle";
    [self addSubview:self.moneyTitle];
}

- (void)initOtherTitle{
    NSString *colorStr = kThemeText2Color ;
    self.otherTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, self.moneyTitle.bottom + 2, self.frame.size.width - 32, 15)];
    self.otherTitle.backgroundColor = [UIColor clearColor];
    self.otherTitle.textAlignment = NSTextAlignmentCenter;
    self.otherTitle.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:colorStr];
    self.otherTitle.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    self.otherTitle.hidden = YES;
//    self.otherTitle.text = @"otherTitle";
    [self addSubview:self.otherTitle];

}

- (void)updateContentView:(SNRedPacketItem *)redPacketItem{
    [self.headImage updateImageWithUrl:redPacketItem.sponsoredIcon defaultImage:[UIImage themeImageNamed:@"icohongbao_placeholder_v5.png"] showVideo:NO];
    self.headTitle.text = redPacketItem.sponsoredTitle;
    
    NSString *string = [NSString stringWithFormat:@"%@元",redPacketItem.moneyValue];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSizeType:UIFontSizeTypeL] range:NSMakeRange(0, string.length -1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSizeType:UIFontSizeTypeC] range:NSMakeRange(string.length -1, 1)];
    self.moneyNumber.attributedText = str;
     //(str);
    
    self.moneyTitle.text = redPacketItem.moneyTitle;
    if (self.redPacketType == SNRedPacketOther) {
        self.otherTitle.text = @"领取你的奖励红包";
        self.otherTitle.hidden = NO;
    }
    else{
        self.otherTitle.hidden = YES;
    }
}

@end
